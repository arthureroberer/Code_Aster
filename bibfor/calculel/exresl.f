      SUBROUTINE EXRESL(CHIN,IMODAT)
      IMPLICIT REAL*8 (A-H,O-Z)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 11/07/2005   AUTEUR VABHHTS J.PELLET 
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
C RESPONSABLE                            VABHHTS J.PELLET
C     ARGUMENTS:
C     ----------
      INTEGER IMODAT
      CHARACTER*19 CHIN
C ----------------------------------------------------------------------
C     ENTREES:
C        CHIN   : NOM DU CHAMP GLOBAL SUR LEQUEL ON FAIT L'EXTRACTION
C        IGR    : NUMERO DU GROUPE_ELEMENT (COMMON)
C        IMODAT : MODE LOCAL ATTENDU
C ----------------------------------------------------------------------
      COMMON /CAII01/IGD,NEC,NCMPMX,IACHIN,IACHLO,IICHIN,IANUEQ,LPRNO,
     &               ILCHLO
      COMMON /CAKK02/TYPEGD
      CHARACTER*8 TYPEGD
      COMMON /CAII04/IACHII,IACHIK,IACHIX
      COMMON /CAII02/IAOPTT,LGCO,IAOPMO,ILOPMO,IAOPNO,ILOPNO,IAOPDS,
     +       IAOPPA,NPARIO,NPARIN,IAMLOC,ILMLOC,IADSGD
      INTEGER        IAWLOC,IAWTYP,NBELGR,IGR,JCTEAT,LCTEAT
      COMMON /CAII06/IAWLOC,IAWTYP,NBELGR,IGR,JCTEAT,LCTEAT
      COMMON /CAII08/IEL

C     FONCTIONS EXTERNES:
C     ------------------
      INTEGER DIGDE2
      CHARACTER*32 JEXNUM,JEXNOM

C     VARIABLES LOCALES:
C     ------------------
      INTEGER DESC,MODE,NCMPEL
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8,NOGREL


      CALL JEMARQ()
      DESC = ZI(IACHII-1+11* (IICHIN-1)+4)

      MODE = ZI(DESC-1+2+IGR)

      IF (MODE.EQ.0) THEN
        CALL CODENT(IGR,'D',NOGREL)
        CALL UTMESS('E','EXRESL',
     +              ' ERREUR DANS L''EXTRACTION D''UN RESUELEM'//
     +              ' POUR LE GREL: '//NOGREL//'LE CHAMP N''EXISTE PAS')
      END IF


      IF (MODE.EQ.IMODAT) THEN
        NCMPEL = DIGDE2(MODE)
        CALL JEVEUO(JEXNUM(CHIN//'.RESL',IGR),'L',IARESU)
        CALL JACOPO(NCMPEL*NBELGR,TYPEGD,IARESU,IACHLO)
      ELSE
        CALL UTMESS('F','EXRESL','A FAIRE ...')
      END IF

C     POUR L'INSTANT EXRESL TROUVE TOUJOURS TOUT :
      DO 20,K = 1,NBELGR*NCMPEL
        ZL(ILCHLO-1+K) = .TRUE.
   20 CONTINUE

      CALL JEDEMA()
      END
