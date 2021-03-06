subroutine csheff_3d(dcash, dcsheff, dalpha, sic, csh,&
                     alsol, dalsol, csheff, xidtot, xidtot1,&
                     nasol, vnasol, dt, alpha, cash,&
                     alc, sc, id0, id1, id2)
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
! ======================================================================
! person_in_charge: etienne.grimal at edf.fr
!=====================================================================
!      provient de rsi_3d : 
!     calcul des vitesses de csheff
!=====================================================================
    implicit none
    real(kind=8) :: dcash
    real(kind=8) :: dcsheff
    real(kind=8) :: dalpha
    real(kind=8) :: sic
    real(kind=8) :: csheff
    real(kind=8) :: csh
    real(kind=8) :: alsol
    real(kind=8) :: dalsol
    real(kind=8) :: cash
    real(kind=8) :: dt
    real(kind=8) :: vnasol
    real(kind=8) :: nasol
    real(kind=8) :: alc
    real(kind=8) :: sc
    real(kind=8) :: alpha
    real(kind=8) :: id0
    real(kind=8) :: id1
    real(kind=8) :: id2
    real(kind=8) :: xidtot
    real(kind=8) :: xidtot1
    real(kind=8) :: frac0
    real(kind=8) :: bsup
    real(kind=8) :: binf
    real(kind=8) :: xid0
    real(kind=8) :: xidseuil
    real(kind=8) :: xidtotref
    real(kind=8) :: bmax
!     fraction de csh participant à la fixation csheff/csh      
!      frac=0.275d0
    xid0=id0
    xidtotref=id1
    xidseuil=id2
!
!      nasolref=0.5d0
!      nasol1=nasol+vnasol*dt
!      frac0=(1.d0-exp(-xidtot/xidtotref))*exp(-nasol/nasolref)
!     calcul bornes de frac par résolution du système d'adenot
    bsup=(alpha*alc-(2.d0/3.d0)*sc*alpha)/csh
    binf=(alpha*alc-2.d0*sc*alpha)/csh
    bmax=(alpha*alc)/csh    
    if ((xidtot.ge.xid0) .and. (xidtot.le.xidtotref)) then
        frac0=binf+((bsup-binf)/(xidtotref-xid0))*xidtot
    else if ((xidtot.gt.xidtotref).and.(xidtot.le.xidseuil)) then
        frac0=bsup+((bmax-bsup)/(xidseuil-xidtotref))*(xidtot-xidtotref)
    else if (xidtot.gt.xidseuil) then
        frac0=bmax
    else
        frac0=binf      
    end if 
!      frac0=binf+(bsup-binf)*(1.d0-exp(-xidtot/xidtotref)) 
!      frac0=0.13+0.18*(1.d0-exp(-xidtot/xidtotref))        
!      frac1=(1.d0-exp(-xidtot1/xidtotref))*exp(-nasol1/nasolref)  
!      dfrac=frac1-frac0      
!      dcsheff=(dalpha*sic)*frac0+csh*dfrac-dcash
    csheff=max((alpha*sic*frac0-cash),1.d-4)
!      print*,frac0
end subroutine
