      SUBROUTINE TE0100(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 26/04/2005   AUTEUR LAVERNE J.LAVERNE 
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

      IMPLICIT NONE
      CHARACTER*16 OPTION,NOMTE
C ......................................................................
C    - FONCTION REALISEE:  CALCUL DES OPTIONS NON-LINEAIRES MECANIQUES
C                          EN 2D (CPLAN ET DPLAN) ET AXI
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................

      CHARACTER*8 TYPMOD(2),NOMAIL
      INTEGER NNO,NPG1,I,KP,K,L,IMATUU,LGPG,LGPG1,LGPG2
      INTEGER IPOIDS,IVF,IDFDE,IGEOM,IMATE
      INTEGER ITREF,ICONTM,IVARIM,ITEMPM,ITEMPP,IPHASM,IPHASP
      INTEGER IINSTM,IINSTP,IDEPLM,IDEPLP,ICOMPO,ICARCR
      INTEGER IVECTU,ICONTP,IVARIP,LI,IDEFAM,IDEFAP
      INTEGER IHYDRM,IHYDRP,ISECHM,ISECHP,ISREF,IVARIX,IRET
      INTEGER IIRRAM, IIRRAP
      INTEGER NDDL,KK,NI,MJ,JTAB(7),IADZI,IAZK24,NZ,JCRET,CODRET
      INTEGER NDIM,NNOS,JGANO,ICAMAS
      REAL*8  MATNS(2*9*2*9)
      REAL*8  VECT1(54), VECT2(4*27*27), VECT3(4*27*2)
      REAL*8  R8VIDE,ANGMAS(3),R8DGRD
      REAL*8  PHASM(7*27),PHASP(7*27)
      LOGICAL DEFANE,MATSYM

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG1,IPOIDS,IVF,IDFDE,JGANO)

C - FONCTIONS DE FORMES ET POINTS DE GAUSS
C
      IF (NNO.GT.9) CALL UTMESS('F','TE0100','MATNS MAL DIMENSIONNEE')

C - TYPE DE MODELISATION

      IF (NOMTE(3:4).EQ.'AX') THEN
        TYPMOD(1) = 'AXIS    '
      ELSE IF (NOMTE(3:4).EQ.'CP') THEN
        TYPMOD(1) = 'C_PLAN  '
      ELSE IF (NOMTE(3:4).EQ.'DP') THEN
        TYPMOD(1) = 'D_PLAN  '
      ELSE
        CALL UTMESS('F','TE0100','NOM D''ELEMENT ILLICITE')
      END IF
      
      IF (NOMTE(1:2).EQ.'MD') THEN
        TYPMOD(2) = 'ELEMDISC'
      ELSE IF (NOMTE(1:2).EQ.'MI') THEN
        TYPMOD(2) = 'INCO    '
      ELSE
        TYPMOD(2) = '        '
      END IF
      CODRET = 0

C - PARAMETRES EN ENTREE

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PCONTMR','L',ICONTM)
      CALL JEVECH('PVARIMR','L',IVARIM)
      CALL JEVECH('PDEPLMR','L',IDEPLM)
      CALL JEVECH('PDEPLPR','L',IDEPLP)
      CALL JEVECH('PCOMPOR','L',ICOMPO)
      CALL JEVECH('PCARCRI','L',ICARCR)

      CALL TECACH('OON','PVARIMR',7,JTAB,IRET)
      LGPG1 = MAX(JTAB(6),1)*JTAB(7)
      LGPG = LGPG1

C     ORIENTATION DU MASSIF     
      CALL TECACH('NNN','PCAMASS',1,ICAMAS,IRET)
      CALL R8INIR(3, R8VIDE(), ANGMAS ,1)

      IF (IRET.EQ.0) THEN
        IF (ZR(ICAMAS).GT.0.D0) THEN
         ANGMAS(1) = ZR(ICAMAS+1)*R8DGRD()
         ANGMAS(2) = ZR(ICAMAS+2)*R8DGRD()
         ANGMAS(3) = ZR(ICAMAS+3)*R8DGRD()
        ENDIF
      ENDIF

C - VARIABLES DE COMMANDE

      CALL JEVECH('PTEREF','L',ITREF)
      CALL JEVECH('PTEMPMR','L',ITEMPM)
      CALL JEVECH('PTEMPPR','L',ITEMPP)
      CALL JEVECH('PINSTMR','L',IINSTM)
      CALL JEVECH('PINSTPR','L',IINSTP)
      CALL TECACH('ONN','PDEFAMR',1,IDEFAM,IRET)
      CALL TECACH('ONN','PDEFAPR',1,IDEFAP,IRET)
      DEFANE = IDEFAM .NE. 0
      CALL TECACH('NNN','PPHASMR',1,IPHASM,IRET)
      CALL TECACH('NNN','PPHASPR',1,IPHASP,IRET)
      IF (IRET.EQ.0) THEN
        CALL TECACH('OON','PPHASPR',7,JTAB,IRET)
        NZ = JTAB(6)
