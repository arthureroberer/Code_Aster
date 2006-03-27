      FUNCTION IORIM2 ( NUM1, N1, NUM2, N2, REORIE )
      IMPLICIT NONE
      INTEGER           IORIM2, N1, N2, NUM1(N1), NUM2(N2)
      LOGICAL           REORIE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 28/03/2006   AUTEUR CIBHHLV L.VIVAN 
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
C     IORIM2  --  ORIENTATION D'UNE MAILLE PAR RAPPORT A UNE VOISINE
C
C   ARGUMENT        E/S  TYPE         ROLE
C    NUM1            IN    K*     NUMEROTATION DE LA MAILLE 1
C    NUM2          IN/OUT  K*     NUMEROTATION DE LA MAILLE 2
C    N1              IN    K*     NOMBRE DE NOEUDS DE LA MAILLE 1
C    N2              IN    K*     NOMBRE DE NOEUDS DE LA MAILLE 2
C
C   CODE RETOUR IORIM2 : 0 SI LES MAILLES NE SONT PAS CONTIGUES
C                       -1 OU 1 SINON (SELON QU'IL AIT OU NON
C                                      FALLU REORIENTER)
C
      LOGICAL EGAL
C     DONNEES POUR TRIA3,TRIA6,TRIA7,QUAD4,QUAD8,QUAD9
C     NOMBRE DE SOMMETS EN FONCTION DU NOMBRE DE NOEUDS DE L'ELEMENT
      INTEGER NSO(9), NSO1, NSO2, I1, J1, I2, J2, I, K, L
      DATA NSO /0,0,3,4,0,3,3,4,4/
C
      EGAL(I1,J1,I2,J2)=(NUM1(I1).EQ.NUM2(I2)).AND.
     .                  (NUM1(J1).EQ.NUM2(J2))
C
C.========================= DEBUT DU CODE EXECUTABLE ==================
C
      NSO1 = NSO(N1)
      NSO2 = NSO(N2)
C     BOUCLES SUR LES ARETES
      DO 10 I1 = 1 , NSO1
         J1 = I1 + 1
         IF ( J1 .GT. NSO1 ) J1 = 1
         DO 10 I2 = 1 , NSO2
            J2 = I2 + 1
            IF ( J2 .GT. NSO2 ) J2 = 1
            IF ( EGAL(I1,J1,I2,J2) ) THEN
               IORIM2 = -1
               GOTO 100
            ENDIF
            IF ( EGAL(I1,J1,J2,I2) ) THEN
               IORIM2 = 1
               GOTO 100
            ENDIF
   10 CONTINUE
      IORIM2 = 0
  100 CONTINUE
C
C --- ON PERMUTE LES SOMMETS
      IF ( REORIE .AND. IORIM2.LT.0 ) THEN
         K = NUM2(2)
         L = NUM2(NSO2)
         NUM2(2) = L
         NUM2(NSO2) = K
C        ON PERMUTE LES NOEUDS INTERMEDIAIRES
         IF ( N2 .NE. NSO2 ) THEN
            DO 200 I = 1 , NSO2/2
               K = NUM2(NSO2+I)
               L = NUM2(2*NSO2+1-I)
               NUM2(NSO2+I) = L
               NUM2(2*NSO2+1-I) = K
  200       CONTINUE
         ENDIF
      ENDIF
C
      END
