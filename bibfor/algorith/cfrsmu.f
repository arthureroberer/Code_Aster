      SUBROUTINE CFRSMU(DEFICO,RESOCO,REAPRE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 18/10/2011   AUTEUR DESOZA T.DESOZA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
      IMPLICIT     NONE
      CHARACTER*24 DEFICO,RESOCO
      LOGICAL      REAPRE
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES DISCRETES)
C
C RESTAURATION DU LAGRANGE DE CONTACT APRES UN APPARIEMENT
C
C ----------------------------------------------------------------------
C
C IN  DEFICO : SD DE DEFINITION DU CONTACT
C IN  RESOCO : SD DE TRAITEMENT NUMERIQUE DU CONTACT
C IN  REAPRE : S'AGIT-IL DU PREMIER APPARIEMENT DU PAS DE TEMPS ?
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
      INTEGER      IFM,NIV
      LOGICAL      CFDISL
      INTEGER      CFDISD
      INTEGER      ILIAI,POSNOE
      INTEGER      NBLIAI
      CHARACTER*19 SVMU  ,MU
      INTEGER      JSVMU ,JMU
      CHARACTER*24 NUMLIA
      INTEGER      JNUMLI
      LOGICAL      LGCP
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('CONTACT',IFM,NIV)
C
C --- LE LAGRANGE DE CONTACT N'EST RESTAURE QU'EN GCP
C
      LGCP = CFDISL(DEFICO,'CONT_GCP')
C
      IF (.NOT.LGCP) THEN
        GOTO 999
      ENDIF
C
C --- ACCES OBJETS
C
      IF (REAPRE) THEN
        SVMU = RESOCO(1:14)//'.SVM0'
      ELSE
        SVMU = RESOCO(1:14)//'.SVMU'
      ENDIF
      CALL JEVEUO(SVMU,'L',JSVMU)
      MU   = RESOCO(1:14)//'.MU'
      CALL JEVEUO(MU,'E',JMU )
      NUMLIA = RESOCO(1:14)//'.NUMLIA'
      CALL JEVEUO(NUMLIA,'L',JNUMLI)
C
C --- INFORMATIONS
C
      NBLIAI = CFDISD(RESOCO,'NBLIAI')
C
C --- SAUVEGARDE DU STATUT DE FROTTEMENT
C
      DO 10 ILIAI = 1,NBLIAI
        POSNOE =  ZI(JNUMLI-1+4*(ILIAI-1)+2)
        ZR(JMU-1+ILIAI) = ZR(JSVMU-1+POSNOE)
  10  CONTINUE
C
 999  CONTINUE
C
      CALL JEDEMA()
      END
