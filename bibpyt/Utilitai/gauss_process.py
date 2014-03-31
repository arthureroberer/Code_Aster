# coding=utf-8
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
# person_in_charge: irmela.zentner at edf.fr
 
# Routines for random signal generation 
"""gauss_process.py

A collection of general-purpose routines using Numeric

DSP2ACCE1D        ---      generation of trajectories of a stationary Gaussian process
gene_traj_gauss_evol1D ---      generation of trajectories of a non stationary Gaussian process
calc_dsp_KT            ---      construct KT PSD
calc_dsp_FR            ---      construct rational PSD
"""

from Utilitai.Utmess       import UTMESS
from math import pi,ceil, exp, sqrt, log ,cos
from cmath import sqrt as csqrt
import numpy as NP
import aster_fonctions
from Cata_Utils.t_fonction import ( t_fonction, )


## ----------------------------------------------------------------- 
##     ALGORITHME DE GENERATION DE SIGNAUX GAUSSIENS POUR LE CAS SCALAIRE 
##-----------------------------------------------------------------   
def DSP2ACCE1D(f_dsp,rv=None):
   # ----------------------------------
   # IN  : f_dsp   :  dsp function for of list frequencies lw2 on (0, OM)
   #       rv : realisation du vecteur de variables aleatoires gaussiennes complexe
   # OUT : Xt trajectoire du processus gaussien stationnaire normalise (m=0, ect=1)
   # ----------------------------------
   import aster_core
 
#ajouter:   FMIN, FMAX
   vale_dsp=f_dsp.vale_y
   lw2=f_dsp.vale_x

   DW=lw2[1]-lw2[0]
   nbfreq2=len(lw2)
   nbfreq=nbfreq2*2
   if rv==None: 
      rv=NP.random.normal(0.0,1.,nbfreq)+1j*NP.random.normal(0.0,1.,nbfreq)
   rv1=rv[0:nbfreq2]
   rv2=rv[nbfreq2:]


   CS=NP.array([0.0+0j]*nbfreq)    
       
   for (iifr) in range(nbfreq2):

      vale_i=sqrt(vale_dsp[iifr])
      CS[nbfreq2+iifr]=vale_i*rv1[iifr]
      CS[nbfreq2-iifr-1]=vale_i*rv2[iifr]
           
   SX=NP.fft.ifft(CS)*nbfreq
   ha=NP.exp(-1.j*pi*NP.arange(nbfreq)*(1.-1./nbfreq))   
   Xt=sqrt(DW)*(SX*ha).real  
   
   return Xt  


# ----------------------------------------------------------------- ------- 
#  ALGORITHME DE GENERATION DE SIGNAUX GAUSSIENS DSP evolutive non separable-----
#------------------------------------------------------------------------ 

def gene_traj_gauss_evol1D(calc_dsp_KT, l_w2,l_temps,t_ini, t_fin, rv=None, **kwargs):
   #---------------------------------------------
   # IN : 
   #      calc_dsp_KT :  function for the definition of the PSD matrix (KT ou rational type)
   #      lw2  :    the list of frequencies corresponding to spec (0, OM)
   #       wg, wn : fond freq and evolution [rad/s], fcp [Hz] corner frequency for Clough&Penzien filter
   # OUT : 
   #       Xt trajectoire du processus gaussien stationnaire normalise (m=0, ect=1)
   #---------------------------------------------
   import aster_core
   nbfreq2=len(l_w2)
   nbfreq=2*nbfreq2
   Xt=[]
   wg=kwargs['W0']
   amo=kwargs['Xi0']
   fcp=kwargs['FCORNER']
   wp=kwargs['WPENTE']
   TYPE=kwargs['TYPE_DSP']
   if TYPE == 'FR':
      R0=kwargs['para_R0']
      R2=kwargs['para_R2']
      l_FIT=kwargs['fonc_FIT'].vale_y
      assert len(l_FIT)==len(l_w2), "ERREUR listes frequences: emettre une fiche anomalie!"
      dsp_fr_refe = calc_dsp_FR(l_w2,wg, amo,R0,R2,fcp)
      #   calcul de la variance (sigma^2) de normalisation mof  
      if 'ALEA_DSP' in kwargs:   
         l_ALPHA = kwargs['ALEA_DSP']
         mof=NP.trapz(dsp_fr_refe*l_FIT*l_ALPHA,l_w2)*2.  
         l_FIT=l_FIT*l_ALPHA 
      else :      mof=NP.trapz(dsp_fr_refe*l_FIT,l_w2)*2.    



   DW=l_w2[1]-l_w2[0]
   if rv==None:
      rv=NP.random.normal(0.0,1.,nbfreq)+1j*NP.random.normal(0.0,1.,nbfreq)
