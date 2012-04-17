      SUBROUTINE PRELOG(NDIM,NNO,AXI,GRAND,VFF,GEOMI,G,IW,IDFDE,
     &                  DEPLM,DEPLT,LGPG,VIM,GN,LAMB,LOGL,
     &                  R,W,DFF,FM,FP,EPSML,DEPS,TN,RESI)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 07/11/2011   AUTEUR PROIX J-M.PROIX 
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
C TOLE CRP_21
C ----------------------------------------------------------------------
C  BUT:  CALCUL DES GRANDES DEFORMATIONS  LOG 2D (D_PLAN ET AXI) ET 3D
C     SUIVANT ARTICLE MIEHE APEL LAMBRECHT CMAME 2002
C ----------------------------------------------------------------------
C IN  NDIM    : DIMENSION DE L'ESPACE
C IN  NNO     : NOMBRE DE NOEUDS DE L'ELEMENT
C IN  AXI     : .TRUE. SI AXIS
C IN  GRAND   : .TRUE.
C IN  VFF     : VALEUR  DES FONCTIONS DE FORME AU POINT G
C IN  GEOMI   : COORDONNEES DES NOEUDS (CONFIGURATION INITIALE)
C IN  G       : NUMERO DU POINTS DE GAUSS
C IN  IW      : PTR. POIDS DES POINTS DE GAUSS
C IN  IDFDE   : PTR. DERIVEE DES FONCTIONS DE FORME ELEMENT DE REF.
C IN  DEPLM   : DEPLACEMENT EN T-
C IN  DEPLT   : DEPLACEMENT EN T+
C IN  LGPG    : DIMENSION DU VECTEUR DES VAR. INTERNES POUR 1 PT GAUSS
C IN  VIM     : VARIABLES INTERNES EN T-
C OUT GN      : TERMES UTILES AU CALCUL DE TL DANS POSLOG
C OUT LAMB    : TERMES UTILES AU CALCUL DE TL DANS POSLOG
C OUT LOGL    : TERMES UTILES AU CALCUL DE TL DANS POSLOG
C OUT R       : RAYON DU POINT DE GAUSS COURANT (EN AXI)
C OUT W       : POIDS DU POINT DE GAUSS COURANT (Y COMPRIS R EN AXI)
C OUT DFF     : DERIVEE DES FONCTIONS DE FORME (POINT DE GAUSS COURANT)
C OUT FM      : GRADIENT TRANSFORMATION EN T-
C OUT FP      : GRADIENT TRANSFORMATION EN T+
C OUT EPSML   : DEFORAMTIONS LOGARITHMIQUES EN T-
C OUT DEPS    : ACCROISSEEMENT DE DEFORMATIONS LOGARITHMIQUES
C OUT TN      : CONTRAINTES ASSOCIEES AUX DEF. LOGARITHMIQUES EN T-
C IN  RESI    : .TRUE. SI FULL_MECA/RAPH_MECA .FALSE. SI RIGI_MECA_TANG
C
      IMPLICIT NONE
      INTEGER I,NDIM,NNO,G,IW,IDFDE,LGPG,IVTN
      REAL*8 VFF(NNO),DEPLM(NDIM*NNO),DFF(NNO,*),GEOMI(*),W,VIM(LGPG)
      REAL*8 FM(3,3),FP(3,3),DEPLT(NDIM*NNO),EPSML(6),EPSPL(6)
      REAL*8 R,TBID(6),TN(6),DEPS(6),GN(3,3),LAMB(3),LOGL(3)
      LOGICAL GRAND, AXI, RESI
C ---------------------------------------------------------------------

      IF (NDIM.EQ.3) AXI=.FALSE.
      CALL DFDMIP(NDIM,NNO,AXI,GEOMI,G,IW,VFF,IDFDE,R,W,DFF)

      CALL NMEPSI(NDIM,NNO,AXI,GRAND,VFF,R,DFF,DEPLM,FM,TBID)
      CALL NMEPSI(NDIM,NNO,AXI,GRAND,VFF,R,DFF,DEPLT,FP,TBID)
      
      CALL DEFLOG(NDIM,FM,EPSML,GN,LAMB,LOGL)
      
      IF (RESI) THEN
         CALL DEFLOG(NDIM,FP,EPSPL,GN,LAMB,LOGL)
         DO 35 I=1,6
            DEPS(I)=EPSPL(I)-EPSML(I)
 35      CONTINUE
      ELSE
         DO 34 I=1,6
            DEPS(I)=0.D0
 34      CONTINUE
      ENDIF
      
C     --------------------------------
C     CALCUL DES CONTRAINTES TN INSTANT PRECEDENT
C     pour gagner du temps : on stocke TN comme variable interne
C     --------------------------------
      IVTN=LGPG-6+1
      CALL R8INIR(6,0.D0,TN,1)
      CALL DCOPY(2*NDIM,VIM(IVTN),1,TN,1)
      
      END
