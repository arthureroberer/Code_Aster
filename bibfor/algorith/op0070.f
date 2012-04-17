      SUBROUTINE OP0070()
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/04/2012   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
C TOLE CRP_20
C
      IMPLICIT NONE
C
C ----------------------------------------------------------------------
C
C COMMANDE:  STAT_NON_LINE ET DYNA_NON_LINE
C
C ----------------------------------------------------------------------
C
C
C --- PARAMETRES DE MECA_NON_LINE
C
      INTEGER      ZPMET ,ZPCRI ,ZCONV
      INTEGER      ZPCON ,ZNMETH
      PARAMETER   (ZPMET  = 30,ZPCRI  = 12,ZCONV = 21)
      PARAMETER   (ZPCON  = 10,ZNMETH = 7 )
      REAL*8       PARMET(ZPMET),PARCRI(ZPCRI),CONV(ZCONV)
      REAL*8       PARCON(ZPCON)
      CHARACTER*16 METHOD(ZNMETH)
      INTEGER      FONACT(100)
      INTEGER      ZMEELM,ZMEASS,ZVEELM,ZVEASS
      PARAMETER    (ZMEELM=9 ,ZMEASS=4 ,ZVEELM=22,ZVEASS=33)
      INTEGER      ZSOLAL,ZVALIN
      PARAMETER    (ZSOLAL=17,ZVALIN=28)
C
C --- GESTION BOUCLES
C
      INTEGER      NUMINS,NBITER
      CHARACTER*4  ETINST,ETCALC
C
C --- GESTION ERREUR
C
      INTEGER      LENOUT
      CHARACTER*16 COMPEX
C
      INTEGER      IBID
C
      REAL*8       ETA
C
      CHARACTER*8  RESULT,MAILLA
C
      CHARACTER*16 K16BID
      CHARACTER*19 LISCHA,LISCH2
      CHARACTER*19 SOLVEU,MAPREC,MATASS
      CHARACTER*24 MODELE,MATE  ,CARELE,COMPOR
      CHARACTER*24 NUMEDD,NUMFIX
      CHARACTER*24 CARCRI,COMREF,CODERE
C
C --- FONCTIONNALITES ACTIVEES
C
      LOGICAL      NDYNLO,LEXPL,LIMPL,LSTAT
C
C --- STRUCTURES DE DONNEES
C
      CHARACTER*24 SDIMPR,SDSENS,SDTIME,SDERRO,SDIETO
      CHARACTER*24 SDSTAT,SDCONV
      CHARACTER*19 SDPILO,SDNUME,SDDYNA,SDDISC,SDCRIT
      CHARACTER*19 SDSUIV,SDOBSE,SDPOST,SDENER
      CHARACTER*24 DEFICO,RESOCO,DEFICU,RESOCU
C
C --- VARIABLES CHAPEAUX
C
      CHARACTER*19 VALINC(ZVALIN),SOLALG(ZSOLAL)
C
C --- MATR_ELEM, VECT_ELEM ET MATR_ASSE
C
      CHARACTER*19 MEELEM(ZMEELM),VEELEM(ZVEELM)
      CHARACTER*19 MEASSE(ZMEASS),VEASSE(ZVEASS)
C
C ----------------------------------------------------------------------
C
      DATA SDPILO, SDOBSE    /'&&OP0070.PILO.','&&OP0070.OBSE.'/
      DATA SDIMPR, SDSUIV    /'&&OP0070.IMPR.','&&OP0070.SUIV.'/
      DATA SDSENS, SDPOST    /'&&OP0070.SENS.','&&OP0070.POST.'/
      DATA SDTIME, SDERRO    /'&&OP0070.TIME.','&&OP0070.ERRE.'/
      DATA SDIETO, SDSTAT    /'&&OP0070.IETO.','&&OP0070.STAT.'/
      DATA SDNUME            /'&&OP0070.NUME.ROTAT'/
      DATA SDDISC, SDCONV    /'&&OP0070.DISC.','&&OP0070.CONV.'/
      DATA SDCRIT            /'&&OP0070.CRIT.'/
      DATA LISCHA            /'&&OP0070.LISCHA'/
      DATA CARCRI            /'&&OP0070.PARA_LDC'/
      DATA SOLVEU            /'&&OP0070.SOLVEUR'/
      DATA DEFICO, RESOCO    /'&&OP0070.DEFIC','&&OP0070.RESOC'/
      DATA DEFICU, RESOCU    /'&&OP0070.DEFUC', '&&OP0070.RESUC'/
      DATA COMREF            /'&&OP0070.COREF'/
      DATA MAPREC            /'&&OP0070.MAPREC'/
      DATA CODERE            /'&&OP0070.CODERE'/
      DATA SDENER            /'&&OP0070.SDENER'/
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C -- TITRE
C
      CALL TITRE ()
      CALL INFMAJ()
      CALL INIDBG()
