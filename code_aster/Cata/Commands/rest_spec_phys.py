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
# person_in_charge: hassan.berro at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


REST_SPEC_PHYS=OPER(nom="REST_SPEC_PHYS",op= 148,sd_prod=interspectre,
                    reentrant='n',
            fr=tr("Calculer la réponse d'une structure dans la base physique"),
         regles=(AU_MOINS_UN('BASE_ELAS_FLUI','MODE_MECA'),
                 AU_MOINS_UN('NOEUD','GROUP_NO'),EXCLUS('NOEUD','GROUP_NO'),EXCLUS('MAILLE','GROUP_MA'),
                 ),
         BASE_ELAS_FLUI  =SIMP(statut='f',typ=melasflu_sdaster ),
         b_fluide = BLOC(condition="""exists("BASE_ELAS_FLUI")""",
           VITE_FLUI      =SIMP(statut='o',typ='R'),
           PRECISION       =SIMP(statut='f',typ='R',defaut=1.0E-3 ),
         ),
         MODE_MECA       =SIMP(statut='f',typ=mode_meca,),
         BANDE           =SIMP(statut='f',typ='R',min=2,validators=NoRepeat(),max=2    ),
         NUME_ORDRE      =SIMP(statut='f',typ='I'      ,validators=NoRepeat(),max='**' ),
         TOUT_ORDRE       =SIMP(statut='f',typ='TXM',defaut="NON",  into=("OUI","NON")  ),
         INTE_SPEC_GENE  =SIMP(statut='o',typ=interspectre),

         NOEUD      = SIMP(statut = 'c', typ=no  , max = '**'),
         GROUP_NO   = SIMP(statut = 'f', typ=grno, max = '**'),
         MAILLE     = SIMP(statut = 'c', typ=ma  , max = '**'),
         GROUP_MA   = SIMP(statut = 'f', typ=grma, max = '**'),

         NOM_CMP         =SIMP(statut='o',typ='TXM',max='**'),
         NOM_CHAM        =SIMP(statut='o',typ='TXM',validators=NoRepeat(),max=7,into=("DEPL",
                               "VITE","ACCE","EFGE_ELNO","SIPO_ELNO","SIGM_ELNO","FORC_NODA") ),
         MODE_STAT       =SIMP(statut='f',typ=mode_meca ),
         EXCIT           =FACT(statut='f',regles=(EXCLUS('NOEUD','GROUP_NO'),AU_MOINS_UN('NOEUD','GROUP_NO')),
           NOEUD           =SIMP(statut='c',typ=no   ,max='**'),
           GROUP_NO        =SIMP(statut='f',typ=grno ,max='**'),
           NOM_CMP         =SIMP(statut='o',typ='TXM',max='**'),
         ),
         MOUVEMENT       =SIMP(statut='f',typ='TXM',defaut="ABSOLU",into=("RELATIF","ABSOLU","DIFFERENTIEL") ),
         OPTION          =SIMP(statut='f',typ='TXM',defaut="DIAG_DIAG",
                               into=("DIAG_TOUT","DIAG_DIAG","TOUT_TOUT","TOUT_DIAG") ),
         TITRE           =SIMP(statut='f',typ='TXM' ),
)  ;
