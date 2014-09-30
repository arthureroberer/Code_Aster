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
interface
    subroutine cfmxsd(mesh_      , model_     , nume_ddl        , list_func_acti  , sddyna,&
                      sdcont_defi, sdcont_solv, ligrel_link_cont, ligrel_link_xfem, sd_iden_rela)
        character(len=*), intent(in) :: mesh_
        character(len=*), intent(in) :: model_
        character(len=24), intent(in) :: nume_ddl
        integer, intent(in) :: list_func_acti(*)
        character(len=19), intent(in) :: sddyna
        character(len=24), intent(in) :: sdcont_defi
        character(len=24), intent(in) :: sdcont_solv
        character(len=19), intent(in) :: ligrel_link_cont
        character(len=19), intent(in) :: ligrel_link_xfem
        character(len=24), intent(in) :: sd_iden_rela
    end subroutine cfmxsd
end interface
