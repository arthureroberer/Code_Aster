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
# person_in_charge: harinaivo.andriambololona at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


RECU_GENE=OPER(nom="RECU_GENE",op=  76,sd_prod=vect_asse_gene,reentrant='n',
               fr=tr("Extraire d'un champ de grandeur (déplacements, vitesses ou accélérations) à partir de résultats"
                   " en coordonnées généralisées"),
               regles=(UN_PARMI('FREQ','INST',),),
         RESU_GENE       =SIMP(statut='o',typ=(tran_gene,harm_gene),),
         INST            =SIMP(statut='f',typ='R',),
         FREQ            =SIMP(statut='f',typ='R',),
         NOM_CHAM        =SIMP(statut='f',typ='TXM',defaut="DEPL",into=("DEPL","VITE","ACCE",),),
         b_interp_temp=BLOC(condition="""exists("INST") and not exists("FREQ")""",
             INTERPOL        =SIMP(statut='f',typ='TXM',defaut="NON",into=("NON","LIN",),),
             CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU",),),
             b_prec_rela=BLOC(condition="""(equal_to("CRITERE", 'RELATIF'))""",
                 PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
             b_prec_abso=BLOC(condition="""(equal_to("CRITERE", 'ABSOLU'))""",
                 PRECISION       =SIMP(statut='o',typ='R',),),),
)  ;
