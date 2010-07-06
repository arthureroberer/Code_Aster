      SUBROUTINE PMINIT(IMATE,NBVARI,NDIM,TYPMOD,TABLE,NBPAR,NBVITA,
     &NOMPAR,ANG,PGL,IROTA,EPSM,SIGM,VIM,VIP,DEFIMP,COEF,INDIMP,
     &FONIMP,CIMPO,KEL,SDDISC,PARCRI,PRED,MATREL,OPTION)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 05/07/2010   AUTEUR PROIX J-M.PROIX 
C ======================================================================
C COPYRIGHT (C) 1991 - 2010  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_21 
      IMPLICIT NONE
C-----------------------------------------------------------------------
C     OPERATEUR    CALC_POINT_MAT : INITIALISATIONS 
C-----------------------------------------------------------------------
C
C IN   IMATE  : adresse materiau cod�
C IN   NBVARI : Nombre de variables internes
C IN   NDIM   : 3
C OUT  TYPMOD : 3D
C OUT  TABLE  : TABLE RESULTAT
C OUT  NBPAR  : NOMBRE DE PARAMETRES DE LA TABLE RESULTAT
C OUT  NOMPAR : NOMS DES PARAMETRES DE LA TABLE RESULTAT
C OUT  ANG    : ANGLES DU MOT-CLE MASSIF
C OUT  PGL    : MATRICE DE ROTATION AUTOUR DE Z
C OUT  IROTA  : =1 SI ROTATION AUTOUR DE Z
C OUT  EPSM   : DEFORMATIONS INITIALES
C OUT  SIGM   : CONTRAINTES INITIALES
C OUT  VIM    : VARIABLES INTERNES INITIALES
C OUT  VIP    : VARIABLES INTERNES NULLES
C OUT  DEFIMP : =1 SI LES 6 CMP DE EPSI DONT DONNEES
C OUT  COEF   : COEF POUR ADIMENSIONNALISER LE PB
C OUT  INDIMP : TABLEAU D'INDICES =1 SI EPS(I) DONNE
C OUT  FONIMP : FONCTIONS IMPOSEES POUR EPSI OU SIGM
C OUT  CIMPO  : = 1 POUR LA CMP DE EPSI OU SIGM IMPOSEE
C OUT  KEL    : OPERATEUR D'ELASTICITE
C OUT  SDDISC : SD DISCRETISATION
C OUT  PARCRI : PARAMETRES DE CONVERGENCE GLOBAUX
C OUT  PRED   : TYPE DE PREDICTION = 1 SI TANGENTE
C OUT  MATREL : MATRICE TANGENTE = 1 SI ELASTIQUE
C OUT  OPTION : FULL_MECA OU RAPH_MECA
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC,CBID
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24,K24BID
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
      INTEGER      NDIM,N1,NBVARI,NBPAR,I,J,K,IMATE,KPG,KSP,NBOCC,N2
      INTEGER      IEPSI,ICONT,IROTA,DEFIMP,INDIMP(6),NBTEMP
      INTEGER      PRED,MATREL,IRELA,DERNIE,NBVITA,JINFO,JTEMPS,JARCH
      INTEGER      ILIGNE,ICOLON,IMESS(2)
      CHARACTER*4  NOMEPS(6),NOMSIG(6)
      CHARACTER*8  TYPMOD(2),MATER,K8B,LISTPS,TABLE,FONIMP(6)
      CHARACTER*8  FONEPS(6),FONSIG(6),TYPPAR(NBVARI+16),VALEF
      CHARACTER*16 OPTION,COMPOR(6),NOMPAR(NBVARI+16),PREDIC,MATRIC
      CHARACTER*16 NOMCMD
      CHARACTER*19 LISINS,SDDISC
      CHARACTER*24 TPSDIA,TPSDIE,TPSDIT,TPSDII
      REAL*8       INSTAM,ANG(7),SIGM(6),EPSM(6),VALE
      REAL*8       VIM(NBVARI),VIP(NBVARI),VR(NBVARI+16)
      REAL*8       SIGI,REP(7),R8DGRD,KEL(6,6),CIMPO(6,12)
      REAL*8       ANGD(3),ANG1,PGL(3,3),XYZGAU,COEF,INSTIN,DELMIN
      REAL*8       PARCRI(12),PARCON(9),ANGEUL(3)
      DATA NOMEPS/'EPXX','EPYY','EPZZ','EPXY','EPXZ','EPYZ'/
      DATA NOMSIG/'SIXX','SIYY','SIZZ','SIXY','SIXZ','SIYZ'/
      
