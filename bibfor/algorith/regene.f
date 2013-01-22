      SUBROUTINE REGENE ( NOMRES, RESGEN, PROFNO )
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM
      CHARACTER*8         NOMRES, RESGEN
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 22/01/2013   AUTEUR BERRO H.BERRO 
C ======================================================================
C COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
C  BUT : < RESTITUTION GENERALISEE >
C
C  RESTITUER EN BASE PHYSIQUE LES RESULTATS "MODE_GENE"
C  SANS SOUS-STRUCTURATION
C  LE CONCEPT RESULTAT EST UN RESULTAT COMPOSE "MODE_MECA"
C               OU "MODE_MECA_C"
C-----------------------------------------------------------------------
C
C NOMRES /I/ : NOM K8 DU CONCEPT MODE MECA RESULTAT
C RESGEN /I/ : NOM K8 DU MODE_GENE AMONT
C
C
C
C
C
      INTEGER      I,IADREF,IADRIF,IAREFE,IBID,IDBASE,IER,IORD,IRET,
     &             ITRESU,JBID,LDNEW,LLCHOL,LLINSK,LLNUEQ,LREFE,
     &             NBMOD,NBNOT,NEQ,NNO,NUMO,IADPAR(7),NBMO2,
     &             LLREF1,LLREF2,LLREF3,LLREF4,LLREF5,LLREF6
      REAL*8       FREQ,GENEK,GENEM,OMEG2,RBID,XSI
      COMPLEX*16   CBID
      CHARACTER*1  K1BID,TYPSCA
      CHARACTER*8  BASMOD,RESPRO,KBID,K8B,MODMEC,MAILSK,MODGEN
      CHARACTER*14 NUMDDL
      CHARACTER*16 DEPL,NOMPAR(7),TYPREP
      CHARACTER*19 CHAMNO,KINT,KREFE,CHAMNE,RAID,NUMGEN,PROFNO
      CHARACTER*24 CHAMOL,INDIRF,CREFE(2),NUMEDD,BASMO2
      CHARACTER*24 VALK
      LOGICAL      ZCMPLX
      INTEGER      IARG
C
C-----------------------------------------------------------------------
      DATA DEPL   /'DEPL            '/
      DATA NOMPAR /'FREQ','RIGI_GENE','MASS_GENE','OMEGA2','NUME_MODE',
     &             'AMOR_REDUIT','TYPE_MODE'/
C-----------------------------------------------------------------------
      CALL JEMARQ()
C
C-----RECUPERATION NOMBRE DE MODES PROPRES CALCULES---------------------
C
      ZCMPLX = .FALSE.

      CALL DCAPNO ( RESGEN, DEPL, 1,CHAMOL )
      CALL JELIRA(CHAMOL,'TYPE',IBID,TYPSCA)
      IF (TYPSCA.EQ.'C') ZCMPLX = .TRUE.

      CALL RSORAC ( RESGEN, 'LONUTI', IBID, RBID, KBID, CBID, RBID,
     &              KBID, NBMOD, 1, IBID )
C
C --- ON RESTITUE SUR TOUS LES MODES OU SUR QUELQUES MODES:
C
      CALL GETVIS ( ' ', 'NUME_ORDRE', 1,IARG,0, IBID, NNO )
      IF ( NNO .NE. 0 ) THEN
        NBMOD = -NNO
        CALL WKVECT ( '&&REGENE.NUME', 'V V I', NBMOD, JBID )
        CALL GETVIS ( ' ', 'NUME_ORDRE', 1,IARG,NBMOD, ZI(JBID), NNO )
      ELSE
        CALL WKVECT ( '&&REGENE.NUME', 'V V I', NBMOD, JBID )
        DO 2 I = 1 , NBMOD
           ZI(JBID+I-1) = I
 2      CONTINUE
      ENDIF
C
C --- ALLOCATION STRUCTURE DE DONNEES RESULTAT
C
      IF (ZCMPLX) THEN
        CALL RSCRSD ( 'G', NOMRES, 'MODE_MECA_C', NBMOD )
      ELSE
        CALL RSCRSD ( 'G', NOMRES, 'MODE_MECA', NBMOD )
      ENDIF
