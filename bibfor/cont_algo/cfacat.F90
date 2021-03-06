subroutine cfacat(indic, nbliac, ajliai, spliai,&
                  indfac, &
                  sdcont_defi, sdcont_solv, solveu, lmat, &
                  xjvmax)
!
implicit none
!
#include "asterfort/cfaca1.h"
#include "asterfort/cfaca2.h"
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
!
    integer :: nbliac
    integer :: indic, ajliai, spliai
    integer :: indfac, lmat
    real(kind=8) :: xjvmax
    character(len=24) :: sdcont_defi, sdcont_solv
    character(len=19) :: solveu
!
! --------------------------------------------------------------------------------------------------
!
! Contact - Solve
!
! Discrete methods - Compute A.C-1.AT
!
! --------------------------------------------------------------------------------------------------
!
! IN  DEFICO : SD DE DEFINITION DU CONTACT (ISSUE D'AFFE_CHAR_MECA)
! IN  RESOCO : SD DE TRAITEMENT NUMERIQUE DU CONTACT
! IN  SOLVEU : SD SOLVEUR
! IN  LMAT   : DESCRIPTEUR DE LA MATR_ASSE DU SYSTEME MECANIQUE
! IN  NBLIAC : NOMBRE DE LIAISONS ACTIVES
! I/O AJLIAI : INDICE DANS LA LISTE DES LIAISONS ACTIVES DE LA DERNIERE
!              LIAISON CORRECTE DU CALCUL
!              DE LA MATRICE DE CONTACT ACM1AT
! I/O XJVMAX : VALEUR DU PIVOT MAX
! I/O SPLIAI : INDICE DANS LA LISTE DES LIAISONS ACTIVES DE LA DERNIERE
!              LIAISON AYANT ETE CALCULEE POUR LE VECTEUR CM1A
! I/O INDFAC : INDICE DE DEBUT DE LA FACTORISATION
! I/O INDIC  : +1 ON A RAJOUTE UNE LIAISON
!              -1 ON A ENLEVE UNE LIAISON
!
! --------------------------------------------------------------------------------------------------
!
    if (indic .ne. -1) then
        call cfaca1(nbliac, ajliai, &
                    sdcont_defi, sdcont_solv, solveu,&
                    lmat)
    endif
    call cfaca2(nbliac, spliai, &
                indfac, sdcont_solv, lmat,&
                xjvmax)
!
    indic = 1
!
end subroutine
