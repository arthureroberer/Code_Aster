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
# person_in_charge: david.haboussa at edf.fr
#Quoi qu'il en soit, on sort la table GP
#Si on est sans copeau et que l'utilisateur souhaite verifier
#les copeaux automatiquement crees, il peut grace a CHAMP_COP
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def calc_gp_prod(self,TRANCHE_2D,GPMAX, **args):
  """Typage des sd_prod
  """
  if TRANCHE_2D:
    if TRANCHE_2D['ZONE_MAIL']== "NON":
        if TRANCHE_2D.get('CHAMP_VISU'):
          self.type_sdprod(TRANCHE_2D['CHAMP_VISU'], cham_elem)
  if GPMAX !=None:
     self.type_sdprod(GPMAX, table_sdaster)
  return table_sdaster


CALC_GP =MACRO(nom="CALC_GP",
                   op=OPS('Macro.calc_gp_ops.calc_gp_ops'),
                   sd_prod=calc_gp_prod,
#                   sd_prod=table_sdaster,
                   reentrant='n',
                   fr=tr("calcul du parametre de clivage energetique Gp en 2D et en 3D"),
                   regles=UN_PARMI('TRANCHE_2D','TRANCHE_3D'),
         RESULTAT    =SIMP(statut='o',typ=resultat_sdaster,
                                      fr=tr("Resultat d'une commande globale STAT_NON_LINE")),
         LIST_INST   = SIMP(statut='o',typ=(listr8_sdaster) ),
         PRECISION   = SIMP(statut='f',typ='R',validators=NoRepeat(),val_min=0.,val_max=1E-3,defaut=1E-6),
         CRITERE     = SIMP(statut='f',typ='TXM',defaut="ABSOLU",into=("RELATIF","ABSOLU") ),
         TRANCHE_2D  = FACT(statut='f',max = 1,
                           ZONE_MAIL     = SIMP(statut='o',typ='TXM',into=("NON","OUI") ),
                           b_cop= BLOC(condition = """equal_to("ZONE_MAIL", 'OUI')""",
                                       fr=tr("Les copeaux sont mailles"),
                                 GROUP_MA  = SIMP(statut='o', typ=grma, validators=NoRepeat(), max='**'),
                                 TAILLE   =SIMP(statut='o',typ=listr8_sdaster),),
                           b_ss_cop = BLOC(condition="""equal_to("ZONE_MAIL", 'NON')""",
                                           fr=tr("Les copeaux ne sont pas mailles"),
                                 CENTRE           =SIMP(statut='o',typ='R',max=2),
                                 RAYON       =SIMP(statut='o',typ='R',max=1),
                                 ANGLE            =SIMP(statut='o',typ='R',max=1),
                                 TAILLE          =SIMP(statut='o',typ='R',max=1),
                                 NB_ZONE        =SIMP(statut='o',typ='I',),
                                 CHAMP_VISU        =SIMP(statut='f',typ=CO),),
                             ),
         TRANCHE_3D  = FACT(statut='f',max ='**',
                           GROUP_MA  = SIMP(statut='o', typ=grma, validators=NoRepeat(), max='**'),
                             ),
         b_tranche_2d = BLOC(condition="""exists("TRANCHE_2D")""",
                 SYME            =SIMP(statut='o',typ='TXM',into=("NON","OUI"),
                      fr=tr("multiplication par 2 si SYME=OUI")),),
         b_tranche_3d = BLOC(condition="""exists("TRANCHE_3D")""",
                 FOND_FISS       =SIMP(statut='o',typ=fond_fiss,max=1,),),
         GPMAX           = SIMP(statut='f',typ=CO,),
           )
