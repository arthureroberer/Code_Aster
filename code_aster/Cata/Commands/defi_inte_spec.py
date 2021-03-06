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
# person_in_charge: irmela.zentner at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


DEFI_INTE_SPEC=OPER(nom="DEFI_INTE_SPEC",op= 115,
                    sd_prod=interspectre,
                    reentrant='n',
                    fr=tr("Définit une matrice interspectrale"),

         DIMENSION       =SIMP(statut='f',typ='I',defaut= 1 ),

         regles=(UN_PARMI('PAR_FONCTION','KANAI_TAJIMI','CONSTANT'),),

         PAR_FONCTION    =FACT(statut='f',max='**',
           regles=(UN_PARMI('NUME_ORDRE_I','NOEUD_I'),),
           NOEUD_I         =SIMP(statut='f',typ=no,max=1,),
           NUME_ORDRE_I    =SIMP(statut='f',typ='I',max=1),
           b_nume_ordre_i = BLOC (condition = """exists("NUME_ORDRE_I")""",
             NUME_ORDRE_J    =SIMP(statut='o',typ='I',max=1),
           ),
           b_noeud_i = BLOC (condition = """exists("NOEUD_I")""",
             NOEUD_J         =SIMP(statut='o',typ=no,max=1,),
             NOM_CMP_I       =SIMP(statut='o',typ='TXM',max=1,),
             NOM_CMP_J       =SIMP(statut='o',typ='TXM',max=1,),
           ),
           FONCTION        =SIMP(statut='o',typ=(fonction_sdaster,fonction_c ),max=1),
         ),

         KANAI_TAJIMI    =FACT(statut='f',max='**',
           regles=(EXCLUS('VALE_R','VALE_C'),
                   UN_PARMI('NUME_ORDRE_I','NOEUD_I'),),
           NUME_ORDRE_I    =SIMP(statut='f',typ='I',max=1),
           NOEUD_I         =SIMP(statut='f',typ=no,max=1,),
           b_nume_ordre_i = BLOC (condition = """exists("NUME_ORDRE_I")""",
             NUME_ORDRE_J    =SIMP(statut='o',typ='I',max=1),
           ),
           b_noeud_i = BLOC (condition = """exists("NOEUD_I")""",
             NOEUD_J         =SIMP(statut='o',typ=no,max=1,),
             NOM_CMP_I       =SIMP(statut='o',typ='TXM',max=1,),
             NOM_CMP_J       =SIMP(statut='o',typ='TXM',max=1,),
           ),
           FREQ_MIN        =SIMP(statut='f',typ='R',defaut= 0.E+0 ),
           FREQ_MAX        =SIMP(statut='f',typ='R',defaut= 100. ),
           PAS             =SIMP(statut='f',typ='R',defaut= 1. ),
           AMOR_REDUIT     =SIMP(statut='f',typ='R',defaut= 0.6 ),
           FREQ_MOY        =SIMP(statut='f',typ='R',defaut= 5. ),
           VALE_R          =SIMP(statut='f',typ='R' ),
           VALE_C          =SIMP(statut='f',typ='C' ),
           INTERPOL        =SIMP(statut='f',typ='TXM',max=2,defaut="LIN",into=("NON","LIN","LOG") ),
           PROL_DROITE     =SIMP(statut='f',typ='TXM',defaut="EXCLU",into=("CONSTANT","LINEAIRE","EXCLU") ),
           PROL_GAUCHE     =SIMP(statut='f',typ='TXM',defaut="EXCLU",into=("CONSTANT","LINEAIRE","EXCLU") ),
         ),
         CONSTANT        =FACT(statut='f',max='**',
           regles=(EXCLUS('VALE_R','VALE_C'),
                   UN_PARMI('NUME_ORDRE_I','NOEUD_I'),),
           NUME_ORDRE_I    =SIMP(statut='f',typ='I',max=1),
           NOEUD_I         =SIMP(statut='f',typ=no,max=1,),
           b_nume_ordre_i = BLOC (condition = """exists("NUME_ORDRE_I")""",
             NUME_ORDRE_J    =SIMP(statut='o',typ='I',max=1),
           ),
           b_noeud_i = BLOC (condition = """exists("NOEUD_I")""",
             NOEUD_J         =SIMP(statut='o',typ=no,max=1,),
             NOM_CMP_I       =SIMP(statut='o',typ='TXM',max=1,),
             NOM_CMP_J       =SIMP(statut='o',typ='TXM',max=1,),
           ),
           FREQ_MIN        =SIMP(statut='f',typ='R',defaut= 0.E+0 ),
           FREQ_MAX        =SIMP(statut='f',typ='R',defaut= 100. ),
           PAS             =SIMP(statut='f',typ='R',defaut= 1. ),
           VALE_R          =SIMP(statut='f',typ='R' ),
           VALE_C          =SIMP(statut='f',typ='C' ),
           INTERPOL        =SIMP(statut='f',typ='TXM',max=2,defaut="LIN",into=("NON","LIN","LOG") ),
           PROL_DROITE     =SIMP(statut='f',typ='TXM',defaut="EXCLU",into=("CONSTANT","LINEAIRE","EXCLU") ),
           PROL_GAUCHE     =SIMP(statut='f',typ='TXM',defaut="EXCLU",into=("CONSTANT","LINEAIRE","EXCLU") ),
         ),
         TITRE           =SIMP(statut='f',typ='TXM'),
         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2) ),
)  ;
