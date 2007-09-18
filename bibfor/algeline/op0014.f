      SUBROUTINE OP0014(IER)
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER IER
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 18/09/2007   AUTEUR DURAND C.DURAND 
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
C     OPERATEUR FACT_LDLT

C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

      CHARACTER*3 KSTOP,MUMPS,KLAG2
      CHARACTER*24 VALK(2)
      CHARACTER*8 MATASS,MATFAC,TYPE,PRECON,KTYPR,KTYPS
      CHARACTER*16 CONCEP,NOMCMD,METHOD
      CHARACTER*19 MASS,MFAC,SOLVEU
      INTEGER NPREC,IATFAC,IBDEB,IBFIN,IBID,IER1,IFM,ILDEB,ILFIN
      INTEGER IRET,ISINGU,ISTOP,JADIA,PCPIV
      INTEGER LDTBLO,LFNBLO,NDECI,NEQ,NIV,NPVNEG
      LOGICAL LPRECO
C     ------------------------------------------------------------------
      CALL JEMARQ()

      CALL INFMAJ
      CALL INFNIV(IFM,NIV)


      CALL GETRES(MATFAC,CONCEP,NOMCMD)
      MFAC = MATFAC
      CALL GETVID('  ','MATR_ASSE',0,1,1,MATASS,IBID)
      MASS = MATASS


      CALL GETVIS('  ','NPREC',0,1,1,NPREC,IBID)
      CALL GETVTX('  ','STOP_SINGULIER',0,1,1,KSTOP,IBID)
      IF (KSTOP.EQ.'OUI') THEN
        ISTOP = 0
      ELSE IF (KSTOP.EQ.'NON') THEN
        ISTOP = 1
      END IF


C     CAS DU SOLVEUR MUMPS :
C     ----------------------
      CALL DISMOI('F','EST_MUMPS',MASS,'MATR_ASSE',IBID,MUMPS,IER1)
      IF (MUMPS.EQ.'OUI') THEN
         IF (MASS.NE.MFAC) CALL COPISD('MATR_ASSE','G',MASS,MFAC)
         CALL DISMOI('F','SOLVEUR',MASS,'MATR_ASSE',IBID,SOLVEU,IER1)
         CALL GETVIS(' ','PCENT_PIVOT',1,1,1,PCPIV,IBID)
         CALL GETVTX(' ','TYPE_RESOL',1,1,1,KTYPR,IBID)
         CALL GETVTX(' ','SCALING',1,1,1,KTYPS,IBID)
         CALL GETVTX(' ','ELIM_LAGR2',1,1,1,KLAG2,IBID)
         CALL JEVEUO(SOLVEU//'.SLVI','E',JSLVI)
         CALL JEVEUO(SOLVEU//'.SLVK','E',JSLVK)
         ZI(JSLVI-1+2)=PCPIV
         ZI(JSLVI-1+3)=ISTOP
         ZK24(JSLVK-1+2)=KTYPS
         ZK24(JSLVK-1+3)=KTYPR
         ZK24(JSLVK-1+6)=KLAG2
         CALL AMUMPS('DETR_MAT',' ',MFAC,' ',' ',' ',IRET)
         CALL AMUMPS('PRERES',SOLVEU,MFAC,' ',' ',' ',IRET)
         IF (IRET.NE.0) CALL U2MESS('F','FACTOR_42')
         GO TO 9999
      END IF


C     --- RECUPERATION DES INDICES DE DEBUT ET FIN DE LA FACTORISATION -
C     - 1) AVEC DDL_XXX
      ILDEB = 1
      ILFIN = 0
      CALL GETVIS('  ','DDL_DEBUT',0,1,1,ILDEB,IBID)
      CALL GETVIS('  ','DDL_FIN',0,1,1,ILFIN,IBID)
C     - 2) AVEC BLOC_XXX
      IBDEB = 1
      IBFIN = 0
      CALL GETVIS('  ','BLOC_DEBUT',0,1,1,IBDEB,LDTBLO)
      CALL GETVIS('  ','BLOC_FIN',0,1,1,IBFIN,LFNBLO)


C     --- EXISTENCE / COMPATIBILITE DES MATRICES ---
      CALL MTEXIS(MFAC,IRET)
      IF (IRET.NE.0) THEN
        CALL VRREFE(MASS,MFAC,IER1)
        IF (IER1.NE.0) THEN
           VALK(1) = MATASS
           VALK(2) = MATFAC
           CALL U2MESK('F','ALGELINE2_18', 2 ,VALK)
        ELSE IF (MFAC.NE.MASS) THEN
          IF (ILDEB.EQ.1 .AND. IBDEB.EQ.1) THEN
            CALL MTCOPY(MASS,MFAC,IRET)
            CALL ASSERT(IRET.EQ.0)
          END IF
        END IF
      ELSE
        TYPE = ' '
        CALL MTDEFS(MFAC,MASS,'GLOBALE',TYPE)
        CALL MTCOPY(MASS,MFAC,IRET)
        CALL ASSERT(IRET.EQ.0)
      END IF

