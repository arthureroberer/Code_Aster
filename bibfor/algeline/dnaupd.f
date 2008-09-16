      SUBROUTINE DNAUPD
     &  (IDO, BMAT, N, WHICH, NEV, TOL, RESID, NCV, V, LDV,
     &   IPARAM, IPNTR, WORKD, WORKL, LWORKL, INFO, NEQACT, ALPHA)
C---------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 16/09/2008   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) LAPACK
C ======================================================================
C TOLE CRP_20
C
C     SUBROUTINE ARPACK CALCULANT LES VALEURS PROPRES DE (OP), ELLE
C     APPELLE LA ROUTINE DE TRAVAIL DNAUPD2.
C---------------------------------------------------------------------
C BEGINDOC
C
C DESCRIPTION:
C  REVERSE COMMUNICATION INTERFACE FOR THE IMPLICITLY RESTARTED ARNOLDI
C  ITERATION. THIS SUBROUTINE COMPUTES APPROXIMATIONS TO A FEW
C  EIGENPAIRS OF A LINEAR OPERATOR "OP" WITH RESPECT TO A SEMI-INNER
C  PRODUCT DEFINED BY A SYMMETRIC POSITIVE SEMI-DEFINITE REAL MATRIX B.
C  B MAY BE THE IDENTITY MATRIX.
C  NOTE: IF THE LINEAR OPERATOR "OP" IS REAL AND SYMMETRIC
C  WITH RESPECT TO THE REAL POSITIVE SEMI-DEFINITE SYMMETRIC MATRIX B,
C  I.E. B*OP = (OP')*B, THEN SUBROUTINE SSAUPD SHOULD BE USED INSTEAD.
C
C  THE COMPUTED APPROXIMATE EIGENVALUES ARE CALLED RITZ VALUES AND
C  THE CORRESPONDING APPROXIMATE EIGENVECTORS ARE CALLED RITZ VECTORS.
C
C  DNAUPD IS USUALLY CALLED ITERATIVELY TO SOLVE ONE OF THE
C  FOLLOWING PROBLEMS:
C
C  MODE 1:  A*X = LAMBDA*X.
C           ===> OP = A  AND  B = I.
C
C  MODE 2:  A*X = LAMBDA*M*X, M SYMMETRIC POSITIVE DEFINITE
C           ===> OP = INV(M)*A  AND  B = M.
C           ===> (IF M CAN BE FACTORED SEE REMARK 3 BELOW)
C
C  MODE 3:  A*X = LAMBDA*M*X, M SYMMETRIC SEMI-DEFINITE
C           ===> OP = REAL_PART( INV(A - SIGMA*M)*M )  AND  B = M.
C           ===> SHIFT-AND-INVERT MODE (IN REAL ARITHMETIC)
C           IF OP*X = AMU*X, THEN
C           AMU = 1/2 * ( 1/(LAMBDA-SIGMA) + 1/(LAMBDA-CONJG(SIGMA)) ).

C
C  MODE 4:  A*X = LAMBDA*M*X, M SYMMETRIC SEMI-DEFINITE
C           ===> OP = IMAGINARY_PART( INV(A - SIGMA*M)*M )  AND  B = M.
C           ===> SHIFT-AND-INVERT MODE (IN REAL ARITHMETIC)
C           IF OP*X = AMU*X, THEN
C           AMU = 1/2I * ( 1/(LAMBDA-SIGMA) - 1/(LAMBDA-CONJG(SIGMA)) ).
C
C  BOTH MODE 3 AND 4 GIVE THE SAME ENHANCEMENT TO EIGENVALUES CLOSE TO
C  THE (COMPLEX) SHIFT SIGMA.  HOWEVER, AS LAMBDA GOES TO INFINITY,
C  THE OPERATOR OP IN MODE 4 DAMPENS THE EIGENVALUES MORE STRONGLY THAN
C  DOES OP DEFINED IN MODE 3.
C
C  NOTE: THE ACTION OF W <- INV(A - SIGMA*M)*V OR W <- INV(M)*V
C        SHOULD BE ACCOMPLISHED EITHER BY A DIRECT METHOD
C        USING A SPARSE MATRIX FACTORIZATION AND SOLVING
C
C           (A - SIGMA*M)*W = V  OR M*W = V,
C
C        OR THROUGH AN ITERATIVE METHOD FOR SOLVING THESE
C        SYSTEMS.  IF AN ITERATIVE METHOD IS USED, THE
C        CONVERGENCE TEST MUST BE MORE STRINGENT THAN
C        THE ACCURACY REQUIREMENTS FOR THE EIGENVALUE
C        APPROXIMATIONS.
C
C
C ARGUMENTS
C  IDO     INTEGER.  (INPUT/OUTPUT)
C          REVERSE COMMUNICATION FLAG.  IDO MUST BE ZERO ON THE FIRST
C          CALL TO DNAUPD.  IDO WILL BE SET INTERNALLY TO
C          INDICATE THE TYPE OF OPERATION TO BE PERFORMED.  CONTROL IS
C          THEN GIVEN BACK TO THE CALLING ROUTINE WHICH HAS THE
C          RESPONSIBILITY TO CARRY OUT THE REQUESTED OPERATION AND CALL
C          DNAUPD WITH THE RESULT.  THE OPERAND IS GIVEN IN
C          WORKD(IPNTR(1)), THE RESULT MUST BE PUT IN WORKD(IPNTR(2)).
C          -------------------------------------------------------------
C          IDO =  0: FIRST CALL TO THE REVERSE COMMUNICATION INTERFACE
C          IDO = -1: COMPUTE  Y = OP * X  WHERE
C                    IPNTR(1) IS THE POINTER INTO WORKD FOR X,
C                    IPNTR(2) IS THE POINTER INTO WORKD FOR Y.
C                    THIS IS FOR THE INITIALIZATION PHASE TO FORCE THE
C                    STARTING VECTOR INTO THE RANGE OF OP.
C          IDO =  1: COMPUTE  Y = OP * X  WHERE
C                    IPNTR(1) IS THE POINTER INTO WORKD FOR X,
C                    IPNTR(2) IS THE POINTER INTO WORKD FOR Y.
C                    IN MODE 3 AND 4, THE VECTOR B * X IS ALREADY
C                    AVAILABLE IN WORKD(IPNTR(3)).  IT DOES NOT
C                    NEED TO BE RECOMPUTED IN FORMING OP * X.
C          IDO =  2: COMPUTE  Y = B * X  WHERE
C                    IPNTR(1) IS THE POINTER INTO WORKD FOR X,
C                    IPNTR(2) IS THE POINTER INTO WORKD FOR Y.
C          IDO =  3: COMPUTE THE IPARAM(8) REAL AND IMAGINARY PARTS
C                    OF THE SHIFTS WHERE INPTR(14) IS THE POINTER
C                    INTO WORKL FOR PLACING THE SHIFTS. SEE REMARK
C                    5 BELOW.
C          IDO = 99: DONE
C          -------------------------------------------------------------
C
C  BMAT    CHARACTER*1.  (INPUT)
C          BMAT SPECIFIES THE TYPE OF THE MATRIX B THAT DEFINES THE
C          SEMI-INNER PRODUCT FOR THE OPERATOR OP.
C          BMAT = 'I' -> STANDARD EIGENVALUE PROBLEM A*X = LAMBDA*X
C          BMAT = 'G' -> GENERALIZED EIGENVALUE PROBLEM A*X = LAMBDA*B*X
C
C  N       INTEGER.  (INPUT)
C          DIMENSION OF THE EIGENPROBLEM.
C
C  WHICH   CHARACTER*2.  (INPUT)
C          'LM' -> WANT THE NEV EIGENVALUES OF LARGEST MAGNITUDE.
C          'SM' -> WANT THE NEV EIGENVALUES OF SMALLEST MAGNITUDE.
C          'LR' -> WANT THE NEV EIGENVALUES OF LARGEST REAL PART.
C          'SR' -> WANT THE NEV EIGENVALUES OF SMALLEST REAL PART.
C          'LI' -> WANT THE NEV EIGENVALUES OF LARGEST IMAGINARY PART.
C          'SI' -> WANT THE NEV EIGENVALUES OF SMALLEST IMAGINARY PART.
C
C  NEV     INTEGER.  (INPUT)
C          NUMBER OF EIGENVALUES OF OP TO BE COMPUTED. 0 < NEV < N-1.
C
C  TOL     DOUBLE PRECISION SCALAR.  (INPUT)
C          STOPPING CRITERION: THE RELATIVE ACCURACY OF THE RITZ VALUE
C          IS CONSIDERED ACCEPTABLE IF BOUNDS(I) .LE. TOL*ABS(RITZ(I))
C          WHERE ABS(RITZ(I)) IS THE MAGNITUDE WHEN RITZ(I) IS COMPLEX.
C          DEFAULT = R8PREM()  (MACHINE PRECISION AS COMPUTED
C                    BY THE ASTER AUXILIARY SUBROUTINE).
C
C  RESID   DOUBLE PRECISION ARRAY OF LENGTH N.  (INPUT/OUTPUT)
C          ON INPUT:
C          IF INFO .EQ. 0, A RANDOM INITIAL RESIDUAL VECTOR IS USED.
C          IF INFO .NE. 0, RESID CONTAINS THE INITIAL RESIDUAL VECTOR,
C                          POSSIBLY FROM A PREVIOUS RUN.
C          ON OUTPUT:
C          RESID CONTAINS THE FINAL RESIDUAL VECTOR.
C
C  NCV     INTEGER.  (INPUT)
C          NUMBER OF COLUMNS OF THE MATRIX V. NCV MUST SATISFY THE TWO
C          INEQUALITIES 2 <= NCV-NEV AND NCV <= N.
C          THIS WILL INDICATE HOW MANY ARNOLDI VECTORS ARE GENERATED
C          AT EACH ITERATION.  AFTER THE STARTUP PHASE IN WHICH NEV
C          ARNOLDI VECTORS ARE GENERATED, THE ALGORITHM GENERATES
C          APPROXIMATELY NCV-NEV ARNOLDI VECTORS AT EACH SUBSEQUENT
C          UPDATE
C          ITERATION. MOST OF THE COST IN GENERATING EACH ARNOLDI
C          VECTOR IS IN THE MATRIX-VECTOR OPERATION OP*X.
C          NOTE: 2 <= NCV-NEV IN ORDER THAT COMPLEX CONJUGATE PAIRS OF
C          RITZ VALUES ARE KEPT TOGETHER. (SEE REMARK 4 BELOW)
C
C  V       DOUBLE PRECISION ARRAY N BY NCV.  (OUTPUT)
C          CONTAINS THE FINAL SET OF ARNOLDI BASIS VECTORS.
C
C  LDV     INTEGER.  (INPUT)
C          LEADING DIMENSION OF V EXACTLY AS DECLARED IN THE CALLING
C          PROGRAM.
C
C  IPARAM  INTEGER ARRAY OF LENGTH 11.  (INPUT/OUTPUT)
C          IPARAM(1) = ISHIFT METHOD FOR SELECTING THE IMPLICIT SHIFTS.
C          THE SHIFTS SELECTED AT EACH ITERATION ARE USED TO RESTART
C          THE ARNOLDI ITERATION IN AN IMPLICIT FASHION.
C          -------------------------------------------------------------
C          ISHIFT = 0: THE SHIFTS ARE PROVIDED BY THE USER VIA
C                      REVERSE COMMUNICATION.  THE REAL AND IMAGINARY
C                      PARTS OF THE NCV EIGENVALUES OF THE HESSENBERG
C                      MATRIX H ARE RETURNED IN THE PART OF THE WORKL
C                      ARRAY CORRESPONDING TO RITZR AND RITZI.
C                      SEE REMARK 5 BELOW.
C          ISHIFT = 1: EXACT SHIFTS WITH RESPECT TO THE CURRENT
C                      HESSENBERG MATRIX H.  THIS IS EQUIVALENT TO
C                      RESTARTING THE ITERATION WITH A STARTING VECTOR
C                      THAT IS A LINEAR COMBINATION OF APPROXIMATE
C                      SCHUR VECTORS ASSOCIATED WITH THE "WANTED"
C                      RITZ VALUES.
C          -------------------------------------------------------------
C
C          IPARAM(2) = NO LONGER REFERENCED.
C
C          IPARAM(3) = MXITER
C          ON INPUT:  MAXIMUM NUMBER OF ARNOLDI UPDATE ITERATIONS
C                     ALLOWED.
C          ON OUTPUT: ACTUAL NUMBER OF ARNOLDI UPDATE ITERATIONS
C                     TAKEN.
C
C          IPARAM(4) = NB: BLOCKSIZE TO BE USED IN THE RECURRENCE.
C          THE CODE CURRENTLY WORKS ONLY FOR NB = 1.
C
C          IPARAM(5) = NCONV: NUMBER OF "CONVERGED" RITZ VALUES.
C          THIS REPRESENTS THE NUMBER OF RITZ VALUES THAT SATISFY
C          THE CONVERGENCE CRITERION.
C
C          IPARAM(6) = IUPD (NOT USED)
C          NO LONGER REFERENCED. IMPLICIT RESTARTING IS ALWAYS USED.
C
C          IPARAM(7) = MODE
C      ON INPUT DETERMINES WHAT TYPE OF EIGENPROBLEM IS BEING SOLVED.
C      MUST BE 1,2,3,4, SEE UNDER  DESCRIPTION OF DNAUPD FOR THE
C      FOUR MODES AVAILABLE.
C
C          IPARAM(8) = NP
C          WHEN IDO = 3 AND THE USER PROVIDES SHIFTS THROUGH REVERSE
C          COMMUNICATION (IPARAM(1)=0), DNAUPD RETURNS NP, THE NUMBER
C          OF SHIFTS THE USER IS TO PROVIDE. 0 < NP <=NCV-NEV.
C          SEE REMARK 5 BELOW.
C
C          IPARAM(9) = NUMOP, IPARAM(10) = NUMOPB, IPARAM(11) = NUMREO,
C          OUTPUT: NUMOP  = TOTAL NUMBER OF OP*X OPERATIONS,
C                  NUMOPB = TOTAL NUMBER OF B*X OPERATIONS IF BMAT='G',
C                  NUMREO = TOTAL NUMBER OF STEPS OF
C                  RE-ORTHOGONALIZATION.
C
C  IPNTR   INTEGER ARRAY OF LENGTH 14.  (OUTPUT)
C          POINTER TO MARK THE STARTING LOCATIONS IN THE WORKD/ WORKL
C          ARRAYS FOR MATRICES/VECTORS USED BY THE ARNOLDI ITERATION.
C          -------------------------------------------------------------
C          IPNTR(1): POINTER TO THE CURRENT OPERAND VECTOR X IN WORKD.
C          IPNTR(2): POINTER TO THE CURRENT RESULT VECTOR Y IN WORKD.
C          IPNTR(3): POINTER TO THE VECTOR B * X IN WORKD WHEN USED IN
C                    THE SHIFT-AND-INVERT MODE.
C          IPNTR(4): POINTER TO THE NEXT AVAILABLE LOCATION IN WORKL
C                    THAT IS UNTOUCHED BY THE PROGRAM.
C          IPNTR(5): POINTER TO THE NCV BY NCV UPPER HESSENBERG MATRIX
C                    H IN WORKL.
C          IPNTR(6): POINTER TO THE REAL PART OF THE RITZ VALUE ARRAY
C                    RITZR IN WORKL.
C          IPNTR(7): POINTER TO THE IMAGINARY PART OF THE RITZ VALUE
C                    ARRAY RITZI IN WORKL.
C          IPNTR(8): POINTER TO THE RITZ ESTIMATES IN ARRAY WORKL
C                    ASSOCIATED WITH THE RITZ VALUES LOCATED IN RITZR
C                    AND RITZI IN WORKL.
C
C          IPNTR(14): POINTER TO THE NP SHIFTS IN WORKL.
C                     SEE REMARK 5 BELOW.
C
C          NOTE: IPNTR(9:13) IS ONLY REFERENCED BY DNEUPD.
C                     SEE REMARK 2 BELOW.
C
C          IPNTR(9):  POINTER TO THE REAL PART OF THE NCV RITZ VALUES
C                     OF THE ORIGINAL SYSTEM.
C          IPNTR(10): POINTER TO THE IMAGINARY PART OF THE NCV RITZ
C                     VALUES OF THE ORIGINAL SYSTEM.
C          IPNTR(11): POINTER TO THE NCV CORRESPONDING ERROR BOUNDS.
C          IPNTR(12): POINTER TO THE NCV BY NCV UPPER QUASI-TRIANGULAR
C                     SCHUR MATRIX FOR H.
C          IPNTR(13): POINTER TO THE NCV BY NCV MATRIX OF EIGENVECTORS
C                     OF THE UPPER HESSENBERG MATRIX H. ONLY REFERENCED
C                     BY DNEUPD IF RVEC = .TRUE. SEE REMARK 2 BELOW.
C          -------------------------------------------------------------
C
C  WORKD   DOUBLE PRECISION WORK ARRAY OF LENGTH 3*N.(REVERSE COM)
C          DISTRIBUTED ARRAY TO BE USED IN THE BASIC ARNOLDI ITERATION
C          FOR REVERSE COMMUNICATION.  THE USER SHOULD NOT USE WORKD
C          AS TEMPORARY WORKSPACE DURING THE ITERATION. UPON TERMINATION
C          WORKD(1:N) CONTAINS B*RESID(1:N). IF AN INVARIANT SUBSPACE
C          ASSOCIATED WITH THE CONVERGED RITZ VALUES IS DESIRED,
C          SEE REMARK 2 BELOW, SUBROUTINE DNEUPD USES THIS OUTPUT.
C          SEE DATA DISTRIBUTION NOTE BELOW.
C
C  WORKL   DOUBLE PRECISION WORK ARRAY OF LENGTH LWORKL.(OUTPUT)
C          PRIVATE (REPLICATED) ARRAY ON EACH PE OR ARRAY ALLOCATED ON
C          THE FRONT END.  SEE DATA DISTRIBUTION NOTE BELOW.
C
C  LWORKL  INTEGER.  (INPUT)
C          LWORKL MUST BE AT LEAST 3*NCV**2 + 6*NCV.
C
C  INFO    INTEGER.  (INPUT/OUTPUT)
C        IF INFO .EQ. 0, A RANDOMLY INITIAL RESIDUAL VECTOR IS USED.
C        IF INFO .NE. 0, RESID CONTAINS THE INITIAL RESIDUAL VECTOR,
C                        POSSIBLY FROM A PREVIOUS RUN.
C        ERROR FLAG ON OUTPUT.
C        =  0: NORMAL EXIT.
C        =  1: MAXIMUM NUMBER OF ITERATIONS TAKEN.
C            ALL POSSIBLE EIGENVALUES OF OP HAS BEEN FOUND. IPARAM(5)
C            RETURNS THE NUMBER OF WANTED CONVERGED RITZ VALUES.
C        =  2: NO LONGER AN INFORMATIONAL ERROR. DEPRECATED STARTING
C              WITH RELEASE 2 OF ARPACK.
C        =  3: NO SHIFTS COULD BE APPLIED DURING A CYCLE OF THE
C            IMPLICITLY RESTARTED ARNOLDI ITERATION. ONE POSSIBILITY
C            IS TO INCREASE THE SIZE OF NCV RELATIVE TO NEV.
C            SEE REMARK 4 BELOW.
C        = -1: N MUST BE POSITIVE.
C        = -2: NEV MUST BE POSITIVE.
C        = -3: NCV-NEV >= 2 AND LESS THAN OR EQUAL TO N.
C        = -4: THE MAXIMUM NUMBER OF ARNOLDI UPDATE ITERATION
C              MUST BE GREATER THAN ZERO.
C        = -5: WHICH MUST BE ONE OF 'LM', 'SM', 'LR', 'SR', 'LI', 'SI'
C        = -6: BMAT MUST BE ONE OF 'I' OR 'G'.
C        = -7: LENGTH OF PRIVATE WORK ARRAY IS NOT SUFFICIENT.
C        = -8: ERROR RETURN FROM LAPACK EIGENVALUE CALCULATION,
C        = -9: STARTING VECTOR IS ZERO.
C        = -10: IPARAM(7) MUST BE 1,2,3,4.
C        = -11: IPARAM(7) = 1 AND BMAT = 'G' ARE INCOMPATABLE.
C        = -12: IPARAM(1) MUST BE EQUAL TO 0 OR 1.
C        = -9999: COULD NOT BUILD AN ARNOLDI FACTORIZATION.
C                 IPARAM(5) RETURNS THE SIZE OF THE CURRENT ARNOLDI
C                 FACTORIZATION.
C
C  NEQACT  INTEGER  (INPUT/ NEW PARAMETER INTRODUCED FOR ASTER)
C          NUMBER OF PHYSICAL DEGREE OF FREEDOM
C
C  ALPHA   REAL  (INPUT/ NEW PARAMETER INTRODUCED FOR ASTER)
C          ORTHONORMALISATION PARAMETER FOR KAHAN-PARLETT ALGORITHM
C
C REMARKS
C  1. THE COMPUTED RITZ VALUES ARE APPROXIMATE EIGENVALUES OF OP. THE
C   SELECTION OF WHICH SHOULD BE MADE WITH THIS IN MIND WHEN
C   MODE = 3 AND 4.  AFTER CONVERGENCE, APPROXIMATE EIGENVALUES OF THE
C   ORIGINAL PROBLEM MAY BE OBTAINED WITH THE ARPACK SUBROUTINE DNEUPD.
C
C  2. IF A BASIS FOR THE INVARIANT SUBSPACE CORRESPONDING TO
C    THE CONVERGED RITZ VALUES IS NEEDED, THE USER MUST CALL DNEUPD
C    IMMEDIATELY FOLLOWING COMPLETION OF DNAUPD.
C    THIS IS NEW STARTING WITH RELEASE 2 OF ARPACK.
C
C  3. IF M CAN BE FACTORED INTO A CHOLESKY FACTORIZATION M = LL'
C     THEN MODE = 2 SHOULD NOT BE SELECTED.  INSTEAD ONE SHOULD USE
C     MODE = 1 WITH  OP = INV(L)*A*INV(L').  APPROPRIATE TRIANGULAR
C     LINEAR SYSTEMS SHOULD BE SOLVED WITH L AND L' RATHER
C     THAN COMPUTING INVERSES.  AFTER CONVERGENCE, AN APPROXIMATE
C     EIGENVECTOR Z OF THE ORIGINAL PROBLEM IS RECOVERED BY SOLVING
C     L'Z = X  WHERE X IS A RITZ VECTOR OF OP.
C
C  4. AT PRESENT THERE IS NO A-PRIORI ANALYSIS TO GUIDE THE SELECTION
C     OF NCV RELATIVE TO NEV. THE ONLY FORMAL REQUIREMENT IS THAT
C     NCV > NEV + 2. HOWEVER, IT IS RECOMMENDED THAT NCV .GE. 2*NEV+1.
C     IF MANY PROBLEMS OF THE SAME TYPE ARE TO BE SOLVED, ONE SHOULD
C     EXPERIMENT WITH INCREASING NCV WHILE KEEPING NEV FIXED FOR A GIVEN
C     TEST PROBLEM.
C     THIS WILL USUALLY DECREASE THE REQUIRED NUMBER OF OP*X OPERATIONS
C     BUT IT ALSO INCREASES THE WORK AND STORAGE REQUIRED TO MAINTAIN
C     THE ORTHOGONAL BASIS VECTORS.
C     THE OPTIMAL "CROSS-OVER" WITH RESPECT TO CPU TIME
C     IS PROBLEM DEPENDENT AND MUST BE DETERMINED EMPIRICALLY.
C     SEE CHAPTER 8 OF REFERENCE 2 FOR FURTHER INFORMATION.
C
C  5. WHEN IPARAM(1) = 0, AND IDO = 3, THE USER NEEDS TO PROVIDE THE
C   NP = IPARAM(8) REAL AND IMAGINARY PARTS OF THE SHIFTS IN LOCATIONS
C       REAL PART                  IMAGINARY PART
C       -----------------------    --------------
C   1   WORKL(IPNTR(14))           WORKL(IPNTR(14)+NP)
C   2   WORKL(IPNTR(14)+1)         WORKL(IPNTR(14)+NP+1)
C                        .                          .
C                        .                          .
C                        .                          .
C   NP  WORKL(IPNTR(14)+NP-1)      WORKL(IPNTR(14)+2*NP-1).
C
C  ONLY COMPLEX CONJUGATE PAIRS OF SHIFTS MAY BE APPLIED AND THE PAIRS
C  MUST BE PLACED IN CONSECUTIVE LOCATIONS. THE REAL PART OF THE
C  EIGENVALUES OF THE CURRENT UPPER HESSENBERG MATRIX ARE LOCATED IN
C  WORKL(IPNTR(6)) THROUGH WORKL(IPNTR(6)+NCV-1) AND THE IMAGINARY PART
C  IN WORKL(IPNTR(7)) THROUGH WORKL(IPNTR(7)+NCV-1). THEY ARE ORDERED
C  ACCORDING TO THE ORDER DEFINED BY WHICH. THE COMPLEX CONJUGATE
C  PAIRS ARE KEPT TOGETHER AND THE ASSOCIATED RITZ ESTIMATES ARE LOCATED
C  IN WORKL(IPNTR(8)), WORKL(IPNTR(8)+1), ... , WORKL(IPNTR(8)+NCV-1).
C
C-----------------------------------------------------------------------
C
C BEGINLIB
C
C REFERENCES:
C  1. D.C. SORENSEN, "IMPLICIT APPLICATION OF POLYNOMIAL FILTERS IN
C     A K-STEP ARNOLDI METHOD", SIAM J. MATR. ANAL. APPS., 13 (1992),
C     PP 357-385.
C  2. R.B. LEHOUCQ, "ANALYSIS AND IMPLEMENTATION OF AN IMPLICITLY
C     RESTARTED ARNOLDI ITERATION", RICE UNIVERSITY TECHNICAL REPORT
C     TR95-13, DEPARTMENT OF COMPUTATIONAL AND APPLIED MATHEMATICS.
C  3. B.N. PARLETT & Y. SAAD, "COMPLEX SHIFT AND INVERT STRATEGIES FOR
C     REAL MATRICES", LINEAR ALGEBRA AND ITS APPLICATIONS, VOL 88/89,
C     PP 575-595, (1987).
C
C ROUTINES CALLED:
C     DNAUP2  ARPACK ROUTINE THAT IMPLEMENTS THE IMPLICITLY RESTARTED
C             ARNOLDI ITERATION.
C     IVOUT   ARPACK UTILITY ROUTINE THAT PRINTS INTEGERS.
C     DVOUT   ARPACK UTILITY ROUTINE THAT PRINTS VECTORS.
C
C     R8PREM  ASTER UTILITY ROUTINE THAT GIVES THE MACHINE PRECISION
C
C INTRINSIC FUNCTION:
C     NONE
C
C AUTHOR
C     DANNY SORENSEN               PHUONG VU
C     RICHARD LEHOUCQ              CRPC / RICE UNIVERSITY
C     DEPT. OF COMPUTATIONAL &     HOUSTON, TEXAS
C     APPLIED MATHEMATICS
C     RICE UNIVERSITY
C     HOUSTON, TEXAS
C
C REVISION HISTORY:
C     12/16/93: VERSION '1.1'
C
C FILE: NAUPD.F   SID: 2.5   DATE OF SID: 8/27/96   RELEASE: 2
C
C ASTER INFORMATION
C 07/01/2000 TOILETTAGE DU FORTRAN SUIVANT LES REGLES ASTER,
C            DISPARITION DE DSTATN, DLAMCH ET SECOND,
C            COMMON TIMING REMPLACE PAR COMMON INFOR,
C            MESSAGE FINAL ASSOCIE EXPURGE,
C            RAJOUT DU PARAMETRE NEQACT,
C            SHUNTAGE MESSAGE ERREUR -3 ET NOUVEAU MESSAGE.
C            UTILISATION DE R8PREM(),
C            IMPLICIT NONE.
C ENDLIB
C-----------------------------------------------------------------------
C CORPS DU PROGRAMME
      IMPLICIT NONE

C     %--------------------------------------%
C     | INCLUDE FILES FOR DEBUGGING AND INFO |
C     %--------------------------------------%

      INTEGER LOGFIL, NDIGIT, MGETV0,
     &  MNAUPD, MNAUP2, MNAITR, MNEIGH, MNAPPS, MNGETS, MNEUPD
      COMMON /DEBUG/
     &  LOGFIL, NDIGIT, MGETV0,
     &  MNAUPD, MNAUP2, MNAITR, MNEIGH, MNAPPS, MNGETS, MNEUPD
      INTEGER NOPX, NBX, NRORTH, NITREF, NRSTRT
      COMMON /INFOR/
     &  NOPX, NBX, NRORTH, NITREF, NRSTRT

C     %------------------%
C     | SCALAR ARGUMENTS |
C     %------------------%

      CHARACTER*1 BMAT
      CHARACTER*2 WHICH
      INTEGER IDO, INFO, LDV, LWORKL, N, NCV, NEV, NEQACT
      REAL*8 TOL, ALPHA

C     %-----------------%
C     | ARRAY ARGUMENTS |
C     %-----------------%

      INTEGER IPARAM(11), IPNTR(14)
      REAL*8 RESID(N), V(LDV,NCV), WORKD(3*N), WORKL(LWORKL)

C     %------------%
C     | PARAMETERS |
C     %------------%

      REAL*8 ZERO
      PARAMETER (ZERO = 0.0D+0)

C     %---------------%
C     | LOCAL SCALARS |
C     %---------------%

      INTEGER BOUNDS, IERR, IH, IQ, ISHIFT, IW,
     &  LDH, LDQ, MODE, MSGLVL, MXITER, NB,
     &  NEV0, NEXT, NP, RITZI, RITZR, J
C DUE TO CRS512 INTEGER LEVEC
      SAVE BOUNDS, IH, IQ, ISHIFT, IW, LDH, LDQ,
     &  MODE, MSGLVL, MXITER, NB, NEV0, NEXT,
     &  NP, RITZI, RITZR
C DUE TO CRS512 SAVE LEVEC
      REAL*8 R8PREM

C     %-----------------------%
C     | EXECUTABLE STATEMENTS |
C     %-----------------------%

      IF (IDO .EQ. 0) THEN

C        %-------------------------------%
C        | INITIALIZE TIMING STATISTICS  |
C        | & MESSAGE LEVEL FOR DEBUGGING |
C        %-------------------------------%

         MSGLVL = MNAUPD

C        %----------------%
C        | ERROR CHECKING |
C        %----------------%

         IERR   = 0
         ISHIFT = IPARAM(1)
C DUE TO CRS512  LEVEC  = IPARAM(2)
         MXITER = IPARAM(3)
         NB     = IPARAM(4)

C        %--------------------------------------------%
C        | REVISION 2 PERFORMS ONLY IMPLICIT RESTART. |
C        %--------------------------------------------%

         MODE   = IPARAM(7)
         IF (N .LE. 0) THEN
           IERR = -1
         ELSE IF (NEV .LE. 0) THEN
           IERR = -2
         ELSE IF (NCV .LE. NEV+1 .OR.  NCV .GT. N) THEN
           IF (MSGLVL.GT.0) THEN
             WRITE(LOGFIL,*)
             WRITE(LOGFIL,*)'&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
             WRITE(LOGFIL,*)'& FLAG ERREUR -3 DEBRANCHE DANS DNAUPD &'
             WRITE(LOGFIL,*)'& NBVECT < NBFREQ + 2 OU NBVECT > NBEQ &'
             WRITE(LOGFIL,*)'&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
             WRITE(LOGFIL,*)
           ENDIF
         ELSE IF (MXITER .LE. 0) THEN
           IERR = -4
         ELSE IF (WHICH .NE. 'LM' .AND.
     &     WHICH .NE. 'SM' .AND.
     &     WHICH .NE. 'LR' .AND.
     &     WHICH .NE. 'SR' .AND.
     &     WHICH .NE. 'LI' .AND.
     &     WHICH .NE. 'SI') THEN
           IERR = -5
         ELSE IF (BMAT .NE. 'I' .AND. BMAT .NE. 'G') THEN
           IERR = -6
         ELSE IF (LWORKL .LT. 3*NCV**2 + 6*NCV) THEN
           IERR = -7
         ELSE IF (MODE .LT. 1 .OR. MODE .GT. 4) THEN
           IERR = -10
         ELSE IF (MODE .EQ. 1 .AND. BMAT .EQ. 'G') THEN
           IERR = -11
         ELSE IF (ISHIFT .LT. 0 .OR. ISHIFT .GT. 1) THEN
           IERR = -12
         END IF

C        %------------%
C        | ERROR EXIT |
C        %------------%

         IF (IERR .NE. 0) THEN
            INFO = IERR
            IDO  = 99
            GO TO 9000
         END IF

C        %------------------------%
C        | SET DEFAULT PARAMETERS |
C        %------------------------%

         IF (NB .LE. 0) NB = 1
         IF (TOL .LE. ZERO) TOL = R8PREM()*10.D0

C        %----------------------------------------------%
C        | NP IS THE NUMBER OF ADDITIONAL STEPS TO      |
C        | EXTEND THE LENGTH NEV LANCZOS FACTORIZATION. |
C        | NEV0 IS THE LOCAL VARIABLE DESIGNATING THE   |
C        | SIZE OF THE INVARIANT SUBSPACE DESIRED.      |
C        %----------------------------------------------%

         NP     = NCV - NEV
         NEV0   = NEV

C        %-----------------------------%
C        | ZERO OUT INTERNAL WORKSPACE |
C        %-----------------------------%

         DO 10 J = 1, 3*NCV**2 + 6*NCV
            WORKL(J) = ZERO
  10     CONTINUE

C        %-------------------------------------------------------------%
C        | POINTER INTO WORKL FOR ADDRESS OF H, RITZ, BOUNDS, Q        |
C        | ETC... AND THE REMAINING WORKSPACE.                         |
C        | ALSO UPDATE POINTER TO BE USED ON OUTPUT.                   |
C        | MEMORY IS LAID OUT AS FOLLOWS:                              |
C        | WORKL(1:NCV*NCV) := GENERATED HESSENBERG MATRIX             |
C        | WORKL(NCV*NCV+1:NCV*NCV+2*NCV) := REAL AND IMAGINARY        |
C        |                                   PARTS OF RITZ VALUES      |
C        | WORKL(NCV*NCV+2*NCV+1:NCV*NCV+3*NCV) := ERROR BOUNDS        |
C        | WORKL(NCV*NCV+3*NCV+1:2*NCV*NCV+3*NCV) := ROTATION MATRIX Q |
C        | WORKL(2*NCV*NCV+3*NCV+1:3*NCV*NCV+6*NCV) := WORKSPACE       |
C        | THE FINAL WORKSPACE IS NEEDED BY SUBROUTINE DNEIGH CALLED   |
C        | BY DNAUP2. SUBROUTINE DNEIGH CALLS LAPACK ROUTINES FOR      |
C        | CALCULATING EIGENVALUES AND THE LAST ROW OF THE EIGENVECTOR |
C        | MATRIX.                                                     |
C        %-------------------------------------------------------------%

         LDH    = NCV
         LDQ    = NCV
         IH     = 1
         RITZR  = IH     + LDH*NCV
         RITZI  = RITZR  + NCV
         BOUNDS = RITZI  + NCV
         IQ     = BOUNDS + NCV
         IW     = IQ     + LDQ*NCV
         NEXT   = IW     + NCV**2 + 3*NCV
         IPNTR(4) = NEXT
         IPNTR(5) = IH
         IPNTR(6) = RITZR
         IPNTR(7) = RITZI
         IPNTR(8) = BOUNDS
         IPNTR(14) = IW
      END IF

C     %-------------------------------------------------------%
C     | CARRY OUT THE IMPLICITLY RESTARTED ARNOLDI ITERATION. |
C     %-------------------------------------------------------%

      CALL DNAUP2
     &  ( IDO, BMAT, N, WHICH, NEV0, NP, TOL, RESID,
     &   ISHIFT, MXITER, V, LDV, WORKL(IH), LDH, WORKL(RITZR),
     &   WORKL(RITZI), WORKL(BOUNDS), WORKL(IQ), LDQ, WORKL(IW),
     &   IPNTR, WORKD, INFO, NEQACT, ALPHA)

C     %--------------------------------------------------%
C     | IDO .NE. 99 IMPLIES USE OF REVERSE COMMUNICATION |
C     | TO COMPUTE OPERATIONS INVOLVING OP OR SHIFTS.    |
C     %--------------------------------------------------%

      IF (IDO .EQ. 3) IPARAM(8) = NP
      IF (IDO .NE. 99) GO TO 9000

      IPARAM(3) = MXITER
      IPARAM(5) = NP
      IPARAM(9) = NOPX
      IPARAM(10) = NBX
      IPARAM(11) = NRORTH

C     %------------------------------------%
C     | EXIT IF THERE WAS AN INFORMATIONAL |
C     | ERROR WITHIN DNAUP2.               |
C     %------------------------------------%

      IF (INFO .LT. 0) GO TO 9000
      IF (INFO .EQ. 2) INFO = 3

      IF (MSGLVL .GT. 0) THEN
        CALL IVOUT (LOGFIL, 1, MXITER, NDIGIT,
     &             '_NAUPD: NUMBER OF UPDATE ITERATIONS TAKEN')
        CALL IVOUT (LOGFIL, 1, NP, NDIGIT,
     &             '_NAUPD: NUMBER OF WANTED "CONVERGED" RITZ VALUES')
        CALL DVOUT (LOGFIL, NP, WORKL(RITZR), NDIGIT,
     &             '_NAUPD: REAL PART OF THE FINAL RITZ VALUES')
        CALL DVOUT (LOGFIL, NP, WORKL(RITZI), NDIGIT,
     &             '_NAUPD: IMAGINARY PART OF THE FINAL RITZ VALUES')
        CALL DVOUT (LOGFIL, NP, WORKL(BOUNDS), NDIGIT,
     &             '_NAUPD: ASSOCIATED RITZ ESTIMATES')
       ENDIF
C        %--------------------------------%
C        | VERSION NUMBER & VERSION DATE  |
C        %--------------------------------%
       WRITE(LOGFIL,1000)
       WRITE(LOGFIL,1100) MXITER, NOPX, NBX, NRORTH, NITREF, NRSTRT
       WRITE(LOGFIL,*)
       MXITER=0
       NOPX=0
       NBX=0
       NRORTH=0
       NITREF=0
       NRSTRT=0
 1000  FORMAT (//,
     &      5X, '=============================================',/
     &      5X, '=       METHODE DE SORENSEN (CODE ARPACK)   =',/
     &      5X, '=       VERSION : ', ' 2.4', 21X, ' =',/
     &      5X, '=          DATE : ', ' 07/31/96', 16X,   ' =',/
     &      5X, '=============================================')
 1100  FORMAT (
     &      5X, 'NOMBRE DE REDEMARRAGES                     = ', I5,/
     &      5X, 'NOMBRE DE PRODUITS OP*X                    = ', I5,/
     &      5X, 'NOMBRE DE PRODUITS B*X                     = ', I5,/
     &      5X, 'NOMBRE DE REORTHOGONALISATIONS  (ETAPE 1)  = ', I5,/
     &      5X, 'NOMBRE DE REORTHOGONALISATIONS  (ETAPE 2)  = ', I5,/
     &      5X, 'NOMBRE DE REDEMARRAGES DU A UN V0 NUL      = ', I5)
C
 9000 CONTINUE

C     %---------------%
C     | END OF DNAUPD |
C     %---------------%

      END
