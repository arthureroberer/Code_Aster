subroutine dismes(questi, nomobz, repi, repkz, ierd)
    implicit   none
#include "jeveux.h"
!
#include "asterfort/assert.h"
#include "asterfort/dismgd.h"
#include "asterfort/jedema.h"
#include "asterfort/jeexin.h"
#include "asterfort/jemarq.h"
#include "asterfort/jenonu.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexnom.h"
    integer :: repi, ierd
    character(len=*) :: questi, nomobz, repkz
! person_in_charge: jacques.pellet at edf.fr
! ----------------------------------------------------------------------
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
!
!     --     DISMOI(CHAM_ELEM_S)
!
!       QUESTI : TEXTE PRECISANT LA QUESTION POSEE
!       NOMOBZ : NOM D'UN OBJET DE TYPE LIGREL
!
! OUT : REPI   : REPONSE ( SI ENTIERE )
!       REPKZ  : REPONSE ( SI CHAINE DE CARACTERES )
!       IERD   : CODE RETOUR (0--> OK, -1 --> CHAMP INEXISTANT)
!
! ----------------------------------------------------------------------
!
    integer :: iret, gd
    character(len=8) :: nogd
    character(len=19) :: nomob
    character(len=24) :: questl
    character(len=32) :: repk
    integer, pointer :: cesd(:) => null()
    character(len=8), pointer :: cesk(:) => null()
! DEB-------------------------------------------------------------------
!
    call jemarq()
    repk = ' '
    repi = 0
    ierd = 0
!
    nomob = nomobz
    questl = questi
!
    call jeexin(nomob//'.CESD', iret)
    if (iret .eq. 0) then
        ierd = 1
        goto 9999
    endif
!
    call jeveuo(nomob//'.CESD', 'L', vi=cesd)
    call jeveuo(nomob//'.CESK', 'L', vk8=cesk)
    nogd = cesk(2)
    call jenonu(jexnom('&CATA.GD.NOMGD', nogd), gd)
!
    if (questi .eq. 'TYPE_CHAMP') then
        if (cesk(3) .eq. 'ELEM') then
            repk = 'CESE'
        else if (cesk(3).eq.'ELGA') then
            repk = 'CESG'
        else if (cesk(3).eq.'ELNO') then
            repk = 'CESN'
        else
            ASSERT(.false.)
        endif
!
    else if (questi .eq. 'NOM_MAILLA') then
        repk=cesk(1)
!
    else if (questl(1:6) .eq. 'NUM_GD') then
        repi = gd
!
    else if (questl(1:6) .eq. 'NOM_GD') then
        repk = nogd
!
    else if (questi .eq. 'MXNBSP') then
        repi=cesd(4)
!
    else if (questi .eq. 'TYPE_SCA') then
        call dismgd(questi, nogd, repi, repk, ierd)
!
    else
        ierd = 1
    endif
!
9999  continue
    repkz = repk
!
    call jedema()
end subroutine
