      SUBROUTINE RSACCH(NOMSDZ,NUMCH,NOMCH,NBORD,LIORD,NBCMP,LISCMP)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 07/10/2008   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
      INTEGER NUMCH, NBORD, LIORD(*), NBCMP
      CHARACTER*8   LISCMP(*)
      CHARACTER*16  NOMCH
      CHARACTER*(*) NOMSDZ
C ---------------------------------------------------------------------
C  DETERMINE LE NOM D'UN CHAMP ET LES NUMEROS D'ORDRE CALCULES
C  CONNAISSANT SON NUMERO D'ACCES DANS LA COLLECTION
C ---------------------------------------------------------------------
C IN  NOMSDZ K*  NOM DE LA SD
C IN  NUMCH   I  NUMERO DU CHAMP A RECHERCHER
C OUT NOMCH  K16 NOM DU CHAMP
C OUT NBORD   I  NOMBRE DE NUMEROS D'ORDRE CALCULES
C OUT LIORD   I  LISTE DES NUMEROS D'ORDRE CALCULES
C OUT NBCMP   I  NOMBRE DE COMPOSANTES DU CHAMP (INFERIEUR A 500)
C OUT LISCMP K8  LISTE DES NOMS DES COMPOSANTES
C ---------------------------------------------------------------------
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
      CHARACTER*32 JEXNUM
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
      INTEGER      IBID, IRET, ITAB, I, NUMORD, LONCMP, ICMP,C,J
      REAL*8       RBID
      COMPLEX*16   CBID
      CHARACTER*4  TYPECH
      CHARACTER*8  K8BID, COMP
      CHARACTER*19 NOMSD, CHAMP, CHS
      CHARACTER*24 TABORD
C ---------------------------------------------------------------------
      CALL JEMARQ()
      NOMSD  = NOMSDZ
      TABORD = '&&RSACCH.LISORD'
      NOMCH  = ' '
      CHS   = 'CHAMP_S'
C    ACCES AU NOM DU CHAMP
      CALL JENUNO(JEXNUM(NOMSD//'.DESC',NUMCH), NOMCH)
C    ACCES AUX NUMEROS D'ORDRE
      CALL RSCHOR(NOMSD, NOMCH, NBORD, TABORD, IRET )
C    RECOPIE DES NUMEROS D'ORDRE
      CALL JEVEUO(TABORD,'L',ITAB)
      DO 10 I = 1, NBORD
        LIORD(I) = ZI(ITAB-1 + I)
 10   CONTINUE
C    COMPOSANTES DU CHAMP
      NBCMP = 0
      DO 20 I = 1, NBORD
C      EXTRACTION DU CHAMP AU NUMERO D'ORDRE COURANT
        NUMORD = ZI(ITAB-1 + I)
        CALL RSEXCH(NOMSD, NOMCH, NUMORD, CHAMP, IRET)
        CALL ASSERT (IRET.EQ.0)
C      TRANSFORMATION EN CHAMP_S ET ACCES A LA LISTE DES COMPOSANTES
        CALL DISMOI('F','TYPE_CHAMP',CHAMP,'CHAMP',IBID,TYPECH,IRET)
        IF (TYPECH.EQ.'NOEU') THEN
          CALL CNOCNS(CHAMP,'V',CHS)
          CALL JEVEUO(CHS // '.CNSC','L',ICMP)
          CALL JELIRA(CHS // '.CNSC','LONMAX',LONCMP,K8BID)
        ELSE IF (TYPECH.EQ.'ELGA' .OR. TYPECH.EQ.'ELNO'
     &                            .OR. TYPECH.EQ.'ELEM') THEN
          CALL CELCES(CHAMP,'V',CHS)
          CALL JEVEUO(CHS // '.CESC','L',ICMP)
          CALL JELIRA(CHS // '.CESC','LONMAX',LONCMP,K8BID)
        ELSE
          GOTO 20
        END IF
C      STOCKAGE DES NOUVELLES COMPOSANTES
        DO 30 C = 1, LONCMP
          COMP = ZK8(ICMP-1 + C)
          DO 40 J = 1, NBCMP
            IF (COMP.EQ.LISCMP(J)) GOTO 30
 40       CONTINUE
          NBCMP = NBCMP + 1
          CALL ASSERT (NBCMP.LE.500)
          LISCMP(NBCMP) = COMP
 30     CONTINUE
C      DESTRUCTION DU CHAMP_S
        CALL DETRSD('CHAMP_GD',CHS)
 20   CONTINUE
 999  CONTINUE
      CALL JEDETR(TABORD)
      CALL JEDEMA()
      END
