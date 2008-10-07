      SUBROUTINE DELAT(MODGEN,NBSST,NBMO)
      IMPLICIT REAL*8  (A-H,O-Z)

C---------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 07/10/2008   AUTEUR PELLET J.PELLET 
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
C---------------------------------------------------------------------
C AUTEUR : G. ROUSSEAU
C
C--------- DEBUT DES COMMUNS JEVEUX ----------------------------------
      CHARACTER*32     JEXNUM, JEXNOM, JEXR8, JEXATR
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16           ZK16
      CHARACTER*24                    ZK24
      CHARACTER*32                            ZK32
      CHARACTER*80                                    ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     --- FIN DES COMMUNS JEVEUX ------------------------------------
      LOGICAL       TEST1,TEST2,EXISDG,TEST3
      INTEGER       NBVALE,NBREFE,NBDESC,IBID,NBID,ISST,IADRP
      INTEGER       I,J,IAD(2),IAD3D(3),ITXSTO,ITYSTO,IPRSTO
      INTEGER       ICOR1,ICOR2,ICOR(2),NDBLE
      REAL*8        R8BID,MIJ,TGEOM(6),CONST(3)
      REAL*8        TAILMI,NORM1,NORM2,RESTE(3),DEUXPI,CA(3),SA(3)
      REAL*8        VAL(2),VAL3D(3),TOL
      CHARACTER*1   TYPECH(3),TYPCST(3)
      CHARACTER*2   MODEL
      CHARACTER*3   REPON
      CHARACTER*6   CHAINE
      CHARACTER*8   TCORX(2),TCORY(2),NOMCH(3),TCORZ(2)
      CHARACTER*8   MOFLUI,MOINT,MA,K8BID
      CHARACTER*8   MODGEN,BAMO,MACEL,MAILLA,GD,MAFLUI
      CHARACTER*14  NU,NUM,NUDDL
      CHARACTER*19  MAX,MAY,CHTMPX,CHTMPY,CHTMPZ,CHCOMB,VESTOC
      CHARACTER*19  VESOLX,VESOLY,VEPR,VESOLZ,CHTEMP,NOMNUM
      CHARACTER*19  CHFLU,CHAMNX,CHAMNY,CHAMNZ,NEWCHA,PCHNO
      CHARACTER*24  NOMCHA
      CHARACTER*72  K72B
      COMPLEX*16    C16B,CBID
C -----------------------------------------------------------------
C---------------------------------------------------------------------

      CALL JEMARQ()

C NB DE MODES TOTAL

       NBMO=0
       DO 1 ISST=1,NBSST
        CALL JEVEUO(JEXNUM(MODGEN//'      .MODG.SSME',ISST),
     +            'L',IMACL)
        MACEL=ZK8(IMACL)
        CALL JEVEUO(MACEL//'.MAEL_REFE','L',IBAMO)
        CALL RSORAC(ZK24(IBAMO),'LONUTI',IBID,BID,K8BID,CBID,EBID,
     +              'ABSOLU',
     +             NBMODG,1,NBID)
        NBMO=NBMO+NBMODG
1      CONTINUE

C TABLEAU INDIQUANT LES MODES PROPRES

       CALL WKVECT('&&DELAT.INDIC','V V I',NBMO,IDELAT)
       ICOMPT=0
       DO 2 ISST=1,NBSST
        CALL JEVEUO(JEXNUM(MODGEN//'      .MODG.SSME',ISST),
     +            'L',IMACL)
        MACEL=ZK8(IMACL)

        CALL JEVEUO(MACEL//'.MAEL_REFE','L',IBAMO)

C       CALL JEVEUO(ZK24(IBAMO)(1:19)//'.TYPE','L',ITYPE)
        CALL JELIRA(ZK24(IBAMO)(1:19)//'.ORDR'
     +           ,'LONUTI',NBTYPE,K8BID)
         DO 3, IJ=1,NBTYPE
            ICOMPT=ICOMPT+1
            CALL RSADPA(ZK24(IBAMO)(1:19),'L',1,'TYPE_DEFO',IJ,
     &                   0,JPARA,K8BID)
            IF(ZK16(JPARA)(1:8).NE.'PROPRE  ') GOTO 3
            ZI(IDELAT+ICOMPT-1)=1
3       CONTINUE
2      CONTINUE
      CALL JEDEMA()
       END
