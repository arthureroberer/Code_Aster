      SUBROUTINE FETGGT(NBSD,MATAS,VSDF,VDDL,LRIGID,NBI,NOMGGT,DIMGI,
     &                  NOMGI,STOGI,LSTOGI,MAMOY,INFOFE,IREX,IFM,
     &                  SDFETI,NBPROC,RANG)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 20/06/2005   AUTEUR BOITEAU O.BOITEAU 
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
C-----------------------------------------------------------------------
C    - FONCTION REALISEE:  CALCUL DES MATRICES GI ET (GI)T * GI
C
C      IN  MATAS: K19  : NOM DE LA MATRICE DE RIGIDITE GLOBALE 
C      IN   VSDF: VIN  : VECTEUR MATR_ASSE.FETF INDIQUANT SI 
C                         SD FLOTTANT
C      IN   NBSD: IN   : NOMBRE DE SOUS-DOMAINES
C      IN   VDDL: VIN  : VECTEUR DES NBRES DE DDLS DES SOUS-DOMAINES
C     OUT LRIGID: LO  : LOGICAL INDIQUANT LA PRESENCE D'AU MOINS UN
C         SOUS-DOMAINES FLOTTANT
C      IN    NBI: IN   : NOMBRE DE NOEUDS D'INTERFACE
C      IN NOMGGT: CH24: NOMS DE OBJ. JEVEUX CONTENANT GIT*GI
C     OUT DIMGI:  IN : TAILLE DE GIT*GI
C      IN NOMGI: CH24: NOMS DE OBJ. JEVEUX CONTENANT GI (EVENTUELLEMENT)
C      IN STOGI: CH24: PARAMETRE DE STOCKAGE DE GI
C     OUT LSTOGI: LO : TRUE, GI STOCKE, FALSE, RECALCULE
C      IN MAMOY: IN : CRITERE DE STOCKAGE DE GI SI STOGI='CAL'
C     IN IREX  : IN    : ADRESSE DU VECTEUR AUXILAIRE EVITANT DES APPELS
C                        JEVEUX.
C     IN RANG  : IN  : RANG DU PROCESSEUR
C     IN SDFETI: CH19: SD DECRIVANT LE PARTIONNEMENT FETI
C     IN NBPROC: IN  : NOMBRE DE PROCESSEURS
C----------------------------------------------------------------------
C RESPONSABLE BOITEAU O.BOITEAU
C CORPS DU PROGRAMME
      IMPLICIT NONE

C DECLARATION PARAMETRES D'APPELS
      INTEGER      NBSD,VSDF(NBSD),VDDL(NBSD),NBI,DIMGI,MAMOY,IREX,IFM,
     &             RANG,NBPROC
      CHARACTER*19 MATAS,SDFETI
      CHARACTER*24 NOMGGT,NOMGI,STOGI,INFOFE
      LOGICAL      LRIGID,LSTOGI
      
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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
      INTEGER      IDD,NBMC,NGI,NGITGI,IDECA3,IMC,IBID,
     &             IFETR,NBDDL,K,OPT,IDECAJ,IMC1,JMC,GII,GIJ,IDECAO,
     &             I,J,JGITGI,JDD,IDD1,NBDDLJ,NBMCJ,ICOMPT,ILIMP1,
     &             IFETRJ,JGI,IDECAI,ILIMPI,NIVMPI,IACH1,IACH2,
     &             IAUX1,IAUX11,NBPRO1
      REAL*8       DDOT,RAUX,RBID
      CHARACTER*8  NOMSD,NOMSDJ
      CHARACTER*24 NOMSDR,SDFETG,NOM1,NOM2
      CHARACTER*32 JEXNUM,JEXNOM
      LOGICAL      LPARA

C CORPS DU PROGRAMME
      CALL JEMARQ()
        
C INITS
      IF (NBPROC.EQ.1) THEN
        LPARA=.FALSE.
      ELSE
        LPARA=.TRUE.
      ENDIF
      SDFETG=SDFETI//'.FETG'
      IF (INFOFE(10:10).EQ.'T') THEN
        NIVMPI=2
      ELSE
        NIVMPI=1
      ENDIF
      NOMSDR=MATAS//'.FETR'
      LRIGID=.FALSE.
      LSTOGI=.FALSE.
      DIMGI=0
      JGITGI=-1
