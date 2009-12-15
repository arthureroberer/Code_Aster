      SUBROUTINE PJ1DTR(CORTR3,CORRES,NUTM1D,ELRF1D)
      IMPLICIT NONE
      CHARACTER*16 CORRES,CORTR3
      CHARACTER*8 ELRF1D(3)
      INTEGER NUTM1D(3)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 14/12/2009   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C     BUT :
C       TRANSFORMER CORTR3 EN CORRES EN UTILISANT LES FONC. DE FORME
C       DES MAILLES DU MAILLAGE1 (EN 1D ISOPARAMETRIQUE)

C
C  IN/JXIN   CORTR3   K16 : NOM DU CORRESP_2_MAILLA FAIT AVEC LES SEG2
C  IN/JXOUT  CORRES   K16 : NOM DU CORRESP_2_MAILLA FINAL
C  IN        NUTM1D(3) I  : NUMEROS DES 3 TYPES DE MAILLES 1D (SEGX)
C  IN        ELRF1D(5) K8 : NOMS DES 3 TYPES DE MAILLES 1D  (SEGX)
C ----------------------------------------------------------------------
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
      INTEGER        NBNOMX,    NBFAMX
      PARAMETER    ( NBNOMX=27, NBFAMX=20)
      CHARACTER*8  M1, M2, KB, ELREFA, FAPG(NBFAMX)
      INTEGER NBPG(NBFAMX),I1CONB,I1CONU,I1COCF,I1COTR,NNO1,IE,NNO2,NMA1
      INTEGER NMA2,IALIM1,IALIN1,IATR3,IACNX1,ILCNX1,IATYMA,I2CONO
      INTEGER I2CONB,I2COM1,IDECA2,INO2,ITR,IMA1,NBNO,I2CONU,I2COCF
      INTEGER IDECA1, ITYPM,NUTM,INDIIS,NDIM,NNO,NNOS,NBFPG,KK,INO
      INTEGER NUNO,I1CONO,IALIN2,I2COCO
      REAL*8       CRREFE(3*NBNOMX), KSI,  X(1), FF(NBNOMX),VOL,X1
C --- DEB --------------------------------------------------------------

      CALL JEMARQ()


