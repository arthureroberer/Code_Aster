subroutine nmop45(matrig, matgeo, defo, option, nfreq,&
                  cdsp, bande, mod45, ddlexc, nddle,&
                  modes, modes2, ddlsta, nsta)
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
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
    implicit none
#include "asterf_types.h"
#include "jeveux.h"
#include "asterc/isnnem.h"
#include "asterc/r8vide.h"
#include "asterfort/codent.h"
#include "asterfort/detrsd.h"
#include "asterfort/dismoi.h"
#include "asterfort/elmddl.h"
#include "asterfort/freqom.h"
#include "asterfort/infdbg.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetr.h"
#include "asterfort/jelira.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/mtdefs.h"
#include "asterfort/mtdscr.h"
#include "asterfort/omega2.h"
#include "asterfort/rectfr.h"
#include "asterfort/utmess.h"
#include "asterfort/vpbost.h"
#include "asterfort/vpcrea.h"
#include "asterfort/vpddl.h"
#include "asterfort/vpfopr.h"
#include "asterfort/vpordi.h"
#include "asterfort/vpordo.h"
#include "asterfort/vppara.h"
#include "asterfort/vpsor1.h"
#include "asterfort/vpsorn.h"
#include "asterfort/vpwecf.h"
#include "asterfort/vrrefe.h"
#include "asterfort/wkvect.h"
#include "asterfort/as_deallocate.h"
#include "asterfort/as_allocate.h"
    character(len=4) :: mod45
    character(len=19) :: matrig, matgeo
    integer :: defo, nfreq, cdsp
    character(len=16) :: option
    real(kind=8) :: bande(2)
    character(len=8) :: modes, modes2
    integer :: nddle, nsta
    character(len=24) :: ddlexc, ddlsta
!
! ======================================================================
!        MODE_ITER_SIMULT
!        RECHERCHE DE MODES PAR ITERATION SIMULTANEE EN SOUS-ESPACE
!-----------------------------------------------------------------------
!        - POUR LE PROBLEME GENERALISE AUX VALEURS PROPRES :
!                         2
!                        L (M) Y  + (K) Y = 0
!
!          LES MATRICES (K) ET (M) SONT REELLES SYMETRIQUES
!          LES VALEURS PROPRES ET DES VECTEURS PROPRES SONT REELS
!
!     ------------------------------------------------------------------
!     APPLICATION DE LA METHODE DE LANCZOS (VARIANTE DE NEUMANN-PIPANO)
!     POUR CONSTRUIRE UNE MATRICE TRIDIAGONALE D'ORDRE REDUIT DE MEME
!     VALEURS PROPRES QUE LE PROBLEME INITIAL (EVENTUELLEMENT DECALE)
!
!
!
!
!
    integer :: nbpari, nbparr, nbpark, mxddl, nbpara
    parameter (nbpari=8,nbparr=16,nbpark=3,nbpara=27)
    parameter (mxddl=1)
    integer :: indf, imet, i, ieq, iret, ier1, ibid, ierd, ifreq
    integer :: lamor, lmasse, lresur, lworkd, laux, lraide
    integer :: lworkl, lworkv, lprod, lddl, eddl, eddl2
    integer :: lmatra, lonwl, ityp, iordre, nbvec2, icoef, jexx, jest
    integer :: npivot, nbvect, priram(8), maxitr, neqact, mfreq, nparr, nbcine
    integer :: nbrss, mxresf, nblagr, nconv, npiv2(2)
    integer :: ifm, niv, nbddl, un
    character(len=1) :: ktyp
    real(kind=8) :: alpha, tolsor, undf, omemin, omemax, omeshi, omecor, precdc
    real(kind=8) :: vpinf, precsh, vpmax, csta, det(2)
    complex(kind=8) :: cbid
    character(len=8) :: knega, method, chaine
    character(len=16) :: typcon, typres, typco2, k16bid
    character(len=19) :: matopa, numedd, solveu
    integer :: ldsor, neq, idet(2)
    integer :: nbddl2, redem
    character(len=24) :: nopara(nbpara), metres
    aster_logical :: flage, lbid
    real(kind=8), pointer :: resid(:) => null()
    integer, pointer :: resu_i(:) => null()
    character(len=24), pointer :: resu_k(:) => null()
    aster_logical, pointer :: select(:) => null()
    real(kind=8), pointer :: vect_propre(:) => null()
    real(kind=8), pointer :: vect_stabil(:) => null()
    character(len=24), pointer :: slvk(:) => null()
