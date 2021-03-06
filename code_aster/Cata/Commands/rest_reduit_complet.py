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
# person_in_charge: mickael.abbas@edf.fr
#
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def post_champ_prod(RESULTAT_REDUIT,**args):
    if (AsType(RESULTAT_REDUIT) == evol_noli):
        return evol_noli
    if (AsType(RESULTAT_REDUIT) == evol_ther):
        return evol_ther

REST_REDUIT_COMPLET=OPER(nom="REST_REDUIT_COMPLET",op=54,
                         sd_prod=post_champ_prod,
                         reentrant='f',
    reuse = SIMP(statut='c', typ=CO),
    MODELE           = SIMP(statut='o',typ=modele_sdaster),
    RESULTAT_REDUIT  = SIMP(statut='o',typ=resultat_sdaster,max=1),
    BASE_PRIMAL      = SIMP(statut='o',typ=mode_empi,max=1),
    BASE_DUAL        = SIMP(statut='o',typ=mode_empi,max=1),
    INFO             = SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2) ),
    TITRE            = SIMP(statut='f',typ='TXM'),
) ;
