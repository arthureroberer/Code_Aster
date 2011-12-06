      SUBROUTINE MECALR(NEWCAL,TYSD,KNUM,KCHA,RESUCO,RESUC1,
     &                  NBORDR,MODELE,MATE,CARA,NCHAR,CTYP)
      IMPLICIT NONE
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 15/11/2011   AUTEUR DELMAS J.DELMAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE DELMAS J.DELMAS
C TOLE CRP_20
C ----------------------------------------------------------------------
C COMMANDE DE CALC_ELEM SPECIFIQUE A LA MECANIQUE
C ----------------------------------------------------------------------
C IN  NEWCAL : TRUE POUR UN NOUVEAU CONCEPT RESULTAT, FALSE SINON
C IN  TYSD   : TYPE DU CONCEPT ATTACHE A RESUCO
C IN  KNUM   : NOM D'OBJET DES NUMEROS D'ORDRE
C IN  KCHA   : NOM JEVEUX OU SONT STOCKEES LES CHARGES
C IN  RESUCO : NOM DE CONCEPT RESULTAT
C IN  RESUC1 : NOM DE CONCEPT DE LA COMMANDE CALC_ELEM
C IN  CONCEP : TYPE DU CONCEPT ATTACHE A RESUC1
C IN  NBORDR : NOMBRE DE NUMEROS D'ORDRE
C IN  MODELE : NOM DU MODELE
C IN  MATE   : NOM DU CHAMP MATERIAU
C IN  CARA   : NOM DU CHAMP DES CARACTERISTIQUES ELEMENTAIRES
C IN  NCHAR  : NOMBRE DE CHARGES
C IN  CTYP   : TYPE DE CHARGE
C ----------------------------------------------------------------------
C
C     --- ARGUMENTS ---

      INTEGER NBORDR,NCHAR
      CHARACTER*4 CTYP
      CHARACTER*8 RESUCO,RESUC1,MODELE,CARA
      CHARACTER*16 TYSD
      CHARACTER*19 KNUM,KCHA
      CHARACTER*24 MATE
      LOGICAL NEWCAL
C
C     ----- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER        ZI
      COMMON /IVARJE/ZI(1)
      REAL*8         ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16     ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL        ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8    ZK8
      CHARACTER*16          ZK16
      CHARACTER*24                  ZK24
      CHARACTER*32                          ZK32,JEXNOM
      CHARACTER*80                                  ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     ----- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
C     --- VARIABLES LOCALES ---

      CHARACTER*6 NOMPRO
      PARAMETER(NOMPRO='MECALR')

      INTEGER IFM,NIV
      INTEGER NUORD
      INTEGER IORDR,JORDR
      INTEGER IRET,IRET1,IRET2,IRET3,IRET4,IRET5,IERD,IRETER
      INTEGER NH,NBOPT,NBCHRE
      INTEGER IADOU,IADIN
      INTEGER IAUX,IB,J,IBID,IE
      INTEGER IOCC,IOPT
      INTEGER N1,N2
      INTEGER JPA,JOPT,JCHA
      INTEGER NBAC,NBPA,NBPARA
      INTEGER JDIM,JCOOR,JTYPE,LTYMO,NPASS
      INTEGER NNOEM,NELEM,NDIM,NNCP

      CHARACTER*4 TYPE
      CHARACTER*8 K8B,NOMA
      CHARACTER*8 CARELE
      CHARACTER*19 PFCHNO
      CHARACTER*16 NOMCMD,OPTION,TYPES,K16B
      CHARACTER*19 LERES1
      CHARACTER*19 CHERRS,CHENES,CHSINS,CHSINN
      CHARACTER*24 CHENEG,CHSING,CHERR1,CHERR2,CHERR3,CHERR4
      CHARACTER*24 CHAMGD,CHSIG,CHSIGN
      CHARACTER*24 CHGEOM,CHCARA(18)
      CHARACTER*24 CHHARM,CHELEM,SOP
      CHARACTER*24 LIGREL
      CHARACTER*24 NOMPAR
      CHARACTER*24 LESOPT
      CHARACTER*24 LIGRMO
      CHARACTER*24 BLAN24
      CHARACTER*19 CHVARC

      REAL*8 PREC
      REAL*8 TBGRCA(3)


      LOGICAL EXICAR

      CHARACTER*24 VALKM(2)
      INTEGER      IARG


      CALL JEMARQ()
      CALL GETRES(K8B,K16B,NOMCMD)
      CALL JERECU('V')
