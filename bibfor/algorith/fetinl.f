      SUBROUTINE FETINL(NBI,VLAGI,MATAS,CHSECM,LRIGID,DIMGI,
     &                  NBSD,VSDF,VDDL,NOMGGT,IPIV,NOMGI,LSTOGI,INFOFE,
     &                  IREX,IFM,SDFETI,NBPROC,RANG,K24LAI)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 06/07/2005   AUTEUR BOITEAU O.BOITEAU 
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
C TOLE CRP_4
C-----------------------------------------------------------------------
C    - FONCTION REALISEE:  CALCUL DU VECTEUR LAGRANGE INITIAL LANDA0
C
C   IN   NBI   : IN  : TAILLE DU VECTEUR
C   IN/OUT VLAGI : VR8: VECTEUR LAGRANGE INITIAL
C   IN   MATAS: K19  : NOM DE LA MATRICE DE RIGIDITE GLOBALE
C   IN  CHSECM: K19  : CHAM_NO SECOND MEMBRE GLOBAL
C   IN  LRIGID: LO   : LOGICAL INDIQUANT LA PRESENCE D'AU MOINS UN
C         SOUS-DOMAINES FLOTTANT
C   IN  DIMGI:  IN   : TAILLE DE GIT*GI
C   IN   NBSD:  IN   : NOMBRE DE SOUS-DOMAINES
C   IN   VSDF: VIN  : VECTEUR MATR_ASSE.FETF INDIQUANT SI SD FLOTTANT
C   IN   VDDL: VIN  : VECTEUR DES NBRES DE DDLS DES SOUS-DOMAINES
C   IN  SDFETI: CH19: SD DECRIVANT LE PARTIONNEMENT FETI
C   IN/OUT IPIV: VIN : ADRRESSE VECTEUR DECRIVANT LE PIVOTAGE LAPACK
C                     POUR INVERSER (GIT)*GI
C   IN LSTOGI: LO : TRUE, GI STOCKE, FALSE, RECALCULE
C   IN IREX  : IN    : ADRESSE DU VECTEUR AUXILAIRE EVITANT DES APPELS
C                        JEVEUX.
C   IN RANG  : IN  : RANG DU PROCESSEUR
C   IN NBPROC: IN  : NOMBRE DE PROCESSEURS
C   IN K24LAI: K24 : NOM DE L'OBJET JEVEUX VLAGI POUR LE PARALLELISME
C   IN NOMGI/NOMGGT: K24 : NOM DES OBJETS JEVEUX GI ET GIT*GI
C----------------------------------------------------------------------
C RESPONSABLE BOITEAU O.BOITEAU
C CORPS DU PROGRAMME
      IMPLICIT NONE

C DECLARATION PARAMETRES D'APPELS
      INTEGER      NBI,DIMGI,NBSD,VSDF(NBSD),VDDL(NBSD),IPIV,
     &             IREX,IFM,NBPROC,RANG
      REAL*8       VLAGI(NBI)
      CHARACTER*19 MATAS,CHSECM,SDFETI
      CHARACTER*24 INFOFE,K24LAI,NOMGI,NOMGGT
      LOGICAL      LRIGID,LSTOGI
      
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER*4          ZI4
      COMMON  / I4VAJE / ZI4(1)
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
      
C DECLARATION VARIABLES LOCALES
      INTEGER      I,JVE,IDD,IFETR,NBMC,IMC,NBMC1,IDECAI,NB,IBID,
     &             IVALE,IDECAO,NBDDL,IFETC,J,JVE1,K,GII,INFOL8,ILIMPI,
     &             DIMGI1,NIVMPI,IDISPL,JGI,JGITGI
      INTEGER*4    INFOLA
      REAL*8       DDOT,RAUX,RBID
      CHARACTER*8  NOMSD
      CHARACTER*19 CHSMDD
      CHARACTER*24 NOMSDR,SDFETG,K24ER,K24BID      
      CHARACTER*32 JEXNUM,JEXNOM
      LOGICAL      LPARA

C CORPS DU PROGRAMME
      CALL JEMARQ()

C INITS.
      IF (INFOFE(10:10).EQ.'T') THEN
        NIVMPI=2
      ELSE
        NIVMPI=1
      ENDIF
      IF (NBPROC.EQ.1) THEN
        LPARA=.FALSE.
      ELSE
        LPARA=.TRUE.
      ENDIF
      SDFETG=SDFETI//'.FETG'
      NOMSDR=MATAS//'.FETR'
      DO 10 I=1,NBI
        VLAGI(I)=0.D0
   10 CONTINUE

C SI MODES DE CORPS RIGIDES CALCUL DE LANDA0=GI*(GITGI)-1*E   
      IF (LRIGID) THEN

