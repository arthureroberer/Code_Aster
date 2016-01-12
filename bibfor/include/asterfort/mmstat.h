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
    subroutine mmstat(mesh  , iter_newt, nume_inst, sddyna    , sdstat,&
                      sddisc, hval_incr, hval_algo, ds_contact)
        use NonLin_Datastructure_type
        character(len=8), intent(in) :: mesh
        integer, intent(in) :: iter_newt
        integer, intent(in) :: nume_inst
        character(len=19), intent(in) :: sddyna
        character(len=24), intent(in) :: sdstat
        character(len=19), intent(in) :: sddisc
        character(len=19), intent(in) :: hval_incr(*)
        character(len=19), intent(in) :: hval_algo(*)
        type(NL_DS_Contact), intent(inout) :: ds_contact
    end subroutine mmstat
end interface