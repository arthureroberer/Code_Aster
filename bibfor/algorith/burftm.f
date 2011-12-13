      SUBROUTINE BURFTM(CMP,VIM,EPSFM)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/12/2011   AUTEUR FOUCAULT A.FOUCAULT 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================
C RESPONSABLE FOUCAULT A.FOUCAULT 
C ----------------------------------------------------------------------
C ROUTINE DE COMPORTEMENT DE FLUAGE BETON_BURGER_FP
C PASSAGE DES VARIABLES INTERNES AU VECTEUR DE DEFORMATIONS DE FLUAGE
C
C IN  CMP : COMPOSANTES A CALCULER : 
C             'FT' : FLUAGE PROPRE + DESSICCATION
C             'FP' : FLUAGE PROPRE UNIQUEMENT
C             'FD' : FLUAGE DE DESSICCATION
C     VIM   : VARIABLES INTERNES
C OUT EPSFM : VECTEUR DE DEFORMATIONS DE FLUAGE
C
C  STRUCTURE DES VARIABLES INTERNES : VIM,VIP ( X = I ou F )
C
C     VIX(1)     = ERSP  : DEFORMATION DE FLUAGE REV SPHERIQUE
C     VIX(2)     = EISP  : DEFORMATION DE FLUAGE IRR SPHERIQUE
C     VIX(3)     = ERD11 : DEFORMATION DE FLUAGE REV DEVIATORIQUE 11
C     VIX(4)     = EID11 : DEFORMATION DE FLUAGE IRE DEVIATORIQUE 11
C     VIX(5)     = ERD22 : DEFORMATION DE FLUAGE REV DEVIATORIQUE 22
C     VIX(6)     = EID22 : DEFORMATION DE FLUAGE IRE DEVIATORIQUE 22
C     VIX(7)     = ERD33 : DEFORMATION DE FLUAGE REV DEVIATORIQUE 33
C     VIX(8)     = EID33 : DEFORMATION DE FLUAGE IRE DEVIATORIQUE 33
C     VIX(9)     = EFD11 : DEFORMATION DE FLUAGE DE DESSICCATION  11
C     VIX(10)    = EFD22 : DEFORMATION DE FLUAGE DE DESSICCATION  22
C     VIX(11)    = EFD33 : DEFORMATION DE FLUAGE DE DESSICCATION  33
C     VIX(12)    = ERD12 : DEFORMATION DE FLUAGE REV DEVIATORIQUE 12
C     VIX(13)    = EID12 : DEFORMATION DE FLUAGE IRE DEVIATORIQUE 12
C     VIX(14)    = ERD23 : DEFORMATION DE FLUAGE REV DEVIATORIQUE 23
C     VIX(15)    = EID23 : DEFORMATION DE FLUAGE IRE DEVIATORIQUE 23
C     VIX(16)    = ERD31 : DEFORMATION DE FLUAGE REV DEVIATORIQUE 31
C     VIX(17)    = EID31 : DEFORMATION DE FLUAGE IRE DEVIATORIQUE 31
C     VIX(18)    = EFD12 : DEFORMATION DE FLUAGE DE DESSICCATION  12
C     VIX(19)    = EFD23 : DEFORMATION DE FLUAGE DE DESSICCATION  23
C     VIX(20)    = EFD31 : DEFORMATION DE FLUAGE DE DESSICCATION  31
C_______________________________________________________________________
C ----------------------------------------------------------------------
      IMPLICIT NONE
      CHARACTER*(*) CMP
      REAL*8  VIM(20), EPSFM(6)
      INTEGER I
      
      IF  (CMP(1:2).EQ.'FP')  THEN 
        DO 20 I=1,3
          EPSFM(I)=(VIM(1)+VIM(2))
 20     CONTINUE
        EPSFM(1)=EPSFM(1)+VIM(3)+VIM(4)
        EPSFM(2)=EPSFM(2)+VIM(5)+VIM(6)
        EPSFM(3)=EPSFM(3)+VIM(7)+VIM(8)
        EPSFM(4)=VIM(12)+VIM(13)
        EPSFM(5)=VIM(14)+VIM(15)
        EPSFM(6)=VIM(16)+VIM(17)
       ELSE IF  (CMP(1:2).EQ.'FD') THEN 
        EPSFM(1)=VIM(9)
        EPSFM(2)=VIM(10)
        EPSFM(3)=VIM(11)
        EPSFM(4)=VIM(18)
        EPSFM(5)=VIM(19)
        EPSFM(6)=VIM(20)
       ELSE IF  (CMP(1:2).EQ.'FT')  THEN 
        DO 25 I=1,3
          EPSFM(I)=(VIM(1)+VIM(2))
 25     CONTINUE
        EPSFM(1)=EPSFM(1)+VIM(3)+VIM(4)+VIM(9)
        EPSFM(2)=EPSFM(2)+VIM(5)+VIM(6)+VIM(10)
        EPSFM(3)=EPSFM(3)+VIM(7)+VIM(8)+VIM(11)
        EPSFM(4)=VIM(12)+VIM(13)+VIM(18)
        EPSFM(5)=VIM(14)+VIM(15)+VIM(19)
        EPSFM(6)=VIM(16)+VIM(17)+VIM(20)
      ENDIF 
      
      END
