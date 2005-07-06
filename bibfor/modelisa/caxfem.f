      SUBROUTINE CAXFEM(FONREE,CHAR)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 06/07/2005   AUTEUR GENIAUT S.GENIAUT 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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

      IMPLICIT NONE

      CHARACTER*8 CHAR
      CHARACTER*4 FONREE

C     BUT: CREER LES RELATIONS LIN�AIRES QUI ANNULENT LES DDLS EN TROP

C ARGUMENTS D'ENTREE:

C      FONREE :  'REEL' OU 'FONC'
C      CHAR    : NOM UTILISATEUR DU RESULTAT DE CHARGE

C     ----------- COMMUNS NORMALISES  JEVEUX  --------------------------
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
      CHARACTER*32 JEXNOM,JEXNUM,JEXATR
C---------------- FIN COMMUNS NORMALISES  JEVEUX  ----------------------
C-----------------------------------------------------------------------
C---------------- DECLARATION DES VARIABLES LOCALES  -------------------

      INTEGER      JFISS,IBID,IER,JSTANO,NREL
      CHARACTER*8  REP,MOD,FISS,MA,K8BID
      CHARACTER*24 GRMA,GRNO
      CHARACTER*19 CHS,LISREL

C-------------------------------------------------------------

      CALL JEMARQ()

      IF (FONREE.NE.'REEL') GOTO 9999

      CALL GETVTX(' ','LIAISON_XFEM',0,1,1,REP,IBID)
      IF (REP.EQ.'NON') GOTO 9999

      CALL DISMOI('F','NOM_MODELE',CHAR(1:8),'CHARGE',IBID,MOD,IER)
      CALL DISMOI('F','NOM_MAILLA',MOD,'MODELE',IBID,MA,IER)

      CALL JEEXIN(MOD//'.FISS',IER)
      CALL ASSERT(IER.NE.0)
      CALL JEVEUO(MOD//'.FISS','L',JFISS)
      FISS=ZK8(JFISS)
      CHS='&&CAXFEM.CHS'     
      CALL CNOCNS(FISS//'.STNO','V',CHS)
      CALL JEVEUO(CHS//'.CNSV','L',JSTANO)

      LISREL = '&&CAXFEM.RLISTE'
      NREL=0

C     ON SUPPRIME LES DDLS HEAVISIDE ET CRACK TIP
      GRMA=FISS//'.MAILFISS  .HEAV'
      CALL XDELDL(MOD,MA,GRMA,JSTANO,LISREL,NREL)

      GRMA=FISS//'.MAILFISS  .CTIP'
      CALL XDELDL(MOD,MA,GRMA,JSTANO,LISREL,NREL)

      GRMA=FISS//'.MAILFISS  .HECT'
      CALL XDELDL(MOD,MA,GRMA,JSTANO,LISREL,NREL)

      GRNO=FISS//'.LISNOH'
      CALL XDELH(MOD,MA,GRNO,LISREL,NREL)

C     ON SUPPRIME LES DDLS DE CONTACT EN TROP
      GRMA=FISS//'.MAILFISS  .HEAV'
      CALL XDELCO(GRMA,MOD,LISREL,NREL)
   
      IF (NREL.NE.0) CALL AFLRCH(LISREL,CHAR)

9999  CONTINUE
      CALL JEDEMA()
      END
