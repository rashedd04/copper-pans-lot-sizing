/*********************************************
 * Modele (P)
 *********************************************/

/** Decommentez la ligne suivante pour tester le modele 
     sur toutes les capacites allant de 35 a 85 **/
  //include "main_P_test_U.mod";

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

/** Variables **/
dvar float+ x[types][periodes];
dvar float+ s[types][periodes];

/** Objectif **/
minimize
  sum(t in periodes, k in types) (
    x[k][t] * alpha[k] * coutProd[t] + 
    s[k][t] * beta[k] * coutStock[t]
  );

/** Contraintes **/
subject to {
  forall(t in periodes)
    ct_capacite:
      sum(k in types) x[k][t] <= capacite;

  forall(k in types)
    ct_flux_init:
      x[k][1] == demande[k][1] + s[k][1];

  forall(k in types, t in periodes : t > 1)
    ct_flux_suivants:
      s[k][t-1] + x[k][t] == demande[k][t] + s[k][t];
}

/** Affichage de la solution primale **/ 
execute AFFICHAGE_SOL_PRIMALE {
   writeln("Cout optimale : " + cplex.getObjValue());
   for (var t in periodes) {
      for (var k in types) {
         writeln("Jour " + t + " Type " + k + " : Prod=" + x[k][t] + ", Stock=" + s[k][t]);
      }
   }
}

/** Affichage de la solution duale **/ 
execute AFFICHAGE_SOL_DUALE {
   writeln("--- Valeurs Duales (Capacité) ---");
   for (var t in periodes) {
      writeln("Jour " + t + " : " + ct_capacite[t].dual);
   }
}
