      SUBROUTINE CAZOCC(CHAR  ,MOTFAC,NOMA  ,NOMO  ,NDIM  ,
     &                  LGLIS ,IREAD ,IWRITE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 30/04/2007   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
C TOLE CRP_20
C
      IMPLICIT NONE
      CHARACTER*8  CHAR
      CHARACTER*16 MOTFAC
      CHARACTER*8  NOMA
      CHARACTER*8  NOMO
      INTEGER      NDIM
      INTEGER      IREAD
      INTEGER      IWRITE
      LOGICAL      LGLIS
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE CONTINUE - LECTURE DONNEES)
C
C LECTURE DES PRINCIPALES CARACTERISTIQUES DU CONTACT (SURFACE IREAD)
C REMPLISSAGE DE LA SD 'DEFICO' (SURFACE IWRITE)
C      
C ----------------------------------------------------------------------
C
C
C IN  CHAR   : NOM UTILISATEUR DU CONCEPT DE CHARGE
C IN  MOTFAC : MOT-CLE FACTEUR (VALANT 'CONTACT')
C IN  NOMA   : NOM DU MAILLAGE
C IN  NOMO   : NOM DU MODELE
C IN  NDIM   : NOMBRE DE DIMENSIONS DU PROBLEME
C IN  IREAD  : INDICE POUR LIRE LES DONNEES DANS AFFE_CHAR_MECA
C IN  IWRITE : INDICE POUR ECRIRE LES DONNEES DANS LA SD DEFICONT
C IN  LGLISS : .TRUE. SI CONTACT GLISSIERE
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      REACCA,REACBS,REACBG
      INTEGER      CFMMVD,ZMETH,ZTOLE,ZECPD,ZCMCF,ZTGDE,ZDIRE,ZPOUD
      CHARACTER*8  TYMOCL(2),STACO0,COMPLI,FONFIS,RACSUR,INDUSU
      CHARACTER*8  PIVAUT
      CHARACTER*16 MOTCLE(2)
      CHARACTER*24 LISMA
      INTEGER      NBMA1
      CHARACTER*16 MODELI,PHENOM
      INTEGER      IER,IBID,NOC,NOCC    
      CHARACTER*24 NORLIS,CARACF,ECPDON,DIRCO,METHCO,TANDEF
      INTEGER      JNORLI,JCMCF,JECPD,JDIR,JMETH,JTGDEF
      CHARACTER*24 JEUSUP,TANPOU,TOLECO
      INTEGER      JJSUP,JPOUDI,JTOLE
      CHARACTER*16 FORM,FROT,SGRNO,ALGOC,ALGOF
      CHARACTER*16 LISSA,INTEG
      REAL*8       DIR1(3),DIR(3),COEFRO,COCAUR,COFAUR,REACSI
      REAL*8       COCAUS,COFAUS,COCAUP,COFAUP,KWEAR,HWEAR
      REAL*8       ASPER,KAPPAN,KAPPAV
      REAL*8       DIST1,DIST2,LAMB,ALJEU
      LOGICAL      LINTNO,MMMAXI,LMAIT,LESCL,LAXIS,LFROT
      CHARACTER*16 VALK(2)      
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ
C
C --- INITIALISATIONS
C
      COCAUR = 0.D0
      COFAUR = 0.D0
      COCAUS = 0.D0
      COFAUS = 0.D0
      COCAUP = 0.D0
      COFAUP = 0.D0
      COEFRO = 0.D0
      REACSI = -1.0D+6
      LINTNO = .FALSE.
      ALJEU  = 0.D0