#      vecc1=(NP.random.normal(0.0,1.,nbfreq2)+1j*NP.random.normal(0.0,1.,nbfreq2))
#      vecc2=(NP.random.normal(0.0,1.,nbfreq2)+1j*NP.random.normal(0.0,1.,nbfreq2))
#   else :
   vecc1=rv[0:nbfreq2]
   vecc2=rv[nbfreq2:]

   t_mid=0.5*(t_ini+ t_fin)
   wg_fin= wg+wp*(t_fin-t_mid)
   wg_ini= wg+wp*(t_ini-t_mid)

   for tii in l_temps:   

      if tii<t_ini:
         wgt=wg_ini
      elif  tii>t_fin:
         wgt= wg_fin
      else:
         wgt=wg+wp*(tii-t_mid)
      if wgt<=0.0: 
         UTMESS('F', 'SEISME_35',valk=(str(tii)))
   
    #calcul du facteur de normalisation
      if TYPE=='KT':
         dsp=calc_dsp_KT(l_w2,wgt, amo,fcp)
         S_cst=1./NP.trapz(dsp,l_w2)*0.5 # constante de normalisation pour que ecart_type=1 a pour tout t
         MAT=calc_dsp_KT(l_w2,wgt, amo, fcp, S_cst)
      elif TYPE=='FR':
         dsp=calc_dsp_FR(l_w2,wgt, amo,R0,R2,fcp)
         S_cst=mof/(NP.trapz(dsp*l_FIT,l_w2)*2.) # constante de normalisation pour que ecart_type=1 a pour tout t
         MAT=calc_dsp_FR(l_w2,wgt, amo,R0,R2,fcp, So=S_cst)*l_FIT

      vale_xp=NP.sqrt(MAT)*vecc1*NP.exp(1.j*l_w2*tii)
      vale_xn=NP.sqrt(MAT)*vecc2*NP.exp(-1.j*l_w2*tii)

      vale_Xt= sum(vale_xp)+ sum(vale_xn)

      Xt.append( vale_Xt.real*sqrt(DW) )
   aster_core.matfpe(1)


   return Xt
   



#----------------------------------------------------------------- 
#    filtre corner frequency wcp (modele Clough&Penzien)
#-----------------------------------------------------------------

# ------------------------------------------------------------------------------------------
def acce_filtre_CP(vale_acce,dt, fcorner,amoc=1.0):
    # ---------------------------------------------------------
    # IN : f_in: ACCELEROGRAMME (signal temporel), pas dt
    #         fcorner : corner frequency (Hz),  amoc: amortissement, l_freq: list of frequencies in Hz
    # OUT: f_out: ACCELEROGRAMME filtre (signal temporel),
    #### attention: il faut de preference  2**N
    # ---------------------------------------------------------

# CP filter/corner frequency : wcp
      wcp=fcorner*2.*pi 
      N=len(vale_acce)
      # discrectisation
      OM=pi/dt
      dw=2.*OM/N
      N2=N/2+1
      ws0=NP.arange(0.0,(N2+1)*dw , dw)   
      ws=ws0[:N2] 

      im=csqrt(-1)
      acce_in=NP.fft.fft(NP.array(vale_acce)) 
      hw2=ws**2*1./((wcp**2-ws**2)+2.*amoc*im*wcp*ws)
      liste_pairs=zip(hw2, acce_in[:N2])
      Yw=[a*b for a,b in liste_pairs]

      if is_even(N):#nombre pair
         ni=1
      else :#nombre impair
         ni=0

      for kk in range (N2+1, N+1):
            Yw.append(Yw[N2-ni-1].conjugate())
            ni=ni+1
      acce_out=NP.fft.ifft(Yw).real 
#      f_out = t_fonction(vale_t, acce_out, para=f_in.para)
      return acce_out        

# ------------------------------------------------------------------------------------------
def dsp_filtre_CP(f_in,fcorner,amoc=1.0):
    # ---------------------------------------------------------
    # IN : f_in: DSP (frequence rad/s), 
    #         fcorner : corner frequency Hz,  amoc: amortissement, l_freq: list of frequencies in Hz
    # OUT: f_out: DSP filtre (frequence rad/s),
    #### attention: il faut de preference  2**N
    # ---------------------------------------------------------

# CP filter/corner frequency : wc
      wcp=fcorner*2.*pi
      vale_freq=f_in.vale_x
      vale_dsp=f_in.vale_y
      HW=1./((wcp**2-vale_freq**2)**2 + 4.*(amoc**2)*(wcp**2)*vale_freq**2)
      dsp_out=vale_freq**4*vale_dsp*HW

      f_out = t_fonction(vale_freq, dsp_out, para=f_in.para)
      return f_out   



#------------------------------------------------------------------ 
#     PSD models
#----------------------------------------------------------------- 


#     KANAI TAJIMI PSD 
#-----------------------------------------------------------------

def calc_dsp_KT(lfreq, w0,amor,fcp, So=1.0):
# KT model  
      x11  =NP.array([4.*(amor**2)*(w0**2)*FREQ**2  for FREQ in lfreq ])
      xnum =x11+w0**4
      denom=NP.array([ (w0**2-FREQ**2)**2 for FREQ in lfreq ])
      denom=denom+x11
      valkt=xnum/denom
# CP filter
      wcp=2.*pi*fcp
#      wcp=0.5*pi
      amocp=1.0
      valcp  =NP.array([  FREQ**4 / ( 4.*(amocp**2)*(wcp**2)*FREQ**2+(wcp**2-FREQ**2)**2 )  for FREQ in lfreq ]  )
      dsp=valcp*valkt
      return dsp*So  
   
   
#     FRACTION RATIONELLE 
#-----------------------------------------------------------------

def calc_dsp_FR(lfreq, w0,amor,R0,R1, fcp, So=1.0):
# KT model  
      q0=w0**2
      q1=2.*amor*w0
      valkt =NP.array([(R0**2+R1**2*FREQ**2)/ ( (w0**2-FREQ**2)**2+ q1**2*FREQ**2 ) for FREQ in lfreq ])

# CP filter
      if fcp>0.0:
         wcp=2.*pi*fcp
#      wcp=0.5*pi
         amocp=1.0
         valcp  =NP.array([  FREQ**4 / ( 4.*(amocp**2)*(wcp**2)*FREQ**2+(wcp**2-FREQ**2)**2 )  for FREQ in lfreq ]  )
         dsp=valcp*valkt*So
      else:
         dsp=valkt*So

      return dsp  



# ----------------------------------------------------------------- 
#     ARIAS, duree phase forte TSM , T1 et T2 -----
#-----------------------------------------------------------------
 