C  passage de PPHASMR et PPHASPR aux points de Gauss
        DO 9 KP = 1,NPG1
          K = (KP-1)*NNO
          DO 7 L = 1,NZ   
            PHASM(NZ*(KP-1)+L)=0.D0
            PHASP(NZ*(KP-1)+L)=0.D0
            DO 5 I = 1,NNO   
              PHASM(NZ*(KP-1)+L) = PHASM(NZ*(KP-1)+L) + 
     +                           ZR(IPHASM+NZ*(I-1)+L-1)*ZR(IVF+K+I-1)
              PHASP(NZ*(KP-1)+L) = PHASP(NZ*(KP-1)+L) + 
     +                           ZR(IPHASP+NZ*(I-1)+L-1)*ZR(IVF+K+I-1)
  5         CONTINUE        
  7       CONTINUE          
  9     CONTINUE
      END IF
                  
      CALL JEVECH('PHYDRMR','L',IHYDRM)
      CALL JEVECH('PHYDRPR','L',IHYDRP)
      CALL JEVECH('PSECHMR','L',ISECHM)
      CALL JEVECH('PSECHPR','L',ISECHP)
      CALL JEVECH('PSECREF','L',ISREF)
      CALL JEVECH('PIRRAMR','L',IIRRAM)
      CALL JEVECH('PIRRAPR','L',IIRRAP)

C PARAMETRES EN SORTIE

      IF (OPTION(1:10).EQ.'RIGI_MECA_' .OR.
     &    OPTION(1:9).EQ.'FULL_MECA') THEN
          CALL NMTSTM(ZK16(ICOMPO),IMATUU,MATSYM)
      ENDIF

      IF (OPTION(1:9).EQ.'RAPH_MECA' .OR.
     &    OPTION(1:9).EQ.'FULL_MECA') THEN
        CALL JEVECH('PVECTUR','E',IVECTU)
        CALL JEVECH('PCONTPR','E',ICONTP)
        CALL JEVECH('PVARIPR','E',IVARIP)

C      ESTIMATION VARIABLES INTERNES A L'ITERATION PRECEDENTE
        CALL JEVECH('PVARIMP','L',IVARIX)
        CALL DCOPY(NPG1*LGPG,ZR(IVARIX),1,ZR(IVARIP),1)
      END IF



C - HYPER-ELASTICITE

      IF (ZK16(ICOMPO+3) (1:9).EQ.'COMP_ELAS') THEN

        IF (OPTION(1:10).EQ.'RIGI_MECA_') THEN

C        OPTION RIGI_MECA_TANG :         ARGUMENTS EN T-
          CALL NMEL2D(NNO,NPG1,IPOIDS,IVF,IDFDE,
     &                ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),ZK16(ICOMPO),
     &                LGPG,ZR(ICARCR),ZR(ITEMPM),ZR(IHYDRM),ZR(ISECHM),
     &                ZR(ITREF),ZR(IDEPLM),VECT1,VECT2,
     &                VECT3,ZR(ICONTM),ZR(IVARIM),
     &                ZR(IMATUU),ZR(IVECTU),CODRET)

        ELSE

C        OPTION FULL_MECA OU RAPH_MECA : ARGUMENTS EN T+
          DO 10 LI = 1,2*NNO
            ZR(IDEPLP+LI-1) = ZR(IDEPLM+LI-1) + ZR(IDEPLP+LI-1)
   10     CONTINUE

          CALL NMEL2D(NNO,NPG1,IPOIDS,IVF,IDFDE,
     &                ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),ZK16(ICOMPO),
     &                LGPG,ZR(ICARCR),ZR(ITEMPP),ZR(IHYDRP),ZR(ISECHP),
     &                ZR(ITREF),ZR(IDEPLP),VECT1,VECT2,
     &                VECT3,ZR(ICONTP),ZR(IVARIP),
     &                ZR(IMATUU),ZR(IVECTU),CODRET)
        END IF

      ELSE


C - HYPO-ELASTICITE

        IF (ZK16(ICOMPO+2) (6:10).EQ.'_REAC') THEN
CCDIR$ IVDEP
          DO 20 I = 1,2*NNO
            ZR(IGEOM+I-1) = ZR(IGEOM+I-1) + ZR(IDEPLM+I-1) +
     &                      ZR(IDEPLP+I-1)
  20     CONTINUE
        END IF

        IF (ZK16(ICOMPO+2) (1:5).EQ.'PETIT') THEN
        
