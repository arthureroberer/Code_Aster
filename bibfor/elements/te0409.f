      SUBROUTINE TE0409(OPTION,NOMTE)
C     ----------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 12/12/2011   AUTEUR DELMAS J.DELMAS 
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
      IMPLICIT NONE

      CHARACTER*16 OPTION, NOMTE
C
C   CALCUL DES OPTIONS DES ELEMENTS DE PLAQUE POUR LA MODELISATION DKTG
C     -----------------------------------------------------------------
C                            TRIANGLE  QUADRANGLE
C        KIRCHOFF  (MINCE)      DKT       DKQ
C
C        OPTIONS     RIGI_MECA       RIGI_MECA_TANG
C                    FULL_MECA       RAPH_MECA
C                    MASS_MECA       MASS_INER
C                    EPOT_ELEM       ECIN_ELEM
C                    FORC_NODA
C                    EFGE_ELNO
C
C RESPONSABLE SFAYOLLE S.FAYOLLE
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
      LOGICAL LRGM

      INTEGER NNOS, IPOIDS, IVF, IDFDX, JGANO
      INTEGER MULTIC, JTAB(7),CODRET, IDEPLM, IDEPLP
      INTEGER ICOMPO, I, I1, I2, J, K, IVECTU, IPG, NPG
      INTEGER  ICHN, ICONTM, JCRET
      INTEGER IMATE, NNO, IGEOM, IMATUU, JENER, JFREQ, IACCE
      INTEGER NDDL, NVEC, NDIM, IRET, N1, NI, N2, ICARCR

      REAL*8 RHO, EPAIS
      REAL*8 PGL(3,3) ,XYZL(3,4),BSIGMA(24), EFFGT(32)
      REAL*8 VECLOC(24), ENER(3), MATP(24,24), MATV(300)
      REAL*8 T2EV(4), T2VE(4), R8PREM
C     ---> POUR DKT MATELEM = 3 * 6 DDL = 171 TERMES STOCKAGE SYME
C     ---> POUR DKQ MATELEM = 4 * 6 DDL = 300 TERMES STOCKAGE SYME
      REAL*8 MATLOC(300)

C     ---> POUR DKT EFFINT = 24
C     ---> POUR DKQ EFFINT = 32
      REAL*8 EFFINT(32), EFFIN2(32)

C     --->   UML : DEPLACEMENT A L'INSTANT T- (REPERE LOCAL)
C     --->   DUL : INCREMENT DE DEPLACEMENT   (REPERE LOCAL)
      REAL*8 UML(6,4),DUL(6,4)

      INTEGER  ICODRE(33)
      CHARACTER*10 PHENOM
      CHARACTER*16 COMP3,COMPOR

C ---   RECUPERATION DES ADRESSES DANS ZR DES POIDS DES PG
C       DES FONCTIONS DE FORME DES VALEURS DES DERIVEES DES FONCTIONS
C       DE FORME ET DE LA MATRICE DE PASSAGE GAUSS -> NOEUDS
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDX,JGANO)

      IF (OPTION.EQ.'FULL_MECA'      .OR.
     &    OPTION.EQ.'RAPH_MECA'      .OR.
     &    OPTION(1:9).EQ.'RIGI_MECA') THEN

