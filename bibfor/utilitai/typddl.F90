subroutine typddl(choixz, numez, neq, tabddl, nbacti,&
                  nbbloq, nblagr, nbliai)
    implicit none
#include "jeveux.h"
#include "asterfort/gettco.h"
#include "asterfort/dismoi.h"
#include "asterfort/exisdg.h"
#include "asterfort/jedema.h"
#include "asterfort/jelira.h"
#include "asterfort/jemarq.h"
#include "asterfort/jenonu.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexnom.h"
#include "asterfort/jexnum.h"
#include "asterfort/mgutdm.h"
#include "asterfort/nbec.h"
#include "asterfort/utmess.h"
!
    integer :: neq, tabddl(*), nbacti, nbbloq, nblagr, nbliai
    character(len=4) :: choix
    character(len=14) :: nume
    character(len=*) :: choixz, numez
!----------------------------------------------------------------------
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
!----------------------------------------------------------------------
!
!     DETERMINATION DU TYPE DES DDL
!     SI CHOIX = 'ACTI' : TABDDL(I) = 1 ,  DDL I ACTIF
!                                   = 0 ,  DDL I BLOQUE OU LAGRANGE
!     SI CHOIX = 'BLOQ' : TABDDL(I) = 1 ,  DDL I BLOQUE
!                                   = 0 ,  DDL I ACTIF OU LAGRANGE
!     SI CHOIX = 'LAGR' : TABDDL(I) = 1 ,  DDL I LAGRANGE
!                                   = 0 ,  DDL I ACTIF OU BLOQUE
!     SI CHOIX = 'BLLA' : TABDDL(I) = 0 ,  DDL I ACTIF
!                                   = 1 ,  DDL I BLOQUE OU LAGRANGE
!     SI CHOIX = 'ACLA' : TABDDL(I) = 0 ,  DDL I BLOQUE
!                                   = 1 ,  DDL I ACTIF OU LAGRANGE
!     SI CHOIX = 'ACBL' : TABDDL(I) = 0 ,  DDL I LAGRANGE
!                                   = 1 ,  DDL I ACTIF OU BLOQUE
!
!----------------------------------------------------------------------
! IN  CHOIX  : K : CHOIX DE LA SORTIE DU TABLEAU TABDDL
! IN  NUME   : K : NOM DE LA NUMEROTATION
! IN  NEQ    : I : NOMBRE D' EQUATIONS
! OUT TABDDL : I : TABLEAU DES TYPES
! OUT NBACTI : I : NOMBRE DE DDL ACTIF
! OUT NBBLOQ : I : NOMBRE DE DDL BLOQUE
! OUT NBLAGR : I : NOMBRE DE DDL LAGRANGE
! OUT NBLIAI : I : NOMBRE DE DDL LAGRANGE UTILISES POUR DES LIAISONS
!----------------------------------------------------------------------
!
!
    integer :: aprno, adeeq, iddl, ideb, nd, n, nec, gd
    character(len=8) :: modgen, basemo
    character(len=16) :: typrep
    character(len=24) :: nprno, ndeeq, kbid, norig
!
!
!-----------------------------------------------------------------------
    integer :: i, ibid, icmp, ico, j, jorig, jprno
    integer :: jrefe, n1ddl, n2ddl, nbdefo, nbprno, nbsst
    integer :: nusst
!-----------------------------------------------------------------------
    call jemarq()
!
    nbliai = 0
    choix = choixz
    nume = numez
    nprno = nume//'.NUME.PRNO'
    norig = nume//'.NUME.ORIG'
    ndeeq = nume//'.NUME.DEEQ'
