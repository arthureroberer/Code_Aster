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


DEFI_FONC_FLUI=OPER(nom="DEFI_FONC_FLUI",op= 142,sd_prod=fonction_sdaster,
                    reentrant='n',
            fr=tr("Définit un profil de vitesse d'écoulement fluide le long d'une poutre"),
            regles=(UN_PARMI('NOEUD_INIT','GROUP_NO_INIT',),
                    UN_PARMI('NOEUD_FIN','GROUP_NO_FIN',),),
         MAILLAGE        =SIMP(statut='o',typ=(maillage_sdaster) ),
         NOEUD_INIT      =SIMP(statut='c',typ=no,max=1),
         GROUP_NO_INIT   =SIMP(statut='f',typ=grno,max=1),
         NOEUD_FIN       =SIMP(statut='c',typ=no,max=1),
         GROUP_NO_FIN    =SIMP(statut='f',typ=grno,max=1),
         VITE            =FACT(statut='o',
           VALE            =SIMP(statut='f',typ='R',defaut= 1. ),
           PROFIL          =SIMP(statut='o',typ='TXM',into=("UNIFORME","LEONARD") ),
           NB_BAV          =SIMP(statut='f',typ='I',defaut= 0,into=( 0 , 2 , 3 ) ),
         ),
         INTERPOL        =SIMP(statut='f',typ='TXM',max=2,defaut="LIN",
                               into=("NON","LIN","LOG") ),
         PROL_DROITE     =SIMP(statut='f',typ='TXM',defaut="EXCLU",
                               into=("CONSTANT","LINEAIRE","EXCLU") ),
         PROL_GAUCHE     =SIMP(statut='f',typ='TXM' ,defaut="EXCLU",
                               into=("CONSTANT","LINEAIRE","EXCLU") ),
         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2 ) ),
         TITRE           =SIMP(statut='f',typ='TXM'),
)  ;
