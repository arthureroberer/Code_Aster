      SUBROUTINE DINON2(NEQ,UL,DUL,UTL,NNO,
     &                  NBCOMP,VARIMO,RAIDE,NBPAR,PARAM,
     &                  VARIPL,DT)
C ----------------------------------------------------------------------
      IMPLICIT NONE
      INTEGER  NEQ,NBCOMP,NNO,NBPAR
      REAL*8   UL(NEQ),DUL(NEQ),UTL(NEQ),DT
      REAL*8   VARIMO(NBCOMP),VARIPL(NBCOMP)
      REAL*8   RAIDE(NBCOMP),PARAM(6,NBPAR)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 18/12/2006   AUTEUR VOLDOIRE F.VOLDOIRE 
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

C ======================================================================
C
C     RELATION DE COMPORTEMENT "VISQUEUX" (DISCRET NON LINEAIRE).
C
C     F = C.|V|^a
C        V    : vitesse
C        C, a : caracteristiques de l'amortisseur
C
C ======================================================================
C
C IN  :
C       NEQ    : NOMBRE DE DDL DE L'ELEMENT
C       UL     : DEPLACEMENT PRECEDENT REPERE LOCAL (DIM NEQ)
C       DUL    : INCREMENT DE DEPLACEMENT REPERE LOCAL (DIM NEQ)
C       UTL    : DEPLACEMENT COURANT REPERE LOCAL (DIM NEQ)
C       NNO    : NOMBRE DE NOEUDS
C       NBCOMP : NOMBRE DE COMPOSANTES
C       VARIMO : VARIABLES INTERNES A T- (2 PAR COMPOSANTES)
C       RAIDE  : RAIDEUR ELASTIQUE DES DISCRETS
C       NBPAR  : NOMBRE MAXIMAL DE PARAMETRE DE LA LOI
C       PARAM  : PARAMETRES DE LA LOI
C       DT     : INCREMENT DE TEMPS
C
C OUT :
C       RAIDE  : RAIDEUR QUASI-TANGENTE AU COMPORTEMENT DES DISCRETS
C       VARIPL : VARIABLES INTERNES INTERNES A T+ (1 PAR COMPOSANTE)
C
C***************** DECLARATION DES VARIABLES LOCALES *******************
C
      INTEGER II,IENER,IFORC
      REAL*8  R8MIEM,ULEL,DULEL,UTLEL,ZERO,R8MIN

      REAL*8  VITESS,FPLUS,FMOIN,PUISS,KR
C
C************ FIN DES DECLARATIONS DES VARIABLES LOCALES ***************

C ----------------------------------------------------------------------
      R8MIN  = R8MIEM()
      ZERO   = 0.0D0

      IF ( DT .LT. R8MIN ) THEN
         CALL U2MESR('F','DISCRETS_4',1,DT)
      ENDIF

      DO 20, II=1,NBCOMP
C        INDEX DES VARIABLES INTERNES
         IFORC = 2*(II-1)+1
         IENER = 2*(II-1)+2
C        PAR DEFAUT LES VARIABLES N'EVOLUENT PAS
         VARIPL(IFORC) = VARIMO(IFORC)
         VARIPL(IENER) = VARIMO(IENER)
C        SI LE COMPORTEMENT EST VISQUEUX
         PUISS = PARAM(II,1)
         IF ( PUISS .GT. R8MIN ) THEN
            IF ( NNO .EQ. 1 ) THEN
               DULEL = DUL(II)
C               ULEL  = UL(II)
C               UTLEL = UTL(II)
            ELSE
               DULEL = DUL(II+NBCOMP) - DUL(II)
C               ULEL  = UL(II+NBCOMP)  - UL(II)
C               UTLEL = UTL(II+NBCOMP) - UTL(II)
            ENDIF
            KR = PARAM(II,2)
C           CALCUL DE LA FORCE A T+
            VITESS = ABS(DULEL/DT)
            IF ( VITESS .GT. R8MIN ) THEN
               IF ( DULEL .GT. ZERO ) THEN
                  FPLUS =  KR*((VITESS)**PUISS)
               ELSE
                  FPLUS = -KR*((VITESS)**PUISS)
               ENDIF
            ELSE
               FPLUS = ZERO
            ENDIF
C           RECUPERATION DE LA FORCE A T-
            FMOIN  = VARIMO(IFORC)
C           ACTUALISATION DE LA VARIABLE INTERNE
            VARIPL(IFORC) = FPLUS
C           RAIDEUR QUASI-TANGENTE AU COMPORTEMENT
            IF ( ABS(DULEL) .GT. R8MIN ) THEN
               RAIDE(II)  = ABS((FPLUS - FMOIN))/DULEL
            ENDIF
C           CALCUL DE L'ENERGIE DISSIPEE
            VARIPL(IENER) = VARIMO(IENER) + FPLUS*DULEL
         ENDIF
20    CONTINUE

      END
