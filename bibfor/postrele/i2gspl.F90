subroutine i2gspl(debspl, tvois1, tvois2, tplace, schm,&
                  achm, pts, pta)
    implicit none
#include "asterf_types.h"
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
!
!******************************************************************
!
!         REPERAGE DANS LE GROUPE DE MAILLE D' UN CHEMIN
!         SIMPLE CONNAISSANT SA MAILLE DE DEPART.
!
!         DEBSPL (IN)      : MAILLE DE DEPART
!
!         TVOISI (IN)      : TABLES DES VOISINS
!
!         TPLACE (IN-OUT)  : TABLE DES MAILLES DEJA PLACEES
!
!         SCHM   (OUT)     : TABLE DE STRUCTURATION DES CHEMINS
!
!         ACHM   (OUT)     : TABLE D 'ACCES A SCHM
!
!         PTS    (IN-OUT)  : POINTEUR SUR SCHM
!
!         PTA    (IN-OUT)  : POINTEUR SUR ACHM
!
!******************************************************************
!
    aster_logical :: tplace(*)
    integer :: debspl, tvois1(*), tvois2(*)
    integer :: schm(*), achm(*), pts, pta
!
    aster_logical :: fini
!
    integer :: s, s1, s2
!
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
    fini = .false.
!
    s1 = 0
!
    s2 = 0
!
    s = debspl
!
    schm(pts) = s
    achm(pta) = pts
!
    tplace(s) = .true.
!
    pts = pts + 1
    pta = pta + 1
!
    if (tvois1(s) .eq. 0) then
!
        schm(pts) = 0
!
        pts = pts + 1
!
        fini = .true.
!
    endif
!
 10 continue
    if (.not. fini) then
!
        s1 = tvois1(s)
        s2 = tvois2(s)
!
        if (.not. tplace(s1)) then
!
            s = s1
!
            tplace(s) = .true.
!
        else
!
            s = s2
!
            if (s2 .ne. 0) then
!
                tplace(s) = .true.
!
            else
!
                fini = .true.
!
            endif
!
        endif
!
        schm(pts) = s
!
        pts = pts + 1
!
        goto 10
!
    endif
!
end subroutine
