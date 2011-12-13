      SUBROUTINE UTFLMD(MAILLA,LIMAIL,DIM,NBTROU,LITROU)
      IMPLICIT NONE
      INTEGER DIM,NBTROU
      CHARACTER*8 MAILLA
      CHARACTER*(*) LITROU,LIMAIL
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 13/12/2011   AUTEUR PELLET J.PELLET 
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
C RESPONSABLE DELMAS J.DELMAS
C
C     BUT:
C       FILTRER UNE LISTE DE MAILLE D'APRES LEUR DIMENSION
C       *           *        *                   *
C       IDEM QUE UTFLM2 MAIS AVEC UN VECTEUR JEVEUX
C
C
C     ARGUMENTS:
C     ----------
C
C      ENTREE :
C-------------
C IN   MAILLA    : NOM DU MAILLAGE
C IN   LIMAIL    : LISTE DES MAILLES (OBJET JEVEUX)
C IN   NDIM      : DIMENSION DES MAILLES A TROUVER (0,1,2,3)
C
C      SORTIE :
C-------------
C OUT  NBTROU    : NOMBRE DE MAILLE TROUVEES
C OUT  LITROU    : LISTE DES MAILLES TROUVEES (OBJET JEVEUX)
C                  SI NBTROU = 0, L'OBJET JEVEUX N'EST PAS CREE
C
C.......................................................................
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)

      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32 JEXNUM
C
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
      INTEGER NBTYP,I,II,IRET,NBMAIL,ITROU
      INTEGER ITYPMA,IDIMTO,JTYPMA,ILIMAI,IT,ITEMPO,ITRMA

      CHARACTER*1 K1BID
      CHARACTER*8 K8BID
C
C ----------------------------------------------------------------------
      CALL JEMARQ()

      CALL JEVEUO(LIMAIL,'L',ILIMAI)
      CALL JELIRA(LIMAIL,'LONMAX',NBMAIL,K1BID)
      CALL WKVECT(LITROU,'V V I',NBMAIL,ITRMA)

      CALL UTFLM2(MAILLA,ZI(ILIMAI),NBMAIL,DIM,NBTROU,ZI(ITRMA))

      IF (NBTROU.GT.0) THEN
        CALL JUVECA(LITROU,NBTROU)
      ELSE
        CALL JEDETR(LITROU)
      ENDIF
      CALL JEDEMA()
      END
