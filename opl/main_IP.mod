/*********************************************
 * Programme permettant d'afficher les informations des IP
 *********************************************/

 main {
  // Generation du modele
  writeln("Nom du modele "+thisOplModel.modelDefinition.modelSource.name);
  writeln("Generation du modele");
  thisOplModel.generate();
  var nbVar = cplex.getNcols();
  var nbCon = cplex.getNrows();
  // Parametrage de cplex pour desactiver toutes les astuces
  cplex.tilim = 60;         // temps limite
  cplex.epagap = 1e-4;      // tolerance absolue sur la qualite de la solution
  cplex.epgap = 1e-9;       // tolerance relative sur la qualite de la solution
  cplex.preind = 0;         // pas de preprocessing
  cplex.aggind = 0;         // pas d'aggregation
  cplex.aggfill = 0;        // pas d'aggregation
  cplex.cutsfactor = 0;     // pas de coupes
  cplex.cutpass = -1;       // pas de coupes
  cplex.heureffort = 1e-9;  // pas d'heuristique (sauf une fois)
  cplex.symmetry = 0;       // pas de dectection de symetrie
  // Resolution de la relaxation lineaire pour avoir la borne zLP
  writeln("Resolution de la relaxation lineaire (LP)");
  thisOplModel.convertAllIntVars();
  cplex.solve();
  var LP_racine = cplex.getObjValue();
  // Resolution de IP par Branch&Bound
  writeln("Resolution du PLNE (IP)");
  thisOplModel.unconvertAllIntVars();
  var debut = cplex.getCplexTime();
  cplex.solve();
  thisOplModel.postProcess();
  var fin = cplex.getCplexTime();
  var LP_feuilles = cplex.getBestObjValue();
  var IP_meilleur = cplex.getObjValue();
  var nbNoeudsBB = cplex.getNnodes();
  // Affichage des statistiques
  writeln("Nombre de variables   : "+nbVar);
  writeln("Nombre de contraintes : "+nbCon);
  writeln("Objectif de la relaxation lineaire a la racine  : "+(0.01*Math.round(100*LP_racine)));
  writeln("Objectif de la meilleure borne LP des feuilles  : "+(0.01*Math.round(100*LP_feuilles)));
  writeln("Objectif de la meilleure solution realisable IP : "+(0.01*Math.round(100*IP_meilleur)));
  writeln("Nombre de noeuds de Branch&Bound : "+nbNoeudsBB);
  var garantie = "optimale";
  if (Math.abs(LP_feuilles-IP_meilleur) > 0.01)
    garantie = (0.01*Math.round(10000*(IP_meilleur-LP_feuilles)/IP_meilleur))+" %";
  writeln("Garantie : "+garantie);
  writeln("Temps d'execution : "+(0.1*Math.round(10*(fin-debut)))+" secondes");  
}