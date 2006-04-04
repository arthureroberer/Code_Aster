      SUBROUTINE ACEARP(NOMA,NOMO,LMAX,NOEMAF,NBOCC,IVR,IFM)
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER           IFM,LMAX,NOEMAF,NBOCC,IVR(*)
      CHARACTER*8       NOMA,NOMO
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 04/04/2006   AUTEUR VABHHTS J.PELLET 
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
C ----------------------------------------------------------------------
C     AFFE_CARA_ELEM
C     AFFECTATION DES CARACTERISTIQUES POUR LES ELEMENTS DISCRET
C ----------------------------------------------------------------------
C IN  : NOMA   : NOM DU MAILLAGE
C IN  : NOMO   : NOM DU MODELE
C IN  : LMAX   : NOMBRE MAX DE MAILLE OU GROUPE DE MAILLE
C IN  : NBOCC  : NOMBRE D'OCCURENCES DU MOT CLE DISCRET
C IN  : IVR    : TABLEAU DES INDICES DE VERIFICATION
C ----------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
      CHARACTER*32     JEXNUM, JEXNOM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
      PARAMETER    ( NBCAR = 100 , NBVAL = 12 , NRD = 2 )
      INTEGER      JDC(3), JDV(3),IBID,NIV
      REAL*8       VAL(NBVAL), ETA, VALE(6),RIROT(3)
      CHARACTER*1  KMA(3)
      CHARACTER*8  K8B, NOMU, CAR(NBCAR)
      CHARACTER*16 REP, REPDIS(NRD), CONCEP, CMD
      CHARACTER*19 CARTDK, CARTDM, CARTDA, CART(3), LIGMO
      CHARACTER*24 TMPNDM, TMPVDM, TMPNDA, TMPVDA, TMPNDK, TMPVDK
      CHARACTER*24 TMPDIS, MLGNNO, MLGNMA
      CHARACTER*24 MODNEM
      CHARACTER*1  K1BID
      CHARACTER*8  NOMNOE, NOGP, NOMMAI

      LOGICAL      TRANS
      DATA REPDIS  /'GLOBAL          ','LOCAL           '/
      DATA KMA     /'K','M','A'/
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL GETRES(NOMU,CONCEP,CMD)
      TMPDIS = NOMU//'.DISCRET'
      MLGNNO = NOMA//'.NOMNOE'
      MLGNMA = NOMA//'.NOMMAI'
      LIGMO  = NOMO//'.MODELE    '
      MODNEM = NOMO//'.MODELE    .NEMA'
      CALL JEEXIN(MODNEM,IXNW)
      NBMTRD = 0
      IF (IXNW.NE.0) THEN
         CALL JELIRA(MODNEM,'NMAXOC',NBMTRD,K1BID)
         CALL JEVEUO(MODNEM,'L',JDNW)
         CALL WKVECT(TMPDIS,'V V I',NBMTRD,JDDI)
      ENDIF
      CALL WKVECT('&&TMPDISCRET','V V K8',LMAX,JDLS)
      CALL WKVECT('&&TMPTABNO','V V K8',LMAX,ITBNO)
      CALL WKVECT('&&TMPRIGNO','V V R',6*LMAX,IRGNO)
      CALL WKVECT('&&TMPRIGTO','V V R',6*NOEMAF,IRGTO)
      CALL WKVECT('&&TMPAMOTO','V V R',6*NOEMAF,IAMTO)
      CALL WKVECT('&&TMPTABMP','V V K8',LMAX,ITBMP)
      IFM = IUNIFI('MESSAGE')
C
C --- RECUPERATION DE LA DIMENSION DU MAILLAGE
      NDIM = 3
C      CALL DISMOI('F','Z_CST',NOMO,'MODELE',IBID,K8B,IER)
C      IF ( K8B(1:3) .EQ. 'OUI' )  NDIM = 2

      CALL DISMOI('F','DIM_GEOM',NOMO,'MODELE',IBID,K8B,IER)
      IF (IBID.GE.1000) IBID = IBID - 1000
      IF (IBID.GE.100) THEN
         IBID = IBID - 100
         NDIM=1
      ENDIF
      IF (IBID.GE.20) THEN
         IBID = IBID - 20
         NDIM=2
      ENDIF
      IF (IBID.EQ.3) THEN
         NDIM=3
      ENDIF

