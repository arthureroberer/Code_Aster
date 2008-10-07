      SUBROUTINE FOCRR0(NOMFON,INTERP,BASE,RESU,NOMCHA,MAILLE,NOEUD,CMP,
     &                  NPOINT,NUSP,IVARI,NBORDR,LORDR)
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER NBORDR,LORDR(*),NPOINT,IVARI
      CHARACTER*1   BASE
      CHARACTER*8   INTERP,MAILLE,NOEUD,CMP
      CHARACTER*16  NOMCHA
      CHARACTER*19  NOMFON,RESU
C     ------------------------------------------------------------------
C MODIF UTILITAI  DATE 07/10/2008   AUTEUR PELLET J.PELLET 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
C     RECUPERATION D'UNE FONCTION DANS UNE STRUCTURE "RESULTAT"
C                  POUR TOUS LES NUMEROS D'ORDRE
C     ------------------------------------------------------------------
C VAR : NOMFON : NOM DE LA FONCTION
C IN  : INTERP : TYPE D'INTERPOLATION DE LA FONCTION
C IN  : BASE   : BASE OU L'ON CREE LA FONCTION
C IN  : RESU   : NOM DE LA STRUCTURE RESULTAT
C IN  : NOMCHA : NOM DU CHAMP
C IN  : NOEUD  : NOEUD
C IN  : MAILLE : MAILE
C IN  : CMP    : COMPOSANTE
C IN  : NPOINT : NUMERO DU POINT ( CAS DES CHAM_ELEMS )
C IN  : NUSP   : NUMERO DU SOUS-POINT ( CAS DES CHAM_ELEMS )
C IN  : IVARI   : NUMERO DE LA CMP (POUR VARI_R)
C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
      CHARACTER*1 TYPE
      CHARACTER*24 VALK(2)
      CHARACTER*8 K8B,NOMA,NOGD
      CHARACTER*16 NOMCMD,TYPCON,NOMACC,TYPCHA,TYPRES
      CHARACTER*19 PROFCH,PROFC2,CHAM19
      COMPLEX*16 VALC
      LOGICAL NVERI1,NVERI2,NVERI3
C     ------------------------------------------------------------------

      CALL JEMARQ()
      CALL GETRES(K8B,TYPCON,NOMCMD)
C GETTCO ne fonctionne pas avec les noms compose issus de sensibilite
C      CALL GETTCO(RESU,TYPRES)
      CALL DISMOI('F','TYPE_RESU',RESU(1:8),'RESULTAT',IBID,TYPRES,IERD)

      CALL RSNOPA(RESU,0,'&&FOCRR0.VAR.ACCES',NBACC,IBID)
      CALL JEEXIN('&&FOCRR0.VAR.ACCES',IRET)
      IF (IRET.GT.0) THEN
         CALL JEVEUO('&&FOCRR0.VAR.ACCES','E',LVACC)
         NOMACC = ZK16(LVACC)
      ELSE
         NOMACC = ' '
      ENDIF