C
C --- LECTURE DES STRUCTURES DE DONNEES DE CONTACT
C 
      DIRCO  = CHAR(1:8)//'.CONTACT.DIRCO'
      ECPDON = CHAR(1:8)//'.CONTACT.ECPDON'
      CARACF = CHAR(1:8)//'.CONTACT.CARACF'
      METHCO = CHAR(1:8)//'.CONTACT.METHCO'
      TANDEF = CHAR(1:8)//'.CONTACT.TANDEF'
      JEUSUP = CHAR(1:8)//'.CONTACT.JSUPCO'
      TANPOU = CHAR(1:8)//'.CONTACT.TANPOU'
      TOLECO = CHAR(1:8)//'.CONTACT.TOLECO'
      NORLIS = CHAR(1:8)//'.CONTACT.NORLIS'      
C
      CALL JEVEUO(CARACF,'E',JCMCF )
      CALL JEVEUO(DIRCO ,'E',JDIR  )
      CALL JEVEUO(ECPDON,'E',JECPD )
      CALL JEVEUO(METHCO,'E',JMETH )
      CALL JEVEUO(TANDEF,'E',JTGDEF)
      CALL JEVEUO(JEUSUP,'E',JJSUP )
      CALL JEVEUO(TANPOU,'E',JPOUDI)
      CALL JEVEUO(TOLECO,'E',JTOLE )
      CALL JEVEUO(NORLIS,'E',JNORLI)      
C
      ZMETH = CFMMVD('ZMETH')
      ZTOLE = CFMMVD('ZTOLE')
      ZECPD = CFMMVD('ZECPD')
      ZCMCF = CFMMVD('ZCMCF')
      ZTGDE = CFMMVD('ZTGDE')
      ZDIRE = CFMMVD('ZDIRE')
      ZPOUD = CFMMVD('ZPOUD')
C
C --- RECUPERATION DU NOM DU PHENOMENE ET DE LA  MODELISATION
C
      CALL DISMOI('F','PHENOMENE',NOMO,'MODELE',IBID,PHENOM,IER)
      CALL DISMOI('F','MODELISATION',NOMO,'MODELE',IBID,MODELI,IER)
C
C --- RECUPERATION DE LA METHODE DE CONTACT
C
      IF (LGLIS) THEN
        ZI(JMETH+ZMETH*(IWRITE-1)+6) = 8
      ELSE
        ZI(JMETH+ZMETH*(IWRITE-1)+6) = 6
      ENDIF  
C
C --- PARAMETRES DE L'OPTION GLISSIERE
C
      IF (LGLIS) THEN
        CALL GETVR8(MOTFAC,'ALARME_JEU',IREAD,1,1,ALJEU,NOC)
        ZR(JTOLE+ZTOLE*(IWRITE-1)+2) = ALJEU
      END IF
C
C --- PARAMETRE APPARIEMENT: MAIT_ESCL 
C
      ZI(JMETH+ZMETH*(IWRITE-1)+1) = 1
C
C --- PARAMETRE APPARIEMENT: NON SYME
C      
      ZI(JMETH+ZMETH*(IWRITE-1)+3) = 0
C
C --- PARAMETRE APPARIEMENT: RECHERCHE NOEUD_BOUCLE
C
      ZI(JMETH+ZMETH*(IWRITE-1)+5) = 1
C
C --- PARAMETRE APPARIEMENT: LISSAGE ?
C
      CALL GETVTX(MOTFAC,'LISSAGE',IREAD,1,1,LISSA,NOC)
      IF (LISSA(1:3) .EQ. 'OUI') THEN
        ZI(JNORLI+(IWRITE-1)+1) = 1
      ELSEIF (LISSA(1:3) .EQ. 'NON') THEN
        ZI(JNORLI+(IWRITE-1)+1) = 0
      ELSE
        VALK(1) = LISSA
        VALK(2) = 'LISSAGE'
        CALL U2MESK('F','CONTACT3_3',2,VALK) 
      END IF
C
C --- PARAMETRE APPARIEMENT: NORMALE MAIT
C
      ZI(JMETH+ZMETH*(IWRITE-1)+8) = 0 
