
# ======================================================================
# COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
# ======================================================================

from cataelem.Tools.base_objects import InputParameter, OutputParameter, Option, CondCalcul
import cataelem.Commons.physical_quantities as PHY
import cataelem.Commons.parameters as SP




PVARCPR  = InputParameter(phys=PHY.VARI_R, container='VOLA!&&CCPARA.VARI_INT_NM1',
comment="""  PVARCPR : TEMPERATURES INSTANT ACTUEL  """)


PVARIMR  = InputParameter(phys=PHY.VARI_R, container='RESU!VARI_ELGA!NM1',
comment="""  PVARIMR : VARIABLES INTERNES INSTANT PRECEDENT  """)


PVARIPR  = InputParameter(phys=PHY.VARI_R, container='RESU!VARI_ELGA!N',
comment="""  PVARIPR : VARIABLES INTERNES INSTANT ACTUEL  """)


PCOMPOR  = InputParameter(phys=PHY.COMPOR, container='RESU!COMPORTEMENT!N',
comment="""  PCOMPOR : COMPORTEMENT """)


PTRIAPG  = OutputParameter(phys=PHY.ENDO_R, type='ELGA',
comment="""  PTRIAGP : TRIAXIALITE, CONTRAINTE ENDOMMAGEMENT,
           ET DOMMAGE DE LEMAITRE-SERMAGE INSTANT ACTUEL """)


ENDO_ELGA = Option(
    para_in=(
           PCOMPOR,
        SP.PCONTGP,
        SP.PMATERC,
        SP.PTRIAGM,
        SP.PVARCMR,
           PVARCPR,
           PVARIMR,
           PVARIPR,
    ),
    para_out=(
           PTRIAPG,
    ),
    condition=(
      CondCalcul('+', (('PHENO','ME'),('BORD','0'),)),
    ),
    comment="""  ENDO_ELGA : CALCUL DU TAUX DE TRIAXIALITE DES CONTRAINTES,
           DE LA CONTRAINTE EQUIVALENTE D'ENDOMMAGEMENT ET DE
           L'ENDOMMAGEMENT DE LEMAITRE-SERMAGE
           AUX POINTS DE GAUSS DE CHAQUE ELEMENT """,
)