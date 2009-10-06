       SUBROUTINE  NMGR2D(FAMI,NNO,NPG,IPOIDS,IVF,IDFDE,GEOMI,TYPMOD,
     &                    OPTION,IMATE,COMPOR,LGPG,CRIT,
     &                    INSTAM,INSTAP,
     &                    DEPLM,DEPLP,
     &                    ANGMAS,
     &                    SIGM,VIM,MATSYM,
     &                    DFDI,
     &                    PFF,DEF,SIGP,VIP,MATUU,VECTU,CODRET)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 06/10/2009   AUTEUR GENIAUT S.GENIAUT 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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

       REAL*8        INSTAM,INSTAP,ANGMAS(3)
       REAL*8        GEOMI(2,NNO), CRIT(3)
       REAL*8        DEPLM(1:2,1:NNO),DEPLP(1:2,1:NNO),DFDI(NNO,2)
       REAL*8        PFF(4,NNO,NNO),DEF(4,NNO,2)
       REAL*8        SIGM(4,NPG),SIGP(4,NPG)
       REAL*8        VIM(LGPG,NPG),VIP(LGPG,NPG)
       REAL*8        MATUU(*),VECTU(2,NNO)
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
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER  ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      LOGICAL GRAND,AXI,RESI,RIGI,CPLAN

      INTEGER KPG,KK,KKD,N,I,M,J,J1,KL,PQ,NMAX

      REAL*8 DSIDEP(6,6),F(3,3),FM(3,3),FR(3,3),EPSM(6),EPSP(6),DEPS(6)
      REAL*8 R,SIGMA(6),SIGN(6),SIG(6),SIGG(4),FTF,DETF,FMM(3,3)
      REAL*8 POIDS,TMP1,TMP2
      REAL*8 ELGEOM(10,9),R8BID

      INTEGER INDI(4),INDJ(4)
      REAL*8  RIND(4),RIND1(4),RAC2
      DATA    INDI / 1 , 2 , 3 , 1 /
      DATA    INDJ / 1 , 2 , 3 , 2 /
      DATA    RIND / 0.5D0 , 0.5D0 , 0.5D0 , 0.70710678118655D0 /
      DATA    RIND1 / 0.5D0 , 0.5D0 , 0.5D0 , 1.D0 /

C 1 - INITIALISATION

      RAC2   = SQRT(2.D0)
      GRAND  = .TRUE.
      AXI    = TYPMOD(1) .EQ. 'AXIS'
      CPLAN  = TYPMOD(1) .EQ. 'C_PLAN'
      RESI = OPTION(1:4).EQ.'RAPH' .OR. OPTION(1:4).EQ.'FULL'
      RIGI = OPTION(1:4).EQ.'RIGI' .OR. OPTION(1:4).EQ.'FULL'

C 3 - CALCUL DES ELEMENTS GEOMETRIQUES SPECIFIQUES AU COMPORTEMENT

      CALL LCEGEO(NNO,NPG,IPOIDS,IVF,IDFDE,GEOMI,TYPMOD,OPTION,
     &            IMATE,COMPOR,LGPG,ELGEOM)

C 4 - INITIALISATION CODES RETOURS

      DO 1955 KPG=1,NPG
        COD(KPG)=0
1955  CONTINUE

C 5 - CALCUL POUR CHAQUE POINT DE GAUSS

      DO 800 KPG=1,NPG

C 5.2 - CALCUL DES ELEMENTS GEOMETRIQUES

C 5.2.1 - CALCUL DE EPSM EN T- POUR LDC

        DO 20 J = 1,6
          EPSM (J)=0.D0
          EPSP (J)=0.D0
20      CONTINUE
        CALL NMGEOM(2,NNO,AXI,GRAND,GEOMI,KPG,IPOIDS,
     &              IVF,IDFDE,DEPLM,POIDS,DFDI,
     &              FM,EPSM,R)

C 5.2.2 - CALCUL DE F, EPSP, DFDI, R ET POIDS EN T+

        CALL NMGEOM(2,NNO,AXI,GRAND,GEOMI,KPG,IPOIDS,
     &              IVF,IDFDE,DEPLP,POIDS,DFDI,
     &              F,EPSP,R)

C 5.2.3 - CALCUL DE DEPS POUR LDC

        DO 25 J = 1,6
         DEPS (J)=EPSP(J)-EPSM(J)
