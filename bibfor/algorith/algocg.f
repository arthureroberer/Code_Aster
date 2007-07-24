      SUBROUTINE ALGOCG(DEFICO,RESOCO,LMAT,NOMA,CINE,RESU,LICCVG,LREAC,
     &                  ITERAT)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 23/07/2007   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE ABBAS M.ABBAS
C TOLE CRP_20
C ======================================================================
      IMPLICIT     NONE
      LOGICAL LREAC(4)
      CHARACTER*8 NOMA
      CHARACTER*24 DEFICO,RESOCO,CINE,RESU
      INTEGER LMAT,ITERAT,LICCVG(5)
C ======================================================================
C ROUTINE APPELEE PAR : CFALGO
C ======================================================================

C ALGO DE CONTACT

C ALGO. POUR CONTACT    : GRADIENT CONJUGUE PROJETE
C ALGO. POUR FROTTEMENT : SANS

C RESOLUTION DE : C.DU + AT.MU  = F
C                 A(U+DU)      <= E (= POUR LES LIAISONS ACTIVES)

C AVEC E = JEU COURANT (CORRESPONDANT A U/I/N)

C      C = ( K  BT ) MATRICE DE RIGIDITE INCLUANT LES LAGRANGE
C          ( B  0  )

C      U = ( DEPL )
C          ( LAM  )

C      F = ( DL  ) DANS LA PHASE DE PREDICTION
C          ( DUD )

C      F = ( L - QT.SIG - BT.LAM  ) AU COURS D'UNE ITERATION DE NEWTON
C          (           0          )

