#pragma rtGlobals=3		// Use modern global access method and strict wave access.


//##########################################################################
//
ThreadSafe function PolyBase_G3F_2D(pos, order, wCP2D,  iCP)
	variable pos;
	variable order;
	wave wCP2D;
	variable iCP;
	
	if (order < 0) 
		return NAN
	endif 
	
	variable i;
	variable result = wCP2D[iCP][0];
	for ( i = 1; i<= order; i+= 1) 
		result += wCP2D[iCP][i] * pos^i;
	endfor;
	return result; 
end 		


//##########################################################################
// direct calculation fitting function 
// 2D global fit for 	four Nernstian trans. 

ThreadSafe function SpecEChem_4Spec_ForOxd_2D(wY, wCClb, wRClb, wGP, wCP2D, wRP2D, row, dFrom, dTo) :FitFunc 
	wave wY; // calculated Y wave
	wave wCClb; // column calibraion, applied potential
	wave wRClb; // frequency calibration 
	wave wGP; // global parameters wave
	wave wCP2D; // Col parameters wave
	wave wRP2D; // Row parameters wave
	variable row; // current row
	variable dFrom; // start offset in of data calculated here in the linear data wave 
	variable dTo; // end offset in of data calculated here in the linear data wave 

	variable Eapp
	variable E0_A = wGP[0]
	variable n_el_A = wGP[1]
	variable E0_B = wGP[2]
	variable n_el_B = wGP[3]
	variable E0_C = wGP[4]
	variable n_el_C = wGP[5]
	variable E0_D = wGP[6]
	variable n_el_D = wGP[7]
	variable RTF = 0.02439
	variable PopA, PopB, PopC, PopD

	variable wl = wRClb[row]; 
	
	variable i, iCP=0 
	for (i = dFrom; i<= dTo; i+=1, iCP+=1)
		EApp = wCClb[iCP]
		PopA = 1/(exp((E0_A - EApp)*n_el_A/RTF) +1)
		PopB = 1/(exp((E0_B - EApp)*n_el_B/RTF) +1)
		PopC = 1/(exp((E0_C - EApp)*n_el_C/RTF) +1)
		PopD = 1/(exp((E0_D - EApp)*n_el_D/RTF) +1)
		
		wY[i] = PopA *  wRP2D[row][0] + PopB *  wRP2D[row][1] + PopC * wRP2D[row][2] +  PopD * wRP2D[row][3]
		wY[i] += PolyBase_G3F_2D(wl, 5, wCP2D,  iCP)
	endfor
	// notice - no return statement
end


//##########################################################################
// process calculation function 
// population calculation for four Nernstian trans prior to fits. 

ThreadSafe function Process_SpecEChem_4Spec_ForOxd_2D(wGP, wProcess, wClb, dFrom, dTo) :FitFunc 
	wave wGP; // global input wave
	wave wProcess; // output wave
	wave wClb; // calibration wave: col0 - rows, col1 - columns, col3 - layers
					// only wClb[i][1] is meaningful in calculating process because it applies to all rows and layers 
	variable dFrom; // start offset in of data calculated here in the linear data wave 
	variable dTo; // end offset in of data calculated here in the linear data wave 

	variable Eapp
	variable E0_A = wGP[0]  
	variable n_el_A = wGP[1]
	variable E0_B = wGP[2]
	variable n_el_B = wGP[3]
	variable E0_C = wGP[4]
	variable n_el_C = wGP[5]
	variable E0_D = wGP[6]
	variable n_el_D = wGP[7]
	variable RTF = 0.02439
	variable PopA, PopB, PopC, PopD

	print "\n Process range is ",dFrom, " to ",dTo
	print "wClb dims are ",dimsize(wClb,0)," by ",dimsize(wClb,1)
	print "i=0 values are :",wClb[0][0],", ",wClb[0][1],",",wClb[0][2],"."
	print "wProcess dims are ",dimsize(wProcess,0)," by ",dimsize(wProcess,1)
	print " wProcess is ",nameofwave(wProcess)

	// G3F does not know how many process variables are necessary. By default wProcess has zero columns
	redimension /N=(-1, 4) wProcess

	variable i// , iCP=0 
	for (i=dFrom; i<= dTo; i+=1) //This loop runs through global wave and stores the output in the output wave.
		EApp = wClb[i][1] //Potential calibration.
		print "EApp for i=",i," is ",EApp
		
		PopA = 1/(exp((E0_A - EApp)*n_el_A/RTF) +1)  //This is the population calculation for all analytes.
		PopB = 1/(exp((E0_B - EApp)*n_el_B/RTF) +1)
		PopC = 1/(exp((E0_C - EApp)*n_el_C/RTF) +1)
		PopD = 1/(exp((E0_D - EApp)*n_el_D/RTF) +1)
		
		wProcess[i][0] = PopA
		wProcess[i][1] = PopB
		wProcess[i][2] = PopC
		wProcess[i][3] = PopD
		
	endfor
	// notice - no return statement
