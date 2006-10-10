      SUBROUTINE OP0146(IER)
      IMPLICIT REAL*8 (A-H,O-Z)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 10/10/2006   AUTEUR MCOURTOI M.COURTOIS 
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
C-----------------------------------------------------------------------
C     OPERATEUR PROJ_SPEC_BASE
C     PROJECTION D UN OU PLUSIEURS SPECTRES DE TURBULENCE SUR UNE BASE
C     MODALE PERTURBEE PAR PRISE EN COMPTE DU COUPLAGE FLUIDE STRUCTURE
C-----------------------------------------------------------------------
C  OUT  : IER = 0 => TOUT S EST BIEN PASSE
C         IER > 0 => NOMBRE D ERREURS RENCONTREES
C-----------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
C
      PARAMETER   ( NBPAR = 8 , NB = 1024 )
      INTEGER       DIM, IVAL(3)
      REAL*8        R8B
      COMPLEX*16    C16B
      LOGICAL       CASINT
      CHARACTER*8   K8B, NOMU, OPTION, NOMZON, NOMPRO, TYPAR(NBPAR)
      CHARACTER*16  CONCEP, CMD, NOMMCF, NOMCFC, NOPAR(NBPAR), KVAL(2)
      CHARACTER*19  BASE, NOMFON, SPECTR, TYPFLU
      CHARACTER*24  VALI, VITE, FREQ, NUMO, PROL, VALE, VATE
      CHARACTER*24  FSVI, FSVK, BASREF, PVITE
C
      DATA NOPAR / 'NOM_CHAM' , 'OPTION' , 'DIMENSION' ,
     &             'NUME_VITE_FLUI' , 'VITE_FLUIDE' ,
     &             'NUME_ORDRE_I' , 'NUME_ORDRE_J' , 'FONCTION_C' /
      DATA TYPAR / 'K16' , 'K16' , 'I' , 'I' , 'R' , 'I' , 'I' , 'K24' /
C
C-----------------------------------------------------------------------
      CALL JEMARQ()
      CALL INFMAJ()
C
      CALL GETRES(NOMU,CONCEP,CMD)
C
      CALL GETVIS(' ','NB_POIN  ',0,1,0,IBID,NPOI)
      NPOI = ABS(NPOI)
      NFI = 1
      NFF = 1
      IF (NPOI.NE.0) THEN
        CALL GETVIS(' ','NB_POIN  ',0,1,1,NBPF,ZI)
        CALL GETVR8(' ','FREQ_INIT',0,1,1,FREQI,ZI)
        CALL GETVR8(' ','FREQ_FIN ',0,1,1,FREQF,ZI)
      ELSE
        NFI = 0
        NFF = 0
      ENDIF
C
C --- 0.VERIFICATIONS AVANT EXECUTION ---
C
      IF (NPOI.NE.0) THEN
        IF (FREQF.LT.FREQI) THEN
          CALL U2MESS('F','MODELISA5_70')
        ENDIF
        IF (FREQF.LE.0.D0 .OR. FREQI.LE.0.D0) THEN
          CALL U2MESS('F','MODELISA5_71')
        ENDIF
        PUI2 = LOG(DBLE(NBPF))/LOG(2.D0)
        PUI = AINT(PUI2)
        PUI2D = ABS(PUI2-PUI)
        PUI3D = ABS(1.D0-PUI2D)
        IF (PUI2D.GE.1.D-06 .AND. PUI3D.GE.1.D-06) THEN
          CALL U2MESS('F','MODELISA5_72')
        ENDIF
      ENDIF
C
C ----- FIN DES VERIFICATIONS AVANT EXECUTION -----
C
C
C --- 1.1.RECUPERATION DES SPECTRES ET VERIFICATIONS A L'EXECUTION ---
C ---     DE LA COMPATIBILITE DES SPECTRES SI COMBINAISON          ---
C
      CALL GETVID(' ','SPEC_TURB',0,1,0,K8B,NBSPEC)
      NBSPEC = ABS(NBSPEC)
      CALL WKVECT('&&OP0146.TEMP.NOMS','V V K8',NBSPEC,LSPEC)
      CALL GETVID(' ','SPEC_TURB',0,1,NBSPEC,ZK8(LSPEC),IBID)
C
      CALL WKVECT('&&OP0146.TEMP.INDS','V V I',NBSPEC,LINDS)
      CALL WKVECT('&&OP0146.TEMP.VMOY','V V R',NBSPEC,LVMOY)
