      SUBROUTINE RSCRSD(BASE,NOMSD,TYPESD,NBORDR)
      IMPLICIT NONE
      CHARACTER*(*) BASE,NOMSD,TYPESD
      INTEGER NBORDR
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 07/10/2008   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE VABHHTS J.PELLET
C TOLE CRP_20
C ----------------------------------------------------------------------
C      CREATION D'UNE STRUCTURE DE DONNEES "RESULTAT-COMPOSE".
C      (SI CETTE STRUCTURE EXISTE DEJA, ON LA DETRUIT).
C     ------------------------------------------------------------------
C IN  NOMSD  : NOM DE LA STRUCTURE "RESULTAT" A CREER.
C IN  TYPESD : TYPE DE LA STRUCTURE "RESULTAT" A CREER.
C IN  NBORDR : NOMBRE MAX DE NUM. D'ORDRE.
C ----------------------------------------------------------------------
      INTEGER I,K,IBID,IRET,NBNOVA
      INTEGER NAEVEL,NAEVNO,NAEVTH,NAFLAM,NAMOME,NBCHAM,NCACOU
      INTEGER NCMEC1,NCMEC2,NCMEC3,NCMECA,NCTHER,NCTHET,NCVARC,NPACHA
      INTEGER NPDYHA,NPDYTR,NPEVEL,NPEVNO,NPEVTH,NPFLAM,NPMOME,NPMUEL
      INTEGER NPVARC,JORDR
      CHARACTER*1 KBID,BAS1
      CHARACTER*16 TYPES2
      CHARACTER*19 NOMS2
      CHARACTER*32 JEXNOM,JEXNUM
C     ------------------------------------------------------------------
C                      C H A M P _ M E C A N I Q U E
C     ------------------------------------------------------------------
      PARAMETER (NCMEC1=49)
      PARAMETER (NCMEC2=54)
      PARAMETER (NCMEC3=35)
      PARAMETER (NCMECA=NCMEC1+NCMEC2+NCMEC3)
      CHARACTER*16 CHMEC1(NCMEC1)
      CHARACTER*16 CHMEC2(NCMEC2)
      CHARACTER*16 CHMEC3(NCMEC3)
      CHARACTER*16 CHMECA(NCMECA)
C     ------------------------------------------------------------------
C                      C H A M P _ T H E R M I Q U E
C     ------------------------------------------------------------------
      PARAMETER (NCTHER=19)
      CHARACTER*16 CHTHER(NCTHER)
C     ------------------------------------------------------------------
C                      C H A M P _ V A R C
C     ------------------------------------------------------------------
      PARAMETER (NCVARC=6)
      CHARACTER*16 CHVARC(NCVARC)
C     ------------------------------------------------------------------
C                      C H A M P _ A C O U S T I Q U E
C     ------------------------------------------------------------------
      PARAMETER (NCACOU=11)
      CHARACTER*16 CHACOU(NCACOU)
C     ------------------------------------------------------------------
C                      C H A M P _ T H E T A
C     ------------------------------------------------------------------
      PARAMETER (NCTHET=2)
      CHARACTER*16 CHTHET(NCTHET)
C     ------------------------------------------------------------------
C     ------------------------------------------------------------------
C                      C H A M P _ M E C A N I Q U E
C     ------------------------------------------------------------------
C      '1234567890123456','1234567890123456','1234567890123456',
      DATA CHMEC1/
     & 'DEPL',            'VITE',            'ACCE','DEPL_ABSOLU',
     & 'VITE_ABSOLU',     'ACCE_ABSOLU',     'EFGE_ELNO_DEPL',
     & 'EFGE_NOEU_DEPL',  'EFGE_ELNO_CART',  'EFGE_NOEU_CART',
     & 'EPSI_ELGA_DEPL',  'EPSI_ELNO_DEPL',  'EPSI_NOEU_DEPL',
     & 'EPSI_ELNO_TUYO',  'SIEF_ELGA',       'SIEF_ELGA_DEPL',
     & 'SIEF_ELNO_ELGA',  'SIEF_NOEU_ELGA',  'SIEF_ELNO',
     & 'SIEF_NOEU',       'SIGM_ELNO_DEPL',  'SIGM_NOEU_DEPL',
     & 'EPEQ_ELNO_TUYO',  'SIEQ_ELNO_TUYO',  'SIGM_ELNO_CART',
     & 'SIGM_NOEU_CART',  'SIGM_NOZ1_ELGA',  'SIGM_NOZ2_ELGA',
     & 'SIRE_ELNO_DEPL',  'SIRE_NOEU_DEPL',  'SIPO_ELNO_DEPL',
     & 'SIPO_NOEU_DEPL',  'EQUI_ELGA_SIGM',  'EQUI_ELNO_SIGM',
     & 'EQUI_NOEU_SIGM',  'EQUI_ELGA_EPSI',  'EQUI_ELNO_EPSI',
     & 'EQUI_NOEU_EPSI',  'SIGM_ELNO_ZAC',   'EPSP_ELNO_ZAC',
     & 'VARI_ELGA_ZAC',   'SIGM_NOEU_ZAC',   'EPSP_NOEU_ZAC',
     & 'ALPH0_ELGA_EPSP', 'ALPHP_ELGA_ALPH0','VARI_NON_LOCAL',
     & 'LANL_ELGA',       'ARCO_ELNO_SIGM',  'ARCO_NOEU_SIGM'/
