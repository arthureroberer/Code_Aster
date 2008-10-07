      SUBROUTINE NMDOET(RESULT,MODELE,COMPOR,CARELE,FONACT,
     &                  NUMEDD,SDSENS,SDPILO,SDDYNA,VALMOI,
     &                  SOLALG,LACC0 ,INSTIN)
C
C MODIF ALGORITH  DATE 07/10/2008   AUTEUR PELLET J.PELLET 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
C RESPONSABLE MABBAS M.ABBAS
C
      IMPLICIT     NONE
      REAL*8       INSTIN
      CHARACTER*8  RESULT
      CHARACTER*24 MODELE,COMPOR,CARELE,SDSENS
      CHARACTER*24 NUMEDD
      CHARACTER*24 VALMOI(8)
      CHARACTER*14 SDPILO
      CHARACTER*19 SDDYNA   
      CHARACTER*19 SOLALG(*)   
      LOGICAL      FONACT(*),LACC0      
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (INITIALISATION)
C
C SAISIE DES CHAMPS A L'ETAT INITIAL - STATIQUE
C      
C ----------------------------------------------------------------------
C
C
C IN  RESULT : NOM DU CONCEPT RESULTAT
C IN  MODELE : NOM DU MODELE
C IN  COMPOR : CARTE COMPORTEMENT
C IN  CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C IN  FONACT : FONCTIONNALITES ACTIVEES
C IN  NUMEDD : NUME_DDL
C IN  VALMOI : VARIABLE CHAPEAU POUR ETAT EN T-
C IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
C IN  SDSENS : SD SENSIBILITE
C IN  SDPILO : SD DE PILOTAGE
C IN  SDDYNA : SD DYNAMIQUE
C OUT LACC0  : .TRUE. SI ACCEL. INITIALE A CALCULER
C OUT INSTIN : INSTANT INITIAL
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ---------------------------
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
C --- FIN DECLARATIONS NORMALISEES JEVEUX -----------------------------
C
      LOGICAL      LBID,EVONOL,LNOCC
      INTEGER      NEQ,REENTR,NOCC,NUME,NCHOUT,IRET,IBID,I
      INTEGER      NRPASE,IER,JPLTK,IRETVI,IERR,IRETAC
      CHARACTER*8  LPAIN(1),LPAOUT(2),K8BID
      CHARACTER*8  NOPASE
      CHARACTER*16 OPT
      CHARACTER*24 LIGRMO,EVOL,LCHIN(1),LCHOUT(2)
      CHARACTER*24 K24BID,TYPECH
      CHARACTER*24 TYPPIL,TYPSEL,COMPOM
      CHARACTER*24 VALK(2)
      CHARACTER*19 NMCHEX,DEPOLD
      CHARACTER*24 DEPMOI,SIGMOI,VARMOI,VITMOI,ACCMOI
      CHARACTER*24 CHAMP,CHAMP2,CHGEOM,RESUID,STRUCT,DEP2,DEP1
      INTEGER      JDEP1,JDEP2,JDEPOL
      INTEGER      NBPASE 
      CHARACTER*24 SENSNB
      INTEGER      JSENSN 
      LOGICAL      ISFONC,LPILO,LPIARC,LCTCC
      LOGICAL      NDYNLO,LDYNA
      INTEGER      IFM,NIV
C      
C ----------------------------------------------------------------------
C      
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- INITIALISATIONS
C
      DEP1   = '&&CNPART.CHP1'
      DEP2   = '&&CNPART.CHP2'  
      COMPOM = ' '       
      LACC0  = .FALSE.
      LPIARC = .FALSE. 
      LNOCC  = .FALSE.
      CALL DISMOI('F','NOM_LIGREL',MODELE,'MODELE',IBID  ,LIGRMO,IRET  )
C      
C --- ACCES SD SENSIBILITE
C   
      SENSNB = SDSENS(1:16)//'.NBPASE '
      CALL JEVEUO(SENSNB,'L',JSENSN)
      NBPASE = ZI(JSENSN+1-1) 
