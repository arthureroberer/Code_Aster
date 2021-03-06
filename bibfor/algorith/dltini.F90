subroutine dltini(lcrea, nume, result, depini, vitini,&
                  accini, fexini, famini, fliini, neq,&
                  numedd, inchac, baseno, ds_energy)
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
!     CALCUL MECANIQUE TRANSITOIRE PAR INTEGRATION DIRECTE
!     RECUPERATION DES CONDITIONS INITIALES
!     ------------------------------------------------------------------
! OUT : LCREA  : CREATION OU NON DU RESULTAT
! OUT : NUME   : NUMERO D'ORDRE DE REPRISE
! OUT : DEPINI : CHAMP DE DEPLACEMENT INITIAL OU DE REPRISE
! OUT : VITINI : CHAMP DE VITESSE INITIALE OU DE REPRISE
! OUT : ACCINI : CHAMP D'ACCELERATION INITIALE OU DE REPRISE
! IN  : NEQ    : NOMBRE D'EQUATIONS
! IN  : NUMEDD : NUMEROTATION DDL
! IN  : BASENO : BASE DES NOMS DE STRUCTURES
! VAR : INCHAC : CALCUL OU NON DE L'ACCELERATION INITIALE
!     ------------------------------------------------------------------
! CORPS DU PROGRAMME
!
use NonLin_Datastructure_type
!
implicit none
!
!
! DECLARATION PARAMETRES D'APPELS
#include "asterf_types.h"
#include "jeveux.h"
#include "asterc/getfac.h"
#include "asterfort/chpver.h"
#include "asterfort/getvid.h"
#include "asterfort/jedema.h"
#include "asterfort/jeexin.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/rsexch.h"
#include "asterfort/rsrusd.h"
#include "asterfort/utmess.h"
#include "asterfort/vtcopy.h"
#include "asterfort/vtcreb.h"
#include "blas/dcopy.h"
    real(kind=8) :: depini(*), vitini(*), accini(*)
    real(kind=8) :: fexini(*), famini(*), fliini(*)
    type(NL_DS_Energy), intent(in) :: ds_energy
    character(len=8) :: baseno, result
    character(len=24) :: numedd
    aster_logical :: lcrea, lener, linfo
    integer :: nume
    integer :: neq
    integer :: inchac
    integer :: ire, iret, jvale
    integer :: nai, ndi, ndy, nvi
    integer :: ierr
    character(len=8) :: reuse, dep, vit
    character(len=19) :: champ, cham2
!     ------------------------------------------------------------------
!
    call jemarq()
    lcrea = .true.
    linfo = .false.
!
!====
! 2.  --- EST-ON EN REPRISE ? ---
!====
!
    call getvid('ETAT_INIT', 'RESULTAT', iocc=1, scal=reuse, nbret=ndy)
    lener=ds_energy%l_comp
!
!====
! 3. EN REPRISE
!====
!
    if (ndy .ne. 0) then

        call utmess('I', 'DYNAMIQUE_78', sk=reuse)

        if (lener) then
            linfo = .true.
        endif
