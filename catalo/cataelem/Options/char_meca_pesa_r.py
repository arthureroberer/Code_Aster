# coding=utf-8
# person_in_charge: xavier.desroches at edf.fr


# ======================================================================
# COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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
import cataelem.Commons.attributes as AT




PNBSP_I  = InputParameter(phys=PHY.NBSP_I, container='CARA!.CANBSP',
comment="""  PNBSP_I :  NOMBRE DE SOUS_POINTS  """)


PCAORIE  = InputParameter(phys=PHY.CAORIE, container='CARA!.CARORIEN',
comment="""  PCAORIE : ORIENTATION LOCALE D'UN ELEMENT DE POUTRE OU DE TUYAU  """)


PVARCPR  = InputParameter(phys=PHY.VARI_R)


PCOMPOR  = InputParameter(phys=PHY.COMPOR)


PPINTTO  = InputParameter(phys=PHY.N132_R,
comment=""" SPECIFIQUE X-FEM """)


PCNSETO  = InputParameter(phys=PHY.N1280I, container='MODL!.TOPOSE.CNS',
comment="""  XFEM - CONNECTIVITE DES SOUS-ELEMENTS  """)


PHEAVTO  = InputParameter(phys=PHY.N512_I)


PLONCHA  = InputParameter(phys=PHY.N120_I, container='MODL!.TOPOSE.LON',
comment="""  XFEM - NBRE DE TETRAEDRES ET DE SOUS-ELEMENTS  """)


PLSN     = InputParameter(phys=PHY.NEUT_R)


PLST     = InputParameter(phys=PHY.NEUT_R)


PSTANO   = InputParameter(phys=PHY.N120_I)


PPMILTO  = InputParameter(phys=PHY.N792_R)


PFISNO   = InputParameter(phys=PHY.NEUT_I,
comment=""" PFISNO : CONNECTIVITE DES FISSURES ET DES DDL HEAVISIDE """)


PHEA_NO  = InputParameter(phys=PHY.N120_I)

PBASLOR  = InputParameter(phys=PHY.NEUT_R)


CHAR_MECA_PESA_R = Option(
    para_in=(
        SP.PCACABL,
        SP.PCACOQU,
        SP.PCADISM,
        SP.PCAGEPO,
        SP.PCAGNBA,
        SP.PCAGNPO,
           PCAORIE,
        SP.PCINFDI,
           PCNSETO,
           PCOMPOR,
        SP.PDEPLMR,
        SP.PDEPLPR,
        SP.PFIBRES,
           PFISNO,
        SP.PGEOMER,
           PHEAVTO,
           PHEA_NO,
           PLONCHA,
           PLSN,
           PLST,
        SP.PMATERC,
           PNBSP_I,
        SP.PPESANR,
           PPINTTO,
           PPMILTO,
           PSTANO,
           PVARCPR,
           PBASLOR,
    ),
    para_out=(
        SP.PVECTUR,
    ),
    condition=(
      CondCalcul('+', ((AT.PHENO,'ME'),(AT.BORD,'0'),)),
      CondCalcul('-', ((AT.PHENO,'ME'),(AT.INTERFACE,'OUI'),)),
      CondCalcul('-', ((AT.PHENO,'ME'),(AT.ABSO,'OUI'),)),

#     les modelisations suivantes n'ont pas de masse : 
      CondCalcul('-', ((AT.PHENO,'ME'),(AT.FLUIDE,'OUI'),)),
      CondCalcul('-', ((AT.PHENO,'ME'),(AT.MODELI,'D2D'),)),
      CondCalcul('-', ((AT.PHENO,'ME'),(AT.MODELI,'D3D'),)),
    ),
    comment=""" CHAR_MECA_PESA_R  : calcul du second membre
   correspondant aux forces de gravite (MOT-CLE: PESANTEUR) """,
)