C     INITIALISATIONS      
      NDIM=3
      TYPMOD(1)='3D'
      TYPMOD(2)=' '

C     ----------------------------------------
C     RECUPERATION DU NOM DE LA TABLE PRODUITE
C     ----------------------------------------
      CALL GETRES(TABLE,K24BID,K24BID)
C     LA TABLE CONTIENT L'INSTANT, EPS, SIG, TRACE, VMIS, VARI, NB_ITER
      NBVITA=NBVARI
      CALL GETVIS(' ','NB_VARI_TABLE',1,1,1,K,N1)
      IF (N1.GT.0) THEN
         NBVITA=K
      ELSEIF (NBVARI.GT.99) THEN
         CALL U2MESS('A','COMPOR2_6')
         NBVITA=99
      ENDIF
      NBPAR=1+6+6+2+NBVITA+1
      NOMPAR(1)='INST'
      DO 10 I=1,NBPAR
         TYPPAR(I)='R'
 10   CONTINUE
      DO 13 I=1,6
         NOMPAR(1+I)=NOMEPS(I)
         NOMPAR(7+I)=NOMSIG(I)
 13   CONTINUE    
      NOMPAR(14)='TRACE'
      NOMPAR(15)='VMIS'
      DO 11 I=1,MIN(9,NBVITA)
         WRITE(NOMPAR(15+I),'(A,I1)') 'V',I
  11  CONTINUE
      IF (NBVITA.GT.9) THEN
         DO 12 I=10,MIN(99,NBVITA)
            WRITE(NOMPAR(15+I),'(A,I2)') 'V',I
  12     CONTINUE
      ENDIF

      NOMPAR(NBPAR)='NB_ITER'
      CALL TBCRSD(TABLE,'G')
      CALL TBAJPA(TABLE,NBPAR,NOMPAR,TYPPAR)
    
C     ----------------------------------------
C     TRAITEMENT DES ANGLES
C     ----------------------------------------
      CALL R8INIR ( 7, 0.D0, ANG ,1 )
      CALL R8INIR ( 7, 0.D0, ANGEUL ,1 )
      CALL R8INIR(3, 0.D0, XYZGAU, 1)
      CALL GETVR8('MASSIF','ANGL_REP',1,1,3,ANG(1),N1)
      CALL GETVR8('MASSIF','ANGL_EULER',1,1,3,ANGEUL,N2)

      IF (N1.GT.0) THEN
         ANG(1) = ANG(1)*R8DGRD()
         IF ( NDIM .EQ. 3 ) THEN
            ANG(2) = ANG(2)*R8DGRD()
            ANG(3) = ANG(3)*R8DGRD()
         ENDIF
         ANG(4) = 1.D0

C        ECRITURE DES ANGLES D'EULER A LA FIN LE CAS ECHEANT
      ELSEIF (N2.GT.0) THEN
          CALL EULNAU(ANGEUL,ANGD)
          ANG(1) = ANGD(1)*R8DGRD()
          ANG(5) = ANGEUL(1)*R8DGRD()
          IF ( NDIM .EQ. 3 ) THEN
             ANG(2) = ANGD(2)*R8DGRD()
             ANG(3) = ANGD(3)*R8DGRD()
             ANG(6) = ANGEUL(2)*R8DGRD()
             ANG(7) = ANGEUL(3)*R8DGRD()
          ENDIF
          ANG(4) = 2.D0
      ENDIF

      CALL R8INIR(6, 0.D0, EPSM, 1)
      CALL R8INIR(6, 0.D0, SIGM, 1)
      CALL R8INIR(NBVARI,0.D0, VIM, 1)
      CALL R8INIR(NBVARI,0.D0, VIP, 1)
      IROTA=0
C     ANGLE DE ROTATION
      CALL GETVR8(' ','ANGLE',1,1,1,ANG1,N1)
      IF ((N1.NE.0).AND.(ANG1.NE.0.D0)) THEN
