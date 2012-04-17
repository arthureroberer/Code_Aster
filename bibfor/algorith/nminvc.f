      SUBROUTINE NMINVC(MODELZ,MATE  ,CARELE,COMPOR,CARCRI,
     &                  SDTIME,SDDISC,SDDYNA,VALINC,SOLALG,
     &                  LISCHA,COMREF,RESOCO,RESOCU,NUMEDD,
     &                  FONACT,PARCON,VEELEM,SDSENS,VEASSE,
     &                  MEASSE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/04/2012   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_21
C
      IMPLICIT      NONE
      INTEGER       FONACT(*)
      CHARACTER*(*) MODELZ
      CHARACTER*24  MATE,CARELE
      CHARACTER*24  COMPOR,CARCRI
      REAL*8        PARCON(8)
      CHARACTER*19  SDDISC,SDDYNA,LISCHA
      CHARACTER*24  RESOCO,RESOCU
      CHARACTER*24  COMREF,NUMEDD,SDSENS,SDTIME
      CHARACTER*19  VEELEM(*),VEASSE(*),MEASSE(*)
      CHARACTER*19  SOLALG(*),VALINC(*)
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (CALCUL)
C
C CALCUL ET ASSEMBLAGE DES VECT_ELEM CONSTANTS AU COURS DU CALCUL
C
C ----------------------------------------------------------------------
C
C
C IN  FONACT : FONCTIONNALITES ACTIVEES (VOIR NMFONC)
C IN  SDDYNA : SD DYNAMIQUE
C IN  COMPOR : CARTE COMPORTEMENT
C IN  MODELE : NOM DU MODELE
C IN  SOLVEU : SOLVEUR
C IN  NUMEDD : NUME_DDL
C IN  RESOCO : SD RESOLUTION CONTACT
C IN  RESOCU : SD RESOLUTION LIAISON_UNILATER
C IN  LISCHA : LISTE DES CHARGEMENTS
C IN  MATE   : NOM DU CHAMP DE MATERIAU
C IN  CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C IN  CARCRI : PARAMETRES DES METHODES D'INTEGRATION LOCALES
C IN  SDDISC : SD DISCRETISATION
C IN  SDTIME : SD TIMER
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
C OUT MEELEM : MATRICES ELEMENTAIRES
C OUT MEASSE : MATRICES ASSEMBLEES
C
C ----------------------------------------------------------------------
C
      LOGICAL      ISFONC,LREFE,LDIDI,LSENS
      INTEGER      IFM,NIV
      INTEGER      NUMINS,NRPASE
      INTEGER      NBVECT
      CHARACTER*6  LTYPVE(20)
      CHARACTER*16 LOPTVE(20)
      LOGICAL      LCALVE(20),LASSVE(20)
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> PRECALCUL DES VECT_ELEM CONSTANTES'
      ENDIF
C
C --- FONCTIONNALITES ACTIVEES
C
      LDIDI  = ISFONC(FONACT,'DIDI')
      LREFE  = ISFONC(FONACT,'RESI_REFE')
C
C --- INITIALISATIONS
C
      NUMINS = 1
      LSENS  = .FALSE.
      NRPASE = 0
C
      CALL NMCVEC('INIT',' ',' ',.FALSE.,.FALSE.,
     &            NBVECT,LTYPVE,LOPTVE,LCALVE,LASSVE)
C
C --- CREATION DU VECT_ELEM POUR DIRICHLET DIFFERENTIEL
C
      IF (LDIDI) THEN
        CALL NMCVEC('AJOU','CNDIDI',' ',.TRUE.,.TRUE.,
     &              NBVECT,LTYPVE,LOPTVE,LCALVE,LASSVE)
      ENDIF
C
C --- CREATION DU VECT_ELEM POUR CRITERE EN CONTRAINTE GENERALISEE
C
      IF (LREFE) THEN
        CALL NMCVEC('AJOU','CNREFE',' ',.TRUE.,.TRUE.,
     &              NBVECT,LTYPVE,LOPTVE,LCALVE,LASSVE)
      ENDIF
C
C --- CREATION DU VECT_ELEM POUR FORCE DE REFERENCE LIEE
C --- AUX VAR. COMMANDES EN T-
C
      CALL NMCVEC('AJOU','CNVCF1',' ',.TRUE.,.TRUE.,
     &            NBVECT,LTYPVE,LOPTVE,LCALVE,LASSVE)
C
C --- CALCUL DES VECT_ELEM DE LA LISTE
C
      IF (NBVECT.GT.0) THEN
        CALL NMXVEC(MODELZ,MATE  ,CARELE,COMPOR,CARCRI,
     &              SDTIME,SDDISC,SDDYNA,NUMINS,VALINC,
     &              SOLALG,LISCHA,COMREF,RESOCO,RESOCU,
     &              NUMEDD,PARCON,SDSENS,LSENS ,NRPASE,
     &              VEELEM,VEASSE,MEASSE,NBVECT,LTYPVE,
     &              LCALVE,LOPTVE,LASSVE)
      ENDIF
C
      CALL JEDEMA()
      END
