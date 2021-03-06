subroutine caraco(sdcont, model, keywf, cont_form, nb_cont_zone)
!
implicit none
!
#include "asterf_types.h"
#include "asterfort/caralv.h"
#include "asterfort/cazoco.h"
#include "asterfort/cazocp.h"
#include "asterfort/cazofm.h"
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
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
!
    character(len=8), intent(in) :: sdcont
    character(len=8), intent(in) :: model
    character(len=16), intent(in) :: keywf
    integer, intent(in) :: cont_form
    integer, intent(in) :: nb_cont_zone
!
! --------------------------------------------------------------------------------------------------
!
! DEFI_CONTACT
!
! Get parameters of contact
!
! --------------------------------------------------------------------------------------------------
!
! In  sdcont           : name of contact concept (DEFI_CONTACT)
! In  model            : name of model
! In  keywf            : factor keyword to read
! In  cont_form        : formulation of contact
! In  nb_cont_zone     : number of zones of contact
!
! --------------------------------------------------------------------------------------------------
!
    integer :: i_zone
!
! --------------------------------------------------------------------------------------------------
!
!
! - Get method of contact
!
    call cazofm(sdcont, keywf, cont_form, nb_cont_zone)
!
! - Get parameters (not depending on contact zones)
!
    call cazocp(sdcont, model)
!
! - Get parameters (depending on contact zones)
!
    do i_zone = 1, nb_cont_zone
        call cazoco(sdcont      , model, keywf, cont_form, i_zone,&
                    nb_cont_zone)
    end do
!
! - Set automatic parameters
!
    call caralv(sdcont, nb_cont_zone, cont_form)
!
end subroutine
