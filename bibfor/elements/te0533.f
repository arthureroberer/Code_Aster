      SUBROUTINE TE0533(OPTION,NOMTE)
      IMPLICIT   NONE
      CHARACTER*16 OPTION,NOMTE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 08/11/2011   AUTEUR MACOCCO K.MACOCCO 
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
C RESPONSABLE GENIAUT S.GENIAUT
C TOLE CRP_20

C
C         CALCUL DES MATRICES DE CONTACT FROTTEMENT POUR X-FEM
C                       (METHODE CONTINUE)
C
C
C  OPTION : 'RIGI_CONT' (CALCUL DES MATRICES DE CONTACT)
C  OPTION : 'RIGI_FROT' (CALCUL DES MATRICES DE FROTTEMENT)

C  ENTREES  ---> OPTION : OPTION DE CALCUL
C           ---> NOMTE  : NOM DU TYPE ELEMENT
C
C......................................................................
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX --------------------
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

C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX --------------------

      INTEGER      I,J,K,IJ,IFA,IPGF,ISSPG,NI,PLI
      INTEGER      JINDCO,JDONCO,JLSN,IPOIDS,IVF,IDFDE,JGANO,IGEOM
      INTEGER      IDEPM,IDEPD,IMATT,JLST,JPTINT,JAINT,JCFACE,JLONCH
      INTEGER      IPOIDF,IVFF,IDFDEF,IADZI,IAZK24,IBID,JBASEC,JSEUIL
      INTEGER      NDIM,NFH,DDLC,DDLS,NDDL,NNO,NNOS,NNOM,NNOF,DDLM
      INTEGER      NPG,NPGF,XOULA,FAC(6,4),NBF
      INTEGER      INDCO(60),NINTER,NFACE,CFACE(5,3),IBID2(12,3)
      INTEGER      NINTEG,NFE,SINGU,JSTNO,NVIT,NVEC
      INTEGER      NNOL,PLA(27),LACT(8),NLACT,IMATE,JARVI
      INTEGER      IER,CONTAC,JCOHES,NPTF,NFISS,JFISNO
      REAL*8       FFP(27),FFC(8),KNP(3,3),RELA,SAUT(3)
      REAL*8       MMAT(216,216),JAC,RHON,MU,RHOTK,COEFBU,COEFFR
      REAL*8       TAU1(3),TAU2(3)
      REAL*8       ND(3),P(3,3),SEUIL(60)
      REAL*8       PTKNP(3,3),IK(3,3),CZMFE
      REAL*8       LSN,LST,R,RR,E,G(3),RBID
      REAL*8       CSTACO,CSTAFR,CPENCO,CPENFR,X(4)
      REAL*8       FFPC(27),DFBID(27,3),DSIDEP(6,6),SIGMA(6)
      REAL*8       AM(3),PP(3,3),DTANG(3),DNOR(3)
      REAL*8       ALPHA,COHES(60),COEFEC,COEFEF
      INTEGER      ZXAIN,XXMMVD,JHEANO,IFISS,JSTNC,JHEAFA,NCOMPH
      INTEGER      JTAB(2),IRET,NCOMPD,NCOMPP,NCOMPA,NCOMPB,NCOMPC
      INTEGER      IBASEC,IPTINT,IAINT
      LOGICAL      LPENAF,NOEUD,LPENAC,ADHER,MATSYM,NOTSYM,LELIM
      CHARACTER*8  ELREF,ELREFC,TYPMA,FPG,ELC,LAG,NOMRES(3),JOB
      CHARACTER*16 ENR
C......................................................................

      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      DO 6 I  = 1,8
        LACT(I) = 0
 6    CONTINUE
      CALL VECINI(27,0.D0,FFP)
      ZXAIN=XXMMVD('ZXAIN')
      LELIM = .FALSE.
      CALL ELREF1(ELREF)
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)
C
C     INITIALISATION DES DIMENSIONS DES DDLS X-FEM
      CALL XTEINI(NOMTE,NFH,NFE,SINGU,DDLC,NNOM,DDLS,NDDL,
     &            DDLM,NFISS,CONTAC)
