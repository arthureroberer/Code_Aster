      SUBROUTINE VDXNLR(OPTION,NOMTE,XI,RIG,NB1,CODRET)
C MODIF ELEMENTS  DATE 15/06/2004   AUTEUR MABBAS M.ABBAS 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
      IMPLICIT REAL*8 (A-H,O-Z)
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER ZI,JNBSPI,ITABM(8),ITABP(8)
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR,R8VIDE
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX --------------------
      CHARACTER*2 VALRET(26)
      CHARACTER*8 NOMRES(26),NOMPAR,NOMPU(2),TYPMOD(2)
      CHARACTER*10 PHENOM
      CHARACTER*16 OPTION,NOMTE
      INTEGER NB1,NB2,NDDLE,NPGE,NPGSR,NPGSN,ITAB(8),NZ,CODRET,COD
      REAL*8 XI(3,9)
      REAL*8 VECTA(9,2,3),VECTN(9,3),VECTPT(9,2,3),VECPT(9,3,3)
      REAL*8 VECTG(2,3),VECTT(3,3)
      REAL*8 HSFM(3,9),HSS(2,9),HSJ1M(3,9),HSJ1S(2,9)
      REAL*8 BTDM(4,3,42),BTDS(4,2,42)
      REAL*8 HSF(3,9),HSJ1FX(3,9),WGT
      REAL*8 BTDF(3,42),BTILD(5,42),WMATCB(5,42),KTILDI(42,42)
      REAL*8 KTILD(42,42),RIG(51,51)
      REAL*8 CTOR,EPAIS,KAPPA
      REAL*8 VALRES(26),VALPAR,VALPU(2)
      REAL*8 ROTFCM(9),ROTFCP(9)
      REAL*8 DEPLM(42),DEPLP(42)
      REAL*8 EPSANM(4),EPSANP(4),EPSI(5),DEPSI(5),EPS2D(4),DEPS2D(4)
      REAL*8 PHASM(7),PHASP(7)
      REAL*8 DTILD(5,5),SGMTD(5),EFFINT(42),VECL(48),VECLL(51)
      REAL*8 SIGN(4),SIGMA(4),DSIDEP(6,6),ANGMAS(3)
      REAL*8 HYDRGM,HYDRGP,SECHGM,SECHGP,SREF,LC
      LOGICAL VECTEU,MATRIC,TEMPNO
      PARAMETER (NPGE=3)
      REAL*8     KSI3S2

      RAC2 = SQRT(2.D0)
      TYPMOD(1) = 'C_PLAN  '
      TYPMOD(2) = '        '
      CODRET=0
