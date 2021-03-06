subroutine nmxvec(modelz  , mate  , carele, ds_constitutive, ds_measure,&
                  sddisc  , sddyna, numins, valinc, solalg,&
                  lischa  , comref, numedd,&
                  ds_inout, veelem, veasse, measse, nbvect,&
                  ltypve  , lcalve, loptve, lassve)
!
use NonLin_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "asterfort/assert.h"
#include "asterfort/diinst.h"
#include "asterfort/nmassv.h"
#include "asterfort/nmcalv.h"
#include "asterfort/nmchex.h"
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
! aslint: disable=W1504
!
    integer :: nbvect
    character(len=6) :: ltypve(20)
    aster_logical :: lcalve(20), lassve(20)
    character(len=16) :: loptve(20)
    character(len=*) :: modelz
    character(len=24) :: mate, carele
    type(NL_DS_Constitutive), intent(in) :: ds_constitutive
    type(NL_DS_Measure), intent(inout) :: ds_measure
    character(len=24) :: numedd
    integer :: numins
    type(NL_DS_InOut), intent(in) :: ds_inout
    character(len=19) :: sddisc, sddyna, lischa
    character(len=24) :: comref
    character(len=19) :: veelem(*), veasse(*), measse(*)
    character(len=19) :: solalg(*), valinc(*)
!
! ----------------------------------------------------------------------
!
! ROUTINE MECA_NON_LINE (CALCUL - UTILITAIRE)
!
! CALCUL ET ASSEMBLAGE DES VECT_ELEM DE LA LISTE
!
! ----------------------------------------------------------------------
!
! IN  MODELE : MODELE
! IN  NUMEDD : NUME_DDL
! IN  MATE   : CHAMP MATERIAU
! IN  CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
! IN  COMREF : VARI_COM DE REFERENCE
! In  ds_constitutive  : datastructure for constitutive laws management
! IN  LISCHA : LISTE DES CHARGES
! IN  SDDYNA : SD POUR LA DYNAMIQUE
! IO  ds_measure       : datastructure for measure and statistics management
! IN  METHOD : INFORMATIONS SUR LES METHODES DE RESOLUTION (VOIR NMLECT)
! IN  PARMET : PARAMETRES DES METHODES DE RESOLUTION (VOIR NMLECT)
! IN  SOLVEU : SOLVEUR
! IN  SDDISC : SD DISCRETISATION TEMPORELLE
! IN  NUMINS : NUMERO D'INSTANT
! In  ds_inout         : datastructure for input/output management
! IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
! IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
! IN  NBVECT : NOMBRE DE VECT_ELEM DANS LA LISTE
! IN  LTYPVE : LISTE DES NOMS DES VECT_ELEM
! IN  LASSVE : SI VECT_ELEM A ASSEMBLER
! IN  LCALVE : SI VECT_ELEM A CALCULER
! IN  LOPTVE : OPTION DE CALCUL DES VECT_ELEM
!
! ----------------------------------------------------------------------
!
    character(len=6) :: typvec
    integer :: ivect
    character(len=19) :: vecele, vecass
    real(kind=8) :: instam, instap
    character(len=24) :: modele
    aster_logical :: lcalc, lasse
    character(len=16) :: option
!
! ----------------------------------------------------------------------
!
    if (numins .eq. 0) then
        instam = 0.d0
        instap = diinst(sddisc,numins)
    else
        instam = diinst(sddisc,numins-1)
        instap = diinst(sddisc,numins)
    endif
    modele = modelz
!
! --- CALCUL ET ASSEMBLAGE DES VECT_ELEM
!
    do ivect = 1, nbvect
!
! --- VECT_ELEM COURANT
!
        typvec = ltypve(ivect)
        lcalc = lcalve(ivect)
        lasse = lassve(ivect)
        option = loptve(ivect)
!
        ASSERT(typvec .ne. 'CNFINT')
        ASSERT(typvec .ne. 'CNDIRI')
        ASSERT(typvec .ne. 'CNBUDI')
!
! --- CALCULER VECT_ELEM
!
        if (lcalc) then
            call nmchex(veelem, 'VEELEM', typvec, vecele)
            call nmcalv(typvec, modele, lischa, mate  , carele,&
                        ds_constitutive, numedd, comref, ds_measure, instam,&
                        instap, valinc, solalg, sddyna, option,&
                        vecele)
        endif
!
! --- ASSEMBLER VECT_ELEM
!
        if (lasse) then
            call nmchex(veasse  , 'VEASSE', typvec, vecass)
            call nmassv(typvec  , modelz, lischa, mate, carele,&
                        ds_constitutive, numedd, instam, instap, &
                        sddyna         , ds_measure, valinc, comref,&
                        ds_inout, measse, vecele, vecass)
        endif
    end do
!
end subroutine
