subroutine capesa(char, noma, ipesa, ndim)
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
    implicit none
! BUT : STOCKAGE DE LA PESANTEUR DANS UNE CARTE ALLOUEE SUR LE
!       LIGREL DU MODELE
!
! ARGUMENTS D'ENTREE:
!      CHAR  : NOM UTILISATEUR DU RESULTAT DE CHARGE
!      NOMA  : NOM DU MAILLAGE
!      IPESA : OCCURENCE DU MOT-CLE FACTEUR PESANTEUR
!      NDIM  : DIMENSIOn DU PROBLEME
!
#include "jeveux.h"
#include "asterc/r8miem.h"
#include "asterfort/alcart.h"
#include "asterfort/char_affe_neum.h"
#include "asterfort/getvr8.h"
#include "asterfort/getvtx.h"
#include "asterfort/jedetr.h"
#include "asterfort/jeveuo.h"
#include "asterfort/mecact.h"
#include "asterfort/nocart.h"
#include "asterfort/reliem.h"
#include "asterfort/utmess.h"
#include "asterfort/vetyma.h"
    character(len=8), intent(in) :: char
    character(len=8), intent(in) :: noma
    integer, intent(in) :: ipesa
    integer, intent(in) :: ndim
!
    real(kind=8) :: pesa(4), norme, pes(3)
    character(len=8) :: licmp(4)
    character(len=19) :: carte
    integer :: iocc, nbmail, nbgpma
    integer :: nbma, ncmp, npesa
    character(len=8) :: k8b
    character(len=16) :: motclf
    character(len=19) :: cartes(1)
    integer :: ncmps(1)
    real(kind=8), pointer :: valv(:) => null()
    character(len=8), pointer :: vncmp(:) => null()
!
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
    motclf = 'PESANTEUR'
    do iocc = 1, ipesa
        call getvr8('PESANTEUR', 'GRAVITE', iocc=iocc, scal=pesa(1), nbret=npesa)
        call getvr8('PESANTEUR', 'DIRECTION', iocc=iocc, nbval=3, vect=pes,&
                    nbret=npesa)
!
        norme=sqrt( pes(1)*pes(1)+pes(2)*pes(2)+pes(3)*pes(3) )
        if (norme .gt. r8miem()) then
            pesa(2)=pes(1)/norme
            pesa(3)=pes(2)/norme
            pesa(4)=pes(3)/norme
        else
            call utmess('F', 'CHARGES2_53')
        endif
!
        call getvtx('PESANTEUR', 'MAILLE', iocc=iocc, scal=k8b, nbret=nbmail)
        call getvtx('PESANTEUR', 'GROUP_MA', iocc=iocc, scal=k8b, nbret=nbgpma)
        nbma=nbmail+nbgpma
!
!   SI NBMA = 0, ALORS IL N'Y A AUCUN MOT CLE GROUP_MA OU MAILLE,
!   DONC LA PESANTEUR S'APPLIQUE A TOUT LE MODELE (VALEUR PAR DEFAUT)
!
        if (nbma .eq. 0) then
!
!   UTILISATION DE LA ROUTINE MECACT (PAS DE CHANGEMENT PAR RAPPORT
!   A LA PRECEDENTE FACON DE PRENDRE EN COMPTE LA PESANTEUR)
!
            carte=char//'.CHME.PESAN'
            licmp(1)='G'
            licmp(2)='AG'
            licmp(3)='BG'
            licmp(4)='CG'
            call mecact('G', carte, 'MAILLA', noma, 'PESA_R',&
                        ncmp=4, lnomcmp=licmp, vr=pesa)
        else
!
!   APPLICATION DE LA PESANTEUR AUX MAILLES OU GROUPES DE MAILLES
!   MENTIONNES. ROUTINE MODIFIEE ET CALQUEE SUR LA PRISE EN COMPTE
!   D'UNE PRESSION (CBPRES ET CAPRES)
!
            carte=char//'.CHME.PESAN'
            call alcart('G', carte, noma, 'PESA_R')
            call jeveuo(carte//'.NCMP', 'E', vk8=vncmp)
            call jeveuo(carte//'.VALV', 'E', vr=valv)
!
! --- STOCKAGE DE FORCES NULLES SUR TOUT LE MAILLAGE
!
            ncmp = 4
            vncmp(1) = 'G'
            vncmp(2) = 'AG'
            vncmp(3) = 'BG'
            vncmp(4) = 'CG'
!
            valv(1) = 0.d0
            valv(2) = 0.d0
            valv(3) = 0.d0
            valv(4) = 0.d0
            call nocart(carte, 1, ncmp)
!
!
! --- STOCKAGE DANS LA CARTE
!
            valv(1) = pesa(1)
            valv(2) = pesa(2)
            valv(3) = pesa(3)
            valv(4) = pesa(4)
            cartes(1) = carte
            ncmps(1) = ncmp
            call char_affe_neum(noma, ndim, motclf, iocc, 1,&
                                cartes, ncmps)
        endif
    end do
end subroutine