C EN PARALLELE, GI ET GIT*GI NE SONT STOCKES QUE PAR LE PROC 0
        IF (RANG.EQ.0) THEN
          IF (LSTOGI) CALL JEVEUO(NOMGI,'L',JGI)
          CALL JEVEUO(NOMGGT,'L',JGITGI)
        ENDIF

C ADRESSE JEVEUX OBJET FETI & MPI
        CALL JEVEUO('&FETI.LISTE.SD.MPI','L',ILIMPI)
C OBJET JEVEUX POINTANT SUR LA LISTE DES CHAM_NO SECOND MEMBRE
        CALL JEVEUO(CHSECM//'.FETC','L',IFETC)
      
C VECTEUR AUXILLIAIRE CONTENANT VECTEUR E=[F1T*B1...FQT*BQ]T
C EN PARALLELE, POUR RANG DIFFERENT DE ZERO, IL SERT JUSTE AU
C MPI_REDUCE
        K24ER='&&FETINL.E.R'
        CALL WKVECT(K24ER,'V V R',DIMGI,JVE)
        DIMGI1=DIMGI-1
        DO 20 I=0,DIMGI1
          ZR(JVE+I)=0.D0
   20   CONTINUE

C -------------------------------------------------------------------- 
C CONSTITUTION DE E STOCKE DANS '&&FETINL.E.R'
C --------------------------------------------------------------------

C DECALAGE STOCKAGE E   
        IDECAO=JVE

C========================================
C BOUCLE SUR LES SOUS-DOMAINES + IF MPI:
C========================================        
        DO 100 IDD=1,NBSD

C NOMBRES DE MODES DE CORPS RIGIDES DU SOUS-DOMAINE IDD
          NBMC=VSDF(IDD)
C LE SOUS-DOMAINE IDD EST IL CONCERNE PAR LE PROCESSUS ACTUEL ?
          IF (ZI(ILIMPI+IDD).EQ.1) THEN
            CALL JEMARQ()                        
            IF (NBMC.NE.0) THEN
C SOUS-DOMAINE FLOTTANT
              NBMC1=NBMC-1

C NBRE DE DDL DU SOUS-DOMAINE IDD       
              NBDDL=VDDL(IDD)
                    
C COMPOSANTES DES MODES DE CORPS RIGIDES
              CALL JENUNO(JEXNUM(SDFETG,IDD),NOMSD)
              CALL JEVEUO(JEXNOM(NOMSDR,NOMSD),'L',IFETR)
C SECOND MEMBRE LOCAL AU SOUS-DOMAINE
              CHSMDD=ZK24(IFETC+IDD-1)(1:19)
              CALL JEVEUO(CHSMDD//'.VALE','L',IVALE)
                  
C ----  BOUCLE SUR LES MODES DE CORPS RIGIDES
C DECALAGE DE .FETR
              IDECAI=IFETR
              DO 90 IMC=0,NBMC1       
                ZR(IDECAO)=DDOT(NBDDL,ZR(IVALE),1,ZR(IDECAI),1)
                IDECAI=IDECAI+NBDDL
                IDECAO=IDECAO+1         
   90         CONTINUE
            ENDIF
            CALL JEDEMA()
          ELSE
C EN PARALLELE, IL FAUT DECALER L'OUTPUT POUR PRENDRE EN COMPTE LES
C MODES DE CORPS RIGIDES DES AUTRES PROCS
            IF (LPARA) IDECAO=IDECAO+NBMC
          ENDIF
C========================================
C BOUCLE SUR LES SOUS-DOMAINES + IF MPI:
C========================================
  100   CONTINUE
C REDUCTION DE E POUR LE PROCESSUS MAITRE
        IF (LPARA)
     &    CALL FETMPI(7,DIMGI,IFM,NIVMPI,IBID,IBID,K24ER,K24BID,K24BID,
     &                RBID)
C MONITORING
        IF (INFOFE(1:1).EQ.'T')
     &    WRITE(IFM,*)'<FETI/FETINL', RANG,'> CONSTRUCTION DE E'
        IF ((INFOFE(4:4).EQ.'T').AND.(RANG.EQ.0)) THEN
          DO 105 I=1,DIMGI
            WRITE(IFM,*)'E(I)',I,ZR(JVE+I-1)
  105     CONTINUE      
        ENDIF
C -------------------------------------------------------------------- 
C CONSTITUTION DE ((GI)T*GI)-1*E STOCKE DANS '&&FETINL.E.R'
C --------------------------------------------------------------------
C EN PARALLELE SEUL LE PROCESSUS MAITRE CONSTRUIT CET OBJET
        IF (RANG.EQ.0) THEN
          NB=1
          INFOLA=0
          INFOL8=0
C FACTORISATION/DESCENTE-REMONTEE SYMETRIQUE INDEFINIE (STOCKEE PAR
C PAQUET) VIA LAPACK
          CALL DSPTRF('L',DIMGI,ZR(JGITGI),ZI4(IPIV),INFOLA)
          INFOL8=INFOLA
          IF (INFOL8.NE.0) THEN
            CALL UTDEBM('F','FETINL','SYSTEME (GI)T*GI PROBABLEMENT')
            CALL UTIMPI('S','  NON INVERSIBLE: ',0,I)
            CALL UTIMPI('L','PB LAPACK DGETRF: ',1,INFOL8)
            CALL UTFINM()
          ENDIF
          INFOL8=0
          INFOLA=0        
          CALL DSPTRS('L',DIMGI,NB,ZR(JGITGI),ZI4(IPIV),ZR(JVE),DIMGI,
     &                INFOLA)
          INFOL8=INFOLA          
          IF (INFOL8.NE.0) THEN
            CALL UTDEBM('F','FETINL','SYSTEME (GI)T*GI PROBABLEMENT')
            CALL UTIMPI('S','  NON INVERSIBLE: ',0,I)
            CALL UTIMPI('L','PB LAPACK DGETRS: ',1,INFOL8)
            CALL UTFINM()
          ENDIF     
C MONITORING
          IF (INFOFE(1:1).EQ.'T')
     &      WRITE(IFM,*)'<FETI/FETINL', RANG,'> INVERSION (GITGI)-1*E'
          IF (INFOFE(4:4).EQ.'T') THEN
            DO 115 I=1,DIMGI
              WRITE(IFM,*)'(GIT*GI)-1*E(I)',I,ZR(JVE+I-1)
  115       CONTINUE
          ENDIF

C -------------------------------------------------------------------- 
C CONSTITUTION DE LANDA0=GI*(((GI)T*GI)-1*E) STOCKE DANS VLAGI
C --------------------------------------------------------------------

          IF (LSTOGI) THEN
            CALL DGEMV('N',NBI,DIMGI,1.D0,ZR(JGI),NBI,ZR(JVE),1,1.D0,
     &                 VLAGI,1)
          ELSE
C SANS CONSTRUIRE GI, SEULEMENT EN SEQUENTIEL        
            CALL WKVECT('&&FETI.GGT.V3','V V R',NBI,GII)
            JVE1=JVE-1
            DO 200 IDD=1,NBSD
C NBRE DE DDL DU SOUS-DOMAINE IDD       
              NBDDL=VDDL(IDD)
C NOMBRES DE MODES DE CORPS RIGIDES DU SOUS-DOMAINE IDD
              NBMC=VSDF(IDD)
                        
              IF (NBMC.NE.0) THEN
C SOUS-DOMAINE FLOTTANT
C COMPOSANTES DES MODES DE CORPS RIGIDES DE IDD
                CALL JENUNO(JEXNUM(SDFETG,IDD),NOMSD)
                CALL JEVEUO(JEXNOM(NOMSDR,NOMSD),'L',IFETR)
C ----  BOUCLES SUR LES MODES DE CORPS RIGIDES DE IDD
                DO 190 IMC=1,NBMC
                  JVE1=JVE1+1
                  RAUX=ZR(JVE1)         
                  CALL FETREX(1,IDD,NBDDL,ZR(IFETR+(IMC-1)*NBDDL),NBI,
     &                        ZR(GII),IREX)
                  CALL DAXPY(NBI,RAUX,ZR(GII),1,VLAGI,1)     
  190           CONTINUE
                CALL JELIBE(JEXNOM(NOMSDR,NOMSD))
              ENDIF
  200       CONTINUE
            CALL JEDETR('&&FETI.GGT.V3')
          
          ENDIF
        
C MONITORING
          IF (INFOFE(1:1).EQ.'T')
     &      WRITE(IFM,*)'<FETI/FETINL', RANG,'> CONSTRUCTION DE LANDA0'
          IF (INFOFE(4:4).EQ.'T') THEN
            DO 205 I=1,NBI
              WRITE(IFM,*)'LANDA0(I)',I,VLAGI(I)
  205       CONTINUE      
          ENDIF

C FIN DU IF RANG
        ENDIF
C DESTRUCTION OBJET TEMPORAIRE        
        CALL JEDETR(K24ER)
C EN PARALLELE, ENVOI DE VLAGI A TOUS LES PROC POUR CALCULER LE RESIDU
        IF (LPARA)
     &    CALL FETMPI(9,NBI,IFM,NIVMPI,IBID,IBID,K24LAI,K24BID,K24BID,
     &                RBID)
C FIN DU IF LRIGID
      ENDIF          
      CALL JEDEMA()
      END
