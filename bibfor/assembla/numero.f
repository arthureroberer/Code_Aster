      SUBROUTINE NUMERO(NUPOSS,MODELZ,INFCHZ,SOLVEU,BASE,NU)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ASSEMBLA  DATE 20/06/2005   AUTEUR BOITEAU O.BOITEAU 
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
C ----------------------------------------------------------------------
C IN  K14  NUPOSS  : NOM D'UN NUME_DDL CANDIDAT (OU ' ')
C                    SI NUPOSS != ' ', ON  REGARDE SI LE PROF_CHNO
C                    DE NUPOSS EST CONVENABLE.
C                    (POUR EVITER DE CREER SYTEMATIQUEMENT 1 PROF_CHNO)
C IN  K8   MODELE  : NOM DU MODELE
C IN  K19  INFCHA  : NOM DE L'OBJET DE TYPE INFCHA
C IN  K19  SOLVEU  : NOM DE L'OBJET DE TYPE SOLVEUR
C IN  K2   BASE    : BASE(1:1) : BASE POUR CREER LE NUME_DDL
C                    (SAUF LE NUME_EQUA)
C                  : BASE(2:2) : BASE POUR CREER LE NUME_EQUA
C VAR/JXOUT K14 NU : NOM DU NUME_DDL.
C                    SI NUPOSS !=' ', NU PEUT ETRE MODIFIE (NU=NUPOSS)
C----------------------------------------------------------------------
C RESPONSABLE VABHHTS J.PELLET
C CORPS DU PROGRAMME
      IMPLICIT NONE

C DECLARATION PARAMETRES D'APPELS
      CHARACTER*(*) MODELZ,SOLVEU,INFCHZ
      CHARACTER*(*) NU,NUPOSS
      CHARACTER*2 BASE

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------

C DECLARATION VARIABLES LOCALES
      INTEGER      NCHAR,NBLIG,IRET,JCHAR,JLLIGR,K,JTYPCH,ISLVK,IDIME,
     &             I,ILIMA,NBMA,NBSD,IFM,NIV,IBID,ISOLFS,IREFE,
     &             IFETN,NEQUA,NBPB,NCHARF,L,NBCHA,IVLIGR,INUEQ,J,
     &             COMPT,NBNO4,IPRNO,JNSLV,LDEEQG,IINF,NBCHA1,IFCPU,
     &             NBPROC,RANG,ILIMPI,NIVMPI
      REAL*8       TEMPS(6),RBID
      CHARACTER*1  K1
      CHARACTER*3  VERIF
      CHARACTER*8  MOLOC,NOMCHA,K8BID,METHOD,NOMSD,MODELE
      CHARACTER*14 NUPOSB,NOMFE2
      CHARACTER*16 PHENO
      CHARACTER*19 INFCHA,LIGRSD
      CHARACTER*24 LCHARG,LLIGR,NOMLIG,SDFETI,NOMSDA,K24B,
     &             KSOLVF,LLIGRS,INFOFE,NOOBJ
      CHARACTER*32 JEXNUM,JEXNOM
      LOGICAL      LFETI,LOBID,LOMPI

C RECUPERATION ET MAJ DU NIVEAU D'IMPRESSION
      CALL INFNIV(IFM,NIV)