C ---   RECUPERATION DU MATERIAU
        CALL JEVECH('PMATERC','L',IMATE)

        IF (OPTION.EQ.'FULL_MECA'      .OR.
     &      OPTION.EQ.'RAPH_MECA'      .OR.
     &      OPTION.EQ.'RIGI_MECA_TANG' .OR.
     &      OPTION.EQ.'RIGI_MECA     ') THEN

          CALL RCCOMA(ZI(IMATE),'ELAS',PHENOM,ICODRE)
        ENDIF
      ENDIF

      IF (OPTION.NE.'EFGE_ELNO') THEN

        CALL JEVECH('PGEOMER','L',IGEOM)

        IF (NNO.EQ.3) THEN
          CALL DXTPGL(ZR(IGEOM),PGL)
        ELSE IF (NNO.EQ.4) THEN
          CALL DXQPGL(ZR(IGEOM),PGL)
        END IF

        CALL UTPVGL(NNO,3,PGL,ZR(IGEOM),XYZL)
      END IF

      IF (OPTION.EQ.'EPOT_ELEM') THEN
        IF (NOMTE.EQ.'MEDKTG3') THEN
          CALL DKTRIG(NOMTE,XYZL,OPTION,PGL,MATLOC,ENER,MULTIC)
        ELSE IF (NOMTE.EQ.'MEDKQG4') THEN
          CALL DKQRIG(NOMTE,XYZL,OPTION,PGL,MATLOC,ENER)
        END IF

        CALL JEVECH('PENERDR','E',JENER)

        DO 10 I = 1,3
          ZR(JENER-1+I) = ENER(I)
   10   CONTINUE
      ELSE IF (OPTION.EQ.'MASS_MECA' .OR.
     &         OPTION.EQ.'MASS_MECA_DIAG' .OR.
     &         OPTION.EQ.'MASS_MECA_EXPLI' .OR.
     &         OPTION.EQ.'M_GAMMA' .OR.
     &         OPTION.EQ.'ECIN_ELEM') THEN

        IF (NOMTE.EQ.'MEDKTG3') THEN
          CALL DKTMAS(XYZL,OPTION,PGL,MATLOC,ENER,MULTIC)
        ELSE IF (NOMTE.EQ.'MEDKQG4') THEN
          CALL DKQMAS(XYZL,OPTION,PGL,MATLOC,ENER)
        END IF

        IF (OPTION.EQ.'MASS_MECA') THEN
          CALL JEVECH('PMATUUR','E',IMATUU)
          CALL UTPSLG(NNO,6,PGL,MATLOC,ZR(IMATUU))
        ELSE IF (OPTION.EQ.'ECIN_ELEM') THEN
          CALL JEVECH('PENERCR','E',JENER)
          CALL JEVECH('POMEGA2','L',JFREQ)

          DO 20 I = 1,3
            ZR(JENER-1+I) = ZR(JFREQ)*ENER(I)
   20     CONTINUE
        ELSE IF (OPTION.EQ.'M_GAMMA') THEN
          CALL JEVECH('PACCELR','L',IACCE)
          CALL JEVECH('PVECTUR','E',IVECTU)

          NDDL = 6*NNO
          NVEC = NDDL* (NDDL+1)/2

          CALL UTPSLG(NNO,6,PGL,MATLOC,MATV)
          CALL VECMA(MATV,NVEC,MATP,NDDL)
          CALL PMAVEC('ZERO',NDDL,MATP,ZR(IACCE),ZR(IVECTU))
        ELSE IF (OPTION.EQ.'MASS_MECA_DIAG'.OR.
     &           OPTION.EQ.'MASS_MECA_EXPLI') THEN
          CALL JEVECH('PMATUUR','E',IMATUU)

          NDDL = 6*NNO
          NDIM = NDDL* (NDDL+1)/2

          DO 30 I = 1,NDIM
            ZR(IMATUU-1+I) = MATLOC(I)
   30     CONTINUE

          IF (OPTION.EQ.'MASS_MECA_EXPLI') THEN
C     CORRECTION DES TERMES CORRESPONDANT AU DDL 6
C     NON PREVU PAR LA THEORIE DKT. ON RAJOUTE
C     UN TERME DIAGONAL NON ZERO EGAL A CELUI DU DDL 5.
C     CETTE CORRECTION A ETE INSPIRE PAR LA DEMARCHE DANS EUROPLEXUS
            DO 35 J = 1,NNO
              N1 = 6*(J-1) + 5
              N2 = 6*(J-1) + 4
              NI = 6*J
              NDIM = (NI + 1)*NI/2
              N1   = (N1 + 1)*N1/2
              N2   = (N2 + 1)*N2/2
              ZR(IMATUU-1+NDIM)=(ZR(IMATUU-1+N1)+ZR(IMATUU-1+N2))*0.5D0
   35       CONTINUE
          ENDIF
        END IF
      ELSE IF (OPTION.EQ.'MASS_INER') THEN
        CALL JEVECH('PMASSINE','E',IMATUU)
        CALL DXROEP(RHO,EPAIS)

        IF(RHO.LE.R8PREM()) THEN
           CALL U2MESS('F','ELEMENTS5_45')
        ENDIF

        CALL DXINER(NNO,ZR(IGEOM),RHO,EPAIS,ZR(IMATUU),ZR(IMATUU+1),
     &              ZR(IMATUU+4))