C
C --- PARAMETRE APPARIEMENT: DIRE_APPA
C     
      CALL GETVR8(MOTFAC,'DIRE_APPA',IREAD,1,3,DIR1,NOC)
      ZR(JDIR+ZDIRE*(IWRITE-1))   = DIR1(1)
      ZR(JDIR+ZDIRE*(IWRITE-1)+1) = DIR1(2)
      IF (NDIM .EQ. 3) THEN
        ZR(JDIR+ZDIRE*(IWRITE-1)+2) = DIR1(3)
      ELSE
        ZR(JDIR+ZDIRE*(IWRITE-1)+2) = 0.D0
      END IF
C
C --- PARAMETRE APPARIEMENT: DIST_MAIT/DIST_ESCL
C
      CALL GETVR8(MOTFAC,'DIST_MAIT',IREAD,1,1,DIST1,NOC)
      CALL GETVR8(MOTFAC,'DIST_ESCL',IREAD,1,1,DIST2,NOC)
      ZR(JJSUP+IWRITE-1) = DIST1 + DIST2
C
C --- PARAMETRE APPARIEMENT: ORIENTATION DU REPERE LOCAL POUTRE
C
      CALL GETVR8(MOTFAC,'VECT_ORIE_POU',IREAD,1,3,DIR,NOC)
      IF (NOC.NE.0) THEN
        ZI(JMETH +ZMETH*(IWRITE-1)+2) = 2
        ZR(JPOUDI+ZPOUD*(IWRITE-1))   = DIR(1)
        ZR(JPOUDI+ZPOUD*(IWRITE-1)+1) = DIR(2)
        ZR(JPOUDI+ZPOUD*(IWRITE-1)+2) = DIR(3)
      ENDIF
C
C --- PARAMETRE APPARIEMENT: TOLE_PROJ_EXT
C --- TOLE_PROJ_EXT <0: LA PROJECTION HORS DE LA MAILLE EST INTERDITE
C --- TOLE_PROJ_EXT >0: LA PROJECTION HORS DE LA MAILLE EST AUTORISEE
C ---                    MAIS LIMITEE PAR LAMB
C
      CALL GETVR8(MOTFAC,'TOLE_PROJ_EXT',IREAD,1,1,LAMB,NOC)
      IF (LAMB .LT. 0.D0) THEN
        ZR(JTOLE+ZTOLE*(IWRITE-1)) = -1.D0
      ELSE
        ZR(JTOLE+ZTOLE*(IWRITE-1)) = LAMB
      END IF                 
C
C --- FORMULATION DEPLACEMENT OU VITESSE
C         
      CALL GETVTX(MOTFAC,'FORMULATION',IREAD,1,1,FORM,NOC)
      IF (FORM(1:4) .EQ. 'DEPL') THEN
        ZI(JECPD+ZECPD*(IWRITE-1)+6) = 1
      ELSEIF (FORM(1:4) .EQ. 'VITE') THEN
        ZI(JECPD+ZECPD*(IWRITE-1)+6) = 2
      ELSE
        VALK(1) = FORM
        VALK(2) = 'FORMULATION'
        CALL U2MESK('F','CONTACT3_3',2,VALK) 
      END IF
