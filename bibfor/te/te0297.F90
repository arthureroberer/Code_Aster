subroutine te0297(option, nomte)
    implicit none
#include "jeveux.h"
#include "asterc/r8prem.h"
#include "asterfort/cgverho.h"
#include "asterfort/elref1.h"
#include "asterfort/elrefe_info.h"
#include "asterfort/fointe.h"
#include "asterfort/iselli.h"
#include "asterfort/ltequa.h"
#include "asterfort/jevecd.h"
#include "asterfort/jevech.h"
#include "asterfort/rccoma.h"
#include "asterfort/rcvad2.h"
#include "asterfort/rcvalb.h"
#include "asterfort/teattr.h"
#include "asterfort/tecach.h"
#include "asterfort/utmess.h"
#include "asterfort/xcgfvo.h"
#include "asterfort/xsifel.h"
#include "asterfort/lteatt.h"
#include "asterfort/xsifle.h"
#include "asterfort/xteini.h"
!
    character(len=16) :: option, nomte
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
! person_in_charge: samuel.geniaut at edf.fr
!
!    - FONCTION REALISEE:  CALCUL DES OPTIONS DE POST-TRAITEMENT
!                          EN MÉCANIQUE DE LA RUPTURE
!                          POUR LES ÉLÉMENTS X-FEM
!
!    - ARGUMENTS:
!        DONNEES:      OPTION       -->  OPTION DE CALCUL
!                      NOMTE        -->  NOM DU TYPE ELEMENT
! ......................................................................
!
!
    integer :: ndim, nno, nnop, npg, ier
    integer :: nfh, nfe, ddlc, nse, ise, in, ino, ninter
    integer :: jpintt, jcnset, jheavt, jlonch, jbaslo, igeom, idepl
    integer :: ipres, ipref, itemps, jptint, jcface, jlongc, imate
    integer :: ithet, i, j, compt, igthet, ibid, jlsn, jlst, idecpg, icode
    integer :: nface, cface(30, 6), ifa, singu, jpmilt, ipuls, iret, jtab(7)
    integer :: irese, ddlm, jbasec, nptf, nfiss, jheavn, jstno
    integer :: contac
    real(kind=8) :: thet, valres(3), devres(3), presn(27), valpar(4)
    real(kind=8) :: pres, fno(81), coorse(81), puls
    integer :: icodre(3)
    character(len=8) :: elrefp, elrese(6), fami(6), nompar(4), enr
    character(len=16) :: nomres(3)
!
    data    elrese /'SE2','TR3','TE4','SE3','TR6','T10'/
    data    fami   /'BID','XINT','XINT','BID','XINT','XINT'/
    data    nomres /'E','NU','ALPHA'/
!
    
    call elref1(elrefp)
    call jevech('PTHETAR', 'L', ithet)
    call elrefe_info(fami='RIGI',ndim=ndim,nno=nnop)
!
!   SI LA VALEUR DE THETA EST NULLE SUR L'ÉLÉMENT, ON SORT
    compt = 0
    do 10 i = 1, nnop
        thet = 0.d0
        do 11 j = 1, ndim
            thet = thet + abs(zr(ithet+ndim*(i-1)+j-1))
11      continue
        if (thet .lt. r8prem()) compt = compt + 1
10  continue
    if (compt .eq. nnop) goto 999
!
!   SOUS-ELEMENT DE REFERENCE : RECUP DE NNO, NPG ET IVF
    if (.not.iselli(elrefp)) then
        irese=3
    else
        irese=0
    endif
    call elrefe_info(elrefe=elrese(ndim+irese),&
                     fami=fami(ndim+irese),&
                     nno=nno,&
                     npg=npg)
!
!   INITIALISATION DES DIMENSIONS DES DDLS X-FEM
    call xteini(nomte, nfh, nfe, singu, ddlc,&
                ibid, ibid, ibid, ddlm, nfiss,&
                contac)
!
!     ------------------------------------------------------------------
!              CALCUL DE G, K1, K2, K3 SUR L'ELEMENT MASSIF
!     ------------------------------------------------------------------
!
!     PARAMÈTRES PROPRES À X-FEM
    if(option.ne.'CALC_K_G_COHE') then
        call jevech('PPINTTO', 'L', jpintt)
        call jevech('PCNSETO', 'L', jcnset)
        call jevech('PHEAVTO', 'L', jheavt)
        call jevech('PLONCHA', 'L', jlonch)
    endif
    call jevech('PBASLOR', 'L', jbaslo)
    call jevech('PLST'   , 'L', jlst)
    call jevech('PGEOMER', 'L', igeom)
    call jevech('PDEPLAR', 'L', idepl)
    call jevech('PMATERC', 'L', imate)
    call jevech('PGTHETA', 'E', igthet)
    call teattr('S', 'XFEM', enr, ier)
    if (nfh.gt.0) call jevech('PHEA_NO', 'L', jheavn)
!   Propre aux elements 1d et 2d (quadratiques)
    if ((ier.eq.0) .and. ltequa(elrefp,enr))&
    call jevech('PPMILTO', 'L', jpmilt)
    if (nfe.gt.0) call jevech('PSTANO', 'L', jstno)
    if(option.eq.'CALC_K_G_COHE') goto 98
    call jevech('PLSN'   , 'L', jlsn)
!
!   VERIFS DE COHERENCE RHO <-> PESANTEUR, ROTATION, PULSATION
    if ( .not. cgverho(imate) ) call utmess('F', 'RUPTURE1_26')
!
!   CALCUL DES FORCES NODALES CORRESPONDANT AUX CHARGES VOLUMIQUES
    call xcgfvo(option, ndim, nnop, fno)