C     RECUPERATION DES OBJETS
      CALL JEVETE('&INEL.'//NOMTE(1:8)//'.DESI',' ',LZI)
      NB1 = ZI(LZI-1+1)
      NB2 = ZI(LZI-1+2)
      NPGSR = ZI(LZI-1+3)
      NPGSN = ZI(LZI-1+4)

      CALL JEVETE('&INEL.'//NOMTE(1:8)//'.DESR',' ',LZR)

      VECTEU = ((OPTION.EQ.'FULL_MECA') .OR. (OPTION.EQ.'RAPH_MECA'))
      MATRIC = ((OPTION.EQ.'FULL_MECA') .OR.
     &         (OPTION.EQ.'RIGI_MECA_TANG'))

      CALL JEVECH('PMATERC','L',IMATE)
      NOMRES(1) = 'E'
      NOMRES(2) = 'NU'
      CALL JEVECH('PVARIMR','L',IVARIM)
      CALL JEVECH('PTEREF','L',ITREF)
      CALL JEVECH('PINSTMR','L',IINSTM)
      CALL JEVECH('PINSTPR','L',IINSTP)
      CALL JEVECH('PDEPLMR','L',IDEPLM)
      CALL JEVECH('PDEPLPR','L',IDEPLP)
      CALL JEVECH('PCOMPOR','L',ICOMPO)
      CALL JEVECH('PNBSP_I','L',JNBSPI)
      NBCOU=ZI(JNBSPI-1+1)
      IF (NBCOU.LE.0) CALL UTMESS('F','VDXNLR',
     &                 'NOMBRE DE COUCHES OBLIGATOIREMENT SUPERIEUR A 0'
     &                            )
      IF (NBCOU.GT.10) CALL UTMESS('F','VDXNLR',
     &                'NOMBRE DE COUCHES LIMITE A 10 POUR LES COQUES 3D'
     &                             )
      READ (ZK16(ICOMPO-1+2),'(I16)') NBVARI
      CALL TECACH('OON','PVARIMR',7,ITAB,IRET)
      LGPG = MAX(ITAB(6),1)*ITAB(7)
      CALL JEVECH('PCARCRI','L',ICARCR)
      CALL JEVECH('PCONTMR','L',ICONTM)

      CALL JEVECH('PCACOQU','L',JCARA)
      EPAIS = ZR(JCARA)
      KAPPA = ZR(JCARA+3)
      CTOR = ZR(JCARA+4)
      ZMIN = -EPAIS/2.D0
      HIC = EPAIS/NBCOU

      IF (VECTEU) THEN
        CALL JEVECH('PVECTUR','E',IVECTU)
        CALL JEVECH('PCONTPR','E',ICONTP)
        CALL JEVECH('PVARIPR','E',IVARIP)
      ELSE
C       -- POUR AVOIR UN TABLEAU BIDON A DONNER A NMCOMP :
        IVARIP = IVARIM
      END IF

C        LGPG=(NBVALC+6)*NPGH*NBCOU

        NDIMV=LGPG*NPGSN
        CALL JEVECH('PVARIMP','L',IVARIX)
        CALL R8COPY(NDIMV,ZR(IVARIX),1,ZR(IVARIP),1)

      NDDLE = 5*NB1 + 2

      CALL VECTAN(NB1,NB2,XI,ZR(LZR),VECTA,VECTN,VECTPT)

      DO 20 I = 1,NDDLE
        DO 10 J = 1,NDDLE
          KTILD(I,J) = 0.D0
   10   CONTINUE
        EFFINT(I) = 0.D0
   20 CONTINUE

      CALL RCCOMA(ZI(IMATE),'ELAS',PHENOM,VALRET)

      IF (PHENOM.EQ.'ELAS') THEN
        NBV = 2
        NOMRES(1) = 'E'
        NOMRES(2) = 'NU'
      ELSE
        CALL UTMESS('F','MATRC','COMPORTEMENT MATERIAU NON ADMIS')
      END IF

C===============================================================
C     -- RECUPERATION DE LA TEMPERATURE POUR LE MATERIAU:
C     -- SI LA TEMPERATURE EST CONNUE AUX NOEUDS :
      CALL TECACH ('ONN','PTEMPER',8,ITAB,IRET)
      ITEMP=ITAB(1)
      IF (ITEMP.NE.0) THEN
        TEMPNO = .TRUE.
        CALL TECACH ('OON','PTEMPMR',8,ITABM,IRET)
        CALL TECACH ('OON','PTEMPPR',8,ITABP,IRET)
        NBPAR = 1
        NOMPAR = 'TEMP'
        TPG1 = 0.D0
        DO 30 I = 1,NB2
          CALL DXTPIF(ZR(ITEMP+3*(I-1)),ZL(ITAB(8)+3*(I-1)))
          T = ZR(ITEMP+3* (I-1))
          TINF = ZR(ITEMP+1+3* (I-1))
          TSUP = ZR(ITEMP+2+3* (I-1))
          TPG1 = TPG1 + T + (TSUP+TINF-2*T)/6.D0
   30   CONTINUE
        VALPAR = TPG1/NB2
      ELSE
C     -- SI LA TEMPERATURE EST UNE FONCTION DE 'INST' ET 'EPAIS':
        CALL TECACH('ONN','PTEMPEF',1,ITEMPF,IRET)
        IF (ITEMPF.GT.0) THEN
          TEMPNO = .FALSE.
          NBPAR = 1
          NOMPAR = 'TEMP'
          NOMPU(1) = 'INST'
          NOMPU(2) = 'EPAIS'
          VALPU(1) = ZR(IINSTP)
          VALPU(2) = 0.D0
          CALL FOINTE('FM',ZK8(ITEMPF),2,NOMPU,VALPU,VALPAR,IER)
C     -- SI LA TEMPERATURE N'EST PAS DONNEE:
        ELSE
          TEMPNO = .TRUE.
          CALL TECACH ('OON','PTEMPMR',8,ITABM,IRET)
          CALL TECACH ('OON','PTEMPPR',8,ITABP,IRET)
          NBPAR = 0
          NOMPAR = ' '
          VALPAR = 0.D0
        END IF
      END IF
C===============================================================

      CALL RCVALA(ZI(IMATE),' ',PHENOM,NBPAR,NOMPAR,VALPAR,NBV,NOMRES,
     &            VALRES,VALRET,'FM')

      CISAIL = VALRES(1)/ (1.D0+VALRES(2))

C     CALCULS DES 2 DDL INTERNES

      CALL TRNDGL(NB2,VECTN,VECTPT,ZR(IDEPLM),DEPLM,ROTFCM)

      CALL TRNDGL(NB2,VECTN,VECTPT,ZR(IDEPLP),DEPLP,ROTFCP)

C     CALL DDLINT(NB1,VECTN,VECTPT,CISAIL,KAPPA,ZR(ICONTM),ZR(IDEPLP),
C    &                                                     DPLPIL,DQJ)

C     CONSTITUTION DES VECTEURS DEPLACEMENT ENTIER A NDDLE DDL
C     (DEPLACEMENT DE L'INSTANT PRECEDANT ET DE DEPLACEMENT INCREMENTAL)

C     DO 15 I=1,NDDLE
C        IF (I.LE.(NDDLE-2)) THEN
C           DEPLM(I)=DPLMIL(I)
C           DEPLP(I)=DPLPIL(I)
C        ELSE
C           DEPLM(I)=ZR( )
C           DEPLP(I)=DQJ(I)
C        ENDIF
C15   CONTINUE

C     POUR AVOIR UN TABLEAU BIDON A DONNER A NMCOMP

      DO 40 J = 1,4
        EPSANM(J) = 0.D0
        EPSANP(J) = 0.D0
   40 CONTINUE
      NZ =0
      DO 50 J = 1,7
        PHASM(J) = 0.D0
        PHASP(J) = 0.D0
   50 CONTINUE

      KWGT = 0
      KPGS = 0
      DO 140 ICOU = 1,NBCOU
        DO 130 INTE = 1,NPGE
          IF (INTE.EQ.1) THEN
            ZIC = ZMIN + (ICOU-1)*HIC
            COEF = 1.D0/3.D0
          ELSE IF (INTE.EQ.2) THEN
            ZIC = ZMIN + HIC/2.D0 + (ICOU-1)*HIC
            COEF = 4.D0/3.D0
          ELSE
            ZIC = ZMIN + HIC + (ICOU-1)*HIC
            COEF = 1.D0/3.D0
          END IF
          KSI3S2 = ZIC/HIC

C     CALCUL DE BTDMR, BTDSR : M=MEMBRANE , S=CISAILLEMENT , R=REDUIT

          DO 60 INTSR = 1,NPGSR
            CALL MAHSMS(0,NB1,XI,KSI3S2,INTSR,ZR(LZR),HIC,VECTN,VECTG,
     &                  VECTT,HSFM,HSS)

            CALL HSJ1MS(HIC,VECTG,VECTT,HSFM,HSS,HSJ1M,HSJ1S)

            CALL BTDMSR(NB1,NB2,KSI3S2,INTSR,ZR(LZR),HIC,VECTPT,
     &                  HSJ1M,HSJ1S,BTDM,BTDS)
   60     CONTINUE

C ---  VARIABLE D HYDRATATION ET DE SECHAGE

          HYDRGM = 0.D0
          HYDRGP = 0.D0
          SECHGM = 0.D0
          SECHGP = 0.D0
          SREF   = 0.D0
          DO 120 INTSN = 1,NPGSN
            K = 459 + 9* (INTSN-1)
C         -- CALCUL DES TEMPERATURES TPC ET TMC SUR LA COUCHE :
C         ---------------------------------------------------
            IF (TEMPNO) THEN
              TMPG1 = 0.D0
              TMPG2 = 0.D0
              TMPG3 = 0.D0
              TPPG1 = 0.D0
              TPPG2 = 0.D0
              TPPG3 = 0.D0

              DO 70 I = 1,NB2
C             TXPG1 = MOY , TXPG2 = INF , TXPG3 = SUP

                ITEMPM=ITABM(1)
                CALL DXTPIF(ZR(ITEMPM+3*(I-1)),ZL(ITABM(8)+3*(I-1)))
                TMPG1 = TMPG1 + ZR(ITEMPM+3*I-3)*ZR(LZR-1+K+I)
                TMPG2 = TMPG2 + ZR(ITEMPM+3*I-2)*ZR(LZR-1+K+I)
                TMPG3 = TMPG3 + ZR(ITEMPM+3*I-1)*ZR(LZR-1+K+I)

                ITEMPP=ITABP(1)
                CALL DXTPIF(ZR(ITEMPP+3*(I-1)),ZL(ITABP(8)+3*(I-1)))
                TPPG1 = TPPG1 + ZR(ITEMPP+3*I-3)*ZR(LZR-1+K+I)
                TPPG2 = TPPG2 + ZR(ITEMPP+3*I-2)*ZR(LZR-1+K+I)
                TPPG3 = TPPG3 + ZR(ITEMPP+3*I-1)*ZR(LZR-1+K+I)
   70         CONTINUE
              TMC = 2* (TMPG2+TMPG3-2*TMPG1)* (ZIC/EPAIS)* (ZIC/EPAIS) +
     &              (TMPG3-TMPG2)* (ZIC/EPAIS) + TMPG1
              TPC = 2* (TPPG2+TPPG3-2*TPPG1)* (ZIC/EPAIS)* (ZIC/EPAIS) +
     &              (TPPG3-TPPG2)* (ZIC/EPAIS) + TPPG1
            ELSE
              VALPU(2) = ZIC
              VALPU(1) = ZR(IINSTM)
              CALL FOINTE('FM',ZK8(ITEMPF),2,NOMPU,VALPU,TMC,IER)
              VALPU(1) = ZR(IINSTP)
              CALL FOINTE('FM',ZK8(ITEMPF),2,NOMPU,VALPU,TPC,IER)
            END IF

C     CALCUL DE BTDFN : F=FLEXION , N=NORMAL
C     ET DEFINITION DE WGT=PRODUIT DES POIDS ASSOCIES AUX PTS DE GAUSS
C                          (NORMAL) ET DU DETERMINANT DU JACOBIEN

            CALL MAHSF(1,NB1,XI,KSI3S2,INTSN,ZR(LZR),HIC,VECTN,VECTG,
     &                 VECTT,HSF)

            CALL HSJ1F(INTSN,ZR(LZR),HIC,VECTG,VECTT,HSF,KWGT,
     &                 HSJ1FX,WGT)

C     PRODUIT DU POIDS DES PTS DE GAUSS DANS L'EPAISSEUR ET DE WGT

            WGT = COEF*WGT

            CALL BTDFN(1,NB1,NB2,KSI3S2,INTSN,ZR(LZR),HIC,VECTPT,
     &                 HSJ1FX,BTDF)

C     CALCUL DE BTDMN, BTDSN
C     ET
C     FORMATION DE BTILD

            CALL BTDMSN(1,NB1,INTSN,NPGSR,ZR(LZR),BTDM,BTDF,
     &                  BTDS,BTILD)

C     CALCULS DES COMPOSANTES DE DEFORMATIONS TRIDIMENSIONNELLES :
C     EPSXX, EPSYY, EPSXY, EPSXZ, EPSYZ (CE SONT LES COMPOSANTES TILDE)
            KPGS = KPGS + 1
            CALL EPSEFF('DEFORM',NB1,DEPLM,BTILD,X,EPSI,WGT,X)
            EPS2D(1) = EPSI(1)
            EPS2D(2) = EPSI(2)
            EPS2D(3) = 0.D0
            EPS2D(4) = EPSI(3)/RAC2

            CALL EPSEFF('DEFORM',NB1,DEPLP,BTILD,X,DEPSI,WGT,X)
            DEPS2D(1) = DEPSI(1)
            DEPS2D(2) = DEPSI(2)
            DEPS2D(3) = 0.D0
            DEPS2D(4) = DEPSI(3)/RAC2

            GXZ = EPSI(4) + DEPSI(4)
            GYZ = EPSI(5) + DEPSI(5)

            K1 = 6* (KPGS-1)
            K2 = LGPG* (INTSN-1) + (NPGE* (ICOU-1)+INTE-1)*NBVARI
            DO 80 I = 1,3
              SIGN(I) = ZR(ICONTM-1+K1+I)
   80       CONTINUE
            SIGN(4) = ZR(ICONTM-1+K1+4)*RAC2
C - LOI DE COMPORTEMENT
C --- ANGLE DU MOT_CLEF MASSIF (AFFE_CARA_ELEM)
C --- INITIALISE A R8VIDE (ON NE S'EN SERT PAS)
            CALL R8INIR(3, R8VIDE(), ANGMAS ,1)
C -    APPEL A LA LOI DE COMPORTEMENT
            CALL NMCOMP(2,TYPMOD,ZI(IMATE),ZK16(ICOMPO),ZR(ICARCR),
     &                  ZR(IINSTM),ZR(IINSTP),
     &                  TMC,TPC,ZR(ITREF),
     &                  HYDRGM,HYDRGP,
     &                  SECHGM,SECHGP,SREF,
     &                  EPS2D,DEPS2D,
     &                  SIGN,ZR(IVARIM+K2),
     &                  OPTION,
     &                  EPSANM,EPSANP,
     &                  NZ,PHASM,PHASP,
     &                  R8VIDE(),R8VIDE(),
     &                  ANGMAS,
     &                  LC,
     &                  SIGMA,ZR(IVARIP+K2),DSIDEP,COD)

C           COD=1 : ECHEC INTEGRATION LOI DE COMPORTEMENT
C           COD=3 : C_PLAN DEBORST SIGZZ NON NUL
            IF (COD.NE.0) THEN
               IF (CODRET.NE.1) THEN
                  CODRET=COD
               ENDIF
            ENDIF

C    CALCULS DE LA MATRICE TANGENTE : BOUCLE SUR L'EPAISSEUR
            IF (MATRIC) THEN

              DTILD(1,1) = DSIDEP(1,1)
              DTILD(1,2) = DSIDEP(1,2)
              DTILD(1,3) = DSIDEP(1,4)/RAC2
              DTILD(1,4) = 0.D0
              DTILD(1,5) = 0.D0

              DTILD(2,1) = DSIDEP(2,1)
              DTILD(2,2) = DSIDEP(2,2)
              DTILD(2,3) = DSIDEP(2,4)/RAC2
              DTILD(2,4) = 0.D0
              DTILD(2,5) = 0.D0

              DTILD(3,1) = DSIDEP(4,1)/RAC2
              DTILD(3,2) = DSIDEP(4,2)/RAC2
              DTILD(3,3) = DSIDEP(4,4)/2.D0
              DTILD(3,4) = 0.D0
              DTILD(3,5) = 0.D0

              DTILD(4,1) = 0.D0
              DTILD(4,2) = 0.D0
              DTILD(4,3) = 0.D0
              DTILD(4,4) = CISAIL*KAPPA/2.D0
              DTILD(4,5) = 0.D0

              DTILD(5,1) = 0.D0
              DTILD(5,2) = 0.D0
              DTILD(5,3) = 0.D0
              DTILD(5,4) = 0.D0
              DTILD(5,5) = CISAIL*KAPPA/2.D0

              CALL R8SCAL(25,WGT,DTILD,1)

              CALL BTKB(5,42,NDDLE,DTILD,BTILD,WMATCB,KTILDI)

              DO 100 I = 1,NDDLE
                DO 90 J = 1,NDDLE
                  KTILD(I,J) = KTILD(I,J) + KTILDI(I,J)
   90           CONTINUE
  100         CONTINUE
            END IF

            IF (VECTEU) THEN

              DO 110 I = 1,3
                ZR(ICONTP-1+K1+I) = SIGMA(I)
  110         CONTINUE
              ZR(ICONTP-1+K1+4) = SIGMA(4)/RAC2
              ZR(ICONTP-1+K1+5) = CISAIL*KAPPA*GXZ/2.D0
              ZR(ICONTP-1+K1+6) = CISAIL*KAPPA*GYZ/2.D0

C    CALCULS DES EFFORTS INTERIEURS
              SGMTD(1) = ZR(ICONTP-1+K1+1)
              SGMTD(2) = ZR(ICONTP-1+K1+2)
              SGMTD(3) = ZR(ICONTP-1+K1+4)
              SGMTD(4) = CISAIL*KAPPA*GXZ/2.D0
              SGMTD(5) = CISAIL*KAPPA*GYZ/2.D0

              CALL EPSEFF('EFFORI',NB1,X,BTILD,SGMTD,X,WGT,EFFINT)

            END IF

  120     CONTINUE
  130   CONTINUE
  140 CONTINUE

      IF (MATRIC) THEN

C     EXPANSION DE LA MATRICE : AJOUTER DE LA ROTATION FICTIVE

        NDDLET = 6*NB1 + 3
        CALL MATRKB(NB1,42,51,NDDLET,KTILD,CTOR,RIG,COEF)
        ZR(LZR-1+1550) = COEF

C     AJOUTER DES 3 TRANSLATIONS FICTIVES ASSOCIEES AU NOEUD INTERNE
C     LES 3 TERMES DE RAIDEUR (FICTIVE) ASSOCIEES ONT POUR VALEUR CELLE
C     DES ROTATION FICTIVE
      END IF

      IF (VECTEU) THEN
        COEF = ZR(LZR-1+1550)

        CALL VEXPAN(NB1,EFFINT,VECL)

        DO 150 I = 1,6*NB1
          VECLL(I) = VECL(I)
  150   CONTINUE
        VECLL(6*NB1+1) = EFFINT(5*NB1+1)
        VECLL(6*NB1+2) = EFFINT(5*NB1+2)
        VECLL(6*NB1+3) = 0.D0

C     CONTRIBUTION DES DDL DE LA ROTATION FICTIVE DANS EFFINT

        DO 160 I = 1,NB1
          VECLL(6*I) = COEF* (ROTFCM(I)+ROTFCP(I))
  160   CONTINUE
        I = NB2
        VECLL(6*NB1+3) = COEF* (ROTFCM(NB2)+ROTFCP(NB2))
C     TRANFORMATION DANS REPERE GLOBAL PUIS STOCKAGE
        DO 190 IB = 1,NB2
          DO 180 I = 1,2
            DO 170 J = 1,3
              VECPT(IB,I,J) = VECTPT(IB,I,J)
  170       CONTINUE
  180     CONTINUE
          VECPT(IB,3,1) = VECTN(IB,1)
          VECPT(IB,3,2) = VECTN(IB,2)
          VECPT(IB,3,3) = VECTN(IB,3)
  190   CONTINUE

        CALL TRNFLG(NB2,VECPT,VECLL,ZR(IVECTU))
      END IF

      END