C
C --- FONCTIONNALITES ACTIVEES
C
      LPILO  = ISFONC(FONACT,'PILOTAGE')
      LDYNA  = NDYNLO(SDDYNA,'DYNAMIQUE')  
      LCTCC  = ISFONC(FONACT,'CONT_CONTINU')    
C   
C --- EXTRACTION VARIABLES CHAPEAUX
C       
      DEPOLD = NMCHEX(SOLALG,'SOLALG','DEPOLD')
C
C --- NOMBRE EQUATIONS
C     
      CALL DISMOI('F','NB_EQUA',NUMEDD,'NUME_DDL',NEQ,K8BID,IRET)
C
C --- PILOTAGE LONGUEUR D'ARC AVEC ANGL_NORM_DEPL: IL FAUT LES DEUX
C --- DERNIERS DEPLACEMENTS POUR QUE CA MARCHE (CHAMP DEPOLD)
C  
      IF (LPILO) THEN
        CALL JEVEUO(SDPILO(1:14)//'.PLTK','L',JPLTK)
        TYPPIL = ZK24(JPLTK)
        TYPSEL = ZK24(JPLTK+5)
        LPIARC = .FALSE.
        IF (TYPPIL(1:8).EQ.'LONG_ARC') THEN
          IF (TYPSEL(1:14).EQ.'ANGL_NORM_DEPL') THEN
            LPIARC = .TRUE.
          ENDIF 
        ENDIF
      ENDIF                 
C          
C --- PAS D'ETAT INITIAL EN PRESENCE D'UN CONCEPT REENTRANT
C
      CALL GETFAC('ETAT_INIT',NOCC)
      CALL JEEXIN(RESULT//'           .DESC',REENTR)
      IF (NOCC.EQ.0) THEN 
        IF (REENTR.NE.0) THEN
          IF (NIV.GE.2) THEN
            WRITE (IFM,*) '<MECANONLINE> LECTURE ETAT INITIAL'
          ENDIF
          CALL U2MESS('A','MECANONLINE4_35')
        ENDIF
      ELSE
        IF (NIV.GE.2) THEN
          WRITE (IFM,*) '<MECANONLINE> LECTURE ETAT INITIAL'
        ENDIF         
      ENDIF   
      CALL GETVID('ETAT_INIT','EVOL_NOLI',1,1,1,EVOL,NOCC)
      EVONOL = NOCC .GT. 0
C
C --- ALARME SI CONTACT CONTINU AVEC UN CONCEPT REENTRANT
C
      IF (LCTCC) THEN
        IF (REENTR.NE.0) THEN
          CALL U2MESS('A','MECANONLINE_14')
        ELSE IF (EVONOL) THEN
          CALL U2MESS('A','MECANONLINE_15')
        ENDIF
      ENDIF       
C
C --- INSTANT INITIAL
C
      CALL NMDOIN(EVOL  ,EVONOL,INSTIN,NUME  )           
C 
C --- BOUCLE SUR L'INITIALISATION DES CHAMPS PRINCIPAUX ET DERIVES
C 
      DO 10 NRPASE = NBPASE,0,-1
C
C --- NOM DES CHAMPS
C       
        CALL NMNSLE(SDSENS,NRPASE,'DEPMOI',DEPMOI)
        CALL NMNSLE(SDSENS,NRPASE,'SIGMOI',SIGMOI)
        CALL NMNSLE(SDSENS,NRPASE,'VARMOI',VARMOI)
        IF (LDYNA) THEN
          CALL NMNSLE(SDSENS,NRPASE,'VITMOI',VITMOI)
          CALL NMNSLE(SDSENS,NRPASE,'ACCMOI',ACCMOI)         
        ENDIF
C        
        IF (EVONOL) THEN
C
C --- ETAT INITIAL DEFINI PAR UN CONCEPT DE TYPE EVOL_NOLI
C 
          IF ( NRPASE.GT.0 ) THEN
            CALL NMNSLE(SDSENS,NRPASE,'NOPASE',NOPASE)
            CALL PSGENC(EVOL  ,NOPASE,RESUID  ,IRET)
            IF ( IRET.NE.0 ) THEN
              VALK(1) = EVOL
              VALK(2) = NOPASE//'                '
              CALL U2MESK('F','SENSIBILITE_3', 2 ,VALK)
            ENDIF
            STRUCT = RESUID
          ELSE
            STRUCT = EVOL
          END IF
C
C --- LECTURE DES DEPLACEMENTS (OU DERIVE)
C
          CALL RSEXCH(STRUCT,'DEPL',NUME  ,CHAMP ,IRET  )
          IF (IRET.EQ.0) THEN  
            CALL VTCOPY(CHAMP,DEPMOI,IRET)
          ELSE
            CALL U2MESK('F','MECANONLINE4_41',1,STRUCT)
          ENDIF    
C
C --- VERIFICATION COMPATIBILITE PILOTAGE
C
          IF (LPIARC) THEN
            CALL RSEXCH(STRUCT,'DEPL',NUME-1,CHAMP2,IRET)     
            IF (IRET.NE.0) THEN
              CALL U2MESK('F','MECANONLINE_77',1,STRUCT)
            ENDIF
            CALL VTCOPY(CHAMP,DEP1,IRET)
            CALL VTCOPY(CHAMP2,DEP2,IRET)   
            CALL JEVEUO(DEP1(1:19)//'.VALE','L',JDEP1)
            CALL JEVEUO(DEP2(1:19)//'.VALE','L',JDEP2)
            CALL JEVEUO(DEPOLD(1:19)//'.VALE','E',JDEPOL)       
            DO 156 I = 1,NEQ
              ZR(JDEPOL-1+I) = ZR(JDEP1-1+I) - ZR(JDEP2-1+I)
 156        CONTINUE 
          ENDIF         
C
C --- LECTURE DES CONTRAINTES AUX POINTS DE GAUSS (OU DERIVE)
C
          CALL RSEXCH(STRUCT,'SIEF_ELGA',NUME,CHAMP,IRET)
          IF (IRET.EQ.0) THEN
            CALL COPISD('CHAMP_GD','V',CHAMP,SIGMOI)
          ELSE
C
C --- CONTRAINTES AUX NOEUDS : PASSAGE AUX POINTS DE GAUSS
C
            CALL RSEXCH(STRUCT,'SIEF_ELNO',NUME,CHAMP,IRET)
            IF (IRET.NE.0) THEN
              CALL U2MESK('F','MECANONLINE4_42',1,STRUCT)
            ENDIF  
            CALL COPISD('CHAM_ELEM_S','V',COMPOR,SIGMOI)
            CALL MENOGA('SIEF_ELGA_ELNO  ',LIGRMO,COMPOR,CHAMP,SIGMOI,
     &                  K24BID)
          END IF
C
C --- CHARGEMENTS DE TYPE PRECONTRAINTE (LE CAS ECHEANT)
C
          CALL NMSIGI(LIGRMO,COMPOR,SIGMOI)
C
C --- LECTURE DES VARIABLES INTERNES AUX POINTS DE GAUSS (OU DERIVE)
C
          CALL RSEXCH(STRUCT,'COMPORTEMENT',NUME,COMPOM,IRET)
          IF (IRET.NE.0) COMPOM = ' '

          CALL RSEXCH(STRUCT,'VARI_ELGA',NUME,CHAMP,IRET)
          IF (IRET.EQ.0) THEN
            CALL COPISD('CHAMP_GD','V',CHAMP,VARMOI)
            IF (NRPASE.EQ.NBPASE) CALL VRCOMP(COMPOM,COMPOR,VARMOI)
          ELSE
C
C --- VARIABLES INTERNES AUX NOEUDS : PASSAGE AUX POINTS DE GAUSS
C
            CALL RSEXCH(STRUCT,'VARI_ELNO',NUME,CHAMP,IRET)
            IF (IRET.NE.0) THEN
              CALL U2MESK('F','MECANONLINE4_46',1,STRUCT)
            ENDIF
            IF (NRPASE.EQ.NBPASE) CALL VRCOMP(COMPOM,COMPOR,CHAMP)
            CALL COPISD('CHAM_ELEM_S','V',COMPOR,VARMOI)
            CALL MENOGA('VARI_ELGA_ELNO  ',LIGRMO,COMPOR,CHAMP,VARMOI,
     &                  K24BID)
          END IF
C
C --- LECTURE DES VITESSES (OU DERIVE)
C
          IF (LDYNA) THEN
            CALL RSEXCH(STRUCT,'VITE',NUME,CHAMP,IRETVI)
            IF (IRETVI.NE.0) THEN
              CALL U2MESK('I','MECANONLINE4_43',1,EVOL)
              CALL NULVEC(VITMOI)
            ELSE
              CALL VTCOPY(CHAMP,VITMOI,IERR)
            END IF
          ENDIF
C
C --- LECTURE DES ACCELERATIONS (OU DERIVE)
C
          IF (LDYNA) THEN
            CALL RSEXCH(STRUCT,'ACCE',NUME,CHAMP,IRETAC)
            IF (IRETAC.NE.0) THEN
              IF (IRETVI.NE.0) THEN
                CALL U2MESK('I','MECANONLINE4_44',1,STRUCT)
                LACC0 = .TRUE.
              ELSE
                CALL U2MESK('F','MECANONLINE4_45',1,STRUCT)
              END IF
            ELSE
              CALL VTCOPY(CHAMP,ACCMOI,IERR)
            END IF 
          ENDIF             
        ELSE
C
C --- DEFINITION CHAMP PAR CHAMP (OU PAS D'ETAT INITIAL DU TOUT)
C 
          NCHOUT = 0
C
C --- LECTURE DES DEPLACEMENTS
C
          CALL GETVID('ETAT_INIT','DEPL',1,1,1,CHAMP,NOCC)
          IF (NOCC.NE.0) THEN
            CALL CHPVER('F',CHAMP(1:19),'NOEU','DEPL_R',IER)
            CALL VTCOPY(CHAMP,DEPMOI,IRET)
            IF (LPIARC) THEN
              CALL U2MESK('F','MECANONLINE_77',1,STRUCT)          
            ENDIF               
          ENDIF

          IF (NOCC.NE.0 .AND. NBPASE.GT.0) THEN
            CALL U2MESS('F','SENSIBILITE_21')
          ENDIF
C
C --- LECTURE DES CONTRAINTES AUX POINTS DE GAUSS
C
          CALL GETVID('ETAT_INIT','SIGM',1,1,1,CHAMP,NOCC)
          IF (NOCC.NE.0 .AND. NBPASE.GT.0 .AND. NRPASE.EQ.0 ) THEN
            CALL U2MESS('F','SENSIBILITE_21')
          ENDIF
C
C --- PREPARATION POUR CREER UN CHAMP NUL
C
          IF (NOCC.EQ.0) THEN
            NCHOUT = NCHOUT + 1
            LPAOUT(NCHOUT) = 'PSIEF_R'
            LCHOUT(NCHOUT) = SIGMOI
            CALL COPISD('CHAM_ELEM_S','V',COMPOR,SIGMOI)
          ELSE
            CALL CHPVER('F',CHAMP(1:19),'*','SIEF_R',IER)
            CALL DISMOI('F','TYPE_CHAMP',CHAMP,'CHAMP',IBID,TYPECH,IRET)
            IF (TYPECH.EQ.'ELNO') THEN
              CALL COPISD('CHAM_ELEM_S','V',COMPOR,SIGMOI)
              CALL MENOGA('SIEF_ELGA_ELNO  ',LIGRMO,COMPOR,CHAMP,SIGMOI,
     &                    K24BID)
            ELSE
              CALL COPISD('CHAMP_GD','V',CHAMP,SIGMOI)
            END IF
          END IF
C
C --- LECTURE DES VARIABLES INTERNES
C
          CALL GETVID('ETAT_INIT','VARI',1,1,1,CHAMP,NOCC)

          IF (NOCC.NE.0 .AND. NBPASE.GT.0) THEN
            CALL U2MESS('F','SENSIBILITE_21')
          ENDIF
C
C --- PREPARATION POUR CREER UN CHAMP NUL
C
          IF (NOCC.EQ.0) THEN
            NCHOUT = NCHOUT + 1
            LPAOUT(NCHOUT) = 'PVARI_R'
            LCHOUT(NCHOUT) = VARMOI
            CALL COPISD('CHAM_ELEM_S','V',COMPOR,VARMOI)

          ELSE
            CALL CHPVER('F',CHAMP(1:19),'ELXX','VARI_R',IER)
            CALL DISMOI('F','TYPE_CHAMP',CHAMP,'CHAMP',IBID,TYPECH,IRET)
            IF (TYPECH.EQ.'ELNO') THEN
              IF (NRPASE.EQ.NBPASE) CALL VRCOMP(' ',COMPOR,CHAMP)
              CALL COPISD('CHAM_ELEM_S','V',COMPOR,VARMOI)
              CALL MENOGA('VARI_ELGA_ELNO  ',LIGRMO,COMPOR,CHAMP,VARMOI,
     &                    K24BID)
            ELSE
              CALL COPISD('CHAMP_GD','V',CHAMP,VARMOI)
              IF (NRPASE.EQ.NBPASE) CALL VRCOMP(' ',COMPOR,VARMOI)
            END IF
          END IF
C
C --- CREATION DES CHAM_ELEM DE CONTRAINTES ET DE VARI. INTERNES NULS
C
          IF (NCHOUT.GT.0) THEN
            CALL MEGEOM(MODELE,' ',LBID,CHGEOM)
            LCHIN(1) = CHGEOM
            LPAIN(1) = 'PGEOMER'
            OPT = 'TOU_INI_ELGA'
            CALL CALCUL('S',OPT,LIGRMO,1,LCHIN,LPAIN,NCHOUT,LCHOUT,
     &                  LPAOUT,'V')
            CALL NMSIGI(LIGRMO,COMPOR,SIGMOI)
          END IF    
C
C --- LECTURE DES VITESSES
C
          IF (LDYNA) THEN
            CALL GETVID('ETAT_INIT','VITE',1,1,1,CHAMP,NOCC)
            LNOCC=(LNOCC.OR.(NOCC.NE.0))
            IF (NOCC.NE.0) THEN
              CALL CHPVER('F',CHAMP(1:19),'NOEU','DEPL_R',IERR)
              CALL VTCOPY(CHAMP,VITMOI,IERR)
            ELSE
              CALL U2MESS('I','MECANONLINE_22')
              CALL NULVEC(VITMOI)
            END IF    
          ENDIF      
C
C --- LECTURE DES ACCELERATIONS
C
          IF (LDYNA) THEN
            CALL GETVID('ETAT_INIT','ACCE',1,1,1,CHAMP,NOCC)
            IF (NOCC.NE.0) THEN
              CALL CHPVER('F',CHAMP(1:19),'NOEU','DEPL_R',IERR)
              CALL VTCOPY(CHAMP,ACCMOI,IERR)
            ELSE
              LACC0 = .TRUE.
            END IF
          ENDIF         
        END IF
   10 CONTINUE
C
C --- AFFICHAGES
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> ... DEPMOI : '
        CALL NMDEBG('VECT',DEPMOI,IFM)      
        WRITE (IFM,*) '<MECANONLINE> ... SIGMOI : '
        CALL NMDEBG('CHEL',SIGMOI,IFM)  
        WRITE (IFM,*) '<MECANONLINE> ... VARMOI : '
        CALL NMDEBG('CHEL',VARMOI,IFM)   
        IF (LDYNA) THEN  
          WRITE (IFM,*) '<MECANONLINE> ... VITMOI : ' 
          CALL NMDEBG('VECT',VITMOI,IFM) 
          IF (.NOT.LACC0) THEN
            WRITE (IFM,*) '<MECANONLINE> ... ACCMOI : ' 
            CALL NMDEBG('VECT',ACCMOI,IFM)           
          ENDIF
        ENDIF      
      ENDIF  
C
C --- CHARGEMENT GRAPPE FLUIDE
C
      IF (LDYNA) THEN
        CALL NMGRIN(NUMEDD,SDDYNA,VALMOI,NUME  )        
      ENDIF  
C    
      CALL JEDEMA()
      END
