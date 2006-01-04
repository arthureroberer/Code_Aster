      SUBROUTINE CHCOMB ( TABLEZ, NOMAOU )
      IMPLICIT   NONE
      CHARACTER*8         NOMAOU
      CHARACTER*(*)       TABLEZ
C.======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 03/01/2006   AUTEUR REZETTE C.REZETTE 
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
C
C      CHCOMB -- IL S'AGIT DE CHANGER LES VALEURS DES COORDONNEES  
C                DES NOEUDS DU MAILLAGE DE NOM NOMAOU QUI SONT EXPRIMEES
C                DANS LE REPERE PRINCIPAL D'INERTIE AVEC POUR ORIGINE
C                LE CENTRE DE GRAVITE DE LA SECTION EN LEURS VALEURS
C                EXPRIMEES DANS UN REPERE AYANT LES MEMES DIRECTIONS
C                MAIS DONT L'ORIGINE EST SITUEE AU CENTRE DE
C                CISAILLEMENT-TORSION.
C                CE CHANGEMENT DE COORDONNEES EST NECESSAIRE
C                POUR CALCULER L'INERTIE DE GAUCHISSEMENT D'UNE POUTRE
C                DONT LA SECTION EST REPRESENTEE PAR LE MAILLAGE
C                NOMAOU QUI EST CONSTITUE D'ELEMENTS MASSIFS 2D.
C                
C
C   ARGUMENT        E/S  TYPE         ROLE
C    TABLEZ         IN    K*      NOM D'UNE TABLE DE TYPE TABL_CARA_GEOM
C                                 ISSUE DE LA COMMANDE POST_ELEM.
C                                 CETTE TABLE CONTIENT LES COORDONNEES
C                                 DU CENTRE DE CISAILLEMENT-TORSION. 
C    NOMAOU         IN    K*      NOM DU MAILLAGE REPRESENTANT LA 
C                                 SECTION DE LA POUTRE MAILLEE AVEC 
C                                 DES ELEMENTS MASSIFS 2D, LES 
C                                 COORDONNEES DES NOEUDS ETANT DEFINIES
C                                 DANS LE REPERE PRINCIPAL D'INERTIE
C                                 DONT L'ORIGINE EST LE CENTRE DE 
C                                 GRAVITE DE LA SECTION EN ENTREE
C                                 DE LA ROUTINE ET DANS CE MEME REPERE
C                                 DONT L'ORIGINE EST SITUEE AU CENTRE
C                                 DE CISAILLEMENT-TORSION EN SORTIE.
C.========================= DEBUT DES DECLARATIONS ====================
C ----- COMMUNS NORMALISES  JEVEUX 
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16            ZK16
      CHARACTER*24                    ZK24
      CHARACTER*32                            ZK32
      CHARACTER*80                                    ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C -----  VARIABLES LOCALES
      INTEGER       IBID, IRET, IDCODE, DIMCOO, NBNO, JCOOR, IDCOOR, INO
      REAL*8        R8B, XT, YT
      COMPLEX*16    C16B
      CHARACTER*8   K8B, NOMA
      CHARACTER*19  TABLE
      CHARACTER*24  COOVAL, COODES
C.========================= DEBUT DU CODE EXECUTABLE ==================
C
      CALL JEMARQ ( )
C
C --- INITIALISATIONS :
C     ---------------
      TABLE  = TABLEZ
      COOVAL = NOMAOU//'.COORDO    .VALE'
      COODES = NOMAOU//'.COORDO    .DESC'
C
C --- VERIFICATION DES PARAMETRES DE LA TABLE
C     ---------------------------------------
      CALL TBEXP2(TABLE,'MAILLAGE')
      CALL TBEXP2(TABLE,'LIEU')
      CALL TBEXP2(TABLE,'EY')
      CALL TBEXP2(TABLE,'EZ')
C
C --- RECUPERATION DANS LA TABLE DES COORDONNEES DU CENTRE DE 
C --- DE CISAILLEMENT-TORSION :
C     -----------------------
      CALL TBLIVA ( TABLE, 0, K8B, IBID, R8B, C16B, K8B, K8B, R8B, 
     +              'MAILLAGE', K8B, IBID, R8B, C16B, NOMA, IRET )
      CALL TBLIVA ( TABLE, 1, 'LIEU', IBID, R8B, C16B, NOMA, K8B,
     +              R8B, 'EY', K8B, IBID, XT, C16B, K8B, IRET )
      IF ( IRET .NE. 0 ) CALL UTMESS('F','CHCOMB','Y A UN BUG 0' )
      CALL TBLIVA ( TABLE, 1, 'LIEU', IBID, R8B, C16B, NOMA, K8B,
     +              R8B, 'EZ', K8B, IBID, YT, C16B, K8B, IRET )
      IF ( IRET .NE. 0 ) CALL UTMESS('F','CHCOMB','Y A UN BUG 2' )
C
C --- RECUPERATION DE LA DIMENSION DU MAILLAGE :
C     ----------------------------------------
      CALL JEVEUO ( COODES, 'L', IDCODE )
      DIMCOO = -ZI(IDCODE+2-1)
C
C --- NOMBRE DE NOEUDS DU MAILLAGE :
C     ----------------------------
      CALL DISMOI('F','NB_NO_MAILLA',NOMAOU,'MAILLAGE',NBNO,K8B,IRET)
C
C --- RECUPERATION DES COORDONNEES DES NOEUDS DU MAILLAGE :
C     ---------------------------------------------------
      CALL JEVEUO(COOVAL,'E',JCOOR)
C
C --- CHANGEMENT D'ORIGINE DES COORDONNEES :
C     ------------------------------------
      DO 10 INO = 1, NBNO
C
         IDCOOR       = JCOOR-1+DIMCOO*(INO-1)
         ZR(IDCOOR+1) = ZR(IDCOOR+1) + XT
         ZR(IDCOOR+2) = ZR(IDCOOR+2) + YT
 10   CONTINUE
C
      CALL JEDEMA ( )
C.============================ FIN DE LA ROUTINE ======================
      END
