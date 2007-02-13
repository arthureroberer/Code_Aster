      SUBROUTINE NMCO1D(FAMI,KPG,KSP,IMATE, COMPOR, OPTION,
     &                  EPSM, DEPS,
     &                  ANGMAS,
     &                  SIGM, VIM,
     &                  TM, TP, TREF,
     &                  SIGP, VIP, DSIDEP,CODRET)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/02/2007   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT NONE
      INTEGER       IMATE,CODRET,KPG,KSP
      CHARACTER*16  COMPOR(*),OPTION
      CHARACTER*(*) FAMI
      REAL*8        EPSM,DEPS,SIGM,VIM(*)
      REAL*8        TM,TP,TREF,ANGMAS(3)
      REAL*8        SIGP,VIP(*),DSIDEP
C ----------------------------------------------------------------------
C          REALISE LES LOIS 1D (DEBORST OU EXPLICITEMENT 1D)
C
C
C IN  IMATE   : ADRESSE DU MATERIAU CODE
C IN  COMPOR  : COMPORTEMENT :  (1) = TYPE DE RELATION COMPORTEMENT
C                               (2) = NB VARIABLES INTERNES / PG
C IN  OPTION  : OPTION DEMANDEE : RIGI_MECA_TANG , FULL_MECA , RAPH_MECA
C IN  EPSM    : DEFORMATIONS A L'INSTANT DU CALCUL PRECEDENT
C IN  DEPS    : INCREMENT DE DEFORMATION (SCALAIRE DANS CE CAS)
C IN  SIGM    : CONTRAINTE A L'INSTANT DU CALCUL PRECEDENT
C IN  VIM     : VARIABLES INTERNES A L'INSTANT DU CALCUL PRECEDENT
C IN   TM     : TEMPERATURE L'INSTANT DU CALCUL PRECEDENT
C IN   TP     : TEMPERATURE A L'INSTANT DU
C IN  TREF    : TEMPERATURE DE REFERENCE
C OUT SIGP    : CONTRAINTE A L'INSTANT ACTUEL
C     VIP     : VARIABLES INTERNES A L'INSTANT ACTUEL
C     DSIDEP  : RIGIDITE (SCALAIRE DANS CE CAS)
C     CODRET  : CODE RETOUR NON NUL SI SIGYY OU SIGZZ NON NULS
C ----------------------------------------------------------------------
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
      INTEGER            ZI
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
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
      LOGICAL       CINE,ISOT,PINTO,PCTNZR,COM1D
      REAL*8        ALPH,E,ET,SIGY
      INTEGER       NVARPI
      PARAMETER    ( NVARPI=8)
      INTEGER       NCSTPM
      PARAMETER     (NCSTPM=13)
      REAL*8        CSTPM(NCSTPM)
      REAL*8        EM,EP,ALPHAM,ALPHAP,R8VIDE
      CHARACTER*2   CODRES

      ISOT = .FALSE.
      CINE = .FALSE.
      PINTO = .FALSE.
      COM1D=.FALSE.
      CODRET=0

      IF ( COMPOR(1)(1:16) .EQ. 'GRILLE_ISOT_LINE') THEN
          ISOT = .TRUE.
      ELSE IF ( COMPOR(1)(1:16) .EQ. 'GRILLE_CINE_LINE') THEN
          CINE = .TRUE.
      ELSE IF ( COMPOR(1)(1:16) .EQ. 'GRILLE_PINTO_MEN') THEN
          PINTO = .TRUE.
      ELSE
          COM1D=.TRUE.
          IF ((COMPOR(5)(1:7).NE.'DEBORST').AND.
     &        (COMPOR(1)(1:4).NE.'SANS')) THEN
                CALL U2MESK('F','ALGORITH6_81',1,COMPOR(1))
          ENDIF
      ENDIF

      IF (.NOT.COM1D) THEN
          CALL NMMABA (IMATE,COMPOR,E,ALPH,ET,SIGY,
     &             NCSTPM,CSTPM)
C --- CARACTERISTIQUES ELASTIQUES A TMOINS

        CALL RCVALA(IMATE,' ','ELAS',1,'TEMP',TM,1,'E',EM,CODRES,'FM')
        CALL RCVALA(IMATE,' ','ELAS',1,'TEMP',TM,1,'ALPHA',ALPHAM,
     &            CODRES,' ')
        IF (CODRES.NE.'OK') ALPHAM = 0.D0

C --- CARACTERISTIQUES ELASTIQUES A TPLUS

        CALL RCVALA(IMATE,' ','ELAS',1,'TEMP',TP,1,'E',EP,CODRES,'FM')
        CALL RCVALA(IMATE,' ','ELAS',1,'TEMP',TP,1,'ALPHA',ALPHAP,
     &            CODRES,' ')
        IF (CODRES.NE.'OK') ALPHAP = 0.D0
      ENDIF


      IF (ISOT) THEN
        CALL NM1DIS(IMATE,TM,TP,TREF,EM,EP,ALPHAM,ALPHAP,SIGM,
     &            DEPS,VIM,OPTION,COMPOR,' ',SIGP,VIP,DSIDEP)
      ELSE IF (CINE) THEN
        CALL NM1DCI(IMATE,TM,TP,TREF,EM,EP,ALPHAM,ALPHAP,SIGM,
     &            DEPS,VIM,OPTION,' ',SIGP,VIP,DSIDEP)
      ELSE IF (COM1D) THEN

        CALL COMP1D(FAMI,KPG,KSP,OPTION,
     &              SIGM,EPSM,DEPS,
     &              TM,TP,TREF,
     &              ANGMAS,
     &              VIM,VIP,SIGP,DSIDEP,CODRET)
      ELSE IF (PINTO) THEN
        CALL NM1DPM(OPTION,NVARPI,ALPH,TM,NCSTPM,CSTPM,
     &              SIGM,VIM,TP,DEPS,VIP,SIGP,DSIDEP)
      ENDIF

      END
