!
! COPYRIGHT (C) 1991 - 2015  EDF R&D                WWW.CODE-ASTER.ORG
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
    subroutine nmdoet(model , compor, list_func_acti, nume_ddl   , sdpilo  ,&
                      sddyna, sdcriq, hval_algo     , l_acce_zero, ds_inout)
        use NonLin_Datastructure_type
        character(len=24), intent(in) :: model
        character(len=24), intent(in) :: compor
        character(len=24), intent(in) :: sdcriq
        character(len=24), intent(in) :: nume_ddl
        character(len=19), intent(in) :: sddyna
        character(len=19), intent(in) :: sdpilo
        character(len=19), intent(in) :: hval_algo(*)
        integer, intent(in) :: list_func_acti(*)
        aster_logical, intent(out) :: l_acce_zero
        type(NL_DS_InOut), intent(inout) :: ds_inout
    end subroutine nmdoet
end interface
