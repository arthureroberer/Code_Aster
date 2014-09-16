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
    subroutine diinit(meshz , modelz, result, mate  , carele  ,&
                      fonact, sddyna, parcri, instin, sd_inout,&
                      solveu, defico, sddisc, sdobse, sdsuiv)
        character(len=*), intent(in) :: meshz
        character(len=*), intent(in) :: modelz
        character(len=8) :: result
        character(len=24) :: mate
        character(len=24) :: carele
        integer :: fonact(*)
        character(len=19) :: sddyna
        real(kind=8) :: parcri(*)
        real(kind=8) :: instin
        character(len=24), intent(in) :: sd_inout
        character(len=19) :: solveu
        character(len=24) :: defico
        character(len=19) :: sddisc
        character(len=19) :: sdobse
        character(len=24) :: sdsuiv
    end subroutine diinit
end interface