C
      CALL TECAEL(IADZI,IAZK24)
      TYPMA=ZK24(IAZK24-1+3+ZI(IADZI-1+2)+3)
C
      IF (NDIM .EQ. 3) THEN
         CALL CONFAC(TYPMA,IBID2,IBID,FAC,NBF)
      ENDIF
C
C     INITIALISATION DE LA MATRICE DE TRAVAIL
      CALL MATINI(216,216,0.D0,MMAT)
C
C --- RECUPERATION DU TYPE DE CONTACT
C
      NOEUD=.FALSE.
      CALL TEATTR (NOMTE,'C','XLAG',LAG,IER)
      CALL ASSERT(IER.EQ.0)
      IF (LAG(1:5).EQ.'NOEUD') NOEUD=.TRUE.
      CALL ELELIN(CONTAC,ELREF,ELREFC,IBID,IBID)
C
C --- RECUPERATION DES ENTREES / SORTIE
C
      CALL JEVECH('PGEOMER','E',IGEOM)
C     DEPMOI
      CALL JEVECH('PDEPL_M','L',IDEPM)
C     DEPDEL
      CALL JEVECH('PDEPL_P','L',IDEPD)
      CALL JEVECH('PINDCOI','L',JINDCO)
      CALL JEVECH('PDONCO','L',JDONCO)
      CALL JEVECH('PSEUIL','L',JSEUIL)
      CALL JEVECH('PLSN','L',JLSN)
      CALL JEVECH('PLST','L',JLST)
      CALL JEVECH('PPINTER','L',JPTINT)
      CALL JEVECH('PAINTER','L',JAINT)
      CALL JEVECH('PCFACE','L',JCFACE)
      CALL JEVECH('PLONCHA','L',JLONCH)
      CALL JEVECH('PBASECO','L',JBASEC)
      IF (NFISS.GT.1) THEN
        CALL JEVECH('PFISNO','L',JFISNO)
        CALL JEVECH('PHEAVNO','L',JHEANO)
        CALL JEVECH('PHEAVFA','L',JHEAFA)
        CALL TECACH('OOO','PHEAVFA',2,JTAB,IRET)
        NCOMPH = JTAB(2)
      ENDIF
C     DIMENSSION DES GRANDEURS DANS LA CARTE
      CALL TECACH('OOO','PDONCO',2,JTAB,IRET)
      NCOMPD = JTAB(2)
      CALL TECACH('OOO','PPINTER',2,JTAB,IRET)
      NCOMPP = JTAB(2)
      CALL TECACH('OOO','PAINTER',2,JTAB,IRET)
      NCOMPA = JTAB(2)
      CALL TECACH('OOO','PBASECO',2,JTAB,IRET)
      NCOMPB = JTAB(2)
      CALL TECACH('OOO','PCFACE',2,JTAB,IRET)
      NCOMPC = JTAB(2)

C     STATUT POUR L'�LIMINATION DES DDLS DE CONTACT
      CALL WKVECT('&&TE0533.STNC','V V I',MAX(1,NFH)*NNOS,JSTNC)
      DO 30 I=1,MAX(1,NFH)*NNOS
        ZI(JSTNC-1+I) = 1
  30  CONTINUE

      CALL TEATTR(NOMTE,'S','XFEM',ENR,IBID)
C
C --- BOUCLE SUR LES FISSURES
C
      DO 90 IFISS = 1,NFISS
        IF (ENR.EQ.'XHC') THEN
          RELA  = ZR(JDONCO-1+(IFISS-1)*NCOMPD+10)
          CZMFE = ZR(JDONCO-1+(IFISS-1)*NCOMPD+11)
        ELSE
          RELA  = 0.D0
          CZMFE = 0.D0
        ENDIF
