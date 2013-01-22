      SUBROUTINE  XMASE2(ELREFP,NDIM,COORSE,IGEOM,HE,DDLH,DDLC,NFE,
     &                   BASLOC,NNOP,NPG,IMATE,
     &                   LSN,LST,MATUU)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER       NDIM,IGEOM,IMATE,NNOP,NPG,DDLH,DDLC,NFE
      CHARACTER*8   ELREFP
      REAL*8        BASLOC(6*NNOP),HE,COORSE(*)
      REAL*8        LSN(NNOP),LST(NNOP),MATUU(*)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 21/01/2013   AUTEUR DELMAS J.DELMAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRS_1404
C
C     BUT:  CALCUL  DE L'OPTION MASS_MECA AVEC X-FEM EN 2D
C
C
C IN  ELREFP  : ELEMENT DE REFERENCE PARENT
C IN  NDIM    : DIMENSION DE L'ESPACE
C IN  COORSE  : COORDONNEES DES SOMMETS DU SOUS-ELEMENT
C IN  IGEOM   : COORDONNEES DES NOEUDS DE L'ELEMENT PARENT
C IN  HE      : VALEUR DE LA FONCTION HEAVISIDE SUR LE SOUS-ELT
C IN  DDLH    : NOMBRE DE DDL HEAVYSIDE (PAR NOEUD)
C IN  DDLC    : NOMBRE DE DDL DE CONTACT (PAR NOEUD)
C IN  NFE     : NOMBRE DE FONCTIONS SINGULI�RES D'ENRICHISSEMENT
C IN  BASLOC  : BASE LOCALE AU FOND DE FISSURE AUX NOEUDS
C IN  NNOP    : NOMBRE DE NOEUDS DE L'ELEMENT PARENT
C IN  NPG     : NOMBRE DE POINTS DE GAUSS DU SOUS-ELEMENT
C IN  TYPMOD  : TYPE DE MODELISATION
C IN  IMATE   : MATERIAU CODE
C IN  LGPG    : "LONGUEUR" DES VARIABLES INTERNES POUR 1 POINT DE GAUSS
C               CETTE LONGUEUR EST UN MAJORANT DU NBRE REEL DE VAR. INT.
C IN  LSN     : VALEUR DE LA LEVEL SET NORMALE AUX NOEUDS PARENTS
C IN  LST     : VALEUR DE LA LEVEL SET TANGENTE AUX NOEUDS PARENTS
C IN  IDECPG  : POSITION DANS LA FAMILLE 'XFEM' DU 1ER POINT DE GAUSS
C               DU SOUS ELEMENT COURRANT (EN FAIT IDECPG+1)
C OUT MATUU   : MATRICE DE MASSE PROFIL
C
C ......................................................................
C
C
C
C
      INTEGER RETOUR
      INTEGER KPG,KK,N,I,M,J,J1,KKD,INO,IG,IRET,IBID
      INTEGER NNO,NNOS,NPGBIS,DDLT,DDLD,CPT,NDIMB
      INTEGER JCOOPG,JDFD2,JGANO,IDFDE,IVF,IPOIDS

      REAL*8 F(3,3),EPS(6),RHO
      REAL*8 FE(4),BASLOG(6)
      REAL*8 XG(NDIM),XE(NDIM),FF(NNOP),JAC,LSNG,LSTG
      REAL*8 RBID1(10),RBID2(10)
      REAL*8 DFDI(NNOP,NDIM),DGDGL(4,3)
      REAL*8 ENR(NNOP,NDIM+DDLH+NDIM*NFE),GRAD(3,3)
      REAL*8 DEPL0(NDIM+DDLH+NDIM*NFE+DDLC,NNOP)

      CHARACTER*16 PHENOM

C--------------------------------------------------------------------

C     NOMBRE DE DDL DE DEPLACEMENT � CHAQUE NOEUD SOMMET
      DDLD=NDIM+DDLH+NDIM*NFE

C     NOMBRE DE DDL TOTAL (DEPL+CONTACT) � CHAQUE NOEUD SOMMET
      DDLT=DDLD+DDLC

      CALL ELREF5('TR3','XINT',NDIMB,NNO,NNOS,NPGBIS,IPOIDS,JCOOPG,IVF,
     &                  IDFDE,JDFD2,JGANO)
      CALL ASSERT(NPG.EQ.NPGBIS.AND.NDIM.EQ.NDIMB)


C - CALCUL POUR CHAQUE POINT DE GAUSS
      DO 10 KPG=1,NPG

