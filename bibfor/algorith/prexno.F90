subroutine prexno(champ, ioc, nomax, cmpmax, valmax,&
                  nomin, cmpmin, valmin, noamax, cmamax,&
                  vaamax, noamin, cmamin, vaamin)
    implicit none
#include "jeveux.h"
#include "asterc/indik8.h"
#include "asterc/r8vide.h"
#include "asterfort/cnocns.h"
#include "asterfort/detrsd.h"
#include "asterfort/getvtx.h"
#include "asterfort/jedetr.h"
#include "asterfort/jenuno.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexnum.h"
#include "asterfort/reliem.h"
#include "asterfort/utmess.h"
#include "asterfort/wkvect.h"
#include "asterfort/as_deallocate.h"
#include "asterfort/as_allocate.h"
!
    integer :: ioc
    real(kind=8) :: valmin, valmax, vaamin, vaamax
    character(len=8) :: nomax, nomin, cmpmax, cmpmin
    character(len=8) :: noamax, noamin, cmamax, cmamin
    character(len=*) :: champ
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
!
!     COMMANDE : POST_RELEVE_T
!                DETERMINE LES EXTREMA POUR UN CHAM_NO
!
! ----------------------------------------------------------------------
!
    integer ::    jcnsl,  nbno, ncmp, nbn
    integer :: ibid, nbnoeu, idnoeu, nbc, nbcmp
    integer :: i100, i110, icp, ino, inomax, inomin, inamax, inamin
    real(kind=8) :: x
    character(len=8) ::  nocmp, ma
    character(len=16) :: motcle(4), typmcl(4)
    character(len=19) :: chams1
    character(len=24) :: mesnoe
    character(len=8), pointer :: nom_cmp(:) => null()
    character(len=8), pointer :: cnsc(:) => null()
    integer, pointer :: cnsd(:) => null()
    real(kind=8), pointer :: cnsv(:) => null()
    character(len=8), pointer :: cnsk(:) => null()
! ---------------------------------------------------------------------
!
    motcle(1) = 'GROUP_NO'
    motcle(2) = 'NOEUD'
    motcle(3) = 'GROUP_MA'
    motcle(4) = 'MAILLE'
    typmcl(1) = 'GROUP_NO'
    typmcl(2) = 'NOEUD'
    typmcl(3) = 'GROUP_MA'
    typmcl(4) = 'MAILLE'
    mesnoe = '&&PREXNO.MES_NOEUDS'
!
    chams1 = '&&PREXNO.CHAMS1'
    call cnocns(champ, 'V', chams1)
!
    call jeveuo(chams1//'.CNSK', 'L', vk8=cnsk)
    call jeveuo(chams1//'.CNSD', 'L', vi=cnsd)
    call jeveuo(chams1//'.CNSC', 'L', vk8=cnsc)
    call jeveuo(chams1//'.CNSV', 'L', vr=cnsv)
    call jeveuo(chams1//'.CNSL', 'L', jcnsl)
    ma = cnsk(1)
    nbno = cnsd(1)
    ncmp = cnsd(2)
!
    call reliem(' ', ma, 'NU_NOEUD', 'ACTION', ioc,&
                4, motcle, typmcl, mesnoe, nbn)
    if (nbn .gt. 0) then
        nbnoeu = nbn
        call jeveuo(mesnoe, 'L', idnoeu)
    else
        nbnoeu = nbno
    endif
!
    call getvtx('ACTION', 'NOM_CMP', iocc=ioc, nbval=0, nbret=nbc)
    if (nbc .ne. 0) then
        nbcmp = -nbc
        AS_ALLOCATE(vk8=nom_cmp, size=nbcmp)
        call getvtx('ACTION', 'NOM_CMP', iocc=ioc, nbval=nbcmp, vect=nom_cmp,&
                    nbret=ibid)
    else
        nbcmp = ncmp
    endif
!
    inomax = 0
    valmax = -r8vide()
    inomin = 0
    valmin = r8vide()
!
    inamax = 0
    vaamax = -r8vide()
    inamin = 0
    vaamin = r8vide()
!
    do 100 i100 = 1, nbcmp
        if (nbc .ne. 0) then
            nocmp = nom_cmp(i100)
            icp = indik8( cnsc, nocmp, 1, ncmp )
            if (icp .eq. 0) goto 100
        else
            icp = i100
            nocmp = cnsc(i100)
        endif
!
        do 110 i110 = 1, nbnoeu
            if (nbn .gt. 0) then
                ino = zi(idnoeu+i110-1)
            else
                ino = i110
            endif
!
            if (zl(jcnsl-1+(ino-1)*ncmp+icp)) then
!
                x = cnsv((ino-1)*ncmp+icp)
!
                if (x .gt. valmax) then
                    inomax = ino
                    valmax = x
                    cmpmax = nocmp
                endif
!
                if (abs(x) .gt. vaamax) then
                    inamax = ino
                    vaamax = abs(x)
                    cmamax = nocmp
                endif
!
                if (x .lt. valmin) then
                    inomin = ino
                    valmin = x
                    cmpmin = nocmp
                endif
!
                if (abs(x) .lt. vaamin) then
                    inamin = ino
                    vaamin = abs(x)
                    cmamin = nocmp
                endif
!
            endif
!
110      continue
!
100  end do
!
    if (inomax .eq. 0) call utmess('F', 'POSTRELE_18')
    call jenuno(jexnum(ma//'.NOMNOE', inomax), nomax)
    call jenuno(jexnum(ma//'.NOMNOE', inomin), nomin)
    call jenuno(jexnum(ma//'.NOMNOE', inamax), noamax)
    call jenuno(jexnum(ma//'.NOMNOE', inamin), noamin)
!
! --- MENAGE
    call detrsd('CHAM_NO_S', chams1)
    call jedetr(mesnoe)
    AS_DEALLOCATE(vk8=nom_cmp)
!
end subroutine
