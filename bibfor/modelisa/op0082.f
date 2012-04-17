      SUBROUTINE OP0082()

      IMPLICIT NONE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 21/09/2011   AUTEUR COURTOIS M.COURTOIS 
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
C RESPONSABLE MASSIN P.MASSIN

C
C ----------------------------------------------------------------------
C
C OPERATEUR DEFI_GRILLE
C
C ----------------------------------------------------------------------
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16             ZK16
      CHARACTER*24                      ZK24
      CHARACTER*32                               ZK32
      CHARACTER*80                                        ZK80
      COMMON  /KVARJE/ ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER        IFM,NIV,IBID
      CHARACTER*8    GRILLE,MAIL
      CHARACTER*16   K16BID
      CHARACTER*19   CNXINV
      CHARACTER*24   VCN,GRLR
      REAL*8         LCMIN
      INTEGER      IARG

C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFMAJ
      CALL INFNIV(IFM,NIV)

C     GRILLE A CREER
      CALL GETRES(GRILLE,K16BID,K16BID)

C     MAILLAGE EN ENTREE
      CALL GETVID(' ','MAILLAGE',1,IARG,1,MAIL,IBID)

C     DUPLIQUE LA SD_MAILLAGE
      CALL COPISD('MAILLAGE','G',MAIL,GRILLE)

C     MET A JOUR LE NOM DU MAILLAGE DANS LA SD_MAILLAGE DUPLIQUEE
      CALL JEVEUO(GRILLE//'.COORDO    .REFE','E',IBID)
      ZK24(IBID) = GRILLE

C     CALCUL DES GRANDEURS DE LA GRILLE ET VERIFICATION QUE LE MAILLAGE
C     EN ENTREE PEUT BIEN ETRE UTILISE POUR LA DEFINITION DE LA GRILLE
      CNXINV = '&&OP0082.CNCINV'
      CALL CNCINV(MAIL,IBID,0,'V',CNXINV)
      VCN=GRILLE//'.GRLI'
      GRLR=GRILLE//'.GRLR'
      CALL XPRCNU(MAIL,CNXINV,'G',VCN,GRLR,LCMIN)

C     STOCKE LA VALEUR DE LA PLUS PETITE ARETE DE LA GRILLE
      CALL JEVEUO(GRLR,'E',IBID)
      ZR(IBID) = LCMIN

C     NETTOYAGE
      CALL JEDETR(CNXINV)

C     INFO
      IF (NIV.GT.0) THEN
         WRITE(IFM,*)'  LONGUEUR DE LA PLUS PETITE ARETE DE LA GRILLE: '
     &                ,LCMIN
         WRITE(IFM,*)' '
         WRITE(IFM,*)'  BASE LOCALE DE LA GRILLE:'
         CALL JEVEUO(GRLR,'E',IBID)
         IBID = IBID+1
         WRITE(IFM,900)ZR(IBID-1+1),ZR(IBID-1+2),ZR(IBID-1+3)
         WRITE(IFM,901)ZR(IBID-1+4),ZR(IBID-1+5),ZR(IBID-1+6)
         WRITE(IFM,902)ZR(IBID-1+7),ZR(IBID-1+8),ZR(IBID-1+9)
      ENDIF

900   FORMAT(6X,' ','X=(',E11.4,',',E11.4,',',E11.4,')')
901   FORMAT(6X,' ','Y=(',E11.4,',',E11.4,',',E11.4,')')
902   FORMAT(6X,' ','Z=(',E11.4,',',E11.4,',',E11.4,')')

      CALL JEDEMA()
      END
