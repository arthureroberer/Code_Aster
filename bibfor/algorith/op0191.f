      SUBROUTINE OP0191(IER)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/06/2004   AUTEUR DURAND C.DURAND 
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
C RESPONSABLE JMBHH01 J.M.PROIX
      IMPLICIT   NONE
      INTEGER    IER
C ----------------------------------------------------------------------
C
C     COMMANDE : MODI_REPERE
C
C ----------------------------------------------------------------------
C ----- DEBUT COMMUNS NORMALISES  JEVEUX  ------------------------------
      INTEGER           ZI
      COMMON / IVARJE / ZI(1)
      REAL*8            ZR
      COMMON / RVARJE / ZR(1)
      COMPLEX*16        ZC
      COMMON / CVARJE / ZC(1)
      LOGICAL           ZL
      COMMON / LVARJE / ZL(1)
      CHARACTER*8       ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                       ZK24
      CHARACTER*32                                ZK32
      CHARACTER*80                                         ZK80
      COMMON / KVARJE / ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
      CHARACTER*32      JEXNUM, JEXNOM
C ----- FIN COMMUNS NORMALISES  JEVEUX  -------------------------------
C ---------------------------------------------------------------------
C
      INTEGER      N0    , NBORDR, IRET  , NOCC  , I   , NP
      INTEGER      N1    , NBCMP , IORD  , ICHAM , IBID, NC
      INTEGER      JCHA  , JORDR , NBCHAM, NBNOSY, JPA
      INTEGER      NBPARA, NBAC  , NBPA  , IFM   , NIV
      REAL*8       PREC
      CHARACTER*8  CRIT  , REPERE, K8B   , TYCH  , NOMMA , TYPE
      CHARACTER*16 CONCEP, NOMCMD, K16BID
      CHARACTER*19 KNUM  , RESUIN, RESUOU
      CHARACTER*24 NOMPAR, CHAMP1

      CALL JEMARQ()
C
C ----- RECUPERATION DU NOM DE LA COMMANDE -----
C
      CALL INFMAJ
      CALL INFNIV(IFM, NIV)
      CALL GETRES(RESUOU,CONCEP,NOMCMD)
      CALL GETVID(' ','RESULTAT',0,1,1,RESUIN,N0)
C
C ----- RECUPERATION DU NOMBRE DE CHAMPS SPECIFIER -----
C
      CALL GETFAC('MODI_CHAM',NOCC)
C
C ----- DEFINITION DU REPERE UTILISE -----
C
      CALL GETVTX('DEFI_REPERE','REPERE',1,1,1,REPERE,I)
C
C ----- RECUPERATION DES NUMEROS D'ORDRE DE LA STRUCTURE DE
C ----- DONNEES DE TYPE RESULTAT RESU A PARTIR DES VARIABLES
C ----- D'ACCES UTILISATEUR 'NUME_ORDRE','FREQ','INST','NOEUD_CMP'
C ----- (VARIABLE D'ACCES 'TOUT_ORDRE' PAR DEFAUT)
C
      KNUM = '&&OP0191.NUME_ORDRE'
      CALL GETVR8 ( ' ', 'PRECISION', 1,1,1, PREC, NP )
      CALL GETVTX ( ' ', 'CRITERE'  , 1,1,1, CRIT, NC )
      CALL RSUTNU ( RESUIN, ' ', 1, KNUM, NBORDR, PREC, CRIT, IRET )
      IF (IRET.EQ.10) THEN
         CALL UTMESS('F',NOMCMD,'LE RESULTAT '//RESUIN//
     +                ' N''EXISTE PAS')
      ENDIF
      IF (IRET.NE.0) THEN
         CALL UTMESS('F',NOMCMD,'ERREUR(S) DANS LES DONNEES')
      ENDIF
      CALL JEVEUO ( KNUM, 'L', JORDR )
C
      CALL JELIRA ( RESUIN//'.DESC', 'NOMMAX', NBNOSY, K8B )
      IF ( NBNOSY .EQ. 0 ) GOTO 9999
      NBCHAM = NOCC
C
C ----- ACCES ET PARAMETRES -----
C
      NOMPAR = '&&OP0191.NOMS_PARA'
      CALL RSNOPA ( RESUIN, 2, NOMPAR, NBAC, NBPA )
      NBPARA = NBAC + NBPA
      CALL JEVEUO ( NOMPAR, 'L', JPA )
      CALL EXTRS2 ( RESUIN, RESUOU, CONCEP, NBORDR, ZI(JORDR),
     +              NBPARA, ZK16(JPA), NBORDR, ZI(JORDR), 0,
     +              K16BID, NBNOSY )
C
      CALL WKVECT('&&CHRPEL.NOM_CHAM','V V K16',NBCHAM,JCHA)
      DO 1 IORD = 1 , NBORDR
         DO 11 ICHAM = 1 , NBCHAM
            CALL JEMARQ()
            CALL GETVTX ('MODI_CHAM','NOM_CHAM',ICHAM,1,1,
     +                   ZK16(JCHA-1+ICHAM),N0)
            CALL GETVTX ('MODI_CHAM','NOM_CMP' ,ICHAM,1,0,K8B,N1)
            NBCMP  = - N1
            CALL GETVTX ('MODI_CHAM','TYPE_CHAM',ICHAM,1,1,TYPE,N0)
            CALL RSEXCH( RESUOU, ZK16(JCHA-1+ICHAM), ZI(JORDR-1+IORD),
     +                   CHAMP1, IRET)
            CALL DISMOI( 'F', 'NOM_MAILLA', CHAMP1(1:19), 'CHAMP',
     +                   IBID, NOMMA, IRET)
            CALL DISMOI( 'A', 'TYPE_CHAMP', CHAMP1, 'CHAMP', IBID,
     +                   TYCH, IRET)
C
C ----- RECUPERATION DE LA NATURE DES CHAMPS
C ----- (CHAM_NO OU CHAM_ELEM)
C
            IF (TYCH(1:4).EQ.'NOEU') THEN
               CALL CHRPNO( CHAMP1, REPERE, NBCMP, ICHAM, TYPE)
            ELSE IF (TYCH(1:2).EQ.'EL') THEN
               CALL CHRPEL( CHAMP1, REPERE, NBCMP, ICHAM, TYPE)
            ELSE
               CALL UTMESS('A','OP0191','ON NE SAIT PAS IMPRIMER'//
     +                     ' LE CHAMP DE TYPE: '//TYCH//' CHAMP : '
     +                     //RESUIN)
            ENDIF
            CALL JEDEMA()
 11      CONTINUE
 1    CONTINUE
      IF(NIV.EQ.2) CALL RSINFO(RESUOU,IFM)
C
      CALL JEDETR(KNUM)
      CALL JEDETR(NOMPAR)
      CALL JEDETR('&&CHRPEL.NOM_CHAM')
 9999 CONTINUE
      CALL JEDEMA( )
C
      END
