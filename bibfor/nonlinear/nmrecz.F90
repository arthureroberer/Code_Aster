subroutine nmrecz(numedd, cndiri, cnfint, cnfext, ddepla,&
                  fonc)
!
! person_in_charge: mickael.abbas at edf.fr
!
!
! COPYRIGHT (C) 1991 - 2015  EDF R&D                WWW.CODE-ASTER.ORG
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
    implicit none
#include "jeveux.h"
#include "asterfort/dismoi.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
    real(kind=8) :: fonc
    character(len=24) :: numedd
    character(len=19) :: cndiri, cnfint, cnfext, ddepla
!
! ----------------------------------------------------------------------
!
! ROUTINE MECA_NON_LINE (RECHERCHE LINEAIRE)
!
! CALCUL DE LA FONCTION POUR LA RECHERCHE LINEAIRE
!
! ----------------------------------------------------------------------
!
!
! IN  NUMEDD : NOM DU NUME_DDL
! IN  CNDIRI : VECT_ASSE REACTIONS D'APPUI
! IN  CNFINT : VECT_ASSE FORCES INTERIEURES
! IN  CNFEXT : VECT_ASSE FORCES EXTERIEURES
! IN  DDEPLA : INCREMENT DE DEPLACEMENT
! OUT FONC   : VALEUR DE LA FONCTION
!
!
!
!
    integer :: ieq, neq
    real(kind=8), pointer :: ddepl(:) => null()
    real(kind=8), pointer :: diri(:) => null()
    real(kind=8), pointer :: fext(:) => null()
    real(kind=8), pointer :: fint(:) => null()
!
! ----------------------------------------------------------------------
!
    call jemarq()
!
! --- INITIALISATIONS
!
    call dismoi('NB_EQUA', numedd, 'NUME_DDL', repi=neq)
!
! --- ACCES OBJETS
!
    call jeveuo(cnfext(1:19)//'.VALE', 'L', vr=fext)
    call jeveuo(cnfint(1:19)//'.VALE', 'L', vr=fint)
    call jeveuo(cndiri(1:19)//'.VALE', 'L', vr=diri)
    call jeveuo(ddepla(1:19)//'.VALE', 'L', vr=ddepl)
!
    fonc = 0.d0
    do ieq = 1, neq
        fonc = fonc + ddepl(ieq) * (fint(ieq)+ diri(ieq)- fext(ieq))
    end do
!
    call jedema()
end subroutine
