subroutine zengen(ppr, ppi, yy0, dy0, dyy, decoup)
    implicit none
#include "asterf_types.h"
    real(kind=8) :: ppr(*)
    integer      :: ppi(*)
    real(kind=8) :: yy0(*)
    real(kind=8) :: dy0(*)
    real(kind=8) :: dyy(*)
    aster_logical :: decoup
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
! person_in_charge: jean-luc.flejou at edf.fr
! ----------------------------------------------------------------------
!
!        MODÈLE DE D'AMORTISSEUR DE ZENER GÉNÉRALISÉ
!
!  IN
!     ppr      : paramètres réels
!     ppi      : paramètres entiers
!     nbeq     : nombre d'équations
!     yy0      : valeurs initiales
!     dy0      : dérivées initiales
!     pf       : adresse des fonctions
!
!  OUT
!     dyy      : dérivées calculées
!     decoup   : pour forcer l'adaptation du pas de temps
!
! ----------------------------------------------------------------------
!
    real(kind=8) :: seuil, xx
    parameter (seuil=1.0e+10)
!
!   système d'équations : contrainte, epsivisq, epsi , dissipation
    integer :: isig, iepvis, iepsi, idissi
    parameter (isig=1,iepvis=2,iepsi=3,idissi=4)
!   paramètres du modèle : s1, e2, s3, nu3, alpha3
    integer :: is1, ie2, is3, inu3, ialp3
    parameter (is1=1,ie2=2,is3=3,inu3=4,ialp3=5)
!
    dyy(iepsi) = dy0(iepsi)
    xx = (yy0(isig)*(1.0d0+ppr(ie2)*ppr(is1)) -ppr(ie2)*yy0(iepsi))/ppr(inu3)
    if (abs(xx) .gt. seuil) then
        if (log10(abs(xx)) .gt. 200.0d0 * ppr(ialp3)) then
            decoup=.true.
            goto 999
        endif
    endif
    if (xx .ge. 0.0d0) then
        dyy(iepvis) = ( abs(xx) )**(1.0d0/ppr(ialp3))
    else
        dyy(iepvis) = -( abs(xx) )**(1.0d0/ppr(ialp3))
    endif
    dyy(idissi) = ppr(inu3)*abs(xx*dyy(iepvis))
!
    dyy(isig) = (dyy(iepsi)*(1.0d0+ppr(ie2)*ppr(is3)) - dyy(iepvis))
    dyy(isig) = dyy(isig)/(ppr(is1)+ppr(is3)+ppr(ie2)*ppr(is1)*ppr(is3))
!
999 continue
end subroutine
