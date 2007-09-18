      SUBROUTINE SANSNM(CHAR,    MOTFAC,  NOMA,  NZOCO,  NNOCO,
     &                  MOTGRZ,  SANSNZ,  PSANZ ,NUMSUR)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 17/09/2007   AUTEUR REZETTE C.REZETTE 
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
C
      IMPLICIT      NONE

      CHARACTER*8   CHAR
      CHARACTER*16  MOTFAC
      CHARACTER*(*) MOTGRZ,SANSNZ,PSANZ      
      CHARACTER*8   NOMA
      INTEGER       NZOCO
      INTEGER       NNOCO
      INTEGER       NUMSUR
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES MAILLEES - LECTURE DONNEES)
C
C LECTURE DES MAILLES DANS LE MOT-CLEF MOTGRT ET STOCKAGE
C DES NOEUDS DANS LA SD NOMSD
C      
C ----------------------------------------------------------------------
C
C
C NB: ON ELIMINE LES NOEUDS DU FOND DE FISSURE POUR LA METHODE 'VERIF'
C 
C IN  CHAR   : NOM UTILISATEUR DU CONCEPT DE CHARGE
C IN  MOTFAC : MOT-CLE FACTEUR (VALANT 'CONTACT')
C IN  NOMA   : NOM DU MAILLAGE
C IN  NZOCO  : NOMBRE DE ZONES DE CONTACT
C IN  NNOCO  : NOMBRE TOTAL DE NOEUDS DES SURFACES
C IN  NUMSUR : NUMERO DE LA SURFACE A LAQUELLE DOIT APPARTENIR LE
C              NOEUD (NUMERO: MAITRE OU ESCLAVE, 0 SI PAS DE VERIF)
C OUT SANS   : LISTE DES NOEUDS LUS DANS LES MOT-CLEFS
C OUT PSANS  : POINTEUR PAR ZONE DES NOEUDS LUS DANS LES MOT-CLEFS
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      CHARACTER*32 JEXNUM
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
      CHARACTER*24 SANS ,PSANS,PSURNO,CONTNO,PZONE
      INTEGER      JSANS,JPSANS,JSUNO,JNOCO,JZONE
      INTEGER      JDECNO,STOCNO,IRET 
      INTEGER      I,IJ,IZONE,INO,NBSURF,ISURF,ITT
      INTEGER      NUMNO,NUELIM,IELIM
      INTEGER      NBNO,NBELIM,JELIM,JTRAV,LTRAV,JTRAV2
      CHARACTER*16 MOTGR
      LOGICAL      LEXCL
      CHARACTER*8  MMAI1,MMAI2
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C 
C --- INITIALISATIONS
C 
      MOTGR  = MOTGRZ       
      SANS   = SANSNZ
      PSANS  = PSANZ
C 
C --- ACCES AUX STRUCTURES DE DONNEES DE CONTACT
C     
      PZONE  = CHAR(1:8)//'.CONTACT.PZONECO'
      PSURNO = CHAR(1:8)//'.CONTACT.PSUNOCO'
      CONTNO = CHAR(1:8)//'.CONTACT.NOEUCO'      
C
      CALL JEVEUO(PZONE, 'L',JZONE)
      CALL JEVEUO(PSURNO,'L',JSUNO)
      CALL JEVEUO(CONTNO,'L',JNOCO)
C
C --- CREATION DES VECTEURS 
C
      LTRAV  = NZOCO*NNOCO
      CALL WKVECT('&&SANSNO.TRAV','V V I',LTRAV,JTRAV)

      CALL JEEXIN(PSANS,IRET)
      IF(IRET.NE.0)CALL JEDETR(PSANS)
      CALL JEEXIN(SANS,IRET)
      IF(IRET.NE.0)CALL JEDETR(SANS)

      CALL WKVECT(PSANS ,'G V I',NZOCO+1,JPSANS)      
C
C --- INITIALISATIONS
C  
      ZI(JPSANS) = 0  
      STOCNO     = 0 
C
      DO 70 IZONE = 1,NZOCO
C
C --- LECTURE DES NOEUDS DONNES SOUS SANS_NOEUD OU SANS_GROUP_NO
C 
        CALL JEDETR('&&SANSNO.SANSNO' )
        CALL RELIEM(' ',NOMA,'NU_NOEUD',MOTFAC,IZONE,1,MOTGR,'GROUP_MA',
     &                '&&SANSNO.SANSNO',NBELIM)
        CALL JEVEUO('&&SANSNO.SANSNO','L',JELIM)
