subroutine lislfc(list_load_resu, i_load, indic , l_load_user, nexci,&
                  lfcplx        , lacce , fctcsr, nomfct)
!
implicit none
!
#include "asterf_types.h"
#include "jeveux.h"
#include "asterfort/assert.h"
#include "asterfort/codent.h"
#include "asterfort/focstc.h"
#include "asterfort/focste.h"
#include "asterfort/getvc8.h"
#include "asterfort/getvid.h"
#include "asterfort/getvr8.h"
#include "asterfort/jedema.h"
#include "asterfort/jeexin.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
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
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
!
    aster_logical :: lfcplx, lacce, l_load_user
    integer :: i_load, indic
    integer :: nexci
    character(len=19) :: list_load_resu
    character(len=8) :: fctcsr
    character(len=8) :: nomfct
!
! ----------------------------------------------------------------------
!
! ROUTINE UTILITAIRE (LISTE_CHARGES)
!
! NOM DE LA FONCTION MULTIPLICATRICE
!
! ----------------------------------------------------------------------
!
!
!
!
!
!
!
    integer :: jinfc2, jlcha2
    character(len=24) :: k24bid
    integer :: nfcplx, nfreel
    integer :: nccplx, ncreel
    integer :: nfacce
    character(len=4) :: knum
    complex(kind=8) :: ccoef
    real(kind=8) :: rcoef, icoef
    character(len=19) :: nomf19
    integer :: iret
    character(len=24), pointer :: fcha(:) => null()
!
! ----------------------------------------------------------------------
!
    call jemarq()
!
! --- ACCES SD
!
    if (.not.l_load_user) then
        call jeveuo(list_load_resu(1:19)//'.INFC', 'L', jinfc2)
        call jeveuo(list_load_resu(1:19)//'.LCHA', 'L', jlcha2)
        call jeveuo(list_load_resu(1:19)//'.FCHA', 'L', vk24=fcha)
    endif
!
! -------- FONCTIONS MULTIPLICATIVES DES CHARGES
!
    if (lfcplx) then
!
        call getvid('EXCIT', 'FONC_MULT_C', iocc=i_load, scal=nomfct, nbret=nfcplx)
        call getvid('EXCIT', 'FONC_MULT', iocc=i_load, scal=nomfct, nbret=nfreel)
!
        if ((nfcplx.eq.0) .and. (nfreel.eq.0)) then
            call codent(i_load, 'D0', knum)
            nomfct = '&&NC'//knum
!
            call getvc8('EXCIT', 'COEF_MULT_C', iocc=i_load, scal=ccoef, nbret=nccplx)
            if (nccplx .eq. 0) then
                call getvr8('EXCIT', 'COEF_MULT', iocc=i_load, scal=rcoef, nbret=ncreel)
                ASSERT(ncreel.eq.0)
                call focste(nomfct, 'TOUTRESU', rcoef, 'V')
            else
                rcoef = dble ( ccoef )
                icoef = dimag( ccoef )
                call focstc(nomfct, 'TOUTRESU', rcoef, icoef, 'V')
            endif
        endif
!
    else
        if (.not.l_load_user) then
            if (fcha(i_load)(1:1) .eq. '&') then
                nfreel = 0
            else
                nfreel = 1
            endif
        else
            call getvid('EXCIT', 'FONC_MULT', iocc=indic, scal=k24bid, nbret=nfreel)
        endif
!
        if (lacce) then
            call getvid('EXCIT', 'ACCE', iocc=indic, scal=k24bid, nbret=nfacce)
        else
            nfacce = 0
        endif
!
! -------- PAS DE FONCTIONS MULTIPLICATRICES -> CREATION FCT CSTE = 1
!
        if (nfreel .eq. 0 .and. nfacce .eq. 0) then
            nomf19 = fctcsr
            call jeexin(nomf19//'.PROL', iret)
            if (iret .eq. 0) then
                rcoef = 1.d0
                call focste(fctcsr, 'TOUTRESU', rcoef, 'V')
            endif
            nomfct = fctcsr
!
        else
            if (nfreel .ne. 0) then
                if (.not.l_load_user) then
                    nomfct = fcha(i_load)(1:8)
                else if (nexci.ne.0) then
                    call getvid('EXCIT', 'FONC_MULT', iocc=indic, scal=nomfct, nbret=nfreel)
                endif
            endif
!
            if (nfacce .ne. 0) then
                call getvid('EXCIT', 'ACCE', iocc=indic, scal=nomfct, nbret=nfacce)
            endif
!
        endif
    endif
!
    call jedema()
end subroutine
