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
          interface 
            subroutine pebpct(ligrel,nbma,lma,cham,nomcmp,dim,bfix,borne&
     &,norme,seuil,lseuil,borpct,voltot,carele,cespoi)
              integer :: dim
              character(len=*) :: ligrel
              integer :: nbma
              character(len=24) :: lma
              character(len=19) :: cham
              character(len=8) :: nomcmp
              integer :: bfix
              real(kind=8) :: borne(2)
              character(len=8) :: norme
              real(kind=8) :: seuil
              aster_logical :: lseuil
              real(kind=8) :: borpct(dim)
              real(kind=8) :: voltot
              character(len=8) :: carele
              character(len=19) :: cespoi
            end subroutine pebpct
          end interface 
