      SUBROUTINE OP0070 (IER)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 04/04/2006   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE MABBAS M.ABBAS
C TOLE CRP_20
C
      IMPLICIT NONE
C      IMPLICIT REAL*8 (A-H,O-Z)
C
      INTEGER            IER
C ----------------------------------------------------------------------
C     COMMANDE:  STAT_NON_LINE/DYNA_NON_LINE/DYNA_TRAN_EXPLI
C
C
C  OUT: IER =      NOMBRE D'ERREURS RENCONTREES
C ----------------------------------------------------------------------
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
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
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'OP0070' )
C
      INTEGER      ZFON
      PARAMETER   (ZFON = 12)
      LOGICAL      ECHLDC, ITEMAX, CONVER, FINPAS, FINTPS, FONACT(ZFON)
      LOGICAL      DIDERN, ECHCON(2), REAROT, LAMORT, LBID, LIMPED
      LOGICAL      PREMIE, LONDE,  ECHEQU, LOBSER, DECOL, MTCPUI, MTCPUP
      LOGICAL      LREAC(2), LOGIC, LMODAL,MAXREL,ECHPIL, FOPREC, LFETI
C
      INTEGER      LICCVG(5), MAXB(4), VECONT(2),TYPALC
      INTEGER      IFM,    NIV
      INTEGER      NEQ,    IRET,   IBID,   I 
      INTEGER      NUMINS, ITERAT
      INTEGER      JDEPDE, JDEPP,  JDDEPL, JARCH
      INTEGER      COMGEO, CSEUIL, COBCA,  INDRO,  ISNNEM, NBMODS
      INTEGER      NMODAM, NREAVI, NONDP
      INTEGER      NBOBSE, NUINS0
      INTEGER      NBOBAR, NUOBSE, NBPASE, NIVEAU
      INTEGER      IFLAMB,  DININS
      INTEGER      IALGO
      INTEGER      JACCGP, JDEPGP, JRESTA, JRESTD, JRESTV, JVITGP 
      INTEGER      NBMODE, NUMA
C
      REAL*8       PARMET(30), PARCRI(11), CONV(21), ETA, ETAN, R8VIDE
      REAL*8       DIINST,     INSTAM,     INSTAP,   INST(5),   ALPHA
      REAL*8       V0VIT,      V0ACC,      A0VIT,    A0ACC,     COEVIT
      REAL*8       COEACC,     DELTA,      TPS1(4),  TPS2(4),   TPS3(4)
      REAL*8       PARCON(5),  TPS1M,      TETA,     VALR(3) ,  COEDEP
      REAL*8       PHI,R8BID
C
      CHARACTER*8  RESULT, MODEDE, MAILLA, SCONEL, MCONEL, K8BID
      CHARACTER*8  MAILL2, BASENO
C
      CHARACTER*13 INPSCO,K13BID
      CHARACTER*14 PILOTE
C
      CHARACTER*16 METHOD(6), OPTION, CMD, K16BID
C
      CHARACTER*19 LISCHA, SOLVEU, SOLVDE, PARTPS, CRITNL
      CHARACTER*19 CNRESI, CNDIRI, CNVCFO, CNFEXT, CNVFRE
      CHARACTER*19 NURO,   CARTCF, LIGRCF, CNSINR, FOINER
      CHARACTER*19 CNFOLD, K19BID
      CHARACTER*19 MAPREC, LISOBS, NOMTAB, AUTOC1, AUTOC2
      CHARACTER*19 MATRIX(2), LISCH2, CNVCF1, MATASS
C
      CHARACTER*24 MODELE, NUMEDD, MATE  , CARELE, COMPOR, CARCRI
      CHARACTER*24 NUMEDE, DEFICO, RESOCO, K24BLA, K24BID, TEMPLU
      CHARACTER*24 DEPMOI, SIGMOI, VARMOI, VARDEM, LAGDEM, MEMASS
      CHARACTER*24 DEPPLU, SIGPLU, VARPLU, VARDEP, LAGDEP, DEPDEL
      CHARACTER*24 COMMOI, COMPLU, COMREF, DDEPLA, DEPOLD, DEPPIL(2)
      CHARACTER*24 CNFEDO, CNFEPI, CNDIDO, CNDIPI, CNFSDO, CNFSPI
      CHARACTER*24 CNDIDI, CNCINE, MEDIRI, DEPENT, VITENT, ACCENT
      CHARACTER*24 VITMOI, ACCMOI, DEPENM, VITENM, ACCENM, VARIGV
      CHARACTER*24 DEPKM1, VITKM1, ACCKM1, VITPLU, ACCPLU, ROMKM1
      CHARACTER*24 ROMK,   OLDGEO, NEWGEO, DEPGEO, DEPLAM, SUIVCO      
      CHARACTER*24 STADYN, AMORT,  VALMOD, BASMOD, CHONDP, MASSE
      CHARACTER*24 FONDEP, FONVIT, FONACC, MULTAP, PSIDEL, IMPRCO
      CHARACTER*24 VALMOI(8), VALPLU(8), SECMBR(8), POUGD(8), MULTIA(8)
      CHARACTER*24 SECOLD(8), OPT, RIGID
      CHARACTER*24 LISINS, VITINI, ACCINI, MASGEN, BASMOI, CHGRFL
      CHARACTER*24 DEFICU, RESOCU      
      CHARACTER*24 ACCGEM, ACCGEP, VITGEM, VITGEP
      CHARACTER*24 DEPGEM, DEPGEP, RIGGEN, AMOGEN, FONGEN, FORGEN
      CHARACTER*19 RESUL2
      LOGICAL      LSSTRU
