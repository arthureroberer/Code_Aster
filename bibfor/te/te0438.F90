subroutine te0438(option, nomte)
    implicit none
#include "jeveux.h"
#include "asterfort/elref2.h"
#include "asterfort/elrefe_info.h"
#include "asterfort/jevech.h"
#include "asterfort/cginit.h"
#include "asterfort/cgtang.h"
#include "asterfort/cgepsi.h"
    character(len=16) :: option, nomte
! =====================================================================
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
! =====================================================================
!    - FONCTION REALISEE:  CALCUL DES OPTIONS EPSI_ELGA
!    - ARGUMENTS:
!        DONNEES:      OPTION       -->  OPTION DE CALCUL
!                      NOMTE        -->  NOM DU TYPE ELEMENT
! =====================================================================
    character(len=8) :: typmod(2), lielrf(10)
    integer :: nno1, nno2, npg
    integer :: iepsi
    integer :: iw, ivf1, idf1, igeom
    integer :: npgn, iwn, ivf1n, idf1n, jgnn
    integer :: ivf2, idf2, nnos, jgn
    integer :: iddld
    integer :: ndim, ntrou
    integer :: iu(3, 3), iuc(3), im(3)
    real(kind=8) :: tang(3, 3)
! =====================================================================
    call elref2(nomte, 2, lielrf, ntrou)
    call elrefe_info(elrefe=lielrf(1),fami='RIGI',ndim=ndim,nno=nno1,nnos=nnos,&
  npg=npg,jpoids=iw,jvf=ivf1,jdfde=idf1,jgano=jgn)
    call elrefe_info(elrefe=lielrf(1),fami='NOEU',ndim=ndim,nno=nno1,nnos=nnos,&
  npg=npgn,jpoids=iwn,jvf=ivf1n,jdfde=idf1n,jgano=jgnn)
    call elrefe_info(elrefe=lielrf(2),fami='RIGI',ndim=ndim,nno=nno2,nnos=nnos,&
  npg=npg,jpoids=iw,jvf=ivf2,jdfde=idf2,jgano=jgn)
    ndim=3
! - DECALAGE D'INDICE POUR LES ELEMENTS D'INTERFACE
    call cginit(nomte, iu, iuc, im)

!
! - TYPE DE MODELISATION
!
    typmod(1) = '1D'
    typmod(2) = ' '
!
! - PARAMETRES EN ENTREE
!
    call jevech('PGEOMER', 'L', igeom)
    call jevech('PDEPLAR', 'L', iddld)
!
!     DEFINITION DES TANGENTES
!
    call cgtang(3, nno1, npgn, zr(igeom), zr(idf1n),&
                tang)
    call jevech('PDEFOPG', 'E', iepsi)

    call cgepsi(ndim, nno1, nno2, npg, zr(iw),&
                zr(ivf1), zr(idf1), zr(igeom), tang,&
                zr(iddld),iu,iuc,zr(iepsi))

! ======================================================================
end subroutine
