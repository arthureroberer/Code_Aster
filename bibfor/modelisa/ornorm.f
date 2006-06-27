      SUBROUTINE ORNORM ( NOMA, LISTMA, NBMAIL, REORIE, NORIEN )
      IMPLICIT NONE
      INTEGER             LISTMA(*), NBMAIL, NORIEN
      LOGICAL             REORIE
      CHARACTER*8         NOMA
C.======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 26/06/2006   AUTEUR CIBHHLV L.VIVAN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
C   ORNORM  --  LE BUT EST QUE TOUTES LES MAILLES DE LA LISTE SOIENT
C               ORIENTEES COMME LA PREMIERE MAILLE DE LA LISTE.
C
C   ARGUMENT        E/S  TYPE         ROLE
C    NOMA           IN    K8      NOM DU MAILLAGE
C    LISTMA         IN    I       LISTE DES MAILLES A REORIENTER
C    NBMAIL         IN    I       NB DE MAILLES DE LA LISTE
C    NORIEN        VAR            NOMBRE DE MAILLES REORIENTEES
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
      CHARACTER*32     JEXNUM, JEXNOM, JEXATR
C -----  VARIABLES LOCALES
      INTEGER       NBNOMX
      PARAMETER    (NBNOMX = 27)
      INTEGER       IDTYMA, NUTYMA, LORI, JORI, NORI, KORI, ILISTE
      INTEGER       IMA, NUMAIL, NUMA, JDES, NBNO1, NORIEG, LLISTE
      INTEGER       IM1, IM2, IDEB, ICO, IORIM1, IORIM2, NORIEM
      INTEGER       P1, P2, IFM , NIV, LISNOE(NBNOMX), KTYP, P3, P4
      INTEGER       NBNMAI, NBNOE, INO, NBNSM, I, JDESM1, JDESM2
      INTEGER       NBMAVO, INDIIS, INDI, IM3, NCONEX
      LOGICAL       PASORI, DIME1, DIME2
      CHARACTER*1   K1BID, LECT
      CHARACTER*2   KDIM
      CHARACTER*8   TYPEL, NOMAIL
      CHARACTER*24  MAILMA, NOMAVO
C
      PASORI(IMA) = ZI(LORI-1+IMA).EQ.0
C
C.========================= DEBUT DU CODE EXECUTABLE ==================
C
      CALL JEMARQ ( )
      CALL INFNIV ( IFM , NIV )
C
      MAILMA = NOMA//'.NOMMAI'
      LECT = 'L'
      IF ( REORIE ) LECT = 'E'