C
C ----------------------------------------------------------------------
C
      DATA LISCHA, PARTPS    /'&&OP0070.LISCHA', '&&OP0070.PARTPS'/
      DATA CRITNL, CARCRI    /'&&OP0070.CRITERE','&&OP0070.PARA_LDC'/
      DATA SOLVEU, SOLVDE    /'&&OP0070.SOLVEUR','&&OP0070.SOLVDE'/
      DATA PILOTE, RESOCO    /'&&OP0070.PILOT',  '&&OP0070.RESOC'/
      DATA DEFICU, RESOCU    /'&&OP0070.DEFUC',  '&&OP0070.RESUC'/      
      DATA DEPDEL, DDEPLA    /'&&OP0070.DEPDEL', '&&OP0070.DDEPLA'/
      DATA DEPPIL            /'&&OP0070.DEPPIL0','&&OP0070.DEPPIL1'/
      DATA DEPOLD, DEFICO    /'&&OP0070.DEPOLD', '&&OP0070.DEFIC'/
      DATA VITMOI, ACCMOI    /'&&OP0070.VITMOI', '&&OP0070.ACCMOI'/
      DATA DEPKM1,VITKM1     /'&&OP0070.DEPKM1', '&&OP0070.VITKM1'/
      DATA ACCKM1            /'&&OP0070.ACCKM1'/
      DATA VITPLU, ACCPLU    /'&&OP0070.VITPLU', '&&OP0070.ACCPLU'/
      DATA VITINI, ACCINI    /'&&OP0070.VITINI', '&&OP0070.ACCINI'/
      DATA DEPENT,VITENT     /'&&OP0070.DEPENT', '&&OP0070.VITENT'/
      DATA ACCENT            /'&&OP0070.ACCENT'/
      DATA ROMKM1,ROMK       /'&&OP0070.ROMKM1', '&&OP0070.ROMK  '/
      DATA DEPENM,VITENM     /'&&OP0070.DEPENM', '&&OP0070.VITENM'/
      DATA ACCENM            /'&&OP0070.ACCENM'/
      DATA NURO              /'&&OP0070.NUME.ROTATION'/
      DATA DEPGEO, DEPLAM    /'&&OP0070.DEPGEO', '&&OP0070.DEPLAM'/
      DATA LIGRCF, CARTCF    /'&&OP0070.LIMECF', '&&OP0070.CARTCF'/
      DATA NEWGEO            /'&&OP0070.ACTUGEO'/
      DATA VARDEM, VARDEP    /'&&OP0070.VARDEM', '&&OP0070.VARDEP'/
      DATA LAGDEM, LAGDEP    /'&&OP0070.LAGDEM', '&&OP0070.LAGDEP'/
      DATA VARIGV            /'&&OP0070.VARIGV'/
      DATA COMMOI, COMPLU    /'&&OP0070.COMOI' , '&&OP0070.COPLU' /
      DATA COMREF            /'&&OP0070.COREF'/
      DATA CNFEDO, CNFEPI    /'&&OP0070.CNFEDO', '&&OP0070.CNFEPI'/
      DATA CNFSDO, CNFSPI    /'&&OP0070.CNFSDO', '&&OP0070.CNFSPI'/
      DATA CNDIDO, CNDIPI    /'&&OP0070.CNDIDO', '&&OP0070.CNDIPI'/
      DATA CNDIDI, CNCINE    /'&&OP0070.CNDIDI', '&&OP0070.CNCINE'/
      DATA CNFOLD            /'&&OP0070.CNFOLD'/
      DATA CNRESI, CNDIRI    /'&&OP0070.CNRESI', '&&OP0070.CNDIRI'/
      DATA CNFEXT, MEDIRI    /'&&OP0070.CNFEXT', '&&MEDIRI.LISTE_RESU'/
      DATA CNVCFO, CNVFRE    /'&&OP0070.CNVCFO', '&&OP0070.CNVFRE'/
      DATA CNVCF1            /'&&OP0070.CNVCF1'/
      DATA MEMASS, FOINER    /'&&OP0070.MEMASS', '&&OP0070.FOINER'/
      DATA AMORT , MASSE     /'&&OP0070.MAMORT', '&&OP0070.MMASSE'/
      DATA MAPREC, RIGID     /'&&OP0070.MAPREC', '&&OP0070.MRIGID'/
      DATA STADYN, MATASS    /'&&OP0070.STA_DYN','&&OP0070.MATASS'/
      DATA MASGEN, BASMOI    /'&&OP0070.MASGEN', '&&OP0070.BASMOI'/
      DATA MCONEL, SCONEL    /'&&CFMMEL', '&&CFMVEL'/
      DATA FONDEP, FONVIT    /'&&FONDEP', '&&FONVIT'/
      DATA FONACC, PSIDEL    /'&&FONACC', '&&PSIDEL'/
      DATA MULTAP, VALMOD    /'&&MULTAP', '&&VALMOD'/
      DATA BASMOD            /'&&BASMOD'/
      DATA AUTOC1            /'&&OP0070.REAC.AUTO1'/
      DATA AUTOC2            /'&&OP0070.REAC.AUTO2'/
      DATA CHGRFL            /'&&OP0070.GRAPPE_FLUIDE  '/
      DATA LISOBS            /'&&OP0070.OBSERVATIO'/
      DATA IMPRCO            /'&&OP0070.IMPR.          '/
      DATA SUIVCO            /'&&OP0070.SUIV.          '/        
      DATA CNSINR            /' '/
      DATA K24BLA            /' '/
      DATA ACCGEM, ACCGEP    /'&&ACCGEM', '&&ACCGEP'/      
      DATA VITGEM, VITGEP    /'&&VITGEM', '&&VITGEP'/
      DATA DEPGEM, DEPGEP    /'&&DEPGEM', '&&DEPGEP'/
      DATA RIGGEN, AMOGEN    /'&&RIGGEN', '&&AMOGEN'/
      DATA FONGEN, FORGEN    /'&&FONGEN', '&&FORGEN'/

C ----------------------------------------------------------------------
      CALL JEMARQ()

C -- TITRE

      CALL TITRE ()
      CALL INFMAJ
      CALL INFNIV (IFM,NIV)

C ======================================================================
C               RECUPERATION DES OPERANDES ET INITIALISATION
C ======================================================================

C -- QUELLE COMMANDE APPELLE CETTE OP (STA OU DYN)

      CALL GETRES ( RESULT, K16BID, CMD )

C -- PREMIERES INITALISATIONS ET AGGLOMERATIONS
     
      CALL NMINI0(NOMPRO,COMGEO,CSEUIL,COBCA, NMODAM,NBMODS,COEDEP,
     &            COEVIT,COEACC,ETA   ,LONDE ,LIMPED,LAMORT,LBID,K8BID,
     &            K13BID,K24BID,LICCVG,NUMINS,PREMIE,DECOL ,MTCPUI,
     &            MTCPUP,LISCH2,BASENO,INPSCO,FINPAS,ZFON,FONACT,
     &            FOPREC)