C ADRESSE JEVEUX OBJET FETI & MPI
      CALL JEVEUO('&FETI.LISTE.SD.MPI','L',ILIMPI)
      CALL JEVEUO('&FETI.LISTE.SD.MPIB','L',ILIMP1)
      
C BOUCLE SUR LES SOUS-DOMAINES POUR CALCULER L'ORDRE DE DE GIT*GI
C ET LA NECESSITE DU STOCKAGE DE GI OU NON
      DO 10 IDD=1,NBSD
        DIMGI=DIMGI+VSDF(IDD)
   10 CONTINUE               
      IF (DIMGI.EQ.0) THEN
C MONITORING
        IF ((INFOFE(1:1).EQ.'T').AND.(RANG.EQ.0))
     &    WRITE(IFM,*)'<FETI/FETGGT', RANG,
     &                '> PAS DE MODE DE CORPS RIGIDE'
        GOTO 999
      ELSE
        LRIGID=.TRUE.
        RAUX=DIMGI*NBI  
C DETERMINATION DU STOCKAGE DE GI OU PAS
        IF (STOGI(1:3).EQ.'OUI') THEN
          LSTOGI=.TRUE.
        ELSE IF (STOGI(1:3).EQ.'NON') THEN
          LSTOGI=.FALSE.
        ELSE IF (STOGI(1:3).EQ.'CAL') THEN
          IF (RAUX.LT.MAMOY) THEN
            LSTOGI=.TRUE.
          ELSE
            LSTOGI=.FALSE.        
          ENDIF
        ELSE
          CALL UTMESS('F','FETGGT','VALEUR DE STOGI INCOHERENTE !')     
        ENDIF
C EN PARALLELE
C ATTENTION, POUR NE PAS AVOIR A TRANSFERER LES MATAS.FETH + COLAUI
C AU PROCESSUS MAITRE OU SUPPORTER LES ENVOIS DE MSG CONTINGENT A
C CHAQUE PROJECTION, IL FAUT CONSTRUIRE GI ET GITGI UNE FOIS POUR TOUTE
C LORS DE CE PREMIER PASSAGE DANS FETGGT
C IL N'EST PAS CHOQUANT QUE CETTE FACILITE D'ECONOMIE DE STOCKAGE NE
C RESERVER QU'AU SEQUENTIEL. EN PARALLELE ON PEUT DISTRIBUER AUTREMENT
C LES PROCESSUS POUR LIMITER DE CHARGER LE PROCESSUS MAITRE EN MEMOIRE
        IF ((LPARA).AND.(.NOT.LSTOGI))
     &    CALL UTMESS('F','FETGGT',
     &   'EN PARALLELE STOGI=OUI OBLIGATOIRE POUR L''INSTANT !')     
             
C MONITORING
        IF (INFOFE(1:1).EQ.'T') THEN
          WRITE(IFM,*)'<FETI/FETGGT', RANG,
     &      '> NBRE TOTAL DE CORPS RIGIDES',DIMGI
          IF (LSTOGI)
     &      WRITE(IFM,*)'              STOCKAGE GI',LSTOGI,RAUX,MAMOY
        ENDIF      
      ENDIF

C VECTEURS AUXILIAIRES CONTENANT GI ET GIT*GI (STOCKAGE PAR COLONNE
C AVEC SEULEMENT LA PARTIE TRIANGULAIRE INFERIEURE POUR GIT*GI)
C EN PARALLELE, SI RANG NON NUL, ON DETRUIT GI EN FIN DE ROUTINE.
C ON EN A JUSTE BESOIN POUR LE MPI_GATHER
      IF (RANG.EQ.0) THEN
        NGITGI=DIMGI*(DIMGI+1)/2
        CALL WKVECT(NOMGGT,'V V R',NGITGI,JGITGI)
      ENDIF
      IF (LSTOGI) THEN
        NGI=NBI*DIMGI      
        CALL WKVECT(NOMGI,'V V R',NGI,JGI)      
      ELSE
        CALL WKVECT('&&FETI.GGT.V1','V V R',NBI,GII)
        CALL WKVECT('&&FETI.GGT.V2','V V R',NBI,GIJ)      
      ENDIF

      OPT=1
      IF (LSTOGI) THEN