end


//##########################################################################
// process-based locals fitting function 
// 2D global fit for 	four Nernstian trans. 

ThreadSafe function ProcessFit_4Spec_ForOxd_2D(wY, wProc, wCClb, wRClb, wGP, wCP2D, wRP2D, row, dFrom, dTo) :FitFunc 
	wave wY; // calculated Y wave
	wave wProc; // process wave; meaning of each column is defined in the process function
	wave wCClb; // column calibraion, applied potential
	wave wRClb; // frequency calibration 
	wave wGP; // global parameters wave
	wave wCP2D; // Col parameters wave
	wave wRP2D; // Row parameters wave
	variable row; // current row
	variable dFrom; // start offset in of data calculated here in the linear data wave 
	variable dTo; // end offset in of data calculated here in the linear data wave 

	variable PopA, PopB, PopC, PopD


	variable wl = wRClb[row]; 
	
	variable i, iCP=0 
	for (i = dFrom; i<= dTo; i+=1, iCP+=1)
		// populations are simply read from the process wave
		PopA = wProc[iCP][0] // 1/(exp((E0_A - EApp)*n_el_A/RTF) +1)
		PopB = wProc[iCP][1] //1/(exp((E0_B - EApp)*n_el_B/RTF) +1)
		PopC = wProc[iCP][2] // 1/(exp((E0_C - EApp)*n_el_C/RTF) +1)
		PopD = wProc[iCP][3] //1/(exp((E0_D - EApp)*n_el_D/RTF) +1)
		
		wY[i] = PopA *  wRP2D[row][0] + PopB *  wRP2D[row][1] + PopC * wRP2D[row][2] +  PopD * wRP2D[row][3]
		wY[i] += PolyBase_G3F_2D(wl, 5, wCP2D,  iCP)
	endfor
	// notice - no return statement
end

//##########################################################################
// modified direct calculation fitting function; fitting a "loose" spectrum 
// 2D global fit for 	four Nernstian trans. 

