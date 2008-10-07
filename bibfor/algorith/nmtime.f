      SUBROUTINE NMTIME(PHASEZ,TIMEZ ,SDTIME,VALL  ,VALR  )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 07/10/2008   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
      IMPLICIT NONE
      CHARACTER*(*) PHASEZ
      CHARACTER*(*) TIMEZ
      CHARACTER*24  SDTIME
      LOGICAL       VALL
      REAL*8        VALR
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (UTILITAIRE)
C
C GESTION DES TIMERS
C      
C ----------------------------------------------------------------------
C
C
C IN  PHASE  : TYPE D'ACTION
C                'INIT'  INITIALISATION DU TIMER
C                'DEBUT' LANCEMENT DU TIMER
C                'FIN'   ARRET DU TIMER
C                'MES'   CALCUL DES CRITERES D'ARRET SUR TEMPS
C                'VAL'   RECUPERE VALEUR DU TEMPS
C                'IFR'   RECUPERE VALEUR REELLE SUR STAT
C                'IFI'   RECUPERE VALEUR ENTIERE SUR STAT
C                'STAT'  SAUVEGARDE DES VALEURS POUR STATS CUMULEES
C                        SUR LE PAS DE TEMPS
C IN  TIMER  : NOM DU TIMER
C                'PAS'   TIMER POUR UN PAS DE TEMPS
C                'ITE'   TIMER POUR UNE ITERATION DE NEWTON
C                'ARC'   TIMER POUR L'ARCHIVAGE
C                'RES'   TIMER POUR JOB TOTAL
C OUT VALL   : RESULTAT DE L'ACTION MES
C OUT VALR   : RESULTAT DE L'ACTION VAL
C IN  SDTIME : SD TIMER
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
      INTEGER      ITPAS,ITITE,ITARC,ITTMP
      PARAMETER    (ITPAS=1,ITITE=2,ITARC=3,ITTMP=4)
C
      CHARACTER*24 TIMPAS,TIMITE,TIMARC,TIMVAL,TIMTMP,TIMDEB
      INTEGER      JTPAS,JTITE,JTARC,JTVAL,JTTMP,JTDEB     

      CHARACTER*24 TIMINR,TIMINI
      INTEGER      JTINFR,JTINFI                   
      CHARACTER*3  TIMER 
      CHARACTER*16 PHASE
      INTEGER      INBR
      INTEGER      IFM,NIV 
C      
C ----------------------------------------------------------------------
C      
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C    
C --- INITIALISATIONS
C              
      TIMER  = TIMEZ  
      PHASE  = PHASEZ   
C
C --- ACCES SD TIMER
C
      TIMTMP = SDTIME(1:19)//'.TEMP'
      TIMPAS = SDTIME(1:19)//'.TPAS'
      TIMITE = SDTIME(1:19)//'.TITE'
      TIMARC = SDTIME(1:19)//'.TARC'
      TIMVAL = SDTIME(1:19)//'.TVAL'
      TIMDEB = SDTIME(1:19)//'.TDEB' 
      TIMINR = SDTIME(1:19)//'.TINR'       
      TIMINI = SDTIME(1:19)//'.TINI'        
 
      CALL JEVEUO(TIMPAS,'E',JTPAS)
      CALL JEVEUO(TIMITE,'E',JTITE)
      CALL JEVEUO(TIMARC,'E',JTARC)
      CALL JEVEUO(TIMVAL,'E',JTVAL)  
      CALL JEVEUO(TIMDEB,'E',JTDEB)        
      CALL JEVEUO(TIMTMP,'E',JTTMP)         
      CALL JEVEUO(TIMINR,'E',JTINFR)        
      CALL JEVEUO(TIMINI,'E',JTINFI)                   