C     --- CHARGEMENT DES DESCRIPTEURS DE LA MATRICE A FACTORISER ---
      CALL MTDSCR(MFAC)
      CALL JEVEUO(MFAC(1:19)//'.&INT','E',IATFAC)
      IF (IATFAC.EQ.0) THEN
        CALL U2MESK('F','ALGELINE2_19',1,MATFAC)
      END IF
      CALL MTDSC2(ZK24(ZI(IATFAC+1)),'SXDI','L',JADIA)

C     --- NEQ : NOMBRE D'EQUATIONS (ORDRE DE LA MATRICE) ---
      NEQ = ZI(IATFAC+2)

C     --- VERIFICATION DES ARGUMENTS RELATIF A LA PARTIE A FACTORISER --
C     --- 1) AVEC DDL_XXX
      IF (ILFIN.LT.ILDEB .OR. ILFIN.GT.NEQ) ILFIN = NEQ

C     --- 2) AVEC BLOC_XXX
      IF (LDTBLO.NE.0) THEN
        IF (IBDEB.LT.1) THEN
          WRITE (IFM,*) 'FACT_LDLT',
     &      'L''ARGUMENT DE "BLOC_DEBUT" DOIT ETRE'//
     &      ' STRICTEMENT POSITIF, IL EST PRIS A 1'
          IBDEB = 1
        ELSE IF (IBDEB.GT.ZI(IATFAC+13)) THEN
          CALL U2MESS('F','ALGELINE2_20')
        END IF
        ILDEB = ZI(JADIA+IBDEB-2) + 1
      END IF
      IF (LFNBLO.NE.0) THEN
        IF (IBFIN.LT.1) THEN
          CALL U2MESS('F','ALGELINE2_21')
        ELSE IF (IBDEB.GT.ZI(IATFAC+13)) THEN
          WRITE (IFM,*) 'FACT_LDLT',
     &      'L''ARGUMENT DE "BLOC_FIN" EST PLUS '//
     &      'GRAND QUE LE NOMBRE DE BLOC DE LA MATRICE, '//
     &      ' IL EST RAMENE A CETTE VALEUR.'
          IBFIN = ZI(IATFAC+13)
        END IF
        ILFIN = ZI(JADIA+IBFIN-1)
      END IF

C     --- RECUPERATION DU TYPE DE CONDITIONNEMENT MATRICIEL ---
      PRECON = '  '
      CALL GETVTX('  ','PRE_COND',0,1,1,PRECON,IBID)
      LPRECO = PRECON(1:4) .EQ. 'DIAG'



C     --- IMPRESSION SUR LE FICHIER MESSAGE ----------------------------
      IF (NIV.EQ.2) THEN
        WRITE (IFM,*) ' +++ EXECUTION DE "',NOMCMD,'"'
        WRITE (IFM,*) '       NOM DE LA MATRICE ASSEMBLEE  "',MATASS,'"'
        WRITE (IFM,*) '       NOM DE LA MATRICE FACTORISEE "',MATFAC,'"'
        IF (ILDEB.EQ.1 .AND. ILFIN.EQ.NEQ) THEN
          WRITE (IFM,*) '     FACTORISATION COMPLETE DEMANDEE'
        ELSE
          WRITE (IFM,*) '     FACTORISATION PARTIELLE DE LA LIGNE',
     &      ILDEB,' A LA LIGNE ',ILFIN
        END IF
        WRITE (IFM,*) '     NOMBRE TOTAL D''EQUATIONS  ',NEQ
        WRITE (IFM,*) '     NB. DE CHIFFRES SIGNIF. (NPREC) ',NPREC
        WRITE (IFM,*) ' +++ -------------------------------------------'
      END IF

C     ------------------ FACTORISATION EFFECTIVE -------------------
      IF (LPRECO) CALL MTCOND(IATFAC,'GLOBALE')
      CALL TLDLGG(ISTOP,IATFAC,ILDEB,ILFIN,NPREC,NDECI,ISINGU,NPVNEG,
     &            IRET)
C     --------------------------------------------------------------

      CALL JEDETR(MFAC//'.&VDI')
      CALL JEDETR(MFAC//'.&TRA')

 9999 CONTINUE
      CALL TITRE
      CALL JEDEMA()
      END
