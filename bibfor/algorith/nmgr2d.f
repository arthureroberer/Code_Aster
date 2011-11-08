       SUBROUTINE  NMGR2D(FAMI,NNO,NPG,IPOIDS,IVF,VFF,IDFDE,GEOMI,
     &                    TYPMOD,OPTION,IMATE,COMPOR,LGPG,CRIT,
     &                    INSTAM,INSTAP,
     &                    DEPLM,DEPLP,
     &                    ANGMAS,
     &                    SIGM,VIM,MATSYM,
     &                    DFDI,
     &                    PFF,DEF,SIGP,VIP,MATUU,VECTU,CODRET)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 07/11/2011   AUTEUR PROIX J-M.PROIX 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE VABHHTS J.PELLET
C TOLE CRP_21

       IMPLICIT NONE

       INTEGER       NNO, NPG, IMATE, LGPG,  CODRET,COD(9)
       INTEGER       IPOIDS,IVF,IDFDE
       CHARACTER*(*) FAMI
       CHARACTER*8   TYPMOD(*)
       CHARACTER*16  OPTION, COMPOR(4)

       REAL*8        INSTAM,INSTAP,ANGMAS(3),DETFM
       REAL*8        GEOMI(2,NNO), CRIT(3)
       REAL*8        DFDI(NNO,2),DEPLM(2*NNO),DEPLP(2*NNO)
       REAL*8        PFF(4,NNO,NNO),DEF(4,NNO,2),VFF(*)
       REAL*8        SIGM(4,NPG),SIGP(4,NPG)
       REAL*8        VIM(LGPG,NPG),VIP(LGPG,NPG)
       REAL*8        MATUU(*),VECTU(2*NNO)
       LOGICAL       MATSYM

C.......................................................................
C
C     BUT:  CALCUL  DES OPTIONS RIGI_MECA_TANG, RAPH_MECA ET FULL_MECA
C           EN GRANDE ROTATION ET PETITE DEFORMATION EN 2D
C.......................................................................
C IN  NNO     : NOMBRE DE NOEUDS DE L'ELEMENT
C IN  NPG     : NOMBRE DE POINTS DE GAUSS
C IN  POIDSG  : POIDS DES POINTS DE GAUSS
C IN  VFF     : VALEUR  DES FONCTIONS DE FORME
C IN  DFDE    : DERIVEE DES FONCTIONS DE FORME ELEMENT DE REFERENCE
C IN  DFDK    : DERIVEE DES FONCTIONS DE FORME ELEMENT DE REFERENCE
C IN  GEOMI   : COORDONEES DES NOEUDS SUR CONFIG INITIALE
C IN  TYPMOD  : TYPE DE MODEELISATION
C IN  OPTION  : OPTION DE CALCUL
C IN  IMATE   : MATERIAU CODE
C IN  COMPOR  : COMPORTEMENT
C IN  LGPG    : "LONGUEUR" DES VARIABLES INTERNES POUR 1 POINT DE GAUSS
C               CETTE LONGUEUR EST UN MAJORANT DU NBRE REEL DE VAR. INT.
C IN  CRIT    : CRITERES DE CONVERGENCE LOCAUX
C IN  INSTAM  : INSTANT PRECEDENT
C IN  INSTAP  : INSTANT DE CALCUL
C IN  DEPLM   : DEPLACEMENT A L'INSTANT PRECEDENT
C IN  DEPLP   : DEPLACEMENT A L'INSTANT COURANT
C IN  ANGMAS  : LES TROIS ANGLES DU MOT_CLEF MASSIF (AFFE_CARA_ELEM)
C IN  SIGM    : CONTRAINTES A L'INSTANT PRECEDENT
C IN  VIM     : VARIABLES INTERNES A L'INSTANT PRECEDENT
C IN  MATSYM  : VRAI SI LA MATRICE DE RIGIDITE EST SYMETRIQUE
C OUT DFDI    : DERIVEE DES FONCTIONS DE FORME  AU DERNIER PT DE GAUSS
C OUT DEF     : PRODUIT DER. FCT. FORME PAR F   AU DERNIER PT DE GAUSS
C OUT SIGP    : CONTRAINTES DE CAUCHY (RAPH_MECA ET FULL_MECA)
C OUT VIP     : VARIABLES INTERNES    (RAPH_MECA ET FULL_MECA)
C OUT MATUU   : MATRICE DE RIGIDITE PROFIL (RIGI_MECA_TANG ET FULL_MECA)
C OUT VECTU   : FORCES NODALES (RAPH_MECA ET FULL_MECA)
C.......................................................................
C

      LOGICAL GRAND,AXI,CPLAN

      INTEGER KPG,J

      REAL*8 DSIDEP(6,6),F(3,3),FM(3,3),EPSM(6),EPSP(6),DEPS(6)
      REAL*8 R,SIGMA(6),SIGMN(6),DETF,POIDS,MAXEPS
      REAL*8 ELGEOM(10,9),R8BID,RAC2