!
!        --- RECUPERATION DES CHAMPS DEPL VITE ET ACCE ---
        call rsexch(' ', reuse, 'DEPL', nume, champ,&
                    iret)
        if (iret .ne. 0) then
            call utmess('F', 'ALGORITH3_25', sk=reuse)
        else
            call jeveuo(champ//'.VALE', 'L', jvale)
            call dcopy(neq, zr(jvale), 1, depini, 1)
        endif
        call rsexch(' ', reuse, 'VITE', nume, champ,&
                    iret)
        if (iret .ne. 0) then
            call utmess('F', 'ALGORITH3_26', sk=reuse)
        else
            call jeveuo(champ//'.VALE', 'L', jvale)
            call dcopy(neq, zr(jvale), 1, vitini, 1)
        endif
        call rsexch(' ', reuse, 'ACCE', nume, champ,&
                    iret)
        if (iret .ne. 0) then
            call utmess('F', 'ALGORITH3_27', sk=reuse)
        else
            call jeveuo(champ//'.VALE', 'L', jvale)
            call dcopy(neq, zr(jvale), 1, accini, 1)
        endif
        call rsexch(' ', reuse, 'FORC_EXTE', nume, champ,&
                    iret)
        if (iret .eq. 0) then
            call jeveuo(champ//'.VALE', 'L', jvale)
            call dcopy(neq, zr(jvale), 1, fexini, 1)
        endif
        call rsexch(' ', reuse, 'FORC_AMOR', nume, champ,&
                    iret)
        if (iret .eq. 0) then
            call jeveuo(champ//'.VALE', 'L', jvale)
            call dcopy(neq, zr(jvale), 1, famini, 1)
        endif
        call rsexch(' ', reuse, 'FORC_LIAI', nume, champ,&
                    iret)
        if (iret .eq. 0) then
            call jeveuo(champ//'.VALE', 'L', jvale)
            call dcopy(neq, zr(jvale), 1, fliini, 1)
        endif
!
!        --- CREE-T-ON UNE NOUVELLE STRUCTURE ? ---
        if (result .eq. reuse) then
            lcrea = .false.
            call rsrusd(result, nume+1)
        endif
!====
! 4. --- RECUPERATION DES CONDITIONS INITIALES ---
!====
!
    else
        call jeexin(result(1:8)//'           .REFD', ire)
        if (ire .gt. 0) then
            lcrea = .false.
        endif
!
        nume = 0
        call getvid('ETAT_INIT', 'DEPL', iocc=1, scal=champ, nbret=ndi)
        if (ndi .gt. 0) then
            if (lener) then
                linfo = .true.
            endif
            call chpver('F', champ, 'NOEU', 'DEPL_R', ierr)
            inchac = 1
            cham2 = baseno//'.DEPINI'
            call vtcreb(cham2, 'V', 'R',&
                        nume_ddlz = numedd,&
                        nb_equa_outz = neq)
            call vtcopy(champ, cham2, ' ', iret)
            call jeveuo(cham2//'.VALE', 'L', jvale)
            call dcopy(neq, zr(jvale), 1, depini, 1)
            dep = champ(1:8)
        else
            dep = 'nul'
        end if
!
        call getvid('ETAT_INIT', 'VITE', iocc=1, scal=champ, nbret=nvi)
        if (nvi .gt. 0) then
            if (lener) then
                linfo = .true.
            endif
            call chpver('F', champ, 'NOEU', 'DEPL_R', ierr)
            inchac = 1
            cham2 = baseno//'.VITINI'
            call vtcreb(cham2, 'V', 'R',&
                        nume_ddlz = numedd,&
                        nb_equa_outz = neq)
            call vtcopy(champ, cham2, ' ', iret)
            call jeveuo(cham2//'.VALE', 'L', jvale)
            call dcopy(neq, zr(jvale), 1, vitini, 1)
            vit = champ(1:8)
        else
            vit = 'nul'
        end if
        call utmess('I', 'DYNAMIQUE_79', nk=2, valk=[dep,vit])

!
        call getvid('ETAT_INIT', 'ACCE', iocc=1, scal=champ, nbret=nai)
        if (nai .gt. 0) then
            if (lener) then
                linfo = .true.
            endif
            call chpver('F', champ, 'NOEU', 'DEPL_R', ierr)
            inchac = 0
            cham2 = baseno//'.ACCINI'
            call vtcreb(cham2, 'V', 'R',&
                        nume_ddlz = numedd,&
                        nb_equa_outz = neq)
            call vtcopy(champ, cham2, ' ', iret)
            call jeveuo(cham2//'.VALE', 'L', jvale)
            call dcopy(neq, zr(jvale), 1, accini, 1)
            call utmess('I', 'DYNAMIQUE_84', sk=champ)
        else
            call utmess('I', 'DYNAMIQUE_84', sk='calculee')
        end if
!
    endif
!
    if (linfo) then
        call utmess('I', 'ETATINIT_5')
    endif
!
    call jedema()
end subroutine