C
C -- LECTURE DES OPERANDES DE LA COMMANDE (OPERANDES GENERALES)
C

      CALL NMLECT (RESULT, MODELE, MATE  , CARELE, COMPOR,
     &             LISCHA, METHOD, SOLVEU, PARMET, PARCRI,
     &             CARCRI, MODEDE, SOLVDE, NBPASE, BASENO,
     &             INPSCO, PARCON )

C
C -- LECTURE DES OPERANDES DE LA COMMANDE (OPERANDES POUR DYNAMIQUE)
C
      IF (CMD(1:4).EQ.'DYNA') THEN 
         CALL NDLECT(CMD,    MODELE, MATE,   LISCHA, STADYN, LAMORT,
     &               ALPHA,  DELTA,  PHI,    V0VIT,  V0ACC,  A0VIT, 
     &               A0ACC,  NBMODS, NMODAM, VALMOD, BASMOD,
     &               NREAVI, LIMPED, LONDE,  CHONDP, NONDP, CHGRFL,
     &               TETA,   IALGO,  FONDEP, FONVIT, FONACC, 
     &               MULTAP, PSIDEL )
      ENDIF

C -- MATRICE DE RIGIDITE ASSOCIEE AUX LAGRANGE

      CALL MEDIME (MODELE,LISCHA,MEDIRI)

