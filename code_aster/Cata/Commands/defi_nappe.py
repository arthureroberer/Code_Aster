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
# person_in_charge: mathieu.courtois at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


DEFI_NAPPE=OPER(nom="DEFI_NAPPE",op=4,sd_prod=nappe_sdaster,
                fr=tr("Définir une fonction réelle de deux variables réelles"),
                reentrant='n',
         regles=(UN_PARMI('FONCTION','DEFI_FONCTION'),
                 EXCLUS('FONCTION','NOM_PARA_FONC',),
                 ENSEMBLE('NOM_PARA_FONC','DEFI_FONCTION'),),
         NOM_PARA        =SIMP(statut='o',typ='TXM',into=C_PARA_FONCTION() ),
         NOM_RESU        =SIMP(statut='f',typ='TXM',defaut="TOUTRESU"),
         PARA            =SIMP(statut='o',typ='R',max='**'),
         FONCTION        =SIMP(statut='f',typ=fonction_sdaster, max='**' ),
         NOM_PARA_FONC   =SIMP(statut='f',typ='TXM',into=C_PARA_FONCTION() ),
         DEFI_FONCTION   =FACT(statut='f',max='**',
           VALE            =SIMP(statut='o',typ='R',max='**'),
           INTERPOL        =SIMP(statut='f',typ='TXM',max=2,defaut="LIN",into=("NON","LIN","LOG"),
                                 fr=tr("Type d'interpolation pour les abscisses et les ordonnées de la fonction.")),
           PROL_DROITE     =SIMP(statut='f',typ='TXM',defaut="EXCLU",into=("CONSTANT","LINEAIRE","EXCLU") ),
           PROL_GAUCHE     =SIMP(statut='f',typ='TXM',defaut="EXCLU",into=("CONSTANT","LINEAIRE","EXCLU") ),
         ),
         INTERPOL        =SIMP(statut='f',typ='TXM',max=2,defaut="LIN",into=("NON","LIN","LOG"),
                               fr=tr("Type d'interpolation pour le paramètre de la nappe")),
         PROL_DROITE     =SIMP(statut='f',typ='TXM',defaut="EXCLU",into=("CONSTANT","LINEAIRE","EXCLU") ),
         PROL_GAUCHE     =SIMP(statut='f',typ='TXM',defaut="EXCLU",into=("CONSTANT","LINEAIRE","EXCLU") ),
         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=(1, 2) ),
         VERIF           =SIMP(statut='f',typ='TXM',into=("CROISSANT",) ),
         TITRE           =SIMP(statut='f',typ='TXM'),
)  ;
