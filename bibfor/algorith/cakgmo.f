      SUBROUTINE CAKGMO(OPTION,RESULT,MODELE,DEPLA,THETAI,MATE,COMPOR,
     &                 NCHAR,LCHAR,SYMECH,CHFOND,NNOFF,BASLOC,COURB,
     &                 IORD,NDEG,THLAGR,GLAGR,PULS,NBPRUP,NOPRUP,FISS)
      IMPLICIT  NONE

      INTEGER IORD,NCHAR,NBPRUP
      REAL*8 PULS
      CHARACTER*8 MODELE,THETAI,LCHAR(*),FISS
      CHARACTER*8 RESULT,SYMECH
      CHARACTER*16 OPTION,NOPRUP(*)
      CHARACTER*24 DEPLA,CHFOND,MATE,COMPOR,BASLOC,COURB,CHPULS
      LOGICAL THLAGR,GLAGR

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 04/04/2006   AUTEUR CIBHHLV L.VIVAN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
C     TOLE CRP_21

C  FONCTION REALISEE:   CALCUL DES FACTEURS D'INTENSITE DE CONTRAINTES 
C                       POUR UN MODE PROPRE EN 3D

C  IN    OPTION --> K_G_MODA
C  IN    RESULT --> NOM UTILISATEUR DU RESULTAT ET TABLE
C  IN    MODELE --> NOM DU MODELE
C  IN    DEPLA  --> CHAMP DE DEPLACEMENT
C  IN    THETAI --> BASE DE I CHAMPS THETA
C  IN    MATE   --> CHAMP DE MATERIAUX
C  IN    COMPOR --> COMPORTEMENT
C  IN    NCHAR  --> NOMBRE DE CHARGES
C  IN    LCHAR  --> LISTE DES CHARGES
C  IN    SYMECH --> SYMETRIE DU CHARGEMENT
C  IN    CHFOND --> POINTS DU FOND DE FISSURE
C  IN    NNOFF  --> NOMBRE DE POINTS DU FOND DE FISSURE
C  IN    BASLOC --> BASE LOCALE
C  IN    IORD   --> NUMERO D'ORDRE DE LA SD
C  IN    THLAGR --> VRAI SI LISSAGE THETA_LAGRANGE (SINON LEGENDRE)
C  IN    GLAGR  --> VRAI SI LISSAGE G_LAGRANGE (SINON LEGENDRE)
C  IN    NDEG   --> DEGRE DU POLYNOME DE LEGENDRE
C  IN    FISS   --> NOM DE LA SD FISS_XFEM
C ......................................................................
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------

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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      INTEGER I,J,IBID,IADRGK,IADGKS,IRET,JRESU,NCHIN, LNOFF
      INTEGER JTEMP,NNOFF,NUM,INCR,NRES,NSIG,NDEP
      INTEGER NDEG,NDIMTE,IERD,INIT,GPMI(2)
      INTEGER IADRNO,IADGKI,IADABS,IFM,NIV
      REAL*8  GKTHI(4),GPMR(6),TIME
      COMPLEX*16 CBID
      LOGICAL EXIGEO,EXITHE,EXITRF,FONC,EPSI,EXTIM
      CHARACTER*1  K1BID
      CHARACTER*8  NOMA,K8BID,RESU,NOEUD
      CHARACTER*8  LPAIN(21),LPAOUT(1),REPK
      CHARACTER*16 OPTI,OPER
      CHARACTER*19 CHROTA,CHPESA,CHVOLU,CF1D2D,CHEPSI,CF2D3D,CHPRES
      CHARACTER*24 LIGRMO,TEMPE,CHGEOM,CHGTHI
      CHARACTER*24 CHTEMP,CHTREF,CHSIGI,CHDEPI
      CHARACTER*24 LCHIN(21),LCHOUT(1),CHTHET,CHALPH,CHTIME
      CHARACTER*24 ABSCUR,NORMFF,PAVOLU,PAPRES,PA2D3D
      CHARACTER*24 CHSIG,CHEPSP,CHVARI,TYPE,PEPSIN
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      OPER = 'CALC_G_LOCAL_T'
      CALL INFNIV(IFM,NIV)
      
      TIME = 0.D0
      EXTIM = .FALSE.
      OPTI = OPTION

C- RECUPERATION DU CHAMP GEOMETRIQUE

      CALL MEGEOM(MODELE,' ',EXIGEO,CHGEOM)
      NOMA = CHGEOM(1:8)