C        VERIFS
         IROTA=1
         CALL R8INIR(9,0.D0, PGL, 1)
         CALL DSCAL(1,R8DGRD(),ANG1,1)
         PGL(1,1)=COS(ANG1)
         PGL(2,2)=COS(ANG1)
         PGL(1,2)=SIN(ANG1)
         PGL(2,1)=-SIN(ANG1)
         PGL(3,3)=1.D0
C VOIR GENERALISATION A 3 ANGLES AVEC CALL MATROT            
      ENDIF

C     ----------------------------------------
C     ETAT INITIAL
C     ----------------------------------------
      CALL GETFAC('SIGM_INIT',NBOCC)
      IF (NBOCC.GT.0) THEN
      DO 15 I=1,6
         CALL GETVR8('SIGM_INIT',NOMSIG(I),1,1,1,SIGI,N1)
         IF (N1.NE.0) THEN
            SIGM(I)=SIGI
         ENDIF
  15  CONTINUE
      ENDIF

      CALL GETFAC('EPSI_INIT',NBOCC)
      IF (NBOCC.GT.0) THEN
      DO 16 I=1,6
         CALL GETVR8('EPSI_INIT',NOMEPS(I),1,1,1,SIGI,N1)
         IF (N1.NE.0) THEN
            EPSM(I)=SIGI
         ENDIF
  16  CONTINUE
      ENDIF

      CALL GETFAC('VARI_INIT',NBOCC)
      IF (NBOCC.GT.0) THEN
         CALL GETVR8('VARI_INIT','VALE',1,1,NBVARI,VIM,N1)
      ENDIF
  
      KPG=1
      KSP=1
      CALL R8INIR(7, 0.D0, REP, 1)
      REP(1)=1.D0
      CALL DCOPY(3,ANG,1,REP(2),1)
      
      INSTAM=0.D0
      
C     ----------------------------------------
C     MATRICE ELASTIQUE ET COEF POUR ADIMENSIONNALISER
C     ----------------------------------------
      CALL DMAT3D('RIGI',IMATE,INSTAM,'+',KPG,KSP,
     &                   REP,XYZGAU,KEL)
C     DMAT ECRIT MU POUR LES TERMES DE CISAILLEMENT
      COEF=MAX(KEL(1,1),KEL(2,2),KEL(3,3))
      DO 67 J=4,6
        KEL(J,J) = KEL(J,J)*2.D0
        COEF=MAX(COEF,KEL(J,J))
 67   CONTINUE
      
C     ----------------------------------------
C     CHARGEMENT
C     ----------------------------------------
      CALL R8INIR(6*12,0.D0, CIMPO, 1)
      ICONT=0
      IEPSI=0
      DO 23 I=1,6
         INDIMP(I)=0
 23   CONTINUE       
      DO 14 I=1,6
         CALL GETVID(' ',NOMEPS(I),1,1,1,FONEPS(I),N1)
         CALL GETVID(' ',NOMSIG(I),1,1,1,FONSIG(I),N2)
         IF (N1.NE.0) THEN
            CIMPO(I,6+I)=1.D0
            FONIMP(I)=FONEPS(I)
            IEPSI=IEPSI+1
            INDIMP(I)=1
         ELSE
            CIMPO(I,I)=1.D0      
            FONIMP(I)=FONSIG(I)
            ICONT=ICONT+1
            INDIMP(I)=0
         ENDIF   
  14  CONTINUE
      DEFIMP=0
      IF (IEPSI.EQ.6) DEFIMP=1

