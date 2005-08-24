      SUBROUTINE INIOBS(NBOBSE, NUINS0, LOBSER, INSTAM, RESULT,
     &                  NUOBSE, NOMTAB, MAILL2, NBOBAR,
     &                  LISINS, LISOBS)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 24/08/2005   AUTEUR MABBAS M.ABBAS 
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
C RESPONSABLE PBADEL P.BADEL

      IMPLICIT NONE
      INTEGER      NBOBSE
      INTEGER      NUINS0
      LOGICAL      LOBSER
      REAL*8       INSTAM
      CHARACTER*8  RESULT
      INTEGER      NUOBSE
      CHARACTER*19 NOMTAB
      CHARACTER*8  MAILL2
      INTEGER      NBOBAR
      CHARACTER*24 LISINS
      CHARACTER*19 LISOBS
C ----------------------------------------------------------------------
C
C      INITIALISATION DES OBSERVATIONS
C
C ----------------------------------------------------------------------
C      OUT  NBOBSE   NOMBRE DE PAS A OBSERVER
C      OUT  NUINS0   NUMERO DU PREMIER INSTANT DE CALCUL DANS LISTE
C                      D'INSTANT D'OBSERVATION
C      OUT  LOBSER   BOOLEEN OBSERVATION
C       IN  INSTAM   PREMIER INSTANT DE CALCUL
C       IN  RESULT   NOM UTILISATEUR DU RESULTAT
C      OUT  NUOBSE   ??
C      OUT  NOMTAB   NOM DE LA TABLE RESULTAT DE L'OBSERVATION
C      OUT  MAILL2   MAILLAGE OBSERVATION (?)
C      OUT  NBOBAR   LONGUEUR DU CHAMP OBSERVE
C      OUT  LISINS   LISTE D'INSTANTS DE L'OBSERVATION
C IN/JXOUT  LISOBS   SD LISTE OBSERVATION
C 
C ----------------------------------------------------------------------
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
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
      INTEGER      NLISIN,KKKMA,NOINS2,JINST
      REAL*8       EPSI
      CHARACTER*8  K8BID
C
C ----------------------------------------------------------------------
C       
      CALL JEMARQ()
      
      NBOBSE = 0
      NUINS0 = 1      
      LOBSER = .FALSE.
C
C --- TOLERANCE RELATIVE ENTRE TEMPS D'OBSERVATION ET LISTE D'INSTANTS
C
      EPSI   = 1.D-4

      CALL GETVID('INCREMENT','LIST_INST',1,1,1,LISINS,NLISIN)

      IF (NLISIN.NE.0) THEN
         CALL JEVEUO(LISINS(1:19)//'.VALE','L',JINST)
         CALL JELIRA(LISINS(1:19)//'.VALE','LONUTI',NOINS2,K8BID)     
         CALL RNLIR8(LISINS,INSTAM,EPSI,NUINS0)      
         CALL DYOBSE(NOINS2,LISINS,LISOBS,NBOBSE,RESULT)
      ENDIF

      IF ( NBOBSE .NE. 0 ) THEN
         NUOBSE = 0
         NOMTAB = ' '
         CALL LTNOTB( RESULT, 'OBSERVATION', NOMTAB )
         CALL JEVEUO('&&DYOBSE.MAILLA'   , 'L' , KKKMA )
         MAILL2 = ZK8(KKKMA)
         CALL JELIRA('&&DYOBSE.NOM_CHAM','LONUTI',NBOBAR,K8BID)
      ENDIF
      
      CALL JEDEMA()
      
      END
