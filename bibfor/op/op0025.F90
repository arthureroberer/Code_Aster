subroutine op0025()
!
use NonLin_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "asterc/etausr.h"
#include "asterfort/assert.h"
#include "asterfort/detmat.h"
#include "asterfort/didern.h"
#include "asterfort/diinst.h"
#include "asterfort/exixfe.h"
#include "asterfort/infmaj.h"
#include "asterfort/infniv.h"
#include "asterfort/medith.h"
#include "asterfort/ntarch.h"
#include "asterfort/ntinit.h"
#include "asterfort/ntreso.h"
#include "asterfort/ntini0.h"
#include "asterfort/ntdata.h"
#include "asterfort/sigusr.h"
#include "asterfort/titre.h"
#include "asterfort/utmess.h"
#include "asterfort/uttcpr.h"
#include "asterfort/uttcpu.h"
#include "asterfort/vtcreb.h"
#include "asterfort/xthpos.h"
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
!


!
! --------------------------------------------------------------------------------------------------
!
! THER_LINEAIRE
!
! --------------------------------------------------------------------------------------------------
!
    integer :: vali
    integer :: ifm, niv, iret
    integer :: nume_inst
    real(kind=8) :: para(2), valr(2)
    real(kind=8) :: tpsthe(6), tps1(4), deltat, deltam
    real(kind=8) :: theta, instap, theta_read
    aster_logical :: matcst, coecst, lostat, levol, asme, asms, finpas
    aster_logical :: reasrg, reasms, force
    character(len=8) :: result,  mesh
    character(len=19) :: maprec, solver, sddisc, list_load
    character(len=24) :: model, cara_elem
    character(len=24) :: nume_dof
    character(len=24) :: mediri, matass
    character(len=24) :: cndiri, cncine, time
    character(len=24) :: mate
    character(len=24) :: vec2nd
    character(len=24) :: compor
!
    type(NL_DS_AlgoPara) :: ds_algopara
    type(NL_DS_InOut)    :: ds_inout
!
! --------------------------------------------------------------------------------------------------
!
    call infmaj()
    call infniv(ifm, niv)
!
! - Initializations
!
    tpsthe(1:6) = 0.d0
    asme        = .true.
    asms        = .false.
    solver      = '&&OP0025.SOLVEUR'
    list_load   = '&&OP0025.LIST_LOAD'
    maprec      = '&&OP0025.MAT_PRECON'
    vec2nd      = '&&OP0025.2ND_MEMBRE'
    matass      = '&&OP0025.MATR_ASSEM'
    result      = ' '
    mediri      = ' '
    cndiri      = ' '
    cncine      = ' '
    compor      = ' '
    sddisc      = '&&OP0025.SDDISC'
!
! - Creation of datastructures
!
    call ntini0(ds_algopara, ds_inout)
!
! - Read parameters (linear)
!
    call ntdata(list_load, solver, matcst   , coecst  , result   ,&
                model    , mate  , cara_elem, ds_inout, theta_read)
    para(1) = theta_read
    para(2) = 0.d0
!
! - Initial state and some parameters
!
    call ntinit(model , mate    , cara_elem, list_load,&
                para  , nume_dof, lostat   , levol    ,&
                sddisc, ds_inout, mesh     , time)
!
! - Elementary matrix for Dirichlet BC
!
    call medith(model, list_load, mediri)
!
! 2.6. ==> PILOTAGE DES REACTUALISATIONS DES ASSEMBLAGES
!     REASRG : MATRICE DE RIGIDITE
!     REASMS : MATRICE DE MASSE
!
    reasrg = .false.
    reasms = .false.
!
!
    if (lostat) then
        asms = .true.
        nume_inst=0
    else
        nume_inst=1
    endif
!
    deltat=-1.d150
!
! - Create empty second member
!
    call vtcreb(vec2nd, 'V', 'R', nume_ddlz = nume_dof)
!
!====
! 3. BOUCLES SUR LES PAS DE TEMPS
!====
!
    call uttcpu('CPU.OP0025', 'INIT', ' ')
!
200 continue
!
! --- RECUPERATION DU PAS DE TEMPS ET DES PARAMETRES DE RESOLUTION
!
! --- CETTE BOUCLE IF SERT A MAINTENIR LE NUMERO D ORDRE
! --- A 1 DANS LE CAS D UN CALCUL STATIONNAIRE.
! --- IL FAUT EN EFFET PROCEDER A CE CALCUL AVANT DE PARCOURIR
! --- LA LISTE D INSTANT DE LA SD SDDISC
!
    if (lostat) then
        if (.not.levol) then
            instap=0.d0
            deltam=deltat
            deltat=-1.d150
            theta=1.d0
        else
            instap=diinst(sddisc, nume_inst)
            deltam=deltat
            deltat=-1.d150
            theta=1.d0
        endif
    else
        instap = diinst(sddisc, nume_inst)
        deltam=deltat
        deltat = instap-diinst(sddisc, nume_inst-1)
        theta=theta_read
    endif
    para(2) = deltat
! --- MATRICE TANGENTE REACTUALISEE POUR UN NOUVEAU DT
!
    call uttcpu('CPU.OP0025', 'DEBUT', ' ')
    tpsthe(1) = instap
    tpsthe(2) = deltat
    tpsthe(3) = theta
!
    if ((.not.matcst.or..not.coecst) .or. asms .or. asme) then
        reasrg = .true.
        asms = .false.
    endif
    if ((.not.matcst) .or. deltam .ne. deltat) then
        reasms = .true.
        asme = .false.
    endif
!
! - Solve system
!
    call ntreso(model , mate  , cara_elem, list_load, nume_dof,&
                solver, lostat, time     , tpsthe   , reasrg  ,&
                reasms, vec2nd, matass   , maprec   , cndiri  ,&
                cncine, mediri, compor)
!
    reasrg = .false.
    reasms = .false.
!
!
! - Save results
!
    if (lostat) then
        force = .true.
    else
        force = .false.
    endif
    call ntarch(nume_inst, model    , mate , cara_elem, para,&
                sddisc   , ds_inout , force)
!
! ------- VERIFICATION SI INTERRUPTION DEMANDEE PAR SIGNAL USR1
!
    if (etausr() .eq. 1) then
        call sigusr()
    endif
!
! 3.2.3. ==> GESTION DU TEMPS CPU
!
    finpas = didern(sddisc, nume_inst)
!
    call uttcpu('CPU.OP0025', 'FIN', ' ')
    call uttcpr('CPU.OP0025', 4, tps1)
    if (tps1(4) .gt. .95d0*tps1(1)-tps1(4)) then
        vali = nume_inst
        valr(1) = tps1(4)
        valr(2) = tps1(1)
        call utmess('Z', 'ALGORITH16_68', si=vali, nr=2, valr=valr,&
                    num_except=28)
    else
        write (ifm,'(A,1X,I6,2(1X,A,1X,1PE11.3))') 'NUMERO D''ORDRE:',&
        nume_inst,'INSTANT:',instap, 'DUREE MOYENNE:',tps1(4)
    endif
    if (lostat) then
        lostat=.false.
    endif
    nume_inst = nume_inst + 1
!
    if (finpas) goto 41
!
    goto 200
!
!
 41 continue
!
!
    call titre()
!
! --- DESTRUCTION DE TOUTES LES MATRICES CREEES
!
    call detmat()
!
! --- POST TRAITEMENT SPECIFIQUE X-FEM : CALCUL / STOCKAGE DE TEMP_ELGA
!
    call exixfe(model, iret)
    if (iret .ne. 0) then
        call xthpos(result, model)
    endif
!
end subroutine