C
C --- TYPE INTEGRATION
C
      CALL GETVTX(MOTFAC,'INTEGRATION',IREAD,1,1,INTEG,NOC)
      IF (INTEG(1:5) .EQ. 'NOEUD') THEN
        LINTNO=.TRUE.
        ZR(JCMCF+ZCMCF*(IWRITE-1)+1) = 1.D0
      ELSEIF (INTEG(1:5) .EQ. 'GAUSS') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+1) = 2.D0
      ELSEIF (INTEG(1:7) .EQ. 'SIMPSON') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+1) = 3.D0
        IF (INTEG(1:8) .EQ. 'SIMPSON1') THEN
          ZR(JCMCF+ZCMCF*(IWRITE-1)+1) = 4.D0
        END IF
        IF (INTEG(1:8) .EQ. 'SIMPSON2') THEN
          ZR(JCMCF+ZCMCF*(IWRITE-1)+1) = 5.D0
        END IF
      ELSEIF (INTEG(1:6) .EQ. 'NCOTES') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+1) = 6.D0
        IF (INTEG(1:7) .EQ. 'NCOTES1') THEN
          ZR(JCMCF+ZCMCF*(IWRITE-1)+1) = 7.D0
        END IF
        IF (INTEG(1:7) .EQ. 'NCOTES2') THEN
          ZR(JCMCF+ZCMCF*(IWRITE-1)+1) = 8.D0
        END IF
      ELSE
        VALK(1) = INTEG
        VALK(2) = 'INTEGRATION'
        CALL U2MESK('F','CONTACT3_3',2,VALK) 
      END IF
C      
C --- OPTIONS ALGORITHME CONTACT
C  
      CALL GETVTX(MOTFAC,'ALGO_CONT',IREAD,1,1,ALGOC,NOC)
      IF (ALGOC(1:10) .EQ. 'LAGRANGIEN') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+16) = 1.D0
        CALL GETVR8(MOTFAC,'COEF_REGU_CONT',IREAD,1,1,COCAUR,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+2) = COCAUR
      ELSEIF (ALGOC(1:9) .EQ. 'STABILISE') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+16) = 2.D0
        CALL GETVR8(MOTFAC,'COEF_REGU_CONT',IREAD,1,1,COCAUR,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+2) = COCAUR
        CALL GETVR8(MOTFAC,'COEF_STAB_CONT',IREAD,1,1,COCAUS,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+17) = COCAUS
      ELSEIF (ALGOC(1:8) .EQ. 'AUGMENTE') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+16) = 3.D0
        CALL GETVR8(MOTFAC,'COEF_REGU_CONT',IREAD,1,1,COCAUR,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+2) = COCAUR
        CALL GETVR8(MOTFAC,'COEF_STAB_CONT',IREAD,1,1,COCAUS,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+17) = COCAUS
        CALL GETVR8(MOTFAC,'COEF_PENA_CONT',IREAD,1,1,COCAUP,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+18) = COCAUP
      ELSE
        VALK(1) = ALGOC
        VALK(2) = 'ALGO_CONT'
        CALL U2MESK('F','CONTACT3_3',2,VALK) 
      END IF
