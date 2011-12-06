      SUBROUTINE LCEJFR(FAMI,KPG,KSP,NDIM,MATE,OPTION,EPSM,DEPS,SIGMA,
     &                  DSIDEP,VIM,VIP)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 20/04/2011   AUTEUR COURTOIS M.COURTOIS 
C TOLE CRS_1404
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
C RESPONSABLE KAZYMYRENKO C.KAZYMYRENKO

      IMPLICIT NONE
      INTEGER MATE,NDIM,KPG,KSP
      REAL*8  EPSM(6),DEPS(6)
      REAL*8  SIGMA(6),DSIDEP(6,6)
      REAL*8  VIM(*),VIP(*)
      CHARACTER*16 OPTION
      CHARACTER*(*)  FAMI

C-----------------------------------------------------------------------
C     LOI DE COMPORTEMENT  MOHR-COULOMB
C     POUR LES ELEMENTS DE JOINT 2D ET 3D.
C
C IN : EPSM SAUT INSTANT - : EPSM(1)= SAUT NORMAL, EPSM(2/3)= SAUT TANG
C IN : DEPS    INCREMENT DE SAUT
C IN : MATE, OPTION, VIM
C OUT : SIGMA , DSIDEP , VIP
C LA TAILLE de SIGMA et EPS EST IMPOSEE PAR LC0000,
C ON UTILISE SEULEMENT LES COMPOSANTES NECESSAIRES NDIM=3 => SIGMA(1:3)
C-----------------------------------------------------------------------
      INTEGER NBPA
      PARAMETER (NBPA=5)
      LOGICAL RESI, RIGI, ELAS
      INTEGER I,J,IFPLAS,KRONEC, IFOUV
      REAL*8  KN,KT,KAPPA,MU,ADHE,A(NDIM),PLASTI(NDIM),DPLAS(NDIM)
      REAL*8  LAMBDA,DLAM,VAL(NBPA),CRITER
      REAL*8  ABSTAU,TAU(NDIM),COEFD,COEFHD
      INTEGER COD(NBPA)
      CHARACTER*8 NOM(NBPA)
      CHARACTER*1 POUM

C OPTION CALCUL DU RESIDU OU CALCUL DE LA MATRICE TANGENTE
C CALCUL DE CONTRAINTE (RESIDU)
      RESI = OPTION(1:9).EQ.'FULL_MECA' .OR. OPTION.EQ.'RAPH_MECA'
C CALCUL DE LA MATRICE TANGEANTE (RIGIDITE)
      RIGI = OPTION(1:9).EQ.'FULL_MECA' .OR. OPTION(1:9).EQ.'RIGI_MECA'
C CALCUL DE LA MATRICE ELASTIQUE A LA PLACE DE LA MATRICE TANGEANTE
      ELAS = OPTION.EQ.'FULL_MECA_ELAS' .OR. OPTION.EQ.'RIGI_MECA_ELAS'


C #####################################
C RECUPERATION DES PARAMETRES PHYSIQUES
C #####################################
      NOM(1) = 'K_N'
      NOM(2) = 'MU'
      NOM(3) = 'ADHESION'
      NOM(4) = 'K_T'
      NOM(5) = 'PENA_TANG'


      IF (OPTION.EQ.'RIGI_MECA_TANG') THEN
        POUM = '-'
      ELSE
        POUM = '+'
      ENDIF

      CALL RCVALB(FAMI,KPG,KSP,POUM,MATE,' ','JOINT_MECA_FROT',0,' ',
     &            0.D0,3,NOM,VAL,COD,2)
C DEFINITION DE PARAMETRES PHYSIQUE:
C     PENTE ELASTIQUE NORMALE
      KN=VAL(1)
C     COEFFICIENT DE FROTTEMENT
      MU=VAL(2)
C     ADHESION
      ADHE=VAL(3)

