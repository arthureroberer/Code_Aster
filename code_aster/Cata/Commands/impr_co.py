# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
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
# person_in_charge: j-pierre.lefebvre at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


IMPR_CO=PROC(nom="IMPR_CO",op=17,
             fr=tr("Imprimer tous les objets JEVEUX qui constituent un concept utilisateur existant (pour les développeurs)"),
         regles=(UN_PARMI('CONCEPT','CHAINE','TOUT' ),),

         UNITE           =SIMP(statut='f',typ=UnitType(),defaut=8, inout='out'),
         NIVEAU          =SIMP(statut='f',typ='I',defaut=2,into=(-1,0,1,2) ),
         ATTRIBUT        =SIMP(statut='f',typ='TXM',defaut="NON",into=("NON","OUI") ),
         CONTENU         =SIMP(statut='f',typ='TXM',defaut="OUI",into=("NON","OUI") ),
         BASE            =SIMP(statut='f',typ='TXM',defaut="G",into=(" ","G","V","L") ),
         CONCEPT    =FACT(statut='f',max='**',
             NOM         =SIMP(statut='o',typ=assd,validators=NoRepeat(),max='**'),),        
         CHAINE          =SIMP(statut='f',typ='TXM'),
         POSITION        =SIMP(statut='f',typ='I',defaut=1),
         TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),

         b_permut = BLOC(
                         condition   = """equal_to("NIVEAU", -1) """,
                         PERMUTATION = SIMP(statut='f',typ='TXM',defaut="OUI",into=("NON","OUI")),
                         ),

)  ;
