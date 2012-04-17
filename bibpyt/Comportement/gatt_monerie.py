#@ MODIF gatt_monerie Comportement  DATE 16/04/2012   AUTEUR PROIX J-M.PROIX 
# -*- coding: iso-8859-1 -*-
#            CONFIGURATION MANAGEMENT OF EDF VERSION
# ======================================================================
# COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
# RESPONSABLE DEBONNIERES P.DEBONNIERES

from cata_comportement import LoiComportement

loi = LoiComportement(
   nom            = 'GATT_MONERIE',
   doc = """Comportement thermo-m�canique du combustible qui permet de simuler des essais d'indentation 
   (cf. [R5.03.08]). Cette loi de comportement est une loi �lasto-viscoplastique isotrope sans �crouissage 
   dont les sp�cificit�s sont :
 - le potentiel de dissipation est la somme de deux potentiels de type Norton (sans seuil),
 - le combustible pr�sentant une porosit� r�siduelle susceptible d'�voluer en compression (densification), 
   ce potentiel d�pend, en plus de la contrainte �quivalente, de la contrainte hydrostatique.""",
   num_lc         = 27,
   nb_vari        = 2,
   nom_vari       = ('EPSPEQ','FVOLPORO'),
   mc_mater       = ('ELAS', 'GATT_MONERIE'),
   modelisation   = ('3D', 'AXIS', 'D_PLAN'),
   deformation    = ('PETIT', 'PETIT_REAC', 'GROT_GDEP'),
   nom_varc       = ('TEMP', 'IRRA'),
   algo_inte         = ('DEKKER',),
   type_matr_tang = ('PERTURBATION', 'VERIFICATION'),
   proprietes     = None,
)