!     ------------------------------------------------------------------
    data  nopara /&
     &  'NUME_MODE'       , 'ITER_QR'         , 'ITER_BATHE'      ,&
     &  'ITER_ARNO'       , 'ITER_JACOBI'     , 'ITER_SEPARE'     ,&
     &  'ITER_AJUSTE'     , 'ITER_INVERSE'    ,&
     &  'NORME'           , 'METHODE'         , 'TYPE_MODE'       ,&
     &  'FREQ'            ,&
     &  'OMEGA2'          , 'AMOR_REDUIT'     , 'ERREUR'          ,&
     &  'MASS_GENE'       , 'RIGI_GENE'       , 'AMOR_GENE'       ,&
     &  'MASS_EFFE_DX'    , 'MASS_EFFE_DY'    , 'MASS_EFFE_DZ'    ,&
     &  'FACT_PARTICI_DX' , 'FACT_PARTICI_DY' , 'FACT_PARTICI_DZ' ,&
     &  'MASS_EFFE_UN_DX' , 'MASS_EFFE_UN_DY' , 'MASS_EFFE_UN_DZ' /
!     ------------------------------------------------------------------
!
!
!
! ----------------------------------------------------------------------
!
    call jemarq()
    call infdbg('MECA_NON_LINE', ifm, niv)
!
! --- INITIALISATIONS
!
    cbid=(0.d0,0.d0)
    omecor = omega2(1.d-2)
    un=1
    precsh = 5.d-2
    precdc = 5.d-2
    flage = .false.
    undf = r8vide()
    indf = isnnem()
    method = 'SORENSEN'
    typres = 'MODE_FLAMB'
    if (mod45 .eq. 'VIBR') typres = 'DYNAMIQUE'
    nbrss = 5
    nconv = nfreq
    nbvect = cdsp*nfreq
    nbvec2 = 0
    lamor = 0
    omemin = bande(1)
    omemax = bande(2)
!
! --- RECUPERATION DU RESULTAT
!
    typcon = 'MODE_FLAMB'
    if (mod45 .eq. 'VIBR') typcon = 'MODE_MECA'
