      SUBROUTINE CESFUS(NBCHS,LICHS,LCUMUL,LCOEFR,LCOEFC,LCOC,BASE,
     & CES3Z)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 07/10/2008   AUTEUR PELLET J.PELLET 
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
C RESPONSABLE VABHHTS J.PELLET
C A_UTIL
      IMPLICIT NONE
      INTEGER NBCHS
      CHARACTER*(*) LICHS(NBCHS),CES3Z,BASE
      LOGICAL LCUMUL(NBCHS),LCOC
      REAL*8 LCOEFR(NBCHS)
      COMPLEX*16 LCOEFC(NBCHS)
C ---------------------------------------------------------------------
C BUT: FUSIONNER UNE LISTE DE CHAM_ELEM_S POUR EN FORMER 1 AUTRE
C ---------------------------------------------------------------------
C     ARGUMENTS:
C NBCHS   IN       I      : NOMBRE DE CHAM_ELEM_S A FUSIONNER
C LICHS   IN/JXIN  V(K19) : LISTE DES SD CHAM_ELEM_S A FUSIONNER
C LCUMUL  IN       V(L)   : V(I) =.TRUE. => ON ADDITIONNE LE CHAMP I
C                         : V(I) =.FALSE. => ON SURCHARGE LE CHAMP I
C LCOEFR  IN       V(R)   : LISTE DES COEF. MULT. DES VALEURS DES CHAMPS
C LCOEFC  IN       V(C)   : LISTE DES COEF. MULT. DES VALEURS DES CHAMPS
C LCOC    IN       L      : =TRUE SI COEF COMPLEXE
C CES3Z   IN/JXOUT K19 : SD CHAM_ELEM_S RESULTAT
C BASE    IN       K1  : BASE DE CREATION POUR CES3Z : G/V/L

C REMARQUES :

C- LES CHAM_ELEM_S DE LICHS DOIVENT ETRE DE LA MEME GRANDEUR,S'APPUYER
C  SUR LE MEME MAILLAGE ET ETRE DE MEME TYPE (ELEM/ELGA/ELNO).
C  DANS TOUS LES CHAM_ELEM_S, CHAQUE MAILLE DOIT AVOIR LE MEME
C  NOMBRE DE POINTS (NOEUD OU GAUSS) ET LE MEME NOMBRE DE SOUS-POINTS.

C- L'ORDRE DES CHAM_ELEM_S DANS LICHS EST IMPORTANT :
C  LES CHAM_ELEM_S SE SURCHARGENT LES UNS LES AUTRES

C- ON PEUT APPELER CETTE ROUTINE MEME SI CES3Z APPARTIENT
C  A LA LISTE LICHS (CHAM_ELEM_S IN/OUT)
C-----------------------------------------------------------------------
C---- COMMUNS NORMALISES  JEVEUX
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
      CHARACTER*32 ZK32,JEXNOM,JEXNUM
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     ------------------------------------------------------------------
      INTEGER JCE1K,JCE1D,JCE1V,JCE1L,JCE1C,NBMA,N1,K
      INTEGER JCE3D,JCE3V,JCE3L,JCE3C,VALI(3)
      INTEGER IBID,JCMPGD,JLICMP,ICHS,ICMP,ICMP3,NCMP3
      INTEGER NCMPMX,NCMP1,ICMP1,JNUCMP,JNBPT,JNBSP,JNBCMP,JCRCMP
      INTEGER IMA,INDIK8,IPT,ISP,NBPT,NBSP,IAD1,IAD3,COEFI,NCMP
      CHARACTER*1 KBID
      CHARACTER*8 MA,NOMGD,NOCMP,TYPCES,NOMCMP
      CHARACTER*3 TSCA
      CHARACTER*19 CES1,CES3
      REAL*8 COEFR
      COMPLEX*16 COEFC
      LOGICAL CUMUL
C     ------------------------------------------------------------------
      CALL JEMARQ()
