      SUBROUTINE JEDBG2 ( DBGAV,DBGAP)
      IMPLICIT NONE
      INTEGER DBGAV,DBGAP
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF JEVEUX  DATE 18/09/2007   AUTEUR DURAND C.DURAND 
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
C BUT :  CONSULTER ET EVENTUELLEMENT METTRE A JOUR
C        LA VALEUR IDEBUG DE JEVEUX
C
C      IDEBUG=1 => "DEBUG_JEVEUX"
C      IDEBUG=0 => PAS DE "DEBUG_JEVEUX"
C
C
C OUT  I  DBGAV : VALEUR DE IDEBUG AVANT L'APPEL A JEDBG2 (0 OU 1)
C IN   I  DBGAP : VALEUR DE IDEBUG APRES L'APPEL A JEDBG2 (-1,0 OU 1)
C                 SI DBGAP=-1 : ON NE MODIFIE PAS IDEBUG
C-----------------------------------------------------------------------
      INTEGER          LUNDEF,IDEBUG
      COMMON /UNDFJE/  LUNDEF,IDEBUG

      DBGAV=IDEBUG

      IF (DBGAP.EQ.-1) THEN
      ELSE IF (DBGAP.EQ.0) THEN
        IDEBUG=0
      ELSE IF (DBGAP.EQ.1) THEN
        IDEBUG=1
      ELSE
        CALL ASSERT(.FALSE.)
      END IF
      END
