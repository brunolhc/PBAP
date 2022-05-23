/*********************************************
 * OPL 12.6.0.0 Model
 * Author: User
 * Creation Date: 23/03/2016 at 14:47:25
 *********************************************/
main{
var problema =  new Array(4);
problema[1] = "Test_Case_PM1.dat";
problema[2] = "Test_Case_PM2.dat";
problema[3] = "Test_Case_PM3.dat";
problema[4] = "Test_Case_PM4.dat";

for (var s = 1; s <= 4; s++) 
{ 

var source = new IloOplModelSource("PBAP.mod"); 

var cplex = new IloCplex(); 

var def = new IloOplModelDefinition(source); 

var opl = new IloOplModel(def,cplex); 

var data = new IloOplDataSource(problema[s]); 
opl.addDataSource(data); 
opl.generate(); 

	
	
if (cplex.solve()){
writeln(s, "obj = ", cplex.getObjValue());
}else {
writeln("No solution");
};
opl.postProcess();			
};
};

