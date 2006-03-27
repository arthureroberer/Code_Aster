      SUBROUTINE XCFACF(JPTINT,PTMAX,IPT,JAINT,LSN,LST,IGEOM,NNO,NDIM,
     &                                                          TYPMA)
      IMPLICIT NONE

      INTEGER       JPTINT,PTMAX,IPT,JAINT,IGEOM,NNO,NDIM
      REAL*8        LSN(NNO),LST(NNO)
      CHARACTER*8   TYPMA

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 27/03/2006   AUTEUR GENIAUT S.GENIAUT 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE GENIAUT S.GENIAUT
C              TROUVER LES PTS D'INTERSECTION ENTRE LE FOND DE FISSURE
C                 ET LES FACES POUR LES ELEMENTS EN FOND DE FISSURE
C
C     ENTREE
C       JPTINT   : ADRESSE DES COORDONNEES DES POINTS D'INTERSECTION
C       PTMAX    : NOMBRE MAX DE POINTS D'INTERSECTION
C       IPT      : COMPTEUR DE NOMBRE DE POINTS D'INTERSECTION
C       JAINT    : ADRESSE DES INFOS SUR LES ARETES ASSOCIEES
C       LSN      : VALEURS DE LA LEVEL SET NORMALE
C       LST      : VALEURS DE LA LEVEL SET TANGENTE
C       IGEOM    : ADRESSE DES COORDONNEES DES NOEUDS DE L'ELT PARENT
C       NNO      : NOMBRE DE NOEUDS DE L'ELEMENT
C       NDIM     : DIMENSION DE L'ESPACE
C       TYPMA    : TYPE DE LA MAILLE ASSOCIEE A L'ELEMENT
C
C     SORTIE
C       JPTINT   : ADRESSE DES COORDONNEES DES POINTS D'INTERSECTION
C       IPT      : COMPTEUR DE NOMBRE DE POINTS D'INTERSECTION
C       JAINT    : ADRESSE DES INFOS SUR LES ARETES ASSOCIEES
C
C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16             ZK16
      CHARACTER*24                      ZK24
      CHARACTER*32                               ZK32
      CHARACTER*80                                        ZK80
      COMMON  /KVARJE/ ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      REAL*8        R8MAEM,MAXLSN,MINLSN,MAXLST,MINLST,L(2,2),DETL
      REAL*8        R8PREM,LL(2,2),EPS1,EPS2,A(3),B(3),C(3),M(3)
      REAL*8        LONCAR,PADIST,DMIN,D
      INTEGER       I,FT(12,3),NBFT,IBID2(6,4),IBID,IFT,NA,NB,NC,J,JMIN

C ----------------------------------------------------------------------

      CALL JEMARQ()

C     INITIALISATION DES MIN ET MAX
      MAXLSN=-1.D0*R8MAEM()
      MINLSN=R8MAEM()
      MAXLST=-1.D0*R8MAEM()
      MINLST=R8MAEM()

C     RECHERCHE DU MIN ET MAX DES LEVEL SETS SUR LES NOEUDS
      DO 100 I=1,NNO
        MAXLSN=MAX(LSN(I),MAXLSN)
        MAXLST=MAX(LST(I),MAXLST)
        MINLSN=MIN(LSN(I),MINLSN)
        MINLST=MIN(LST(I),MINLST)
 100  CONTINUE

C     SI CE N'EST PAS UN ELEMENT EN FOND DE FISSURE, ON SORT
      IF (MINLSN*MAXLSN.GE.0.D0.OR.MINLST*MAXLST.GE.0.D0) GOTO 9999

C     RECHERCHE DES INTERSECTION ENTRE LE FOND DE FISSURE ET LES FACES
C     (COMME DANS XPTFON.F)

      CALL CONFAC(TYPMA,FT,NBFT,IBID2,IBID)

C     BOUCLE SUR LES FACES TRIANGULAIRES
      DO 410 IFT=1,NBFT

        NA=FT(IFT,1)
        NB=FT(IFT,2)
        NC=FT(IFT,3)
        L(1,1)=LSN(NB)-LSN(NA)
        L(1,2)=LSN(NC)-LSN(NA)
        L(2,1)=LST(NB)-LST(NA)
        L(2,2)=LST(NC)-LST(NA)
        DETL=L(1,1)*L(2,2)-L(2,1)*L(1,2)
        IF (ABS(DETL).LE.R8PREM()) GOTO 410
        LL(1,1)=L(2,2)/DETL
        LL(2,2)=L(1,1)/DETL
        LL(1,2)=-1*L(1,2)/DETL
        LL(2,1)=-1*L(2,1)/DETL
        EPS1=-LL(1,1)*LSN(NA)-LL(1,2)*LST(NA)
        EPS2=-LL(2,1)*LSN(NA)-LL(2,2)*LST(NA)
        DO 411 I=1,NDIM
          A(I)=ZR(IGEOM-1+NDIM*(NA-1)+I)
          B(I)=ZR(IGEOM-1+NDIM*(NB-1)+I)
          C(I)=ZR(IGEOM-1+NDIM*(NC-1)+I)
          M(I)=A(I)+EPS1*(B(I)-A(I))+EPS2*(C(I)-A(I))
 411    CONTINUE

C       ON SORT SI M N'EST DANS LE TRIANGLE
        IF (0.D0.GT.EPS1.OR.EPS1.GT.1.D0 .OR.
     &      0.D0.GT.EPS2.OR.EPS2.GT.1.D0 .OR.
     &      0.D0.GT.(EPS1+EPS2).OR.(EPS1+EPS2).GT.1.D0) GOTO 410

C       LONGUEUR CARACTERISTIQUE
        LONCAR=(PADIST(NDIM,A,B)+PADIST(NDIM,A,C)+PADIST(NDIM,B,C))/3.D0

C       ON AJOUTE A LA LISTE LE POINT M
        CALL XAJPIN(JPTINT,PTMAX,IPT,IBID,M,LONCAR,JAINT,-1,-1,0.D0)

 410  CONTINUE
  
C     POUR UN RACCORD CONTACT (BOOK VI 17/03/2006)
C     ON MET LES LAMBDAS DU FOND EGAUX AU LAMBDA NODAL LE PLUS PROCHE
      DO 510 I=1,IPT

C       ON SE RESTREINT AUX LAMBDA DU FOND
        IF (ZR(JAINT-1+4*(I-1)+1).NE.-1.D0) GOTO 510
 
C       RECHERCHE DU LAMBDA NODAL LE PLUS PROCHE 
        DMIN=R8MAEM()
        DO 511 J=1,IPT
          IF (J.EQ.I) GOTO 511
          D=PADIST(NDIM,ZR(JPTINT-1+NDIM*(I-1)+1),
     &                  ZR(JPTINT-1+NDIM*(J-1)+1))
          IF (D.LE.DMIN) THEN
             DMIN=D
             JMIN=J
          ENDIF
 511    CONTINUE
 
C       COPIE DU VECTEUR JAINT 
        DO 512 J=1,4
          ZR(JAINT-1+4*(I-1)+J)=ZR(JAINT-1+4*(JMIN-1)+J)
 512    CONTINUE
 
 510  CONTINUE
 
C--------------------------- FIN -------------------------------------- 
 
 9999 CONTINUE

      CALL JEDEMA()
      END
