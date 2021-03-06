!
! COPYRIGHT (C) 1991 - 2017  EDF R&D                WWW.CODE-ASTER.ORG
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
    subroutine exfonc(list_func_acti, ds_algopara, solver, ds_contact, sddyna,&
                      mate, model)
        use NonLin_Datastructure_type
        integer, intent(in) :: list_func_acti(*)
        character(len=19), intent(in) :: solver
        character(len=19), intent(in) :: sddyna
        type(NL_DS_Contact), intent(in) :: ds_contact
        character(len=24), intent(in) :: mate
        character(len=24), intent(in) :: model
        type(NL_DS_AlgoPara), intent(in) :: ds_algopara
    end subroutine exfonc
end interface