25      CONTINUE

C 5.2.4 - CALCUL DES PRODUITS SYMETR. DE F PAR N,

        IF (RESI) THEN
         DO 26 I=1,3
          DO 27 J=1,3
           FR(I,J) = F(I,J)
 27       CONTINUE
 26      CONTINUE
        ELSE
         DO 28 I=1,3
          DO 29 J=1,3
           FR(I,J) = FM(I,J)
 29       CONTINUE
 28      CONTINUE
        ENDIF

        DO 40 N=1,NNO
         DO 30 I=1,2
          DEF(1,N,I) =  FR(I,1)*DFDI(N,1)
          DEF(2,N,I) =  FR(I,2)*DFDI(N,2)
          DEF(3,N,I) =  0.D0
          DEF(4,N,I) = (FR(I,1)*DFDI(N,2) + FR(I,2)*DFDI(N,1))/RAC2
 30      CONTINUE
 40     CONTINUE

C 5.2.5 - TERME DE CORRECTION (3,3) AXI QUI PORTE EN FAIT SUR LE DDL 1

        IF (AXI) THEN
         DO 50 N=1,NNO
          DEF(3,N,1) = FR(3,3)*ZR(IVF+N+(KPG-1)*NNO-1)/R
 50      CONTINUE
        ENDIF

C 5.2.6 - CALCUL DES PRODUITS DE FONCTIONS DE FORMES (ET DERIVEES)

        IF (RIGI) THEN
         DO 125 N=1,NNO
          IF(MATSYM) THEN
           NMAX = N
          ELSE
           NMAX = NNO
          ENDIF
          DO 126 M=1,NMAX
           PFF(1,N,M) =  DFDI(N,1)*DFDI(M,1)
           PFF(2,N,M) =  DFDI(N,2)*DFDI(M,2)
           PFF(3,N,M) = 0.D0
           PFF(4,N,M) =(DFDI(N,1)*DFDI(M,2)+DFDI(N,2)*DFDI(M,1))/RAC2
 126      CONTINUE
 125     CONTINUE
        ENDIF

C 5.3 - LOI DE COMPORTEMENT
C 5.3.1 - CONTRAINTE CAUCHY -> CONTRAINTE LAGRANGE POUR LDC EN T-

        IF (CPLAN) FM(3,3) = SQRT(ABS(2.D0*EPSM(3)+1.D0))
        DETF = FM(3,3)*(FM(1,1)*FM(2,2)-FM(1,2)*FM(2,1))
        CALL MATINV('S',3,FM,FMM,R8BID)
        DO 127 PQ = 1,4
         SIGN(PQ) = 0.D0
         DO 128 KL = 1,4
          FTF = (FMM(INDI(PQ),INDI(KL))*FMM(INDJ(PQ),INDJ(KL)) +
     &          FMM(INDI(PQ),INDJ(KL))*FMM(INDJ(PQ),INDI(KL)))*RIND1(KL)
          SIGN(PQ) =  SIGN(PQ)+ FTF*SIGM(KL,KPG)
 128     CONTINUE
         SIGN(PQ) = SIGN(PQ)*DETF
 127    CONTINUE
        SIGN(4) = SIGN(4)*RAC2

C 5.3.2 - INTEGRATION

        CALL NMCOMP(FAMI,KPG,1,2,TYPMOD,IMATE,COMPOR,CRIT,
     &            INSTAM,INSTAP,
     &            EPSM,DEPS,
     &            SIGN,VIM(1,KPG),
     &            OPTION,
     &            ANGMAS,
     &            ELGEOM(1,KPG),
     &            SIGMA,VIP(1,KPG),DSIDEP,COD(KPG))


        IF(COD(KPG).EQ.1) THEN
          GOTO 1956
        ENDIF

C 5.4 - CALCUL DE LA MATRICE DE RIGIDITE

        IF (RIGI) THEN
         DO 160 N=1,NNO
          DO 150 I=1,2
           DO 151,KL=1,4
            SIG(KL)=0.D0
            SIG(KL)=SIG(KL)+DEF(1,N,I)*DSIDEP(1,KL)
            SIG(KL)=SIG(KL)+DEF(2,N,I)*DSIDEP(2,KL)
            SIG(KL)=SIG(KL)+DEF(3,N,I)*DSIDEP(3,KL)
            SIG(KL)=SIG(KL)+DEF(4,N,I)*DSIDEP(4,KL)