C      
C --- OPTIONS ALGORITHME FROTTEMENT
C  
      CALL GETVTX(MOTFAC,'FROTTEMENT',IREAD,1,1,FROT,NOCC)
      IF (FROT(1:7) .EQ. 'COULOMB') THEN
        CALL GETVTX(MOTFAC,'ALGO_FROT',IREAD,1,1,ALGOF,NOC)
        LFROT = .TRUE.
        IF (ALGOF(1:10) .EQ. 'LAGRANGIEN') THEN
          ZR(JCMCF+ZCMCF*(IWRITE-1)+19) = 1.D0
          CALL GETVR8(MOTFAC,'COEF_REGU_FROT',IREAD,1,1,COFAUR,NOC)
          ZR(JCMCF+ZCMCF*(IWRITE-1)+3) = COFAUR
        ELSEIF (ALGOF(1:9) .EQ. 'STABILISE') THEN
          ZR(JCMCF+ZCMCF*(IWRITE-1)+19) = 2.D0
          CALL GETVR8(MOTFAC,'COEF_REGU_FROT',IREAD,1,1,COFAUR,NOC)
          ZR(JCMCF+ZCMCF*(IWRITE-1)+3) = COFAUR
          CALL GETVR8(MOTFAC,'COEF_STAB_FROT',IREAD,1,1,COFAUS,NOC)
          ZR(JCMCF+ZCMCF*(IWRITE-1)+20) = COFAUS
        ELSEIF (ALGOF(1:8) .EQ. 'AUGMENTE') THEN
          ZR(JCMCF+ZCMCF*(IWRITE-1)+19) = 3.D0
          CALL GETVR8(MOTFAC,'COEF_REGU_FROT',IREAD,1,1,COFAUR,NOC)
          ZR(JCMCF+ZCMCF*(IWRITE-1)+3) = COFAUR
          CALL GETVR8(MOTFAC,'COEF_STAB_FROT',IREAD,1,1,COFAUS,NOC)
          ZR(JCMCF+ZCMCF*(IWRITE-1)+20) = COFAUS
          CALL GETVR8(MOTFAC,'COEF_PENA_FROT',IREAD,1,1,COFAUP,NOC)
          ZR(JCMCF+ZCMCF*(IWRITE-1)+21) = COFAUP
        ELSE
          VALK(1) = ALGOF
          VALK(2) = 'ALGO_FROT'
          CALL U2MESK('F','CONTACT3_3',2,VALK) 
        END IF
        ZR(JCMCF+ZCMCF*(IWRITE-1)+5) = 3.D0
        CALL GETVR8(MOTFAC,'COULOMB',IREAD,1,1,COEFRO,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+4) = COEFRO
        CALL GETVR8(MOTFAC,'SEUIL_INIT',IREAD,1,1,REACSI,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+6) = REACSI
      ELSEIF (FROT(1:4) .EQ. 'SANS') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+5) = 1.D0
        LFROT = .FALSE.
      ELSE
        VALK(1) = FROT
        VALK(2) = 'FROTTEMENT'
        CALL U2MESK('F','CONTACT3_3',2,VALK) 
      END IF
C
C --- LECTURE DES PARAMETRES DE LA COMPLIANCE
C
      CALL GETVTX(MOTFAC,'COMPLIANCE',IREAD,1,1,COMPLI,NOC)
      IF (COMPLI .EQ. 'OUI') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+7) = 1
        CALL GETVR8(MOTFAC,'ASPERITE',IREAD,1,1,ASPER,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+8) = ASPER
        CALL GETVR8(MOTFAC,'E_N',IREAD,1,1,KAPPAN,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+9) = KAPPAN
        CALL GETVR8(MOTFAC,'E_V',IREAD,1,1,KAPPAV,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+10) = KAPPAV
      ELSEIF (COMPLI .EQ. 'NON') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+7) = 0
        ZR(JCMCF+ZCMCF*(IWRITE-1)+8) = 0.D0
      ELSE
        VALK(1) = COMPLI
        VALK(2) = 'COMPLIANCE'
        CALL U2MESK('F','CONTACT3_3',2,VALK)   
      END IF
C
C --- LECTURE DES PARAMETRES DE LA LOI D'USURE 
C
      IF (LFROT) THEN
        CALL GETVTX(MOTFAC,'USURE',IREAD,1,1,INDUSU,NOC)
        IF (INDUSU .EQ. 'ARCHARD') THEN
          ZR(JCMCF+ZCMCF*(IWRITE-1)+13) = 1
          CALL GETVR8(MOTFAC,'K',IREAD,1,1,KWEAR,NOC)
          ZR(JCMCF+ZCMCF*(IWRITE-1)+14) = KWEAR
          CALL GETVR8(MOTFAC,'H',IREAD,1,1,HWEAR,NOC)
          ZR(JCMCF+ZCMCF*(IWRITE-1)+15) = HWEAR
        ELSEIF (INDUSU .EQ. 'SANS') THEN
          ZR(JCMCF+ZCMCF*(IWRITE-1)+13) = 0
        ELSE
          VALK(1) = INDUSU
          VALK(2) = 'USURE'
          CALL U2MESK('F','CONTACT3_3',2,VALK)           
        END IF
      ENDIF     