!
!
!
!     --- TEST DU TYPE (COMPLEXE OU REELLE) DE LA MATRICE DE RAIDEUR ---
    call jelira(matrig//'.VALM', 'TYPE', cval=ktyp)
!
!     --- RECUPERATION DE LA NUMEROTATION DE LA MATRICE DE RAIDEUR ---
    call dismoi('NOM_NUME_DDL', matrig, 'MATR_ASSE', repk=numedd)
!
!     --- COMPATIBILITE DES MODES (DONNEES ALTEREES) ---s
!
!------------------a remettre------------------------------
!
    call vpcrea(0, modes, matgeo, ' ', matrig,&
                numedd, ier1)
    call vpcrea(0, modes2, matgeo, ' ', matrig,&
                numedd, ier1)
!------------------------------------------------------------
!
!
!     --- VERIFICATION DES "REFE" ---
!      IF (OPTION.EQ.'BANDE') THEN
    call vrrefe(matgeo, matrig, iret)
!      ENDIF
!
!     --- DESCRIPTEUR DES MATRICES ---
    call mtdscr(matgeo)
    call jeveuo(matgeo(1:19)//'.&INT', 'E', lmasse)
!
    call mtdscr(matrig)
    call jeveuo(matrig(1:19)//'.&INT', 'E', lraide)
!     --- NOMBRE D'EQUATIONS ---
    neq = zi(lraide+2)
!
!     ------------------------------------------------------------------
!     ----------- DDL : LAGRANGE, BLOQUE PAR AFFE_CHAR_CINE  -----------
!     ------------------------------------------------------------------
!
    call wkvect('&&NMOP45.POSITION.DDL', 'V V I', neq*mxddl, lddl)
    call wkvect('&&NMOP45.DDL.BLOQ.CINE', 'V V I', neq, lprod)
!
    call vpddl(matrig, matgeo, neq, nblagr, nbcine,&
               neqact, zi(lddl), zi(lprod), ierd)
    if (ierd .ne. 0) goto 80
!
!     --- CREATION DE LA MATRICE DYNAMIQUE ET DE SA FACTORISEE ---
!
    matopa = '&&NMOP45.DYN_FAC_C '
!   pour gerer l'appel depuis modint :    
    call dismoi('SOLVEUR', matrig, 'MATR_ASSE', repk=solveu)
    if ((solveu(1:8) .ne. '&&NUME91') .and. (solveu(1:8) .ne. '&&DTM&&&')) then
        solveu='&&OP00XX.SOLVER'
    endif
! --- VERIF SOLVEUR LINEAIRE
    call jeveuo(solveu//'.SLVK', 'L', vk24=slvk)
    metres = slvk(1)
    if ((metres(1:4).ne.'LDLT') .and. (metres(1:10).ne.'MULT_FRONT') .and.&
        (metres(1:5).ne.'MUMPS')) then
        call utmess('F', 'ALGELINE5_71')
    endif
!
!     --- CREATION / AFFECTATION DES MATRICES DYNAMIQUES  ---
!
!
!     --- PROBLEME GENERALISE ---
!      - CAS REEL
!
    call mtdefs(matopa, matrig, 'V', 'R')
    call mtdscr(matopa)
    call jeveuo(matopa(1:19)//'.&INT', 'E', lmatra)
!        RECHERCHE DU NOMBRE DE CHAR_CRIT DANS LINTERVALEE OMEMIN,OMEMAX
    if (option .eq. 'BANDE') then
        call vpfopr(option, typres, lmasse, lraide, lmatra,&
                    omemin, omemax, omeshi, nfreq, npiv2,&
                    omecor, precsh, nbrss, nblagr, solveu,&
                    det, idet)
        npivot=npiv2(1)
        if (nfreq .le. 0) then
            call utmess('I', 'ALGELINE2_15')
            goto 80
        else
            call codent(nfreq, 'G', chaine)
            call utmess('I', 'ALGELINE2_16', sk=chaine)
        endif
    else
        omeshi = 0.d0
        call vpfopr(option, typres, lmasse, lraide, lmatra,&
                    omemin, omemax, omeshi, nfreq, npiv2,&
                    omecor, precsh, nbrss, nblagr, solveu,&
                    det, idet)
        npivot=npiv2(1)
    endif
!
!     ------------------------------------------------------------------
!     ----  DETERMINATION DE LA DIMENSION DU SOUS ESPACE NBVECT   ------
!     ------------------------------------------------------------------
!
    if (niv .ge. 2) then
        write (ifm,*) 'INFORMATIONS SUR LE CALCUL DEMANDE:'
        write (ifm,*) 'NOMBRE DE MODES DEMANDES     : ',nfreq
        write (ifm,*)
    endif
!
!     --- CORRECTION DU NOMBRE DE FREQUENCES DEMAMDEES EN FONCTION
!         DE NEQACT
!
    if (nfreq .gt. neqact) then
        nfreq = neqact
        if (niv .ge. 2) then
            write (ifm,*) 'INFORMATIONS SUR LE CALCUL DEMANDE:'
            write (ifm,*) 'TROP DE MODES DEMANDES POUR LE NOMBRE '//&
     &      'DE DDL ACTIFS, ON EN CALCULERA LE MAXIMUM '//'A SAVOIR: ',&
     &      nfreq
        endif
    endif
!
!     --- DETERMINATION DE NBVECT (DIMENSION DU SOUS ESPACE) ---
!
    if (niv .ge. 2) then
        write (ifm,*) 'LA DIMENSION DE L''ESPACE REDUIT EST : ',&
        nbvect
    endif
!
    if (nbvec2 .ne. 0) then
        icoef = nbvec2
    else
        icoef = 2
    endif
!
    if (nbvect .lt. nfreq) then
        nbvect = min(max(2+nfreq,icoef*nfreq),neqact)
        if (niv .ge. 2) then
            write (ifm,*) 'ELLE EST INFERIEURE AU NOMBRE '//&
     &      'DE MODES, ON LA PREND EGALE A ',nbvect
            write (ifm,*)
        endif
    else
        if (nbvect .gt. neqact) then
            nbvect = neqact
            if (niv .ge. 2) then
                write (ifm,*) 'ELLE EST SUPERIEURE AU'//&
     &        ' NOMBRE DE DDL ACTIFS, ON LA RAMENE A CE NOMBRE ',nbvect
                write (ifm,*)
            endif
        endif
    endif
!
!     --- TRAITEMENT SPECIFIQUE A SORENSEN ---
!
    if ((method.eq.'SORENSEN') .and. (nbvect-nfreq.lt.2)) then
!C  AUGMENTATION FORCEE DE NBVECT
!C (NECESSITE UNE ALARME OU INFO UTILISATEUR : A VOIR)
        nbvect = nfreq + 2
    endif
!
!     ------------------------------------------------------------------
!     --------------  ALLOCATION DES ZONES DE TRAVAIL   ----------------
!     ------------------------------------------------------------------
!
    mxresf = nfreq
    AS_ALLOCATE(vi=resu_i, size=nbpari*mxresf)
    call wkvect('&&NMOP45.RESU_R', 'V V R', nbparr*mxresf, lresur)
    AS_ALLOCATE(vk24=resu_k, size=nbpark*mxresf)
!
!     --- INITIALISATION A UNDEF DE LA STRUCTURE DE DONNEES RESUF --
!
    do ieq = 1, nbparr*mxresf
        zr(lresur+ieq-1) = undf
    end do
    do ieq = 1, nbpari*mxresf
        resu_i(ieq) = indf
    end do
!
!     --- CAS REEL ET GENERALISE ---
    AS_ALLOCATE(vr=vect_propre, size=neq*nbvect)
    AS_ALLOCATE(vr=vect_stabil, size=neq)
!
    lonwl = 3*nbvect*nbvect + 6*nbvect
    AS_ALLOCATE(vl=select, size=nbvect)
!     --- CAS REEL GENERALISE ---
!
    AS_ALLOCATE(vr=resid, size=neq)
    call wkvect('&&NMOP45.VECT.WORKD', 'V V R', 3*neq, lworkd)
    call wkvect('&&NMOP45.VECT.WORKL', 'V V R', lonwl, lworkl)
    call wkvect('&&NMOP45.VECT.WORKV', 'V V R', 3*nbvect, lworkv)
    call wkvect('&&NMOP45.VAL.PRO', 'V V R', 2* (nfreq+1), ldsor)
    call wkvect('&&NMOP45.VECT.AUX', 'V V R', neq, laux)
!
!
!     ------------------------------------------------------------------
!     -------  CALCUL DES VALEURS PROPRES ET VECTEURS PROPRES   --------
!     ------------------------------------------------------------------
!
    alpha = 0.717d0
    maxitr = 200
    tolsor = 0.d0
!
    if (niv .eq. 2) then
        priram(1) = 2
        priram(2) = 2
        priram(3) = 2
        priram(4) = 2
        priram(5) = 0
        priram(6) = 0
        priram(7) = 0
        priram(8) = 2
    else
        do i = 1, 8
            priram(i) = 0
        end do
    endif
!     --- SORENSEN : CAS REEL GENERALISE ---
!     CALCUL DES MODES PROPRES
!
    if (mod45 .eq. 'FLAM') then
!
        if (defo .eq. 0) then
!
            call vpsorn(lmasse, lmatra, neq, nbvect, nfreq,&
                        tolsor, vect_propre, resid, zr(lworkd), zr(lworkl),&
                        lonwl, select, zr(ldsor), omeshi, zr(laux),&
                        zr(lworkv), zi(lprod), zi(lddl), neqact, maxitr,&
                        ifm, niv, priram, alpha, omecor,&
                        nconv, flage, solveu)
!
        else
            call wkvect('&&NMOP45.POSI.EDDL', 'V V I', neq*mxddl, eddl)
            if (nddle .ne. 0) then
                call jeveuo(ddlexc, 'L', jexx)
                call elmddl(matrig, 'DDL_EXCLUS    ', neq, zk8(jexx), nddle,&
                            nbddl, zi(eddl))
            else
                nbddl = 0
            endif
!
            call wkvect('&&NMOP45.POSI.SDDL', 'V V I', neq*mxddl, eddl2)
!
            if (nsta .ne. 0) then
                call jeveuo(ddlsta, 'L', jest)
                call elmddl(matrig, 'DDL_STAB      ', neq, zk8(jest), nsta,&
                            nbddl2, zi(eddl2))
            else
                nbddl2 = 0
            endif
!
            redem = 0
!
            call vpsor1(lmatra, neq, nbvect, nfreq, tolsor,&
                        vect_propre, resid, zr(lworkd), zr(lworkl), lonwl,&
                        select, zr(ldsor), omeshi, zr(laux), zr(lworkv),&
                        zi(lprod), zi(lddl), zi(eddl), nbddl, neqact,&
                        maxitr, ifm, niv, priram, alpha,&
                        omecor, nconv, flage, solveu, nbddl2,&
                        zi(eddl2), vect_stabil, csta, redem)
!
        endif
    else
        call vpsorn(lmasse, lmatra, neq, nbvect, nfreq,&
                    tolsor, vect_propre, resid, zr(lworkd), zr(lworkl),&
                    lonwl, select, zr(ldsor), omeshi, zr(laux),&
                    zr(lworkv), zi(lprod), zi(lddl), neqact, maxitr,&
                    ifm, niv, priram, alpha, omecor,&
                    nconv, flage, solveu)
!
    endif
!
!     --- DESTRUCTION DE LA MATRICE DYNAMIQUE (ET DE SON ENVENTUELLE
!         OCCURENCE MUMPS)
    call detrsd('MATR_ASSE', matopa)
    call jedetr(matopa(1:19)//'.&INT')
    call jedetr(matopa(1:19)//'.&IN2')
!
!     TRI DE CES MODES
    call rectfr(nconv, nconv, omeshi, npivot, nblagr,&
                zr(ldsor), nfreq+1, resu_i, zr(lresur), nfreq)
    call vpbost(typres, nconv, nconv, omeshi, zr(ldsor),&
                nfreq+1, vpinf, vpmax, precdc, method,&
                omecor)
    if (mod45 .eq. 'VIBR') then
        call vpordi(1, 0, nconv, zr(lresur+mxresf), vect_propre,&
                    neq, resu_i)
    endif
    do imet = 1, nconv
        resu_i(mxresf+imet) = 0
        zr(lresur-1+imet) = freqom(zr(lresur-1+mxresf+imet))
        zr(lresur-1+2*mxresf+imet) = 0.0d0
        resu_k(mxresf+imet) = 'SORENSEN'
    end do
!
!
    if (mod45 .ne. 'VIBR') then
        ityp = 0
        iordre = 0
        call vpordo(ityp, iordre, nconv, zr(lresur+mxresf), vect_propre,&
                    neq)
        do imet = 1, nconv
            zr(lresur-1+imet) = freqom(zr(lresur-1+mxresf+imet))
            resu_i(imet) = imet
        end do
    endif
!
!     ------------------------------------------------------------------
!     -------------------- CORRECTION : OPTION BANDE -------------------
!     ------------------------------------------------------------------
!
!     --- SI OPTION BANDE ON NE GARDE QUE LES FREQUENCES DANS LA BANDE
!
    mfreq = nconv
    if (option .eq. 'BANDE') then
        do ifreq = mfreq - 1, 0, -1
            if (zr(lresur+mxresf+ifreq) .gt. omemax .or. zr(lresur+ mxresf+ifreq) .lt.&
                omemin) then
                nconv = nconv - 1
            endif
        end do
        if (mfreq .ne. nconv) then
            call utmess('I', 'ALGELINE2_17')
        endif
    endif
!
    knega = 'NON'
    nparr = nbparr
!
    call vppara(modes, typcon, knega, lraide, lmasse,&
                lamor, mxresf, neq, nconv, omecor,&
                zi(lddl), zi(lprod), vect_propre, [cbid], nbpari,&
                nparr, nbpark, nopara, mod45, resu_i,&
                zr(lresur), resu_k, ktyp, .false._1, ibid,&
                ibid, k16bid, ibid)
!
    if (niv .ge. 2) then
        lbid = .false.
        call vpwecf(' ', typres, nconv, mxresf, resu_i,&
                    zr(lresur), resu_k, lamor, ktyp, lbid)
    endif
!
    if (nsta .ne. 0) then
!
        typco2 = 'MODE_STAB'
!
        call vppara(modes2, typco2, knega, lraide, lmasse,&
                    lamor, un, neq, un, omecor,&
                    zi(lddl), zi(lprod), vect_stabil, [cbid], nbpari,&
                    nparr, nbpark, nopara, 'STAB', resu_i,&
                    [csta], resu_k, ktyp, .false._1, ibid,&
                    ibid, k16bid, ibid)
!
    endif
!
 80 continue
!
!
! --- MENAGE
!
    call jedetr('&&NMOP45.POSITION.DDL')
    call jedetr('&&NMOP45.DDL.BLOQ.CINE')
    AS_DEALLOCATE(vi=resu_i)
    call jedetr('&&NMOP45.RESU_R')
    AS_DEALLOCATE(vk24=resu_k)
    AS_DEALLOCATE(vr=vect_propre)
    AS_DEALLOCATE(vr=vect_stabil)
    AS_DEALLOCATE(vl=select)
    AS_DEALLOCATE(vr=resid)
    call jedetr('&&NMOP45.VECT.WORKD')
    call jedetr('&&NMOP45.VECT.WORKL')
    call jedetr('&&NMOP45.VECT.WORKV')
    call jedetr('&&NMOP45.VAL.PRO')
    call jedetr('&&NMOP45.VECT.AUX')
    call jedetr('&&NMOP45.POSI.EDDL')
    call jedetr('&&NMOP45.POSI.SDDL')
    call detrsd('MATR_ASSE', matopa)
    call jedetr(matopa(1:19)//'.&INT')
    call jedetr(matopa(1:19)//'.&IN2')
!
    call jedema()
!
!     ------------------------------------------------------------------
!
!     FIN DE NMOP45
!
end subroutine
