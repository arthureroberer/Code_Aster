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
    subroutine accel0(modele    , numedd, numfix     , fonact, lischa,&
                      ds_contact, maprec, solveu     , valinc, sddyna,&
                      ds_measure, ds_algopara, meelem, measse,&
                      veelem    , veasse, solalg)
        use NonLin_Datastructure_type        
        character(len=24) :: modele
        character(len=24) :: numedd
        character(len=24) :: numfix
        integer :: fonact(*)
        character(len=19) :: lischa
        type(NL_DS_Contact), intent(in) :: ds_contact
        character(len=19) :: maprec
        character(len=19) :: solveu
        character(len=19) :: valinc(*)
        character(len=19) :: sddyna
        type(NL_DS_Measure), intent(inout) :: ds_measure
        type(NL_DS_AlgoPara), intent(in) :: ds_algopara
        character(len=19) :: meelem(*)
        character(len=19) :: measse(*)
        character(len=19) :: veelem(*)
        character(len=19) :: veasse(*)
        character(len=19) :: solalg(*)
    end subroutine accel0
end interface
