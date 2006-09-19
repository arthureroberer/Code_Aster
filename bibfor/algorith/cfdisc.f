      SUBROUTINE CFDISC(DEFICO,RESOCO,TYPALC,TYPALF,FROT3D,MATTAN)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 18/09/2006   AUTEUR MABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE MABBAS M.ABBAS
      IMPLICIT     NONE
      CHARACTER*24 DEFICO
      CHARACTER*14 RESOCO
      INTEGER      TYPALC
      INTEGER      TYPALF
      INTEGER      FROT3D
      INTEGER      MATTAN
C ----------------------------------------------------------------------
C  ROUTINE UTILITAIRE (CONTACT TOUTES METHODES)
C ----------------------------------------------------------------------
C
C PERMET DE SAVOIR S'IL Y A CONTACT/FROTTEMENT
C
C IN  DEFICO  : SD DE DEFINITION DU CONTACT (ISSUE D'AFFE_CHAR_MECA) 
C IN  RESOCO  : SD DE TRAITEMENT NUMERIQUE DU CONTACT 
C               SI RESOCO = ' ', ON NE REGARDE PAS S'IL Y A 
C                CONTACT EFFECTIF
C OUT TYPALC  : TYPE ALGO UTILISE POUR LE CONTACT
C   LES VALEURS SONT NEGATIVES SI AUCUNE LIAISON ACTIVE
C   0 PAS DE CONTACT
C   1 CONTACT PENALISE
C   2 CONTACT LAGRANGIEN
C   3 CONTACT METHODE CONTINUE
C   4 CONTACT CONTRAINTES ACTIVES
C   5 CONTACT SANS CALCUL
C OUT TYPALF  : TYPE ALGO UTILISE POUR LE FROTTEMENT
C   LES VALEURS SONT NEGATIVES SI AUCUNE LIAISON ACTIVE
C   0 PAS DE FROTTEMENT 
C   1 FROTTEMENT PENALISE
C   2 FROTTEMENT LAGRANGIEN
C   3 FROTTEMENT METHODE CONTINUE
C OUT FROT3D  : VAUT 1 LORSQU'ON CONSIDERE LE FROTTEMENT EN 3D
C OUT MATTAN  : INDIQUE SI LA MATRICE TANGENTE GLOBALE EST MODIFIEE
C   PAR LA PRESENCE DE CONTACT/FROTTEMENT
C   0 NON
C   1 OUI
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
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
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      INTEGER      CFMMVD,ZMETH
      INTEGER      ICONTA,NBLIAC,LLF
      CHARACTER*24 COCO,METHCO,K24BID
      REAL*8       R8BID
      INTEGER      JCOCO,JMETH
      INTEGER      IMETH,IZONE,IBID
      LOGICAL      LFROTT
      CHARACTER*24 RESOCZ
C
C ----------------------------------------------------------------------
C
C
C --- INITIALISATION: NI CONTACT, NI FROTTEMENT  
C     
      TYPALC = 0
      TYPALF = 0
      MATTAN = 0
      FROT3D = 0
      ZMETH  = CFMMVD('ZMETH')
      RESOCZ(1:14) = RESOCO
C      
C --- Y A T-IL DU CONTACT/FROTTEMENT DANS LE CALCUL ?
C
      METHCO = DEFICO(1:16)//'.METHCO'
      CALL JEEXIN ( METHCO, ICONTA )
      IF (ICONTA.EQ.0) THEN 
        GOTO 10
      ENDIF
C
C --- RECUPERATION METHODE CONTACT/FROTTEMENT    
C
      CALL JEVEUO(METHCO,'L',JMETH)
      IZONE = 1
      IMETH = ZI(JMETH+ZMETH*(IZONE-1)+6)

      IF (IMETH.EQ.-2) THEN
        TYPALC = 5
        TYPALF = 0
        MATTAN = 0
        FROT3D = 0
      ELSE IF (IMETH.EQ.-1) THEN
        TYPALC = -1
        TYPALF = 0
        MATTAN = 1
        FROT3D = 0
      ELSE IF (IMETH.EQ.0) THEN
        TYPALC = -4
        TYPALF = 0
        MATTAN = 0
        FROT3D = 0
      ELSE IF  (IMETH.EQ.1) THEN
        TYPALC = -2
        TYPALF = 0
        MATTAN = 0
        FROT3D = 0
      ELSE IF  (IMETH.EQ.2) THEN
        TYPALC = -2
        TYPALF = -2
        MATTAN = 0
        FROT3D = 0
      ELSE IF  (IMETH.EQ.3) THEN
        TYPALC = -2
        TYPALF = -1
        MATTAN = 1
        FROT3D = 1
      ELSE IF  (IMETH.EQ.4) THEN
        TYPALC = -2
        TYPALF = -2
        MATTAN = 1
        FROT3D = 1
      ELSE IF  (IMETH.EQ.5) THEN
        TYPALC = -4
        TYPALF = -2
        MATTAN = 1
        FROT3D = 1
      ELSE IF  (IMETH.EQ.6) THEN
        TYPALC = -3
        MATTAN = 1
        FROT3D = 1
      ELSE IF  (IMETH.EQ.7) THEN
        TYPALC = -4
        TYPALF = 0
        MATTAN = 0
        FROT3D = 0
      ELSE IF  (IMETH.EQ.8) THEN
        TYPALC = -3
        TYPALF = 0
        MATTAN = 1
        FROT3D = 0
      ELSE IF  (IMETH.EQ.9) THEN
        TYPALC = -4
        TYPALF = 0
        MATTAN = 0
        FROT3D = 0
      ELSE
        CALL UTMESS('F',
     &              'CFDISC',
     &              'CODE METHODE CONTACT INCORRECT (DVLP)')   
      ENDIF
C
C --- FROTTEMENT METHODE CONTINUE
C
      IF (TYPALC.EQ.-3) THEN
        CALL MMINFP(IZONE,DEFICO,RESOCZ,'FROTTEMENT',
     &              IBID,R8BID,K24BID,LFROTT)
        IF (LFROTT) THEN
          TYPALF = -3
        ELSE
          TYPALF = 0
        ENDIF
      ENDIF
C
C --- DETECTION SI LIAISONS ACTIVES DE CONTACT OU FROTTEMENT
C
      IF (RESOCO(1:1).NE.' ') THEN
        CALL JEEXIN ( RESOCO(1:14)//'.APREAC', ICONTA )
        IF ( ICONTA .NE. 0 ) THEN
          COCO = RESOCO(1:14)//'.COCO'
          CALL JEEXIN(COCO,ICONTA)
          IF ( ICONTA .EQ. 0 ) THEN
            GOTO 10
          ENDIF
           
          CALL JEVEUO(COCO,'L',JCOCO)
          NBLIAC = ZI(JCOCO+2)
          LLF    = ZI(JCOCO+5)

          IF (NBLIAC.NE.0) THEN
            TYPALC = ABS(TYPALC)
          ENDIF
          IF (LLF.NE.0) THEN
            TYPALF = ABS(TYPALF)
          ENDIF

        END IF
      ENDIF

   10 CONTINUE

      END
