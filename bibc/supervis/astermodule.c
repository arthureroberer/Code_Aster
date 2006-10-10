/* ------------------------------------------------------------------ */
/*           CONFIGURATION MANAGEMENT OF EDF VERSION                  */
/* MODIF astermodule supervis  DATE 10/10/2006   AUTEUR MCOURTOI M.COURTOIS */
/* ================================================================== */
/* COPYRIGHT (C) 1991 - 2001  EDF R&D              WWW.CODE-ASTER.ORG */
/*                                                                    */
/* THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR      */
/* MODIFY IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS     */
/* PUBLISHED BY THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE */
/* LICENSE, OR (AT YOUR OPTION) ANY LATER VERSION.                    */
/* THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL,    */
/* BUT WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF     */
/* MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU   */
/* GENERAL PUBLIC LICENSE FOR MORE DETAILS.                           */
/*                                                                    */
/* YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE  */
/* ALONG WITH THIS PROGRAM; IF NOT, WRITE TO : EDF R&D CODE_ASTER,    */
/*    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.     */
/* ================================================================== */
/* RESPONSABLE                                 D6BHHJP J.P.LEFEBVRE   */
/* ------------------------------------------------------------------ */

#include <stdio.h>
#include "Python.h"
#include <math.h>
#include <ctype.h>


#ifndef min
#define min(A,B)  ((A) < (B) ? (A) : (B))
#endif

#define VARIABLE_LEN 16




#ifndef UTILITES_H        /*{*/
#define UTILITES_H


/* pour indiquer le  statut des arguments des fonctions. */

#ifdef _IN
#error  _IN est deja definie
#endif
#define _IN

#ifdef _OUT
#error  _OUT est deja definie
#endif
#define _OUT

#ifdef _INOUT
#error  _INOUT est deja definie
#endif
#define _INOUT

#ifdef _UNUSED
#error  _UNUSED est deja definie
#endif
#define _UNUSED

/* Pour d�finir les appels et signatures de fonctions appelables en Fortran
 * On utilise l'operateur de concatenation ## du pr�processeur C (cpp) pour ajouter l'underscore
 * au nom en majuscule ou minuscule de la fonction � d�finir ou � appeler.
 * Pour les anciens compilateurs non ANSI, utiliser un commentaire vide � la place.
 * Pour appeler une subroutine Fortran de nom SUB avec un argument string et 2 arguments autres, faire:
 * #define CALL_SUB(a,b,c) CALLSPP(SUB,sub,a,b,c)
 * puis : CALL_SUB(a,b,c)
 * Pour d�finir une fonction C de nom SUB avec un argument string et 2 arguments autres,
 * appelable depuis le fortran, faire:
 * void DEFSPP(SUB,sub,char * nomobj,int lnom,double *d,INTEGER *i)
 * {
 * }
 * ici, lnom est l'entier qui indique la longueur de la chaine Fortran nomobj
 * Les macros d�finies ici ne servent qu'� former le nom de la fonction et �
 * mettre les arguments dans le bon ordre. On utilise l'ordre de Visual comme
 * base (pointeur char suivi d'un int) et on reordonne pour les autres compilateurs.
 */

/* Operateur de concatenation */
#define  _(A,B)   A##B

#if defined SOLARIS || IRIX || TRU64 || LINUX64 || SOLARIS64 || P_LINUX
#define F_FUNC(UN,LN)                            _(LN,_)

#elif defined HPUX
#define F_FUNC(UN,LN)                            LN

#elif defined PPRO_NT
#define F_FUNC(UN,LN)                            UN

#endif

#if defined SOLARIS || IRIX || TRU64 || LINUX64 || SOLARIS64 || P_LINUX || HPUX
#define STDCALL(UN,LN)                           F_FUNC(UN,LN)

#define CALLSS(UN,LN,a,b)                        F_FUNC(UN,LN)(a,b,strlen(a),strlen(b))
#define CALLSSP(UN,LN,a,b,c)                        F_FUNC(UN,LN)(a,b,c,strlen(a),strlen(b))
#define CALLSSPP(UN,LN,a,b,c,d)                        F_FUNC(UN,LN)(a,b,c,d,strlen(a),strlen(b))
#define CALLSSPPP(UN,LN,a,b,c,d,e)                        F_FUNC(UN,LN)(a,b,c,d,e,strlen(a),strlen(b))
#define CALLS(UN,LN,a)                     F_FUNC(UN,LN)(a,strlen(a))
#define CALLSP(UN,LN,a,b)                     F_FUNC(UN,LN)(a,b,strlen(a))
#define CALLSPP(UN,LN,a,b,c)                     F_FUNC(UN,LN)(a,b,c,strlen(a))
#define CALLSPPP(UN,LN,a,b,c,d)                     F_FUNC(UN,LN)(a,b,c,d,strlen(a))
#define CALLSPPPP(UN,LN,a,b,c,d,e)                     F_FUNC(UN,LN)(a,b,c,d,e,strlen(a))

#define CALLSPPPPS(UN,LN,a,b,c,d,e,f)                     F_FUNC(UN,LN)(a,b,c,d,e,f,strlen(a),strlen(f))
#define CALLSPPPPPPS(UN,LN,a,b,c,d,e,f,g,h)                  F_FUNC(UN,LN)(a,b,c,d,e,f,g,h,strlen(a),strlen(h))
#define CALLPPPSP(UN,LN,a,b,c,d,e)                        F_FUNC(UN,LN)(a,b,c,d,e,strlen(d))
#define DEFPPPSP(UN,LN,a,b,c,d,ld,e)                        STDCALL(UN,LN)(a,b,c,d,e,ld)

#define DEFS(UN,LN,a,la)                      STDCALL(UN,LN)(a,la)
#define DEFSP(UN,LN,a,la,b)                      STDCALL(UN,LN)(a,b,la)
#define DEFSPP(UN,LN,a,la,b,c)                   STDCALL(UN,LN)(a,b,c,la)
#define DEFSPPP(UN,LN,a,la,b,c,d)                   STDCALL(UN,LN)(a,b,c,d,la)
#define DEFSPPPP(UN,LN,a,la,b,c,d,e)                   STDCALL(UN,LN)(a,b,c,d,e,la)

#define DEFSPPPPS(UN,LN,a,la,b,c,d,e,f,lf)          STDCALL(UN,LN)(a,b,c,d,e,f,la,lf)
#define DEFSPPPPPPS(UN,LN,a,la,b,c,d,e,f,g,h,lh)     STDCALL(UN,LN)(a,b,c,d,e,f,g,h,la,lh)
#define DEFSSPPPPP(UN,LN,a,la,b,lb,c,d,e,f,g)    STDCALL(UN,LN)(a,b,c,d,e,f,g,la,lb)
#define DEFSSPPPP(UN,LN,a,la,b,lb,c,d,e,f)    STDCALL(UN,LN)(a,b,c,d,e,f,la,lb)
#define DEFSSPPP(UN,LN,a,la,b,lb,c,d,e)    STDCALL(UN,LN)(a,b,c,d,e,la,lb)
#define DEFSSPP(UN,LN,a,la,b,lb,c,d)    STDCALL(UN,LN)(a,b,c,d,la,lb)
#define DEFSSP(UN,LN,a,la,b,lb,c)    STDCALL(UN,LN)(a,b,c,la,lb)
#define DEFSS(UN,LN,a,la,b,lb)    STDCALL(UN,LN)(a,b,la,lb)

#define DEFSSSPPPPS(UN,LN,a,la,b,lb,c,lc,d,e,f,g,h,lh)    STDCALL(UN,LN)(a,b,c,d,e,f,g,h,la,lb,lc,lh)
#define CALLSSSPPPPS(UN,LN,a,b,c,d,e,f,g,h)    F_FUNC(UN,LN)(a,b,c,d,e,f,g,h,strlen(a),strlen(b),strlen(c),strlen(h))

#define DEFSPPSSSP(UN,LN,a,la,b,c,d,ld,e,le,f,lf,g)    STDCALL(UN,LN)(a,b,c,d,e,f,g,la,ld,le,lf)
#define CALLSPPSSSP(UN,LN,a,b,c,d,e,f,g)    F_FUNC(UN,LN)(a,b,c,d,e,f,g,strlen(a),strlen(d),strlen(e),strlen(f))

#define DEFSSPPPSP(UN,LN,a,la,b,lb,c,d,e,f,lf,g)             STDCALL(UN,LN)(a,b,c,d,e,f,g,la,lb,lf)
#define CALLSSPPPSP(UN,LN,a,b,c,d,e,f,g)                     F_FUNC(UN,LN)(a,b,c,d,e,f,g,strlen(a),strlen(b),strlen(f))
#define CALLSSPPPPP(UN,LN,a,b,c,d,e,f,g)                     F_FUNC(UN,LN)(a,b,c,d,e,f,g,strlen(a),strlen(b))
#define DEFSPSP(UN,LN,a,la,b,c,lc,d)                      STDCALL(UN,LN)(a,b,c,d,la,lc)
#define CALLSPSP(UN,LN,a,b,c,d)                           F_FUNC(UN,LN)(a,b,c,d,strlen(a),strlen(c))
#define CALLSSSP(UN,LN,a,b,c,d)                           F_FUNC(UN,LN)(a,b,c,d,strlen(a),strlen(b),strlen(c))
#define CALLSSSSP(UN,LN,a,b,c,d,e)                           F_FUNC(UN,LN)(a,b,c,d,e,strlen(a),strlen(b),strlen(c),strlen(d))
#define CALLSSSSPPS(UN,LN,a,b,c,d,e,f,g)                  F_FUNC(UN,LN)(a,b,c,d,e,f,g,strlen(a),strlen(b),strlen(c),strlen(d),strlen(g))
#define DEFSPSPP(UN,LN,a,la,b,c,lc,d,e)                      STDCALL(UN,LN)(a,b,c,d,e,la,lc)
#define DEFSPPSSP(UN,LN,a,la,b,c,d,ld,e,le,f)                      STDCALL(UN,LN)(a,b,c,d,e,f,la,ld,le)
#define DEFSSS(UN,LN,a,la,b,lb,c,lc)    STDCALL(UN,LN)(a,b,c,la,lb,lc)
#define CALLSSS(UN,LN,a,b,c)    F_FUNC(UN,LN)(a,b,c,strlen(a),strlen(b),strlen(c))
#define DEFSSSS(UN,LN,a,la,b,lb,c,lc,d,ld)    STDCALL(UN,LN)(a,b,c,d,la,lb,lc,ld)
#define CALLSSSS(UN,LN,a,b,c,d)    F_FUNC(UN,LN)(a,b,c,d,strlen(a),strlen(b),strlen(c),strlen(d))
#define DEFSPPPPPP(UN,LN,a,la,b,c,d,e,f,g)    STDCALL(UN,LN)(a,b,c,d,e,f,g,la)
#define CALLSPPPPPP(UN,LN,a,b,c,d,e,f,g)    F_FUNC(UN,LN)(a,b,c,d,e,f,g,strlen(a))
#define DEFPS(UN,LN,a,b,lb)                      STDCALL(UN,LN)(a,b,lb)
#define DEFPSP(UN,LN,a,b,lb,c)                      STDCALL(UN,LN)(a,b,c,lb)
#define DEFPSSP(UN,LN,a,b,lb,c,lc,d)    STDCALL(UN,LN)(a,b,c,d,lb,lc)
#define CALLPPS(UN,LN,a,b,c)    F_FUNC(UN,LN)(a,b,c,strlen(c))
#define DEFPPS(UN,LN,a,b,c,lc)    STDCALL(UN,LN)(a,b,c,lc)
#define DEFSSSP(UN,LN,a,la,b,lb,c,lc,d)    STDCALL(UN,LN)(a,b,c,d,la,lb,lc)
#define DEFSSSSP(UN,LN,a,la,b,lb,c,lc,d,ld,e)    STDCALL(UN,LN)(a,b,c,d,e,la,lb,lc,ld)
#define DEFSSSSPPS(UN,LN,a,la,b,lb,c,lc,d,ld,e,f,g,lg)    STDCALL(UN,LN)(a,b,c,d,e,f,g,la,lb,lc,ld,lg)
#define DEFSSPSPP(UN,LN,a,la,b,lb,c,d,ld,e,f)    STDCALL(UN,LN)(a,b,c,d,e,f,la,lb,ld)
#define FCALLSSPSPP(UN,LN,a,la,b,lb,c,d,ld,e,f)    F_FUNC(UN,LN)(a,b,c,d,e,f,la,lb,ld)
#define DEFSPSPPPS(UN,LN,a,la,b,c,lc,d,e,f,g,lg)    STDCALL(UN,LN)(a,b,c,d,e,f,g,la,lc,lg)
#define FCALLSPSPPPS(UN,LN,a,la,b,c,lc,d,e,f,g,lg)    F_FUNC(UN,LN)(a,b,c,d,e,f,g,la,lc,lg)
#define DEFSPSSPPP(UN,LN,a,la,b,c,lc,d,ld,e,f,g)    STDCALL(UN,LN)(a,b,c,d,e,f,g,la,lc,ld)
#define CALLSPSSPPP(UN,LN,a,b,c,d,e,f,g)    F_FUNC(UN,LN)(a,b,c,d,e,f,g,strlen(a),strlen(c),strlen(d))
#define FCALLSSS(UN,LN,a,la,b,lb,c,lc)    F_FUNC(UN,LN)(a,b,c,la,lb,lc)
#define FCALLPSSP(UN,LN,a,b,lb,c,lc,d)    F_FUNC(UN,LN)(a,b,c,d,lb,lc)
#define DEFSSPSPPSPSS(UN,LN,a,la,b,lb,c,d,ld,e,f,g,lg,h,i,li,j,lj)    STDCALL(UN,LN)(a,b,c,d,e,f,g,h,i,j,la,lb,ld,lg,li,lj)
#define CALLSSPSPPSPSS(UN,LN,a,b,c,d,e,f,g,h,i,j)                     F_FUNC(UN,LN)(a,b,c,d,e,f,g,h,i,j,strlen(a),strlen(b),strlen(d),strlen(g),strlen(i),strlen(j))
#define DEFSSSPSPPPP(UN,LN,a,la,b,lb,c,lc,d,e,le,f,g,h,i)    STDCALL(UN,LN)(a,b,c,d,e,f,g,h,i,la,lb,lc,le)
#define CALLSSSPSPPPP(UN,LN,a,b,c,d,e,f,g,h,i)            F_FUNC(UN,LN)(a,b,c,d,e,f,g,h,i,strlen(a),strlen(b),strlen(c),strlen(e))

#elif defined PPRO_NT
#define STDCALL(UN,LN)                           __stdcall F_FUNC(UN,LN)

#define CALLSS(UN,LN,a,b)                        F_FUNC(UN,LN)(a,strlen(a),b,strlen(b))
#define CALLSSP(UN,LN,a,b,c)                        F_FUNC(UN,LN)(a,strlen(a),b,strlen(b),c)
#define CALLSSPP(UN,LN,a,b,c,d)                        F_FUNC(UN,LN)(a,strlen(a),b,strlen(b),c,d)
#define CALLSSPPP(UN,LN,a,b,c,d,e)                        F_FUNC(UN,LN)(a,strlen(a),b,strlen(b),c,d,e)
#define CALLS(UN,LN,a)                     F_FUNC(UN,LN)(a,strlen(a))
#define CALLSP(UN,LN,a,b)                     F_FUNC(UN,LN)(a,strlen(a),b)
#define CALLSPP(UN,LN,a,b,c)                     F_FUNC(UN,LN)(a,strlen(a),b,c)
#define CALLSPPP(UN,LN,a,b,c,d)                     F_FUNC(UN,LN)(a,strlen(a),b,c,d)
#define CALLSPPPP(UN,LN,a,b,c,d,e)                     F_FUNC(UN,LN)(a,strlen(a),b,c,d,e)

#define CALLSPPPPS(UN,LN,a,b,c,d,e,f)                     F_FUNC(UN,LN)(a,strlen(a),b,c,d,e,f,strlen(f))
#define CALLSPPPPPPS(UN,LN,a,b,c,d,e,f,g,h)                  F_FUNC(UN,LN)(a,strlen(a),b,c,d,e,f,g,h,strlen(h))
#define CALLPPPSP(UN,LN,a,b,c,d,e)                        F_FUNC(UN,LN)(a,b,c,d,strlen(d),e)
#define DEFPPPSP(UN,LN,a,b,c,d,ld,e)                        STDCALL(UN,LN)(a,b,c,d,ld,e)

#define DEFS(UN,LN,a,la)                      STDCALL(UN,LN)(a,la)
#define DEFSP(UN,LN,a,la,b)                      STDCALL(UN,LN)(a,la,b)
#define DEFSPP(UN,LN,a,la,b,c)                      STDCALL(UN,LN)(a,la,b,c)
#define DEFSPPP(UN,LN,a,la,b,c,d)                   STDCALL(UN,LN)(a,la,b,c,d)
#define DEFSPPPP(UN,LN,a,la,b,c,d,e)                   STDCALL(UN,LN)(a,la,b,c,d,e)

#define DEFSPPPPS(UN,LN,a,la,b,c,d,e,f,lf)           STDCALL(UN,LN)(a,la,b,c,d,e,f,lf)
#define DEFSPPPPPPS(UN,LN,a,la,b,c,d,e,f,g,h,lh)    STDCALL(UN,LN)(a,la,b,c,d,e,f,g,h,lh)
#define DEFSSPPPPP(UN,LN,a,la,b,lb,c,d,e,f,g)    STDCALL(UN,LN)(a,la,b,lb,c,d,e,f,g)
#define DEFSSPPPP(UN,LN,a,la,b,lb,c,d,e,f)    STDCALL(UN,LN)(a,la,b,lb,c,d,e,f)
#define DEFSSPPP(UN,LN,a,la,b,lb,c,d,e)    STDCALL(UN,LN)(a,la,b,lb,c,d,e)
#define DEFSSPP(UN,LN,a,la,b,lb,c,d)    STDCALL(UN,LN)(a,la,b,lb,c,d)
#define DEFSSP(UN,LN,a,la,b,lb,c)    STDCALL(UN,LN)(a,la,b,lb,c)
#define DEFSS(UN,LN,a,la,b,lb)    STDCALL(UN,LN)(a,la,b,lb)

#define DEFSSSPPPPS(UN,LN,a,la,b,lb,c,lc,d,e,f,g,h,lh)    STDCALL(UN,LN)(a,la,b,lb,c,lc,d,e,f,g,h,lh)
#define CALLSSSPPPPS(UN,LN,a,b,c,d,e,f,g,h)    F_FUNC(UN,LN)(a,strlen(a),b,strlen(b),c,strlen(c),d,e,f,g,h,strlen(h))
#define DEFSSSPSPPPP(UN,LN,a,la,b,lb,c,d,ld,e,f,g,h,i)    STDCALL(UN,LN)(a,la,b,lb,c,lc,d,e,le,f,g,h,i)
#define CALLSSSPSPPPP(UN,LN,a,b,c,d,e,f,g,h,i)            F_FUNC(UN,LN)(a,strlen(a),b,strlen(b),c,strlen(c),d,e,strlen(e),f,g,h,i)

#define DEFSPPSSSP(UN,LN,a,la,b,c,d,ld,e,le,f,lf,g)    STDCALL(UN,LN)(a,la,b,c,d,ld,e,le,f,lf,g)
#define CALLSPPSSSP(UN,LN,a,b,c,d,e,f,g)    F_FUNC(UN,LN)(a,strlen(a),b,c,d,strlen(d),e,strlen(e),f,strlen(f),g)

