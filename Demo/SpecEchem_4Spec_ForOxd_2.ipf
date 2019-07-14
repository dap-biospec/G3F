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
