function diinst(sddisc, numins)
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
!
    implicit none
    real(kind=8) :: diinst
#include "jeveux.h"
#include "asterfort/gettco.h"
#include "asterfort/assert.h"
#include "asterfort/jedema.h"
#include "asterfort/jeexin.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
    integer :: numins
    character(len=19) :: sddisc
!
! ----------------------------------------------------------------------
!
! ROUTINE MECA_NON_LINE (UTILITAIRE)
!
! ACCES A LA VALEUR D'UN INSTANT
!
! ----------------------------------------------------------------------
!
!
! IN  SDDISC : SD DISCRETISATION LOCALE OU
! IN  NUMINS : NUMERO D'INSTANTS
! OUT DIINST : VALEUR DE L'INSTANT
!
!
!
!
!
    integer :: iret, jinst
    character(len=24) :: tpsdit
    character(len=16) :: typeco
!
! ----------------------------------------------------------------------
!
    call jemarq()
!
    if (numins .lt. 0) then
        ASSERT(.false.)
    endif
    typeco = ' '
!
    call gettco(sddisc, typeco)
!
! --- ACCES SD LISTE D'INSTANTS
!
    if (typeco .eq. 'LISTR8_SDASTER') then
        call jeveuo(sddisc(1:19)//'.VALE', 'L', jinst)
    else if (typeco.eq.'LIST_INST') then
        call jeveuo(sddisc(1:8)//'.LIST.DITR', 'L', jinst)
    else
        tpsdit = sddisc(1:19)//'.DITR'
        call jeexin(tpsdit, iret)
        if (iret .eq. 0) then
            diinst = 0.d0
            goto 99
        else
            call jeveuo(tpsdit, 'L', jinst)
        endif
    endif
!
! --- VALEUR DE L'INSTANT
!
    diinst = zr(jinst+numins)
 99 continue
!
    call jedema()
end function
