      SUBROUTINE MMINTG(TYPELT,TYPINT,TYPMAE,IPG   ,XPC   ,
     &                  YPC   ,WPG)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 17/10/2011   AUTEUR ABBAS M.ABBAS 
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      CHARACTER*(*) TYPELT
      CHARACTER*8   TYPMAE
      REAL*8        WPG,XPC,YPC
      INTEGER       IPG,TYPINT
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE CONTINUE - UTILITAIRE)
C
C POINTS ET POIDS D'INTEGRATION
C
C ----------------------------------------------------------------------
C
C
C IN  TYPELT : TYPE ELEMENT DE CONTACT (POIN_ELEM OU ELEM_ELEM)
C IN  TYPINT : TYPE DU SCHEMA D'INTEGRATION
C IN  TYPMAE : TYPE DE LA MAILLE DE CONTACT
C IN  IPG    : NUMERO DU POINT D'INTEGRATION
C OUT WPG    : POIDS DU POINT INTEGRATION DU POINT DE CONTACT
C OUT XPC    : POINT DE CONTACT SUIVANT KSI1
C OUT YPC    : POINT DE CONTACT SUIVANT KSI2 
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
      INTEGER JPCF
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
      IF (TYPELT.EQ.'POIN_ELEM') THEN
        CALL JEVECH('PCONFR','L',JPCF )
        XPC      =      ZR(JPCF-1+1)
        YPC      =      ZR(JPCF-1+2)
        WPG      =      ZR(JPCF-1+11)
      ELSEIF  (TYPELT.EQ.'ELEM_ELEM') THEN
        CALL MMGAUS(TYPMAE,TYPINT,IPG   ,XPC   ,YPC   ,
     &              WPG   )
      ELSE 
        CALL ASSERT(.FALSE.)
      ENDIF
C      
      CALL JEDEMA()
C
      END
