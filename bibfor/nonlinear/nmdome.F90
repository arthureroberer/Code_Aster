subroutine nmdome(modele, mate, carele, lischa, result,&
                  nuord)
!
implicit none
!
#include "asterf_types.h"
#include "asterc/getres.h"
#include "asterfort/dismoi.h"
#include "asterfort/getvid.h"
#include "asterfort/jedema.h"
#include "asterfort/jeexin.h"
#include "asterfort/jemarq.h"
#include "asterfort/nmdoch.h"
#include "asterfort/rcmfmc.h"
#include "asterfort/rslesd.h"
#include "asterfort/utmess.h"
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
!
    integer :: nuord
    character(len=8) :: result
    character(len=19) :: lischa
    character(len=24) :: modele, mate, carele
!
! ----------------------------------------------------------------------
!
! ROUTINE UTILITAIRE
!
! SAISIE ET VERIFICATION DE LA COHERENCE DES DONNEES MECANIQUES
!
! ----------------------------------------------------------------------
!
!
! VAR MODELE  : NOM DU MODELE
! OUT MATE    : NOM DU CHAMP DE MATERIAU CODE
! OUT CARELE  : CARACTERISTIQUES DES POUTRES ET COQUES
! I/O LISCHA  : SD L_CHARGES
! IN  RESULT  : NOM DE LA SD RESULTAT
! IN  NUORD   : NUMERO D'ORDRE
!
! ----------------------------------------------------------------------
!
    integer :: iexcit, n1
    character(len=8) :: k8bid, k8bla
    character(len=8) :: cara, nomo, materi, repons
    character(len=16) :: nomcmd, typesd
    character(len=19) :: excit
    aster_logical :: l_load_user
!
! ----------------------------------------------------------------------
!
    call jemarq()
    call getres(k8bid, typesd, nomcmd)
!
! --- INITIALISATIONS
!
    iexcit = 1
    excit = ' '
    k8bla = ' '
    l_load_user = .true.
!
! --- LECTURES
!
    if (nomcmd .eq. 'LIRE_RESU' .or. nomcmd .eq. 'CREA_RESU') goto 500
!
    if ((nomcmd.eq.'CALC_CHAMP') .or. (nomcmd.eq.'POST_ELEM')) then
!
! ------ RECUPERATION DU MODELE, MATERIAU, CARA_ELEM et EXCIT
!        POUR LE NUMERO D'ORDRE NUORDR
!
        call rslesd(result, nuord, modele(1:8), materi, carele(1:8),&
                    excit, iexcit)
        l_load_user = iexcit.eq.1
!
        if (materi .ne. k8bla) then
            call rcmfmc(materi, mate)
        else
            mate = ' '
        endif
        cara = carele(1:8)
    else
!
! ------ LE MODELE
!
        if (modele .eq. ' ') then
            call getvid(' ', 'MODELE', scal=nomo, nbret=n1)
            if (n1 .eq. 0) then
                call utmess('F', 'CALCULEL3_50')
            endif
            modele = nomo
        endif
!
! ------ LE MATERIAU
!
        materi = ' '
        call getvid(' ', 'CHAM_MATER', scal=materi, nbret=n1)
        call dismoi('BESOIN_MATER', modele, 'MODELE', repk=repons)
        if ((n1.eq.0) .and. (repons(1:3).eq.'OUI')) then
            call utmess('A', 'CALCULEL3_40')
        endif
        if (n1 .ne. 0) then
            call rcmfmc(materi, mate)
        else
            mate = ' '
        endif
!
! ------ LES CARACTERISTIQUES ELEMENTAIRES
!
        cara = ' '
!
        call getvid(' ', 'CARA_ELEM', scal=cara, nbret=n1)
        call dismoi('EXI_RDM', modele, 'MODELE', repk=repons)
        if ((n1.eq.0) .and. (repons(1:3).eq.'OUI')) then
            call utmess('A', 'CALCULEL3_39')
        endif
!
        carele = cara
    endif
!
500 continue
!
! --- TRAITEMENT DES CHARGES
!
    call nmdoch(lischa, l_load_user, excit)
!
    call jedema()
end subroutine
