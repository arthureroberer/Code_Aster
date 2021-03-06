subroutine nmassv(typvez         , modelz, lischa, mate    , carele,&
                  ds_constitutive, numedd, instam, instap  , sddyna,&
                  ds_measure     , valinc, comref, ds_inout, measse,&
                  vecelz         , vecasz)
!
use NonLin_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "jeveux.h"
#include "asterfort/asasve.h"
#include "asterfort/ascova.h"
#include "asterfort/assert.h"
#include "asterfort/assmiv.h"
#include "asterfort/assvec.h"
#include "asterfort/assvss.h"
#include "asterfort/copisd.h"
#include "asterfort/infdbg.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/ndfdyn.h"
#include "asterfort/ndynlo.h"
#include "asterfort/nmamod.h"
#include "asterfort/nmchex.h"
#include "asterfort/nmcvci.h"
#include "asterfort/nmdebg.h"
#include "asterfort/nmmacv.h"
#include "asterfort/nmtime.h"
#include "asterfort/nmvcpr.h"
#include "asterfort/nmviss.h"
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
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
!
    character(len=*) :: modelz, typvez
    character(len=19) :: lischa
    real(kind=8) :: instap, instam
    character(len=19) :: sddyna
    character(len=24) :: mate, carele, numedd, comref
    type(NL_DS_Constitutive), intent(in) :: ds_constitutive
    type(NL_DS_Measure), intent(inout) :: ds_measure
    character(len=19) :: measse(*), valinc(*)
    type(NL_DS_InOut), intent(in) :: ds_inout
    character(len=*) :: vecasz, vecelz
!
! --------------------------------------------------------------------------------------------------
!
! ROUTINE MECA_NON_LINE (CALCUL)
!
! ASSEMBLAGE DES VECTEURS ELEMENTAIRES
!
! --------------------------------------------------------------------------------------------------
!
! IN  TYPVEC : TYPE DE CALCUL VECT_ELEM
! IN  MODELE : MODELE
! IN  LISCHA : LISTE DES CHARGES
! IN  MATE   : CHAMP MATERIAU
! IN  CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
! In  ds_constitutive  : datastructure for constitutive laws management
! IN  NUMEDD : NUME_DDL
! IN  INSTAP : INSTANT PLUS
! IN  SDDYNA : SD DYNAMIQUE
! IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
! IN  COMREF : VARI_COM DE REFERENCE
! IO  ds_measure       : datastructure for measure and statistics management
! In  ds_inout         : datastructure for input/output management
! IN  VECELE : VECT_ELEM A ASSEMBLER
! OUT VECASS : VECT_ASSE CALCULEE
!
! --------------------------------------------------------------------------------------------------
!
    real(kind=8) :: r8bid
    character(len=19) :: sstru
    character(len=19) :: vecele
    character(len=24) :: vaonde, vadido, vafedo, valamp, vaimpe
    character(len=24) :: vafepi, vafsdo
    character(len=8) :: modele
    character(len=24) :: vecass
    character(len=19) :: depmoi, vitplu, accplu, depplu, accmoi, vitmoi
    character(len=19) :: depkm1, vitkm1, acckm1, romkm1, romk
    character(len=24) :: charge, infoch, fomult, fomul2
    character(len=16) :: typvec
    integer :: jimpe, jvaanc
    integer :: ifm, niv
!
! ----------------------------------------------------------------------
!
    call jemarq()
    call infdbg('MECA_NON_LINE', ifm, niv)
!
! --- INITIALISATIONS
!
    typvec = typvez
    modele = modelz
    vecass = vecasz
    vecele = vecelz
!
    charge = lischa(1:19)//'.LCHA'
    infoch = lischa(1:19)//'.INFC'
    fomult = lischa(1:19)//'.FCHA'
    fomul2 = lischa(1:19)//'.FCSS'
!
! --- DECOMPACTION DES VARIABLES CHAPEAUX
!
    if (valinc(1)(1:1) .ne. ' ') then
        call nmchex(valinc, 'VALINC', 'DEPMOI', depmoi)
        call nmchex(valinc, 'VALINC', 'VITMOI', vitmoi)
        call nmchex(valinc, 'VALINC', 'ACCMOI', accmoi)
        call nmchex(valinc, 'VALINC', 'DEPPLU', depplu)
        call nmchex(valinc, 'VALINC', 'VITPLU', vitplu)
        call nmchex(valinc, 'VALINC', 'ACCPLU', accplu)
        call nmchex(valinc, 'VALINC', 'DEPKM1', depkm1)
        call nmchex(valinc, 'VALINC', 'VITKM1', vitkm1)
        call nmchex(valinc, 'VALINC', 'ACCKM1', acckm1)
        call nmchex(valinc, 'VALINC', 'ROMKM1', romkm1)
        call nmchex(valinc, 'VALINC', 'ROMK  ', romk)
    endif
!
! --- AFFICHAGE
!
    if (niv .ge. 2) then
        write (ifm,*) '<MECANONLINE><VECT> ASSEMBLAGE DES VECT_ELEM DE TYPE <',typvec,'>'
    endif
!
! - Launch timer
!
    call nmtime(ds_measure, 'Init'  , '2nd_Member')
    call nmtime(ds_measure, 'Launch', '2nd_Member')
!
! --- FORCES NODALES
!
    if (typvec .eq. 'CNFNOD') then
        call assvec('V', vecass, 1, vecele, [1.d0],&
                    numedd, ' ', 'ZERO', 1)
!
! --- DEPLACEMENTS DIRICHLET FIXE
!
    else if (typvec.eq.'CNDIDO') then
        call asasve(vecele, numedd, 'R', vadido)
        call ascova('D', vadido, fomult, 'INST', instap,&
                    'R', vecass)