def f_ARIAS (ta, acce, norme)   :
      acce2=NP.array(acce)**2   
      arias = NP.trapz(acce2,ta)   # energie 
      arias =arias*pi/(2.*norme)   # indic Arias      
      return arias     

def f_ARIAS_TSM (ta, acce, norme)   :
      arias =f_ARIAS (ta, acce, norme)  # indic Arias   
      ener=arias*(2.*norme)/pi
      acce2=NP.array(acce)**2 
      cumener=NP.array([NP.trapz(acce2[0:ii+1],ta[0:ii+1])  for ii in range(len(ta))])
      fract=cumener/ener 
      n1= NP.searchsorted(fract, 0.05) 
      n2= NP.searchsorted(fract,0.95)
#      n45= NP.searchsorted(fract,0.45)      
      TSM=ta[n2]-ta[n1]
      T1=ta[n1]
      T2=ta[n2]      
      return arias, TSM , T1,  T2     
         
def f_ENER_qt (ta, acce, n1, n2)   :
      acce2=acce**2
      ener= NP.trapz(acce2,ta)   # energie    
      P1=NP.trapz(acce2[0:n1],ta[0:n1])/ener
      P2=NP.trapz(acce2[0:n2],ta[0:n2])/ener             
      return ener, P1,  P2     
         


#----------------------------------------------------------------- 
#     FONCTION DE MODULATION Gamma
#----------------------------------------------------------------
 # fonction de modulation gamma:  calcul pour liste de freq (normalisee si a1=1.0)
def fonctm_gam(ltemps, a1,a2,a3):  
      qt=NP.array([a1*tt**(a2-1)*exp(-a3*tt) for tt in ltemps])
      return qt
#x_opt=fmin(f_opta,x0,args=(liste_t, N1, N2))           
 # fonction de modulation gamma: fonction cout pour identification des parametres     
def f_opta(x0,  ltemps, n1, n2) :
      alpha=x0[0]
      beta=x0[1]
      if alpha<=1.:
         resu=10.
      elif beta<0.0:
         resu=1000.
      else:
         qt=fonctm_gam(ltemps, 1.0,alpha,beta)
         ener, PINI, PFIN = f_ENER_qt (ltemps, qt, n1, n2)
         resu=sqrt((PINI-0.05)**2+ (PFIN-0.95)**2)
      return resu


# ----------------------------------------------------------------- 
#     FONCTION DE MODULATION Jennnings & Housner
# -----------------------------------------------------------------

def f_opt1(t1,ltemps, TS,a1,a2 ) :
   T1=t1[0]
   T2=T1+TS
   qt=fonctm_JetH(ltemps, T1,T2, a1,a2)
   n1= NP.searchsorted(ltemps,T1)  
   ener, PINI, PFIN = f_ENER_qt (ltemps, qt, n1, n1)
   residu=sqrt((PINI-0.05)**2)
   return residu


def f_opt2(x0,  ltemps, T1, TS) :
   T2=T1+TS      
   a1=x0[0]
   a2=x0[1]
   qt=fonctm_JetH(ltemps, T1,T2, a1,a2)
   n2= NP.searchsorted(ltemps,T2)  
   n1= NP.searchsorted(ltemps,T1)  
   ener, PINI, PFIN = f_ENER_qt (ltemps, qt, n1, n2)
   residu=sqrt((PFIN-0.95)**2)
   return residu


 # fonction de modulation Jennings & Housner normalisee 
def fonctm_JetH(ltemps, T1,T2, a1,a2) :     
      qt=[]
      for tt in ltemps:
         if tt<T1:
            qt.append((tt/T1)**2)
         elif tt<T2 :
            qt.append(1.0)
         else :
            qt.append(exp(-a1*(tt-T2)**a2))
      return NP.array(qt)





# ----------------------------------------------------------------- 
#     FORMULES DE RICE
# -----------------------------------------------------------------

def Rice2(w2,DSP) :  
#   MOMENTS 
    m0 = NP.trapz(DSP,w2)*2.
    m1 = NP.trapz(DSP*abs(w2),w2)*2.  
    m2 = NP.trapz(DSP*w2**2,w2)*2.  
#   FREQ_CENTRALE, BANDWIDTH
    vop=1/(2.*pi)*sqrt(m2/m0)
    delta=sqrt(1.-m1**2/(m0*m2))

    return m0,m1,m2,vop,delta



# ----------------------------------------------------------------- 
#     FACTEUR DE PIC (VANMARCKE)
# -----------------------------------------------------------------

 # calcul du facteur de peak par formule approche (Vanmarcke)
def peak(p,TSM, vop,amort) : 
   # ---------------------------------------------
   # IN  : oscillator eigenfrequency  vop (Hz), reduced damping amort , 
   #          fractile p, duration TSM  
   # OUT :  peak factor 
   # ---------------------------------------------
      omega0=vop*2.*pi
      deuxn = 2. * vop * TSM / ( -log(p) )
      if deuxn<1.:
         return 1.
      else: 
         xis=amort/(1.-exp(-2.*amort*omega0*TSM))
         delta=sqrt(4.*xis/pi)
         sexp = - delta**1.2 * sqrt(pi * log(deuxn))      
         nup2= 2. * log( deuxn * ( 1. - exp(sexp)) )
         nup2=max(1.0,nup2)
         return sqrt(nup2)