C
        IF(RELA.EQ.1.D0.OR.RELA.EQ.2.D0) THEN
          CALL JEVECH('PMATERC','L',IMATE)
          IMATE = IMATE + 60*(IFISS-1)
          CALL JEVECH('PCOHES' ,'L',JCOHES)
        ENDIF
C
C --- RECUPERATIONS DES DONNEES SUR LE CONTACT & TOPOLOGIE DES FACETTES
C
        NINTER=ZI(JLONCH+3*(IFISS-1)-1+1)
        IF (NINTER.EQ.0) GOTO 90
        NFACE=ZI(JLONCH+3*(IFISS-1)-1+2)
        NPTF=ZI(JLONCH+3*(IFISS-1)-1+3)
        DO 11 I=1,NFACE
          DO 12 J=1,NPTF
            CFACE(I,J)=ZI(JCFACE-1+NCOMPC*(IFISS-1)+NPTF*(I-1)+J)
 12       CONTINUE
 11     CONTINUE
        IBASEC = JBASEC + NCOMPB*(IFISS-1)
        IPTINT = JPTINT + NCOMPP*(IFISS-1)
        IAINT  = JAINT + NCOMPA*(IFISS-1)
C
        DO 10 I=1,60
          INDCO(I) = ZI(JINDCO-1+60*(IFISS-1)+I)
          SEUIL(I) = ZR(JSEUIL-1+60*(IFISS-1)+I)
          IF(RELA.EQ.1.D0.OR.RELA.EQ.2.D0) THEN
             COHES(I) = ZR(JCOHES-1+60*(IFISS-1)+I)
          ENDIF
 10     CONTINUE

        RHON   = ZR(JDONCO-1+(IFISS-1)*NCOMPD+1)
        MU     = ZR(JDONCO-1+(IFISS-1)*NCOMPD+2)
        RHOTK  = ZR(JDONCO-1+(IFISS-1)*NCOMPD+3)

C --- COEFFICIENTS DE STABILISATION
        CSTACO = ZR(JDONCO-1+(IFISS-1)*NCOMPD+6)
        CSTAFR = ZR(JDONCO-1+(IFISS-1)*NCOMPD+7)
C
C --- COEFFICIENTS DE PENALISATION
        CPENCO = ZR(JDONCO-1+(IFISS-1)*NCOMPD+8)
        CPENFR = ZR(JDONCO-1+(IFISS-1)*NCOMPD+9)
C
        IF (CSTACO.EQ.0.D0) CSTACO=RHON
        IF (CSTAFR.EQ.0.D0) CSTAFR=RHOTK
C
        IF (CPENCO.EQ.0.D0) CPENCO=RHON
        IF (CPENFR.EQ.0.D0) CPENFR=RHOTK
C
C     PENALISATION PURE
C     PENALISATION DU CONTACT
        LPENAC=.FALSE.
        IF (CSTACO.EQ.0.D0) THEN
          CSTACO=CPENCO
          IF(CPENCO.NE.0.0D0)LPENAC=.TRUE.
        ENDIF
C     PENALISATION DU FROTTEMENT
        LPENAF=.FALSE.
        IF (CSTAFR.EQ.0.D0) THEN
          IF(CPENFR.NE.0.0D0)LPENAF=.TRUE.
        ENDIF
C
C     COEFFICIENT DE MISE � L'ECHELLE DE CONTACT
C
      IF(LPENAC) COEFEC = CPENCO
      IF(.NOT.LPENAC) COEFEC = ZR(JDONCO-1+(IFISS-1)*NCOMPD+5)
      IF(LPENAF) COEFEF = CPENFR
      IF(.NOT.LPENAF) COEFEF = 1.D0
C
      IF(RELA.EQ.1.D0.OR.RELA.EQ.2.D0) THEN
        IF(CZMFE.EQ.1.D0) THEN
          CSTACO=COEFEC
          LPENAC=.FALSE.
        ENDIF
      ENDIF
