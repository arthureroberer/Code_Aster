subroutine getvtx(motfac, motcle, iocc, nbval, vect,&
                  scal, nbret, isdefault)
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
! person_in_charge: mathieu.courtois at edf.fr
    implicit none
    character(len=*), intent(in) :: motfac
    character(len=*), intent(in) :: motcle
    integer, intent(in), optional :: iocc
    integer, intent(in), optional :: nbval
    character(len=*), intent(out), optional :: vect(*)
    character(len=*), intent(out), optional :: scal
    integer, intent(out), optional :: nbret
    integer, intent(out), optional :: isdefault
#include "asterc/getvtx_wrap.h"
#include "asterfort/assert.h"
!
#include "asterc/getres.h"
!   really used variables
    integer :: uioc, uisdef, unbret, umax
!   this kind of dynamic allocation is not supported with gfortran < 4.8
!    character(len=:), allocatable :: uvect
!        allocate(character(len=len(scal)) :: uvect)
!        ...
!        deallocate(uvect)
    integer, parameter :: maxlen=255
    character(len=maxlen) :: uvect(1)
    character(len=1) :: vdummy(1)
!
!   motfac + iocc
    if (present(iocc)) then
        uioc = iocc
    else
        uioc = 0
    endif
    ASSERT(motfac == ' ' .or. uioc > 0)
!   vect + nbval
    ASSERT(AU_MOINS_UN3(nbret,scal,vect))
    ASSERT(EXCLUS2(vect,scal))
    if (present(nbval)) then
        umax = nbval
    else
        umax = 1
    endif
!
    if (present(vect)) then
        call getvtx_wrap(motfac, motcle, uioc, uisdef, umax,&
                         vect, unbret)
    else if (present(scal)) then
        ASSERT(len(scal) .le. maxlen)
        call getvtx_wrap(motfac, motcle, uioc, uisdef, umax,&
                         uvect, unbret)
        if (unbret .ne. 0) then
            scal = uvect(1)(1:len(scal))
        endif
    else
        call getvtx_wrap(motfac, motcle, uioc, uisdef, umax,&
                         vdummy, unbret)
    endif
!   if the ".capy" can not ensure that at least 'umax' are provided, you must check
!   the number of values really read using the 'nbret' argument
    ASSERT(present(nbret) .or. umax .eq. unbret)
!
    if (present(isdefault)) then
        isdefault = uisdef
    endif
    if (present(nbret)) then
        nbret = unbret
    endif
!
end subroutine getvtx