C
      DO 10 IS = 1,NBSPEC
        SPECTR = ZK8(LSPEC+IS-1)
        VALI = SPECTR//'.VAIN'
        CALL JEVEUO(VALI,'L',IVALI)
        ZI(LINDS+IS-1) = ZI(IVALI)
  10  CONTINUE
C
      IF (NBSPEC.GT.1) THEN
        NSPELO = 0
        DO 20 IS = 1,NBSPEC
          IF (ZI(LINDS+IS-1).LT.10) NSPELO = NSPELO + 1
  20    CONTINUE
          IF (NSPELO.GT.0.AND.NSPELO.LT.NBSPEC) THEN
            CALL U2MESS('F','MODELISA5_73')
          ENDIF
      ENDIF
C
C --- 2.0 TRAITEMENT SPECIAL POUR SPEC-LONG-COR-5
C
      CALL JEVEUO(ZK8(LSPEC)//'           .VATE','L',IVATE)
      IF (ZK16(IVATE)(1:14).EQ.'SPEC_CORR_CONV') THEN
        CALL SFIFJ ( NOMU )
      ELSE
C
C --- 2.RECUPERATION DES OBJETS DE LA BASE MODALE PERTURBEE ---
C
        CALL GETVID(' ','BASE_ELAS_FLUI',0,1,1,BASE,ZI)
C
        VITE = BASE//'.VITE'
        FREQ = BASE//'.FREQ'
        NUMO = BASE//'.NUMO'
C
        CALL JEVEUO ( VITE, 'L', IVITE )
        CALL JELIRA ( VITE, 'LONUTI', NPV, K8B )
        CALL JEVEUO ( FREQ, 'L', IFREQ )
        CALL JELIRA ( FREQ, 'LONUTI', NBM, K8B )
        CALL JEVEUO ( NUMO, 'L', INUMO )
C
        NBM = NBM/(2*NPV)
C
C
C --- 2.1.RECUPERATION DES NOM DES PROFILS DE VITESSE ASSOCIES AUX ---
C ---     SPECTRES DANS LE CAS DES SPECTRES DE TYPE LONGUEUR DE    ---
C ---     TYPE LONGUEUR DE CORRELATION                             ---
C
      IF (ZI(LINDS).LT.10) THEN
        CALL WKVECT('&&OP0146.TEMP.NOZ','V V K16',NBSPEC,LNOZO)
        DO 11 IS = 1,NBSPEC
          SPECTR = ZK8(LSPEC+IS-1)
          CALL JEVEUO(SPECTR//'.VAVF','L',JVAVF)
          ZK16(LNOZO+IS-1) = ZK8(JVAVF)
  11    CONTINUE
C
C
C --- 2.2.VERIFICATION DE L EXISTENCE DES ZONES ASSOCIEES DANS LE   ---
C ---     CONCEPT TYPE_FLUI_STRU ASSOCIE, POUR LES SPECTRES DE TYPE ---
C ---     LONGUEUR DE CORRELATION                                   ---
C
         BASREF = BASE//'.REMF'
         CALL JEVEUO(BASREF,'L',LBAREF)
         TYPFLU = ZK8(LBAREF)
         FSVI = TYPFLU(1:19)//'.FSVI'
         FSVK = TYPFLU(1:19)//'.FSVK'
         CALL JEVEUO(FSVI,'L',LFSVI)
         CALL JEVEUO(FSVK,'L',LFSVK)
         NZEX = ZI(LFSVI+1)
         PVITE = ZK8(LFSVK+4)
         PVITE = PVITE(1:19)//'.VALE'
         CALL JELIRA(PVITE,'LONUTI',LNOE,K8B)
         LNOE = LNOE / 2
C
         DO 40 IS = 1,NBSPEC
            NOMZON = ZK16(LNOZO+IS-1)
            DO 30 IZ = 1,NZEX
               IF(NOMZON.EQ.ZK8(LFSVK+3+IZ)) GOTO 31
  30        CONTINUE
            CALL UTMESS('F',CMD,'LE SPECTRE DE NOM '//ZK8(LSPEC+IS-1)//
     &      ' EST ASSOCIE A LA ZONE '//NOMZON// ' QUI N EXISTE PAS'//
     &      ' DANS LE CONCEPT '// TYPFLU )
C        CALL U2MESK('F','MODELISA5_74', 3 ,VALK)
  31        CONTINUE
            CALL UTMESS('I',CMD,'LE SPECTRE DE NOM '//ZK8(LSPEC+IS-1)//
     &       ' EST ASSOCIE A LA ZONE DE NOM '// ZK8(LFSVK+IZ+3) )
C        CALL U2MESK('I','MODELISA5_75', 2 ,VALK)
  40     CONTINUE
C
C --- 2.2.ON VERIFIE QUE TOUS LES SPECTRES SONT ASSOCIES A DES ZONES ---
C ---     DIFFERENTES ET SONT DIFFERENTS                             ---
C
         DO 50 IS = 1,NBSPEC-1
           DO 60 JS = IS+1,NBSPEC
            IF(ZK8(LSPEC+IS-1).EQ.ZK8(LSPEC+JS-1)) THEN
               CALL U2MESS('F','MODELISA5_76')
            ENDIF
            NOMPRO = ZK16(LNOZO+IS-1)
            NOMZON = ZK16(LNOZO+JS-1)
            IF(NOMPRO.EQ.NOMZON) THEN
               CALL UTMESS('F',CMD,'LES SPECTRES DE NOMS '//
     &         ZK8(LSPEC+IS-1) //' ET '// ZK8(LSPEC+JS-1) //' SONT'//
     &       ' ASSOCIES AU MEME PROFIL DE VITESSE, DE NOM ' //
     &       NOMZON )
C        CALL U2MESK('F','MODELISA5_77', 3 ,VALK)
            ENDIF
  60       CONTINUE
  50     CONTINUE
C
C --- 2.3.CALCUL DES VITESSES MOYENNES DE CHAQUE ZONE D EXCITATION ---
C ---     ET DE LA VITESSE MOYENNE DE L ENSEMBLE DES ZONES         ---
C
         VMOYTO = 0.D0
         ALONTO = 0.D0
C ---    BOUCLE SUR LES ZONES D EXCITATION DU FLUIDE
         DO 160 NUZO = 1,NZEX
            PVITE = ZK8(LFSVK+3+NUZO)
            PVITE = PVITE(1:19)//'.VALE'
            CALL JEVEUO(PVITE,'L',IPV)
C ---       RECHERCHE DES EXTREMITES DE LA ZONE 'NUZO'
            DO 120 IK = 1,LNOE
               IF(ZR(IPV+LNOE+IK-1).NE.0.D0) THEN
                  N1 = IK
                  GOTO 121
               ENDIF
 120        CONTINUE
 121        CONTINUE
C
            DO 130 IK = LNOE,1,-1
               IF(ZR(IPV+LNOE+IK-1).NE.0.D0) THEN
                  N2 = IK
                  GOTO 131
               ENDIF
 130        CONTINUE
 131        CONTINUE
C
            AIRE = 0.D0
            X1 = ZR(IPV+N1-1)
            X2 = ZR(IPV+N2-1)
            DO 140 IK = N1+1,N2
              AIRE = AIRE + ( ZR(IPV+LNOE+IK-1) + ZR(IPV+LNOE+IK-2) )
     &                    * ( ZR(IPV+     IK-1) - ZR(IPV+    IK-2))/2.D0
 140       CONTINUE
C
           VMOY = AIRE / (X2-X1)
           ZR(LVMOY+NUZO-1) = VMOY
           VMOYTO = VMOYTO + AIRE
           ALONTO = ALONTO + (X2-X1)
C
C ---   FIN DE BOUCLE SUR LES ZONES D EXCITATION DU FLUIDE
 160    CONTINUE
C
        VMOYTO = VMOYTO / ALONTO
C
          ENDIF
C
C --- 3.RECUPERATION DE L'OPTION DE CALCUL
C
      CASINT = .TRUE.
      CALL GETVTX(' ','OPTION',0,1,1,OPTION,ZI)
      IF (OPTION(1:4).EQ.'DIAG') CASINT = .FALSE.
C
C --- 4.DECOUPAGE DE LA BANDE DE FREQUENCE ---
C
C        ---- RECHERCHE DE LA FREQUENCE INITIALE  ET
C                       DE LA FREQUENCE FINALE
C        ---- RECHERCHE DES NUMEROS D ORDRE DES MODES PRIS EN COMPTE
C                       EN FONCTION DE FREQ_INIT ET FREQ_FIN.
C
      CALL REBDFR(ZR(IFREQ),NFI,NFF,FREQI,FREQF,NMODI,NMODF,NBM,NPV)
C
C
      DIM = (NMODF-NMODI) + 1
C
C --- 5.CREATION DE LA TABLE D'INTERSPECTRES ---
C
C
      CALL TBCRSD ( NOMU, 'G' )
      CALL TBAJPA ( NOMU, NBPAR, NOPAR, TYPAR )
C
      KVAL(1) = 'SPEC_GENE'
      KVAL(2) = OPTION
      CALL TBAJLI ( NOMU, 3, NOPAR, DIM, R8B, C16B, KVAL, 0 )
C
C
C --- CREATION D'UN VECTEUR DE TRAVAIL POUR STOCKER LA DISCRETISATION
C --- FREQUENTIELLE
C
      IF (NPOI.EQ.0) THEN
        CALL WKVECT('&&OP0146.TEMP.PASF','V V R',DIM*NB,LPASF)
        NBPF = DIM*NB
      ELSE
        CALL WKVECT('&&OP0146.TEMP.PASF','V V R',NBPF,LPASF)
        PAS = (FREQF-FREQI)/DBLE(NBPF-1)
        DO 190 IPF = 1,NBPF
          ZR(LPASF+IPF-1) = FREQI + DBLE(IPF-1)*PAS
 190    CONTINUE
      ENDIF
      CALL WKVECT('&&OP0146.TEMP.DISC','V V R',8*DIM,IDISC)
C
C --- CREATION DE CHAQUE INTERSPECTRE
C
      DO 230 IV = 1 , NPV
C
        IVAL(1) = IV
C
        IF (NPOI.EQ.0) THEN
          CALL PASFRE(ZR(IDISC),ZR(IFREQ),ZR(LPASF),DIM,NBM,IV,NMODI,
     &                FREQI,FREQF,NB)
        ENDIF
C
        DO 220 IM2 = NMODI,NMODF
C
          IVAL(3) = ZI(INUMO+IM2-1)
C
          IDEB = IM2
          IF ( CASINT ) IDEB = NMODI
C
          DO 210 IM1 = IDEB,IM2
C
            IVAL(2) = ZI(INUMO+IM1-1)
C
            WRITE (NOMFON,'(A8,A2,3I3.3)') NOMU,'.S',IV,ZI(INUMO+IM1-1),
     &                                     ZI(INUMO+IM2-1)
C
            CALL TBAJLI ( NOMU, 5, NOPAR(4),
     &                          IVAL, ZR(IVITE+IV-1), C16B, NOMFON, 0 )
C
            VALE = NOMFON(1:19)//'.VALE'
            PROL = NOMFON(1:19)//'.PROL'
            CALL WKVECT(VALE,'G V R ',3*NBPF,LVALE)
            CALL WKVECT(PROL,'G V K16',5,LPROL)
C
            ZK16(LPROL  ) = 'FONCT_C '
            ZK16(LPROL+1) = 'LIN LIN '
            ZK16(LPROL+2) = 'FREQ    '
            ZK16(LPROL+3) = 'DSP     '
            ZK16(LPROL+4) = 'LL      '
C
            DO 200 IPF = 1,NBPF
              ZR(LVALE+IPF-1) = ZR(LPASF+IPF-1)
 200        CONTINUE
C
 210      CONTINUE
 220    CONTINUE
 230  CONTINUE
C
C
C --- 6.CALCUL DES INTERSPECTRES D'EXCITATIONS MODALES
C ---   BOUCLE SUR LE NOMBRE DE SPECTRES
C
      DO 240 IS = 1,NBSPEC
        ISPECT = ZI(LINDS+IS-1)
        SPECTR = ZK8(LSPEC+IS-1)
        IF (ISPECT.LT.10) THEN
          NOMZON = ZK16(LNOZO+IS-1)
          CALL SPECT1(CASINT,NOMU,SPECTR,ISPECT,BASE,ZR(IVITE),
     &                ZI(INUMO),NMODI,NMODF,NBM,NBPF,NPV,
     &                NOMZON,ZR(LVMOY+IS-1),VMOYTO)
        ELSE IF (ISPECT.EQ.11) THEN
          CALL SPECFF(CASINT,NOMU,SPECTR,BASE,ZI(INUMO),NMODI,NMODF,
     &                NBM,NBPF,NPV)
        ELSE
          CALL SPECEP(CASINT,NOMU,SPECTR,BASE,ZR(IVITE),ZI(INUMO),
     &                NMODI,NMODF,NBM,NBPF,NPV)
        ENDIF
 240  CONTINUE
C FINSI ALTERNATIVE SPEC-LONG-COR-5
        ENDIF
C
      CALL TITRE
C
      CALL JEDEMA()
      END