C     -- OPTIONS NON-LINEAIRES
      ELSE IF (OPTION.EQ.'FULL_MECA'      .OR.
     &         OPTION.EQ.'RAPH_MECA'      .OR.
     &         OPTION.EQ.'RIGI_MECA_TANG' .OR.
     &         OPTION.EQ.'RIGI_MECA') THEN

        LRGM = OPTION.EQ.'RIGI_MECA       '

        IF(.NOT. LRGM) THEN
          CALL JEVECH('PDEPLMR','L',IDEPLM)
          CALL JEVECH('PDEPLPR','L',IDEPLP)
          CALL JEVECH('PCOMPOR','L',ICOMPO)
          COMP3 = ZK16(ICOMPO+3)

          IF (COMP3.EQ.'COMP_ELAS') THEN
            CALL U2MESS('F','ELEMENTS2_90')
          ENDIF

          IF (ZK16(ICOMPO+2)(6:10).EQ.'_REAC' .OR.
     &        ZK16(ICOMPO+2).EQ.'GROT_GDEP' ) THEN
            IF(ZK16(ICOMPO+2)(6:10).EQ.'_REAC')
     &        CALL U2MESS('A','ELEMENTS2_72')

            DO 40 I = 1,NNO
              I1 = 3* (I-1)
              I2 = 6* (I-1)
              ZR(IGEOM+I1)   = ZR(IGEOM+I1)   + ZR(IDEPLM+I2)
     &                                        + ZR(IDEPLP+I2)
              ZR(IGEOM+I1+1) = ZR(IGEOM+I1+1) + ZR(IDEPLM+I2+1) +
     &                                          ZR(IDEPLP+I2+1)
              ZR(IGEOM+I1+2) = ZR(IGEOM+I1+2) + ZR(IDEPLM+I2+2) +
     &                                          ZR(IDEPLP+I2+2)
   40       CONTINUE

            IF (NNO.EQ.3) THEN
              CALL DXTPGL(ZR(IGEOM),PGL)
            ELSE IF (NNO.EQ.4) THEN
              CALL DXQPGL(ZR(IGEOM),PGL)
            END IF

            CALL UTPVGL(NNO,3,PGL,ZR(IGEOM),XYZL)
          END IF

          CALL UTPVGL(NNO,6,PGL,ZR(IDEPLM),UML)
          CALL UTPVGL(NNO,6,PGL,ZR(IDEPLP),DUL)
          CALL JEVECH('PCARCRI','L',ICARCR)
        ELSE
          COMP3  = 'COMP_INCR       '
          COMPOR = 'GLRC_DM         '
        ENDIF

        IF (NOMTE.EQ.'MEDKTG3') THEN
          IF (COMP3(1:9).EQ.'COMP_INCR') THEN
            IF(LRGM) THEN
              CALL DXGLRC(NOMTE,OPTION,COMPOR,XYZL,UML,DUL,VECLOC,
     &                    MATLOC,EFFINT,PGL,ZR(ICARCR),CODRET)
            ELSE
              CALL DXGLRC(NOMTE,OPTION,ZK16(ICOMPO),XYZL,UML,DUL,VECLOC,
     &                    MATLOC,EFFINT,PGL,ZR(ICARCR),CODRET)
            ENDIF
          ELSEIF (COMP3 (1:9).EQ.'COMP_ELAS') THEN
            CALL U2MESS('F','ELEMENTS3_92')
          ENDIF
        ELSE IF (NOMTE.EQ.'MEDKQG4') THEN
          IF (COMP3(1:9).EQ.'COMP_INCR') THEN
            IF(LRGM) THEN
              CALL DXGLRC(NOMTE,OPTION,COMPOR,XYZL,UML,DUL,VECLOC,
     &                    MATLOC,EFFINT,PGL,ZR(ICARCR),CODRET)
            ELSE
              CALL DXGLRC(NOMTE,OPTION,ZK16(ICOMPO),XYZL,UML,DUL,VECLOC,
     &                    MATLOC,EFFINT,PGL,ZR(ICARCR),CODRET)
            ENDIF
          ELSEIF (COMP3 (1:9).EQ.'COMP_ELAS') THEN
            CALL U2MESS('F','ELEMENTS3_92')
          ENDIF
        ELSE
          CALL U2MESK('F','ELEMENTS2_74',1,NOMTE)
        END IF

        IF (OPTION.EQ.'FULL_MECA') THEN
          CALL JEVECH('PMATUUR','E',IMATUU)
          CALL JEVECH('PVECTUR','E',IVECTU)
          CALL UTPSLG(NNO,6,PGL,MATLOC,ZR(IMATUU))
          CALL UTPVLG(NNO,6,PGL,VECLOC,ZR(IVECTU))
        ELSE IF (OPTION.EQ.'RAPH_MECA') THEN
          CALL JEVECH('PVECTUR','E',IVECTU)
          CALL UTPVLG(NNO,6,PGL,VECLOC,ZR(IVECTU))
        ELSE IF (OPTION.EQ.'RIGI_MECA_TANG' .OR.
     &           OPTION.EQ.'RIGI_MECA' ) THEN
          CALL JEVECH('PMATUUR','E',IMATUU)
          CALL UTPSLG(NNO,6,PGL,MATLOC,ZR(IMATUU))
        END IF
      ELSEIF (OPTION.EQ.'EFGE_ELNO') THEN
         CALL JEVECH('PEFFORR','E',ICHN)

        CALL JEVECH('PGEOMER','L',IGEOM)
        CALL TECACH('NNN','PCOMPOR',1,ICOMPO,IRET)

        IF (NNO.EQ.3) THEN
          CALL DXTPGL(ZR(IGEOM),PGL)
        ELSE IF (NNO.EQ.4) THEN
          CALL DXQPGL(ZR(IGEOM),PGL)
        END IF

        CALL DXREPE( PGL, T2EV, T2VE)
        CALL TECACH('OON','PCONTRR',7,JTAB,IRET)
        CALL R8INIR(32,0.D0,EFFINT,1)

        DO 779,IPG=1,NPG
          ICONTM=JTAB(1)+8*(IPG-1)
          CALL DCOPY(8,ZR(ICONTM),1,EFFINT(8*(IPG-1)+1),1)
