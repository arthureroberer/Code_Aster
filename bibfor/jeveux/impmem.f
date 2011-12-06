      SUBROUTINE IMPMEM()
      IMPLICIT NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF JEVEUX  DATE 26/07/2011   AUTEUR ABBAS M.ABBAS 
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
C ======================================================================
C     RENVOIE LA VALEUR EN MEGA OCTETS DE LA MEMOIRE UTILISEE PAR JEVEUX
C     RVAL(1) = TAILLE EN MO CUMULEE UTISEE
C     RVAL(2) = TAILLE EN MO MAXIMUM UTILISEE AU COURS DE L'EX�CUTION
C     RVAL(3) = TAILLE EN MO CUMULEE ALLOUEE DYNAMIQUEMENT
C     RVAL(4) = TAILLE EN MO MAXIMUM ALLOUEE DYNAMIQUEMENT
C     RVAL(5) = LIMITE MAXIMALE POUR L'ALLOCATION DYNAMIQUE
C     RVAL(6) = TAILLE EN MO POUR VMDATA
C     RVAL(7) = TAILLE EN MO POUR VMSIZE
C     RVAL(8) = NOMBRE DE MISE EN OEUVRE DU MECANISME DE LIBERATION 
C     RVAL(9) = TAILLE EN MO POUR VMPEAK
C ======================================================================
      REAL*8           RVAL(9)
      
      CALL R8INIR(9,-1.D0,RVAL,1)
      
      CALL JEINFO(RVAL)
      
      IF (RVAL(9).GT.0.D0) THEN
        RVAL(9)=RVAL(9)/1024
        CALL U2MESR('I','JEVEUX_33',9,RVAL)
      ELSE
        CALL U2MESR('I','JEVEUX_34',9,RVAL)
      ENDIF
      
            
      END      
