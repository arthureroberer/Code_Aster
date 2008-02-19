      SUBROUTINE TE0379 ( OPTION , NOMTE )
      IMPLICIT NONE
      CHARACTER*16        OPTION  , NOMTE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 19/02/2008   AUTEUR MEUNIER S.MEUNIER 
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
C ......................................................................
C    - FONCTION REALISEE: EXTENSION DU CHAM_ELEM ERREUR AUX NOEUDS
C                         OPTION : 'ERRE_ELNO_ELEM'
C             (POUR PERMETTRE D'UTILISER POST_RELEVE_T)
C
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE
C ......................................................................
C
C ---------- DEBUT DECLARATIONS NORMALISEES JEVEUX --------------------
C
      INTEGER           ZI
      COMMON / IVARJE / ZI(1)
      REAL*8            ZR
      COMMON / RVARJE / ZR(1)
      COMPLEX*16        ZC
      COMMON / CVARJE / ZC(1)
      LOGICAL           ZL
      COMMON / LVARJE / ZL(1)
      CHARACTER*8       ZK8
      CHARACTER*16               ZK16
      CHARACTER*24                         ZK24
      CHARACTER*32                                   ZK32
      CHARACTER*80                                             ZK80
      COMMON / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C --------- FIN DECLARATIONS NORMALISEES JEVEUX ----------------------
C
      INTEGER    NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO,NBCMP
      INTEGER    I,J,ITAB(3),IERR,IERRN,IRET
C
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)
C
      CALL TECACH ('OOO','PERREUR',3,ITAB,IRET)
      CALL JEVECH('PERRENO','E',IERRN)
      IERR=ITAB(1)
      NBCMP=ITAB(2)
C
      DO 10 I = 1 , NNO
        DO 20 J = 1 , NBCMP
          ZR(IERRN+NBCMP*(I-1)+J-1) = ZR(IERR-1+J)
   20   CONTINUE
   10 CONTINUE
C
      END
