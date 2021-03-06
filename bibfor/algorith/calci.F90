subroutine calci(phib24, phi1j, bj, cij1)
!-------------------------------------------------------------------
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
!-------------------------------------------------------------------
    implicit none
!
! ROUTINE CALCULANT LA MASSE AJOUTEE SUR LE MODELE THERMIQUE
!                    D INTERFACE
! IN: POTENTIELS PHIBARRE ET PHI1
! OUT : CIJ1 :COEFFICIENT D'AMORTISSEMENT CORRESPONDANT AU POTENTIEL
! PHI1
#include "jeveux.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetr.h"
#include "asterfort/jelira.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/mrmult.h"
#include "asterfort/mtdscr.h"
#include "asterfort/wkvect.h"
#include "asterfort/as_deallocate.h"
#include "asterfort/as_allocate.h"
#include "blas/ddot.h"
    integer ::   imade, nphi1
    real(kind=8) :: cij1
    character(len=19) :: phib24, phi1j, bj
!--------------------------------------------------------------------
!
!-----------------------------------------------------------------------

    real(kind=8), pointer :: produit(:) => null()
    real(kind=8), pointer :: barre(:) => null()
    real(kind=8), pointer :: phi1(:) => null()
!-----------------------------------------------------------------------
    call jemarq()
    call jeveuo(phi1j//'.VALE', 'L', vr=phi1)
    call jeveuo(phib24//'.VALE', 'L', vr=barre)
    call jelira(phi1j//'.VALE', 'LONMAX', nphi1)
!
    AS_ALLOCATE(vr=produit, size=nphi1)
!
! --- RECUPERATION DES DESCRIPTEURS DE MATRICE ASSEMBLEE MADE
!
    call mtdscr(bj)
    call jeveuo(bj(1:19)//'.&INT', 'E', imade)
!
! ---PRODUIT MATRICE BJ ET LE VECTEUR POTENTIEL PHI1J
!
    call mrmult('ZERO', imade, phi1, produit, 1,&
                .true._1)
!
!
!--PRODUITS SCALAIRES VECTEURS  PHI1J PAR LE VECTEUR RESULTAT PRECEDENT
!
    cij1= ddot(nphi1,barre, 1,produit, 1)
!
!---------------- MENAGE SUR LA VOLATILE ---------------------------
!
    AS_DEALLOCATE(vr=produit)
!
    call jedema()
end subroutine
