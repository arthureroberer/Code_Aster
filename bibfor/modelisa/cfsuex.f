      SUBROUTINE CFSUEX(DEFICO,NOESUP,NBEXCL,NZOCO)
C      
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 24/11/2008   AUTEUR DESOZA T.DESOZA 
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
C RESPONSABLE MABBAS M.ABBAS
C
      IMPLICIT NONE
      CHARACTER*24 NOESUP,DEFICO
      INTEGER NBEXCL
      INTEGER NZOCO
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (TOUTES METHODES - UTILITAIRE)
C
C NOEUD A SUPPRIMER DANS LES VECTEURS IDOINES POUR LE CONTACT
C      
C ----------------------------------------------------------------------
C
C
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT
C IN  NOESUP : LISTE DES NOEUDS A ELIMINER
C IN  NBEXCL : LONGUEUR DU VECTEUR NOESUP (NB NOEUDS A ELIMINER)
C IN  NZOCO  : NOMBRE DE ZONES DE CONTACT
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
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
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER KSANS,KPSANS,JPSANS,JSANS,JNOES
      INTEGER I,IZONE,IND,JDEC,NBOLD,NBNEW,LSANSN
      CHARACTER*8  KBID
      CHARACTER*24 PSANS,SANSNO      
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()

C --- SAUVEGARDE ANCIENS VECTEURS
      SANSNO = DEFICO(1:16)//'.SSNOCO'
      PSANS  = DEFICO(1:16)//'.PSSNOCO'           
      CALL JEVEUO(SANSNO,'L',JSANS)
      CALL JEVEUO(PSANS ,'E',JPSANS)  
      CALL JEVEUO(NOESUP,'L',JNOES)
      CALL JELIRA(SANSNO,'LONMAX',LSANSN,KBID)
      CALL WKVECT('&&CFSUEX.SSNOCO','V V I',LSANSN,KSANS)
      CALL WKVECT('&&CFSUEX.PSSNOCO','V V I',NZOCO+1,KPSANS)
      DO 10 I = 1,LSANSN
        ZI(KSANS-1+I)  = ZI(JSANS-1+I)
   10 CONTINUE
      DO 20 I = 1,NZOCO + 1
        ZI(KPSANS-1+I) = ZI(JPSANS-1+I)
   20 CONTINUE
C
C --- DESTRUCTION ANCIENS OBJETS
C
      CALL JEDETR(SANSNO)
      CALL JEDETR(PSANS)
C
C --- CREATION NOUVEAUX VECTEURS
C      
      CALL WKVECT(SANSNO,'G V I',LSANSN+NBEXCL*NZOCO,JSANS)
      CALL WKVECT(PSANS ,'G V I',NZOCO+1,JPSANS)
      JDEC = 1
      ZI(JPSANS) = 0
      DO 50 IZONE = 1,NZOCO
        NBOLD = ZI(KPSANS-1+IZONE+1) - ZI(KPSANS-1+IZONE)
        DO 30 IND = 1,NBOLD
          ZI(JSANS-1+JDEC) = ZI(KSANS-1+JDEC)
          JDEC = JDEC + 1
   30   CONTINUE
        DO 40 IND = 1,NBEXCL
          ZI(JSANS-1+JDEC) = ZI(JNOES-1+IND)
          JDEC = JDEC + 1
   40   CONTINUE
        NBNEW = NBOLD + NBEXCL
        ZI(JPSANS-1+IZONE+1) = ZI(JPSANS-1+IZONE) + NBNEW
   50 CONTINUE
C
C --- MENAGE
C
      CALL JEDETR('&&CFSUEX.SSNOCO')
      CALL JEDETR('&&CFSUEX.PSSNOCO')
      CALL JEDEMA()
      END