C     INITIALISATION

      RAC2   = SQRT(2.D0)
      GRAND  = .TRUE.
      AXI    = TYPMOD(1) .EQ. 'AXIS'
      CPLAN  = TYPMOD(1) .EQ. 'C_PLAN'

C     CALCUL DES ELEMENTS GEOMETRIQUES SPECIFIQUES AU COMPORTEMENT

      CALL LCEGEO(NNO   ,NPG   ,IPOIDS,IVF   ,IDFDE ,
     &            GEOMI ,TYPMOD,COMPOR,2     ,DFDI  ,
     &            DEPLM,DEPLP,ELGEOM)

C     INITIALISATION CODES RETOURS

      DO 1955 KPG=1,NPG
        COD(KPG)=0
1955  CONTINUE

C     CALCUL POUR CHAQUE POINT DE GAUSS

      DO 800 KPG=1,NPG

C        CALCUL DES ELEMENTS GEOMETRIQUES

C        CALCUL DE EPSM EN T- POUR LDC

         CALL R8INIR(6, 0.D0, EPSM ,1)
         CALL R8INIR(6, 0.D0, EPSP ,1)
         CALL NMGEOM(2,NNO,AXI,GRAND,GEOMI,KPG,IPOIDS,
     &              IVF,IDFDE,DEPLM,.TRUE.,POIDS,DFDI,
     &                     FM,EPSM,R)

C        CALCUL DE F, EPSP, DFDI, R ET POIDS EN T+

         CALL NMGEOM(2,NNO,AXI,GRAND,GEOMI,KPG,IPOIDS,
     &              IVF,IDFDE,DEPLP,.TRUE.,POIDS,DFDI,
     &                     F,EPSP,R)

C        CALCUL DE DEPS POUR LDC

         MAXEPS=0.D0
         DO 25 J = 1,6
            DEPS (J)=EPSP(J)-EPSM(J)
            MAXEPS=MAX(MAXEPS,ABS(EPSP(J)))
25       CONTINUE

C        VERIFICATION QUE EPS RESTE PETIT
         IF (MAXEPS.GT.0.05D0) THEN
            IF( COMPOR(1)(1:4).NE.'ELAS') THEN
               CALL U2MESR('A','COMPOR2_9',1,MAXEPS)
            ENDIF
         ENDIF

C        LOI DE COMPORTEMENT
C        CONTRAINTE CAUCHY -> CONTRAINTE LAGRANGE POUR LDC EN T-

         IF (CPLAN) FM(3,3) = SQRT(ABS(2.D0*EPSM(3)+1.D0))
         CALL NMDETF(2,FM,DETFM)
         CALL PK2SIG(2,FM,DETFM,SIGMN,SIGM(1,KPG),-1)

         SIGMN(4) = SIGMN(4)*RAC2

C        INTEGRATION

         CALL NMCOMP(FAMI,KPG,1,2,TYPMOD,IMATE,COMPOR,CRIT,
     &            INSTAM,INSTAP,
     &            6,EPSM,DEPS,
     &            6,SIGMN,VIM(1,KPG),
     &            OPTION,
     &            ANGMAS,
     &            10,ELGEOM(1,KPG),
     &            SIGMA,VIP(1,KPG),36,DSIDEP,1,R8BID,COD(KPG))


         IF(COD(KPG).EQ.1) THEN
            GOTO 1956
         ENDIF

C        CALCUL DE LA MATRICE DE RIGIDITE ET DES FORCES INTERIEURES

         CALL  NMGRTG(2,NNO,POIDS,KPG,VFF,DFDI,DEF,PFF,OPTION,AXI,R,
     &                FM,F,DSIDEP,SIGMN,SIGMA,MATSYM,MATUU,VECTU)


C        CALCUL DES CONTRAINTES DE CAUCHY, CONVERSION LAGRANGE -> CAUCHY

         IF (OPTION(1:4).EQ.'RAPH' .OR. OPTION(1:4).EQ.'FULL') THEN
            IF (CPLAN) F(3,3) = SQRT(ABS(2.D0*EPSP(3)+1.D0))
            CALL NMDETF(2,F,DETF)
            CALL PK2SIG(2,F,DETF,SIGMA,SIGP(1,KPG),1)
         ENDIF

800   CONTINUE

1956  CONTINUE

C - SYNTHESE DES CODES RETOURS

      CALL CODERE(COD,NPG,CODRET)
      END
