subroutine asschc(matas, nbchc, lchci, nomnu, cumul)
    implicit none
#include "jeveux.h"
#include "asterfort/assert.h"
#include "asterfort/dismoi.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetr.h"
#include "asterfort/jeexin.h"
#include "asterfort/jelira.h"
#include "asterfort/jemarq.h"
#include "asterfort/jenonu.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexnom.h"
#include "asterfort/jexnum.h"
#include "asterfort/wkvect.h"
!
    character(len=*) :: matas, lchci(*), nomnu
    character(len=1) :: base
    integer :: nbchc
!-----------------------------------------------------------------------
! person_in_charge: jacques.pellet at edf.fr
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
!  BUT : ON NOTE LES DDLS ELIMINES PAR LES CHARGES CINEMATIQUES
!
!  REMARQUE : LE RESTE DU TRAITEMENT DES CHARGES CINEMATIQUES EST FAIT
!             AU DERNIER MOMENT (ASMCHC+CSMBGG)
!
!-----------------------------------------------------------------------
! VAR  MATAS   K*19    : NOM DE LA MATR_ASSE
! IN   NBCHC   I       : NOMBRE DE CHARGE CINEMATIQUES
! IN   LCHCI   K*      : LISTE DES NOMS DES CHARGES CINEMATIQUES
!                        L'EFFET DE CES CHARGES EST CUMULE DANS MATAS
! IN   NOMNU   K*14    : NOM DE LA NUMEROTATION
! IN   CUMUL   K4      : 'ZERO' / 'CUMU'
!-----------------------------------------------------------------------
!----------------------------------------------------------------------
!     VARIABLES LOCALES
!----------------------------------------------------------------------
    character(len=4) :: cumul
    character(len=8) :: gd
    character(len=14) :: nu
    character(len=19) :: mat, nomch
    integer ::   neq, numgd, iddes, nec, jccid, idprno
    integer :: nelim, jafci, nimp, imp, ino, iddl, ieq, ich, imatd
    integer, pointer :: nugl(:) => null()
    integer, pointer :: nequ(:) => null()
    character(len=24), pointer :: refa(:) => null()
!----------------------------------------------------------------------
!
    call jemarq()
    mat = matas
    call jeveuo(mat//'.REFA', 'E', vk24=refa)
    nu = nomnu
    ASSERT(refa(2).eq.nu)
    if (nbchc .eq. 0) goto 40
!
!     -- IL N'Y A PEUT-ETRE AUCUN DDL A ELIMINER (CHAR_CINE VIDES) :
    nimp=0
    do ich = 1, nbchc
        nomch = lchci(ich)
        call jeveuo(nomch//'.AFCI', 'L', jafci)
        nimp = nimp + zi(jafci)
    end do
    if (nimp .eq. 0) goto 40
!
!
    call jeexin(nu//'.NUML.DELG', imatd)
    call jeveuo(nu//'.NUME.NEQU', 'L', vi=nequ)
    if (imatd .ne. 0) then
        call jeveuo(nu//'.NUML.NUGL', 'L', vi=nugl)
    endif
    neq = nequ(1)
    call dismoi('NOM_GD', nu, 'NUME_DDL', repk=gd)
    call jenonu(jexnom('&CATA.GD.NOMGD', gd), numgd)
    call jeveuo(jexnum('&CATA.GD.DESCRIGD', numgd), 'L', iddes)
    nec = zi(iddes+2)
    call jelira(mat//'.REFA', 'CLAS', cval=base)
!
    if (cumul .eq. 'ZERO') then
        call jedetr(mat//'.CCID')
        call wkvect(mat//'.CCID', base//' V I ', neq+1, jccid)
    else if (cumul.eq.'CUMU') then
        call jeveuo(mat//'.CCID', 'E', jccid)
    else
        ASSERT(.false.)
    endif
!
!
    call jeveuo(jexnum(nu//'.NUME.PRNO', 1), 'L', idprno)
    nelim=0
    do ich = 1, nbchc
        nomch = lchci(ich)
        call jeveuo(nomch//'.AFCI', 'L', jafci)
        nimp = zi(jafci)
        do imp = 1, nimp
            ino = zi(jafci+3* (imp-1)+1)
            iddl = zi(jafci+3* (imp-1)+2)
            ieq = zi(idprno-1+ (nec+2)* (ino-1)+1) + iddl - 1
            zi(jccid-1+ieq) = 1
        end do
    end do
!
    nelim=0
    do ieq = 1, neq
        if (imatd .ne. 0) then
            if (nugl(ieq) .eq. 0) goto 30
        endif
        if (zi(jccid-1+ieq) .eq. 1) nelim=nelim+1
 30     continue
    end do
    zi(jccid-1+neq+1) = nelim
    if (nelim .gt. 0) refa(3)='ELIML'
!
!
 40 continue
    call jedema()
end subroutine
