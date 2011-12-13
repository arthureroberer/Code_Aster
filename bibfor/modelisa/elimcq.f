      SUBROUTINE ELIMCQ(CHAR  ,NOMA  ,INDQUA,NZOCO ,NSUCO ,
     &                  NNOCO )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 12/12/2011   AUTEUR DESOZA T.DESOZA 
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
      IMPLICIT     NONE
      CHARACTER*8  CHAR
      CHARACTER*8  NOMA
      INTEGER      INDQUA
      INTEGER      NZOCO,NSUCO,NNOCO
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES MAILLEES - LECTURE DONNEES)
C
C ELIMINATION AU SEIN DE CHAQUE SURFACE DE CONTACT POTENTIELLE DES
C NOEUDS ET MAILLES REDONDANTS. MODIFICATION DES POINTEURS ASSOCIES.
C
C ----------------------------------------------------------------------
C
C
C IN  CHAR   : NOM UTILISATEUR DU CONCEPT DE CHARGE
C IN  NOMA   : NOM DU MAILLAGE
C IN  INDQUA : VAUT 0 LORSQUE L'ON DOIT TRAITER LES NOEUDS MILIEUX
C                     A PART
C              VAUT 1 LORSQUE L'ON DOIT TRAITER LES NOEUDS MILIEUX
C                     NORMALEMENT
C IN  NZOCO  : NOMBRE TOTAL DE ZONES DE CONTACT
C IN  NSUCO  : NOMBRE TOTAL DE SURFACES DE CONTACT
C I/O NNOCO  : NOMBRE TOTAL DE NOEUDS DES SURFACES
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
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
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      NNOCO0
      CHARACTER*24 DEFICO
      CHARACTER*24 POINSN,LISTNO
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- LECTURE DES STRUCTURES DE DONNEES DE CONTACT
C
      DEFICO = CHAR(1:8)//'.CONTACT'
      LISTNO = '&&ELIMCQ.TRAVNO'
      POINSN = '&&ELIMCQ.ELIMNO'
C
C --- CAS DES QUAD8
C
      IF (INDQUA.EQ.0) THEN
C
C ----- CREATION D'UNE LISTE DES NOEUDS MILIEUX DES ARETES POUR 
C ----- LES MAILLES QUADRATIQUES      
C        
        NNOCO0 = NNOCO
        CALL CFLEQ8(NOMA  ,DEFICO,NZOCO ,NSUCO ,NNOCO ,
     &              NNOCO0,LISTNO,POINSN)
C
C ----- MISE A JOUR DE LA LISTE DES NOEUDS APRES ELIMINATION
C
        IF (NNOCO0.NE.NNOCO) THEN
         CALL CFMENO(DEFICO,NSUCO  ,NNOCO0,LISTNO,POINSN,
     &               NNOCO )
        ENDIF
          
      ENDIF
C
      CALL JEDETR(LISTNO)
      CALL JEDETR(POINSN)      
C
      CALL JEDEMA()
      END