C
C --- SCHEMA D'INTEGRATION NUMERIQUE ET ELEMENT DE REFERENCE DE CONTACT
C     DISCUSSION VOIR BOOK IV 18/10/2004 ET BOOK VI 06/07/2005
        NINTEG = NINT(ZR(JDONCO-1+(IFISS-1)*NCOMPD+4))
        CALL XMINTE(NDIM,NINTEG,FPG)
C
        IF (NDIM .EQ. 3) THEN
          ELC='TR3'
        ELSEIF (NDIM.EQ.2) THEN
          IF(CONTAC.LE.2) THEN
            ELC='SE2'
          ELSE
            ELC='SE3'
          ENDIF
        ENDIF
C
        CALL ELREF4(ELC,FPG,IBID,NNOF,IBID,NPGF,IPOIDF,IVFF,IDFDEF,IBID)
C
C --- LISTE DES LAMBDAS ACTIFS
C
        IF(NOEUD) THEN
          CALL XLACTI(TYPMA,NINTER,IAINT,LACT,NLACT)
          IF (NLACT.LT.NNO) LELIM = .TRUE.
        ENDIF
        IF (NFISS.EQ.1) THEN
          DO 50 I=1,NNOS
            IF (LACT(I).EQ.0) ZI(JSTNC-1+I)=0
  50      CONTINUE
        ELSE
          DO 60 I=1,NNOS
            IF (LACT(I).EQ.0) ZI(JSTNC-1+(I-1)*NFH+
     &                       ZI(JHEANO-1+(I-1)*NFISS+IFISS))=0
  60      CONTINUE
        ENDIF
C
C --- BOUCLE SUR LES FACETTES
C
        DO 100 IFA=1,NFACE

C --- NOMBRE DE LAMBDAS ET LEUR PLACE DANS LA MATRICE
          IF (NOEUD) THEN
            IF (CONTAC.EQ.1 .OR. CONTAC.EQ.4) NNOL=NNO
            IF (CONTAC.EQ.3) NNOL=NNOS
            DO 15 I=1,NNOL
              CALL XPLMAT(NDIM,NFH,NFE,DDLC,DDLM,NNO,NNOM,I,PLI)
              IF (NFISS.EQ.1) THEN
                PLA(I) = PLI
              ELSE
                PLA(I) = PLI+NDIM*(ZI(JHEANO-1+(I-1)*NFISS+IFISS)-1)
              ENDIF
 15         CONTINUE
          ELSE
            NNOL=NNOF
            DO 16 I=1,NNOF
C             XOULA  : RENVOIE LE NUMERO DU NOEUD PORTANT CE LAMBDA
              NI=XOULA(CFACE,IFA,I,JAINT,TYPMA,CONTAC)
C             PLACE DU LAMBDA DANS LA MATRICE
              CALL XPLMAT(NDIM,NFH,NFE,DDLC,DDLM,NNO,NNOM,NI,PLI)
              PLA(I)=PLI
 16         CONTINUE
          ENDIF
C
C --- BOUCLE SUR LES POINTS DE GAUSS DES FACETTES
C
          DO 110 IPGF=1,NPGF
C
C --- INDICE DE CE POINT DE GAUSS DANS INDCO
C
            ISSPG=NPGF*(IFA-1)+IPGF
C
C --- CALCUL DE JAC (PRODUIT DU JACOBIEN ET DU POIDS)
C --- ET DES FF DE L'ELEMENT PARENT AU POINT DE GAUSS
C --- ET LA NORMALE ND ORIENT�E DE ESCL -> MAIT
C
            IF (NDIM.EQ.3) THEN
            CALL XJACFF(ELREF,ELREFC,ELC,NDIM,FPG,IPTINT,IFA,CFACE,IPGF,
     &                  NNO,IGEOM,IBASEC,G,'NON',JAC,FFP,FFPC,DFBID,ND,
     &                  TAU1,TAU2)
            ELSEIF (NDIM.EQ.2) THEN
            CALL XJACF2(ELREF,ELREFC,ELC,NDIM,FPG,IPTINT,IFA,CFACE,NPTF,
     &                  IPGF,NNO,IGEOM,IBASEC,G,'NON',JAC,FFP,FFPC,
     &                  DFBID,ND,TAU1)
            ENDIF
