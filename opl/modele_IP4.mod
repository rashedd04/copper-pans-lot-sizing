/*********************************************
 * Modele (IP4) = (IP3) avec remarque sur les 14 jours
 *********************************************/

 include "main_IP.mod";

 /** Donnees **/
 int nbTypes = ...;
 int nbPeriodes = ...;
 range types = 1..nbTypes;
 range periodes = 1..nbPeriodes;
 int capacite = ...;
 int demande[types][periodes] = ...;
 float alpha[types] = ...;
 float beta[types] = ...;
 float coutProd[periodes] = ...;
 float coutStock[periodes] = ...;
 float coutFixe[periodes] = ...;
 int dureeMaxStock = 14; // Limite : on ne stocke pas plus de 14 jours
 /** Calcul des nombres maximum de casseroles stockees en fonction des donnees **/

 
 
 /** Variables **/
 dvar float+ x[types][periodes]; 
 dvar float+ s[types][periodes]; 
 dvar boolean y[periodes];
 dvar float+ w[types][periodes][periodes];
 
 
 /** Objectif **/
 minimize
  sum(t in periodes) (
    (sum(k in types) (x[k][t] * alpha[k] * coutProd[t] + s[k][t] * beta[k] * coutStock[t]))
    + coutFixe[t] * y[t]
  );
 
 /** Contraintes **/
 subject to {



  forall(t in periodes)
    ct_capacite:
      sum(k in types) x[k][t] <= capacite;

  forall(k in types)
    ct_flux_init:
      x[k][1] - s[k][1] == demande[k][1];

  forall(k in types, t in periodes : t > 1)
    ct_flux_suivants:
      s[k][t-1] + x[k][t] - s[k][t] == demande[k][t];


  forall(k in types, t in periodes)
    ct_lien_prod:
    // Prod ne sert que pour les demandes des 14 prochains jours
      x[k][t] == sum(p in periodes : p >= t && p <= t + dureeMaxStock) w[k][t][p];


  forall(k in types, p in periodes)
    ct_satisfaction_demande:
    // Demande satisfaite par production datant de moins de 14 jours
      sum(t in periodes : t <= p && t >= p - dureeMaxStock) w[k][t][p] == demande[k][p];



  
  forall(t in periodes, k in types, p in periodes : 
         p > t && p <= t + dureeMaxStock) 
    ct_gardiennage_fort:
    // Contrainte forte limitée à la fenêtre de 14 jours
      sum(tau in periodes : tau <= t && tau >= p - dureeMaxStock) w[k][tau][p] <= demande[k][p] * y[t];
      
 }