        SUBROUTINE LCMMFL( TAUS,COEFT,IFA,NMAT,NBCOMM,NECOUL,RP,
     &                     NUMS,VIS,NVI,VINI,DT,DTIME,DGAMMA,DP,TPERD )
        IMPLICIT NONE
        INTEGER IFA,NMAT,NBCOMM(NMAT,3),NVI,NUMS
        REAL*8 TAUS,COEFT(NMAT),VIS(3),DGAMMA,DP,DT,DTIME,TAUMU,TAUV
        REAL*8 VINI(NVI),RP
        CHARACTER*16 NECOUL
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/06/2004   AUTEUR JMBHH01 J.M.PROIX 
C RESPONSABLE JMBHH01 J.M.PROIX
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
C  COMPORTEMENT MONOCRISTALLIN : ECOULEMENT (VISCO)PLASTIQUE
C  INTEGRATION DES LOIS MONOCRISTALLINES 
C       IN  TAUS    :  SCISSION REDUITE
C           COEFT   :  PARAMETRES MATERIAU
C           IFA     :  NUMERO DE FAMILLE
C           NMAT    :  NOMBRE MAXI DE MATERIAUX
C           NBCOMM  :  NOMBRE DE COEF MATERIAU PAR FAMILLE
C           NECOUL  :  NOM DE LA LOI D'ECOULEMENT
C           RP      :  R(P) FONCTION D'ECROUISSAGE ISTROPE
C           NUMS    :  NUMERO DU SYSTEME DE GLISSEMET EN COURS
C           VIS : VARIABLES INTERNES DU SYSTEME DE GLISSEMENT COURANT
C           NVI     :  NOMBRE DE VARIABLES INTERNES 
C           VINI    :  TOUTES lES VARIABLES INTERNES
C           DT      :  INTERVALLE DE TEMPS EVENTULLEMENT REDECOUPE
C           DTIME   :  INTERVALLE DE TEMPS INITIAL
C           TPERD   :  TEMPERATURE
C     OUT:
C           DGAMMA    :  DERIVEES DES VARIABLES INTERNES A T
C           DP
C ======================================================================

C     ----------------------------------------------------------------
      REAL*8 C,P,R0,Q,H,B,K,N,FTAU,CRIT,B1,B2,Q1,Q2,A,GAMMA0,V,D
      REAL*8 TPERD,TABS,PR,DRDP,DDVIR(NVI),DRDPR
      INTEGER IFL,IEI,TNS,NS,IS
C     ----------------------------------------------------------------

C     DANS VIS : 1 = ALPHA, 2=GAMMA, 3=P

      IFL=NBCOMM(IFA,1)

C-------------------------------------------------------------
C     POUR UN NOUVEAU TYPE D'ECOULEMENT, AJOUTER UN BLOC IF
C------------------------------------------------------------
     
      IF (NECOUL.EQ.'ECOU_VISC1') THEN
          N=COEFT(IFL-1+1)
          K=COEFT(IFL-1+2)
          C=COEFT(IFL-1+3)
      
          FTAU=TAUS-C*VIS(1)
          
          CRIT=ABS(FTAU)-RP 
          IF (CRIT.GT.0.D0) THEN
             DP=((CRIT/K)**N)*DT
             DGAMMA=DP*FTAU/ABS(FTAU)
          ELSE
             DP=0.D0
             DGAMMA=0.D0
          ENDIF
       ENDIF
      IF (NECOUL.EQ.'ECOU_VISC2') THEN
          N=COEFT(IFL-1+1)
          K=COEFT(IFL-1+2)
          C=COEFT(IFL-1+3)
          A=COEFT(IFL-1+4)
          D=COEFT(IFL-1+5)
          
          FTAU=TAUS-C*VIS(1)-A*VIS(2)
          
          CRIT=ABS(FTAU)-RP + (C/2/D)*(C*VIS(1))**2
          IF (CRIT.GT.0.D0) THEN
             DP=((CRIT/K)**N)*DT
             DGAMMA=DP*FTAU/ABS(FTAU)
          ELSE
             DP=0.D0
             DGAMMA=0.D0
          ENDIF
       ENDIF
      IF (NECOUL.EQ.'ECOU_VISC3') THEN
          K      =COEFT(IFL-1+1)
          TAUMU  =COEFT(IFL-1+2)
          GAMMA0 =COEFT(IFL-1+3)
          V      =COEFT(IFL-1+4)
                
          TAUV=ABS(TAUS)-TAUMU 
          IF (TAUV.GT.0.D0) THEN
             DP=TAUV*V
             TABS=TPERD+273.5D0
             DGAMMA=2*GAMMA0*SINH(TAUV*V/K/TABS)*TAUS/ABS(TAUS)
          ELSE
             DP=0.D0
             DGAMMA=0.D0
          ENDIF
       ENDIF
       
      IF (NECOUL.EQ.'ECOU_PLAS1') THEN
          C=COEFT(IFL-1+1)
          FTAU=TAUS-C*VIS(1)
          CRIT=ABS(FTAU)-RP 
      
          IF (CRIT.GT.0.D0) THEN
C             DP=(TAUS-C*DALPHA)*TAUS/ABS(TAUS)/DRDP
             CALL UTMESS('F','LCMMFL','ECOU_PLAS1 NON DISPONIBLE')
          ELSE
             DP=0.D0
             DGAMMA=0.D0
          ENDIF
       ENDIF  
           
      END