C
C      '1234567890123456','1234567890123456','1234567890123456',
      DATA CHMEC2/
     & 'DEGE_ELNO_DEPL',  'DEGE_NOEU_DEPL',  'EPOT_ELEM_DEPL',
     & 'ECIN_ELEM_DEPL',  'FORC_NODA',       'REAC_NODA',
     & 'ERRE_ELEM_SIGM',  'ERRE_ELNO_ELEM',  'ERRE_NOEU_ELEM',
     & 'ERZ1_ELEM_SIGM',  'ERZ2_ELEM_SIGM',  'QIRE_ELEM_SIGM',
     & 'QIRE_ELNO_ELEM',  'QIRE_NOEU_ELEM',  'QIZ1_ELEM_SIGM',
     & 'QIZ2_ELEM_SIGM',  'EPSG_ELGA_DEPL',  'EPSG_ELNO_DEPL',
     & 'EPSG_NOEU_DEPL',  'EPSP_ELGA',       'EPSP_ELNO',
     & 'EPSP_NOEU',       'VARI_ELGA',       'VARI_ELNO',
     & 'VARI_NOEU',       'VARI_ELNO_ELGA',  'VARI_NOEU_ELGA',
     & 'VARI_ELNO_TUYO',  'EPSA_ELNO',       'EPSA_NOEU',
     & 'COMPORTEMENT',    'DCHA_ELGA_SIGM',  'DCHA_ELNO_SIGM',
     & 'DCHA_NOEU_SIGM',  'RADI_ELGA_SIGM',  'RADI_ELNO_SIGM',
     & 'RADI_NOEU_SIGM',  'ENDO_ELNO_SIGA',  'ENDO_ELNO_SINO',
     & 'ENDO_NOEU_SINO',  'PRES_DBEL_DEPL',  'SIGM_ELNO_COQU',
     & 'EPME_ELNO_DEPL',  'EPME_ELGA_DEPL',  'EPMG_ELNO_DEPL',
     & 'EPMG_ELGA_DEPL',  'ENEL_ELGA',       'ENEL_ELNO_ELGA',
     & 'ENEL_NOEU_ELGA',  'SIGM_NOEU_COQU',  'SIGM_ELNO_TUYO',
     & 'EPMG_NOEU_DEPL',  'SING_ELEM',       'SING_ELNO_ELEM'/
C
C      '1234567890123456','1234567890123456','1234567890123456',
      DATA CHMEC3/
     & 'EQUI_ELGA_EPME',  'EQUI_ELNO_EPME',   'EQUI_NOEU_EPME',
     & 'DEDE_ELNO_DLDE',  'DEDE_NOEU_DLDE',   'DESI_ELNO_DLSI',
     & 'DESI_NOEU_DLSI',  'PMPB_ELGA_SIEF',   'PMPB_ELNO_SIEF',
     & 'PMPB_NOEU_SIEF',  'SIGM_ELNO_SIEF',   'SIPO_ELNO_SIEF',
     & 'SIGM_NOEU_SIEF',  'SIPO_NOEU_SIEF',   'EPFP_ELNO',
     & 'EPFP_ELGA',       'EPFD_ELNO',        'EPFD_ELGA',
     & 'EPVC_ELNO',       'EPVC_ELGA',        'VALE_CONT',
     & 'VARI_ELNO_COQU',  'CRIT_ELNO_RUPT',   'ETOT_ELGA',
     & 'ETOT_ELNO_ELGA',  'ETOT_ELEM',        'VALE_NCOU_MAXI',
     & 'MODE_FLAMB',      'ENDO_ELGA',        'ENDO_ELNO_ELGA',
     & 'INDI_LOCA_ELGA',  'EXTR_ELGA_VARI',   'EXTR_ELNO_VARI',
     & 'EXTR_NOEU_VARI',  'MODE_MECA'/

