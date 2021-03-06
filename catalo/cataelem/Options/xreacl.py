# coding=utf-8
# person_in_charge: samuel.geniaut at edf.fr


# ======================================================================
# COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
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




PAINTER  = InputParameter(phys=PHY.N1360R)


PCFACE   = InputParameter(phys=PHY.N720_I)


PLONGCO  = InputParameter(phys=PHY.N120_I, container='MODL!.TOPOSE.LON',
comment="""  XFEM - NBRE DE TETRAEDRES ET DE SOUS-ELEMENTS  """)


PPINTER  = InputParameter(phys=PHY.N816_R)


PLST     = InputParameter(phys=PHY.NEUT_R)


PBASECO  = InputParameter(phys=PHY.N2448R)


# Attention : le champ PSEUIL est un champ a sous-points
# pour les elements de contact XFEM (xhc,xhtc,xtc)
PSEUIL   = OutputParameter(phys=PHY.NEUT_R, type='ELEM')


XREACL = Option(
    para_in=(
           PAINTER,
           PBASECO,
           PCFACE,
        SP.PDEPL_P,
        SP.PDONCO,
        SP.PGEOMER,
           PLONGCO,
           PLST,
           PPINTER,
    ),
    para_out=(
           PSEUIL,
    ),
    condition=(
      CondCalcul('+', ((AT.LXFEM,'OUI'),(AT.CONTACT,'OUI'),)),
    ),
)