C
C --- CALCUL DES FONCTIONS DE FORMES DE CONTACT DANS LE CAS LAG NOEUD
C
C        CALCUL DES FONCTIONS DE FORMES DE CONTACT DANS LE CAS LAG NOEUD
            IF (CONTAC.EQ.1) THEN
              CALL XMOFFC(LACT,NLACT,NNO,FFP,FFC)
            ELSEIF (CONTAC.EQ.3) THEN
              CALL XMOFFC(LACT,NLACT,NNOS,FFPC,FFC)
            ELSEIF (CONTAC.EQ.4) THEN
              CALL XMOFFC(LACT,NLACT,NNO,FFP,FFC)
            ENDIF
C
C --- CE POINT DE GAUSS EST-IL SUR UNE ARETE?
C
            K=0
            DO 17 I=1,NINTER
              IF (K.EQ.0) THEN
                X(4)=0.D0
                DO 20 J=1,NDIM
                  X(J)=ZR(IPTINT-1+NDIM*(I-1)+J)
 20             CONTINUE
                DO 21 J=1,NDIM
                  X(4) = X(4) + (X(J)-G(J))*(X(J)-G(J))
 21             CONTINUE
                X(4) = SQRT(X(4))
                IF (X(4).LT.1.D-12) THEN
                  K=I
                  GOTO 17
                ENDIF
              ENDIF
 17         CONTINUE
C
            IF (K.NE.0) THEN
              NVIT = NINT(ZR(IAINT-1+ZXAIN*(K-1)+5))
            ELSE
              NVIT = 0
            ENDIF
C           IL NE FAUT PAS UTILISER NVIT SI LE SCHEMA D'INTEGRATION
C           NE CONTIENT PAS DE NOEUDS
            IF ((FPG(1:3).EQ.'FPG').OR.(FPG.EQ.'GAUSS')
     &             .OR.(FPG.EQ.'XCON')) NVIT=1
C
C --- CALCUL DE RR = SQRT(DISTANCE AU FOND DE FISSURE)
C
            IF (SINGU.EQ.1) THEN
              LSN=0.D0
              LST=0.D0
              DO 112 I=1,NNO
                LSN=LSN+ZR(JLSN-1+I)*FFP(I)
                LST=LST+ZR(JLST-1+I)*FFP(I)
 112          CONTINUE
C             LSN NON NUL SUR LA SURFACE
              CALL ASSERT(ABS(LSN).LE.1.D-3)
              R=ABS(LST)
              RR=SQRT(R)
            ENDIF
C
C --- CALCUL DES MATRICES DE CONTACT
C     ..............................

            IF (OPTION.EQ.'RIGI_CONT') THEN
              IF (INDCO(ISSPG).EQ.0) THEN
                IF (NVIT.NE.0) THEN
C
C --- CALCUL DE LA MATRICE C - CAS SANS CONTACT
C
                  CALL XMMAA4(NNOL,NNOF,PLA,IPGF,IVFF,FFC,
     &                        COEFEC,JAC,NOEUD,CSTACO,MMAT)
                ENDIF

              ELSE IF (INDCO(ISSPG).EQ.1) THEN
C
C --- CALCUL DES MATRICES A, AT, AU - CAS DU CONTACT
C
                CALL XMMAA3(NDIM,NNO,NNOS,NNOL,NNOF,PLA,IPGF,IVFF,
     &                    FFC,FFP,COEFEC,JAC,NFH,NOEUD,ND,CPENCO,CSTACO,
     &                    SINGU,RR,DDLS,DDLM,LPENAC,
     &                    JFISNO,NFISS,IFISS,JHEAFA,NCOMPH,IFA,
     &                    MMAT )
C
              ELSE
                CALL ASSERT(INDCO(ISSPG).EQ.0 .OR. INDCO(ISSPG).EQ.1)
              END IF
