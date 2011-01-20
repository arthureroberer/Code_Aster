      SUBROUTINE XMMBCA(NOMA,NOMO,MATE,RESOCO,VALINC,MMCVCA)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/01/2011   AUTEUR MASSIN P.MASSIN 
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
C RESPONSABLE GENIAUT S.GENIAUT
C
      IMPLICIT NONE
      LOGICAL       MMCVCA
      CHARACTER*8   NOMA  ,NOMO
      CHARACTER*24  RESOCO,MATE
      CHARACTER*19  VALINC(*)
C
C ----------------------------------------------------------------------
C
C ROUTINE XFEM (METHODE XFEM - ALGORITHME)
C
C MISE � JOUR DU STATUT DES POINTS DE CONTACT
C RENVOIE MMCVCA (INDICE DE CONVERGENCE DE LA BOUCLE
C                         SUR LES CONTRAINTES ACTIVES)
C
C ----------------------------------------------------------------------
C
C
C IN  NOMO   : NOM DE L'OBJET MOD�LE
C IN  NOMA   : NOM DE L'OBJET MAILLAGE
C IN  MATE   : SD MATERIAU
C IN  RESOCO : SD CONTACT (RESOLUTION)
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C OUT MMCVCA : INDICE DE CONVERGENCE DE LA BOUCLE SUR LES C.A.
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      NBOUT,NBIN
      PARAMETER    (NBOUT=4, NBIN=15)
      CHARACTER*8  LPAOUT(NBOUT),LPAIN(NBIN)
      CHARACTER*19 LCHOUT(NBOUT),LCHIN(NBIN)
C
      INTEGER      IBID,SINCO,NBMA
      INTEGER      JFISS
      REAL*8       RBID
      COMPLEX*16   CBID
      CHARACTER*19 XDONCO,XINDCO,XMEMCO,XGLISS,XCOHES,CCOHES
      CHARACTER*16 OPTION
      CHARACTER*8  K8BID
      CHARACTER*19 LIGRMO,CICOCA,CINDOO,CMEMCO,LTNO
      CHARACTER*19 PINTER,AINTER,CFACE ,FACLON,BASECO,XCOHEO
      INTEGER      JXC
      LOGICAL      DEBUG,LCONTX
      INTEGER      IFM,NIV,IFMDBG,NIVDBG
      CHARACTER*19 OLDGEO,DEPMOI,DEPPLU
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('XFEM',IFM,NIV)
      CALL INFDBG('PRE_CALCUL',IFMDBG,NIVDBG)
C
C --- INITIALISATIONS
C
      OLDGEO = NOMA(1:8)//'.COORDO'
      LIGRMO = NOMO(1:8)//'.MODELE'
      CICOCA = '&&XMMBCA.CICOCA'
      CINDOO = '&&XMMBCA.INDOUT'
      CMEMCO = '&&XMMBCA.MEMCON'
      CCOHES = '&&XMMBCA.COHES'
            
      XINDCO = RESOCO(1:14)//'.XFIN'
      XDONCO = RESOCO(1:14)//'.XFDO'
      XMEMCO = RESOCO(1:14)//'.XMEM'
      XGLISS = RESOCO(1:14)//'.XFGL'
      XCOHES = RESOCO(1:14)//'.XCOH'
      XCOHEO = RESOCO(1:14)//'.XCOP'
            
      MMCVCA = .FALSE.
      OPTION = 'XCVBCA'
      IF (NIVDBG.GE.2) THEN
        DEBUG  = .TRUE.
      ELSE
        DEBUG  = .FALSE.
      ENDIF
      CALL DISMOI('F','NB_MA_MAILLA',NOMA,'MAILLAGE',NBMA,K8BID,IBID)
C
C --- DECOMPACTION DES VARIABLES CHAPEAUX
C
      CALL NMCHEX(VALINC,'VALINC','DEPMOI',DEPMOI)
      CALL NMCHEX(VALINC,'VALINC','DEPPLU',DEPPLU)
