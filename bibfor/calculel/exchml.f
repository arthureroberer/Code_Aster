      SUBROUTINE EXCHML(IPARG,IMODAT)
      IMPLICIT NONE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 11/07/2005   AUTEUR VABHHTS J.PELLET 
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
C RESPONSABLE                            VABHHTS J.PELLET
C     ARGUMENTS:
C     ----------
      INTEGER IPARG,IMODAT
C ----------------------------------------------------------------------
C     ENTREES:
C        IGR    : NUMERO DU GREL (COMMON)
C        IMODAT : MODE LOCAL ATTENDU
C        IPARG  : NUMERO DU PARAMETRE DANS L'OPTION
C       (IGR EST RELATIF AU LIGREL SOUS-JACENT A CHIN )

C ----------------------------------------------------------------------
      COMMON /CAII01/IGD,NEC,NCMPMX,IACHIN,IACHLO,IICHIN,IANUEQ,LPRNO,
     &               ILCHLO
      COMMON /CAKK02/TYPEGD
      CHARACTER*8 TYPEGD
      COMMON /CAII04/IACHII,IACHIK,IACHIX
      COMMON /CAII02/IAOPTT,LGCO,IAOPMO,ILOPMO,IAOPNO,ILOPNO,IAOPDS,
     +       IAOPPA,NPARIO,NPARIN,IAMLOC,ILMLOC,IADSGD
      INTEGER        IAWLOC,IAWTYP,NBELGR,IGR,JCTEAT,LCTEAT
      COMMON /CAII06/IAWLOC,IAWTYP,NBELGR,IGR,JCTEAT,LCTEAT
      COMMON /CAII08/IEL

C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C ---------------- FIN COMMUNS NORMALISES  JEVEUX  --------------------

C     FONCTIONS EXTERNES:
C     ------------------

C     VARIABLES LOCALES:
C     ------------------
      INTEGER JCELD,MODE,DEBUGR,LGGREL
      INTEGER ITYPL1,MODLO1,NBPOI1,LGCATA
      INTEGER ITYPL2,MODLO2,NBPOI2
      INTEGER ILOPMO,IAOPMO,ILOPNO,IAOPDS,IAOPPA,NPARIO,NPARIN,IAMLOC
      INTEGER ILMLOC,IADSGD,IEL,IGD,NEC
      INTEGER NCMPMX,IACHIN,IACHLO,IICHIN,IANUEQ,LPRNO,ILCHLO,IACHII
      INTEGER IACHIK,IACHIX,IAOPTT,LGCO,IAOPNO
      INTEGER JEC,NCMP,JAD1,JAD2,JEL,IPT2,K,IPT1,LONG2,DIGDE2
      LOGICAL ETENDU
      CHARACTER*8 TYCH
C DEB-------------------------------------------------------------------

      TYCH = ZK8(IACHIK-1+2* (IICHIN-1)+1)
      IF (TYCH(1:4).NE.'CHML') CALL UTMESS('F','EXCHML','STOP 1')

      JCELD = ZI(IACHII-1+11* (IICHIN-1)+4)
      LGGREL = ZI(JCELD-1+ZI(JCELD-1+4+IGR)+4)
      DEBUGR = ZI(JCELD-1+ZI(JCELD-1+4+IGR)+8)

      MODE = ZI(JCELD-1+ZI(JCELD-1+4+IGR)+2)
      LONG2 = DIGDE2(IMODAT)*NBELGR

C     -- SI MODE=0 : IL FAUT METTRE CHAMP_LOC.EXIS A .FALSE.
      IF (MODE.EQ.0) THEN
        DO 77,K=1,LONG2
          ZL(ILCHLO-1+K) = .FALSE.
77      CONTINUE
        GO TO 9999
      END IF


C     -- SI LE CHAMP A LE MODE ATTENDU : ON RECOPIE
C     ----------------------------------------------------
      IF (MODE.EQ.IMODAT) THEN
C       LGGREL EST > LONG2 SI LE CHAMP EST ETENDU :
        LONG2=LGGREL
        CALL JACOPO(LONG2,TYPEGD,IACHIN-1+DEBUGR,IACHLO)
      ELSE


