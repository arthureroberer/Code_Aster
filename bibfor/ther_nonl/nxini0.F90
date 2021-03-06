subroutine nxini0(ds_algopara, ds_inout, ds_algorom)
!
use NonLin_Datastructure_type
use Rom_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "asterfort/infniv.h"
#include "asterfort/CreateAlgoParaDS.h"
#include "asterfort/CreateInOutDS.h"
#include "asterfort/romAlgoNLDSCreate.h"
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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
! person_in_charge: mickael.abbas at edf.fr
!
    type(NL_DS_AlgoPara), intent(out) :: ds_algopara
    type(NL_DS_InOut), intent(out) :: ds_inout
    type(ROM_DS_AlgoPara), intent(out) :: ds_algorom
!
! --------------------------------------------------------------------------------------------------
!
! THER_NON_LINE - Init
!
! Creation of datastructures
!
! --------------------------------------------------------------------------------------------------
!
! Out ds_algopara      : datastructure for algorithm parameters
! Out ds_inout         : datastructure for input/output management
! Out ds_algorom       : datastructure for ROM parameters
!
! --------------------------------------------------------------------------------------------------
!
    integer :: ifm, niv
!
! --------------------------------------------------------------------------------------------------
!
    call infniv(ifm, niv)
    if (niv .ge. 2) then
        write (ifm,*) '<THER_NON_LINE> Create datastructures'
    endif
!
! - Create input/output management datastructure
!
    call CreateInOutDS('THNL', ds_inout)
!
! - Create algorithm parameters datastructure
!
    call CreateAlgoParaDS(ds_algopara)
!
! - Create ROM parameters datastructure
!
    call romAlgoNLDSCreate(ds_algorom)
!
end subroutine
