      SUBROUTINE GCOURO ( BASE, RESU, NOMA, NOMNO, COORN, LOBJ2, TRAV1, 
     &                   TRAV2, TRAV3, DIR, NOMNOE, FOND, DIREC, STOK4 )
      IMPLICIT REAL*8 (A-H,O-Z)
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 30/09/2008   AUTEUR REZETTE C.REZETTE 
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
C
C FONCTION REALISEE:
C
C     OPTION COURONNE
C     ---------------
C
C 1.  POUR CHAQUE NOEUD DU FOND DE FISSURE GAMM0 ON RECUPERE
C     LE TRIPLET ( MODULE(THETA), RINF, RSUP )
C
C 2.  PUIS ON CALCULE LA DIRECTION DE THETA SI CELLE-CI N'EST PAS DONNEE
C     PAR APPEL A GDIREC
C
C 3.  ENSUITE ON CALCULE THETA SUR TOUS LES NOEUDS DU MAILLAGE
C
C     ------------------------------------------------------------------
C ENTREE:
C        BASE   : BASE DE CREATION DU CHAMP CHAM_NO
C        RESU   : NOM DU CONCEPT DE TYPE CHAM_NO
C        NOMA   : NOM DU MAILLAGE
C        NOMNO  : NOM DE L'OBJET CONTENANT LES NOEUDS DU MAILLAGE
C        NOMNOE : NOMS DES NOEUDS DU FOND DE FISSURE
C        COORN  : NOM DE L'OBJET CONTENANT LES COORDONNEES DU MAILLAGE
C        LOBJ2  : NOMBRE DE NOEUDS DE GAMM0
C        FOND   : NOM DE CONCEPT POUR DEFI_FOND_FISS CONTENANT LES
C                 NOEUD DU FOND DE FISSURE
C        DIREC  : SI LA DIRECTION EST DONNEE ALORS DIREC=.TRUE.
C                      ON LA RECUPERE ( DIR )
C                 SINON ON LA CALCULE DIREC=.FALSE.
C                       APPEL A GDIREC
C        TRAV1  : RINF
C        TRAV2  : RSUP
C
C SORTIE:
C        STOK4  : DIRECTION DU CHAMP THETA
C                     LISTE DE CHAMPS_NO THETA
C        TRAV3  : MODULE(THETA)
C     ------------------------------------------------------------------
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
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
      CHARACTER*8 CHBID
      CHARACTER*1 K1BID
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
      CHARACTER*24      OBJ3,STOK1,STOK2,STOK3,NUMGAM,CHAMNO
      CHARACTER*24      TRAV1,TRAV2,TRAV3,OBJOR,OBJEX,DIRTH
      CHARACTER*24      NORM,STOK4,DIRE4,COORN,NOMNO,DIRE5,INDICG,RESU
      CHARACTER*8       FOND,NOMA,NOMNOE(*),K8B
      CHARACTER*16      NOMCMD,MOTFAC,K16B
      CHARACTER*1       BASE
C
      INTEGER           LOBJ2,IADRT1,IADRT2,IADRT3,IDIREC,ITHETA
      INTEGER           IM2,IN2,IADRCO,JMIN,IELINF,IADNUM,IOCC,JNORM
      INTEGER           NNOEU,NUM,INDIC,IERD,IADRTT,NBRE,NEC,IBID
      INTEGER           IRET,NUMA,NDIMTE,IENORM,NBDIR,IDIRTH,IDEEQ
      INTEGER           IREFE
C
      REAL*8            DIRX,DIRY,DIRZ,XI1,YI1,ZI1,XJ1,YJ1,ZJ1
      REAL*8            XIJ,YIJ,ZIJ,EPS,D,TEI,TEJ
      REAL*8            XM,YM,ZM,XIM,YIM,ZIM,S,DMIN,SMIN,XN,YN,ZN
      REAL*8            RII,RSI,ALPHA,VALX,VALY,VALZ,NORM2
      REAL*8            NORME,VECX,VECY,VECZ,DIR(3),TMPV(3),PSCA
C
      LOGICAL           DIREC,SUIV,MILIEU
