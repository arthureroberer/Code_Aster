subroutine lrmhdf(nomamd, nomu, ifm, nrofic, nivinf,&
                  infmed, nbnoeu, nbmail, nbcoor)
!     ------------------------------------------------------------------
! person_in_charge: nicolas.sellenet at edf.fr
! ======================================================================
! COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
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
!     LECTURE DU MAILLAGE - FORMAT MED/HDF
!     -    -                       -   ---
!-----------------------------------------------------------------------
!     ENTREES :
!        NOMAMD : NOM MED DU MAILLAGE A LIRE
!                 SI ' ' : ON LIT LE PREMIER MAILLAGE DU FICHIER
!        NOMU   : NOM ASTER SOUS LEQUEL LE MAILLAGE SERA STOCKE
! ...
!     SORTIES:
!        NBNOEU : NOMBRE DE NOEUDS
! ...
!     ------------------------------------------------------------------
!
    implicit none
!
! 0.1. ==> ARGUMENTS
!
!     IN
!
#include "asterf_types.h"
#include "asterc/utflsh.h"
#include "asterfort/as_mficlo.h"
#include "asterfort/as_mficom.h"
#include "asterfort/as_mfinvr.h"
#include "asterfort/as_mfiope.h"
#include "asterfort/as_mlbnuv.h"
#include "asterfort/codent.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetc.h"
#include "asterfort/jemarq.h"
#include "asterfort/lrmdes.h"
#include "asterfort/lrmmdi.h"
#include "asterfort/lrmmeq.h"
#include "asterfort/lrmmfa.h"
#include "asterfort/lrmmma.h"
#include "asterfort/lrmmno.h"
#include "asterfort/lrmtyp.h"
#include "asterfort/mdexma.h"
#include "asterfort/mdexpm.h"
#include "asterfort/sdmail.h"
#include "asterfort/ulisog.h"
#include "asterfort/utmess.h"
    integer :: ifm, nivinf
    integer :: nrofic, infmed
    character(len=*) :: nomamd
    character(len=8) :: nomu
!
!     OUT
!
    integer :: nbnoeu, nbmail, nbcoor
!
! 0.2. ==> COMMUNS
!
! 0.3. ==> VARIABLES LOCALES
!
    character(len=6) :: nompro
    parameter ( nompro = 'LRMHDF' )
!
    integer :: ntymax
    parameter (ntymax = 69)
    integer :: nnomax
    parameter (nnomax=27)
    integer :: edlect
    parameter (edlect=0)
!
    integer :: iaux, ifimed
    integer :: nmatyp(ntymax)
    integer :: nnotyp(ntymax), typgeo(ntymax), nuanom(ntymax, nnomax)
    integer :: renumd(ntymax), modnum(ntymax), numnoa(ntymax, nnomax)
    integer :: nbtyp
    integer :: ndim, fid, codret
    integer :: nbnoma
    integer :: nbltit, nbgrno, nbgrma
    integer :: vlib(3), vfic(3), iret
    integer :: vali(3), hdfok, medok
!
    character(len=1) :: saux01
    character(len=6) :: saux06
    character(len=8) :: nomtyp(ntymax)
    character(len=8) :: saux08
    character(len=24) :: cooval, coodsc, cooref, grpnoe, grpmai, connex
    character(len=24) :: titre, nommai, nomnoe, typmai, adapma, gpptnn, gpptnm
    character(len=64) :: valk(2)
    character(len=200) :: nofimd
    character(len=255) :: kfic
    character(len=200) :: descfi
!
    aster_logical :: existm
!
!     ------------------------------------------------------------------
    call jemarq()
!
    call sdmail(nomu, nommai, nomnoe, cooval, coodsc,&
                cooref, grpnoe, gpptnn, grpmai, gpptnm,&
                connex, titre, typmai, adapma)
!
    descfi=' '
!
!====
! 1. PREALABLES
!====
!
    if (nivinf .gt. 1) then
        call utflsh(codret)
        write (ifm,1001) 'DEBUT DE '//nompro
    endif
    1001 format(/,10('='),a,10('='),/)
!
! 1.1. ==> NOM DU FICHIER MED
!
    call ulisog(nrofic, kfic, saux01)
    if (kfic(1:1) .eq. ' ') then
        call codent(nrofic, 'G', saux08)
        nofimd = 'fort.'//saux08
    else
        nofimd = kfic(1:200)
    endif
!
    if (nivinf .gt. 1) then
        write (ifm,*) '<',nompro,'> NOM DU FICHIER MED : ',nofimd
    endif
!
! 1.2. ==> VERIFICATION DU FICHIER MED
!
! 1.2.1. ==> VERIFICATION DE LA VERSION HDF
!
    call as_mficom(nofimd, hdfok, medok, codret)
    if (hdfok .eq. 0) then
        valk (1) = nofimd(1:32)
        valk (2) = nomamd
        vali (1) = codret
        call utmess('A', 'MODELISA9_44', nk=2, valk=valk, si=vali(1))
        call utmess('F', 'PREPOST3_10')
    endif
