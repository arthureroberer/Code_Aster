      SUBROUTINE DISCAX(NOMA,NBN,IAXE,NUNO,DIAX)
      IMPLICIT REAL*8 (A-H,O-Z)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 11/04/97   AUTEUR VABHHTS J.PELLET 
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
C-----------------------------------------------------------------------
C     CREATION D'UNE LISTE ORDONNEE DE NOEUDS SUR UNE STRUCTURE POUTRE
C     DROITE : ORDRE CROISSANT DU PARAMETRE LE LONG DE L'AXE DIRECTEUR
C     DE LA POUTRE
C     APPELANT : SPECFF
C-----------------------------------------------------------------------
C IN  : NOMA   : NOM DU CONCEPT MAILLAGE
C IN  : NBN    : NOMBRE DE NOEUDS DU MAILLAGE
C IN  : IAXE   : ENTIER DEFINISSANT L'AXE DIRECTEUR
C       IAXE = 1 L'AXE DIRECTEUR EST L'AXE DES X DU REPERE GLOBAL
C       IAXE = 2 L'AXE DIRECTEUR EST L'AXE DES Y DU REPERE GLOBAL
C       IAXE = 3 L'AXE DIRECTEUR EST L'AXE DES Z DU REPERE GLOBAL
C OUT : NUNO   : LISTE DES NUMEROS DES NOEUDS DU MAILLAGE, REORDONNEE
C                PAR VALEURS CROISSANTES DU PARAMETRE LE LONG DE L'AXE
C OUT : DIAX   : LISTE DES VALEURS DU PARAMETRE LE LONG DE L'AXE
C                ORDRE CROISSANT
C
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CHARACTER*8  NOMA
      INTEGER      NBN,IAXE,NUNO(NBN)
      REAL*8       DIAX(NBN)
C
      CHARACTER*8  NOMNOE
      CHARACTER*24 COORMA,NNOEMA
      CHARACTER*32 JEXNOM,JEXNUM
C
C-----------------------------------------------------------------------
      CALL JEMARQ()
C
C --- 1.ACCES AUX OBJETS DU CONCEPT MAILLAGE
C
      COORMA = NOMA//'.COORDO    .VALE'
      CALL JEVEUO(COORMA,'L',ICOMA)
      NNOEMA = NOMA//'.NOMNOE'
C
C --- 2.ON RECOPIE LA DISCRETISATION (NON ORDONNEE) LUE DANS L'OBJET
C ---   .COORDO    .VALE DU CONCEPT MAILLAGE
C ---   ON RECOPIE SIMULTANEMENT LA LISTE DES NOMS DES NOEUDS
C
      CALL WKVECT('&&DISCAX.TEMP.NNOE','V V K8',NBN,INNOE)
      DO 10 INO = 1,NBN
        DIAX(INO) = ZR(ICOMA+3*(INO-1)+IAXE-1)
        CALL JENUNO(JEXNUM(NNOEMA,INO),ZK8(INNOE+INO-1))
  10  CONTINUE
C
C --- 3.ON REORDONNE LA DISCRETISATION PAR VALEURS CROISSANTES
C ---   ON REORDONNE SIMULTANEMENT LA LISTE DES NOMS DES NOEUDS
C ---   ON EN DEDUIT LA LISTE ORDONNEE DES NUMEROS DES NOEUDS
C
      DO 20 INO = 1,NBN-1
        XMIN = DIAX(INO)
        NOMNOE = ZK8(INNOE+INO-1)
        IMIN = INO
        DO 21 JNO = INO+1,NBN
          IF (DIAX(JNO).LT.XMIN) THEN
            XMIN = DIAX(JNO)
            NOMNOE = ZK8(INNOE+JNO-1)
            IMIN = JNO
          ENDIF
  21    CONTINUE
        DIAX(IMIN) = DIAX(INO)
        ZK8(INNOE+IMIN-1) = ZK8(INNOE+INO-1)
        DIAX(INO) = XMIN
        ZK8(INNOE+INO-1) = NOMNOE
        CALL JENONU(JEXNOM(NNOEMA,ZK8(INNOE+INO-1)),NUNO(INO))
  20  CONTINUE
      CALL JENONU(JEXNOM(NNOEMA,ZK8(INNOE+NBN-1)),NUNO(NBN))
C
      CALL JEDETR('&&DISCAX.TEMP.NNOE')
      CALL JEDEMA()
      END