C
C ======================================================================
C     RECUPERATION DES OPERANDES ET INITIALISATION
C ======================================================================
C
C --- ON STOCKE LE COMPORTEMENT EN CAS D'ERREUR AVANT MNL : COMPEX
C --- PUIS ON PASSE DANS LE MODE "VALIDATION DU CONCEPT EN CAS D'ERREUR"
C
      CALL ONERRF(' ',COMPEX,LENOUT)
      CALL ONERRF('EXCEPTION+VALID',K16BID,IBID  )
C
C --- NOM DE LA SD RESULTAT
C
      CALL GETRES(RESULT,K16BID,K16BID)
C
C --- PREMIERES INITALISATIONS
C
      CALL NMINI0(ZPMET ,ZPCRI ,ZCONV ,ZPCON ,ZNMETH,
     &            FONACT,PARMET,PARCRI,CONV  ,PARCON,
     &            METHOD,ETA   ,NUMINS,MATASS,ZMEELM,
     &            ZMEASS,ZVEELM,ZVEASS,ZSOLAL,ZVALIN)
C
C --- LECTURE DES OPERANDES DE LA COMMANDE
C
      CALL NMDATA(RESULT,MODELE,MATE  ,CARELE,COMPOR,
     &            LISCHA,SOLVEU,METHOD,PARMET,PARCRI,
     &            PARCON,CARCRI,SDDYNA,SDSENS,SDPOST,
     &            SDERRO,SDENER)
C
C --- ETAT INITIAL ET CREATION DES STRUCTURES DE DONNEES
C
      CALL NMINIT(RESULT,MODELE,NUMEDD,NUMFIX,MATE  ,
     &            COMPOR,CARELE,PARMET,LISCHA,MAPREC,
     &            SOLVEU,CARCRI,NUMINS,SDSTAT,SDDISC,
     &            SDNUME,DEFICO,SDCRIT,COMREF,FONACT,
     &            PARCON,PARCRI,METHOD,LISCH2,MAILLA,
     &            SDPILO,SDDYNA,SDIMPR,SDSUIV,SDSENS,
     &            SDOBSE,SDTIME,SDERRO,SDPOST,SDIETO,
     &            SDENER,SDCONV,DEFICU,RESOCU,RESOCO,
     &            VALINC,SOLALG,MEASSE,VEELEM,MEELEM,
     &            VEASSE,CODERE)
C
C --- PREMIER INSTANT
C
      NUMINS = 1
C
C --- QUELQUES FONCTIONNALITES ACTIVEES
C
      LIMPL  = NDYNLO(SDDYNA,'IMPLICITE')
      LEXPL  = NDYNLO(SDDYNA,'EXPLICITE')
      LSTAT  = NDYNLO(SDDYNA,'STATIQUE' )
C
C ======================================================================
C  DEBUT DU PAS DE TEMPS
C ======================================================================
C
 200  CONTINUE
C
C --- AUCUNE BOUCLE N'EST CONVERGE
C
      CALL NMECEB(SDERRO,'RESI','CONT')
      CALL NMECEB(SDERRO,'NEWT','CONT')
      CALL NMECEB(SDERRO,'FIXE','CONT')
      CALL NMECEB(SDERRO,'INST','CONT')
C
      CALL JERECU('V')
      CALL NMTIME(SDTIME,'RUN','PAS')
C
C --- REALISATION DU PAS DE TEMPS
C
      IF (LEXPL) THEN
        CALL NDEXPL(MODELE,NUMEDD,NUMFIX,MATE  ,CARELE,
     &              COMREF,COMPOR,LISCHA,METHOD,FONACT,
     &              CARCRI,PARCON,SDIMPR,SDSTAT,SDNUME,
     &              SDDYNA,SDDISC,SDTIME,SDSENS,SDERRO,
     &              VALINC,NUMINS,SOLALG,SOLVEU,MATASS,
     &              MAPREC,MEELEM,MEASSE,VEELEM,VEASSE,
     &              NBITER)
      ELSEIF (LSTAT.OR.LIMPL) THEN
        CALL NMNEWT(MAILLA,MODELE,NUMINS,NUMEDD,NUMFIX,
     &              MATE  ,CARELE,COMREF,COMPOR,LISCHA,
     &              METHOD,FONACT,CARCRI,PARCON,CONV  ,
     &              PARMET,PARCRI,SDSTAT,SDSENS,SDIETO,
     &              SDTIME,SDERRO,SDIMPR,SDNUME,SDDYNA,
     &              SDDISC,SDCRIT,SDSUIV,SDPILO,SDCONV,
     &              SOLVEU,MAPREC,MATASS,VALINC,SOLALG,
     &              MEELEM,MEASSE,VEELEM,VEASSE,DEFICO,
     &              RESOCO,DEFICU,RESOCU,ETA   ,NBITER)
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
C
C --- TEMPS CPU PAS DE TEMPS
C
      CALL NMTIME(SDTIME,'END','PAS')
      CALL NMRINC(SDSTAT,'PAS')
C
C ======================================================================
C  FIN DU PAS DE TEMPS
C ======================================================================
C
C
C --- TEMPS PERDU SI DECOUPE
C
      CALL NMLEEB(SDERRO,'INST',ETINST)
      IF (ETINST.EQ.'ERRE') THEN
        CALL NMLOST(SDTIME)
      ENDIF
