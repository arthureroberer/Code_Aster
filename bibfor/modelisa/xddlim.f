      SUBROUTINE XDDLIM(MODELE,MOTCLE,NOMCMP,NBCMP,NOMN,INO,VALIMR,
     &                  VALIMC,VALIMF,PRNM,FONREE,ICOMPT,LISREL)
      IMPLICIT NONE

      INTEGER      INO,ICOMPT,NBCMP,PRNM(*)
      REAL*8       VALIMR
      CHARACTER*4  FONREE
      CHARACTER*8  MODELE,NOMN,VALIMF,NOMCMP(*)
      CHARACTER*16 MOTCLE
      CHARACTER*19 LISREL

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 12/03/2007   AUTEUR GENIAUT S.GENIAUT 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE GENIAUT S.GENIAUT

C
C      TRAITEMENT DE DDL_IMPO SUR UN NOEUD X-FEM
C             (POUR LES MOT CLE DX, DY ,DZ)
C
C IN  MODELE : NOM DE L'OBJET MODELE ASSOCIE AU LIGREL DE CHARGE
C IN  MOTCLE : NOM DE LA COMPOSANTE DU DEPLACEMENT A IMPOSER
C IN  NOMN   : NOM DU NOEUD INO OU EST EFFECTUE LE BLOCAGE
C IN  INO    : NUMERO DU NOEUD OU EST EFFECTUE LE BLOCAGE
C IN  VALIMR : VALEUR DE BLOCAGE SUR CE DDL (FONREE = 'REEL')
C IN  VALIMC : VALEUR DE BLOCAGE SUR CE DDL (FONREE = 'COMP')
C IN  VALIMF : VALEUR DE BLOCAGE SUR CE DDL (FONREE = 'FONC')
C IN  PRNM   : DESCRIPTEUR GRANDEUR SUR LE NOEUD INO
C IN  FONREE : AFFE_CHAR_XXXX OU AFFE_CHAR_XXXX_F

C IN/OUT     
C     ICOMPT : "COMPTEUR" DES DDLS AFFECTES REELLEMENT
C     LISREL : LISTE DE RELATIONS AFFECTEE PAR LA ROUTINE
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
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
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      INTEGER     IER,STANO,JSTANO,JLSN,JLST,NREL,I,NTERM,IREL,DIMENS(6)
      INTEGER     ICMP,INDIK8
      REAL*8      LSN,LST,R,THETA(2),R8PI,HE(2),T,COEF(6),SIGN
      REAL*8      RBID
      CHARACTER*8 DDL(6),NOEUD(6),VALK(2)
      CHARACTER*19 CH1,CH2,CH3
      COMPLEX*16  CBID,VALIMC
      LOGICAL     EXISDG
      DATA        DIMENS/0,0,0,0,0,0/

C ----------------------------------------------------------------------
C
      CALL JEMARQ()

C       REMARQUE : FAIRE DES CALL JEVEUO AU COEUR DE LA BOUCLE SUR 
C      LES NOEUDS ET SUR LES DDLS BLOQUES N'EST PAS OPTIMAL DU POINT
C      DE VUE DES PERFORMANCES, MAIS A PRIORI, CA NE DEVRAIT PAS ETRE
C      POUR BEAUCOUP DE NOEUDS

C     ON NE TRAITE QUE LES MOT CLE DX DY OU DZ
      IF (MOTCLE.NE.'DX'.AND.MOTCLE.NE.'DY'.AND.MOTCLE.NE.'DZ') GOTO 999

C     ON NE TRAITE QUE LES NOEUDS X-FEM 
      ICMP = INDIK8(NOMCMP,'DCX',1,NBCMP)
      IF (.NOT.EXISDG(PRNM,ICMP)) GOTO 999

