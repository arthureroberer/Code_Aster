# coding=utf-8
# person_in_charge: mickael.abbas at edf.fr


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




PTRIAPG  = InputParameter(phys=PHY.ENDO_R, container='RESU!ENDO_ELGA!N',
comment="""  PTRIAPG : TRIAXIALITE, CONTRAINTE ENDOMMAGEMENT,
           ET DOMMAGE DE LEMAITRE-SERMAGE INSTANT ACTUEL
           AUX POINTS DE GAUSS """)


ENDO_ELNO = Option(
    para_in=(
           PTRIAPG,
    ),
    para_out=(
        SP.PTRIANO,
    ),
    condition=(
      CondCalcul('+', ((AT.PHENO,'ME'),(AT.BORD,'0'),)),
    ),
    comment="""  ENDO_ELNO : CALCUL DU TAUX DE TRIAXIALITE DES CONTRAINTES,
           DE LA CONTRAINTE EQUIVALENTE D'ENDOMMAGEMENT ET DE
           L'ENDOMMAGEMENT DE LEMAITRE-SERMAGE
           AUX NOEUDS DE CHAQUE ELEMENT """,
)
