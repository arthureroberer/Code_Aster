      SUBROUTINE NMCRPX(MOTFAZ,MOTPAZ,IOCC  ,NOMSD ,BASE  )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 21/09/2011   AUTEUR COURTOIS M.COURTOIS 
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
      IMPLICIT      NONE
      CHARACTER*(*) MOTFAZ,MOTPAZ      
      CHARACTER*1   BASE
      INTEGER       IOCC
      CHARACTER*19  NOMSD
C
C ----------------------------------------------------------------------
C
C ROUTINE *_NON_LINE (UTILITAIRE - SELEC. INST.)
C
C LECTURE DES INFORMATIONS DANS CATAPY POUR LES MOTS-CLEFS
C DE TYPE SELECTION D'INSTANTS 
C
C ----------------------------------------------------------------------
C
C
C CETTE ROUTINE LIT DES ARGUMENTS DE TYPE SELECTION D'INSTANTS
C  L'UTILISATEUR DONNE SES INSTANTS DE TROIS MANIERES DIFFERENTES
C
C    1/ LISTE D'INSTANTS DONNEE PAR MOT-CLEF <LIST_INST>
C         LA LISTE AYANT ETE CREEE PAR DEFI_LIST_REEL
C    2/ LISTE D'INSTANTS DONNEE PAR MOT-CLEF <LIST>
C         LA LISTE AYANT ETE CREEE PAR UNE LISTE PYTHON (LIST_R8)
C    3/ FREQUENCE DES INSTANTS DONNEE PAR MOT-CLEF <PAS_*>
C         LA LISTE AYANT ETE CREEE PAR UNE LISTE PYTHON (LIST_R8)
C
C NB: SI PAS DE LISTE NI DE FREQUENCE DONNEES, PAR DEFAUT, PAS = 1
C
C
C IN  MOTFAC : MOT-FACTEUR POUR LIRE <LIST_INST/INST>
C               SI MOTFAC= ' ' -> ON NE LIT RIEN ET ON PREND DES
C               VALEURS PAR DEFAUT
C               FREQ = 1  
C IN  MOTPAS : MOT-FACTEUR POUR LIRE <PAS>
C IN  IOCC   : OCCURRENCE DU MOT-CLEF FACTEUR MOTFAC
C IN  NOMSD  : NOM DE LA STRUCTURE DE DONNEES PRODUITE
C     ON VA CREER DEUX OBJETS :
C         NOMSD(1:19)//'.INFL' -  VECTEUR DE R8 DE LONGUEUR 4 
C            1 - FREQUENCE (0 SI LISTE)
C            2 - TOLERANCE RECHERCHE (<0 SI ABSOLU, 
C                                     >0 SI RELATIF)
C            3 - NOMBRE D'INSTANTS DE LA LISTE (NBINST)
C            4 - VALEUR MINI. ENTRE DEUX INSTANTS
C         NOMSD(1:19)//'.LIST' - VECTEUR DE R8 DE LONGUEUR NBINST
C            LISTE DES INSTANTS
C IN  BASE   : NOM DE LA BASE POUR LA CREATION SD
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      INTEGER      ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8       ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16   ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL      ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8  ZK8
      CHARACTER*16    ZK16
      CHARACTER*24        ZK24
      CHARACTER*32            ZK32
      CHARACTER*80                ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C  
      CHARACTER*16 MOTFAC,MOTPAS
      CHARACTER*8  CRITER
      REAL*8       PREC,DTMIN,TOLE
      INTEGER      NBINST,N1,FREQ 
      CHARACTER*24 SDLIST,SDINFL   
      INTEGER      JINFL
      INTEGER      IARG
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      MOTFAC = MOTFAZ
      MOTPAS = MOTPAZ
      NBINST = 0
      FREQ   = 0      
C
C --- NOM DES SDS
C
      SDLIST = NOMSD(1:19)//'.LIST'
      SDINFL = NOMSD(1:19)//'.INFL'
C
C --- L'OPERATEUR N'UTILISE PAS LIST_INST
C
      IF (MOTFAC.EQ.' ') THEN
        FREQ   = 1
        CRITER = 'RELATIF'
        TOLE   = 0.D0
        NBINST = 0
        DTMIN  = 0.D0
        GOTO 99
      ENDIF
C
C --- LECTURE PRECISION
C
      CALL NMCRPP(MOTFAC,IOCC  ,PREC  ,CRITER,TOLE  )
C
C --- LECTURE LISTE INSTANTS
C
      CALL NMCRPA(MOTFAC,IOCC  ,SDLIST,BASE  ,NBINST,
     &            DTMIN )
C
C --- LECTURE PAS
C
      N1 = 0
      IF (NBINST .EQ. 0) THEN
        CALL GETVIS(MOTFAC,MOTPAS,IOCC  ,IARG,1,FREQ,N1)
        IF (N1.NE.0) THEN
          CALL ASSERT(FREQ.GE.0)
        ENDIF  
      ENDIF
C
C --- AUCUN MOT-CLE : PAS  = 1
C
      IF (N1+NBINST .EQ. 0) THEN
        FREQ = 1
      ENDIF
C
C --- SAUVEGARDE INFORMATIONS
C 
  99  CONTINUE
      CALL WKVECT(SDINFL,BASE//' V R',4,JINFL)
      ZR(JINFL-1+1) = FREQ
      ZR(JINFL-1+2) = TOLE
      ZR(JINFL-1+3) = NBINST
      ZR(JINFL-1+4) = DTMIN
C
      CALL JEDEMA()

      END