C     ------------------------------------------------------------------
C                      C H A M P _ T H E R M I Q U E
C     ------------------------------------------------------------------
C      '1234567890123456','1234567890123456','1234567890123456',
      DATA CHTHER/
     & 'TEMP',            'FLUX_ELGA_TEMP',  'FLUX_ELNO_TEMP',
     & 'FLUX_NOEU_TEMP',  'META_ELGA_TEMP',  'META_ELNO_TEMP',
     & 'META_NOEU_TEMP',  'DURT_ELGA_META',  'DURT_ELNO_META',
     & 'DURT_NOEU_META',  'HYDR_ELNO_ELGA',  'SOUR_ELGA_ELEC',
     & 'HYDR_NOEU_ELGA',  'DETE_ELNO_DLTE',  'DETE_NOEU_DLTE',
     & 'COMPORTHER',      'ERRE_ELEM_TEMP',  'ERRE_ELNO_ELEM',
     & 'ERRE_NOEU_ELEM'/
C     ------------------------------------------------------------------
C                      C H A M P _ V A R C
C     ------------------------------------------------------------------
C      '1234567890123456','1234567890123456','1234567890123456',
      DATA CHVARC/
     & 'IRRA',            'TEMP',            'HYDR_ELNO_ELGA',
     & 'HYDR_NOEU_ELGA',  'EPSA_ELNO',       'META_ELNO_TEMP'/
C     ------------------------------------------------------------------
C                      C H A M P _ A C O U S T I Q U E
C     ------------------------------------------------------------------
C      '1234567890123456','1234567890123456','1234567890123456',
      DATA CHACOU/
     & 'PRES',            'PRES_ELNO_DBEL',  'PRES_ELNO_REEL',
     & 'PRES_ELNO_IMAG',  'INTE_ELNO_ACTI',  'INTE_ELNO_REAC',
     & 'PRES_NOEU_DBEL',  'PRES_NOEU_REEL',  'PRES_NOEU_IMAG',
     & 'INTE_NOEU_ACTI',  'INTE_NOEU_REAC'/
C     ------------------------------------------------------------------
C                      C H A M P _ T H E T A _ R U P T
C     ------------------------------------------------------------------
C      '1234567890123456','1234567890123456','1234567890123456',
      DATA CHTHET/
     & 'THETA',           'GRAD_NOEU_THETA'/
C     ------------------------------------------------------------------

      NOMS2=NOMSD
      TYPES2=TYPESD
      BAS1=BASE

