// Copyright © 2019, Denis A. Proshlyakov, dapro@chemistry.msu.edu
// This file is part of G3F project. 
// For more details see <https://github.com/dap-biospec/G3F> 
//
// G3F is free software: you can redistribute it and/or modify it under the terms of 
// the GNU General Public License version 3 as published by the Free Software Foundation.
//
// G3F is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied 
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this file.  If not, see <https://www.gnu.org/licenses/>.

#pragma rtGlobals=1		// Use modern global access method.
#pragma version =  20190710
#pragma IndependentModule = G3F

constant opt1stRowSkip = 65536
constant opt1stRowCalc = 131072
 
 

//***********************************************************************************************
// Global
Function DoFitButtonProc(ctrlName) : ButtonControl
	String ctrlName
	return DoFit(ctrlName, 0, 0)
end
	
//***********************************************************************************************
//Global
Function SimulateFitButtonProc(ctrlName) : ButtonControl
	String ctrlName
	return DoFit(ctrlName, (0x1 | 0x2 | 0x4 | 0x8 | 0x10| 0x20),1)
end
	
//***********************************************************************************************
//Local
Function DoFitRowOnlyButtonProc(ctrlName) : ButtonControl
	String ctrlName
	return DoFit(ctrlName, 2, 0)
End

//***********************************************************************************************
//Local

Function DoFitColOnlyButtonProc(ctrlName) : ButtonControl
	String ctrlName
	return DoFit(ctrlName, 4, 0)
End

//***********************************************************************************************
//Local
Function DoFitAllLocButtonProc(ctrlName) : ButtonControl
	String ctrlName
	return DoFit(ctrlName, 6, 0)
End
//***********************************************************************************************
Function CheckRanges(PFromS, PToS, PThinS, PMax, ErrorMsg )
	string PFromS, PToS, PThinS;
	variable  PMax; 
	string ErrorMsg
	
	NVAR PFrom = $PFromS
	NVAR PTo =$PToS
	NVAR PThin = $PThinS

	variable tmp
	if (PFrom > PTo) 
		tmp = PFrom;
		PFrom = PTo;
		PTo=tmp;
	endif
//	print "MaxVal ", PMax
	if (PTo > PMax)
		Doalert 0, ErrorMsg
		return 0
	endif
	if (PThin < 1)
		PThin = 1
	endif
	return 1
end

//***********************************************************************************************
// Global
Function AutoCycleButtonProc(ctrlName) : ButtonControl
	String ctrlName
	// how many times?
	NVAR cycleNum = $cG3FControl+":autoCycles"
//	print "AC:", cycleNum
	strswitch (ctrlName)
		case  "AutoCycleRCButton":
			FitSeries (cycleNum, "AutoCycleColRow")
			break;
		case  "AutoCycleGRButton":
			FitSeries (cycleNum, "AutoCycleGlobRow")
			break;
		case  "AutoCycleGCButton":
			FitSeries (cycleNum, "AutoCycleGlobCol")
			break;
		case  "AutoCycleGRCButton":
			FitSeries (cycleNum, "AutoCycleGlobRowCol")
			break;
		default:
			DoAlert 0, "Unknown autocylce mode..."
	endswitch 
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function  AutoCycleGlobRow(cycle)
	variable cycle;
	print ">>> Hold globals <<<";
	DoFit("", 0x2 | 0x4, 0)
	// Now local
	print "****************"
	print ">>> Fitting ROW Locals only <<<";
	DoFit("", 0x1 | 0x4, 0)
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function  AutoCycleGlobCol(cycle)
	variable cycle;
	print ">>> Hold globals <<<";
	DoFit("", 0x2 | 0x4, 0)
	// Now local
	print "****************"
	print ">>> Fitting COL Locals only <<<";
	DoFit("", 0x1 | 0x2, 0)
end
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function  AutoCycleColRow(cycle)
	variable cycle;
	print "****************"
	print ">>> Fitting COL Locals only <<<";
	DoFit("", 0x1 | 0x2, 0)
	// Now local
	print "****************"
	print ">>> Fitting ROW Locals only <<<";
	DoFit("", 0x1 | 0x4, 0)
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function  AutoCycleGlobRowCol(cycle)
	variable cycle;
	print "****************"
	print ">>> Fitting Globals only <<<";
	DoFit("", 0x2 | 0x4, 0)
	print "****************"
	print ">>> Fitting ROW Locals only <<<";
	DoFit("", 0x1 | 0x4, 0)
	print "****************"
	print ">>> Fitting COL Locals only <<<";
	DoFit("", 0x1 | 0x2, 0)
