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
    subroutine dpvpdb(nbmat, mater, crit, dt, vinm,&
                      vinp, nvi, seqe, i1e, seqm,&
                      i1m, dp, nbre, retcom)
        integer :: nvi
        integer :: nbmat
        real(kind=8) :: mater(nbmat, 2)
        real(kind=8) :: crit(3)
        real(kind=8) :: dt
        real(kind=8) :: vinm(nvi)
        real(kind=8) :: vinp(nvi)
        real(kind=8) :: seqe
        real(kind=8) :: i1e
        real(kind=8) :: seqm
        real(kind=8) :: i1m
        real(kind=8) :: dp
        integer :: nbre
        integer :: retcom
    end subroutine dpvpdb
end interface
