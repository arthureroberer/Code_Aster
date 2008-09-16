      SUBROUTINE RECBEC(NOMRES,TYPESD,BASMOD,MODCYC,NUMSEC)
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
      IMPLICIT REAL*8 (A-H,O-Z)
C-----------------------------------------------------------------------
C MODIF ALGORITH  DATE 16/09/2008   AUTEUR PELLET J.PELLET 
C
C  BUT:  < RESTITUTION CRIAG-BAMPTON ECLATEE >
C
C   RESTITUER LES RESULTATS ISSUS D'UN CALCUL CYCLIQUE
C          AVEC DES INTERFACES DE TYPE CRAIG-BAMPTON
C     => RESULTAT COMPOSE DE TYPE MODE_MECA ALLOUE PAR LA
C   ROUTINE
C-----------------------------------------------------------------------
C
C NOMRES  /I/: NOM UT DU CONCEPT RESULTAT A REMPLIR
C TYPESD  /I/: NOM K16 DU TYPE DE LA STRUCTURE DE DONNEE
C BASMOD  /I/: NOM UT DE LA BASE MODALE EN AMONT DU CALCUL CYCLIQUE
C MODCYC  /I/: NOM UT DU RESULTAT ISSU DU CALCUL CYCLIQUE
C NUMSEC  /I/: NUMERO DU SECTEUR  SUR LEQUEL RESTITUER
C
C-------- DEBUT COMMUNS NORMALISES  JEVEUX  ----------------------------
C
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                        ZK24
      CHARACTER*32                                  ZK32
      CHARACTER*80                                            ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C----------  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CHARACTER*8   NOMRES,BASMOD,MODCYC,KBID,K8B
      CHARACTER*16  DEPL,TYPESD,TYPSUP(2)
      CHARACTER*19  CHAMVA,NUMDDL,MATRIX,MASS
      CHARACTER*24  TETGD,NOMVEC
      CHARACTER*24  VALK(3)
      COMPLEX*16    DEPHC
      REAL*8        PARA(2),DEPI,R8DEPI,FACT,GENEK,BETA
C
C-----------------------------------------------------------------------
      DATA DEPL   /'DEPL            '/
      DATA TYPSUP /'BASE_MODALE     ','MODE_MECA       '/
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
C
      DEPI = R8DEPI()
C
C----------------VERIFICATION DU TYPE DE STRUCTURE RESULTAT-------------
C
      IF(TYPESD.NE.TYPSUP(1) .AND. TYPESD.NE.TYPSUP(2))THEN
        VALK (1) = TYPESD
        VALK (2) = TYPSUP(1)
        VALK (3) = TYPSUP(2)
        CALL U2MESG('F', 'ALGORITH14_4',3,VALK,0,0,0,0.D0)
      ENDIF
