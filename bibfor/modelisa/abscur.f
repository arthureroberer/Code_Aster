      SUBROUTINE ABSCUR(CONNEX,TYPMAI,COOVAL,NOMU,IT)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 04/04/2006   AUTEUR VABHHTS J.PELLET 
C ======================================================================
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
C-----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*8  NOMU, NSP
      CHARACTER*24 CONNEX, TYPMAI, COOVAL
C-----------------------------------------------------------------------
C     CALCUL D'UNE ABSCISSE CURVILIGNE POUR UN GROUPE DE MAILLES
C     " TOUTES LES MAILLES DOIVENT ETRE DU TYPE 'POI1' OU 'SEG2' "
C
C     ARGUMENTS EN ENTREE
C     ------------------
C
C     CONNEX : NOM DE L'OBJET CONNECTIVITE
C     TYPMAI : NOM CONTENANT LES TYPES DE MAILLES
C     COOVAL : NOM DE L'OBJET CONTENANT LES COORDONNEES DES NOEUDS
C     NOMU   : NOM DU MAILLAGE
C     IT     : =1 CALCUL SUR L'ENSEMBLE DU MAILLAGE
C
C     EN SORTIE
C     ---------
C
C     CREATION D'UNE CARTE: (APPEL A ALCART)
C
      CHARACTER*8        TYPM,K8BID
      CHARACTER*24       NOMMAI,CONSEG,TYPSEG
      INTEGER      PTCH,ADRM
C
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
      CHARACTER*1 K1BID
      CHARACTER*32 JEXNOM, JEXNUM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CALL JEMARQ()
      NSP = 'ABSCUR'
      IF (IT.EQ.1) THEN
        NOMMAI = NOMU//'.NOMMAI'
        CALL JELIRA(NOMMAI,'NOMUTI',NBRMA,K1BID)
        CALL WKVECT('&&ABSCURV.TEMP','V V I',NBRMA,IAGM)
        DO 11 IJ=1,NBRMA
          ZI(IAGM+IJ-1) = IJ
   11   CONTINUE
      ELSE
        CALL UTMESS('F',NSP,'L OPTION DE CALCUL D UNE ABSCISSE'//
     +                ' CURVILIGNE SUR UN GROUPE DE MAILLES'//
     +                ' N EST PAS IMPLANTEE')
      ENDIF
C
      NBRMA2 = 2*NBRMA
      NBRMA1 = NBRMA+1
C
C     CREATION D'OBJETS TEMPORAIRES
C
      CALL WKVECT('&&ABSCUR.TEMP.VOIS1','V V I',NBRMA,IAV1)
      CALL WKVECT('&&ABSCUR.TEMP.VOIS2','V V I',NBRMA,IAV2)
      CALL WKVECT('&&ABSCUR.TEMP.CHM  ','V V I',NBRMA1,PTCH)
      CALL WKVECT('&&ABSCUR.TEMP.IACHM','V V I',NBRMA2,IACH)
      CALL WKVECT('&&ABSCUR.TEMP.PLACE','V V L',NBRMA,LPLACE)
      CALL WKVECT('&&ABSCUR.TEMP.IPOI1','V V I',NBRMA,IMA1)
      CALL WKVECT('&&ABSCUR.TEMP.ISEG2','V V I',NBRMA,IMA2)
      CALL WKVECT('&&ABSCUR.TEMP.AB1  ','V V R',NBRMA,IAB1)
      CALL WKVECT('&&ABSCUR.TEMP.AB2  ','V V R',NBRMA,IAB2)
      CALL WKVECT('&&ABSCUR.TEMP.COR2 ','V V I',NBRMA,ICOR2)
C
C     TRI DES MAILLES POI1 ET SEG2
      NBSEG2=0
      NBPOI1=0
      KSEG=0
      DO 12 IM=1,NBRMA
        CALL JEVEUO (TYPMAI,'L',ITYPM)
        CALL JENUNO (JEXNUM('&CATA.TM.NOMTM',ZI(ITYPM+IM-1)),TYPM)
        IF      (TYPM .EQ. 'SEG2') THEN
           KSEG=ZI(ITYPM+IM-1)
           NBSEG2=NBSEG2+1
           ZI(IMA2+NBSEG2-1)=IM
        ELSE IF (TYPM .EQ. 'POI1') THEN
           NBPOI1=NBPOI1+1
           ZI(IMA1+NBPOI1-1)=IM
        ELSE
          CALL UTMESS('F',NSP,'IL EST POSSIBLE DE DEFINIR UNE'//
     +                ' ABSCISSE CURVILIGNE UNIQUEMENT POUR DES'//
     +                ' MAILLES DE TYPE: POI1 OU SEG2')
        ENDIF
 12   CONTINUE
      CONSEG='&&ABSCUR.CONNEX'
      TYPSEG='&&ABSCUR.TYPMAI'
      CALL WKVECT(TYPSEG,'V V I',NBRMA,ITYM)
      DO 13 IM=1,NBRMA
        ZI(ITYM-1+IM)=KSEG
 13   CONTINUE
