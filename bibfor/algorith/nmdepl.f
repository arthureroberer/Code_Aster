      SUBROUTINE NMDEPL(MODELE,NUMEDD,MATE,CARELE,COMREF,COMPOR,LISCHA,
     &                 CNFEXT,PARMET,CARCRI,MODEDE,NUMEDE,SOLVDE,
     &                 PARCRI,POUGD,ITERAT,VALMOI,RESOCO,VALPLU,CNRESI,
     &                 CNDIRI,REAROT,NURO,METHOD,NUMINS,OPTION,CONV,
     &                 STADYN,DEPENT,VITENT,LAMORT,MATASS,MEMASS,
     &                 MASSE,AMORT,COEDEP,COEVIT,COEACC,INDRO,SECMBR,
     &                 INSTAP,INSTAM,CMD,ETAN,PARTPS,PREMIE,ZFON,
     &                 FONACT,RIGID,DEPKM1,VITKM1,ACCKM1,VITPLU,ACCPLU,
     &                 ROMKM1,ROMK,PILOTE,DEPDEL,DEPPIL,DEPOLD,LIGRCF,
     &                 CARTCF,MCONEL,SCONEL,MAILLA,DEPPLT,DEFICO,
     &                 CNCINE,SOLVEU,LREAC,ETA,LICCVG,DDEPLA,VITMOI,
     &                 ACCMOI,DEFICU,RESOCU,IALGO,LSSTRU,ACCGEM,ACCGEP,
     &                 VITGEM,VITGEP,DEPGEM,DEPGEP)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 04/04/2006   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
      IMPLICIT NONE
      INTEGER       ZFON
      LOGICAL REAROT,LAMORT,PREMIE,FONACT(ZFON),LREAC(2)
      INTEGER ITERAT,LICCVG(2),INDRO,NUMINS,IALGO
      REAL*8 PARMET(*),CONV(*),INST(3),ETA,ETAN
      REAL*8 PARCRI(*),COEDEP,COEVIT,COEACC
      REAL*8 INSTAP,INSTAM
      CHARACTER*8 MODEDE,MCONEL,SCONEL,MAILLA
      CHARACTER*14 PILOTE
      CHARACTER*16 OPTION,METHOD(*),CMD
      CHARACTER*19 LISCHA,CNRESI,CNDIRI,CNFEXT,SOLVDE,PARTPS
      CHARACTER*19 NURO,LIGRCF,CARTCF,SOLVEU,MATASS
      CHARACTER*24 MODELE,NUMEDD,MATE,CARELE,COMREF,COMPOR
      CHARACTER*24 CARCRI,VALMOI,POUGD,DDEPLA,VALPLU,DEPDEL
      CHARACTER*24 RESOCO,SECMBR,DEPOLD,NUMEDE,DEPPIL(2)
      CHARACTER*24 STADYN,DEPENT,VITENT,MEMASS,MASSE,AMORT
      CHARACTER*24 DEPKM1,VITKM1,ACCKM1,VITPLU,ACCPLU
      CHARACTER*24 ROMKM1,ROMK,DEPPLT,DEFICO,CNCINE,RIGID
      CHARACTER*24 VITMOI,ACCMOI
      CHARACTER*24 DEFICU,RESOCU
      CHARACTER*24 ACCGEM,ACCGEP,VITGEM,VITGEP,DEPGEM,DEPGEP
      LOGICAL      LSSTRU