#define DEFSSPPPSP(UN,LN,a,la,b,lb,c,d,e,f,lf,g)    STDCALL(UN,LN)(a,la,b,lb,c,d,e,f,lf,g)
#define CALLSSPPPSP(UN,LN,a,b,c,d,e,f,g)                     F_FUNC(UN,LN)(a,strlen(a),b,strlen(b),c,d,e,f,strlen(f),g)
#define CALLSSPPPPP(UN,LN,a,b,c,d,e,f,g)                     F_FUNC(UN,LN)(a,strlen(a),b,strlen(b),c,d,e,f,g)
#define DEFSPSP(UN,LN,a,la,b,c,lc,d)                      STDCALL(UN,LN)(a,la,b,c,lc,d)
#define CALLSPSP(UN,LN,a,b,c,d)                     F_FUNC(UN,LN)(a,strlen(a),b,c,strlen(c),d)
#define CALLSSSP(UN,LN,a,b,c,d)                     F_FUNC(UN,LN)(a,strlen(a),b,strlen(b),c,strlen(c),d)
#define CALLSSSSP(UN,LN,a,b,c,d,e)                     F_FUNC(UN,LN)(a,strlen(a),b,strlen(b),c,strlen(c),d,strlen(d),e)
#define CALLSSSSPPS(UN,LN,a,b,c,d,e,f,g)                     F_FUNC(UN,LN)(a,strlen(a),b,strlen(b),c,strlen(c),d,strlen(d),e,f,g,strlen(g))
#define DEFSPSPP(UN,LN,a,la,b,c,lc,d,e)                      STDCALL(UN,LN)(a,la,b,c,lc,d,e)
#define DEFSPPSSP(UN,LN,a,la,b,c,d,ld,e,le,f)                      STDCALL(UN,LN)(a,la,b,c,d,ld,e,le,f)
#define DEFSSS(UN,LN,a,la,b,lb,c,lc)    STDCALL(UN,LN)(a,la,b,lb,c,lc)
#define CALLSSS(UN,LN,a,b,c)    F_FUNC(UN,LN)(a,strlen(a),b,strlen(b),c,strlen(c))
#define DEFSSSS(UN,LN,a,la,b,lb,c,lc,d,ld)    STDCALL(UN,LN)(a,la,b,lb,c,lc,d,ld)
#define CALLSSSS(UN,LN,a,b,c,d)    F_FUNC(UN,LN)(a,strlen(a),b,strlen(b),c,strlen(c),d,strlen(d))
#define DEFSPPPPPP(UN,LN,a,la,b,c,d,e,f,g)    STDCALL(UN,LN)(a,b,c,d,e,f,g,la)
#define CALLSPPPPPP(UN,LN,a,b,c,d,e,f,g)    F_FUNC(UN,LN)(a,b,c,d,e,f,g,strlen(a))
#define DEFPS(UN,LN,a,b,lb)                      STDCALL(UN,LN)(a,b,lb)
#define DEFPSP(UN,LN,a,b,c,lb)                      STDCALL(UN,LN)(a,b,c,lb)
#define DEFPSSP(UN,LN,a,b,lb,c,lc,d)    STDCALL(UN,LN)(a,b,lb,c,lc,d)
#define CALLPPS(UN,LN,a,b,c)    F_FUNC(UN,LN)(a,b,c,strlen(c))
#define DEFPPS(UN,LN,a,b,c,lc)    STDCALL(UN,LN)(a,b,c,lc)
#define DEFSSSP(UN,LN,a,la,b,lb,c,lc,d)    STDCALL(UN,LN)(a,la,b,lb,c,lc,d)
#define DEFSSSSP(UN,LN,a,la,b,lb,c,lc,d,ld,e)    STDCALL(UN,LN)(a,la,b,lb,c,lc,d,ld,e)
#define DEFSSSSPPS(UN,LN,a,la,b,lb,c,lc,d,ld,e,f,g,lg)    STDCALL(UN,LN)(a,la,b,lb,c,lc,d,ld,e,f,g,lg)
#define DEFSSPSPP(UN,LN,a,la,b,lb,c,d,ld,e,f)    STDCALL(UN,LN)(a,la,b,lb,c,d,ld,e,f)
#define FCALLSSPSPP(UN,LN,a,la,b,lb,c,d,ld,e,f)    F_FUNC(UN,LN)(a,la,b,lb,c,d,ld,e,f)
#define DEFSPSPPPS(UN,LN,a,la,b,c,lc,d,e,f,g,lg)    STDCALL(UN,LN)(a,la,b,c,lc,d,e,f,g,lg)
#define FCALLSPSPPPS(UN,LN,a,la,b,c,lc,d,e,f,g,lg)    F_FUNC(UN,LN)(a,la,b,c,lc,d,e,f,g,lg)
#define DEFSPSSPPP(UN,LN,a,la,b,c,lc,d,ld,e,f,g)    STDCALL(UN,LN)(a,la,b,c,lc,d,ld,e,f,g)
#define CALLSPSSPPP(UN,LN,a,b,c,d,e,f,g)    F_FUNC(UN,LN)(a,strlen(a),b,c,strlen(c),d,strlen(d),e,f,g)
#define FCALLSSS(UN,LN,a,la,b,lb,c,lc)    F_FUNC(UN,LN)(a,la,b,lb,c,lc)
#define FCALLPSSP(UN,LN,a,b,lb,c,lc,d)    F_FUNC(UN,LN)(a,b,lb,c,lc,d)
#define DEFSSPSPPSPSS(UN,LN,a,la,b,lb,c,d,ld,e,f,g,lg,h,i,li,j,lj)    STDCALL(UN,LN)(a,la,b,lb,c,d,ld,e,f,g,lg,h,i,li,j,lj)
#define CALLSSPSPPSPSS(UN,LN,a,b,c,d,e,f,g,h,i,j)                     F_FUNC(UN,LN)(a,strlen(a),b,strlen(b),c,d,strlen(d),e,f,g,strlen(g),h,i,strlen(i),j,strlen(j))

#endif

#define CALLP(UN,LN,a)                        F_FUNC(UN,LN)(a)
#define CALLPP(UN,LN,a,b)                        F_FUNC(UN,LN)(a,b)
#define CALLPPPP(UN,LN,a,b,c,d)                        F_FUNC(UN,LN)(a,b,c,d)
#define DEFP(UN,LN,a)                            STDCALL(UN,LN)(a)
#define DEFPP(UN,LN,a,b)                            STDCALL(UN,LN)(a,b)
#define DEFPPP(UN,LN,a,b,c)                            STDCALL(UN,LN)(a,b,c)
#define DEFPPPP(UN,LN,a,b,c,d)                            STDCALL(UN,LN)(a,b,c,d)

/* FIN DE pour d�finir les appels et signatures de fonctions appelables en Fortran */

/* Fonction retournant PI en R8 */
#define R8PI() F_FUNC(R8PI,r8pi)()
extern double STDCALL(R8PI,r8pi)();

/* pour representer les logical sur toutes les stations {*/

/* FORTRAN_TRUE = -1 sur HP-UX avec l'option de compilation +DAportable +apollo */
enum ENUM_LOGICAL { FORTRAN_TRUE=-1, FORTRAN_FALSE=0} ;
#define FORTRAN_LOGICAL enum ENUM_LOGICAL

/*                                                      }*/

/* pour representer les entiers sur toutes les stations. {*/

#if defined(SOLARIS) || defined(P_LINUX) || defined(PPRO_NT) || defined(HPUX)
#define INTEGER long
#else
#if defined IRIX || TRU64 || LINUX64 || SOLARIS64
#define INTEGER long
#else
#error Environnement INDEFINI pour INTEGER
#endif
#endif

/*                                                       }*/



/* pour preciser quel fichier affiche les  messages et les valeurs */

#define INTERRUPTION(code) { ICI ; fprintf(stderr,"INTERRUPTION - code retour %d\n",code) ;abort() ; }

#ifdef _DEBUT
#error _DEBUT est deja definie
#endif
#ifdef _FIN
#error _FIN est deja definie
#endif

#ifdef _DEBOG_        /*{*/

#define ICI fflush(stdout);fprintf( stderr, "%s  %d : " , __FILE__ , __LINE__  ) ; fflush(stderr) ;
#define MESSAGE(chaine) ICI ; fprintf( stderr , "%s\n" , chaine ) ; fflush(stderr) ;

#ifndef ASSERT        /*{*/
#define ASSERT(condition) if( !(condition) ){ ICI ; fprintf(stderr,"condition %s VIOLEE\n",#condition);INTERRUPTION(17);}
#endif                /*}# ifndef ASSERT*/

