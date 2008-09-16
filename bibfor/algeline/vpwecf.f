      SUBROUTINE VPWECF (OPTION,TYPRES,NFREQ,MXFREQ,RESUFI,RESUFR,
     +                   RESUFK,LAMOR,KTYP,LNS)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 16/09/2008   AUTEUR PELLET J.PELLET 
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
C     ECRITURE DES FREQUENCES RELATIVEMENT A LA METHODE UTILISEE
C     IMPRESSION D'OFFICE SUR "MESSAGE"
C-----------------------------------------------------------------------
      IMPLICIT   NONE

C PARAMETRES D'APPEL
      INTEGER           NFREQ, MXFREQ, RESUFI(MXFREQ,*), LAMOR
      REAL*8            RESUFR(MXFREQ,*)
      CHARACTER*(*)     OPTION, RESUFK(MXFREQ,*),TYPRES
      CHARACTER*1       KTYP
      LOGICAL           LNS

C VARIABLES LOCALES
      INTEGER      IFM,IFREQ,IRESO,ITERB,ITERJ,ITERQ,ITERA,INDF,ISNNEM,
     &             NIV,NFSUP
      REAL*8       FFF,AM,ERR,PREC,UNDF,R8VIDE,CHA,AM2,ERC,ERRMOY
      CHARACTER*27 STRAUX