end


//***********************************************************************************************
function  FitSeries (cycles, AutoCycleFuncS)
variable cycles
string AutoCycleFuncS;

string autoFitCoeffS = cG3FHome+":autoFitCoeff"
string coeffS = cG3FHome+":Coeff"
variable nCoeff = DimSize($coeffS, 0)
if ((exists(autoFitCoeffS)!=1) || (DimSize($autoFitCoeffS, 1) != nCoeff+1) ) 
	Make /O/N=(0,nCoeff+1) $autoFitCoeffS
endif
Wave autoFitCoef = $autoFitCoeffS
Wave coef = $coeffS
variable logCount = DimSize($autoFitCoeffS, 0)
NVAR ChiSq = V_ChiSq
DoWindow/F G3FitPanel

variable i, j, k, l;

for (i=0; i<cycles; i+=1)
	// Set to hold global
	print "\r***********************************************************************************************"
	print "Round ",i, " of ", cycles
	
	// Call cycle function 
	Execute "G3F#"+AutoCycleFuncS+"("+num2str(i)+")"
	
	// Save results
	redimension /N=(logCount +1, nCoeff +1)   $autoFitCoeffS
	 autoFitCoef[logCount][, nCoeff -1] = coef[q]
	 autoFitCoef[logCount][nCoeff] = ChiSq
	 logCount += 1
	 DoUpdate
	 NVAR V_FitQuitReason = $"V_FitQuitReason";
	if (V_FitQuitReason ==2 )
		return 0
	endif
endfor
end

//***********************************************************************************************
//
// below use of coefficients must be revised!!!
function  X_FitSeries (cycles)
variable cycles
variable i


string autoFitCoeffS = cG3FHome+":autoFitCoeff"
string coeffS = cG3FHome+":Coeff"
variable nCoeff = DimSize($coeffS, 0)
if ((exists(autoFitCoeffS)!=1) || (DimSize($autoFitCoeffS, 1) != nCoeff+1) ) 
	Make /O/N=(0,nCoeff+1) $autoFitCoeffS
endif
Wave autoFitCoef = $autoFitCoeffS
Wave coef = $coeffS
variable logCount = DimSize($autoFitCoeffS, 0)
NVAR ChiSq = V_ChiSq
DoWindow/F G3FitPanel

CheckBox HoldNoneCheck win=G3FitPanel,  value=0
for (i=0; i<cycles; i+=1)
	// Set to hold global
	print "\r***********************************************************************************************"
	print "Round ",i, " of ", cycles

	// Save results
	
	redimension /N=(logCount +1, nCoeff +1)   $autoFitCoeffS
	 autoFitCoef[logCount][, nCoeff -1] = coef[q]
	 autoFitCoef[logCount][nCoeff] = ChiSq
	 logCount += 1
	 DoUpdate
	 NVAR V_FitQuitReason = $"V_FitQuitReason";
	if (V_FitQuitReason ==2 )
		return 0
	endif
endfor

endmacro
//***********************************************************************************************

