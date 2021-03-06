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


def macr_ecla_pg_prod(self,RESULTAT,MAILLAGE,RESU_INIT,**args):
  self.type_sdprod(RESULTAT,AsType(RESU_INIT))
  self.type_sdprod(MAILLAGE,maillage_sdaster)
  return None


MACR_ECLA_PG=MACRO(nom="MACR_ECLA_PG",
                   op=OPS('Macro.macr_ecla_pg_ops.macr_ecla_pg_ops'),
                   sd_prod=macr_ecla_pg_prod,
                   reentrant='n',
                   fr=tr("Permettre la visualisation des champs aux points de Gauss d'une "
                        "SD_RESULTAT sans lissage ni interpolation"),

             # SD résultat ,modèle et champs à "éclater" :
             RESU_INIT       =SIMP(statut='o',typ=resultat_sdaster,fr=tr("RESULTAT à éclater"),),
             MODELE_INIT     =SIMP(statut='o',typ=modele_sdaster,fr=tr("MODELE à éclater")),
             NOM_CHAM        =SIMP(statut='o',typ='TXM',validators=NoRepeat(),max='**',into=C_NOM_CHAM_INTO('ELGA'),),

             # paramètres numériques de la commande :
             SHRINK          =SIMP(statut='f',typ='R',defaut= 0.9, fr=tr("Facteur de réduction") ),
             TAILLE_MIN      =SIMP(statut='f',typ='R',defaut= 0.0, fr=tr("Taille minimale d'un coté") ),

             # concepts produits par la commande :
             RESULTAT        =SIMP(statut='o',typ=CO,fr=tr("SD_RESULTAT résultat de la commande")),
             MAILLAGE        =SIMP(statut='o',typ=CO,fr=tr("MAILLAGE associé aux cham_no de la SD_RESULTAT")),

             # Sélection éventuelle d'un sous-ensemble des éléments à visualiser :
             TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
             MAILLE          =SIMP(statut='c',typ=ma  ,validators=NoRepeat(),max='**'),
             GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),

             # Sélection des numéros d'ordre :
             regles=(EXCLUS('TOUT_ORDRE','NUME_ORDRE','INST','LIST_INST','LIST_ORDRE'),),
             TOUT_ORDRE      =SIMP(statut='f',typ='TXM',into=("OUI",) ),
             NUME_ORDRE      =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
             LIST_ORDRE      =SIMP(statut='f',typ=listis_sdaster),
             INST            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
             LIST_INST       =SIMP(statut='f',typ=listr8_sdaster),
             CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU",),),
             b_prec_rela=BLOC(condition="""(equal_to("CRITERE", 'RELATIF'))""",
                 PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
             b_prec_abso=BLOC(condition="""(equal_to("CRITERE", 'ABSOLU'))""",
                 PRECISION       =SIMP(statut='o',typ='R',),),
            )