C -------------------------------------------------------------------- 
C CONSTITUTION DE (GI)T*GI EN CONSTRUISANT GI
C --------------------------------------------------------------------
C DECALAGE DU VECTEUR OUTPUT DE FETREX (GI)
        IDECAO=JGI

C PREPARATION DU TERRAIN POUR LE PARALLELISME SI NECESSAIRE
        IF (LPARA) THEN
          NOM1='&&RECVCOUNT_FETGGT'
          CALL WKVECT(NOM1,'V V I',NBPROC,IACH1)
          NOM2='&&DISPLS_FETGGT'
          CALL WKVECT(NOM2,'V V I',NBPROC,IACH2)
          DO 14 I=1,NBPROC
            ZI(IACH1+I-1)=0
            ZI(IACH2+I-1)=0
   14     CONTINUE
          NBPRO1=NBPROC-1
          DO 16 IDD=1,NBSD
            NBMC=VSDF(IDD)
            IF (NBMC.NE.0) THEN
              NBMC=NBMC*NBI
              IAUX1=ZI(ILIMP1+IDD-1)
              ZI(IACH1+IAUX1)=ZI(IACH1+IAUX1)+NBMC
              IAUX11=IAUX1+1
              DO 15 I=IAUX11,NBPRO1
                ZI(IACH2+I)=ZI(IACH2+I)+NBMC
   15         CONTINUE
            ENDIF
   16     CONTINUE         
        ENDIF
C========================================
C BOUCLE SUR LES SOUS-DOMAINES + IF MPI:
C========================================
        DO 30 IDD=1,NBSD
C LE SOUS-DOMAINE IDD EST IL CONCERNE PAR LE PROCESSUS ACTUEL ?
          IF (ZI(ILIMPI+IDD).EQ.1) THEN
            NBDDL=VDDL(IDD)
            NBMC=VSDF(IDD)           
            IF (NBMC.NE.0) THEN
              CALL JENUNO(JEXNUM(SDFETG,IDD),NOMSD)
              CALL JEVEUO(JEXNOM(NOMSDR,NOMSD),'L',IFETR)
              DO 20 IMC=1,NBMC         
                CALL FETREX(OPT,IDD,NBDDL,ZR(IFETR+(IMC-1)*NBDDL),NBI,
     &            ZR(IDECAO),IREX)
                IDECAO=IDECAO+NBI
   20         CONTINUE
              CALL JELIBE(JEXNOM(NOMSDR,NOMSD))      
            ENDIF
C========================================
C FIN BOUCLE SUR LES SOUS-DOMAINES + IF MPI:
C========================================
          ENDIF
   30   CONTINUE
C COLLECTE SELECTIVE DE GI POUR LE PROCESSUS MAITRE 
        IF (LPARA) THEN
          IBID=ZI(IACH1+RANG)
          CALL FETMPI(8,IBID,IFM,NIVMPI,RANG,NBPROC,NOMGI,NOM1,NOM2,
     &                RBID)
        ENDIF
C MONITORING
        IF (INFOFE(1:1).EQ.'T')
     &    WRITE(IFM,*)'<FETI/FETGGT', RANG,'> CONSTRUCTION GI'
        IF ((INFOFE(4:4).EQ.'T').AND.(RANG.EQ.0)) THEN
          IDECAO=JGI
          DO 32 J=1,DIMGI
            DO 31 I=1,NBI
              WRITE(IFM,*)'G(I,J)',I,J,ZR(IDECAO)
              IDECAO=IDECAO+1       
   31       CONTINUE
   32     CONTINUE
        ENDIF

C DESTRUCTION DES OBJETS AUXILIAIRES ENCOMBRANTS EN PARALLELISME
        IF (RANG.NE.0) CALL JEDETR(NOMGI)
        IF (LPARA) THEN
          CALL JEDETR(NOM1)
          CALL JEDETR(NOM2)
        ENDIF
        
C IL ME SEMBLE QU'IL N'Y A PAS DE ROUTINE BLAS EFFECTUANT GT*G AVEC
C G MATRICE RECTANGLE ET LE RESULTAT STOCKE DANS UNE MATRICE TRIANG
C GULAIRE. EN PARALLELE, SEUL LE PROCESSEUR ZERO CONSTRUIT GIT*G
        IF (RANG.EQ.0) THEN        
          IDECAO=JGITGI
          DO 43 J=1,DIMGI
            IDECAJ=(J-1)*NBI+JGI
            DO 42 I=J,DIMGI           
              IDECAI=(I-1)*NBI+JGI
              ZR(IDECAO)=DDOT(NBI,ZR(IDECAI),1,ZR(IDECAJ),1)
              IDECAO=IDECAO+1
   42       CONTINUE
   43     CONTINUE
        ENDIF
     
      ELSE         