C
C --- POST-TRAITEMENTS
C
      CALL NMPOST(MODELE,MAILLA,NUMEDD,NUMFIX,CARELE,
     &            COMPOR,SOLVEU,MAPREC,MATASS,NUMINS,
     &            MATE  ,COMREF,LISCHA,DEFICO,RESOCO,
     &            RESOCU,PARMET,PARCON,FONACT,CARCRI,
     &            SDIMPR,SDSTAT,SDDISC,SDTIME,SDOBSE,
     &            SDERRO,SDSENS,SDIETO,SDDYNA,SDPOST,
     &            VALINC,SOLALG,MEELEM,MEASSE,VEELEM,
     &            VEASSE,SDENER,ETA   )
C
C --- ETAT DE LA CONVERGENCE DU PAS DE TEMPS
C
      CALL NMCVGP(SDDISC,NUMINS,SDERRO,VALINC,FONACT,
     &            DEFICO,RESOCO)
C
C --- AFFICHAGES PENDANT LA BOUCLE DES PAS DE TEMPS
C
      CALL NMAFFI(FONACT,IBID  ,SDCONV,SDIMPR,SDERRO,
     &            'INST')
C
C --- STATISTIQUES SUR PAS DE TEMPS
C
      IF (.NOT.LEXPL) THEN
        CALL NMSTAT('P'   ,FONACT,SDSTAT,SDTIME,DEFICO)
      ENDIF
C
C --- GESTION DES ACTIONS A LA FIN D'UN PAS DE TEMPS
C
      CALL NMACTP(SDIMPR,SDDISC,SDERRO,DEFICO,RESOCO,
     &            PARCRI,NBITER,NUMINS)
C
C --- INSTANT SUIVANT
C
      CALL NMLEEB(SDERRO,'INST',ETINST)
      IF (ETINST.EQ.'ERRE') THEN
        GOTO 200
      ELSEIF (ETINST.EQ.'STOP') THEN
        GOTO 1000
      ENDIF
C
C --- VERIFICATION DU DECLENCHEMENT DES ERREURS FATALES
C
      CALL NMEVDT(SDTIME,SDERRO,'PAS')
C
C --- EVALUATION DE LA CONVERGENCE DU CALCUL
C
      CALL NMCVGC(SDDISC,SDERRO,NUMINS,FONACT)
C
C --- ARCHIVAGE DES RESULTATS
C
      CALL ONERRF(COMPEX,K16BID,IBID  )
      CALL NMARCH(NUMINS,MODELE,MATE  ,CARELE,FONACT,
     &            CARCRI,SDIMPR,SDDISC,SDPOST,SDCRIT,
     &            SDTIME,SDERRO,SDSENS,SDDYNA,SDPILO,
     &            SDENER,SDIETO,LISCH2)
      CALL ONERRF('EXCEPTION+VALID',K16BID,IBID  )
C
C --- ETAT DU CALCUL
C
      CALL NMLEEB(SDERRO,'CALC',ETCALC)
      IF ((ETCALC.EQ.'ERRE').OR.(ETCALC.EQ.'STOP')) THEN
        GOTO 1000
      ELSEIF (ETCALC.EQ.'CONV') THEN
        GOTO 900
      ENDIF
C
C --- MISE A JOUR DES INFORMATIONS POUR UN NOUVEAU PAS DE TEMPS
C
      CALL ASSERT(ETCALC.EQ.'CONT')
      CALL NMFPAS(FONACT,SDDYNA,SDPILO,SDDISC,NBITER,
     &            NUMINS,ETA   ,VALINC,SOLALG,VEASSE)
      NUMINS = NUMINS + 1
C
      GOTO 200

C ======================================================================
C     GESTION DES ERREURS
C ======================================================================

1000  CONTINUE
C
C --- ON COMMENCE PAR ARCHIVER LE PAS DE TEMPS PRECEDENT
C
      IF (NUMINS.NE.1) THEN
        CALL NMARCH(NUMINS-1,MODELE,MATE,CARELE,FONACT,
     &              CARCRI,SDIMPR,SDDISC,SDPOST,SDCRIT,
     &              SDTIME,SDERRO,SDSENS,SDDYNA,SDPILO,
     &              SDENER,SDIETO,LISCH2)
      ENDIF
C
C --- GESTION DES ERREURS ET EXCEPTIONS
C
      CALL NMERRO(SDERRO,SDTIME,NUMINS)

C ======================================================================
C     SORTIE
C ======================================================================

 900  CONTINUE
C
C --- IMPRESSION STATISTIQUES FINALES
C
      IF (.NOT.LEXPL) THEN
        CALL NMSTAT('T'   ,FONACT,SDSTAT,SDTIME,DEFICO)
      ENDIF
C
C --- ON REMET LE MECANISME D'EXCEPTION A SA VALEUR INITIALE
C
      CALL ONERRF(COMPEX,K16BID,IBID  )
C
C --- MENAGE
C
      CALL NMMENG(FONACT)
C
      CALL JEDEMA()

      END
