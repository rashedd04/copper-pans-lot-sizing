/*********************************************
 * Programme permettant de tester (P) sur plusieurs valeurs de U
 * Copiez/collez la sortie du journal du script dans Excel
 *********************************************/

 main {
   // Parametrage
   var capacite_min = 35;
   var capacite_max = 85;
   var pas = 1;
   // boucle pour tester modele_P.mod sur plusieurs valeurs de U
   thisOplModel.generate();
   var masterData = thisOplModel.dataElements;   
   var subSource = new IloOplModelSource("modele_P.mod");
   var subDef = new IloOplModelDefinition(subSource);
   var subCplex = new IloCplex();
   writeln("U;z*(U)");
   for (var capa = capacite_min-pas; capa <= capacite_max; capa += pas){
      var subOpl = new IloOplModel(subDef,subCplex);
      masterData.capacite = capa;
      subOpl.addDataSource(masterData); 
      subOpl.generate();
      subCplex.solve();
      if (capa >= capacite_min)
        writeln(capa+";"+subCplex.getObjValue());
      subOpl.end();      
   }   
   subCplex.end();
   subDef.end();
   subSource.end();
 }