C     STATUT D'ENRICHISSMENT DU NOEUD
      CH1 = '&&XDDLIM.CHS1'
      CALL CNOCNS(MODELE//'.STNO','V',CH1)
      CALL JEVEUO(CH1//'.CNSV','L',JSTANO)
      STANO=ZI(JSTANO-1+INO)

C     SI LE NOEUD N'EST PAS ENRICHI, ON SORT
      IF (STANO.EQ.0) THEN 
        CALL JEDETR('&&XDDLIM.CHS1')
        GOTO 999
      ENDIF

C     LEVEL SETS AU NOEUD
      CH2 = '&&XDDLIM.CHS2'
      CH3 = '&&XDDLIM.CHS3'
      CALL CNOCNS(MODELE//'.LNNO','V',CH2)
      CALL CNOCNS(MODELE//'.LTNO','V',CH3)
      CALL JEVEUO(CH2//'.CNSV','L',JLSN)
      CALL JEVEUO(CH3//'.CNSV','L',JLST)
      LSN = ZR(JLSN-1+INO)
      LST = ZR(JLST-1+INO)

C     IDENTIFICATIOND DES CAS A TRAITER :
C     SI NOEUD SUR LES LEVRES : 2 RELATIONS (UNE POUR CHAQUE LEVRE)
C     SINON                   : 1 RELATION
      IF (LSN.EQ.0.D0.AND.LST.LT.0.D0) THEN
        NREL = 2
        THETA(1) =  R8PI()
        THETA(2) = -R8PI()
        HE(1)    =  1.D0
        HE(2)    = -1.D0
      ELSE
        NREL = 1
        HE(1)    = SIGN(1.D0,LSN)
        THETA(1) = HE(1)*ABS(ATAN2(LSN,LST))
      ENDIF

      CALL ASSERT(FONREE.EQ.'REEL')

      DO 5 I=1,6
        NOEUD(I)=NOMN
 5    CONTINUE

C     BOUCLE SUR LES RELATIONS
      DO 10 IREL=1,NREL

C       CALCUL DES COORDONNÉES POLAIRES DU NOEUD (R,T)
        R = SQRT(LSN**2+LST**2)
        T = THETA(IREL)

C       COEFFICIENTS ET DDLS DE LA RELATION
        DDL(1) = 'DC'//MOTCLE(2:2)
        COEF(1)=1.D0
        I = 1
        IF (STANO.EQ.1.OR.STANO.EQ.3) THEN 
          I = I+1
          DDL(I) = 'H1'//MOTCLE(2:2)
          COEF(I)=HE(IREL)
        ENDIF
        IF (STANO.EQ.2.OR.STANO.EQ.3) THEN 
          I = I+1
          DDL(I) = 'E1'//MOTCLE(2:2)
          COEF(I)=SQRT(R)*SIN(T/2.D0)
          I = I+1
          DDL(I) = 'E2'//MOTCLE(2:2)
          COEF(I)=SQRT(R)*COS(T/2.D0)
          I = I+1
          DDL(I) = 'E3'//MOTCLE(2:2)
          COEF(I)=SQRT(R)*SIN(T/2.D0)*SIN(T)
          I = I+1
          DDL(I) = 'E4'//MOTCLE(2:2)
          COEF(I)=SQRT(R)*COS(T/2.D0)*SIN(T)
        ENDIF
        NTERM = I

        CALL AFRELA(COEF,CBID,DDL,NOEUD,DIMENS,RBID,NTERM,VALIMR,VALIMC,
     &              VALIMF,'REEL',FONREE,'12',0.D0,LISREL)

 10   CONTINUE

      VALK(1)=MOTCLE(1:8)
      VALK(2)=NOMN
      CALL U2MESG('I','XFEM_6',2,VALK,0,0,1,VALIMR)
      ICOMPT = ICOMPT + 1

      CALL JEDETR('&&XDDLIM.CHS1')
      CALL JEDETR('&&XDDLIM.CHS2')
      CALL JEDETR('&&XDDLIM.CHS3')

 999  CONTINUE

      CALL JEDEMA()
      END