C
C --- VECTEUR DU TYPE DES MAILLES DU MAILLAGE :
C     ---------------------------------------
      CALL JEVEUO(NOMA//'.TYPMAIL','L',IDTYMA)
C
C --- APPEL A LA CONNECTIVITE :
C     -----------------------
      CALL JEVEUO ( JEXATR(NOMA//'.CONNEX','LONCUM'), 'L', P2 )
      CALL JEVEUO ( NOMA//'.CONNEX', LECT, P1 )
C
C     ALLOCATIONS :
C     -----------
      CALL WKVECT('&&ORNORM.ORI1','V V I',NBMAIL,LORI)
      CALL WKVECT('&&ORNORM.ORI2','V V I',NBMAIL,JORI)
      CALL WKVECT('&&ORNORM.ORI3','V V I',NBMAIL,NORI)
      CALL WKVECT('&&ORNORM.ORI4','V V I',NBMAIL,KORI)
      CALL WKVECT('&&ORNORM.ORI5','V V K8',NBMAIL,KTYP)
C
C --- VERIFICATION DU TYPE DES MAILLES
C --- (ON DOIT AVOIR DES MAILLES DE PEAU) :
C     -----------------------------------
      DIME1 = .FALSE.
      DIME2 = .FALSE.
      DO 10 IMA = 1, NBMAIL
        ZI(LORI-1+IMA) = 0
        NUMA = LISTMA(IMA)
        ZI(NORI-1+IMA) = ZI(P2+NUMA)-ZI(P2-1+NUMA)
        ZI(KORI-1+IMA) = ZI(P2+NUMA-1)
        JDESM1 = ZI(P2+NUMA-1)
C
C ---   TYPE DE LA MAILLE COURANTE :
C       --------------------------
        NUTYMA = ZI(IDTYMA+NUMA-1)
        CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',NUTYMA),TYPEL)
        ZK8(KTYP-1+IMA) = TYPEL
C
        IF (TYPEL(1:4).EQ.'QUAD') THEN
          DIME2 = .TRUE.
        ELSEIF (TYPEL(1:4).EQ.'TRIA') THEN
          DIME2 = .TRUE.
        ELSEIF (TYPEL(1:3).EQ.'SEG') THEN
          DIME1 = .TRUE.
        ELSE
          CALL JENUNO(JEXNUM(MAILMA,NUMA),NOMAIL)
          CALL UTMESS('F','ORNORM','IMPOSSIBILITE, LA MAILLE '//
     +                NOMAIL//' DOIT ETRE UNE MAILLE DE PEAU, I.E. '//
     +                'DE TYPE "QUAD" OU "TRIA" EN 3D OU DE TYPE "SEG" '
     +              //'EN 2D, ET ELLE EST DE TYPE : '//TYPEL)
        ENDIF
        IF (DIME1.AND.DIME2) CALL UTMESS('F','ORNORM',
     +  'IMPOSSIBILITE DE MELANGER DES "SEG" ET DES "TRIA" OU "QUAD" !')
  10  CONTINUE
C
C --- RECUPERATION DES MAILLES VOISINES DU GROUP_MA :
C     ---------------------------------------------
      KDIM ='  '
      IF ( DIME1 ) KDIM ='1D'
      IF ( DIME2 ) KDIM ='2D'
      NOMAVO = '&&ORNORM.MAILLE_VOISINE '
      CALL UTMAVO ( NOMA, KDIM, LISTMA, NBMAIL, 'V', NOMAVO )
      CALL JEVEUO ( JEXATR(NOMAVO,'LONCUM'), 'L', P4 )
      CALL JEVEUO ( NOMAVO, 'L', P3 )
C
      NORIEG = 0
C
C --- LA BOUCLE 100 DEFINIT LES CONNEXES
C
      NCONEX = 0
      DO 100 IMA = 1 , NBMAIL
        NUMAIL = LISTMA(IMA)
C ----- SI LA MAILLE N'EST PAS ORIENTEE ON L'ORIENTE
        IF ( PASORI(IMA) ) THEN
          IF ( NIV. EQ. 2 ) THEN
            CALL JENUNO(JEXNUM(MAILMA,NUMAIL),NOMAIL)
            WRITE (IFM,*) 'LA MAILLE ',NOMAIL,
     +                    ' SERT A ORIENTER UN NOUVEAU GROUPE CONNEXE'
          ENDIF
          NCONEX = NCONEX + 1
          IF ( NCONEX .GT. 1 ) 
     +       CALL UTMESS('F','ORNORM','1 SEUL CONNEXE')
          ZI(LORI-1+IMA) = 1
          LLISTE = 0
          ILISTE = 0
          ZI(JORI+LLISTE) = IMA
C
C ------- ON ORIENTE TOUTES LES MAILLES DU CONNEXE
C
  200     CONTINUE
C
          IM1 = ZI(JORI+ILISTE)
          JDESM1 =  ZI(KORI-1+IM1)
C ------- ON ESSAYE D'ORIENTER LES MAILLES VOISINES
          NBMAVO = ZI(P4+IM1)-ZI(P4-1+IM1)
          DO 210 IM3 = 1, NBMAVO
            INDI = ZI(P3+ZI(P4+IM1-1)-1+IM3-1)
            IM2 = INDIIS ( LISTMA, INDI, 1, NBMAIL )
            IF ( IM2 .EQ. 0 ) GOTO 210
            NUMAIL = LISTMA(IM2)
            IF ( PASORI(IM2) ) THEN
              JDESM2 = ZI(KORI-1+IM2)
C             VERIFICATION DE LA CONNEXITE ET REORIENTATION EVENTUELLE
              IF (DIME1) ICO = IORIM1 ( ZI(P1+JDESM1-1), 
     +                                  ZI(P1+JDESM2-1), REORIE )
              IF (DIME2)
     +         ICO = IORIM2 ( ZI(P1+JDESM1-1),ZI(NORI-1+IM1),
     +                        ZI(P1+JDESM2-1),ZI(NORI-1+IM2), REORIE )
C             SI MAILLES CONNEXES
              IF (ICO.NE.0) THEN
                ZI(LORI-1+IM2) = 1
                LLISTE = LLISTE + 1
                ZI(JORI+LLISTE) = IM2
                IF ( REORIE .AND. NIV. EQ. 2 ) THEN
                  CALL JENUNO(JEXNUM(MAILMA,NUMAIL),NOMAIL)
                  IF (ICO.LT.0) THEN
                  WRITE (IFM,*) 'LA MAILLE ',NOMAIL,' A ETE REORIENTEE'
                  ELSE
                    WRITE (IFM,*) 'LA MAILLE ',NOMAIL,' EST ORIENTEE'
                  ENDIF
                ENDIF
              ENDIF
C              
C             SI ORIENTATIONS CONTRAIRES
              IF (ICO.LT.0)  NORIEG = NORIEG + 1
C
            ENDIF
  210     CONTINUE
          ILISTE = ILISTE + 1
          IF (ILISTE.LE.LLISTE) GOTO 200
        ENDIF
  100 CONTINUE
C
      NORIEN = NORIEN + NORIEG
C
      CALL JEDETR('&&ORNORM.ORI1')
      CALL JEDETR('&&ORNORM.ORI2')
      CALL JEDETR('&&ORNORM.ORI3')
      CALL JEDETR('&&ORNORM.ORI4')
      CALL JEDETR('&&ORNORM.ORI5')
      CALL JEDETR(NOMAVO)
C
      CALL JEDEMA()
      END
