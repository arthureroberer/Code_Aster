      SUBROUTINE XCONLI(NOMA  ,NOMO  ,PREMIE,DEFICO,RESOCO,
     &                  DEPDEL,DDEPLA,DEPMOI,DEPPLU,SCONEL,
     &                  MCONEL)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 30/04/2007   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE GENIAUT S.GENIAUT
C
      IMPLICIT NONE
      LOGICAL       PREMIE
      CHARACTER*8   NOMO,NOMA
      CHARACTER*24  DEPMOI,DEPPLU,DEPDEL,DDEPLA
      CHARACTER*8   MCONEL,SCONEL
      CHARACTER*24  DEFICO,RESOCO
C     
C ----------------------------------------------------------------------
C
C ROUTINE XFEM (METHODE XFEM - CREATION OBJETS)
C
C CREATION DES OBJETS ELEMENTAIRES:
C  - CHAM_ELEM
C  - VECT_ELEM
C  - MATR_ELEM
C      
C ----------------------------------------------------------------------
C
C
C IN  DEPDEL : INCREMENT DE DEPLACEMENT CUMULE
C IN  DEPDEL : INCREMENT DE DEPLACEMENT SOLUTION
C IN  DEPMOI : CHAM_NO DES DEPLACEMENTS A L'INSTANT PRECEDENT
C IN  DEPMOI : CHAM_NO DES DEPLACEMENTS A L'INSTANT COURANT
C IN  PREMIE : VAUT .TRUE. SI PREMIER PAS DE TEMPS
C IN  NOMO   : NOM DE L'OBJET MOD�LE
C IN  NOMA   : NOM DE L'OBJET MAILLAGE 
C IN  RESOCO : SD CONTACT RESULTAT
C IN  DEFICO : SD CONTACT DEFINITION
C OUT MCONEL : MATR_ELEM - MATRICES ELEMENTAIRES
C OUT SCONEL : VECT_ELEM - SECONDS MEMBRES ELEMENTAIRES
C      
C ----------------------------------------------------------------------
C
      INTEGER      IFM,NIV   
      INTEGER      NEQ
      INTEGER      JDEPDE,JDDEPL   
      CHARACTER*8  K8BID
C      
C ----------------------------------------------------------------------
C
      CALL INFDBG('XFEM',IFM,NIV)      
C
C --- AFFICHAGE
C      
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<XFEM   > CREATION ET INITIALISATION'//
     &        ' DES OBJETS *_ELEM' 
      ENDIF 
C 
C --- INITIALISATION DES CHAMPS DE DEPLACEMENT
C     
      CALL COPISD('CHAMP_GD','V',DEPMOI,DEPPLU) 
      CALL JEVEUO(DEPDEL(1:19)//'.VALE','E',JDEPDE)
      CALL JEVEUO(DDEPLA(1:19)//'.VALE','E',JDDEPL)
      CALL JELIRA(DEPDEL(1:19)//'.VALE','LONMAX',NEQ,K8BID)
      CALL ZZZERO(NEQ,JDEPDE)
      CALL ZZZERO(NEQ,JDDEPL)      
C
C --- CREATION DES CHAM_ELEM SI PREMIER PAS DE TEMPS
C  
      IF (PREMIE) THEN
        CALL XMELEM(NOMA  ,NOMO  ,DEFICO,RESOCO)
      ENDIF     
C
C --- CREATION DES VECT_ELEM ET MATR_ELEM
C  
      CALL XMMCME(NOMO  ,NOMA  ,DEPMOI,DEPDEL,RESOCO,
     &            MCONEL,SCONEL)
C
      END