C     1. RECUPERATION DES INFORMATIONS GENERALES :
C     -----------------------------------------------
      CALL JEVEUO(CORTR3//'.PJEF_NO','L',I1CONO)
      CALL JEVEUO(CORTR3//'.PJEF_NB','L',I1CONB)
      CALL JEVEUO(CORTR3//'.PJEF_NU','L',I1CONU)
      CALL JEVEUO(CORTR3//'.PJEF_CF','L',I1COCF)
      CALL JEVEUO(CORTR3//'.PJEF_TR','L',I1COTR)

      M1=ZK8(I1CONO-1+1)
      M2=ZK8(I1CONO-1+2)
      CALL DISMOI('F','NB_NO_MAILLA', M1,'MAILLAGE',NNO1,KB,IE)
      CALL DISMOI('F','NB_NO_MAILLA', M2,'MAILLAGE',NNO2,KB,IE)
      CALL DISMOI('F','NB_MA_MAILLA', M1,'MAILLAGE',NMA1,KB,IE)
      CALL DISMOI('F','NB_MA_MAILLA', M2,'MAILLAGE',NMA2,KB,IE)

      CALL JEVEUO('&&PJXXCO.LIMA1','L',IALIM1)
      CALL JEVEUO('&&PJXXCO.LINO1','L',IALIN1)
      CALL JEVEUO('&&PJXXCO.LINO2','L',IALIN2)
      CALL JEVEUO('&&PJXXCO.SEG2','L',IATR3)

      CALL JEVEUO(M1//'.CONNEX','L',IACNX1)
      CALL JEVEUO(JEXATR(M1//'.CONNEX','LONCUM'),'L',ILCNX1)
      CALL JEVEUO(M1//'.TYPMAIL','L',IATYMA)


C     2. ALLOCATION DE CORRES :
C     -----------------------------------------------
      CALL WKVECT(CORRES//'.PJEF_NO','V V K8',2,I2CONO)
      ZK8(I2CONO-1+1)=M1
      ZK8(I2CONO-1+2)=M2


C     2.1 REMPLISSAGE DE .PJEF_NB ET .PJEF_M1:
C     ----------------------------------------
      CALL WKVECT(CORRES//'.PJEF_NB','V V I',NNO2,I2CONB)
      CALL WKVECT(CORRES//'.PJEF_M1','V V I',NNO2,I2COM1)
      IDECA2=0
      DO 10, INO2=1,NNO2
C       ITR : SEG2 ASSOCIE A INO2
        ITR=ZI(I1COTR-1+INO2)
        IF (ITR.EQ.0) GO TO 10
C       IMA1 : MAILLE DE M1 ASSOCIEE AU SEG2 ITR
        IMA1=ZI(IATR3+3*(ITR-1)+3)
        NBNO=ZI(ILCNX1+IMA1)-ZI(ILCNX1-1+IMA1)
        ZI(I2CONB-1+INO2)=NBNO
        ZI(I2COM1-1+INO2)=IMA1
        IDECA2=IDECA2+NBNO
10    CONTINUE
      IF (IDECA2.EQ.0) CALL U2MESS('F','CALCULEL3_97')

C     2.2 ALLOCATION DE .PJEF_NU .PJEF_CF .PJEF_CO:
C         (ET REMPLISSAGE DE CES 3 OBJETS)
C     ------------------------------------------------------
      CALL WKVECT(CORRES//'.PJEF_NU','V V I',IDECA2,I2CONU)
      CALL WKVECT(CORRES//'.PJEF_CF','V V R',IDECA2,I2COCF)
      CALL WKVECT(CORRES//'.PJEF_CO','V V R',3*NNO2,I2COCO)
      IDECA1=0
      IDECA2=0
      DO 20, INO2=1,NNO2
C       ITR : SEG2 ASSOCIE A INO2
        ITR = ZI(I1COTR-1+INO2)
        IF (ITR.EQ.0) GO TO 20
C       IMA1 : MAILLE DE M1 ASSOCIE AU SEG2 ITR
        IMA 1= ZI(IATR3+3*(ITR-1)+3)
C       ITYPM : TYPE DE LA MAILLE IMA1
        ITYPM = ZI(IATYMA-1+IMA1)
        NUTM   = INDIIS(NUTM1D,ITYPM,1,3)
        ELREFA = ELRF1D(NUTM)
        NBNO   = ZI(ILCNX1+IMA1)-ZI(ILCNX1-1+IMA1)

        CALL ELRACA(ELREFA,NDIM,NNO,NNOS,NBFPG,FAPG,NBPG,CRREFE,VOL)
        CALL ASSERT(NBNO.EQ.NNO)


C       2.2.1 DETERMINATION DES COORDONEES DE INO2 DANS L'ELEMENT
C             DE REFERENCE : KSI
C     -----------------------------------------------------------
        KSI=0.D0
        DO 771,KK=1,2
          X1 = CRREFE(NDIM*(KK-1)+1)
          KSI = KSI + ZR(I1COCF-1+IDECA1+KK)*X1
771     CONTINUE
        X(1) = KSI
        ZR(I2COCO+3*(INO2-1)+1)=X(1)


C       2.2.2 :
C       CALCUL DES F. DE FORME AUX NOEUDS POUR LE POINT KSI
C       -------------------------------------------------------
        CALL ELRFVF(ELREFA,X,27,FF,NNO)
        DO 22,INO=1,NBNO
          NUNO = ZI(IACNX1+ ZI(ILCNX1-1+IMA1)-2+INO)
          ZI(I2CONU-1+IDECA2+INO) = NUNO
          ZR(I2COCF-1+IDECA2+INO) = FF(INO)
22      CONTINUE

        IDECA1=IDECA1+2
        IDECA2=IDECA2+NBNO

20    CONTINUE

9999  CONTINUE
      CALL JEDEMA()
      END