# calcul du facteur de peak par moments(formule Rice +Vanmarcke)
def peakm(p,TSM, w2, DSP) : 
    # ---------------------------------------------
    # IN   :  S(w) : DSP, w 
    #          fractile p, duration TSM  
    # OUT  :  peak factor     
    # ---------------------------------------------  
      m0 = NP.trapz(DSP,w2)*2.
      m1 = NP.trapz(DSP*abs(w2),w2)*2.  
      m2 = NP.trapz(DSP*w2**2,w2)*2. 
      vop=1./(2.*pi)*sqrt(m2/m0)      #   FREQ_CENTRALE
      delta=sqrt(1.-m1**2./(m0*m2))   #   BANDWIDTH
      deuxn = 2. * vop * TSM / ( -log(p) )
      if deuxn<1.:
         return 1.,m0
      else: 
         sexp = - delta**1.2 * sqrt(pi * log(deuxn))      
         nup2= 2. * log( deuxn * ( 1. - exp(sexp)) )
         nup2=max(1.0,nup2)
         return sqrt(nup2), m0




# ----------------------------------------------------------------- 
#     DSPSRO      SRO and DSP: functions of frequency (rad/s)
# -----------------------------------------------------------------

 # conversion DSP en SRO par formule de Rice
def DSP2SRO(f_in, xig, TSM, liste_freq, ideb=2) :
    # ---------------------------------------------
    # IN  : f_in: DSP   function of frequency (rad/s), amortissement xig, duree pase forte TSM, 
    #       liste_freq: liste de freq SRO (Hz)
    # OUT : f_out: SRO  function of frequency (Hz), meme norme que DSP
    # ---------------------------------------------
      para_dsp=f_in.para

      vale_dsp_in=f_in.vale_y
      vale_sro=[]
      vale_freq=f_in.vale_x

#      w=NP.array(vale_freq)
      vale_freq2=vale_freq**2

      for f_0 in liste_freq:
         if f_0 == 0.0:
            vale_sro.append(0.0 )
         else:
            w_0=f_0*2.*pi
            vale_dsp_rep=vale_dsp_in/((w_0**2-vale_freq2)**2+4.*xig**2*w_0**2*vale_freq2)
            npeakm ,m0i =peakm( 0.5,  TSM,  vale_freq, vale_dsp_rep)  
            vale_sro.append(w_0**ideb*npeakm*sqrt(m0i) )
#
      f_out = t_fonction(liste_freq, vale_sro, para=para_dsp)
      return f_out




# ----------------------------------------------------------------- 
#     SRO2DSP     DSP: function of frequency (rad/s)
# -----------------------------------------------------------------

# iteration par formule de Rice pour mieux fitter le spectre cible
def iter_SRO(f_dsp, f_sro, amort, TS) :
    # ---------------------------------------------
    # IN  : f_in: DSP [rad/s], sro : spectre cible [Hz], amort: amortissement sro, TS: duree phase forte, meme disretisation
    # OUT : f_out: dsp apres iterations pour fitter au mieux le spectre sro
    # --------------------------------------------- 
      para_dsp=f_dsp.para
      freq_dsp=f_dsp.vale_x
      vale_dsp=f_dsp.vale_y
      freq_sro=f_sro.vale_x
      vale_sro_ref=f_sro.vale_y
      nbvale=len(freq_dsp)

      Niter=10
      ii=0
      while ii < Niter:
         ii=ii+1
         f_sroi = DSP2SRO(f_dsp, amort, TS, freq_sro)
         valesro=f_sroi.vale_y
        #  calcul de la correction des DSP
         nz=NP.nonzero(valesro)
         factm=NP.ones(nbvale)
         factm[nz]=vale_sro_ref[nz]/valesro[nz]
         vale_dspi= vale_dsp*factm**2
         vale_dsp= vale_dspi
         f_dsp=t_fonction(freq_dsp,vale_dsp , para=para_dsp)

      f_out = f_dsp
      return f_out


# iteration par simulation temporelle pour fitter le spectre cible sur une realisation (accelerogramme)
#def itersim_SRO(f_dsp, f_sro, amort, TS, nb_iter, f_modul, INFO, dico_err, FMIN,FCORNER, NB_TIRAGE=1 ) :
def itersim_SRO(f_dsp, f_sro,nb_iter,f_modul, SRO_args ,dico_err,NB_TIRAGE=1 ) :
    # ---------------------------------------------
    # IN  : f_dsp: DSP [rad/s], f_sro: spectre cible [Hz], 
    #    amort: amortissement sro, TS: duree phase forte, meme disretisation
    #    type_mod: type de fonction de modulation     niter: nombre d'iterations, 
    #    FMIN: fequence min pour fit et filtrage ("corner frequency" Hz)
    # OUT : f_out: accelerogramme apres iterations pour fitter au mieux le spectre cible
    # ---------------------------------------------
   #  dsp in  

   FMIN=SRO_args['FMIN']
   FCORNER=SRO_args['FCORNER']
   amort=SRO_args['AMORT']
   TS=SRO_args['TSM']
   METHODE_SRO=SRO_args['METHODE_SRO']
   INFO=SRO_args['INFO']

#  #  dsp initiale
   para_dsp=f_dsp.para
   freq_dsp=f_dsp.vale_x
   vale_dsp=f_dsp.vale_y
   nbfreq2=len(freq_dsp)
   nbfreq=2*nbfreq2
#  #  sro cible
   freq_sro=freq_dsp/2./pi
   vale_sro_ref=f_sro.evalfonc(freq_sro).vale_y
   #  fonction de modulation 
   hmod=f_modul.vale_y
   ltemps=f_modul.vale_x
   dt=ltemps[2]-ltemps[1]
   para_modul=f_modul.para

