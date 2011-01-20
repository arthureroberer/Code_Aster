      SUBROUTINE XTEINI(NOMTE,NFH,NFE,SINGU,DDLC,NNOM,DDLS,NDDL,DDLM,
     &                 NFISS,CONTAC)
      IMPLICIT NONE

      CHARACTER*16   NOMTE
      INTEGER        NFH,NFE,SINGU,DDLC,NNOM,DDLS,NDDL,DDLM
      INTEGER        NFISS,CONTAC

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 19/01/2011   AUTEUR MASSIN P.MASSIN 
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
C RESPONSABLE GENIAUT S.GENIAUT
C
C          BUT : INITIALISER LES DIMENSIONS DES DDL DANS UN TE
C                POUR LES ELEMENTS X-FEM
C
C
C IN   NOMTE  : NOM DU TYPE ELEMENT
C OUT  NFH    : NOMBRE DE FONCTIONS HEAVISIDES
C OUT  NFE    : NOMBRE DE FONCTIONS SINGULI�RES D'ENRICHISSEMENT
C OUT  SINGU  : 1 SI ELEMENT SINGULIER, 0 SINON
C OUT  DDLC   : NOMBRE DE DDL DE CONTACT (PAR NOEUD)
C OUT  NNOM   : NB DE NOEUDS MILIEU SERVANT � PORTER DES DDL DE CONTACT
C OUT  DDLS   : NOMBRE DE DDL (DEPL+CONTACT) � CHAQUE NOEUD SOMMET
C OUT  NDDL   : NOMBRE DE DDL TOTAL DE L'�L�MENT
C OUT  DDLM   : NOMBRE DE DDL A CHAQUE NOEUD MILIEU
C OUT  NFISS  : NOMBRE DE FISSURES
C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16             ZK16
      CHARACTER*24                      ZK24
      CHARACTER*32                               ZK32
      CHARACTER*80                                        ZK80
      COMMON  /KVARJE/ ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      INTEGER       NDIM,NNO,IBID,LXLGUT,IER,NNOS
      INTEGER       DDLD,IADZI,IAZK24,JTAB(7),IRET
      CHARACTER*8   ELREFP,ENR,LAG,TYPMA
      LOGICAL       ISMALI
C
C ----------------------------------------------------------------------
C
      CALL ELREF1(ELREFP)
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,IBID,IBID,IBID,IBID,IBID)
C
C --- INITIALISATIONS
C
      NFH   = 0
      NFE   = 0
      SINGU = 0
      DDLC  = 0
      DDLM  = 0
      NNOM  = 0
      NFISS = 1
      CONTAC= 0
C
      CALL TEATTR (NOMTE,'S','XFEM',ENR,IER)
      CALL TEATTR (NOMTE,'C','XLAG',LAG,IER)
C
C --- DDL ENRICHISSEMENT : HEAVYSIDE, ENRICHIS (FOND)
C
      IF (ENR(1:2).EQ.'XH') THEN
        NFH = 1
        IF (ENR.EQ.'XH2') NFH = 2
        IF (ENR.EQ.'XH3') NFH = 3
        IF (ENR.EQ.'XH4') NFH = 4
C       NOMBRE DE FISSURES
        CALL TECACH('NOO','PLST',7,JTAB,IRET)
        NFISS = JTAB(7)
      ENDIF
C
      IF (ENR(1:2).EQ.'XT'.OR.ENR(3:3).EQ.'T') THEN
        NFE   = 4
        SINGU = 1
      ENDIF
C
C --- DDL DE CONTACT
C
      IF (ENR(1:3).EQ.'XHC'.OR.ENR(1:3).EQ.'XTC'
     &         .OR.ENR(1:4).EQ.'XHTC') DDLC = NDIM
C
C --- NOMBRE DE DDL DE DEPLACEMENT
C
      DDLD=NDIM*(1+NFH+NFE)
C
C --- NOMBRE DE DDL AUX NOEUDS SOMMETS
C
      DDLS=DDLD+DDLC
C
C --- NOMBRE DE DDL AUX NOEUDS MILIEUX
C
      CALL TECAEL(IADZI,IAZK24)
      TYPMA=ZK24(IAZK24-1+3+ZI(IADZI-1+2)+3)
C
      IF (IER.EQ.0) THEN
        IF (LAG.EQ.'ARETE') THEN
          DDLM=DDLC
          CONTAC=2
        ELSEIF (LAG(1:5).EQ.'NOEUD') THEN
          IF (ISMALI(TYPMA)) THEN
            CONTAC=1
            DDLM=0
          ELSE
            IF (LAG.EQ.'NOEUD2') THEN
              CONTAC=4
              DDLM=DDLD+DDLC
            ELSE
              CONTAC=3
              DDLM=DDLD
            ENDIF
          ENDIF
        ENDIF
      ELSE
        IF(.NOT.ISMALI(ELREFP)) DDLM=DDLD
      ENDIF
C
C --- NB DE NOEUDS MILIEUX
C
      IF (LAG.EQ.'ARETE') THEN
        IF (NDIM .EQ. 3) THEN
          NNOM=3*(NNO/2)
        ELSE
          NNOM=NNOS
        ENDIF
      ELSE
        NNOM=NNO-NNOS
      ENDIF
C
C --- NOMBRE DE DDLS (DEPL+CONTACT) SUR L'ELEMENT
C
      NDDL=(NNOS*DDLS)+(NNOM*DDLM)
C
      END
