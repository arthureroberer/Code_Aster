subroutine lxnoac(chin, chout)
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
! aslint: disable=
    implicit none
#include "asterfort/lxlgut.h"
    character(len=*) :: chin, chout
!
! ----------------------------------------------------------------------
! --- REMPLACE TOUS LES CARACTERES NON AUTORISES D'UNE CHAINE
!     DE CARACTERES PAR DES '_' (UNDERSCORE).
!      IN : CHIN  = CHAINE EN ENTREE
!     OUT : CHOUT = CHAINE AVEC UNIQUEMENT DES CARACTERES LICITES
! ----------------------------------------------------------------------
!
    integer :: mxchar
    parameter ( mxchar=255 )
    character(len=1) :: class(0:mxchar)
    character(len=255) :: keep
    integer :: i, long, long2
!
    integer :: first
    save         class, first
!
!     ------------------------------------------------------------------
    data first/0/
!                123456789.123456789.123456789.123456789.123456789.12
    data keep/'ABCDEFGHIJKLMONPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890'/
!     ------------------------------------------------------------------
!
    if (first .eq. 0) then
!
!        INITIALISATION DES TABLES DE CONVERSION
!
        first = 1
        do i = 0, mxchar
            class(i) = '_'
        end do
!
        do i = 1, lxlgut(keep)
            class(ichar(keep(i:i))) = keep(i:i)
        end do
!        ---------------------------------------------------------------
!        WRITE(6,'(25X,A)')' *** CONTROLE DE LA TABLE DE CONVERSION ***'
!        WRITE(6,'(10(1X,4A))') (' * ',CHAR(I),'= ',CLASS(I),I=0,255)
!        WRITE(6,'(1X,79(''-''))')
!        ---------------------------------------------------------------
    endif
!
!       LONG = LEN(CHIN)
    long = lxlgut(chin)
    long2 = len(chout)
    do i = 1, min(long, long2)
        chout(i:i) = class(ichar(chin(i:i)))
    end do
!
!     MISE A BLANC DE LA FIN DE LA CHAINE
    do i = min(long, long2)+1, long2
        chout(i:i) = ' '
    end do
!
!     ------------------------------------------------------------------
end subroutine