C     --- REMPLISSAGE DU .PROL ---
      CALL ASSERT(LXLGUT(NOMFON).LE.24)
      CALL WKVECT(NOMFON//'.PROL',BASE//' V K24',6,LPRO)
      IF (TYPRES(1:10).EQ.'DYNA_HARMO') THEN
        ZK24(LPRO) = 'FONCT_C'
      ELSE
        ZK24(LPRO) = 'FONCTION'
      END IF
      ZK24(LPRO+1) = INTERP
      ZK24(LPRO+2) = NOMACC
      ZK24(LPRO+3) = CMP
      ZK24(LPRO+4) = 'EE      '
      ZK24(LPRO+5) = NOMFON

      IF (TYPRES(1:10).EQ.'DYNA_HARMO') THEN
        CALL WKVECT(NOMFON//'.VALE',BASE//' V R',3*NBORDR,LVAR)
      ELSE
        CALL WKVECT(NOMFON//'.VALE',BASE//' V R',2*NBORDR,LVAR)
      END IF
      LFON = LVAR + NBORDR
      CALL RSEXCH(RESU,NOMCHA,LORDR(1),CHAM19,IE)
      CALL DISMOI('F','TYPE_SUPERVIS',CHAM19,'CHAMP',IBID,TYPCHA,IE)

      IF (TYPCHA(1:7).EQ.'CHAM_NO') THEN
        CALL DISMOI('F','PROF_CHNO',CHAM19,'CHAM_NO',IBID,PROFCH,IE)
        CALL DISMOI('F','NOM_MAILLA',CHAM19,'CHAM_NO',IBID,NOMA,IE)
        CALL POSDDL('CHAM_NO',CHAM19,NOEUD,CMP,INOEUD,IDDL)
        IF (INOEUD.EQ.0) THEN
          LG1 = LXLGUT(NOEUD)
          CALL U2MESK('F','UTILITAI_92',1,NOEUD(1:LG1))
        ELSE IF (IDDL.EQ.0) THEN
          LG1 = LXLGUT(NOEUD)
          LG2 = LXLGUT(CMP)
         VALK(1) = CMP(1:LG2)
         VALK(2) = NOEUD(1:LG1)
         CALL U2MESK('F','UTILITAI_93', 2 ,VALK)
        END IF
        II = 0
        DO 10 IORDR = 1,NBORDR
          CALL JEMARQ()

C           --- EXTRACTION DU CHAMP ET DE LA VALEUR DE L'ACCES ----
          CALL RSEXCH(RESU,NOMCHA,LORDR(IORDR),CHAM19,IE)
          IF (IE.EQ.0) THEN
            CALL DISMOI('F','PROF_CHNO',CHAM19,'CHAM_NO',IBID,PROFC2,IE)
            IF (PROFC2.NE.PROFCH) THEN
              PROFCH = PROFC2
              CALL POSDDL('CHAM_NO',CHAM19,NOEUD,CMP,INOEUD,IDDL)
              IF (INOEUD.EQ.0) THEN
                LG1 = LXLGUT(NOEUD)
                CALL U2MESK('F','UTILITAI_92',1,NOEUD(1:LG1))
              ELSE IF (IDDL.EQ.0) THEN
                LG1 = LXLGUT(NOEUD)
                LG2 = LXLGUT(CMP)
               VALK(1) = CMP(1:LG2)
               VALK(2) = NOEUD(1:LG1)
               CALL U2MESK('F','UTILITAI_93', 2 ,VALK)
              END IF
            END IF
            CALL RSADPA(RESU,'L',1,NOMACC,LORDR(IORDR),0,LACCE,K8B)
            CALL JEVEUO(CHAM19//'.VALE','L',LVALE)
            IF (TYPRES(1:10).EQ.'DYNA_HARMO') THEN
              ZR(LVAR+IORDR-1) = ZR(LACCE)
              ZR(LFON+II) = DBLE(ZC(LVALE+IDDL-1))
              II = II + 1
              ZR(LFON+II) = DIMAG(ZC(LVALE+IDDL-1))
              II = II + 1
            ELSE
              ZR(LVAR+IORDR-1) = ZR(LACCE)
              ZR(LFON+IORDR-1) = ZR(LVALE+IDDL-1)
            END IF
            CALL JELIBE(CHAM19//'.VALE')
          END IF
          CALL JEDEMA()
   10   CONTINUE

      ELSE IF (TYPCHA(1:9).EQ.'CHAM_ELEM') THEN

C ---    VERIFICATION DE LA PRESENCE DES MOTS CLE GROUP_MA (OU MAILLE)
C ---    ET GROUP_NO (OU NOEUD OU POINT) DANS LE CAS D'UN CHAM_ELEM
C        -------------------------------------------------------------
        NVERI1 = MAILLE .EQ. ' '
        NVERI2 = NOEUD .EQ. ' '
        NVERI3 = NPOINT .EQ. 0
        IF (NVERI1 .OR. (NVERI2.AND.NVERI3)) THEN
          CALL U2MESS('F', 'UTILITAI6_15')
        END IF
        CALL DISMOI('F','NOM_MAILLA',CHAM19,'CHAM_ELEM',IBID,NOMA,IE)
        CALL DISMOI('F','NOM_GD',CHAM19,'CHAM_ELEM',IBID,NOGD,IE)
        CALL DISMOI('F','TYPE_SCA',NOGD,'GRANDEUR',IBID,TYPE,IE)
        II = 0
        DO 20 IORDR = 1,NBORDR
          CALL JEMARQ()

C           --- EXTRACTION DU CHAMP ET DE LA VALEUR DE L'ACCES ----
          CALL RSEXCH(RESU,NOMCHA,LORDR(IORDR),CHAM19,IE)
          IF (IE.EQ.0) THEN
            CALL RSADPA(RESU,'L',1,NOMACC,LORDR(IORDR),0,LACCE,K8B)
            CALL UTCH19(CHAM19,NOMA,MAILLE,NOEUD,NPOINT,NUSP,IVARI,CMP,
     &                  TYPE,VALR,VALC,IRET)
            IF (IRET.EQ.0) THEN
              ZR(LVAR+IORDR-1) = ZR(LACCE)
              IF (TYPE.EQ.'R') THEN
                ZR(LFON+IORDR-1) = VALR
              ELSE
                ZR(LFON+II) = DBLE(VALC)
                II = II + 1
                ZR(LFON+II) = DIMAG(VALC)
                II = II + 1
              END IF
            END IF
          END IF
          CALL JEDEMA()
   20   CONTINUE
      ELSE
        CALL U2MESK('F','UTILITAI_94',1,TYPCHA)
      END IF
      CALL JEDETR('&&FOCRR0.VAR.ACCES')

      CALL JEDEMA()
      END
