      SUBROUTINE NMREP2(N,R,G,GU,RMIN,RMAX,REXM,REXP,POSOPT)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 27/06/2006   AUTEUR CIBHHPD L.SALMONA 
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
      INTEGER N,POSOPT
      REAL*8 R(*),G(*),GU,RMIN,RMAX,REXM,REXP

C ----------------------------------------------------------------------
C  CALCUL DU MINIMUM POUR LA RECHERCHE LINEAIRE AVEC PILOTAGE (NMREPL)

C VAR N      NOMBRE DE POINTS CONSIDERES  (N >= 2)
C VAR R       ABSCISSES DES POINTS R(1) < ... R(I) ... < R(N)
C IN  G       ORDONNEES DES POINTS
C IN  GU      ORDONNEE A CONVERGENCE (GAIN)
C VAR RMIN    ABSCISSE MINIMALE
C VAR RMAX    ABSCISSE MAXIMALE
C VAR REXM    INTERVALLE INTERDIT AUTOUR DE 0 EN NEGATIF
C VAR REXP    INTERVALLE INTERDIT AUTOUR DE 0 EN POSITIF
C OUT POSOPT  POSITION DU NOUVEAU R :  R(POSOPT)
C ----------------------------------------------------------------------

      LOGICAL GAUCHE,DROITE
      INTEGER I,C,J,POS
      REAL*8 A,B,DET,V,D,X,PENTE,DG,R8GAEM,X1,Y1,X2,Y2,X3,Y3
      REAL*8 APPUIG,APPUID,VALG,VALD,VAL,VALOPT,XOPT
      REAL*8 DIFF
      PARAMETER (DIFF=1.D-8)


      VALOPT = R8GAEM()

C      write (6,*) 'NMREP2'
C      write (6,*) 'N = ',N
C      write (6,*) 'GU= ',GU
C      write (6,*) 'RHOMIN = ',RMIN,' ; RHOMAX = ',RMAX
C      do i = 1,n
C        write (6,6968) r(i),g(i)
C 6968   format (' R,G = ',G22.15,2X,G22.15)
C      end do

      DO 50 I = 1,N


C ----------------------------------------------------------------------
C                   PROPOSITION D'UN NOUVEAU POINT
C ----------------------------------------------------------------------

C      EXTRAPOLATION LINEAIRE POUR LE POINT LE PLUS A GAUCHE
        IF (I.EQ.1) THEN
          PENTE = (G(2)-G(1))/ (R(2)-R(1))
          DG = GU/1.2D0 - G(1)

C        EXTRAPOLATION LICITE UNIQUEMENT DU COTE SANS INFORMATION
          IF (PENTE.LE.0.D0) GO TO 50

          IF (ABS(PENTE).GT.ABS(DG)/R8GAEM()) THEN
            X = R(1) + DG/PENTE
C            write (6,*) '1a. X = ',X
C        EXTRAPOLATION IMPOSSIBLE : PENTE NULLE
          ELSE
            X = (R(1)+R(2))/2
          END IF


C      EXTRAPOLATION LINEAIRE POUR LE POINT LE PLUS A DROITE
        ELSE IF (I.EQ.N) THEN
          PENTE = (G(N)-G(N-1))/ (R(N)-R(N-1))
          DG = GU/1.2D0 - G(N-1)

C        EXTRAPOLATION LICITE UNIQUEMENT DU COTE SANS INFORMATION
          IF (PENTE.GE.0.D0) GO TO 50

          IF (ABS(PENTE).GT.ABS(DG)/R8GAEM()) THEN
            X = R(N-1) + DG/PENTE
C            write (6,*) '1b. X = ',X

C        EXTRAPOLATION IMPOSSIBLE : PENTE NULLE
          ELSE
            X = (R(N-1)+R(N))/2
          END IF


C      INTERPOLATION QUADRATIQUE POUR UN POINT INTERMEDIAIRE

        ELSE IF (I.GT.1 .AND. I.LT.N) THEN
          DET = - (R(I-1)-R(I))* (R(I)-R(I+1))* (R(I+1)-R(I-1))
