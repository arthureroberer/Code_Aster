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
interface
    subroutine e1e2nn(nno, dfde, dfdk, e1n, e2n,&
                      nxn, nyn, nzn, normn, j1n,&
                      j2n, san, can)
        integer :: nno
        real(kind=8) :: dfde(9, 9)
        real(kind=8) :: dfdk(9, 9)
        real(kind=8) :: e1n(3, 9)
        real(kind=8) :: e2n(3, 9)
        real(kind=8) :: nxn(9)
        real(kind=8) :: nyn(9)
        real(kind=8) :: nzn(9)
        real(kind=8) :: normn(3, 9)
        real(kind=8) :: j1n(9)
        real(kind=8) :: j2n(9)
        real(kind=8) :: san(9)
        real(kind=8) :: can(9)
    end subroutine e1e2nn
end interface
