!
! COPYRIGHT (C) 1991 - 2016  EDF R&D                WWW.CODE-ASTER.ORG
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
    subroutine ptinma(elem_nbnode, elem_dime , elem_code, elem_coor, pair_tole,&
                      poin_coorx , poin_coory, test)
        integer, intent(in) :: elem_nbnode
        integer, intent(in) :: elem_dime
        character(len=8), intent(in) :: elem_code
        real(kind=8), intent(in) :: elem_coor(elem_dime-1,elem_nbnode)
        real(kind=8), intent(in) :: pair_tole
        real(kind=8), intent(in) :: poin_coorx
        real(kind=8), intent(in) :: poin_coory
        integer, intent(out) :: test
    end subroutine ptinma
end interface