C        INTERPOLATION QUADRATIQUE IMPOSSIBLE : COURBURE NULLE
          IF (ABS(DET).LT.1.D0/R8GAEM()) GO TO 50
          A = ((G(I-1)-G(I))* (R(I)-R(I+1))-
     &        (G(I)-G(I+1))* (R(I-1)-R(I)))/DET

C        LE MINIMUM N'EXISTE PAS
          IF (A.LE.0) GO TO 50

          B = ((G(I)-G(I+1))* (R(I-1)**2-R(I)**2)-
     &        (G(I-1)-G(I))* (R(I)**2-R(I+1)**2))/DET
          X = -B/ (2*A)

C        LE MINIMUM N'EST PAS DANS UN VOISINAGE DES 3 POINTS
          IF (I-2.GE.1) THEN
            IF (X.LE.R(I-2)) GO TO 50
          END IF
          IF (I+2.LE.N) THEN
            IF (X.GE.R(I+2)) GO TO 50
          END IF
        END IF


C ----------------------------------------------------------------------
C                   PROJECTION DU POINT SUR LES BORNES
C                 ET EN DEHORS DES POINTS DEJA CALCULES
C ----------------------------------------------------------------------

C      PROJECTION SUR L'INTERVALLE DE RECHERCHE
        IF (X.LT.RMIN) THEN
          X = RMIN
C          write (6,*) '2a. X= ',X,' ; RMIN = ',RMIN 
        END IF
        IF (X.GT.RMAX) THEN
          X = RMAX
C          write (6,*) '2b. X= ',X,' ; RMAX = ',RMAX 
        END IF
        IF (X.LT.0 .AND. X.GE.REXM) THEN
          X = REXM
C          write (6,*) '3a. X= ',X,' ; REXM = ',REXM
        END IF
        IF (X.GE.0 .AND. X.LE.REXP) THEN
          X = REXP
C          write (6,*) '3b. X= ',X,' ; REXM = ',REXM
        END IF
C      X EST-IL CONFONDU AVEC UN POINT DEJA CALCULE
        C = 0
        DO 10 J = 1,N
          IF (ABS(R(J)-X).LE.DIFF) C = J
C          write (6,*) '4. C = ',C
   10   CONTINUE
        IF (C.EQ.0) GO TO 20
C      LES CHOIX VERS LA GAUCHE OU LA DROITE SONT-ILS LICITES
        GAUCHE = R(C) - RMIN .GT. DIFF
        DROITE = RMAX - R(C) .GT. DIFF
C      POINTS D'APPUI A GAUCHE ET A DROITE
        IF (GAUCHE) THEN
          IF (C.EQ.1) THEN
            APPUIG = RMIN
            VALG = G(1) + (APPUIG-R(1))/ (R(2)-R(1))* (G(2)-G(1))
C            write (6,*) '5a. VALG = ',VALG
          ELSE
            APPUIG = MAX(RMIN,R(C-1))
            VALG = G(C-1) + (APPUIG-R(C-1))/ (R(C)-R(C-1))*
     &             (G(C)-G(C-1))
C            write (6,*) '5b. VALG = ',VALG
          END IF
        END IF
        IF (DROITE) THEN
          IF (C.EQ.N) THEN
            APPUID = RMAX
            VALD = G(N) + (APPUID-R(N))/ (R(N-1)-R(N))* (G(N-1)-G(N))
C            write (6,*) '6a. VALD = ',VALD
          ELSE
            APPUID = MIN(RMAX,R(C+1))
            VALD = G(C+1) + (APPUID-R(C+1))/ (R(C)-R(C+1))*
     &             (G(C)-G(C+1))
C            write (6,*) '6b. VALD = ',VALD
          END IF
        END IF
C      UNIQUEMENT LE CHOIX A GAUCHE
        IF (.NOT.DROITE) X = (R(C)+APPUIG)/2
C      UNIQUEMENT LE CHOIX A DROITE
        IF (.NOT.GAUCHE) X = (R(C)+APPUID)/2
