      SUBROUTINE TE0577(OPTION,NOMTE)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 04/04/2006   AUTEUR CIBHHLV L.VIVAN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C ======================================================================

      IMPLICIT NONE

      CHARACTER*16 OPTION,NOMTE

C ......................................................................

C    - FONCTION REALISEE: CALCUL DES VECTEURS ELEMENTAIRES
C     TERMES PROVENANT DE LA DERIVATION DU PREMIER MEMBRE DE L'EQUATION.

C          OPTION : 'CHAR_DLAG_MECAST'

C    - ELEMENTS ISOPARAMETRIQUES 2D

C    - SI LE CHAMP THETA EST NUL SUR TOUS LES NOEUDS, SEULE LA
C      CONTRIBUTION EN K * DLAG(T) * IDENTITE COMPTE.
C      EN EFFET, DANS CE CAS LA DIVERGENCE ET LE GRADIENT DE THETA SONT
C      NULS SUR TOUS LES POINTS DE GAUSS DE L'ELEMENT. DU COUP, LA
C      CONTRIBUTION DES AUTRES TERMES AU SECOND MEMBRE EST NULLE.

C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................
      REAL*8 R
      REAL*8 POIDS,DFDX(9),DFDY(9)
      REAL*8 COEFEQ(5)
      REAL*8 GRADTH(3,3),DIVTHT,THETAR
      REAL*8 EPSI,R8PREM
      REAL*8 DLAGTG,GRADU(3,3),UR
      REAL*8 LAMBDA(3),LAGUGT(4),KDLTID
      REAL*8 INSTAN
      REAL*8 TEMPER
      REAL*8 SIXX,SIYY,SIZZ,SIXY
      REAL*8 R8AUX

      INTEGER IGEOM,IMATE,IVECTU
      INTEGER IPOIDS,IVF,IDFDE
      INTEGER NNO,NPG,NNOS,JGANO,NDIM
      INTEGER KP,I,K,IDEB,IFIN,IAUX
      INTEGER ITEMPS,IDEPL,ICONTR,ITEMPE,IDLAGT
      INTEGER ITHETA

      LOGICAL DPAXI
      LOGICAL THTNUL,DLTNUL
      LOGICAL AXI,LTEATT

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

C====
C 1. INITIALISATIONS ET CONTROLE DE LA NULLITE DE THETA
C====

      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)
      EPSI = R8PREM()
      CALL JEVECH('PVECTTH','L',ITHETA)
      IDEB = ITHETA
      IFIN = ITHETA + 2*NNO - 1
      THTNUL = .TRUE.
      DO 10,I = IDEB,IFIN
        IF (ABS(ZR(I)).GT.EPSI) THEN
          THTNUL = .FALSE.
        END IF
   10 CONTINUE

      CALL JEVECH('PDLAGTE','L',IDLAGT)

      IDEB = IDLAGT
      IFIN = IDLAGT + NNO - 1
      DLTNUL = .TRUE.
      DO 20,I = IDEB,IFIN
        IF (ABS(ZR(I)).GT.EPSI) THEN
          DLTNUL = .FALSE.
        END IF
   20 CONTINUE

C====
C 2. CALCUL
C====

C 2.1. ==> FIN DES INITIALISATIONS

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PTEMPSR','L',ITEMPS)
      CALL JEVECH('PTEMPER','L',ITEMPE)
      IF (.NOT.THTNUL) THEN
        CALL JEVECH('PDEPLAR','L',IDEPL)
        CALL JEVECH('PCONTRR','L',ICONTR)
      END IF

      CALL JEVECH('PVECTUR','E',IVECTU)

      IDEB = IVECTU
      IFIN = IVECTU + 2*NNO - 1
      DO 30,I = IDEB,IFIN
        ZR(I) = 0.D0
   30 CONTINUE

      IF (LTEATT(' ','AXIS','OUI')) THEN
        AXI = .TRUE.
        DPAXI = .TRUE.
      ELSE
        AXI = .FALSE.
        IF (NOMTE(3:4).EQ.'DP') THEN
          DPAXI = .TRUE.
        ELSE IF (NOMTE(3:4).EQ.'CP') THEN
          DPAXI = .FALSE.
        ELSE
          CALL UTMESS('F','TE0577','LA MODELISATION : '//NOMTE//
     +                'N''EST PAS TRAITEE.')
        END IF
      END IF

C     INSTAN : L'INSTANT COURANT

      INSTAN = ZR(ITEMPS)

C 2.2. ==> BOUCLE SUR LES POINTS DE GAUSS

      DO 100,KP = 1,NPG

        K = (KP-1)*NNO
        CALL DFDM2D(NNO,KP,IPOIDS,IDFDE,ZR(IGEOM),DFDX,DFDY,POIDS)

