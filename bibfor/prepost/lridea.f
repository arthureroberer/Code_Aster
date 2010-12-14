      SUBROUTINE LRIDEA(RESU,TYPRES,LINOCH,NBNOCH,NOMCMD,LISTRZ,LISTIZ,
     &                  PRECIS,CRIT,EPSI,ACCES,MFICH,NOMA,LIGREZ,NBVARI)
      IMPLICIT  NONE
      CHARACTER*(*) TYPRES,LINOCH(*),NOMCMD
      CHARACTER*8   RESU
      CHARACTER*(*) LISTRZ,LISTIZ,CRIT,ACCES
      CHARACTER*(*) LIGREZ
      REAL*8 EPSI
      INTEGER PRECIS,NBNOCH,MFICH,NBVARI

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 14/12/2010   AUTEUR PELLET J.PELLET 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================

C TOLE CRS_512 CRP_20
C----------------------------------------------------------------------
C  LECTURE DES RESULTATS PRESENTS DANS LE FICHIER UNIVERSEL ET STOCKAGE
C  DANS LA SD RESULTAT

C IN  : RESU   : K8    : NOM DE LA SD_RESULTAT
C IN  : TYPRES : K16   : TYPE DE RESULTAT ('EVOL_ELAS','DYNA_TRANS')
C IN  : LINOCH : L_K16 : LISTE DES NOMS DE CHAMP ('DEPL',SIEF_ELNO')
C IN  : NBNOCH : I     : NOMBRE DE CHAMPS A LIRE
C IN  : NOMCMD : K16   : NOM DE LA COMMANDE
C IN  : LISTRZ : K19   : NOM DE L'OBJET CONTENANT LA LISTE DES INSTANTS
C                        OU DES FREQUENCES A LIRE
C IN  : LISTIZ : K19   : NOM DE L'OBJET CONTENANT LA LISTE DES
C                        NUMEROS D'ORDRE A LIRE
C IN  : PRECIS : I     : INDICATEUR DE VERIFICATION DE LA PRECISION
C IN  : CRIT   : K8    : PRECISION : CRITERE RELATIF OU ABSOLU
C IN  : EPSI   : R     : PRECISION DEMANDEE
C IN  : ACCES  : K10   : TYPE D'ACCES ('TOUT_ORDRE','NUME_ORDRE','INST'
C                                      'LIST_INST',...)
C IN  : MFICH  : I     : NUMERO UNITE LOGIQUE DU FICHIER UNIVERSEL
C IN  : NOMA   : K8    : NOM DU MAILLAGE
C IN  : LIGREZ : K19   : NOM DU LIGREL
C IN  : NBVARI : I     : NOMBRE DE VARIABLES INTERNES A LIRE POUR LE
C                        CHAMP DE VARIABLES INTERNES (VARI_R)
C     -----------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX --------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR, ZERO
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24,NOOJB
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32 JEXNUM,JEXNOM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX --------------------------
      REAL*8 RBID,VAL(1000),IOUF,MASGEN,AMRGE
      INTEGER LFINOM,LFINUM,LFIPAR,LFILOC,LFINBC,LFICMP
      INTEGER VALI,NBVAL,IAUX,ICHAMP
      INTEGER JCNSD,JCNSV,JCNSL,JCESD,JCESV,JCESL
      INTEGER NBREC,NUMDAT,NUMCH,JPERM,IAST,ISUP,JTYPM,ITYPE
      INTEGER INOIDE,INOAST,IELAST,IELIDE,KNOIDE,KNOAST
      INTEGER NBCMP,NBCMID,ICH,ICMP,NBCMP1,MAXNOD,LON1,VERSIO
      INTEGER IREC,ICOMPT,VALATT,IFIELD,IORD,IBID,ILU1
      INTEGER I,IEXP,NBNOE,NBFIEL,IER,NBNOEU,NBELEM
      INTEGER IRET,IDECAL,ICMP1,ICMP2,INATUR,KK,NUMODE
      LOGICAL TROUVE,ASTOCK,CHAMOK,ZCMPLX
      CHARACTER*4 TYCHAS,TYCHID,ACCE2
      CHARACTER*6 KAR
      CHARACTER*8 NOMGD,LICMP(1000),K8BID,NOMNO,NOMMA,NOMA
      CHARACTER*8 NOMNOA,NOMNOB, PROLO
      CHARACTER*13 A13BID
      CHARACTER*16 NOMCH,NOIDEA,CONCEP,NOMC2,NOMCHA
      CHARACTER*19 CHS,LISTR8,LISTIS,LIGREL,PRCHNO,PRCHN2,PRCHN3
      CHARACTER*80 REC(20)

      PARAMETER (NBFIEL=40,VERSIO=5)
