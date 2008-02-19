      SUBROUTINE TE0137(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 19/02/2008   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT NONE
      CHARACTER*16 OPTION,NOMTE
C ......................................................................
C    - FONCTION REALISEE:  CALCUL DES VECTEURS ELEMENTAIRES
C                          OPTION : 'RESI_THER_COEF_F'
C                          OPTION : 'RESI_THER_RAYO_F'
C                          ELEMENTS 2D
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................

      INTEGER    NBRES
      PARAMETER (NBRES=3)
      CHARACTER*8 NOMPAR(NBRES),  ELREFE
      REAL*8 VALPAR(NBRES),POIDS,R,Z,NX,NY,TPG,THETA
      REAL*8 COENP1,SIGMA,EPSIL,TZ0,R8T0
      REAL*8 COORSE(18),VECTT(9)
      INTEGER NNO,NNOS,NDIM,KP,NPG,IPOIDS,IVF,IDFDE,JGANO,IGEOM
      INTEGER ITEMPS,IVERES,I,J,L,LI,IECH,IRAY,ITEMP,ICODE,IER
      INTEGER NNOP2,C(6,9),ISE,NSE
      LOGICAL LTEATT, LAXI

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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
C
      CALL ELREF1(ELREFE)
      IF (NOMTE(5:7).EQ.'SL3') ELREFE='SE2'
C
      CALL ELREF4(ELREFE,'RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,
     +            IVF,IDFDE,JGANO)
C
      TZ0 = R8T0()

      LAXI = .FALSE.
      IF (LTEATT(' ','AXIS','OUI')) LAXI = .TRUE.

      IF (OPTION(11:14).EQ.'COEF') THEN
        CALL JEVECH('PCOEFHF','L',IECH)
      ELSE IF (OPTION(11:14).EQ.'RAYO') THEN
        CALL JEVECH('PRAYONF','L',IRAY)
      END IF
      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PTEMPSR','L',ITEMPS)
      CALL JEVECH('PTEMPEI','L',ITEMP)
      CALL JEVECH('PRESIDU','E',IVERES)

      THETA = ZR(ITEMPS+2)

      CALL CONNEC(NOMTE,NSE,NNOP2,C)

      DO 10 I = 1,NNOP2
        VECTT(I) = 0.D0
   10 CONTINUE

C BOUCLE SUR LES SOUS-ELEMENTS

      DO 80 ISE = 1,NSE

        DO 30 I = 1,NNO
          DO 20 J = 1,2
            COORSE(2* (I-1)+J) = ZR(IGEOM-1+2* (C(ISE,I)-1)+J)
   20     CONTINUE
   30   CONTINUE

        DO 70 KP = 1,NPG
          CALL VFF2DN(NDIM,NNO,KP,IPOIDS,IDFDE,COORSE,NX,NY,POIDS)
          R = 0.D0
          Z = 0.D0
          TPG = 0.D0
          DO 40 I = 1,NNO
            L = (KP-1)*NNO + I
            R = R + COORSE(2* (I-1)+1)*ZR(IVF+L-1)
            Z = Z + COORSE(2* (I-1)+2)*ZR(IVF+L-1)
            TPG = TPG + ZR(ITEMP-1+C(ISE,I))*ZR(IVF+L-1)
   40     CONTINUE
          IF (LAXI) POIDS = POIDS*R
          VALPAR(1) = R
          NOMPAR(1) = 'X'
          VALPAR(2) = Z
          NOMPAR(2) = 'Y'
          NOMPAR(3) = 'INST'
          VALPAR(3) = ZR(ITEMPS)
          IF (OPTION(11:14).EQ.'COEF') THEN
            CALL FOINTE('A',ZK8(IECH),3,NOMPAR,VALPAR,COENP1,ICODE)
            IF (ICODE.NE.0) THEN
              CALL U2MESS('F','ELEMENTS3_21')
            END IF
            DO 50 I = 1,NNO
              LI = IVF + (KP-1)*NNO + I - 1
              VECTT(C(ISE,I)) = VECTT(C(ISE,I)) +
     &                          POIDS*ZR(LI)*THETA*COENP1*TPG
   50       CONTINUE
          ELSE IF (OPTION(11:14).EQ.'RAYO') THEN
            CALL FOINTE('A',ZK8(IRAY),4,NOMPAR,VALPAR,SIGMA,IER)
            IF (IER.NE.0) THEN
              CALL U2MESS('F','ELEMENTS3_21')
            END IF
            CALL FOINTE('A',ZK8(IRAY+1),4,NOMPAR,VALPAR,EPSIL,IER)
            IF (IER.NE.0) THEN
              CALL U2MESS('F','ELEMENTS3_21')
            END IF
            DO 60 I = 1,NNO
              LI = IVF + (KP-1)*NNO + I - 1
              VECTT(C(ISE,I)) = VECTT(C(ISE,I)) +
     &                          POIDS*ZR(LI)*THETA*SIGMA*EPSIL*
     &                          (TPG+TZ0)**4
   60       CONTINUE
          END IF

   70   CONTINUE
   80 CONTINUE

      DO 90 I = 1,NNOP2
        ZR(IVERES-1+I) = VECTT(I)
   90 CONTINUE

      END
