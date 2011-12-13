      SUBROUTINE PJTYCO(ISOLE,RESUIN,CHAM1,LNOEU,LELNO,LELEM,LELGA)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/12/2011   AUTEUR PELLET J.PELLET 
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
C COMMANDE:  PROJ_CHAMP
C BUT : DETERMINER LES TYPES DE CHAMP A PROJETER


      IMPLICIT   NONE
C
C 0.1. ==> ARGUMENTS
C

      CHARACTER*8 RESUIN
      CHARACTER*19 CHAM1
      LOGICAL ISOLE
      LOGICAL LNOEU,LELNO,LELEM,LELGA

C
C  LNOEU  : .TRUE.  : IL Y A UN CHAM_NO A PROJETER
C  LELNO  : .TRUE.  : IL Y A UN CHAM_ELEM DE TYPE ELNO A PROJETER
C  LELEM  : .TRUE.  : IL Y A UN CHAM_ELEM DE TYPE ELEM A PROJETER
C  LELGA  : .TRUE.  : IL Y A UN CHAM_ELEM DE TYPE ELGA A PROJETER



C
C 0.2. ==> COMMUNS
C ----------------------------------------------------------------------
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
C
      INTEGER I,IE,IRET,IBID
      INTEGER JORDR,NBORDR
      INTEGER IORDR,ISYM,NBSYM
      LOGICAL ACCENO
      REAL*8 PREC
      CHARACTER*4 TYCH
      CHARACTER*8 CRIT
      CHARACTER*16 NOMSYM(200)
      INTEGER IARG

C DEB ------------------------------------------------------------------
      CALL JEMARQ()

      LNOEU=.FALSE.
      LELNO=.FALSE.
      LELEM=.FALSE.
      LELGA=.FALSE.



C       1- CAS CHAMP ISOLE :
C       =====================
      IF (ISOLE) THEN
        CALL DISMOI('F','TYPE_CHAMP',CHAM1,'CHAMP',IBID,TYCH,IBID)
        IF (TYCH.EQ.'NOEU') THEN
          LNOEU=.TRUE.
        ELSEIF (TYCH.EQ.'ELNO') THEN
          LELNO=.TRUE.
        ELSEIF (TYCH.EQ.'ELEM') THEN
          LELEM=.TRUE.
        ELSEIF (TYCH.EQ.'ELGA') THEN
          LELGA=.TRUE.
        ENDIF


C       2- CAS SD_RESULTAT :
C       =====================
      ELSE
        CALL GETVR8(' ','PRECISION',0,IARG,1,PREC,IE)
        CALL GETVTX(' ','CRITERE',0,IARG,1,CRIT,IE)
        CALL RSUTNU(RESUIN,' ',0,'&&PJXXCO.NUME_ORDRE',NBORDR,PREC,CRIT,
     &              IRET)

        IF (IRET.NE.0) THEN
          CALL U2MESK('F','CALCULEL4_61',1,RESUIN)
        ENDIF
        IF (NBORDR.EQ.0) THEN
          CALL U2MESK('F','CALCULEL4_62',1,RESUIN)
        ENDIF

        CALL JEVEUO('&&PJXXCO.NUME_ORDRE','L',JORDR)
        CALL RSUTC4(RESUIN,' ',1,200,NOMSYM,NBSYM,ACCENO)


C       -- DETERMINATION DE LNOEU
        DO 20,ISYM=1,NBSYM
          DO 10,I=1,NBORDR
            IORDR=ZI(JORDR+I-1)
            CALL RSEXCH(RESUIN,NOMSYM(ISYM),IORDR,CHAM1,IRET)

            IF (IRET.EQ.0) THEN
              CALL DISMOI('F','TYPE_CHAMP',CHAM1,'CHAMP',IBID,TYCH,IBID)
              IF (TYCH.EQ.'NOEU') THEN
                LNOEU=.TRUE.
                GOTO 20

              ENDIF
            ENDIF

   10     CONTINUE
   20   CONTINUE

C       -- DETERMINATION DE LELNO
        DO 40,ISYM=1,NBSYM
          DO 30,I=1,NBORDR
            IORDR=ZI(JORDR+I-1)
            CALL RSEXCH(RESUIN,NOMSYM(ISYM),IORDR,CHAM1,IRET)

            IF (IRET.EQ.0) THEN
              CALL DISMOI('F','TYPE_CHAMP',CHAM1,'CHAMP',IBID,TYCH,IBID)
              IF (TYCH.EQ.'ELNO') THEN
                LELNO=.TRUE.
                GOTO 40

              ENDIF
            ENDIF

   30     CONTINUE
   40   CONTINUE

C       -- DETERMINATION DE LELEM
        DO 60,ISYM=1,NBSYM
          DO 50,I=1,NBORDR
            IORDR=ZI(JORDR+I-1)
            CALL RSEXCH(RESUIN,NOMSYM(ISYM),IORDR,CHAM1,IRET)

            IF (IRET.EQ.0) THEN
              CALL DISMOI('F','TYPE_CHAMP',CHAM1,'CHAMP',IBID,TYCH,IBID)
              IF (TYCH.EQ.'ELEM') THEN
                LELEM=.TRUE.
                GOTO 60

              ENDIF
            ENDIF

   50     CONTINUE
   60   CONTINUE

C       -- DETERMINATION DE LELGA
        DO 80,ISYM=1,NBSYM
          DO 70,I=1,NBORDR
            IORDR=ZI(JORDR+I-1)
            CALL RSEXCH(RESUIN,NOMSYM(ISYM),IORDR,CHAM1,IRET)

            IF (IRET.EQ.0) THEN
              CALL DISMOI('F','TYPE_CHAMP',CHAM1,'CHAMP',IBID,TYCH,IBID)
              IF (TYCH.EQ.'ELGA') THEN
                LELGA=.TRUE.
                GOTO 80

              ENDIF
            ENDIF

   70     CONTINUE
   80   CONTINUE
      ENDIF

      CALL JEDEMA()
      END
