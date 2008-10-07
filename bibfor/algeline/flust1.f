      SUBROUTINE FLUST1 ( MELFLU, TYPFLU, BASE, NUOR, AMOR, AMOC, FREQ,
     &                    MASG, FACT, VITE, NBM, CALCUL, NPV, NIVPAR,
     &                    NIVDEF )
      IMPLICIT REAL*8 (A-H,O-Z)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 07/10/2008   AUTEUR PELLET J.PELLET 
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
C DESCRIPTION :  CALCUL DES PARAMETRES DE COUPLAGE FLUIDE-STRUCTURE
C -----------    POUR UNE CONFIGURATION DE TYPE "FAISCEAU DE TUBES
C                SOUS ECOULEMENT TRANSVERSE"
C
C                OPERATEUR APPELANT : CALC_FLUI_STRU , OP0144
C
C  IN : MELFLU : NOM DU CONCEPT DE TYPE MELASFLU PRODUIT
C  IN : TYPFLU : NOM DU CONCEPT DE TYPE TYPE_FLUI_STRU DEFINISSANT LA
C                CONFIGURATION ETUDIEE
C  IN : BASE   : NOM DU CONCEPT DE TYPE MODE_MECA DEFINISSANT LA BASE
C                MODALE DU SYSTEME AVANT PRISE EN COMPTE DU COUPLAGE
C  IN : NUOR   : LISTE DES NUMEROS D'ORDRE DES MODES SELECTIONNES POUR
C                LE COUPLAGE (PRIS DANS LE CONCEPT MODE_MECA)
C  IN : AMOR   : LISTE DES AMORTISSEMENTS REDUITS MODAUX INITIAUX
C  IN : VITE   : LISTE DES VITESSES D'ECOULEMENT ETUDIEES
C  IN : NBM    : NOMBRE DE MODES PRIS EN COMPTE POUR LE COUPLAGE
C  IN : NPV    : NOMBRE DE VITESSES D'ECOULEMENT
C  IN : NIVPAR : NIVEAU D'IMPRESSION DANS LE FICHIER RESULTAT POUR LES
C                PARAMETRES DU COUPLAGE (FREQ,AMOR)
C  IN : NIVDEF : NIVEAU D'IMPRESSION DANS LE FICHIER RESULTAT POUR LES
C                DEFORMEES MODALES
C  OUT: FREQ   : FREQUENCES ET AMORTISSEMENTS REDUITS MODAUX PERTUBES
C                PAR L'ECOULEMENT
C  OUT: MASG   : MASSES GENERALISEES DES MODES PERTURBES, SUIVANT LA
C                DIRECTION CHOISIE PAR L'UTILISATEUR
C  OUT: FACT   : PSEUDO FACTEUR DE PARTICIPATION
C
C-------------------   DECLARATION DES VARIABLES   ---------------------
C
C COMMUNS NORMALISES JEVEUX
C -------------------------
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
C
C ARGUMENTS
C ---------
      CHARACTER*19  MELFLU
      CHARACTER*8   TYPFLU, BASE
      INTEGER       NUOR(*)
      REAL*8        AMOR(*),AMOC(*), FREQ(*), MASG(*), FACT(*)
      REAL*8        VITE(*)
      REAL*8        CARAC(2)
      INTEGER       NBM, NPV, NIVPAR, NIVDEF,JPARA,KK,N1
      LOGICAL       CALCUL(2)
C
C VARIABLES LOCALES
C -----------------
      CHARACTER*1   K1BID
      CHARACTER*8   DEPL,MAILLA,K8B
      CHARACTER*14  NUMDDL
      CHARACTER*19  CAELEM, MASSE
      CHARACTER*24  FSIC, FSVI, FSVK, PVITE, FRHOE, NOMNOE
      CHARACTER*24  REFEI, MATRIA, VALE
      INTEGER       LZONE
C
C FONCTIONS EXTERNES
C ------------------
      REAL*8        R8PI
C     EXTERNAL      R8PI
C
C DATA
C ----
      DATA  VALE  /'                   .VALE'/
C
C-------------------   DEBUT DU CODE EXECUTABLE    ---------------------
C
      CALL JEMARQ()
      PI = R8PI()
C
C
C --- 1.RECUPERATION DES INFORMATIONS APPORTEES PAR LE CONCEPT ---
C ---   TYPE_FLUI_STRU                                         ---
C
C --- 1.1.PRISE EN COMPTE OU NON DU COUPLAGE
C
      FSIC = TYPFLU//'           .FSIC'
      CALL JEVEUO(FSIC,'L',IFSIC)
      ICOUPL = ZI(IFSIC+1)