C 2.2.1. ==> CALCUL DES GRADIENTS DU DEPLACEMENT,
C            DE LA DERIVEE LAGRANGIENNE DE T,
C            DU GRADIENT ET DE LA DIVERGENCE DE THETA AU POINT DE GAUSS
C   GRADTH(I,K) = D THETA I / D X K
C   DIVTHT = D THETA X / DX  +  D THETA Y / DY
C          = D THETA R / DR  +  D THETA Z / DZ  +  THETA R / R
C   SI THETA EST NUL, IL SUFFIT DE CALCULER LA TEMPERATURE ET SA DERIVEE

        TEMPER = 0.D0
        DLAGTG = 0.D0

        IF (THTNUL) THEN

          DO 40,I = 1,NNO
            R8AUX = ZR(IVF+K+I-1)
            TEMPER = TEMPER + ZR(ITEMPE+I-1)*R8AUX
            DLAGTG = DLAGTG + ZR(IDLAGT+I-1)*R8AUX
   40     CONTINUE

        ELSE

          GRADU(1,1) = 0.D0
          GRADU(1,2) = 0.D0
          GRADU(2,1) = 0.D0
          GRADU(2,2) = 0.D0
          GRADTH(1,1) = 0.D0
          GRADTH(1,2) = 0.D0
          GRADTH(2,1) = 0.D0
          GRADTH(2,2) = 0.D0
          DO 50,I = 1,NNO
            R8AUX = ZR(IVF+K+I-1)
            TEMPER = TEMPER + ZR(ITEMPE+I-1)*R8AUX
            DLAGTG = DLAGTG + ZR(IDLAGT+I-1)*R8AUX
            GRADU(1,1) = GRADU(1,1) + ZR(IDEPL+2*I-2)*DFDX(I)
            GRADU(1,2) = GRADU(1,2) + ZR(IDEPL+2*I-2)*DFDY(I)
            GRADU(2,1) = GRADU(2,1) + ZR(IDEPL+2*I-1)*DFDX(I)
            GRADU(2,2) = GRADU(2,2) + ZR(IDEPL+2*I-1)*DFDY(I)
            GRADTH(1,1) = GRADTH(1,1) + ZR(ITHETA+2*I-2)*DFDX(I)
            GRADTH(1,2) = GRADTH(1,2) + ZR(ITHETA+2*I-2)*DFDY(I)
            GRADTH(2,1) = GRADTH(2,1) + ZR(ITHETA+2*I-1)*DFDX(I)
            GRADTH(2,2) = GRADTH(2,2) + ZR(ITHETA+2*I-1)*DFDY(I)
   50     CONTINUE
          DIVTHT = GRADTH(1,1) + GRADTH(2,2)

        END IF

C 2.2.2. ==>
C EN 2D-AXI, MODIFICATION DU POIDS ET TERME
C COMPLEMENTAIRE SUR LES GRADIENTS EN UR/R
C LES POINTS DE GAUSS ETANT TOUJOURS STRICTEMENT INTERIEURS
C A L'ELEMENT, R NE PEUT PAS ETRE NUL, DONC ON PEUT DIVISER PAR R.

        IF (AXI) THEN
          R = 0.D0
          IF (THTNUL) THEN
            DO 60,I = 1,NNO
              R = R + ZR(IGEOM+2*I-2)*ZR(IVF+K+I-1)
   60       CONTINUE
          ELSE
            THETAR = 0.D0
            UR = 0.D0
            DO 70,I = 1,NNO
              R8AUX = ZR(IVF+K+I-1)
              R = R + ZR(IGEOM+2*I-2)*R8AUX
              THETAR = THETAR + ZR(ITHETA+2*I-2)*R8AUX
              UR = UR + ZR(IDEPL+2*I-2)*R8AUX
   70       CONTINUE
            GRADU(3,3) = UR/R
            GRADTH(3,3) = THETAR/R
            DIVTHT = DIVTHT + GRADTH(3,3)
          END IF
          POIDS = POIDS*R
        END IF

C 2.2.3. ==> CALCUL DES TENSEURS
C     0.5 * ( MATRICE DE HOOKE )
C     * ( T(GRAD(U),GRAD(THETA)) + T(GRAD(U),GRAD(THETA))T )
C                ET
C     K * DLAGTE * IDENTITE

        CALL DEEUT1(LAMBDA,LAGUGT,KDLTID,ZI(IMATE),INSTAN,R,THTNUL,AXI,
     +              DPAXI,TEMPER,DLAGTG,DLTNUL,GRADU,GRADTH)

C 2.2.4. ==> CALCUL DES COEFFICIENTS DU SECOND MEMBRE

C      COEFEQ(1) = FACTEUR DE DVX/DX POUR LE CALCUL DE DLAGU X
C      COEFEQ(2) = .......... DVX/DY ................. DLAGU X
C      COEFEQ(3) = .......... DVY/DX ................. DLAGU Y
C      COEFEQ(4) = .......... DVY/DY ................. DLAGU Y
C      EN AXI :
C      COEFEQ(5) = ..........  VR/R  ................. DLAGU R

