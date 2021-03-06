subroutine pemima(indch, chamgd, resu, modele, nbocc)
    implicit none
#include "asterf_types.h"
#include "jeveux.h"
#include "asterfort/dismoi.h"
#include "asterfort/getvid.h"
#include "asterfort/getvis.h"
#include "asterfort/getvr8.h"
#include "asterfort/getvtx.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetr.h"
#include "asterfort/jelira.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexnom.h"
#include "asterfort/pemaxe.h"
#include "asterfort/pemaxn.h"
#include "asterfort/rsadpa.h"
#include "asterfort/rsexch.h"
#include "asterfort/rsorac.h"
#include "asterfort/rsutnu.h"
#include "asterfort/tbajpa.h"
#include "asterfort/tbcrsd.h"
#include "asterfort/wkvect.h"
#include "asterfort/as_deallocate.h"
#include "asterfort/as_allocate.h"
!
    integer :: nbocc, indch
    character(len=8) :: modele
    character(len=19) :: resu
    character(len=24) :: chamgd
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
!     OPERATEUR   POST_ELEM
!     TRAITEMENT DU MOT CLE-FACTEUR "MINMAX"
!     ------------------------------------------------------------------
!
    integer :: iret, nbcmp, nzero, nbordr, iocc, jnuma, nbma
    integer :: n1, nr, np, nc, ni, no, jno, jin, numo, tord(1)
    integer :: nbgma, jgma, nma, igm, nbpar, nn, inum, nli, nlo
    parameter(nzero=0,nbpar=3)
    real(kind=8) :: prec, inst
    complex(kind=8) :: cbid
    character(len=8) :: k8b, kbid, mailla, resuco, crit, tych
    character(len=8) :: nomgd, tout, grpma, typpar(nbpar)
    parameter(tout='TOUT',grpma='GROUP_MA')
    character(len=16) :: nompar(nbpar)
    character(len=19) :: knum, cham, kins, lisins
    character(len=24) :: nomcha
    aster_logical :: exiord
    character(len=8), pointer :: cmp(:) => null()
    data nompar/'CHAMP_GD','NUME_ORDRE','INST'/
    data typpar/'K16','I','R'/
!     ------------------------------------------------------------------
!
    call jemarq()
!
!     --- CREATION DE LA TABLE
    call tbcrsd(resu, 'G')
    call tbajpa(resu, nbpar, nompar, typpar)
!
!     --- RECUPERATION DU MAILLAGE ET DU NOMBRE DE MAILLES
    call dismoi('NOM_MAILLA', modele, 'MODELE', repk=mailla)
    call dismoi('NB_MA_MAILLA', mailla, 'MAILLAGE', repi=nbma)
!
    if (indch .eq. 0) then
!
!        --- RECUPERATION DU RESULTAT ET DU NUMERO D'ORDRE
        call getvid('MINMAX', 'RESULTAT', iocc=1, scal=resuco, nbret=nr)
        call getvr8('MINMAX', 'PRECISION', iocc=1, scal=prec, nbret=np)
        call getvtx('MINMAX', 'CRITERE', iocc=1, scal=crit, nbret=nc)
        call getvr8('MINMAX', 'INST', iocc=1, nbval=0, nbret=ni)
        call getvis('MINMAX', 'NUME_ORDRE', iocc=1, nbval=0, nbret=no)
        call getvid('MINMAX', 'LIST_INST', iocc=1, nbval=0, nbret=nli)
        call getvid('MINMAX', 'LIST_ORDRE', iocc=1, nbval=0, nbret=nlo)
!
        knum = '&&PEMIMA.NUME_ORDRE'
        kins = '&&PEMIMA.INST'
        exiord=.false.
        if (no .ne. 0) then
            exiord=.true.
            nbordr=-no
            call wkvect(knum, 'V V I', nbordr, jno)
            call getvis('MINMAX', 'NUME_ORDRE', iocc=1, nbval=nbordr, vect=zi(jno),&
                        nbret=iret)
        endif
!
        if (ni .ne. 0) then
            nbordr=-ni
            call wkvect(kins, 'V V R', nbordr, jin)
            call getvr8('MINMAX', 'INST', iocc=1, nbval=nbordr, vect=zr(jin),&
                        nbret=iret)
        endif
