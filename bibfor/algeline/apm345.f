      SUBROUTINE APM345(NBTETC,TYPCON,RAYONC,CENTRC,NK,K24RC,PIVOT2,
     &                  LTEST,TYPCHA,LRAIDE,LMASSE,LDYNAM,SOLVEU,LAMOR,
     &                  LC,IMPR,IFAPM)
      IMPLICIT NONE
      INTEGER       NBTETC,NK,PIVOT2,LRAIDE,LMASSE,LDYNAM,LAMOR,
     &              IFAPM
      REAL*8        RAYONC
      COMPLEX*16    CENTRC
      LOGICAL       LTEST,LC
      CHARACTER*3   IMPR           
      CHARACTER*8   TYPCON,TYPCHA
      CHARACTER*19  SOLVEU         
      CHARACTER*24  K24RC
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 10/10/2011   AUTEUR BOITEAU O.BOITEAU 
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
C     ------------------------------------------------------------------
C     STEPS 3/4/5 OF THE ARGUMENT PRINCIPAL METHOD THAT COUNT THE 
C     EIGENVALUES WITHIN A GIVEN SHAPE OF THE COMPLEX PLANE
C     ------------------------------------------------------------------
C IN NBTETC : IN : NUMBER OF CHECKED POINTS THAT DISCRETIZE THE SHAPE
C IN TYPCON : K8 : TYPE OF SHAPE
C IN RAYONC : R8 : RADIUS OF THE DISC OF THE GIVEN SHAPE
C IN CENTRC : C16: CENTRE OF THE DISC
C IN NK     : IN : SIZE OF THE EIGENVALUE PROBLEM
C IN K24RC  : K24: JEVEUX NAME OF THE COEFFICIENTS OF THE CHARACTERIS
C                  TIC POLYNOMIAL (ONLY NEEDED IF TYPCHA='ROMBOUT')
C OUT PIVOT2: IN : NUMBER OF EIGENVALUES IN THE SHAPE
C IN LTEST  : LOG: RUN OF INTERNAL TEST FOR DEBUGGING IF LTEST=.TRUE.
C IN TYPCHA : K8 : TYPE OF METHOD TO EVALUATE THE CHARAC. POLYNOME
C IN LRAIDE : IN : JEVEUX ATTRIBUT OF THE STIFFNESS MATRIX
C IN LMASSE : IN : JEVEUX ATTRIBUT OF THE MASS MATRIX
C IN LDYNAM : IN : JEVEUX ATTRIBUT OF THE DYNAMIC MATRIX
C IN SOLVEU : K19: JEVEUX SD OF THE LINEAR SOLVER
C IN LAMOR  : IN : JEVEUX ATTRIBUT OF THE DAMPING MATRIX
C IN LC     : LOG: FLAG THAT INDICATES IF THE PB IS QUADRATIC OR NOT
C IN IMPR/IFAPM: IN/K3 : PRINT PARAMETERS FOR DEBBUGING
C     ------------------------------------------------------------------
C RESPONSABLE BOITEAU O.BOITEAU

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
      CHARACTER*16              ZK16
      CHARACTER*24                        ZK24
      CHARACTER*32                                  ZK32
      CHARACTER*80                                            ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

      INTEGER     I,JCONT,JTHETA,IFM,NIV
      REAL*8      RAUX1,PI,R8PI,RAUX2,RAUXX,RAUXY,RAUXM,THETA,THETAO,
     &            THETAP,THETAM,RADDEG,R8PREM,PREC2,PIPREC

C   --- MISCELLANEOUS ---
      CALL JEMARQ()
      CALL INFNIV(IFM,NIV)
      PI=R8PI()
      RADDEG=180.D0/PI

C   --- VERBOSE MODE FOR APM STEPS ---
C      NIV=2
C    --- PERTURBATION TO BE ADDED TO THE EVALUATION OF THE ARGUMENT ---
C    --- FOR NOT MISSING A LOOP WHEN ARG IS JUST UNDER 2*PI RADIENT ---
      PREC2=1.D-3
      PIPREC=2.D0*PI-PREC2
              
C   --- STEP 3: DISCRETISATION OF THE SHAPE ---
      CALL WKVECT('&&APM345.CONTOUR.DIS','V V C',NBTETC,JCONT)
      IF (TYPCON(1:6).EQ.'CERCLE') THEN
        CALL ASSERT(NBTETC.GT.1)
        RAUX1=2.D0*PI/(NBTETC-1)
        DO 210 I=1,NBTETC
          RAUX2=(I-1)*RAUX1
          RAUXX=RAYONC*COS(RAUX2)
          RAUXY=RAYONC*SIN(RAUX2)
          ZC(JCONT+I-1)=CENTRC+DCMPLX(RAUXX,RAUXY)
  210   CONTINUE
      ENDIF

C   --- STEP 4: EVALUATING THE ARGUMENT VALUE OF P(CONTOUR) ---
      CALL WKVECT('&&APM345.CONTOUR.THETA','V V R',NBTETC,JTHETA)
      DO 251 I=1,NBTETC
        CALL APCHAR(TYPCHA,K24RC,NK,ZC(JCONT+I-1),THETA,LRAIDE,LMASSE,
     &              LDYNAM,SOLVEU,LAMOR,LC,IMPR,IFAPM,I)
        ZR(JTHETA+I-1)=THETA
  251 CONTINUE
      CALL JEDETR('&&APM345.CONTOUR.DIS')

C   --- STEP 5: COUNTING THE DIFFERENCE BETWEEN ANGLE         ---
      IF (LTEST.OR.(NIV.GE.2)) THEN
        WRITE(IFM,*)'DISPLAY I/ARG(P(LAMBDA_I))/NB_EIGENVALUE_I'
        WRITE(IFM,*)'------------------------------------------'
      ENDIF
      PIVOT2=0
      THETAO=ZR(JTHETA)
      IF (LTEST.OR.(NIV.GE.2))
     &  WRITE(IFM,*)'STEP 5: ',1,THETAO*RADDEG,PIVOT2
      DO 260 I=2,NBTETC
        THETA=ZR(JTHETA+I-1)
C   --- CORRECTION IF THETA GOES NEAR 2*PI TO NOT MISS A LOOP ---
        IF (THETA.GT.PIPREC) THETA=PREC2

C   --- HEURISTIC BASED ON THE WORK OF O.BERTRAND (PHD INRIA) ---
C   --- WE ADD ONLY THE CONDITION I>2                         ---
        THETAP=THETAO+PI
        THETAM=THETAO-PI
        IF ((THETAO.LT.PI).AND.((THETA.GT.THETAP).OR.
     &       ABS(THETA).LT.PREC2).AND.(I.GT.2)) THEN
          PIVOT2=PIVOT2-1
        ELSE IF ((THETAO.GT.PI).AND.((THETA.LT.THETAM).OR.
     &            ABS(THETA).LT.PREC2)) THEN
          PIVOT2=PIVOT2+1
        ENDIF
        THETAO=THETA

        IF (LTEST.OR.(NIV.GE.2))
     &    WRITE(IFM,*)'STEP 5: ',I,THETA*RADDEG,PIVOT2
  260 CONTINUE
      CALL JEDETR('&&APM345.CONTOUR.THETA')

      CALL JEDEMA()

      END
