      SUBROUTINE PJMA2P(NDIM,MOA2,MA2P,CORRES)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 13/12/2011   AUTEUR PELLET J.PELLET 
C RESPONSABLE PELLET J.PELLET
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
C
      IMPLICIT   NONE

C ----------------------------------------------------------------------
C
C COMMANDE PROJ_CHAMP
C
C ----------------------------------------------------------------------
C 0.1. ==> ARGUMENTS
C

C MOA2 : MODELE2 DONT ON VEUT EXTRAIRE LES POINTS DE GAUSS
C CORRES : TABLEAU DE CORRESPONDANCE REMPLI DANS LE .PJEL
C MA2P : MAILLAGE 2 PRIME (OBTENU A PARTIR DES PG DU MAILLAGE 2)


      CHARACTER*16 CORRES
      CHARACTER*8 MA2P,MOA2
      INTEGER NDIM
C
C 0.2. ==> COMMUNS
C ----------------------------------------------------------------------
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
      CHARACTER*32 JEXNUM
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

      CHARACTER*32 JEXNOM
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
C 0.3. ==> VARIABLES LOCALES
C


      INTEGER NTGEO,IPO,IPG,NUNO2
      INTEGER IBID,IRET,NBNO2P,NNO2,INO2P
      INTEGER K,J1,J4,IPOI1
      INTEGER NBMA,NBPT,NBCMP
      INTEGER IMA,IPT,ICMP,IAD,IADIME
      INTEGER JTYPMA,JDIMT,JPO2,JLIMAT,NBMAT,NBTROU,JLITR
      INTEGER JCESD,JCESL,JCESV,IATYPM
      CHARACTER*8 NOM,MAIL2,KBID,NOMA
      CHARACTER*19 CHAMG,CES,CHGEOM,LIGREL
      CHARACTER*24 COODSC,LIMATO,LITROU



      CALL JEMARQ()

C     -- RECUPERATION DU NOM DU MAILLAGE 2
      CALL DISMOI('F','NOM_MAILLA',MOA2,'MODELE',IBID,MAIL2,IRET)

C     -- RECUPERATION DU CHAMP DE COORDONNEES DU MAILLAGE 2
      CHGEOM=MAIL2//'.COORDO'


C     -- ON REDUIT LE LIGREL DE MOA2 SUR MAILLES DE DIMENSION NDIM :
      LIGREL='&&PJMA2P.LIGREL'
C     CALL PJLIGR(MAIL2,NDIM,LIGREL)
      LIMATO='&&PJMA2P.LIMATOT'
      LITROU='&&PJMA2P.LITROU'
      CALL DISMOI('F','NB_MA_MAILLA',MAIL2,'MAILLAGE',NBMAT,KBID,IRET)
      CALL WKVECT(LIMATO,'V V I',NBMAT,JLIMAT)
      DO 10,K=1,NBMAT
        ZI(JLIMAT-1+K)=K
   10 CONTINUE
      CALL UTFLMD(MAIL2,LIMATO,NDIM,NBTROU,LITROU)
      CALL ASSERT(NBTROU.GT.0)
      CALL JEVEUO(LITROU,'L',JLITR)
      CALL EXLIM1(ZI(JLITR),NBTROU,MOA2,'V',LIGREL)
      CALL JEDETR(LIMATO)
      CALL JEDETR(LITROU)


      CHAMG='&&PJMA2P.PGCOOR'

C     -- CALCUL DU CHAMP DE COORDONNEES DES ELGA
      CALL CALCUL('S','COOR_ELGA',LIGREL,1,CHGEOM,'PGEOMER',1,CHAMG,
     &            'PCOORPG ','V','OUI')