Function DoFit(ctrlName, aHoldOverride, Simulate)
	string ctrlName
	variable aHoldOverride
	variable Simulate
	
	ControlInfo MinReportCheckBox
	variable MinReport = V_Value 
	
	NVAR V_FitError = V_FitError;
	if (!NVAR_Exists(V_FitError)) 
		variable /G V_FitError
	endif 
	V_FitError = 0;
	
	NVAR V_FitQuitReason = $"V_FitQuitReason";
	if (!NVAR_Exists(V_FitQuitReason)) 
		variable /G V_FitQuitReason
	endif 
	V_FitQuitReason = 0;

	STRUCT inDataT in3D;
	STRUCT outDataT outSet
	STRUCT chunkDataT chunk;
	
	NVAR mainOptions_ = $cG3FControl+":mainOptions"
	chunk.mainOptions = mainOptions_;
	NVAR corrOptions_ = $cG3FControl+":corrOptions"
	chunk.corrOptions = corrOptions_;
	
	ControlInfo DbgKeepCheckBox
	chunk.dbgKeep = V_Value;
	
	ControlInfo DbgSaveCheckBox
	chunk.dbgSave = V_Value;
	
	
	
	// see if set ID is applied
	SVAR sSetID = $cG3FControl+":setID"
	
	if (SetInRanges (in3D, sSetID))
		return -1;
	endif
	

	
	variable i,j
	
	if (!MinReport)
		Printf "\r*** G3F fitting ver. %s ***\r %s : %s\r", cG3FVer, date(), time()
	endif
	
	
	// check if we have enough columns to fit each row
	ControlInfo ColNo1stCheckBox
	variable skip1stCol = V_value;
	
	
	// check if we have enough rows to fit each column
	chunk.fData.L.fitLines = in3D.L.mtxLines
	if (chunk.fData.L.fitLines <=0 )
