      SUBROUTINE NMCALM(TYPMAT,MODELZ,LISCHA,MATE  ,CARELE,
     &                  COMPOR,INSTAM,INSTAP,CARCRI,VALINC,
     &                  SOLALG,OPTMAZ,BASE  ,MEELEM,DEFICO,
     &                  RESOCO,MATELE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/04/2012   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
      CHARACTER*(*) MODELZ
      CHARACTER*(*) MATE,CARELE
      CHARACTER*24  COMPOR,CARCRI
      REAL*8        INSTAM,INSTAP
      CHARACTER*24  DEFICO,RESOCO
      CHARACTER*19  LISCHA
      CHARACTER*6   TYPMAT
      CHARACTER*(*) OPTMAZ
      CHARACTER*1   BASE
      CHARACTER*19  MEELEM(*),SOLALG(*),VALINC(*)
      CHARACTER*19  MATELE
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (CALCUL)
C
C CALCUL DES MATRICES ELEMENTAIRES
C
C ----------------------------------------------------------------------
C
C
C IN  MODELE : NOM DU MODELE
C IN  LISCHA : LISTE DES CHARGEMENTS
C IN  MATE   : CHAMP MATERIAU
C IN  CARCRI : PARAMETRES DES METHODES D'INTEGRATION LOCALES
C IN  TYPMAT : TYPE DE MATRICE A CALCULER
C                MERIGI  - MATRICE POUR RIGIDITE
C                MEDIRI  - MATRICE POUR CL DIRICHLET LAGRANGE
C                MEGEOM  - MATRICE POUR NON-LIN. GEOMETRIQUE
C                MEAMOR  - MATRICE POUR AMORTISSEMENT
C                MEMASS  - MATRICE POUR MASSE
C                MESUIV  - MATRICE POUR CHARGEMENT SUIVEUR
C                MESSTR  - MATRICE POUR SOUS-STRUCTURES
C                MEELTC  - MATRICE POUR ELTS DE CONTACT
C                MEELTF  - MATRICE POUR ELTS DE FROTTEMENT
C IN  OPTCAL : OPTION DE CALCUL DU MATR_ELEM
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
C IN  OPTMAT : OPTION DE CALCUL POUR LA MATRICE
C OUT MATELE : MATRICE ELEMENTAIRE
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
      CHARACTER*19 MEMASS,MERIGI
      CHARACTER*24 MODELE
      INTEGER      JINFC,JCHAR,JCHAR2,IAREFE
      INTEGER      NBCHAR
      INTEGER      IBID,IRET,I
      CHARACTER*16 OPTMAT
      CHARACTER*19 DEPMOI,SIGPLU,VITPLU,VITMOI,ACCMOI,STRPLU
      CHARACTER*19 DEPDEL
      CHARACTER*24 CHARGE,INFOCH
      CHARACTER*8  MAILLA
      INTEGER      IFM,NIV
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- INITIALISATIONS
C
      OPTMAT = OPTMAZ
      MODELE = MODELZ
      CALL DISMOI('F','NOM_MAILLA',MODELE,'MODELE'  ,IBID  ,MAILLA,IRET)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE><MATR> CALCUL DES MATR_ELEM' //
     &                ' DE TYPE <',TYPMAT,'>'
      ENDIF
C
C --- DECOMPACTION DES VARIABLES CHAPEAUX
C
      IF (VALINC(1)(1:1).NE.' ') THEN
        CALL NMCHEX(VALINC,'VALINC','DEPMOI',DEPMOI)
        CALL NMCHEX(VALINC,'VALINC','VITMOI',VITMOI)
        CALL NMCHEX(VALINC,'VALINC','ACCMOI',ACCMOI)
        CALL NMCHEX(VALINC,'VALINC','VITPLU',VITPLU)
        CALL NMCHEX(VALINC,'VALINC','SIGPLU',SIGPLU)
        CALL NMCHEX(VALINC,'VALINC','STRPLU',STRPLU)
      ENDIF
      IF (SOLALG(1)(1:1).NE.' ') THEN
        CALL NMCHEX(SOLALG,'SOLALG','DEPDEL',DEPDEL)
      ENDIF
      IF (MEELEM(1)(1:1).NE.' ') THEN
        CALL NMCHEX(MEELEM,'MEELEM','MERIGI',MERIGI)
        CALL NMCHEX(MEELEM,'MEELEM','MEMASS',MEMASS)
      ENDIF
C
C --- TRANSFO CHARGEMENTS
C
      CHARGE = LISCHA(1:19)//'.LCHA'
      INFOCH = LISCHA(1:19)//'.INFC'
      CALL JEVEUO(INFOCH,'L',JINFC)
      NBCHAR = ZI(JINFC)
      IF(NBCHAR.NE.0)THEN
         CALL JEVEUO(CHARGE,'L',JCHAR)
         CALL WKVECT('&&NMCALC.LISTE_CHARGE','V V K8',NBCHAR,JCHAR2)
         DO 10 I = 1,NBCHAR
           ZK8(JCHAR2-1+I) = ZK24(JCHAR-1+I) (1:8)
   10    CONTINUE
      ELSE
         CALL WKVECT('&&NMCALC.LISTE_CHARGE','V V K8',1,JCHAR2)
      ENDIF
C
      IF (TYPMAT.EQ.'MEDIRI') THEN
C
C --- MATR_ELEM DES CL DE DIRICHLET B
C
        CALL MEDIME('V','ZERO',MODELE,LISCHA,MATELE)
C
C --- MATR_ELEM RIGIDITE GEOMETRIQUE
C
      ELSEIF (TYPMAT.EQ.'MEGEOM') THEN
        CALL DETRSD('MATR_ELEM',MATELE)
        CALL MERIGE(MODELE(1:8),CARELE(1:8),SIGPLU,STRPLU,MATELE,'V',0)
C
C --- MATR_ELEM MASSES
C
      ELSEIF (TYPMAT.EQ.'MEMASS') THEN
        CALL MEMAME(OPTMAT,MODELE,NBCHAR,ZK8(JCHAR2),MATE  ,
     &              CARELE,.TRUE.,INSTAM,COMPOR     ,MATELE,
     &              BASE  )
C
C --- MATR_ELEM AMORTISSEMENT
C
      ELSEIF (TYPMAT.EQ.'MEAMOR') THEN
        CALL MEAMME(OPTMAT,MODELE,NBCHAR,ZK8(JCHAR2),MATE  ,
     &              CARELE,.TRUE.,INSTAM,'V'        ,MERIGI,
     &              MEMASS,MATELE)
C
C --- MATR_ELEM POUR CHARGES SUIVEUSES
C
      ELSEIF (TYPMAT.EQ.'MESUIV') THEN
        CALL MECGME(MODELE,CARELE,MATE  ,LISCHA,INSTAP,
     &              DEPMOI,DEPDEL,INSTAM,COMPOR,CARCRI,
     &              MATELE)
        CALL MECGM2(LISCHA,INSTAP,MATELE)
C
C --- MATR_ELEM DES SOUS-STRUCTURES
C
      ELSEIF (TYPMAT.EQ.'MESSTR') THEN
        CALL MEMARE(BASE  ,MATELE,MODELE(1:8),MATE,CARELE,
     &              OPTMAT)
        CALL JEVEUO(MATELE//'.RERR','E',IAREFE)
        ZK24(IAREFE-1+3) = 'OUI_SOUS_STRUC'
C
C --- MATR_ELEM DES ELTS DE CONTACT (XFEM+CONTINUE)
C
      ELSEIF (TYPMAT.EQ.'MEELTC') THEN
        CALL NMELCM('CONT',MODELE,DEFICO,RESOCO,MATE  ,
     &              DEPMOI,DEPDEL,VITMOI,VITPLU,ACCMOI,
     &              MATELE)
C
C --- MATR_ELEM DES ELTS DE FROTTEMENT (XFEM+CONTINUE)
C
      ELSEIF (TYPMAT.EQ.'MEELTF') THEN
        CALL NMELCM('FROT',MODELE,DEFICO,RESOCO,MATE  ,
     &              DEPMOI,DEPDEL,VITMOI,VITPLU,ACCMOI,
     &              MATELE)
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
C
C --- DEBUG
C
      IF (NIV.EQ.2) THEN
        CALL NMDEBG(' ',MATELE,IFM   )
      ENDIF
C
C --- MENAGE
C
      CALL JEDETR('&&NMCALC.LISTE_CHARGE')
      CALL JEDEMA()
C
      END
