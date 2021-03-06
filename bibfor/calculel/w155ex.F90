subroutine w155ex(nomres, resu, nbordr, liordr)
! ----------------------------------------------------------------------
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
! person_in_charge: ayaovi-dzifa.kudawoo at edf.fr
! ======================================================================
!     COMMANDE :  POST_CHAMP /EXTR_XXXX
! ----------------------------------------------------------------------
    implicit none
#include "jeveux.h"
#include "asterc/getfac.h"
#include "asterfort/assert.h"
#include "asterfort/exlima.h"
#include "asterfort/getvis.h"
#include "asterfort/getvtx.h"
#include "asterfort/infmaj.h"
#include "asterfort/infniv.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/rsexch.h"
#include "asterfort/rslesd.h"
#include "asterfort/rsnoch.h"
#include "asterfort/utmess.h"
#include "asterfort/w155ch.h"
    character(len=8) :: nomres, resu
    integer :: nbordr, liordr(nbordr)
!
    integer :: ifm, niv, nucou, nufib, nangl
    integer :: iret, i, nuordr, ibid, n1, nbsym, isym
    character(len=8) :: modele, carele
    character(len=8) :: modeav
    character(len=3) :: nicou
    character(len=16) :: motfac, nomsym(10)
    character(len=19) :: chin, chextr, ligrel, resu19
    character(len=24) :: valk(4)
!     ------------------------------------------------------------------
!
    call jemarq()
!
!
    call infmaj()
    call infniv(ifm, niv)
    resu19=resu
!
!
!
!     -- 1. : QUEL MOTFAC ?
!     -------------------------
    call getfac('EXTR_COQUE', n1)
    if (n1 .eq. 1) then
        motfac='EXTR_COQUE'
    else
        call getfac('EXTR_TUYAU', n1)
        if (n1 .eq. 1) then
            motfac='EXTR_TUYAU'
        else
            call getfac('EXTR_PMF', n1)
            if (n1 .eq. 1) then
                motfac='EXTR_PMF'
            else
!           -- IL N'Y A RIEN A FAIRE :
                goto 30
!
            endif
        endif
    endif
!
!
!     -- 2.  : NOMSYM, NUCOU, NICOU, NANGL, NUFIB
!     --------------------------------------------------
    call getvtx(motfac, 'NOM_CHAM', iocc=1, nbval=10, vect=nomsym,&
                nbret=nbsym)
    ASSERT(nbsym.gt.0)
    if (motfac .eq. 'EXTR_COQUE' .or. motfac .eq. 'EXTR_TUYAU') then
        call getvis(motfac, 'NUME_COUCHE', iocc=1, scal=nucou, nbret=ibid)
        call getvtx(motfac, 'NIVE_COUCHE', iocc=1, scal=nicou, nbret=ibid)
        if (motfac .eq. 'EXTR_TUYAU') then
            call getvis(motfac, 'ANGLE', iocc=1, scal=nangl, nbret=ibid)
        endif
    else if (motfac.eq.'EXTR_PMF') then
        call getvis(motfac, 'NUME_FIBRE', iocc=1, scal=nufib, nbret=ibid)
    endif
!
!
!     -- 3. : BOUCLE SUR LES CHAMPS
!     --------------------------------------------------
    do isym=1,nbsym
        modeav=' '
        do i=1,nbordr
            nuordr=liordr(i)
            call rsexch(' ', resu19, nomsym(isym), nuordr, chin,iret)
            if (iret .eq. 0) then
                call rslesd(resu, nuordr, model_ = modele, cara_elem_ = carele)
                if (modele .ne. modeav) then
                    call exlima(' ', 1, 'G', modele, ligrel)
                    modeav=modele
                endif
                call rsexch(' ', nomres, nomsym(isym), nuordr, chextr,&
                            iret)
                ASSERT(iret.eq.100)
                call w155ch(chin, carele, ligrel, chextr, motfac,&
                            nucou, nicou, nangl, nufib)
                call rsnoch(nomres, nomsym(isym), nuordr)
            else
                valk(1)=nomsym(isym)
                valk(2)=resu
                call utmess('A', 'CALCULEL5_3', nk=2, valk=valk, si=nuordr)
            endif
        end do
    end do
!
!
30  continue
    call jedema()
end subroutine
