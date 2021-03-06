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
    subroutine immeca(tablca, lirela, mailla, nbnobe, nunobe,&
                      icabl, nbnoca, xnoca, ynoca, znoca,&
                      ncncin, nmabet)
        character(len=19) :: tablca
        character(len=19) :: lirela
        character(len=8) :: mailla
        integer :: nbnobe
        character(len=19) :: nunobe
        integer :: icabl
        integer :: nbnoca(*)
        character(len=19) :: xnoca
        character(len=19) :: ynoca
        character(len=19) :: znoca
        character(len=24) :: ncncin
        character(len=24) :: nmabet
    end subroutine immeca
end interface
