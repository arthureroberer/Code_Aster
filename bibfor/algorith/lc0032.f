      SUBROUTINE LC0032(FAMI,KPG,KSP,NDIM,IMATE,COMPOR,CRIT,INSTAM,
     &             INSTAP,EPSM,DEPS,SIGM,VIM,OPTION,ANGMAS,SIGP,VIP,
     &    TM,TP,TREF,TAMPON,TYPMOD,ICOMP,NVI,DSIDEP,CODRET)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C TOLE CRP_21
C MODIF ALGORITH  DATE 14/12/2009   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT NONE
      INTEGER         IMATE,NDIM,KPG,KSP,CODRET,ICOMP,NVI,N
      REAL*8          CRIT(12),ANGMAS(3),INSTAM,INSTAP,TAMPON(*)
      REAL*8          EPSM(6),DEPS(6),SIGM(6),SIGP(6),VIM(*),VIP(*)
      REAL*8          DSIDEP(6,6),TM,TP,TREF
      CHARACTER*16    COMPOR(16),OPTION
      CHARACTER*8     TYPMOD(*)
      CHARACTER*(*)   FAMI
      
C     Lois de comportement int�gr�es en IMPLICITE et en RUNGE_KUTTA
C     rappel (voir nmdorc) : CRIT(6) = 0 : IMPLICITE
C                                      1 : RK_2
C                                      2 : RK_4
C                                      3: IMPLICITE + RECHERCHE LINEAIRE

      N = INT(CRIT(6))

      IF (N.EQ.0.OR.N.EQ.3) THEN
      
        CALL PLASTI(FAMI,KPG,KSP,TYPMOD,IMATE,COMPOR,CRIT,INSTAM,INSTAP,
     &              TM,TP,TREF,EPSM,DEPS,SIGM,VIM,OPTION,ANGMAS,
     &              SIGP,VIP,DSIDEP,ICOMP,NVI,TAMPON,CODRET)

      ELSEIF (N.EQ.1.OR.N.EQ.2) THEN

         CALL NMVPRK(FAMI,KPG,KSP,NDIM,TYPMOD,IMATE,COMPOR,CRIT,INSTAM,
     &               INSTAP,EPSM,DEPS,SIGM,VIM,OPTION,ANGMAS,SIGP,VIP,
     &               DSIDEP)

      ENDIF
      
      END