151        CONTINUE
           IF(MATSYM) THEN
            NMAX = N
           ELSE
             NMAX = NNO
           ENDIF
           DO 140 J=1,2
            DO 130 M=1,NMAX

C 5.4.1 - RIGIDITE GEOMETRIQUE

             IF (OPTION(1:4).EQ.'RIGI') THEN
               SIGG(1)=SIGN(1)
               SIGG(2)=SIGN(2)
               SIGG(3)=SIGN(3)
               SIGG(4)=SIGN(4)
              ELSE
               SIGG(1)=SIGMA(1)
               SIGG(2)=SIGMA(2)
               SIGG(3)=SIGMA(3)
               SIGG(4)=SIGMA(4)
              ENDIF

             TMP1 = 0.D0
             IF (I.EQ.J) THEN
              TMP1 = PFF(1,N,M)*SIGG(1)
     &            + PFF(2,N,M)*SIGG(2)
     &            + PFF(3,N,M)*SIGG(3)
     &            + PFF(4,N,M)*SIGG(4)

C TERME DE CORRECTION AXISYMETRIQUE

              IF (AXI .AND. I.EQ.1) THEN
               TMP1=TMP1+ZR(IVF+N+(KPG-1)*NNO-1)*
     &         ZR(IVF+M+(KPG-1)*NNO-1)/(R*R)*SIGG(3)
              END IF
             ENDIF

C 5.4.2 - RIGIDITE ELASTIQUE

             TMP2=0.D0
             TMP2=TMP2+SIG(1)*DEF(1,M,J)
             TMP2=TMP2+SIG(2)*DEF(2,M,J)
             TMP2=TMP2+SIG(3)*DEF(3,M,J)
             TMP2=TMP2+SIG(4)*DEF(4,M,J)

            IF(MATSYM) THEN
C 5.4.3 - STOCKAGE EN TENANT COMPTE DE LA SYMETRIE
              IF (M.EQ.N) THEN
               J1 = I
              ELSE
               J1 = 2
              ENDIF

             IF (J.LE.J1) THEN
              KKD = (2*(N-1)+I-1) * (2*(N-1)+I) /2
              KK = KKD + 2*(M-1)+J
              MATUU(KK) = MATUU(KK) + (TMP1+TMP2)*POIDS
             END IF
            ELSE
C 5.4.4 - STOCKAGE SANS SYMETRIE
              KK = 2*NNO*(2*(N-1)+I-1) + 2*(M-1)+J
              MATUU(KK) = MATUU(KK) + (TMP1+TMP2)*POIDS
            ENDIF

 130        CONTINUE
 140       CONTINUE
 150      CONTINUE
 160     CONTINUE
        ENDIF

C 5.5 - CALCUL DE LA FORCE INTERIEURE

        IF (RESI) THEN
         DO 230 N=1,NNO
          DO 220 I=1,2
           DO 210 KL=1,4
            VECTU(I,N)=VECTU(I,N)+DEF(KL,N,I)*SIGMA(KL)*POIDS
 210       CONTINUE
 220      CONTINUE
 230     CONTINUE

C 5.6 - CALCUL DES CONTRAINTES DE CAUCHY, CONVERSION LAGRANGE -> CAUCHY

         IF (CPLAN) F(3,3) = SQRT(ABS(2.D0*EPSP(3)+1.D0))
         DETF = F(3,3)*(F(1,1)*F(2,2)-F(1,2)*F(2,1))
         DO 190 PQ = 1,4
          SIGP(PQ,KPG) = 0.D0
          DO 200 KL = 1,4
           FTF = (F(INDI(PQ),INDI(KL))*F(INDJ(PQ),INDJ(KL)) +
     &           F(INDI(PQ),INDJ(KL))*F(INDJ(PQ),INDI(KL)))*RIND(KL)
           SIGP(PQ,KPG) =  SIGP(PQ,KPG)+ FTF*SIGMA(KL)
 200      CONTINUE
          SIGP(PQ,KPG) = SIGP(PQ,KPG)/DETF
 190     CONTINUE
        ENDIF

800   CONTINUE

1956  CONTINUE

C - SYNTHESE DES CODES RETOURS

      CALL CODERE(COD,NPG,CODRET)
      END