C
C --- CALCUL DES MATRICES DE FROTTEMENT
C     .................................

            ELSEIF (OPTION.EQ.'RIGI_FROT') THEN

              IF (MU.EQ.0.D0.OR.SEUIL(ISSPG).EQ.0.D0) INDCO(ISSPG) = 0
              IF (NFISS.GT.1) INDCO(ISSPG) = 0
              IF (INDCO(ISSPG).EQ.0) THEN
                IF (NVIT.NE.0) THEN
C
C --- CALCUL DE LA MATRICE F - CAS SANS CONTACT
C
                  CALL XMMAB6(NDIM,NNOL,NNOF,PLA,IPGF,IVFF,FFC,JAC,
     &                      NOEUD,TAU1,TAU2,COEFEF,IFA,CFACE,LACT,
     &                      MMAT)

                ENDIF
C
C --- ACTIVATION DE LA LOI COHESIVE & RECUPERATION DES
C --- PARAMETRES MATERIAUX
C
                IF(RELA.EQ.1.D0.OR.RELA.EQ.2.D0) THEN
C
C --- CALCUL DU SAUT DE DEPLACEMENT EQUIVALENT [[UEG]]
C
                   NVEC=2
                   CALL XMMSA3(NDIM,NNO,NNOS,FFP,NDDL,NVEC,ZR(IDEPD),
     &                       ZR(IDEPM),ZR(IDEPM),NFH,SINGU,RR,DDLS,DDLM,
     &                       JFISNO,NFISS,IFISS,JHEAFA,NCOMPH,IFA,
     &                       SAUT)
                   JOB='MATRICE'
                   CALL XMMSA2(NDIM ,IPGF  ,ZI(IMATE)   ,SAUT ,ND  ,
     &                       TAU1 ,TAU2  ,COHES(ISSPG),JOB  ,RELA,
     &                       ALPHA,DSIDEP,SIGMA       ,PP   ,DNOR,
     &                       DTANG,P     ,AM)     
C
C --- CALCUL DES MATRICES DE COHESION 
C
                   CALL XMMCO1(NDIM,NNO,DSIDEP,PP,P,
     &                       ND,NFH,DDLS,JAC,FFP,
     &                       SINGU,RR,TAU1,TAU2,MMAT)

                ENDIF
C
              ELSE IF (INDCO(ISSPG).EQ.1) THEN
C
C --- CALCUL DES INCREMENTS - D�PLACEMENTS & 
C --- SEMI-MULTIPLICATEUR DE FROTTEMENT
C
                CALL XMMSA1(NDIM,NNO,NNOS,NNOL,NNOF,PLA,IPGF,IVFF,
     &                    FFC,FFP,IDEPD ,IDEPM,NFH,NOEUD,ND,
     &                    TAU1,TAU2,SINGU,RR,IFA,CFACE,LACT,
     &                    DDLS,DDLM,RHOTK,CSTAFR,CPENFR,LPENAF,
     &                    P,ADHER,KNP,PTKNP,IK )
C
C --- CALCUL DE B, BT
C
                CALL XMMAB3(NDIM,NNO,NNOS,NNOL,NNOF,PLA,IPGF,IVFF,
     &                    FFC,FFP,JAC,KNP,NFH,NOEUD ,SEUIL(ISSPG),
     &                    COEFEF,TAU1,TAU2,MU,SINGU,RR,IFA,CFACE,
     &                    LACT,DDLS,DDLM,
     &                    LPENAF,MMAT)
C
                IF (ADHER) THEN
C               CAS ADHERENT, TERME DE PENALISATION:
C               ON A ALORS PTKNP=PT.ID.P
                COEFBU=CPENFR
                ELSE
                  IF (LPENAF) THEN
C                 CAS GLISSANT, PENALISATION SEULE
                    COEFBU=CPENFR
                  ELSE
C                 CAS GLISSANT
                    COEFBU=CSTAFR
                  ENDIF
                ENDIF
