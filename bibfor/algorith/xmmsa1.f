      SUBROUTINE XMMSA1(NDIM,NNO,NNOS,NNOL,NNOF,PLA,
     &                    IPGF,IVFF,FFC,FFP,IDEPD,IDEPM,
     &                    NFH,NOEUD,ND,TAU1,TAU2,SINGU,RR ,
     &                    IFA,CFACE,LACT,DDLS,DDLM,RHOTK,
     &                    CSTAFR,CPENFR,LPENAF,
     &                    P,ADHER,KNP,PTKNP,IK)

      IMPLICIT NONE
      INTEGER     NDIM,NNO,NNOS,NNOL,NNOF,IVFF,IPGF
      INTEGER     NFH,DDLS,DDLM,CFACE(5,3),IFA
      INTEGER     SINGU,PLA(27),LACT(8),IDEPD,IDEPM
      REAL*8      RR,RHOTK,CSTAFR,CPENFR,P(3,3),IK(3,3)
      REAL*8      FFC(8),FFP(27),TAU1(3),TAU2(3),PTKNP(3,3)
      REAL*8      KNP(3,3),ND(3)
      LOGICAL     NOEUD,LPENAF,ADHER

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/01/2011   AUTEUR MASSIN P.MASSIN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY  
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY  
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR     
C (AT YOUR OPTION) ANY LATER VERSION.                                   
C                                                                       
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT   
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF            
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU      
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.                              
C                                                                       
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE     
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,         
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================

C TOLE CRP_21
C
C ROUTINE CONTACT (METHODE XFEM HPP - CALCUL ELEM.)
C
C --- CALCUL DES INCREMENTS - D�PLACEMENTS & 
C --- SEMI-MULTIPLICATEUR DE FROTTEMENT
C      
C ----------------------------------------------------------------------
C
C IN  NDIM   : DIMENSION DE L'ESPACE
C IN  NNO    : NOMBRE DE NOEUDS DE L'ELEMENT DE REF PARENT
C IN  NNOS   : NOMBRE DE NOEUDS SOMMET DE L'ELEMENT DE REF PARENT
C IN  NNOL   : NOMBRE DE NOEUDS PORTEURS DE DDLC
C IN  NNOF   : NOMBRE DE NOEUDS DE LA FACETTE DE CONTACT
C IN  PLA    : PLACE DES LAMBDAS DANS LA MATRICE
C IN  IPGF   : NUM�RO DU POINTS DE GAUSS
C IN  IVFF   : ADRESSE DANS ZR DU TABLEAU FF(INO,IPG)
C IN  FFC    : FONCTIONS DE FORME DE L'ELEMENT DE CONTACT
C IN  FFP    : FONCTIONS DE FORME DE L'ELEMENT PARENT
C IN  IDEPD  :
C IN  IDEPM  :
C IN  NFH    : NOMBRE DE FONCTIONS HEAVYSIDE
C IN  NOEUD  : INDICATEUR FORMULATION (T=NOEUDS , F=ARETE)
C IN  TAU1   : TANGENTE A LA FACETTE AU POINT DE GAUSS
C IN  TAU2   : TANGENTE A LA FACETTE AU POINT DE GAUSS
C IN  SINGU  : 1 SI ELEMENT SINGULIER, 0 SINON
C IN  RR     : DISTANCE AU FOND DE FISSURE
C IN  IFA    : INDICE DE LA FACETTE COURANTE
C IN  CFACE  : CONNECTIVIT� DES NOEUDS DES FACETTES
C IN  LACT   : LISTE DES LAGRANGES ACTIFS
C IN  DDLS   : NOMBRE DE DDL (DEPL+CONTACT) � CHAQUE NOEUD SOMMET
C IN  DDLM   : NOMBRE DE DDL A CHAQUE NOEUD MILIEU
C IN  RHOTK  :
C IN  CSTAFR : COEFFICIENTS DE STABILISATION DU FROTTEMENT
C IN  CPENFR : COEFFICIENTS DE PENALISATION DU FROTTEMENT
C IN  LPENAF : INDICATEUR DE PENALISATION DU FROTTEMENT
C IN  P      :
C OUT ADHER  :
C OUT KNP    : PRODUIT KN.P
C OUT PTKNP  : MATRICE PT.KN.P
C OUT IK     :
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX --------------------
C
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)

C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX --------------------
C
      INTEGER I,J,NLI,INO,IN,PLI
      REAL*8  FFI,LAMB1(3),R3(3),VITANG(3),KN(3,3),SAUT(3)
C
C ----------------------------------------------------------------------
C
C --- INITIALISATION
      CALL VECINI(3,0.D0,SAUT)
      CALL VECINI(3,0.D0,LAMB1)
      CALL MATINI(3,3,0.D0,PTKNP)
      CALL MATINI(3,3,0.D0,P)
      CALL MATINI(3,3,0.D0,KNP)
      CALL MATINI(3,3,0.D0,KN)
C
      CALL XMAFR1(NDIM,ND,P)
C
      DO 154 INO=1,NNO
        CALL INDENT(INO,DDLS,DDLM,NNOS,IN)
C
        DO 155 J=1,NFH*NDIM
          SAUT(J) = SAUT(J) - 2.D0 * FFP(INO) *
     &    ZR(IDEPD-1+IN+NDIM+J)
 155    CONTINUE
        DO 156 J = 1,SINGU*NDIM
          SAUT(J) = SAUT(J) - 2.D0 * FFP(INO) * RR *
     &    ZR(IDEPD-1+IN+NDIM*(1+NFH)+J)
 156    CONTINUE
 154  CONTINUE

      DO 158 I=1,NNOL
        PLI=PLA(I)

        IF (NOEUD) THEN
          FFI=FFC(I)
          NLI=LACT(I)
          IF (NLI.EQ.0) GOTO 158
        ELSE
          FFI=ZR(IVFF-1+NNOF*(IPGF-1)+I)
          NLI=CFACE(IFA,I)
        ENDIF

        DO 159 J=1,NDIM
          LAMB1(J)=LAMB1(J) + FFI * TAU1(J) *
     &    (ZR(IDEPD-1+PLI+1)+ZR(IDEPM-1+PLI+1))

          IF (NDIM.EQ.3)
     &      LAMB1(J)=LAMB1(J) + FFI * TAU2(J) *
     &               (ZR(IDEPD-1+PLI+2) + ZR(IDEPM-1+PLI+2))
 159    CONTINUE
 158  CONTINUE

C
C --- TEST DE L'ADHERENCE ET CALCUL DES MATRICES DE FROTTEMENT UTILES
C
      CALL XADHER(P,SAUT,LAMB1,RHOTK,CSTAFR,CPENFR,LPENAF,
     &                     VITANG,R3,KN,PTKNP,IK,ADHER)
C
      CALL PROMAT(KN,3,NDIM,NDIM,P,3,NDIM,NDIM,KNP)
C
      END