C
C --- NOMBRE DE NOEUDS A ELIMINER POUR LA ZONE
C        
        IF (NBELIM.NE.0) THEN
          CALL JEDETR('&&SANSNO.TRAV2' )
          CALL WKVECT('&&SANSNO.TRAV2','V V L',NBELIM,JTRAV2)
        ENDIF  
C
C --- ACCES A LA SURFACE DE CONTACT
C        
        NBSURF = ZI(JZONE+IZONE) - ZI(JZONE+IZONE-1)
        IF (NUMSUR.GT.NBSURF) THEN
          CALL ASSERT(.FALSE.)      
        ENDIF   
        IF (NUMSUR.NE.0) THEN
          CALL ASSERT(.FALSE.)      
        ENDIF                      
        ISURF  = NBSURF*(IZONE-1)+NUMSUR
C
C --- VERIF SI NOEUD APPARTIENT A SURFACE DE CONTACT
C
        
        DO 50 IELIM = 1, NBELIM
          NUELIM = ZI(JELIM+IELIM-1)
          CALL JENUNO(JEXNUM(NOMA(1:8)//'.NOMNOE',NUELIM),MMAI1)
          DO 11 IJ = 1,NBSURF
            ISURF  = NBSURF*(IZONE-1)+IJ
            NBNO   = ZI(JSUNO+ISURF) - ZI(JSUNO+ISURF-1)
            JDECNO = ZI(JSUNO+ISURF-1)
            DO 40 INO = 1,NBNO          
              NUMNO  = ZI(JNOCO+JDECNO+INO-1)
              CALL JENUNO(JEXNUM(NOMA(1:8)//'.NOMNOE',NUMNO),MMAI2)
              IF (NUMNO .EQ.NUELIM) THEN
                ZL(JTRAV2+IELIM-1) = .TRUE. 
              ENDIF         
   40       CONTINUE  
   11     CONTINUE                     
   50   CONTINUE 
C
        DO 51 IELIM = 1, NBELIM
          NUELIM = ZI(JELIM+IELIM-1)
          LEXCL  = ZL(JTRAV2+IELIM-1)
          CALL JENUNO(JEXNUM(NOMA(1:8)//'.NOMNOE',NUELIM),MMAI1)
          IF (.NOT.LEXCL) THEN
            NBELIM = NBELIM - 1
          ENDIF
          
  51    CONTINUE               
C
C --- NOMBRE FINAL DE NOEUDS A ELIMINER
C    
        IF (NBELIM.LT.0) THEN
          NBELIM = 0
        ENDIF               
C
C --- MISE A JOUR POINTEUR
C
        ZI(JPSANS+IZONE) = ZI(JPSANS+IZONE-1) + NBELIM 
C
C --- MISE A JOUR SD
C
        ITT    = 1
        DO 100 IELIM = 1,NBELIM
          NUELIM = ZI(JELIM+IELIM-1)
          LEXCL  = ZL(JTRAV2+IELIM-1)
          IF (LEXCL) THEN          
            ZI(JTRAV+STOCNO+ITT-1) = NUELIM 
            ITT = ITT + 1
          ENDIF                  
  100   CONTINUE 
C
        STOCNO = STOCNO + NBELIM   
        IF (STOCNO.GT.LTRAV) CALL ASSERT(.FALSE.)
C      
  70  CONTINUE
C
C --- CREATION DU VECTEUR 
C   
      IF (STOCNO.EQ.0) THEN
        CALL WKVECT(SANS,'G V I',1     ,JSANS) 
      ELSE
        CALL WKVECT(SANS,'G V I',STOCNO,JSANS)   
C
C --- TRANSFERT DU VECTEUR
C
        DO 170 I = 1,STOCNO          
          IF (ZI(JTRAV+I-1).NE.0) THEN
            ZI(JSANS+I-1) = ZI(JTRAV+I-1)
          ENDIF
  170   CONTINUE       
      ENDIF
C
C --- DESTRUCTION DES VECTEURS DE TRAVAIL TEMPORAIRES
C
      CALL JEDETR('&&SANSNO.SANSNO')
      CALL JEDETR('&&SANSNO.TRAV'  )
      CALL JEDETR('&&SANSNO.TRAV2' )      
C
      CALL JEDEMA()  
      END