C     -- TRANSFORMATION DE CE CHAMP EN CHAM_ELEM_S
      CES='&&PJMA2P.PGCORS'
      CALL CELCES(CHAMG,'V',CES)

      CALL JEVEUO(CES//'.CESD','L',JCESD)
      CALL JEVEUO(CES//'.CESL','L',JCESL)
      CALL JEVEUO(CES//'.CESV','L',JCESV)

      NBMA=ZI(JCESD-1+1)


C     -- CALCUL DE NBNO2P : NOMBRE DE NOEUDS (ET DE MAILLES) DE MA2P
C     -- CALCUL DE '.PJEF_EL'
C     ----------------------------------------------------------------
      NBNO2P=0

C     NBMA*27*2 = NB MAX DE MAILLES * NB DE PG MAX PAR MAILLE * 2
C     ON CREE UN TABLEAU, POUR CHAQUE JPO2, ON STOCKE DEUX VALEURS :
C      * LA PREMIERE VALEUR EST LE NUMERO DE LA MAILLE
C      * LA DEUXIEME VALEUR EST LE NUMERO DU PG DANS CETTE MAILLE
      CALL WKVECT(CORRES//'.PJEF_EL','V V I',NBMA*27*2,JPO2)
      CALL JEVEUO(MAIL2(1:8)//'.TYPMAIL','L',JTYPMA)

      IPO=1
      DO 30,IMA=1,NBMA
        CALL JEVEUO(JEXNUM('&CATA.TM.TMDIM',ZI(JTYPMA-1+IMA)),'L',JDIMT)
        IF (ZI(JDIMT).EQ.NDIM) THEN
          NBPT=ZI(JCESD-1+5+4*(IMA-1)+1)
          CALL JENUNO(JEXNUM(MAIL2//'.NOMMAI',IMA),NOMA)
          DO 20,IPG=1,NBPT
            ZI(JPO2-1+IPO)=IMA
            ZI(JPO2-1+IPO+1)=IPG
            IPO=IPO+2
   20     CONTINUE
          NBNO2P=NBNO2P+NBPT
        ENDIF
   30 CONTINUE


C     -- CREATION DU .DIME DU NOUVEAU MAILLAGE
C        IL Y A AUTANT DE MAILLES QUE DE NOEUDS
C        TOUTES LES MAILLES SONT DES POI1
C     --------------------------------------------------
      CALL WKVECT(MA2P//'.DIME','V V I',6,IADIME)
      ZI(IADIME-1+1)=NBNO2P
      ZI(IADIME-1+3)=NBNO2P
      ZI(IADIME-1+6)=3


C     -- CREATION DU .NOMNOE ET DU .NOMMAI DU NOUVEAU MAILLAGE
C     ---------------------------------------------------------
      CALL JECREO(MA2P//'.NOMNOE','V N K8')
      CALL JEECRA(MA2P//'.NOMNOE','NOMMAX',NBNO2P,' ')
      CALL JECREO(MA2P//'.NOMMAI','V N K8')
      CALL JEECRA(MA2P//'.NOMMAI','NOMMAX',NBNO2P,' ')


      NOM(1:1)='N'
      DO 40,K=1,NBNO2P
        CALL CODENT(K,'G',NOM(2:8))
        CALL JECROC(JEXNOM(MA2P//'.NOMNOE',NOM))
   40 CONTINUE
      NOM(1:1)='M'
      DO 50,K=1,NBNO2P
        CALL CODENT(K,'G',NOM(2:8))
        CALL JECROC(JEXNOM(MA2P//'.NOMMAI',NOM))
   50 CONTINUE



C     -- CREATION DU .CONNEX ET DU .TYPMAIL DU NOUVEAU MAILLAGE
C     ----------------------------------------------------------
      CALL JECREC(MA2P//'.CONNEX','V V I','NU','CONTIG','VARIABLE',
     &            NBNO2P)
      CALL JEECRA(MA2P//'.CONNEX','LONT',NBNO2P,' ')
      CALL JEVEUO(MA2P//'.CONNEX','E',IBID)

      CALL WKVECT(MA2P//'.TYPMAIL','V V I',NBNO2P,IATYPM)
      CALL JENONU(JEXNOM('&CATA.TM.NOMTM','POI1'),IPOI1)

      NUNO2=0
      DO 60,IMA=1,NBNO2P
        ZI(IATYPM-1+IMA)=IPOI1
        NNO2=1
        CALL JECROC(JEXNUM(MA2P//'.CONNEX',IMA))
        CALL JEECRA(JEXNUM(MA2P//'.CONNEX',IMA),'LONMAX',NNO2,KBID)
        NUNO2=NUNO2+1
        ZI(IBID-1+NUNO2)=NUNO2
   60 CONTINUE



C     -- CREATION DU .REFE DU NOUVEAU MAILLAGE
C     --------------------------------------------------
      CALL WKVECT(MA2P//'.COORDO    .REFE','V V K24',4,J4)
      ZK24(J4)='MA2P'


C     -- CREATION DE COORDO.VALE DU NOUVEAU MAILLAGE
C     --------------------------------------------------
      CALL WKVECT(MA2P//'.COORDO    .VALE','V V R',3*NBNO2P,J1)

      INO2P=0
      DO 90,IMA=1,NBMA
        NBPT=ZI(JCESD-1+5+4*(IMA-1)+1)
        NBCMP=ZI(JCESD-1+5+4*(IMA-1)+3)
        CALL JEVEUO(JEXNUM('&CATA.TM.TMDIM',ZI(JTYPMA-1+IMA)),'L',JDIMT)

        IF (ZI(JDIMT).EQ.NDIM) THEN
          CALL ASSERT(NBCMP.GE.3)
          DO 80,IPT=1,NBPT
            INO2P=INO2P+1
            DO 70,ICMP=1,3
              CALL CESEXI('C',JCESD,JCESL,IMA,IPT,1,ICMP,IAD)
              IF (IAD.GT.0) THEN
                ZR(J1-1+3*(INO2P-1)+ICMP)=ZR(JCESV-1+IAD)
              ENDIF
   70       CONTINUE
   80     CONTINUE
        ENDIF
   90 CONTINUE
      CALL ASSERT(INO2P.EQ.NBNO2P)



C     -- CREATION DU .DESC DU NOUVEAU MAILLAGE
C     --------------------------------------------------
      COODSC=MA2P//'.COORDO    .DESC'

      CALL JENONU(JEXNOM('&CATA.GD.NOMGD','GEOM_R'),NTGEO)
      CALL JECREO(COODSC,'V V I')
      CALL JEECRA(COODSC,'LONMAX',3,' ')
      CALL JEECRA(COODSC,'DOCU',0,'CHNO')
      CALL JEVEUO(COODSC,'E',IAD)
      ZI(IAD)=NTGEO
      ZI(IAD+1)=-3
      ZI(IAD+2)=14

      CALL DETRSD('CHAM_ELEM',CHAMG)
      CALL DETRSD('CHAM_ELEM_S',CES)


      CALL JEDEMA()

      END
