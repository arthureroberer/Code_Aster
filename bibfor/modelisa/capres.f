      SUBROUTINE CAPRES ( CHAR, LIGRMO, NOMA, NDIM, FONREE)
      IMPLICIT   NONE
      INTEGER           NDIM
      CHARACTER*4       FONREE
      CHARACTER*8       CHAR, NOMA
      CHARACTER*(*)     LIGRMO
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 04/04/2006   AUTEUR VABHHTS J.PELLET 
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
C
C BUT : STOCKAGE DES PRESSIONS DANS UNE CARTE ALLOUEE SUR LE
C       LIGREL DU MODELE (Y COMPRIS THM)
C
C ARGUMENTS D'ENTREE:
C      CHAR   : NOM UTILISATEUR DU RESULTAT DE CHARGE
C      LIGRMO : NOM DU LIGREL DE MODELE
C      NOMA   : NOM DU MAILLAGE
C      NDIM   : DIMENSION DU PROBLEME (2D OU 3D)
C      FONREE : FONC OU REEL
C-----------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
      CHARACTER*32     JEXNOM, JEXNUM
C     ----- FIN COMMUNS NORMALISES  JEVEUX  ----------------------------
      INTEGER       IBID, NPRES, NCMP, JVALV, JNCMP, IOCC, NP, NC, IER,
     +              NBTOU, NBMA, JMA
      CHARACTER*8   K8B, TYPMCL(2)
      CHARACTER*16  MOTCLF, MOTCLE(2)
      CHARACTER*19  CARTE
      CHARACTER*24  MESMAI
C-----------------------------------------------------------------------
      CALL JEMARQ()
C
      MOTCLF = 'PRES_REP'
      CALL GETFAC ( MOTCLF, NPRES )
C
      CARTE = CHAR//'.CHME.PRESS'
C
      IF (FONREE.EQ.'REEL') THEN
         CALL ALCAR2 ( 'G', CARTE, NOMA, 'PRES_R')
      ELSEIF (FONREE.EQ.'FONC') THEN
         CALL ALCAR2 ( 'G', CARTE, NOMA, 'PRES_F')
      ELSE
         CALL UTMESS('F','CAPRES','VALEUR INATTENDUE: '//FONREE )
      END IF
C
      CALL JEVEUO ( CARTE//'.NCMP', 'E', JNCMP )
      CALL JEVEUO ( CARTE//'.VALV', 'E', JVALV )
C
C --- STOCKAGE DE FORCES NULLES SUR TOUT LE MAILLAGE
C
      NCMP = 2
      ZK8(JNCMP)   = 'PRES'
      ZK8(JNCMP+1) = 'CISA'

      IF (FONREE.EQ.'REEL') THEN
         ZR(JVALV)   = 0.D0
         ZR(JVALV+1) = 0.D0
      ELSE
         ZK8(JVALV)   = '&FOZERO'
         ZK8(JVALV+1) = '&FOZERO'
      END IF
      CALL NOCAR2 (CARTE,1,' ','NOM',0,' ',0,LIGRMO,NCMP)
C
      MESMAI = '&&CAPRES.MES_MAILLES'
      MOTCLE(1) = 'GROUP_MA'
      MOTCLE(2) = 'MAILLE'
      TYPMCL(1) = 'GROUP_MA'
      TYPMCL(2) = 'MAILLE'
C
C --- STOCKAGE DANS LA CARTE
C
      DO 10 IOCC = 1, NPRES
C
         IF (FONREE.EQ.'REEL') THEN
            CALL GETVR8 (MOTCLF, 'PRES'   , IOCC,1,1,ZR(JVALV)  ,NP)
            CALL GETVR8 (MOTCLF, 'CISA_2D', IOCC,1,1,ZR(JVALV+1),NC)
         ELSE
            CALL GETVID (MOTCLF, 'PRES'   , IOCC,1,1,ZK8(JVALV)  ,NP)
            CALL GETVID (MOTCLF, 'CISA_2D', IOCC,1,1,ZK8(JVALV+1),NC)
         ENDIF
C
         CALL GETVTX ( MOTCLF, 'TOUT', IOCC, 1, 1, K8B, NBTOU )
C
         IF ( NBTOU .NE. 0 ) THEN
C
            CALL NOCAR2(CARTE, 1, ' ', 'NOM', 0, ' ', 0,LIGRMO, NCMP)
         ELSE
            CALL RELIEM(LIGRMO, NOMA, 'NO_MAILLE', MOTCLF, IOCC, 2,
     +                                  MOTCLE, TYPMCL, MESMAI, NBMA )
            CALL JEVEUO ( MESMAI, 'L', JMA )
            CALL VETYMA ( NOMA, ZK8(JMA),NBMA, K8B,0, MOTCLF,NDIM,IER)
            CALL NOCAR2 (CARTE,3,K8B,'NOM',NBMA,ZK8(JMA),IBID,' ',NCMP)
            CALL JEDETR ( MESMAI )
         ENDIF
C
 10   CONTINUE
C-----------------------------------------------------------------------
      CALL JEDEMA()
      END
