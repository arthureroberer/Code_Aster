
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




PPINTER  = InputParameter(phys=PHY.N816_R)


PAINTER  = InputParameter(phys=PHY.N1360R)


PCFACE   = InputParameter(phys=PHY.N720_I)


PLONGCO  = InputParameter(phys=PHY.N120_I)


PLSN     = InputParameter(phys=PHY.NEUT_R)


PLST     = InputParameter(phys=PHY.NEUT_R)


PSTANO   = InputParameter(phys=PHY.N120_I)


PBASECO  = InputParameter(phys=PHY.N2448R)


PHEA_NO  = InputParameter(phys=PHY.N120_I)


PMATTTR  = OutputParameter(phys=PHY.MTEM_R, type='RESL')


RIGI_THER_PARO_F = Option(
    para_in=(
           PAINTER,
           PBASECO,
           PCFACE,
        SP.PGEOMER,
           PHEA_NO,
        SP.PHECHPF,
           PLONGCO,
           PLSN,
           PLST,
           PPINTER,
           PSTANO,
        SP.PTEMPSR,
    ),
    para_out=(
           PMATTTR,
    ),
    condition=(
      CondCalcul('+', (('PHENO','TH'),('BORD','0'),('MODELI','CL1'),)),
      CondCalcul('+', (('PHENO','TH'),('BORD','0'),('MODELI','CL2'),)),
      CondCalcul('+', (('PHENO','TH'),('BORD','0'),('LXFEM','OUI'),)),
    ),
)