C
C --- 1.2.DIAMETRE EXTERIEUR DU TUBE (TEST SI SECTION CONSTANTE)
C
      FSVK = TYPFLU//'           .FSVK'
      CALL JEVEUO(FSVK,'L',IFSVK)
C
      DEPL = ZK8(IFSVK+1)
C
C --- 1.4.NOMBRE DE POINTS DE DISCRETISATION DU TUBE
C
      CALL JEVEUO ( BASE//'           .REFD' , 'L', KREF )
      MASSE = ZK24(KREF+1)
      CALL MTDSCR ( MASSE )
      CALL JEVEUO ( MASSE//'.&INT' , 'L' , LMASSE )
      CALL DISMOI('F','NOM_NUME_DDL',MASSE,'MATR_ASSE',IBID,NUMDDL,IRE)
      CALL DISMOI('F','NOM_MAILLA'  ,MASSE,'MATR_ASSE',IBID,MAILLA,IRE)
      CALL DISMOI('F','NB_EQUA'     ,MASSE,'MATR_ASSE',NEQ ,K8B   ,IRE)
C
C-----RECUPERATION DU NOMBRE DE NOEUDS DU MAILLAGE
C
      NOMNOE = MAILLA//'.NOMNOE'
      CALL JELIRA(NOMNOE,'NOMUTI',LNOE,K8B)
C
C-----CREATION ET REMPLISSAGE DES OBJETS DE TRAVAIL DEPENDANT DU
C-----TYPE DU CONFIGURATION
C
C --- 1.5.CONCEPT DE TYPE FONCTION DEFINISSANT LE PROFIL DE VITESSE
C --- A PARTIR DES PROFIL DE VITESSE DE CHAQUE ZONE ON CONSTRUIT UN
C --- PROFIL UNIQUE, AINSI QUE LES VECTEUR IRES (TYPE DE RESEAU) ET
C --- VMOY (VITESSE MOYENNE) DE CHAQUE POINT DU TUBE.
C --- VMOYTO EST LA VITESSE MOYENNE SUR L ENSEMBLE DES ZONES.
C --- LES PROFILS DE VITESSE NE SONT PAS NORMES.
C
      CALL WKVECT ('&&FLUST1.TEMP.PROFV', 'V V R',(2*LNOE+1),LPROFV)
      CALL WKVECT ('&&FLUST1.TEMP.PROFR', 'V V R',2*LNOE,    LRHO)
      CALL WKVECT ('&&FLUST1.TEMP.ABSC' , 'V V R',LNOE,      LABSC)
      CALL WKVECT ('&&FLUST1.TEMP.IRES' , 'V V I',LNOE,      LIRES)
      CALL WKVECT ('&&FLUST1.TEMP.ZONE' , 'V V I',2*LNOE,    LZONE)
      IF (ICOUPL.EQ.1) THEN
         CALL WKVECT('&&FLUST1.TEMP.DEFM','V V R',NBM*LNOE, LDEFM)
      ENDIF
C
C ---
         CALL MDCONF(TYPFLU,BASE,K8B,NBM,LNOE,NUOR,0,INDIC,
     &         ZI(LIRES),ZR(LPROFV),ZR(LRHO),ZR(LDEFM),CARAC,ZR(LABSC)
     &         )
C
C
C --- 2. CALCUL DES MASS_GENE_DX, _DY, _DZ ---
C        REMPLISSAGE DES OBJETS .MASG .FACT ---
C
      CALL WKVECT ('&&FLUST1.TEMP.LAUX1' , 'V V R', NEQ , LAUX1 )
      CALL WKVECT ('&&FLUST1.TEMP.LAUX2' , 'V V R', NEQ , LAUX2 )
      CALL WKVECT ('&&FLUST1.TEMP.MASG'  , 'V V R', NBM , KMASG )
      CALL WKVECT ('&&FLUST1.POSITION.DDL','V V I', NEQ , LDDL  )
      CALL PTEDDL ( 'NUME_DDL', NUMDDL, 1, DEPL, NEQ, ZI(LDDL) )
      DO 80 IEQ = 0, NEQ-1
         ZR(LAUX1+IEQ) = ZI(LDDL+IEQ)
 80   CONTINUE
      CALL MRMULT ( 'ZERO', LMASSE, ZR(LAUX1), 'R', ZR(LAUX2), 1 )
      DO 100 IM = 1,NBM
         IOR = NUOR(IM)
         CALL RSEXCH ( BASE, 'DEPL', IOR, VALE(1:19), IRET )
         CALL ASSERT( IRET .EQ. 0 )
         CALL JEVEUO ( VALE, 'L', LVALE )
         RVAL1 = 0.0D0
         DO 90 IEQ = 0, NEQ-1
            RVAL1 = RVAL1 + ZR(LVALE+IEQ)*ZR(LAUX2+IEQ)*ZR(LVALE+IEQ)
 90      CONTINUE
         ZR(KMASG+IM-1) = RVAL1
C
         CALL RSADPA ( BASE,'L',1,'FACT_PARTICI_DX',IOR,0,LFACT,K8B)
         CALL RSADPA ( BASE,'L',1,'MASS_GENE'      ,IOR,0,LMASG,K8B)
         MASG(IM) = ZR(LMASG)
         FACT(3*(IM-1)+1) = ZR(LFACT  ) * MASG(IM)
         FACT(3*(IM-1)+2) = ZR(LFACT+1) * MASG(IM)
         FACT(3*(IM-1)+3) = ZR(LFACT+2) * MASG(IM)
 100  CONTINUE
C
C
C --- 3.REMPLISSAGE DES OBJETS .VALE DES CHAMPS DE DEPLACEMENTS ---
C
      CALL CPDEPL ( MELFLU, BASE, NUOR, NBM )
C
C
C --- 4.CALCUL DES PARAMETRES DE COUPLAGE SI DEMANDE ---
      CALL RSLIPA(BASE,'FREQ','&&FLUST1.LIFREQ',IFREQI,N1)

C
      IF (CALCUL(1)) THEN
         IF (ICOUPL.EQ.1) THEN
C
            CALL WKVECT('&&FLUST1.TEMP.AMFR','V V R',2*NBM,IAMFR)
            DO 110 IM = 1,NBM
               IMOD = NUOR(IM)
               ZR(IAMFR+IM-1) = 4.D0*PI*ZR(IFREQI+IMOD-1)*AMOR(IM)*
     &                                               ZR(KMASG+IM-1)
               ZR(IAMFR+NBM+IM-1) = ZR(IFREQI+IMOD-1)
  110       CONTINUE
C
            NT = 2
            LVALE = 2*NT*NT + 10*NT + 2
            CALL WKVECT('&&FLUST1.TEMP.VALE','V V R',LVALE,IVALE)
C
C-------LANCEMENT DU CALCUL
C
            CALL PACOUC (TYPFLU,ZR(LPROFV),ZR(LRHO),VITE,ZR(LDEFM),
     &               ZR(KMASG),FREQ,ZR(IAMFR),NBM,LNOE,NPV,
     &               ZR(IVALE),ZI(LIRES),CARAC,ZR(LABSC),IER)
C
         ELSE
C
C-------REMPLISSAGE DE L'OBJET .FREQ
C
            DO 140 IV = 1,NPV
               DO 130 IM = 1,NBM
                  IMOD = NUOR(IM)
                  IND = 2*NBM*(IV-1)+2*(IM-1)+1
                  FREQ(IND) = ZR(IFREQI+IMOD-1)
                  FREQ(IND+1) = AMOR(IM)
 130           CONTINUE
 140        CONTINUE
C
         ENDIF
      ENDIF
      IF (CALCUL(2)) THEN
         CALL CONNOR(MELFLU, TYPFLU,ZR(IFREQI),BASE,NUOR,AMOC,
     &               CARAC,MASG,LNOE,NBM,ZR(LPROFV),
     &               ZR(LRHO),ZR(LABSC))
      ENDIF



C
C --- 5.IMPRESSIONS DANS LE FICHIER RESULTAT SI DEMANDEES ---
C
      IF (NIVPAR.EQ.1 .OR. NIVDEF.EQ.1) THEN
        CALL FLUIMP(1,NIVPAR,NIVDEF,MELFLU,TYPFLU,NUOR,FREQ,
     &              ZR(IFREQI),NBM,VITE,NPV,CARAC,CALCUL,AMOC)
      ENDIF
C
C     NETTOYAGE SUR LA VOLATILE
      CALL JEDETC('V','&&FLUST1',1)
C
      CALL JEDETR('&&COEFMO.COMPT')
      CALL JEDETR('&&COEFMO.EXTR')
      CALL JEDETR('&&COEFMO.VRZO')
      CALL JEDETR('&&COEFMO.ALARM')
      CALL JEDETR('&&COEFAM.CDI')
      CALL JEDETR('&&COEFAM.CDR1')
      CALL JEDETR('&&COEFAM.CDR2')
      CALL JEDETR('&&COEFRA.CKI')
      CALL JEDETR('&&COEFRA.CKR1')
      CALL JEDETR('&&COEFRA.CKR2')
      CALL JEDETR('&&PACOUC.TRAV1')
      CALL JEDETR('&&PACOUC.TRAV2')
      CALL JEDETR('&&MDCONF.TEMPO')
C
      CALL JEDEMA()
C
C --- FIN DE FLUST1.
      END
