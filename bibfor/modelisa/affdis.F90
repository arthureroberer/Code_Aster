subroutine affdis(ndim, irep, eta, car, val,&
                  jdc, jdv, ivr, iv, kma,&
                  ncmp, ntp, jdcinf, jdvinf, isym )
!
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
!
! --------------------------------------------------------------------------------------------------
!
!           Affectation des valeurs des matrices à tous les éléments
!           demandés par l'utilisateur dans les cartes correspondantes
!           les éléments concernés sont les éléments discrets 2D et 3D
!
! --------------------------------------------------------------------------------------------------
implicit   none
!
    integer :: ndim, irep, jdv(3), jdc(3), ivr(*), iv, ncmp, ntp
    integer :: isym, jdcinf, jdvinf
    real(kind=8) :: eta, val(*)
    character(len=1) :: kma(3)
    character(len=*) :: car
!
#include "asterfort/afdi2d.h"
#include "asterfort/afdi3d.h"
!
! --------------------------------------------------------------------------------------------------
!
    if (ndim .eq. 2) then
        call afdi2d(irep, eta, car, val, jdc,&
                    jdv, ivr, iv, kma, ncmp,&
                    ntp, jdcinf, jdvinf, isym)
    else if (ndim.eq.3) then
        call afdi3d(irep, eta, car, val, jdc,&
                    jdv, ivr, iv, kma, ncmp,&
                    ntp, jdcinf, jdvinf, isym)
    endif
!
end subroutine
