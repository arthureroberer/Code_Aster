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


PROJ_SPEC_BASE=OPER(nom="PROJ_SPEC_BASE",op= 146,sd_prod=interspectre,reentrant='n',
            fr=tr("Projecter un ou plusieurs spectres de turbulence sur une (ou plusieurs) base(s) modale(s) "),
      regles=(UN_PARMI('BASE_ELAS_FLUI','MODE_MECA','CHAM_NO'),
              UN_PARMI('TOUT','GROUP_MA','MAILLE'),
              PRESENT_PRESENT('CHAM_NO','MODELE_INTERFACE'),),
         SPEC_TURB      =SIMP(statut='o',typ=spectre_sdaster,validators=NoRepeat(),max='**' ),
         TOUT_CMP       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON")),
         BASE_ELAS_FLUI =SIMP(statut='f',typ=melasflu_sdaster ),
         b_fluide = BLOC(condition="""exists("BASE_ELAS_FLUI")""",
           VITE_FLUI      =SIMP(statut='o',typ='R'),
           PRECISION       =SIMP(statut='f',typ='R',defaut=1.0E-3 ),
         ),
         MODE_MECA      =SIMP(statut='f',typ=mode_meca ),
         CHAM_NO        =SIMP(statut='f',typ=cham_no_sdaster),
         FREQ_INIT      =SIMP(statut='o',typ='R',val_min=0.E+0 ),
         FREQ_FIN       =SIMP(statut='o',typ='R',val_min=0.E+0 ),
         NB_POIN        =SIMP(statut='o',typ='I' ),
         OPTION         =SIMP(statut='f',typ='TXM',defaut="TOUT",into=("TOUT","DIAG")),
         TOUT           =SIMP(statut='f',typ='TXM',into=("OUI",), ),
         GROUP_MA       =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
         MAILLE         =SIMP(statut='c',typ=ma,validators=NoRepeat(),max='**'),
#  Quel est le type attendu derriere  MODELE_INTERFACE
         MODELE_INTERFACE=SIMP(statut='f',typ=modele_sdaster),
         VECT_X         =SIMP(statut='f',typ='R',min=3,max=3 ),
         VECT_Y         =SIMP(statut='f',typ='R',min=3,max=3 ),
         ORIG_AXE       =SIMP(statut='f',typ='R',min=3,max=3 ),
         TITRE          =SIMP(statut='f',typ='TXM' ),
);