C
C --- SI PAS DE CONTACT ALORS ON ZAPPE LA V�RIFICATION
C
      CALL JEVEUO(NOMO(1:8)//'.XFEM_CONT'  ,'L',JXC)
      LCONTX = ZI(JXC) .GE. 1
      IF (.NOT.LCONTX) THEN
        MMCVCA = .TRUE.
        GOTO 9999
      ENDIF
C
C --- INITIALISATION DES CHAMPS POUR CALCUL
C
      CALL INICAL(NBIN  ,LPAIN ,LCHIN ,
     &            NBOUT ,LPAOUT,LCHOUT)
C
C --- ACCES A LA SD FISS_XFEM
C
      CALL JEVEUO(NOMO(1:8)//'.FISS','L',JFISS)
C
C --- CREATION DU CHAM_ELEM_S VIERGE  INDIC. CONTACT ET MEMOIRE CONTACT
C
      CALL XMCHEX(NOMA  ,NBMA  ,CINDOO)
      CALL XMCHEX(NOMA  ,NBMA  ,CMEMCO)
      CALL XMCHEX(NOMA  ,NBMA  ,CCOHES)      
C
C --- RECUPERATION DES DONNEES XFEM
C
      LTNO   = NOMO(1:8)//'.LTNO'
      PINTER = NOMO(1:8)//'.TOPOFAC.OE'
      AINTER = NOMO(1:8)//'.TOPOFAC.AI'
      CFACE  = NOMO(1:8)//'.TOPOFAC.CF'
      FACLON = NOMO(1:8)//'.TOPOFAC.LO'
      BASECO = NOMO(1:8)//'.TOPOFAC.BA'
C
C --- CREATION DES LISTES DES CHAMPS IN
C
      LPAIN(1)  = 'PGEOMER'
      LCHIN(1)  = OLDGEO(1:19)
      LPAIN(2)  = 'PDEPL_M'
      LCHIN(2)  = DEPMOI(1:19)
      LPAIN(3)  = 'PDEPL_P'
      LCHIN(3)  = DEPPLU(1:19)
      LPAIN(4)  = 'PINDCOI'
      LCHIN(4)  = XINDCO
      LPAIN(5)  = 'PLST'
      LCHIN(5)  = LTNO
      LPAIN(6)  = 'PPINTER'
      LCHIN(6)  = PINTER
      LPAIN(7)  = 'PAINTER'
      LCHIN(7)  = AINTER
      LPAIN(8)  = 'PCFACE'
      LCHIN(8)  = CFACE
      LPAIN(9)  = 'PLONCHA'
      LCHIN(9)  = FACLON
      LPAIN(10) = 'PDONCO'
      LCHIN(10) = XDONCO
      LPAIN(11) = 'PGLISS'
      LCHIN(11) = XGLISS
      LPAIN(12) = 'PMEMCON'
      LCHIN(12) = XMEMCO
      LPAIN(13) = 'PCOHES'
      LCHIN(13) = XCOHES
      LPAIN(14) = 'PBASECO'
      LCHIN(14) = BASECO
      LPAIN(15) = 'PMATERC'
      LCHIN(15) = MATE(1:19)    

C
C --- CREATION DES LISTES DES CHAMPS OUT
C
      LPAOUT(1) = 'PINCOCA'
      LCHOUT(1) = CICOCA
      LPAOUT(2) = 'PINDCOO'
      LCHOUT(2) = CINDOO
      LPAOUT(3) = 'PINDMEM'
      LCHOUT(3) = CMEMCO
      LPAOUT(4) = 'PCOHESO'
      LCHOUT(4) = CCOHES
C
C --- APPEL A CALCUL
C
      CALL CALCUL('S',OPTION,LIGRMO,NBIN  ,LCHIN ,LPAIN,
     &                              NBOUT ,LCHOUT,LPAOUT,'V','OUI')
C
      IF (DEBUG) THEN
        CALL DBGCAL(OPTION,IFMDBG,
     &              NBIN  ,LPAIN ,LCHIN ,
     &              NBOUT ,LPAOUT,LCHOUT)
      ENDIF
C
C --- ON FAIT SINCO = SOMME DES CICOCA SUR LES �LTS DU LIGRMO
C
      CALL MESOMM(CICOCA,1,SINCO,RBID,CBID,0,IBID)
C
C --- SI SINCO EST STRICTEMENT POSITIF, ALORS ON A EU UN CODE RETOUR
C --- SUPERIEUR A ZERO SUR UN ELEMENT ET DONC ON A PAS CONVERG�
C
      IF (SINCO.GT.0) THEN
        MMCVCA = .FALSE.
      ELSE
        MMCVCA = .TRUE.
      ENDIF
C
C --- ON COPIE CINDO DANS RESOCO.XFIN
C
      CALL COPISD('CHAMP_GD','V',LCHOUT(2),XINDCO)
C
C --- ON COPIE CMEMCO DANS RESOCO.XMEM
C
      CALL COPISD('CHAMP_GD','V',LCHOUT(3),XMEMCO)
      CALL COPISD('CHAMP_GD','V',LCHOUT(4),XCOHEO)                 
C
 9999 CONTINUE
C
      CALL JEDEMA()
      END
