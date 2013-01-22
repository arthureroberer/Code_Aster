      SUBROUTINE TE0134(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 21/01/2013   AUTEUR DELMAS J.DELMAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
      INCLUDE 'jeveux.h'

      CHARACTER*16 OPTION,NOMTE
C----------------------------------------------------------------------
C
C   - FONCTION REALISEE: CALCUL DU REPERE LOCAL DONNE PAR L'UTILISATEUR
C   - TYPES D'ELEMENT : DKT,DKTG,DST,Q4G,Q4GG,COQUE_3D,GRILLE
C
C
C----------------------------------------------------------------------

      INTEGER JGEOM,JREPL1,JREPL2,JREPL3,JCACOQ,IRET
      INTEGER NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDX,JGANO
      INTEGER I
      REAL*8  PGL(3,3),T2EV(4),T2VE(4)
      REAL*8  PULX(3),PULY(3),PULZ(3),UX(3),UY(3),UZ(3)
      REAL*8  COOR(12),ALPHA,BETA,R8DGRD,C,S
C

      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDX,JGANO)
      CALL ASSERT(NNOS.LE.8)

      CALL JEVECH('PGEOMER','L',JGEOM)
      CALL JEVECH('PCACOQU','L',JCACOQ)
      CALL JEVECH('PREPLO1','E',JREPL1)
      CALL JEVECH('PREPLO2','E',JREPL2)
      CALL JEVECH('PREPLO3','E',JREPL3)

      DO 40 I = 1,NNOS*3
        COOR(I) = ZR(JGEOM-1+I)
 40   CONTINUE

C     CALCUL DE LA MATRICE DE PASSAGE GLOBAL -> LOCAL(INTRINSEQUE)
      IF (NNOS.EQ.3)THEN
        CALL DXTPGL ( COOR, PGL )
      ELSEIF (NNOS.EQ.4)THEN
        CALL DXQPGL ( COOR, PGL, 'S', IRET )
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
      ALPHA = ZR(JCACOQ+1)*R8DGRD()
      BETA  = ZR(JCACOQ+2)*R8DGRD()

      CALL COQREP(PGL, ALPHA, BETA, T2EV, T2VE,C,S)

C     T2EV : LA MATRICE DE PASSAGE (2X2) : UTILISATEUR -> INTRINSEQUE
C
C     PUL : LA MATRICE DE PASSAGE (3X3) : UTILISATEUR -> INTRINSEQUE
C
C         (T2EV(1) , T2EV(3) , 0 )
C     PUL=(T2EV(2) , T2EV(4) , 0 )
C         (  0     ,    0    , 1 )
C     PUL = (PULX,PULY,PULZ)
      PULX(1) = T2EV(1)
      PULX(2) = T2EV(2)
      PULX(3) = 0.0D0

      PULY(1) = T2EV(3)
      PULY(2) = T2EV(4)
      PULY(3) = 0.0D0
      PULZ(1) = 0.0D0
      PULZ(2) = 0.0D0
      PULZ(3) = 1.0D0

C     (UX,UY,UZ) : VECTEUR LOCAUX UTILISATEUR DANS LE BASE GLOBALE
C     (UX,UY,UZ) = INV(PGL) * PUL

      CALL UTPVLG(1,3,PGL,PULX,UX)
      CALL UTPVLG(1,3,PGL,PULY,UY)
      CALL UTPVLG(1,3,PGL,PULZ,UZ)

      DO 12 I = 1,3
        ZR(JREPL1-1+I)=UX(I)
        ZR(JREPL2-1+I)=UY(I)
        ZR(JREPL3-1+I)=UZ(I)
 12   CONTINUE

      END
