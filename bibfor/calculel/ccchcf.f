      SUBROUTINE CCCHCF(NOMFOR, NBCMP, VALIN, LICMP, NBCMPR,
     &                  VALRES, IRET)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 13/09/2011   AUTEUR COURTOIS M.COURTOIS 
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
      IMPLICIT NONE
      INTEGER      NBCMP,NBCMPR,IRET
      REAL*8       VALIN(NBCMP),VALRES(NBCMPR)
      CHARACTER*8  NOMFOR(NBCMPR),LICMP(NBCMP)
C RESPONSABLE COURTOIS M.COURTOIS
C ----------------------------------------------------------------------
C  CALC_CHAMP - TRAITEMENT DE CHAM_UTIL - CALCUL FORMULE
C  -    -                     --          -      -
C  EVALUE LES FORMULES (SUR LA GRANDEUR 'NOMGD') SUR LES
C  'NBCMP' VALEURS DES COMPOSANTES. RANGE LE RESULTAT DANS 'VALRES'.
C ----------------------------------------------------------------------
C IN  :
C   NOMFOR K8(*) NOMS DES FORMULES
C   NOMGD  K8    NOM DE LA GRANDEUR DU CHAMP IN
C   NBCMP  I     NBRE DE COMPOSANTES DEFINIES SUR LE POINT COURANT
C   VALIN  R(*)  VALEURS DES COMPOSANTES
C   LICMP  K8(*) NOM DES COMPOSANTES EFFECTIVEMENT REMPLIES
C   NBCMPR I     NOMBRE DE COMPOSANTES EN SORTIE
C IN :
C   VALRES R(*)  VALEURS DU CRITERE
C   IRET   I     CODE RETOUR : = 0 OK,
C                              > 0 ON N'A PAS PU CALCULER LE CRITERE
C ----------------------------------------------------------------------
C   ----- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER        ZI
      COMMON /IVARJE/ZI(1)
      REAL*8         ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16     ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL        ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8    ZK8
      CHARACTER*16          ZK16
      CHARACTER*24                  ZK24
      CHARACTER*32                          ZK32
      CHARACTER*80                                  ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     ----- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
      INTEGER      I
      CHARACTER*1  CODMES
      CHARACTER*8  NOMF
C     ----- FIN  DECLARATIONS ------------------------------------------
C
      CALL JEMARQ()
      IRET = 1
C     METTRE 'A' POUR DEBUG, ' ' EN PROD
      CODMES = 'A'
      IF (NBCMP.EQ.0) GOTO 9999
C
      DO 100 I=1,NBCMPR
        NOMF = NOMFOR(I)
C       VERIFIER QUE LES PARAMETRES DE LA FORMULE SONT DANS LES
C       COMPOSANTES FOURNIES
        CALL FOINTE(CODMES,NOMF,NBCMP,LICMP,VALIN,VALRES(I),IRET)
        IF (IRET.NE.0) THEN
          GOTO 9999
        ENDIF
 100  CONTINUE
C
 9999 CONTINUE
      CALL JEDEMA()
C
      END
