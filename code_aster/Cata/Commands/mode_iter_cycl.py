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
# person_in_charge: mathieu.corus at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


MODE_ITER_CYCL=OPER(nom="MODE_ITER_CYCL",op=  80,sd_prod=mode_cycl,
                    fr=tr("Calcul des modes propres d'une structure à répétitivité cyclique à partir"
                        " d'une base de modes propres réels"),
                    reentrant='n',
         BASE_MODALE     =SIMP(statut='o',typ=mode_meca ),
         NB_MODE         =SIMP(statut='f',typ='I'),
         NB_SECTEUR      =SIMP(statut='o',typ='I' ),
         LIAISON         =FACT(statut='o',
           DROITE          =SIMP(statut='o',typ='TXM' ),
           GAUCHE          =SIMP(statut='o',typ='TXM' ),
           AXE             =SIMP(statut='f',typ='TXM' ),
         ),
         VERI_CYCL       =FACT(statut='f',
           PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-3 ),
           CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF",) ),
           DIST_REFE       =SIMP(statut='f',typ='R' ),
         ),
         CALCUL          =FACT(statut='o',
           regles=(UN_PARMI('TOUT_DIAM','NB_DIAM'),),
           TOUT_DIAM       =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           NB_DIAM         =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
           OPTION          =SIMP(statut='f',typ='TXM',defaut="PLUS_PETITE"
                                ,into=("PLUS_PETITE","CENTRE","BANDE") ),
           b_centre      =BLOC(condition = """equal_to("OPTION", 'CENTRE')""",
             FREQ            =SIMP(statut='o',typ='R',),
           ),
           b_bande       =BLOC(condition = """equal_to("OPTION", 'BANDE')""",
             FREQ            =SIMP(statut='o',typ='R',min=2,validators=NoRepeat(),max=2),
           ),
#  NMAX_FREQ n a-t-il pas un sens qu avec OPTION CENTRE                                
           NMAX_FREQ       =SIMP(statut='f',typ='I',defaut= 10 ),
           PREC_SEPARE     =SIMP(statut='f',typ='R',defaut= 100. ),
           PREC_AJUSTE     =SIMP(statut='f',typ='R',defaut= 1.E-6 ),
           NMAX_ITER       =SIMP(statut='f',typ='I',defaut= 50 ),
         ),
         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2) ),
)  ;
