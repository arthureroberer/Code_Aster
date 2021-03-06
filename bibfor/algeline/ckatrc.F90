subroutine ckatrc(vr, xsi, coefck, ck)
    implicit none
!-----------------------------------------------------------------------
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
!-----------------------------------------------------------------------
!
#include "jeveux.h"
#include "asterc/r8pi.h"
#include "asterfort/routhc.h"
    real(kind=8) :: vr, xsi, coefck(1, 11), ck
!
    integer :: ior
    real(kind=8) :: dcldy, a0(2), dr(2)
    real(kind=8) :: pi, hr, hi, xcor, omr
    complex(kind=8) :: pr
!
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
    ior = 2
    pi = r8pi()
    dcldy = coefck(1,1)
    a0(1) = coefck(1,2)
    dr(1) = coefck(1,3)
    a0(2) = coefck(1,4)
    dr(2) = coefck(1,5)
!
    xcor = dble(sqrt(1.0d0-xsi*xsi))
    omr = 2.0d0*pi/vr
    pr = dcmplx(-xsi,xcor)*omr
    call routhc(hr, hi, pr, a0, dr,&
                ior)
    ck = dcldy*(hr+hi*xsi/xcor)
!
end subroutine