C       COORDONNEES DU PT DE GAUSS DANS LE REPERE REEL : XG
        CALL VECINI(NDIM,0.D0,XG)
        DO 110 I=1,NDIM
          DO 111 N=1,NNO
          XG(I)=XG(I)+ZR(IVF-1+NNO*(KPG-1)+N)*COORSE(NDIM*(N-1)+I)
 111      CONTINUE
 110    CONTINUE

        DO 300 I=1,NNOP
          DO 301 J=1,DDLT
            DEPL0(J,I)=0.D0
 301      CONTINUE
 300    CONTINUE

C       JUSTE POUR CALCULER LES FF
        CALL REERE3(ELREFP,NNOP,IGEOM,XG,DEPL0,.FALSE.,NDIM,HE,
     &              IBID,IBID,DDLH,NFE,DDLT,FE,DGDGL,'NON',
     &              XE,FF,DFDI,F,EPS,GRAD)

        IF (NFE.GT.0) THEN
C         BASE LOCALE AU POINT DE GAUSS
          CALL VECINI(6,0.D0,BASLOG)
          LSNG = 0.D0
          LSTG = 0.D0
          DO 113 INO=1,NNOP
            LSNG = LSNG + LSN(INO) * FF(INO)
            LSTG = LSTG + LST(INO) * FF(INO)
            DO 114 I=1,6
              BASLOG(I) = BASLOG(I) + BASLOC(6*(INO-1)+I) * FF(INO)
 114        CONTINUE
 113      CONTINUE
C
C         FONCTION D'ENRICHISSEMENT AU POINT DE GAUSS ET LEURS DERIVEES
          CALL XCALF2(HE,LSNG,LSTG,BASLOG,FE,DGDGL,IRET)
C         ON A PAS PU CALCULER LES DERIVEES DES FONCTIONS SINGULIERES
C         CAR ON SE TROUVE SUR LE FOND DE FISSURE
          CALL ASSERT(IRET.NE.0)

        ENDIF
C
C       COORDONN�ES DU POINT DE GAUSS DANS L'ELEMENT DE REF PARENT : XE
C       ET CALCUL DE FF, DFDI, ET EPS

        CALL REERE3(ELREFP,NNOP,IGEOM,XG,DEPL0,.FALSE.,NDIM,HE,
     &              IBID,IBID,DDLH,NFE,DDLT,FE,DGDGL,'DFF',
     &              XE,FF,DFDI,F,EPS,GRAD)

C - CALCUL DES ELEMENTS GEOMETRIQUES

C--------CALCUL DES FONCTIONS ENRICHIES--------------------------
        DO 120 N=1,NNOP
          CPT=0
C         FONCTIONS DE FORME CLASSIQUES
          DO 121 I=1,NDIM
            CPT=CPT+1
            ENR(N,I) = FF(N)
 121      CONTINUE
C         ENRICHISSEMENT PAR HEAVYSIDE
          DO 122 I=1,DDLH
            CPT=CPT+1
            ENR(N,CPT) =  ENR(N,I) * HE
 122      CONTINUE
C         ENRICHISSEMENT PAR LES NFE FONTIONS SINGULI�RES
          DO 124 IG=1,NFE
            DO 125 I=1,NDIM
              CPT=CPT+1
              ENR(N,CPT)=FF(N)*FE(IG)
 125        CONTINUE
 124      CONTINUE

          CALL ASSERT(CPT.EQ.DDLD)

 120    CONTINUE

C       POUR CALCULER LE JACOBIEN DE LA TRANSFO SSTET->SSTET REF
C       ON ENVOIE DFDM2D AVEC LES COORD DU SS-ELT
        CALL DFDM2D(NNO,KPG,IPOIDS,IDFDE,COORSE,RBID1,RBID2,JAC)


C       ON RECUPERE LA MASSE VOLUMIQUE

        CALL RCCOMA(IMATE,'ELAS',1,PHENOM,RETOUR)
        CALL RCVALB('RIGI',KPG,1,'+',IMATE,' ',PHENOM,0,' ',0.D0,
     &             1,'RHO',RHO,RETOUR,1)


        DO 230 N=1,NNOP
          DO 231 I=1,DDLD
            KKD = (DDLT*(N-1)+I-1) * (DDLT*(N-1)+I) /2
            DO 240 J=1,DDLD
              DO 241 M=1,N
                IF (M.EQ.N) THEN
                  J1 = I
                ELSE
                  J1 = DDLD
                ENDIF
                IF (J.LE.J1) THEN
                  KK = KKD + DDLT*(M-1)+J
                  MATUU(KK) = MATUU(KK)+ENR(N,I)*ENR(M,J)*JAC*RHO
                END IF
C
 241          CONTINUE
 240        CONTINUE
 231      CONTINUE
 230    CONTINUE

 10   CONTINUE

      END