C     TRAITEMENT DES RELATIONS LINEAIRES (MOT CLE MATR_C1)    
      CALL GETFAC('MATR_C1',NBOCC)
      IF (NBOCC.NE.0) THEN
         DO 55 I=1,NBOCC
            CALL GETVIS('MATR_C1','NUME_LIGNE',I,1,1,ILIGNE,N1)
            CALL GETVIS('MATR_C1','NUME_COLONNE',I,1,1,ICOLON,N1)
            CALL GETVR8('MATR_C1','VALE',I,1,1,VALE,N1)
            CIMPO(ILIGNE,ICOLON)=VALE
 55      CONTINUE
      ENDIF
      CALL GETFAC('MATR_C2',NBOCC)
      IF (NBOCC.NE.0) THEN
         DO 56 I=1,NBOCC
            CALL GETVIS('MATR_C2','NUME_LIGNE',I,1,1,ILIGNE,N1)
            CALL GETVIS('MATR_C2','NUME_COLONNE',I,1,1,ICOLON,N1)
            CALL GETVR8('MATR_C2','VALE',I,1,1,VALE,N1)
            CIMPO(ILIGNE,ICOLON+6)=VALE
 56      CONTINUE
      ENDIF
      CALL GETFAC('VECT_IMPO',NBOCC)
      IF (NBOCC.NE.0) THEN
         DO 57 I=1,NBOCC
            CALL GETVIS('VECT_IMPO','NUME_LIGNE',I,1,1,ILIGNE,N1)
            CALL GETVID('VECT_IMPO','VALE',I,1,1,VALEF,N1)
            FONIMP(ILIGNE)=VALEF
 57      CONTINUE
      ENDIF
      
C     ----------------------------------------
C     ECRITURE ETAT INITIAL DANS TABLE
C     ----------------------------------------
      CALL DCOPY(6,SIGM,1,VR(8),1)
      CALL DCOPY(6,EPSM,1,VR(2),1)
      VR(14)=0.D0
      VR(15)=0.D0
      CALL DCOPY(NBVARI,VIM,1,VR(16),1)
      VR(1)=INSTAM
      VR(NBPAR)=0
      CALL TBAJLI(TABLE,NBPAR,NOMPAR,0,VR,CBID,K8B,0)
      
C     ----------------------------------------
C     CREATION SD DISCRETISATION
C     ----------------------------------------
      CALL GETVID('INCREMENT','LIST_INST',1,1,1,LISINS,N1)      
      INSTIN=0.D0    
      NOMCMD='SIMU_POINT_MAT' 
      CALL NMCRLI(INSTIN,LISINS,SDDISC,DELMIN,NOMCMD)
        
C     Instructions remlpacant CALL NMCRAR(K8B,SDDISC,DERNI,DELMIN,NOMCMD
C     on n'a pas le mot-cl� ARCHIVAGE dans calc_point_mat.capy,
C     mais NMCRAR cr�e d'autre objets utiles au red�coupage 
      TPSDIT = SDDISC(1:19)//'.DITR'
      CALL JEVEUO(TPSDIT,'L',JTEMPS)
      CALL JELIRA(TPSDIT,'LONUTI',NBTEMP,K8B)
      TPSDIA = SDDISC(1:19)//'.DIAL'
      CALL WKVECT(TPSDIA,'V V L',NBTEMP+1,JARCH)
      TPSDII = SDDISC(1:19)//'.DIIR'
      DO 30 I = 1, NBTEMP
        ZL(JARCH+I) = .TRUE.
 30   CONTINUE
      CALL WKVECT(TPSDII,'V V R8',8,JINFO)
      ZR(JINFO-1 + 1) = 0
      ZR(JINFO-1 + 2) = 1
      
C     SUBDIVISION AUTOMATIQUE DU PAS DE TEMPS      
      CALL NMCRSU(SDDISC,LISINS,DELMIN,NOMCMD)
      
C     ----------------------------------------
C     NEWTON 
C     ----------------------------------------
      PRED=1    
      CALL GETVTX('NEWTON','PREDICTION',1,1,1,PREDIC,N1)
       CALL DCOPY(6,SIGM,1,VR(8),1)
      IF (PREDIC.EQ.'ELASTIQUE') PRED=0     
      MATREL=0
      OPTION='FULL_MECA'  
      CALL GETVTX('NEWTON','MATRICE',1,1,1,MATRIC,N1)
      IF (N1.NE.0) THEN
         IF (MATRIC.EQ.'ELASTIQUE') THEN
            MATREL=1
            PRED=0
            OPTION='RAPH_MECA'
         ENDIF
      ENDIF   

C     ----------------------------------------
C     LECTURE DES PARAMETRES DE CONVERGENCE
C     ----------------------------------------
      CALL NMDOCN(K24BID,PARCRI,PARCON)   

      END
