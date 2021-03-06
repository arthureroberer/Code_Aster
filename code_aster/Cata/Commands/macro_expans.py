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


def macro_expans_prod(self, MODELE_MESURE, RESU_NX, RESU_EX, RESU_ET, RESU_RD, **args):
    RESU_EXP = MODELE_MESURE['MESURE']
    self.type_sdprod(RESU_NX, mode_meca)
    for res in (RESU_EX, RESU_ET, RESU_RD):
        if res is not None and res.is_typco():
            if AsType(RESU_EXP) == mode_meca:
                self.type_sdprod(res, mode_meca)
            else:
                self.type_sdprod(res, dyna_harmo)
    return None

MACRO_EXPANS=MACRO(nom="MACRO_EXPANS",
                   op=OPS('Macro.macro_expans_ops.macro_expans_ops'),
                   sd_prod=macro_expans_prod,
                   reentrant='n',
                   fr=tr("Outil d'expansion de resultats exprimentaux sur une base definie sur un modele numerique"),
                        MODELE_CALCUL   = FACT(statut='o',
                           MODELE          = SIMP(statut='o',typ=(modele_sdaster) ),
                           BASE            = SIMP(statut='o',typ=(mode_meca,) ),
                           NUME_MODE       = SIMP(statut='f',typ='I',validators=NoRepeat(),max='**',defaut=0),
                           NUME_ORDRE      = SIMP(statut='f',typ='I',validators=NoRepeat(),max='**',defaut=0),

                                             ),
                        MODELE_MESURE   = FACT(statut='o',
                           MODELE          = SIMP(statut='o',typ=(modele_sdaster) ),
                           MESURE          = SIMP(statut='o',typ=(dyna_trans,dyna_harmo,mode_meca,mode_meca_c,) ),
                           NOM_CHAM        = SIMP(statut='f',typ='TXM',defaut="DEPL",
                                                  into=("DEPL","VITE","ACCE","SIEF_NOEU","EPSI_NOEU",) ),
                           NUME_MODE       = SIMP(statut='f',typ='I',validators=NoRepeat(),max='**',defaut=0),
                           NUME_ORDRE      = SIMP(statut='f',typ='I',validators=NoRepeat(),max='**',defaut=0),

                                             ),
                        NUME_DDL       = SIMP(statut='f',typ=(nume_ddl_sdaster)),
                        RESU_NX        = SIMP(statut='f',typ=(mode_meca,dyna_harmo, CO)),
                        RESU_EX        = SIMP(statut='f',typ=(mode_meca,dyna_harmo, CO)),
                        RESU_ET        = SIMP(statut='f',typ=(mode_meca,dyna_harmo, CO)),
                        RESU_RD        = SIMP(statut='f',typ=(mode_meca,dyna_harmo, CO)),
                        RESOLUTION     = FACT(statut='f',
                           METHODE =SIMP(statut='f',typ='TXM',defaut="LU",into=("LU","SVD",) ),
                           b_svd   =BLOC(condition="""equal_to("METHODE", 'SVD')""",
                                         EPS=SIMP(statut='f',typ='R',defaut=0. ),
                                        ),
                           REGUL   =SIMP(statut='f',typ='TXM',defaut="NON",into=("NON","NORM_MIN","TIK_RELA",) ),
                           b_regul =BLOC(condition="""not equal_to("REGUL", 'NON')""",
                                         regles=(PRESENT_ABSENT('COEF_PONDER','COEF_PONDER_F', ),),
                                         COEF_PONDER   =SIMP(statut='f',typ='R',defaut=0.     ,max='**' ),
                                         COEF_PONDER_F =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule),max='**' ),
                                        ),
                                             ),
                   )
