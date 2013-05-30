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
    subroutine lkdgds(nmat, materf, para, vara, devsig,&
                      i1, val, ds2hds, vecn, dfds,&
                      bprimp, nvi, vint, dhds, dgds,&
                      iret)
        integer :: nvi
        integer :: nmat
        real(kind=8) :: materf(nmat, 2)
        real(kind=8) :: para(3)
        real(kind=8) :: vara(4)
        real(kind=8) :: devsig(6)
        real(kind=8) :: i1
        integer :: val
        real(kind=8) :: ds2hds(6)
        real(kind=8) :: vecn(6)
        real(kind=8) :: dfds(6)
        real(kind=8) :: bprimp
        real(kind=8) :: vint(nvi)
        real(kind=8) :: dhds(6)
        real(kind=8) :: dgds(6, 6)
        integer :: iret
    end subroutine lkdgds
end interface
