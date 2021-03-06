subroutine dfc_read_disc(sdcont      , keywf       , mesh        , model        , model_ndim,&
                         nb_cont_zone)
!
implicit none
!
#include "asterf_types.h"
#include "asterfort/dfc_read_zone.h"
#include "asterfort/dfc_save_dime.h"
#include "asterfort/dfc_chck.h"
#include "asterfort/quadco.h"
#include "asterfort/elimcq.h"
#include "asterfort/tablco.h"
#include "asterfort/cacoco.h"
#include "asterfort/cacoeq.h"
#include "asterfort/capoco.h"
#include "asterfort/elimco.h"
#include "asterfort/sansco.h"
#include "asterfort/typeco.h"
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
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
!
    character(len=8), intent(in) :: sdcont
    character(len=8), intent(in) :: mesh
    character(len=8), intent(in) :: model
    character(len=16), intent(in) :: keywf
    integer, intent(in) :: model_ndim
    integer, intent(in) :: nb_cont_zone
!
! --------------------------------------------------------------------------------------------------
!
! DEFI_CONTACT
!
! Discrete method - Read contact data
!
! --------------------------------------------------------------------------------------------------
!
! In  sdcont           : name of contact concept (DEFI_CONTACT)
! In  keywf            : factor keyword to read
! In  mesh             : name of mesh
! In  model            : name of model
! In  model_ndim       : dimension of model
! In  nb_cont_zone     : number of zones of contact
! Out nb_cont_surf     : number of surfaces of contact
! Out nb_cont_elem     : number of elements of contact
! Out nb_cont_node     : number of nodes of contact
!
! --------------------------------------------------------------------------------------------------
!
    integer :: nb_cont_surf, nb_cont_elem, nb_cont_node
    aster_logical :: l_elim_coq3d, l_node_q8
!
! --------------------------------------------------------------------------------------------------
!
    l_node_q8    = .true.
    l_elim_coq3d = .true.
!
! - QUAD8 specific treatment activation (l_node_q8 = .true. if need linearization, see CACOEQ)
!
    call quadco(sdcont, l_node_q8)
!
! - Read zone: nodes and elements
!
    call dfc_read_zone(sdcont      , keywf       , mesh        , model        , nb_cont_zone,&
                       nb_cont_surf, nb_cont_elem, nb_cont_node)
!
! - Cleaning nodes and elements
!
    call elimco(sdcont      , mesh        , model  , nb_cont_surf,&
                nb_cont_elem, nb_cont_node, l_elim_coq3d)
!
! - QUAD8 specific treatment: suppress middle nodes in contact lists
!
    if (l_node_q8) then
        call elimcq(sdcont, mesh, nb_cont_zone, nb_cont_surf, nb_cont_node)
    endif
!
! - Inverse connectivities
!
    call tablco(sdcont, mesh, nb_cont_surf, nb_cont_elem, nb_cont_node)
!
! - Save contact counters
!
    call dfc_save_dime(sdcont      , mesh        , model_ndim, nb_cont_zone, nb_cont_surf,&
                       nb_cont_elem, nb_cont_node)
!
! - Keyword SANS_GROUP_NO
!
    call sansco(sdcont, keywf, mesh)
!
! - Elements and nodes parameters
!
    call typeco(sdcont, mesh)
!
! - Some checks
!
    call dfc_chck(sdcont, mesh, model_ndim)
!
! - Gap for beams
!
    call capoco(sdcont, keywf)
!
! - Gap for shells
!
    call cacoco(sdcont, keywf, mesh)
!
! - Create QUAD8 linear relations
!
    if (l_node_q8) then
        call cacoeq(sdcont, mesh)
    endif
!
end subroutine