C- RECUPERATION DE L'ETAT INITIAL

      CALL GETFAC('ETAT_INIT',INIT)
      IF (INIT.NE.0) THEN
        CALL GETVID('ETAT_INIT','SIGM',1,1,1,CHSIGI,NSIG)
        IF(NSIG.NE.0)THEN
            CALL CHPVER('F',CHSIGI,'ELGA','SIEF_R',IERD)
        ENDIF
        CALL GETVID('ETAT_INIT','DEPL',1,1,1,CHDEPI,NDEP)
        IF(NDEP.NE.0)THEN
            CALL CHPVER('F',CHDEPI,'NOEU','DEPL_R',IERD)
        ENDIF
        IF ((NSIG.EQ.0) .AND. (NDEP.EQ.0)) THEN
          CALL UTMESS('F',OPER,'AUCUN CHAMP INITIAL TROUVE')
        END IF
      END IF

C- RECUPERATION (S'ILS EXISTENT) DES CHAMP DE TEMPERATURES (T,TREF)

      TEMPE = ' '
      CHTEMP = '&&CAKGMO.CH_TEMP_R'
      DO 10 I = 1,NCHAR
        CALL JEEXIN(LCHAR(I)//'.CHME.TEMPE.TEMP',IRET)
        IF (IRET.NE.0) THEN
          CALL JEVEUO(LCHAR(I)//'.CHME.TEMPE.TEMP','L',JTEMP)
          TEMPE = ZK8(JTEMP)
        END IF
   10 CONTINUE
      CALL METREF(MATE,NOMA,EXITRF,CHTREF)
      CALL METEMP(NOMA,TEMPE,EXTIM,TIME,CHTREF,EXITHE,CHTEMP(1:19))
      CALL DISMOI('F','ELAS_F_TEMP',MATE,'CHAM_MATER',IBID,REPK,IERD)
      IF (REPK.EQ.'OUI') THEN
        IF (.NOT.EXITHE) THEN
          CALL UTMESS('F','CAKGMO',
     &                'LE MATERIAU DEPEND DE LA TEMPERATURE'//
     &                '! IL N''Y A PAS DE CHAMP DE TEMPERATURE '//
     &                '! LE CALCUL EST IMPOSSIBLE ')
        END IF
        IF (.NOT.EXITRF) THEN
          CALL UTMESS('A',' CAKGMO',
     &                'LE MATERIAU DEPEND DE LA TEMPERATURE'//
     &                ' IL N''Y A PAS DE TEMPERATURE DE REFERENCE'//
     &                ' ON PRENDRA DONC LA VALEUR 0')
        END IF
      END IF

C- CALCUL DES K(THETA_I) AVEC I=1,NDIMTE  NDIMTE = NNOFF  SI TH-LAGRANGE
C                                         NDIMTE = NDEG+1 SI TH-LEGENDRE
      IF (THLAGR) THEN
        NDIMTE = NNOFF
      ELSE
        NDIMTE = NDEG + 1
      END IF

      CALL WKVECT('&&CAKGMO.VALG','V V R8',NDIMTE*5,IADRGK)
      CALL JEVEUO(THETAI,'L',JRESU)

      LIGRMO = MODELE//'.MODELE'

      CHPULS = '&&CAKGMO.PULS'
      CALL MECACT('V',CHPULS,'MODELE',LIGRMO,'FREQ_R  ',1,'FREQ   ',
     &            IBID,PULS,CBID,' ')

      DO 20 I = 1,NDIMTE
      
        CHTHET = ZK24(JRESU+I-1)
        CALL CODENT(I,'G',CHGTHI)
        LPAOUT(1) = 'PGTHETA'
        LCHOUT(1) = CHGTHI
        LPAIN(1) = 'PGEOMER'
        LCHIN(1) = CHGEOM
        LPAIN(2) = 'PDEPLAR'
        LCHIN(2) = DEPLA
        LPAIN(3) = 'PTHETAR'
        LCHIN(3) = CHTHET
        LPAIN(4) = 'PMATERC'
        LCHIN(4) = MATE
        LPAIN(5) = 'PTEMPER'
        LCHIN(5) = CHTEMP
        LPAIN(6) = 'PTEREF'
        LCHIN(6) = CHTREF
        LPAIN(7) = 'PCOMPOR'
        LCHIN(7) = COMPOR
        LPAIN(8) = 'PBASLOR'
        LCHIN(8) = BASLOC
        LPAIN(9) = 'PCOURB'
        LCHIN(9) = COURB
        LPAIN(10) = 'PPULPRO'
        LCHIN(10) = CHPULS
        LPAIN(11) = 'PLSN'
        LCHIN(11) = FISS//'.LNNO'
        LPAIN(12) = 'PLST'
        LCHIN(12) = FISS//'.LTNO'
C        
        NCHIN = 12
C        
        CALL CALCUL('S',OPTI,LIGRMO,NCHIN,LCHIN,LPAIN,1,LCHOUT,LPAOUT,
     &              'V')
        
C     BUT :  FAIRE LA "SOMME" D'UN CHAM_ELEM        
        CALL MESOMM(CHGTHI,5,IBID,GKTHI,CBID,0,IBID)
        
        DO 29 J=1,4
          ZR(IADRGK-1+(I-1)*5+J) = GKTHI(J)
 29     CONTINUE
        
 20   CONTINUE
  
C- CALCUL DE G(S), K1(S), K2(S) et K3(S)
C             SUR LE FOND DE FISSURE PAR 2 METHODES
C- PREMIERE METHODE : G_LEGENDRE ET THETA_LEGENDRE
C- DEUXIEME METHODE : G_LEGENDRE ET THETA_LAGRANGE
C- TROISIEME METHODE: G_LAGRANGE ET THETA_LAGRANGE
C    (OU G_LAGRANGE_NO_NO ET THETA_LAGRANGE)

      CALL WKVECT('&&CAKGMO.VALGK_S','V V R8',NNOFF*5,IADGKS)  
      CALL WKVECT('&&CAKGMO.VALGKI','V V R8',NNOFF*5,IADGKI) 
      ABSCUR='&&CAKGMO.TEMP     .ABSCU'       
      CALL WKVECT(ABSCUR,'V V R',NNOFF,IADABS)
      
      IF ((.NOT.GLAGR) .AND. (.NOT.THLAGR)) THEN
        NUM = 1        
        CALL GKMET1(NDEG,NNOFF,CHFOND,IADRGK,IADGKS,IADGKI,ABSCUR)
C            
      ELSE IF (THLAGR) THEN
C        NORMFF = ZK24(JRESU+NNOFF+1-1)
C        NORMFF(20:24) = '.VALE'
        IF (.NOT.GLAGR) THEN
          NUM = 2
          CALL UTMESS('F','CAKGMO','THLAG-GLEG PAS POSSIBLE')
C         CALL GMETH2(NDEG,NNOFF,CHFOND,IADRGK,IADGKS,IADGKI,ABSCUR,NUM)
        ELSE
          NUM = 3
          CALL GKMET3(NNOFF,CHFOND,IADRGK,IADGKS,IADGKI,ABSCUR,NUM)
        END IF
      END IF
C
C- SYMETRIE DU CHARGEMENT ET IMPRESSION DES RESULTATS
C
      IF (SYMECH.EQ.'SYME') THEN
        DO 30 I = 1,NNOFF
C         G(S) = 2*G(S)
          ZR(IADGKS+5*(I-1)) = 2.D0*ZR(IADGKS+5*(I-1))
C         K1(S) = 2*K1(S)
          ZR(IADGKS+5*(I-1) + 1) = 2.D0*ZR(IADGKS+5*(I-1) + 1)
C         K2(S) = 0, K3(S) = 0
          ZR(IADGKS+5*(I-1) + 2) = 0.D0
          ZR(IADGKS+5*(I-1) + 3) = 0.D0
 30    CONTINUE
      END IF
C
      IF (SYMECH.EQ.'ANTI') THEN
        DO 333 I = 1,NNOFF
C         G(S) = 2*G(S)
          ZR(IADGKS+5*(I-1)) = 2.D0*ZR(IADGKS+5*(I-1))
C         K2(S) = 2*K2(S)
          ZR(IADGKS+5*(I-1) + 2) = 2.D0*ZR(IADGKS+5*(I-1) + 2)
C         K1(S) = 0, K3(S) = 0
          ZR(IADGKS+5*(I-1) + 1) = 0.D0
          ZR(IADGKS+5*(I-1) + 3) = 0.D0
 333    CONTINUE
      END IF
C
C- IMPRESSION ET ECRITURE DANS TABLE(S) DE K1(S), K2(S) ET K3(S)

      IF (NIV.GE.2) THEN
        CALL GKSIMP(RESULT,NNOFF,ZR(IADABS),IADRGK,NUM,IADGKS,
     &              NDEG,IADGKI,EXTIM,TIME,IORD,IFM)        
      END IF
C      
      DO 40 I = 1,NNOFF
          GPMI(1)=IORD
          GPMI(2)=I
          GPMR(1) = ZR(IADABS-1+I)
          GPMR(2) = ZR(IADGKS-1+5*(I-1)+2)
          GPMR(3) = ZR(IADGKS-1+5*(I-1)+3)
          GPMR(4) = ZR(IADGKS-1+5*(I-1)+4)
          GPMR(5) = ZR(IADGKS-1+5*(I-1)+1)
          GPMR(6) = ZR(IADGKS-1+5*(I-1)+5)
        
        CALL TBAJLI(RESULT,NBPRUP,NOPRUP,GPMI,GPMR,CBID,K1BID,0)
 40   CONTINUE
C      
C- DESTRUCTION D'OBJETS DE TRAVAIL
C
      CALL JEDETR(ABSCUR)
      CALL JEDETR('&&CAKGMO.VALG_S')
      CALL JEDETR('&&CAKGMO.VALGKI')
      CALL JEDETR('&&CAKGMO.VALGK_S')
      CALL DETRSD('CHAMP_GD',CHTEMP) 
C
      CALL JEDETR('&&CAKGMO.VALG') 
C      
      CALL JEDEMA()
      END