C -------------------------------------------------------------------- 
C CONSTITUTION DE (GI)T*GI SANS CONSTRUIRE GI SEULEMENT EN SEQUENTIEL
C --------------------------------------------------------------------
C ----  BOUCLE SUR LES SOUS-DOMAINES

C NOMBRE DE SOUS-DOMAINES FLOTTANTS      
        ICOMPT=-1
        DO 100 IDD=1,NBSD
      
          NBDDL=VDDL(IDD)
          NBMC=VSDF(IDD)
                        
          IF (NBMC.NE.0) THEN
            CALL JENUNO(JEXNUM(SDFETG,IDD),NOMSD)
            CALL JEVEUO(JEXNOM(NOMSDR,NOMSD),'L',IFETR)
            IDD1=IDD+1
            DO 90 IMC=1,NBMC
              CALL FETREX(OPT,IDD,NBDDL,ZR(IFETR+(IMC-1)*NBDDL),NBI,
     &                  ZR(GII),IREX)
              ICOMPT=ICOMPT+1     
              ZR(JGITGI+ICOMPT)=DDOT(NBI,ZR(GII),1,ZR(GII),1)
              IMC1=IMC+1
              DO 60 JMC=IMC1,NBMC
                ICOMPT=ICOMPT+1       
                CALL FETREX(OPT,IDD,NBDDL,ZR(IFETR+(JMC-1)*NBDDL),NBI,
     &                    ZR(GIJ),IREX)
                ZR(JGITGI+ICOMPT)=DDOT(NBI,ZR(GII),1,ZR(GIJ),1)
   60         CONTINUE

C ----  BOUCLE SUR LES SOUS-DOMAINES JDD > IDD
              DO 80 JDD=IDD1,NBSD
                NBDDLJ=VDDL(JDD)
                NBMCJ=VSDF(JDD)
                IF (NBMCJ.NE.0) THEN
C SOUS-DOMAINE FLOTTANT
C COMPOSANTES DES MODES DE CORPS RIGIDES
                  CALL JENUNO(JEXNUM(SDFETG,JDD),NOMSDJ)
                  CALL JEVEUO(JEXNOM(NOMSDR,NOMSDJ),'L',IFETRJ)
C ----  BOUCLE SUR LES MODES DE CORPS RIGIDES DE JDD
                  DO 70 JMC=1,NBMCJ         
                    ICOMPT=ICOMPT+1           
                   CALL FETREX(OPT,JDD,NBDDLJ,ZR(IFETRJ+(JMC-1)*NBDDLJ),
     &                NBI,ZR(GIJ),IREX)
                    ZR(JGITGI+ICOMPT)=DDOT(NBI,ZR(GII),1,ZR(GIJ),1)
   70             CONTINUE
                  CALL JELIBE(JEXNOM(NOMSDR,NOMSDJ))
                ENDIF         
   80         CONTINUE                       
   90       CONTINUE
            CALL JELIBE(JEXNOM(NOMSDR,NOMSD))      
          ENDIF
  100   CONTINUE
        CALL JEDETR('&&FETI.GGT.V1')
        CALL JEDETR('&&FETI.GGT.V2')  
      ENDIF

C MONITORING
      IF (INFOFE(1:1).EQ.'T')
     &  WRITE(IFM,*)'<FETI/FETGGT', RANG,'> CONSTRUCTION (GI)T*GI'
      IF ((INFOFE(4:4).EQ.'T').AND.(RANG.EQ.0)) THEN
        IDECAO=JGITGI      
        DO 151 J=1,DIMGI
          DO 150 I=J,DIMGI
            WRITE(IFM,*)'GTG(I,J)',I,J,ZR(IDECAO)
            IDECAO=IDECAO+1     
  150     CONTINUE
  151   CONTINUE
      ENDIF
  999 CONTINUE
  
      CALL JEDEMA()  
      END