C
C
C ----------------------------------------------------------------------
C
C                   CALCUL DE L'INCREMENT DE DEPLACEMENT
C
C                A PARTIR DE(S) DIRECTION(S) DE DESCENTE :
C
C              PRISE EN COMPTE DU PILOTAGE ET DE LA RECHERCHE LINEAIRE
C
C ----------------------------------------------------------------------
C
C IN       MODELE K24  MODELE
C IN       NUMEDD K24  NUME_DDL
C IN       MATE   K24  CHAMP MATERIAU
C IN       CARELE K24  CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C IN       COMREF K24  VARI_COM DE REFERENCE
C IN       COMPOR K24  COMPORTEMENT
C IN       LISCHA K19  L_CHARGES
C IN       CNFEXT K19  RESULTANTE DES EFFORTS EXTERIEURS
C IN       PARMET  R8  PARAMETRES DES METHODES DE RESOLUTION
C IN       CARCRI K24  PARAMETRES DES METHODES D'INTEGRATION LOCALES
C IN       MODEDE K8   MODELE NON LOCAL
C IN       NUMEDE K24  NUME_DDL NON LOCAL
C IN       SOLVDE K19  SOLVEUR NON LOCAL
C IN       PARCRI  R   CRITERES DE CONVERGENCE GLOBAUX
C IN       POUGD  K24  DONNES POUR POUTRES GRANDES DEFORMATIONS
C IN       ITERAT  I   NUMERO D'ITERATION DE NEWTON
C IN       VALMOI K24  ETAT EN T-
C IN       ZFON    I   LONGUEUR MAXI DU VECTEUR FONACT
C IN       FONACT  I   FONCTIONNALITES ACTIVEES (VOIR NMFONC)
C IN       MATASS K24  NOM DE LA MATRICE DE RIGIDITE ASSEMBLE 
C                       (CAS DYNAMIQUE)
C IN       RESOCO K24  SD CONTACT
C IN       DEFICU K24  SD DEF. LIAISON_UNILATERALE
C IN       RESOCU K24  SD RES. LIAISON_UNILATERALE
C IN/JXVAR VALPLU K24  ETAT EN T+ : SIGPLU ET VARPLU
C IN/JXVAR CNRESI K19  FINT+BT.LAMBDA
C IN/JXVAR CNDIRI K19  BT.LAMBDA
C IN       REAROT L    BOOLEEN DE PRESENCE DE DDL DE GRDE ROTATION
C IN/JXIN  NURO   K19  TYPE DES DDLS (CF. MAJDVA)
C IN       METHOD K16  INFORMATIONS SUR LES METHODES DE RESOLUTION
C                      VOIR DETAIL DES COMPOSANTES DANS NMLECT
C IN       NUMINS  I   NUMERO D'INSTANT
C OUT      OPTION K16  NOM D'OPTION PASSE A MERIMO 
C IN       MATASS K19  NOM DE LA MATRICE DU PREMIER MEMBRE ASSEMBLEE
C IN       PILOTE K14  SD PILOTAGE
C IN       NBEFFE  I   NOMBRE DE VALEURS DE PILOTAGE ENTRANTES
C IN       DEPDEL K24  INCREMENT DE DEPLACEMENT CUMULE
C IN       DEPPIL K24  CORRECTION DE DEPLACEMENT DE L'ITERATION
C IN       DEPOLD K24  INCREMENT DE DEPLACEMENT PAS PRECEDENT (LONG_ARC)
C IN       IALGO  I    ALGORITHME D'INTEGRATION EN TEMPS
C                       (6) : EXPLICITE : DIFFERENCES CENTREES
C                       (7) : EXPLICITE : TCHAMWA-WIELGOSZ
C OUT      ETA     R8  PARAMETRE DE PILOTAGE
C OUT      LICCVG  I   CODES RETOURS 
C                       (1) PILOTAGE
C                       (2) LOI DE COMPORTEMENT
C                       (3) CONTACT - FROTTEMENT
C                       (4) CONTACT - FROTTEMENT
C OUT      DDEPLA K24  DIRECTION DE DESCENTE REACTUALISEE
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      LOGICAL CFINT
      INTEGER NEQ,JDEPM,JDEPDE,JDEPP,JDDEPL,IBID
      CHARACTER*8 K8BID
      CHARACTER*19 K19BLA
      CHARACTER*24 DEPMOI,SIGMOI,COMMOI
      CHARACTER*24 DEPPLU,SIGPLU,VARPLU,COMPLU
      CHARACTER*24 K24BID,VARDEP,LAGDEP,K24BLA
C
      INTEGER IRET,IRE2,JTRA,JRESI,JRSST,NBSS
      CHARACTER*24 TABTRA
C
C ----------------------------------------------------------------------
C
      
      TABTRA = '&&NMDEPL.TABTRA'    
C
C    A-T-ON BESOIN DE REACTUALISER LES FORCES INTERNES ?
C
      CALL NMMATR('FORCES_INT',K24BLA,K24BLA,K24BLA,K24BLA,
     &                  K24BLA,K24BLA,K19BLA,K24BLA,' ',
     &                  METHOD,K19BLA,PARMET,K24BLA,PARTPS,
     &                  NUMINS,ITERAT,K24BLA,K24BLA,K24BLA,
     &                  K24BLA,K19BLA,OPTION,DEFICO,STADYN,
     &                  PREMIE,   CMD,DEPENT,VITENT,RIGID,
     &                  LAMORT ,MEMASS, MASSE,AMORT ,COEDEP,
     &                  COEVIT,COEACC,IBID)