!
! --- RECUPERATION DE LA PULSATION
!
    call tecach('ONO', 'PPULPRO', 'L', iret, nval=7,&
                itab=jtab)
    ipuls=jtab(1)
    if (iret .eq. 0) then
        puls = zr(ipuls)
    else
        puls = 0.d0
    endif
!
!   Recuperation de la subdivision de l'element en nse sous element
    nse=zi(jlonch-1+1)
!
!   Boucle sur les nse sous-elements
    do 110 ise = 1, nse
!
!       Boucle sur les sommets du sous-tria (du sous-seg)
        do 111 in = 1, nno
            ino=zi(jcnset-1+nno*(ise-1)+in)
            do 112 j = 1, ndim
                if (ino .lt. 1000) then
                    coorse(ndim*(in-1)+j)=zr(igeom-1+ndim*(ino-1)+j)
                else if (ino.gt.1000 .and. ino.lt.2000) then
                    coorse(ndim*(in-1)+j)=zr(jpintt-1+ndim*(ino-1000-&
                    1)+j)
                else if (ino.gt.2000 .and. ino.lt.3000) then
                    coorse(ndim*(in-1)+j)=zr(jpmilt-1+ndim*(ino-2000-&
                    1)+j)
                else if (ino.gt.3000) then
                    coorse(ndim*(in-1)+j)=zr(jpmilt-1+ndim*(ino-3000-&
                    1)+j)
                endif
112          continue
111      continue
!
        idecpg = npg * (ise-1)
!
        call xsifel(elrefp, ndim, coorse, igeom, jheavt,&
                    ise, nfh, ddlc, ddlm, nfe,&
                    puls, zr(jbaslo), nnop,&
                    idepl, zr(jlsn), zr( jlst), idecpg, igthet,&
                    fno, nfiss, jheavn, jstno)
!
110  continue
!
!     ------------------------------------------------------------------
!              CALCUL DE G, K1, K2, K3 SUR LES LEVRES
!     ------------------------------------------------------------------
!
    if (option .eq. 'CALC_K_G') then
!       SI LA PRESSION N'EST CONNUE SUR AUCUN NOEUD, ON LA PREND=0.
        call jevecd('PPRESSR', ipres, 0.d0)
    else if (option.eq.'CALC_K_G_F') then
        call jevech('PPRESSF', 'L', ipref)
        call jevech('PTEMPSR', 'L', itemps)
!
!       RECUPERATION DES PRESSIONS AUX NOEUDS PARENTS
        nompar(1)='X'
        nompar(2)='Y'
        if (ndim .eq. 3) nompar(3)='Z'
        if (ndim .eq. 3) nompar(4)='INST'
        if (ndim .eq. 2) nompar(3)='INST'
        do 70 i = 1, nnop
            do 80 j = 1, ndim
                valpar(j) = zr(igeom+ndim*(i-1)+j-1)
80          continue
            valpar(ndim+1)= zr(itemps)
            call fointe('FM', zk8(ipref), ndim+1, nompar, valpar,&
                        presn(i), icode)
70      continue
    endif
!
!   SI LA VALEUR DE LA PRESSION EST NULLE SUR L'ÉLÉMENT, ON SORT
    compt = 0
    do 90 i = 1, nnop
        if (option .eq. 'CALC_K_G') pres = abs(zr(ipres-1+i))
        if (option .eq. 'CALC_K_G_F') pres = abs(presn(i))
        if (pres .lt. r8prem()) compt = compt + 1
90  continue
    if (compt .eq. nnop) goto 999
!
98  continue
!
!   PARAMETRES PROPRES A X-FEM
    call jevech('PPINTER', 'L', jptint)
    call jevech('PCFACE', 'L', jcface)
    call jevech('PLONGCO', 'L', jlongc)
    call jevech('PBASECO', 'L', jbasec)
!
!   RÉCUPÉRATIONS DES DONNÉES SUR LA TOPOLOGIE DES FACETTES
    ninter=zi(jlongc-1+1)
    nface=zi(jlongc-1+2)
    nptf=zi(jlongc-1+3)
    if (ninter .lt. ndim) goto 999
!
    do 40 i = 1, 30
        do 41 j = 1, 6
            cface(i,j)=0
41      continue
40  continue
!
    do 20 i = 1, nface
        do 21 j = 1, nptf
            cface(i,j)=zi(jcface-1+ndim*(i-1)+j)
21      continue
20  continue
!
!   RECUPERATION DES DONNEES MATERIAU AU 1ER POINT DE GAUSS !!
!   LE MATÉRIAU DOIT ETRE HOMOGENE DANS TOUT L'ELEMENT
    call rcvad2('XFEM', 1, 1, '+', zi(imate),&
                'ELAS', 3, nomres, valres, devres,&
                icodre)
    if ((icodre(1).ne.0) .or. (icodre(2).ne.0)) then
        call utmess('F', 'RUPTURE1_25')
    endif
    if (icodre(3) .ne. 0) then
        valres(3) = 0.d0
        devres(3) = 0.d0
    endif
!
!   BOUCLE SUR LES FACETTES
    do 200 ifa = 1, nface
        call xsifle(ndim, ifa, jptint, cface,&
                    igeom, nfh, jheavn, singu, nfe, ddlc,&
                    ddlm, jlsn, jlst, jstno, ipres, ipref, itemps,&
                    idepl, nnop, valres, zr( jbaslo), ithet,&
                    nompar, option, igthet, jbasec,&
                    contac)
200  continue
!
!
999  continue
end subroutine