//		chunk.fData.L.fitLines = 1;
	endif
	
	variable nEffLayers = chunk.fData.L.fitLines ? chunk.fData.L.fitLines : 1; // at least one for dimensionality 
	
	
	chunk.fData.Z.fitLines = trunc((in3D.Z.to - in3D.Z.from + 1) / in3D.Z.thin); // until reduced due to mask
	chunk.cols = chunk.fData.Z.fitLines;
	if (skip1stCol) 
		chunk.cols -= 1;
	endif
	
	
	//*******************************************************
	// check masks, calibraion etc for input data dimensions
	//
	if (prepLInput(in3D, chunk.fData, outSet, MinReport))
		return -1;
	endif
	
	if (prepZInput(in3D, chunk.fData, outSet, MinReport))
		return -1;
	endif
	
	if (prepXInput(in3D, chunk.fData, outSet, MinReport))
		return -1;
	endif
	
	if (chunk.fData.Z.fitLines < 2)
		Doalert 0, "Less than 2 columns to fit - please adjust range or thinning"
		return -1
	endif
	
	
	//*******************************************************
	// this only checks/assembles input data
	//
	if (prepDataInput(in3D, chunk.fData, outSet, MinReport))
		return 0
	endif
	
	
	
	//***************************************************************************************************
	// Check for Local Parameters waves and set/adjust guesses as needed
	//
	
	if (skip1stCol)
		chunk.corrOptions = chunk.corrOptions | 0x04
	endif

	if (!SetGlobGuesses("Glob", chunk.fVars.Glob, in3D ) \
		||	!SetLocGuesses(RecycleRow,  		"Row", 	chunk.fVars.Row, 		"SetRowGuessFunction", 		chunk.fData.X.fitLines, 	chunk.fData.X.fitLines, 0, 							in3D, 1,  in3D.X.clbW ) \
		|| !SetLocGuesses(RecycleCol,  		"Col", 	chunk.fVars.Col, 		"SetColGuessFunction", 		chunk.cols,  					chunk.fData.Z.fitLines, 0, 							in3D, 0, in3D.Z.clbW ))
		return 0;
	endif
	
	if (chunk.fData.L.fitLines > 0 )
		if (	!SetLocGuesses(RecycleLay,  		"Lay", chunk.fVars.Lay, 		"SetLayGuessFunction", 		chunk.fData.L.fitLines, 		chunk.fData.L.fitLines, 0, 								in3D, 2, in3D.L.clbW ) \
			|| !SetLocGuesses(RecycleLayRow, 	"LayRow", chunk.fVars.LayRow, "SetLayRowGuessFunction", 	chunk.fData.X.fitLines,  	chunk.fData.X.fitLines, chunk.fData.L.fitLines, in3D, 3, LRWave ) \
			||	!SetLocGuesses(RecycleLayCol, 	"LayCol", chunk.fVars.LayCol, "SetLayColGuessFunction", 	chunk.fData.Z.fitLines,  	chunk.fData.Z.fitLines, chunk.fData.L.fitLines, in3D, 4, LCWave ))
			return 0;
		endif
	else
		SetLocGuesses(RecycleLay,  		"Lay", 	chunk.fVars.Lay, 		"SetLayGuessFunction", 		0, 	0, 0, in3D, 2, in3D.L.clbW )
		SetLocGuesses(RecycleLayRow, 	"LayRow", chunk.fVars.LayRow, "SetLayRowGuessFunction", 	0,  	0, 0, in3D, 3, LRWave )
		SetLocGuesses(RecycleLayCol, 	"LayCol", chunk.fVars.LayCol, "SetLayColGuessFunction", 	0,  	0, 0, in3D, 4, LCWave )
	endif
	
	
	
	//*******************************************************
	// prepare fitting waves and set corresponding references in chunk structure
	//	
	if (prepFitChunk(in3D, chunk.fData, outSet, chunk, MinReport))
		return -1
	endif


	// Set reporting options
	variable /G V_FitOptions
	NVAR VFitOptions = V_FitOptions
	variable DoNotReportValues
	VFitOptions = 0;
	if (aHoldOverride)
		ControlInfo SupressDialogCheckBox 
		if (V_value) 
			VFitOptions = VFitOptions | 4
		endif
		ControlInfo DoNotReportCheckBox 
		if (V_value) 
			DoNotReportValues = V_Value
		endif
	endif

	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Functions section

	prepFitFunctions(in3D, chunk, MinReport);


	copyGuesses(in3D, chunk.fData, chunk.fVars, chunk, aHoldOverride, MinReport) // this sets GHoldFlags


	variable k;
	
	//*********************************************************************************
	// Logging options
	prepLogging(chunk);
	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Report ranges used
	if (!MinReport)
		if (in3D.X.ave)
			printf "\rRow range [%u (%u ave.) %u]  ", in3D.X.from , in3D.X.thin , in3D.X.to
		else
			printf "\rRow range [%u (%u) %u]  ", in3D.X.from , in3D.X.thin , in3D.X.to
		endif
		if (in3D.Z.ave)
			printf "  Col range [%u (%u ave.) %u]\r", in3D.Z.from, in3D.Z.thin, in3D.Z.to
		else
			printf "  Col range [%u (%u) %u]\r", in3D.Z.from, in3D.Z.thin, in3D.Z.to
		endif
		if (in3D.L.mtxLines > 0 )
			printf "  Layer range [0 to %u]\r", (chunk.fData.L.fitLines-1)
		endif 
	endif
	
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Start of chunky behavior
	variable CStart, CEnd,  C
	variable ChunkLLen; 
	variable linCoefOffset;
	
	// if track time!
	chunk.startTime = DateTime;
	
	chunk.cpuTime = 0;
	chunk.stepCount = 0;

	NVAR V_FitError = V_FitError;
	V_FitError = 0;
	
	for (CStart = 0, C=1; CStart < chunk.fData.X.fitLines; CStart+= chunk.fData.ChunkSize, C+=1)
		CEnd = CStart + chunk.fData.ChunkSize -1;
		if (CEnd >= chunk.fData.X.fitLines)
			CEnd = chunk.fData.X.fitLines -1;
		endif
		chunk.rows = CEnd - CStart +1;
	
		// Set initial size; it will be adjusted later
		Redimension /D/N=(chunk.rows * chunk.fData.Z.fitLines * nEffLayers) chunk.CLinW, chunk.CDestW
		if (waveexists(chunk.CResW))
			Redimension /D/N=(chunk.rows * chunk.fData.Z.fitLines * nEffLayers) chunk.CResW
		endif 
		Redimension /D/N=(chunk.rows * chunk.fData.Z.fitLines * nEffLayers, 3) chunk.CClbW 
		chunk.CClbW[][]=-1
		if (waveexists(chunk.CXZRefW))
			Redimension /D/N=(chunk.rows * chunk.fData.Z.fitLines * nEffLayers,-1) chunk.CXZRefW 
		endif 
	
		Redimension /D/N=(0) chunk.CParamW 
	
		// load coefficients
		Guess2FitCoef(chunk.CParamW, chunk.fVars.Glob,     	1, 								0,     						linCoefOffset); // globals
		Guess2FitCoef(chunk.CParamW, chunk.fVars.Row,      	chunk.rows, 					0,     						linCoefOffset);
		Guess2FitCoef(chunk.CParamW, chunk.fVars.Col,      	chunk.cols, 					0,     						linCoefOffset);
	  	Guess2FitCoef(chunk.CParamW, chunk.fVars.Lay,   		chunk.fData.L.fitLines, 		0,     						linCoefOffset);
		Guess2FitCoef(chunk.CParamW, chunk.fVars.LayRow, 	chunk.fData.X.fitLines, 		chunk.fData.L.fitLines, 	linCoefOffset);
		Guess2FitCoef(chunk.CParamW, chunk.fVars.LayCol, 	chunk.cols, 					chunk.fData.L.fitLines, 	linCoefOffset);
		
		variable offsL = AssembleLinearChunk (chunk.fData, chunk, CStart)
	
		// Actual size may be smaller if col limit was used!
		Redimension /D/N=(offsL) chunk.CLinW, chunk.CDestW 
		if (waveexists(chunk.CResW))
			Redimension /D/N=(offsL) chunk.CResW 
		endif
		Redimension /D/N=(offsL, 3)  chunk.CClbW // $ClbWaveS 
		if (waveexists(chunk.CXZRefW))
			Redimension /D/N=(ChunkLLen, -1) chunk.CXZRefW //$XZRefWaveS
		endif	
		
		// Make options strings and waves
		MtrxMakeHoldString(			chunk); // applies to fitted COL locals only 
		G3FitMakeConstraintWave(	chunk) ; 
		G3FitMakeEpsilonWave(		chunk) ;
		
		CheckError("Final fit prep");
		
		// MAIN FIT COMMAND EXECUTION!	
		if (Simulate || (dimsize(chunk.CParamW, 0) <=0)) // everything is held, perform simulation
			simulateChunk(chunk)
		else	//	  	execute FullCommand
			fitChunk(chunk, C) //HSTR, WEps, WConstr, C)
			if (!MinReport)
				printf "<<ChiSq=%g>> points=%u, variables=%u\r",chunk.V_ChiSq ,chunk.V_npnts, numpnts(chunk.CParamW)
			else
				printf "<< ChiSq=%g >>\r",chunk.V_ChiSq
			endif
		endif
		
		// report the results	
		WAVE WSigma = $"w_sigma"
	
		MTXReportResults(chunk.fVars);
		 	
		Wave/Z w = TempXW
		if (WaveExists(w))
			KillWaves w
		endif
		Wave/Z w = TempYW
		if (WaveExists(w))
			KillWaves w
		endif
		CheckError("Cleanup temp waves");
	
	
		//copy values to local coefficients wave
		if (V_FitError)
			V_FitError =  V_FitError & ~1;
			if (V_FitError & 1 << 3)
				// check if there is a non-number in coefficients
				string CErrors = "";
				for (i=0; i< dimSize(chunk.CParamW, 0); i++)
					// is this param held? 
					if (strlen(chunk.HoldStr)==0 || (cmpstr(chunk.HoldStr[i,i], "0") == 0 ))
						switch (numtype(chunk.CParamW[i]))
							case 1: 
										CErrors += "INF@"+num2str(i)+" ";
										break;
							case 2: 
										CErrors += "NAN@"+num2str(i)+" ";
										break;
							case 0: // real number, OK
						endswitch
					endif
				endfor
				
				string YErrors = "";
				for (i=0; i< dimSize(chunk.CDestW, 0); i++)
					switch (numtype(chunk.CDestW[i]))
						case 1: 
									YErrors += "INF@"+num2str(i)+" ";
									break;
						case 2: 
									YErrors += "NAN@"+num2str(i)+" ";
									break;
						case 0: // real number, OK
					endswitch
				endfor
				
				if (strlen(CErrors) + strlen(YErrors))
					string alertStr = "";
					if (strlen(CErrors))
						alertStr += "Coeffs: ["+CErrors+"] ";
					endif 
					if (strlen(YErrors))
						alertStr += "Destination: ["+YErrors+"] ";
					endif 
					DoAlert 1, "Non-real value was returned in "+alertStr+". Do you want save results?"
					if (V_flag == 1)
						V_FitError = V_FitError & ~ (1 << 3);
					endif	
				else
					DoAlert 1, "Igor raised a \"INF or NAN return value\" error, but no such values were found in the coefficients or destination data. Do you want save results?"
					if (V_flag == 1) // clear flag
						V_FitError = V_FitError & ~ (1 << 3);
						// calculate ChiSq since fitting did not report any
						variable ChiSq = 0;
						for (i=0; i< chunk.CDestW[i]; i++)
							ChiSq += (chunk.CDestW[i] - chunk.CLinW[i]  )^2 / chunk.CLinW[i];
						endfor
						printf "actual <<ChiSq=%g>>", ChiSq 
					endif	
					
				endif
				
			endif
			if (V_FitError  & 1 << 1)
				DoAlert 0, "Singular matrix error occured, results will not be saved.\rAre you using epsilon for all local variables?\rAre all fitted variables used in calculation?"
			endif
			if (V_FitError  & 1 << 2)
				DoAlert 0, "Out of memory error occured, results will not be saved. Revise conditions and try again."	
			endif
		endif 
		
		if (V_FitError == 0) // Save results
				
				//linCoefOffset = locCoefOffs;
				linCoefOffset = 0;
				FitCoeff2Guess(chunk.CParamW, 	chunk.fVars.Glob, 		1, 								0, 								linCoefOffset,	CStart	);
				FitCoeff2Guess(chunk.CParamW, 	chunk.fVars.Row, 		chunk.rows, 					0, 								linCoefOffset,	CStart);
				FitCoeff2Guess(chunk.CParamW, 	chunk.fVars.Col, 		chunk.cols, 					0, 								linCoefOffset,	0);
				if (chunk.fData.L.fitLines > 0 )
					FitCoeff2Guess(chunk.CParamW, 	chunk.fVars.Lay, 		chunk.fData.L.fitLines, 	0, 								linCoefOffset,	0);
					FitCoeff2Guess(chunk.CParamW, 	chunk.fVars.LayRow, 	chunk.fData.X.fitLines, 	chunk.fData.L.fitLines, 	linCoefOffset, 	0);
					FitCoeff2Guess(chunk.CParamW, 	chunk.fVars.LayCol, 	chunk.fData.Z.fitLines, 	chunk.fData.L.fitLines,	linCoefOffset, 	0);
				endif 
				
				//linCoefOffset = locCoefOffs;
				linCoefOffset = 0;
				FitSigma2Guess(WSigma, 		chunk.fVars.Glob, 		1, 								0,								linCoefOffset, CStart);
				FitSigma2Guess(WSigma, 		chunk.fVars.Row, 		chunk.rows, 					0,								linCoefOffset, CStart);
				FitSigma2Guess(WSigma, 		chunk.fVars.Col, 		chunk.cols, 					0,								linCoefOffset, 0);
				if (chunk.fData.L.fitLines > 0)
					FitSigma2Guess(WSigma, 		chunk.fVars.Lay, 		chunk.fData.L.fitLines, 	0,								linCoefOffset, 0);
					FitSigma2Guess(WSigma, 		chunk.fVars.LayRow, 	chunk.fData.X.fitLines, 	chunk.fData.L.fitLines, 	linCoefOffset, 0);
					FitSigma2Guess(WSigma, 		chunk.fVars.LayCol, 	chunk.fData.Z.fitLines, 	chunk.fData.L.fitLines, 	linCoefOffset, 0);
				endif 
				
	
				if (!(chunk.fVars.Glob.hold)) 
					Wave/T GuessListWave = $cG3FControl+":GuessListWave"
					for (i=0; i<dimSize(GuessListWave, 0); i+=1)
						switch (numtype(chunk.fVars.Glob.ParW[i]))
							case 0: // regular value
							case 1: // inf
								GuessListWave[i][2] = num2str(chunk.fVars.Glob.ParW[i]) // save back values
								break;
							case 2:
								GuessListWave[i][2] = "";
								break;
							endswitch
					endfor
				endif
	
				outSet.oFitW = NaN;
				variable LShift = 0, L;
				for (L=0; L<chunk.fData.L.fitLines || L == 0; L+=1)
					for (i=0; i<chunk.rows; i+=1)
						if (waveexists(chunk.CResW))
							outSet.oResW [i][0, chunk.fData.ColNumWave[i] -1][L] = chunk.CResW[LShift + q]
						endif
						outSet.oFitW[i][0, chunk.fData.ColNumWave[i] -1][L] = chunk.CDestW[LShift+q]
						// Now calcuate thinned wave is necessary
						// this can be optional IF data are not complete...
						LShift += chunk.fData.ColNumWave[i];		
					endfor
				endfor
				
				makedThinnedDim(in3D, outSet.X, chunk.fData.X.fitClbW, "MakeXClbCheckBox", "_ThinXClb" )
				makedThinnedDim(in3D, outSet.Z, chunk.fData.Z.fitClbW, "MakeZClbCheckBox", "_ThinZClb" )
				makedThinnedDim(in3D, outSet.L, chunk.fData.L.fitClbW, "MakeLClbCheckBox", "_ThinLClb" )
	
		elseif (V_FitError != 2 && V_FitError != 4) // V_FitError is none of the above....
			DoAlert 0, "Error flag was raised with the code="+num2str(V_FitError)+" but I do not know how to handle it.\n Results will not be saved. To update results manually hold all parameters and invoke fit."	
		endif
		// Save results of the chunk
		// RP Ref are averaged within chunk only 
		if (waveexists(outSet.X.refW) && waveexists(chunk.CXZRefW))  // Optional Col Reference wave	
			outSet.X.refW[CStart, CEnd][]  = chunk.CXZRefW[(p - CStart) *chunk.fData.Z.fitLines ] [q];
		endif 
	endfor // END of chunky behavior
	CheckError("chunks");
	
	// CP Refs are the same for the whole matrix
	if (waveexists(outSet.Z.refW) && waveexists(chunk.CXZRefW))  // Optional Col Reference wave
		variable NXRefData = dimsize(outSet.X.refW,1);
		outSet.Z.refW[][]  = chunk.CXZRefW[p] [q+NXRefData];
	endif 
	
	
	// cleanup
	if (strlen(chunk.UserSimFunc)!=0) // it was a process/simulation 
		ControlInfo /W=G3FitPanel KeepLastSimCheckBox 
		if (!V_Value)
			KillWaves  /Z  $GetWavesDataFolder(chunk.ProcW,4)
		endif
	endif
	
	if (!MinReport)
		Print "Complete in ", Secs2Time((DateTime - chunk.startTime), 5), " computation time = ", (1e-9 * chunk.cpuTime), "sec for ",chunk.stepCount," steps or ", ((1e-6 * chunk.cpuTime) / chunk.stepCount) , "msec/step";
	endif
	
	//*********************************************************************************************************************************
	// Report the results
	//********************************************************************************************************************************
		if (!(chunk.fVars.Glob.hold))	// Globals are not held
			// report local coeffs
			string CoeffStr=""
			Duplicate /O/R=(0,chunk.fVars.Glob.nVars-1) chunk.CParamW, $in3D.baseName+"_Globals"
			WAVE GlobalsW = $in3D.baseName+"_Globals"
	
			i = 0
			do
				if (i > 0) 
					CoeffStr+=", "
				endif
				CoeffStr+= Num2Str (GlobalsW[i])
				i += 1
			while (i < chunk.fVars.Glob.nVars)
			if (!MinReport)
				Printf "\rGlobal coefficients '%s'={%s}", NameOfWave(GlobalsW), CoeffStr
			else
				Printf "Global coefficients {%s}",  CoeffStr
			endif
			if (!Simulate && WaveExists(WSigma))  	// report sigma
				string SigmaStr=""
				Duplicate /O/R=(0,chunk.fVars.Glob.nVars-1) WSigma, $in3D.baseName+"_GlSigma"
				WAVE GlobalsRowSigmaW = $in3D.baseName+"_GlSigma"
				Wave/U/B  GuessListSelection=$cG3FControl+":GuessListSelection"
			
				i = 0
				do
					if (i >0 ) 
						SigmaStr+=","
					endif
	
					if (GuessListSelection[i][3] & 16)
						SigmaStr+="held"
					else
						SigmaStr+=Num2Str(GlobalsRowSigmaW[i])
					endif
					i += 1
				while (i < chunk.fVars.Glob.nVars)
	
				if (!MinReport)
					Printf "\rSigma '%s'={%s}", NameOfWave(GlobalsRowSigmaW), SigmaStr
				else
					Printf "\rSigma {%s}", SigmaStr
				endif
			endif
		endif
	
	
	// Make individual components...
	string ExtraLocNames 
	string LocalCompS;
	string RowLocName = in3D.baseName+"_RLoc_";
	string ColLocName = in3D.baseName+"_CLoc_";
	ControlInfo DelExtraLocals
	if (V_Value)
		ExtraLocNames = WaveList(RowLocName+"*", ",","") + ","+ WaveList(ColLocName+"*", ",","") // get all matching 
	endif
	
	ControlInfo SplitLocals
	if (V_Value)
	
		for ( i=0; i<chunk.fVars.Row.nVars; i+=1)
			LocalCompS = RowLocName+num2str(i)
			ExtraLocNames = RemoveFromList(LocalCompS, ExtraLocNames,",")
			Make /o/n=(chunk.fData.X.fitLines) $LocalCompS
			WAVE LocalCompW =  $LocalCompS
			LocalCompW[] = chunk.fVars.Row.ParW[p][i]
		endfor
		for ( i=0; i<chunk.fVars.Col.nVars; i+=1)
			LocalCompS = ColLocName+num2str(i)
			ExtraLocNames = RemoveFromList(LocalCompS, ExtraLocNames,",")
			Make /o/n=(chunk.cols) $LocalCompS
			WAVE LocalCompW =  $LocalCompS
			LocalCompW = chunk.fVars.Col.ParW[p][i]
		endfor
	endif
	if (strlen(ExtraLocNames))
		ExtraLocNames = RemoveEnding(ExtraLocNames, ",") 
	endif 
	
	
	// Make individual sigma waves
	ControlInfo SplitLocalsSigma
	if (V_Value)
		for ( i=0; i<chunk.fVars.Row.nVars; i+=1)
			LocalCompS = in3D.baseName+"_RLoc"+num2str(i)+"Sigma"
			Make /o/n=(chunk.fData.X.fitLines) $LocalCompS
			WAVE LocalCompW =  $LocalCompS
			LocalCompW = chunk.fVars.Row.SigmaW[p][i]//chunk.CParamW[chunk.fVars.Glob.nVars + i +(chunk.fVars.Lay.nVars*p)]
		endfor
		for ( i=0; i<chunk.fVars.Col.nVars; i+=1)
			LocalCompS = in3D.baseName+"_CLoc"+num2str(i)+"Sigma"
			Make /o/n=(chunk.cols) $LocalCompS
			WAVE LocalCompW =  $LocalCompS
			LocalCompW = chunk.fVars.Col.SigmaW[p][i]//chunk.CParamW[chunk.fVars.Glob.nVars + i +(chunk.fVars.Lay.nVars*p)]
		endfor
	endif
	
	if (!MinReport)
		printf "\r***************** End of Global Fit *********************\r"
	endif
	
	UpdateFeedback(); 
	return 1;
