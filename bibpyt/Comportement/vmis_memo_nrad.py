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

from cata_comportement import LoiComportement

loi = LoiComportement(
    nom            = 'VMIS_MEMO_NRAD',
    doc            =   """Loi élastoplastique de J.L.Chaboche à 2 variables cinématiques qui
   rend compte du comportement cyclique en élasto-plasticité avec 2 tenseurs
   d'écrouissage cinématique non linéaire, un écrouissage isotrope non linéaire,
   un effet d'écrouissage sur les variables
   tensorielles de rappel, un effet de mémoire du plus grand écrouissage, et
   prise en compte de la non proportionnalité du chargement.
   Toutes les constantes du matériau peuvent éventuellement dépendre de la
   température."""      ,
    num_lc         = 4,
    nb_vari        = 28,
    nom_vari       = ('EPSPEQ','INDIPLAS','ALPHAXX','ALPHAYY','ALPHAZZ',
        'ALPHAXY','ALPHAXZ','ALPHAYZ','ALPHA2XX','ALPHA2YY',
        'ALPHA2ZZ','ALPHA2XY','ALPHA2XZ','ALPHA2YZ','ECROISOT',
        'MEMOECRO','KSIXX','KSIYY','KSIZZ','KSIXY',
        'KSIXZ','KSIYZ','EPSPXX','EPSPYY','EPSPZZ',
        'EPSPXY','EPSPXZ','EPSPYZ',),
    mc_mater       = ('ELAS','CIN2_CHAB','MEMO_ECRO','CIN2_NRAD',),
    modelisation   = ('3D','AXIS','D_PLAN',),
    deformation    = ('PETIT','PETIT_REAC','GROT_GDEP','GDEF_LOG',),
    algo_inte      = ('BRENT','SECANTE',),
    type_matr_tang = ('PERTURBATION','VERIFICATION',),
    proprietes     = None,
    syme_matr_tang = ('Yes',),
)
