      SUBROUTINE ASCAVC(CHARGE,INFCHA,FOMULT,NUMEDD,INST,VCI)
      IMPLICIT NONE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 28/01/2005   AUTEUR VABHHTS J.PELLET 
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

      CHARACTER*24 CHARGE,INFCHA,FOMULT
      CHARACTER*(*) VCI,NUMEDD
      REAL*8 INST
C ----------------------------------------------------------------------
C BUT  :  CALCUL DU CHAM_NO CONTENANT LE VECTEUR LE CINEMATIQUE
C ---     ASSOCIE A LA LISTE DE CHAR_CINE_* CHARGE A UN INSTANT INST
C         AVEC LES FONCTIONS MULTIPLICATIVES FOMULT.
C ----------------------------------------------------------------------
C IN  K*24 CHARGE : NOM DE L'OJB S V K24 CONTENANT LA LISTE DES CHARGES
C IN  K*19 INFCHA : NOM DE L'OJB S V I CONTENANT LA LISTE DES INFO.
C IN  K*24 FOMULT : NOM DE L'OJB S V K24 CONTENANT LA LISTE DES FONC.
C IN  K*14 NUMEDD  : NOM DE LA NUMEROTATION SUPPORTANT LE CHAM_NO
C IN  R*8  INST   : VALE DU PARAMETRE INST.
C VAR/JXOUT  K*19 VCI    :  CHAM_NO RESULTAT
C   -------------------------------------------------------------------
C     ASTER INFORMATIONS:
C       04/12/03 (OB): BLINDAGE POUR EVITER FETI + AFFE_CHAR_CINE
C----------------------------------------------------------------------
C     FONCTIONS JEVEUX
C-----------------------------------------------------------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXATR
C-----------------------------------------------------------------------
C     COMMUNS   JEVEUX
C-----------------------------------------------------------------------
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
C----------------------------------------------------------------------
C     VARIABLES LOCALES
C----------------------------------------------------------------------
      INTEGER IDCHAR,IDINFO,IDFOMU,NCHTOT,NCHCI,ICHAR,ICINE,ILCHNO
      INTEGER NEQ,ICHCI,IBID,IFM,NIV
      CHARACTER*8 NEWNOM
      CHARACTER*19 CHARCI,CHAMNO,VCI2
      CHARACTER*24 VACHCI
      INTEGER     NBREFN,IREFN,IER
      CHARACTER*8 K8BID
      LOGICAL     LFETI
      DATA CHAMNO/'&&ASCAVC.???????'/
      DATA VACHCI/'&&ASCAVC.LISTE_CI'/
C----------------------------------------------------------------------


      CALL JEMARQ()
      IF (VCI.EQ.' ') VCI='&&ASCAVC.VCI'
      VCI2=VCI
C RECUPERATION ET MAJ DU NIVEAU D'IMPRESSION
      CALL INFNIV(IFM,NIV)

C --- TEST POUR SAVOIR SI LE SOLVEUR EST DE TYPE FETI
C --- NUME_DDL ET DONC MATR_ASSE ETENDU, OUI OU NON ?
      CALL JELIRA(NUMEDD(1:14)//'.NUME.REFN','LONMAX',NBREFN,K8BID)
      LFETI = .FALSE.
      IF ((NBREFN.NE.4).AND.(NIV.GE.3)) THEN
        WRITE(IFM,*)'<FETI/ASCAVC> NUME_DDL NON ETENDU POUR FETI ',
     &              NUMEDD(1:14)//'.NUME.REFN'
      ELSE
        CALL JEVEUO(NUMEDD(1:14)//'.NUME.REFN','L',IREFN)
        IF (ZK24(IREFN+2).EQ.'FETI') LFETI=.TRUE.
      ENDIF

      NEWNOM='.0000000'

      CALL JEDETR(VACHCI)

      CALL JEVEUO(CHARGE,'L',IDCHAR)
      CALL JEVEUO(INFCHA,'L',IDINFO)
      CALL JEVEUO(FOMULT,'L',IDFOMU)

      NCHTOT = ZI(IDINFO)
      NCHCI = 0

      DO 10 ICHAR = 1,NCHTOT
        ICINE = ZI(IDINFO+ICHAR)
        IF (ICINE.LT.0) NCHCI = NCHCI + 1
   10 CONTINUE


      CALL WKVECT(VACHCI,'V V K24',MAX(NCHCI,1),ILCHNO)

C     -- S'IL N'Y A PAS DE CHARGES CINEMATIQUES, ON CREE UN CHAMP NUL:
      IF (NCHCI.EQ.0) THEN
        CALL GCNCO2(NEWNOM)
        CHAMNO(10:16) = NEWNOM(2:8)
        CALL CORICH('E',CHAMNO,-2,IBID)
        CALL VTCREB(CHAMNO,NUMEDD,'V','R',NEQ)
        ZK24(ILCHNO-1+1) = CHAMNO


C     -- S'IL Y A DES CHARGES CINEMATIQUES :
      ELSE

        IF (LFETI) CALL UTMESS('F','ASCAVC',
     &     'LES CHARGES CINEMATIQUES SONT POUR L''INSTANT '//
     &     'PROSCRITES AVEC FETI')

        ICHCI = 0
        DO 20 ICHAR = 1,NCHTOT
          ICINE = ZI(IDINFO+ICHAR)
          IF (ICINE.LT.0) THEN
            ICHCI = ICHCI + 1
            CALL GCNCO2(NEWNOM)
            CHAMNO(10:16) = NEWNOM(2:8)
            CALL CORICH('E',CHAMNO,ICHAR,IBID)
            CHARCI = ZK24(IDCHAR-1+ICHAR)
            ZK24(ILCHNO-1+ICHCI) = CHAMNO
            CALL CALVCI(CHAMNO,NUMEDD,1,CHARCI,INST,'V')
            CALL JEEXIN(VCI2//'.DLCI',IER)
            IF (IER.EQ.0) CALL JEDUPO(CHAMNO//'.DLCI','V',
     &                    VCI2//'.DLCI',.FALSE.)
            CALL JEDETR(CHAMNO//'.DLCI')
          END IF
   20   CONTINUE
      END IF

C     -- ON COMBINE LES CHAMPS CALCULES :

      CALL ASCOVA('D',VACHCI,FOMULT,'INST',INST,'R',VCI2)

      CALL JEDEMA()
      END
