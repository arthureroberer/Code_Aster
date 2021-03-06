subroutine mdall2(nomres, basemo, res, nbo, nbmode)
    implicit none
#include "jeveux.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/mdallo.h"
#include "asterfort/rsadpa.h"
    character(len=8) :: basemo, nomres, res, blanc8
    character(len=16) :: blan16
! ----------------------------------------------------------------------
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
!
!
!     ALLOCATION DES VECTEURS DE SORTIE POUR PROJ_RESU_BASE
!     ------------------------------------------------------------------
! IN  : NOMRES : NOM DU RESULTAT DELA COMMANDE (RESU_GENE)
! IN  : BASEMO : BASE MODALE SUR LAQUELLE ON PROJETTE RES
! IN  : RES    : RESULTAT PHYSIQUE A PROJETER
! IN  : NBO    : NOMBRE DE PAS DE TEMPS
! IN  : NBMODE : NOMBRE DE MODES
! ----------------------------------------------------------------------
!
!     ------------------------------------------------------------------
!-----------------------------------------------------------------------
    integer :: iinst, inord,  iptem, jacce, jvite, jdepl, jpass
    integer :: ibid, jinst, jordr, nbmode, nbo
    real(kind=8) :: dtbid
    character(len=8) :: k8b
    integer, pointer :: ordr(:) => null()
!-----------------------------------------------------------------------
    blanc8 = '        '
    blan16 = '                '
    ibid = 0
    dtbid = 0.d0
!
    call jemarq()
!
!----- INITIALISATION DE LA SD TYPE
!
    call mdallo(nomres, 'TRAN', nbo, sauve='GLOB', base=basemo,&
                nbmodes=nbmode, jordr=jordr, jdisc=jinst, jdepl=jdepl, jvite=jvite,&
                jacce=jacce, jptem=jpass, dt=dtbid)

!
!---- EN ABSENCE D'INFORMATION SUR LE PAS DE TEMPS, LE .PTEM EST
!---- EST FORCE A ZERO
    if (nbo .ne. 0) then
        do 66 iptem = 0, nbo-1
            zr(jpass+iptem) = dtbid
66      continue
    endif
! --- REMPLISSAGE DU .ORDR ET DU .DISC
!
    call jeveuo(res//'           .ORDR', 'E', vi=ordr)
    do 10 inord = 1, nbo
        zi(jordr-1+inord) = ordr(inord)
        call rsadpa(res, 'L', 1, 'INST', ordr(inord),&
                    0, sjv=iinst, styp=k8b)
        zr(jinst-1+inord) = zr(iinst)
10  continue
!
!
    call jedema()
end subroutine