#  FMIN pour le calcul de l'erreur relative 
   FMINM=max(FMIN, 0.1)
   FC=max(FCORNER,FMINM)
   N1=NP.searchsorted(freq_sro,FMINM)+1
   FRED=freq_sro[N1:]
   ZPA=vale_sro_ref[-1]
   vpsum=sum([ err_listes[0]   for err_listes in dico_err.values() ])

   coef_ZPA = dico_err['ERRE_ZPA'][0]/vpsum
   coef_MAX=  dico_err['ERRE_MAX'][0]/vpsum
   coef_RMS=  dico_err['ERRE_RMS'][0]/vpsum


   rv=NP.random.normal(0.0,1.,nbfreq)+1j*NP.random.normal(0.0,1.,nbfreq)
   list_rv=[rv]


   if NB_TIRAGE>1:
      ntir=1
      while ntir<NB_TIRAGE:
         rv=NP.random.normal(0.0,1.,nbfreq)+1j*NP.random.normal(0.0,1.,nbfreq)
         list_rv.append(rv)
         ntir=ntir+1

#  INITIALISATION
   errmult=[]
   l_dsp=[f_dsp]

   if NB_TIRAGE==1:
     acce =DSP2ACCE1D(f_dsp ,rv)*hmod  #modulation   
     if FCORNER> 0.0:  
        acce=acce_filtre_CP(acce,dt,FCORNER)
     f_acce=t_fonction(ltemps,acce, para=para_modul)

     l_acce=[f_acce]
     f_sroi = ACCE2SROM(f_acce, amort,freq_sro,2 , METHODE_SRO) 
     valesro=f_sroi.vale_y

   elif NB_TIRAGE>1 :
     liste_valesro=[]
     for ntir in range(NB_TIRAGE):
         Xt=DSP2ACCE1D(f_dsp ,list_rv[ntir])
         acce =Xt*hmod  #   modulation 
         if FCORNER> 0.0:  
             acce=acce_filtre_CP(acce,dt,FCORNER)
         f_acce=t_fonction(ltemps,acce, para=para_modul)
         f_sroi = ACCE2SROM(f_acce, amort,freq_sro,2, METHODE_SRO) 
         liste_valesro.append(f_sroi.vale_y)
     valesro=NP.median(NP.array(liste_valesro),axis=0)


   l_sro=[valesro]
   err_zpa,err_max,err_min,err_rms, freq_err  = erre_spectre(FRED, valesro[N1:],vale_sro_ref[N1:] )
   if INFO==2:  print 'ERREUR INITIAL: ZPA ERROR, MAX ERROR, RMS ERROR:', err_zpa, err_max, err_rms
   #  erreur multiobjectif
   err_ZPA = coef_ZPA*err_zpa
   err_MAX=  coef_MAX*err_max
   err_RMS=  coef_RMS*err_rms
   errmult.append (sqrt( 1./3.*(err_ZPA**2+err_MAX**2+err_RMS**2))   )
   print 'err_mult : ',sqrt( 1./3.*(err_ZPA**2+err_MAX**2+err_RMS**2))


# ITERATIONS

   for kk in range(nb_iter):
         if INFO==2: print 'ITERATION  ',   kk+1 , 'sur',  nb_iter

       #  CALCUL CORRECTION des DSP et mise a jour f_dsp
         nz=NP.nonzero(valesro)  
         factm=NP.ones(nbfreq2)
         factm[nz]=vale_sro_ref[nz]/valesro[nz]

         vale_dspi= vale_dsp*factm**2
#          vale_dsp[N1:]= vale_dspi[N1:]
         vale_dsp= vale_dspi
         f_dsp=t_fonction(freq_dsp,vale_dsp , para=para_dsp)
         f_dsp=dsp_filtre_CP(f_dsp,FC)
         l_dsp.append(f_dsp)


         #  ITERATION DSP ACCE
         if NB_TIRAGE==1:  
         #  calcul accelerogramme et SRO
            Xt =DSP2ACCE1D(f_dsp ,rv)       
            acce =Xt*hmod  #   modulation  
            if FCORNER> 0.0:  
                acce=acce_filtre_CP(acce,dt,FCORNER)
            f_acce=t_fonction(ltemps,acce, para=para_modul)
            l_acce.append(f_acce)
            f_sroi = ACCE2SROM(f_acce, amort,freq_sro,2, METHODE_SRO ) 
            valesro=f_sroi.vale_y

         elif NB_TIRAGE>1 :

            liste_valesro=[]
            for ntir in range(NB_TIRAGE):
               Xt=DSP2ACCE1D(f_dsp ,list_rv[ntir])
               acce =Xt*hmod  #   modulation 
               if FCORNER> 0.0:  
                   acce=acce_filtre_CP(acce,dt,FCORNER)
               f_acce=t_fonction(ltemps,acce, para=para_modul)
               f_sroi = ACCE2SROM(f_acce, amort,freq_sro,2, METHODE_SRO ) 
               liste_valesro.append(f_sroi.vale_y)
            valesro=NP.median(NP.array(liste_valesro),axis=0)
#            valesro=median_values(liste_valesro)

         #  CALCUL DES ERREURS 
         l_sro.append(valesro)
         err_zpa,err_max,err_min,err_rms, freq_err  = erre_spectre(FRED, valesro[N1:],vale_sro_ref[N1:] )
#         print 'err_zpa, err_max,  err_RMS:', err_zpa, err_max, err_rms
         #  erreur multionjectif
         err_ZPA = coef_ZPA*err_zpa
         err_MAX=  coef_MAX*err_max
         err_RMS=  coef_RMS*err_rms
         errmult.append (sqrt( 1./3.*(err_ZPA**2+err_MAX**2+err_RMS**2))   )
         print 'err_mult : ',sqrt( 1./3.*(err_ZPA**2+err_MAX**2+err_RMS**2))


# OPTIMUM

   ind_opt=NP.argmin(NP.array(errmult)  )
   f_dsp_opt=l_dsp[ind_opt]
