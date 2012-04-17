      INTEGER FUNCTION DFLLVD(VECT) 
C    
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 12/07/2011   AUTEUR ABBAS M.ABBAS 
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
C
      IMPLICIT NONE
      CHARACTER*5 VECT
C      
C ----------------------------------------------------------------------
C
C ROUTINE GESTION LISTE INSTANTS
C
C RETOURNE LA LONGUEUR FIXE DES VECTEURS DE LA SD SDCONT
C
C ----------------------------------------------------------------------
C
C
C IN  VECT   : NOM DU VECTEUR DONT ON VEUT LA DIMENSION
C
C /!\ PENSER A MODIFIE SD_LIST_INST.PY (POUR SD_VERI)
C
C ----------------------------------------------------------------------
C
      INTEGER      LLINR
      PARAMETER   (LLINR=10)
      INTEGER      LEEVR,LEEVK,LESUR
      PARAMETER   (LEEVR=6,LEEVK=3,LESUR=10)
      INTEGER      LAEVR,LAEVK,LATPR,LATPK
      PARAMETER   (LAEVR=6,LAEVK=1,LATPR=6,LATPK=4)
C
C ----------------------------------------------------------------------
C

      IF (VECT.EQ.'LLINR') THEN
        DFLLVD = LLINR
      ELSE IF (VECT.EQ.'LEEVR') THEN
        DFLLVD = LEEVR  
      ELSE IF (VECT.EQ.'LEEVK') THEN
        DFLLVD = LEEVK 
      ELSE IF (VECT.EQ.'LESUR') THEN
        DFLLVD = LESUR           
      ELSE IF (VECT.EQ.'LAEVR') THEN
        DFLLVD = LAEVR     
      ELSE IF (VECT.EQ.'LAEVK') THEN
        DFLLVD = LAEVK            
      ELSE IF (VECT.EQ.'LATPR') THEN
        DFLLVD = LATPR   
      ELSE IF (VECT.EQ.'LATPK') THEN
        DFLLVD = LATPK             
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF  
C
      END
