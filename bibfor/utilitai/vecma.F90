subroutine vecma(mv, n, mp, m)
    implicit none
#include "asterfort/assert.h"
    integer :: n, m
    real(kind=8) :: mv(n), mp(m, m)
!       ----------------------------------------------------------------
! ======================================================================
! COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
! THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
! IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
! THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
! (AT YOUR OPTION) ANY LATER VERSION.
!
! THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
! WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
! MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
! GENERAL PUBLIC LICENSE FOR MORE DETAILS.
!
! YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
! ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
!       ----------------------------------------------------------------
!       PASSAGE DEMI-MATRICE COLONNE VECTEUR (N)  > MATRICE PLEINE (M*M)
!       IN      MV = VECTEUR DEMI - MATRICE STOCKE COLONNE , LONGUEUR N
!       OUT     MP = MATRICE PLEINE (M*M)
!       ----------------------------------------------------------------
    integer :: k, i, j
! ----------------------------------------------------------------------
!
    ASSERT(n.ge.m*(m+1)/2)
!
    k = 0
    do 10 i = 1, m
        do 20 j = 1, m
            k = k + 1
            mp(i,j) = mv(k)
            mp(j,i) = mv(k)
            if (j .eq. i) goto 10
20      continue
10  continue
!
end subroutine