C -- ETAT INITIAL ET CREATION DES STRUCTURES DE DONNEES

      CALL NMINIT(RESULT,MODELE,MODEDE,NUMEDD,MATE  ,SOLVDE,NUMEDE,
     &            COMPOR,CARELE,MEMASS,MASSE,MEDIRI,LISCHA,DEPPLU,
     &            DEPMOI,SIGPLU,SIGMOI,VARPLU,VARMOI,VALMOI,VITPLU,
     &            ACCPLU,MAPREC,SOLVEU,DEPENT,VITENT,ACCENT,CARCRI,
     &            COMMOI,COMPLU,VARDEP,LAGDEP,VARIGV,CNFEDO,CNFEPI,
     &            CNDIDO,CNDIPI,CNFSDO,CNFSPI,CNDIDI,CNCINE,DEPKM1,
     &            VITKM1,ACCKM1,ROMKM1,ROMK  ,DDEPLA,FONDEP,FONVIT,
     &            FONACC,MULTAP,PSIDEL,VALPLU,SECMBR,POUGD ,MULTIA,
     &            PARTPS,NURO  ,REAROT,VARDEM,LAGDEM,PILOTE,DEFICO,
     &            RESOCO,CRITNL,ZFON,FONACT,CMD   ,NBMODS,CNVFRE,
     &            PARCON,PARCRI(6),NBPASE,INPSCO,LISCH2,NBOBSE,NUINS0,
     &            LOBSER,NUOBSE,NOMTAB,MAILL2,NBOBAR,LISINS,LISOBS,
     &            INSTAM,IMPRCO,SUIVCO,DEFICU,RESOCU)     
     
      LMODAL = .FALSE.
      LSSTRU = .FALSE.
      IF (CMD.EQ.'DYNA_TRAN_EXPLI') THEN
        RESUL2 = RESULT
        CALL MXMOAM(MASGEN,BASMOI,LMODAL,LSSTRU,ACCGEM,ACCGEP,
     &              VITGEM,VITGEP,DEPGEM,DEPGEP,RIGGEN,AMOGEN,
     &              FONGEN,FORGEN,RESUL2,INSTAM,NUMA)
        IF (LSSTRU) THEN
          CALL JEVEUO(RESUL2//'.DGEN','E',JRESTD)
          CALL JEVEUO(RESUL2//'.VGEN','E',JRESTV)
          CALL JEVEUO(RESUL2//'.AGEN','E',JRESTA)
        ENDIF
      ENDIF


C -- CREATION DES VECTEURS D'INCONNUS 

      CALL NMCRCH(CMD,    DEPPLU, DEPDEL, DEPOLD, DDEPLA, DEPPIL, 
     &            DEPLAM, DEPKM1, VITKM1, ACCKM1, ROMKM1, ROMK  ,
     &            FOINER, DEPENT, VITENT, ACCENT, DEPENM, VITENM,
     &            ACCENM, VITMOI, ACCMOI, DEPGEO, VITPLU, ACCPLU,
     &            NEQ,    NUMEDD, NBPASE, INPSCO, NBMODS, VITINI,
     &            ACCINI)

C -- MAILLAGE SOUS-TENDU PAR LE MODELE

      CALL DISMOI ('F','NOM_MAILLA',MODELE,'MODELE',IBID,MAILLA,IRET)

C -- TRAITEMENT DES VARIABLES DE COMMANDE
C

C -- VERIFICATION DE LA COHERENCE MATERIAU / VARIABLES PRESENTES
      CALL NMVCVE(MATE,LISCHA)

C -- LECTURE DES VARIABLES DE COMMANDE DE L'INSTANT INITIAL
      CALL NMVCLE(MODELE,MATE,CARELE,LISCHA,INSTAM,COMMOI)

C -- LECTURE DES VALEURS DE REFERENCE DES VARIABLES DE COMMANDE
      CALL NMVCRE(MODELE,MATE,LISCHA,COMREF)

C -- ESTIMATION DES FORCES NODALES LIEE AUX VAR. COMMANDES INITIALES
      CALL NMVCFO(MODELE(1:8), NUMEDD, MATE  , CARELE, COMREF,
     &            COMMOI, CNVCF1)

C -- POUTRES EN GRANDES ROTATIONS
      INDRO = ISNNEM()
      IF (REAROT) CALL JEVEUO (NURO//'.NDRO','L',INDRO)


C ======================================================================
C                   BOUCLE SUR LES PAS DE TEMPS
C ======================================================================

      CALL UTTCPU (1,'INIT',4,TPS1)
      CALL UTTCPU (2,'INIT',4,TPS2)
      CALL UTTCPU (3,'INIT',4,TPS3)

C ======================================================================
C                REPRISE DE LA BOUCLE EN TEMPS 
C ======================================================================
 200  CONTINUE
C


      CALL JERECU('V')
      TPS1M = TPS1(3)
      CALL UTTCPU (1,'DEBUT',4,TPS1)

 210  CONTINUE
      
      IF ((DININS(PARTPS,NUMINS-1)-DININS(PARTPS,NUMINS)).GT.1) THEN
        CALL DIDECO(PARTPS, NUMINS, IRET)
        IF (IRET.EQ.0) THEN
          GOTO 210
        ELSE
          CALL UTMESS('F',NOMPRO,'ERREUR DANS DECOUPE INITIALE DES PAS')
        ENDIF
      ENDIF     
      INSTAP = DIINST(PARTPS, NUMINS)

C -- DOIT-ON FAIRE UNE OBSERVATION

      CALL LOBS(NBOBSE, NUINS0, LOBSER, INSTAP,
     &          NUOBSE, LISINS, LISOBS)

C -- MISE A ZERO LAGRANGIENS POUR CONTACT CONTINU

      CALL MISAZL(DEPMOI,DEFICO)
      IF (CMD(1:4).EQ.'DYNA') THEN
        CALL MISAZL(ACCPLU,DEFICO)    
        CALL MISAZL(VITPLU,DEFICO)
      END IF      
      
C -- IMPRESSION TITRE TABLEAU DE CONVERGENCE
      
      IF (CMD.EQ.'DYNA_TRAN_EXPLI') THEN
        CALL NMIMPR('TITR','DYNA_TRAN',' ',INSTAP,0) 
      ELSE
        CALL NMIMPR('TITR',' ',' ',INSTAP,0)                    
      ENDIF

C --  REINITIALISATION DU TABLEAU DE CONVERGENCE
      DO 10 I = 1 , 21
        CONV(I) = R8VIDE()
 10   CONTINUE
      CONV(3)=-1
      CONV(10)=-1

C -- INITIALISATION DU CONTACT POUR LE NOUVEAU PAS DE TEMPS 

      CALL CFINIT(DEFICO,NUMEDD,FONACT(4),NINT(PARMET(1)),
     &            NUMINS,NEQ,AUTOC1,AUTOC2,VECONT,LREAC)

C ======================================================================
C        EVALUATION DES CHAMPS POUR LE NOUVEAU PAS DE TEMPS
C ======================================================================


C -- ESTIMATIONS INITIALES DES VARIABLES INTERNES ET DES MULTIPLICATEURS

      CALL COPISD('CHAMP_GD','V',VARMOI,VARPLU)
      IF (MODEDE.NE.' ') CALL COPISD('CHAMP_GD','V',VARDEM,VARDEP)
      IF (MODEDE.NE.' ') CALL COPISD('CHAMP_GD','V',LAGDEM,LAGDEP)


C -- INITIALISATION DES DEPLACEMENTS, VITESSES 

      CALL COPISD('CHAMP_GD','V',DEPMOI,DEPPLU)
      CALL JEVEUO (DEPDEL(1:19)//'.VALE','E',JDEPDE)
      CALL JEVEUO (DEPPLU(1:19)//'.VALE','E',JDEPP )
      CALL JEVEUO (DDEPLA(1:19)//'.VALE','E',JDDEPL)
      CALL INITIA (NEQ,REAROT,ZI(INDRO),ZR(JDEPP),ZR(JDEPDE))
      IF (CMD(1:4).EQ.'DYNA') 
     &    CALL DINIT(NEQ,V0VIT,V0ACC,A0VIT,A0ACC,ALPHA,DELTA,PHI,
     &               INSTAM,INSTAP,COEDEP,COEVIT,COEACC,DEPPLU,POUGD,
     &               DEPENT,VITENT,ACCENT,MULTIA,NBMODS,NBPASE,INPSCO,
     &               TETA,IALGO,CMD,DEFICO,DECOL,VITMOI,ACCMOI,
     &               DEPDEL,VITPLU,ACCPLU,LSSTRU,ACCGEM,VITGEM,
     &               DEPGEM,DEPGEP)


C -- LECTURE DES VARIABLES DE COMMANDE A L'INSTANT COURANT
      CALL NMVCLE(MODELE,MATE,CARELE,LISCHA,INSTAP,COMPLU)

C -- ESTIMATION D'UNE FORCE DE REFERENCE LIEE AUX VAR. COMMANDES EN T+
      CALL NMVCFO(MODELE, NUMEDD, MATE  , CARELE, COMREF,
     &            COMPLU, CNVCFO)

C -- ADHERENCE DES POUTRES EN GRANDES ROTATIONS
      CALL NMVCEX('TEMP',COMPLU,TEMPLU)

C -- PARAMETRES DE L'INSTANT DE CALCUL (SUIVANT SCHEMA D'INTEGRATION)

      INST(1) = INSTAP
      INST(2) = INSTAP - INSTAM
      INST(3) = PARMET(30)
      IF (CMD(1:4).EQ.'DYNA') THEN
        INST(4) = ALPHA
        INST(5) = DELTA
      END IF
      
C -- MISE A ZERO LAGRANGIENS POUR CONTACT CONTINU

      IF (CMD(1:4).EQ.'DYNA') THEN
        CALL MISAZL(VITPLU,DEFICO)    
        CALL MISAZL(ACCPLU,DEFICO)
      END IF
      
C -- CALCUL DES CHARGEMENTS EXTERIEURS
      
      CALL NMCHAR ('FIXE', MODELE, NUMEDD, MATE  , CARELE,
     &             K24BLA, LISCHA, K24BLA, INST  , DEPMOI,
     &             DEPDEL, LBID,   VITKM1, ACCKM1, K24BID, 
     &             K24BID, K24BID, K24BID, IBID,   K24BID, 
     &             K24BID, IBID,   LBID,   LONDE,  NONDP,
     &             CHONDP, TEMPLU, 0,      0,      K13BID,
     &             K8BID,  IALGO,  SECOLD, CNFOLD, FOPREC, 
     &             SECMBR)

C -- CALCUL DU CONTACT FROTTEMENT AVEC LA METHODE CONTACT ECP
C -- LES BOUCLES NECESSAIRES SONT TRAITEES PAR
C --      NMICBLE AVANT NEWTON-RAPHSON
C --      NMTBLE  APRES NEWTON-RAPHSON
C -- ET COMMUNIQUENT PAR LA VARIABLE NIVEAU

      IF (FONACT(5)) THEN
        NIVEAU = 4
      ELSE
        NIVEAU = -1
      ENDIF
      
  101 CONTINUE
  
      CALL NMIBLE(NIVEAU, 
     &            PREMIE, MAILLA, DEFICO, OLDGEO, NEWGEO,
     &            DEPMOI, DEPGEO, MAXB,   DEPLAM,
     &            COMGEO, CSEUIL, COBCA, 
     &            NEQ   , DEPDEL, DDEPLA, DEPPLU, LIGRCF,
     &            CARTCF, MODELE, LISCHA, SOLVEU, NUMEDD, 
     &            MCONEL, SCONEL, MATASS, MEMASS, MASSE,
     &            VITPLU, VITMOI, ACCPLU, ACCMOI, VITINI, 
     &            ACCINI, CMD, INST, FONACT(9))


C ======================================================================
C   PHASE DE PREDICTION : INTERPRETEE COMME UNE DIRECTION DE DESCENTE
C ======================================================================

C -- PREDICTION D'UNE DIRECTION DE DESCENTE
      CALL NMPRED(MODELE, NUMEDD, MATE,   CARELE, COMREF,
     &            COMPOR, LISCHA, MEDIRI, METHOD, SOLVEU,
     &            PARMET, CARCRI, PILOTE, PARTPS, NUMINS,
     &            INST  , DEPOLD, VALMOI, POUGD , VALPLU,
     &            SECMBR, DEPPIL, LICCVG, STADYN, RIGID,
     &            MATASS, LAMORT, VITPLU, ACCPLU, MASSE,
     &            AMORT,  CMD,    PREMIE, MEMASS, DEPENT,
     &            VITENT, COEDEP, COEVIT, COEACC, VITKM1,
     &            NMODAM, VALMOD, BASMOD, LIMPED, LONDE,
     &            NONDP,  CHONDP, MODEDE, NUMEDE, SOLVDE,
     &            PARCRI, RESOCO, CONV,   CNRESI, CNDIRI,
     &            MASGEN, BASMOI, LMODAL, DEPDEL, LSSTRU,
     &            ACCGEM, ACCGEP, VITGEM, VITGEP, DEPGEM,
     &            DEPGEP, RIGGEN,  AMOGEN, FONGEN, FORGEN,
     &            IALGO,  SECOLD,  CNFOLD, FOPREC)


      PREMIE = .FALSE.

C ======================================================================
C              ITERATIONS DE LA METHODE DE NEWTON-RAPHSON
C ======================================================================

C -- REPRISE DE LA BOUCLE D'ITERATIONS DE NEWTON-RAPHSON

      ITERAT = 0
 300  CONTINUE
      CALL UTTCPU (2,'DEBUT',4,TPS2)



C -- CALCUL PROPREMENT DIT DE L'INCREMENT DE DEPLACEMENT
C -- EN CORRIGEANT LA (LES) DIRECTIONS DE DESCENTE
C -- SI CONTACT OU PILOTAGE OU RECHERCHE LINEAIRE
C -- DES FORCES INTERIEURES (RHO SI RL, ETA SI PILOTAGE)
C -- DES RIGI_ELEM (SI DEMANDE)

      ETAN = ETA
      CALL NMDEPL(MODELE, NUMEDD, MATE  , CARELE, COMREF,
     &            COMPOR, LISCHA, CNFEXT, PARMET, CARCRI,
     &            MODEDE, NUMEDE, SOLVDE, PARCRI, POUGD ,
     &            ITERAT, VALMOI, RESOCO, VALPLU, CNRESI,
     &            CNDIRI, REAROT, NURO  , METHOD, NUMINS,
     &            OPTION, CONV,   STADYN, DEPENT, VITENT,
     &            LAMORT, MATASS, MEMASS, MASSE,  AMORT,
     &            COEDEP, COEVIT, COEACC, INDRO , SECMBR,
     &            INSTAP, INSTAM, CMD,    ETAN  , PARTPS,
     &            PREMIE, ZFON  , FONACT, RIGID ,
     &            DEPKM1, VITKM1, ACCKM1, VITPLU, ACCPLU,
     &            ROMKM1, ROMK,   PILOTE, DEPDEL, DEPPIL,
     &            DEPOLD, LIGRCF, CARTCF, MCONEL,
     &            SCONEL, MAILLA, DEPPLU, DEFICO, CNCINE,
     &            SOLVEU, LREAC,  ETA   , LICCVG, DDEPLA,
     &            VITMOI, ACCMOI, DEFICU, RESOCU, IALGO ,  
     &            LSSTRU, ACCGEM, ACCGEP, VITGEM, VITGEP,
     &            DEPGEM, DEPGEP)

      IF (LICCVG(1).EQ.1) GOTO 4000

      IF (CMD.EQ.'DYNA_TRAN_EXPLI') THEN
        CONVER = .TRUE.
        GOTO 540
      ENDIF

C -- CALCUL DES FORCES SUIVEUSES
      CALL NMCHAR ('SUIV', MODELE, NUMEDD, MATE  , CARELE,
     &             COMPOR, LISCHA, CARCRI, INST  , DEPMOI,
     &             DEPDEL, LAMORT, VITPLU, ACCPLU, K24BID, 
     &             K24BID, K24BID, K24BID, IBID,   K24BID, 
     &             K24BID, IBID,   LBID,   LBID,   IBID,
     &             K24BID, TEMPLU, 0,      0,      K13BID,
     &             K8BID,  IALGO,  SECOLD, CNFOLD, FOPREC, 
     &             SECMBR)
     
      IF (CMD(1:4).EQ.'DYNA') THEN
        CALL NMCHAR ('INER', MODELE, NUMEDD, MATE  , CARELE,
     &               COMPOR, LISCHA, CARCRI, INST  , DEPMOI,
     &               DEPDEL, LAMORT, VITPLU, ACCPLU, MASSE,
     &               AMORT,  VITPLU, VITENT, NMODAM, VALMOD,
     &               BASMOD, NREAVI, LIMPED, LONDE,  NONDP,
     &               CHONDP, TEMPLU, 0,      0,      K13BID,
     &               K8BID,  IALGO,  SECOLD, CNFOLD, FOPREC, 
     &               SECMBR)
      ENDIF


C -- FORCES D'INERTIE POUR L'ESTIMATION DE LA CONVERGENCE
      CALL NDINER(MASSE,VITPLU,FOINER,CMD,INST,A0VIT)


C -- CALCUL DE LA RESULTANTE DES FORCES EXTERIEURES

      CALL NMFEXT (NUMEDD, ETA , SECMBR,RESOCO,DEFICO,CNFEXT)

C -- SUIVI DE DDL

      CALL SUIDDL(MAILLA,NBMODS,INSTAM,ITERAT,
     &            VITPLU,ACCPLU,VALPLU,DEPDEL,
     &            SECMBR,IMPRCO,SUIVCO,
     &            DEPENT,VITENT,ACCENT,CNSINR)

 4000 CONTINUE
 
C -- ESTIMATION DE LA CONVERGENCE ET SUIVI DU CALCUL (IMPRESSION)
 
      CALL NMCONV (CNRESI, CNDIRI, CNFEXT, CNVCFO, PARCRI,
     &             ITERAT, ETA   , CONV  , LICCVG, ITEMAX,
     &             CONVER, ECHLDC, ECHEQU, ECHCON, ECHPIL,
     &             FINPAS, CRITNL, NUMINS, FOINER, PARTPS,
     &             PARMET, NEQ,    DEPDEL, AUTOC1, AUTOC2,
     &             VECONT, LREAC,  CNVFRE, MAILLA, CNVCF1, 
     &             NUMEDD, DEFICO, RESOCO, MATASS, IMPRCO,
     &             ZFON,   FONACT, MAXREL)



C -- AVEC ARRET='NON' ON FORCE LE PASSAGE 
      IF (ITEMAX.AND.(NINT(PARCRI(4)).EQ.1)) THEN
        CALL UTMESS('A',NOMPRO,'ATTENTION, ARRET=NON DONC POURSUITE'
     &                // ' DU CALCUL SANS AVOIR EU CONVERGENCE')
        CONVER = .TRUE.
      END IF
C -- ON A CONVERGE ON FINIT LE PAS DE TEMPS 
540   CONTINUE
      IF ( CONVER ) THEN
        CALL UTTCPU (2,'FIN',4,TPS2)
        GOTO 550
      ENDIF

C -- CA NE SE PASSE PAS BIEN... -> ON VA TENTER DE REDECOUPER
C -- 1 - LE NOMBRE D'ITERATIONS MAXIMAL EST ATTEINT 
C -- 2 - SI LA MATRICE EST SINGULIERE 
C -- 3 - S'IL Y A ECHEC DANS L'INTEGRATION DE LA LOI DE COMPORTEMENT 
C -- 4 - S'IL Y A ECHEC DANS LE TRAITEMENT DU CONTACT 
C -- 5 - S'IL Y A ECHEC DANS LE PILOTAGE
            
      IF ( ITEMAX    .OR.
     &     ECHPIL    .OR.
     &     ECHEQU    .OR.
     &     ECHLDC    .OR.
     &     ECHCON(1) .OR. ECHCON(2) )  GOTO 500

C -- SINON ON CONTINUE LES ITERATIONS DE NEWTON : CALCUL DE LA DESCENTE
      CALL NMDESC(MODELE, NUMEDD, MATE  , CARELE, COMREF,
     &            COMPOR, LISCHA, MEDIRI, RESOCO, METHOD,
     &            SOLVEU, PARMET, CARCRI, PILOTE, PARTPS,
     &            NUMINS, ITERAT, VALMOI, POUGD , DEPDEL,
     &            VALPLU, SECMBR, CNRESI, DEPPIL ,ETA   ,
     &            LICCVG, DEFICO, STADYN, PREMIE, CMD,
     &            DEPENT, VITENT, LAMORT, MEMASS, MASSE,
     &            RIGID,  MATASS, AMORT,  COEDEP, COEVIT, COEACC)

C -- TEMPS DISPONIBLE POUR FAIRE UNE NOUVELLE ITERATION DE NEWTON ?

      CALL UTTCPU (2,'FIN',4,TPS2)
      ITERAT = ITERAT + 1
      IF (2.D0*TPS2(4).LE.0.95D0*TPS2(1)-TPS3(4)) THEN
        GOTO 300
      ELSE
        MTCPUI=.TRUE.
        GOTO 1000
      ENDIF

C ======================================================================
C                      FIN DES ITERATIONS DE NEWTON
C ======================================================================

C -- EN L'ABSENCE DE CONVERGENCE ON CHERCHE A SUBDIVISER LE PAS DE TEMPS

 500  CONTINUE

      CALL UTTCPU (2,'FIN',4,TPS2)

      CALL DIDECO(PARTPS, NUMINS, IRET)
      IF (IRET.EQ.0)  THEN
        CALL UTTCPU (1,'FIN',4,TPS1)
        FINTPS = TPS1(4) .GT. 0.90D0*TPS1(1)
        GOTO 600
      ELSE
        GOTO 1000
      ENDIF


C ======================================================================
C  FIN DU PAS DE TEMPS
C ======================================================================

 550  CONTINUE

C --- VERIFICATION DE LA CONVERGENCE
C --- METHODE CONTACT CONTINUE
      CALL NMTBLE(NIVEAU, 
     &            MAILLA, DEFICO, OLDGEO, NEWGEO,
     &            DEPMOI, DEPGEO, MAXB,   DEPLAM,
     &            COMGEO, CSEUIL, COBCA,  FONACT(9),
     &            DEPPLU, INST,   DECOL,  MODELE,
     &            MAXREL, IMPRCO)

C --- RETOUR POUR BOUCLE NMIBLE/NMTBLE      
      IF (NIVEAU.GT.0) THEN 
        GOTO 101
      ENDIF
      
      
C -- TEMPS DISPONIBLE
      CALL UTTCPU (1,'FIN',4,TPS1)
      FINTPS = TPS1(4) .GT. 0.90D0*TPS1(1)

C -- IMPRESSION TEMPS
      VALR(1) = TPS1(3)-TPS1M

      CALL CFDISC(DEFICO,'              ',TYPALC,IBID,IBID,IBID)
      IF (FONACT(4).AND.(TYPALC.NE.5)) THEN
        CALL CFITER(RESOCO,'L','TIMA',IBID,VALR(3))
        CALL CFITER(RESOCO,'L','TIMG',IBID,VALR(2)) 
        CALL NMIMPR('    ','TPS_PAS',' ',VALR,1)
      ELSE
        CALL NMIMPR('    ','TPS_PAS',' ',VALR,0)
      ENDIF
         

C -- ECRITURE DES NOEUDS EN CONTACT SI ON A CONVERGE
      
      IF (FONACT(5).AND. .NOT.FONACT(9)) THEN
        CALL MMMRES (DEFICO,DEPDEL,NUMEDD,MAILLA,CNSINR)
      ENDIF
      IF (FONACT(4).AND. .NOT.ECHCON(1) .AND. .NOT.ECHCON(2)) THEN
        CALL CFRESU(NUMINS,INSTAP,MATASS,DEFICO,RESOCO,DEPDEL,
     &              DDEPLA,MAILLA,CNSINR)
      ENDIF
      
C -- OBSERVATION EVENTUELLE

      IF ( LOBSER ) THEN   
         CALL DYOBAR ( MAILL2, NOMTAB,
     &                 NBMODS, NBOBAR, NUOBSE, INSTAP,
     &                 VITPLU, ACCPLU, VALPLU,
     &                 DEPENT, VITENT, ACCENT, CNSINR)
      ENDIF      

C -- ARCHIVAGE DES RESULTATS

      FINPAS = FINPAS .OR. DIDERN(PARTPS, NUMINS)
      
      CALL UTTCPU (3,'DEBUT',4,TPS3)
      LOGIC = NBPASE.EQ.0
      CALL NMARCH (RESULT, NUMINS, PARTPS, FINTPS.OR.FINPAS, COMPOR,
     &             CRITNL, VALPLU, CNSINR, CMD ,VITPLU, ACCPLU,
     &             NBMODS, DEPENT, VITENT, ACCENT, LOGIC,
     &             MODELE, MATE,   CARELE, LISCH2 )

      IF (LSSTRU) THEN
        CALL JEVEUO(PARTPS // '.DIAL','L',JARCH)
        IF (.NOT.ZL(JARCH+NUMINS)) GOTO 700 
        NUMA = NUMA + 1
        CALL JELIRA(DEPGEP,'LONMAX',NBMODE,K8BID)
        CALL JEVEUO(DEPGEP,'L',JDEPGP)        
        CALL JEVEUO(VITGEP,'L',JVITGP)
        CALL JEVEUO(ACCGEP,'L',JACCGP)
        CALL DCOPY(NBMODE,ZR(JDEPGP),1,ZR(JRESTD+(NUMA-1)*NBMODE),1)
        CALL DCOPY(NBMODE,ZR(JVITGP),1,ZR(JRESTV+(NUMA-1)*NBMODE),1)
        CALL DCOPY(NBMODE,ZR(JACCGP),1,ZR(JRESTA+(NUMA-1)*NBMODE),1)
 700    CONTINUE
      ENDIF

      CALL UTTCPU (3,'FIN',4,TPS3)

C -- CALCUL DE SENSIBILITE

      IF (NBPASE.GT.0) THEN
        MATRIX(1)=MATASS
        CALL NMSENS (MODELE,NEQ,NUMEDD,MATE,COMPOR,CARELE,LISCHA,
     &                    COEVIT,COEACC,LAMORT,MASSE,AMORT,NMODAM ,
     &                    VALMOD,BASMOD,LIMPED,NBMODS,
     &                    CMD,SOLVEU,MATRIX,PARTPS,INST,
     &                    NUMINS,SECMBR,NBPASE,INPSCO)
      ENDIF
      
C -- CALCUL DE FLAMBEMENT EN STATIQUE ET DYNAMIQUE

      IF (CMD(1:13).EQ.'STAT_NON_LINE') THEN
        CALL GETFAC('CRIT_FLAMB',IFLAMB)
        IF (IFLAMB.GT.0) CALL NMFLAM(MODELE,NUMEDD,CARELE,COMPOR,SOLVEU,
     &             NUMINS,VALPLU,RESULT,MATE,COMREF,
     &             LISCHA,MEDIRI,RESOCO,METHOD,PARMET,CARCRI,
     &             ITERAT,POUGD,DEPDEL,PARTPS,
     &             DEFICO,STADYN,PREMIE,CMD,DEPENT,VITENT,LAMORT,
     &             RIGID,MATASS,MEMASS,MASSE,AMORT,COEVIT,COEACC,LICCVG,
     &             'FLAMBSTA')
      ELSE IF (CMD(1:13).EQ.'DYNA_NON_LINE') THEN
        CALL GETFAC('CRIT_FLAMB',IFLAMB)
        IF (IFLAMB.GT.0) CALL NMFLAM(MODELE,NUMEDD,CARELE,COMPOR,SOLVEU,
     &             NUMINS,VALPLU,RESULT,MATE,COMREF,
     &             LISCHA,MEDIRI,RESOCO,METHOD,PARMET,CARCRI,
     &             ITERAT,POUGD,DEPDEL,PARTPS,
     &             DEFICO,STADYN,PREMIE,CMD,DEPENT,VITENT,LAMORT,
     &             RIGID,MATASS,MEMASS,MASSE,AMORT,COEVIT,COEACC,LICCVG,
     &             'FLAMBDYN')
      ENDIF

C -- CALCUL DE MODES VIBRATOIRES EN DYNAMIQUE

      IF (CMD(1:13).EQ.'DYNA_NON_LINE') THEN
        CALL GETFAC('MODE_VIBR',IFLAMB)
        IF (IFLAMB.GT.0) THEN
          CALL NMFLAM(MODELE,NUMEDD,CARELE,COMPOR,SOLVEU,NUMINS,
     &             VALPLU,RESULT,MATE,COMREF,
     &             LISCHA,MEDIRI,RESOCO,METHOD,PARMET,CARCRI,
     &             ITERAT,POUGD,DEPDEL,PARTPS,
     &             DEFICO,STADYN,PREMIE,CMD,DEPENT,VITENT,LAMORT,
     &             RIGID,MATASS,MEMASS,MASSE,AMORT,COEVIT,COEACC,LICCVG,
     &             'VIBRDYNA')
        ENDIF
      ENDIF

C -- DERNIER INSTANT DE CALCUL ? -> ON SORT DE STAT_NON_LINE

      IF (FINPAS) GOTO 900

C -- SINON : REACTUALISATION

C    POUR UNE PREDICTION PAR EXTRAPOLATION DES INCREMENTS DU PAS D'AVANT
      CALL COPISD('CHAMP_GD','V',DEPDEL,DEPOLD)

C    ETAT AU DEBUT DU NOUVEAU PAS DE TEMPS

      CALL COPISD('CHAMP_GD','V',DEPPLU,DEPMOI)
      CALL COPISD('CHAMP_GD','V',SIGPLU,SIGMOI)
      CALL COPISD('CHAMP_GD','V',VARPLU,VARMOI)
      CALL COPISD('VARI_COM','V',COMPLU,COMMOI)
      IF (MODEDE.NE.' ') CALL COPISD('CHAMP_GD','V',VARDEP,VARDEM)
      IF (MODEDE.NE.' ') CALL COPISD('CHAMP_GD','V',LAGDEP,LAGDEM)
      
      IF (CMD(1:4).EQ.'DYNA') THEN
       CALL COPISD('CHAMP_GD','V',VITPLU,VITMOI)
       CALL COPISD('CHAMP_GD','V',ACCPLU,ACCMOI)
       IF (NBMODS.NE.0) THEN
        CALL COPISD('CHAMP_GD','V',DEPENT,DEPENM)
        CALL COPISD('CHAMP_GD','V',ACCENT,ACCENM)
        CALL COPISD('CHAMP_GD','V',VITENT,VITENM)
       ENDIF
      ENDIF            
      INSTAM = INSTAP
      NUMINS = NUMINS + 1

C -- TEMPS DISPONIBLE POUR FAIRE UN NOUVEAU PAS DE TEMPS ?

 600  CONTINUE

      IF (FINTPS) THEN
        MTCPUP = .TRUE.
        GOTO 1000
      END IF

C -- SAUVEGARDE DU SECOND MEMBRE POUR ALPHA-METHODE
      
      IF ( IALGO .EQ. 4 ) THEN
        CALL NMCHSV(CNRESI, SECMBR, CNFOLD, SECOLD )
        FOPREC = .TRUE.
      ENDIF

      GOTO 200

C ======================================================================
C                   GESTION DES ERREURS
C
C ======================================================================

1000  CONTINUE

C -- ON COMMENCE PAR ARCHIVER LE PAS DE TEMPS PRECEDENT
      IF (NUMINS.NE.1) THEN
       CALL JEVEUO(PARTPS // '.DIAL','L',JARCH)
       IF (.NOT.ZL(JARCH+NUMINS-1)) THEN
         CALL NMARCH (RESULT, NUMINS-1, PARTPS, .TRUE., COMPOR,
     &               CRITNL, VALMOI, CNSINR, CMD ,VITMOI, ACCMOI,
     &               NBMODS,DEPENM,VITENM,ACCENM,.TRUE.,
     &               MODELE, MATE, CARELE, LISCH2 )
       ENDIF
      ENDIF
      CALL COPISD(' ','G',LISCHA,LISCH2)

      IF (MTCPUI) THEN
        CALL UTDEXC (28,NOMPRO,'ARRET PAR MANQUE DE TEMPS CPU')
        CALL UTIMPI ('S',' AU NUMERO D''INSTANT : ',1,NUMINS)
        CALL UTIMPI ('S',' LORS DE L''ITERATION : ',1,ITERAT)
        CALL UTIMPR ('L',' TEMPS MOYEN PAR ITERATION : ',1,TPS2(4))
        CALL UTIMPR ('L',' TEMPS CPU RESTANT: ',1,TPS2(1))
        CALL UTIMPI ('L',' LA BASE GLOBALE EST SAUVEGARDEE,' ,0,NUMINS)
        CALL UTIMPI ('S',' ELLE CONTIENT LES PAS ARCHIVES' ,0,NUMINS)
        CALL UTIMPI ('S',' AVANT L''ARRET' ,0,NUMINS)
        CALL UTFINM ()

      ELSE IF (MTCPUP) THEN
        CALL UTDEXC (28,NOMPRO,'ARRET PAR MANQUE DE TEMPS CPU')
        CALL UTIMPI ('S',' AU NUMERO D''INSTANT : ',1,NUMINS)
        CALL UTIMPR ('L',' TEMPS MOYEN PAR INCREMENT DE CHARGE : ',1,
     &               TPS1(4))
        CALL UTIMPR ('L',' TEMPS CPU RESTANT : ',1,TPS1(1))
        CALL UTIMPI ('L',' LA BASE GLOBALE EST SAUVEGARDEE,' ,0,NUMINS)
        CALL UTIMPI ('S',' ELLE CONTIENT LES PAS ARCHIVES' ,0,NUMINS)
        CALL UTIMPI ('S',' AVANT L''ARRET' ,0,NUMINS)
        CALL UTFINM ()

      ELSE IF (ECHLDC) THEN
        CALL UTEXCP(23,NOMPRO,'ARRET PAR ECHEC DE '
     &  // 'L''INTEGRATION DE LA LOI DE COMPORTEMENT')

      ELSE IF (ECHEQU) THEN 
        CALL UTEXCP(25,NOMPRO,'ARRET POUR CAUSE DE '
     &  // 'MATRICE NON INVERSIBLE')

      ELSE IF (ECHCON(1)) THEN 
        CALL UTEXCP(26,NOMPRO,'ARRET PAR ECHEC DE '
     &  // 'TRAITEMENT DU CONTACT')

      ELSE IF (ECHCON(2)) THEN
        CALL UTEXCP(27,NOMPRO,'ARRET SUR MATRICE DE '
     &  // 'CONTACT SINGULIERE')

      ELSE IF (ITEMAX) THEN
         CALL UTEXCP(22,NOMPRO,'ARRET : ABSENCE DE CONVERGENCE '
     &          //'AVEC LE NOMBRE D''ITERATIONS REQUIS')
     
      ELSE
        CALL UTMESS('F',NOMPRO,'ERREUR DANS LA GESTION DES ERREURS')

      ENDIF



C ======================================================================
C                   FIN DE LA BOUCLE SUR LES PAS DE TEMPS
C ======================================================================

 900  CONTINUE
C
C --- COPIE DE LA SD INFO_CHARGE DANS LA BASE GLOBALE
C
      CALL COPISD(' ','G',LISCHA,LISCH2)
C
C --- MENAGE FINAL 
C
      CALL DETMAT()
C           
C --- SI FETI, NETTOYAGE DES OBJETS TEMPORAIRES
C --- NETTOYAGE DES SD FETI SI NECESSAIRE (SUCCESSION DE CALCULS 
C --- DECOUPLES)
C --- ET INITIALISATION NUMERO D'INCREMENT
C
      IF (FONACT(11)) THEN
        OPT='NETTOYAGE_SDT'     
        CALL ALFETI(OPT,K19BID,K19BID,K19BID,K19BID,IBID,R8BID,K24BID,
     &              R8BID,IBID,K24BID,K24BID,K24BID,K24BID,IBID,
     &              K24BID,K24BID)
      ENDIF
      
      CALL JEDEMA()
      
      END