End


function MTXReportResults (fVars)
	struct fitVarsT &fVars
	
	NVAR V_FitError = V_FitError;
	NVAR V_FitQuitReason = V_FitQuitReason;
	NVAR V_FitNumIters = V_FitNumIters;
	NVAR V_FitMaxIters = V_FitMaxIters;
	NVAR V_FitTol = V_FitTol;

	if (V_FitError)
		if (V_FitError == 2)
			printf " caused singular matrix error :=(\r"
			abort "Singular matrix error occured"
		endif
		printf "Fit was terminated (%u): ",V_FitError
	else
		if (!(fVars.Glob.hold && fVars.Row.hold && fVars.Col.hold && fVars.Lay.hold && fVars.LayRow.hold && fVars.LayCol.hold )) 
			printf " completed sucessfuly in %u iterations", V_FitNumIters
			printf " to the limit of %g!\r", V_FitTol
		endif
	endif
//			printf "- A maximum of %u iterations was reached.\r", V_FitNumIters
//	endif
	if (V_FitQuitReason == 1)
		printf " Iteration limit of %u was reached\r", V_FitNumIters
	endif
	if (V_FitQuitReason == 2)
		printf " - Process was interrupted by user.\r"
	endif
	if (V_FitQuitReason== 3)
		printf " - A maximum of %u of %u iterations was reached without decrease in ChiSq\r", V_FitNumIters, V_FitMaxIters
	endif
end

//***********************************************************************************************