C
C --- CONSTRUCTION DES CARTES ET ALLOCATION
      CARTDM = NOMU//'.CARDISCM'
      CARTDA = NOMU//'.CARDISCA'
      CARTDK = NOMU//'.CARDISCK'
      CART(1) = CARTDK
      CART(2) = CARTDM
      CART(3) = CARTDA
      TMPNDM = CARTDM//'.NCMP'
      TMPVDM = CARTDM//'.VALV'
      TMPNDA = CARTDA//'.NCMP'
      TMPVDA = CARTDA//'.VALV'
      TMPNDK = CARTDK//'.NCMP'
      TMPVDK = CARTDK//'.VALV'
      CALL JEEXIN(TMPNDM,IXCA)
      IF (IXCA.NE.0) GOTO 11
C
      CALL ALCAR2('G',CART(1),NOMA,'CADISK')
      CALL ALCAR2('G',CART(2),NOMA,'CADISM')
      CALL ALCAR2('G',CART(3),NOMA,'CADISA')
 11   CONTINUE
C
      CALL JEVEUO(TMPNDK,'E',JDC(1))
      CALL JEVEUO(TMPVDK,'E',JDV(1))
      CALL JEVEUO(TMPNDM,'E',JDC(2))
      CALL JEVEUO(TMPVDM,'E',JDV(2))
      CALL JEVEUO(TMPNDA,'E',JDC(3))
      CALL JEVEUO(TMPVDA,'E',JDV(3))

C     RECUPERATION DU NIVEAU D'IMPRESSION
C     -----------------------------------
      CALL INFNIV(IBID,NIV)
C
C
C     PAR DEFAUT ON EST DANS LE REPERE GLOBAL
      IREP = 1
      REP  = REPDIS(IREP)
C --- BOUCLE SUR LES OCCURENCES DE DISCRET
      DO 30 IOC = 1 , NBOCC
         ETA = 0.D0
         CALL GETVEM(NOMA,'GROUP_MA','RIGI_PARASOL','GROUP_MA',
     +               IOC,1,LMAX,ZK8(JDLS),NG)
         CALL GETVTX('RIGI_PARASOL','CARA'    ,IOC,1,NBCAR,CAR,NCAR)
         CALL GETVR8('RIGI_PARASOL','VALE'    ,IOC,1,NBVAL,VAL,NVAL)
         CALL GETVTX('RIGI_PARASOL','REPERE'  ,IOC,1,1,REP,NREP)
         CALL GETVID('RIGI_PARASOL','GROUP_MA_POI1',IOC,1,1,NOGP,NGP)
         IF ( NGP .EQ. 0 ) THEN
            CALL GETVID('RIGI_PARASOL','GROUP_MA_SEG2',IOC,1,1,NOGP,NGP)
         ENDIF

         IF ( NREP .NE. 0) THEN
            DO 32 I = 1 , NRD
               IF (REP.EQ.REPDIS(I)) IREP = I
 32         CONTINUE
         ENDIF

         IF (NCAR.GT.0) NCARAC = NCAR
         IF (IVR(3).EQ.1) THEN
            WRITE(IFM,1000) REP,IOC
 1000       FORMAT(/,3X,
     +            '<DISCRET> MATRICES AFFECTEES AUX ELEMENTS DISCRET ',
     +                                '(REPERE ',A6,'), OCCURENCE ',I4)
         ENDIF
C
C ---    "GROUP_MA" = TOUTES LES MAILLES DE TOUS LES GROUPES DE MAILLES
         IF (NG.LE.0) GOTO 30

         II = 0
         DO 34 NC = 1,NCARAC
            IF (NC.EQ.2.AND.CAR(1)(1:1).EQ.CAR(2)(1:1))
     +         CALL UTMESS('F','ACEARP.00',
     +         'SI 2 CARACTERISTIQUES 1 AMOR ET 1 RIGI OBLIGATOIRES')
            IF     (CAR(NC)(1:8).EQ.'K_TR_D_N') THEN
               DO 131 J = 1,6
                  VALE(J) = VAL(II+J)
131            CONTINUE
               CALL RAIREP(NOMA,IOC,CAR(NC),VALE,NG,ZK8(JDLS),NBNO,
     +               ZK8(ITBNO),ZR(IRGNO),ZR(IRGTO),ZR(IAMTO),RIROT)
               II = II + 6
            ELSEIF (CAR(NC)(1:7).EQ.'K_T_D_N') THEN
               DO 132 J = 1,3
                  VALE(J) = VAL(II+J)