#define TAB fflush(stdout);fprintf( stderr, "\t" );ICI
#define RES fflush(stdout);fprintf( stderr, "\t RESULTAT >> " );ICI
#define ISCRUTE(entier) TAB ; fprintf(stderr,"%s = %ld\n",#entier,(INTEGER)entier) ; fflush(stderr);
#define PSCRUTE(pointeur) TAB ; fprintf(stderr,"%s = %p\n",#pointeur,(void*)pointeur) ; fflush(stderr);
#define TISCRUTE(n,entier) TAB ; fprintf(stderr,"%s = %ld",#n,(INTEGER)n) ; \
                           if(n>0) fprintf(stderr,", %s[0] = %ld",#entier,(INTEGER)entier[0]) ; \
                           fprintf(stderr,"\n");fflush(stderr);
#define REFSCRUTE(objet) ISCRUTE(objet->ob_refcnt) ;
#define DSCRUTE(reel) TAB ; fprintf(stderr,"%s = %f\n",#reel,reel) ; fflush(stderr);
#define TDSCRUTE(n,reel) TAB ; fprintf(stderr,"%s = %ld",#n,(INTEGER)n) ; \
                           if(n>0) fprintf(stderr,", %s[0] = %f",#reel,reel[0]) ; \
                           fprintf(stderr,"\n");fflush(stderr);
#define OBSCRUTE(obj) TAB ; fprintf(stderr,"%s = ",#obj) ; PyObject_Print(obj, stderr, 0); fprintf(stderr,"\n");fflush(stderr);
#define SSCRUTE(chaine) TAB ; fprintf(stderr,"%s = ",#chaine) ; if (chaine){fprintf(stderr,"\"%s\"\n",chaine);}else{fprintf(stderr,"(char*)0\n");} ; fflush(stderr);
#define FSSCRUTE(chaine,longueur) TAB ; fprintf(stderr,"%s = ",#chaine) ; fflush(stderr) ; AfficheChaineFortran(chaine,longueur) ;
#define _DEBUT(nom) fprintf( stderr , "\n\n\n") ; ICI ; fprintf( stderr , "{ DEBUT %s\n" , #nom ) ; fflush(stderr) ;
#define _FIN(nom) ICI ; fprintf( stderr , "} FIN %s\n\n\n" , #nom ) ; fflush(stderr) ;

#else                /*}# ifdef _DEBOG_{*/

#define ICI
#define TAB
#define RES
#define MESSAGE(chaine)
#define ISCRUTE(entier)
#define PSCRUTE(pointeur)
#define TISCRUTE(n,entier)
#define DSCRUTE(reel)
#define TDSCRUTE(n,reel)
#define OBSCRUTE(obj)
#define SSCRUTE(chaine)
#define REFSCRUTE(objet)
#define FSSCRUTE(chaine,longueur)
#define ASSERT(condition)
#define _DEBUT(nom)
#define _FIN(nom)

#endif                /*}# ifdef _DEBOG_*/
#endif                /*}# ifndef _UTILITES_*/


/* fin du fichier UTILITE.h */






#define EstValide(c) (isprint((int)c) && (isalnum((int)c) || (c=='_') || (c==' ')))




/* --- declarations des interfaces des fonctions de ce fichier --- */
/*{*/

static PyObject *aster_argv( _UNUSED  PyObject *self, _IN PyObject *args ) ;
const char *aster_ident() ;

int EstPret( _IN char *chaine , _IN int longueur ) ;
long FindLength( _IN char *chaineFortran , _IN INTEGER longueur ) ;
void AfficheChaineFortran( _IN char *chaine , _IN int longueur ) ;
void TraiteMessageErreur( _IN char* ) ;
void PRE_myabort( _IN const char *nomFichier , _IN const int numeroLigne , _IN const char *message ) ;
#define MYABORT(message) PRE_myabort( __FILE__ , __LINE__ , message )



char * fstr1( _IN char *s, _IN int l) ;
char * fstr2( _IN char *s, _IN int l) ;
char * fstr3( _IN char *s, _IN int l) ;
void convert( _IN int nval, _IN PyObject *tup, _OUT INTEGER *val) ;
void convertxt( _IN int nval, _IN PyObject *tup, _OUT char *val, _IN int taille) ;
void converltx( _IN int nval, _IN PyObject *tup, _OUT char *val, _IN int taille) ;

void AjoutChaineA( _INOUT char **base , _IN char *supplement ) ;

void TraitementFinAster( _IN int val ) ;

PyObject * MakeTupleString(long nbval,char *kval,int lkval,INTEGER *lval);
PyObject * MakeListString( long nbval,char *kval,int lkval );
PyObject * MakeTupleInt(long nbval,long* kval);
PyObject * MakeListInt(long nbval,long* kval);
PyObject * MakeTupleFloat(long nbval,double* kval);
PyObject * MakeListFloat(long nbval,double* kval);


/*}*/
/* --- FIN declarations des interfaces des fonctions de ce fichier --- */



#define _UTILISATION_SETJMP_
/*
 *   Emulation d'exceptions en C : on utilise le couple de fonctions systemes setjmp/longjmp
 *   pour reproduire le comportement des exceptions en C.
 *   Pour initier une exception, le Fortran doit appeler la fonction XFINI
 *   avec en argument le code de l'exception.
 *   La fonction XFINI fait appel � longjmp pour effectuer le debranchement necessaire.
 *
 *   La variable exception_flag indique comment toute anomalie intervenant pendant
 *   le try doit etre trait�e :  par une exception (si try(1)) ou par un abort (si try(0))
 */

#define CodeFinAster       19
#define CodeAbortAster     20
#define CodeErrorAster     21
#define CodeNonConvergenceAster           22
#define CodeEchecComportementAster        23
#define CodeBandeFrequenceVideAster       24
#define CodeMatriceSinguliereAster        25
#define CodeTraitementContactAster        26
#define CodeMatriceContactSinguliereAster 27
#define CodeArretCPUAster                 28

int exception_status=-1;
#define REASONMAX 800
static char exception_reason[REASONMAX+1];

#define NIVMAX 10
static int niveau=0;

#ifdef _UTILISATION_SETJMP_
#include <setjmp.h>

static jmp_buf env[NIVMAX+1] ;           /* utilise par longjmp, le type jmp_buf est defini dans setjmp.h */
static int exception_flag[NIVMAX+1];

#define try(val) exception_flag[niveau]=val;if((exception_status = setjmp(env[niveau])) == 0)
#define catch(val) else if (exception_status == val)
#define throw(val) longjmp(env[niveau],val)
#define finally else

void TraiteErreur( _IN int code )
{
   _DEBUT("TraiteErreur");
        if(exception_flag[niveau]==1){
          exception_flag[niveau]=0;
          throw(code);
        }
        else{
          abort();
        }
   _FIN("TraiteErreur");
}

#else
#define try(val) if(1)
#define catch(val) else if (0)
#define throw(val)
#define finally else

void TraiteErreur( _IN int code )
{
        switch( code ){

        case CodeFinAster :
                exit(0);
                break ;
        case CodeAbortAster :
                abort();
                break ;
        case CodeErrorAster :
                abort();
                break ;

        /* exceptions particularis�es */
        case CodeNonConvergenceAster :
                abort();
                break ;
        case CodeEchecComportementAster :
                abort();
                break ;
        case CodeBandeFrequenceVideAster :
                abort();
                break ;
        case CodeMatriceSinguliereAster :
                abort();
                break ;
        case CodeTraitementContactAster :
                abort();
                break ;
        case CodeMatriceContactSinguliereAster :
                abort();
                break ;
        case CodeArretCPUAster :
                abort();
                break ;
        default :
                MESSAGE("code erreur INCONNU !!!!") ;
                ISCRUTE(*code) ;
                INTERRUPTION(1) ;
                break ;
        }

}

#endif                /* #ifdef _UTILISATION_SETJMP_ */

void STDCALL(XFINI,xfini)(_IN INTEGER *code)
{
   _DEBUT("XFINI");
   switch( *code ){
        case CodeFinAster :
                strcpy(exception_reason,"exit ASTER");
                break ;
        case CodeAbortAster :
                strcpy(exception_reason,"abort ASTER");
                break ;
        default:
                *code=CodeAbortAster;
                strcpy(exception_reason,"abort ASTER");
                break ;
        }
   TraiteErreur(*code);
   _FIN("XFINI");
}

/* Fin emulation exceptions en C */



/* --- liste des variables globales au fonctions  de ce fichier --- */ /*{*/



/* commande (la commande courante) est definie par les fonctions aster_debut et aster_oper */
static PyObject *commande       = (PyObject*)0 ;
static PyObject *pile_commandes = (PyObject*)0 ;
static PyObject *static_module  = (PyObject*)0 ;

/* NomCas est initialise dans aster_debut() */
/* NomCas est initialise a blanc pour permettre la recuperation de la
   trace des commandes lors de l'appel a debut ou poursuite. On ne connait
   pas encore NomCas qui sera initialise lors de l'appel a RecupNomCas */
static char *NomCas          = "        ";

/* ------------------------------------------------------------------ */
/*
    Les exceptions levees dans le Fortran par les developpeurs
    doivent etre des objets de la classe AsterError (numero equivalent 21) ou d'une classe
    derivee.
 */
/* exceptions de base */
static PyObject *AsterError = (PyObject*)0 ; /* Ce type d'exception est levee sur appel de XFINI avec le parametre 21 */
static PyObject *FatalError = (PyObject*)0 ; /* Ce type d'exception (derive de AsterError) est levee sur appel de XFINI avec le parametre 20 */

/* exceptions particularis�es */
static PyObject *NonConvergenceError = (PyObject*)0 ;           /* Exception non convergence */
static PyObject *EchecComportementError = (PyObject*)0 ;        /* Exception �chec int�gration du comportement */
static PyObject *BandeFrequenceVideError = (PyObject*)0 ;       /* Exception bande de fr�quence vide */
static PyObject *MatriceSinguliereError = (PyObject*)0 ;        /* Exception matrice singuliere */
static PyObject *TraitementContactError = (PyObject*)0 ;        /* Exception �chec de traitement du contact */
static PyObject *MatriceContactSinguliereError = (PyObject*)0 ; /* Exception matrice de contact non inversible */
static PyObject *ArretCPUError = (PyObject*)0 ;                 /* Exception manque de temps CPU */

void initExceptions(PyObject *dict)
{
        AsterError = PyErr_NewException("aster.error", NULL, NULL);
        if(AsterError != NULL) PyDict_SetItemString(dict, "error", AsterError);
        /* type d'exception Fatale derivee de AsterError */
        FatalError = PyErr_NewException("aster.FatalError", NULL, NULL);
        if(FatalError != NULL) PyDict_SetItemString(dict, "FatalError", FatalError);

        /* Exceptions particularis�es */
        NonConvergenceError = PyErr_NewException("aster.NonConvergenceError", AsterError, NULL);
        if(NonConvergenceError != NULL) PyDict_SetItemString(dict, "NonConvergenceError", NonConvergenceError);

        EchecComportementError = PyErr_NewException("aster.EchecComportementError", AsterError, NULL);
        if(EchecComportementError != NULL) PyDict_SetItemString(dict, "EchecComportementError", EchecComportementError);

        BandeFrequenceVideError = PyErr_NewException("aster.BandeFrequenceVideError", AsterError, NULL);
        if(BandeFrequenceVideError != NULL) PyDict_SetItemString(dict, "BandeFrequenceVideError", BandeFrequenceVideError);

        MatriceSinguliereError = PyErr_NewException("aster.MatriceSinguliereError", AsterError, NULL);
        if(MatriceSinguliereError != NULL) PyDict_SetItemString(dict, "MatriceSinguliereError", MatriceSinguliereError);

        TraitementContactError = PyErr_NewException("aster.TraitementContactError", AsterError, NULL);
        if(TraitementContactError != NULL) PyDict_SetItemString(dict, "TraitementContactError", TraitementContactError);

        MatriceContactSinguliereError = PyErr_NewException("aster.MatriceContactSinguliereError", AsterError, NULL);
        if(MatriceContactSinguliereError != NULL) PyDict_SetItemString(dict, "MatriceContactSinguliereError", MatriceContactSinguliereError);

        ArretCPUError = PyErr_NewException("aster.ArretCPUError", AsterError, NULL);
        if(ArretCPUError != NULL) PyDict_SetItemString(dict, "ArretCPUError", ArretCPUError);
}

/* ------------------------------------------------------------------ */
/*
  Subroutine appelable depuis le Fortran pour demander la levee d'une exception de type exc_type
  Une chaine de charactere (reason) ajoute un commentaire au type d'exception
*/
void DEFPS(UEXCEP,uexcep,_IN INTEGER *exc_type,  _IN char *reason , _IN int lreason )
{
   int l;
   _DEBUT("UEXCEP");
   l=min(FindLength(reason,lreason),REASONMAX);
   strncpy(exception_reason,reason,l);
   exception_reason[l]='\0';
   TraiteErreur(*exc_type);
   _FIN("UEXCEP");
}

#define BLANK(dest,taille) memset(dest,' ',taille)
#define STRING_FCPY(dest,taille,src,longueur) \
   memcpy(dest,src,min(taille,longueur));taille>longueur?memset(dest+longueur,' ',taille-longueur):0;
#define CSTRING_FCPY(dest,taille,src) STRING_FCPY(dest,taille,src,strlen(src))

#define PRINTERR if(PyErr_Occurred()){ \
            fprintf(stderr,"Warning: une exception n'a pas ete trait�e\n"); \
            PyErr_Print(); \
            fprintf(stderr,"Warning: on l'annule pour continuer mais elle aurait du etre trait�e avant\n"); \
            PyErr_Clear(); \
        }


static char nom_fac[256];        /* utilise par fstr1 */
static char nom_cle[256];        /* utilise par fstr2 */
static char nom_cmd[256];        /* utilise par fstr3 */


/*}*/ /* --- FIN liste des variables globales au fonctions  de ce fichier --- */


/*
 *   Ce module cr�e de nombreux objets Python. Il doit respecter les r�gles
 *   g�n�rales de cr�ation des objets et en particulier les r�gles sur le
 *   compteur de r�f�rences associ� � chaque objet.
 *   Tous les objets sont partag�s. Seules des r�f�rences � des objets peuvent
 *   etre acquises.
 *   Si une fonction a acquis une r�f�rence sur un objet elle doit la traiter
 *   proprement, soit en la transf�rant (habituellement � l'appelant), soit en
 *   la relachant (par appel � Py_DECREF ou Py_XDECREF).
 *   Quand une fonction transfere la propri�t� d'une r�f�rence, l'appelant recoit
 *   une nouvelle r�f�rence. Quand la propri�t� n'est pas transf�r�e, l'appelant
 *   emprunte la r�f�rence.
 *   Dans l'autre sens, quand un appelant passe une r�f�rence � une fonction, il y a
 *   deux possibilit�s : la fonction vole une r�f�rence � l'objet ou elle ne le fait
 *   pas. Peu de fonctions (de l'API Python) volent des r�f�rences : les deux exceptions
 *   les plus notables sont PyList_SetItem() et PyTuple_SetItem() qui volent une
 *   r�f�rence � l'item qui est ins�r� dans la liste ou dans le tuple.
 *   Ces fonctions qui volent des r�f�rences existent, en g�n�ral, pour all�ger
 *   la programmation.
 */




/* ------------------------------------------------------------------ */

void TraiteMessageErreur( _IN char * message )
{
        printf("%s\n",message);
        if(PyErr_Occurred())PyErr_Print();
        abort();
        if(exception_flag[niveau]==1){
          int l;
          exception_flag[niveau]=0;
          l=min(REASONMAX,strlen(message));
          strncpy(exception_reason,message,l);
          exception_reason[l+1]='\0';
          throw(CodeAbortAster);
        }
        else{
          abort();
        }
}

/* ------------------------------------------------------------------ */
void PRE_myabort( _IN const char *nomFichier , _IN const int numeroLigne , _IN const char *message )
{

        /*
        Procedure : PRE_myabort
        Intention
                Cette procedure prepare la chaine de caracteres affichee par TraiteMessageErreur()
                en ajoutant devant cette chaine, le nom du fichier source et le numero
                de la ligne a partir desquels PRE_myabort a ete appelee.
                Puis elle appelle elle-meme TraiteMessageErreur().
                Voir aussi la macro MYABORT qui permet de generer automatiquement le nom
                du fichier et le numero de la ligne.
        */

        char *chaine = (char*)0 ;
        int longueur = 0 ;
        void *malloc(size_t size);
                                                        ASSERT(numeroLigne>0);
                                                        ASSERT(((int)log10((float)numeroLigne))<=5);
                                                        ASSERT(nomFichier!=(char*)0) ;
        longueur += strlen( nomFichier ) ;
        longueur += 1 ; /* pour le blanc de separation */
        longueur += 5 ; /* pour le numero de la ligne */
        longueur += 3 ; /* pour les deux points entre deux blancs */
                                                        ASSERT(message!=(const char*)0);
        longueur += ( message != (const char*)0 ) ? strlen( message ) : 0 ;
        longueur += 1 ; /* pour le caractere de fin de chaine */

        chaine = (char*)(malloc(longueur*sizeof(char))) ;
                                                        ASSERT(chaine!=(char*)0);

        sprintf( chaine , "%s %u : %s" , nomFichier , numeroLigne , message ) ;
        TraiteMessageErreur( chaine ) ;

        free( chaine )   ;
        chaine=(char*)0 ;
        longueur = 0     ;
}

/* ------------------------------------------------------------------ */
void DEFSSPPPPP(GETLTX,getltx,_IN char *motfac,_IN int lfac,_IN char *motcle,_IN int lcle,_IN INTEGER *iocc,
                              _IN INTEGER *iarg,_IN INTEGER *mxval,_OUT INTEGER *isval, _OUT INTEGER *nbval )
{
        /*
        Procedure : getltx_ (appelee par le fortran sous le nom GETLTX)
        Intention

        */
        PyObject *res = (PyObject*)0 ;
        PyObject *tup = (PyObject*)0 ;
        char *mfc     = (char*)0 ;
        char *mcs     = (char*)0 ;
        int ok        = 0 ;
        int nval      = 0 ;
        int ioc       = 0 ;

        _DEBUT("getltx_") ;
                                                        FSSCRUTE(motfac,lfac) ; FSSCRUTE(motcle,lcle) ; ISCRUTE(*iocc) ;

        mfc=fstr1(motfac,lfac);
                                                        ASSERT(mfc!=(char*)0);

                                                        ASSERT(EstPret(motcle,lcle)!=0);
        mcs=fstr2(motcle,lcle);
                                                        ASSERT(mcs!=(char*)0);

                                                        ISCRUTE(*iocc);
        ioc=*iocc ;
        ioc=ioc-1 ;
                                                        ASSERT(commande!=(PyObject*)0);
        res=PyObject_CallMethod(commande,"getltx","ssiii",mfc,mcs,ioc,*iarg,*mxval);

        /*  si le retour est NULL : exception Python a transferer
            normalement a l appelant mais FORTRAN ??? */
        if (res == NULL)MYABORT("erreur dans la partie Python");


        ok = PyArg_ParseTuple(res,"lO",nbval,&tup);
        if (!ok)MYABORT("erreur dans la partie Python");

        nval=*nbval;
        if(*nbval < 0)nval=*mxval;
        convert(nval,tup,isval);
                                                        ISCRUTE(nbval);
                                                        TISCRUTE(nval,isval);
        Py_DECREF(res);                /*  decrement sur le refcount du retour */
        _FIN(getltx_) ;
        return ;
}


/* ------------------------------------------------------------------ */
char * fstr1( _IN char *s, _IN int l)
{
        /*
        copie l caracteres d'une chaine de caracteres fortran s dans la chaine
        statique globale nom_fac, et retourne un pointeur sur nom_fac
        */
        strncpy(nom_fac, s, l );
        nom_fac[l]='\0';
        return nom_fac;
}
char * fstr2( _IN char *s, _IN int l)
{
        /*
        copie l caracteres d'une chaine de caracteres fortran s dans la chaine
        statique globale nom_cle, et retourne un pointeur sur nom_cle
        */
        strncpy(nom_cle, s, l );
        nom_cle[l]='\0';
        return nom_cle;
}
char * fstr3( _IN char *s, _IN int l)
{
        /*
        copie l caracteres d'une chaine de caracteres fortran s dans la chaine
        statique globale nom_cmd, et retourne un pointeur sur nom_cmd
        */
        strncpy(nom_cmd, s, l );
        nom_cmd[l]='\0';
        return nom_cmd;
}



/* ------------------------------------------------------------------ */
void DEFSP(GETFAC,getfac,_IN char *nomfac, _IN int lfac, _OUT INTEGER *occu)
{
        /*
          Procedure GETFAC pour le FORTRAN : emule le fonctionnement
          de la procedure equivalente ASTER
          Entrees :
            le nom d un mot cle facteur : nomfac (string)
          Retourne :
            le nombre d occurence de ce mot cle dans les args : occu (entier)
            dans l'etape (ou la commande) courante
        */
        PyObject *res  = (PyObject*)0 ;

        _DEBUT(getfac_) ;
                                                        FSSCRUTE(nomfac,lfac) ;
                                                        ASSERT(EstPret(nomfac,lfac)!=0);
                                                        ASSERT(commande!=(PyObject*)0);
        res=PyObject_CallMethod(commande,"getfac","s",fstr1(nomfac,lfac));

        /*  si le retour est NULL : exception Python a transferer
            normalement a l appelant mais FORTRAN ??? */
        if (res == NULL)MYABORT("erreur dans la partie Python");

        *occu=PyInt_AsLong(res);
                                                        ISCRUTE(*occu);

        Py_DECREF(res);                /*  decrement sur le refcount du retour */
        _FIN(getfac_) ;
        return ;
}




/* ------------------------------------------------------------------ */
void convc8( _IN int nval, _IN PyObject *tup, _OUT double *val)
{

        /*
                  tup est un tuple de tuples internes, chaque tuple
                interne contenant le type et les deux parties du complexe.
        */

        int    i = 0 ;
        int    k = 0 ;
        int conv_un_c8( _IN PyObject *tup, _OUT double *val) ;

                                                                    ASSERT(PyTuple_Check(tup)) ;
                                                                    OBSCRUTE(tup) ;
        if(nval != 0){
                PyObject *v = (PyObject*)0 ;
                                                                    ASSERT(nval>0) ;
                for(i=0;i<nval;i++){
                                                                    ISCRUTE(i) ;
                        v=PyTuple_GetItem(tup,i);
                        k += conv_un_c8( v , val+k ) ;
                }
        }
        return ;
}

/* ------------------------------------------------------------------ */
int conv_un_c8( _IN PyObject *tup, _OUT double *val)
{

        /* Enrichissement des complexes stockes dans val a partir du tuple tup */

        char *repres = (char*)0 ; /* representation "RI" (reelle/imaginaire) ou "MP" (module phase) */

        double x = 0.0 ;
        double y = 0.0 ;
        double *rho = &x ;
        double *theta = &y ;
                                                                    OBSCRUTE(tup) ;
        if(PyComplex_Check(tup)||PyFloat_Check(tup)||PyLong_Check(tup)||PyInt_Check(tup)){
           /* On est dans le cas d'un objet Python complexe */
           /* representation : partie reelle/partie imaginaire */
           *val    =PyComplex_RealAsDouble(tup)  ;
           *(val+1)=PyComplex_ImagAsDouble(tup)  ;
                                                               DSCRUTE(*val);DSCRUTE(*(val+1));
        }
        else if(PyTuple_Check(tup)){
           /* On est dans le cas d'un complexe repr�sent� par un triplet : "RI" ou "MP",x,y */
           if(!PyArg_ParseTuple(tup,"sdd",&repres,&x,&y))
                     MYABORT("erreur dans la partie Python");
                                                                                     SSCRUTE(repres) ;
                                                                                     ASSERT((strcmp(repres,"RI")==0)||(strcmp(repres,"MP")==0)) ;
                                                                                     DSCRUTE(x) ;
                                                                                     DSCRUTE(y) ;
                                                                                     ISCRUTE(strcmp(repres,"RI"))
           if (strcmp(repres,"RI")==0){
                /* representation : partie reelle/partie imaginaire */
                *val    =x ;
                *(val+1)=y ;
           }
           else{
                /* representation RHO,THETA (les angles sont fournis en degres) */
                *val    =*rho * cos( *theta /180. * R8PI()) ;
                *(val+1)=*rho * sin( *theta /180. * R8PI()) ;
           }
        }
        else {
           MYABORT("erreur dans la partie Python");
        }
        return 2 ;
}


/* ------------------------------------------------------------------ */
void convr8( _IN int nval, _IN PyObject *tup, _OUT double *val)
{

        /* Convertit un Tuple en tableau de double */

        int i;
        PyObject *v = (PyObject*)0 ;
        if(nval == 0)return;
        if (!PyTuple_Check(tup)){
                printf("tup : ");
                PyObject_Print(tup, stdout, 0);
                printf("\n ");
                MYABORT("erreur sur le type : devrait etre un tuple");
        }
        for(i=0;i<nval;i++){
                v=PyTuple_GetItem(tup,i);
                val[i]=PyFloat_AsDouble(v);
        }
        return ;
}


/* ------------------------------------------------------------------ */
void convert( _IN int nval, _IN PyObject *tup, _OUT INTEGER *val)
{

        /* Convertit un Tuple en tableau d entier */

        int i;
        PyObject *v = (PyObject*)0 ;
        if(nval == 0)return;
        if (!PyTuple_Check(tup)){
                printf("tup : ");
                PyObject_Print(tup, stdout, 0);
                printf("\n ");
                MYABORT("erreur sur le type : devrait etre un tuple");
        }
        for(i=0;i<nval;i++){
                v=PyTuple_GetItem(tup,i);
                val[i]=PyInt_AsLong(v);
        }
        return ;
}


/* ------------------------------------------------------------------ */
void convertxt( _IN int nval, _IN PyObject *tup, _OUT char *val, _IN int taille)
{
        /*
        Convertit un Tuple en tableau de chaines
        Pour retour au Fortran : le tableau existe deja (val)
           nval   : indique le nombre d'elements du tuple a convertir
           tup    : est le tuple Python a convertir
           val    : est le tableau de chaines Fortran a remplir
           taille : indique la taille des chaines
        */
                                                                   ASSERT(PyTuple_Check(tup)) ;
                                                                   ISCRUTE(nval) ;
                                                                   ISCRUTE(taille) ;
                                                                   OBSCRUTE(tup) ;
        if(nval != 0){
                PyObject *v  = (PyObject*)0 ;
                int i;
                char *s      = (char*)0 ;
                char *val_i      = (char*)0 ;
                int longueur = 0 ;
                                                                   ASSERT(nval>0) ;
                                                                   ASSERT(taille>0) ;
                if (!PyTuple_Check(tup)){
                        printf("tup : ");
                        PyObject_Print(tup, stdout, 0);
                        printf("\n ");
                        MYABORT("erreur sur le type : devrait etre un tuple");
                }
                for(i=0;i<nval;i++){
                        v=PyTuple_GetItem(tup,i);
                        /*                               v=PySequence_GetItem(tup,i); */
                        s=PyString_AsString(v);
                        if(s == NULL){
                                printf("s : ");
                                PyObject_Print(v, stdout, 0);
                                printf("\n ");
                                MYABORT("erreur sur le type : devrait etre une string");
                        }

                        /* le fortran attend des chaines de caracteres completees par des blancs */
                        longueur=strlen(s);
                        val_i=&val[i*taille];
                        STRING_FCPY(val_i,taille,s,longueur);
                }
        }
}


/* ------------------------------------------------------------------ */
void converltx( _IN int nval, _IN PyObject *tup, _OUT char *val, _IN int taille)
{
        /*
        Convertit une Liste  en tableau de chaines
        Pour retour au Fortran : le tableau existe deja (val)
        */

        PyObject *v = (PyObject*)0 ;
        int i;
        char *s = (char*)0 ;
        char *val_i      = (char*)0 ;
        int longueur=0 ;

        if(nval != 0){
                if (!PyList_Check(tup)){
                        printf("tup : ");
                        PyObject_Print(tup, stdout, 0);
                        printf("\n ");
                        MYABORT("erreur sur le type : devrait etre une liste");
                }
                for(i=0;i<nval;i++){
                        v=PyList_GetItem(tup,i);
                        /* v=PySequence_GetItem(tup,i); */
                        s=PyString_AsString(v);
                        if(s == NULL){
                                printf("s : ");
                                PyObject_Print(v, stdout, 0);
                                printf("\n ");
                                MYABORT("erreur sur le type : devrait etre une string");
                        }

                        /* le fortran attend des chaines de caracteres completees par des blancs */
                        longueur=strlen(s);
                        val_i=&val[i*taille];
                        STRING_FCPY(val_i,taille,s,longueur);
                }
        }
        return ;
}


/* ------------------------------------------------------------------ */
void STDCALL(GETRAN,getran)(_OUT double *rval)
{
        /*
          Procedure GETRAN pour le FORTRAN : recupere un r�el aleatoire (loi uniforme 0-1) du module python Random
          Entrees :
            neant
          Retourne :
            un reel tir� au hasard
        */

        PyObject *res  = (PyObject*)0 ;
        PyObject *val  = (PyObject*)0 ;
        int ok=0;
        int nval=0;
        int nbval=0;

        _DEBUT(getran) ;

        res=PyObject_CallMethod(commande,"getran","");

        /*  si le retour est NULL : exception Python a transferer
            normalement a l appelant mais FORTRAN ??? */
        if (res == NULL)MYABORT("erreur dans la partie Python");

        ok = PyArg_ParseTuple(res,"O",&val);
        if(!ok)MYABORT("erreur dans la partie Python");

        *rval=PyFloat_AsDouble(val);

        Py_DECREF(res);                /*  decrement sur le refcount du retour */
        _FIN(getran) ;
        return ;
}


/* ------------------------------------------------------------------ */
void DEFP(INIRAN,iniran,_IN INTEGER *jump)
{
        /*
          Procedure INIRAN pour le FORTRAN : recupere un r�el aleatoire (loi uniforme 0-1) du module python Random
          avec un shift eventuel de jump termes
        */

        PyObject *res  = (PyObject*)0 ;

        _DEBUT(iniran) ;
                                                           ISCRUTE(*jump);
        res=PyObject_CallMethod(commande,"iniran","i",*jump);
                                                           ISCRUTE(*jump);
        Py_DECREF(res);                /*  decrement sur le refcount du retour */
        _FIN(iniran) ;
        return ;
}


/* ------------------------------------------------------------------ */
void DEFSS(GETTCO,gettco,_IN char *nomobj, _IN int lnom, _OUT char *typobj, _IN int ltyp)
{
        /*
        Procedure gettco_
          remplace le sous-programme fortran  GETTCO

         BUT :
          retrouver le type "superviseur" du concept nomobj.

        cf. cas : hpla100a
        */

        char *mcs      = (char*)0 ;
        PyObject *res  = (PyObject*)0 ;
        PyObject *tup  = (PyObject*)0 ;
        char *nomType  = (char*)0 ;
        int longueur   = 0 ;
        int ok         = 0 ;
        int nval       = 1 ;
        int k          = 0 ;

        _DEBUT("gettco_") ;
                                                              ASSERT(lnom>0) ;
                                                              FSSCRUTE(nomobj,lnom);
        mcs=fstr2(nomobj,lnom);

        /*
        recherche dans le jeu de commandes python du nom du type de
         du concept Aster de nom nomobj
        */
                                                              ASSERT(commande!=(PyObject*)0);
                                                              SSCRUTE(mcs) ;
        res=PyObject_CallMethod(commande,"gettco","s",mcs);
        if (res == (PyObject*)0)MYABORT("erreur dans la partie Python (gettco)");
                                                              OBSCRUTE(res);
                                                              ASSERT( PyString_Check(res) )
        nomType=PyString_AsString(res);
                                                              SSCRUTE(nomType);
                                                              ASSERT(nomType!=(char*)0) ;
        longueur = strlen(nomType) ;
                                                              ASSERT(longueur>0) ;
                                                              ASSERT(longueur<=ltyp) ;
        STRING_FCPY(typobj,ltyp,nomType,longueur);
                                                              ASSERT(EstPret(typobj,ltyp)) ;

        Py_DECREF(res);                /*  decrement sur le refcount du retour */
        _FIN("gettco_") ;
        return ;
}


/* ------------------------------------------------------------------ */
void DEFPS(GETMAT,getmat,_OUT INTEGER *nbarg,_OUT char *motcle,_IN int lcle)
{

        /*
          Procedure GETMAT pour le FORTRAN
          Routine a l usage de DEFI_MATERIAU : consultation du catalogue (et non de l etape)
          Retourne :
            le nombre de mots cles facteur sous la commande, y compris en eliminant les blocs
            la liste de leur noms
        */

        PyObject *res   = (PyObject*)0 ;
        PyObject *lnom  = (PyObject*)0 ; /* liste python des noms */
        int       nval = 0 ;
        int          k = 0 ;


        _DEBUT(getmat_) ;
                                                                        ISCRUTE(lcle);
                                                                        ASSERT(lcle>0);
        for ( k=0 ;k<lcle ; k++ ) motcle[k]=' ' ;
                                                                        ASSERT(commande!=(PyObject*)0);
        res=PyObject_CallMethod(commande,"getmat","");
        /*  si le retour est NULL : exception Python a transferer
            normalement a l appelant mais FORTRAN ??? */
        if (res == NULL)MYABORT("erreur dans la partie Python");
        /*  si non impression du retour */

        if(!PyArg_ParseTuple(res,"O",&lnom)) MYABORT("erreur dans la partie Python");
        nval=PyList_Size(lnom);
                                                                        ISCRUTE(nval) ;
        *nbarg = nval ;
                                                                        ISCRUTE(*nbarg) ;

        if ( nval > 0 ){
                converltx(nval,lnom,motcle,lcle); /* conversion  */
        }

        Py_DECREF(res);                /*  decrement sur le refcount du retour */
        _FIN("getmat_") ;
        return ;
}


/* ------------------------------------------------------------------ */
void DEFSPPSSP(GETMJM,getmjm,_IN char *nomfac,_IN int lfac,_IN INTEGER *iocc,_IN INTEGER *nbval,
                            _OUT char *motcle,_IN int lcle,_OUT char *type,_IN int ltyp, _OUT INTEGER *nbarg)
{

        /*
          Procedure GETMJM : emule la procedure equivalente ASTER
           Retourne les nbval premiers mots cles du mot cle facteur nomfac du catalogue de la commande en cours
          Entrees :
           nomfac : nom du mot cle facteur
           iocc   : numero d occurence du mot cle facteur
           nbval  : nombre de mots cles facteurs demandes
          Retourne :
           motcle : liste des mots cles du mot cle facteur demande
           type   : liste des types des mots cles du mot cle facteur demande
                    R8 , R8L : un reel ou une liste de reels ;
                    C8 , C8L : un complexe ou une liste de complexes ;
                     ...
                    CO , COL : un concept ou une liste de concepts.
           nbarg  : nombre d arguments des mots cles du mot cle facteur
        */

        PyObject *res   = (PyObject*)0 ;
        PyObject *lnom  = (PyObject*)0 ;
        PyObject *lty   = (PyObject*)0 ; /* liste python des noms */
        int       nval = 0 ;
        int          k = 0 ;
        int        ioc = 0 ;


        _DEBUT(getmjm_) ;
                                                                        ISCRUTE(*iocc);
                                                                        ISCRUTE(*nbval);
                                                                        FSSCRUTE(nomfac,lfac) ; ISCRUTE(ltyp);
                                                                        ASSERT(ltyp>0);
        for ( k=0 ;k<ltyp ; k++ ) type[k]=' ' ;
                                                        ISCRUTE(*iocc);
        ioc=*iocc ;
        ioc=ioc-1 ;
                                                                        ASSERT(commande!=(PyObject*)0);
        res=PyObject_CallMethod(commande,"getmjm","sii",fstr2(nomfac,lfac),ioc,*nbval);
                                                                        ISCRUTE(*iocc);
                                                                        ISCRUTE(*nbval);
        /*  si le retour est NULL : exception Python a transferer
            normalement a l appelant mais FORTRAN ??? */
        if (res == NULL)MYABORT("erreur dans la partie Python");
        /*  si non impression du retour */


        if(!PyArg_ParseTuple(res,"OO",&lnom,&lty)) MYABORT("erreur dans la partie Python");
        nval=PyList_Size(lnom);

                                                                        ISCRUTE(nval) ; ISCRUTE(*nbval) ;

        *nbarg = (nval > *nbval) ? -nval : nval ;
                                                                        ISCRUTE(*nbarg) ;
                                                                        ASSERT(((nval<=*nbval)&&(*nbarg==nval))||(*nbarg==-nval)) ;

        if(*nbarg < 0)nval=*nbval;
                                                                        ISCRUTE(nval) ;

        if ( nval > 0 ){
                converltx(nval,lnom,motcle,lcle); /* conversion  */
                converltx(nval,lty,type,ltyp);
       }


        /*
        A.Y.
        A la demande des developpeurs (J. Pellet), le nom des concepts retourne par
        la methode EXECUTION.getmjm (par exemple grma) est ici remplace par
        la chaine CO (pour COncept).
        les types retournes sont donc parmi les valeurs : R8 , C8 , IS , TX et CO.
        */

        for( k=0 ; k<nval*ltyp ; k+=ltyp ){
                char     *mot = (char*)0 ;
                mot           = type+k ;
                if ( strncmp( mot , "R8" , 2 )!=0 && strncmp( mot , "IS" , 2 )!=0 && strncmp( mot , "TX" , 2 )!=0 && strncmp( mot , "C8" , 2 )!=0 ){
                        int j=0 ;

                        ASSERT(ltyp>2);
                        mot[0]='C' ;
                        mot[1]='O' ;
                        for ( j=2 ; j<ltyp ; j++ ) mot[j]=' ' ;
                }
        }

        Py_DECREF(res);                /*  decrement sur le refcount du retour */
        _FIN("getmjm_") ;
        return ;
}


/* ------------------------------------------------------------------ */
FORTRAN_LOGICAL DEFSS( GETEXM ,getexm, _IN char *motfac,_IN int lfac,_IN char *motcle,_IN int lcle)
{
        /*
          Procedure GETEXM pour le FORTRAN : emule le fonctionnement
          de la procedure equivalente ASTER
          Entrees :
            le nom d un mot cle facteur : motfac (string)
            le nom d un mot cle simple ou sous mot cle : motcle (string)
          Retourne :
            0 si n existe pas 1 si existe

          ATTENTION : la valeur C 0 correspond a le valeur Fortran .FORTRAN_FALSE.
        */
        PyObject *res  = (PyObject*)0 ;
        FORTRAN_LOGICAL presence     = FORTRAN_FALSE;

        _DEBUT(getexm_) ;
                                                                        FSSCRUTE(motfac,lfac) ; FSSCRUTE(motcle,lcle) ;
                                                                        ASSERT(motcle!=(char*)0);
                                                                        ASSERT(commande!=(PyObject*)0);
        res=PyObject_CallMethod(commande,"getexm","ss",
                                fstr1(motfac,lfac),fstr2(motcle,lcle));
        /*  si le retour est NULL : exception Python a transferer
            normalement a l appelant mais FORTRAN ??? */
        if (res == NULL)MYABORT("erreur dans la partie Python");
                                                                        OBSCRUTE(res);
        presence=PyInt_AsLong(res) ? FORTRAN_TRUE : FORTRAN_FALSE ;
        /*  decrement sur le refcount du retour */
                                                                        ISCRUTE(presence) ;
                                                                        FSSCRUTE(motcle,lcle) ;
        Py_DECREF(res);                /*  decrement sur le refcount du retour */
        _FIN(getexm_) ;
        return presence;
}


/* ------------------------------------------------------------------ */
void DEFSSS( GETRES ,getres, _OUT char *nomres, _IN int lres, _OUT char *concep, _IN int lconc, _OUT char *nomcmd, _IN int lcmd)
{
        /*
          Procedure GETRES pour le FORTRAN : emule le fonctionnement
          de la procedure equivalente ASTER
          Retourne
            le nom utilisateur du resultat : nomres (string)
            le nom du concept resultat     : concep (string)
            le nom de la commande          : nomcmd (string)
        */
        PyObject *res  = (PyObject*)0 ;
        int ok;
        int s1,s2,s3;
        char *ss1,*ss2,*ss3;

        _DEBUT(getres_) ;
                                                       ISCRUTE(lres) ; ISCRUTE(lconc) ; ISCRUTE(lcmd) ;
        /* (MC) le 1er test ne me semble pas suffisant car entre deux commandes,
           commande n'est pas remis � (PyObject*)0... */
        if(commande == (PyObject*)0 || PyObject_HasAttrString(commande, "getres")==0) {
          /* Aucune commande n'est active on retourne des chaines blanches */
          BLANK(nomres,lres);
          BLANK(concep,lconc);
          BLANK(nomcmd,lcmd);
          return ;
        }
                                                        ASSERT(commande!=(PyObject*)0);
        res=PyObject_CallMethod(commande,"getres","");
        /*  si le retour est NULL : exception Python a transferer
            normalement a l appelant mais FORTRAN ??? */
        if (res == NULL){
          /* Aucune commande n'est active on retourne des chaines blanches */
          BLANK(nomres,lres);
          BLANK(concep,lconc);
          BLANK(nomcmd,lcmd);
          return ;
        }

        ok = PyArg_ParseTuple(res,"s#s#s#",&ss1,&s1,&ss2,&s2,&ss3,&s3);
        if (!ok)MYABORT("erreur dans la partie Python");


        /* le fortran attend des chaines de caracteres completees par des blancs */
                                                       ISCRUTE(s1) ; SSCRUTE(ss1) ;
        STRING_FCPY(nomres,lres,ss1,s1);
                                                       FSSCRUTE(nomres,lres) ;

                                                       ISCRUTE(s2) ; SSCRUTE(ss2) ;
        STRING_FCPY(concep,lconc,ss2,s2);
                                                       FSSCRUTE(concep,lconc) ;

                                                       ISCRUTE(s3) ; SSCRUTE(ss3) ;
        STRING_FCPY(nomcmd,lcmd,ss3,s3);
                                                       FSSCRUTE(nomcmd,lcmd) ;

        Py_DECREF(res);                /*  decrement sur le refcount du retour */
        _FIN(getres_) ;
        return ;
}


/* ------------------------------------------------------------------ */
void DEFSSPPPPP(GETVC8,getvc8,_IN char *motfac,_IN int lfac,_IN char *motcle,_IN int lcle,_IN INTEGER *iocc,
                              _IN INTEGER *iarg,_IN INTEGER *mxval,_INOUT double *val,_OUT INTEGER *nbval)
{
        /*
          Procedure GETVC8 pour le FORTRAN : emule le fonctionnement
          de la procedure equivalente ASTER
          Entrees :
            le nom d un mot cle facteur : motfac (string)
            le nom d un mot cle simple ou sous mot cle : motcle (string)
            le numero de l occurence du mot cle facteur : iocc (entier)
            le numero de l argument demande (obsolete =1): iarg (entier)
            le nombre max de valeur attendues dans val : mxval (entier)
          Retourne :
            le tableau des valeurs attendues : val (2 reels (double) par complexe)
            le nombre de valeurs effectivement retournees : nbval (entier)
               si pas de valeur nbval =0
               si plus de valeur que mxval nbval <0 et valeur abs = nbre valeurs
               si moins de valeurs que mxval nbval>0 et egal au nombre retourne
        */

        PyObject *res  = (PyObject*)0 ;
        PyObject *tup  = (PyObject*)0 ;
        int ok         = 0 ;
        int nval       = 0 ;
        int ioc        = 0 ;
        char *mfc      = (char*)0 ;
        char *mcs      = (char*)0 ;

        _DEBUT(getvc8_)
                                                        SSCRUTE(PyString_AsString(PyObject_CallMethod(commande,"retnom",""))) ;
                                                        FSSCRUTE(motfac,lfac) ; FSSCRUTE(motcle,lcle) ; ISCRUTE(*iocc) ;
                                                        ASSERT(EstPret(motcle,lcle)!=0);

        mfc=fstr1(motfac,lfac);
                                                        ASSERT(mfc!=(char*)0);
        mcs=fstr2(motcle,lcle);

        /*
                VERIFICATION
                Si le mot-cle simple est recherche sous un mot-cle facteur et uniquement dans ce cas,
                le numero d'occurrence (*iocc) doit etre strictement positif.
                Si le mot-cle simple est recherche sans un mot-cle facteur iocc n'est pas utilise

        */
        if( isalpha(mfc[0])&&(*iocc<=0) )
        {
                printf( "<F> GETVC8 : le numero d'occurence (IOCC=%d) est invalide\n",*iocc) ;
                printf( "             commande : %s\n",PyString_AsString(PyObject_CallMethod(commande,"retnom",""))) ;
                printf( "             mot-cle facteur : %s\n",mfc) ;
                printf( "             mot-cle simple  : %s\n",mcs) ;
                MYABORT( "erreur d'utilisation detectee") ;
        }

                                                        ISCRUTE(*iocc);
        ioc=*iocc ;
        ioc=ioc-1 ;
                                                        ASSERT(commande!=(PyObject*)0);
        res=PyObject_CallMethod(commande,"getvc8","ssiii",mfc,mcs,ioc,*iarg,*mxval);

        /*  si le retour est NULL : exception Python a transferer
            normalement a l appelant mais FORTRAN ??? */
        if (res == NULL)MYABORT("erreur dans la partie Python");
                                                        ASSERT(PyTuple_Check(res)) ;


        ok = PyArg_ParseTuple(res,"lO",nbval,&tup);
        if(!ok)MYABORT("erreur dans la partie Python");

        nval=*nbval;
        if(*nbval < 0)nval=*mxval;

        convc8(nval,tup,val);
                                                        ISCRUTE(*nbval) ;
                                                        TDSCRUTE(nval,val) ;

        Py_DECREF(res);
        _FIN(getvc8_) ;
        return ;
}


/* ------------------------------------------------------------------ */
void DEFSSPPPPP(GETVR8,getvr8,_IN char *motfac,_IN int lfac,_IN char *motcle,_IN int lcle,_IN INTEGER *iocc,
                              _IN INTEGER *iarg,_IN INTEGER *mxval,_INOUT double *val,_OUT INTEGER *nbval)
{
        /*
          Procedure GETVR8 pour le FORTRAN : emule le fonctionnement
          de la procedure equivalente ASTER
          Entrees :
            le nom d un mot cle facteur : motfac (string)
            le nom d un mot cle simple ou sous mot cle : motcle (string)
            le numero de l occurence du mot cle facteur : iocc (entier)
            le numero de l argument demande (obsolete =1): iarg (entier)
            le nombre max de valeur attendues dans val : mxval (entier)
          Retourne :
            le tableau des valeurs attendues : val (tableau de R8    )
            le nombre de valeurs effectivement retournees : nbval (entier)
               si pas de valeur nbval =0
               si plus de valeur que mxval nbval <0 et valeur abs = nbre valeurs
               si moins de valeurs que mxval nbval>0 et egal au nombre retourne
        */

        PyObject *res  = (PyObject*)0 ;
        PyObject *tup  = (PyObject*)0 ;
        int ok         = 0 ;
        int nval       = 0 ;
        int ioc        = 0 ;
        char *mfc      = (char*)0 ;
        char *mcs      = (char*)0 ;

        _DEBUT(getvr8) ;
                                                        SSCRUTE(PyString_AsString(PyObject_CallMethod(commande,"retnom",""))) ;
                                                        FSSCRUTE(motfac,lfac) ; FSSCRUTE(motcle,lcle) ; ISCRUTE(*iocc) ;
                                                        ASSERT(EstPret(motcle,lcle)!=0);
        mfc=fstr1(motfac,lfac); /* conversion chaine fortran en chaine C */
                                                        ASSERT(mfc!=(char*)0);
        mcs=fstr2(motcle,lcle);

        /*
                VERIFICATION
                Si le mot-cle simple est recherche sous un mot-cle facteur et uniquement dans ce cas,
                le numero d'occurrence (*iocc) doit etre strictement positif.
                Si le mot-cle simple est recherche sans un mot-cle facteur iocc n'est pas utilise

        */
        if( isalpha(mfc[0])&&(*iocc<=0) )
        {
                printf( "<F> GETVR8 : le numero d'occurence (IOCC=%d) est invalide\n",*iocc) ;
                printf( "             commande : %s\n",PyString_AsString(PyObject_CallMethod(commande,"retnom",""))) ;
                printf( "             mot-cle facteur : %s\n",mfc) ;
                printf( "             mot-cle simple  : %s\n",mcs) ;
                MYABORT( "erreur d'utilisation detectee") ;
        }


                                                        ISCRUTE(*iocc);
        ioc=*iocc ;
        ioc=ioc-1 ;
                                                        ASSERT(commande!=(PyObject*)0);
        res=PyObject_CallMethod(commande,"getvr8","ssiii",mfc,mcs,ioc,*iarg,*mxval);
        /*  si le retour est NULL : exception Python a transferer
            normalement a l appelant mais FORTRAN ??? */
        if (res == NULL)MYABORT("erreur dans la partie Python");
                                                       OBSCRUTE(res);
                                                       ASSERT(PyTuple_Check(res)) ;
        ok = PyArg_ParseTuple(res,"lO",nbval,&tup);
        if(!ok)MYABORT("erreur dans la partie Python");

        nval=*nbval;
        if(*nbval < 0)nval=*mxval;
        if ( nval>0 ){
                convr8(nval,tup,val);
        }
                                                        ISCRUTE(*nbval) ;
                                                        TDSCRUTE(nval,val) ;

        Py_DECREF(res);                /*  decrement sur le refcount du retour */
        _FIN(getvr8) ;
        return ;
}


/* ------------------------------------------------------------------ */
void DEFSSSPSPPPP(UTPRIN,utprin,_IN char *typmess,_IN int ltype,_IN char *unite,_IN int lunite,_IN char *idmess,_IN int lidmess,_IN INTEGER *nbk,
                                _IN char *valk,_IN int lvk,_IN INTEGER *nbi,_IN INTEGER *vali,_IN INTEGER *nbr,_IN double *valr)
{

        PyObject *tup_valk,*tup_vali,*tup_valr,*res;
        char *kvar;
        int i;

        _DEBUT(utprin) ;
        tup_valk = PyTuple_New( *nbk ) ;
        for(i=0;i<*nbk;i++){
           kvar = valk + i*lvk;
           PyTuple_SetItem( tup_valk, i, PyString_FromStringAndSize(kvar,lvk) ) ;
        }
	
        tup_vali = PyTuple_New( *nbi ) ;	
        for(i=0;i<*nbi;i++){
           PyTuple_SetItem( tup_vali, i, PyInt_FromLong(vali[i]) ) ;
        }
	
        tup_valr = PyTuple_New( *nbr ) ;
        for(i=0;i<*nbr;i++){
           PyTuple_SetItem( tup_valr, i, PyFloat_FromDouble(valr[i]) ) ;
        }

        res=PyObject_CallMethod(static_module,"utprin","s#s#s#OOO",typmess,ltype,unite,lunite,idmess,lidmess,tup_valk,tup_vali,tup_valr);
        if (!res) {
           MYABORT("erreur lors de l'appel � UTPRIN");
        }

        Py_DECREF(tup_valk);
        Py_DECREF(tup_vali);
        Py_DECREF(tup_valr);
	
        _FIN(utprin) ;
        ;
}

/* ------------------------------------------------------------------ */
void DEFSPSPP(FIINTF,fiintf,_IN char *nomfon,_IN int lfon,_IN INTEGER *nbpu,_IN char *param,_IN int lpara,_IN double *val,
                     _OUT double *resu)
{

        PyObject *res  = (PyObject*)0 ;
        PyObject *tup_par;
        PyObject *tup_val;
        char *nfon   = (char*)0 ;
        char *npar   = (char*)0 ;
        char *kvar;
        int i;

        _DEBUT(fiintf) ;
                        DSCRUTE(*val); ISCRUTE(*nbpu) ;
                                                        SSCRUTE(PyString_AsString(PyObject_CallMethod(commande,"retnom",""))) ;
                                                        FSSCRUTE(nomfon,lfon) ; FSSCRUTE(param,lpara) ;
                                                        ASSERT(commande!=(PyObject*)0);
        tup_par = PyTuple_New( *nbpu ) ;
        tup_val = PyTuple_New( *nbpu ) ;
        for(i=0;i<*nbpu;i++){
                   OBSCRUTE(tup_par);
           kvar = param + i*lpara;
           PyTuple_SetItem( tup_par, i, PyString_FromStringAndSize(kvar,lpara) ) ;
        }
        for(i=0;i<*nbpu;i++){
                   OBSCRUTE(tup_val);
           PyTuple_SetItem( tup_val, i, PyFloat_FromDouble(val[i]) ) ;
        }

        res=PyObject_CallMethod(commande,"fiintf","s#OO",nomfon,lfon,tup_par,tup_val);

        if (res == NULL)MYABORT("erreur dans la partie Python");
                            OBSCRUTE(res);
                                                       ASSERT(PyFloat_Check(res)) ;

        *resu=PyFloat_AsDouble(res);

        Py_DECREF(tup_par);
        Py_DECREF(tup_val);
        Py_DECREF(res);           /*  decrement sur le refcount du retour */
        _FIN(fiintf) ;
        return ;
}


/* ------------------------------------------------------------------ */
void DEFSSPPPPP(GETVIS,getvis,_IN char *motfac,_IN int lfac,_IN char *motcle,_IN int lcle,_IN INTEGER *iocc,
                              _IN INTEGER *iarg,_IN INTEGER *mxval,_INOUT INTEGER *val,_OUT INTEGER *nbval )
{
        /*
          Procedure GETVIS pour le FORTRAN : emule le fonctionnement
          de la procedure equivalente ASTER
          Entrees :
            le nom d un mot cle facteur : motfac (string)
            le nom d un mot cle simple ou sous mot cle : motcle (string)
            le numero de l occurence du mot cle facteur : iocc (entier)
            le numero de l argument demande (obsolete =1): iarg (entier)
            le nombre max de valeur attendues dans val : mxval (entier)
          Retourne :
            le tableau des valeurs attendues : val (tableau d entier )
            le nombre de valeurs effectivement retournees : nbval (entier)
               si pas de valeur nbval =0
               si plus de valeur que mxval nbval <0 et valeur abs = nbre valeurs
               si moins de valeurs que mxval nbval>0 et egal au nombre retourne
        */
        PyObject *res  = (PyObject*)0 ;
        PyObject *tup  = (PyObject*)0 ;
        int ok         = 0 ;
        int nval       = 0 ;
        int ioc        = 0 ;
        char *mfc      = (char*)0 ;
        char *mcs      = (char*)0 ;

        _DEBUT(getvis_) ;
                                                        FSSCRUTE(motfac,lfac) ; FSSCRUTE(motcle,lcle) ;
                                                        ASSERT((*iocc>0)||(FindLength(motfac,lfac)==0));
                                                        ASSERT(EstPret(motcle,lcle)!=0);


        mfc=fstr1(motfac,lfac); /* conversion chaine fortran en chaine C */
                                                        ASSERT(mfc!=(char*)0);
        mcs=fstr2(motcle,lcle);

        /*
                VERIFICATION
                Si le mot-cle simple est recherche sous un mot-cle facteur et uniquement dans ce cas,
                le numero d'occurrence (*iocc) doit etre strictement positif.
                Si le mot-cle simple est recherche sans un mot-cle facteur iocc n'est pas utilise

        */
        if( isalpha(mfc[0])&&(*iocc<=0) )
        {
                printf( "<F> GETVIS : le numero d'occurence (IOCC=%d) est invalide\n",*iocc) ;
                printf( "             commande : %s\n",PyString_AsString(PyObject_CallMethod(commande,"retnom",""))) ;
                printf( "             mot-cle facteur : %s\n",mfc) ;
                printf( "             mot-cle simple  : %s\n",mcs) ;
                MYABORT( "erreur d'utilisation detectee") ;
        }

                                                        ISCRUTE(*iocc);
        ioc=*iocc ;
        ioc=ioc-1 ;
                                                        ASSERT(commande!=(PyObject*)0);
        res=PyObject_CallMethod(commande,"getvis","ssiii",mfc,mcs,ioc,*iarg,*mxval);

        /*  si le retour est NULL : exception Python a transferer
            normalement a l appelant mais FORTRAN ??? */
        if (res == NULL)MYABORT("erreur dans la partie Python");

                                                        OBSCRUTE(res) ;
        ok = PyArg_ParseTuple(res,"lO",nbval,&tup);
        if (!ok)MYABORT("erreur dans la partie Python");

        nval=*nbval;
        if(*nbval < 0)nval=*mxval;
        convert(nval,tup,val);

                                                        ISCRUTE(*nbval) ;
                                                        TISCRUTE(nval,val) ;

        Py_DECREF(res);                /*  decrement sur le refcount du retour */
        _FIN(getvis_) ;
        return ;
}


/* ------------------------------------------------------------------ */
void DEFPS(GETVLI,getvli,_OUT INTEGER *unite , _OUT char *cas , _IN int lcas )
{
        /*
        Cette fonction est destinee a etre utilisee pour le fichier "*.code" (fort.15)
        */
        _DEBUT(getvli) ;
                                                        ISCRUTE(lcas);
                                                        ASSERT(NomCas!=(char*)0) ;
        *unite = 15 ;
        CSTRING_FCPY(cas,lcas,NomCas);
                                                        FSSCRUTE(cas,lcas);
        _FIN(getvli) ;
        return ;
}


/* ------------------------------------------------------------------ */
void DEFSSPPPPP(GETVLS,getvls,_IN char *motfac,_IN int lfac,_IN char *motcle,_IN int lcle,_IN INTEGER *iocc,
                              _IN INTEGER *iarg,_IN INTEGER *mxval,_INOUT INTEGER *val,_OUT INTEGER *nbval )
{
        /*
          Procedure GETVLS pour le FORTRAN : emule le fonctionnement
          de la procedure equivalente ASTER
          Entrees :
            le nom d un mot cle facteur : motfac (string)
            le nom d un mot cle simple ou sous mot cle : motcle (string)
            le numero de l occurence du mot cle facteur : iocc (entier)
            le numero de l argument demande (obsolete =1): iarg (entier)
            le nombre max de valeur attendues dans val : mxval (entier)
          Retourne :
            le tableau des valeurs attendues : val (tableau de logical )
            le nombre de valeurs effectivement retournees : nbval (entier)
               si pas de valeur nbval =0
               si plus de valeur que mxval nbval <0 et valeur abs = nbre valeurs
               si moins de valeurs que mxval nbval>0 et egal au nombre retourne
        */

        PyObject *res  = (PyObject*)0 ;
        PyObject *tup  = (PyObject*)0 ;
        int ok         = 0 ;
        int nval       = 0 ;
        int ioc        = 0 ;
        char *mfc      = (char*)0 ;
        char *mcs      = (char*)0 ;

        _DEBUT(getvls_) ;
                                                        FSSCRUTE(motfac,lfac) ; FSSCRUTE(motcle,lcle) ;
                                                        ASSERT((*iocc>0)||(FindLength(motfac,lfac)==0));
                                                        ASSERT(EstPret(motcle,lcle)!=0);


        mfc=fstr1(motfac,lfac); /* conversion chaine fortran en chaine C */
                                                        ASSERT(mfc!=(char*)0);
        mcs=fstr2(motcle,lcle);

        /*
                VERIFICATION
                Si le mot-cle simple est recherche sous un mot-cle facteur et uniquement dans ce cas,
                le numero d'occurrence (*iocc) doit etre strictement positif.
                Si le mot-cle simple est recherche sans un mot-cle facteur iocc n'est pas utilise

        */
        if( isalpha(mfc[0])&&(*iocc<=0) )
        {
                printf( "<F> GETVLS : le numero d'occurence (IOCC=%d) est invalide\n",*iocc) ;
                printf( "             commande : %s\n",PyString_AsString(PyObject_CallMethod(commande,"retnom",""))) ;
                printf( "             mot-cle facteur : %s\n",mfc) ;
                printf( "             mot-cle simple  : %s\n",mcs) ;
                MYABORT( "erreur d'utilisation detectee") ;
        }

                                                        ISCRUTE(*iocc);
        ioc=*iocc ;
        ioc=ioc-1 ;
                                                        ASSERT(commande!=(PyObject*)0);
        res=PyObject_CallMethod(commande,"getvls","ssiii",mfc,mcs,ioc,*iarg,*mxval);

        /*  si le retour est NULL : exception Python a transferer
            normalement a l appelant mais FORTRAN ??? */
        if (res == NULL)MYABORT("erreur dans la partie Python");

        ok = PyArg_ParseTuple(res,"lO",nbval,&tup);
        if (!ok)MYABORT("erreur dans la partie Python");

        nval=*nbval;
        if(*nbval < 0)nval=*mxval;
        convert(nval,tup,val);
                                                        ISCRUTE(*nbval) ;
                                                        TISCRUTE(nval,val) ;

        Py_DECREF(res);                /*  decrement sur le refcount du retour */
        _FIN(getvls_) ;
        return ;
}


/* ------------------------------------------------------------------ */
void DEFSSPPPSP(GETVTX,getvtx,_IN char *motfac,_IN int lfac,_IN char *motcle,_IN int lcle,_IN INTEGER *iocc,
                              _IN INTEGER *iarg,_IN INTEGER *mxval,_INOUT char *txval,_IN int ltx,_OUT INTEGER *nbval)
{
        /*
          Procedure GETVTX pour le FORTRAN : emule le fonctionnement
          de la procedure equivalente ASTER
          Entrees :
            le nom d un mot cle facteur : motfac (string)
            le nom d un mot cle simple ou sous mot cle : motcle (string)
            le numero de l occurence du mot cle facteur : iocc (entier)
            le numero de l argument demande (obsolete =1): iarg (entier)
            le nombre max de valeur attendues dans val : mxval (entier)
          Retourne :
            le tableau des valeurs attendues : txval (tableau de string)
            ATTENTION : txval arrive avec une valeur par defaut
            le nombre de valeurs effectivement retournees : nbval (entier)
               si pas de valeur nbval =0
               si plus de valeur que mxval nbval <0 et valeur abs = nbre valeurs
               si moins de valeurs que mxval nbval>0 et egal au nombre retourne

        */
        PyObject *res  = (PyObject*)0 ;
        PyObject *tup  = (PyObject*)0 ;
        int ok         = 0 ;
        int nval       = 0 ;
        int ioc        = 0 ;
        int k          = 0 ;
        char *mfc      = (char*)0 ;
        char *mcs      = (char*)0 ;

        _DEBUT(getvtx_) ;
                                                        SSCRUTE(PyString_AsString(PyObject_CallMethod(commande,"retnom",""))) ;
                                                        FSSCRUTE(motfac,lfac) ; FSSCRUTE(motcle,lcle) ; ISCRUTE(ltx) ; ISCRUTE(*iocc) ;
                                                        /*ASSERT((*iocc>0)||(FindLength(motfac,lfac)==0));*/


        mfc=fstr1(motfac,lfac); /* conversion chaine fortran en chaine C */
                                                        ASSERT(mfc!=(char*)0);
        mcs=fstr2(motcle,lcle);

        /*
                VERIFICATION
                Si le mot-cle simple est recherche sous un mot-cle facteur et uniquement dans ce cas,
                le numero d'occurrence (*iocc) doit etre strictement positif.
                Si le mot-cle simple est recherche sans un mot-cle facteur iocc n'est pas utilise

        */
        if( isalpha(mfc[0])&&(*iocc<=0) )
        {
                printf( "<F> GETVTX : le numero d'occurence (IOCC=%d) est invalide\n",*iocc) ;
                printf( "             commande : %s\n",PyString_AsString(PyObject_CallMethod(commande,"retnom",""))) ;
                printf( "             mot-cle facteur : %s\n",mfc) ;
                printf( "             mot-cle simple  : %s\n",mcs) ;
                MYABORT( "erreur d'utilisation detectee") ;
        }
                                                        ISCRUTE(*iocc);
        ioc=*iocc ;
        ioc=ioc-1 ;
                                                        ASSERT(commande!=(PyObject*)0);
        res=PyObject_CallMethod(commande,"getvtx","ssiii",mfc,mcs,ioc,*iarg,*mxval);

        /*  si le retour est NULL : exception Python a transferer
            normalement a l appelant mais FORTRAN ??? */
        if (res == NULL)MYABORT("erreur dans la partie Python");

                                                        OBSCRUTE(res);

        ok = PyArg_ParseTuple(res,"lO",nbval,&tup);
        if (!ok)MYABORT("erreur au decodage d'une chaine dans le module C aster.getvtx");

                                                        ISCRUTE(*nbval);
                                                        ISCRUTE(*mxval);
                                                        ISCRUTE(ltx);
                                                        OBSCRUTE(tup);
        nval=*nbval;
        if(*nbval < 0)nval=*mxval;

        if( nval > 0 ){
                convertxt(nval,tup,txval,ltx);
                                                        FSSCRUTE(txval,nval*ltx) ;
        }

        /* ATTENTION : il ne faut decrementer le compteur de references de res
         *             qu'apres en avoir fini avec l'utilisation de tup.
         *             NE PAS decrementer le compteur de references de tup car
         *             la disparition de res entrainera un decrement automatique
         *             du compteur de tup (res=(nbval,tup))
         */
        Py_DECREF(res);                /*  decrement sur le refcount du retour */
        _FIN(getvtx_) ;
        return ;
}


/* ------------------------------------------------------------------ */
void DEFSSPPPSP(GETVID,getvid,_IN char *motfac,_IN int lfac,_IN char *motcle,_IN int lcle,_IN INTEGER *iocc,
                              _IN INTEGER *iarg,_IN INTEGER *mxval,_INOUT char *txval,_IN int ltx,_OUT INTEGER *nbval)
{
        /*
          Procedure GETVID pour le FORTRAN : emule le fonctionnement
          de la procedure equivalente ASTER
          Entrees :
            le nom d un mot cle facteur : motfac (string)
            le nom d un mot cle simple ou sous mot cle : motcle (string)
            le numero de l occurence du mot cle facteur : iocc (entier)
            le numero de l argument demande (obsolete =1): iarg (entier)
            le nombre max de valeur attendues dans val : mxval (entier)
          Retourne :
            le tableau des valeurs attendues : val (tableau de string)
            le nombre de valeurs effectivement retournees : nbval (entier)
               si pas de valeur nbval =0
               si plus de valeur que mxval nbval <0 et valeur abs = nbre valeurs
               si moins de valeurs que mxval nbval>0 et egal au nombre retourne
        */
        PyObject *res  = (PyObject*)0 ;
        PyObject *tup  = (PyObject*)0 ;
        int ok,nval,ioc ;
        char *mfc;
        char *mcs;


        _DEBUT(getvid_) ;
                                                        SSCRUTE(PyString_AsString(PyObject_CallMethod(commande,"retnom",""))) ;
                                                        FSSCRUTE(motfac,lfac) ; FSSCRUTE(motcle,lcle) ;
                                                        ASSERT((*iocc>0)||(FindLength(motfac,lfac)==0));



        mfc=fstr1(motfac,lfac); /* conversion chaine fortran en chaine C */
                                                        ASSERT(mfc!=(char*)0);
        mcs=fstr2(motcle,lcle);

        /*
                VERIFICATION
                Si le mot-cle simple est recherche sous un mot-cle facteur et uniquement dans ce cas,
                le numero d'occurrence (*iocc) doit etre strictement positif.
                Si le mot-cle simple est recherche sans un mot-cle facteur iocc n'est pas utilise

        */
        if( isalpha(mfc[0])&&(*iocc<=0) )
        {
                printf( "<F> GETVID : le numero d'occurence (IOCC=%d) est invalide\n",*iocc) ;
                printf( "             commande : %s\n",PyString_AsString(PyObject_CallMethod(commande,"retnom",""))) ;
                printf( "             mot-cle facteur : %s\n",mfc) ;
                printf( "             mot-cle simple  : %s\n",mcs) ;
                MYABORT( "erreur d'utilisation detectee") ;
        }


                                                        ISCRUTE(*iocc);
        ioc=*iocc ;
        ioc=ioc-1 ;
                                                        ASSERT(commande!=(PyObject*)0);
        res=PyObject_CallMethod(commande,"getvid","ssiii",mfc,mcs,ioc,*iarg,*mxval);

        /*  si le retour est NULL : exception Python a transferer
            normalement a l appelant mais FORTRAN ??? */
        if (res == NULL)MYABORT("erreur dans la partie Python");

                                                        OBSCRUTE(res);

        ok = PyArg_ParseTuple(res,"lO",nbval,&tup);
        if (!ok)MYABORT("erreur dans la partie Python");

                                                        ISCRUTE((INTEGER)*nbval) ;

        nval=*nbval;
        if(*nbval < 0)nval=*mxval;
                                                        ISCRUTE(nval) ;
        if ( nval > 0 ){
                convertxt(nval,tup,txval,ltx);
                                                        ISCRUTE(ltx) ;
                                                        ISCRUTE(nval*ltx) ;
                                                        FSSCRUTE(txval,nval*ltx) ;
        }

        Py_DECREF(res);                /*  decrement sur le refcount du retour */
        _FIN(getvid_) ;
        return ;
}


/* ------------------------------------------------------------------ */
void DEFPPP(SMCDEL,smcdel,INTEGER *iold,INTEGER *inew,INTEGER *ierusr)
{
        /*
          Entrees:
            iold ancien numero d ordre de la commande
            inew nouveau numero d ordre de la commande (si inew < iold, commande detruite)
          Sorties:
            ierusr code retour d erreur incremente
        */
        PyObject *res  = (PyObject*)0 ;

        /*
           Normalement on doit utiliser l dans le format pour des entiers de type long (INTEGER==long)
        */
        _DEBUT("smcdel_")
        res=PyObject_CallMethod(commande,"smcdel","ll",*iold,*inew);

        /*
            Si le retour est NULL : une exception a ete levee dans le code Python appele
            Cette exception est a transferer normalement a l appelant mais FORTRAN ???
            On produit donc un abort en ecrivant des messages sur la stdout
        */
        if (res == NULL)MYABORT("erreur a l appel de smcdel dans la partie Python");
        *ierusr=*ierusr+PyInt_AsLong(res);
        Py_DECREF(res);
        _FIN("smcdel_")
}


/* ------------------------------------------------------------------ */
long FindLength( _IN char *chaineFortran , _IN INTEGER longueur )
{
        /*
        Fonction  : FindLength
        Intention
                Retourne la taille exacte de la chaine de caracteres fortran
                chaineFortran contenant eventuellement des blancs de fin de ligne..
                La taille exacte est la longueur de la chaine du debut au
                dernier caractere non blanc.
        */

        long k = longueur-1 ;
        if ( ! chaineFortran ) return 0 ;

        while( k>=0 && chaineFortran[k]==' ' ) k-- ;
        return k+1 ;
}


/* ------------------------------------------------------------------ */
PyObject * MakeTupleString(long nbval,char *kval,int lkval,INTEGER *lval)
{
   /*
            Entrees:
               nbval nombre de chaines dans kval
               kval  tableau de nbval chaines FORTRAN
               lkval longueur des chaines FORTRAN (compilateur)
               lval  longueur des nbval chaines FORTRAN (utilisateur)
            Sorties:
               RETOUR fonction : tuple de string Python de longueur nbval
            Fonction:
               Convertir un tableau de chaines FORTRAN en un tuple de string Python de meme longueur
   */
   int i, len;
   char *deb=kval;
   if(nbval == 1){
      if (lval) {
         len = lval[0];
      } else {
         len = lkval;
      }
      return PyString_FromStringAndSize(deb, FindLength(deb,len));
   }
   else{
      PyObject *t=PyTuple_New(nbval);
      for(i=0;i<nbval;i++){
         if (lval) {
            len = lval[i];
         } else {
            len = lkval;
         }
         if( PyTuple_SetItem(t,i,PyString_FromStringAndSize(deb,FindLength(deb,len)))) {
            Py_DECREF(t);
            return NULL;
         }
         deb=deb+lkval;
      }
      return t;
   }
}

/* ------------------------------------------------------------------ */
PyObject * MakeListString( long nbval,char *kval,int lkval )
{
   /*
            Entrees:
               nbval nombre de chaines dans kval
               kval  tableau de nbval chaines FORTRAN
               lkval longueur des chaines FORTRAN (compilateur)
            Sorties:
               RETOUR fonction : tuple de string Python de longueur nbval les espaces terminant la
               chaine sont supprimes
            Fonction:
               Convertir un tableau de chaines FORTRAN en un tuple de string Python de meme longueur
   */
   int i;
   char *deb=kval;
   PyObject *l=PyList_New(nbval);
   for(i=0;i<nbval;i++){
      if( PyList_SetItem(l,i,PyString_FromStringAndSize(deb,FindLength(deb,lkval)))) {
         Py_DECREF(l);
         return NULL;
      }
      deb=deb+lkval;
   }
   return l;
}


/* ------------------------------------------------------------------ */
PyObject * MakeTupleInt(long nbval,long* kval)
{
   /*
            Entrees:
               nbval nombre d'entiers dans kval
               kval  tableau de nbval long FORTRAN
            Sorties:
               RETOUR fonction : tuple de int Python de longueur nbval
            Fonction:
               Convertir un tableau de long FORTRAN en un tuple de int Python de meme longueur
   */
   int i;
   if(nbval == 1){
      return PyInt_FromLong(*kval);
   }
   else{
      PyObject * t=PyTuple_New(nbval);
      for(i=0;i<nbval;i++){
         if(PyTuple_SetItem(t,i,PyInt_FromLong(kval[i]))) {
         Py_DECREF(t);
         return NULL;
         }
      }
      return t;
   }
}

/* ------------------------------------------------------------------ */
PyObject * MakeListInt(long nbval,long* kval)
{
   /*
            Entrees:
               nbval nombre d'entiers dans kval
               kval  tableau de nbval long FORTRAN
            Sorties:
               RETOUR fonction : liste de int Python de longueur nbval
            Fonction:
               Convertir un tableau de long FORTRAN en une liste de int Python de meme longueur
   */
   int i;
   PyObject *l=PyList_New(nbval);
   for(i=0;i<nbval;i++){
      if (PyList_SetItem(l,i,PyInt_FromLong(kval[i]))) {
         Py_DECREF(l);
         return NULL;
      }
   }
   return l;
}



/* ------------------------------------------------------------------ */
PyObject * MakeTupleFloat(long nbval,double * kval)
{
   /*
            Entrees:
               nbval nombre de reels dans kval
               kval  tableau de nbval double FORTRAN
            Sorties:
               RETOUR fonction : tuple de float Python de longueur nbval
            Fonction:
               Convertir un tableau de double FORTRAN en un tuple de float Python de meme longueur
   */
   int i;
   if(nbval == 1){
      return PyFloat_FromDouble(*kval);
   }
   else{
      PyObject * t=PyTuple_New(nbval);
      for(i=0;i<nbval;i++){
         if(PyTuple_SetItem(t,i,PyFloat_FromDouble(kval[i]))) {
            Py_DECREF(t);
            return NULL;
         }
      }
      return t;
   }
}

/* ------------------------------------------------------------------ */
PyObject * MakeListFloat(long nbval,double * kval)
{
   /*
            Entrees:
               nbval nombre de reels dans kval
               kval  tableau de nbval double FORTRAN
            Sorties:
               RETOUR fonction : list de float Python de longueur nbval
            Fonction:
               Convertir un tableau de double FORTRAN en une liste de float Python de meme longueur
   */
   int i;
   PyObject *l=PyTuple_New(nbval);
   for(i=0;i<nbval;i++){
      if(PyList_SetItem(l,i,PyFloat_FromDouble(kval[i]))) {
         Py_DECREF(l);
         return NULL;
      }
   }
   return l;
}


/* ------------------------------------------------------------------ */
void STDCALL(PUTVIR,putvir) (_IN INTEGER *ival)
{
   /*
      Entrees:
         ival entier � affecter
      Fonction:
         renseigner l'attribut valeur associ� � la sd
         n'est utile que pour DEFI_FICHIER
         cet attribut est ensuite �valu� par la m�thode traite_value
         de B_ETAPE.py
   */
   PyObject *res = (PyObject*)0 ;
   _DEBUT("putvir_") ;
   ISCRUTE(*ival) ;

   res = PyObject_CallMethod(commande,"putvir","i",*ival);
   /*
         Si le retour est NULL : une exception a ete levee dans le code Python appele
         Cette exception est a transferer normalement a l appelant mais FORTRAN ???
         On produit donc un abort en ecrivant des messages sur la stdout
   */
   if (res == NULL)
      MYABORT("erreur a l appel de putvir dans la partie Python");

   Py_DECREF(res);
   _FIN("putvir_") ;
}


/* ------------------------------------------------------------------ */
void DEFSSP(GCUCON,gcucon, char *resul, int lresul, char *concep, int lconcep, INTEGER *ier)
{
   /*
            Entrees:
               resul   nom du concept
               concep type du concept
            Sorties :
               ier     >0 le concept existe avant
                        =0 le concept n'existe pas avant
                        <0 le concept existe avant mais n'est pas du bon type
            Fonction:
               Verification de l existence du couple (resul,concep) dans les
               resultats produits par les etapes precedentes
   */
   PyObject * res = (PyObject*)0 ;
   _DEBUT("gcucon_") ;
                                                                              ASSERT(lresul) ;
                                                                              ASSERT(lconcep) ;
   res = PyObject_CallMethod(commande,"gcucon","s#s#",resul,lresul,concep,lconcep);
   /*
               Si le retour est NULL : une exception a ete levee dans le code Python appele
               Cette exception est a transferer normalement a l appelant mais FORTRAN ???
               On produit donc un abort en ecrivant des messages sur la stdout
   */
   if (res == NULL)
            MYABORT("erreur a l appel de gcucon dans la partie Python");

   *ier = PyInt_AsLong(res);
   Py_DECREF(res);
   _FIN("gcucon_") ;
}


/* ------------------------------------------------------------------ */
void DEFPSP(GCUCDT,gcucdt,INTEGER *icmd,char *resul,int lresul,INTEGER *ier)
{
        /*
        Emulation de la fonction ASTER correspondante

        Entrees:
                icmd    numero de la commande
                resul   nom du concept
                Sorties :
                ier     >0 le concept existe avant
                        =0 le concept n'existe pas avant
                        <0 le concept existe avant mais est detruit
        Fonction:
                VERIFICATION DE L'EXISTENCE D'UN CONCEPT DANS LES
                DECLARATIONS PRECEDENTES (IE JUSQU'A L'ORDRE ICMD-1)
        Commentaire :
                L'�mulation de la fonction est seulement partielle. On utilise
                la fonction gcucon qui ne donne pas l'information sur les concepts
                detruits
        */
        PyObject * res = (PyObject*)0 ;
        _DEBUT("gcucdt_") ;
        res = PyObject_CallMethod(commande,"gcucon","ls#s",*icmd,resul,lresul,"");
        /*
           Si le retour est NULL : une exception a ete levee dans le code Python appele
            Cette exception est a transferer normalement a l appelant mais FORTRAN ???
            On produit donc un abort en ecrivant des messages sur la stdout
        */
        if (res == NULL)
                MYABORT("erreur a l appel de gcucdt dans la partie Python");

        *ier = PyInt_AsLong(res);
        /*
                ier= -1 indique que le concept existe mais d'un autre type. On doit donc
                retourner 1
        */
        if(*ier==-1)*ier=1;
                                                                                     ISCRUTE(*ier);
        Py_DECREF(res);
        _FIN("gcucdt_") ;
}


/* ------------------------------------------------------------------ */
void DEFSSPPP(GETTVC,gettvc,char * nom,int lnom,char *ctyp,int lctyp,INTEGER *ival,double *rval,INTEGER *ier)
{
        /*
                  Entrees:
                    nom    numero de la commande
                  Sorties :
                    ctyp    type de la constante (IS,R8,C8,LS)
                    ival    valeur de la constante si IS ou LS
                    rval    valeur de la constante si R8 ou C8 (dimension 2)
                    ier     >0 la constante existe
                            =0 la constante n'existe pas
                  Fonction:
                    Retourner la valeur de la constante nom si elle existe
                    si elle n existe pas ier = 0
                  Commentaire : RAS
        */
        PyObject * res = (PyObject*)0 ;
        PyObject * valeur = (PyObject*)0 ;
        int ok=0;
        _DEBUT("gettvc_") ;
        *ier=0;
        res = PyObject_CallMethod(commande,"gettvc","s#",nom,lnom);
        /*
                    Si le retour est NULL : une exception a ete levee dans le code Python appele
                    Cette exception est a transferer normalement a l appelant mais FORTRAN ???
                    On produit donc un abort en ecrivant des messages sur la stdout
        */
        if (res == NULL)
                MYABORT("erreur a l appel de gettvc dans la partie Python");

        ok=PyArg_ParseTuple(res, "lO",ier,&valeur);
        if(!ok)MYABORT("erreur dans gettvc_ ");
                                                                              REFSCRUTE(valeur) ;
        if(PyInt_Check(valeur)){
          *ival=PyInt_AsLong(valeur);
          strncpy(ctyp,"IS  ",4);
        }
        else if(PyFloat_Check(valeur)){
          *rval=PyFloat_AsDouble(valeur);
          strncpy(ctyp,"R8  ",4);
        }
        else{
          *ier=0;
        }

        Py_DECREF(res); /* le compteur de references de valeur sera automatiquement decremente */
        _FIN("gettvc_") ;
}


/* ------------------------------------------------------------------ */
void DEFPPP(GCECDU,gcecdu,INTEGER *ul,INTEGER *icmdu, INTEGER *numint)
{
        /*
          Entrees:
            ul      unite logique pour les ecritures
            icmdu   numero de la commande
          Sorties :
            numint  numero de l operateur de la commande
          Fonction:
             Ecriture d'un operateur ou d une commande utilisateur avec ses arguments (pas implemente)
             Recuperation du numero de l operateur
        */
        PyObject * res = (PyObject*)0 ;
        _DEBUT("gcecdu_") ;
        res = PyObject_CallMethod(commande,"getoper","");
        /*
                    Si le retour est NULL : une exception a ete levee dans le code Python appele
                    Cette exception est a transferer normalement a l appelant mais FORTRAN ???
                    On produit donc un abort en ecrivant des messages sur la stdout
        */
        if (res == NULL)
                MYABORT("erreur a l appel de gcecdu dans la partie Python");

        *numint = PyInt_AsLong(res);
        Py_DECREF(res);
        _FIN("gcecdu_") ;
}



/* ------------------------------------------------------------------ */
void gcncon2_(char *type,char *resul,int ltype,int lresul)
{
/* CCAR : cette fonction devrait s appeler gcncon mais elle est utilisee par
          tous les operateurs (???) et pas seulement dans les macros
          Pour le moment il a ete decide de ne pas l'emuler dans le superviseur
          Python mais d'utiliser les fonctions FORTRAN existantes
          Ceci a l avantage d'assurer la coherence entre tous les operateurs
          et de conserver les fonctionnalites de poursuite pour les macros
*/
        /*
          Entrees:
            type vaut soit
                    '.' : le concept sera detruit en fin de job
                    '_' : le concept ne sera pas detruit

          Sorties:
            resul  nom d'un concept delivre par le superviseur
                   Ce nom est de la forme type // '000ijkl' ou ijkl est un nombre
                   incremente a chaque appel pour garantir l unicite des noms

          Fonction:
            Delivrer un nom de concept non encore utilise et unique
        */
        MYABORT("Cette procedure n est pas implementee");
}

/* ------------------------------------------------------------------ */
/*
 * Pour conserver le lien entre le code de calcul en Fortran et le superviseur
 * en Python, on memorise la commande courante.
 * Cette commande est celle que le fortran interroge lors de ses appels � l'API
 * GETXXX.
 * Cette commande courante est enregistr�e dans une pile de commandes car avec le
 * m�canisme des macros, une commande peut avoir des sous commandes qui sont
 * appel�es pendant l'ex�cution de la commande principale.
 * La fonction empile doit etre appel�e avant l'ex�cution d'une commande (appel � oper,
 * par exemple) et la fonction depile doit etre appel�e apr�s l'ex�cution de cette
 * commande.
 */
static PyObject * empile(PyObject *c)
{
        _DEBUT(empile) ;
                                                               OBSCRUTE(c) ; /*  impression de la commande courante */
                                                               REFSCRUTE(c) ; /*  impression du compteur de references de la commande courante */
        /* PyList_Append incremente de 1 le compteur de references de c (commande courante) */
        PyList_Append(pile_commandes,c);
        niveau=niveau+1;
                                                               ISCRUTE(niveau);
        if(NIVMAX < niveau){
          printf("Le nombre de niveau max prevus %d est insuffisant pour le nombre demande %d\n",NIVMAX,niveau);
          abort();
        }
                                                               REFSCRUTE(c) ;
        _FIN(empile) ;
        return c;
}

/* ------------------------------------------------------------------ */
static PyObject * depile()
{
        PyObject * com;
        int l=PyList_Size(pile_commandes);
        _DEBUT(depile) ;
        niveau=niveau-1;
                                                               ISCRUTE(niveau);
                                                               ISCRUTE(l) ;
        if(l == 0){
          /* Pile vide */
          Py_INCREF( Py_None ) ;
          _FIN(depile) ;
          return Py_None;
        }
        /* Derniere commande dans la pile */
        com = PyList_GetItem(pile_commandes,l-1);
        /* PyList_GetItem n incremente pas le compteur de ref de com */
                                                               REFSCRUTE(com) ;
        /* On tronque la liste a la dimension l-1 */
        PyList_SetSlice(pile_commandes,l-1,l,NULL);
        /* Le compteur de ref de com est decremente de 1 */
                                                               REFSCRUTE(com) ;
        if(l == 1){
          /* La pile tronquee est vide */
          Py_INCREF( Py_None ) ;
          _FIN(depile) ;
          return Py_None;
        }
        /* On ne passe ici que pour les macros avec sous commandes
         * en mode commande par commande */
        /* On retourne la derniere commande de la pile */
        com = PyList_GetItem(pile_commandes,l-2);
                                                               REFSCRUTE(com) ;
        _FIN(depile) ;
        return com;
}

/* ------------------------------------------------------------------ */
PyObject * get_active_command()
{
        /*
         * Retourne un pointeur sur la commande active
         */
   return commande;
}

/* ------------------------------------------------------------------ */
/* -------------------- appels aux routines JEVEUX ------------------ */
#define CALL_JEMARQ() STDCALL(JEMARQ, jemarq)()
void CALL_JEMARQ();

#define CALL_JEDEMA() STDCALL(JEDEMA, jedema)()
void CALL_JEDEMA();

#define CALL_JEDETR(nom) CALLS(JEDETR, jedetr, nom)
void DEFS(JEDETR, jedetr, char *, int);
/* ------------------------------------------------------------------ */

#define CALL_PRCOCH(nomce,nomcs,nomcmp,ktype,itopo,nval,groups) CALLSSSSPPS(PRCOCH,prcoch,nomce,nomcs,nomcmp,ktype,itopo,nval,groups)
void DEFSSSSPPS(PRCOCH,prcoch,char *,int,char *,int,char *,int,char *,int,INTEGER *,INTEGER *,char *,int);

static PyObject* aster_prepcompcham(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
        char *nomce;
        char *nomcs;
        char *nomcmp;
        char *ktype;
        char *groups;
        PyObject *list;
        INTEGER nval=0;
        int k;
        int long_nomcham=8;
        INTEGER itopo;
        void *malloc(size_t size);
	
        _DEBUT(aster_prepcompcham) ;

        if (!PyArg_ParseTuple(args, "sssslO:prepcompcham",&nomce,&nomcs,&nomcmp,&ktype,&itopo,&list)) return NULL;

        nval=PyList_Size(list);


        if (nval > 0) {
          groups = (char *)malloc(nval*long_nomcham*sizeof(char));
          converltx(nval,list,groups,long_nomcham); /* conversion  */
        }
        /* on ne peut passer a fortran une chaine non allouee
           a cause du strlen() que l'on va faire dessus au moment du passage
           c -> fortran
        */
        else {
          groups = (char *)malloc(long_nomcham*sizeof(char));
          groups = strcpy(groups,"        ");
        }



        try(1){
          CALL_JEMARQ();
                                SSCRUTE(nomce);
                                SSCRUTE(nomcs);
                                SSCRUTE(nomcmp);
                                SSCRUTE(ktype);
                                ISCRUTE(itopo);
                                ISCRUTE(nval);
                                FSSCRUTE(groups,nval*long_nomcham);
          CALL_PRCOCH(nomce,nomcs,nomcmp,ktype,&itopo,&nval,groups);
          Py_INCREF( Py_None ) ;
          CALL_JEDEMA();
          _FIN(aster_prepcompcham) ;
          free(groups);
          return Py_None;
        }
        catch(CodeAbortAster){
          /* une exception a ete levee, elle est destinee a etre traitee dans l'appelant */
          PyErr_SetString(PyExc_KeyError, "Concept inexistant");
          CALL_JEDEMA();
          _FIN(aster_prepcompcham) ;
          return NULL;
        }
}

/* ------------------------------------------------------------------ */
#define CALL_GETCON(nomsd,iob,ishf,ilng,ctype,lcon,iaddr,nomob) CALLSPPPPPPS(GETCON,getcon,nomsd,iob,ishf,ilng,ctype,lcon,iaddr,nomob)
void DEFSPPPPPPS(GETCON,getcon,char *,int,INTEGER *,INTEGER *,INTEGER *,INTEGER *,INTEGER *,char **,char *,int);

static char getvectjev_doc[]=
"getvectjev(nomsd)->valsd      \n\
\n\
Retourne la valeur du concept nomsd \n\
dans un tuple.";

static PyObject* aster_getvectjev(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
        char *nomsd;
        char nomob[8];
        double *f;
        INTEGER *l;
        char *kvar;
        PyObject *tup;
        INTEGER lcon, iob;
        INTEGER ishf=0;
        INTEGER ilng=0;
        INTEGER ctype=0;
        int i;
        char *iaddr;

        _DEBUT(aster_getvectjev) ;

        if (!PyArg_ParseTuple(args, "s|ll:getvectjev",&nomsd,&ishf,&ilng)) return NULL;

        try(1){
          iob=0 ;
          CALL_JEMARQ();
                                   SSCRUTE(nomsd);
                                   ISCRUTE(iob);
                                   ISCRUTE(ishf);
                                   ISCRUTE(ilng);
          CALL_GETCON(nomsd,&iob,&ishf,&ilng,&ctype,&lcon,&iaddr,nomob);
                                   ISCRUTE(lcon);
                                   ISCRUTE(ctype);
                                   ISCRUTE(iaddr);
                                   SSCRUTE(nomob);
          if(ctype < 0){
            /* Erreur */
/*            PyErr_SetString(PyExc_KeyError, "Concept inexistant");
            CALL_JEDEMA();
            _FIN(aster_getvectjev) ;
            return NULL;*/
            /* vecteur jeveux inexistant : retourne None */
            Py_INCREF( Py_None ) ;
            CALL_JEDEMA();
            _FIN(aster_getvectjev) ;
            return Py_None;
          }
          else if(ctype == 0){
            /* Liste vide */
            tup = PyTuple_New( 0 ) ;
          }
          else if(ctype == 1){
            /* REEL */
            f = (double *)iaddr;
            tup = PyTuple_New( lcon ) ;
            for(i=0;i<lcon;i++){
               PyTuple_SetItem( tup, i, PyFloat_FromDouble(f[i]) ) ;
            }
          }
          else if(ctype == 2){
            /* ENTIER */
            l = (INTEGER*)iaddr;
            tup = PyTuple_New( lcon ) ;
            for(i=0;i<lcon;i++){
               PyTuple_SetItem( tup, i, PyInt_FromLong(l[i]) ) ;
            }
          }
          else if(ctype == 3){
            /* COMPLEXE */
            f = (double *)iaddr;
            tup = PyTuple_New( lcon ) ;
            for(i=0;i<lcon;i++){
               PyTuple_SetItem( tup, i, PyComplex_FromDoubles(f[2*i],f[2*i+1]) ) ;
            }
          }
          else if(ctype == 4){
            /* CHAINE K8 */
            tup = PyTuple_New( lcon ) ;
            for(i=0;i<lcon;i++){
                                        OBSCRUTE(tup);
               kvar = iaddr + i*8;
               PyTuple_SetItem( tup, i, PyString_FromStringAndSize(kvar,8) ) ;
            }
          }
          else if(ctype == 5){
            /* CHAINE K16 */
            tup = PyTuple_New( lcon ) ;
            for(i=0;i<lcon;i++){
                                        OBSCRUTE(tup);
               kvar = iaddr + i*16;
               PyTuple_SetItem( tup, i, PyString_FromStringAndSize(kvar,16) ) ;
            }
          }
          else if(ctype == 6){
            /* CHAINE K24 */
            tup = PyTuple_New( lcon ) ;
            for(i=0;i<lcon;i++){
                                        OBSCRUTE(tup);
               kvar = iaddr + i*24;
               PyTuple_SetItem( tup, i, PyString_FromStringAndSize(kvar,24) ) ;
            }
          }
          else if(ctype == 7){
            /* CHAINE K32 */
            tup = PyTuple_New( lcon ) ;
            for(i=0;i<lcon;i++){
                                        OBSCRUTE(tup);
               kvar = iaddr + i*32;
               PyTuple_SetItem( tup, i, PyString_FromStringAndSize(kvar,32) ) ;
            }
          }
          else if(ctype == 8){
            /* CHAINE K80 */
            tup = PyTuple_New( lcon ) ;
            for(i=0;i<lcon;i++){
                                        OBSCRUTE(tup);
               kvar = iaddr + i*80;
               PyTuple_SetItem( tup, i, PyString_FromStringAndSize(kvar,80) ) ;
            }
          }
                                   SSCRUTE(nomsd);
          CALL_JEDETR("&&GETCON.PTEUR_NOM");
          CALL_JEDEMA();
          _FIN(aster_getvectjev) ;
          return tup;
        }
        catch(CodeAbortAster){
          /* une exception a ete levee, elle est destinee a etre traitee dans l'appelant */
          PyErr_SetString(PyExc_KeyError, "Concept inexistant");
          CALL_JEDEMA();
          _FIN(aster_getvectjev) ;
          return NULL;
        }
}

#define CALL_TAILSD(nom, nomsd, val, nbval) CALLSSPP(TAILSD,tailsd,nom, nomsd, val, nbval)
void DEFSSPP(TAILSD,tailsd,char *,int,char *,int,INTEGER *, INTEGER *);

static char getcolljev_doc[]=
"getcolljev(nomsd)->valsd      \n\
\n\
Retourne la valeur du concept nomsd \n\
dans un tuple.";

/* ------------------------------------------------------------------ */
static PyObject* aster_getcolljev(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
        char *nomsd, *nom;
        char nomob[8];
        double *f;
        INTEGER *l;
        char *kvar;
        PyObject *tup, *dico, *key;
        INTEGER iob,j,ishf,ilng;
        INTEGER lcon;
        INTEGER ctype=0;
        INTEGER *val, nbval;
        int i;
        char *iaddr;
        void *malloc(size_t size);
	
        _DEBUT(aster_getcolljev) ;

        if (!PyArg_ParseTuple(args, "s:getcolljev",&nomsd)) return NULL;

/* Taille de la collection */
        nbval = 1;
        val = (INTEGER *)malloc((nbval)*sizeof(INTEGER));
        nom = (char *)malloc(24*sizeof(char));
        strcpy(nom, "LIST_COLLECTION");
        CALL_JEMARQ();
        CALL_TAILSD(nom, nomsd, val, &nbval);
        iob=val[0];

        dico = PyDict_New();
        try(1){
          for(j=1;j<iob+1;j++){
          ishf=0 ;
          ilng=0 ;
                                   SSCRUTE(nomsd);
                                   ISCRUTE(j);
                                   ISCRUTE(ishf);
                                   ISCRUTE(ilng);
          CALL_GETCON(nomsd,&j,&ishf,&ilng,&ctype,&lcon,&iaddr,nomob);
                                   ISCRUTE(lcon);
                                   ISCRUTE(ctype);
                                   ISCRUTE(iaddr);
                                   SSCRUTE(nomob);
          if(nomob[0] == ' '){
             key=PyInt_FromLong(j);
          }
          else {
             key=PyString_FromStringAndSize(nomob,8);
          }
          if(ctype < 0){
            /* Erreur */
            PyErr_SetString(PyExc_KeyError, "Concept inexistant");
            _FIN(aster_getcolljev) ;
            return NULL;
          }
          else if(ctype == 0){
            Py_INCREF( Py_None );
            PyDict_SetItem(dico,key,Py_None);
          }
          else if(ctype == 1){
            /* REEL */
            f = (double *)iaddr;
            tup = PyTuple_New( lcon ) ;
            for(i=0;i<lcon;i++){
               PyTuple_SetItem( tup, i, PyFloat_FromDouble(f[i]) ) ;
            }
            PyDict_SetItem(dico,key,tup);
          }
          else if(ctype == 2){
            /* ENTIER */
            l = (INTEGER*)iaddr;
            tup = PyTuple_New( lcon ) ;
            for(i=0;i<lcon;i++){
               PyTuple_SetItem( tup, i, PyInt_FromLong(l[i]) ) ;
            }
            PyDict_SetItem(dico,key,tup);
          }
          else if(ctype == 3){
            /* COMPLEXE */
            f = (double *)iaddr;
            tup = PyTuple_New( lcon ) ;
            for(i=0;i<lcon;i++){
               PyTuple_SetItem( tup, i, PyComplex_FromDoubles(f[2*i],f[2*i+1]) ) ;
            }
            PyDict_SetItem(dico,key,tup);
          }
          else if(ctype == 4){
            /* CHAINE K8 */
            tup = PyTuple_New( lcon ) ;
            for(i=0;i<lcon;i++){
                                        OBSCRUTE(tup);
               kvar = iaddr + i*8;
               PyTuple_SetItem( tup, i, PyString_FromStringAndSize(kvar,8) ) ;
            }
            PyDict_SetItem(dico,key,tup);
          }
          else if(ctype == 5){
            /* CHAINE K16 */
            tup = PyTuple_New( lcon ) ;
            for(i=0;i<lcon;i++){
                                        OBSCRUTE(tup);
               kvar = iaddr + i*16;
               PyTuple_SetItem( tup, i, PyString_FromStringAndSize(kvar,16) ) ;
            }
            PyDict_SetItem(dico,key,tup);
          }
          else if(ctype == 6){
            /* CHAINE K24 */
            tup = PyTuple_New( lcon ) ;
            for(i=0;i<lcon;i++){
                                        OBSCRUTE(tup);
               kvar = iaddr + i*24;
               PyTuple_SetItem( tup, i, PyString_FromStringAndSize(kvar,24) ) ;
            }
            PyDict_SetItem(dico,key,tup);
          }
          else if(ctype == 7){
            /* CHAINE K32 */
            tup = PyTuple_New( lcon ) ;
            for(i=0;i<lcon;i++){
                                        OBSCRUTE(tup);
               kvar = iaddr + i*32;
               PyTuple_SetItem( tup, i, PyString_FromStringAndSize(kvar,32) ) ;
            }
            PyDict_SetItem(dico,key,tup);
          }
          else if(ctype == 8){
            /* CHAINE K80 */
            tup = PyTuple_New( lcon ) ;
            for(i=0;i<lcon;i++){
                                        OBSCRUTE(tup);
               kvar = iaddr + i*80;
               PyTuple_SetItem( tup, i, PyString_FromStringAndSize(kvar,80) ) ;
            }
            PyDict_SetItem(dico,key,tup);
          }
         }
         CALL_JEDETR("&&GETCON.PTEUR_NOM");
         CALL_JEDEMA();
         _FIN(aster_getcolljev) ;
         return dico;
       }
        catch(CodeAbortAster){
          /* une exception a ete levee, elle est destinee a etre traitee dans l'appelant */
          PyErr_SetString(PyExc_KeyError, "Concept inexistant");
          CALL_JEDEMA();
          _FIN(aster_getcolljev) ;
          return NULL;
        }
}



#define CALL_PUTCON(nomsd,nbind,ind,valr,valc,num,iret) CALLSPPPPPP(PUTCON,putcon,nomsd,nbind,ind,valr,valc,num,iret)
void DEFSPPPPPP(PUTCON,putcon,char *,int,INTEGER *,INTEGER *,double *,double *,INTEGER *,INTEGER *);

static char putvectjev_doc[]=
"putvectjev(nomsd)->valsd      \n\
\n\
Renvoie le contenu d'un objet python dans  \n\
un vecteur jeveux.";

/* ------------------------------------------------------------------ */
static PyObject* aster_putvectjev(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
        PyObject *tupi  = (PyObject*)0 ;
        PyObject *tupr  = (PyObject*)0 ;
        PyObject *tupc  = (PyObject*)0 ;
        char *nomsd;
        double *valr;
        double *valc;
        INTEGER *ind;
        INTEGER num;
        INTEGER nbind;
        unsigned int nind  = 0 ;
        int ok        = 0 ;
        INTEGER iret=0;
        INTEGER lnom=0;
        void *malloc(size_t size);
	
        _DEBUT(aster_putvectjev) ;

        ok = PyArg_ParseTuple(args, "slOOOl",&nomsd,&nbind,&tupi,&tupr,&tupc,&num);
        if (!ok)MYABORT("erreur dans la partie Python");
/*        PyObject_Print(args, stdout, 0);*/

        nind = (unsigned int)(nbind);

        ind = (INTEGER *)malloc((nind)*sizeof(INTEGER));
        valr = (double *)malloc((nind)*sizeof(double));
        valc = (double *)malloc((nind)*sizeof(double));

        if ( nind>0 ){
                 convert(nind,tupi,ind);
                 convr8(nind,tupr,valr);
                 convr8(nind,tupc,valc);
        }
        try(1){
          CALL_JEMARQ();
                                   SSCRUTE(nomsd);
                                   ISCRUTE(*nbind);
                                   TISCRUTE(nind,ind);
                                   TDSCRUTE(nind,valr);
                                   TDSCRUTE(nind,valc);
                                   ISCRUTE(*num);
          CALL_PUTCON(nomsd,&nbind,ind,valr,valc,&num,&iret);
                                   ISCRUTE(iret);
          CALL_JEDEMA();

          if(iret == 0){
            /* Erreur */
            PyErr_SetString(PyExc_KeyError, "Concept inexistant");
            _FIN(aster_putvectjev) ;
            return NULL;
          }

          free((char *)valc);
          free((char *)valr);
          free((char *)ind);
        }
        catch(CodeAbortAster){
          /* une exception a ete levee, elle est destinee a etre traitee dans l'appelant */
          PyErr_SetString(PyExc_KeyError, "Concept inexistant");
          _FIN(aster_putvectjev) ;
          return NULL;
        }
        Py_INCREF( Py_None ) ;
        _FIN(aster_putvectjev) ;
        return Py_None;
}


static char putcolljev_doc[]=
"putcolljev(nomsd)->valsd      \n\
\n\
Renvoie le contenu d'un objet python dans  \n\
un vecteur jeveux.";

/* ------------------------------------------------------------------ */
static PyObject* aster_putcolljev(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
        PyObject *tupi  = (PyObject*)0 ;
        PyObject *tupr  = (PyObject*)0 ;
        PyObject *tupc  = (PyObject*)0 ;
        char *nomsd;
        double *valr;
        double *valc;
        INTEGER *ind;
        INTEGER num;
        INTEGER nbind;
        unsigned int nind  = 0 ;
        int ok        = 0 ;
        INTEGER iret=0;
        INTEGER lnom=0;
        void *malloc(size_t size);
	
        _DEBUT(aster_putcolljev) ;


        ok = PyArg_ParseTuple(args, "slOOOl",&nomsd,&nbind,&tupi,&tupr,&tupc,&num);
        if (!ok)MYABORT("erreur dans la partie Python");
/*        PyObject_Print(args, stdout, 0);*/

        nind = (unsigned int)(nbind);

        ind = (INTEGER *)malloc((nind)*sizeof(INTEGER));
        valr = (double *)malloc((nind)*sizeof(double));
        valc = (double *)malloc((nind)*sizeof(double));

        if ( nind>0 ){
                 convert(nind,tupi,ind);
                 convr8(nind,tupr,valr);
                 convr8(nind,tupc,valc);
        }

        CALL_JEMARQ();
                                   SSCRUTE(nomsd);
                                   ISCRUTE(*nbind);
                                   TISCRUTE(nind,ind);
                                   TDSCRUTE(nind,valr);
                                   TDSCRUTE(nind,valc);
                                   ISCRUTE(*num);
        CALL_PUTCON(nomsd,&nbind,ind,valr,valc,&num,&iret);
                                   ISCRUTE(iret);
        CALL_JEDEMA();

        if(iret == 0){
          /* Erreur */
          PyErr_SetString(PyExc_KeyError, "Concept inexistant");
          _FIN(aster_putcolljev) ;
          return NULL;
          }

        free((char *)valc);
        free((char *)valr);
        free((char *)ind);

        Py_INCREF( Py_None ) ;
        _FIN(aster_putcolljev) ;
        return Py_None;
}


/* ------------------------------------------------------------------ */
void DEFSPSPPPS(RSACCH,rsacch,char *, int, INTEGER *, char *,int,INTEGER *, INTEGER *, INTEGER *, char *,int);
void DEFSPSSPPP(RSACVA,rsacva,char *, int,INTEGER *, char *,int,char *,int,INTEGER *, double *,INTEGER *);
void DEFSPSSPPP(RSACPA,rsacpa,char *, int,INTEGER *, char *,int,char *,int,INTEGER *, double *,INTEGER *);

#define CALL_RSACCH(nomsd, numch, nomch, nbord, liord, nbcmp, liscmp) \
                  FCALLSPSPPPS(RSACCH,rsacch,nomsd,strlen(nomsd),numch, nomch,16,nbord, liord, nbcmp, liscmp,8)
#define CALL_RSACVA(nomsd, numva, nomva, ctype, ival, rval, ier) \
                  CALLSPSSPPP(RSACVA,rsacva,nomsd, numva, nomva, ctype, ival, rval, ier)
#define CALL_RSACPA(nomsd, numva, nomva, ctype, ival, rval, ier) \
                  CALLSPSSPPP(RSACPA,rsacpa,nomsd, numva, nomva, ctype, ival, rval, ier)



/* ------------------------------------------------------------------ */
static PyObject* aster_GetResu(self, args)
PyObject *self; /* Not used */
PyObject *args;

/* Construit sous forme d'un dictionnaire Python l'architecture d'une SD resultat

   Arguments :
     IN Nom de la SD resultat
     IN Nature des informations recherchees
          CHAMPS      -> Champs de resultats
          COMPOSANTES -> Liste des composantes des champs
          VARI_ACCES  -> Variables d'acces
          PARAMETRES  -> Parametres


     OUT dico
       Si 'CHAMPS'
       dico['NOM_CHAM'] -> [] si le champ n'est pas calcule
                        -> Liste des numeros d'ordre ou le champ est calcule

       Si 'COMPOSANTES'
       dico['NOM_CHAM'] -> [] si le champ n'est pas calcule
                        -> Liste des composantes du champ (enveloppe sur tous les instants)

       Si 'VARI_ACCES'
       dico['NOM_VA']   -> Liste des valeurs de la variable d'acces

       Si 'PARAMETRES'
       dico['NOM_VA']   -> Liste des valeurs du parametre

*/

{
   INTEGER nbchmx, nbpamx, nbord, numch, numva, ier, nbcmp ;
   INTEGER *liord, *ival;
   INTEGER *val, nbval ;
   double *rval;
   char *nomsd, *mode, *liscmp, *nom ;
   char nomch[16], ctype, nomva[16];
   int i, lo, nb;
   PyObject *dico, *liste, *key;
   void *malloc(size_t size);

   if (!PyArg_ParseTuple(args, "ss",&nomsd, &mode)) return NULL;

/* Identifiant de la SD resultat */
   nbval = 1;
   val = (INTEGER *)malloc((nbval)*sizeof(INTEGER));
   nom = (char *)malloc(24*sizeof(char));
   strcpy(nom, "LIST_RESULTAT");

/* Taille de la SD resultat : nbr champs, nbr paras, nbr numeros d'ordre */
   CALL_JEMARQ();
   CALL_TAILSD(nom, nomsd, val, &nbval);
   nbchmx = val[0];
   nbpamx = val[1];
   nbord  = val[2];

   if (strcmp(mode,"CHAMPS") == 0 || strcmp(mode,"COMPOSANTES") == 0)

/* Construction du dictionnaire : cle d'acces = nom du champ */

          {
     liord  = (INTEGER *)malloc(nbord*sizeof(INTEGER));
     liscmp = (char *)malloc(500*8*sizeof(char));
     dico = PyDict_New();
     for (numch=1; numch<=nbchmx; numch++)
            {
       CALL_RSACCH(nomsd, &numch, nomch, &nbord, liord, &nbcmp, liscmp);

       lo = 16;
       while (nomch[lo-1] == ' ')  lo--;
       key = PyString_FromStringAndSize(nomch,lo);

       liste = PyList_New(0);

       if (strcmp(mode,"CHAMPS") == 0)
              {
              for (i=0; i<nbord; i++)
              PyList_Append(liste,PyInt_FromLong(liord[i]));
              }

            if (strcmp(mode,"COMPOSANTES") == 0)
              {
              for (i=0; i<nbcmp; i++)
                {
                nom = &(liscmp[i*8]);
                lo = 8; while (nom[lo-1] == ' ')  lo--;
                PyList_Append(liste,PyString_FromStringAndSize(nom,lo));
                }
              }

            PyDict_SetItem(dico,key,liste);
            };

          free(liord);
          }


        else if (strcmp(mode,"VARI_ACCES") == 0 )

/* Extraction des variables d'acces */

          {
          ival  = (INTEGER *)malloc(nbord*sizeof(INTEGER));
          rval  = (double * )malloc(nbord*sizeof(double) );

          dico = PyDict_New();
          for (numva=0; numva<=nbpamx; numva++)
            {
            CALL_RSACVA(nomsd, &numva, nomva, &ctype, ival, rval, &ier);
            if (ier != 0) continue;

            lo = 16;
            while (nomva[lo-1] == ' ') lo--;
            key = PyString_FromStringAndSize(nomva,lo);

            liste = PyList_New(0);
            if (ctype == 'I')
              for (i=0; i<nbord; i++)
                PyList_Append(liste,PyInt_FromLong(ival[i]));
            else
              for (i=0; i<nbord; i++)
                PyList_Append(liste,PyFloat_FromDouble(rval[i]));

            PyDict_SetItem(dico,key,liste);
            };

          free(ival);
          free(rval);
          }
        else if (strcmp(mode,"PARAMETRES") == 0 )

/* Extraction des parametres */

          {
          ival  = (INTEGER *)malloc(nbord*sizeof(INTEGER));
          rval  = (double * )malloc(nbord*sizeof(double) );

          dico = PyDict_New();
          for (numva=0; numva<=nbpamx; numva++)
            {
            CALL_RSACPA(nomsd, &numva, nomva, &ctype, ival, rval, &ier);
            if (ier != 0) continue;

            lo = 16;
            while (nomva[lo-1] == ' ') lo--;
            key = PyString_FromStringAndSize(nomva,lo);

            liste = PyList_New(0);
            if (ctype == 'I')
              for (i=0; i<nbord; i++)
                PyList_Append(liste,PyInt_FromLong(ival[i]));
            else
              for (i=0; i<nbord; i++)
                PyList_Append(liste,PyFloat_FromDouble(rval[i]));

            PyDict_SetItem(dico,key,liste);
            };

          free(ival);
          free(rval);
          };

   CALL_JEDEMA();
   return dico;

}


/* ------------------------------------------------------------------ */
#define CALL_EXPASS(a,b,c,d)  F_FUNC(EXPASS,expass)(a,b,c,d)
extern void STDCALL(EXPASS,expass)(INTEGER* , INTEGER* , INTEGER* , INTEGER*);

static PyObject* aster_oper(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
        PyObject *temp;
        INTEGER jxvrf=1 ; /* FORTRAN_TRUE */
        INTEGER iertot=0 ;
        INTEGER icmd=0 ;
        INTEGER ipass=0 ;

        _DEBUT(aster_oper) ;

        if (!PyArg_ParseTuple(args, "Olll",&temp,&jxvrf,&ipass,&icmd)) return NULL;

        /* On empile le nouvel appel */
        commande=empile(temp);

        if(PyErr_Occurred()){
            fprintf(stderr,"Warning: une exception n'a pas ete trait�e\n");
            PyErr_Print();
            fprintf(stderr,"Warning: on l'annule pour continuer mais elle aurait\n\
                            etre trait�e avant\n");
            PyErr_Clear();
        }

        fflush(stderr) ;
        fflush(stdout) ;

        try(1){

                /*  appel du sous programme expass pour verif ou exec */
                CALL_EXPASS (&jxvrf,&ipass,&icmd,&iertot);

                /* On depile l appel */
                commande = depile();

                                                                                 ISCRUTE(iertot) ;
                _FIN(aster_oper) ;
                return PyInt_FromLong(iertot); /*  retour de la fonction oper sous la forme d un entier */
        }
        finally{
                /* On depile l appel */
                commande = depile();

                /* une exception a ete levee, elle est destinee a etre traitee dans JDC.py */
                TraitementFinAster( exception_status ) ;

                _FIN(aster_oper) ;
                return NULL;
        }
}

/* ------------------------------------------------------------------ */
#define CALL_OPSEXE(a,b,c,d,e)  CALLPPPSP(OPSEXE,opsexe,a,b,c,d,e)
extern void DEFPPPSP(OPSEXE,opsexe,INTEGER* , INTEGER* , INTEGER* , char *,int ,INTEGER* ) ;

static PyObject* aster_opsexe(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
        PyObject *temp;
        INTEGER ier=0 ;
        INTEGER icmd=0 ;
        INTEGER oper=0 ;
        INTEGER ipass=0 ;
        char *cmdusr="                                                                          ";

        _DEBUT(aster_opsexe) ;

        if (!PyArg_ParseTuple(args, "Olll",&temp,&icmd,&ipass,&oper)) return NULL;

        /* On empile le nouvel appel */
        commande=empile(temp);

        if(PyErr_Occurred()){
            fprintf(stderr,"Warning: une exception n'a pas ete trait�e\n");
            PyErr_Print();
            fprintf(stderr,"Warning: on l'annule pour continuer mais elle aurait\n\
                            etre trait�e avant\n");
            PyErr_Clear();
        }

        fflush(stderr) ;
        fflush(stdout) ;

        try(1){
                /*  appel du sous programme opsexe */
                CALL_OPSEXE (&icmd,&ipass,&oper,cmdusr,&ier);

                /* On depile l appel */
                commande = depile();
                                                                                 ISCRUTE(ier) ;
                                                                                 PRINTERR ;
                _FIN(aster_opsexe) ;
                return PyInt_FromLong(ier); /*  retour de la fonction oper sous la forme d un entier */
        }
        finally{
                /* On depile l appel */
                commande = depile();

                /* une exception a ete levee, elle est destinee a etre traitee dans JDC.py */
                TraitementFinAster( exception_status ) ;

                _FIN(aster_opsexe) ;
                return NULL;
        }
}


/* ------------------------------------------------------------------ */
extern void STDCALL(IMPERS,impers)();
#define CALL_IMPERS() F_FUNC(IMPERS,impers)()

static PyObject * aster_impers(self,args)
PyObject *self; /* Not used */
{
        _DEBUT(aster_impers) ;
        CALL_IMPERS ();
      /*   impers_() ;*/
        Py_INCREF( Py_None ) ;
        _FIN(aster_impers)
        return Py_None;
}

/* ------------------------------------------------------------------ */
void DEFSS(AFFICH,affich,char *,int,char *,int);
#define CALL_AFFICH(a,b) CALLSS(AFFICH,affich,a,b)

static PyObject * aster_affich(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
        char *texte;
        char *nomfic;

        _DEBUT(aster_affich) ;
        if (!PyArg_ParseTuple(args, "ss:affiche",&nomfic,&texte)) return NULL;
                                                       SSCRUTE(nomfic);
                                                       SSCRUTE(texte);
/*jpl        fprintf( stderr , "%s" , texte ) ; */
        CALL_AFFICH (nomfic,texte);

        Py_INCREF( Py_None ) ;
        _FIN(aster_affich) ;
        return Py_None;
}

/* ------------------------------------------------------------------ */
void DEFSSP(ONERRF,onerrf,char *,int, _OUT char *,int, _OUT INTEGER *);
#define CALL_ONERRF(a,b,c) CALLSSP(ONERRF,onerrf,a,b,c)


static PyObject * aster_onFatalError(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
/*
   Cette m�thode d�finie le comportement lors des erreurs Fatales :

   aster.onFatalError('ABORT')
         => on s'arr�te avec un JEFINI('ERREUR') dans UTFINM

   aster.onFatalError('EXCEPTION()
         => on l�ve l'exception FatalError

   aster.onFatalError()
         => retourne la valeur actuelle : 'ABORT' ou 'EXCEPTION'.
*/
      int len=-1;
      int lng;
      char tmp[16+1];
      char *comport, *res;

      _DEBUT(aster_onFatalError) ;
      if (!PyArg_ParseTuple(args, "|s#:onFatalError",&comport ,&len)) return NULL;
                                                     SSCRUTE(comport);
      if (len == -1) {
            CALL_ONERRF(" ", &tmp, &lng);
            res = PyString_FromStringAndSize(tmp, lng);
            _FIN(aster_onFatalError) ;
            return res;

      } else if (strcmp(comport,"ABORT")==0 || strcmp(comport, "EXCEPTION")==0) {
            CALL_ONERRF(comport, &tmp, &lng);
            Py_INCREF( Py_None ) ;
            _FIN(aster_onFatalError) ;
            return Py_None;

      } else {
            MYABORT("Seules ABORT et EXCEPTION sont des valeurs valides.");
      }
}

/* ------------------------------------------------------------------ */
void DEFSSSSP(ULOPEN,ulopen,char *,int,char *,int,char *,int,char *,int,INTEGER *);
#define CALL_ULOPEN(a,b,c,d,e) CALLSSSSP(ULOPEN,ulopen,a,b,c,d,e)

static PyObject * aster_ulopen(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
        char *fichie;
        char *name;
        char *acces;
        char *autor;
        INTEGER unit=0 ;

        _DEBUT(aster_affich) ;
        if (!PyArg_ParseTuple(args, "ssssl:ulopen",&fichie,&name,&acces,&autor,&unit)) return NULL;
                                                       SSCRUTE(fichie);
                                                       SSCRUTE(name);
                                                       SSCRUTE(acces);
                                                       SSCRUTE(autor);
                                                       ISCRUTE(unit);
        CALL_ULOPEN (&unit,fichie,name,acces,autor);

        Py_INCREF( Py_None ) ;
        _FIN(aster_ulopen) ;
        return Py_None;
}


/* ------------------------------------------------------------------ */
void DEFP(FCLOSE,fclose,INTEGER *);
#define CALL_FCLOSE(a) CALLP(FCLOSE,fclose,a)

static PyObject * aster_fclose(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
        INTEGER unit=0 ;

        _DEBUT(aster_affich) ;
        if (!PyArg_ParseTuple(args, "l:fclose",&unit)) return NULL;
                                                       ISCRUTE(unit);
        CALL_FCLOSE (&unit);

        Py_INCREF( Py_None ) ;
        _FIN(aster_fclose) ;
        return Py_None;
}


/* ------------------------------------------------------------------ */
void DEFPPS(REPOUT,repout,INTEGER *,INTEGER *,char *,int);
#define CALL_REPOUT(a,b,c) CALLPPS(REPOUT,repout,a,b,c)


static PyObject * aster_repout(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
        PyObject *temp = (PyObject*)0 ;
        INTEGER maj=1 ;
        INTEGER lnom=0;
        char nom[129];

        _DEBUT(aster_repout) ;
        if (!PyArg_ParseTuple(args, "")) return NULL;
                                                       ISCRUTE(maj);
        BLANK(nom,128);
        nom[128]='\0';
                                                       SSCRUTE(nom);
        CALL_REPOUT (&maj,&lnom,nom);
                                                       ISCRUTE(lnom);
                                                       FSSCRUTE(nom,128);
        temp= PyString_FromStringAndSize(nom,FindLength(nom,lnom));
                                                       OBSCRUTE(temp);
        _FIN(aster_repout)
        return temp;
}

/* ------------------------------------------------------------------ */
void DEFPPS(REPDEX,repdex,INTEGER *,INTEGER *,char *,int);
#define CALL_REPDEX(a,b,c) CALLPPS(REPDEX,repdex,a,b,c)


static PyObject * aster_repdex(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
        PyObject *temp = (PyObject*)0 ;
        INTEGER maj=1 ;
        INTEGER lnom=0;
        char nom[129];

        _DEBUT(aster_repdex) ;
        if (!PyArg_ParseTuple(args, "")) return NULL;
                                                       ISCRUTE(maj);
        BLANK(nom,128);
        nom[128]='\0';
                                                       SSCRUTE(nom);
        CALL_REPDEX (&maj,&lnom,nom);
                                                       ISCRUTE(lnom);
                                                       FSSCRUTE(nom,128);
        temp= PyString_FromStringAndSize(nom,FindLength(nom,lnom));
                                                       OBSCRUTE(temp);
        _FIN(aster_repdex)
        return temp;
}

/* ---------------------------------------------------------------------- */
void DEFSSPSPPSPSS(RCVALE, rcvale, char *,int, char *,int, INTEGER *, char *,int, double *, INTEGER *, char *,int, double *, char *, int, char *, int);
#define CALL_RCVALE(a,b,c,d,e,f,g,h,i,j) CALLSSPSPPSPSS(RCVALE,rcvale,a,b,c,d,e,f,g,h,i,j)

static char rcvale_doc[] =
"Interface d'appel � la routine fortran RCVALE.\n"
"   Arguments : nommat, phenomene, nompar, valpar, nomres, stop\n"
"   Retourne  : valres, codret (tuples)\n"
" Aucune v�rification n'est faite sur les arguments d'entr�e (c'est l'appelant,\n"
" a priori mater_sdaster.rcvale, qui le fait)";

static PyObject * aster_rcvale(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
   char *nommat, *phenom;
   char *stop;
   PyObject *t_nompar, *t_valpar, *t_nomres;
   PyObject *t_valres, *t_codret;
   PyObject *t_res;
   int i;
   INTEGER nbpar, nbres;
   char *nompar, *nomres, *codret;
   double *valpar, *valres;
   int long_nompar = 8;       /* doivent imp�rativement correspondre aux  */
   int long_nomres = 8;       /* longueurs des chaines de caract�res      */
   int long_codret = 2;       /* d�clar�es dans la routine fortran RCVALE */
   void *malloc(size_t size);

   _DEBUT(aster_rcvale)

   if (!PyArg_ParseTuple(args, "ssOOOs", &nommat, &phenom, \
                  &t_nompar, &t_valpar, &t_nomres, &stop)) return NULL;

   /* Conversion en tableaux de chaines et r�els */
   nbpar = PyTuple_Size(t_nompar);
   nompar = (char *)malloc(long_nompar*nbpar*sizeof(char));
   convertxt(nbpar, t_nompar, nompar, long_nompar);

   valpar = (double *)malloc(nbpar*sizeof(double));
   convr8(nbpar, t_valpar, valpar);

   nbres = PyTuple_Size(t_nomres);
   nomres = (char *)malloc(long_nomres*nbres*sizeof(char));
   convertxt(nbres, t_nomres, nomres, long_nomres);

   /* allocation des variables de sortie */
   valres = (double *)malloc(nbres*sizeof(double));
   codret = (char *)malloc(long_codret*nbres*sizeof(char));

   CALL_RCVALE(nommat, phenom, &nbpar, nompar, valpar, &nbres, nomres, valres, codret, stop);

   /* cr�ation des tuples de sortie */
   t_valres = MakeTupleFloat(nbres, valres);
   t_codret = MakeTupleString(nbres, codret, long_codret, NULL);

   /* retour de la fonction */
   t_res = PyTuple_New(2);
   PyTuple_SetItem(t_res, 0, t_valres);
   PyTuple_SetItem(t_res, 1, t_codret);

   _FIN(aster_rcvale)
   free(nompar);
   free(valpar);
   free(valres);
   free(codret);

   return t_res;
}


/* ---------------------------------------------------------------------- */
void DEFSPSP(MDNOMA,mdnoma,char *,int,INTEGER *,char *,int,INTEGER *);
#define CALL_MDNOMA(a,b,c,d) CALLSPSP(MDNOMA,mdnoma,a,b,c,d)


static PyObject * aster_mdnoma(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
        PyObject *temp = (PyObject*)0 ;
        INTEGER lnomam=0;
        INTEGER codret=0;
	int lon1;
        char *nomast;
        char nomamd[33],n1[9];

        _DEBUT(aster_mdnoma) ;
        if (!PyArg_ParseTuple(args, "s#",&nomast,&lon1)) return NULL;
                                                       SSCRUTE(nomast);
        BLANK(nomamd,32);
        nomamd[32]='\0';
	BLANK(n1,8);strncpy(n1,nomast,lon1);
                                                       SSCRUTE(nomamd);
        CALL_MDNOMA (nomamd,&lnomam,n1,&codret);
                                                       ISCRUTE(lnomam);
                                                       FSSCRUTE(nomamd,32);

        temp= PyString_FromStringAndSize(nomamd,FindLength(nomamd,lnomam));
                                                       OBSCRUTE(temp);
        _FIN(aster_mdnoma)
        return temp;
}

/* ------------------------------------------------------------------ */
void DEFSPPSSSP(MDNOCH,mdnoch,char *,int,INTEGER *,INTEGER *,char *,int,char *,int,char *,int,INTEGER *);
#define CALL_MDNOCH(a,b,c,d,e,f,g) CALLSPPSSSP(MDNOCH,mdnoch,a,b,c,d,e,f,g)

static PyObject * aster_mdnoch(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
        PyObject *temp = (PyObject*)0 ;
        INTEGER lnochm=0;
        INTEGER lresu ;
        char *noresu;
        char *nomsym;
        char *nopase;
        INTEGER codret=0;
	int lon1,lon2,lon3;
        char nochmd[33],n1[33],n2[17],n3[9];

        _DEBUT(aster_mdnoch) ;
        if (!PyArg_ParseTuple(args, "ls#s#s#",&lresu,&noresu,&lon1,&nomsym,&lon2,&nopase,&lon3)) return NULL;
                                                       ISCRUTE(lresu);
                                                       SSCRUTE(noresu);
                                                       SSCRUTE(nomsym);
                                                       SSCRUTE(nopase);
        BLANK(nochmd,32);
        nochmd[32]='\0';
	BLANK(n1,32);strncpy(n1,noresu,lon1);
	BLANK(n2,16);strncpy(n2,nomsym,lon2);
	BLANK(n3,8); strncpy(n3,nopase,lon3);
                                                       SSCRUTE(nochmd);
        CALL_MDNOCH (nochmd,&lnochm,&lresu,n1,n2,n3,&codret);
                                                       ISCRUTE(lnochm);
                                                       FSSCRUTE(nochmd,32);
        temp= PyString_FromStringAndSize(nochmd,FindLength(nochmd,lnochm));
                                                       OBSCRUTE(temp);
        _FIN(aster_mdnoch)
        return temp;
}


/* ------------------------------------------------------------------ */
void TraitementFinAster( _IN int val )
{
        _DEBUT("TraitementFinAster") ;
                             ISCRUTE(val) ;
        switch( val ){
        case CodeFinAster :
                PyErr_SetString(PyExc_EOFError, "exit ASTER");
                break ;
        case CodeAbortAster :
                PyErr_SetString(FatalError, exception_reason);
                break ;
        case CodeErrorAster :
                PyErr_SetString(AsterError, exception_reason);
                break ;

        /* exceptions particularis�es */
        case CodeNonConvergenceAster :
                PyErr_SetString(NonConvergenceError, exception_reason);
                break ;
        case CodeEchecComportementAster :
                PyErr_SetString(EchecComportementError, exception_reason);
                break ;
        case CodeBandeFrequenceVideAster :
                PyErr_SetString(BandeFrequenceVideError, exception_reason);
                break ;
        case CodeMatriceSinguliereAster :
                PyErr_SetString(MatriceSinguliereError, exception_reason);
                break ;
        case CodeTraitementContactAster :
                PyErr_SetString(TraitementContactError, exception_reason);
                break ;
        case CodeMatriceContactSinguliereAster :
                PyErr_SetString(MatriceContactSinguliereError, exception_reason);
                break ;
        case CodeArretCPUAster :
                PyErr_SetString(ArretCPUError, exception_reason);
                break ;

        default :
                MESSAGE("code erreur INCONNU !!!!") ;
                ISCRUTE(val) ;
                INTERRUPTION(1) ;
                break ;
        }
        _FIN("TraitementFinAster") ;
        return ;
}

/* ------------------------------------------------------------------ */
#define CALL_GETLTX(a,b,c,d,e,f,g) CALLSSPPPPP(GETLTX,getltx,a,b,c,d,e,f,g)
#define CALL_GETVTX(a,b,c,d,e,f,g) CALLSSPPPSP(GETVTX,getvtx,a,b,c,d,e,f,g)

int RecupNomCas(void)
{
        /* recuperation du nom du cas */

                INTEGER un          = 1 ;
                INTEGER *iocc       = (INTEGER*)&un ;
                INTEGER *iarg       = (INTEGER*)&un ;
                INTEGER *mxval      = (INTEGER*)&un ;
                INTEGER nbval       = 1 ;
                int ltx       = 8 ;
                INTEGER longueur[1] ;
                void *malloc(size_t size);
                                                                ASSERT(commande!=(PyObject*)0);
                CALL_GETLTX ( "CODE","NOM",iocc,iarg,mxval, longueur ,&nbval) ;
                if(nbval == 0){
                  /* Le mot cle NOM n'a pas ete fourni on donne un nom
                   * par defaut au nom du cas */
                  NomCas = strdup("??????");
                }
                else if(nbval > 0){
                                                                ISCRUTE(longueur[0]) ;
                                                                ASSERT(longueur[0]>0);
                  NomCas = (char*)(malloc((longueur[0]+1)*sizeof(char))) ;
                  BLANK(NomCas,longueur[0]); /* initialisation a blanc */
                  NomCas[longueur[0]]='\0';
                                                                ASSERT(NomCas!=(char*)0);
                  ltx = longueur[0];
                  CALL_GETVTX ( "CODE","NOM",iocc,iarg,mxval, NomCas ,&nbval) ;
                }
                else{
                  /* Erreur  */
                  PyErr_SetString(PyExc_KeyError, "Erreur a la recuperation du nom du cas");
                  return -1;
                }
                                                                SSCRUTE(NomCas) ;
                return 0;
}

/* ------------------------------------------------------------------ */
void DEFPPPP(POURSU,poursu,INTEGER* , INTEGER* , INTEGER* ,INTEGER*) ;
void DEFS(GCCPTS,gccpts,char *, int );

#define CALL_POURSU(a,b,c,d) CALLPPPP(POURSU,poursu,a,b,c,d)
#define CALL_GCCPTS(a,la) F_FUNC(GCCPTS,gccpts)(a,la)

static PyObject * aster_poursu(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
        /*
        FONCTIONALITE : poursuite
        est appele par cata.POURSUITE (cf. ops.py)
        */
        PyObject *temp = (PyObject*)0 ;
        PyObject *concepts = (PyObject*)0 ;
        INTEGER ipass=0;
        INTEGER lot=1 ; /* FORTRAN_TRUE */
        INTEGER ier=0 ;
        INTEGER lonuti=0 ;
        static int nbPassages=0 ;

        _DEBUT(aster_poursu) ;
                                                                SSCRUTE(aster_ident()) ;
                                                                ASSERT((nbPassages==1)||(commande==(PyObject*)0));
        nbPassages++ ;
        if (!PyArg_ParseTuple(args, "Ol",&temp,&ipass)) return NULL;

        /* On empile le nouvel appel */
        commande=empile(temp);

        if(PyErr_Occurred()){
            fprintf(stderr,"Warning: une exception n'a pas ete trait�e\n");
            PyErr_Print();
            fprintf(stderr,"Warning: on l'annule pour continuer mais elle aurait\n\
                            etre trait�e avant\n");
            PyErr_Clear();
        }

        fflush(stderr) ;
        fflush(stdout) ;

        try(1){
                /*  appel de la commande debut (effectue dans POURSU) */
                /*  La routine fortran POURSU traite aussi le cas     */
                /*  de la poursuite de calcul (en retour lonuti       */
                /*  contient le nombre de concepts crees dans le      */
                /*  calcul precedent)                                 */

                CALL_POURSU (&lot,&ipass,&ier,&lonuti);


                /* recuperation de la liste des concepts dans une     */
                /* string python                                      */

                concepts=PyString_FromStringAndSize(NULL,lonuti*80);
                CALL_GCCPTS (PyString_AsString(concepts),80);
        }
        finally{
                /* On depile l appel */
                commande = depile();

                /* une exception a ete levee, elle est destinee a etre traitee dans JDC.py */
                TraitementFinAster( exception_status ) ;

                _FIN(aster_poursu) ;
                return NULL;
        }

        /* On recupere le nom du cas */
        if(RecupNomCas() == -1){
          /* Erreur a la recuperation */

          /* On depile l appel */
          commande = depile();

          _FIN(aster_poursu) ;
          return NULL;
        }
        else{
          /* On depile l appel */
          commande = depile();

          /*  retour de la fonction poursu sous la forme
           *  d'un tuple de trois entiers et un objet */
          _FIN(aster_poursu) ;
          return Py_BuildValue("(iiiN)",lot ,ier,lonuti,concepts );
        }
}

/* ------------------------------------------------------------------ */
#define CALL_DEBUT(a,b,c)  F_FUNC(DEBUT,debut)(a,b,c)
extern void STDCALL(DEBUT,debut)(INTEGER* , INTEGER* , INTEGER* );

static PyObject * aster_debut(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
        PyObject *temp = (PyObject*)0 ;
        INTEGER ipass=0;
        INTEGER lot=1 ; /* FORTRAN_TRUE */
        INTEGER ier=0 ;
        static int nbPassages=0 ;

        _DEBUT(aster_debut) ;
                                                                SSCRUTE(aster_ident()) ;
                                                                ASSERT((nbPassages==1)||(commande==(PyObject*)0));
        nbPassages++ ;
        if (!PyArg_ParseTuple(args, "Ol",&temp,&ipass)) return NULL;

        /* On empile le nouvel appel */
        commande=empile(temp);

        if(PyErr_Occurred()){
            fprintf(stderr,"Warning: une exception n'a pas ete trait�e\n");
            PyErr_Print();
            fprintf(stderr,"Warning: on l'annule pour continuer mais elle aurait\n\
                            etre trait�e avant\n");
            PyErr_Clear();
        }

        fflush(stderr) ;
        fflush(stdout) ;

        try(1){
                /*  appel de la commande debut */
                CALL_DEBUT (&lot,&ipass,&ier);
        }
        finally{
                /* On depile l appel */
                commande = depile();

                /* une exception a ete levee, elle est destinee a etre traitee dans JDC.py */
                _FIN(aster_debut) ;
                TraitementFinAster( exception_status ) ;
                return NULL;
        }

        /* On recupere le nom du cas */
        if(RecupNomCas() == -1){
          /* Erreur a la recuperation */
          /* On depile l appel */
          commande = depile();
          _FIN(aster_debut) ;
          return NULL;
        }
        else{
          /* On depile l appel */
          commande = depile();
          /*  retour de la fonction debut sous la forme d un tuple de deux entiers */
          _FIN(aster_debut) ;
          return Py_BuildValue("(ii)",lot ,ier );
        }
}

/* ------------------------------------------------------------------ */
#define CALL_IBMAIN(a,b,c)  F_FUNC(IBMAIN,ibmain)(a,b,c)
extern void STDCALL(IBMAIN,ibmain)(INTEGER* , INTEGER* , INTEGER* );

static PyObject *aster_init(self, args)
PyObject *self; /* Not used */
PyObject *args;
{
   PyObject *res;
   INTEGER lot=1 ; /* FORTRAN_TRUE */
   INTEGER ier=0 ;
   INTEGER dbg=0 ; /* FORTRAN_FALSE */
   
   _DEBUT(aster_init)
   if (!PyArg_ParseTuple(args, "l",&dbg)) return NULL;
   
   /* initialisation de la variable `static_module` */
   static_module = PyImport_ImportModule("Execution/E_Global");
   if (! static_module) {
      MYABORT("Impossible d'importer le module E_Global !");
   }
   
   fflush(stderr) ;
   fflush(stdout) ;
   
   CALL_IBMAIN (&lot,&ier,&dbg);
   
   _FIN(aster_init)
return PyInt_FromLong(ier);
}


/* ------------------------------------------------------------------ */
static PyObject *aster_argv( _UNUSED  PyObject *self, _IN PyObject *args )
{

        /*
        A partir des arguments passes au script python, construction du
        tableau de chaines de caracteres C "char** argv" et initialisation
        de "argc" : la taille de ce tableau.
        Puis appel de Code_Aster en passant ces informations en argument.
        */


        int        k       = 0 ;
        long       argc    = 0 ;
        char      *chaine  = NULL ;
        PyObject  *liste   = NULL ;
        PyObject  *string  = NULL ;
        char     **argv    = NULL ;

        void asterm( long , char** ) ;
        void *malloc(size_t size);
	
        _DEBUT("aster_argv") ;


        /*
           la fonction aster_argv recoit un tuple d'arguments (ici de taille 1�
           dans lequel est stockee la liste, qui est extraite par l'appel a
           PyArg_ParseTuple.
        */

                                                                ISCRUTE((INTEGER)PyTuple_Size(args)) ;
        if (!PyArg_ParseTuple(args, "O" , &liste )) return NULL;


        /*  Allocation dynamique de argv : on ajoute un argument NULL */

        argc=PyList_GET_SIZE(liste) ;
                                                                ISCRUTE((INTEGER)argc) ;

        argv = (char**)malloc(1+argc*sizeof(char*)) ;
        argv[argc]=(char*)0 ;


        /* conversion de chaque element de la liste en une chaine */

        for ( k=0 ; (long)k<argc ; k++ ){
                string=PyList_GetItem(liste,k) ;
                                                                ASSERT(string!=NULL);
                                                                ASSERT(PyString_Check(string));
                argv[k]=PyString_AsString( string ) ;
                                                                ASSERT(argv[k]!=NULL);
        }
#ifdef _DEBOG_
        for ( k=0 ; (long)k<argc ; k++ ){
                ISCRUTE(k);SSCRUTE(argv[k]) ;
        }
#endif


        /* Passage des arguments a Code_Aster */

        asterm(argc,argv) ;


                                                                ASSERT(argv) ;
        free(argv);
        argv=(char**)0 ;

        Py_INCREF( Py_None ) ;
        _FIN("aster_argv") ;
        return Py_None;
}


/* ------------------------------------------------------------------ */
/* List of functions defined in the module */

static PyMethodDef aster_methods[] = {
                {"onFatalError", aster_onFatalError, METH_VARARGS},
                {"fclose",       aster_fclose,       METH_VARARGS},
                {"ulopen",       aster_ulopen,       METH_VARARGS},
                {"affiche",      aster_affich,       METH_VARARGS},
                {"init",         aster_init,         METH_VARARGS},
                {"debut",        aster_debut,        METH_VARARGS},
                {"poursu",       aster_poursu,       METH_VARARGS},
                {"oper",         aster_oper,         METH_VARARGS},
                {"opsexe",       aster_opsexe,       METH_VARARGS},
                {"repout",       aster_repout,       METH_VARARGS},
                {"impers",       aster_impers,       METH_VARARGS},
                {"repdex",       aster_repdex,       METH_VARARGS},
                {"mdnoma",       aster_mdnoma,       METH_VARARGS},
                {"mdnoch",       aster_mdnoch,       METH_VARARGS},
                {"rcvale",       aster_rcvale,       METH_VARARGS, rcvale_doc},
                {"argv",         aster_argv,         METH_VARARGS},
                {"prepcompcham", aster_prepcompcham, METH_VARARGS},
                {"getvectjev",   aster_getvectjev,   METH_VARARGS, getvectjev_doc},
                {"putvectjev",   aster_putvectjev,   METH_VARARGS},
                {"putcolljev",   aster_putcolljev,   METH_VARARGS},
                {"getcolljev",   aster_getcolljev,   METH_VARARGS, getcolljev_doc},
                {"GetResu",      aster_GetResu,      METH_VARARGS},
                {NULL,                NULL}/* sentinel */
};


/* ------------------------------------------------------------------ */
#define CALL_VERSIO(a,b,c,d,e) CALLPPPSP(VERSIO,versio,a,b,c,d,e)

void initvers(PyObject *dict)
{
    PyObject *v;
    INTEGER vers,util,nivo;
    INTEGER exploi;
    char date[20];
    char rev[8];

    CALL_VERSIO(&vers,&util,&nivo,date,&exploi);
    sprintf(rev,"%d.%d.%d",vers,util,nivo);
    PyDict_SetItemString(dict, "__version__", v = PyString_FromString(rev));
    Py_XDECREF(v);
}


/* Initialization function for the module (*must* be called initaster) */
static char aster_module_documentation[] =
"C implementation of the Python aster module\n"
"\n"
;

DL_EXPORT(void)
initaster()
{
        PyObject *m = (PyObject*)0 ;
        PyObject *d = (PyObject*)0 ;

        _DEBUT(initaster) ;

        /* Create the module and add the functions */
        m = Py_InitModule3("aster", aster_methods,aster_module_documentation);

        /* Add some symbolic constants to the module */
        d = PyModule_GetDict(m);

        initvers(d);
        initExceptions(d);

        /* Initialisation de la pile d appel des commandes */
        pile_commandes = PyList_New(0);

        _FIN(initaster) ;
}



/* ------------------------------------------------------------------ */
void AfficheChaineFortran( _IN char *chaine , _IN int longueur )
{
        /* Traitement des chaines fortran : pour le deboguage uniquement*/

        static FILE *strm ; /* le stream de sortie pointe sur la stderr */
        strm=stderr;

        if ( longueur ){
                int k=0 ;
                fprintf( strm , "'" ) ;
                for ( k=0 ; k<((longueur<=512)?longueur:512) ; k++ ){
                        fprintf( strm , "%c" , chaine[k] ) ;
                }
                fprintf( strm , "'\n" ) ;
                fflush(strm) ;
        }
        return ;
}

int EstPret( _IN char *chaine , _IN int longueur )
{
        /*
        Fonction  : EstPret
        Intention
                dit si "chaine" destinee a etre exploitee par un module fortran,
                est une commande ASTER i.e. si elle est composee uniquement de lettres,
                de chiffres, de _ et de caracteres blancs et si elle contient un
                caractere non blanc.
        */
        int pret     = 0 ;
        int k        = 0 ;
        int taille   = 0 ;

        taille = ( longueur < 1024 ) ? FindLength( chaine , longueur ) : 1024 ;
                                                                                        ASSERT(taille <= longueur ) ;

        if ( taille >= 0 ){
                pret = 1 ;
                if( isalpha(chaine[0]) ){
                        for( k=0 ; pret==1 && k<longueur ; k++ ){
                                pret = ( EstValide(chaine[k] ) ) ? 1 : 0 ;
                                if ( pret != 1 ){
                                        fprintf( stderr , "CARACTERE %d INVALIDE '%c' %d\n" , k , chaine[k] , (int)chaine[k]) ;
                                }
                        }
                }
                else{
                        fprintf( stderr , "PREMIER CARACTERE INVALIDE '%c' %d\n" , chaine[0] , (int)chaine[0]) ;
                }
                if ( pret != 1 ){
                                                                                        FSSCRUTE(chaine,longueur) ;
                }
        }
        return pret ;
}


/* ------------------------------------------------------------------ */
void AjoutChaineA( _INOUT char **base , _IN char *supplement )
{


        /*
        Procedure  : AjoutChaineA
        Intention
                la chaine de caractere "base" est agrandie de la chaine
                "supplement". La zone memoire occupee par base est reallouee
                et la valeur du pointeur *base est donc modifiee.
                Dans cette operation tous les caracteres sont significatifs
                sauf le caractere NUL ('\0').

        PRENEZ GARDE ! : base doit etre une zone allouee DYNAMIQUEMENT

        */

        char *resultat = (char*)0 ;
        int ajout      = 0 ;
        int taille     = 0 ;
        int total      = 0 ;
        void *malloc(size_t size);
	
        taille = ( *base ) ? strlen( *base ) : 0 ;

        ajout = ( supplement ) ? strlen( supplement ) : 0 ;
   total = taille + ajout + 1 /* caractere de fin de chaine */;

        if ( ajout > 0 ){
                if ( taille > 0 ){
                        resultat = (char*)(malloc(total)) ;
                        ASSERT(resultat!=NULL) ;
                        strcpy(resultat,*base) ;
                        strcat(resultat,supplement) ;
                }
                else{
                        resultat = (char*)(malloc(total)) ;
                        ASSERT(resultat!=NULL) ;
                        strcpy(resultat,supplement) ;
                }
        }
        else{
                if ( taille > 0 ){
                        resultat = (char*)(malloc(total)) ;
                        strcpy(resultat,*base) ;
                }
        }
        if( *base ){
                ASSERT(strlen(*base)==taille) /* verification INVARIANT !! */
                free(*base) ;
                *base=(char*)0 ;
        }
        *base = resultat ;
}


/* ------------------------------------------------------------------ */
const char *aster_ident()
{
        const char *identCVS = "$Id: astermodule.c,v 1.59.12.1.2.1 2001/05/16 16:14:54 iliade Exp $ $Name:  $" ;
        return identCVS ;
}


/* ------------------------------------------------------------------ */
void DEFP(GETCMC,getcmc,INTEGER *icmc)
{
        /*
          Procedure GETCMC : emule la procedure equivalente ASTER

          Entrees : aucune
          Sorties :
            icmc   : numero de la commande
          Fonction :
            Retourne le numero de la commande courante

        */
        PyObject * res = (PyObject*)0 ;
        _DEBUT("getcmc_") ;
        res = PyObject_GetAttrString(commande,"icmd");
        /*
                    Si le retour est NULL : une exception a ete levee dans le code Python appele
                    Cette exception est a transferer normalement a l appelant mais FORTRAN ???
                    On produit donc un abort en ecrivant des messages sur la stdout
        */
        if (res == NULL)
                MYABORT("erreur a l appel de getcmc dans la partie Python");

        *icmc = PyInt_AsLong(res);
                                                                                   ISCRUTE(*icmc) ;
        Py_DECREF(res);
        _FIN("getcmc_") ;
}
