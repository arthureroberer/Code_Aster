subroutine reajeu(ds_contact)
!
use NonLin_Datastructure_type
!
implicit none
!
#include "asterfort/jedupo.h"
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
!
    type(NL_DS_Contact), intent(in) :: ds_contact
!
! ----------------------------------------------------------------------
!
! ROUTINE CONTACT (METHODES DISCRETES - APPARIEMENT)
!
! RECUPERATION DES VECTEURS DE JEU
!
! ----------------------------------------------------------------------
!
! SAUVEGARDE DANS CFDECO
! In  ds_contact       : datastructure for contact management
!
! ----------------------------------------------------------------------
!
    character(len=24) :: jeuite, jeusav
!
! ----------------------------------------------------------------------
!
    jeuite = ds_contact%sdcont_solv(1:14)//'.JEUITE'
    jeusav = ds_contact%sdcont_solv(1:14)//'.JEUSAV'
    call jedupo(jeusav, 'V', jeuite, .false._1)
!
end subroutine
