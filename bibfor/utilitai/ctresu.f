      SUBROUTINE CTRESU(NOMTB)
      IMPLICIT   NONE
      CHARACTER*8      NOMTB
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 28/06/2010   AUTEUR FLEJOU J-L.FLEJOU 
C ======================================================================
C COPYRIGHT (C) 1991 - 2010  EDF R&D                  WWW.CODE-ASTER.ORG
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
C     ----- OPERATEUR CREA_TABLE , MOT-CLE FACTEUR RESU   --------------
C
C        BUT : CREER UNE TABLE A PARTIR D'UN RESULTAT OU D'UN CHAMP
C
C        IN/OUT : NOMTB (K8) : NOM DE LA TABLE
C                
C ----------------------------------------------------------------------
      INTEGER      NBCMP,NDIM,NBNO,NBMA,NBVAL
      LOGICAL      TOUCMP 
      CHARACTER*1  TYGD
      CHARACTER*4  TYCH
      CHARACTER*8  TYPAC,SDRES,NOMA
      CHARACTER*16 NSYMB
      CHARACTER*19 CHPGS
      CHARACTER*24 NIVAL,NRVAL,NIORD,NKCHA,NKCMP,MESNOE,MESMAI
C     ------------------------------------------------------------------
      CALL JEMARQ()
C
C  -- 1.INITIALISATION
C     -----------------
      CHPGS  = '&&CTRESU.PT_GAUSS_S'
      NIVAL  = '&&CTRESU.ACCES_IS'
      NRVAL  = '&&CTRESU.ACCES_R8'
      NKCHA  = '&&CTRESU.SD_CHAM'
      NIORD  = '&&CTRESU.ORDRE'
      NKCMP  = '&&CTRESU.CMP_USER'
      MESMAI = '&&CTRESU.MES_MAILLES'
      MESNOE = '&&CTRESU.MES_NOEUDS'
C
C  -- 2.RECUPERATIONS DES CHAMPS
C     --------------------------
      CALL CTACCE(NSYMB,TYPAC,NBVAL,NIVAL,NRVAL,NIORD,NKCHA,SDRES)
C
C  -- 3.RECUPERATION DES NOEUDS,MAILLES,COMPOSANTES
C     ---------------------------------------------
      CALL CTDATA(MESNOE,MESMAI,NKCHA,TYCH,TOUCMP,NKCMP,NBCMP,
     &            NDIM,CHPGS,NOMA,NBNO,NBMA,NBVAL,TYGD)
C
C  -- 4.CREATION DE LA TABLE
C     ----------------------
      CALL CTCRTB(NOMTB,TYCH,SDRES,NKCHA,TYPAC,TOUCMP,NBCMP,NBVAL,
     &            NKCMP,NDIM)
C
C  -- 5.REMPLISSAGE DE LA TABLE
C     ----------------------
      IF(TYCH.EQ.'NOEU')THEN
C
            CALL CTNOTB(NBNO,MESNOE,NOMA,NBVAL,NKCHA,NKCMP,TOUCMP,
     &                  NBCMP,TYPAC,NDIM,NRVAL,SDRES,NOMTB,NSYMB,
     &                  NIVAL,NIORD)
C
      ELSE IF(TYCH(1:2).EQ.'EL')THEN
C
             CALL CTELTB(NBMA,MESMAI,NOMA,NBVAL,NKCHA,NKCMP,TOUCMP,
     &                   NBCMP,TYPAC,NDIM,NRVAL,SDRES,NOMTB,NSYMB,
     &                   CHPGS,TYCH,NIVAL,NIORD)
C
      ENDIF
C
C  -- 6.NETTOYAGE
C     ------------
      CALL JEDETR(CHPGS)
      CALL JEDETR(NIVAL)
      CALL JEDETR(NRVAL)
      CALL JEDETR(NKCHA)
      CALL JEDETR(NIORD)
      CALL JEDETR(NKCMP)
      CALL JEDETR(MESMAI)
      CALL JEDETR(MESNOE)

      CALL JEDEMA()

      END
