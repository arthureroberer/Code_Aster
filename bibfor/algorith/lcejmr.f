      SUBROUTINE LCEJMR(FAMI,KPG,KSP,NDIM,MATE,OPTION,EPSM,DEPS,SIGMA,
     &                  DSIDEP,VIM,VIP,COOROT,TYPMOD,INSTAM,INSTAP)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 14/12/2010   AUTEUR PROIX J-M.PROIX 
C ======================================================================
C COPYRIGHT (C) 1991 - 2010  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE KAZYMYRENKO

      IMPLICIT NONE
      INTEGER MATE,NDIM,KPG,KSP
      REAL*8  EPSM(6),DEPS(6)
      REAL*8  SIGMA(6),DSIDEP(6,6)
      REAL*8  VIM(*),VIP(*),INSTAM,INSTAP,COOROT(NDIM+NDIM*NDIM)
      CHARACTER*8  TYPMOD(*)
      CHARACTER*16 OPTION
      CHARACTER*(*) FAMI

C-----------------------------------------------------------------------
C     LOI DE COMPORTEMENT DES JOINTS DE BARRAGE : JOINT_MECA_RUPT
C     POUR LES ELEMENTS DE JOINT ET JOINT_HYME 2D ET 3D
C
C IN : EPSM SAUT INSTANT MOINS ET GRAD PRESSION SI MODELISATION HM
C IN : DEPS INCREMENT DE SAUT  ET INCREMENT GRAD PRESSION SI HM
C IN : MATE, OPTION, VIM, COOROT,INSTAM, INSTAP
C OUT : SIGMA , DSIDEP , VIP
C-----------------------------------------------------------------------
      INTEGER NBPA
      PARAMETER (NBPA=11)
      INTEGER I,J,N,DISS,CASS
      REAL*8 SC,LC,LCT,K0,VAL(NBPA),PRESFL,PRESCL,INSTCL,TMP,COEF
      REAL*8 GP(NDIM-1),GPLOC(NDIM),GPGLO(NDIM),FHLOC(NDIM),FHGLO(NDIM)
      REAL*8 A(NDIM),KA,KAP,R0,RC,ALPHA,BETA,RK,RA,RT,RT0,R8BID
      REAL*8 OSET,DOSET,R8PI,INST,VALPAR(NDIM+1),RHOF,VISF,AMIN
      REAL*8 INVROT(NDIM,NDIM),RIGART
      CHARACTER*2 COD(NBPA)
      CHARACTER*8 NOM(NBPA),NOMPAR(NDIM+1)
      CHARACTER*1 POUM
      LOGICAL RESI,RIGI,ELAS
     
C OPTION CALCUL DU RESIDU OU CALCUL DE LA MATRICE TANGENTE
      RESI = OPTION(1:9).EQ.'FULL_MECA' .OR. OPTION.EQ.'RAPH_MECA'
      RIGI = OPTION(1:9).EQ.'FULL_MECA' .OR. OPTION(1:9).EQ.'RIGI_MECA'
      ELAS = OPTION.EQ.'FULL_MECA_ELAS' .OR. OPTION.EQ.'RIGI_MECA_ELAS'

C SAUT DE DEPLACEMENT EN T- OU T+
      CALL DCOPY(NDIM,EPSM,1,A,1)             
      IF (RESI) CALL DAXPY(NDIM,1.D0,DEPS,1,A,1)

C GRADIENT DE PRESSION EN T- OU T+
      IF ((TYPMOD(2).EQ.'EJ_HYME')) THEN
        DO 10 N=1,NDIM-1
          GP(N) = EPSM(NDIM+N)
          IF (RESI) GP(N) = GP(N) + DEPS(NDIM+N)
  10    CONTINUE
      ENDIF
      
C INSTANT DE CALCUL T- OU T+
      INST = INSTAM
      IF (RESI) INST = INSTAP