#   if FCORNER>0.0 and ind_opt>0:
#      f_dsp_opt=dsp_filtre_CP(f_dsp_opt,FCORNER)
   valesro_opt=l_sro[ind_opt]


   err_zpa,err_max,err_min,err_rms, freq_err  = erre_spectre(FRED, valesro_opt[N1:],vale_sro_ref[N1:] )
   dico_err['ERRE_ZPA'].append(err_zpa)
   dico_err['ERRE_MAX'].append(err_max)
   dico_err['ERRE_RMS'].append(err_rms)

   if INFO==2:
      print  'MIN MULTERROR', errmult[ind_opt], '%   iteration ',  ind_opt
      print  'MAX ABS ERROR', err_max, '%  ',  'pour la frequence ', freq_err[0]
      print  'MAX MIN ERROR', err_min, '%  ',  'pour la frequence ', freq_err[1]
      print  'MAX ZPA ERROR', err_zpa 
      print  'MAX RMS ERROR', err_rms

      print '----------------------------------------------------------'

   for keys, listev in dico_err.items(): 
      tole=listev[1]*100.
      erre=abs(listev[-1])
      if abs(erre)>tole:
         nbi=len(listev)-2
         UTMESS('A', 'SEISME_36', vali=nbi,  valk=keys, valr=(erre,tole) )
   return f_dsp_opt, list_rv



# calcul de l'erreur
# ---------------------------------------------
def erre_spectre(Freq, valesro,vale_sro_ref ) :
         errlin=(valesro-vale_sro_ref)/vale_sro_ref*100.
         errzpa=errlin[-1]
         errmax=max(abs(errlin))
         errmin=min(errlin)
         errms=sqrt( 1./len(Freq)*NP.sum(errlin**2) )
         freqerr=([  Freq[NP.argmax(abs(errlin))], Freq[NP.argmin((errlin))]  ])

         return errzpa, errmax, errmin, errms, freqerr


def median_values(listes):
      N=len(listes[0])
      Nb=len(listes)
      median_val=[]

      for (ni1) in range(N):
         vsorted=[]
         for ni2 in range(Nb):
            vsorted.append(listes[ni2][ni1])
         vsorted.sort()
         if is_even(Nb):#nombre pair
            median_val.append(0.5*(vsorted[Nb/2]+vsorted[Nb/2-1]))   #even
         else :#nombre impair
            median_val.append(vsorted[(Nb-1)/2])   #odd


      return NP.array(median_val)


# conversion SRO en DSP equivalente par formule de Vanmarcke
def SRO2DSP(f_in, NORME, AMORT, TSM, FCOUP, PAS, FCORNER, FMIN, LIST_FREQ=None) :
   # ---------------------------------------------
   #  f_in : SRO cible, frequency given in (Hz)
   #  f_out: DSP compatible avec SRO, frequency list lw in (rad/s)
   # ---------------------------------------------
      wmax=FCOUP*2.*pi

      fmin=max(FMIN,0.05)
      wmin=fmin*2.*pi
#      wmin=1.001 
      para_dsp = {
         'INTERPOL' : ['LIN','LIN'],
         'NOM_PARA'    : 'FREQ',
         'PROL_DROITE' : 'CONSTANT',
         'PROL_GAUCHE' : 'EXCLU', 'NOM_RESU'   : 'ACCE'}

      freq0=0.0
      freqi=freq0
      DSP =[0.0]
      lw =[freq0]
      lf =[freq0]
      lsro=[0.0]

      

#      Sa_min=float(f_in.evalfonc([fmin]).vale_y*NORME)
#      nupi=peak(0.5,  TSM, fmin ,  AMORT)
#      DSP_min=Sa_min**2*2.*AMORT/(wmin*nupi**2)
#      dsp_p= DSP_min/ wmin   
      ii=0

      while freqi<wmax:

         if PAS!=None:
            freqi=freqi+PAS*2.*pi 
         else:
            if ii<len(LIST_FREQ):
               freqi=LIST_FREQ[ii]*2.*pi
               ii=ii+1
            else:
               freqi=wmax

         if freqi <= wmin:
            assert freqi > 0.0
            fi=freqi/2./pi
#            valsro=float(f_in.evalfonc([fi]).vale_y*NORME)
#            lsro.append(valsro)
            lsro.append(0.0)
#            valg = freqi*dsp_p
            DSP.append( 0.0)

         else:
            fi=freqi/2./pi
            valsro = float(f_in.evalfonc([fi]).vale_y*NORME) 
            lsro.append(valsro)
            nupi=peak(0.5,  TSM, fi,  AMORT)
            nup2=nupi**2
            v1 = 1. / (freqi * (pi / (2. * AMORT) - 2.))
            v2 = (valsro**2) / nup2
            v3 = 2.*NP.trapz(NP.array(DSP), NP.array(lw)) 
            v4=v1 * (v2 - v3)
            valg = max(v4, 0.)
            DSP.append(valg)

         lw.append(freqi)
         lf.append(freqi/2./pi)


      f_out = t_fonction(lw, DSP, para=para_dsp)
#     iteration sans simulation: formule de rice
      f_iter_sro_ref = t_fonction(lf, lsro, para=para_dsp)  # sro for   frequency list lw (rad/s), physical units (not g)
      f_dsp=iter_SRO(f_out,f_iter_sro_ref, AMORT, TSM )

      if FCORNER> 0.0:  
         f_out=dsp_filtre_CP(f_dsp,FCORNER) 
      else:
         f_out=f_dsp
      return f_out, f_iter_sro_ref


# ----------------------------------------------------------------- 
#     ACCE2SRO
# -----------------------------------------------------------------
 
