#@ MODIF contact Messages  DATE 23/07/2007   AUTEUR ABBAS M.ABBAS 
# -*- coding: iso-8859-1 -*-
#            CONFIGURATION MANAGEMENT OF EDF VERSION
# ======================================================================
# COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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

def _(x) : return x

cata_msg={

1: _("""
La m�thode de r�solution du contact utilis�e suppose la sym�trie de la
matrice du syst�me � r�soudre.
Dans le cas o� votre mod�lisation ferait intervenir une matrice 
non-sym�trique, on force sa sym�trie. On �met une alarme pour vous 
en avertir. 

CONSEIL : 
Vous pouvez supprimer cette alarme en renseignant SYME='OUI' sous le 
mot-cl� facteur SOLVEUR.
"""),

2: _("""
Contact methode GCP. Nombre d'it�rations maximal (%(i1)s) d�pass� pour le GCP.
Vous pouvez essayer d'augmenter ITER_GCP_MAXI.
La liste des noeuds pr�sentant une interp�n�tration est donn�e ci-dessous.
"""),

3: _("""
Contact methode GCP. Nombre d'it�rations maximal (%(i1)s) d�pass� pour le pr�conditionneur.
Vous pouvez essayer d'augmenter ITER_PRE_MAXI
"""),

6: _("""
Contact methode GCP. On ne peut utiliser le solveur GCPC avec le contact 
"""),

7: _("""
Contact methode GCP. Le pas d'avancement est negatif ; risque de comportement hasardeux de l'algorithme
"""),

9: _("""
Contact liaison glissiere. Des noeuds se decollent plus que la valeur d'ALARME_JEU:
"""),

10: _("""
Contact methodes discretes. Une maille maitre de type SEG a une longueur nulle. Verifiez votre maillage.
"""),

11: _("""
Contact methodes discretes. Le vecteur tangent defini par VECT_Y est colineaire au vecteur normal.
"""),

12: _("""
Contact methodes discretes. Le vecteur normal est colineaire au plan de projection.
"""),

13: _("""
Contact methodes discretes. Il faut reactualiser la projection : contacter les developpeurs
"""),

14: _("""
Contact methodes discretes. La projection quadratique pour les triangles n'est pas disponible
"""),

15: _("""
Contact methodes discretes. Une maille maitre de type TRI a une surface nulle. Verifiez votre maillage.
"""),

22: _("""
Contact methodes discretes. Cette methode d'appariement n'existe pas : contacter les developpeurs.
"""),

23: _("""
Contact methodes discretes. Erreur d'appel par l'option d'appariement n'existe pas : contacter les developpeurs.
"""),

24: _("""
Contact methodes discretes. Erreur de dimensionnement nombre maximal de noeuds esclaves depasse : contacter les developpeurs
"""),

25: _("""
Contact methodes discretes. Erreur de dimensionnement des tableaux apcoef et apddl : contacter les developpeurs
"""),

27: _("""
Contact methodes discretes. On n'a pas trouve de noeud maitre proche du noeud esclave : contacter les developpeurs
"""),

30: _("""
Contact methodes discretes. On ne sait pas traiter ce type de maille
"""),

31: _("""
Contact methodes discretes. Le noeud esclave n'a pas pu s'apparier avec la maille quadrangle : contacter les developpeurs
"""),

32: _("""
Contact methodes discretes. Pas de lissage des normales possible avec l'appariement nodal : contacter les developpeurs
"""),

38: _("""
Contact. Erreur dans la definition symetrique : contacter les developpeurs
"""),

54: _("""
Contact. On ne peut pas utiliser une direction d'appariement fixe VECT_NORM_ESCL si l'appariement n'est pas nodal.
"""),

55: _("""
Contact. La commande VECT_Y n'intervient pas en 2D.
"""),

56: _("""
Contact. La commande VECT_ORIE_POU n'intervient pas en 2D.
"""),


60: _("""
Contact methodes discretes. Vous utilisez des mailles de type SEG2/SEG3 en 3D sans definir un repere pour l'appariement. Voir les mots-clefs VECT_Y et VECT_ORIE_POU.
"""),

74: _("""
Contact. Erreur de dimensionnement car le nombre de noeuds est superieur a 9 : contacter les developpeurs
"""),

75: _("""
Contact. Un POI1 ne peut pas etre une maille maitre.
"""),

76: _("""
Contact. On ne peut pas avoir plus de 3 ddls impliques dans la meme relation unilaterale : contacter les developpeurs
"""),

83: _("""
Contact. Il y a plusieurs charges contenant des conditions de contact.
"""),

84: _("""
Contact. Melange 2d et 3d dans le contact.
"""),

85: _("""
Contact. Melange dimensions maillage dans le contact.
"""),

86: _("""
Contact. Code methode contact incorrect : contacter les developpeurs
"""),

87: _("""
Contact. La norme tangentielle de frottement est negative: contacter les developpeurs
"""),

88: _("""
Contact. Ne pas utiliser REAC_INCR=0 avec le frottement.
"""),

93: _("""
Contact methode VERIF.
 -> Interp�n�trations des surfaces.
 -> Risque & Conseil :
    V�rifier si le niveau d'interp�n�tration des surfaces est acceptable dans
    votre probl�me.
"""),

94: _("""
Operation d'appariement inconnue : contacter les developpeurs
"""),

97: _("""
Contact methode CONTINUE. Pour l'option SANS_GROUP_NO, l'int�gration aux noeuds est obligatoire.
"""),



}