C ---------------------------------------------------------------------
      CALL JEMARQ()

      ZERO = 0.D0
      NOMC2=' '

      LISTR8 = LISTRZ
      LISTIS = LISTIZ
      LIGREL = LIGREZ
      ZCMPLX = .FALSE.

      ACCE2 = 'INST'
      CALL RSEXPA(RESU,0,'FREQ',IRET)
      IF (IRET.GT.0)  ACCE2 = 'FREQ'

      CALL DISMOI('F','NB_MA_MAILLA',NOMA,'MAILLAGE',NBELEM,K8BID,IER)
      CALL DISMOI('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NBNOEU,K8BID,IER)

      CALL JEVEUO(NOMA//'.TYPMAIL','L',JTYPM)

C- TABLEAU DE PERMUTATION POUR LES CONNECTIVITES DES MAILLES :
      CALL IRADHS(VERSIO)
      CALL JEVEUO('&&IRADHS.PERMUTA','L',JPERM)
      CALL JELIRA('&&IRADHS.PERMUTA','LONMAX',LON1,K8BID)
      MAXNOD=ZI(JPERM-1+LON1)

C- CREATION DE LA STRUCTURE DE DONNEES FORMAT_IDEAS ---

      NOIDEA = '&&LIRE_RESU_IDEA'
      CALL CRSDFI(LINOCH,NBNOCH,NOIDEA)

C- OUVERTURE EN LECTURE DES OBJETS COMPOSANTS LA SD FORMAT_IDEAS

      CALL JEVEUO(NOIDEA//'.FID_NOM','L',LFINOM)
      CALL JEVEUO(NOIDEA//'.FID_NUM','L',LFINUM)
      CALL JEVEUO(NOIDEA//'.FID_PAR','L',LFIPAR)
      CALL JEVEUO(NOIDEA//'.FID_LOC','L',LFILOC)
      CALL JEVEUO(NOIDEA//'.FID_CMP','L',LFICMP)
      CALL JEVEUO(NOIDEA//'.FID_NBC','L',LFINBC)

C- CREATION DE L'OBJET .REFD DANS LES MODE_MECA
C- S'IL N'Y PAS DE PROFIL DE STOCKAGE PREDEFINI IL FAUT EN CREER UN
C- C'EST FAIT DANS CNSCNO EN LUI INDIQUANT UN NOM DE PROFIL MIS A BLANC
C- SINON ON RECHERCHE LE PROFIL DE LA MATRICE DE RIGIDITE (MATRB)
      PRCHNO = ' '
      IF ((TYPRES.EQ.'MODE_MECA').OR.(TYPRES.EQ.'MODE_MECA_C')) THEN
        CALL LRREFD(RESU,PRCHNO)
      ENDIF
      REWIND MFICH

C- LECTURE DU NUMERO DU DATASET

   10 CONTINUE
      READ (MFICH,'(A6)',END=170,ERR=160) KAR

C- ON NE LIT QUE LES DATASETS 55, 57 ET 2414

      IF (KAR.EQ.'    55') THEN
        NBREC = 8
        NUMDAT = 55
      ELSE IF (KAR.EQ.'    57') THEN
        NBREC = 8
        NUMDAT = 57
      ELSE IF (KAR.EQ.'  2414') THEN
        NBREC = 13
        NUMDAT = 2414
      ELSE
        GO TO 10
      END IF

C-LECTURE DE L'ENTETE DU DATASET

      DO 20 IREC = 1,NBREC
        READ (MFICH,'(A80)',END=160) REC(IREC)
   20 CONTINUE

C-TRAITEMENT DE L'ENTETE : ON RECHERCHE SI LE CONTENU EST
C CONFORME A CELUI PRESENT DANS LA SD FORMAT_IDEAS

      DO 30 ICH = 1,NBNOCH
        IF (ZI(LFINUM-1+ICH).EQ.NUMDAT) GO TO 40
   30 CONTINUE
      GO TO 10

   40 CONTINUE

C RECUPERATION DU NOMCHA DU DATASET
      IF ((NUMDAT .EQ. 55) .OR. (NUMDAT .EQ. 57)) THEN
        IREC = 6
      ELSE IF (NUMDAT .EQ. 2414) THEN
        IREC = 9
      ELSE
        GO TO 10
      END IF

      IFIELD = 4
      CALL DECOD2(REC,IREC,IFIELD,0,ICHAMP,RBID,TROUVE)
         
      CHAMOK = .FALSE.
      DO 70 ICH = 1,NBNOCH
        IF (.NOT.CHAMOK) THEN
          VALATT = ZI(LFIPAR-1+ (ICH-1)*800+(IREC-1)*40+4)
          IF (VALATT.EQ.9999) THEN
            IF (ICHAMP.EQ.0) NOMCHA='VARI_ELNO' 
            IF (ICHAMP.EQ.2) NOMCHA='SIEF_ELNO' 
            IF (ICHAMP.EQ.3) NOMCHA='EPSA_ELNO' 
            IF (ICHAMP.EQ.5) NOMCHA='TEMP' 
            IF (ICHAMP.EQ.8) NOMCHA='DEPL' 
            IF (ICHAMP.EQ.11) NOMCHA='VITE' 
            IF (ICHAMP.EQ.12) NOMCHA='ACCE' 
            IF (ICHAMP.EQ.15) NOMCHA='PRES' 
            IF(NOMCHA(1:3).EQ.ZK16(LFINOM-1+ICH)(1:3))THEN
              NOMCH = ZK16(LFINOM-1+ICH)
              NUMCH = ICH
              CHAMOK = .TRUE.
            END IF
          ELSE
            DO 60 IREC = 1,NBREC
              DO 50 IFIELD = 1,NBFIEL
                VALATT = ZI(LFIPAR-1+ (ICH-1)*800+
     &                   (IREC-1)*40+IFIELD)
                IF (VALATT.NE.9999) THEN
                  CALL DECOD1(REC,IREC,IFIELD,VALATT,TROUVE)
                  IF (.NOT.TROUVE) GO TO 70
                END IF
   50         CONTINUE
   60       CONTINUE
            CHAMOK = .TRUE.
            NOMCH = LINOCH(ICH)
            NUMCH = ICH
          END IF
        END IF
   70 CONTINUE
      IF (.NOT.CHAMOK) GO TO 10

C- TRAITEMENT DU NUMERO D'ORDRE, DE L'INSTANT OU DE LA FREQUENCE
      IREC = ZI(LFILOC-1+ (NUMCH-1)*10+1)
      IFIELD = ZI(LFILOC-1+ (NUMCH-1)*10+2)
      CALL DECOD2(REC,IREC,IFIELD,0,IORD,RBID,TROUVE)
      IF (.NOT.TROUVE) CALL U2MESS('F','PREPOST3_31')

      IF (ACCES.EQ.'INST' .OR. ACCES.EQ.'LIST_INST'
     &    .OR. ACCE2.EQ.'INST') THEN
        IREC = ZI(LFILOC-1+ (NUMCH-1)*10+3)
        IFIELD = ZI(LFILOC-1+ (NUMCH-1)*10+4)
        CALL DECOD2(REC,IREC,IFIELD,1,IBID,IOUF,TROUVE)
        IF (.NOT.TROUVE) CALL U2MESS('F','PREPOST3_32')
      END IF

      IF (ACCES.EQ.'FREQ' .OR. ACCES.EQ.'LIST_FREQ'
     &    .OR. ACCE2.EQ.'FREQ') THEN
        IREC = ZI(LFILOC-1+ (NUMCH-1)*10+5)
        IFIELD = ZI(LFILOC-1+ (NUMCH-1)*10+6)
        CALL DECOD2(REC,IREC,IFIELD,1,IBID,IOUF,TROUVE)
        IF (.NOT.TROUVE) THEN
          CALL U2MESS('F','PREPOST3_33')
        END IF
      END IF
C---  ON RECUPERE NUME_MODE ET MASS_GENE S'ILS SONT PRESENTS:
      NUMODE=0
      MASGEN=0.D0
      AMRGE=0.D0
C---  NUME_MODE :
      IREC = ZI(LFILOC-1+ (NUMCH-1)*10+7)
      IFIELD = ZI(LFILOC-1+ (NUMCH-1)*10+8)
      CALL DECOD2(REC,IREC,IFIELD,0,NUMODE,RBID,TROUVE)
C---  MASS_GENE :
      IREC = ZI(LFILOC-1+ (NUMCH-1)*10+9)
      IFIELD = ZI(LFILOC-1+ (NUMCH-1)*10+10)
      CALL DECOD2(REC,IREC,IFIELD,1,IBID,MASGEN,TROUVE)
C---  AMOR_GENE :
      IREC = ZI(LFILOC-1+ (NUMCH-1)*10+11)
      IFIELD = ZI(LFILOC-1+ (NUMCH-1)*10+12)
      CALL DECOD2(REC,IREC,IFIELD,2,IBID,AMRGE,TROUVE)

C---  ON VERIFIE SI LE NUMERO D'ORDRE OU L'INSTANT OU LA FREQUENCE LU
C     CORRESPOND A CELUI OU CELLE RECHERCHEE.

      CALL NUMEOK(ACCES,IORD,IOUF,LISTR8,LISTIS,PRECIS,CRIT,EPSI,ASTOCK)

C- ON RECHERCHE LE TYPE DE CHAMP

      IF (NUMDAT.EQ.55) THEN
        TYCHID = 'NOEU'
      ELSE IF (NUMDAT.EQ.57) THEN
        TYCHID = 'ELNO'
      ELSE IF (NUMDAT.EQ.2414) THEN
        IREC = 3
        IFIELD = 1
        CALL DECOD2(REC,IREC,IFIELD,0,ILU1,RBID,TROUVE)
        IF (.NOT.TROUVE) THEN
          CALL U2MESS('F','PREPOST3_34')
        END IF
        IF (ILU1.EQ.1) THEN
          TYCHID = 'NOEU'
        ELSE IF (ILU1.EQ.2) THEN
          TYCHID = 'ELGA'
        ELSE IF (ILU1.EQ.3) THEN
          TYCHID = 'ELNO'
        END IF
      END IF

C- RECHERCHE DU NOMBRE DE COMPOSANTES CONTENUES DANS LE DATASET

      IF (NUMDAT.EQ.55 .OR. NUMDAT.EQ.57) THEN
        IREC = 6
        IFIELD = 6
      ELSE IF (NUMDAT.EQ.2414) THEN
        IREC = 9
        IFIELD = 6
      END IF
      CALL DECOD2(REC,IREC,IFIELD,0,NBCMID,RBID,TROUVE)
      IF (.NOT.TROUVE)  CALL U2MESS('F','PREPOST3_35')

C- ON RECHERCHE DANS LE FICHIER UNV SI LA NATURE DU CHAMP
C  DE DEPLACEMENT
C  'DEPL_R' -> REEL     --> INATUR = 2,4 -> REEL
C  'DEPL_C' -> COMPLEXE --> INATUR = 5,6-> COMPLEXE

      IFIELD = 5
      CALL DECOD2(REC,IREC,IFIELD,0,INATUR,RBID,TROUVE)
      IF (.NOT.TROUVE) CALL U2MESS('F','PREPOST3_36')
      IF (INATUR.EQ.5 .OR. INATUR.EQ.6) ZCMPLX = .TRUE.

C- ON RECHERCHE LE TYPE DE CHAMP DEMANDE PAR L'UTILISATEUR
C  ET LA GRANDEUR ASSOCIEE

      CALL RSUTC2(TYPRES,NOMCH,NOMGD,TYCHAS)

C- VERIFICATION DE LA COMPATIBILITE DU CHAMP DEMANDE
C  AVEC LE CHAMP IDEAS
      IF (TYCHID.NE.TYCHAS) CALL U2MESS('F','PREPOST3_37')

C- VERIFICATION SI LE CHAMP IDEAS ET ASTER SONT DE MEME NATURE
C  REEL OU COMPLEXE

      IF (.NOT.ZCMPLX) THEN
        IF (TYPRES.EQ.'DYNA_HARM' .OR. TYPRES.EQ.'HARM_GENE'
     &   .OR.TYPRES.EQ.'MODE_MECA_C') THEN
          CALL U2MESS('F','PREPOST3_38')
        END IF
      END IF

      IF (ASTOCK) THEN

C- CREATION DES CHAMPS SIMPLES NOEUDS ET ELEMENTS

        NBCMP = ZI(LFINBC-1+NUMCH)

        NBCMP1 = 0
        DO 80 ICMP = 1,NBCMP
          IF (ZK8(LFICMP-1+ (NUMCH-1)*1000+ICMP).NE.'XXX') THEN
            NBCMP1 = NBCMP1 + 1
            LICMP(NBCMP1) = ZK8(LFICMP-1+ (NUMCH-1)*1000+ICMP)
          END IF
   80   CONTINUE

        IF (TYCHID.EQ.'NOEU') THEN

          CHS = '&&LRIDEA.CHNS'
          CALL CNSCRE(NOMA,NOMGD,NBCMP1,LICMP,'V',CHS)
        ELSE

          CALL JEEXIN(LIGREL//'.LGRF',IRET)
          IF (IRET.EQ.0) CALL U2MESS('F','PREPOST3_39')
          CHS = '&&LRIDEA.CHES'

          IF (NOMCH(1:4).EQ.'VARI') NBCMP1 = NBVARI

          CALL CESCRE('V',CHS,TYCHAS,NOMA,NOMGD,NBCMP1,LICMP,IBID,-1,
     &                -NBCMP1)
        END IF

C --- LECTURE DU CHAMP NOEUDS

        IF (TYCHID.EQ.'NOEU') THEN
          CALL JEVEUO(CHS//'.CNSD','E',JCNSD)
          CALL JEVEUO(CHS//'.CNSV','E',JCNSV)
          CALL JEVEUO(CHS//'.CNSL','E',JCNSL)

          CALL GETVTX(' ','PROL_ZERO',0,1,1,PROLO,IRET)
          IF(PROLO(1:3).EQ.'OUI')THEN
             CALL U2MESK('I','PREPOST_13',1,NOMCH)
             CALL JELIRA(CHS//'.CNSV','LONMAX',NBVAL,K8BID)
             IF (ZCMPLX) THEN
               DO 85 IAUX=1,NBVAL
                 ZC(JCNSV-1+IAUX) = DCMPLX(0.D0,0.D0)
                 ZL(JCNSL-1+IAUX) = .TRUE.
 85            CONTINUE
             ELSE
               DO 86 IAUX=1,NBVAL
                 ZR(JCNSV-1+IAUX) = 0.D0
                 ZL(JCNSL-1+IAUX) = .TRUE.
 86            CONTINUE
             ENDIF
          ENDIF

   90     CONTINUE

          READ (MFICH,'(I10,A13,A8)',END=160) INOIDE,A13BID,NOMNOA
          IF (INOIDE.EQ.-1) GO TO 150

          NOMNO='NXXXXXXX'
          CALL CODENT(INOIDE,'G',NOMNO(2:8))
          CALL JENONU(JEXNOM(NOMA//'.NOMNOE',NOMNO),INOAST)
C  ON ESSAIE DE RECUPERER LE NUMERO DU NOEUD DIRECTEMENT
C  SI ON NE LE TROUVE PAS VIA NXXXX
          IF (INOAST .EQ. 0) THEN
            CALL JENUNO(JEXNUM(NOMA//'.NOMNOE',INOIDE),NOMNOB)
            IF (NOMNOB .NE. NOMNOA) CALL U2MESS('F','PREPOST3_40')
            INOAST=INOIDE
          ENDIF
          CALL ASSERT(INOAST.GT.0)


          IF (INOAST.GT.NBNOEU) THEN
            VALI = INOAST
            CALL U2MESG('F', 'PREPOST5_45',0,' ',1,VALI,0,0.D0)
          END IF

          IDECAL = (INOAST-1)*ZI(JCNSD-1+2)
          IF (ZCMPLX) THEN
            READ (MFICH,'(6E13.5)',END=160) (VAL(I),I=1,2*NBCMID)
            ICMP1 = 0
            DO 100 ICMP = 1,NBCMP
              ICMP2 = ICMP*2
              IF (ZK8(LFICMP-1+ (NUMCH-1)*1000+ICMP).NE.'XXX') THEN
                ICMP1 = ICMP1 + 1
                ZC(JCNSV-1+IDECAL+ICMP1) = DCMPLX(VAL(ICMP2-1),
     &                                     VAL(ICMP2))
                ZL(JCNSL-1+IDECAL+ICMP1) = .TRUE.
              END IF
  100       CONTINUE
          ELSE
            READ (MFICH,'(6E13.5)',END=160) (VAL(I),I=1,NBCMID)
            ICMP1 = 0
            DO 110 ICMP = 1,NBCMP
              IF (ZK8(LFICMP-1+ (NUMCH-1)*1000+ICMP).NE.'XXX') THEN
                ICMP1 = ICMP1 + 1
                ZR(JCNSV-1+IDECAL+ICMP1) = VAL(ICMP)
                ZL(JCNSL-1+IDECAL+ICMP1) = .TRUE.
              END IF
  110       CONTINUE
          END IF
          GO TO 90
C - LECTURE DU CHAMP ELEMENT

        ELSE IF (TYCHID.EQ.'ELNO') THEN
          CALL JEVEUO(CHS//'.CESD','L',JCESD)
          CALL JEVEUO(CHS//'.CESV','E',JCESV)
          CALL JEVEUO(CHS//'.CESL','E',JCESL)

  120     CONTINUE
          READ (MFICH,'(4I10)',END=160) IELIDE,IEXP,NBNOE,NBCMID
          IF (NOMCH(1:4).EQ.'VARI') NBCMP = NBVARI
          IF (IELIDE.EQ.-1) GO TO 150
          NOMMA='MXXXXXXX'
          CALL CODENT(IELIDE,'G',NOMMA(2:8))
          CALL JENONU(JEXNOM(NOMA//'.NOMMAI',NOMMA),IELAST)
C  ON ESSAIE DE RECUPERER LE NUMERO DE LA MAILLE DIRECTEMENT
C  SI ON NE LE TROUVE PAS VIA MXXXX
          IF (IELAST .EQ. 0) IELAST = IELIDE
          CALL ASSERT(IELAST.GT.0)

          IF (IELAST.GT.NBELEM) THEN
            VALI = IELAST
            CALL U2MESG('F', 'PREPOST5_46',0,' ',1,VALI,0,0.D0)
          END IF
          ITYPE=ZI(JTYPM-1+IELAST)

          DO 140 KNOIDE = 1,NBNOE

C           -- CALCUL DE KNOAST :
            DO 141 IAST = 1,NBNOE
               ISUP=ZI(JPERM-1+MAXNOD*(ITYPE-1)+IAST)
               IF (ISUP.EQ.KNOIDE) GOTO 142
 141        CONTINUE
            CALL U2MESS('F','PREPOST3_40')
 142        CONTINUE
            KNOAST=IAST

            READ (MFICH,'(6E13.5)',END=160) (VAL(I),I=1,NBCMID)
            ICMP1 = 0
            DO 130 ICMP = 1,NBCMP
              IF (ZK8(LFICMP-1+ (NUMCH-1)*1000+ICMP).NE.'XXX') THEN
                ICMP1 = ICMP1 + 1
                CALL CESEXI('S',JCESD,JCESL,IELAST,KNOAST,1,ICMP1,KK)
                ZR(JCESV-1+ABS(KK)) = VAL(ICMP)
                ZL(JCESL-1+ABS(KK)) = .TRUE.
              END IF
  130       CONTINUE
  140     CONTINUE

          GO TO 120
        ELSE IF (TYCHID.EQ.'ELGA') THEN
          CALL U2MESS('F','PREPOST3_41')
        END IF

  150   CONTINUE
C       -- STOCKAGE DU CHAMP SIMPLE DANS LA SD_RESULTAT :

C       -- ON CHERCHE A ECONOMISER LES PROF_CHNO :
        IF (PRCHNO.EQ.' ') THEN
          IF (NOMCH.EQ.NOMC2) THEN
            PRCHN3=PRCHN2
          ELSE
            NOOJB='12345678.00000.NUME.PRNO'
            CALL GNOMSD ( NOOJB,10,14)
            PRCHN3=NOOJB(1:19)
          END IF
          NOMC2=NOMCH
          PRCHN2=PRCHN3
        ELSE
          PRCHN3=PRCHNO
        END IF
        CALL STOCK(RESU,NOMCMD,CHS,NOMCH,LIGREL,TYCHAS,IORD,IOUF,
     &  NUMODE,MASGEN,AMRGE,PRCHN3)
        GO TO 10
      ELSE
        GO TO 10
      END IF

      GO TO 180
  160 CONTINUE
      CALL GETRES(RESU,CONCEP,NOMCMD)
      CALL U2MESS('F','ALGORITH5_5')

  170 CONTINUE

  180 CONTINUE
      CALL JEDETR('&&IRADHS.PERMUTA')
      CALL JEDETR('&&IRADHS.CODEGRA')
      CALL JEDETR('&&IRADHS.CODEPHY')
      CALL JEDETR('&&IRADHS.CODEPHD')
      CALL JEDEMA()
      END