# conversion ACCE en SRO par methode HARMO ou NIGAM
def ACCE2SROM(f_in, xig, l_freq, ideb, METHODE_SRO) :
   if METHODE_SRO=="NIGAM" : 
      para_dsp = {
         'INTERPOL' : ['LIN','LIN'],
         'NOM_PARA'    : 'FREQ',
         'PROL_DROITE' : 'CONSTANT',
         'PROL_GAUCHE' : 'EXCLU',
         'NOM_RESU'   : 'ACCE',
          }
      spectr = aster_fonctions.SPEC_OSCI(f_in.vale_x, f_in.vale_y,l_freq, [xig])
      vale_sro = spectr[0, ideb, :]
      f_out = t_fonction(l_freq, vale_sro, para=para_dsp)
   elif METHODE_SRO=="HARMO":
      f_out=ACCE2SRO(f_in, xig, l_freq, ideb=2)
   else: print "ERROR METHODE SRO"
   return f_out


 # conversion ACCE en SRO par fft et filtrage: METHODE_SRO=HARMO
def ACCE2SRO(f_in, xig, l_freq, ideb=2) :
    # ---------------------------------------------------------
    # IN : f_in: ACCELEROGRAMME (signal temporel) 
    #         xig: amortissement, l_freq: list of frequencies in Hz
    # OUT: f_out: SRO for l_freq (Hz)
    #### attention: il faut de preference en 2**N
    # ---------------------------------------------------------
      para_dsp = {
         'INTERPOL' : ['LIN','LIN'],
         'NOM_PARA'    : 'FREQ',
         'PROL_DROITE' : 'CONSTANT',
         'PROL_GAUCHE' : 'EXCLU',
         'NOM_RESU'   : 'ACCE',
      }
      vale_t=f_in.vale_x
      vale_acce=f_in.vale_y
      N=len(vale_t)
      dt=vale_t[1]-vale_t[0]

      # discrectisation
      OM=pi/dt
      dw=2.*OM/N
      N2=N/2+1

      ws0=NP.arange(0.0,(N2+1)*dw , dw)   
      ws=ws0[:N2] 
  
      vale_sro=[]
      im=csqrt(-1)
      acce_in=NP.fft.fft(NP.array(vale_acce))
      for fi in l_freq:
         w_0=fi*2.*pi  
         hw2=1./((w_0**2-ws**2)+2.*xig*im*w_0*ws)
         liste_pairs=zip(hw2, acce_in[:N2])
         Yw=[a*b for a,b in liste_pairs]

         if is_even(N):#nombre pair
            ni=1
         else :#nombre impair
            ni=0

         for kk in range (N2+1, N+1):
            Yw.append(Yw[N2-ni-1].conjugate())
            ni=ni+1
         acce_out=NP.fft.ifft(Yw).real 

         vale_sro.append(w_0**ideb*max(abs(acce_out)) )
      f_out = t_fonction(l_freq, vale_sro, para=para_dsp)
      return f_out
#
def is_even(num):
    """Return whether the number num is even."""
    return num % 2 == 0



## ----------------------------------------------------------------- 
##     DSP2FR
## -----------------------------------------------------------------
# # Ajustement d'une DSP rationelle proche de KT
#
#
def DSP2FR(f_dsp_refe, FC,) :
    # ---------------------------------------------------------
    # IN : f_spec: SRO cible en fonction de la frequence en Hz
    #      
    # OUT: f_out: DSP FR fonction de la frequence(rad/s)
    # ---------------------------------------------------------
      from Utilitai.optimize   import fmin
    
#  CALCUL DE LA DSP SPECTRUM-COMPATIBLE

#      f_dsp_refe =SRO2DSP(f_spec, NORME, AMORT, TSM, FCOUP, PAS, FCORNER, FMIN)  #  CALCUL DE LA DSP SPECTRUM-COMPATIBLE

#  FIT DSP FR
      para_dsp = f_dsp_refe.para
      lfreq=f_dsp_refe.vale_x
      vale_dsp=f_dsp_refe.vale_y
      m0,m1,m2, vop, deltau=Rice2(lfreq , vale_dsp)
##   parametres initiales
      w0= vop*2.*pi
      xi0=deltau**(2./1.2)*pi/4.
      dsp_FR_ini=calc_dsp_FR(lfreq,w0,xi0,w0**2 ,2.*w0*xi0 , FC)
      const_ini=2.*NP.trapz(dsp_FR_ini,lfreq)
      R0=w0**2*sqrt(m0)/sqrt(const_ini)
      R2=2.*w0*xi0*sqrt(m0)/sqrt(const_ini)
##    optimisation
#      dsp_FR_ini=calc_dsp_FR(lfreq,w0,xi0, R0 , R2, fcorner, So=1.0)

      x0=[R0,R2]
      para_opt=fmin(f_opt_FR1,x0,args=(f_dsp_refe,w0,xi0,FC)) 
      R0=abs(para_opt[0])
      R2=abs(para_opt[1])

      x0=[w0,xi0]
      para_opt=fmin(f_opt_FR2,x0,args=(f_dsp_refe,R0,R2,FC)) 
      w0=para_opt[0]
      xi0=para_opt[1]

      x0=[R0,R2]
      para_opt=fmin(f_opt_FR1,x0,args=(f_dsp_refe,w0,xi0,FC)) 
      R0=abs(para_opt[0])
      R2=abs(para_opt[1])
      

      dsp_FR_fin=calc_dsp_FR(lfreq,w0,xi0, R0 , R2, FC)
      FIT=NP.ones(len(lfreq))
      nz=NP.nonzero(dsp_FR_fin)
      FIT[nz]=vale_dsp[nz]/dsp_FR_fin[nz]
      f_fit = t_fonction(lfreq,FIT , para=para_dsp)
      return w0, xi0, R0, R2, f_fit
 