C 2.2.4.1. ==> TERMES DE L'INTEGRALE :
C            0.5 * ( MATRICE DE HOOKE )
C  * ( T(GRAD(U),GRAD(THETA)) + T(GRAD(U),GRAD(THETA))T ) :: GRAD_SYM(V)

C            REMARQUE : SI THETA EST NUL, LAGUGT EST RENVOYE A NUL
C                       PARTOUT. IL FAUT DONC TOUJOURS METTRE CES
C                       INSTRUCTIONS POUR INITIALISER LES COEFFICIENTS
C                       DE L'EQUATION.

        COEFEQ(1) = LAGUGT(1)
        COEFEQ(2) = LAGUGT(4)
        COEFEQ(3) = LAGUGT(4)
        COEFEQ(4) = LAGUGT(2)
        IF (AXI) THEN
          COEFEQ(5) = LAGUGT(3)
        ELSE
          COEFEQ(5) = 0.D0
        END IF

C 2.2.4.2. ==> TERMES DE L'INTEGRALE :
C            K * DLAGTE * IDENTITE :: GRAD_SYM(V)

        IF (.NOT.DLTNUL) THEN

          COEFEQ(1) = COEFEQ(1) - KDLTID
          COEFEQ(4) = COEFEQ(4) - KDLTID
          IF (AXI) THEN
            COEFEQ(5) = COEFEQ(5) - KDLTID
          END IF

        END IF

C 2.2.4.3. ==> LE TENSEUR DES CONTRAINTES
C          VARIABLE ! PLAN ! AXIS
C            SIXX   !  XX  !  RR
C            SIYY   !  YY  !  ZZ
C            SIZZ   !  ZZ  !  THETATHETA
C            SIXY   !  XY  !  RZ

        IF (.NOT.THTNUL) THEN

          I = ICONTR + 4* (KP-1)
          SIXX = ZR(I)
          SIYY = ZR(I+1)
          SIZZ = ZR(I+2)
          SIXY = ZR(I+3)

        END IF

C 2.2.4.4. ==> TERMES DE L'INTEGRALE :
C            SIGMA(U) :: T (GRAD_SYM(V),GRAD(THETA))
C     L'OPERATEUR T EST EGAL FORMELLEMENT AU PRODUIT MATRICIEL
C     RAPPEL :  GRADTH(I,K) = D THETA I / D X K

        IF (.NOT.THTNUL) THEN

          COEFEQ(1) = COEFEQ(1) + SIXX*GRADTH(1,1) + SIXY*GRADTH(1,2)
          COEFEQ(2) = COEFEQ(2) + SIXX*GRADTH(2,1) + SIXY*GRADTH(2,2)

          COEFEQ(3) = COEFEQ(3) + SIXY*GRADTH(1,1) + SIYY*GRADTH(1,2)
          COEFEQ(4) = COEFEQ(4) + SIXY*GRADTH(2,1) + SIYY*GRADTH(2,2)

          IF (AXI) THEN
            COEFEQ(5) = COEFEQ(5) + SIZZ*GRADTH(3,3)
          END IF

        END IF

C 2.2.4.5. ==> TERMES DE L'INTEGRALE :
C            - ( SIGMA(U) :: GRAD_SYM(V) ) DIV(THETA)

        IF (.NOT.THTNUL) THEN

          COEFEQ(1) = COEFEQ(1) - SIXX*DIVTHT
          COEFEQ(2) = COEFEQ(2) - SIXY*DIVTHT

          COEFEQ(3) = COEFEQ(3) - SIXY*DIVTHT
          COEFEQ(4) = COEFEQ(4) - SIYY*DIVTHT

          IF (AXI) THEN
            COEFEQ(5) = COEFEQ(5) - SIZZ*DIVTHT
          END IF

        END IF

C 2.2.5. ==> CUMUL DANS LE SECOND MEMBRE

        DO 80,I = 1,NNO

          IAUX = IVECTU + 2*I - 2

          ZR(IAUX) = ZR(IAUX) + POIDS* (COEFEQ(1)*DFDX(I)+
     +               COEFEQ(2)*DFDY(I))

          ZR(IAUX+1) = ZR(IAUX+1) + POIDS*
     +                 (COEFEQ(3)*DFDX(I)+COEFEQ(4)*DFDY(I))

   80   CONTINUE

        IF (AXI) THEN

          R8AUX = POIDS*COEFEQ(5)/R

          DO 90,I = 1,NNO

            IAUX = IVECTU + 2*I - 2
            ZR(IAUX) = ZR(IAUX) + R8AUX*ZR(IVF+K+I-1)

   90     CONTINUE

        END IF

  100 CONTINUE

      END