C     ------------------------------------------------------------------
C
      CALL JEMARQ()

      CALL GETRES(K8B,K16B,NOMCMD)
      IF (NOMCMD .EQ. 'CALC_G')THEN
          MOTFAC='THETA'
          IOCC=1
      ELSE
          MOTFAC=' '
          IOCC=0
      ENDIF

      CALL JEVEUO(COORN,'L',IADRCO)
      CALL JEVEUO(TRAV1,'L',IADRT1)
      CALL JEVEUO(TRAV2,'L',IADRT2)
      CALL JEVEUO(TRAV3,'E',IADRT3)
      EPS = 1.D-06
C
C RECUPERATION  DES NUMEROS DE NOEUDS DE GAMM0
C
      NUMGAM = '&&COURON.NUMGAMM0'
      CALL WKVECT(NUMGAM,'V V I',LOBJ2,IADNUM)
      DO 550 J=1,LOBJ2
            CALL JENONU(JEXNOM(NOMNO,NOMNOE(J)),ZI(IADNUM+J-1))
550   CONTINUE
C
C RECUPERATION DES DIRECTIONS AUX EXTREMITES DE GAMM0 (EN 3D)
C
      OBJOR  = FOND//'.DTAN_ORIGINE'
      CALL JEEXIN(OBJOR,ITANOR)
      OBJEX  = FOND//'.DTAN_EXTREMITE'
      CALL JEEXIN(OBJEX,ITANEX)
C
C  SI LEVRE_SUP EST DEFINIE DANS LE CONCEPT FOND
C
      OBJ3  = FOND//'.LEVRESUP  .MAIL'
      CALL JEEXIN(OBJ3,IELSUP)
C
C  SI LEVRE_INF EST DEFINIE DANS LE CONCEPT FOND
C
      OBJ3  = FOND//'.LEVREINF  .MAIL'
      CALL JEEXIN(OBJ3,IELINF)
C
C  SI NORMALE EST DEFINIE DANS LE CONCEPT FOND
C
      NORM  = FOND//'.NORMALE        '
      CALL JEEXIN(NORM,IENORM)
C
      STOK4 = '&&COURON.DIREC'
      CALL WKVECT(STOK4,'V V R',3*LOBJ2,IN2)
C
      DIRE4 = '&&COURON.LEVRESUP'
      DIRE5 = '&&COURON.LEVREINF'
C
C  RECUPERATION DIRECTION DU CHAMP THETA

C     DANS LE CAS OU LA NORMALE EST DEFINIE DANS DEFI_FOND_FISS/NORMALE,
C     ON AVERTIT L'UTILISATEUR PAR UNE ALARME SI LA DIRECTION N'EST PAS
C     FOURNIE
      IF(.NOT.DIREC.AND.IENORM.NE.0)THEN
        CALL U2MESS('A','RUPTURE0_91')
      ENDIF
C     ON VERIFIE QUE LA DIRECTION FOURNIE EST ORTHOGONALE A LA NORMALE
      
      IF(DIREC.AND.IENORM.NE.0)THEN
          CALL JEVEUO(NORM,'L',JNORM)
          CALL DCOPY(3,ZR(JNORM),1,TMPV,1)
          CALL NORMEV(DIR,NORME)
          CALL NORMEV(TMPV,NORME)
          CALL LCPRSN(3,DIR,TMPV,PSCA)
          IF(ABS(PSCA).GT.0.1D0)CALL U2MESS('F','RUPTURE0_94')
      ENDIF
      CALL GETVID(MOTFAC,'DIRE_THETA',IOCC,1,1,DIRTH,NBDIR)
C
C 1ER CAS: LA DIRECTION DE THETA EST DONNEE, ON LA NORME
C
      IF (DIREC) THEN
        NORME = 0.D0
        DO 991 I=1,3
          NORME =  NORME + DIR(I)*DIR(I)
991     CONTINUE
        NORME = SQRT(NORME)
        DO 1 I=1,LOBJ2
          ZR(IN2+(I-1)*3+1-1) = DIR(1)/NORME
          ZR(IN2+(I-1)*3+2-1) = DIR(2)/NORME
          ZR(IN2+(I-1)*3+3-1) = DIR(3)/NORME
1       CONTINUE
      ELSE IF (NBDIR.NE.0) THEN