C      LES DEUX CHOIX SONT LICITES
        IF (GAUCHE .AND. DROITE) THEN
          IF (VALG.LE.VALD) THEN
            X = (R(C)+APPUIG)/2
          ELSE
            X = (R(C)+APPUID)/2
          END IF
        END IF
   20   CONTINUE
C        write (6,*) '7. X = ',X

C ----------------------------------------------------------------------
C             APPROXIMATION DE LA VALEUR DE LA FONCTION EN X
C ----------------------------------------------------------------------

C      RECHERCHE DE L'INTERVALLE DANS LEQUEL SE TROUVE X
        POS = N + 1
        DO 30 J = 1,N
          IF (X.LE.R(J)) THEN
            POS = J
            GO TO 40
          END IF
   30   CONTINUE
   40   CONTINUE

C        write (6,*) 'POS = ',POS
C      SI DEUX POINTS : INTERPOLATION LINEAIRE
        IF (N.EQ.2) THEN
          VAL = G(1) + (X-R(1))/ (R(2)-R(1))* (G(2)-G(1))
C      EXTRAPOLATION A GAUCHE
        ELSE IF (POS.EQ.1) THEN
          VAL = G(1) + (X-R(1))/ (R(2)-R(1))* (G(2)-G(1))
C      EXTRAPOLATION A DROITE
        ELSE IF (POS.EQ.N+1) THEN
          VAL = G(N) + (X-R(N))/ (R(N-1)-R(N))* (G(N-1)-G(N))

C      INTERPOLATION QUADRATIQUE
        ELSE
          VALG = R8GAEM()
          VALD = R8GAEM()

C        INTERPOLATION ENTRE POS-1, POS ET POS+1
          IF (POS+1.LE.N) THEN
            X1 = R(POS-1)
            X2 = R(POS)
            X3 = R(POS+1)
            Y1 = G(POS-1)
            Y2 = G(POS)
            Y3 = G(POS+1)
            D = (X2-X1)* (X3-X2)* (X1-X3)
            A = ((Y2-Y1)* (X3-X2)- (Y3-Y2)* (X2-X1))/D
            B = ((X2**2-X1**2)* (Y3-Y2)- (X3**2-X2**2)* (Y2-Y1))/D
            V = Y1 - A*X1**2 - B*X1
            VALG = A*X**2 + B*X + V
          END IF
C        INTERPOLATION ENTRE POS-2, POS-1 ET POS
          IF (POS-2.GE.1) THEN
            X1 = R(POS-2)
            X2 = R(POS-1)
            X3 = R(POS)
            Y1 = G(POS-2)
            Y2 = G(POS-1)
            Y3 = G(POS)
            D = (X2-X1)* (X3-X2)* (X1-X3)
            A = ((Y2-Y1)* (X3-X2)- (Y3-Y2)* (X2-X1))/D
            B = ((X2**2-X1**2)* (Y3-Y2)- (X3**2-X2**2)* (Y2-Y1))/D
            V = Y1 - A*X1**2 - B*X1
            VALD = A*X**2 + B*X + V
          END IF

C        ON GARDE LA VALEUR DE L'INTERPOLATION LA PLUS BASSE
          VAL = MIN(VALG,VALD)
C          write (6,*) '8. VAL =',VAL
        END IF

C ----------------------------------------------------------------------
C               ON GARDE LE MINIMUM DES X CONSTRUITS
C ----------------------------------------------------------------------

        IF (VAL.LT.VALOPT) THEN
          VALOPT = VAL
          XOPT = X
          POSOPT = POS
C          write (6,*) '9. XOPT = ',XOPT
        END IF

   50 CONTINUE


C    INSERTION DU MINIMUM

      DO 60 I = N,1,-1
        IF (XOPT.GT.R(I)) THEN
          POSOPT = I + 1
          GO TO 70
        END IF
        R(I+1) = R(I)
        G(I+1) = G(I)
   60 CONTINUE
      POSOPT = 1
   70 CONTINUE

      N = N + 1
      R(POSOPT) = XOPT
C      write (6,*) '10. XOPT = ',XOPT

      END