C            
      IF (PHASE.EQ.'INIT') THEN
        IF (TIMER.EQ.'ALL') THEN
          CALL UTTCPU(ITPAS,'INIT',4,ZR(JTPAS))
          ZR(JTDEB+1-1) = ZR(JTPAS+3-1)
          CALL UTTCPU(ITITE,'INIT',4,ZR(JTITE))
          ZR(JTDEB+2-1) = ZR(JTITE+3-1)
          CALL UTTCPU(ITARC,'INIT',4,ZR(JTARC))  
          ZR(JTDEB+3-1) = ZR(JTARC+3-1)            
        ELSEIF (TIMER.EQ.'PAS') THEN
          CALL UTTCPU(ITPAS,'INIT',4,ZR(JTPAS))
          ZR(JTDEB+1-1) = ZR(JTPAS+3-1)    
        ELSEIF (TIMER.EQ.'ITE') THEN
          CALL UTTCPU(ITITE,'INIT',4,ZR(JTITE))
          ZR(JTDEB+2-1) = ZR(JTITE+3-1)
        ELSEIF (TIMER.EQ.'ARC') THEN
          CALL UTTCPU(ITARC,'INIT',4,ZR(JTARC))
          ZR(JTDEB+3-1) = ZR(JTARC+3-1) 
        ELSEIF (TIMER.EQ.'TMP') THEN
          CALL UTTCPU(ITTMP,'INIT',4,ZR(JTTMP))
          ZR(JTDEB+4-1) = ZR(JTTMP+3-1)
        ELSEIF (TIMER.EQ.'STA') THEN
          DO 10 INBR = 1,10
            ZI(JTINFI+INBR-1) = 0
  10      CONTINUE
          ZI(JTINFI+22-1) = 0 
          DO 11 INBR = 1,6
            ZR(JTINFR+INBR-1) = 0.D0
  11      CONTINUE
          ZR(JTINFR+13-1) = 0.D0                      
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF   
      ELSEIF (PHASE.EQ.'DEBUT') THEN
        IF (TIMER.EQ.'PAS') THEN
          CALL UTTCPU(ITPAS,'DEBUT',4,ZR(JTPAS)) 
        ELSEIF (TIMER.EQ.'ITE') THEN
          CALL UTTCPU(ITITE,'DEBUT',4,ZR(JTITE))
        ELSEIF (TIMER.EQ.'ARC') THEN
          CALL UTTCPU(ITARC,'DEBUT',4,ZR(JTARC))
        ELSEIF (TIMER.EQ.'TMP') THEN
          CALL UTTCPU(ITTMP,'DEBUT',4,ZR(JTTMP))                    
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF             
      ELSEIF (PHASE.EQ.'FIN') THEN
        IF (TIMER.EQ.'PAS') THEN
          CALL UTTCPU(ITPAS,'FIN',4,ZR(JTPAS))
          VALR = ZR(JTPAS+3-1) - ZR(JTDEB+1-1)
          ZR(JTVAL+1-1) = VALR
          ZR(JTDEB+1-1) = ZR(JTPAS+3-1)
        ELSEIF (TIMER.EQ.'ITE') THEN
          CALL UTTCPU(ITITE,'FIN',4,ZR(JTITE))
          VALR = ZR(JTITE+3-1) - ZR(JTDEB+2-1)
          ZR(JTVAL+2-1) = VALR
          ZR(JTDEB+2-1) = ZR(JTITE+3-1)
          ZI(JTINFI+5-1) = ZI(JTINFI+5-1)+1
        ELSEIF (TIMER.EQ.'ARC') THEN
          CALL UTTCPU(ITARC,'FIN',4,ZR(JTARC))
          VALR = ZR(JTARC+3-1) - ZR(JTDEB+3-1)
          ZR(JTVAL+3-1) = VALR
          ZR(JTDEB+3-1) = ZR(JTARC+3-1)
        ELSEIF (TIMER.EQ.'TMP') THEN
          CALL UTTCPU(ITTMP,'FIN',4,ZR(JTTMP))
          VALR = ZR(JTTMP+3-1) - ZR(JTDEB+4-1) 
          ZR(JTVAL+4-1) = VALR
          ZR(JTDEB+4-1) = ZR(JTTMP+3-1)                          
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF     
      ELSEIF (PHASE.EQ.'MES') THEN  
        IF (TIMER.EQ.'ITE') THEN
          IF ((2.D0*ZR(JTITE+4-1)).LE.
     &         (0.95D0*ZR(JTITE+1-1)-ZR(JTARC+4-1))) THEN
            VALL = .FALSE.
          ELSE
            VALL = .TRUE.
          ENDIF
        ELSEIF (TIMER.EQ.'PAS') THEN
          IF (ZR(JTPAS+4-1) .GT. 0.90D0*ZR(JTPAS+1-1)) THEN
            VALL = .TRUE.
          ELSE
            VALL = .FALSE.
          ENDIF
        ELSE
          CALL ASSERT(.FALSE.)  
        ENDIF     
      ELSEIF (PHASE.EQ.'VAL') THEN
        IF (TIMER.EQ.'PAS') THEN
          VALR = ZR(JTVAL+1-1)      
        ELSEIF (TIMER.EQ.'ITE') THEN
          VALR = ZR(JTVAL+2-1) 
        ELSEIF (TIMER.EQ.'ARC') THEN
          VALR = ZR(JTVAL+3-1)
        ELSEIF (TIMER.EQ.'TMP') THEN
          VALR = ZR(JTVAL+4-1)                        
        ELSEIF (TIMER.EQ.'RES') THEN
          VALR = ZR(JTITE+1-1)          
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
      ELSEIF (PHASE.EQ.'IFI') THEN
        IF (TIMER.EQ.'FCS') THEN
          VALR = ZI(JTINFI+1-1)      
        ELSEIF (TIMER.EQ.'FCN') THEN
          VALR = ZI(JTINFI+2-1) 
        ELSEIF (TIMER.EQ.'INT') THEN
          VALR = ZI(JTINFI+3-1)
        ELSEIF (TIMER.EQ.'RES') THEN
          VALR = ZI(JTINFI+4-1)                       
        ELSEIF (TIMER.EQ.'ITE') THEN
          VALR = ZI(JTINFI+5-1)
        ELSEIF (TIMER.EQ.'REL') THEN
          VALR = ZI(JTINFI+6-1)
        ELSEIF (TIMER.EQ.'FET') THEN
          VALR = ZI(JTINFI+7-1) 
        ELSEIF (TIMER.EQ.'CTG') THEN
          VALR = ZI(JTINFI+8-1) 
        ELSEIF (TIMER.EQ.'CTA') THEN
          VALR = ZI(JTINFI+9-1)  
        ELSEIF (TIMER.EQ.'CTF') THEN
          VALR = ZI(JTINFI+10-1)                  

        ELSEIF (TIMER.EQ.'CU1') THEN
          VALR = ZI(JTINFI+11-1) 
        ELSEIF (TIMER.EQ.'CU2') THEN
          VALR = ZI(JTINFI+12-1)           
        ELSEIF (TIMER.EQ.'CU3') THEN
          VALR = ZI(JTINFI+13-1) 
        ELSEIF (TIMER.EQ.'CU4') THEN
          VALR = ZI(JTINFI+14-1) 
        ELSEIF (TIMER.EQ.'CU5') THEN
          VALR = ZI(JTINFI+15-1)           
        ELSEIF (TIMER.EQ.'CU6') THEN
          VALR = ZI(JTINFI+16-1) 
        ELSEIF (TIMER.EQ.'CU7') THEN
          VALR = ZI(JTINFI+17-1) 
        ELSEIF (TIMER.EQ.'CU8') THEN
          VALR = ZI(JTINFI+18-1)           
        ELSEIF (TIMER.EQ.'CU9') THEN
          VALR = ZI(JTINFI+19-1)                     
        ELSEIF (TIMER.EQ.'C10') THEN
          VALR = ZI(JTINFI+20-1)
          
        ELSEIF (TIMER.EQ.'C11') THEN
          VALR = ZI(JTINFI+21-1) - 1         
                              
                                       
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF   
      ELSEIF (PHASE.EQ.'IFR') THEN
        IF (TIMER.EQ.'FCS') THEN
          VALR = ZR(JTINFR+1-1)      
        ELSEIF (TIMER.EQ.'FCN') THEN
          VALR = ZR(JTINFR+2-1) 
        ELSEIF (TIMER.EQ.'INT') THEN
          VALR = ZR(JTINFR+3-1)
        ELSEIF (TIMER.EQ.'RES') THEN
          VALR = ZR(JTINFR+4-1)
        ELSEIF (TIMER.EQ.'CTG') THEN
          VALR = ZR(JTINFR+5-1)
        ELSEIF (TIMER.EQ.'CTA') THEN
          VALR = ZR(JTINFR+6-1)
          
        ELSEIF (TIMER.EQ.'CU1') THEN
          VALR = ZR(JTINFR+7-1) 
        ELSEIF (TIMER.EQ.'CU2') THEN
          VALR = ZR(JTINFR+8-1)           
        ELSEIF (TIMER.EQ.'CU3') THEN
          VALR = ZR(JTINFR+9-1) 
        ELSEIF (TIMER.EQ.'CU4') THEN
          VALR = ZR(JTINFR+10-1) 
        ELSEIF (TIMER.EQ.'CU5') THEN
          VALR = ZR(JTINFR+11-1)           
        ELSEIF (TIMER.EQ.'CU6') THEN
          VALR = ZR(JTINFR+12-1)          
          
                                 
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF         
      ELSEIF (PHASE.EQ.'SFR') THEN
        IF (TIMER.EQ.'CTG') THEN
          ZR(JTINFR+5-1) = VALR     
        ELSEIF (TIMER.EQ.'CTA') THEN
          ZR(JTINFR+6-1) = VALR                        
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF  

      ELSEIF (PHASE.EQ.'SFI') THEN
        IF (TIMER.EQ.'CTG') THEN
          ZI(JTINFI+8-1) = NINT(VALR)     
        ELSEIF (TIMER.EQ.'CTA') THEN
          ZI(JTINFI+9-1) = NINT(VALR) 
        ELSEIF (TIMER.EQ.'CTF') THEN
          ZI(JTINFI+10-1) = NINT(VALR)                       
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF         
        
                 
      ELSEIF (PHASE.EQ.'FACT_SYMB') THEN
        IF (TIMER.EQ.'TMP') THEN
          ZR(JTINFR+1-1) = ZR(JTINFR+1-1)+ZR(JTVAL+4-1)  
          ZI(JTINFI+1-1) = ZI(JTINFI+1-1)+1
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF   
      ELSEIF (PHASE.EQ.'FACT_NUME') THEN
        IF (TIMER.EQ.'TMP') THEN
          ZR(JTINFR+2-1) = ZR(JTINFR+2-1)+ZR(JTVAL+4-1) 
          ZI(JTINFI+2-1) = ZI(JTINFI+2-1)+1
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF  
      ELSEIF (PHASE.EQ.'INTE_COMP') THEN
        IF (TIMER.EQ.'TMP') THEN
          ZR(JTINFR+3-1) = ZR(JTINFR+3-1)+ZR(JTVAL+4-1) 
          ZI(JTINFI+3-1) = ZI(JTINFI+3-1)+1
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF 
      ELSEIF (PHASE.EQ.'RESOL') THEN
        IF (TIMER.EQ.'TMP') THEN
          ZR(JTINFR+4-1) = ZR(JTINFR+4-1)+ZR(JTVAL+4-1) 
          ZI(JTINFI+4-1) = ZI(JTINFI+4-1)+1
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF 
      ELSEIF (PHASE.EQ.'RECH_LINE') THEN
        ZI(JTINFI+6-1) = ZI(JTINFI+6-1) + INT(VALR)
      ELSEIF (PHASE.EQ.'ITER_FETI') THEN
        ZI(JTINFI+7-1) = ZI(JTINFI+7-1) + INT(VALR)  

      ELSEIF (PHASE.EQ.'SECO_MEMB') THEN
        IF (TIMER.EQ.'TMP') THEN
          ZR(JTINFR+13-1) = ZR(JTINFR+13-1)+ZR(JTVAL+4-1) 
          ZI(JTINFI+22-1) = ZI(JTINFI+22-1)+1
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF        
        
      ELSEIF (PHASE.EQ.'STAT') THEN   
        ZI(JTINFI+11-1) = ZI(JTINFI+11-1) + ZI(JTINFI+1-1)
        ZI(JTINFI+12-1) = ZI(JTINFI+12-1) + ZI(JTINFI+2-1)         
        ZI(JTINFI+13-1) = ZI(JTINFI+13-1) + ZI(JTINFI+3-1)
        ZI(JTINFI+14-1) = ZI(JTINFI+14-1) + ZI(JTINFI+4-1)
        ZI(JTINFI+15-1) = ZI(JTINFI+15-1) + ZI(JTINFI+5-1)
        ZI(JTINFI+16-1) = ZI(JTINFI+16-1) + ZI(JTINFI+6-1)
        ZI(JTINFI+17-1) = ZI(JTINFI+17-1) + ZI(JTINFI+7-1)
        ZI(JTINFI+18-1) = ZI(JTINFI+18-1) + ZI(JTINFI+8-1)
        ZI(JTINFI+19-1) = ZI(JTINFI+19-1) + ZI(JTINFI+9-1)       
        ZI(JTINFI+20-1) = ZI(JTINFI+20-1) + ZI(JTINFI+10-1) 
        ZI(JTINFI+21-1) = ZI(JTINFI+21-1) + 1
        
        ZR(JTINFR+7-1)  = ZR(JTINFR+7-1)  + ZR(JTINFR+1-1)
        ZR(JTINFR+8-1)  = ZR(JTINFR+8-1)  + ZR(JTINFR+2-1)
        ZR(JTINFR+9-1)  = ZR(JTINFR+9-1)  + ZR(JTINFR+3-1)
        ZR(JTINFR+10-1) = ZR(JTINFR+10-1) + ZR(JTINFR+4-1) 
        ZR(JTINFR+11-1) = ZR(JTINFR+11-1) + ZR(JTINFR+5-1)
        ZR(JTINFR+12-1) = ZR(JTINFR+12-1) + ZR(JTINFR+6-1)
                               
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
C
  999 CONTINUE      
C
      CALL JEDEMA()
      END
