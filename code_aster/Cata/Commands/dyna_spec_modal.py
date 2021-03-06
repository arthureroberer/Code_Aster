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


DYNA_SPEC_MODAL=OPER(nom="DYNA_SPEC_MODAL",op= 147,sd_prod=interspectre,
                     fr=tr("Calcul de la réponse par recombinaison modale d'une structure linéaire pour une excitation aléatoire"),
                     reentrant='n',
         BASE_ELAS_FLUI  =SIMP(statut='o',typ=melasflu_sdaster ),
         VITE_FLUI      =SIMP(statut='o',typ='R'),
         PRECISION       =SIMP(statut='f',typ='R',defaut=1.0E-3 ),
         EXCIT           =FACT(statut='o',
           INTE_SPEC_GENE  =SIMP(statut='o',typ=interspectre),
         ),
         OPTION          =SIMP(statut='f',typ='TXM',defaut="TOUT",into=("TOUT","DIAG") ),
         TITRE           =SIMP(statut='f',typ='TXM'),
)  ;