C
C 2ER CAS: LA DIRECTION DU CHAMP THETA EST DONNEE EN CHAQUE NOEUD
C          DU FOND DE FISSURE PAR L'UTILISATEUR
C
        CALL CHPVER('F',DIRTH(1:19),'NOEU','DEPL_R',IERD)
        DIRTH(20:24) = '.VALE'
        CALL JEVEUO(DIRTH,'L',IDIRTH)
        CALL JELIRA(DIRTH,'LONMAX',LNDIR,K1BID)
        DIRTH(20:24) = '.REFE'
        CALL JEVEUO(DIRTH,'L',IREFE)
        CALL JEVEUO(ZK24(IREFE+1)(1:19)//'.DEEQ','L',IDEEQ)
        CALL ASSERT(LNDIR.EQ.(3*LOBJ2))
        DO 5 I=1,LOBJ2
          DIRX = ZR(IDIRTH+(I-1)*3+1-1)
          DIRY = ZR(IDIRTH+(I-1)*3+2-1)
          DIRZ = ZR(IDIRTH+(I-1)*3+3-1)
          NORME = SQRT(DIRX*DIRX + DIRY*DIRY + DIRZ*DIRZ)
          SUIV = .FALSE.
          DO 6 J=1,LOBJ2
            IF (ZI(IADNUM+J-1).EQ.ZI(IDEEQ+6*(I-1)+1-1)) THEN
              ZR(IN2+(J-1)*3+1-1) = DIRX/NORME
              ZR(IN2+(J-1)*3+2-1) = DIRY/NORME
              ZR(IN2+(J-1)*3+3-1) = DIRZ/NORME
              SUIV = .TRUE.
            ENDIF
            IF (SUIV) GOTO 5
 6        CONTINUE
 5      CONTINUE

      ELSE
C
C 3ER CAS: LA DIRECTION DE THETA EST CALCULEE, ON LA NORME
C
C  LEVRE SUPERIEURE
C
        IF (IELSUP.NE.0) THEN
         CALL GDIREC(NOMA,FOND,'LEVRESUP',NOMNO,NOMNOE,COORN,
     &              LOBJ2,DIRE4,MILIEU)
        CALL JEVEUO(DIRE4,'L',IDIRS)
          IF (IELINF.NE.0) THEN
C
C  LEVRE INFERIEURE
C
            CALL GDIREC(NOMA,FOND,'LEVREINF',NOMNO,NOMNOE,COORN,
     &               LOBJ2,DIRE5,MILIEU)
            CALL JEVEUO(DIRE5,'L',IDIRI)
C
C LES DIRECTIONS OBTENUES POUR CHAQUE LEVRE SONT MOYENNEES ET NORMEES
C
            DO 2 I=1,LOBJ2
               DIRX = ZR(IDIRI+(I-1)*3+1-1)
               DIRY = ZR(IDIRI+(I-1)*3+2-1)
               DIRZ = ZR(IDIRI+(I-1)*3+3-1)
               VECX = (ZR(IDIRS+(I-1)*3+1-1)+DIRX)/2
               VECY = (ZR(IDIRS+(I-1)*3+2-1)+DIRY)/2
               VECZ = (ZR(IDIRS+(I-1)*3+3-1)+DIRZ)/2
               NORME = SQRT(VECX*VECX + VECY*VECY + VECZ*VECZ)
               ZR(IN2+(I-1)*3+1-1) = VECX/NORME
               ZR(IN2+(I-1)*3+2-1) = VECY/NORME
               ZR(IN2+(I-1)*3+3-1) = VECZ/NORME
2           CONTINUE
          ELSE
            DO 22 I=1,LOBJ2
              DIRX = ZR(IDIRS+(I-1)*3+1-1)
              DIRY = ZR(IDIRS+(I-1)*3+2-1)
              DIRZ = ZR(IDIRS+(I-1)*3+3-1)
              NORME = SQRT(DIRX*DIRX + DIRY*DIRY + DIRZ*DIRZ)
              ZR(IN2+(I-1)*3+1-1) = DIRX/NORME
              ZR(IN2+(I-1)*3+2-1) = DIRY/NORME
              ZR(IN2+(I-1)*3+3-1) = DIRZ/NORME
22          CONTINUE
          ENDIF
        ELSE IF (IENORM.NE.0) THEN
          CALL GDINOR(NORM,LOBJ2,IADNUM,COORN,IN2)
        ELSE
          CALL U2MESS('F','RUPTURE0_98')
        ENDIF
C
C  ON RECUPERE LES DIRECTIONS UTILISATEUR AUX EXTREMITES DU FOND(EN 3D)
C
        IF (ITANOR.NE.0) THEN
          CALL JEVEUO(OBJOR,'L',IAORIG)
          VECX = ZR(IAORIG)
          VECY = ZR(IAORIG+1)
          VECZ = ZR(IAORIG+2)
          NORME = SQRT(VECX*VECX + VECY*VECY + VECZ*VECZ)
          ZR(IN2+1-1) = VECX/NORME
          ZR(IN2+2-1) = VECY/NORME
          ZR(IN2+3-1) = VECZ/NORME
        ENDIF
        IF (ITANEX.NE.0) THEN
          CALL JEVEUO(OBJEX,'L',IAEXTR)
          VECX = ZR(IAEXTR)
          VECY = ZR(IAEXTR+1)
          VECZ = ZR(IAEXTR+2)
          NORME = SQRT(VECX*VECX + VECY*VECY + VECZ*VECZ)
          ZR(IN2+3*(LOBJ2-1)+1-1) = VECX/NORME
          ZR(IN2+3*(LOBJ2-1)+2-1) = VECY/NORME
          ZR(IN2+3*(LOBJ2-1)+3-1) = VECZ/NORME
        ENDIF
      ENDIF
C
C ALLOCATION D UN OBJET INDICATEUR DU CHAMP THETA SUR GAMMO
C
      CALL DISMOI('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NBEL,CHBID,IERD)
      INDICG = '&&COURON.INDIC        '
      CALL WKVECT(INDICG,'V V I',NBEL,INDIC)
C
C ALLOCATION DES OBJETS POUR STOCKER LE CHAMP_NO THETA ET LA DIRECTION
C TYPE CHAM_NO ( DEPL_R) AVEC PROFIL NOEUD CONSTANT (3 DDL)
C
      CHAMNO(1:19) = RESU(1:19)
C
C  .DESC
      CHAMNO(20:24) = '.DESC'
      CALL DISMOI('F','NB_EC','DEPL_R','GRANDEUR',NEC,K1BID,IBID)
      CALL WKVECT(CHAMNO,BASE//' V I',2+NEC,IDESC)
C
      CALL JEECRA(CHAMNO,'DOCU',0,'CHNO')
      CALL JENONU(JEXNOM('&CATA.GD.NOMGD','DEPL_R'),NUMA)
      ZI(IDESC+1-1) = NUMA
      ZI(IDESC+2-1) = -3
      ZI(IDESC+3-1) = 14
C
C  .REFE
      CHAMNO(20:24) = '.REFE'
      CALL WKVECT(CHAMNO,BASE//' V K24',2,IREFE)
      ZK24(IREFE+1-1) = NOMA//'                '
C
C  .VALE
      CHAMNO(20:24) = '.VALE'
      CALL WKVECT(CHAMNO,BASE//' V R',3*NBEL,ITHETA)
C
      DO 4 I=1,LOBJ2
        NUM    = ZI(IADNUM+I-1)
        IADRTT = IADRT3 + I - 1
        ZR(ITHETA+(NUM-1)*3+1-1) = ZR(IADRTT)*ZR(IN2+(I-1)*3+1-1)
        ZR(ITHETA+(NUM-1)*3+2-1) = ZR(IADRTT)*ZR(IN2+(I-1)*3+2-1)
        ZR(ITHETA+(NUM-1)*3+3-1) = ZR(IADRTT)*ZR(IN2+(I-1)*3+3-1)
        ZI(INDIC+NUM-1) = 1
4     CONTINUE
C
C BOUCLE SUR LES NOEUDS M COURANTS DU MAILLAGE SANS GAMMO
C POUR CALCULER PROJ(M)=N
      DO 500 I=1,NBEL
        IF(ZI(INDIC+I-1).NE.1) THEN
          XM = ZR(IADRCO+(I-1)*3+1-1)
          YM = ZR(IADRCO+(I-1)*3+2-1)
          ZM = ZR(IADRCO+(I-1)*3+3-1)
          DMIN = 10000000.D0
          JMIN = 0
          SMIN = 0.D0
          DO 600 J=1,LOBJ2-1
            XI1 = ZR(IADRCO+(ZI(IADNUM+J-1)-1)*3+1-1)
            YI1 = ZR(IADRCO+(ZI(IADNUM+J-1)-1)*3+2-1)
            ZI1 = ZR(IADRCO+(ZI(IADNUM+J-1)-1)*3+3-1)
            XJ1 = ZR(IADRCO+(ZI(IADNUM+J+1-1)-1)*3+1-1)
            YJ1 = ZR(IADRCO+(ZI(IADNUM+J+1-1)-1)*3+2-1)
            ZJ1 = ZR(IADRCO+(ZI(IADNUM+J+1-1)-1)*3+3-1)
            XIJ = XJ1-XI1
            YIJ = YJ1-YI1
            ZIJ = ZJ1-ZI1
            XIM = XM-XI1
            YIM = YM-YI1
            ZIM = ZM-ZI1
            S   = XIJ*XIM + YIJ*YIM + ZIJ*ZIM
            NORM2 = XIJ*XIJ + YIJ *YIJ + ZIJ*ZIJ
            S     = S/NORM2
            IF((S-1).GE.EPS) THEN
              S = 1.D0
            ENDIF
            IF(S.LE.EPS) THEN
              S = 0.D0
            ENDIF
            XN = S*XIJ+XI1
            YN = S*YIJ+YI1
            ZN = S*ZIJ+ZI1
            D = SQRT((XN-XM)*(XN-XM)+(YN-YM)*(YN-YM)+(ZN-ZM)*(ZN-ZM))
            IF(D.LT.DMIN) THEN
              DMIN = D
              JMIN = J
              SMIN = S
            ENDIF
600       CONTINUE
          RII = (1-SMIN)*ZR(IADRT1+JMIN-1)+SMIN*ZR(IADRT1+JMIN+1-1)
          RSI = (1-SMIN)*ZR(IADRT2+JMIN-1)+SMIN*ZR(IADRT2+JMIN+1-1)
          ALPHA = (DMIN-RII)/(RSI-RII)
          IADRTT = IADRT3+JMIN-1
          TEI = ZR(IADRTT)
          TEJ = ZR(IADRTT+1)
          VALX = (1-SMIN)*ZR(IN2+(JMIN-1)*3+1-1)*TEI
          VALX = VALX+SMIN*ZR(IN2+(JMIN+1-1)*3+1-1)*TEJ
          VALY = (1-SMIN)*ZR(IN2+(JMIN-1)*3+2-1)*TEI
          VALY = VALY+SMIN*ZR(IN2+(JMIN+1-1)*3+2-1)*TEJ
          VALZ = (1-SMIN)*ZR(IN2+(JMIN-1)*3+3-1)*TEI
          VALZ = VALZ+SMIN*ZR(IN2+(JMIN+1-1)*3+3-1)*TEJ
          IF((ABS(ALPHA).LE.EPS).OR.(ALPHA.LT.0)) THEN
            ZR(ITHETA+(I-1)*3+1-1) = VALX
            ZR(ITHETA+(I-1)*3+2-1) = VALY
            ZR(ITHETA+(I-1)*3+3-1) = VALZ
          ELSE IF((ABS(ALPHA-1).LE.EPS).OR.((ALPHA-1).GT.0)) THEN
            ZR(ITHETA+(I-1)*3+1-1) = 0.D0
            ZR(ITHETA+(I-1)*3+2-1) = 0.D0
            ZR(ITHETA+(I-1)*3+3-1) = 0.D0
          ELSE
            ZR(ITHETA+(I-1)*3+1-1) = (1-ALPHA)*VALX
            ZR(ITHETA+(I-1)*3+2-1) = (1-ALPHA)*VALY
            ZR(ITHETA+(I-1)*3+3-1) = (1-ALPHA)*VALZ
          ENDIF
        ENDIF
500   CONTINUE
C
C DESTRUCTION D'OBJETS DE TRAVAIL
C
      CALL JEEXIN(DIRE4,IRET)
      IF(IRET.NE.0) THEN
         CALL JEDETR(DIRE4)
      ENDIF
      CALL JEEXIN(DIRE5,IRET)
      IF(IRET.NE.0) THEN
         CALL JEDETR(DIRE5)
      ENDIF
      CALL JEDETR(INDICG)
      CALL JEDETR(NUMGAM)
C
      CALL JEDEMA()
C
      END