C        CALL IMPRSD('CHAMP',LICHS(1),6,'cesfus in 1')
C        CALL IMPRSD('CHAMP',LICHS(2),6,'cesfus in 2')

C     -- POUR NE PAS RISQUER D'ECRASER UN CHAM_ELEM_S "IN",
C        ON CREE CES3 SOUS UN NOM TEMPORAIRE :
      CES3 = '&&CESFUS.CES3'
      CALL ASSERT(NBCHS.GT.0)

      CES1 = LICHS(1)

      CALL JEVEUO(CES1//'.CESK','L',JCE1K)
      CALL JEVEUO(CES1//'.CESD','L',JCE1D)

      MA = ZK8(JCE1K-1+1)
      NOMGD = ZK8(JCE1K-1+2)
      TYPCES = ZK8(JCE1K-1+3)

      NBMA = ZI(JCE1D-1+1)
      NCMP1 = ZI(JCE1D-1+2)


      CALL DISMOI('F','TYPE_SCA',NOMGD,'GRANDEUR',IBID,TSCA,IBID)


C     -- RECUPERATION DE LA LISTE DES CMPS DU CATALOGUE :
C        POUR LA GRANDEUR VARI_* , IL FAUT CONSTITUER :(V1,V2,...,VN)
C     ---------------------------------------------------------------
      IF (NOMGD(1:5).NE.'VARI_') THEN
        CALL DISMOI('F','NB_CMP_MAX',NOMGD,'GRANDEUR',NCMPMX,KBID,IBID)
        CALL JEVEUO(JEXNOM('&CATA.GD.NOMCMP',NOMGD),'L',JCMPGD)
      ELSE
        NCMPMX = 0
        DO 20,ICHS = 1,NBCHS
          CES1 = LICHS(ICHS)
          CALL JEVEUO(CES1//'.CESC','L',JCE1C)
          CALL JELIRA(CES1//'.CESC','LONMAX',N1,KBID)
          DO 10,K = 1,N1
            READ (ZK8(JCE1C-1+K) (2:),'(I7)') ICMP
            NCMPMX = MAX(NCMPMX,ICMP)
   10     CONTINUE
   20   CONTINUE

        CALL WKVECT('&&CESFUS.LISVARI','V V K8',NCMPMX,JCMPGD)
        DO 30,K = 1,NCMPMX
          NOMCMP = 'V'
          CALL CODENT(K,'G',NOMCMP(2:8))
          ZK8(JCMPGD-1+K) = NOMCMP
   30   CONTINUE
      END IF



C     1- QUELQUES VERIFICATIONS SUR LES CHAMPS "IN"
C        + CALCUL DES OBJETS CONTENANT LES NOMBRES DE POINTS
C          ET DE SOUS-POINTS PAR MAILLE
C     --------------------------------------------------------
      CALL WKVECT('&&CESFUS.NBPT','V V I',NBMA,JNBPT)
      CALL WKVECT('&&CESFUS.NBSP','V V I',NBMA,JNBSP)
      DO 60,ICHS = 1,NBCHS
        CES1 = LICHS(ICHS)
        CALL JEVEUO(CES1//'.CESK','L',JCE1K)
        CALL JEVEUO(CES1//'.CESD','L',JCE1D)

C       TEST SUR IDENTITE DES 2 MAILLAGES
        CALL ASSERT(MA.EQ.ZK8(JCE1K-1+1))
C       TEST SUR IDENTITE DES 2 GRANDEURS
        CALL ASSERT(NOMGD.EQ.ZK8(JCE1K-1+2))
C       TEST SUR IDENTITE DES 2 TYPES (ELEM/ELNO/ELGA)
        CALL ASSERT(TYPCES.EQ.ZK8(JCE1K-1+3))

        IF (ICHS.EQ.1) THEN
          DO 40,IMA = 1,NBMA
            ZI(JNBPT-1+IMA) = ZI(JCE1D-1+5+4* (IMA-1)+1)
            ZI(JNBSP-1+IMA) = ZI(JCE1D-1+5+4* (IMA-1)+2)
   40     CONTINUE
        ELSE
          DO 50,IMA = 1,NBMA
            NBPT = ZI(JCE1D-1+5+4* (IMA-1)+1)
            NBSP = ZI(JCE1D-1+5+4* (IMA-1)+2)
            NCMP = ZI(JCE1D-1+5+4* (IMA-1)+3)
            IF (NBPT*NBSP*NCMP.EQ.0) GO TO 50

            IF (ZI(JNBPT-1+IMA).NE.0) THEN
C             TEST SUR IDENTITE DU NOMBRE DE POINTS
              IF (ZI(JNBPT-1+IMA).NE.NBPT) THEN
                VALI(1)=IMA
                VALI(2)=NBPT
                VALI(3)=ZI(JNBPT-1+IMA)
                CALL U2MESI('F','CALCULEL_35',3,VALI)
              ENDIF
            ELSE
              IF (NBPT.NE.0) ZI(JNBPT-1+IMA)=NBPT
            END IF

            IF (ZI(JNBSP-1+IMA).NE.0) THEN
C             TEST SUR IDENTITE DU NOMBRE DE SOUS-POINTS
              IF (ZI(JNBSP-1+IMA).NE.NBSP) THEN
                VALI(1)=IMA
                VALI(2)=NBSP
                VALI(3)=ZI(JNBSP-1+IMA)
                CALL U2MESI('F','CALCULEL_36',3,VALI)
              ENDIF
            ELSE
              IF (NBSP.NE.0) ZI(JNBSP-1+IMA)=NBSP
            END IF
   50     CONTINUE
        END IF
        CALL JELIBE(CES1//'.CESK')
        CALL JELIBE(CES1//'.CESD')
   60 CONTINUE



C     2- CALCUL DE LA LISTE DES CMPS DE CES3
C     -------------------------------------------

C     -- ON "COCHE" LES CMPS PRESENTES DANS LES CES DE LICHS:
      CALL WKVECT('&&CESFUS.LICMP','V V K8',NCMPMX,JLICMP)
      CALL WKVECT('&&CESFUS.NUCMP','V V I',NCMPMX,JNUCMP)
      DO 80,ICHS = 1,NBCHS
        CES1 = LICHS(ICHS)
        CALL JEVEUO(CES1//'.CESK','L',JCE1K)
        CALL JEVEUO(CES1//'.CESD','L',JCE1D)
        CALL JEVEUO(CES1//'.CESC','L',JCE1C)

        NCMP1 = ZI(JCE1D-1+2)
        DO 70,ICMP1 = 1,NCMP1
          NOCMP = ZK8(JCE1C-1+ICMP1)

          ICMP = INDIK8(ZK8(JCMPGD),NOCMP,1,NCMPMX)
          ZI(JNUCMP-1+ICMP) = 1
   70   CONTINUE
        CALL JELIBE(CES1//'.CESK')
        CALL JELIBE(CES1//'.CESD')
        CALL JELIBE(CES1//'.CESC')
   80 CONTINUE

      ICMP3 = 0
      DO 90,ICMP = 1,NCMPMX
        IF (ZI(JNUCMP-1+ICMP).EQ.1) THEN
          ICMP3 = ICMP3 + 1
          ZK8(JLICMP-1+ICMP3) = ZK8(JCMPGD-1+ICMP)
        END IF
   90 CONTINUE
      NCMP3 = ICMP3



C     3- CALCUL DE L'OBJET CONTENANT LE NOMBRE DE CMPS PAR MAILLE
C     -----------------------------------------------------------
      CALL WKVECT('&&CESFUS.NBCMP','V V I',NBMA,JNBCMP)
      CALL WKVECT('&&CESFUS.CORR_CMP','V V I',NCMPMX,JCRCMP)

      DO 120,ICHS = 1,NBCHS
        CES1 = LICHS(ICHS)
        CALL JEVEUO(CES1//'.CESD','L',JCE1D)
        CALL JEVEUO(CES1//'.CESC','L',JCE1C)

        NCMP1 = ZI(JCE1D-1+2)
        DO 100,ICMP1 = 1,NCMP1
          NOCMP = ZK8(JCE1C-1+ICMP1)
          ICMP3 = INDIK8(ZK8(JLICMP),NOCMP,1,NCMP3)
          ZI(JCRCMP-1+ICMP1) = ICMP3
  100   CONTINUE

        DO 110,IMA = 1,NBMA
          NCMP1 = ZI(JCE1D-1+5+4* (IMA-1)+3)
          IF (NCMP1.EQ.0) GO TO 110
          CALL ASSERT(NCMP1.GE.0)
          DO 111,ICMP1 = 1,NCMP1
             ICMP3 = ZI(JCRCMP-1+ICMP1)
             ZI(JNBCMP-1+IMA) = MAX(ICMP3,ZI(JNBCMP-1+IMA))
  111     CONTINUE
  110   CONTINUE

        CALL JELIBE(CES1//'.CESD')
        CALL JELIBE(CES1//'.CESC')
  120 CONTINUE


C     4- ALLOCATION DE CES3 :
C     --------------------------
      CALL CESCRE(BASE,CES3,TYPCES,MA,NOMGD,NCMP3,ZK8(JLICMP),ZI(JNBPT),
     &            ZI(JNBSP),ZI(JNBCMP))
      CALL JEVEUO(CES3//'.CESD','L',JCE3D)
      CALL JEVEUO(CES3//'.CESC','L',JCE3C)
      CALL JEVEUO(CES3//'.CESV','E',JCE3V)
      CALL JEVEUO(CES3//'.CESL','E',JCE3L)




C     5- RECOPIE DE CES1 DANS CES3 :
C     ------------------------------------------
      DO 170,ICHS = 1,NBCHS
        CES1 = LICHS(ICHS)

        CALL JEVEUO(CES1//'.CESD','L',JCE1D)
        CALL JEVEUO(CES1//'.CESC','L',JCE1C)
        CALL JEVEUO(CES1//'.CESV','L',JCE1V)
        CALL JEVEUO(CES1//'.CESL','L',JCE1L)
        NCMP1 = ZI(JCE1D-1+2)

        CUMUL = LCUMUL(ICHS)
        IF(LCOC)THEN
          COEFC = LCOEFC(ICHS)
        ELSE
          COEFR = LCOEFR(ICHS)
          IF (TSCA.EQ.'I') COEFI = NINT(COEFR)
        ENDIF

        DO 160,ICMP1 = 1,NCMP1
          NOCMP = ZK8(JCE1C-1+ICMP1)
          ICMP3 = INDIK8(ZK8(JCE3C),NOCMP,1,NCMP3)
          DO 150,IMA = 1,NBMA
            NBPT = ZI(JCE3D-1+5+4* (IMA-1)+1)
            NBSP = ZI(JCE3D-1+5+4* (IMA-1)+2)
            DO 140,IPT = 1,NBPT
              DO 130,ISP = 1,NBSP
                CALL CESEXI('C',JCE1D,JCE1L,IMA,IPT,ISP,ICMP1,IAD1)
                CALL CESEXI('C',JCE3D,JCE3L,IMA,IPT,ISP,ICMP3,IAD3)
                IF (IAD1.LE.0) GO TO 130

                CALL ASSERT(IAD3.NE.0)


C               -- SI AFFECTATION :
                IF ((.NOT.CUMUL) .OR. (IAD3.LT.0)) THEN
                  IAD3 = ABS(IAD3)
                  ZL(JCE3L-1+IAD3) = .TRUE.

                  IF (TSCA.EQ.'R') THEN
                    ZR(JCE3V-1+IAD3) = COEFR*ZR(JCE1V-1+IAD1)
                  ELSE IF (TSCA.EQ.'I') THEN
                    ZI(JCE3V-1+IAD3) = COEFI*ZI(JCE1V-1+IAD1)
                  ELSE IF (TSCA.EQ.'C') THEN
                    IF(LCOC)THEN
                      ZC(JCE3V-1+IAD3) = COEFC*ZC(JCE1V-1+IAD1)
                    ELSE
                      ZC(JCE3V-1+IAD3) = COEFR*ZC(JCE1V-1+IAD1)
                    ENDIF
                  ELSE IF (TSCA.EQ.'L') THEN
                    ZL(JCE3V-1+IAD3) = ZL(JCE1V-1+IAD1)
                  ELSE IF (TSCA.EQ.'K8') THEN
                    ZK8(JCE3V-1+IAD3) = ZK8(JCE1V-1+IAD1)
                  ELSE IF (TSCA.EQ.'K16') THEN
                    ZK16(JCE3V-1+IAD3) = ZK16(JCE1V-1+IAD1)
                  ELSE
                    CALL ASSERT(.FALSE.)
                  END IF

C               -- SI CUMUL DANS UNE VALEUR DEJA AFFECTEE :
                ELSE

                  IF (TSCA.EQ.'R') THEN
                    ZR(JCE3V-1+IAD3) = ZR(JCE3V-1+IAD3) +
     &                                 COEFR*ZR(JCE1V-1+IAD1)
                  ELSE IF (TSCA.EQ.'I') THEN
                    ZI(JCE3V-1+IAD3) = ZI(JCE3V-1+IAD3) +
     &                                 COEFI*ZI(JCE1V-1+IAD1)
                  ELSE IF (TSCA.EQ.'C') THEN
                    IF(LCOC)THEN
                      ZC(JCE3V-1+IAD3) = ZC(JCE3V-1+IAD3) +
     &                                 COEFC*ZC(JCE1V-1+IAD1)
                    ELSE
                      ZC(JCE3V-1+IAD3) = ZC(JCE3V-1+IAD3) +
     &                                 COEFR*ZC(JCE1V-1+IAD1)
                    ENDIF
                  ELSE IF ((TSCA.EQ.'L') .OR. (TSCA.EQ.'K8')) THEN
C                   CUMUL INTERDIT SUR CE TYPE NON-NUMERIQUE
                    CALL ASSERT(.FALSE.)
C                  ELSE IF (TSCA.EQ.'K16') THEN
C                    ZK16(JCE3V-1+IAD3) = ZK16(JCE1V-1+IAD1)
                  ELSE
                    CALL ASSERT(.FALSE.)
                  END IF
                END IF


  130         CONTINUE
  140       CONTINUE
  150     CONTINUE
  160   CONTINUE

        CALL JELIBE(CES1//'.CESD')
        CALL JELIBE(CES1//'.CESC')
        CALL JELIBE(CES1//'.CESV')
        CALL JELIBE(CES1//'.CESL')

  170 CONTINUE


C     6- RECOPIE DE LA SD TEMPORAIRE DANS LE RESULTAT :
C     -------------------------------------------------
      CALL COPISD('CHAM_ELEM_S',BASE,CES3,CES3Z)
C        CALL IMPRSD('CHAMP',CES3,6,'cesfus out 3')

C     7- MENAGE :
C     -----------
      CALL DETRSD('CHAM_ELEM_S',CES3)
      CALL JEDETR('&&CESFUS.LISVARI')
      CALL JEDETR('&&CESFUS.NBPT')
      CALL JEDETR('&&CESFUS.NBSP')
      CALL JEDETR('&&CESFUS.LICMP')
      CALL JEDETR('&&CESFUS.NUCMP')
      CALL JEDETR('&&CESFUS.NBCMP')
      CALL JEDETR('&&CESFUS.CORR_CMP')

      CALL JEDEMA()
      END