132            CONTINUE
               CALL RAIREP(NOMA,IOC,CAR(NC),VALE,NG,ZK8(JDLS),NBNO,
     +               ZK8(ITBNO),ZR(IRGNO),ZR(IRGTO),ZR(IAMTO),RIROT)
               II = II + 3
            ELSEIF (CAR(NC)(1:8).EQ.'K_TR_D_L') THEN
               DO 133 J = 1,6
                  VALE(J) = VAL(II+J)
133            CONTINUE
               CALL RAIREP(NOMA,IOC,CAR(NC),VALE,NG,ZK8(JDLS),NBNO,
     +               ZK8(ITBNO),ZR(IRGNO),ZR(IRGTO),ZR(IAMTO),RIROT)
               II = II + 6
            ELSEIF (CAR(NC)(1:7).EQ.'K_T_D_L') THEN
               DO 134 J = 1,3
                  VALE(J) = VAL(II+J)
134            CONTINUE
               CALL RAIREP(NOMA,IOC,CAR(NC),VALE,NG,ZK8(JDLS),NBNO,
     +               ZK8(ITBNO),ZR(IRGNO),ZR(IRGTO),ZR(IAMTO),RIROT)
               II = II + 3

            ELSEIF (CAR(NC)(1:8).EQ.'A_TR_D_N') THEN
               DO 135 J = 1,6
                  VALE(J) = VAL(II+J)
135            CONTINUE
               CALL RAIREP(NOMA,IOC,CAR(NC),VALE,NG,ZK8(JDLS),NBNO,
     +               ZK8(ITBNO),ZR(IRGNO),ZR(IRGTO),ZR(IAMTO),RIROT)
               II = II + 6
            ELSEIF (CAR(NC)(1:7).EQ.'A_T_D_N') THEN
               DO 136 J = 1,3
                  VALE(J) = VAL(II+J)
136            CONTINUE
               CALL RAIREP(NOMA,IOC,CAR(NC),VALE,NG,ZK8(JDLS),NBNO,
     +               ZK8(ITBNO),ZR(IRGNO),ZR(IRGTO),ZR(IAMTO),RIROT)
               II = II + 3
            ELSEIF (CAR(NC)(1:8).EQ.'A_TR_D_L') THEN
               DO 137 J = 1,6
                  VALE(J) = VAL(II+J)
137            CONTINUE
               CALL RAIREP(NOMA,IOC,CAR(NC),VALE,NG,ZK8(JDLS),NBNO,
     +               ZK8(ITBNO),ZR(IRGNO),ZR(IRGTO),ZR(IAMTO),RIROT)
               II = II + 6
            ELSEIF (CAR(NC)(1:7).EQ.'A_T_D_L') THEN
               DO 138 J = 1,3
                  VALE(J) = VAL(II+J)