##---------------------------------------------------------
def f_opt_FR1(para_ini,f_dsp_refe,w0,xi0,fcorner) :
   R0=para_ini[0]
   R2=para_ini[1]
   lfreq=f_dsp_refe.vale_x
   sFR=calc_dsp_FR(lfreq,w0,xi0, R0, R2, fcorner, So=1.0)
   residu2=NP.sum((sFR-f_dsp_refe.vale_y)**2)
   return sqrt(residu2)

## ---------------------------------------------------------
def f_opt_FR2(para_ini,f_dsp_refe,R0,R2,fcorner) :
   w0=para_ini[0]
   xi0=para_ini[1]
   lfreq=f_dsp_refe.vale_x
   sFR=calc_dsp_FR(lfreq,w0,xi0, R0  , R2 , fcorner, So=1.0)
   residu2=NP.sum((sFR-f_dsp_refe.vale_y)**2)
   return sqrt(residu2)
## ---------------------------------------------------------



### ----------------------------------------------------------------- 
###     RAND_DSP
### -----------------------------------------------------------------

##  TIRAGE DSP ALEATOIRE : LOI LOGNORMALE

## Realisation de la DSP aleatoire de mediane f_dsp

def RAND_DSP(Periods, MAT_CHOL, f_dsp) :
#    # ---------------------------------------------------------
#    # IN : f_dsp: DSP mediane
#    #      MAT_CHOL  : chol(COV) pour la liste Periods
#    # OUT: f_rand_dsp = f_dsp*rand_vec: realisation DSP aleatoire 
#    # ---------------------------------------------------------
#
   vale_dsp=f_dsp.vale_y   
   freq_dsp=f_dsp.vale_x   

   alpha2=RAND_VEC(Periods, MAT_CHOL, len(freq_dsp), para=2.0)

   rand_dsp=vale_dsp*alpha2
   f_rand_dsp = t_fonction(freq_dsp,rand_dsp, para=f_dsp.para)
   return f_rand_dsp



def RAND_VEC(Periods, MAT_CHOL, Nbf, para=1.) :
#    # ---------------------------------------------------------
#    # IN : MAT_CHOL  : chol(COV) pour la liste Periods
#    # OUT: alpha = vecteur aleatoire lognormal
#    # ---------------------------------------------------------
#
   nbp=len(Periods)
   #on genere le vecteur Gaussien independ de moyenne 0 et COV=MAT_CHOL**2
   rv=NP.random.normal(0.0,1.,nbp)
   rvec=NP.inner(MAT_CHOL,rv)  

   if nbp<Nbf: #il faut completer pour les tres basses frequences avec Period>10s
      nbv=Nbf-nbp
      vec0=NP.ones(nbv)*rvec[0]
      rvec=NP.concatenate((vec0,rvec),axis=0)

   alpha=NP.exp(para*rvec)   #on prend la variable lognormale de median 1 et sigma=beta, on prend le carre car DSP: exp(rv)**2
   return alpha



#% %%% ------- Calcul de la matrice des coef de correlation 
## Model des coefficients de correlation (Baker)
##
#
def corrcoefmodel(Period, f_beta=None) :
    # ---------------------------------------------------------
    # IN : Periods= liste des periodes 1/f  [s]
    #      optionnel: liste de beta (ecart-type)
    #
    # OUT : mat_out= matrice de covariance pour periodes T 
    #       >>>coef de correlation (ecart-type=1)  si beta=None 
    #       >>>covariance si beta=tfonction 
    #    
    # REFERENCE     corrcoef selon le modele de Baker:  
    #          Baker & Jayaram, Earthquake Spectra 24(1),299-317, 2008.
    #     
    #       
    # ---------------------------------------------------------


   PMIN=min(Period)
   if  PMIN<0.01 : 
         UTMESS('F', 'SEISME_37', valk=(str(1./PMIN)) )   

   if  max(Period)>10.:
      nb=len(NP.extract(Period>10.,Period))
      Periods=Period[nb:]
   else: Periods=Period

   nbT=len(Periods)
   Mat_Eps=NP.array([0.0]*nbT*nbT) 
   Mat_Eps.resize(nbT,nbT)  


#Le modele de Baker est defini pour 
#   assert max(Periods)<=10., 'FREQUENCE MIN TROP ELEVEE, IL FAUT FMIN>0.1Hz POUR CE MODELE'


   if f_beta != None:
      f_beta=f_beta.evalfonc(1./Periods)
      vale_beta=f_beta.vale_y


   for  (ii,Ti)  in enumerate(Periods):
      for (jj,Tj)  in enumerate(Periods):
     
         Tmin=min(Ti,Tj)
         Tmax=max(Ti,Tj)
         C1=1.-cos(pi/2.-0.366*log(Tmax/max(Tmin,0.109)))
         C3=C1

         if Tmax <0.109: 
           C2=1.-0.105*(1.-1./(1.+exp(100.*Tmax-5.)))*((Tmax-Tmin)/(Tmax-0.0099))         
           Mat_Eps[ii,jj]=C2

         elif Tmin > 0.109 :
            Mat_Eps[ii,jj]=C1
        
         elif Tmax < 0.2 :
            C2=1.-0.105*(1-1/(1+exp(100*Tmax-5)))*((Tmax-Tmin)/(Tmax-0.0099))
            C4=C1+0.5*(sqrt(C3)-C3)*(1+cos(pi*Tmin/0.109))
            Mat_Eps[ii,jj]=min(C2,C4)

         else :
            C4=C1+0.5*(sqrt(C3)-C3)*(1.+cos(pi*Tmin/0.109))
            Mat_Eps[ii,jj]=C4


         if f_beta != None:
            Mat_Eps[ii,jj]= Mat_Eps[ii,jj]*vale_beta[ii]*vale_beta[jj]

   Mat_Gx=NP.linalg.cholesky(Mat_Eps)

   return Periods, Mat_Gx