!
! --- DEPLACEMENTS DIRICHLET PILOTE
!
    else if (typvec.eq.'CNDIPI') then
        call assvec('V', vecass, 1, vecele, [1.d0],&
                    numedd, ' ', 'ZERO', 1)
!
! --- FORCES DE LAPLACE
!
    else if (typvec.eq.'CNLAPL') then
        call asasve(vecele, numedd, 'R', valamp)
        call ascova('D', valamp, fomult, 'INST', instap,&
                    'R', vecass)
!
! --- FORCES ONDES PLANES
!
    else if (typvec.eq.'CNONDP') then
        call asasve(vecele, numedd, 'R', vaonde)
        call ascova('D', vaonde, ' ', 'INST', r8bid,&
                    'R', vecass)
!
! --- FORCES IMPEDANCES
!
    else if (typvec(1:9).eq.'CNIMPP') then
        call asasve(vecele, numedd, 'R', vaimpe)
        call jeveuo(vaimpe, 'L', jvaanc)
        call jeveuo(zk24(jvaanc)(1:19)//'.VALE', 'L', jimpe)
        call copisd('CHAMP_GD', 'V', zk24(jvaanc), vecass)
    else if (typvec(1:9).eq.'CNIMPC') then
        call asasve(vecele, numedd, 'R', vaimpe)
        call jeveuo(vaimpe, 'L', jvaanc)
        call jeveuo(zk24(jvaanc)(1:19)//'.VALE', 'L', jimpe)
        call copisd('CHAMP_GD', 'V', zk24(jvaanc), vecass)
!
! --- FORCES FIXES MECANIQUES DONNEES
!
    else if (typvec.eq.'CNFEDO') then
        call asasve(vecele, numedd, 'R', vafedo)
        call ascova('D', vafedo, fomult, 'INST', instap,&
                    'R', vecass)
!
! --- FORCES PILOTEES
!
    else if (typvec.eq.'CNFEPI') then
        call asasve(vecele, numedd, 'R', vafepi)
        call ascova('D', vafepi, fomult, 'INST', instap,&
                    'R', vecass)
!
! --- FORCES ISSUES DU CALCUL PAR SOUS-STRUCTURATION
!
    else if (typvec.eq.'CNSSTF') then
        call assvss('V', vecass, vecele, numedd, ' ',&
                    'ZERO', 1, fomul2, instap)
!
! --- FORCES SUIVEUSES
!
    else if (typvec.eq.'CNFSDO') then
        call asasve(vecele, numedd, 'R', vafsdo)
        call ascova('D', vafsdo, fomult, 'INST', instap,&
                    'R', vecass)
!
! --- FORCE DE REFERENCE POUR VARIABLES DE COMMANDE INITIALES
!
    else if (typvec.eq.'CNVCF1') then
        call assvec('V', vecass, 1, vecele, [1.d0],&
                    numedd, ' ', 'ZERO', 1)
!
! --- FORCE DE REFERENCE POUR VARIABLES DE COMMANDE COURANTES
!
    else if (typvec.eq.'CNVCF0') then
        call assvec('V', vecass, 1, vecele, [1.d0],&
                    numedd, ' ', 'ZERO', 1)
!
! --- CONDITIONS DE DIRICHLET VIA AFFE_CHAR_CINE (PAS DE VECT_ELEM)
!
    else if (typvec.eq.'CNCINE') then
        call nmcvci(charge, infoch, fomult, numedd, depmoi,&
                    instap, vecass)
!
! --- FORCES VEC_ISS
!
    else if (typvec.eq.'CNVISS') then
        call nmviss(numedd, sddyna, ds_inout, instam, instap,&
                    vecass)
!
! --- FORCES ISSUES DES MACRO-ELEMENTS (PAS DE VECT_ELEM)
! --- VECT_ASSE(MACR_ELEM) = MATR_ASSE(MACR_ELEM) * VECT_DEPL
!
    else if (typvec.eq.'CNSSTR') then
        call nmchex(measse, 'MEASSE', 'MESSTR', sstru)
        call nmmacv(depplu, sstru, vecass)
!
! --- FORCES ISSUES DES VARIABLES DE COMMANDE (PAS DE VECT_ELEM)
!
    else if (typvec.eq.'CNVCPR') then
        call nmvcpr(modele, mate  , carele, comref, ds_constitutive%compor, &
                    valinc, nume_dof_ = numedd, base_ = 'V',&
                    vect_elem_prev_ = '&&VEVCOM',&
                    vect_elem_curr_ = '&&VEVCOP',&
                    cnvcpr_ = vecass)
!
! --- FORCE D'EQUILIBRE DYNAMIQUE (PAS DE VECT_ELEM)
!
    else if (typvec.eq.'CNDYNA') then
        call ndfdyn(sddyna, measse, vitplu, accplu, vecass)
!
! --- FORCES D'AMORTISSEMENT MODAL EN PREDICTION (PAS DE VECT_ELEM)
!
    else if (typvec.eq.'CNMODP') then
        call nmamod('PRED', numedd, sddyna, vitplu, vitkm1,&
                    vecass)
!
! --- FORCES D'AMORTISSEMENT MODAL EN CORRECTION (PAS DE VECT_ELEM)
!
    else if (typvec.eq.'CNMODC') then
        call nmamod('CORR', numedd, sddyna, vitplu, vitkm1,&
                    vecass)
    else
        ASSERT(.false.)
    endif
!
! --- DEBUG
!
    if (niv .eq. 2) then
        call nmdebg('VECT', vecass, ifm)
    endif
!
! - Stop timer
!
    call nmtime(ds_measure, 'Stop', '2nd_Member')
!
    call jedema()
!
end subroutine
