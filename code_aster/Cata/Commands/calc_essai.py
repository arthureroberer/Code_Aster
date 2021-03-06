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


def calc_essai_prod(self,RESU_IDENTIFICATION,
                    RESU_MODIFSTRU,
                    **args):

    if RESU_IDENTIFICATION != None:
        for res in RESU_IDENTIFICATION:
            self.type_sdprod(res['TABLE'],interspectre)

    MTYPES = {
        'MODELE'    : modele_sdaster,
        'MODE_MECA' : mode_meca,
        'NUME_DDL'  : nume_ddl_sdaster,
        'MAILLAGE'  : maillage_sdaster,
        'MASS_MECA' : matr_asse_depl_r,
        'RIGI_MECA' : matr_asse_depl_r,
        'AMOR_MECA' : matr_asse_depl_r,
        'MACR_ELEM' : macr_elem_stat,
        'PROJ_MESU' : mode_gene,
        'BASE_ES'   : mode_meca,
        'BASE_LMME' : mode_meca,
        'MODE_STA'  : mode_meca,
              }
    if RESU_MODIFSTRU != None:
        for res in RESU_MODIFSTRU:
            for mc, typ in MTYPES.items():
                if res[mc]:
                    self.type_sdprod(res[mc], typ)
    return None


CALC_ESSAI = MACRO(nom       = 'CALC_ESSAI',
                   op        = OPS('Macro.calc_essai_ops.calc_essai_ops'),
                   sd_prod   = calc_essai_prod,
                   reentrant = 'n',
                   fr        = tr("Outil de post-traitement interactif pour Meidee "),
                   INTERACTIF  = SIMP( statut='f',typ='TXM',into=('OUI','NON'),defaut='OUI' ),
                   RESU_IDENTIFICATION = FACT( statut='f',max='**',
                                               TABLE = SIMP(statut='f', typ=CO),
                                             ),
                   RESU_MODIFSTRU = FACT( statut='f', max=1,
                                          MODELE=SIMP(statut='f',typ=CO,defaut=None),
                                          MODE_MECA=SIMP(statut='f',typ=CO,defaut=None),
                                          MAILLAGE=SIMP(statut='f',typ=CO,defaut=None),
                                          NUME_DDL=SIMP(statut='f',typ=CO,defaut=None),
                                          MASS_MECA=SIMP(statut='f',typ=CO,defaut=None),
                                          RIGI_MECA=SIMP(statut='f',typ=CO,defaut=None),
                                          AMOR_MECA=SIMP(statut='f',typ=CO,defaut=None),
                                          MACR_ELEM=SIMP(statut='f',typ=CO,defaut=None),
                                          PROJ_MESU=SIMP(statut='f',typ=CO,defaut=None),
                                          BASE_ES=SIMP(statut='f',typ=CO,defaut=None),
                                          BASE_LMME=SIMP(statut='f',typ=CO,defaut=None),
                                          MODE_STA=SIMP(statut='f',typ=CO,defaut=None),
                                         ),

                   b_inter    = BLOC( condition="""equal_to("INTERACTIF", 'NON')""",

                             EXPANSION        = FACT( statut='f',max='**',
                                                      CALCUL           = SIMP(statut='o',typ=mode_meca),
                                                      NUME_MODE_CALCUL = SIMP(statut='f',typ='I',validators=NoRepeat(),
                                                                              max='**',defaut=0),
                                                      MESURE           = SIMP(statut='o',typ=mode_meca),
                                                      NUME_MODE_MESURE = SIMP(statut='f',typ='I',validators=NoRepeat(),
                                                                              max='**',defaut=0),
                                                      RESOLUTION       = SIMP(statut='f',typ='TXM',defaut='SVD',into=('SVD','LU')),
                                                      b_reso           = BLOC(condition = """equal_to("RESOLUTION", 'SVD')""",
                                                                              EPS = SIMP(statut='f',typ='R', defaut = 0.)
                                                                       )
                                                    ),
                             IDENTIFICATION   = FACT( statut='f',max='**',
                                                      ALPHA   = SIMP(statut='f',typ='R', defaut = 0.),
                                                      EPS     = SIMP(statut='f',typ='R', defaut = 0.),
                                                      OBSERVABILITE  = SIMP(statut='o',typ=mode_meca),
                                                      COMMANDABILITE = SIMP(statut='o',typ=mode_meca),
                                                      INTE_SPEC      = SIMP(statut='o',typ=interspectre),
                                                      RESU_EXPANSION = SIMP(statut='f',typ='TXM',defaut='NON',into=('OUI','NON')),
                                                      BASE           = SIMP(statut='o',typ=mode_meca),
                                                     ),
                             MODIFSTRUCT = FACT( statut='f', max=1,
                                                 MESURE = SIMP(statut='o', typ=mode_meca),
                                                 MODELE_SUP = SIMP(statut='o', typ=modele_sdaster),
                                                 MATR_RIGI = SIMP(statut='o', typ=matr_asse_depl_r),
                                                 RESOLUTION = SIMP(statut='f', typ='TXM',
                                                               into=('ES', 'LMME'), defaut='ES'),
                                                 b_resol = BLOC( condition = """equal_to("RESOLUTION", 'LMME')""",
                                                                 MATR_MASS = SIMP(statut='o', typ=matr_asse_depl_r),
                                                                ),
                                                 NUME_MODE_MESU   = SIMP(statut='o', typ='I',max='**'),
                                                 NUME_MODE_CALCUL = SIMP(statut='o', typ='I',max='**'),
                                                 MODELE_MODIF = SIMP(statut='o', typ=modele_sdaster),
                                               ),
                             # Si on realise une modification structurale, on donne les DDL capteurs et interface
                             b_modif   = BLOC( condition="""exists("MODIFSTRUCT")""",
                                   GROUP_NO_CAPTEURS  = FACT( statut='f', max='**',
                                                              GROUP_NO = SIMP(statut='o',typ=grno,),
                                                              NOM_CMP  = SIMP(statut='o',typ='TXM', max='**'),
                                                            ),
                                   GROUP_NO_EXTERIEUR = FACT( statut='f', max='**',
                                                              GROUP_NO = SIMP(statut='o',typ=grno,),
                                                              NOM_CMP  = SIMP(statut='o',typ='TXM', max='**'),
                                                            ),
                                               ),
                                          ),
                        );