C
C    PAS DE RECHERCHE LINEAIRE
C    EN PARTICULIER SUITE A LA PREDICTION
C
      IF (.NOT.FONACT(1) .OR. ITERAT.EQ.0) THEN

        CALL NMPICH(MODELE,NUMEDD,MATE,CARELE,COMREF,COMPOR,LISCHA,
     &              CNFEXT,PARMET,CARCRI,MODEDE,NUMEDE,SOLVDE,PARCRI,
     &              POUGD,ITERAT,VALMOI,RESOCO,VALPLU,CNRESI,CNDIRI,
     &              REAROT,FONACT,CONV,INDRO,PILOTE,DEPDEL,DEPPIL,
     &              DEPOLD,INSTAP-INSTAM,SECMBR,ETA,LICCVG,DDEPLA)
        IF (LICCVG(1) .EQ. 1) THEN
          GOTO 9999
        ENDIF  
       
        CFINT = .TRUE.
        
      ELSE
C
C -- RECHERCHE LINEAIRE
C
        IF (FONACT(2)) THEN
C
C        AVEC PILOTAGE        
C
          CALL NMREPL(MODELE,NUMEDD,MATE,CARELE,COMREF,COMPOR,LISCHA,
     &                CNFEXT,PARMET,CARCRI,MODEDE,NUMEDE,SOLVDE,PARCRI,
     &                DEPPIL,INST,ITERAT,VALMOI,POUGD,DEPDEL,RESOCO,
     &                DDEPLA,VALPLU,CNRESI,CNDIRI,CONV,LICCVG,REAROT,
     &                INDRO,SECMBR,INSTAP-INSTAM,PILOTE,ETAN,ETA,DEPOLD)
C
C
          ELSE
C
C        SANS PILOTAGE
            CALL COPISD('CHAMP_GD','V',DEPPIL(1),DDEPLA)
            CALL NMRECH(MODELE,NUMEDD,MATE,CARELE,COMREF,COMPOR,LISCHA,
     &                  CNFEXT,PARMET,CARCRI,MODEDE,NUMEDE,SOLVDE,
     &                  PARCRI,ITERAT,VALMOI,POUGD,DEPDEL,RESOCO,DDEPLA,
     &                  VALPLU,CNRESI,CNDIRI,CONV,LICCVG(2),REAROT,INDRO
     &                 )
        END IF
 
        IF (OPTION .EQ. 'FULL_MECA') THEN
          CFINT = .TRUE.
        ELSE
          CFINT = .FALSE.
        END IF
      END IF
C
      IF (CMD .EQ. 'DYNA_TRAN_EXPLI') THEN
