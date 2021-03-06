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
# person_in_charge: josselin.delmas at edf.fr


from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


MACR_LIGN_COUPE=MACRO(nom="MACR_LIGN_COUPE",
                      op=OPS('Macro.macr_lign_coupe_ops.macr_lign_coupe_ops'),
                      sd_prod=table_sdaster,
                      reentrant='n',
                      fr=tr("Extraction des valeurs d'un résultat dans une ou plusieurs tables sur "
                           "des lignes de coupe définies par deux points et un intervalle"),
            regles=(UN_PARMI("RESULTAT","CHAM_GD"),),

         RESULTAT        =SIMP(statut='f',typ=(evol_elas,evol_noli,evol_ther,mode_meca,
                                               comb_fourier, mult_elas, fourier_elas) ),
         CHAM_GD         =SIMP(statut='f',typ=(cham_gd_sdaster)),

         b_extrac        =BLOC(condition = """exists("RESULTAT")""",fr=tr("extraction des résultats"),
                                 regles=(EXCLUS('NUME_ORDRE','NUME_MODE','LIST_ORDRE','INST','LIST_INST',), ),
             NUME_ORDRE      =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
             NUME_MODE       =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
             LIST_ORDRE      =SIMP(statut='f',typ=listis_sdaster),
             INST            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
             LIST_INST       =SIMP(statut='f',typ=listr8_sdaster),
             CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU",),),
             b_prec_rela=BLOC(condition="""(equal_to("CRITERE", 'RELATIF'))""",
                 PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
             b_prec_abso=BLOC(condition="""(equal_to("CRITERE", 'ABSOLU'))""",
                 PRECISION       =SIMP(statut='o',typ='R',),),
           ),

# extraction des résultats
         b_meca        =BLOC(condition = """is_type("RESULTAT") in (evol_elas,evol_noli,mode_meca, comb_fourier,
                                            mult_elas, fourier_elas)""",fr=tr("résultat mécanique"),
           NOM_CHAM        =SIMP(statut='f',typ='TXM',validators=NoRepeat(),defaut='SIGM_NOEU',into=C_NOM_CHAM_INTO(),),
         ),
         b_ther        =BLOC(condition = """is_type("RESULTAT") in (evol_ther,)""",fr=tr("résultat thermique"),
           NOM_CHAM        =SIMP(statut='f',typ='TXM',validators=NoRepeat(),defaut='TEMP',into=("TEMP",
                                 "FLUX_ELGA","FLUX_ELNO","FLUX_NOEU",
                                 "META_ELNO","META_NOEU",
                                 "DURT_ELNO","DURT_NOEU",
                                 "HYDR_ELNO","HYDR_NOEU",
                                 "DETE_ELNO","DETE_NOEU",
                                 "SOUR_ELGA","COMPORTHER",
                                 "ERTH_ELEM","ERTH_ELNO","ERTH_NOEU",),),),
         b_cham       =BLOC(condition = """exists("CHAM_GD")""",
           NOM_CHAM        =SIMP(statut='f',typ='TXM',validators=NoRepeat(),into=C_NOM_CHAM_INTO(),),),

         UNITE_MAILLAGE  =SIMP(statut='f',typ=UnitType(),defaut=25, inout='out'),
         MODELE          =SIMP(statut='f',typ=modele_sdaster ),

         VIS_A_VIS       =FACT(statut='f',max='**',
                             regles=(EXCLUS('GROUP_MA_1','MAILLE_1'),),
           GROUP_MA_1        =SIMP(statut='f',typ=grma),
           MAILLE_1          =SIMP(statut='c',typ=ma,max='**'),),

         LIGN_COUPE     =FACT(statut='o',max='**',
            regles=(EXCLUS("NOM_CMP","INVARIANT","ELEM_PRINCIPAUX","RESULTANTE"),
                    PRESENT_PRESENT("TRAC_DIR","DIRECTION"),
                    EXCLUS("TRAC_DIR","TRAC_NOR"),
                    PRESENT_PRESENT("TRAC_DIR","NOM_CMP"),
                    PRESENT_PRESENT("TRAC_NOR","NOM_CMP"),),

           INTITULE        =SIMP(statut='f',typ='TXM',),
           TYPE            =SIMP(statut='o',typ='TXM',max=1,
                                 into=("GROUP_NO","SEGMENT","ARC","GROUP_MA"),defaut="SEGMENT"),
           REPERE          =SIMP(statut='f',typ='TXM',defaut="GLOBAL",
                                into=("GLOBAL","LOCAL","POLAIRE","UTILISATEUR","CYLINDRIQUE"),),
           OPERATION       =SIMP(statut='f',typ='TXM',into=("EXTRACTION","MOYENNE",),defaut="EXTRACTION",),

           NOM_CMP         =SIMP(statut='f',typ='TXM',max='**'),
           INVARIANT       =SIMP(statut='f',typ='TXM',into=("OUI",),),
           ELEM_PRINCIPAUX =SIMP(statut='f',typ='TXM',into=("OUI",),),
           RESULTANTE      =SIMP(statut='f',typ='TXM',max='**',into=("DX","DY","DZ")),
           TRAC_NOR        =SIMP(statut='f',typ='TXM',into=("OUI",)),
           TRAC_DIR        =SIMP(statut='f',typ='TXM',into=("OUI",)),
           DIRECTION       =SIMP(statut='f',typ='R',max='**'),


           b_local        =BLOC(condition = """equal_to("REPERE", 'LOCAL') """,
             VECT_Y          =SIMP(statut='f',typ='R',min=2,max=3),),

           b_utili        =BLOC(condition = """equal_to("REPERE", 'UTILISATEUR')""",
             ANGL_NAUT       =SIMP(statut='o',typ='R',min=3,max=3),),

           b_grno          =BLOC(condition = """equal_to("TYPE", 'GROUP_NO')""",
             GROUP_NO        =SIMP(statut='o',typ=grno, max=1),),

           b_grma          =BLOC(condition = """equal_to("TYPE", 'GROUP_MA')""",
                                 regles=(EXCLUS('NOEUD_ORIG','GROUP_NO_ORIG'),
                                         EXCLUS('NOEUD_EXTR','GROUP_NO_EXTR'),),
             GROUP_MA        =SIMP(statut='o',typ=grma, max=1),
             MAILLAGE        =SIMP(statut='o',typ=maillage_sdaster),
             # si le groupe de mailles forme une ligne ouverte, on peut choisir le sens de parcours en choissant l'origine:
             # si le groupe de mailles forme une ligne fermée, il FAUT choisir l'origine et l'extrémité (= origine):
             NOEUD_ORIG      =SIMP(statut='c',typ=no),
             GROUP_NO_ORIG   =SIMP(statut='f',typ=grno),
             NOEUD_EXTR      =SIMP(statut='c',typ=no),
             GROUP_NO_EXTR   =SIMP(statut='f',typ=grno),
             # si le groupe de mailles forme une ligne fermée, on peut choisir le sens de parcours
             VECT_ORIE       =SIMP(statut='f',typ='R',max=3),  # utilisé seulement si NOEUD_ORIG=NOEUD_EXTR
             ),

           b_segment       =BLOC(condition = """equal_to("TYPE", 'SEGMENT')""",
             NB_POINTS       =SIMP(statut='o',typ='I',max=1),
             COOR_ORIG       =SIMP(statut='o',typ='R',min=2,max=3),
             COOR_EXTR       =SIMP(statut='o',typ='R',min=2,max=3),),

           b_arc           =BLOC(condition = """equal_to("TYPE", 'ARC')""",
             NB_POINTS       =SIMP(statut='o',typ='I',max=1),
             COOR_ORIG       =SIMP(statut='o',typ='R',min=2,max=3),
             CENTRE          =SIMP(statut='o',typ='R',min=2,max=3),
             ANGLE           =SIMP(statut='o',typ='R',max=1),
             DNOR            =SIMP(statut='f',typ='R',min=2,max=3),),

           b_cylind       =BLOC(condition = """equal_to("REPERE", 'CYLINDRIQUE') and not equal_to("TYPE", 'ARC')""",
             ORIGINE         =SIMP(statut='f',typ='R',min=2,max=3),
             AXE_Z           =SIMP(statut='f',typ='R',min=3,max=3),),

           DISTANCE_MAX    =SIMP(statut='f',typ='R', defaut=0.,
                fr=tr("Si la distance entre un noeud de la ligne de coupe et le maillage coupé "
                "est > DISTANCE_MAX, ce noeud sera ignoré.")),
           DISTANCE_ALARME =SIMP(statut='f',typ='R',
                fr=tr("Si la distance entre un noeud de la ligne de coupe et le maillage coupé "
                "est > DISTANCE_ALARME, une alarme sera émise.")),

         ),
)
