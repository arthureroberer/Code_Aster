      SUBROUTINE XLAGSL(NOMA,FISS,ALGOLA,NDIM,CNSBAS,NLISUP)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 06/10/2009   AUTEUR GENIAUT S.GENIAUT 
C ======================================================================
C COPYRIGHT (C) 1991 - 2009  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE MAZET S.MAZET
C
      IMPLICIT NONE
      CHARACTER*8   NOMA,FISS
      INTEGER       ALGOLA,NDIM
      CHARACTER*19  CNSBAS,NLISUP
C
C ----------------------------------------------------------------------
C
C ROUTINE XFEM (PREPARATION)
C
C CHOIX DE L'ESPACE DES LAGRANGES DE CONTACT
C      DANS LE CAS DES LAGRANGES AUX NOEUDS
C
C    - DETERMINATION DES NOEUDS DES ARETES NON-COUPEES
C    - DETERMINATION DU "NIVEAU" DE CHACUN DE CES NOEUDS
C    - CREATION DES RELATIONS DE LIAISONS ENTRE LAGRANGES D'UN
C      "NIVEAU" ET LAGRANGES DU "NIVEAU" INFERIEUR
C
C ----------------------------------------------------------------------
C
C IN  NOMA   : NOM DE L'OBJET MAILLAGE
C IN  ALGOLA : TYPE DE CREATION DES RELATIONS DE LIAISONS ENTRE LAGRANGE
C IN  NDIM   : DIMENSION DE L'ESPACE
C OUT CNSBAS : CHAM_NO_S DE LA BASE COVARIANTE
C OUT NLISUP : LISTE REL. LIN. SUPPL�MENTAIRES POUR MAILLAGE LIN�AIRE
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      CHARACTER*32 JEXNUM,JEXATR
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      NBCMP,VALI(2)
      PARAMETER    (NBCMP = 12)
      CHARACTER*8  LICMPR(NBCMP)
      INTEGER      NBMA,NBNO,NBAR,NBNOCO,INOCO1,INOCO2
      INTEGER      AR(12,2),NA,NB,NMIL,NUNOA
      INTEGER      NUNOB,NUNOM,NOMIL,NUNOAA,NUNOBB,NUNOMM,NUNO
      INTEGER      IA,IIA,IA1,IA2,I,IRET,IMA,IIMA,JMA,IBID,IBID2(12,3)
      INTEGER      J,JCOOR,JCONX1,JCONX2,JCNSV,JCNSL
      REAL*8       LSNA,LSNB,LSTA,LSTB,A(3),B(3),C(3),CC(3),S
      CHARACTER*8  K8BID,TYPMA
      CHARACTER*19 LTNO,LNNO,GRLTNO,GRLNNO,CONID,NOCON,LIEDG,NBEDG,NIVEA
      CHARACTER*19 CNSLT,CNSLN,GRLN,GRLT
      INTEGER      JLTSV,JLNSV,JGRLNV,JGRLTV,JCONID,JNOCON,JLIEDG,JNBEDG
      CHARACTER*19 MATRA
      INTEGER      JTABIN,JMATRA,NMATRA,ITYPMA,NDIME,JTMDIM
      INTEGER      XXMMVD
      REAL*8       LON,DIST1,DIST2,R8MAEM,TMP,CRIINF,CRISUP,ANG,AB(3)
      LOGICAL      MAQUA,ISMALI
      INTEGER      INO,IINO,NBNOMA,IFA,IFACO,INOFA,FAC(6,4),NBF
      INTEGER      FANO(8,4),NONO(8,4),JLISUP,PASSE,ZXEDG,JNIVEA
      INTEGER      NIVINO,NIVJ,NBNOSU,NBEDLO,NBFANO,NBNONO
      INTEGER      NBEDGE,EDGE1,EDGE2,EDGE3,EDGE4,EDGE5,EDGE6
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- RECUPERATION DE DONNEES RELATIVES AU MAILLAGE
C
      CALL DISMOI('F','NB_MA_MAILLA',NOMA,'MAILLAGE',NBMA,K8BID,IRET)
      CALL DISMOI('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NBNO,K8BID,IRET)
      CALL JEVEUO(NOMA(1:8)//'.TYPMAIL','L',JMA)
      CALL JEVEUO(NOMA(1:8)//'.CONNEX','L',JCONX1)
      CALL JEVEUO(JEXATR(NOMA(1:8)//'.CONNEX','LONCUM'),'L',JCONX2)
      CALL JEVEUO(NOMA(1:8)//'.COORDO    .VALE','L',JCOOR)
      CALL JEVEUO('&CATA.TM.TMDIM','L',JTMDIM)
C
C --- DIMENSIONNEMENT DU NOMBRE MAXIMUM D'ARETES COUPEES PAR LA FISSURE
C --- PAR LE NOMBRE DE NOEUDS DU MAILLAGE (� AUGMENTER SI N�CESSAIRE)
C
C --- INITIALISATIONS
C
      MATRA  = '&&XLAGSL.MATRA'
      CONID  = '&&XLAGSL.CONID'
      CNSLT  = '&&XLAGSL.CNSLT'
      CNSLN  = '&&XLAGSL.CNSLN'
      GRLT   = '&&XLAGSL.GRLT'
      GRLN   = '&&XLAGSL.GRLN'
C
C --- TRANSFO. CHAM_NO -> CHAM_NO_S DES LEVEL SETS
C
      LTNO   = FISS(1:8)//'.LTNO'
      LNNO   = FISS(1:8)//'.LNNO'
      CALL CNOCNS(LTNO  ,'V',CNSLT)
      CALL CNOCNS(LNNO  ,'V',CNSLN)
C
C --- TRANSFO. CHAM_NO -> CHAM_NO_S DES GRADIENTS
C
      GRLTNO = FISS(1:8)//'.GRLTNO'
      GRLNNO = FISS(1:8)//'.GRLNNO'
      CALL CNOCNS(GRLTNO,'V',GRLT)
      CALL CNOCNS(GRLNNO,'V',GRLN)
C
C --- ACCES AUX CHAM_NO_S LEVEL SETS ET GRADIENTS
C
      CALL JEVEUO(CNSLT(1:19)//'.CNSV','L',JLTSV )
      CALL JEVEUO(CNSLN(1:19)//'.CNSV','L',JLNSV )
      CALL JEVEUO(GRLT(1:19) //'.CNSV','L',JGRLTV)
      CALL JEVEUO(GRLN(1:19) //'.CNSV','L',JGRLNV)
C
C --- ACCES AU CHAM_NO_S DE LA BASE COVARIANTE
C
      CALL JEVEUO(CNSBAS(1:19)//'.CNSV','E',JCNSV)
      CALL JEVEUO(CNSBAS(1:19)//'.CNSL','E',JCNSL)
C
C --- CREATION OBJETS DE TRAVAIL
C
      CALL WKVECT(CONID ,'V V I',NBNO     ,JCONID)
C
C --- CREATION DE LA LISTE DES MAILLES COUPEES: DEUX PASSES
C
      DO 120 PASSE=1,2

        IF (PASSE.EQ.2) THEN
          IF (NMATRA.EQ.0) GOTO 900
          CALL WKVECT(MATRA ,'V V I',NMATRA,JMATRA)
        ENDIF

C       NOMBRE DE MAILLES TRAVERS�ES PAR LA FISSURE
        NMATRA=0

        DO 100 IMA = 1,NBMA

          ITYPMA = ZI(JMA-1+IMA)
          CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ITYPMA),TYPMA)

C         NDIME : DIMENSION TOPOLOGIQUE DE LA MAILLE
          NDIME= ZI(JTMDIM-1+ITYPMA)
C
C ----    ON ZAPPE LES MAILLES DE BORD (MAILLES NON PRINCIPALES)
          IF (NDIM.NE.NDIME) GOTO 100
C
C ---     MAILLE QUADRATIQUE ?
          MAQUA=.NOT.ISMALI(TYPMA)
          IF (MAQUA) GOTO 100
C
C --- BOUCLE SUR LES ARETES DE LA MAILLE VOLUMIQUE
C
          CALL CONARE(TYPMA,AR,NBAR)

          DO 110 IA=1,NBAR
            NA    = AR(IA,1)
            NB    = AR(IA,2)
            NUNOA = ZI(JCONX1-1+ZI(JCONX2+IMA-1)+NA-1)
            NUNOB = ZI(JCONX1-1+ZI(JCONX2+IMA-1)+NB-1)
C
C --- SI CETTE ARETE N'EST PAS COUPEE PAR LA FISSURE, ON SORT
C
            LSNA  = ZR(JLNSV-1+(NUNOA-1)+1)
            LSNB  = ZR(JLNSV-1+(NUNOB-1)+1)
            IF (LSNA*LSNB.GE.0.D0) GOTO 110

            LSTA  = ZR(JLTSV-1+(NUNOA-1)+1)
            LSTB  = ZR(JLTSV-1+(NUNOB-1)+1)
            IF (LSTA.GE.0.D0.OR.LSTB.GE.0.D0) GOTO 110
C
C --- AU MOINS UNE ARETE COUPEE
C     PASSE 1: ON COMPTE LES MAILLES
C     PASSE 2: ON LISTE LES MAILLES
C
            NUNOM=0
            NMATRA=NMATRA+1
            IF (PASSE.EQ.2) THEN
              ZI(JMATRA-1+NMATRA)=IMA
            ENDIF
            GOTO 100
C
 110      CONTINUE
 100    CONTINUE
C
C FIN DES PASSES 1 ET 2
 120  CONTINUE
C
C --- MARQUAGE ET COMPTAGE DES NOEUDS 
C     PORTANT DES DDLS DE CONTACT
C
      NBNOCO=0
      DO 200 IIMA=1,NMATRA
        IMA=ZI(JMATRA-1+IIMA)
        NBNOMA= ZI(JCONX2+IMA) - ZI(JCONX2+IMA-1)
        DO 210 INO=1,NBNOMA
          NUNOA = ZI(JCONX1-1+ZI(JCONX2+IMA-1)+INO-1)
          IF (ZI(JCONID-1+NUNOA).EQ.0) NBNOCO=NBNOCO+1
          ZI(JCONID-1+NUNOA)=1
 210    CONTINUE
 200  CONTINUE
C
C     INDEXAGE DES NOEUDS PORTANT DES DDLS DE CONTACT
C --- CONID  : MAPPING INDEX GLOBAL VERS INDEX DES NOEUD PORTANT
C              DES DDLS DE CONTACT
C --- NOCON  : MAPPING INVERSE DE CONID
C
      NOCON='&&XLAGSL.NOCON'
      CALL WKVECT(NOCON  ,'V V I',NBNOCO   ,JNOCON)
      NBNOCO=0
      DO 230 NUNO=1,NBNO
        IF (ZI(JCONID-1+NUNO).NE.0) THEN
          NBNOCO=NBNOCO+1
          ZI(JCONID-1+NUNO)=NBNOCO
          ZI(JNOCON-1+NBNOCO)=NUNO
        ENDIF
 230  CONTINUE
C
C --- LISTE DES ARETES PAR NOEUD
C     NOMBRE D'ARETES MAX TOLERE: DONNE PAR XXMMVD
C
      ZXEDG = XXMMVD('ZXEDG')
      LIEDG='&&XLAGSL.LIEDG'
      CALL WKVECT(LIEDG  ,'V V I',ZXEDG*NBNOCO,JLIEDG)
      NBEDG='&&XLAGSL.NBEDG'
      CALL WKVECT(NBEDG  ,'V V I',NBNOCO       ,JNBEDG)
C     POUR CHAQUE MAILLE TRAVERS�E
      DO 300 IIMA=1,NMATRA
        IMA=ZI(JMATRA-1+IIMA)
        CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ZI(JMA-1+IMA)),TYPMA)
        CALL COFANO(TYPMA,FANO,NONO,NBFANO,NBNONO)
        NBNOMA= ZI(JCONX2+IMA) - ZI(JCONX2+IMA-1)
C       POUR CHAQUE NOEUD DE LA MAILLE
        DO 310 INO=1,NBNOMA
          NUNOA  = ZI(JCONX1-1+ZI(JCONX2+IMA-1)+INO-1)
          INOCO1 = ZI(JCONID-1+NUNOA)
          CALL ASSERT(INOCO1.GT.0)
C         POUR CHAQUE NOEUD CONNECT� � NUNOA
          DO 320 IA=1,NBNONO
            IINO=NONO(INO,IA)
            IF (IINO.EQ.0) GOTO 320
            NUNOB  = ZI(JCONX1-1+ZI(JCONX2+IMA-1)+IINO-1)
            INOCO2 = ZI(JCONID-1+NUNOB)
            CALL ASSERT(INOCO2.GT.0)
C           L'ARETE EST-ELLE D�J� PR�SENTE?
            DO 330 IIA=1,ZI(JNBEDG-1+INOCO1)
              IF (ZI(JLIEDG-1+ZXEDG*(INOCO1-1)+IIA).EQ.INOCO2) THEN
                GOTO 320
              ENDIF
              IF (ZI(JLIEDG-1+ZXEDG*(INOCO2-1)+IIA).EQ.INOCO1) THEN
                GOTO 320
              ENDIF
 330        CONTINUE
C           SINON, ON AJOUTE L'AR�TE
            ZI(JNBEDG-1+INOCO1)=ZI(JNBEDG-1+INOCO1)+1
            IF (ZI(JNBEDG-1+INOCO1).GT.ZXEDG) THEN
              VALI(1)=NUNOA
              VALI(2)=ZXEDG
              CALL U2MESG('F','XFEM_40',0,' ',2,VALI,0,0.D0)
              CALL ASSERT(ZI(JNBEDG-1+INOCO1).LE.ZXEDG)
            ENDIF
            ZI(JLIEDG-1+ZXEDG*(INOCO1-1)+ZI(JNBEDG-1+INOCO1))=INOCO2

            ZI(JNBEDG-1+INOCO2)=ZI(JNBEDG-1+INOCO2)+1
            IF (ZI(JNBEDG-1+INOCO2).GT.ZXEDG) THEN
              VALI(1)=NUNOB
              VALI(2)=ZXEDG
              CALL U2MESG('F','XFEM_40',0,' ',2,VALI,0,0.D0)
              CALL ASSERT(ZI(JNBEDG-1+INOCO2).LE.ZXEDG)
            ENDIF
            ZI(JLIEDG-1+ZXEDG*(INOCO2-1)+ZI(JNBEDG-1+INOCO2))=INOCO1
C           REMPLISSAGE DU CHAM_NO_S DE LA BASE COVARIANTE
C           SEULEMENT POUR LES ARETES NON PARALLELES A LA FISSURE
            LSNA  = ZR(JLNSV-1+(NUNOA-1)+1)
            LSNB  = ZR(JLNSV-1+(NUNOB-1)+1)
            IF (ABS(LSNA-LSNB).GT.1.D-12) THEN
              NUNOM = 0
              DO 160 I=1,NDIM
                A(I)  = ZR(JCOOR-1+3*(NUNOA-1)+I)
                B(I)  = ZR(JCOOR-1+3*(NUNOB-1)+I)
                S     = -LSNA/(LSNB-LSNA)
                C(I)  = A(I)+S*(B(I)-A(I))
 160          CONTINUE
              CALL XBASCO(NDIM  ,MAQUA,NUNOA ,NUNOB ,NUNOM ,
     &                    A     ,B     ,C     ,S     ,
     &                    JGRLNV,JGRLTV,JCNSV ,JCNSL )
            ENDIF

 320      CONTINUE
 310    CONTINUE
 300  CONTINUE
C
C ---
C --- MARQUAGE DES NOEUDS DE NIVEAU 1
C ---
C
      NIVEA='&&XLAGSL.NIVEA'
      CALL WKVECT(NIVEA  ,'V V I',NBNOCO       ,JNIVEA)
      DO 401 I=1,NBNOCO
        ZI(JNIVEA-1+I) = 0
 401  CONTINUE

      DO 400 IIMA = 1,NMATRA
        IMA=ZI(JMATRA-1+IIMA)
        CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ZI(JMA-1+IMA)),TYPMA)
C
C --- BOUCLE SUR LES ARETES DE LA MAILLE VOLUMIQUE
C
        CALL CONARE(TYPMA,AR,NBAR)
        DO 410 IA=1,NBAR
          NA    = AR(IA,1)
          NB    = AR(IA,2)
          NUNOA = ZI(JCONX1-1+ZI(JCONX2+IMA-1)+NA-1)
          NUNOB = ZI(JCONX1-1+ZI(JCONX2+IMA-1)+NB-1)
C
C --- SI CETTE ARETE N'EST PAS COUPEE PAR LA FISSURE, ON CONTINUE
C
          LSNA  = ZR(JLNSV-1+(NUNOA-1)+1)
          LSNB  = ZR(JLNSV-1+(NUNOB-1)+1)
C         NOEUDS ISOL�S
          IF (LSNA.EQ.0)  THEN
            INOCO1=ZI(JCONID-1+NUNOA)
            ZI(JNIVEA-1+INOCO1)=1
          ENDIF
          IF (LSNB.EQ.0)  THEN
            INOCO1=ZI(JCONID-1+NUNOB)
            ZI(JNIVEA-1+INOCO1)=1
          ENDIF
          IF (LSNA*LSNB.GE.0.D0) GOTO 410

          LSTA  = ZR(JLTSV-1+(NUNOA-1)+1)
          LSTB  = ZR(JLTSV-1+(NUNOB-1)+1)
          IF (LSTA.GE.0.D0.OR.LSTB.GE.0.D0) GOTO 410
C
C --- ARETE COUPEE
C
          INOCO1=ZI(JCONID-1+NUNOA)
          INOCO2=ZI(JCONID-1+NUNOB)
          ZI(JNIVEA-1+INOCO1)=2
          ZI(JNIVEA-1+INOCO2)=2
 410    CONTINUE
 400  CONTINUE
C
C ---
C --- MARQUAGE DES NOEUDS DE NIVEAU I+1 POUR I=2,3
C ---
C
      DO 500 I=2,3
        DO 510 INO=1,NBNOCO
          NIVINO=ZI(JNIVEA-1+INO)
          IF (NIVINO.NE.I) GOTO 510
          DO 520 IA=1,ZI(JNBEDG-1+INO)
            J=ZI(JLIEDG-1+ZXEDG*(INO-1)+IA)
            NIVJ=ZI(JNIVEA-1+J)
            IF (NIVJ.EQ.0) THEN
              ZI(JNIVEA-1+J)=I+1
              ENDIF
 520      CONTINUE
 510    CONTINUE
 500  CONTINUE
C
C --- REMPLISSAGE NLISUP
C
C     D�COMPTE
      NBNOSU=0
      DO 630 INO=1,NBNOCO
        NIVINO=ZI(JNIVEA-1+INO)
        NBEDGE=ZI(JNBEDG-1+INO)
        IF (NIVINO.GE.3) THEN
C         ON COMPTE LES NOEUDS DE LA RELATION LIN�AIRE
          NBEDLO=0
          DO 640 IA=1,NBEDGE
            J   =ZI(JLIEDG-1+ZXEDG*(INO-1)+IA)
            NIVJ=ZI(JNIVEA-1+J)
            IF (NIVJ.EQ.NIVINO-1) THEN
              NBEDLO=NBEDLO+1
            ENDIF
 640      CONTINUE
          IF (NBEDLO.GT.0) THEN
            NBNOSU=NBNOSU+1
          ENDIF
        ENDIF
 630    CONTINUE
C
C     REMPLISSAGE
      IF (NBNOSU.GT.0) THEN
        CALL WKVECT(NLISUP,'G V I',NBNOSU*ZXEDG,JLISUP)
        NBNOSU=0
        DO 600 INO=1,NBNOCO
          NIVINO=ZI(JNIVEA-1+INO)
          NBEDGE=ZI(JNBEDG-1+INO)
          IF (NIVINO.GE.3) THEN
C           ON COMPTE LES NOEUDS DE LA RELATION LIN�AIRE
            NBEDLO=0
            DO 610 IA=1,NBEDGE
              J   =ZI(JLIEDG-1+ZXEDG*(INO-1)+IA)
              NIVJ=ZI(JNIVEA-1+J)
              IF (NIVJ.EQ.NIVINO-1) THEN
                NBEDLO=NBEDLO+1
              ENDIF
 610        CONTINUE
            IF (NBEDLO.GT.0) THEN
              NBNOSU=NBNOSU+1
              ZI(JLISUP-1+ZXEDG*(NBNOSU-1)+1)=NBEDLO
              ZI(JLISUP-1+ZXEDG*(NBNOSU-1)+2)=ZI(JNOCON-1+INO)
C             ON �CRIT LA RELATION LIN�AIRE DANS NLISUP
              NBEDLO=0
              DO 620 IA=1,NBEDGE
                J   =ZI(JLIEDG-1+ZXEDG*(INO-1)+IA)
                NIVJ=ZI(JNIVEA-1+J)
                IF (NIVJ.EQ.NIVINO-1) THEN
                  NBEDLO=NBEDLO+1
                  INOCO2=ZI(JLIEDG-1+ZXEDG*(INO-1)+IA)
                  ZI(JLISUP-1+ZXEDG*(NBNOSU-1)+2+NBEDLO)=
     &                     ZI(JNOCON-1+INOCO2)
                ENDIF
 620          CONTINUE
            ENDIF
          ENDIF
 600    CONTINUE
      ENDIF

C
C --- DESTRUCTION DES OBJETS TEMPORAIRES
C
      CALL JEDETR(MATRA)
      CALL JEDETR(NOCON)
      CALL JEDETR(LIEDG)
      CALL JEDETR(NBEDG)
      CALL JEDETR(NIVEA)
 900  CONTINUE
      CALL JEDETR(CONID)
      CALL DETRSD('CHAM_NO_S',CNSLT)
      CALL DETRSD('CHAM_NO_S',CNSLN)
      CALL DETRSD('CHAM_NO_S',GRLT)
      CALL DETRSD('CHAM_NO_S',GRLN)
C
      CALL JEDEMA()
      END
