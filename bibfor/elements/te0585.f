      SUBROUTINE TE0585(OPTION,NOMTE)
      IMPLICIT NONE
      CHARACTER*16 OPTION,NOMTE
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 22/05/2012   AUTEUR DELMAS J.DELMAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C
C    - FONCTION REALISEE:  CALCUL DES OPTIONS FORC_NODA ET
C      EFGE_ELNO POUR U

C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................

      INTEGER NBRDDM
      PARAMETER (NBRDDM=156)
      REAL*8 B(4,NBRDDM),F(NBRDDM)
      REAL*8 VIN(NBRDDM),VOUT(NBRDDM),MAT(NBRDDM,4)
      REAL*8 VTEMP(NBRDDM),PASS(NBRDDM,NBRDDM)

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C     CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      INTEGER NDIM,NNOS,NNO,JCOOPG,IDFDK,JDFD2,JGANO
      INTEGER NPG,IPOIDS,IVF
      INTEGER M,NBRDDL

      CALL ELREF5(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,JCOOPG,IVF,IDFDK,
     &            JDFD2,JGANO)

      M = 3
      IF (NOMTE.EQ.'MET6SEG3') M = 6

C     FORMULE GENERALE

      NBRDDL = NNO* (6+3+6* (M-1))

C     VERIFS PRAGMATIQUES

      IF (NBRDDL.GT.NBRDDM) THEN
        CALL U2MESS('F','ELEMENTS4_40')
      END IF
      IF (NOMTE.EQ.'MET3SEG3') THEN
        IF (NBRDDL.NE.63) THEN
          CALL U2MESS('F','ELEMENTS4_41')
        END IF
      ELSE IF (NOMTE.EQ.'MET6SEG3') THEN
        IF (NBRDDL.NE.117) THEN
          CALL U2MESS('F','ELEMENTS4_41')
        END IF
      ELSE IF (NOMTE.EQ.'MET3SEG4') THEN
        IF (NBRDDL.NE.84) THEN
          CALL U2MESS('F','ELEMENTS4_41')
        END IF
      ELSE
        CALL U2MESS('F','ELEMENTS4_42')
      END IF

      CALL TUFORC(OPTION,NOMTE,NBRDDL,B,F,VIN,VOUT,MAT,PASS,VTEMP)
      END