!
        if (nli .ne. 0) then
            call getvid('MINMAX', 'LIST_INST', iocc=1, scal=lisins, nbret=iret)
            call jeveuo(lisins // '.VALE', 'L', jin)
            call jelira(lisins // '.VALE', 'LONMAX', nbordr)
        endif
!
        if (nlo .ne. 0) then
            exiord=.true.
            call getvid('MINMAX', 'LIST_ORDRE', iocc=1, scal=lisins, nbret=iret)
            call jeveuo(lisins // '.VALE', 'L', jno)
            call jelira(lisins // '.VALE', 'LONMAX', nbordr)
        endif
!
        nn=nlo+nli+no+ni
        if (nn .eq. 0) then
            exiord=.true.
            call rsutnu(resuco, ' ', 0, knum, nbordr,&
                        prec, crit, iret)
            call jeveuo(knum, 'L', jno)
        endif
!
    else
!        CAS DU CHAMGD
        nbordr=1
        exiord=.true.
    endif
!
!
!     --- ON PARCOURT LES OCCURENCES DU MOT CLE 'MINMAX':
!     =====================================================
!
    do iocc = 1, nbocc
!
!
!     --- BOUCLE SUR LES NUMEROS D'ORDRE:
!     ===================================
!
        do inum = 1, nbordr
!
!
            if (indch .eq. 0) then
!             --- NUME_ORDRE, INST ---
                if (exiord) then
                    numo=zi(jno+inum-1)
                    call rsadpa(resuco, 'L', 1, 'INST', numo,&
                                0, sjv=jin, styp=kbid)
                    inst=zr(jin)
                else
                    inst=zr(jin+inum-1)
                    call rsorac(resuco, 'INST', 0, zr(jin+inum-1), kbid,&
                                cbid, prec, crit, tord, nbordr,&
                                iret)
                    numo=tord(1)
                endif
!
!             --- CHAMP DU POST-TRAITEMENT
                call getvtx('MINMAX', 'NOM_CHAM', iocc=iocc, scal=nomcha, nbret=iret)
                call rsexch(' ', resuco, nomcha, numo, cham,&
                            iret)
            else
                cham=chamgd
                nomcha=chamgd
                numo=0
                inst=0.d0
            endif
!
            call dismoi('TYPE_CHAMP', cham, 'CHAMP', repk=tych, arret='C',&
                        ier=iret)
!
            call dismoi('NOM_GD', cham, 'CHAMP', repk=nomgd, arret='C',&
                        ier=iret)
            if (nomgd(6:6) .eq. 'C') goto 10
!
!         --- COMPOSANTES DU POST-TRAITEMENT
            call getvtx('MINMAX', 'NOM_CMP', iocc=iocc, nbval=nzero, vect=k8b,&
                        nbret=nbcmp)
            nbcmp=-nbcmp
            AS_ALLOCATE(vk8=cmp, size=nbcmp)
            call getvtx('MINMAX', 'NOM_CMP', iocc=iocc, nbval=nbcmp, vect=cmp,&
                        nbret=iret)
!
!         --- CALCUL ET STOCKAGE DES MINMAX : MOT-CLE 'TOUT'
!
            call getvtx('MINMAX', 'TOUT', iocc=iocc, nbval=nzero, vect=k8b,&
                        nbret=iret)
            if (iret .ne. 0) then
                if (tych(1:2) .eq. 'EL') then
                    call pemaxe(resu, nomcha, tout, tout, modele,&
                                cham, nbcmp, cmp, numo, inst,&
                                iocc)
                else
                    call pemaxn(resu, nomcha, tout, tout, modele,&
                                cham, nbcmp, cmp, numo, inst)
                endif
            endif
!
!         --- CALCUL ET STOCKAGE DES MOYENNES : MOT-CLE 'GROUP_MA'
            call getvtx('MINMAX', 'GROUP_MA', iocc=iocc, nbval=nzero, vect=k8b,&
                        nbret=n1)
            if (n1 .ne. 0) then
                nbgma=-n1
                call wkvect('&&PEMIMA_GMA', 'V V K8', nbgma, jgma)
                call getvtx('MINMAX', 'GROUP_MA', iocc=iocc, nbval=nbgma, vect=zk8(jgma),&
                            nbret=n1)
                do igm = 1, nbgma
                    call jelira(jexnom(mailla//'.GROUPEMA', zk8(jgma+ igm-1)), 'LONMAX', nma,&
                                k8b)
                    call jeveuo(jexnom(mailla//'.GROUPEMA', zk8(jgma+ igm-1)), 'L', jnuma)
                    if (tych(1:2) .eq. 'EL') then
                        call pemaxe(resu, nomcha, grpma, zk8(jgma+igm-1), modele,&
                                    cham, nbcmp, cmp, numo, inst,&
                                    iocc)
                    else
                        call pemaxn(resu, nomcha, grpma, zk8(jgma+igm-1), modele,&
                                    cham, nbcmp, cmp, numo, inst)
                    endif
                end do
                call jedetr('&&PEMIMA_GMA')
            endif
!
            AS_DEALLOCATE(vk8=cmp)
!
        end do
!
 10     continue
    end do
!
    call jedema()
!
end subroutine