C               123456789012345678901234
      BLAN24 = '                        '
      LESOPT='&&'//NOMPRO//'.LES_OPTION'
      NH=0
      CHAMGD=BLAN24
      CHGEOM=BLAN24
      CHHARM=BLAN24
      CHSIG=BLAN24
      CHELEM=BLAN24
      SOP=BLAN24
      CHVARC='&&'//NOMPRO//'.CHVARC'

C     COMPTEUR DE PASSAGES DANS LA COMMANDE (POUR MEDOM2.F)
      NPASS=0

      CALL INFMAJ()
      CALL INFNIV(IFM,NIV)
      CARELE=' '
      CALL GETVID(' ','CARA_ELEM',1,IARG,1,CARELE,N1)

      CALL GETVTX ( ' ', 'OPTION', 1,IARG,0, K8B, N2 )
      NBOPT = -N2
      CALL WKVECT ( LESOPT, 'V V K16', NBOPT, JOPT )
      CALL GETVTX (' ', 'OPTION'  , 1,IARG, NBOPT, ZK16(JOPT), N2)
      CALL MODOPT(RESUCO,LESOPT,NBOPT)
      CALL JEVEUO(LESOPT,'L',JOPT)

C     ON RECUPERE LE TYPE DE MODE: DYNAMIQUE OU STATIQUE
      IF (TYSD.EQ.'MODE_MECA') THEN
        CALL RSADPA(RESUCO,'L',1,'TYPE_MODE',1,0,LTYMO,K8B)
      ENDIF

      CALL JEVEUO(KNUM,'L',JORDR)
      NUORD=ZI(JORDR)
      CALL JEVEUO(KCHA,'L',JCHA)
      IF (NEWCAL) THEN
        CALL RSCRSD('G',RESUC1,TYSD,NBORDR)
        CALL TITRE
      ENDIF
      CALL DISMOI('F','NOM_LIGREL',MODELE,'MODELE',IBID,LIGRMO,IERD)
      CALL JENONU(JEXNOM(RESUCO//'           .NOVA','INST'),IRET)
      CALL EXLIMA(' ',0,'V',MODELE,LIGREL)

      CALL DISMOI('F','NOM_MAILLA',MODELE,'MODELE',IBID,NOMA,IERD)
C
C -- GRANDEURS CARACTERISTIQUES DE L'ETUDE
C
      CALL CETULE(MODELE,TBGRCA,IRET)
C=======================================================================


      LERES1=RESUC1

C    ------------------------------------------------------------------
C    -- RECOPIE DES PARAMETRES DANS LA NOUVELLE SD RESULTAT
C    ------------------------------------------------------------------

      IF (NEWCAL) THEN
        NOMPAR='&&'//NOMPRO//'.NOMS_PARA '
        CALL RSNOPA(RESUCO,2,NOMPAR,NBAC,NBPA)
        NBPARA=NBAC+NBPA
        CALL JEVEUO(NOMPAR,'L',JPA)
        DO 30,IAUX=1,NBORDR
          IORDR=ZI(JORDR+IAUX-1)
          DO 20 J=1,NBPARA
            CALL RSADPA(RESUCO,'L',1,ZK16(JPA+J-1),IORDR,1,IADIN,TYPE)
            CALL RSADPA(LERES1,'E',1,ZK16(JPA+J-1),IORDR,1,IADOU,TYPE)
            IF (TYPE(1:1).EQ.'I') THEN
              ZI(IADOU)=ZI(IADIN)
            ELSEIF (TYPE(1:1).EQ.'R') THEN
              ZR(IADOU)=ZR(IADIN)
            ELSEIF (TYPE(1:1).EQ.'C') THEN
              ZC(IADOU)=ZC(IADIN)
            ELSEIF (TYPE(1:3).EQ.'K80') THEN
              ZK80(IADOU)=ZK80(IADIN)
            ELSEIF (TYPE(1:3).EQ.'K32') THEN
              ZK32(IADOU)=ZK32(IADIN)
            ELSEIF (TYPE(1:3).EQ.'K24') THEN
              ZK24(IADOU)=ZK24(IADIN)
            ELSEIF (TYPE(1:3).EQ.'K16') THEN
              ZK16(IADOU)=ZK16(IADIN)
            ELSEIF (TYPE(1:2).EQ.'K8') THEN
              ZK8(IADOU)=ZK8(IADIN)
            ENDIF
   20     CONTINUE
   30   CONTINUE
      ENDIF

C    ------------------------------------------------------------------
C    -- FIN RECOPIE DES PARAMETRES DANS LA NOUVELLE SD RESULTAT
C    ------------------------------------------------------------------



C============ DEBUT DE LA BOUCLE SUR LES OPTIONS A CALCULER ============
      DO 660 IOPT=1,NBOPT
C
        OPTION=ZK16(JOPT+IOPT-1)
C
        CALL JEVEUO(KNUM,'L',JORDR)

C         PASSAGE CALC_CHAMP
        CALL CALCOP(OPTION,LESOPT,RESUCO,RESUC1,KNUM,NBORDR,
     &              KCHA,NCHAR,CTYP,TYSD,NBCHRE,IOCC,SOP,
     &              IRET)
        IF (IRET.EQ.0)GOTO 660

        NUORD=ZI(JORDR)
        CALL MEDOM2(MODELE,MATE,CARA,KCHA,NCHAR,CTYP,RESUCO,NUORD,
     &              NBORDR,'G',NPASS,LIGREL)
        CALL JEVEUO(KCHA,'L',JCHA)
C
        CALL MECHAM(OPTION,MODELE,NCHAR,ZK8(JCHA),CARA,NH,CHGEOM,CHCARA,
     &              CHHARM,IRET)
        IF (IRET.NE.0)GOTO 690

C    ------------------------------------------------------------------
C    -- OPTIONS "SIZ1_NOEU","SIZ2_NOEU"
C    ------------------------------------------------------------------
        IF (OPTION.EQ.'SIZ1_NOEU' .OR.
     &      OPTION.EQ.'SIZ2_NOEU') THEN


          DO 160,IAUX=1,NBORDR
            CALL JEMARQ()
            CALL JERECU('V')
            IORDR=ZI(JORDR+IAUX-1)
            CALL MEDOM2(MODELE,MATE,CARA,KCHA,NCHAR,CTYP,RESUCO,IORDR,
     &                  NBORDR,'G',NPASS,LIGREL)
            CALL JEVEUO(KCHA,'L',JCHA)
            CALL MECARA(CARA,EXICAR,CHCARA)
            CALL RSEXC2(1,1,RESUCO,'DEPL',IORDR,CHAMGD,OPTION,IRET)
            IF (IRET.GT.0)GOTO 150
            CALL RSEXC2(1,1,RESUCO,'SIEF_ELGA',IORDR,CHSIG,OPTION,IRET)
            IF (IRET.GT.0) THEN
              CALL U2MESK('A','CALCULEL3_7',1,OPTION)
              CALL JEDEMA
              GOTO 660

            ENDIF
            CALL RSEXC1(LERES1,OPTION,IORDR,CHSIGN)
            IF (OPTION.EQ.'SIZ1_NOEU') THEN
              CALL SINOZ1(MODELE,CHSIG,CHSIGN)
            ELSEIF (OPTION.EQ.'SIZ2_NOEU') THEN
              CALL DISMOI('F','PROF_CHNO',CHAMGD,'CHAM_NO',IB,PFCHNO,IE)
              CALL SINOZ2(MODELE,PFCHNO,CHSIG,CHSIGN)
            ENDIF
            CALL RSNOCH(LERES1,OPTION,IORDR,' ')
  150       CONTINUE
            CALL JEDEMA()
  160     CONTINUE

C    ------------------------------------------------------------------
C    -- OPTIONS DES INDICATEURS D'ERREURS
C    ------------------------------------------------------------------
        ELSEIF (OPTION.EQ.'ERZ1_ELEM' .OR.
     &          OPTION.EQ.'ERZ2_ELEM' .OR.
     &          OPTION.EQ.'ERME_ELEM' .OR. OPTION.EQ.'ERME_ELNO' .OR.
     &          OPTION.EQ.'QIRE_ELEM' .OR.
     &          OPTION.EQ.'QIRE_ELNO' .OR.
     &          OPTION.EQ.'QIZ1_ELEM' .OR.
     &          OPTION.EQ.'QIZ2_ELEM') THEN
C
          CALL MECA01(OPTION,NBORDR,JORDR,NCHAR,JCHA,KCHA,CTYP,TBGRCA,
     &                RESUCO,RESUC1,LERES1,NOMA,MODELE,LIGRMO,MATE,CARA,
     &                CHVARC,0,NPASS,IRET)
C
          IF (IRET.EQ.1) THEN
            GOTO 650

          ELSEIF (IRET.EQ.2) THEN
            GOTO 690

          ELSEIF (IRET.EQ.3) THEN
            GOTO 660

          ENDIF
C
C    ------------------------------------------------------------------
C    -- OPTION "SING_ELEM"
C    ------------------------------------------------------------------
        ELSEIF (OPTION.EQ.'SING_ELEM') THEN

          CALL GETVR8(' ','PREC_ERR',1,IARG,1,PREC,IRET1)
          IF (IRET1.NE.1) THEN
            CALL U2MESS('F','CALCULEL3_12')
          ELSE
            IF (PREC.LE.0.D0) THEN
              CALL U2MESS('F','CALCULEL3_13')
            ENDIF
          ENDIF

          TYPES=' '
          CALL GETVTX(' ','TYPE_ESTI',1,IARG,1,TYPES,IRETER)
          IF (IRETER.GT.0) THEN
            CALL U2MESK('I','CALCULEL3_24',1,TYPES)
          ENDIF

C 1 - RECUPERATION DE :
C  NNOEM : NOMBRE DE NOEUDS
C  NELEM : NOMBRE D ELEMENTS FINIS (EF)
C  NDIM  : DIMENSION
C  JCOOR : ADRESSE DES COORDONNEES
C  JTYPE : ADRESSE DU TYPE D ELEMENTS FINIS

          CALL DISMOI('F','NOM_MAILLA',MODELE,'MODELE',IBID,NOMA,IERD)

          CALL JEVEUO(NOMA//'.DIME','L',JDIM)
          CALL JEVEUO(NOMA//'.COORDO    .VALE','L',JCOOR)
          CALL JEVEUO(NOMA//'.TYPMAIL','L',JTYPE)

          NNOEM=ZI(JDIM)
          NELEM=ZI(JDIM+2)
          NDIM=ZI(JDIM+5)

C 2 - CREATION D OBJETS TEMPORAIRES UTILES POUR LA SUITE
C '&&SINGUM.DIME' (DIM=3) CONTIENT
C   NBRE MAX DE NOEUDS SOMMETS CONNECTES AUX EF (NSOMMX)
C   NBRE MAX D EF CONNECTES AUX NOEUDS (NELCOM)
C   DEGRE DES EF (1 SI LINEAIRE ET 2 SI QUADRATIQUE)
C '&&SINGUM.MESU' (DIM=NELEM) CONTIENT L AIRE OU LE VOLUME DES EFS
C '&&SINGUM.CONN' (DIM=NELEM*(NSOMMX+2)) CONTIENT
C   1ERE VALEUR = NBRE DE NOEUDS SOMMETS CONNECTES A L EF N�X
C   2EME VALEUR = 1 SI EF EST SURFACIQUE EN 2D ET VOLUMIQUE EN 3D
C                 0 SINON
C   CONNECTIVITE EF N�X=>N� DES NOEUDS SOMMETS CONNECTES A X
C '&&SINGUM.CINV' (DIM=NNOEM*(NELCOM+2)) CONTIENT
C   1ERE VALEUR = NBRE D EF CONNECTES AU NOEUD N�X
C   2EME VALEUR = 0 NOEUD MILIEU OU NON CONNECTE A UN EF UTILE
C                 1 NOEUD SOMMET A L INTERIEUR + LIE A UN EF UTILE
C                 2 NOEUD SOMMET BORD + LIE A UN EF UTILE
C                 EF UTILE = EF SURF EN 2D ET VOL EN 3D
C   CONNECTIVITE INVERSE NOEUD N�X=>N� DES EF CONNECTES A X

          CALL SINGUM(NOMA,NDIM,NNOEM,NELEM,ZI(JTYPE),ZR(JCOOR))

C 3 - BOUCLE SUR LES INSTANTS DEMANDES

          DO 260 IAUX=1,NBORDR
            CALL JEMARQ()
            IORDR=ZI(JORDR+IAUX-1)

            IF (IRETER.GT.0) THEN
              CALL RSEXCH(RESUCO,TYPES,IORDR,CHERR4,IRET5)

              IF (IRET5.GT.0) THEN
                VALKM(1)=TYPES
                VALKM(2)=RESUCO
                CALL U2MESK('A','CALCULEL3_26',2,VALKM)
                IRET=1
              ENDIF

C 3.1 - RECUPERATION DE LA CARTE D ERREUR ET D ENERGIE
C       SI PLUSIEURS INDICATEURS ON PREND PAR DEFAUT
C       ERME_ELEM SI IL EST PRESENT
C       ERZ2_ELEM PAR RAPPORT A ERZ1_ELEM

            ELSE

              IRET5=1
              CALL RSEXCH(RESUCO,'ERME_ELEM',IORDR,CHERR1,IRET1)
              CALL RSEXCH(RESUCO,'ERZ1_ELEM',IORDR,CHERR2,IRET2)
              CALL RSEXCH(RESUCO,'ERZ2_ELEM',IORDR,CHERR3,IRET3)

              IF (IRET1.GT.0 .AND. IRET2.GT.0 .AND. IRET3.GT.0) THEN
                CALL U2MESS('A','CALCULEL3_14')
                IRET=1
              ENDIF

            ENDIF

            IF (TYSD.EQ.'EVOL_NOLI') THEN
              CALL RSEXCH(RESUCO,'ETOT_ELEM',IORDR,CHENEG,IRET4)
            ELSE
              CALL RSEXCH(RESUCO,'EPOT_ELEM',IORDR,CHENEG,IRET4)
            ENDIF
            IF (IRET4.GT.0) THEN
              CALL U2MESS('A','CALCULEL3_29')
            ENDIF

            IF ((IRET+IRET4).GT.0) THEN
              CALL U2MESS('A','CALCULEL3_36')
              GOTO 250

            ENDIF
C 3.2 - TRANSFORMATION DE CES DEUX CARTES EN CHAM_ELEM_S

            CHERRS='&&'//NOMPRO//'.ERRE'

            IF (IRET5.EQ.0) THEN
              CALL CELCES(CHERR4(1:19),'V',CHERRS)
            ELSEIF (IRET1.EQ.0) THEN
              CALL CELCES(CHERR1(1:19),'V',CHERRS)
              IF ((IRET2.EQ.0) .OR. (IRET3.EQ.0)) THEN
                CALL U2MESS('A','CALCULEL3_15')
              ENDIF
            ELSEIF (IRET3.EQ.0) THEN
              CALL CELCES(CHERR3(1:19),'V',CHERRS)
              IF (IRET2.EQ.0) CALL U2MESS('A','CALCULEL3_16')
            ELSEIF (IRET2.EQ.0) THEN
              CALL CELCES(CHERR2(1:19),'V',CHERRS)
            ELSE
              CALL ASSERT(.FALSE.)
            ENDIF

            CHENES='&&'//NOMPRO//'.ENER'
            CALL CELCES(CHENEG(1:19),'V',CHENES)

C 3.3 - ROUTINE PRINCIPALE QUI CALCULE DANS CHAQUE EF :
C       * LE DEGRE DE LA SINGULARITE
C       * LE RAPPORT ENTRE L ANCIENNE ET LA NOUVELLE TAILLE
C       DE L EF CONSIDERE
C       => CE RESULAT EST STOCKE DANS CHELEM (CHAM_ELEM)
C       CES DEUX COMPOSANTES SONT CONSTANTES PAR ELEMENT

            CALL RSEXC1(LERES1,OPTION,IORDR,CHELEM)

            CALL SINGUE(CHERRS,CHENES,NOMA,NDIM,NNOEM,NELEM,ZR(JCOOR),
     &                  PREC,LIGRMO,IORDR,CHELEM,TYPES)

            CALL RSNOCH(LERES1,OPTION,IORDR,' ')

C 3.4 - DESTRUCTION DES CHAM_ELEM_S

            CALL DETRSD('CHAM_ELEM_S',CHERRS)
            CALL DETRSD('CHAM_ELEM_S',CHENES)

  250       CONTINUE
            CALL JEDEMA()
  260     CONTINUE

C 4 - DESTRUCTION DES OBJETS TEMPORAIRES

          CALL JEDETR('&&SINGUM.DIME           ')
          CALL JEDETR('&&SINGUM.MESU           ')
          CALL JEDETR('&&SINGUM.CONN           ')
          CALL JEDETR('&&SINGUM.CINV           ')
C    ------------------------------------------------------------------
C    -- OPTION "SING_ELNO"
C    ------------------------------------------------------------------
        ELSEIF (OPTION.EQ.'SING_ELNO') THEN
          DO 280 IAUX=1,NBORDR
            CALL JEMARQ()
            IORDR=ZI(JORDR+IAUX-1)

C 1 - RECUPERATION DE LA CARTE DE SINGULARITE

            CALL RSEXC2(1,1,RESUCO,'SING_ELEM',IORDR,CHSING,OPTION,
     &                  IRET1)

            IF (IRET1.GT.0)GOTO 270

C 2 - TRANSFORMATION DE CE CHAMP EN CHAM_ELEM_S

            CHSINS='&&'//NOMPRO//'.SING'
            CALL CELCES(CHSING(1:19),'V',CHSINS)

C 3 - TRANSFOMATION DU CHAMP CHSINS ELEM EN ELNO

            CHSINN='&&'//NOMPRO//'.SINN'
            CALL CESCES(CHSINS,'ELNO',' ',' ',' ','V',CHSINN)

C 4 - STOCKAGE

            CALL RSEXC1(LERES1,OPTION,IORDR,CHELEM)

            CALL CESCEL(CHSINN,LIGRMO(1:19),'SING_ELNO','PSINGNO',
     &                  'NON',NNCP,'G',CHELEM(1:19),'F',IBID)

            CALL RSNOCH(LERES1,OPTION,IORDR,' ')

C 5 - DESTRUCTION DES CHAM_ELEM_S

            CALL DETRSD('CHAM_ELEM_S',CHSINS)
            CALL DETRSD('CHAM_ELEM_S',CHSINN)

  270       CONTINUE
            CALL JEDEMA()
  280     CONTINUE

C      -----------------------------------------------------------------

        ELSE
          CALL U2MESK('A','CALCULEL3_22',1,OPTION)
        ENDIF

  650   CONTINUE
  660 CONTINUE
C
C============= FIN DE LA BOUCLE SUR LES OPTIONS A CALCULER =============
C
  690 CONTINUE
      CALL JEDEMA()
      END