C-----------------------------------------------------------------------
C CONSTRUCTION D'UN OBJET JEVEUX CONTENANT LA LISTE DES CHARGES ET
C LE NOM DU MODELE DE CALCUL
C-----------------------------------------------------------------------
      CALL JEMARQ()
      INFCHA = INFCHZ
      MODELE = MODELZ
      LCHARG = INFCHA//'.LCHA'
      NCHAR = 0
      CALL JEEXIN(LCHARG,IRET)
      IF (IRET.NE.0) THEN
        CALL JELIRA(LCHARG,'LONMAX',NCHAR,K8BID)
        CALL JEVEUO(LCHARG,'L',JCHAR)
      ENDIF
      LLIGR = '&&NUMERO.LISTE_LIGREL'
      CALL WKVECT(LLIGR,'V V K24',NCHAR+1,JLLIGR)
      NBLIG = 0
      CALL JEEXIN(MODELE//'.MODELE    .NBNO',IRET)
      IF (IRET.GT.0) THEN
        ZK24(JLLIGR) = MODELE(1:8)//'.MODELE'
        NBLIG = NBLIG + 1
      ENDIF
      DO 10 K = 1,NCHAR
        NOMCHA = ZK24(JCHAR+K-1)
        CALL JEVEUO(NOMCHA(1:8)//'.TYPE','L',JTYPCH)
        NOMLIG = NOMCHA(1:8)//'.CH'//ZK8(JTYPCH) (1:2)//'.LIGRE.LIEL'
        CALL JEEXIN(NOMLIG,IRET)
        IF (IRET.GT.0) THEN
          ZK24(JLLIGR+NBLIG) = NOMLIG(1:19)
          NBLIG = NBLIG + 1
        ENDIF
   10 CONTINUE
      CALL JEECRA(LLIGR,'LONUTI',NBLIG,K8BID)

C SOLVEUR FETI ?
      CALL JEVEUO(SOLVEU(1:19)//'.SLVK','L',ISLVK)
      METHOD=ZK24(ISLVK)
      IF (METHOD(1:4).EQ.'FETI') THEN
        LFETI=.TRUE.
        NUPOSB=' '
      ELSE
        LFETI=.FALSE.
        INFOFE='FFFFFFFFFFFFFFFFFFFFFFFF'
      ENDIF

C CALCUL TEMPS
      IF ((NIV.GE.2).OR.(LFETI)) THEN
        CALL UTTCPU(50,'INIT ',6,TEMPS)
        CALL UTTCPU(50,'DEBUT',6,TEMPS)
      ENDIF
C --------------------------------------------------------------
C CREATION ET REMPLISSAGE DE LA SD NUME_DDL "MAITRE"
C --------------------------------------------------------------

      CALL NUMER2(NUPOSS,NBLIG,ZK24(JLLIGR),' ',SOLVEU,BASE,NU,NEQUA)

      IF ((NIV.GE.2).OR.(LFETI)) THEN
        CALL UTTCPU(50,'FIN  ',6,TEMPS)
        WRITE(IFM,*)'TEMPS CPU/SYS FACT SYMB: ',TEMPS(5),
     &   TEMPS(6)
        IF (LFETI) THEN
          CALL JEVEUO('&FETI.INFO.CPU.FACS','E',IFCPU)
          ZR(IFCPU)=TEMPS(5)+TEMPS(6)
        ENDIF
      ENDIF
C-----------------------------------------------------------------------
C-----------------------------------------------------------------------
      IF (LFETI) THEN

C STRUCTURE DE DONNEES DE TYPE SD_FETI
        SDFETI=' '
        SDFETI(1:8)=ZK24(ISLVK+5)
        VERIF=ZK24(ISLVK+2)
        CALL JEVEUO('&&'//SDFETI(1:17)//'.FINF','L',IINF)
        INFOFE=ZK24(IINF)

C MONITORING
        IF (INFOFE(1:1).EQ.'T')
     &    WRITE(IFM,*)'<FETI/NUMERO> DOMAINE GLOBAL ',NU(1:14)
        IF (INFOFE(2:2).EQ.'T')
     &    CALL UTIMSD(IFM,2,.FALSE.,.TRUE.,NU(1:14),1,' ')

C VERIFICATION COHERENCE SD_FETI AVEC PARAMETRAGE OPERATEUR
        CALL JEVEUO(SDFETI(1:19)//'.FREF','L',IREFE)
        CALL JELIRA(SDFETI(1:19)//'.FREF','LONMAX',NCHARF,K8BID)
        NCHARF=NCHARF-1
        NBPB=0
        IF (ZK8(IREFE).NE.MODELE) NBPB=NBPB+1
        DO 17 K=1,NCHAR
          NOMCHA=ZK24(JCHAR+K-1)(1:8)
          DO 15 L=1,NCHARF
            IF (NOMCHA.EQ.ZK8(IREFE+L)) GOTO 17
   15     CONTINUE
          NBPB=NBPB+1
   17   CONTINUE
        DO 19 L=1,NCHARF
          NOMCHA=ZK8(IREFE+L)
          DO 18 K=1,NCHAR
            IF (NOMCHA.EQ.ZK24(JCHAR+K-1)(1:8)) GOTO 19
   18     CONTINUE
          NBPB=NBPB+1
   19   CONTINUE
        IF (VERIF.EQ.'OUI') THEN
          K1='F'
        ELSE
          K1='A'
        ENDIF
        IF (NBPB.NE.0) THEN
          CALL UTDEBM(K1,'NUMERO','INCOHERENCE ENTRE SD_FETI ET ')
          CALL UTIMPI('L','LE PARAMETRAGE DE L''OPERATEUR',0,IBID)
          CALL UTIMPI('L','NOMBRE D''INCOHERENCE(S): ',1,NBPB)
          CALL UTFINM()
        ENDIF
C RECHERCHE DU PHENOMENE POUR LES NOUVEAUX LIGRELS DE SOUS-DOMAINE
C CF DISMPH.F
        CALL DISMOI('F','PHENOMENE',MODELE,'MODELE',IBID,PHENO,IRET)
        MOLOC=' '
        IF (PHENO(1:9).EQ.'MECANIQUE') THEN
          MOLOC='DDL_MECA'
        ELSE IF (PHENO(1:9).EQ.'THERMIQUE') THEN
          MOLOC='DDL_THER'
        ELSE IF (PHENO(1:9).EQ.'ACOUSTIQU') THEN
          MOLOC='DDL_ACOU'
        ELSE
          CALL UTMESS('F','NUMERO',
     &       'PHENOMENE NON PREVU DANS LE MOLOC DE NUMER2 POUR DD')
        ENDIF
        IF (INFOFE(1:1).EQ.'T') THEN
          WRITE(IFM,*)
          WRITE (IFM,*)'<FETI/NUMERO> PHENOMENE ',PHENO,MOLOC
          WRITE(IFM,*)
        ENDIF


C PREPARATION BOUCLE SUR LES SOUS-DOMAINES
        CALL JEVEUO(SDFETI(1:19)//'.FDIM','L',IDIME)
        NBSD=ZI(IDIME)
        NOMSDA=SDFETI(1:19)//'.FETA'
C ADRESSE DANS L'OBJET JEVEUX SOLVEUR.FETS DES NOMS DES OBJETS
C JEVEUX REPRESENTANT LES SOLVEURS LOCAUX
        CALL JEVEUO(SOLVEU(1:19)//'.FETS','L',ISOLFS)

C CONSTITUTION OBJET STOCKAGE.FETN
        CALL WKVECT(NU(1:14)//'.FETN',BASE(1:1)//' V K24',NBSD,IFETN)
C OBJET JEVEUX FETI & MPI
        CALL JEVEUO('&FETI.LISTE.SD.MPI','L',ILIMPI)
C APPEL MPI POUR DETERMINER LE NOMBRE DE PROCESSEURS
        IF (INFOFE(10:10).EQ.'T') THEN
          NIVMPI=2
        ELSE
          NIVMPI=1
        ENDIF
        CALL FETMPI(3,NBSD,IFM,NIVMPI,RANG,NBPROC,K24B,K24B,K24B,RBID)
C========================================
C BOUCLE SUR LES SOUS-DOMAINES + IF MPI:
C========================================
        DO 30 I=1,NBSD
          IF (ZI(ILIMPI+I).EQ.1) THEN
          
            IF ((NIV.GE.2).OR.(LFETI)) THEN
              CALL UTTCPU(50,'INIT ',6,TEMPS)
              CALL UTTCPU(50,'DEBUT',6,TEMPS)
            ENDIF
            CALL JEMARQ()
            CALL JEVEUO(JEXNUM(NOMSDA,I),'L',ILIMA)
            CALL JELIRA(JEXNUM(NOMSDA,I),'LONMAX',NBMA,K8BID)

C OBJET TEMPORAIRE CONTENANT LES NOMS DES MAILLES DU SD I
            CALL JENUNO(JEXNUM(NOMSDA,I),NOMSD)

C CREATION DU LIGREL TEMPORAIRE ASSOCIE AU SOUS-DOMAINE
C LES 16 PREMIERS CHARACTERES SONT OBLIGEATOIRES COMPTE-TENU DES
C PRE-REQUIS DES ROUTINES DE CONSTRUCTION DU NUM_DDL.
C NOUVELLE CONVENTION POUR LES LIGRELS FILS, GESTTION DE NOMS
C ALEATOIRES
            CALL GCNCON('.',K8BID)
            K8BID(1:2)='&F'
            LIGRSD=K8BID//'.MODELE   '
            CALL EXLIM1(ZI(ILIMA),NBMA,MODELE,'V',LIGRSD)

C DETECTION DES LIGRELS DE CHARGES CONCERNES PAR CE SOUS-DOMAINE
C ET REMPLISSAGE DE LA LISTE DE LIGRELS AD HOC POUR NUEFFE VIA
C NUMER2.F
            LLIGRS='&&NUMERO.LIGREL_SD'
            CALL EXLIM2(SDFETI,NOMSD,LLIGRS,LIGRSD,NBCHA,I,NBSD,INFOFE,
     &                  NBPROC)
            CALL JEVEUO(LLIGRS,'L',IVLIGR)

C --------------------------------------------------------------
C CREATION ET REMPLISSAGE DE LA SD NUME_DDL "ESCLAVE" LIEE A
C CHAQUE SOUS-DOMAINE
C --------------------------------------------------------------
C CREATION DU NUME_DDL ASSOCIE AU SOUS-DOMAINE
C         DETERMINATION DU NOM DU NUME_DDL  ASSOCIE AU SOUS-DOMAINE
            NOOBJ ='12345678.00000.NUME.PRNO'
            CALL GNOMSD(NOOBJ,10,14)
            NOMFE2=NOOBJ(1:14)
            KSOLVF = ZK24(ISOLFS+I-1)
            NBCHA1=NBCHA+1
            CALL NUMER2(NUPOSB,NBCHA1,ZK24(IVLIGR),MOLOC,KSOLVF,BASE,
     &        NOMFE2,NEQUA)
            CALL DETRSD('LIGREL',LIGRSD)
            CALL JEDETR(LLIGRS)

C REMPLISSAGE OBJET NU.FETN
            ZK24(IFETN+I-1)=NOMFE2

C MONITORING
            IF (INFOFE(1:1).EQ.'T')
     &        WRITE(IFM,*)'<FETI/NUMERO> SD ',I,' ',NOMFE2
            IF (INFOFE(2:2).EQ.'T')
     &        CALL UTIMSD(IFM,2,.FALSE.,.TRUE.,NOMFE2,1,' ')
            IF ((NIV.GE.2).OR.(LFETI)) THEN
              CALL UTTCPU(50,'FIN  ',6,TEMPS)
              WRITE(IFM,*)'TEMPS CPU/SYS FACT SYMB: ',TEMPS(5),TEMPS(6)
              ZR(IFCPU+I)=TEMPS(5)+TEMPS(6)
            ENDIF
            CALL JEDEMA()

          ENDIF
   30   CONTINUE
C========================================
C FIN BOUCLE SUR LES SOUS-DOMAINES + IF MPI:
C========================================

C FIN DE IF METHOD='FETI'
      ENDIF
C-----------------------------------------------------------------------
C APPEL MPI POUR DETERMINER LE RANG DU PROCESSEUR
      CALL FETMPI(2,NBSD,IFM,NIVMPI,RANG,NBPROC,K24B,K24B,K24B,RBID)
      IF ((LFETI).AND.(RANG.EQ.0)) THEN
C POUR EVITER QUE LA RECONSTRUCTION DU CHAMP GLOBAL SOIT FAUSSE DANS
C FETRIN OU ON TRAVAILLE DIRECTEMENT SUR LES .VALE (GLOBAL ET LOCAUX)
C TEST DE L'OBJET .NUEQ DU PROF_CHNO DU NUME_DDL. POUR FETI IL DOIT
C ETRE EGALE A L'IDENTITE (EN THERORIE CE PB SE PRESENTE QUE POUR LA
C SOUS-STRUCTURATION QUI EST ILLICITE AVEC FETI, MAIS ON NE SAIT JAMAIS)
        K24B=NU(1:14)//'.NUME.NUEQ'
        CALL JEVEUO(K24B,'L',INUEQ)
        CALL JELIRA(K24B,'LONMAX',LDEEQG,K8BID)
        DO 40 I=1,LDEEQG
          IBID=ZI(INUEQ+I-1)
          IF (IBID.NE.I) THEN
            CALL UTDEBM('F','NUMERO','OBJET PROF_CHNO.NUEQ DIFFERENT ')
            CALL UTIMPI('L','DE L''IDENTITE AVEC FETI',0,I)
            CALL UTIMPI('L','POUR I= ',1,I)
            CALL UTIMPI('S',' NUEQ(I)= ',1,IBID)
            CALL UTFINM()
          ENDIF
   40   CONTINUE
      ENDIF


C --- CREATION DE L'OBJET .NSLV :
C     -------------------------------------
      IF (METHOD.EQ.'MUMPS' ) THEN
        CALL WKVECT(NU(1:14)//'.NSLV',BASE(1:1)//' V K24',1,JNSLV)
        ZK24(JNSLV-1+1)=SOLVEU
      ENDIF
      CALL JEDETR(LLIGR)
      CALL JEDEMA()
      END
