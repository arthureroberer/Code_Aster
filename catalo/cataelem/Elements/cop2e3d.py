
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

from cataelem.Tools.base_objects import LocatedComponents, ArrayOfComponents, SetOfNodes, ElrefeLoc
from cataelem.Tools.base_objects import Calcul, Element, AbstractElement
import cataelem.Commons.physical_quantities as PHY
import cataelem.Commons.located_components as LC
import cataelem.Commons.parameters as SP
import cataelem.Commons.mesh_types as MT
from cataelem.Options.options import OP

#----------------
# Modes locaux :
#----------------


DDL_MECA = LocatedComponents(phys=PHY.DEPL_R, type='ELNO',
    components=('DX','DY','DZ','LAGS_C',))



#------------------------------------------------------------
abstractElement = AbstractElement()
ele = abstractElement

ele.addCalcul(OP.EXISTE_DDL, te=99,
    para_out=((OP.EXISTE_DDL.PDEPL_R, DDL_MECA), ),
)


#------------------------------------------------------------
COP2E3D = Element(modele=abstractElement)
ele = COP2E3D
ele.meshType = MT.SEG2


#------------------------------------------------------------
COQ4E3D = Element(modele=abstractElement)
ele = COQ4E3D
ele.meshType = MT.QUAD4


#------------------------------------------------------------
COT3E3D = Element(modele=abstractElement)
ele = COT3E3D
ele.meshType = MT.TRIA3


#------------------------------------------------------------
COQ8E3D = Element(modele=abstractElement)
ele = COQ8E3D
ele.meshType = MT.QUAD8


#------------------------------------------------------------
COT6E3D = Element(modele=abstractElement)
ele = COT6E3D
ele.meshType = MT.TRIA6


#------------------------------------------------------------
COQ9E3D = Element(modele=abstractElement)
ele = COQ9E3D
ele.meshType = MT.QUAD9