!
    call jenonu(jexnom(nprno(1:19)//'.LILI', '&MAILLA'), nbprno)
    call jeveuo(ndeeq, 'L', adeeq)
    call dismoi('NUM_GD_SI', nume, 'NUME_DDL', repi=gd)
    nec = nbec(gd)
!
    if (nbprno .ne. 0) then
!
!     --- CONSTRUCTION D'UN VECTEUR D'ENTIERS TEL QUE  ---
!     --- = 1 DDL PHYSIQUE LIBRE OU BLOQUE PAR LIAISON ---
!     --- = 0 LAGRANGE                                 ---
!     --- = -1 DDL PHYSIQUE BLOQUE                     ---
!
        call jenonu(jexnom(nprno(1:19)//'.LILI', '&MAILLA'), ibid)
        call jeveuo(jexnum(nprno, ibid), 'L', aprno)
        do i = 1, neq
            tabddl(i) = 1
        end do
        do i = 1, neq
            n = zi(adeeq + 2*i-1)
            if (n .eq. 0) then
                nbliai = nbliai + 1
                tabddl(i) = 0
            else if (n .lt. 0) then
                tabddl(i) = 0
                nd = zi(adeeq + 2*i-2)
                ideb = zi(aprno + (nec+2)*(nd-1) + 1-1)
                ico = 0
                do icmp = 1, -n - 1
                    if (exisdg(zi(aprno+(nec+2)*(nd-1)+ 3-1),icmp)) then
                        ico = ico + 1
                    endif
                end do
                iddl = ideb + ico
                tabddl(iddl) = -1
            endif
        end do
!
    else
!
! CAS DE LA NUMEROTATION GENERALISEE
!
        do i = 1, neq
            n=zi(adeeq+2*i-1)
            if (n .gt. 0) then
                tabddl(i)=i
            else
                tabddl(i)=0
            endif
        end do
!
        call jeveuo(nume//'.NUME.REFN', 'L', jrefe)
        call gettco(zk24(jrefe), typrep)
        if (typrep .eq. 'MODELE_GENE     ') then
            modgen = zk24(jrefe)(1:8)
            call jenonu(jexnom(norig(1:19)//'.LILI', '&SOUSSTR'), ibid)
            call jelira(jexnum(norig, ibid), 'LONMAX', nbsst)
! On compte que si il y a plus d'une sous-structure
            if (nbsst .gt. 2) then
                call jeveuo(jexnum(norig, ibid), 'L', jorig)
                call jeveuo(jexnum(nprno, ibid), 'L', jprno)
                do i = 1, nbsst
                    nusst = zi(jorig-1+i)
                    kbid = '        '
                    call mgutdm(modgen, kbid, nusst, 'NOM_BASE_MODALE', ibid,&
                                basemo)
                    call dismoi('NB_MODES_STA', basemo, 'RESULTAT', repi=nbdefo)
                    n1ddl = zi(jprno+2*(i-1))+zi(jprno+2*(i-1)+1)- nbdefo
                    n2ddl = zi(jprno+2*(i-1))+zi(jprno+2*(i-1)+1)-1
                    do j = n1ddl, n2ddl
                        tabddl(j)=-j
                    end do
                end do
            endif
        endif
!
    endif
!
!
    nbacti = 0
    nbbloq = 0
    nblagr = 0
    if (choix .eq. 'ACTI') then
        do i = 1, neq
            n = tabddl(i)
            if (n .gt. 0) then
                nbacti = nbacti + 1
                tabddl(i) = 1
            else if (n .eq. 0) then
                nblagr = nblagr + 1
                tabddl(i) = 0
            else
                nbbloq = nbbloq + 1
                tabddl(i) = 0
            endif
        end do
    else if (choix.eq.'BLOQ') then
        do i = 1, neq
            n = tabddl(i)
            if (n .gt. 0) then
                nbacti = nbacti + 1
                tabddl(i) = 0
            else if (n .eq. 0) then
                nblagr = nblagr + 1
                tabddl(i) = 0
            else
                nbbloq = nbbloq + 1
                tabddl(i) = 1
            endif
        end do
    else if (choix .eq. 'LAGR') then
        do i = 1, neq
            n = tabddl(i)
            if (n .gt. 0) then
                nbacti = nbacti + 1
                tabddl(i) = 0
            else if (n .eq. 0) then
                nblagr = nblagr + 1
                tabddl(i) = 1
            else
                nbbloq = nbbloq + 1
                tabddl(i) = 0
            endif
        end do
    else if (choix .eq. 'ACBL') then
        do i = 1, neq
            n = tabddl(i)
            if (n .gt. 0) then
                nbacti = nbacti + 1
                tabddl(i) = 1
            else if (n .eq. 0) then
                nblagr = nblagr + 1
                tabddl(i) = 0
            else
                nbbloq = nbbloq + 1
                tabddl(i) = 1
            endif
        end do
    else if (choix .eq. 'ACLA') then
        do i = 1, neq
            n = tabddl(i)
            if (n .gt. 0) then
                nbacti = nbacti + 1
                tabddl(i) = 1
            else if (n .eq. 0) then
                nblagr = nblagr + 1
                tabddl(i) = 1
            else
                nbbloq = nbbloq + 1
                tabddl(i) = 0
            endif
        end do
    else if (choix .eq. 'BLLA') then
        do i = 1, neq
            n = tabddl(i)
            if (n .gt. 0) then
                nbacti = nbacti + 1
                tabddl(i) = 0
            else if (n .eq. 0) then
                nblagr = nblagr + 1
                tabddl(i) = 1
            else
                nbbloq = nbbloq + 1
                tabddl(i) = 1
            endif
        end do
    else
        call utmess('F', 'UTILITAI5_3', sk=choix)
    endif
!
    call jedema()
!
end subroutine
