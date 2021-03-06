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

cata_msg = {

    8 : _(u"""
 arrêt sur maillage non squelette
"""),

    10 : _(u"""
 problème de duplication de la matrice :  %(k1)s
"""),

    11 : _(u"""
  arrêt problème de factorisation
  présence de modes de corps rigide
"""),

    17 : _(u"""
 arrêt sur problème base modale sans INTERF_DYNA
 base modale -->  %(k1)s
"""),

    26 : _(u"""
 conflit de nom de groupe de maille dans le squelette
 le nom de groupe               :  %(k1)s
 provenant de la sous-structure :  %(k2)s
 et du groupe de maille         :  %(k3)s
 existe déjà.
 %(k4)s
"""),

    27 : _(u"""
 nom de groupe non trouvé
 le groupe :  %(k1)s n'existe pas  %(k2)s dans la sous-structure :  %(k3)s
"""),

    28 : _(u"""
 aucun axe de rotation défini
"""),

    35 : _(u"""
 numéro de mode de votre liste inexistant dans les modes utilisés:
 numéro dans votre liste : %(i1)d
"""),

    39 : _(u"""
 choc mal défini
 la maille définissant le choc  %(k1)s doit être de type  %(k2)s
"""),

    41 : _(u"""
 trop de noeuds dans le GROUP_NO  %(k1)s
 noeud utilisé:  %(k2)s
"""),

    44 : _(u"""
 Aucun des chargements présents ne correspond à une excitation de type MULT_APPUI.
 Aucune correction n'est alors apportée aux résultats, calculés en relatif.
"""),

    46 : _(u"""
 Il manque les modes statiques. Vérifiez que MODE_STAT est bien renseigné.
"""),

    47 : _(u"""
 Il manque les modes corrigés. Vérifiez que MODE_CORR est bien renseigné.
"""),

    48 : _(u"""
 Nombre de modes propres calcules insuffisant.
 Nombre de modes propres de la base limite à : %(i1)d
"""),

    49 : _(u"""
 sous-structure inexistante dans le modèle généralisé
 modèle généralisé       -->  %(k1)s
 sous-structure demandée -->  %(k2)s
"""),

    50 : _(u"""
 sous-structure inexistante dans le modèle généralisé
 modèle généralisé              -->  %(k1)s
 numéro sous-structure demandée -->  %(i1)d
"""),

    69 : _(u"""
Le noeud %(k1)s n'est pas du bon type
Ce message est un message d'erreur développeur.
Contactez le support technique.
    '
"""),

    75 : _(u"""
 détection d'une sous-structure non connectée
 sous-structure de nom: %(k1)s
"""),

    76 : _(u"""
 arrêt sur problème de connexion sous-structure
"""),

    78 : _(u"""
 les intervalles doivent être croissants
 valeur de la borne précédente :  %(i1)d
 valeur de la borne            :  %(i2)d
"""),

    79 : _(u"""
 l'intervalle entre les  deux derniers instants ne sera pas égal au pas courant :  %(i1)d
 pour l'intervalle  %(i2)d
"""),

    80 : _(u"""
 le nombre de pas est trop grand :  %(i1)d , pour l'intervalle  %(i2)d
"""),

    81 : _(u"""
 les valeurs doivent être croissantes
 valeur précédente :  %(i1)d
 valeur            :  %(i2)d
"""),

    82 : _(u"""
 la distance entre les deux derniers réels ne sera pas égale
 au pas courant :  %(r1)f,
 pour l'intervalle  %(i1)d
"""),

    99 : _(u"""
 matrice d'amortissement non créée dans le macro-élément :  %(k1)s
"""),

}