C ------------> MISE A JOUR DES VITESSES :
C               {VN+1}={VN}+DT/2*({AN}+{AN+1})
C                       {UN}={UN+1}
C                       {AN}={AN+1}
C                       {VN}={VN+1}
        CALL JELIRA(ACCMOI(1:19)//'.VALE','LONMAX',NEQ,K8BID)
        CALL MXMAJD(NEQ,REAROT,NURO,INSTAP-INSTAM,VITMOI,ACCMOI,VITPLU,
     &              ACCPLU,IALGO,LSSTRU,ACCGEM,ACCGEP,VITGEM,VITGEP,
     &              DEPGEM,DEPGEP)
      ELSE
C -- MISE A JOUR DES DEPLACEMENTS
        CALL DESAGG(VALMOI,DEPMOI,SIGMOI,K24BID,COMMOI,K24BID,K24BID,
     &              K24BID,K24BID)
        CALL DESAGG(VALPLU,DEPPLU,SIGPLU,VARPLU,COMPLU,VARDEP,LAGDEP,
     &              K24BID,K24BID)
        CALL JELIRA(DEPMOI(1:19)//'.VALE','LONMAX',NEQ,K8BID)
C
        CALL JEVEUO(DEPMOI(1:19)//'.VALE','L',JDEPM)
        CALL JEVEUO(DEPDEL(1:19)//'.VALE','E',JDEPDE)
        CALL JEVEUO(DEPPLU(1:19)//'.VALE','E',JDEPP)
        CALL JEVEUO(DDEPLA(1:19)//'.VALE','L',JDDEPL)
C
C --- TRAITEMENT EVENTUEL DU CONTACT ET/OU DU FROTTEMENT
C --- ON CALCULE LES FORCES INTERNES QUELQUE SOIT L'OPTION D'ASSEMBLAGE
C
        IF (FONACT(4)) THEN
          CALL NMCOFR(MAILLA,DEPPLT,DEPDEL,DDEPLA,MATASS,DEFICO,RESOCO,
     &                CNCINE,ITERAT,INSTAP,CONV,LICCVG,LREAC)
          CFINT = .TRUE.
        END IF
C
C --- TRAITEMENT EVENTUEL DE LIAISON_UNILATER
C --- ON CALCULE LES FORCES INTERNES QUELQUE SOIT L'OPTION D'ASSEMBLAGE
C      
        IF (FONACT(12)) THEN
        CALL NMUNIL(MAILLA,DEPPLT,DEPDEL,DDEPLA,MATASS,
     &              DEFICU,RESOCU,CNCINE,ITERAT,INSTAP)   
          CFINT = .TRUE.        
        END IF  
        IF (CMD(1:4) .EQ. 'STAT') THEN
          CALL MAJOUR(NEQ,REAROT,ZI(INDRO),ZR(JDEPDE),ZR(JDDEPL),1.D0,
     &                ZR(JDEPDE))
          CALL MAJOUR(NEQ,REAROT,ZI(INDRO),ZR(JDEPP),ZR(JDDEPL),1.D0,
     &                ZR(JDEPP))
        ELSE
          CALL MAJDVA(NEQ,REAROT,NURO,COEVIT,COEACC,DEPMOI,DDEPLA,
     &                DEPDEL,DEPKM1,VITKM1,ACCKM1,DEPPLU,VITPLU,ACCPLU,
     &                ROMKM1,ROMK)
        END IF
C
C --- CALCUL DES FORCES INTERNES
C
        IF (CFINT) THEN
C
C --- CONTACT METHODE CONTINUE AVEC OU SANS XFEM
C
          IF (FONACT(5)) THEN
            IF (FONACT(9)) THEN
              CALL XMMCME(MODELE(1:8),DEPMOI,DEPDEL,DEFICO,
     &                    MCONEL,SCONEL)
            ELSE
              CALL MMCMEM(MODELE,DEPMOI,DEPDEL,VITMOI,ACCMOI,
     &                    LIGRCF,CARTCF,MCONEL,SCONEL)
            ENDIF
          ENDIF
C  Modif en test :
          CALL NMFINT(MODELE,NUMEDD,MATE,CARELE,COMREF,COMPOR,LISCHA,
     &                CARCRI,POUGD,ITERAT,MODEDE,NUMEDE,SOLVDE,PARMET,
     &                PARCRI,VALMOI,DEPDEL,RESOCO,VALPLU,CNRESI,CNDIRI,
     &                LICCVG(2),OPTION,CONV,STADYN,DEPENT,VITENT)

C
C   NECESSAIRE POUR LA PRISE EN COMPTE DE MACRO-ELEMENT STATIQUE
          CALL DISMOI('F','NB_SS_ACTI',MODELE,'MODELE',NBSS,K8BID,IRET)
          IF (NBSS .GT. 0) THEN
            CALL JEEXIN('&&SSRIGI.REFE_RESU',IRET)
            IF (IRET .NE. 0) THEN
              CALL JEEXIN(TABTRA,IRE2)
              IF (IRE2 .EQ. 0) THEN
                CALL WKVECT(TABTRA,'V V R',NEQ,JTRA)
              ELSE
                CALL JEVEUO(TABTRA,'E',JTRA)
              END IF
              CALL JEVEUO(CNRESI(1:19)//'.VALE','E',JRESI)
              CALL JEVEUO('&&ASRSST           .&INT','L',JRSST)
              CALL MRMULT('ZERO',JRSST,ZR(JDEPP),'R',ZR(JTRA),1)
              CALL DAXPY(NEQ,1.D0,ZR(JTRA),1,ZR(JRESI),1)
            END IF
          END IF
C
C   FIN MACRO-ELEMENT STATIQUE
C
         END IF
      END IF
C
C
 9999 CONTINUE
      END