C RECUPERATION DES PARAMETRES PHYSIQUES
C--------------------------------------
      NOM(1) = 'K_N'
      NOM(2) = 'SIGM_MAX'
      NOM(3) = 'PENA_RUPT'
      NOM(4) = 'PENA_CONTACT'
      NOM(5) = 'ALPHA'
      NOM(6) = 'K_T'
      NOM(7) = 'PRES_FLUIDE'
      NOM(8) = 'PRES_CLAVAGE'
      NOM(9) = 'RHO_FLUIDE'
      NOM(10) ='VISC_FLUIDE'
      NOM(11) ='OUV_MIN'
                 
      IF (OPTION.EQ.'RIGI_MECA_TANG') THEN
        POUM = '-'
      ELSE
        POUM = '+'
      ENDIF

      CALL RCVALB(FAMI,KPG,KSP,POUM,MATE,' ','JOINT_MECA_RUPT',0,' ',
     &            0.D0,5,NOM,VAL,COD,'F ')

C CONTRAINTE CRITIQUE SANS PENALISATION
      SC   = VAL(2)*(1.D0 + VAL(3))/VAL(3)
C LONGUEUR CRITIQUE AVANT LA RUPTURE COMPLETE DU JOINT
      LC   = (1.D0 + VAL(3))*VAL(2)/VAL(1)
C LONGUEUR AVANT L'ADOUCISSEMENT
      K0   = VAL(2)/VAL(1)
C PENTE NORMALE INITIAL
      R0   = VAL(1)    
      BETA = VAL(4)
C PARAMETRE QUI DEFINI LA LONGUEUR CRITIQUE TANGENTIELLE (0<ALPHA<=2)
      ALPHA= VAL(5)
C LONGUEUR CRITIQUE TANGENTIELLE 
C ALPHA=0: LCT=0; ALPHA=1: LCT=LC; ALPHA=2;LCT=INFTY
      IF (ALPHA.NE.2.D0) THEN 
        LCT=LC*TAN(ALPHA*R8PI()/4.D0)
      ELSE
C PRESENTATION D'UNE INFINITE NUMERIQUE
        LCT=(1.D0 + LC)*1.D8
      ENDIF