C
C --- CALCUL DE B_U
C
                CALL XMMAB4(NDIM,NNO,NNOS,FFP,JAC,PTKNP,
     &                    NFH ,SEUIL(ISSPG),MU,SINGU,
     &                    RR,COEFBU,DDLS,DDLM,
     &                    MMAT )
C
                IF ((.NOT.ADHER).OR.LPENAF) THEN
C               LE COEFFICIENT DE F_R EST CELUI DE STABILISATION
                  COEFFR=CSTAFR
C               SAUF EN CAS DE PENALISATION SEULE
                  IF (LPENAF) COEFFR=CPENFR
C
C --- CALCUL DE F - CAS GLISSANT OU PENALISATION (NON SEULE)
C
                    CALL XMMAB5(NDIM,NNOL,NNOF,PLA,IPGF,IVFF,
     &                        FFC,JAC,COEFFR,COEFEF,NOEUD,
     &                        SEUIL(ISSPG),TAU1,TAU2,MU,IK,IFA,
     &                        CFACE,LACT,LPENAF,MMAT )
                ENDIF
C
              ELSE
                CALL ASSERT(INDCO(ISSPG).EQ.0 .OR. INDCO(ISSPG).EQ.1)
              END IF
            ELSE
              CALL ASSERT(OPTION.EQ.'RIGI_FROT' .OR.
     &                  OPTION.EQ.'RIGI_CONT')
            ENDIF

C --- FIN DE BOUCLE SUR LES POINTS DE GAUSS
 110      CONTINUE

C --- FIN DE BOUCLE SUR LES FACETTES
 100    CONTINUE
C --- FIN BOUCLE SUR LES FISSURES
  90  CONTINUE
C
C-----------------------------------------------------------------------
C     COPIE DES CHAMPS DE SORTIES ET FIN
C-----------------------------------------------------------------------
C
      IF(LPENAC.OR.LPENAF)THEN
C --- RECUPERATION DE LA MATRICE 'OUT' NON SYMETRIQUE
        MATSYM=.FALSE.
        CALL JEVECH('PMATUNS','E',IMATT)
        DO 201 J = 1,NDDL
          DO 211 I = 1,NDDL
            IJ = J+NDDL*(I-1)
            ZR(IMATT+IJ-1) = MMAT(I,J)
 211      CONTINUE
 201    CONTINUE
      ELSE
C --- RECUPERATION DE LA MATRICE 'OUT' SYMETRIQUE
        MATSYM=.TRUE.
        CALL JEVECH('PMATUUR','E',IMATT)
        DO 200 J = 1,NDDL
          DO 210 I = 1,J
            IJ = (J-1)*J/2 + I
            ZR(IMATT+IJ-1) = MMAT(I,J)
 210      CONTINUE
 200    CONTINUE
      ENDIF
      CALL TEATTR (NOMTE,'C','XLAG',LAG,IBID)
      IF (IBID.EQ.0.AND.LAG.EQ.'ARETE') THEN
        NNO = NNOS
      ENDIF
C --- SUPPRESSION DES DDLS DE DEPLACEMENT SEULEMENT POUR LES XHTC
      IF (NFH.NE.0) THEN
        CALL JEVECH('PSTANO' ,'L',JSTNO)
        CALL XTEDDL(NDIM,NFH,NFE,DDLS,NDDL,NNO,NNOS,ZI(JSTNO),
     &              .FALSE.,MATSYM,OPTION,NOMTE,ZR(IMATT),RBID,DDLM,
     &              NFISS,JFISNO)
      ENDIF
C --- SUPPRESSION DES DDLS DE CONTACT
      IF (LELIM) THEN
        CALL XTEDDL(NDIM,NFH,NFE,DDLS,NDDL,NNO,NNOS,ZI(JSTNC),
     &              .TRUE.,MATSYM,OPTION,NOMTE,ZR(IMATT),RBID,DDLM,
     &              NFISS,JFISNO)
      ENDIF
C
      CALL JEDETR('&&TE0533.STNC')
C
      CALL JEDEMA()
      END