C     IL FAUT CREER UNE TABLE DE CONNECTIVITE POUR LES SEG2
C
C -     OBJET CONSEG    = FAMILLE CONTIGUE DE VECTEURS N*IS
C                         POINTEUR DE NOM       = NOMMAI
C                         POINTEUR DE LONGUEUR  = CONSEG.$$LONC
C                         LONGUEUR TOTALE       = NBNOMA
C
      NBNOMA=2*NBSEG2
      CALL JECREC(CONSEG,'V V I','NU','CONTIG','VARIABLE',NBSEG2)
      CALL JEECRA(CONSEG,'LONT',NBNOMA,' ')
      DO 14 ISEG2=1,NBSEG2
        IM=ZI(IMA2+ISEG2-1)
        CALL JELIRA(JEXNUM(CONNEX,IM   ),'LONMAX',NBNOMA,K8BID)
        CALL JEVEUO(JEXNUM(CONNEX,IM   ),'L',IACNEX)
        CALL JEECRA(JEXNUM(CONSEG,ISEG2),'LONMAX',NBNOMA,' ')
        CALL JEVEUO(JEXNUM(CONSEG,ISEG2),'E',JGCNX)
        DO 3 INO =1,NBNOMA
           NUMNO=ZI(IACNEX-1+INO)
           ZI(JGCNX+INO-1)=NUMNO
  3     CONTINUE
 14   CONTINUE
C     IL FAUT VERIFIER L'INCLUSION DES POI1
      DO 15 IPOI1=1,NBPOI1
        IM=ZI(IMA1+IPOI1-1)
        CALL JEVEUO (JEXNUM(CONNEX,IM),'L',ADRM)
        N = ZI(ADRM)
        DO 16 ISEG2=1,NBSEG2
          CALL JEVEUO (JEXNUM(CONSEG,ISEG2),'L',IADR2)
          N1 = ZI(IADR2)
          N2 = ZI(IADR2 + 1)
          IF (N1.EQ.N) THEN
            ZI(ICOR2+IPOI1-1)= ISEG2
            GOTO 15
          ELSE IF (N2.EQ.N) THEN
            ZI(ICOR2+IPOI1-1)=-ISEG2
            GOTO 15
          ENDIF
   16   CONTINUE
        CALL UTMESS('F',NSP,'POINT NON TROUVE PARMI LES SEG2')
   15  CONTINUE


      CALL I2VOIS(CONSEG,TYPSEG,ZI(IAGM),NBSEG2,ZI(IAV1),ZI(IAV2))
      CALL I2TGRM(ZI(IAV1),ZI(IAV2),NBSEG2,ZI(IACH),ZI(PTCH),NBCHM)
C
      IF (NBCHM .GT. 1) THEN
        CALL UTMESS('F',NSP,'MAUVAISE DEFINITION POUR L ABS_CURV.'//
     +               ' DETECTION DE PLUSIEURS CHEMINS. ')
      ENDIF
C
      CALL I2SENS(ZI(IACH),2*NBSEG2,ZI(IAGM),NBSEG2,CONSEG,TYPSEG)
C
C     CREATION D'UNE CARTE
C
      CALL ALCAR2('G',NOMU//'.ABS_CURV  ',NOMU,'ABSC_R')
      CALL JEVEUO(NOMU//'.ABS_CURV  .NCMP','E',IANCMP)
      CALL JEVEUO(NOMU//'.ABS_CURV  .VALV','E',IAVALV)
      ZK8(IANCMP)   = 'ABSC1'
      ZK8(IANCMP+1) = 'ABSC2'
      STOT = 0.D0
C
C     CALCUL DE L'ABSCISSE CURVILIGNE
C
      DO 10 ISEG2 = 1,NBSEG2
        ISENS = 1
        MI = ZI(IACH+ISEG2-1)
        IF (MI .LT. 0) THEN
          MI = - MI
          ISENS = -1
        ENDIF
        IMA=ZI(IMA2+MI-1)
        CALL I2EXTF(MI,1,CONSEG,TYPSEG,ING,IND)
        CALL JEVEUO(COOVAL,'L',IVAL)
        IF (ISENS.EQ.1) THEN
          ICOO1 = 3*(ING-1)
          ICOO2 = 3*(IND-1)
        ELSE
          ICOO1 = 3*(IND-1)
          ICOO2 = 3*(ING-1)
        ENDIF
        X1 = ZR(IVAL + ICOO1)
        Y1 = ZR(IVAL + ICOO1 + 1)
        Z1 = ZR(IVAL + ICOO1 + 2)
        X2 = ZR(IVAL + ICOO2)
        Y2 = ZR(IVAL + ICOO2 + 1)
        Z2 = ZR(IVAL + ICOO2 + 2)
        S = SQRT((X2-X1)**2+(Y2-Y1)**2+(Z2-Z1)**2)
        ZR(IAVALV  ) = STOT
        ZR(IAB1+MI-1)= STOT
        STOT = STOT+S
        ZR(IAVALV+1) = STOT
        ZR(IAB2+MI-1)= STOT
        CALL NOCAR2(NOMU//'.ABS_CURV  ',3,' ','NUM',1,' ',IMA,' ',2)
   10 CONTINUE
C     CAS DES POI1
      DO 20 IPOI1 = 1,NBPOI1
        IMA=ZI(IMA1+IPOI1-1)
        MI=ZI(ICOR2+IPOI1-1)
        IF (MI.GT.0) THEN
          S=ZR(IAB1+MI-1)
        ELSE
          S=ZR(IAB2-MI-1)
        ENDIF
        ZR(IAVALV  ) = S
        ZR(IAVALV+1) = S
        CALL NOCAR2(NOMU//'.ABS_CURV  ',3,' ','NUM',1,' ',IMA,' ',2)
   20 CONTINUE
      CALL JEDETC('V','&&ABSCUR',1)
      CALL JEDETC('V',NOMU//'.ABS_CURV  .VALV',1)
      CALL JEDETC('V',NOMU//'.ABS_CURV  .NCMP',1)
      CALL JEDEMA()
      END
