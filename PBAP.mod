/*********************************************
 * OPL 12.6.0.0 Machine and Berth Alocation Problem
 Model and Algorithm created by Bruno Luís Hönigmann Cereser
 * Creation Date: 24/09/2015 at 15:58:09
 *********************************************/

/* --------------- Ranges --------------------------------------------------------- */
int N = ...; //Number of ships
int B = ...; //Number of berths
int P = ...; //Number of Machine Patterns
float M = ...; //Large number (for constraint reasons)


/* --------------- Sets --------------------------------------------------------- */
range Ships  = 1..N; //Set of ships
range Berths  = 1..B; //Set of berths
range Order = 1..N; //Order of ship service
range Patterns = 1..P; //Set of machines types
//range Machine = 1..TM; //Set of machines types


/* --------------- Parameters --------------------------------------------------------- */
float arrival_time[Ships] = ...;
float deadline_time[Ships] = ...;
float service_time[Patterns,Berths,Ships] = ...;



/* --------------- Variables --------------------------------------------------------- */
dvar float+ T[Ships]; //Sevice begin time
dvar boolean x[Ships,Order,Berths]; //Allocation variable
dvar boolean s[Ships,Ships]; //Indicator of machine sharing variable
dvar boolean w[Ships,Ships]; //Indicator of machine sharing variable
dvar boolean t_aloc[Patterns,Berths,Ships]; //Pattern used variable
dvar float+ t[Ships]; //Service time variable
dvar float z; //Object function value
dvar float d; //Dual function value

/* --------------- Auxiliarys --------------------------------------------------------- */
//auxiliary for better result print
string Result_sched[Order,Berths];
string Result_sim[1..N*N];
string Pattern_C[Ships];

//Optimization Time
float opt_time; float before;
execute{
	before = new Date();
}

string aux_input_1 = ...; string aux_input_2 = ...; 
string aux_output_1 = ...; string aux_output_2 = ...; string aux_output_3 = ...;
string aux_output_4 = ...; string aux_output_5 = ...;

/* --------------- Objective Function --------------------------------------------------------- */
minimize z; 
            												
            												
/* --------------- Constrains --------------------------------------------------------- */
subject to{
	OF: z == sum(i in Ships) (4*(T[i] - arrival_time[i]) + t[i]); 
	
	Service_time: forall( i in Ships, k in Berths, p in Patterns) 
					t[i] >= t_aloc[p,k,i] * service_time[p,k,i] ;
					
	Service_bin: forall( i in Ships, j in Ships, p in Patterns) 
					sum(k in Berths)t_aloc[p,k,i] >= sum(k in Berths)t_aloc[p,k,j] + (w[i,j] + s[i,j] -1) -1;
					
	Single_pattern: forall( i in Ships) sum(p in Patterns, k in Berths)t_aloc[p,k,i] == 1;
					
									
	Pattern_sel: forall( i in Ships,k in Berths) 
					sum(p in Patterns) t_aloc[p,k,i] >= sum(j in Order) x[i,j,k];
			
	Ship_in_port: forall(i in Ships) 
					T[i] >= arrival_time[i];
					
	Service_before_deadline: forall(i in Ships) 
								T[i] + t[i] <= deadline_time[i];
	
	Single_order: forall(j in Order, k in Berths) sum(i in Ships) x[i,j,k] <= 1;
	
	Single_service: forall(i in Ships) sum(j in Order, k in Berths) x[i,j,k] == 1;
	
	Position_order: forall(j in 2..N, k in Berths) sum(i in Ships) 
						x[i,j,k]<= sum(i in Ships)x[i,j-1,k];
	
	Mooring_time: forall(i in Ships, r in Ships, j in 2..N, k in Berths) 
					T[i] + M * (2 - x[i,j,k] - x[r,j-1,k]) >= T[r] + t[r];
					
	Simultaneous_Service: forall (i in Ships, j in Ships) 
						T[i] + t[i] - M*s[i,j] <= T[j];
					  forall (i in Ships, j in Ships) 
					  	T[i] + M*w[i,j] >= T[j] + t[j];


}
/* --------------- After Optimizations ------------------------------------------------ */
execute {
	for(var k in Berths){
		for(var j in Order){
			for(var i in Ships){
				if( x[i][j][k] == 1 ){
					//To print Results on Excel
					Result_sched[j][k] = ("Ship " + i);				
  				}				
			}
		}
 	}
 	
 	for(var i in Ships){
 		for(var j in Ships){
 			var a = 0; 		
 			for (var p in Order){		
 				a = a + (x[j][p][2] + x[i][p][1]);
   			}
   			if(5 - (s[i][j] + w[i][j] + a) == 1){
 				Result_sim[i+j] = ("Ship " + i + " and Ship " + j);			
 			} 						
 		} 	
 	}
 	
 	for(var k in Berths){
		for(var p in Patterns){
			for(var i in Ships){
				if( t_aloc[p][k][i] == 1 ){
					//To print Results on Excel
					Pattern_C[i] = p;				
  				}				
			}
		}
 	}
 	//optimization Time
 	var after = new Date();
	opt_time = (after-before)/1000;	
	
	d = cplex.getBestObjValue();
				
}
