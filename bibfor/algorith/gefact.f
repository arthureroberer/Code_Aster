      SUBROUTINE GEFACT (DUREE,NOMINF)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 03/01/2006   AUTEUR REZETTE C.REZETTE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE CAMBIER S.CAMBIER
C ----------------------------------------------------------------------
C
C GENERATION DE FCT ALEATOIRES : 
C        - PREPARATION (DISCRETISATION-PROLONGEMENT) DE L INTERSPECTRE 
C            (EN FONCTION DES CARACTERISTIQUES DU TEMPOREL A GENERER) 
C        - FACTORISATION DE L INTERSPECTRE
C
C ----------------------------------------------------------------------
C
C      IN   :
C             DUREE : DUREE DU TEMPOREL A SIMULER (NEGATIVE SI ELLE
C                     N'EST PAS UNE DONNEE)
C      OUT  :  
C             NOMINF : NOM DE L'INTERSPECTRE FACTORISE 
C
C ----------------------------------------------------------------------
C 
C
      IMPLICIT NONE
C 
C 0.1. ==> ARGUMENTS
C  
      REAL*8        DUREE
      CHARACTER*8   BASENO

C
C 0.2. ==> COMMUNS
C
C     ----- DEBUT DES COMMUNS JEVEUX -----------------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16            ZK16
      CHARACTER*24                    ZK24
      CHARACTER*32                            ZK32
      CHARACTER*80                                    ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32  JEXNUM
C     ----- FIN DES COMMUNS JEVEUX -------------------------------------
C
C 0.3. ==> VARIABLES LOCALES
C 
C
      INTEGER      L, N1, COEF, NUMVIT, NBPOIN, NBPINI, IBID, IRET, IER
      INTEGER      DIM, LONG, DIM2, DIM3, DIM4, IVAL(3)
      INTEGER      NNN, NBMR, NBPT1, NBPT2, LONGH, NBVALU
      INTEGER      NBFC, NBVAL,NBVAL1, NBVAL3, NBF1 
      INTEGER      I, II, JJ, J, K, KVAL, KF, LTABL, LVAL2, LVALC, IPAS
      INTEGER      IINF, ISUP, LS, LR, LD, LU, LV, LW, IX, IY
      INTEGER      LVAL, LVAL1, LCHDES, INUOR, LNUOR, JNUOR, LFON 

      REAL*8       R8B, FREQ1, FREQ2, PREC
      REAL*8       FREQI, FREQF, FREQ, FRINIT, FMAX, FMIN
      REAL*8       PMIN, DFREQ, DIFPAS, DIFF, DT
      REAL*8       PAS, PAS1,RESURE, RESUIM
      REAL*8       PUI2, PUI2D, PUI3D

      COMPLEX*16   C16B
      CHARACTER*3  TYPPAR,INTERP
      CHARACTER*8  K8B
      CHARACTER*16 K16BID, NOMCMD, NOPAR(3)
      CHARACTER*19 K19BID, NOMINF, NOMINT, NOMFON
      CHARACTER*24 VALE, CHVALE, CHDESC, NOMOB2,CHNUOR,NOMOBJ
      LOGICAL      LTAB, EXISP, LFREQF, LFREQI, LNBPN, LINTER, LPREM
C
      DATA NOPAR / 'NUME_VITE_FLUI' , 'NUME_ORDRE_I' , 'NUME_ORDRE_J' /
C     ----------------------------------------------------------------
C     --- INITIALISATION  ---
C
      CALL JEMARQ()
C

      CALL GETRES ( K19BID, K16BID, NOMCMD )

C===============
C 1. LECTURE DES DONNEES LIEES A L INTERSPECTRE ET VERIFS
C===============

      CALL GETVID (' ', 'INTE_SPEC'     , 0,1,1, NOMINT, L )

      CALL GETVIS (' ', 'NUME_VITE_FLUI', 0,1,1, NUMVIT    , N1)
      CALL TBEXIP ( NOMINT, 'NUME_VITE_FLUI', LTAB ,TYPPAR)
C 
      IF ( LTAB.AND.(N1.EQ.0) ) THEN
          CALL UTMESS('F',NOMCMD,'LE TYPE DE CONCEPT: TABLE_SDASTER'//
     +        ' DOIT ETRE ASSOCIE AU MOT CLE NUME_VITE_FLUI')
      ENDIF
C
C     VERIFICATION SUR LES PARAMETRES DE LA TABLE
      CALL TBEXP2(NOMINT,'NUME_ORDRE_I')
      CALL TBEXP2(NOMINT,'FONCTION')
      IF(LTAB)THEN
          CALL TBEXP2(NOMINT,'NUME_ORDRE_J')
      ELSE
          CALL TBEXP2(NOMINT,'DIMENSION')
      ENDIF
C
      CALL GETVTX ( ' ', 'INTERPOL'   , 1,1,2, INTERP     , N1 )
      LINTER = (INTERP.EQ.'NON')

      CALL GETVIS ( ' ', 'NB_POIN', 0,1,1, NBPOIN, L )
      LNBPN = L .NE. 0
      NBPINI = NBPOIN
C 
C=====
C  1.1  RECUPARATION DES DIMENSIONS, DES NUMEROS D'ORDRE, ... 
C=====
      NOMOBJ = '&&GEFACT.TEMP.NUOR'
      CALL TBEXVE ( NOMINT, 'NUME_ORDRE_I', NOMOBJ, 'V', NBMR, K8B )
      CALL JEVEUO ( NOMOBJ, 'L', JNUOR )
      CALL ORDIS  ( ZI(JNUOR) , NBMR )
      CALL WKVECT ( '&&GEFACT.MODE', 'V V I', NBMR, INUOR )
      NNN = 1
      ZI(INUOR) = ZI(JNUOR)
      DO 10 I = 2 , NBMR
         IF ( ZI(JNUOR+I-1) .EQ. ZI(INUOR+NNN-1) ) GOTO 10
         NNN = NNN + 1
         ZI(INUOR+NNN-1) = ZI(JNUOR+I-1)
 10   CONTINUE

      IF ( LTAB ) THEN
        DIM = NNN
        NBFC = DIM * ( DIM + 1 ) / 2
        CALL WKVECT('&&GEFACT.TEMP.FONC','V V K24',NBFC,LFON)
        IVAL(1) = NUMVIT
        DO 5 II = 1,DIM
          IVAL(2) = ZI(INUOR+II-1)
          DO 6 JJ = II,DIM
             IVAL(3) = ZI(INUOR+JJ-1)
             CALL TBLIVA ( NOMINT, 3, NOPAR, IVAL, R8B, C16B, K8B,K8B,
     +            R8B, 'FONCTION', K8B, IBID, R8B, C16B, NOMFON, IRET )
             IF (IRET.NE.0) CALL UTMESS('F','GEFACT','Y A UN BUG 2')
             KF = ((JJ-1)*JJ)/2 + II
             ZK24(LFON+KF-1) = NOMFON//'     '
    6     CONTINUE
    5   CONTINUE
        LTABL = LFON
C
      ELSE
        CALL TBLIVA ( NOMINT, 0, K8B, IBID, R8B, C16B, K8B, K8B, R8B,
     +              'DIMENSION', K8B, DIM, R8B, C16B, K8B, IRET )
        IF ( IRET .NE. 0 ) CALL UTMESS('F','GEFACT','Y A UN BUG 3' )
        NBFC = DIM * ( DIM + 1 ) / 2
        NOMOB2 = '&&GEFACT.FONCTION'
        CALL TBEXVE ( NOMINT, 'FONCTION', NOMOB2, 'V', NBF1, K8B )
        IF ( NBFC .NE. NBF1 ) CALL UTMESS('F','GEFACT','Y A UN BUG 4' )
        CALL JEVEUO ( NOMOB2, 'L', LTABL )
      ENDIF
C
C=====
C 1.2 DONNEES ECHANTILLONNAGE FREQUENTIEL, DEDUCTION DES DONNEES 
C     MANQUANTES (POUR RESPECTER ENTRE AUTRE LE TH. DE SHANNON)
C=====

C 1.2.1 CAS OU ON UTILISE LA DISCRETISATION DE L INTERSPECTRE :
C     VERIFICATION DE LA COHERENCE DE LA DISCRETISATION DES FONCTIONS
C     DANS LE CAS OU CETTE DISCRETISATION EST CONSERVEE        
      IF (LINTER) THEN
        NOMFON = ZK24(LTABL)
        VALE = NOMFON//'.VALE'
        CALL JELIRA(VALE,'LONUTI',NBVAL3,K8B)
        CALL JEVEUO(VALE,'L',LVAL1)
        NBVAL = NBVAL3/3
        PAS = (ZR(LVAL1+NBVAL-1)-ZR(LVAL1))/ (NBVAL-1)
        PREC = 1.D-06
        DO 100 II = 1,NBVAL-1
          PAS1 = ZR(LVAL1+II) - ZR(LVAL1+II-1)
          DIFPAS = ABS(PAS1-PAS)
          IF (DIFPAS.GT.PREC) THEN
            CALL UTMESS('F',NOMCMD,'PAS DE DISCRETISATION'//
     +              ' DE L''INTERSPECTRE NON CONSTANT.')
          ENDIF
  100   CONTINUE
        DO 20 I = 2,NBFC
          NOMFON = ZK24(LTABL+I-1)
          CALL JELIRA(NOMFON//'.VALE','LONUTI',NBVALU,K8B)
          IF (NBVALU.NE.NBVAL3) THEN
            CALL UTMESS('F',NOMCMD,'DISCRETISATIONS DIFFERENTES'//
     +                'SELON LES FONCTIONS DE L''INTERSPECTRE')
          ENDIF
          CALL JEVEUO(VALE,'L',LVAL2)
          DO 30 J = 1,NBVAL
            FREQ1 = ZR(LVAL1+J-1)
            FREQ2 = ZR(LVAL2+J-1)
            DIFF = FREQ2 - FREQ1
            IF (DIFF.GT.PREC) THEN
              CALL UTMESS('F',NOMCMD,'DISCRETISATIONS DIFFERENTES'//
     +                'SELON LES FONCTIONS DE L''INTERSPECTRE')
            ENDIF
   30     CONTINUE
   20   CONTINUE

        IF (( LNBPN ).AND.(NBPINI.LT.NBVAL)) THEN
          FREQF =  ZR(LVAL1+NBPINI-1)
          CALL UTDEBM('A',NOMCMD,'"NB_POIN" EST INFERIEUR AU '//
     +         'NOMBRE DE POINTS DE L''INTERSPECTRE.')
          CALL UTIMPR('L','LE SPECTRE EST TRONQUEE A LA FREQUENCE : '
     +                                           ,1,FREQF)
          CALL UTFINM()          
        ELSE
          FREQF =  ZR(LVAL1+NBVAL-1)       
        ENDIF  
        DFREQ = PAS
        DUREE = 1.D0 / DFREQ
        FREQI = ZR(LVAL1)
        FRINIT = FREQI
       
        NBPOIN = 2**(INT(LOG(FREQF/DFREQ)/LOG(2.D0))+1)
        IF (LNBPN) THEN 
          IF (NBPOIN.GT.NBPINI ) THEN
          CALL UTDEBM('A',NOMCMD,'LE "NB_POIN" DONNE EST MODIFIE (EN'//
     +        ' UNE PUISSANCE DE 2 COMPATIBLE AVEC L''INTERSPECTRE). ')
            CALL UTIMPI('S','LE "NB_POIN" RETENU  EST :  ',1,NBPOIN)
            CALL UTFINM()
          ELSE
            PUI2  = LOG(DBLE(NBPINI))/LOG(2.D0)
            PUI2D = ABS( PUI2 - AINT( PUI2 ))
            PUI3D = ABS( 1.D0 - PUI2D )
            IF (PUI2D.GE.1.D-06 .AND. PUI3D.GE.1.D-06) THEN
              NBPOIN = 2**(INT(PUI2)+1)
              CALL UTMESS('A',NOMCMD,
     +                   '"NB_POIN" N EST PAS UNE PUISSANCE DE 2,'//
     +         'ON PREND LA PUISSANCE DE 2 SUPERIEURE')              
            ENDIF                     
          ENDIF
        ENDIF
                       
      ELSE
C 1.2.2 CAS OU ON PEUT INTERPOLER L INTERSPECTRE 

        CALL GETVR8(' ','FREQ_FIN',0,1,1,FREQF,L)
        LFREQF = L .NE. 0
C
        CALL GETVR8(' ','FREQ_INIT',0,1,1,FREQI,L)
        LFREQI = L .NE. 0

C      RECHERCHE DES FREQUENCES MIN ET MAX ET DU PAS EN FREQUENCE MIN   
C      DE L INTERSPECTRE 
        PMIN=1.D+10
        FMAX = 0.D0
        FMIN = 1.D+10
        DO 25 I = 1,NBFC
          NOMFON = ZK24(LTABL+I-1)
          CALL JELIRA(NOMFON//'.VALE','LONUTI',NBVAL3,K8B)
          NBVAL = NBVAL3/3
          CALL JEVEUO(NOMFON//'.VALE','L',LVAL1)
          DO 35 J = 1,NBVAL-1
            PAS= ABS(ZR(LVAL1+J) - ZR(LVAL1+J-1))
            IF (PAS .LT. PMIN ) PMIN = PAS
   35     CONTINUE
          FREQ = ZR(LVAL1+NBVAL-1)
          IF (FREQ .GT. FMAX ) FMAX = FREQ
          FREQ = ZR(LVAL1)
          IF (FREQ .LT. FMIN ) FMIN = FREQ          
   25   CONTINUE
        IF ( .NOT.  LFREQF)  FREQF = FMAX
        IF ( .NOT.  LFREQI)  FREQI = FMIN 

C     DETERMINATION DES PARAMETRES DE L ALGO.
        IF (DUREE .GT. 0.D0) THEN
C     LA DUREE EST UNE DONNEE
          DFREQ = 1.D0 / DUREE
          IF ( LNBPN ) THEN
            DT = DUREE/NBPOIN/2.D0
            IF (1.D0/DT . LT. 2.D0*FREQF) THEN
              NBPOIN = 2**(INT(LOG(2.D0*FREQF*DUREE)/LOG(2.D0)))        
              CALL UTDEBM('A',NOMCMD,'LA DUREE EST TROP GRANDE OU'//
     +        ' NB_POIN ET TROP PETIT PAR RAPPORT A LA FREQUENCE'//
     +        ' MAX (TH. DE SHANNON).')
             CALL UTIMPI('L','ON CHOISIT NBPOIN = ',1,NBPOIN)
             CALL UTFINM()          
            ENDIF                   
          ELSE
            NBPOIN = 2**(INT(LOG(2.D0*FREQF*DUREE)/LOG(2.D0)))        
            IF (( DFREQ. GT. 2*PMIN).AND. (PMIN.GT.0.D0) ) THEN
             CALL UTDEBM('A',NOMCMD,'LA DUREE EST PETITE PAR '//
     +        'RAPPORT AU PAS DE DISCRETISATION DE L''INTERSPECTRE.')
             CALL UTIMPR('L','CHOISIR PLUTOT : DUREE > ',1,1.D0/PMIN)
             CALL UTFINM()          
            ENDIF        
          ENDIF        
        ELSE
C     LA DUREE EST UNE INCONNUE
          IF ( LNBPN ) THEN
            PUI2  = LOG(DBLE(NBPOIN))/LOG(2.D0)
            PUI2D = ABS( PUI2 - AINT( PUI2 ))
            PUI3D = ABS( 1.D0 - PUI2D )
            IF (PUI2D.GE.1.D-06 .AND. PUI3D.GE.1.D-06) THEN
              CALL UTMESS('A',NOMCMD,
     +                   '"NB_POIN" N EST PAS UNE PUISSANCE DE 2,'//
     +         'ON PREND LA PUISSANCE DE 2 SUPERIEURE')
              NBPOIN = 2**(INT(PUI2)+1)
            ENDIF
            DFREQ = (FREQF-FREQI)/DBLE(NBPOIN-1)
            IF ((DFREQ . GT. 2*PMIN ).AND. (PMIN.GT.0.D0)) THEN
              CALL UTDEBM('A',NOMCMD,'"NB_POIN" EST PETIT PAR '//
     +        'RAPPORT AU PAS DE DISCRETISATION DE L''INTERSPECTRE.') 
              CALL UTIMPI('L','NB_POIN = ',1,NBPOIN)
              CALL UTIMPR('L','NOMBRE DE POINT INTERSPECTRE = ',1,
     +          (FREQF-FREQI)/PMIN+1)
              CALL UTFINM()          
            ENDIF           
          ELSE
            IF (PMIN.GT.0.D0) THEN
              NBPOIN = 2**(INT(LOG((FREQF-FREQI)/PMIN+1)/LOG(2.D0))+1)
              IF ( NBPOIN .LT. 256 ) NBPOIN =256
            ELSE
              NBPOIN =256 
            ENDIF
            DFREQ = (FREQF-FREQI)/DBLE(NBPOIN-1)
          ENDIF
          DUREE = 1.D0 / DFREQ
        ENDIF
        
        IF (DBLE(NBPOIN-1)*DFREQ .GT. (FREQF-FREQI)) THEN
          FRINIT = FREQF - DBLE(NBPOIN)*DFREQ
          IF (FRINIT . LT. 0.D0) FRINIT =0.D0
        ELSE
          FRINIT = FREQI
        ENDIF
      ENDIF
      
C
C===============
C 3. LECTURE DES VALEURS DES FONCTIONS ET/OU INTERPOLATION-PROLONGEMENT
C===============

      NBPT1 = NBPOIN
      NBPT2 = NBPOIN*2
      LONG  = NBFC*NBPT2 + NBPT1
      LONGH = DIM*DIM*NBPT2 + NBPT1
C
C     --- CREATION D'UN VECTEUR TEMP.VALE POUR STOCKER LES VALEURS
C           DES FONCTIONS  ---
C
      CALL WKVECT('&&GEFACT.TEMP.VALE','V V R',LONG,LVAL)

C
C     --- ON STOCKE LES FREQUENCES ET ON RECHERCHE LES INDICES AU
C         DE LA DES QUELLES LA MATRICE EST NULLE---
      LPREM = .TRUE.
      IINF = 0
      ISUP = NBPT1+1
      DO 70 K = 1,NBPT1
        FREQ = FRINIT + (K-1)*DFREQ
        ZR(LVAL+K-1) = FREQ
        IF (FREQ.LT.FREQI) IINF= K
        IF ((FREQ.GT.FREQF) .AND. LPREM) THEN
          ISUP = K
          LPREM = .FALSE.
        ENDIF            
   70 CONTINUE
      LVAL1 = LVAL + NBPT1
C
C     --- POUR CHAQUE FONCTION CALCUL DE X,Y POUR CHAQUE FREQ.
C     (ON PROLONGE PAR 0 EN DEHORS DE (FREQI,FREQF)), PUIS ON STOCKE ---
      DO 80 KF = 1,NBFC
        NOMFON = ZK24(LTABL+KF-1)
        IF (LINTER)  CALL JEVEUO(NOMFON//'.VALE','L',LVAL2)
        K8B = ' '
        DO 120 IPAS = 1,NBPT1
          FREQ = FRINIT + (IPAS-1)*DFREQ
          IX = LVAL1 + (KF-1)*NBPT2 + IPAS - 1
          IY = LVAL1 + (KF-1)*NBPT2 + IPAS - 1 + NBPT1
          IF ((IPAS.LE.IINF) .OR. (IPAS.GE.ISUP)) THEN
            ZR(IX) = 0.D0
            ZR(IY) = 0.D0
          ELSE
            IF (LINTER) THEN
              RESURE = ZR(LVAL2+NBVAL+2*(IPAS-1))
              RESUIM = ZR(LVAL2+NBVAL+2*(IPAS-1)+1)
            ELSE
              CALL FOINTC(NOMFON,0,K8B,FREQ,RESURE,RESUIM,IER)
              IF (IER.NE.0) GO TO 999              
            ENDIF
            ZR(IX) = RESURE
            ZR(IY) = RESUIM
          ENDIF

  120   CONTINUE
   80 CONTINUE
      NBVAL1 = NBPT1

C===============
C 4. FACTORISATION DES MATRICES INTERSPECTRALES (UNE PAR FREQ.)
C===============

C               1234567890123456789
      NOMINF = '&&INTESPECFACT     '
C
C     --- CREATION DE L'OBJET NOMINF//'.VALE'
      CHVALE = NOMINF//'.VALE'
      CALL WKVECT(CHVALE,'V V R',LONGH,LVALC)
C
C     --- CREATION DE L'OBJET NOMINF//'.DESC'
      CHDESC = NOMINF//'.DESC'
      CALL WKVECT(CHDESC,'V V I',3,LCHDES)
      ZI(LCHDES) = NBVAL1
      ZI(LCHDES+1) = DIM
      ZI(LCHDES+2) = DIM*DIM
C
C     --- CREATION DE L'OBJET NOMINF//'.NUOR'
      CHNUOR = NOMINF//'.NUOR'
      CALL WKVECT(CHNUOR,'V V I',DIM,LNUOR)
      CALL JEVEUO('&&GEFACT.MODE','L',INUOR)
      DO 125 I=1,DIM
        ZI(LNUOR-1+I) = ZI(INUOR-1+I)
  125 CONTINUE
C
      DIM2 = DIM*DIM
      DIM3 = DIM2 + DIM
      DIM4 = 2*DIM
      CALL WKVECT('&&GEFACT.TEMP.VALS','V V C',DIM2,LS)
      CALL WKVECT('&&GEFACT.TEMP.VALR','V V C',DIM2,LR)
      CALL WKVECT('&&GEFACT.TEMP.VALD','V V R',DIM,LD)
      CALL WKVECT('&&GEFACT.TEMP.VALU','V V C',DIM2,LU)
      CALL WKVECT('&&GEFACT.TEMP.VALV','V V R',DIM3,LV)
      CALL WKVECT('&&GEFACT.TEMP.VALW','V V C',DIM4,LW)
C
      CALL FACINT(NBVAL1,DIM,LONGH,ZR(LVAL),ZR(LVALC),LONG,ZC(LS),
     +            ZC(LR),ZR(LD),ZC(LU),ZR(LV),ZC(LW))
C
      NBPT1 = NBVAL1
      DO 130 JJ = 1,NBPT1
        ZR(LVALC+JJ-1) = ZR(LVAL+JJ-1)
  130 CONTINUE
  999 CONTINUE
C
      CALL TITRE
C
      CALL JEDETR( '&&GEFACT.MODE' )
      CALL JEDETR( NOMOBJ )
      CALL JEEXIN('&&GEFACT.FONCTION',IRET)
      IF (IRET.NE.0) CALL JEDETR('&&GEFACT.FONCTION')
      CALL JEDETR('&&GEFACT.TEMP.VALE')
      CALL JEDETR('&&GEFACT.TEMP.VALD')
      CALL JEDETR('&&GEFACT.TEMP.VALR')
      CALL JEDETR('&&GEFACT.TEMP.VALS')
      CALL JEDETR('&&GEFACT.TEMP.VALU')
      CALL JEDETR('&&GEFACT.TEMP.VALV')
      CALL JEDETR('&&GEFACT.TEMP.VALW')
      CALL JEDETR('&&GEFACT.TEMP.FONC')
      CALL JEDEMA()
      END
