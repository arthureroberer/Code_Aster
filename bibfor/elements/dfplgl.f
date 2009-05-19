      SUBROUTINE DFPLGL (NMNBN,NMPLAS,NMDPLA,BEND,DFPL)

      IMPLICIT NONE
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 19/05/2009   AUTEUR SFAYOLLE S.FAYOLLE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR   
C (AT YOUR OPTION) ANY LATER VERSION.                                 
C
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT 
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF          
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU    
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.                            
C
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE   
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,       
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C======================================================================
C
C     CALCUL LE GRADIENT DU CRITERE DE PLASICITE
C
C IN  NMNBN : FORCE - BACKFORCE
C IN  NMPLAS : MOMENTS LIMITES DE PLASTICITE
C IN  NMDPLA : DERIVEES DES MOMENTS LIMITES DE PLASTICITE
C IN  BEND : FLEXION POSITIVE (1) OU NEGATIVE (2)
C
C OUT DFPL : GRADIENT DU CRITERE DE PLASICITE


      INTEGER BEND

      REAL*8 DFPL(*), NMNBN(6), NMPLAS(2,3), NMDPLA(2,2)

      DFPL(4) = -(NMNBN(5)-NMPLAS(BEND,2))
      DFPL(5) = -(NMNBN(4)-NMPLAS(BEND,1))
      DFPL(6) = 2.D0*NMNBN(6)
      DFPL(1) = -NMDPLA(BEND,1)*DFPL(4)
      DFPL(2) = -NMDPLA(BEND,2)*DFPL(5)
      DFPL(3) = 0.D0*NMNBN(6)

      END
