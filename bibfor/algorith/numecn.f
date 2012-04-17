      SUBROUTINE NUMECN(MODELE,CHAMP,NUME)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 17/04/2012   AUTEUR DELMAS J.DELMAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE PELLET J.PELLET
C----------------------------------------------------------------------
      IMPLICIT NONE
      CHARACTER*(*) MODELE,CHAMP
      CHARACTER*(*) NUME
C ----------------------------------------------------------------------
C  IN/JXIN   : MODELE : MODELE
C  IN/JXIN   : CHAMP  : CHAMP "MODELE" POUR LA NUMEROTATION
C  VAR/JXOUT : NUME   : NUME_EQUA
C ----------------------------------------------------------------------
C BUT CREER UN NUME_EQUA (SANS STOCKAGE)
C
C CETTE ROUTINE ETANT APPELEE DANS UNE BOUCLE SUR LES NUMEROS D'ORDRE
C ON CHERCHE A LIMITER LE NOMBRE DE NUME DIFFERENTS CREES
C EN COMPARANT 2 APPELS SUCCESSIFS
C ----------------------------------------------------------------------
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

C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
      CHARACTER*8 KBID,MO
      CHARACTER*24 LLIGR,LLIGRS,NOOJB
      CHARACTER*19 PRFCHN,NOMLIG,NUMES
      INTEGER IBID,NB1,JLLIGR,I1,I2,IRET,NB2,IEXI
      CHARACTER*14 NU14
      CHARACTER*19 NU19,K19BID
      LOGICAL IDENOB,NEWNUM
      SAVE NUMES
C DEB ------------------------------------------------------------------

      CALL JEMARQ()
      MO=MODELE
      CALL DISMOI('F','PROF_CHNO',CHAMP,'CHAM_NO',IBID,PRFCHN,IBID)
      CALL JELIRA(PRFCHN//'.LILI','NOMMAX',NB1,KBID)



C     1. -- CALCUL DE LLIGR : LISTE DES LIGRELS:
C     ----------------------------------------
      LLIGR = '&&NUMECN.LISTE_LIGREL'
      IF (NB1.EQ.1) THEN
        CALL WKVECT(LLIGR,'V V K24',1,JLLIGR)
        ZK24(JLLIGR-1+1) = MO//'.MODELE'
      ELSE
C       ON N'AJOUTE QUE LES LIGRELS QUI EXISTENT ENCORE :
        NB2=0
        DO 10 I1 = 2,NB1
          CALL JENUNO(JEXNUM(PRFCHN//'.LILI',I1),NOMLIG)
          CALL JEEXIN(NOMLIG//'.LIEL',IRET)
          IF (IRET.NE.0) THEN
            IF (NOMLIG.NE.MO//'.MODELE' )  NB2=NB2+1
          END IF
   10   CONTINUE
        CALL WKVECT(LLIGR,'V V K24',NB2+1,JLLIGR)
        I2=1
        ZK24(JLLIGR-1+I2) = MO//'.MODELE'
        DO 11 I1 = 2,NB1
          CALL JENUNO(JEXNUM(PRFCHN//'.LILI',I1),NOMLIG)
          CALL JEEXIN(NOMLIG//'.LIEL',IRET)
          IF (IRET.NE.0) THEN
            IF (NOMLIG.NE.MO//'.MODELE' ) THEN
              I2=I2+1
              ZK24(JLLIGR-1+I2) = NOMLIG
            END IF
          END IF
   11   CONTINUE
      END IF


C     2. -- ON SAUVEGARDE LA LISTE DES LIGRELS D'UNE FOIS SUR L'AUTRE
C           POUR NE PAS RECREER PLUSIEURS FOIS LE MEME NUME_EQUA
C       => NEWNUM : FAUT-IL CREER UN NOUVEAU NUME_EQUA ?
C       => LLIGRS : LISTE DES LIGRELS SAUVEGARDEE
C     ----------------------------------------------------------------
      LLIGRS= '&&NUMECN.LISTE_LIGREL_S'
      NEWNUM=.TRUE.
      CALL JEEXIN(LLIGRS,IEXI)
      IF (IEXI.GT.0) THEN
        IF (IDENOB(LLIGR,LLIGRS)) NEWNUM=.FALSE.
        CALL JEDETR(LLIGRS)
      ENDIF
      CALL JEDUPO(LLIGR,'V',LLIGRS,.FALSE.)



C     3. -- ON CALCULE NU14 SI NECESSAIRE :
C     -------------------------------------
      IF (NEWNUM) THEN
        NOOJB='12345678.00000.NUME.PRNO'
        CALL GNOMSD ( NOOJB,10,14)
        NU14=NOOJB(1:14)

        K19BID=' '
        CALL NUEFFE(LLIGR,'VG',NU14,'SANS',' ',K19BID,IBID)
        NU19=NU14
        CALL JEDETR(NU19//'.ADLI')
        CALL JEDETR(NU19//'.ADNE')
        NUME=NU14//'.NUME'
        NUMES=NUME
      ELSE
        NUME=NUMES
      ENDIF



      CALL JEDETR(LLIGR)
      CALL JEDEMA()
      END
