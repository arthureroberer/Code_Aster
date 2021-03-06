subroutine te0597(option, nomte)
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
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: sebastien.fayolle at edf.fr
    implicit none
#include "asterf_types.h"
#include "jeveux.h"
#include "asterfort/assert.h"
#include "asterfort/elref2.h"
#include "asterfort/elrefe_info.h"
#include "asterfort/jevech.h"
#include "asterfort/lteatt.h"
#include "asterfort/niinit.h"
#include "asterfort/nurmtd.h"
#include "asterfort/teattr.h"
#include "asterfort/utmess.h"
!
    character(len=16) :: option, nomte
! ----------------------------------------------------------------------
! FONCTION REALISEE:  CALCUL DE LA RIGIDITE MECANIQUE POUR LES ELEMENTS
!                     INCOMPRESSIBLES A 2 CHAMPS UP
!                     EN 3D/D_PLAN/AXI
!
!    - ARGUMENTS:
!        DONNEES:      OPTION       -->  OPTION DE CALCUL
!                      NOMTE        -->  NOM DU TYPE ELEMENT
! ----------------------------------------------------------------------
!
    aster_logical :: mini
    integer :: ndim, nno1, nno2, nnos, npg, jgn, ntrou
    integer :: iw, ivf1, ivf2, idf1, idf2
    integer :: vu(3, 27), vg(27), vp(27), vpi(3, 27)
    integer :: igeom, imate, imatuu
    integer :: ibid
    character(len=8) :: lielrf(10), typmod(2), alias8
! ----------------------------------------------------------------------
!
! - MINI ELEMENT ?
    call teattr('S', 'ALIAS8', alias8, ibid)
    if (alias8(6:8) .eq. 'TR3' .or. alias8(6:8) .eq. 'TE4') then
        mini = .true.
    else
        mini = .false.
    endif
!
! - FONCTIONS DE FORMES ET POINTS DE GAUSS
    call elref2(nomte, 10, lielrf, ntrou)
    ASSERT(ntrou.ge.2)
    call elrefe_info(elrefe=lielrf(2), fami='RIGI', ndim=ndim, nno=nno2, nnos=nnos,&
                     npg=npg, jpoids=iw, jvf=ivf2, jdfde=idf2, jgano=jgn)
    call elrefe_info(elrefe=lielrf(1), fami='RIGI', ndim=ndim, nno=nno1, nnos=nnos,&
                     npg=npg, jpoids=iw, jvf=ivf1, jdfde=idf1, jgano=jgn)
!
! - TYPE DE MODELISATION
    if (ndim .eq. 2 .and. lteatt('AXIS','OUI')) then
        typmod(1) = 'AXIS  '
    else if (ndim.eq.2 .and. lteatt('D_PLAN','OUI')) then
        typmod(1) = 'D_PLAN  '
    else if (ndim .eq. 3) then
        typmod(1) = '3D'
    else
        call utmess('F', 'ELEMENTS_34', sk=nomte)
    endif
    typmod(2) = '        '
!
! - ACCES AUX COMPOSANTES DU VECTEUR DDL
    call niinit(nomte, typmod, ndim, nno1, 0,&
                nno2, 0, vu, vg, vp,&
                vpi)
!
! - PARAMETRES EN ENTREE
    call jevech('PGEOMER', 'L', igeom)
    call jevech('PMATERC', 'L', imate)
    call jevech('PMATUUR', 'E', imatuu)
!
    call nurmtd(ndim, nno1, nno2, npg, iw,&
                zr(ivf1), zr(ivf2), ivf1, idf1, vu,&
                vp, typmod, igeom, zi(imate), mini,&
                zr(imatuu))
!
end subroutine
