      SUBROUTINE REPMAT (MAJ,LNOM,NOM)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF SUPERVIS  DATE 29/05/98   AUTEUR SABHHCM C.MASSERET 
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
      IMPLICIT NONE
      INTEGER MAJ,LNOM
      CHARACTER*(*) NOM
C     ----------------------------------------------------------------
C     MISE A JOUR ET INTERROGATION DU NOM DE REPERTOIRE DES FICHIERS
C     DU CATALOGUE DE MATERIAU
C     ----------------------------------------------------------------
      SAVE NOMREP,LL
      CHARACTER*128 NOMREP
      INTEGER LL
      DATA NOMREP /' '/
      IF (MAJ .EQ. 0) THEN
        NOMREP=NOM(1:LNOM)
        LL = LNOM
      ELSE
        NOM=NOMREP
        LNOM = LL
      ENDIF
      END
