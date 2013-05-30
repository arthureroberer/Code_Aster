!
! COPYRIGHT (C) 1991 - 2013  EDF R&D                WWW.CODE-ASTER.ORG
!
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
! 1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
!
interface
    subroutine mditm2(np2, np3, np4, n2, nbm,&
                      nbmcd, nbmp, nbnl, indic, impr,&
                      itrans, epst, icoupl, tpfl, veci1,&
                      locfl0, dt0, tfexm, ts, dttr,&
                      vecdt, iarch, vitg0, depg0, masgi,&
                      amori, pulsi, phii, vecr5, vecr3,&
                      vecr1, vecr2, vgap, vecr4, xsi0,&
                      nbsauv, indx, indxf, intge1, intge2,&
                      iconfb, tconf1, tconf2, tconfe, typch,&
                      nbseg, oldia, itforn, amor, amor0,&
                      amor00, puls, puls0, puls00, trans,&
                      pulsd, fmod0, fmod00, fmodt, fmod0t,&
                      fexmod, fnlmod, fmoda, fmres, depg,&
                      depge, depgc, depgt, depg0t, vitg,&
                      vitge, vitgc, vitgt, vitg0t, accg,&
                      accg0, accgt, dep, vit, acc,&
                      dep0, vit0, acc0, kmod, cmod,&
                      kmod0, cmod0, kmod00, cmod00, kmodca,&
                      cmodca, cmodfa, amflu0, amfluc, vg,&
                      vd, ttr, vg0, vd0, vvg,&
                      rr, ri, rr0, mtmp1, mtmp2,&
                      mtmp6, ftmp, dd, u, w,&
                      omegaf, aa, bb, fext, fextts,&
                      text, textts, fexttr, fextt0, nomch,&
                      choc, orig, rc, theta, alpha,&
                      beta, gamma, old, locflc, loc,&
                      s0, z0, sr0, za1, za2,&
                      za3, za4, za5, zin, zitr,&
                      nbchoc, parcho, noecho)
        integer :: nbnl
        integer :: nbm
        integer :: n2
        integer :: np4
        integer :: np3
        integer :: np2
        integer :: nbmcd
        integer :: nbmp
        integer :: indic
        integer :: impr
        integer :: itrans
        real(kind=8) :: epst
        integer :: icoupl
        character(len=8) :: tpfl
        integer :: veci1(*)
        logical :: locfl0(*)
        real(kind=8) :: dt0
        real(kind=8) :: tfexm
        real(kind=8) :: ts
        real(kind=8) :: dttr
        real(kind=8) :: vecdt(*)
        integer :: iarch
        real(kind=8) :: vitg0(*)
        real(kind=8) :: depg0(*)
        real(kind=8) :: masgi(*)
        real(kind=8) :: amori(*)
        real(kind=8) :: pulsi(*)
        real(kind=8) :: phii(np2, nbm, *)
        real(kind=8) :: vecr5(*)
        real(kind=8) :: vecr3(*)
        real(kind=8) :: vecr1(*)
        real(kind=8) :: vecr2(*)
        real(kind=8) :: vgap
        real(kind=8) :: vecr4(*)
        real(kind=8) :: xsi0(*)
        integer :: nbsauv
        integer :: indx(*)
        integer :: indxf(*)
        integer :: intge1(*)
        integer :: intge2(*)
        integer :: iconfb(*)
        real(kind=8) :: tconf1(4, *)
        real(kind=8) :: tconf2(4, *)
        real(kind=8) :: tconfe(4, *)
        integer :: typch(*)
        integer :: nbseg(*)
        integer :: oldia(*)
        integer :: itforn(*)
        real(kind=8) :: amor(*)
        real(kind=8) :: amor0(*)
        real(kind=8) :: amor00(*)
        real(kind=8) :: puls(*)
        real(kind=8) :: puls0(*)
        real(kind=8) :: puls00(*)
        real(kind=8) :: trans(2, 2, *)
        real(kind=8) :: pulsd(*)
        real(kind=8) :: fmod0(*)
        real(kind=8) :: fmod00(*)
        real(kind=8) :: fmodt(*)
        real(kind=8) :: fmod0t(*)
        real(kind=8) :: fexmod(*)
        real(kind=8) :: fnlmod(*)
        real(kind=8) :: fmoda(*)
        real(kind=8) :: fmres(*)
        real(kind=8) :: depg(*)
        real(kind=8) :: depge(*)
        real(kind=8) :: depgc(*)
        real(kind=8) :: depgt(*)
        real(kind=8) :: depg0t(*)
        real(kind=8) :: vitg(*)
        real(kind=8) :: vitge(*)
        real(kind=8) :: vitgc(*)
        real(kind=8) :: vitgt(*)
        real(kind=8) :: vitg0t(*)
        real(kind=8) :: accg(*)
        real(kind=8) :: accg0(*)
        real(kind=8) :: accgt(*)
        real(kind=8) :: dep(3, *)
        real(kind=8) :: vit(3, *)
        real(kind=8) :: acc(3, *)
        real(kind=8) :: dep0(3, *)
        real(kind=8) :: vit0(3, *)
        real(kind=8) :: acc0(3, *)
        real(kind=8) :: kmod(nbm, *)
        real(kind=8) :: cmod(nbm, *)
        real(kind=8) :: kmod0(nbm, *)
        real(kind=8) :: cmod0(nbm, *)
        real(kind=8) :: kmod00(nbm, *)
        real(kind=8) :: cmod00(nbm, *)
        real(kind=8) :: kmodca(nbm, *)
        real(kind=8) :: cmodca(nbm, *)
        real(kind=8) :: cmodfa(nbm, *)
        real(kind=8) :: amflu0(nbm, *)
        real(kind=8) :: amfluc(nbm, *)
        real(kind=8) :: vg(nbm, *)
        real(kind=8) :: vd(nbm, *)
        real(kind=8) :: ttr(n2, *)
        real(kind=8) :: vg0(nbm, *)
        real(kind=8) :: vd0(nbm, *)
        real(kind=8) :: vvg(nbm, *)
        real(kind=8) :: rr(*)
        real(kind=8) :: ri(*)
        real(kind=8) :: rr0(*)
        real(kind=8) :: mtmp1(nbm, *)
        real(kind=8) :: mtmp2(nbm, *)
        real(kind=8) :: mtmp6(3, *)
        real(kind=8) :: ftmp(*)
        real(kind=8) :: dd(*)
        real(kind=8) :: u(*)
        real(kind=8) :: w(*)
        real(kind=8) :: omegaf(*)
        real(kind=8) :: aa(np4, *)
        real(kind=8) :: bb(np4, *)
        real(kind=8) :: fext(np4, *)
        real(kind=8) :: fextts(np4, *)
        real(kind=8) :: text(*)
        real(kind=8) :: textts(*)
        real(kind=8) :: fexttr(*)
        real(kind=8) :: fextt0(*)
        character(len=8) :: nomch(*)
        real(kind=8) :: choc(6, *)
        real(kind=8) :: orig(6, *)
        real(kind=8) :: rc(np3, *)
        real(kind=8) :: theta(np3, *)
        real(kind=8) :: alpha(2, *)
        real(kind=8) :: beta(2, *)
        real(kind=8) :: gamma(2, *)
        real(kind=8) :: old(9, *)
        logical :: locflc(*)
        logical :: loc(*)
        complex(kind=8) :: s0(*)
        complex(kind=8) :: z0(*)
        complex(kind=8) :: sr0(*)
        complex(kind=8) :: za1(*)
        complex(kind=8) :: za2(*)
        complex(kind=8) :: za3(*)
        complex(kind=8) :: za4(np4, *)
        complex(kind=8) :: za5(np4, *)
        complex(kind=8) :: zin(*)
        complex(kind=8) :: zitr(*)
        integer :: nbchoc
        real(kind=8) :: parcho(nbnl, *)
        character(len=8) :: noecho(nbnl, *)
    end subroutine mditm2
end interface