C     ------------------------------------------------------------------
      CALL INFNIV(IFM,NIV)
      UNDF = R8VIDE()
      INDF = ISNNEM()
      ERRMOY = 0.D0
      IF (NFREQ.EQ.0) CALL ASSERT(.FALSE.)
      IF (RESUFK(NFREQ,2) .EQ. 'BATHE_WILSON') THEN
        IF (TYPRES .EQ. 'DYNAMIQUE') THEN
          WRITE(IFM,1000)
        ELSE
          WRITE(IFM,1001)
        ENDIF
        DO 10 IFREQ = 1, NFREQ
          IRESO = RESUFI(IFREQ,1)
          FFF   = RESUFR(IFREQ,1)
          CHA   = RESUFR(IFREQ,2)
          AM    = RESUFR(IFREQ,4)
          ITERB = RESUFI(IFREQ,3)
          ITERJ = RESUFI(IFREQ,5)
          ERRMOY = ERRMOY + ABS(AM)
          IF (TYPRES .EQ. 'DYNAMIQUE') THEN
            WRITE(IFM,1010) IRESO,FFF,AM,ITERB,ITERJ
          ELSE
            WRITE(IFM,1010) IRESO,CHA,AM,ITERB,ITERJ
          ENDIF
 10     CONTINUE
        WRITE(IFM,7776)ERRMOY/NFREQ
        WRITE(IFM,7777)

      ELSEIF ( RESUFK(NFREQ,2) .EQ. 'LANCZOS' ) THEN
        IF (LAMOR.EQ.0) THEN
          IF (TYPRES .EQ. 'DYNAMIQUE') THEN
            WRITE(IFM,2000)
          ELSE
            WRITE(IFM,2001)
          ENDIF
        ELSE
          IF (TYPRES .EQ. 'DYNAMIQUE') THEN
            WRITE(IFM,2100)
          ELSE
            WRITE(IFM,2101)
          ENDIF
        ENDIF
        DO 20 IFREQ = 1, NFREQ
          IRESO = RESUFI(IFREQ,1)
          FFF   = RESUFR(IFREQ,1)
          CHA   = RESUFR(IFREQ,2)
          IF (LAMOR.EQ.0) THEN
            AM  = RESUFR(IFREQ,4)
          ELSE
            AM  = RESUFR(IFREQ,3)
          ENDIF
          ITERQ = RESUFI(IFREQ,2)
          ERRMOY = ERRMOY + ABS(AM)
          IF (TYPRES .EQ. 'DYNAMIQUE') THEN
            WRITE(IFM,2010) IRESO,FFF,AM,ITERQ
          ELSE
            WRITE(IFM,2010) IRESO,CHA,AM,ITERQ
          ENDIF
 20     CONTINUE
        IF (LAMOR.EQ.0) WRITE(IFM,7776)ERRMOY/NFREQ
        WRITE(IFM,7777)

      ELSEIF ( RESUFK(NFREQ,2) .EQ. 'SORENSEN' ) THEN
        IF ((LAMOR.EQ.0).AND.(KTYP.EQ.'R').AND.(.NOT.LNS)) THEN
          IF (TYPRES .EQ. 'DYNAMIQUE') THEN
            WRITE(IFM,2200)
          ELSE
            WRITE(IFM,2201)
          ENDIF
        ELSE
          IF (TYPRES .EQ. 'DYNAMIQUE') THEN
            WRITE(IFM,2202)
          ELSE
            WRITE(IFM,2203)
          ENDIF
        ENDIF
        DO 35 IFREQ = 1, NFREQ
          IRESO = RESUFI(IFREQ,1)
          FFF   = RESUFR(IFREQ,1)
          CHA   = RESUFR(IFREQ,2)
          IF ((LAMOR.EQ.0).AND.(KTYP.EQ.'R').AND.(.NOT.LNS)) THEN
            AM  = RESUFR(IFREQ,4)
            ERRMOY = ERRMOY + ABS(AM)
          ELSE
            AM  = RESUFR(IFREQ,3)
            ERC = RESUFR(IFREQ,4)
            ERRMOY = ERRMOY + ABS(ERC)
          ENDIF
          IF ((LAMOR.EQ.0).AND.(KTYP.EQ.'R').AND.(.NOT.LNS)) THEN
            IF (TYPRES .EQ. 'DYNAMIQUE') THEN
              WRITE(IFM,2210) IRESO,FFF,AM
            ELSE
              WRITE(IFM,2210) IRESO,CHA,AM
            ENDIF
          ELSE
            IF (TYPRES .EQ. 'DYNAMIQUE') THEN
              WRITE(IFM,2211) IRESO,FFF,AM,ERC
            ELSE
              WRITE(IFM,2211) IRESO,CHA,AM,ERC
            ENDIF
          ENDIF
 35      CONTINUE
         WRITE(IFM,7776)ERRMOY/NFREQ
         WRITE(IFM,7777)
         
      ELSEIF ( RESUFK(NFREQ,2)(1:2) .EQ. 'QZ' ) THEN
        STRAUX='ALGORITHME '//RESUFK(NFREQ,2)(1:16)
        IF ((LAMOR.EQ.0).AND.(KTYP.EQ.'R').AND.(.NOT.LNS)) THEN
          IF (TYPRES .EQ. 'DYNAMIQUE') THEN
            WRITE(IFM,3200)STRAUX
          ELSE
            WRITE(IFM,3201)STRAUX
          ENDIF
        ELSE
          IF (TYPRES .EQ. 'DYNAMIQUE') THEN
            WRITE(IFM,3202)STRAUX
          ELSE
            WRITE(IFM,3203)STRAUX
          ENDIF
        ENDIF
        DO 36 IFREQ = 1, NFREQ
          IRESO = RESUFI(IFREQ,1)
          FFF   = RESUFR(IFREQ,1)
          CHA   = RESUFR(IFREQ,2)
          IF ((LAMOR.EQ.0).AND.(KTYP.EQ.'R').AND.(.NOT.LNS)) THEN
            AM  = RESUFR(IFREQ,4)
            ERRMOY = ERRMOY + ABS(AM)
          ELSE
            AM  = RESUFR(IFREQ,3)
            ERC = RESUFR(IFREQ,4)
            ERRMOY = ERRMOY + ABS(ERC)
          ENDIF
          IF ((LAMOR.EQ.0).AND.(KTYP.EQ.'R').AND.(.NOT.LNS)) THEN
            IF (TYPRES .EQ. 'DYNAMIQUE') THEN
              WRITE(IFM,3210) IRESO,FFF,AM
            ELSE
              WRITE(IFM,3210) IRESO,CHA,AM
            ENDIF
          ELSE
            IF (TYPRES .EQ. 'DYNAMIQUE') THEN
              WRITE(IFM,3211) IRESO,FFF,AM,ERC
            ELSE
              WRITE(IFM,3211) IRESO,CHA,AM,ERC
            ENDIF
          ENDIF
 36     CONTINUE
        WRITE(IFM,7776)ERRMOY/NFREQ
        WRITE(IFM,7777)

      ELSEIF ((RESUFK(NFREQ,2) .EQ. 'INVERSE_R'  .OR.
     +         RESUFK(NFREQ,2) .EQ. 'INVERSE_C') .AND.
     +           ( OPTION(1:6) .EQ. 'PROCHE')    ) THEN
         IF (TYPRES .EQ. 'DYNAMIQUE') THEN
           WRITE(IFM,4000)
         ELSE
           WRITE(IFM,4001)
         ENDIF
         DO 40 IFREQ = 1, NFREQ
            IRESO = RESUFI(IFREQ,1)
            FFF   = RESUFR(IFREQ,1)
            CHA   = RESUFR(IFREQ,2)
            AM    = RESUFR(IFREQ,3)
            ITERQ = RESUFI(IFREQ,4)
            ERR   = RESUFR(IFREQ,15)
            AM2   = RESUFR(IFREQ,4)
            IF (TYPRES .EQ. 'DYNAMIQUE') THEN
              WRITE(IFM,4010) IRESO,FFF,AM,ITERQ,ERR,AM2
            ELSE
              WRITE(IFM,4010) IRESO,CHA,AM,ITERQ,ERR,AM2
            ENDIF
            RESUFR(IFREQ,14) = UNDF
            RESUFR(IFREQ,15) = UNDF
            RESUFI(IFREQ,2)  = INDF
            RESUFI(IFREQ,3)  = INDF
            RESUFI(IFREQ,4)  = INDF
            RESUFI(IFREQ,8)  = ITERQ
 40      CONTINUE
         WRITE(IFM,7777)

      ELSEIF ( RESUFK(NFREQ,2) .EQ. 'INVERSE_R'  .AND.
     +             OPTION(1:6) .EQ. 'AJUSTE'     ) THEN
         IF (TYPRES .EQ. 'DYNAMIQUE') THEN
           WRITE(IFM,5000)
         ELSE
           WRITE(IFM,5001)
         ENDIF
         DO 50 IFREQ = 1, NFREQ
            IRESO = RESUFI(IFREQ,1)
            FFF   = RESUFR(IFREQ,1)
            CHA   = RESUFR(IFREQ,2)
            AM    = RESUFR(IFREQ,3)
            ITERA = RESUFI(IFREQ,2)
            ITERB = RESUFI(IFREQ,3)
            PREC  = RESUFR(IFREQ,14)
            ITERQ = RESUFI(IFREQ,4)
            ERR   = RESUFR(IFREQ,15)
            AM2   = RESUFR(IFREQ,4)
            IF (TYPRES .EQ. 'DYNAMIQUE') THEN
         WRITE(IFM,5010) IRESO,FFF,AM,ITERA,ITERB,PREC,ITERQ,ERR,AM2
            ELSE
         WRITE(IFM,5010) IRESO,CHA,AM,ITERA,ITERB,PREC,ITERQ,ERR,AM2
            ENDIF
            RESUFR(IFREQ,14) = UNDF
            RESUFR(IFREQ,15) = UNDF
            RESUFI(IFREQ,2)  = INDF
            RESUFI(IFREQ,3)  = INDF
            RESUFI(IFREQ,4)  = INDF
            RESUFI(IFREQ,7)  = ITERQ
 50      CONTINUE
         WRITE(IFM,7777)

      ELSEIF ( RESUFK(NFREQ,2) .EQ. 'INVERSE_R'  .AND.
     +             OPTION(1:6) .EQ. 'SEPARE'     ) THEN
         IF (TYPRES .EQ. 'DYNAMIQUE') THEN
           WRITE(IFM,6000)
         ELSE
           WRITE(IFM,6001)
         ENDIF
         DO 60 IFREQ = 1, NFREQ
            IRESO = RESUFI(IFREQ,1)
            FFF   = RESUFR(IFREQ,1)
            AM    = RESUFR(IFREQ,3)
            CHA   = RESUFR(IFREQ,2)
            ITERA = RESUFI(IFREQ,2)
            ITERQ = RESUFI(IFREQ,4)
            ERR   = RESUFR(IFREQ,15)
            AM2   = RESUFR(IFREQ,4)
            IF (TYPRES .EQ. 'DYNAMIQUE') THEN
              WRITE(IFM,6010) IRESO,FFF,AM,ITERA,ITERQ,ERR,AM2
            ELSE
              WRITE(IFM,6010) IRESO,CHA,AM,ITERA,ITERQ,ERR,AM2
            ENDIF
            RESUFR(IFREQ,14) = UNDF
            RESUFR(IFREQ,15) = UNDF
            RESUFI(IFREQ,2)  = INDF
            RESUFI(IFREQ,3)  = INDF
            RESUFI(IFREQ,4)  = INDF
            RESUFI(IFREQ,6)  = ITERQ
 60      CONTINUE
         WRITE(IFM,7777)

      ELSEIF ( RESUFK(NFREQ,2) .EQ. 'INVERSE_C'  .AND.
     +           ( OPTION(1:6) .EQ. 'AJUSTE'     .OR.
     +             OPTION(1:6) .EQ. 'SEPARE' )   ) THEN
         IF (TYPRES .EQ. 'DYNAMIQUE') THEN
           WRITE(IFM,7000)
         ELSE
           WRITE(IFM,7001)
         ENDIF
         DO 70 IFREQ = 1, NFREQ
            IRESO = RESUFI(IFREQ,1)
            FFF   = RESUFR(IFREQ,1)
            AM    = RESUFR(IFREQ,3)
            ITERB = RESUFI(IFREQ,2)
            PREC  = RESUFR(IFREQ,14)
            ITERQ = RESUFI(IFREQ,4)
            ERR   = RESUFR(IFREQ,15)
            AM2   = RESUFR(IFREQ,4)
            IF (TYPRES .EQ. 'DYNAMIQUE') THEN
              WRITE(IFM,7010) IRESO,FFF,AM,ITERB,PREC,ITERQ,ERR,AM2
            ELSE
              WRITE(IFM,7010) IRESO,CHA,AM,ITERB,PREC,ITERQ,ERR,AM2
            ENDIF
            RESUFR(IFREQ,14) = UNDF
            RESUFR(IFREQ,15) = UNDF
            RESUFI(IFREQ,2)  = INDF
            RESUFI(IFREQ,3)  = INDF
            RESUFI(IFREQ,4)  = INDF
            RESUFI(IFREQ,8)  = ITERQ
 70      CONTINUE
         WRITE(IFM,7777)

      ENDIF

 1000 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION SIMULTANEE',/,
     +        22X,'METHODE DE BATHE ET WILSON',/,/,
     +       4X,'NUMERO',4X,'FREQUENCE (HZ)',4X,'NORME D''ERREUR',4X,
     +            'ITER_BATHE',4X,'ITER_JACOBI' )
 1001 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION SIMULTANEE',/,
     +        22X,'METHODE DE BATHE ET WILSON',/,/,
     +      4X,'NUMERO',4X,'CHARGE CRITIQUE',4X,'NORME D''ERREUR',4X,
     +            'ITER_BATHE',4X,'ITER_JACOBI' )
 1010 FORMAT (1P,6X,I4,5X,E12.5,6X,E12.5,7X,I4,10X,I4)

 2000 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION SIMULTANEE',/,
     +        22X,'METHODE DE LANCZOS',/,/,
     +       4X,'NUMERO',4X,'FREQUENCE (HZ)',4X,'NORME D''ERREUR',4X,
     +            'ITER_QR' )
 2001 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION SIMULTANEE',/,
     +        22X,'METHODE DE LANCZOS',/,/,
     +       4X,'NUMERO',4X,'CHARGE CRITIQUE',4X,'NORME D''ERREUR',4X,
     +            'ITER_QR' )
 2010 FORMAT (1P,6X,I4,5X,E12.5,6X,E12.5,7X,I4)
 2100 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION SIMULTANEE',/,
     +        22X,'METHODE DE LANCZOS',/,/,
     +        4X,'NUMERO',4X,'FREQUENCE (HZ)',4X,'AMORTISSEMENT',4X,
     +            'ITER_QR' )
 2101 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION SIMULTANEE',/,
     +        22X,'METHODE DE LANCZOS',/,/,
     +        4X,'NUMERO',4X,'CHARGE CRITIQUE',4X,'AMORTISSEMENT',4X,
     +            'ITER_QR' )

 2200 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION SIMULTANEE',/,
     +        22X,'METHODE DE SORENSEN',/,/,
     +        4X,'NUMERO',4X,'FREQUENCE (HZ)',4X,'NORME D''ERREUR')
 2201 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION SIMULTANEE',/,
     +        22X,'METHODE DE SORENSEN',/,/,
     +        4X,'NUMERO',4X,'CHARGE CRITIQUE',4X,'NORME D''ERREUR')
 2202 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION SIMULTANEE',/,
     +        22X,'METHODE DE SORENSEN',/,/,
     +        4X,'NUMERO',4X,'FREQUENCE (HZ)',4X,'AMORTISSEMENT',4X,
     +        'NORME D''ERREUR')
 2203 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION SIMULTANEE',/,
     +        22X,'METHODE DE SORENSEN',/,/,
     +        4X,'NUMERO',4X,'CHARGE CRITIQUE',4X,'AMORTISSEMENT',4X,
     +        'NORME D''ERREUR')
 2210 FORMAT (1P,6X,I4,5X,E12.5,6X,E12.5)
 2211 FORMAT (1P,6X,I4,5X,E12.5,6X,E12.5,6X,E12.5)


 3200 FORMAT ( 7X,'CALCUL MODAL:  METHODE GLOBALE DE TYPE QR',/,
     +        22X,A27,/,/,
     +        4X,'NUMERO',4X,'FREQUENCE (HZ)',4X,'NORME D''ERREUR')
 3201 FORMAT ( 7X,'CALCUL MODAL:  METHODE GLOBALE DE TYPE QR',/,
     +        22X,A27,/,/,
     +        4X,'NUMERO',4X,'CHARGE CRITIQUE',4X,'NORME D''ERREUR')
 3202 FORMAT ( 7X,'CALCUL MODAL:  METHODE GLOBALE DE TYPE QR',/,
     +        22X,A27,/,/,
     +        4X,'NUMERO',4X,'FREQUENCE (HZ)',4X,'AMORTISSEMENT',4X,
     +        'NORME D''ERREUR')
 3203 FORMAT ( 7X,'CALCUL MODAL:  METHODE GLOBALE DE TYPE QR',/,
     +        22X,A27,/,/,
     +        4X,'NUMERO',4X,'CHARGE CRITIQUE',4X,'AMORTISSEMENT',4X,
     +        'NORME D''ERREUR')
 3210 FORMAT (1P,6X,I4,5X,E12.5,6X,E12.5)
 3211 FORMAT (1P,6X,I4,5X,E12.5,6X,E12.5,6X,E12.5)



 4000 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION INVERSE',/,
     +        54X,'INVERSE',/,
     +        4X,'NUMERO',4X,'FREQUENCE (HZ)',4X,'AMORTISSEMENT',4X,
     +        'NB_ITER',4X,'PRECISION',4X,'NORME D''ERREUR' )
 4001 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION INVERSE',/,
     +        54X,'INVERSE',/,
     +        4X,'NUMERO',4X,'CHARGE CRITIQUE',4X,'AMORTISSEMENT',4X,
     +        'NB_ITER',4X,'PRECISION',4X,'NORME D''ERREUR' )
 4010 FORMAT (1P,6X,I4,5X,E12.5,6X,E12.5,5X,I4,4X,E12.5,6X,E12.5)

 5000 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION INVERSE',/,
     +        48X,'DICHOTOMIE',7X,'SECANTE',17X,'INVERSE',/,
     +        4X,'NUMERO',4X,'FREQUENCE (HZ)',4X,'AMORTISSEMENT',4X,
     +        'NB_ITER',2(4X,'NB_ITER',4X,'PRECISION'),
     +        4X,'NORME D''ERREUR')
 5001 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION INVERSE',/,
     +        48X,'DICHOTOMIE',7X,'SECANTE',17X,'INVERSE',/,
     +        4X,'NUMERO',4X,'CHARGE CRITIQUE',4X,'AMORTISSEMENT',4X,
     +        'NB_ITER',2(4X,'NB_ITER',4X,'PRECISION'),
     +        4X,'NORME D''ERREUR')
 5010 FORMAT (1P,6X,I4,5X,E12.5,6X,E12.5,5X,I4,7X,I4,4X,E12.5,4X,I4,
     +        4X,E12.5,6X,E12.5)

 6000 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION INVERSE',/,
     +        48X,'DICHOTOMIE',8X,'INVERSE',/,
     +        4X,'NUMERO',4X,'FREQUENCE (HZ)',4X,'AMORTISSEMENT',4X,
     +        'NB_ITER',4X,'NB_ITER',4X,'PRECISION',
     +        4X,'NORME D''ERREUR')
 6001 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION INVERSE',/,
     +        48X,'DICHOTOMIE',8X,'INVERSE',/,
     +        4X,'NUMERO',4X,'CHARGE_CRITIQUE',4X,'AMORTISSEMENT',4X,
     +        'NB_ITER',4X,'NB_ITER',4X,'PRECISION',
     +        4X,'NORME D''ERREUR')
 6010 FORMAT (1P,6X,I4,5X,E12.5,6X,E12.5,5X,I4,7X,I4,4X,E12.5,
     +        6X,E12.5)

 7000 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION INVERSE',/,
     +        55X,'MULLER',17X,'INVERSE',/,
     +        4X,'NUMERO',4X,'FREQUENCE (HZ)',4X,'AMORTISSEMENT',
     +        2(4X,'NB_ITER',4X,'PRECISION'),4X,'NORME D''ERREUR')
 7001 FORMAT ( 7X,'CALCUL MODAL:  METHODE D''ITERATION INVERSE',/,
     +        55X,'MULLER',17X,'INVERSE',/,
     +        4X,'NUMERO',4X,'CHARGE_CRITIQUE',4X,'AMORTISSEMENT',
     +        2(4X,'NB_ITER',4X,'PRECISION'),4X,'NORME D''ERREUR')
 7010 FORMAT (1P,6X,I4,5X,E12.5,6X,E12.5,5X,I4,4X,E12.5,4X,I4,4X,E12.5,
     +        6X,E12.5)

 7776 FORMAT(' NORME D''ERREUR MOYENNE: ',E12.5)
 7777 FORMAT ( / )

C     ------------------------------------------------------------------
 9999 CONTINUE
      END