C     -- SI LE CHAMP N'A PAS LE MODE ATTENDU ...
C     ----------------------------------------------------
        CALL CHLOET(IPARG,ETENDU,JCELD)
        IF (ETENDU) THEN
          CALL UTMESS('F','EXCHML','CHAM_ELEM ETENDU A FAIRE ... ')
        ELSE
          MODLO1 = IAMLOC - 1 + ZI(ILMLOC-1+MODE)
          MODLO2 = IAMLOC - 1 + ZI(ILMLOC-1+IMODAT)
          ITYPL1 = ZI(MODLO1-1+1)
          ITYPL2 = ZI(MODLO2-1+1)
          CALL ASSERT(ITYPL1.LE.3)
          CALL ASSERT(ITYPL2.LE.3)
          NBPOI1 = ZI(MODLO1-1+4)
          NBPOI2 = ZI(MODLO2-1+4)

C         -- ON VERIFIE QUE LES POINTS NE SONT PAS "DIFF__" :
          CALL ASSERT(NBPOI1.LT.10000)
          CALL ASSERT(NBPOI2.LT.10000)

          CALL ASSERT(LONG2.EQ.(LGGREL/NBPOI1)*NBPOI2)

C         -- ON VERIFIE QUE LES CMPS SONT LES MEMES:
C            (SINON IL FAUDRAIT TRIER ... => A FAIRE (TRIGD) )
          DO 71, JEC=1,NEC
            CALL ASSERT(ZI(MODLO1-1+4+JEC).EQ.ZI(MODLO2-1+4+JEC))
 71       CONTINUE
          LGCATA = ZI(IAWLOC-1+7* (IPARG-1)+4)
          NCMP=LGCATA/NBPOI2

C         -- CAS "EXPAND" :
C         ------------------------
          IF (NBPOI1.EQ.1) THEN
            DO 11, JEL=1,NBELGR
              JAD1=IACHIN-1+DEBUGR+(JEL-1)*NCMP
              DO 12, IPT2=1,NBPOI2
                JAD2=IACHLO+((JEL-1)*NBPOI2+IPT2-1)*NCMP
                CALL JACOPO(NCMP,TYPEGD,JAD1,JAD2)
12            CONTINUE
11          CONTINUE

C         -- CAS "MOYENN" :
C         ------------------------
          ELSE IF (NBPOI2.EQ.1) THEN

            IF (TYPEGD.EQ.'R') THEN
              DO 171,K=1,NBELGR *NCMP
                ZR(IACHLO-1+K) = 0.D0
171           CONTINUE
            ELSE IF (TYPEGD.EQ.'C') THEN
              DO 172,K=1,NBELGR *NCMP
                ZC(IACHLO-1+K) = (0.D0,0.D0)
172           CONTINUE
            ELSE
              CALL ASSERT(.FALSE.)
            END IF

            DO 21, JEL=1,NBELGR
              JAD2=IACHLO+(JEL-1)*NCMP
              DO 22, IPT1=1,NBPOI1
                JAD1=IACHIN-1+DEBUGR+((JEL-1)*NBPOI1+IPT1-1)*NCMP
                DO 23, K=0,NCMP-1
                  IF (TYPEGD.EQ.'R') THEN
                    ZR(JAD2+K)=ZR(JAD2+K)+ZR(JAD1+K)/DBLE(NBPOI1)
                  ELSE IF (TYPEGD.EQ.'C') THEN
                    ZC(JAD2+K)=ZC(JAD2+K)+ZC(JAD1+K)/DBLE(NBPOI1)
                  END IF
23              CONTINUE
22            CONTINUE
21          CONTINUE

C         -- AUTRES CAS PAS ENCORE PROGRAMMES :
          ELSE
            CALL UTMESS('F','EXCHML','A FAIRE ... ')
          END IF
        END IF
      END IF

      DO 10,K = 1,LONG2
        ZL(ILCHLO-1+K) = .TRUE.
   10 CONTINUE

9999  CONTINUE
      END