C
C --- TRAITEMENT EXCLUSION NOEUDS
C
      CALL GETVTX(MOTFAC,'SANS_GROUP_NO',IREAD,1,1,SGRNO,NOC)
      IF ((NOC.NE.0) .AND. (.NOT.LINTNO)) THEN
        CALL U2MESS('F','CONTACT_97')
      ENDIF
C
      IF (LFROT) THEN
        CALL GETVR8(MOTFAC,'VECT_Y',IREAD,1,3,DIR,NOC)
        IF (NOC.NE.0) THEN
          ZI(JMETH+ZMETH*(IWRITE-1)+2) = 1
        ENDIF
        IF (NOC.NE.0 .AND. NDIM.GE.2) THEN
          ZR(JTGDEF+ZTGDE*(IWRITE-1))   = DIR(1)
          ZR(JTGDEF+ZTGDE*(IWRITE-1)+1) = DIR(2)
          ZR(JTGDEF+ZTGDE*(IWRITE-1)+2) = DIR(3)
        ELSE
          ZR(JTGDEF+ZTGDE*(IWRITE-1))   = 0.D0
          ZR(JTGDEF+ZTGDE*(IWRITE-1)+1) = 0.D0
          ZR(JTGDEF+ZTGDE*(IWRITE-1)+2) = 0.D0
        END IF
        CALL GETVR8(MOTFAC,'VECT_Z',IREAD,1,3,DIR,NOC)
        IF (NOC .NE. 0) THEN
          ZR(JTGDEF+ZTGDE*(IWRITE-1)+3) = DIR(1)
          ZR(JTGDEF+ZTGDE*(IWRITE-1)+4) = DIR(2)
          ZR(JTGDEF+ZTGDE*(IWRITE-1)+5) = DIR(3)
        ELSE
          ZR(JTGDEF+ZTGDE*(IWRITE-1)+3) = 0.D0
          ZR(JTGDEF+ZTGDE*(IWRITE-1)+4) = 0.D0
          ZR(JTGDEF+ZTGDE*(IWRITE-1)+5) = 0.D0
        END IF
      END IF      
C      
      CALL GETVTX(MOTFAC,'FOND_FISSURE',IREAD,1,1,FONFIS,NOC)
      IF (FONFIS .EQ. 'OUI') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+11) = 1.D0
      ELSEIF (FONFIS .EQ. 'NON') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+11) = 0.D0
      ELSE  
        VALK(1) = FONFIS
        VALK(2) = 'FOND_FISSURE'
        CALL U2MESK('F','CONTACT3_3',2,VALK)       
      END IF
C      
      CALL GETVTX(MOTFAC,'RACCORD_LINE_QUAD',IREAD,1,1,RACSUR,NOC)
      IF (RACSUR .EQ. 'OUI') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+12) = 1.D0
      ELSEIF (RACSUR .EQ. 'NON') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+12) = 0.D0
      ELSE  
        VALK(1) = RACSUR
        VALK(2) = 'RACCORD_LINE_QUAD'
        CALL U2MESK('F','CONTACT3_3',2,VALK)       
      END IF
C      
      CALL GETVTX(MOTFAC,'EXCLUSION_PIV_NUL',IREAD,1,1,PIVAUT,NOC)
      IF (PIVAUT .EQ. 'OUI') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+22) = 1.D0
      ELSEIF (PIVAUT .EQ. 'NON') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+22) = 0.D0
      ELSE
        VALK(1) = PIVAUT
        VALK(2) = 'EXCLUSION_PIV_NUL'
        CALL U2MESK('F','CONTACT3_3',2,VALK)        
      END IF
C
C -- AXISYMETRIE
C      
      MOTCLE(1) = 'GROUP_MA_MAIT'
      MOTCLE(2) = 'MAILLE_MAIT'
      TYMOCL(1) = 'GROUP_MA'
      TYMOCL(2) = 'MAILLE'
      LISMA = '&&CARACO.LISTE_MAILLES_1'
      CALL RELIEM(NOMO,NOMA,'NU_MAILLE',MOTFAC,IREAD,2,MOTCLE,TYMOCL,
     &            LISMA,NBMA1)
