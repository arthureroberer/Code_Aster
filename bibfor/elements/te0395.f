      SUBROUTINE TE0395(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 14/12/2010   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2010  EDF R&D                  WWW.CODE-ASTER.ORG
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
C ======================================================================
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*16 OPTION,NOMTE
C ----------------------------------------------------------------------
C FONCTION REALISEE:  CALCUL DE L'OPTION FORC_NODA ELEMENT HEXAS8

C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
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
      REAL*8 BSIGM(3,8),GEO(24),SIGTMP(6),FTEMP(24)
      INTEGER JGANO,NNO,KP,K,NPG1,I,J,IVECTU,NDIM,NNOS
      INTEGER IPOIDS,IVF,IDFDE,IGEOM,ICONTM,IMATE,IDEPL
      INTEGER ICOMP,II,IRETC,IRETD
C DEB ------------------------------------------------------------------

C ---- CARACTERISTIQUES DU TYPE D'ELEMENT :
C ---- GEOMETRIE ET INTEGRATION
C      ------------------------
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG1,IPOIDS,IVF,IDFDE,JGANO)

C ---- PARAMETRES EN ENTREE
C ----     COORDONNEES DES CONNECTIVITES
      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      DO 10 I = 1,NDIM*NNO
        GEO(I) = ZR(IGEOM-1+I)
   10 CONTINUE

C ---- PARAMETRES EN SORTIE
C      --------------------
C ----     VECTEUR DES FORCES INTERNES (BT*SIGMA)
      CALL JEVECH('PVECTUR','E',IVECTU)

C ---- CALCUL DE FORC_NODA
      CALL TECACH('ONN','PCOMPOR',1,ICOMP,IRETC)

      IF (OPTION.EQ.'FORC_NODA') THEN
C      --------------------
C         CHAMPS POUR LA REACTUALISATION DE LA GEOMETRIE
        CALL TECACH('ONN','PDEPLMR',1,IDEPL,IRETD)
        IF ((IRETD.EQ.0) .AND. (IRETC.EQ.0)) THEN
          IF (ZK16(ICOMP+2) (1:6).NE.'PETIT ') THEN
            DO 20 I = 1,NDIM*NNO
              GEO(I) = GEO(I) + ZR(IDEPL-1+I)
   20       CONTINUE
          END IF
        END IF
C ----     CONTRAINTES AUX POINTS D'INTEGRATION
        CALL JEVECH('PCONTMR','L',ICONTM)

C ---- CALCUL DU VECTEUR DES FORCES INTERNES (BT*SIGMA) :
C      --------------------------------------------------
        CALL NMASF3 (NNO,NPG1,IPOIDS,IVF,IDFDE,ZI(IMATE),GEO,
     &           ZR(IDEPL),ZR(ICONTM),ZR(IVECTU),ZK16(ICOMP))


      ELSE IF (OPTION.EQ.'REFE_FORC_NODA') THEN
        CALL JEVECH('PREFCO','L',ICONTM)

C
        CALL TECACH('ONN','PDEPLMR',1,IDEPL,IRETD)

        CALL R8INIR(6*NPG1,0.D0,SIGTMP,1)
        CALL R8INIR(3*NNO,0.D0,FTEMP,1)
        DO 50 I = 1,6*NPG1

          SIGTMP(I) = ZR(ICONTM)
          CALL NMASF3 (NNO,NPG1,IPOIDS,IVF,IDFDE,ZI(IMATE),GEO,
     &                ZR(IDEPL),SIGTMP, BSIGM ,ZK16(ICOMP))

          DO 40 J = 1,NNO
            II = 3*(J-1)
            DO 41 K = 1,3
            FTEMP(II+K) = FTEMP(II+K) + ABS(BSIGM(K,J))
   41       CONTINUE
   40     CONTINUE

          SIGTMP(I) = 0.D0

   50   CONTINUE

        CALL DAXPY(NDIM*NNO,1.D0/NPG1,FTEMP,1,ZR(IVECTU),1)

      END IF

C FIN ------------------------------------------------------------------
      END