138            CONTINUE
               CALL RAIREP(NOMA,IOC,CAR(NC),VALE,NG,ZK8(JDLS),NBNO,
     +               ZK8(ITBNO),ZR(IRGNO),ZR(IRGTO),ZR(IAMTO),RIROT)
               II = II + 3
            ELSE
               CALL UTMESS('F','ACEARP01','CARACTERISTIQUE '//CAR(NC)//
     &                     ' NON ADMISE ACTUELLEMENT')
            ENDIF
            IF (IXNW.NE.0.AND.NGP.EQ.0) THEN
               DO 39 I = 1,NBNO
                  ITROU = 0
                  DO 100 K = 1 , NBMTRD
                     NUMNOE = ZI(JDNW+K*2-2)
                     CALL JENUNO(JEXNUM(MLGNNO,NUMNOE),NOMNOE)
                     IF (ZK8(ITBNO+I-1).EQ.NOMNOE) THEN
                        ITROU = 1
                        GOTO 101
                     ENDIF
 100              CONTINUE
 101              CONTINUE
                  IF (ITROU.EQ.0) CALL UTMESS('F','ACEARP02',
     +               'LE NOEUD '//ZK8(ITBNO+I-1)//
     &               ' NON MODELISE PAR UN DISCRET')
 39            CONTINUE
            ELSEIF (IXNW.EQ.0.AND.NGP.EQ.0) THEN
               CALL UTMESS('F','ACEARP03',
     +            'PAS DE NOEUDS DU RADIER MODELISES PAR DES DISCRETS')
            ENDIF
            IF (NGP.NE.0) THEN
               IF     (CAR(NC)(1:8).EQ.'K_TR_D_N') THEN
                  NBNOEU = 1
                  LOKM = 8
                  TRANS = .FALSE.
               ELSEIF (CAR(NC)(1:8).EQ.'A_TR_D_N') THEN
                  NBNOEU = 1
                  LOKM = 8
                  TRANS = .FALSE.
               ELSEIF (CAR(NC)(1:8).EQ.'K_TR_D_L') THEN
                  NBNOEU = 2
                  LOKM = 8
                  TRANS = .FALSE.
               ELSEIF (CAR(NC)(1:8).EQ.'A_TR_D_L') THEN
                  NBNOEU = 2
                  LOKM = 8
                  TRANS = .FALSE.
               ELSEIF (CAR(NC)(1:7).EQ.'K_T_D_N')  THEN
                  NBNOEU = 1
                  LOKM = 7
                  TRANS = .TRUE.
               ELSEIF (CAR(NC)(1:7).EQ.'A_T_D_N')  THEN
                  NBNOEU = 1
                  LOKM = 7
                  TRANS = .TRUE.
               ELSEIF (CAR(NC)(1:7).EQ.'K_T_D_L')  THEN
                  NBNOEU = 2
                  LOKM = 7
                  TRANS = .TRUE.
               ELSEIF (CAR(NC)(1:7).EQ.'A_T_D_L')  THEN
                  NBNOEU = 2
                  LOKM = 7
                  TRANS = .TRUE.
               ENDIF

               CALL JELIRA(JEXNOM(NOMA//'.GROUPEMA',NOGP),'LONMAX',
     +                     NMA,K8B)
               CALL JEVEUO(JEXNOM(NOMA//'.GROUPEMA',NOGP),'L',LDGM)
               DO 22 IN = 0,NMA-1
C                 RECUPERE LE NOMBRE DE NOEUD DE LA MAILLE
                  CALL JELIRA(JEXNUM(NOMA//'.CONNEX',ZI(LDGM+IN)),
     &                        'LONMAX',NBNMA,K8B)
                  CALL JEVEUO(JEXNUM(NOMA//'.CONNEX',ZI(LDGM+IN)),
     &                        'L',LDNM)
                  CALL JENUNO(JEXNUM(MLGNMA,ZI(LDGM+IN)),NOMMAI)
C                 BOUCLE SUR LE NB DE NOEUD DE LA MAILLE
                  IF ( NBNMA .NE. NBNOEU) THEN
                     CALL UTMESS('F','ACEARP04','LE DISCRET '//NOMMAI//
     &                  ' N A PAS LE BON NOMBRE DE NOEUDS.')
                  ENDIF
                  DO 25 INBN = 1 , NBNMA
                     INOE = ZI(LDNM+INBN-1)
                     CALL JENUNO(JEXNUM(MLGNNO,INOE),NOMNOE)
                     DO 24 INO = 1, NBNO
                        IF (ZK8(ITBNO+INO-1) .EQ. NOMNOE) THEN
                           ZK8(ITBMP+INO-1) = NOMMAI
                           GOTO 22
                        ENDIF
 24                  CONTINUE
 25               CONTINUE
C                 SI ON PASSE ICI AUCUN DES NOEUDS DU DISCRET APPARTIENT
C                 A LA SURFACE, ET CE N'EST PAS NORMAL
                  WRITE(IFM,*)'GROUP_MA :',(' '//ZK8(JDLS+II-1),II=1,NG)
                  CALL UTMESS('F','ACEARP05','LE NOEUD '//NOMNOE//
     &             ' EXTREMITE D UN DES DISCRETS'//
     &             ' N EXISTE PAS DANS LA SURFACE DONNEE PAR GROUP_MA.')
 22            CONTINUE
C              PREPARATION DES IMPRESSIONS DANS LE FICHIER RESULTAT
               IFR = IUNIFI('RESULTAT')
               IF ( IREP .EQ. 1) THEN
                  LOREP  = 6
               ELSE
                  LOREP  = 5
               ENDIF
               IF ( TRANS .AND. (NIV .EQ. 2) ) THEN
                  WRITE(IFR,1005) CAR(NC)(1:LOKM)
               ELSEIF ( NIV .EQ. 2 ) THEN
                  WRITE(IFR,1006) CAR(NC)(1:LOKM),
     &                            RIROT(1),RIROT(2),RIROT(3)
               ENDIF
               DO 28 I = 1,NBNO
                  IV = 1
                  JD = ITBMP + I - 1
                  JN = ITBNO + I - 1
                  IF ( NBNOEU .EQ. 1 ) THEN
                     IF ( TRANS .AND. (NIV .EQ. 2) ) THEN
                        WRITE(IFR,1010) 'NOEUD',ZK8(JN),
     &                        CAR(NC)(1:LOKM),
     &                       (ZR(IRGNO+6*I-6+JJ),JJ=0,2),
     &                        REPDIS(IREP)(1:LOREP)
                     ELSEIF ( NIV .EQ. 2 ) THEN
                        WRITE(IFR,1011) 'NOEUD',ZK8(JN),
     &                        CAR(NC)(1:LOKM),
     &                       (ZR(IRGNO+6*I-6+JJ),JJ=0,5),
     &                        REPDIS(IREP)(1:LOREP)
                     ENDIF
                  ELSE
                     IF ( TRANS .AND. (NIV .EQ. 2) ) THEN
                        WRITE(IFR,1010) 'MAILLE',ZK8(JD),
     &                        CAR(NC)(1:LOKM),
     &                       (ZR(IRGNO+6*I-6+JJ),JJ=0,2),
     &                        REPDIS(IREP)(1:LOREP)
                     ELSEIF ( NIV .EQ. 2 ) THEN
                        WRITE(IFR,1011) 'MAILLE',ZK8(JD),
     &                        CAR(NC)(1:LOKM),
     &                       (ZR(IRGNO+6*I-6+JJ),JJ=0,5),
     &                        REPDIS(IREP)(1:LOREP)
                     ENDIF
                  ENDIF
                  CALL AFFDIS(NDIM,IREP,ETA,CAR(NC),ZR(IRGNO+6*I-6),
     &                        JDC,JDV,IVR,IV,KMA,NCMP,L,IFM)
                  CALL NOCAR2(CART(L),3,' ','NOM',1,ZK8(JD),0,' ',NCMP)
 28            CONTINUE
            ELSE
               DO 36 I = 1,NBNO
                  IV = 1
                  JD = ITBNO + I - 1
                  CALL CRLINU('NOM', MLGNNO, 1, IBID, ZK8(JD),
     +                        NBMTRD, ZI(JDNW), ZI(JDDI), KK )
                  CALL AFFDIS(NDIM,IREP,ETA,CAR(NC),ZR(IRGNO+6*I-6),
     &                        JDC,JDV,IVR,IV,KMA,NCMP,L,IFM)
                  CALL NOCAR2(CART(L),-3,' ','NUM',KK,' ',ZI(JDDI),
     +                        LIGMO,NCMP)
 36            CONTINUE
            ENDIF
 34      CONTINUE
 30   CONTINUE
C
      IF (IXNW.NE.0) CALL JEDETR(TMPDIS)
      CALL JEDETR('&&TMPDISCRET')
      CALL JEDETR('&&TMPTABNO')
      CALL JEDETR('&&TMPRIGNO')
      CALL JEDETR('&&TMPRIGTO')
      CALL JEDETR('&&TMPAMOTO')
      CALL GETFAC('RIGI_MISS_3D',NBORM)
      IF (NBORM.EQ.0) THEN
         CALL JEDETR(TMPNDK)
         CALL JEDETR(TMPVDK)
         CALL JEDETR(TMPNDM)
         CALL JEDETR(TMPVDM)
         CALL JEDETR(TMPNDA)
         CALL JEDETR(TMPVDA)
      ENDIF
C
      CALL JEDEMA()
 1005 FORMAT(/,' PAS DE REPARTITION EN ROTATION POUR DES ',A,/)
 1006 FORMAT(/,' RAIDEURS DE ROTATION A REPARTIR POUR DES ',A,/
     +        ,'  KRX: ',1PE12.5,' KRY: ',1PE12.5,' KRZ: ',1PE12.5,/)
 1010 FORMAT(' _F(',A,'=''',A8,''', CARA=''',A,''',',/,
     +       '    VALE=(',3(1X,1PE12.5,','),'),',/,
     +       '    REPERE=''',A,'''),')

 1011 FORMAT(' _F(',A,'=''',A8,''', CARA=''',A,''',',/,
     +       '    VALE=(',3(1X,1PE12.5,','),/,
     +       '          ',3(1X,1PE12.5,','),'),',/,
     +       '    REPERE=''',A,'''),')
      END
