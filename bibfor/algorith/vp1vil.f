      FUNCTION VP1VIL(X)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 15/06/2004   AUTEUR MABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT NONE
      REAL*8     X,VP1VIL
C
CDEB
C---------------------------------------------------------------
C     FONCTION A(X)  :  CAS DE LA LOI DE FLUAGE AXIAL LOG 
C                           (PACHYDERME) EN 1D
C---------------------------------------------------------------
C IN  X     :R: ARGUMENT RECHERCHE LORS DE LA RESOLUTION SCALAIRE
C---------------------------------------------------------------
C     L'ETAPE LOCALE DU CALCUL VISCOPLASTIQUE (CALCUL DU TERME
C       ELEMENTAIRE DE LA MATRICE DE RIGIDITE TANGENTE) COMPORTE
C       LA RESOLUTION D'UNE EQUATION SCALAIRE NON LINEAIRE:
C
C           A(X) = 0
C
C     (DPC,TSCHEM,SIELEQ,DEUXMU,DELTAT JOUENT LE ROLE DE PARAMETRES)
C---------------------------------------------------------------
CFIN
C     COMMON POUR LES PARAMETRES DES LOIS VISCOPLASTIQUES
      COMMON / NMPAVP / DPC,SIELEQ,DEUXMU,DELTAT,TSCHEM,PREC,THETA,NITER
      REAL*8            DPC,SIELEQ,DEUXMU,DELTAT,TSCHEM,PREC,THETA,NITER
C     COMMON POUR LES PARAMETRES DES LOIS DE FLUAGE SOUS IRRADIATION
C     ZIRC_EPRI    : FLUPHI VALDRP TTAMAX
C     ZIRC_CYRA2   : FLUPHI EPSFAB TPREC  
C     VISC_IRRA_LOG: FLUPHI A      B      CTPS    ENER  
      COMMON / NMPAIR / FLUPHI,
     *                  EPSFAB,TPREC,
     *                  VALDRP,TTAMAX,
     *                  A,B,CTPS,ENER
      REAL*8            FLUPHI
      REAL*8            VALDRP,TTAMAX          
      REAL*8            EPSFAB,TPREC
      REAL*8            A,B,CTPS,ENER
C
      REAL*8 TPS,NRJACT
      REAL*8 FP1,FP2,G1,G2,G
C    
      NITER = 100
C  RECHERCHE DU TEMPS
      CALL TPSVIL(TPS,X,DPC,TSCHEM,FLUPHI,A,B,
     &            CTPS,ENER,PREC,INT(NITER))
C
C
C----CALCUL DE F1,FP1-------------------------------------------
C  
      IF ((1+(CTPS*TPS*FLUPHI)).LE.0.D0) THEN 
         CALL UTMESS('F','VP1VIL','ERREUR LOG NEGATIF OU NUL')
      ENDIF

      FP1= CTPS*FLUPHI / (1+CTPS*TPS*FLUPHI)
C       
C----CALCUL DE F2,FP2-------------------------------------------
C
      FP2= FLUPHI
C
C----CALCUL DE G1-----------------------------------------------
C
      G1 = A*EXP(-ENER/(TSCHEM+273.15D0))*X      
C
C----CALCUL DE G2-----------------------------------------------
C
      G2 = B*EXP(-ENER/(TSCHEM+273.15D0))*X
      G = FP1*G1 + FP2*G2
      G = G*THETA
      VP1VIL  = 1.5D0*DEUXMU*DELTAT*G + X - SIELEQ
C
      END
