#@ MODIF proba0 Messages  DATE 07/11/2011   AUTEUR COURTOIS M.COURTOIS 
# -*- coding: iso-8859-1 -*-
#            CONFIGURATION MANAGEMENT OF EDF VERSION
# ======================================================================
# COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
# RESPONSABLE DELMAS J.DELMAS

cata_msg={
1: _(u"""
  Il faut BORNE_INF < BORNE_SUP
  BORNE_INF = %(r1)f
  BORNE_SUP = %(r2)f
"""),

2: _(u"""
  VALE_MOY trop grand ou trop petit
  BORNE_INF = %(r1)f
  VALE_MOY  = %(r2)f
  BORNE_SUP = %(r3)f
"""),

3: _(u"""
  BORNE SUP tr�s grande, probl�me de pr�cision possible,
  v�rifiez la distribution des valeurs g�n�r�es.
"""),

4: _(u"""
  On doit avoir : VALE_MOY > BORNE_INF 
  VALE_MOY  = %(r1)f
  BORNE_INF = %(r2)f
"""),

5: _(u"""
  Erreur : ALPHA < 1
"""),

6: _(u"""
  Erreur : UNIF < 0
"""),

7: _(u"""
  Erreur : GAMDEV(ALPHA) < 0
"""),

8: _(u"""
  Il faut autant d'indices en I et J.
"""),

9: _(u"""
  Il faut autant de composantes en I et J.
"""),

10: _(u"""
  Il faut autant de composantes que de noeuds.
"""),

11: _(u"""
  Nombre de tirages sup�rieur a la taille de l'�chantillon.
"""),



}
