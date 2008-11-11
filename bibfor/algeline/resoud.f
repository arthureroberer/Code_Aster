      SUBROUTINE RESOUD(MATASS,MATPRE,CHSECM,SOLVEU,CHCINE,BASE,CHSOLU,
     &                  CRITER,NSECM,RSOLU,CSOLU)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 10/11/2008   AUTEUR PELLET J.PELLET 
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
C BUT : RESOUDRE UN SYSTEME LINEAIRE D'EQUATIONS (REEL OU COMPLEXE)
C-----------------------------------------------------------------------
C
C ARGUMENTS:
C-----------

C REMARQUES : ON PEUT APPELER RESOUD DE 2 FACONS :
C   1) AVEC NSECM = 0 + (CHSECM, CHSOLU, BASE)
C   2) AVEC NSECM > 0 + RSOLU (OU CSOLU) (CHSECM=CHSOLU=' ')
C      DANS CE CAS (NSECM > 0) :
C        * LE SOLVEUR FETI EST (ET RESTERA) IMPOSSIBLE
C        * LE SOLVEUR PETSC EST A PROGRAMMER
C
C IN/JXIN  K19 MATASS : MATR_ASSE PREMIER MEMBRE DU SYSTEME LINEAIRE
C IN/JXIN  K19 MATPRE :
C       MATR_ASSE DE PRECONDITIONNEMENT SI SOLVEUR ITERATIF (OU ' ')
C IN       I   NSECM  : / 0 => ON UTILISE CHSECM, CHSOLU, BASE
C                       / N => ON UTILISE RSOLU (OU CSOLU)
C                         N : NOMBRE DE SECONDS MEMBRES
C IN/JXIN  K*  CHSECM : CHAMP SECOND MEMBRE DU SYSTEME LINEAIRE
C IN/JXIN  K19 SOLVEU : SD_SOLVEUR  (OU ' ')
C       SI SOLVEU=' ' : ON PREND LE SOLVEUR PAR DEFAUT DE MATASS
C IN/JXIN  K*  CHCINE : CHAMP ASSOCIE AUX CHARGES CINEMATIQUES (OU ' ')
C IN       K*  BASE   : BASE SUR LAQUELLE ON CREE CHSOLU
C IN/JXOUT K*  CHSOLU : CHAMP SOLUTION
C IN/JXOUT K*  CRITER : SD_CRITER (CRITERES DE CONVERGENCE)
C                       SI CRITER=' ', ON NE LE CALCULE PAS
C IN/OUT   R   RSOLU(*,NSECM)  :
C        EN ENTREE : VECTEUR DE REELS CONTENANT LES SECONDS MEMBRES
C        EN SORTIE : VECTEUR DE REELS CONTENANT LES SOLUTIONS
C IN/OUT   C   CSOLU(*,NSECM)  : IDEM RSOLU POUR LES COMPLEXES.
C-----------------------------------------------------------------------
      IMPLICIT NONE

      CHARACTER*(*) BASE,CHSECM,CHCINE,MATASS,MATPRE,CHSOLU
      CHARACTER*(*) CRITER,SOLVEU
      INTEGER NSECM
      REAL*8 RSOLU(*)
      COMPLEX*16 CSOLU(*)

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC,CBID
      COMMON /CVARJE/ZC(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      INTEGER IBID,IFM,NIV
      REAL*8 TEMPS(6)
      CHARACTER*24 METRES
      CHARACTER*3 KMPIC,TYPE,TYP1,KBID
      CHARACTER*19 MATR19,MPRE19,CSOL19
      CHARACTER*19 CINE19,SECM19,SOLV19,CRIT19

      INTEGER JSLVK,JSLVR,JSLVI,IDBGAV,NEQ,NEQ1
      INTEGER IRET,NITER,LMAT,JVALS,JTRAV,JVAL2
      REAL*8 EPSI,RBID
      LOGICAL DBG
      CHARACTER*1 FTYPE(2)
      DATA FTYPE/'R','C'/
C ----------------------------------------------------------------------
      DBG=.TRUE.
      DBG=.FALSE.

      CALL JEMARQ()
      CALL JEDBG2(IDBGAV,0)
      CALL INFNIV(IFM,NIV)

      MATR19=MATASS
      MPRE19=MATPRE
      SECM19=CHSECM
      CSOL19=CHSOLU
      SOLV19=SOLVEU
      CINE19=CHCINE
      CRIT19=CRITER

      CALL ASSERT(MATR19.NE.' ')
      CALL DISMOI('F','MPI_COMPLET',MATR19,'MATR_ASSE',IBID,KMPIC,IBID)


      IF (SOLV19.EQ.' ') CALL DISMOI('F','SOLVEUR',MATR19,'MATR_ASSE',
     &                               IBID,SOLV19,IBID)
      CALL JEVEUO(SOLV19//'.SLVK','L',JSLVK)
      CALL JEVEUO(SOLV19//'.SLVR','L',JSLVR)
      CALL JEVEUO(SOLV19//'.SLVI','L',JSLVI)
      METRES=ZK24(JSLVK)
      CALL ASSERT(METRES.NE.' ')
      IF (KMPIC.EQ.'NON') CALL ASSERT(METRES.EQ.'FETI' .OR.
     &                                METRES.EQ.'MUMPS')


C     -- SI 'FETI', ON NE PEUT PAS APPELER MTDSCR :
      IF (METRES.NE.'FETI') THEN
        CALL MTDSCR(MATR19)
        CALL JEVEUO(MATR19//'.&INT','L',LMAT)
        NEQ=ZI(LMAT+2)
        TYPE=FTYPE(ZI(LMAT+3))
      ELSE
        IF (NSECM.GE.1) CALL U2MESS('F','FACTOR_13')
      ENDIF

      CALL ASSERT(NSECM.GE.0)
      IF (NSECM.EQ.0) THEN
        CALL ASSERT(SECM19.NE.' ')
        CALL ASSERT(CSOL19.NE.' ')
        IF (CSOL19.NE.SECM19) THEN
          CALL DETRSD('CHAMP_GD',CSOL19)
          CALL VTDEFS(CSOL19,SECM19,BASE,' ')
        ENDIF
        IF (METRES.NE.'FETI') THEN
          CALL JELIRA(SECM19//'.VALE','LONMAX',NEQ1,KBID)
          CALL JELIRA(SECM19//'.VALE','TYPE',IBID,TYP1)
          IF (NEQ1.NE.NEQ) CALL U2MESS('F','FACTOR_67')
          IF (TYP1.NE.TYPE) CALL U2MESS('F','FACTOR_68')

          CALL JEVEUO(SECM19//'.VALE','L',JVAL2)
          CALL WKVECT('&&RESOUD.TRAV','V V '//TYPE,NEQ,JTRAV)
          CALL JACOPO(NEQ,TYPE,JVAL2,JTRAV)
        ENDIF
      ELSE
        CALL ASSERT(SECM19.EQ.' ')
        CALL ASSERT(CSOL19.EQ.' ')
      ENDIF

      IF ((CINE19.NE.' ').AND.(METRES.NE.'FETI')) THEN
        CALL JELIRA(CINE19//'.VALE','TYPE',IBID,TYP1)
        CALL ASSERT(TYP1.EQ.TYPE)
      ENDIF





      IF (DBG) THEN
        IF (.NOT.(METRES.EQ.'FETI')) CALL CHEKSD(MATR19,'SD_MATR_ASSE',
     &      IRET)
        IF (NSECM.EQ.0) CALL DBGOBJ(SECM19//'.VALE','OUI',6,
     &                              '&&RESOUD 2ND MEMBRE')
        CALL DBGOBJ(CINE19//'.VALE','OUI',6,'&&RESOUD CINE19')
        CALL DBGOBJ(MATR19//'.VALM','OUI',6,'&&RESOUD MATR.VALM')
        CALL DBGOBJ(MATR19//'.VALF','OUI',6,'&&RESOUD MATR.VALF')
        CALL DBGOBJ(MATR19//'.CONL','OUI',6,'&&RESOUD MATR.CONL')
        CALL DBGOBJ(MATR19//'.CCVA','OUI',6,'&&RESOUD MATR.CCVA')
      ENDIF



      IF (NIV.GE.2) THEN
        CALL UTTCPU(53,'INIT ',6,TEMPS)
        CALL UTTCPU(53,'DEBUT',6,TEMPS)
      ENDIF




      IF (METRES.EQ.'LDLT' .OR. METRES.EQ.'MULT_FRO') THEN
C     ----------------------------------------------------
        IF (NSECM.GT.0) THEN
          CALL RESLDL(SOLV19,MATR19,CINE19,NSECM,RSOLU,CSOLU)
        ELSE
          IF (TYPE.EQ.'R') THEN
            CALL RESLDL(SOLV19,MATR19,CINE19,1,ZR(JTRAV),CBID)
          ELSE
            CALL RESLDL(SOLV19,MATR19,CINE19,1,RBID,ZC(JTRAV))
          ENDIF
        ENDIF



      ELSEIF (METRES.EQ.'MUMPS') THEN
C     ----------------------------------------------------
        IF (NSECM.GT.0) THEN
          CALL AMUMPS('RESOUD',SOLV19,MATR19,RSOLU,CSOLU,
     &                 CINE19,NSECM,IRET)
        ELSE
          IF (TYPE.EQ.'R') THEN
            CALL AMUMPS('RESOUD',SOLV19,MATR19,ZR(JTRAV),CBID,
     &                 CINE19,1,IRET)
          ELSE
            CALL AMUMPS('RESOUD',SOLV19,MATR19,RBID,ZC(JTRAV),
     &                 CINE19,1,IRET)
          ENDIF
        ENDIF
        CALL ASSERT(IRET.EQ.0)



      ELSEIF (METRES.EQ.'FETI') THEN
C     ----------------------------------
        CALL RESFET(MATR19,CINE19,SECM19,CSOL19,NITER,CRIT19,SOLV19)



      ELSEIF (METRES.EQ.'GCPC') THEN
C     ----------------------------------
        NITER=ZI(JSLVI+1)
        EPSI=ZR(JSLVR+1)
        CALL ASSERT(TYPE.EQ.'R')
        IF (NSECM.GT.0) THEN
          CALL RESGRA(MATR19,MPRE19,CINE19,NITER,EPSI,CRIT19,NSECM,
     &                RSOLU)
        ELSE
          CALL RESGRA(MATR19,MPRE19,CINE19,NITER,EPSI,CRIT19,1,
     &                ZR(JTRAV))
        ENDIF



      ELSEIF (METRES.EQ.'PETSC') THEN
C     ----------------------------------
        CALL ASSERT(TYPE.EQ.'R')
        IF (NSECM.GT.0) THEN
          CALL APETSC('RESOUD',SOLV19,MATR19,RSOLU,CINE19,NSECM,IRET)
        ELSE
          CALL APETSC('RESOUD',SOLV19,MATR19,ZR(JTRAV),CINE19,1,IRET)
        ENDIF
        CALL ASSERT(IRET.EQ.0)



      ELSE
        CALL U2MESK('F','ALGELINE3_44',1,METRES)
      ENDIF


      IF (NIV.GE.2) THEN
        CALL UTTCPU(53,'FIN  ',6,TEMPS)
        WRITE (IFM,'(A44,D11.4,D11.4)')
     &    'TEMPS CPU/SYS SOLVEUR                     : ',TEMPS(5),
     &    TEMPS(6)
      ENDIF


C     -- RECOPIE DANS LE CHAMP SOLUTION S'IL Y LIEU :
      IF ((NSECM.EQ.0).AND.(METRES.NE.'FETI')) THEN
        CALL JEVEUO(CSOL19//'.VALE','E',JVALS)
        CALL JACOPO(NEQ,TYPE,JTRAV,JVALS)
      ENDIF
      CALL JEDETR('&&RESOUD.TRAV')




      IF (DBG.AND.(NSECM.EQ.0)) CALL DBGOBJ(CSOL19//'.VALE','OUI',6,
     &                              '&&RESOUD SOLU')


      CALL JEDBG2(IBID,IDBGAV)
      CALL JEDEMA()
      END