C -       ELEMENT A DISCONTINUITE INTERNE
          IF (TYPMOD(2).EQ.'ELEMDISC') THEN
                    
            CALL NMED2D(NNO,NPG1,IPOIDS,IVF,IDFDE,
     &                  ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),ZK16(ICOMPO),
     &                  LGPG,ZR(ICARCR),
     &                  ZR(IDEPLM),ZR(IDEPLP),
     &                  ZR(ICONTM),ZR(IVARIM),VECT1,
     &                  VECT3,ZR(ICONTP),ZR(IVARIP),
     &                  ZR(IMATUU),ZR(IVECTU),CODRET)

          ELSE
          
            CALL NMPL2D(NNO,NPG1,IPOIDS,IVF,IDFDE,
     &                  ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),ZK16(ICOMPO),
     &                  LGPG,ZR(ICARCR),
     &                  ZR(IINSTM),ZR(IINSTP),
     &                  ZR(ITEMPM),ZR(ITEMPP),ZR(ITREF),
     &                  ZR(IHYDRM),ZR(IHYDRP),
     &                  ZR(ISECHM),ZR(ISECHP),ZR(ISREF),
     &                  ZR(IIRRAM),ZR(IIRRAP),
     &                  NZ,PHASM,PHASP,
     &                  ZR(IDEPLM),ZR(IDEPLP),ZR(IDEFAM),ZR(IDEFAP),
     &                  DEFANE,
     &                  ANGMAS,
     &                  ZR(ICONTM),ZR(IVARIM),MATSYM,VECT1,
     &                  VECT3,ZR(ICONTP),ZR(IVARIP),
     &                  ZR(IMATUU),ZR(IVECTU),CODRET)

          ENDIF

C      GRANDES DEFORMATIONS : FORMULATION SIMO - MIEHE

        ELSE IF (ZK16(ICOMPO+2) (1:10).EQ.'SIMO_MIEHE') THEN
          CALL NMGP2D(NNO,NPG1,IPOIDS,IVF,IDFDE,
     &                ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),ZK16(ICOMPO),
     &                LGPG,ZR(ICARCR),
     &                ZR(IINSTM),ZR(IINSTP),
     &                ZR(ITEMPM),ZR(ITEMPP),ZR(ITREF),
     &                ZR(IHYDRM),ZR(IHYDRP),
     &                ZR(ISECHM),ZR(ISECHP),ZR(ISREF),
     &                ZR(IIRRAM),ZR(IIRRAP),
     &                NZ,PHASM,PHASP,
     &                ZR(IDEPLM),ZR(IDEPLP),
     &                ANGMAS,
     &                ZR(ICONTM),ZR(IVARIM),
     &                VECT1,VECT2,ZR(ICONTP),ZR(IVARIP),
     &                MATNS,ZR(IVECTU),CODRET)

C        SYMETRISATION DE MATNS DANS MATUU
          IF (OPTION(1:4).EQ.'RIGI' .OR. OPTION(1:4).EQ.'FULL') THEN
            NDDL = 2*NNO
            KK = 0
            DO 40 NI = 1,NDDL
              DO 30 MJ = 1,NI
                ZR(IMATUU+KK) = (MATNS((NI-1)*NDDL+MJ)+
     &                          MATNS((MJ-1)*NDDL+NI))/2.D0
                KK = KK + 1
   30         CONTINUE
   40       CONTINUE
          END IF

C 7.3 - GRANDES ROTATIONS ET PETITES DEFORMATIONS
        ELSE IF (ZK16(ICOMPO+2) .EQ.'GREEN') THEN

          DO 45 LI = 1,2*NNO
            ZR(IDEPLP+LI-1) = ZR(IDEPLM+LI-1) + ZR(IDEPLP+LI-1)
   45     CONTINUE

          CALL NMGR2D(NNO,NPG1,IPOIDS,IVF,IDFDE,
     &                ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),ZK16(ICOMPO),
     &                LGPG,ZR(ICARCR),
     &                ZR(IINSTM),ZR(IINSTP),
     &                ZR(ITEMPM),ZR(ITEMPP),ZR(ITREF),
     &                ZR(IHYDRM),ZR(IHYDRP),
     &                ZR(ISECHM),ZR(ISECHP),ZR(ISREF),
     &                ZR(IIRRAM),ZR(IIRRAP),
     &                NZ,PHASM,PHASP,
     &                ZR(IDEPLM),ZR(IDEPLP),ZR(IDEFAM),ZR(IDEFAP),
     &                DEFANE,
     &                ANGMAS,
     &                ZR(ICONTM),ZR(IVARIM),
     &                VECT1,VECT2,VECT3,
     &                ZR(ICONTP),ZR(IVARIP),
     &                ZR(IMATUU),ZR(IVECTU),CODRET)
        ELSE
          CALL UTMESS('F','TE0100','COMPORTEMENT:'//ZK16(ICOMPO+2)//
     &                'NON IMPLANTE')
        END IF

      END IF
      IF (OPTION(1:9).EQ.'FULL_MECA' .OR.
     &    OPTION(1:9).EQ.'RAPH_MECA') THEN
        CALL JEVECH('PCODRET','E',JCRET)
        ZI(JCRET) = CODRET
      END IF
      END