C PENTE TANGENTIELLE INITIAL (SI ELLE N'EST PAS DEFINI ALORS K_T=K_N)
      CALL RCVALB(FAMI,KPG,KSP,POUM,MATE,' ','JOINT_MECA_RUPT',0,' ',
     &            0.D0,1,NOM(6),VAL(6),COD(6),'  ')
      IF (COD(6).EQ.'OK') THEN
        RT0 = VAL(6)
      ELSE
        RT0 = R0
      ENDIF 

C DEFINITION DES PARAMETRES POUR LA RECUPERATION DES FONCTIONS        
      NOMPAR(1)='INST'
      NOMPAR(2)='X'
      NOMPAR(3)='Y'
      VALPAR(1)= INST
      VALPAR(2)= COOROT(1)
      VALPAR(3)= COOROT(2)
      IF (NDIM.EQ.3) THEN
        NOMPAR(4)='Z'
        VALPAR(4)= COOROT(3)
      ENDIF

C RECUPERATION DE LA PRESS FLUIDE ET DE CLAVAGE (MODELISATION MECA PURE)
C-----------------------------------------------------------------------

C RECUPERATION DE LA PRESS FLUIDE (FONCTION DE L'ESPACE ET DU TEMPS)
      CALL RCVALB(FAMI,KPG,KSP,POUM,MATE,' ','JOINT_MECA_RUPT',NDIM+1,
     &            NOMPAR,VALPAR,1,NOM(7),VAL(7),COD(7),'  ')

      IF (COD(7).EQ.'OK') THEN
        PRESFL = VAL(7)
      ELSE
        PRESFL = 0.D0
      ENDIF
              
C RECUPERATION DE LA PRESS CLAVAGE (FONCTION DE L'ESPACE ET DU TEMPS)
      CALL RCVALB(FAMI,KPG,KSP,POUM,MATE,' ','JOINT_MECA_RUPT',NDIM+1,
     &            NOMPAR,VALPAR,1,NOM(8),VAL(8),COD(8),'  ')

      IF (COD(8).EQ.'OK') THEN
        PRESCL = VAL(8)
      ELSE
        PRESCL = -1.D0
      ENDIF
      
C RECUPERATION DE LA MASSE VOL ET DE LA VISCO (MODELISATION JOINT HM)
C--------------------------------------------------------------------

      CALL RCVALB(FAMI,KPG,KSP,POUM,MATE,' ','JOINT_MECA_RUPT',0,' ',
     &            0.D0,1,NOM(9),VAL(9),COD(9),'  ')
      CALL RCVALB(FAMI,KPG,KSP,POUM,MATE,' ','JOINT_MECA_RUPT',0,' ',
     &            0.D0,1,NOM(10),VAL(10),COD(10),'  ')
      CALL RCVALB(FAMI,KPG,KSP,POUM,MATE,' ','JOINT_MECA_RUPT',0,' ',
     &            0.D0,1,NOM(11),VAL(11),COD(11),'  ')

      IF (COD(9).EQ.'OK')  RHOF = VAL(9)
      IF (COD(10).EQ.'OK') VISF = VAL(10)
      IF (COD(11).EQ.'OK') AMIN = VAL(11)
 
C VERIFICATION DE LA PRESENCE/ABSENCE DE PARAMETRES
C EN FONCTION DE LA MODELISATION MECA PUR OU HYDRO MECA
   
      IF ((TYPMOD(2).EQ.'EJ_HYME')) THEN
        
        IF ((COD(7).EQ.'OK').OR.(COD(8).EQ.'OK')) THEN
          CALL U2MESS('F','ALGORITH17_14')
        ENDIF
        IF ((COD(9).NE.'OK').OR.(COD(10).NE.'OK')) THEN
          CALL U2MESS('F','ALGORITH17_15')    
        ENDIF
        
      ELSEIF (TYPMOD(2).EQ.'ELEMJOIN') THEN  
        
        IF((COD(9).EQ.'OK').OR.(COD(10).EQ.'OK')) THEN
          CALL U2MESS('F','ALGORITH17_16')
        ENDIF
        
      ENDIF

C DANS LE CAS DU CLAVAGE
C-----------------------
C INITIALISATION DU POINT D'EQUILIBRE POUR LA LDC (OFFSET)
      DOSET = A(1) + PRESCL/(BETA*R0)
      IF ((PRESCL.LT.0.D0).OR.(DOSET.LT.0.D0)) THEN
        OSET = VIM(10)
      ELSE
        OSET = VIM(10) + DOSET
      ENDIF
                 
C LA LDC EST DEFINIE PAR RAPPORT A NOUVEAU POINT D'EQUILIBRE
      A(1) = A(1) - OSET 

C INITIALISATION DU SEUIL D'ENDOMMAGEMENT ACTUEL
      KA = MAX(K0,VIM(1))

C CALCUL DES PENTES
C------------------

C PENTE ACTUEL EN DECHARGE DANS LA ZONE DE TRACTION
      IF (LC*KA.NE.0.D0) THEN 
        RK = MAX(0.D0, SC*(1.D0-KA/LC)/KA)
      ELSE
        RK = 0.D0
      ENDIF
      
C DANS LE DOMAINE DE COMPRESSION
      RC = BETA*R0
      
C PENTE TANGENTIELLE ACTUELLE 
C SI ALPHA=2 RT CSTE, SI ALPHA=0 ALORS LCT=0 ET DONC RT=0)
      RT = RT0
      IF (A(1).GT.0.D0) THEN
        IF (LCT.NE.0.D0) RT = MAX(0.D0, RT0*(1.D0-A(1)/LCT))
        IF (LCT.EQ.0.D0) RT = 0.D0
      ENDIF
      IF (ALPHA.EQ.2.D0) RT = RT0

C INITIALISATION COMPLEMENTAIRE POUR RIGI_MECA_TANG (SECANTE PENALISEE)
      IF (.NOT. RESI) THEN
        IF (ELAS) THEN
          DISS = 0
        ELSE
          DISS = NINT(VIM(2))
        ENDIF
        CASS = NINT(VIM(3))
        GOTO 5000
      ENDIF

C     INITIALISATION DE LA CONTRAINTE
      CALL R8INIR(6, 0.D0, SIGMA,1)

C CALCUL DE LA CONTRAINTE HYDRO : DEBIT (LOI CUBIQUE)
C----------------------------------------------------

      IF ((TYPMOD(2).EQ.'EJ_HYME')) THEN
        DO 44 N=1,NDIM-1
          SIGMA(NDIM+N)= 
     &          -RHOF*GP(N)*(MAX(AMIN,A(1)+AMIN))**3/(12*VISF)
  44    CONTINUE    
      ENDIF


C CALCUL DE LA CONTRAINTE MECANIQUE
C----------------------------------

C    CONTRAINTE DE CONTACT PENALISE 
C    ET PRISE EN COMPTE DE LA PRESSION DE FLUIDE EVENTUELLE
      SIGMA(1) = RC * MIN(0.D0,A(1)) - PRESFL
C    PARTIE TANGENTIELLE
      DO 20 I=2,NDIM
        SIGMA(I) = RT*A(I)
20    CONTINUE      

C    CONTRAINTE DE FISSURATION NORMALE
      IF ((A(1).GE.LC) .OR. (KA.GT.LC)) THEN
        DISS = 0
        CASS = 2
      ELSE
        IF (A(1).LE.KA) THEN

          DISS = 0
          IF (KA.GT.K0) THEN
            CASS = 1
          ELSE
            CASS = 0
          ENDIF
          SIGMA(1) = SIGMA(1) + RK*MAX(0.D0,A(1))

        ELSE

          DISS = 1
          CASS = 1
          IF (LC.NE.0.D0) THEN
            RA = MAX(0.D0,SC*(1.D0 - A(1)/LC)/A(1)) 
          ELSE
            RA = 0.D0
          ENDIF
          SIGMA(1) = SIGMA(1) + RA*MAX(0.D0,A(1))

        ENDIF
      ENDIF

C ACTUALISATION DES VARIABLES INTERNES
C-------------------------------------

C V1 : SEUIL, PLUS GRANDE NORME DU SAUT
C V2 : INDICATEUR DE DISSIPATION (0 : NON, 1 : OUI)
C V3 : INDICATEUR D'ENDOMMAGEMENT NORMAL (0 : SAIN, 1: ENDOM, 2: CASSE)
C V4 : POURCENTAGE D'ENDOMMAGEMENT NORMAL (DANS LA ZONE ADOUCISSANTE)
C V5 : INDICATEUR D'ENDOMMAGEMENT TANGENTIEL (0:SAIN, 1:ENDOM, 2:CASSE)
C V6 : POURCENTAGE D'ENDOMMAGEMENT TANGENTIEL
C V7 A V9 : VALEURS DU SAUT DANS LE REPERE LOCAL
C V10: EPAISSEUR DU JOINT CLAVE
C V11 : CONTRAINTE MECANIQUE NORMALE (SANS PRESSION DE FLUIDE)
C V12 A V14 : COMPOSANTES DU GRADIENT DE PRESSION DANS LE REPERE GLOBAL
C V15 A V17 : COMPOSANTES DU FLUX HYDRO DANS LE REPERE GLOBAL

      KAP    = MAX(KA,A(1))
      VIP(1) = KAP
      VIP(2) = DISS
      VIP(3) = CASS
      IF (LC.NE.0.D0) THEN 
        TMP = MAX(0.D0, (KAP - VAL(2)/VAL(1)) / (LC - VAL(2)/VAL(1)) )
        VIP(4) = MIN(1.D0,TMP)
      ELSE
        VIP(4) = 1.D0
      ENDIF
      VIP(5) = 0.D0
      IF (RT.LT.RT0)  VIP(5) = 1.D0
      IF (RT.EQ.0.D0) VIP(5) = 2.D0     
      VIP(6) = 1.D0 - RT/RT0
      VIP(7) = A(1) + OSET
      VIP(8) = A(2)
      IF (NDIM.EQ.3) THEN
        VIP(9) = A(3)
      ELSE
        VIP(9) = 0.D0
      ENDIF
      
C     CALCUL DU NOUVEL POINT D'EQUILIBRE V10 DANS LE CAS DE CLAVAGE
C     LE CLAVAGE NE FAIT QU'AUGMENTER L'EPAISSEUR DU JOINT 
C     => OSET EST CROISSANT
      IF ((PRESCL.LT.0.D0).OR.(DOSET.LT.0.D0)) THEN
        VIP(10) = VIM(10)        
      ELSE
        VIP(10) = VIM(10) + DOSET
      ENDIF

C     VISUALISATION DE LA CONTRAINTE MECANIQUE NORMALE 
C     SANS PRESSION DE FLUIDE EVENTUELLE
      VIP(11)=SIGMA(1)

C     VISUALISATION DES FLUX ET DES GRADIENTS DE PRESSION 
C     DANS LE REPERE GLOBAL
      IF ((TYPMOD(2).EQ.'EJ_HYME')) THEN
        
        GPLOC(1) = 0.D0
        GPLOC(2) = GP(1)
        IF (NDIM.EQ.3) THEN
          GPLOC(3) = GP(2)
        ELSE
           GPLOC(3) = 0.D0
        ENDIF
        
        FHLOC(1) = 0.D0
        FHLOC(2) = SIGMA(NDIM+1)
        IF (NDIM.EQ.3) THEN
          FHLOC(3) = SIGMA(2*NDIM-1)
        ELSE
          FHLOC(3) = 0.D0
        ENDIF
            
        CALL MATINV('S',NDIM,COOROT(NDIM+1),INVROT,R8BID)
        CALL PMAVEC('ZERO',NDIM,INVROT,GPLOC,GPGLO)
        CALL PMAVEC('ZERO',NDIM,INVROT,FHLOC,FHGLO)

        VIP(12) = GPGLO(1)
        VIP(13) = GPGLO(2)
        VIP(15) = FHGLO(1)
        VIP(16) = FHGLO(2)
        
        IF (NDIM.EQ.3) THEN
          VIP(14) = GPGLO(3)
          VIP(17) = FHGLO(3)
        ELSE
          VIP(14) = 0.D0
          VIP(17) = 0.D0
        ENDIF
        
      ELSE
      
        VIP(12) = 0.D0
        VIP(13) = 0.D0
        VIP(14) = 0.D0
        VIP(15) = 0.D0
        VIP(16) = 0.D0
        VIP(17) = 0.D0
        
      ENDIF  

 5000 CONTINUE
 
C INITIALISATION DE LA MATRICE TANGENTE
      CALL R8INIR(6*6, 0.D0, DSIDEP,1)
      
      IF (.NOT. RIGI) GOTO 9999
      
C CALCUL DE LA MATRICE TANGENTE HYDRO
C------------------------------------
      
      IF ((TYPMOD(2).EQ.'EJ_HYME')) THEN
          
C       TERME : DW/DGP  (POUR KTAN P P)
        DO 42 N=1,NDIM-1
                  
          DSIDEP(NDIM+N,NDIM+N) = 
     &            -RHOF*(MAX(AMIN,A(1)+AMIN))**3/(12*VISF)

  42    CONTINUE
      
C       TERME : DW/DDELTA_N  (POUR KTAN P U)
        DO 43 N=1,NDIM-1
        
          IF (A(1).LT.0.D0) THEN
            DSIDEP(NDIM+N,1) = 0.D0    
          ELSE 
            DSIDEP(NDIM+N,1) = -3*RHOF*GP(N)*(A(1)+AMIN)**2/(12*VISF)
          ENDIF
           
  43    CONTINUE
      
      ENDIF


C CALCUL DE LA MATRICE TANGENTE MECA (POUR KTAN U U)
C-----------------------------------

C MATRICE TANGENTE DE CONTACT FERME
      IF (A(1).LE.0.D0) THEN 
         DSIDEP(1,1) =  RC
         DO 38 I=2,NDIM
            DSIDEP(I,I) =  RT0
  38     CONTINUE
         GOTO 9999
      ENDIF

C MATRICE TANGENTE DE CONTACT OUVERT 
C  (IL FAUT NOTER QUE DANS LA SUITE A(1)>0)

C MATRICE TANGENTE DE FISSURATION
      IF ((DISS.EQ.0) .OR. ELAS) THEN
        DSIDEP(1,1) =  RK
      ELSE
        IF (LC.NE.0.D0) DSIDEP(1,1) = -SC/LC 
      ENDIF
      
      DO 40 I=2,NDIM
        DSIDEP(I,I) =  RT
        IF ((LCT.NE.0.D0).AND.(A(1).LT.LCT)) THEN
          DSIDEP(I,1) = -A(I)*RT0/LCT
        ENDIF  
  40  CONTINUE

C DANS LE CAS OU L'ELEMENT EST TOTALEMENT CASSE ON INTRODUIT UNE
C RIGIDITE ARTIFICIELLE DANS LA MATRICE TANGENTE POUR ASSURER
C LA CONVERGENCE 

      RIGART=1.D-8
      IF (CASS.EQ.2) DSIDEP(1,1) =  RIGART
      
      IF (ABS(RT).LT.RIGART) THEN
        DO 39 I=2,NDIM
          DSIDEP(I,I) = RIGART
  39    CONTINUE
      ENDIF


 9999 CONTINUE

      END