C PENTE ELASTIQUE TANGENTIELLE
C (SI ELLE N'EST PAS DEFINI ALORS K_T=K_N)
      CALL RCVALB(FAMI,KPG,KSP,POUM,MATE,' ','JOINT_MECA_FROT',0,' ',
     &            0.D0,1,NOM(4),VAL(4),COD(4),0)
      IF (COD(4).EQ.0) THEN
        KT = VAL(4)
      ELSE
        KT = KN
      ENDIF
C PARAMETRE PENA_TANG
C (SI IL N'EST PAS DEFINI ALORS KAPPA=(K_N+K_T)*1E-6)
      CALL RCVALB(FAMI,KPG,KSP,POUM,MATE,' ','JOINT_MECA_FROT',0,' ',
     &            0.D0,1,NOM(5),VAL(5),COD(5),0)
      IF (COD(5).EQ.0) THEN
        KAPPA = VAL(5)
      ELSE
        KAPPA = (KN+KT)*1.D-6
      ENDIF

C #####################################
C INITIALISATION DE VARIABLES
C #####################################

C CALCUL DU SAUT EN T+ OU T- EN FOCTION DE L'OPTION DE CALCUL
C     A=AM
      CALL DCOPY(NDIM,EPSM,1,A,1)
C     A=A+DA
      IF (RESI) CALL DAXPY(NDIM,1.D0,DEPS,1,A,1)


C INITIALISATION DE VARIABLE INTERNES
C     LAMBDA = accumutation de deplacement tang en valeur absolue
C     PLASTI = vecteur de deplacement plastique tangentiel
      LAMBDA=VIM(1)
      DO 10 I=2,NDIM
        PLASTI(I) = VIM(I+1)
10    CONTINUE
C     IDICATEUR DE PLASTIFICATION A L'INSTANT ACTUEL
      IF (ELAS) THEN
        IFPLAS = 0
      ELSE
        IFPLAS = NINT(VIM(2))
      END IF
C     INDICATEUR D'OUVERTURE
      IFOUV=NINT(VIM(5))
CCC      WRITE(*,*) 'ADHESION=', ADHE
CCC      WRITE(*,*) 'K_N=',KN,' KAPPA=',KAPPA, ' MU=', MU
CCC      WRITE(*,*) ' LAMBDA=',LAMBDA, ' PLASTI=', PLASTI(2)


C #####################################
C CALCUL DE LA CONTRAINTE
C #####################################

C     INITIALISATION DE LA CONTRAINTE A ZERO
      CALL R8INIR(6, 0.D0, SIGMA,1)


C     CONTRAINTE NORMALE DE CONTACT PENALISE +
C     INDICATEUR D'OUVERTURE COMPLETE
C     (CONTRAINTE TANGENTIEL EST MIS A ZERO)
      IF (KN*A(1).LT.(ADHE/MU)) THEN
        IFOUV=0
        SIGMA(1) = KN*A(1)
      ELSE
        IFOUV=1
        SIGMA(1) = ADHE/MU
      END IF
C     CONTRAINTE TANGENTIELLE
      DO 20 I=2,NDIM
        SIGMA(I) = KT*( A(I)-PLASTI(I) )
20    CONTINUE

C     DIRECTION DE GLISSEMENT = SIGMA TANG SANS INCREMENT PLASTIQUE
      DO 27 I=2,NDIM
        TAU(I) = SIGMA(I)
27    CONTINUE

C     MODULE DE SIGMA TANGENTE SANS INCREMENT PLASTIQUE
C     NB:SI ABSTAU==0 ON EST TOUJOURS DANS LE REGIME ELASTIQUE
      ABSTAU=0.D0
      DO 30 I=2,NDIM
        ABSTAU = ABSTAU+TAU(I)**2
30    CONTINUE
      ABSTAU=SQRT(ABSTAU)



C ###########################################################
C SI ON CALCULE LA RIGIDITE SEULEMENT, ON Y SAUTE DIRECTEMENT
C ###########################################################
      IF (.NOT. RESI) GOTO 5000

C     CRITERE DE PLASTICITE  NB: SIGMA(1)<0 EN COMPRESSION
      CRITER=ABSTAU+MU*SIGMA(1)-KAPPA*LAMBDA - ADHE
C     VERIFICATION DE CRITERE DE PLASTICITE
      IF (CRITER.LE.0.D0) THEN
C     PAS DE PLASTICITE
         IFPLAS=0
         DO 32 I=2,NDIM
            DPLAS(I) = 0.D0
32       CONTINUE
         DLAM=0.D0
      ELSE
C     AVEC LA PLASTICITE
         IFPLAS=1
         DO 34 I=2,NDIM
            DPLAS(I) = CRITER/(KT+KAPPA)*TAU(I)/ABSTAU
            SIGMA(I) = SIGMA(I)-KT*DPLAS(I)
34       CONTINUE
         DLAM=CRITER/(KT+KAPPA)
      ENDIF


C ACTUALISATION DES VARIABLES INTERNES
C   V1 :  LE DEPLACEMENT PLASTIQUE CUMULE (SANS ORIENTATION) LAMBDA:
C            LAMBDA NE PEUX QU'AUGMENTER
C   V2 : INDICATEUR DE PLASTIFICATION (0 : NON, 1 : OUI)
C   V3-V4 :  VECTEUR DE DEPLACEMENT TANG PAR RAPPORT AU POINT DE DEPART
C                        (INDIQUE LA POSITION D'EQUILIBRE ACTUELLE)
C   V5    : INDICATEUR D'OUVERTURE COMPLETE
C                         (CONTRAINTE TANGENTIEL EST MIS A ZERO)
C   V6    : MODULE DE LA CONTRAINTE TANGENTE
C   V7 A V9 : VALEURS DU SAUT

      VIP(1) = LAMBDA+DLAM
      VIP(2) = IFPLAS
      DO 36 I=2,NDIM
         VIP(I+1) = VIM(I+1)+DPLAS(I)
36    CONTINUE
      VIP(5) = MAX(NINT(VIM(5)),IFOUV)

      VIP(6)=VIM(6)
      DO 37 I=2,NDIM
         VIP(6) = VIP(6)+SIGMA(I)**2
      VIP(6)=SQRT(VIP(6))
37    CONTINUE
      VIP(7) = A(1)
      DO 38 I=2,NDIM
         VIP(I+6)=A(I)
38    CONTINUE


C #####################################
C CALCUL DE LA MATRICE TANGENTE
C #####################################

5000  CONTINUE
      IF (.NOT. RIGI) GOTO 9999
C     INITIALISATION DE DSIDEP = 0
      CALL R8INIR(6*6, 0.D0, DSIDEP,1)
C DSIGMA_N/DDELTA_N
      IF (IFOUV.EQ.0) THEN
         DSIDEP(1,1)=KN
      ELSE
         DSIDEP(1,1)=0.D0
      ENDIF
C DSIGMA_N/DDELTA_T
      DO 40 I=2,NDIM
         DSIDEP(1,I)=0.D0
40    CONTINUE
C DSIGMA_T/DDELTA_N
      DO 50 I=2,NDIM
         IF ((IFOUV.EQ.0).AND.(IFPLAS.EQ.1)) THEN
            DSIDEP(I,1)=-TAU(I)*MU*KN*KT/ABSTAU/(KT+KAPPA)
         ELSE
            DSIDEP(I,1)=0.D0
         ENDIF
50    CONTINUE
C DSIGMA_T/DDELTA_T
      IF (IFPLAS.EQ.1) THEN
         COEFHD= - (KAPPA*LAMBDA+ADHE-MU*SIGMA(1))
     &     *KT**2/ABSTAU**3/(KT+KAPPA)
         COEFD=KAPPA*KT/(KT+KAPPA) - COEFHD*ABSTAU**2
         DO 60 J=2,NDIM
            DO 70 I=J,NDIM
              IF (I.EQ.J) THEN
                 KRONEC=1
              ELSE
                 KRONEC=0
              ENDIF
              DSIDEP(J,I) = COEFHD*TAU(J)*TAU(I) + COEFD*KRONEC
              DSIDEP(I,J) = COEFHD*TAU(I)*TAU(J) + COEFD*KRONEC
70          CONTINUE
60       CONTINUE
      ELSE
         DO 80 I=2,NDIM
            DSIDEP(I,I)=KT
80       CONTINUE
      ENDIF



CCC MATRICE TANGENTE DE CONTACT OUVERT

C DANS LE CAS OU L'ELEMENT EST TOTALEMENT CASSE ON INTRODUIT UNE
C RIGIDITE ARTIFICIELLE DANS LA MATRICE TANGENTE POUR ASSURER
C LA CONVERGENCE

C     POUR LE JOINT OUVERT LA PARTIE NORMALE EST CORRIGEE
      IF (IFOUV.EQ.1) THEN
        DSIDEP(1,1) = KN*1.D-8
CCC        WRITE (*,*) 'COMPLETEMENT CASSE NORMALE'
      END IF
C     POUR LE JOINT SANS ECROUISSAGE LA PARTIE TANGENTIELLE EST DECALEE
      IF (KAPPA.EQ.0.D0) THEN
        DO 90 I=2,NDIM
          DSIDEP(I,I) =  DSIDEP(I,I) + KT*1.D-8
90      CONTINUE
CCC       WRITE (*,*) 'COMPLETEMENT CASSE TANGENTE'
      END IF




 9999 CONTINUE


      END