ThreadSafe function Loose_SpecEChem_4Spec_ForOxd_2D(wY, wCClb, wRClb, wGP, wCP2D, wRP2D, row, dFrom, dTo) :FitFunc 
	wave wY; // calculated Y wave
	wave wCClb; // column calibraion, applied potential
	wave wRClb; // frequency calibration 
	wave wGP; // global parameters wave
	wave wCP2D; // Col parameters wave
	wave wRP2D; // Row parameters wave
	variable row; // current row
	variable dFrom; // start offset in of data calculated here in the linear data wave 
	variable dTo; // end offset in of data calculated here in the linear data wave 

	variable Eapp
	variable E0_A = wGP[0]
	variable n_el_A = wGP[1]
	variable E0_B = wGP[2]
	variable n_el_B = wGP[3]
	variable E0_C = wGP[4]
	variable n_el_C = wGP[5]
	//variable E0_D = wGP[6]		I'm commenting out the globals for analyte 4 in the mixture. This is my target for the "loose" spectrum.
	//variable n_el_D = wGP[7]
	variable RTF = 0.02439
	variable PopA, PopB, PopC, PopD

	variable wl = wRClb[row]; 
	
	variable i, iCP=0 
	for (i = dFrom; i<= dTo; i+=1, iCP+=1)
		EApp = wCClb[iCP]
		PopA = 1/(exp((E0_A - EApp)*n_el_A/RTF) +1)
		PopB = 1/(exp((E0_B - EApp)*n_el_B/RTF) +1)
		PopC = 1/(exp((E0_C - EApp)*n_el_C/RTF) +1)
		PopD = wCP2D [iCP][6] //1/(exp((E0_D - EApp)*n_el_D/RTF) +1)		
		//I assume that I need to calculate PopD using wCP2D. My idea was to calculate it at each Eapp, resulting in a 1D wave with populations at each potential.
		
		wY[i] = PopA *  wRP2D[row][0] + PopB *  wRP2D[row][1] + PopC * wRP2D[row][2] +  PopD * wRP2D[row][3]
		wY[i] += PolyBase_G3F_2D(wl, 5, wCP2D,  iCP)
		//I commented the baseline function out, since it was calling the ColLoc wave and I plan to use this for my loose spectrum.
	endfor
	// notice - no return statement
end

//##########################################################################
// loose process calculation function 
// population calculation for four Nernstian trans prior to fits. 

//ThreadSafe function Process_Loose_SpecEChem_4Spec_ForOxd_2D(wGP, wProcess, wClb, dFrom, dTo) :FitFunc 
	//wave wGP; // global input wave
	//wave wProcess; // output wave
	//wave wClb; // calibration wave: col0 - rows, col1 - columns, col3 - layers
					// only wClb[i][1] is meaningful in calculating process because it applies to all rows and layers 
	//variable dFrom; // start offset in of data calculated here in the linear data wave 
	//variable dTo; // end offset in of data calculated here in the linear data wave 

	//variable Eapp
	//variable E0_A = wGP[0]  
	//variable n_el_A = wGP[1]
	//variable E0_B = wGP[2]
	//variable n_el_B = wGP[3]
	//variable E0_C = wGP[4]
	//variable n_el_C = wGP[5]
	//variable E0_D = wGP[6]
	//variable n_el_D = wGP[7]
	//variable RTF = 0.02439
	//variable PopA, PopB, PopC, PopD

	//print "\n Process range is ",dFrom, " to ",dTo
	//print "wClb dims are ",dimsize(wClb,0)," by ",dimsize(wClb,1)
	//print "i=0 values are :",wClb[0][0],", ",wClb[0][1],",",wClb[0][2],"."
	//print "wProcess dims are ",dimsize(wProcess,0)," by ",dimsize(wProcess,1)
	//print " wProcess is ",nameofwave(wProcess)

	// G3F does not know how many process variables are necessary. By default wProcess has zero columns
	//redimension /N=(-1, 4) wProcess

	//variable i// , iCP=0 
	//for (i=dFrom; i<= dTo; i+=1) //This loop runs through global wave and stores the output in the output wave.
		//EApp = wClb[i][1] //Potential calibration.
		//print "EApp for i=",i," is ",EApp
		
		//PopA = 1/(exp((E0_A - EApp)*n_el_A/RTF) +1)  //This is the population calculation for all analytes.
		//PopB = 1/(exp((E0_B - EApp)*n_el_B/RTF) +1)
		//PopC = 1/(exp((E0_C - EApp)*n_el_C/RTF) +1)
		//PopD = 1/(exp((E0_D - EApp)*n_el_D/RTF) +1)
		
		//wProcess[i][0] = PopA
		//wProcess[i][1] = PopB
		//wProcess[i][2] = PopC
		//wProcess[i][3] = PopD
		
	//endfor
	// notice - no return statement
//end
