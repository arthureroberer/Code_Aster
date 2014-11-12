!
! COPYRIGHT (C) 1991 - 2013  EDF R&D                WWW.CODE-ASTER.ORG
!
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
! 1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
!
#include "asterf_types.h"
!
interface
    subroutine nmvarc_prep(type_comp, model    , cara_elem, mate     , varc_refe,&
                           compor   , exis_temp, mxchin   , nbin     , lpain    ,&
                           lchin    , mxchout  , nbout    , lpaout   , lchout   ,&
                           sigm_prev, vari_prev, varc_prev, varc_curr)
        character(len=1), intent(in) :: type_comp
        character(len=24), intent(in) :: model
        character(len=24), intent(in) :: mate
        character(len=24), intent(in) :: varc_refe
        character(len=24), intent(in) :: cara_elem
        character(len=24), intent(in) :: compor
        aster_logical, intent(in) :: exis_temp
        integer, intent(in) :: mxchin
        character(len=8), intent(inout) :: lpain(mxchin)
        character(len=19), intent(inout) :: lchin(mxchin)
        integer, intent(out) :: nbin
        integer, intent(in) :: mxchout
        character(len=8), intent(inout) :: lpaout(mxchout)
        character(len=19), intent(inout) :: lchout(mxchout)
        integer, intent(out) :: nbout
        character(len=19), intent(in) :: sigm_prev
        character(len=19), intent(in) :: vari_prev
        character(len=19), intent(in) :: varc_prev
        character(len=19), intent(in) :: varc_curr
    end subroutine nmvarc_prep
end interface