C
C--------------------------RECUPERATION DU .DESC------------------------
C
      CALL JEVEUO(MODCYC//'.CYCL_DESC','L',LLDESC)
      NBMOD = ZI(LLDESC)
      NBDDR = ZI(LLDESC+1)
      NBDAX = ZI(LLDESC+2)
C
C-------------------RECUPERATION DU NOMBRE DE SECTEUR-------------------
C
      CALL JEVEUO(MODCYC//'.CYCL_NBSC','L',LLNSEC)
      NBSEC  = ZI(LLNSEC)
      MDIAPA = INT(NBSEC/2)*(1-NBSEC+(2*INT(NBSEC/2)))
C
C------------------RECUPERATION DES NOMBRES DE DIAMETRES MODAUX---------
C
      CALL JEVEUO(MODCYC//'.CYCL_DIAM','L',LLDIAM)
      CALL JELIRA(MODCYC//'.CYCL_DIAM','LONMAX',NBDIA,K8B)
      NBDIA = NBDIA / 2
C
C-----------------RECUPERATION DU NOMBRE DE DDL PHYSIQUES---------------
C
      CALL JEVEUO(BASMOD//'           .REFD','L',LLREF)
      NUMDDL = ZK24(LLREF+3)
      MATRIX = ZK24(LLREF)
      CALL DISMOI('F','NB_EQUA',NUMDDL,'NUME_DDL',NEQ,K8B,IER)
C
C-------------RECUPERATION DES FREQUENCES-------------------------------
C
      CALL JEVEUO(MODCYC//'.CYCL_FREQ','L',LLFREQ)
C
C----------------RECUPERATION MATRICE DE MASSE--------------------------
C
      MASS = ZK24(LLREF+1)
      CALL MTEXIS ( MASS, IER )
      IF(IER.EQ.0) THEN
        VALK (1) = MASS(1:8)
        CALL U2MESG('F', 'ALGORITH12_39',1,VALK,0,0,0,0.D0)
      ENDIF
      CALL MTDSCR(MASS)
      CALL JEVEUO(MASS(1:19)//'.&INT','E',LMASS)
C
C------------------ALLOCATION DES VECTEURS DE TRAVAIL-------------------
C
      CALL WKVECT('&&RECBEC.VEC.TRAVC','V V C',NEQ,LTVEZT)
      CALL WKVECT('&&RECBEC.VEC.COMP' ,'V V C',NEQ,LTVECO)
      CALL WKVECT('&&RECBEC.VEC.REEL' ,'V V R',NEQ,LTVERE)
C
C-----------------RECUPERATION DES NUMERO D'INTERFACE-------------------
C
      CALL JEVEUO(MODCYC//'.CYCL_NUIN','L',LLNUMI)
      NUMD = ZI(LLNUMI)
      NUMG = ZI(LLNUMI+1)
      NUMA = ZI(LLNUMI+2)
C
C---------------RECUPERATION DU NUMERO ORDRE DES DEFORMEES--------------
C
      NOMVEC = '&&RECBEC.ORD.DEF.DR'
      CALL WKVECT(NOMVEC,'V V I',NBDDR,LTORD)
      KBID = ' '
      CALL BMNODI(BASMOD,KBID,'       ',NUMD,NBDDR,ZI(LTORD),IBID)
      NOMVEC = '&&RECBEC.ORD.DEF.GA'
      CALL WKVECT(NOMVEC,'V V I',NBDDR,LTORG)
      KBID = ' '
      CALL BMNODI(BASMOD,KBID,'       ',NUMG,NBDDR,ZI(LTORG),IBID)
C
      IF(NBDAX.GT.0) THEN
        NOMVEC = '&&RECBEC.ORD.DEF.AX'
        CALL WKVECT(NOMVEC,'V V I',NBDAX,LTORA)
        KBID = ' '
        CALL BMNODI(BASMOD,KBID,'       ',NUMA,NBDAX,ZI(LTORA),IBID)
      ENDIF
C
C--------------------CLASSEMENT DES MODES PROPRES-----------------------
C               COMPTAGE DU NOMBRE DE MODES PHYSIQUES
C
      NBMOC = 0
      NBMOR = 0
      DO 5 IDDI=1,NBDIA
        NBTMP = ZI(LLDIAM+NBDIA+IDDI-1)
        NBMOC = NBMOC + NBTMP
        IDIA  = ZI(LLDIAM+IDDI-1)
        IF(IDIA.EQ.0 .OR. IDIA.EQ.MDIAPA) THEN
          NBMOR = NBMOR + NBTMP
        ELSE
          NBMOR = NBMOR + 2*NBTMP
        ENDIF
 5    CONTINUE
      CALL WKVECT('&&RECBEC.ORDRE.FREQ','V V I',NBMOC,LTORF )
      CALL WKVECT('&&RECBEC.ORDRE.TMPO','V V I',NBMOC,LTORTO)
      CALL ORDR8(ZR(LLFREQ),NBMOC,ZI(LTORTO))
C
      IF(TYPESD.EQ.'BASE_MODALE')THEN
        CALL JEVEUO(NOMRES//'           .UTIL','E',LDDESC)
        ZI(LDDESC+1) = NBMOR
      ENDIF
C
C-----------------ALLOCATION STRUCTURE DE DONNEES-----------------------
C
      CALL RSCRSD('G',NOMRES,TYPESD,NBMOR)
C
C-------DETERMINATION DES FUTUR NUMERO ORDRES DE MODES REELS------------
C
      NBORC = 0
      DO 6 II=1,NBMOC
        IORMO  = ZI(LTORTO+II-1)
        ICOMP  = 0
        IDICOU = 0
        DO 7 JJ=1,NBDIA
          ICOMP = ICOMP + ZI(LLDIAM+NBDIA+JJ-1)
          IF(ICOMP.GE.IORMO .AND. IDICOU.EQ.0) IDICOU = JJ
 7      CONTINUE
        NBORC = NBORC + 1
        ZI(LTORF+IORMO-1) = NBORC
        IDIAM = ZI(LLDIAM+IDICOU-1)
        IF(IDIAM.NE.0 .AND. IDIAM.NE.MDIAPA) NBORC = NBORC + 1
 6    CONTINUE
      CALL JEDETR('&&RECBEC.ORDRE.TMPO')
C
C---------------------RECUPERATION DES MODES COMPLEXES------------------
C
      CALL JEVEUO(MODCYC//'.CYCL_CMODE','L',LLMOC)
C
C--------------CALCUL DU TETA DE CHANGEMENT DE BASE GAUCHE DROITE-------
C
      TETGD = '&&RECBEC.TETGD'
      CALL WKVECT(TETGD,'V V R',NBDDR*NBDDR,LTETGD)
      CALL CTETGD(BASMOD,NUMD,NUMG,NBSEC,ZR(LTETGD),NBDDR)
C
C--------------------------RESTITUTION----------------------------------
C
      NBDDG = NBMOD + NBDDR + NBDAX
      ICOMP = 0
C
C --- BOUCLE SUR LES DIAMETRES NODAUX
C
      DO 10 IDI=1,NBDIA
C
C ----- CALCUL DU DEPHASAGE DU SECTEUR DEMANDE
C
        IDIAM  = ZI(LLDIAM+IDI-1)
        BETA   = (DEPI/NBSEC)*IDIAM
        BETSEC = (NUMSEC-1)*BETA
        AAA    = COS(BETSEC)
        BBB    = SIN(BETSEC)
        DEPHC  = DCMPLX(AAA,BBB)
C
C ----- BOUCLE SUR LES MODE DU DIAMETRE COURANT
C
        DO 15 I=1,ZI(LLDIAM+NBDIA+IDI-1)
C
          ICOMP = ICOMP + 1
          IORC  = ZI(LTORF+ICOMP-1)
C
C ------- DETERMINATION DU NUMERO DE DIAMETRE MODAL
C
          IAD = LLMOC + ((ICOMP-1)*NBDDG)
C
C ------- CALCUL MODE COMPLEXE SECTEUR DE BASE
C
          CALL RECBBN ( BASMOD,NBMOD,NBDDR,NBDAX,TETGD,ZI(LTORD),
     &                 ZI(LTORG),ZI(LTORA),ZC(IAD),ZC(LTVECO),NEQ,BETA)
C
C ------- CALCUL MASSE GENERALISEE
C
          CALL GENECY ( ZC(LTVECO),ZC(LTVECO),NEQ,LMASS,PARA,NBSEC,
     &                  BETA,BETA,ZC(LTVEZT))
C
          DO 20 J=1,NEQ
            ZC(LTVECO+J-1) = ZC(LTVECO+J-1)*DEPHC
            ZR(LTVERE+J-1) = DBLE(ZC(LTVECO+J-1))
 20       CONTINUE
C
C ------- RESTITUTION DU MODE PROPRE REEL (PARTIE RELLE)
C
          CALL RSEXCH(NOMRES,DEPL,IORC,CHAMVA,IER)
          CALL VTCREM(CHAMVA,MATRIX,'G','R')
          CALL JEVEUO(CHAMVA//'.VALE','E',LLCHAM)
C
C ------- COMMUN POUR MODE_MECA ET BASE_MODALE
C
          CALL RSADPA(NOMRES,'E',1,'FREQ'     ,IORC,0,LDFRE,K8B)
          CALL RSADPA(NOMRES,'E',1,'RIGI_GENE',IORC,0,LDKGE,K8B)
          CALL RSADPA(NOMRES,'E',1,'MASS_GENE',IORC,0,LDMGE,K8B)
          CALL RSADPA(NOMRES,'E',1,'OMEGA2'   ,IORC,0,LDOM2,K8B)
          CALL RSADPA(NOMRES,'E',1,'NUME_MODE',IORC,0,LDOMO,K8B)
C
          FACT  = 1.D0 / (PARA(1)**0.5D0)
          GENEK = (ZR(LLFREQ+ICOMP-1)*DEPI)**2
          CALL DAXPY(NEQ,FACT,ZR(LTVERE),1,ZR(LLCHAM),1)
          ZR(LDFRE) = ZR(LLFREQ+ICOMP-1)
          ZR(LDKGE) = GENEK
          ZR(LDMGE) = 1.D0
          ZR(LDOM2) = GENEK
          ZI(LDOMO) = IORC
C
C ------- SPECIFIQUE A BASE_MODALE
C
          IF(TYPESD.EQ.TYPSUP(1)) THEN
            CALL RSADPA(NOMRES,'E',1,'TYPE_DEFO',IORC,0,LDTYD,K8B)
            ZK16(LDTYD) = 'PROPRE          '
          ENDIF
C
          CALL RSNOCH(NOMRES,DEPL,IORC,' ')
C
C ------- EVENTUELLE RESTITUTION DE LA PARTIE IMAGINAIRE
C
          IF(IDIAM.NE.0 .AND. IDIAM.NE.MDIAPA) THEN
C
            DO 30 J=1,NEQ
              ZR(LTVERE+J-1) = DIMAG(ZC(LTVECO+J-1))
 30         CONTINUE
            IORC = IORC + 1
C
            CALL RSEXCH(NOMRES,DEPL,IORC,CHAMVA,IER)
            CALL VTCREM(CHAMVA,MATRIX,'G','R')
            CALL JEVEUO(CHAMVA//'.VALE','E',LLCHAM)
C
            CALL RSADPA(NOMRES,'E',1,'FREQ'     ,IORC,0,LDFRE,K8B)
            CALL RSADPA(NOMRES,'E',1,'RIGI_GENE',IORC,0,LDKGE,K8B)
            CALL RSADPA(NOMRES,'E',1,'MASS_GENE',IORC,0,LDMGE,K8B)
            CALL RSADPA(NOMRES,'E',1,'OMEGA2'   ,IORC,0,LDOM2,K8B)
            CALL RSADPA(NOMRES,'E',1,'NUME_MODE',IORC,0,LDOMO,K8B)
C
            FACT  = 1.D0 / (PARA(2)**0.5D0)
            GENEK = (ZR(LLFREQ+ICOMP-1)*DEPI)**2
            CALL DAXPY(NEQ,FACT,ZR(LTVERE),1,ZR(LLCHAM),1)
            ZR(LDFRE) = ZR(LLFREQ+ICOMP-1)
            ZR(LDKGE) = GENEK
            ZR(LDMGE) = 1.D0
            ZR(LDOM2) = GENEK
            ZI(LDOMO) = IORC
C
            IF(TYPESD.EQ.TYPSUP(1)) THEN
              CALL RSADPA(NOMRES,'E',1,'TYPE_DEFO',IORC,0,LDTYD,K8B)
              ZK16(LDTYD) = 'PROPRE          '
            ENDIF
C
            CALL RSNOCH(NOMRES,DEPL,IORC,' ')
C
          ENDIF
C
 15     CONTINUE
C
 10   CONTINUE
C
      CALL JEDETR ( '&&RECBEC.VEC.TRAVC' )
      CALL JEDETR ( '&&RECBEC.VEC.COMP'  )
      CALL JEDETR ( '&&RECBEC.VEC.REEL'  )
      CALL JEDETR ( '&&RECBEC.ORD.DEF.DR')
      CALL JEDETR ( '&&RECBEC.ORD.DEF.GA')
      CALL JEDETR ( '&&RECBEC.ORDRE.FREQ')
      CALL JEDETR ( '&&RECBEC.TETGD'     )
      IF(NBDAX.GT.0)  CALL JEDETR ( '&&RECBEC.ORD.DEF.AX' )
C
      CALL JEDEMA()
      END
