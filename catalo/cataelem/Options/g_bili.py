
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




PVARCPR  = InputParameter(phys=PHY.VARI_R)


G_BILI = Option(
    para_in=(
        SP.PDEPLAU,
        SP.PDEPLAV,
        SP.PGEOMER,
        SP.PMATERC,
        SP.PTHETAR,
        SP.PVARCMR,
           PVARCPR,
        SP.PVARCRR,
        SP.UEPSINR,
        SP.UPESANR,
        SP.UPFR23D,
        SP.UPFRVOL,
        SP.UPRESSR,
        SP.UROTATR,
        SP.VEPSINR,
        SP.VPESANR,
        SP.VPFR23D,
        SP.VPFRVOL,
        SP.VPRESSR,
        SP.VROTATR,
    ),
    para_out=(
        SP.PGTHETA,
    ),
    condition=(
      CondCalcul('+', (('PHENO','ME'),('BORD','0'),)),
      CondCalcul('+', (('PHENO','ME'),('BORD','-1'),)),
    ),
)