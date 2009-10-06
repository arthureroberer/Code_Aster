      SUBROUTINE NMCOUN(MAILLA,FONACT,MATASS,DEFICO,RESOCO,
     &                  DEFICU,RESOCU,ITERAT,VALPLU,SOLALG,
     &                  VEASSE,INSTAN,RESIGR,SDTIME,CTCCVG)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 05/10/2009   AUTEUR DESOZA T.DESOZA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
      CHARACTER*8  MAILLA
      CHARACTER*24 DEFICO,RESOCO
      CHARACTER*24 DEFICU,RESOCU,SDTIME
      CHARACTER*24 VALPLU(8)
      CHARACTER*19 SOLALG(*),VEASSE(*)
      CHARACTER*19 MATASS
      INTEGER      ITERAT
      REAL*8       INSTAN
      REAL*8       RESIGR
      INTEGER      CTCCVG(2)
      LOGICAL      FONACT(*)
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C MISE A JOUR DE L'INCREMENT DE DEPLACEMENT SI CONTACT OU
C LIAISON_UNILATER
C
C
C ----------------------------------------------------------------------
C
C
C IN  MAILLA : NOM DU MAILLAGE
C IN  FONACT : FONCTIONNALITES ACTIVEES (VOIR NMFONC)
C IN  MATASS : NOM DE LA MATRICE DU PREMIER MEMBRE ASSEMBLEE
C IN  DEFICO : SD DE DEFINITION DU CONTACT
C IN  RESOCO : SD DE RESOLUTION DU CONTACT
C IN  DEFICU : SD DE DEFINITION DE LIAISON_UNILATER
C IN  RESOCU : SD DE RESOLUTION DE LIAISON_UNILATER
C IN  VALPLU : VARIABLE CHAPEAU POUR ETAT EN T+
C IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
C               OUT: DDEPLA
C IN  SDTIME : SD TIMER
C IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
C IN  RESIGR : RESI_GLOB_RELA
C IN  ITERAT : ITERATION DE NEWTON
C IN  INSTAN : VALEUR DE L'INSTANT DE CALCUL
C OUT CTCCVG : CODES RETOURS D'ERREUR DU CONTACT
C                       (1) NOMBRE MAXI D'ITERATIONS
C                       (2) MATRICE SINGULIERE
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      LOGICAL      ISFONC,LUNIL,LCTCD
      CHARACTER*19 NMCHEX,DEPDEL,DDEPLA,CNCINE
      CHARACTER*24 K24BID,DEPPLU
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL UTTCPU('CPU.COFR.1','DEBUT',' ')
C
C --- FONCTIONNALITES ACTIVEES
C
      LUNIL  = ISFONC(FONACT,'LIAISON_UNILATER')
      LCTCD  = ISFONC(FONACT,'CONT_DISCRET')
C
C --- DECOMPACTION VARIABLES CHAPEAUX
C
      CALL DESAGG(VALPLU,DEPPLU,K24BID,K24BID,K24BID,
     &            K24BID,K24BID,K24BID,K24BID)
      DDEPLA = NMCHEX(SOLALG,'SOLALG','DDEPLA')
      DEPDEL = NMCHEX(SOLALG,'SOLALG','DEPDEL')
      CNCINE = NMCHEX(VEASSE,'VEASSE','CNCINE')
C
C --- TRAITEMENT DU CONTACT ET/OU DU FROTTEMENT DISCRET
C
      IF (LCTCD) THEN
        CALL NMCOFR(MAILLA,DEPPLU,DEPDEL,DDEPLA,MATASS,
     &              DEFICO,RESOCO,INSTAN,ITERAT,RESIGR,
     &              SDTIME,CTCCVG)
      END IF
C
C --- TRAITEMENT DE LIAISON_UNILATER
C
      IF (LUNIL) THEN
        CALL NMUNIL(MAILLA,DEPPLU,DDEPLA,MATASS,DEFICU,
     &              RESOCU,CNCINE,ITERAT,INSTAN)
      END IF
C
      CALL UTTCPU('CPU.COFR.1','FIN',' ')
      CALL JEDEMA()
      END