!
! 1.2.2. ==> VERIFICATION DE LA VERSION MED
!
    if (medok .eq. 0) then
        vali (1) = codret
        call utmess('A+', 'MED_24', si=vali(1))
        call as_mlbnuv(vlib(1), vlib(2), vlib(3), iret)
        if (iret .eq. 0) then
            vali (1) = vlib(1)
            vali (2) = vlib(2)
            vali (3) = vlib(3)
            call utmess('A+', 'MED_25', ni=3, vali=vali)
        endif
        call as_mfiope(fid, nofimd, edlect, codret)
        call as_mfinvr(fid, vfic(1), vfic(2), vfic(3), iret)
        if (iret .eq. 0) then
            if (vfic(2) .eq. -1 .or. vfic(3) .eq. -1) then
                call utmess('A+', 'MED_26')
            else
                vali (1) = vfic(1)
                vali (2) = vfic(2)
                vali (3) = vfic(3)
                call utmess('A+', 'MED_27', ni=3, vali=vali)
            endif
            if (vfic(1) .lt. vlib(1) .or. ( vfic(1).eq.vlib(1) .and. vfic(2).lt.vlib(2) )&
                .or.&
                (&
                vfic(1) .eq. vlib(1) .and. vfic( 2) .eq. vlib(2) .and. vfic(3) .eq. vlib(3)&
                )) then
                call utmess('A+', 'MED_28')
            endif
        endif
        call as_mficlo(fid, codret)
        call utmess('A', 'MED_41')
    endif
!
! 1.3. ==> VERIFICATION DE L'EXISTENCE DU MAILLAGE A LIRE
!
! 1.3.1. ==> C'EST LE PREMIER MAILLAGE DU FICHIER
!            ON RECUPERE SON NOM ET SA DIMENSION.
!
    if (nomamd .eq. ' ') then
!
        ifimed = 0
        call mdexpm(nofimd, ifimed, nomamd, existm, ndim,&
                    codret)
        if (.not.existm) then
            call utmess('F', 'MED_50', sk=nofimd)
        endif
!
! 1.3.2. ==> C'EST UN MAILLAGE DESIGNE PAR UN NOM
!            ON RECUPERE SA DIMENSION.
!
    else
!
        iaux = 1
        ifimed = 0
        call mdexma(nofimd, ifimed, nomamd, iaux, existm,&
                    ndim, codret)
        if (.not.existm) then
            valk(1) = nomamd
            valk(2) = nofimd(1:32)
            call utmess('F', 'MED_51', nk=2, valk=valk)
        endif
!
    endif
!
    nbcoor = ndim
    if (ndim .eq. 1) nbcoor = 2
!
!====
! 2. DEMARRAGE
!====
!
! 2.1. ==> OUVERTURE FICHIER MED EN LECTURE
!
    call as_mfiope(fid, nofimd, edlect, codret)
    if (codret .ne. 0) then
        valk (1) = nofimd(1:32)
        valk (2) = nomamd
        vali (1) = codret
        call utmess('A', 'MODELISA9_51', nk=2, valk=valk, si=vali(1))
        call utmess('F', 'PREPOST_69')
    endif
!
!
! 2.2. ==> . RECUPERATION DES NB/NOMS/NBNO/NBITEM DES TYPES DE MAILLES
!            DANS CATALOGUE
!          . RECUPERATION DES TYPES GEOMETRIE CORRESPONDANT POUR MED
!          . VERIF COHERENCE AVEC LE CATALOGUE
!
    call lrmtyp(nbtyp, nomtyp, nnotyp, typgeo, renumd,&
                modnum, nuanom, numnoa)
!
!====
! 3. DESCRIPTION
!====
!
    call lrmdes(fid, nbltit, descfi, titre)
!
!====
! 4. DIMENSIONNEMENT
!====
!
    call lrmmdi(fid, nomamd, typgeo, nomtyp, nnotyp,&
                nmatyp, nbnoeu, nbmail, nbnoma, descfi,&
                adapma)
!
!====
! 5. LES NOEUDS
!====
!
    call lrmmno(fid, nomamd, ndim, nbnoeu, nomu,&
                nomnoe, cooval, coodsc, cooref, ifm,&
                infmed)
!
!====
! 6. LES MAILLES
!====
!
    saux06 = nompro
!
    call lrmmma(fid, nomamd, nbmail, nbnoma, nbtyp,&
                typgeo, nomtyp, nnotyp, renumd, nmatyp,&
                nommai, connex, typmai, saux06, infmed,&
                modnum, numnoa)
!
!====
! 7. LES FAMILLES
!====
!
    saux06 = nompro
!
    call lrmmfa(fid, nomamd, nbnoeu, nbmail, grpnoe,&
                gpptnn, grpmai, gpptnm, nbgrno, nbgrma,&
                typgeo, nomtyp, nmatyp, saux06, infmed)
!
!====
! 8. LES EQUIVALENCES
!====
!
    call lrmmeq(fid, nomamd, infmed)
!
!====
! 9. FIN
!====
!
! 9.1. ==> FERMETURE FICHIER
!
    call as_mficlo(fid, codret)
    if (codret .ne. 0) then
        valk (1) = nofimd(1:32)
        valk (2) = nomamd
        vali (1) = codret
        call utmess('A', 'MODELISA9_52', nk=2, valk=valk, si=vali(1))
        call utmess('F', 'PREPOST_70')
    endif
!
! 9.2. ==> MENAGE
!
    call jedetc('V', '&&'//nompro, 1)
!
    call jedema()
!
    if (nivinf .gt. 1) then
        write (ifm,1001) 'FIN DE '//nompro
        call utflsh(codret)
    endif
!
end subroutine
