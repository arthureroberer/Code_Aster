      SUBROUTINE ARLCBO(NOMBOI,BASE  ,NMA   ,NDIME ,NPAN  ,
     &                  NSOM  )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 09/01/2007   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      CHARACTER*1  BASE
      CHARACTER*16 NOMBOI
      INTEGER      NMA,NDIME,NPAN,NSOM
C      
C ----------------------------------------------------------------------
C
C ROUTINE ARLEQUIN
C
C CREATION DE LA SD BOITE 
C
C ----------------------------------------------------------------------
C
C IN  NOMBOI : NOM DE LA SD BOITE
C IN  BASE   : TYPE DE BASE ('V' OU 'G')
C IN  NMA    : NOMBRE DE MAILLES (= NOMBRE DE BOITES)
C IN  NDIME  : DIMENSION DE L'ESPACE (2 OU 3)
C IN  NPAN   : NOMBRE DE PANS
C IN  NSOM   : NOMBRE DE SOMMETS     
C      
C ----------------------------------------------------------------------
C
      CALL BOITCR(NOMBOI,BASE  ,NMA   ,NDIME ,NPAN  ,
     &            NSOM  )    
      END
