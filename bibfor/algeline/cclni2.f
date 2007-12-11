      SUBROUTINE CCLNI2(COL1,COL2,N,D1,D2,COEF1,T1,T2,EPS,IER)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 07/01/2002   AUTEUR JFBHHUC C.ROSE 
C RESPONSABLE JFBHHUC C.ROSE
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
C ======================================================================
C     VERSION COMPLEXE DE COLNI2
      IMPLICIT NONE
      INTEGER N,IER
      COMPLEX*16 COL1(N),COL2(N),D1,D2,COEF1,T1(N),T2(N)
      REAL*8 EPS
C
      INTEGER I
      IF (ABS(D1).LE.EPS .OR. ABS(D2).LE.EPS) THEN
          IER = 1
      ELSE
          DO 110 I = 1,N
              T1(I) = COL1(I)
              COL1(I) = T1(I)/D1
              T2(I) = COL2(I) - COEF1*COL1(I)
              COL2(I) = T2(I)/D2
  110     CONTINUE
      END IF
      END