C
C --- RECUPERATION DE LA BASE MODALE
C
      CALL JEVEUO(JEXNUM(RESGEN//'           .TACH',1),'L',IAREFE)
      KINT = ZK24(IAREFE)(1:19)
      CALL JEVEUO(KINT//'.VALE','L',ITRESU)
      CALL JEVEUO(KINT//'.REFE','L',IADREF)
      BASMOD = ZK24(IADREF)(1:8)
C
      BASMO2 = BASMOD
      CALL GETTCO ( BASMO2, TYPREP )
C
      IF ( TYPREP(1:9) .EQ. 'MODE_GENE' ) THEN
         CALL GETVID(' ','SQUELETTE',1,IARG,1,MAILSK,IBID)
         INDIRF = '&&REGEGL'//'.INDIR.SST'
C
C ------ VERIF SQUELETTE
C
         CALL JEEXIN ( MAILSK//'.INV.SKELETON',IRET)
         IF (IRET.EQ.0) THEN
            VALK = MAILSK
            CALL U2MESG('F', 'ALGORITH14_27',1,VALK,0,0,0,0.D0)
         ENDIF
         CALL JEVEUO ( MAILSK//'.INV.SKELETON','L',LLINSK)
C
C ------ RECUPERATION DU MODELE GENERALISE
C
         CALL JEVEUO(RESGEN//'           .REFD','L',LLREF1)
         RAID=ZK24(LLREF1)
         CALL JELIBE(RESGEN//'           .REFD')
C
         CALL JEVEUO(RAID//'.REFA','L',LLREF2)
         NUMGEN(1:14)=ZK24(LLREF2+1)
         NUMGEN(15:19)='.NUME'
         CALL JELIBE(RAID//'.REFA')
C
         CALL JEVEUO(NUMGEN//'.REFN','L',LLREF3)
         RESPRO=ZK24(LLREF3)
         CALL JELIBE(NUMGEN//'.REFN')
C
         CALL JEVEUO(RESPRO//'           .REFD','L',LLREF4)
         RAID=ZK24(LLREF4)
         CALL JELIBE(RESPRO//'           .REFD')
C
         CALL JEVEUO(RAID//'.REFA','L',LLREF5)
         NUMGEN(1:14)=ZK24(LLREF5+1)
         NUMGEN(15:19)='.NUME'
         CALL JELIBE(RAID//'.REFA')
C
         CALL JEVEUO(NUMGEN//'.REFN','L',LLREF6)
         MODGEN=ZK24(LLREF6)
         CALL JELIBE(NUMGEN//'.REFN')
C
C ------ CREATION DU PROF-CHAMNO
C
         CALL GENUGL(PROFNO,INDIRF,MODGEN,MAILSK)
         CALL JELIRA(PROFNO//'.NUEQ','LONMAX',NEQ,K1BID)
C
C ------ RECUPERATION DU NOMBRE DE NOEUDS
C
      CALL DISMOI('F','NB_NO_MAILLA',MAILSK,'MAILLAGE',NBNOT,KBID,IRET)
C
C ------ RECUPERATION DE LA BASE MODALE
C
         CREFE(1)=MAILSK
         CREFE(2)=PROFNO
C
CC
CCC ---- RESTITUTION PROPREMENT DITE
CC
C
         CALL JEVEUO (NUMGEN//'.NUEQ','L',LLNUEQ)
         CALL GETVID ( ' ', 'MODE_MECA', 1,IARG,1, MODMEC, IBID )
         IF (IBID.NE.0) BASMOD=MODMEC
         CALL RSORAC ( BASMOD, 'LONUTI', IBID, RBID, KBID, CBID, RBID,
     &              KBID, NBMO2, 1, IBID )
         CALL WKVECT ('&&REGENE.BASEMODE','V V R',NBMO2*NEQ,IDBASE)
         CALL COPMOD(BASMOD,'DEPL',NEQ,PROFNO(1:14),NBMO2,'R',
     &               ZR(IDBASE),CBID)
C
C ------ BOUCLE SUR LES MODES A RESTITUER
C
         DO 10 I = 1,NBMOD
            IORD = ZI(JBID+I-1)
C
C --------- REQUETE NOM ET ADRESSE CHAMNO GENERALISE
C
            CALL DCAPNO ( RESGEN, DEPL, IORD,CHAMOL )
            CALL JEVEUO ( CHAMOL, 'L', LLCHOL )
C
C --------- REQUETE NOM ET ADRESSE NOUVEAU CHAMNO
C
            CALL RSEXCH(' ',NOMRES, DEPL, I, CHAMNE, IER )
            IF (ZCMPLX) THEN
              CALL VTCREA ( CHAMNE, CREFE, 'G', 'C',NEQ )
            ELSE
              CALL VTCREA ( CHAMNE, CREFE, 'G', 'R',NEQ )
            ENDIF
            CALL JEVEUO ( CHAMNE//'.VALE', 'E', LDNEW )
C
            CALL RSADPA ( RESGEN, 'L', 6,NOMPAR, IORD,0,IADPAR,KBID)
            FREQ  = ZR(IADPAR(1))
            GENEK = ZR(IADPAR(2))
            GENEM = ZR(IADPAR(3))
            OMEG2 = ZR(IADPAR(4))
            NUMO  = ZI(IADPAR(5))
            XSI   = ZR(IADPAR(6))

            IF (ZCMPLX) THEN
             CALL MDGEPC ( NEQ,NBMO2,ZR(IDBASE),ZC(LLCHOL),ZC(LDNEW))
            ELSE
             CALL MDGEPH ( NEQ,NBMO2,ZR(IDBASE),ZR(LLCHOL),ZR(LDNEW))
            ENDIF

            CALL RSNOCH ( NOMRES,DEPL,I)
            CALL RSADPA ( NOMRES, 'E', 7,NOMPAR, I,0,IADPAR,KBID)
            ZR(IADPAR(1)) = FREQ
            ZR(IADPAR(2)) = GENEK
            ZR(IADPAR(3)) = GENEM
            ZR(IADPAR(4)) = OMEG2
            ZI(IADPAR(5)) = NUMO
            ZR(IADPAR(6)) = XSI
            ZK16(IADPAR(7)) = 'MODE_DYN'
C
            CALL JELIBE(CHAMOL)
10       CONTINUE
C-----------------------------------------------------------------------
      ELSE
C-----------------------------------------------------------------------
         CALL JEVEUO(BASMOD//'           .REFD','L',IADRIF)

         CALL RSORAC ( BASMOD, 'LONUTI', IBID, RBID, KBID, CBID, RBID,
     &              KBID, NBMO2, 1, IBID )

C         IF (TYPREP(1:9) .EQ. 'BASE_MODA') THEN
           NUMEDD = ZK24(IADRIF+3)
C           WRITE(6,*) 'NUMEDD ',NUMEDD
           CALL GETVID(' ','NUME_DDL',1,IARG,1,K8B,IBID)
           IF (IBID.NE.0) THEN
             CALL GETVID(' ','NUME_DDL',1,IARG,1,NUMEDD,IBID)
             NUMEDD = NUMEDD(1:14)//'.NUME'
           ENDIF
           NUMDDL = NUMEDD(1:14)
           CALL DISMOI('F','NB_EQUA',NUMDDL,'NUME_DDL',NEQ,K8B,IRET)
           CALL WKVECT('&&REGENE.BASEMODE','V V R',NBMO2*NEQ,IDBASE)
           CALL COPMOD(BASMOD,'DEPL',NEQ,NUMDDL,NBMO2,'R',ZR(IDBASE),
     &                 CBID)

CCC ---- RESTITUTION PROPREMENT DITE
CC
C
         DO 20 I=1,NBMOD
            IORD = ZI(JBID+I-1)
C
C --------- REQUETE NOM ET ADRESSE CHAMOL GENERALISE

            CALL DCAPNO ( RESGEN, DEPL, IORD, CHAMOL )
            CALL JEVEUO ( CHAMOL, 'L', LLCHOL )
C
C --------- REQUETE NOM ET ADRESSE NOUVEAU CHAMNO
C
            CALL RSEXCH(' ',NOMRES,DEPL,I,CHAMNO,IER)
            IF (ZCMPLX) THEN
              CALL VTCREB(CHAMNO,NUMEDD,'G','C',NEQ)
            ELSE
              CALL VTCREB(CHAMNO,NUMEDD,'G','R',NEQ)
            ENDIF
            CALL JEVEUO(CHAMNO//'.VALE','E',LDNEW)
C
            CALL RSADPA ( RESGEN, 'L', 6,NOMPAR, IORD,0, IADPAR,KBID)
            FREQ  = ZR(IADPAR(1))
            GENEK = ZR(IADPAR(2))
            GENEM = ZR(IADPAR(3))
            OMEG2 = ZR(IADPAR(4))
            NUMO  = ZI(IADPAR(5))
            XSI   = ZR(IADPAR(6))

            IF (ZCMPLX) THEN
             CALL MDGEPC ( NEQ,NBMO2,ZR(IDBASE),ZC(LLCHOL),ZC(LDNEW))
            ELSE
             CALL MDGEPH ( NEQ,NBMO2,ZR(IDBASE),ZR(LLCHOL),ZR(LDNEW))
            ENDIF

            CALL RSNOCH ( NOMRES,DEPL,I)

            CALL RSADPA ( NOMRES, 'E', 7,NOMPAR, I,0, IADPAR,KBID)
            ZR(IADPAR(1)) = FREQ
            ZR(IADPAR(2)) = GENEK
            ZR(IADPAR(3)) = GENEM
            ZR(IADPAR(4)) = OMEG2
            ZI(IADPAR(5)) = NUMO
            ZR(IADPAR(6)) = XSI
            ZK16(IADPAR(7)) = 'MODE_DYN'
C
            CALL JELIBE(CHAMOL)
20       CONTINUE

         KREFE  = NOMRES
         CALL WKVECT(KREFE//'.REFD','G V K24',7,LREFE)
         ZK24(LREFE  ) = ZK24(IADRIF)
         ZK24(LREFE+1) = ZK24(IADRIF+1)
         ZK24(LREFE+2) = ZK24(IADRIF+2)
         ZK24(LREFE+3) = NUMEDD
         ZK24(LREFE+4) = ZK24(IADRIF+4)
         ZK24(LREFE+5) = ZK24(IADRIF+5)
         ZK24(LREFE+6) = ZK24(IADRIF+6)
         CALL JELIBE(KREFE//'.REFD')
      ENDIF

C --- MENAGE
      CALL JEDETR ( '&&REGENE.NUME' )
      CALL JEDETR ( '&&REGENE.BASEMODE' )
      CALL JEDETR ( '&&REGEGL'//'.INDIR.SST' )

      CALL TITRE
      CALL JEDEMA()
      END
