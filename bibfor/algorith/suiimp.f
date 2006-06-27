      SUBROUTINE SUIIMP(SUIVCO,ISUIV,ZTIT,
     &                  TITRE)
     
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 27/06/2006   AUTEUR CIBHHPD L.SALMONA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE MABBAS M.ABBAS

      IMPLICIT     NONE
      CHARACTER*24 SUIVCO
      INTEGER      ISUIV
      INTEGER      ZTIT
      CHARACTER*16 TITRE(3)    
C
C ----------------------------------------------------------------------
C ROUTINE APPELEE PAR : IMPREF
C ----------------------------------------------------------------------
C
C PREPARE LE TITRE POUR LA COLONNE D'AFFICHAGE EN MODE SUIVI
C
C IN  SUIVCO : NOM DE LA SD CONTENANT INFOS DE SUIVIS DDL
C IN  ISUIV  : NUMERO DU SUIVI 
C IN  ZTIT   : NOMBRE DE LIGNES DU TITRE 
C OUT TITRE  : TITRE
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
      INTEGER      NBSUIV
      CHARACTER*16 CHAM
      INTEGER      JCHAM,JCOMP,JNUCM,JNOEU,JMAIL,JPOIN,JSUINB,JEXTR
      INTEGER      SUBTOP
      CHARACTER*8  CMP,TOPO
      CHARACTER*2  SUBTOZ      
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
      CALL JEVEUO(SUIVCO(1:14)//'NBSUIV'   ,'L',JSUINB)
      NBSUIV = ZI(JSUINB)
      
      IF (NBSUIV.EQ.0) THEN 
        CALL UTMESS('F','SUIIMP','PAS DE SUIVI ATTACHE A LA DEMANDE'//
     &              ' D AFFICHAGE')
      ENDIF 
C
      IF (ZTIT.NE.3) THEN 
        CALL UTMESS('F','SUIIMP','TROP DE LIGNES DANS LE TITRE')
      ENDIF      
C           
      CALL JEVEUO(SUIVCO(1:14)//'NOM_CHAM' ,'L',JCHAM)
      CALL JEVEUO(SUIVCO(1:14)//'NOM_CMP ' ,'L',JCOMP)
      CALL JEVEUO(SUIVCO(1:14)//'NUME_CMP' ,'L',JNUCM)
      CALL JEVEUO(SUIVCO(1:14)//'NOEUD'    ,'L',JNOEU)
      CALL JEVEUO(SUIVCO(1:14)//'MAILLE'   ,'L',JMAIL)
      CALL JEVEUO(SUIVCO(1:14)//'POINT'    ,'L',JPOIN)
      CALL JEVEUO(SUIVCO(1:14)//'EXTREMA'  ,'L',JEXTR)
C
C --- CHAMP
C
      CHAM   = ZK16(JCHAM-1+ISUIV)
C
C --- COMPOSANTE
C
      CMP    = ZK8(JCOMP-1+ISUIV)
C
C --- TOPOLOGIE
C        
      IF (ZI(JEXTR-1+ISUIV).EQ.0) THEN
        IF ((CHAM(1:9) .EQ. 'SIEF_ELGA' ).OR.
     &      (CHAM(1:9) .EQ. 'VARI_ELGA' )) THEN
          TOPO   = ZK8(JMAIL-1+ISUIV)
          SUBTOP = ZI(JPOIN-1+ISUIV)     
        ELSE

          TOPO   = ZK8(JNOEU-1+ISUIV)
          SUBTOP = 0            
        ENDIF
      ENDIF
C
C --- TITRE
C
      TITRE(1)       = CHAM
      TITRE(2)(1:4)  = '    ' 
      TITRE(2)(5:12) = CMP
      TITRE(2)(13:15)  = '   ' 
              
      IF (ZI(JEXTR-1+ISUIV).EQ.0) THEN
        IF (SUBTOP.EQ.0) THEN
          TITRE(3)(1:4)   = '    ' 
          TITRE(3)(5:12)  = TOPO
        ELSE
          WRITE (SUBTOZ,'(I2)') SUBTOP
          TITRE(3)(1:8)   = TOPO 
          TITRE(3)(9:11)  = ' - '
          TITRE(3)(12:13) = SUBTOZ              
        ENDIF
      ELSE IF (ZI(JEXTR-1+ISUIV).EQ.1) THEN
          TITRE(3)(1:2)   = '    ' 
          TITRE(3)(3:12)  = 'VALEUR MIN'
          TITRE(3)(13:15) = '   ' 
      ELSE IF (ZI(JEXTR-1+ISUIV).EQ.2) THEN
          TITRE(3)(1:2)   = '    ' 
          TITRE(3)(3:12)  = 'VALEUR MAX'
          TITRE(3)(13:15) = '   ' 
      ELSE
          CALL UTMESS ('F','SUIIMP','ERREUR DVT DANS LE TYPE D EXTREMA')
      ENDIF
C
 999  CONTINUE
      CALL JEDEMA()
C
      END