C IN  DEFICO  : SD DE DEFINITION DU CONTACT (ISSUE D'AFFE_CHAR_MECA)
C IN  RESOCO  : SD DE TRAITEMENT NUMERIQUE DU CONTACT
C                'E':  RESOCO(1:14)//'.APJEU'
C                'E':  RESOCO(1:14)//'.LIAC'
C                'E':  RESOCO(1:14)//'.LIOT'
C                'E':  RESOCO(1:14)//'.MU'
C                'E':  RESOCO(1:14)//'.DEL0'
C                'E':  RESOCO(1:14)//'.DELT'
C                'E':  RESOCO(1:14)//'.COCO'
C IN  LMAT    : DESCRIPTEUR DE LA MATR_ASSE DU SYSTEME MECANIQUE
C IN  NOMA    : NOM DU MAILLAGE
C IN  CINE    : CHAM_NO CINEMATIQUE
C VAR RESU    : INCREMENT "DDEPLA" DE DEPLACEMENT DEPUIS DEPTOT
C               (DEPLACEMENT TOTAL OBTENU A L'ISSUE DE L'ITERATION
C               DE NEWTON PRECEDENTE)
C                 EN ENTREE : SOLUTION OBTENUE SANS TRAITER LE CONTACT
C                 EN SORTIE : SOLUTION CORRIGEE PAR LE CONTACT
C OUT LICCVG  : CODES RETOURS D'ERREUR
C                       (1) PILOTAGE
C                       (2) LOI DE COMPORTEMENT
C                       (3) CONTACT/FROTTEMENT: NOMBRE MAXI D'ITERATIONS
C                       (4) CONTACT/FROTTEMENT: MATRICE SINGULIERE
C
C --------------- DEBUT DECLARATIONS NORMALISEES JEVEUX ---------------
C
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
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      INTEGER CFDISI
      LOGICAL CONJUG
      INTEGER IFM,NIV,IZONE,NZOCO,FREQ,ISMAEM
      INTEGER II,ILIAC,JRESU,JDECAL,ITER,JDELT1,PREMAX
      INTEGER NEQ,NESCL,NBLIAC,NBLIAI,NBDDL,JDMU,JRESU0
      INTEGER JAPPAR,JAPPTR,JAPCOE,JAPJEU,JAPDDL,JZOCO,JSGPRE
      INTEGER JNOCO,JMACO,JSECMB,JVEZER,JMUM,JVECC,JMU0
      INTEGER JLIAC,JMU,JDELT0,JDELTA,JCOCO,JATMU,JMETH,JSLVK
      INTEGER GCPMAX,JRCINE,JSGRAM,JSGRAP,JDIREM,JDIREP
      REAL*8 AJEU,VAL,R8PREM,R8VIDE,DDOT,TOLE,RELA,CFDISR
      REAL*8 NUMER,DENOM,NINF,ALPHA,EPSI,R8BID,GAMMA,NUMER2,EPSIPC
      CHARACTER*2 TYPEC0
      CHARACTER*8 METRES
      CHARACTER*16 PRECON,SEARCH
      CHARACTER*19 LIAC,MU,DELT0,DELTA,COCO,ATMU,SGRADM,SGRADP,MU0
      CHARACTER*19 DIRECM,DIRECP,MUM,SOLVEU,CONVEC
      CHARACTER*19 SGRPRE,RESU0,KBID,MATASS
      CHARACTER*24 APPARI,APPOIN,APCOEF,APJEU,APDDL,NOZOCO,VEZERO
      CHARACTER*24 CONTNO,CONTMA,METHCO,DELTAM,SECMBR,DELTAU

C ----------------------------------------------------------------------

C ======================================================================
C             INITIALISATIONS DES OBJETS ET DES ADRESSES
C ======================================================================
C U      : DEPTOT + RESU+
C DEPTOT : DEPLACEMENT TOTAL OBTENU A L'ISSUE DE L'ITERATION DE NEWTON
C          PRECEDENTE. C'EST U/I/N.
C RESU   : INCREMENT DEPUIS DEPTOT (ACTUALISE AU COURS DES ITERATIONS
C          DE CONTRAINTES ACTIVES : RESU+ = RESU- + RHO.DELTA)
C          C'EST DU/K OU DU/K+1.
C DELTA  : INCREMENT DONNE PAR CHAQUE ITERATION DE CONTRAINTES ACTIVES.
C          C'EST D/K+1.
C DELT0  : INCREMENT DE DEPLACEMENT DEPUIS LA DERNIERE ITERATION DE
C          NEWTON SANS TRAITER LE CONTACT. C'EST C-1.F.
C ======================================================================
      CALL INFNIV(IFM,NIV)
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<CONTACT> <> ALGO_CONTACT   : GRADIENT '//
     &    'CONJUGUE PROJETE'
        WRITE (IFM,*) '<CONTACT> <> ALGO_FROTTEMENT: SANS'
      END IF

      CALL JEMARQ()

C ======================================================================
C --- LECTURE DES STRUCTURES DE DONNEES DE CONTACT
C ======================================================================

      METHCO = DEFICO(1:16)//'.METHCO'
      CONTNO = DEFICO(1:16)//'.NOEUCO'
      CONTMA = DEFICO(1:16)//'.MAILCO'
      NOZOCO = DEFICO(1:16)//'.NOZOCO'
      APPARI = RESOCO(1:14)//'.APPARI'
      APPOIN = RESOCO(1:14)//'.APPOIN'
      APCOEF = RESOCO(1:14)//'.APCOEF'
      APJEU  = RESOCO(1:14)//'.APJEU'
      APDDL  = RESOCO(1:14)//'.APDDL'
      LIAC   = RESOCO(1:14)//'.LIAC'
      MU     = RESOCO(1:14)//'.MU'
      DELT0  = RESOCO(1:14)//'.DEL0'
      DELTA  = RESOCO(1:14)//'.DELT'
      ATMU   = RESOCO(1:14)//'.ATMU'
      COCO   = RESOCO(1:14)//'.COCO'
      SOLVEU = '&&OP0070.SOLVEUR'
      MATASS = '&&OP0070.MATASS'

C     SI SOLVEUR GCPC, ON S'ARRETE EN FATALE
C     ---------------------------------------
      CALL JEVEUO(SOLVEU//'.SLVK','L',JSLVK)
      METRES=ZK24(JSLVK-1+1)
      IF (METRES.EQ.'GCPC') THEN
        CALL U2MESS('F','CONTACT_6')
      END IF

C ======================================================================
      CALL JEVEUO(COCO,'E',JCOCO)
      CALL JEVEUO(NOZOCO,'L',JZOCO)
      CALL JEVEUO(CONTNO,'L',JNOCO)
      CALL JEVEUO(CONTMA,'L',JMACO)
      CALL JEVEUO(APPARI,'L',JAPPAR)
      CALL JEVEUO(APPOIN,'L',JAPPTR)
      CALL JEVEUO(APCOEF,'L',JAPCOE)
      CALL JEVEUO(APJEU,'E',JAPJEU)
      CALL JEVEUO(APDDL,'L',JAPDDL)
      CALL JEVEUO(LIAC,'E',JLIAC)
      CALL JEVEUO(ATMU,'E',JATMU)
      CALL JEVEUO(MU,'E',JMU)
      CALL JEVEUO(DELT0,'E',JDELT0)
      CALL JEVEUO(DELTA,'E',JDELT1)
      CALL JEVEUO(RESU(1:19)//'.VALE','E',JRESU)
      CALL JEVEUO(CINE(1:19)//'.VALE','L',JRCINE)
C ======================================================================
C --- INITIALISATION DE VARIABLES
C --- NESCL  : NOMBRE DE NOEUDS ESCLAVES SUSCEPTIBLES D'ETRE EN CONTACT
C --- NBLIAI : NOMBRE DE LIAISONS DE CONTACT
C --- NBLIAC : NOMBRE DE LIAISONS ACTIVES
C --- NEQ    : NOMBRE D'EQUATIONS DU MODELE
C --- ITEMUL : NOMBRE PAR LEQUEL IL FAUT MULTIPLIER LE NOMBRE DE
C              LIAISONS DE CONTACT POUR OBTENIR LE NOMBRE MAXI
C              D'ITERATIONS DANS L'ALGO GCPMAX=ITEMUL*NBLIAI
C                   <!> FIXE A 10 POUR CET ALGO <!>
C --- GCPMAX : NOMBRE D'ITERATIONS DE CONTACT DANS L'ALGO
C ======================================================================
      NESCL  = ZI(JAPPAR)
      NBLIAI = NESCL
      NEQ    = ZI(LMAT+2)
      TYPEC0 = 'C0'
C ======================================================================
C                             INITIALISATIONS
C ======================================================================

      ITER = 1
      CONJUG = .FALSE.
      TOLE = 1.D-12

C     RECUPERATION DU CRITERE DE CONVERGENCE ET DE LA FREQUENCE DE
C     REACTUALISATION DES DIRECTIONS (MIN DE TOUS)
C     --------------------------------------------------------------

      EPSI = 1.D0/R8PREM()
      FREQ = ISMAEM()
      RELA = 1.D0/R8PREM()
      PRECON = 'SANS'
      SEARCH = 'ADMISSIBLE'
      GCPMAX = 2*NBLIAI
      PREMAX = ISMAEM()
      CALL JEVEUO(METHCO,'L',JMETH)
      NZOCO = ZI(JMETH)
      DO 10 IZONE = 1,NZOCO
C       CRITERE DE CONVERGENCE GCP
        EPSI = MIN(EPSI,CFDISR(DEFICO,'RESI_ABSO',IZONE))
C       FREQUENCE DE REACTUALISATION
        FREQ = MIN(FREQ,CFDISI(DEFICO,'REAC_ITER',IZONE))
C       CRITERE_PRECOND = RELA*EPSI
        RELA = MIN(RELA,CFDISR(DEFICO,'COEF_RESI',IZONE))
C       NOMBRE D'ITERATIONS MAX DU GCP
        IF (CFDISI(DEFICO,'ITER_GCP_MAXI',IZONE).NE.0) THEN
          GCPMAX=MIN(GCPMAX,CFDISI(DEFICO,'ITER_GCP_MAXI',IZONE))
        ENDIF  
C       NOMBRE D'ITERATIONS MAX DU PRECONDITIONNEUR
        IF (CFDISI(DEFICO,'ITER_PRE_MAXI',IZONE).NE.0) THEN
          PREMAX=MIN(PREMAX,CFDISI(DEFICO,'ITER_PRE_MAXI',IZONE))
        ENDIF  
C       TYPE DE PRECONDITIONNEUR
        IF (CFDISI(DEFICO,'PRE_COND',IZONE).EQ.1) THEN
          PRECON = 'DIRICHLET'
        ENDIF  
C       TYPE DE RECHERCHE LINEAIRE
        IF (CFDISI(DEFICO,'RECH_LINEAIRE',IZONE).EQ.1) THEN
          SEARCH = 'NON_ADMISSIBLE'
        ENDIF  
   10 CONTINUE


C     CREATION DES VECTEURS DE TRAVAIL
C     ---------------------------------

C     SS-GRADIENT ITERATION (-) ET (+)
      SGRADM = '&&ALGOCG.SGRADM'
      SGRADP = '&&ALGOCG.SGRADP'

C     SS-GRADIENT ITERATION (-) ET (+)
      DIRECM = '&&ALGOCG.DIRECM'
      DIRECP = '&&ALGOCG.DIRECP'

C     SS-GRADIENT PRECONDITIONNE
      SGRPRE = '&&ALGOCG.SGRPRE'

C     MULT. LAGRANGE ITERATION (-)
      MUM = '&&ALGOCG.MUM'

C     MULT. LAGRANGE ITERATION DE NEWTON (-)
      MU0 = '&&ALGOCG.MU0'

C     INCR. DE DEPLACEMENT INITIAL
      RESU0 = '&&ALGOCG.RESU0'

C     INCREMENT DE MULT. LAGRANGE
      DELTAM = '&&ALGOCG.DELTAM'

C     SECOND MEMBRE ET VECTEUR NUL
      SECMBR = '&&ALGOCG.SECMBR'
      VEZERO = '&&ALGOCG.VEZERO'
      DELTAU = '&&ALGOCG.DELTA'

      IF (ITERAT.EQ.0) THEN
        CALL INITIA(NBLIAI,.FALSE.,0,R8BID,ZR(JMU))
      END IF

      CALL JEDUPO(MU,'V',SGRADM,.FALSE.)
      CALL JEDUPO(MU,'V',SGRADP,.FALSE.)
      CALL JEDUPO(MU,'V',SGRPRE,.FALSE.)
      CALL JEDUPO(MU,'V',DIRECM,.FALSE.)
      CALL JEDUPO(MU,'V',DIRECP,.FALSE.)
      CALL JEDUPO(MU,'V',MUM,.FALSE.)
      CALL JEDUPO(MU,'V',MU0,.FALSE.)
      CALL JEDUPO(MU,'V',DELTAM,.FALSE.)
      CALL JEDUPO(ATMU,'V',RESU0,.FALSE.)
      CALL COPISD('CHAMP_GD','V',CINE,SECMBR)
      CALL COPISD('CHAMP_GD','V',CINE,DELTAU)
      CALL COPISD('CHAMP_GD','V',CINE,VEZERO)

      CALL JEVEUO(SGRADM,'E',JSGRAM)
      CALL JEVEUO(SGRADP,'E',JSGRAP)
      CALL JEVEUO(DIRECM,'E',JDIREM)
      CALL JEVEUO(DIRECP,'E',JDIREP)
      CALL JEVEUO(MUM,'E',JMUM)
      CALL JEVEUO(MU0,'E',JMU0)
      CALL JEVEUO(DELTAM,'E',JDMU)
      CALL JEVEUO(SGRPRE,'E',JSGPRE)
      CALL JEVEUO(RESU0,'E',JRESU0)
      CALL JEVEUO(SECMBR(1:19)//'.VALE','E',JSECMB)
      CALL JEVEUO(DELTAU(1:19)//'.VALE','E',JDELTA)
      CALL JEVEUO(VEZERO(1:19)//'.VALE','E',JVEZER)
      CALL R8INIR(NEQ,0.D0,ZR(JVEZER),1)


C     IMPRESSIONS INITIALES
C     ---------------------
      IF (NIV.EQ.2) THEN
        WRITE (IFM,*) '<CONTACT> <> LIAISONS INITIALES '
      END IF

      IF (NIV.GE.2) THEN
        WRITE (IFM,9000) NBLIAI
        WRITE (IFM,9010) GCPMAX
      END IF

C     TOUTES LES LIAISONS SONT DES LIAISONS DE CONTACT
C     ET PORTENT LEUR NUMERO "NATUREL"
      CONVEC = RESOCO(1:14)//'.CONVEC'
      CALL JEVEUO(CONVEC,'E',JVECC)
      DO 20 II = 1,NBLIAI
        ZK8(JVECC-1+II) = TYPEC0
        ZI(JLIAC-1+II) = II
   20 CONTINUE

C     SAUVEGARDE DU DEPLACEMENT INITIAL
      CALL DCOPY(NEQ,ZR(JRESU),1,ZR(JRESU0),1)

C ======================================================================
C =========================== BOUCLE PRINCIPALE ========================
C ======================================================================

   30 CONTINUE

C ======================================================================
C --- CALCUL ET PROJECTION DU SOUS-GRADIENT
C --- EVALUATION DE LA CONVERGENCE
C --- IMPRESSION DE DEBUGGAGE SUR DEMANDE
C ======================================================================

      IF (NIV.EQ.2) THEN
        WRITE (IFM,*) '<CONTACT> <> -----------------------------------'
        WRITE (IFM,*) '<CONTACT> <> ITERATION DE GCP = ',ITER
      END IF

      NINF = 0.D0
      DO 40 II = 1,NBLIAI
        JDECAL = ZI(JAPPTR+II-1)
        NBDDL = ZI(JAPPTR+II) - ZI(JAPPTR+II-1)
        CALL CALADU(NEQ,NBDDL,ZR(JAPCOE+JDECAL),ZI(JAPDDL+JDECAL),
     &              ZR(JRESU),VAL)
        IF (ZR(JAPJEU+II-1).NE.R8VIDE()) THEN
          AJEU = ZR(JAPJEU+II-1) - VAL

        ELSE
          AJEU = 1.D0/R8PREM()
        END IF
C       PROJECTION DU SOUS-GRADIENT
        ZR(JSGRAP-1+II) = -AJEU
        IF (ZR(JMU-1+II).LT.TOLE) THEN
          ZR(JSGRAP-1+II) = MAX(-1.D0*AJEU,0.D0)
        END IF
C       NORME INFINIE DU RESIDU
        NINF = MAX(ABS(ZR(JSGRAP-1+II)),NINF)
   40 CONTINUE


C     ON A CONVERGE
      IF (NINF.LT.EPSI) THEN
        IF (NIV.EQ.2) WRITE (IFM,9060) NINF,EPSI
        GO TO 110
      END IF
      IF (NIV.EQ.2) THEN
        WRITE (IFM,9060) NINF,EPSI
      END IF

C ======================================================================
C --- CONJUGAISON
C ======================================================================

C     ON FAIT LA CONJUGAISON DE POLAK-RIBIERE :
C        - SI L'ETAT DE CONTACT EST LE MEME D'UNE ITERATION SUR L'AUTRE
C        - TOUTES LES FREQ ITERATIONS
C        - SI DIR+ EST UNE DIRECTION DE DESCENTE I.E. (DIR+)'.(SGRAD+)>0
C     NB : LA CONJUGAISON DE FLETCHER-REEVES EST : GAMMA = NUMER/DENOM
      GAMMA = 0.D0
      IF (CONJUG) THEN
        NUMER = DDOT(NBLIAI,ZR(JSGRAP),1,ZR(JSGRAP),1)
        NUMER2 = DDOT(NBLIAI,ZR(JSGRAP),1,ZR(JSGRAM),1)
        DENOM = DDOT(NBLIAI,ZR(JSGRAM),1,ZR(JSGRAM),1)
        GAMMA = (NUMER-NUMER2)/DENOM
      END IF


C     DIRECP = GAMMA DIRECM + SSGRAP
      CALL DCOPY(NBLIAI,ZR(JSGRAP),1,ZR(JDIREP),1)
      CALL DAXPY(NBLIAI,GAMMA,ZR(JDIREM),1,ZR(JDIREP),1)

C     DIRECP EST-ELLE UNE DIRECTION DE DESCENTE
      NUMER2 = DDOT(NBLIAI,ZR(JDIREP),1,ZR(JSGRAP),1)
      IF (NUMER2.LE.0.D0) THEN
        CONJUG = .FALSE.
        GAMMA = 0.D0
        CALL DCOPY(NBLIAI,ZR(JSGRAP),1,ZR(JDIREP),1)
      END IF

      IF (CONJUG) THEN
        IF (NIV.EQ.2) THEN
          WRITE (IFM,*) '<CONTACT> <> CONJUGAISON DES DIRECTIONS '//
     &      'DE RECHERCHE, GAMMA=',GAMMA
        END IF
      END IF


C ======================================================================
C --- RECHERCHE LINEAIRE
C ======================================================================

C-----INITIALISATION DE DELTA ET DU PRECONDITIONNEUR
      CALL R8INIR(NEQ,0.D0,ZR(JDELTA),1)
      CALL R8INIR(NBLIAI,0.D0,ZR(JSGPRE),1)

C----PRECONDITIONNEMENT DIRICHLET
      IF (PRECON.EQ.'DIRICHLET') THEN
        EPSIPC = EPSI*RELA
        CALL PREGCP(NEQ,NBLIAI,TOLE,EPSIPC,ZR(JMU),ZR(JDIREP),
     &              ZR(JAPCOE),ZI(JAPDDL),ZI(JAPPTR),ZI(JLIAC),MATASS,
     &              ZR(JSGRAP),ZR(JSGPRE),SECMBR,VEZERO,DELTAU,SOLVEU,
     &              PREMAX)
        CALL JEVEUO(DELTAU(1:19)//'.VALE','E',JDELTA)
      ELSE
C----SINON ON RECOPIE
        CALL DCOPY(NBLIAI,ZR(JDIREP),1,ZR(JSGPRE),1)
      END IF

C     K DELTA = A' DIRECP
      DO 50 ILIAC = 1,NBLIAI
        JDECAL = ZI(JAPPTR+ILIAC-1)
        NBDDL = ZI(JAPPTR+ILIAC) - ZI(JAPPTR+ILIAC-1)
        CALL CALATM(NEQ,NBDDL,ZR(JSGPRE-1+ILIAC),ZR(JAPCOE+JDECAL),
     &              ZI(JAPDDL+JDECAL),ZR(JDELTA))
   50 CONTINUE
      CALL DCOPY(NEQ,ZR(JDELTA),1,ZR(JSECMB),1)
      CALL RESOUD(MATASS,KBID,SECMBR,SOLVEU, VEZERO, 'V',
     &                   DELTAU, KBID)
      CALL JEVEUO(DELTAU(1:19)//'.VALE','E',JDELTA)
      
      
C     PRODUIT SCALAIRE  NUMER=DIRECP' DIRECP
      NUMER = DDOT(NBLIAI,ZR(JSGPRE),1,ZR(JDIREP),1)


C     PRODUIT SCALAIRE  DENOM=DIRECP' A K-1 A' DIRECP
      DENOM = DDOT(NEQ,ZR(JDELTA),1,ZR(JSECMB),1)

      IF (DENOM.LT.0.D0) THEN
        CALL U2MESS('A','CONTACT_7')
      END IF

      ALPHA = NUMER/DENOM

      IF (NIV.EQ.2) THEN
        WRITE (IFM,9040) ALPHA
      END IF

C ======================================================================
C --- PROJECTION ET MISES A JOUR
C ======================================================================

C     PROJECTION DU PAS D'AVANCEMENT POUR RESPECTER LES CONTRAINTES
      IF (SEARCH.EQ.'ADMISSIBLE') THEN
      
        DO 60 ILIAC = 1,NBLIAI
          IF (ZR(JSGPRE-1+ILIAC).LT.0.D0) THEN
            ALPHA = MIN(ALPHA,-ZR(JMU-1+ILIAC)/ZR(JSGPRE-1+ILIAC))
          END IF
   60   CONTINUE

        IF (NIV.EQ.2) THEN
          WRITE (IFM,9050) ALPHA
        END IF

C       MISE A JOUR DE MU PUIS DE DELTA
        CALL DAXPY(NBLIAI,ALPHA,ZR(JSGPRE),1,ZR(JMU),1)
        CALL DAXPY(NEQ,-ALPHA,ZR(JDELTA),1,ZR(JRESU),1)


C     METHODE NON ADMISSIBLE DE CALCUL DU PAS D'AVANCEMENT
      ELSEIF (SEARCH.EQ.'NON_ADMISSIBLE') THEN
      
C       MISE A JOUR DE MU PUIS PROJECTION
        CALL DAXPY(NBLIAI,ALPHA,ZR(JSGPRE),1,ZR(JMU),1)
        DO 70 ILIAC = 1,NBLIAI
          IF (ZR(JMU-1+ILIAC).LT.0.D0) THEN
            ZR(JMU-1+ILIAC) = 0.D0
          END IF
   70   CONTINUE

C       K DELTA = A' MU+
        CALL R8INIR(NEQ,0.D0,ZR(JDELTA),1)
        DO 80 ILIAC = 1,NBLIAI
          JDECAL = ZI(JAPPTR+ILIAC-1)
          NBDDL = ZI(JAPPTR+ILIAC) - ZI(JAPPTR+ILIAC-1)
          CALL CALATM(NEQ,NBDDL,ZR(JMU-1+ILIAC),ZR(JAPCOE+JDECAL),
     &                ZI(JAPDDL+JDECAL),ZR(JDELTA))
   80   CONTINUE
        CALL DCOPY(NEQ,ZR(JDELTA),1,ZR(JSECMB),1)
        CALL RESOUD(MATASS,KBID,SECMBR,SOLVEU, VEZERO, 'V',
     &                     DELTAU, KBID)
        CALL JEVEUO(DELTAU(1:19)//'.VALE','E',JDELTA)
        CALL DCOPY(NEQ,ZR(JRESU0),1,ZR(JRESU),1)
        CALL DAXPY(NEQ,-1.D0,ZR(JDELTA),1,ZR(JRESU),1)

      ELSE
        CALL ASSERT(.FALSE.)
      END IF



C     ON VERIFIE SI L'ETAT DE CONTACT A CHANGE (ON NE CONJUGUE PAS)
C     ON REINITIALISE LA DIRECTION DE RECHERCHE TOUTES LES FREQ
C     ITERATIONS
      CONJUG = .TRUE.
      IF (MOD(ITER,FREQ).NE.0) THEN
        DO 90 II = 1,NBLIAI
          IF (((ZR(JMU-1+II).GT.TOLE).AND. (ZR(JMUM-1+II).LT.TOLE)) .OR.
     &        ((ZR(JMU-1+II).LT.TOLE).AND.
     &        (ZR(JMUM-1+II).GT.TOLE))) THEN
            CONJUG = .FALSE.
            IF (NIV.EQ.2) THEN
              WRITE (IFM,*) '<CONTACT> <>'//
     &          ' CHANGEMENT DE L''ETAT DE CONTACT'
            END IF
            GO TO 100

          END IF
   90   CONTINUE
      ELSE
        CONJUG = .FALSE.
      END IF
  100 CONTINUE


C     MISE � JOUR DES GRADIENTS ET DES DIRECTIONS DE RECHERCHE
      CALL DCOPY(NBLIAI,ZR(JSGRAP),1,ZR(JSGRAM),1)
      CALL DCOPY(NBLIAI,ZR(JSGPRE),1,ZR(JDIREM),1)
      CALL DCOPY(NBLIAI,ZR(JMU),1,ZR(JMUM),1)

      ITER = ITER + 1

C ======================================================================
C --- A-T-ON DEPASSE LE NOMBRE D'ITERATIONS DE CONTACT AUTORISE ?
C ======================================================================
      IF (ITER.GE.GCPMAX) THEN
        CALL U2MESI('A','CONTACT_2',1,GCPMAX)
        DO 150  II=1,NBLIAI
          JDECAL = ZI(JAPPTR+II-1)
          NBDDL = ZI(JAPPTR+II) - ZI(JAPPTR+II-1)
          CALL CALADU(NEQ,NBDDL,ZR(JAPCOE+JDECAL),ZI(JAPDDL+JDECAL),
     &                ZR(JRESU),VAL)
          AJEU = ZR(JAPJEU+II-1) - VAL
          IF ((ABS(AJEU).GT.AJEU).AND.(ZR(JMU-1+II).GT.TOLE)) THEN
             CALL CFIMP2(IFM,NOMA,II,TYPEC0,'N','AGC',AJEU,
     &                   JAPPAR,JNOCO,JMACO)
          END IF
 150    CONTINUE
        GO TO 110
      END IF


      GO TO 30

C ======================================================================
C =========================== ON A CONVERGE! ===========================
C ======================================================================

  110 CONTINUE
      

C     ON CALCULE L'INCREMENT DE MULTIPLICATEUR DMU=MU-MU0
C     CAR C'EST CE DONT LE CALCUL DU RESIDU GLOBAL A BESOIN
      CALL DCOPY(NBLIAI,ZR(JMU),1,ZR(JDMU),1)
      CALL DAXPY(NBLIAI,-1.D0,ZR(JMU0),1,ZR(JDMU),1)
C     ON RECOPIE LA VALEUR DE LA CORRECTION DANS L'OBJET 
      CALL DCOPY(NEQ,ZR(JDELTA),1,ZR(JDELT1),1)

      CALL INITIA(NEQ,.FALSE.,0,R8BID,ZR(JATMU))
      DO 120 ILIAC = 1,NBLIAI
        JDECAL = ZI(JAPPTR+ILIAC-1)
        NBDDL = ZI(JAPPTR+ILIAC) - ZI(JAPPTR+ILIAC-1)
        CALL CALATM(NEQ,NBDDL,ZR(JDMU-1+ILIAC),ZR(JAPCOE+JDECAL),
     &              ZI(JAPDDL+JDECAL),ZR(JATMU))
  120 CONTINUE

      NBLIAC = 0
      DO 130 II = 1,NBLIAI
        IF (ZR(JMU-1+II).GT.TOLE) THEN
          NBLIAC = NBLIAC + 1
          ZI(JLIAC-1+NBLIAC) = II
        END IF
  130 CONTINUE


C ======================================================================
C --- STOCKAGE DE L'ETAT DE CONTACT DEFINITIF
C ======================================================================
C --- VALEUR DES VARIABLES DE CONVERGENCE
      LICCVG(3) = 0
      LICCVG(4) = 0

      ZI(JCOCO+2) = NBLIAC

C ======================================================================
C --- CALCUL DU JEU FINAL
C ======================================================================
      CALL CFJEFI(NEQ,NBLIAI,JAPPTR,JAPCOE,JAPDDL,JRESU,JAPJEU,0,0)

C ======================================================================
C --- AFFICHAGE FINAL
C ======================================================================
      IF (NIV.GE.2) THEN
        WRITE (IFM,9020) ITER
        WRITE (IFM,9030) NBLIAC
        WRITE (IFM,*) '<CONTACT> <> LIAISONS FINALES '
        CALL CFIMP1(DEFICO,RESOCO,NOMA,NBLIAI,IFM)
      END IF

  140 CONTINUE

C ======================================================================
C --- SAUVEGARDE DES INFOS DE DIAGNOSTIC (NOMBRE D'ITERATIONS)
C ======================================================================
      CALL CFITER(RESOCO,'E','ITER',ITER,R8BID)

C ======================================================================
C --- DESTRUCTION DES VECTEURS INUTILES
C ======================================================================
      CALL JEDETR(SGRADM)
      CALL JEDETR(SGRADP)
      CALL JEDETR(DIRECM)
      CALL JEDETR(DIRECP)
      CALL JEDETR(SECMBR)
      CALL JEDETR(MUM)
      CALL JEDETR(MU0)
      CALL JEDETR(DELTAM)
      CALL JEDETR(VEZERO)
      CALL JEDETR(SGRPRE)
      CALL JEDETR(RESU0)

      CALL JEDEMA()

C ======================================================================

 9000 FORMAT (' <CONTACT> <> NOMBRE DE LIAISONS POSSIBLES: ',I8)
 9010 FORMAT (' <CONTACT> <> DEBUT DES ITERATIONS (MAX: ',I8,')')
 9020 FORMAT (' <CONTACT> <> FIN DES ITERATIONS (NBR: ',I8,')')
 9030 FORMAT (' <CONTACT> <> NOMBRE DE LIAISONS CONTACT FINALES:',I8,
     &       ')')
 9040 FORMAT (' <CONTACT> <> PAS D''AVANCEMENT INITIAL : ',1PE12.5)
 9050 FORMAT (' <CONTACT> <> PAS D''AVANCEMENT APRES PROJECTION : ',
     &       1PE12.5)
 9060 FORMAT (' <CONTACT> <> NORME INFINIE DU RESIDU : ',1PE12.5,' (CR',
     &       'ITERE: ',1PE12.5,')')
      END