779     CONTINUE

C --- PASSAGE DU VECTEUR DES EFFORTS GENERALISES AUX POINTS
C --- D'INTEGRATION DU REPERE INTRINSEQUE AU REPERE LOCAL :
        CALL DXEFRO(NPG,T2VE,EFFINT,EFFIN2)

        IPG=1

        CALL PPGAN2(JGANO,1,8,EFFIN2,ZR(ICHN))
      ELSE IF (OPTION.EQ.'FORC_NODA') THEN
C --- VECTEUR DES EFFORTS GENERALISES AUX POINTS
C --- D'INTEGRATION DU REPERE LOCAL
        CALL TECACH('OON','PCONTMR',7,JTAB,IRET)

        DO 778,IPG=1,NPG
          ICONTM=JTAB(1)+8*(IPG-1)
          CALL DCOPY(8,ZR(ICONTM),1,EFFGT(8*(IPG-1)+1),1)
778     CONTINUE

C --- CALCUL DES EFFORTS INTERNES (I.E. SOMME_VOL(BT_SIG))
        CALL DXBSIG(NOMTE,XYZL,PGL,EFFGT,BSIGMA)

C --- AFFECTATION DES VALEURS DE BSIGMA AU VECTEUR EN SORTIE
        CALL JEVECH('PVECTUR','E',IVECTU)

        K = 0

        DO 90 I = 1,NNO
          DO 80 J = 1,6
            K = K + 1
            ZR(IVECTU+K-1) = BSIGMA(K)
   80     CONTINUE
   90   CONTINUE
      ELSE
C OPTION DE CALCUL INVALIDE
        CALL ASSERT(.FALSE.)
      END IF

      IF ( OPTION(1:9).EQ.'FULL_MECA'  .OR.
     &     OPTION(1:9).EQ.'RAPH_MECA'  ) THEN
         CALL JEVECH ( 'PCODRET', 'E', JCRET )
         ZI(JCRET) = CODRET
      ENDIF

      END