C     --- SI LA SD EXISTE DEJA, ON S'ARRETE EN ERREUR F :
      CALL JEEXIN(NOMS2//'.DESC',IRET)
      CALL ASSERT(IRET.EQ.0)

C     --- CREATION DE .DESC  ET  .ORDR ---
      CALL JECREO(NOMS2//'.DESC',BAS1//' N K16')
      CALL WKVECT(NOMS2//'.ORDR',BAS1//' V I',NBORDR,JORDR)
      CALL JEECRA(NOMS2//'.ORDR','LONUTI',0,' ')

      DO 10 I=1,NCMEC1
        CHMECA(I)=CHMEC1(I)
   10 CONTINUE
      DO 20 I=1,NCMEC2
        CHMECA(I+NCMEC1)=CHMEC2(I)
   20 CONTINUE
      DO 30 I=1,NCMEC3
        CHMECA(I+NCMEC1+NCMEC2)=CHMEC3(I)
   30 CONTINUE

C     -- DECLARATION ET INITIALISATION DES PARAMETRES ET VAR. D'ACCES :
C     ------------------------------------------------------------------
      CALL UTPARA(BAS1,NOMSD,TYPES2,NBORDR)




C     ------------------------------------------------------------------
      IF (TYPES2.EQ.'EVOL_ELAS') THEN

        NBCHAM=NCMECA
        CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
        CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'EVEL')
        DO 40 I=1,NBCHAM
          CALL JECROC(JEXNOM(NOMS2//'.DESC',CHMECA(I)))
   40   CONTINUE

        GOTO 320

C     ------------------------------------------------------------------
      ELSEIF (TYPES2.EQ.'MULT_ELAS') THEN

        NBCHAM=NCMECA
        CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
        CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'MUEL')
        DO 60 I=1,NBCHAM
          CALL JECROC(JEXNOM(NOMS2//'.DESC',CHMECA(I)))
   60   CONTINUE
        GOTO 320

C     ------------------------------------------------------------------
      ELSEIF (TYPES2.EQ.'FOURIER_ELAS') THEN

        NBCHAM=NCMECA
        CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
        CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'FOEL')
        DO 80 I=1,NBCHAM
          CALL JECROC(JEXNOM(NOMS2//'.DESC',CHMECA(I)))
   80   CONTINUE

        GOTO 320

C     ------------------------------------------------------------------
      ELSEIF (TYPES2.EQ.'FOURIER_THER') THEN

        NBCHAM=NCTHER
        CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
        CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'FOTH')
        DO 90 I=1,NBCHAM
          CALL JECROC(JEXNOM(NOMS2//'.DESC',CHTHER(I)))
   90   CONTINUE

        GOTO 320

C     ------------------------------------------------------------------
      ELSEIF (TYPES2.EQ.'EVOL_NOLI') THEN

        NBCHAM=NCMECA
        CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
        CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'EVNO')
        DO 100 I=1,NBCHAM
          CALL JECROC(JEXNOM(NOMS2//'.DESC',CHMECA(I)))
  100   CONTINUE

        GOTO 320

C     ------------------------------------------------------------------
      ELSEIF (TYPES2.EQ.'DYNA_TRANS') THEN

        NBCHAM=NCMECA
        CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
        CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'DYTR')
        DO 120 I=1,NBCHAM
          CALL JECROC(JEXNOM(NOMS2//'.DESC',CHMECA(I)))
  120   CONTINUE
        GOTO 320

C     ------------------------------------------------------------------
      ELSEIF (TYPES2.EQ.'DYNA_HARMO') THEN

        NBCHAM=NCMECA
        CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
        CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'DYHA')
        DO 140 I=1,NBCHAM
          CALL JECROC(JEXNOM(NOMS2//'.DESC',CHMECA(I)))
  140   CONTINUE
        GOTO 320

C     ------------------------------------------------------------------
      ELSEIF (TYPES2.EQ.'HARM_GENE') THEN

        NBCHAM=NCMECA
        CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
        CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'HAGE')
        DO 160 I=1,NBCHAM
          CALL JECROC(JEXNOM(NOMS2//'.DESC',CHMECA(I)))
  160   CONTINUE
        GOTO 320

C     ------------------------------------------------------------------
      ELSEIF (TYPES2.EQ.'ACOU_HARMO') THEN

        NBCHAM=NCACOU
        CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
        CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'ACHA')
        DO 170 I=1,NBCHAM
          CALL JECROC(JEXNOM(NOMS2//'.DESC',CHACOU(I)))
  170   CONTINUE

        GOTO 320

C     ------------------------------------------------------------------
      ELSEIF (TYPES2.EQ.'EVOL_CHAR') THEN

        NBCHAM=6
        CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
        CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'EVCH')
        CALL JECROC(JEXNOM(NOMS2//'.DESC','PRES'))
        CALL JECROC(JEXNOM(NOMS2//'.DESC','FVOL_3D'))
        CALL JECROC(JEXNOM(NOMS2//'.DESC','FVOL_2D'))
        CALL JECROC(JEXNOM(NOMS2//'.DESC','FSUR_3D'))
        CALL JECROC(JEXNOM(NOMS2//'.DESC','FSUR_2D'))
        CALL JECROC(JEXNOM(NOMS2//'.DESC','VITE_VENT'))
        GOTO 320


C     ------------------------------------------------------------------
      ELSEIF (TYPES2.EQ.'EVOL_THER') THEN

        NBCHAM=NCTHER
        CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
        CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'EVTH')
        DO 190 I=1,NBCHAM
          CALL JECROC(JEXNOM(NOMS2//'.DESC',CHTHER(I)))
  190   CONTINUE
        GOTO 320


C     ------------------------------------------------------------------
      ELSEIF (TYPES2.EQ.'EVOL_VARC') THEN

        NBCHAM=NCVARC
        CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
        CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'EVVA')
        DO 210 I=1,NBCHAM
          CALL JECROC(JEXNOM(NOMS2//'.DESC',CHVARC(I)))
  210   CONTINUE
        GOTO 320

C     ------------------------------------------------------------------
      ELSEIF (TYPES2.EQ.'MODE_MECA' .OR. TYPES2.EQ.'MODE_MECA_C' .OR.
     &        TYPES2.EQ.'MODE_GENE' .OR. TYPES2(1:9).EQ.'MODE_STAT' .OR.
     &        TYPES2.EQ.'MODE_ACOU' .OR. TYPES2.EQ.'DYNAMIQUE' .OR.
     &        TYPES2.EQ.'BASE_MODALE') THEN


        IF (TYPES2.EQ.'MODE_MECA') THEN
          CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'MOME')
        ELSEIF (TYPES2.EQ.'MODE_MECA_C') THEN
          CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'MOME')
        ELSEIF (TYPES2.EQ.'MODE_GENE') THEN
          CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'MOGE')
        ELSEIF (TYPES2(1:9).EQ.'MODE_STAT') THEN
          CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'MOST')
        ELSEIF (TYPES2.EQ.'DYNAMIQUE') THEN
          CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'BAMO')
        ELSEIF (TYPES2.EQ.'BASE_MODALE') THEN
          CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'BAMO')
        ELSEIF (TYPES2.EQ.'MODE_ACOU') THEN
          CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'MOAC')
        ENDIF

        IF (TYPES2.EQ.'MODE_ACOU') THEN
          NBCHAM=1
          CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
          CALL JECROC(JEXNOM(NOMS2//'.DESC','PRES'))
        ELSE
          NBCHAM=NCMECA
          CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
          DO 230 I=1,NBCHAM
            CALL JECROC(JEXNOM(NOMS2//'.DESC',CHMECA(I)))
  230     CONTINUE
        ENDIF
        GOTO 320

C     ------------------------------------------------------------------
      ELSEIF (TYPES2.EQ.'MODE_FLAMB') THEN

        NBCHAM=NCMECA
        CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
        CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'MOFL')
        DO 250 I=1,NBCHAM
          CALL JECROC(JEXNOM(NOMS2//'.DESC',CHMECA(I)))
  250   CONTINUE
        GOTO 320

C     ------------------------------------------------------------------
      ELSEIF (TYPES2.EQ.'COMB_FOURIER') THEN

        NBCHAM=NCMECA
        NBCHAM=NBCHAM+NCTHER-3
        CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
        CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'COFO')
        DO 270 I=1,NCMECA
          CALL JECROC(JEXNOM(NOMS2//'.DESC',CHMECA(I)))
  270   CONTINUE
        DO 280 I=1,NCTHER-3
          CALL JECROC(JEXNOM(NOMS2//'.DESC',CHTHER(I)))
  280   CONTINUE
        GOTO 320

C     ------------------------------------------------------------------
      ELSEIF (TYPES2.EQ.'THETA_GEOM') THEN

        NBCHAM=NCTHET
        CALL JEECRA(NOMS2//'.DESC','NOMMAX',NBCHAM,' ')
        CALL JEECRA(NOMS2//'.DESC','DOCU',IBID,'THET')
        DO 290 I=1,NBCHAM
          CALL JECROC(JEXNOM(NOMS2//'.DESC',CHTHET(I)))
  290   CONTINUE
        GOTO 320

      ELSE
        CALL U2MESK('F','UTILITAI4_31',1,TYPES2)
      ENDIF

C     ------------------------------------------------------------------
  320 CONTINUE



C     --- CREATION DE .TACH
C     -------------------------
      CALL JECREC(NOMS2//'.TACH',BAS1//' V K24','NU','CONTIG',
     &            'CONSTANT',NBCHAM)
      CALL JEECRA(NOMS2//'.TACH','LONMAX',NBORDR,' ')


C     -- POUR QUE LES COLLECTIONS .TACH ET .TAVA SOIENT BIEN CREEES :
C     ---------------------------------------------------------------
      DO 330,K=1,NBCHAM
        CALL JECROC(JEXNUM(NOMS2//'.TACH',K))
  330 CONTINUE
      CALL JELIRA(NOMS2//'.NOVA','NOMMAX',NBNOVA,KBID)
      DO 340,K=1,NBNOVA
        CALL JECROC(JEXNUM(NOMS2//'.TAVA',K))
  340 CONTINUE


      END
