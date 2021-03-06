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
    subroutine cptr03(main  , maout , inc   , jcoor , jcnnpa, conloc,&
                      limane, nomnoe, nbno  , jmacou, jmacsu, macou ,&
                      macsu , ind   , ind1  )
        character(len=8), intent(in) :: main
        character(len=8), intent(in) :: maout
        integer, intent(in) :: inc 
        integer, intent(in) :: jcoor
        integer, intent(in) :: jcnnpa
        character(len=24), intent(in) :: conloc
        character(len=24), intent(in) :: limane
        character(len=24), intent(in) :: nomnoe
        integer, intent(in) :: nbno 
        integer, intent(in) :: jmacou
        integer, intent(in) :: jmacsu
        integer, intent(in) :: macou
        integer, intent(in) :: macsu
        integer, intent(out) :: ind 
        integer, intent(out) :: ind1
    end subroutine cptr03
end interface