C
C --- MAILLES MAITRES AXISYMETRIQUES ?
C      
      LMAIT  = MMMAXI(NOMO,LISMA,NBMA1)
C
      MOTCLE(1) = 'GROUP_MA_ESCL'
      MOTCLE(2) = 'MAILLE_ESCL'
      TYMOCL(1) = 'GROUP_MA'
      TYMOCL(2) = 'MAILLE'
      CALL RELIEM(NOMO,NOMA,'NU_MAILLE',MOTFAC,IREAD,2,MOTCLE,TYMOCL,
     &            LISMA,NBMA1)
C
C --- MAILLES ESCLAVES AXISYMETRIQUES ? 
C     
      LESCL  = MMMAXI(NOMO,LISMA,NBMA1)
C
C --- MODELE AXISYMETRIQUE ? 
C
      LAXIS  = .FALSE.
      IF (LMAIT.EQV.LESCL) THEN
        IF (LMAIT) LAXIS=.TRUE. 
      ELSE
        CALL U2MESS('F','CONTACT2_12')
      ENDIF
           
      IF (LAXIS) THEN
        ZI(JECPD+ZECPD*(IWRITE-1)+1) = 1
      ELSE
        ZI(JECPD+ZECPD*(IWRITE-1)+1) = 0
      END IF
C
C --- PARAMETRES BOUCLES
C
      CALL GETVIS(MOTFAC,'ITER_CONT_MAXI',IREAD,1,1,REACCA,NOC)
      ZI(JECPD+ZECPD*(IWRITE-1)+2) = REACCA
      CALL GETVIS(MOTFAC,'ITER_GEOM_MAXI',IREAD,1,1,REACBG,NOC)
      ZI(JECPD+ZECPD*(IWRITE-1)+4) = REACBG
      IF (LFROT) THEN
        CALL GETVIS(MOTFAC,'ITER_FROT_MAXI',IREAD,1,1,REACBS,NOC)
        ZI(JECPD+ZECPD*(IWRITE-1)+3) = REACBS
      ENDIF  
C
C --- CONTACT INITIAL
C
      CALL GETVTX(MOTFAC,'CONTACT_INIT',IREAD,1,1,STACO0,NOC)
      IF (STACO0 .EQ. 'OUI') THEN
        ZI(JECPD+ZECPD*(IWRITE-1)+5) = 1
      ELSEIF (STACO0 .EQ. 'NON') THEN
        ZI(JECPD+ZECPD*(IWRITE-1)+5) = 0
      ELSE
        VALK(1) = STACO0
        VALK(2) = 'CONTACT_INIT'
        CALL U2MESK('F','CONTACT3_3',2,VALK)        
      END IF
C
C --- AJOUT DES ELEMENTS TARDIFS AU LIGREL
C
      MOTCLE(1) = 'GROUP_MA_ESCL'
      MOTCLE(2) = 'MAILLE_ESCL'
      TYMOCL(1) = 'GROUP_MA'
      TYMOCL(2) = 'MAILLE'
      LISMA = '&&CARACO.LISTE_MAILLES_1'
      CALL RELIEM(NOMO,NOMA,'NU_MAILLE',MOTFAC,IREAD,2,MOTCLE,TYMOCL,
     &            LISMA,NBMA1)
C
      IF (NDIM .EQ. 2) THEN
        MODELI = 'CONT_DVP_2D'
      ELSEIF (NDIM .EQ. 3) THEN
        MODELI = 'CONT_DVP_3D'
      ELSE 
        CALL ASSERT(.FALSE.) 
      END IF
C
      CALL AJELLT('&&CALICO.LIGRET',NOMA,NBMA1,LISMA,' ',PHENOM,MODELI,
     &           0,' ')
C
      CALL JEDEMA()
      END
