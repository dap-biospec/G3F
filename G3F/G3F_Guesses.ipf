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
#pragma version = 20190710
#pragma IndependentModule = G3F

Function/S MtrxListPsblInitalGuessWaves()

	Wave/T/Z GuessListWave = $cG3FControl+":GuessListWave"
	NVAR NGVar = $cG3FControl+":NumGlobVars"
	NVAR NRVar = $cG3FControl+":NumRowVar"
	NVAR NCVar = $cG3FControl+":NumColVar"
	if ( (!WaveExists(GuessListWave)) || (NGVar + NRVar  + NCVar<= 0) )
		return "Data sets not initialized"
	endif
	
	Variable numpoints = DimSize(GuessListWave, 0)
	String theList = ""
	Variable i=0
	do
		Wave/Z w = WaveRefIndexed("", i, 4)
		if (!WaveExists(w))
			break
		endif
		if ( (DimSize(w, 0) == numpoints) && (WaveType(w) & 6) )		// select floating-point waves with the right number of points
			theList += NameOfWave(w)+";"
		endif
		i += 1
	while (1)
	
	if (i == 0)
		return "None Available"
	endif
	return theList
end

//*******************************************************
Function MtrxWaveToInitGuessMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Wave/T/Z GuessListWave = $cG3FControl+":GuessListWave"
	Wave/Z cWave = $popStr
	if (!WaveExists(cWave))
		DoAlert 0, "Strange- the wave "+popStr+" doesn't exist"
		return -1
	endif
	GuessListWave[][%'Guess'] = num2str(cWave[p])
	return 0
End

//*******************************************************
Function/S MtrxNewGuessWaveName() // Was NewGuessWaveName

	String theName = "G3FitCoefs"
	Prompt theName, "Enter a name for the wave:"
	DoPrompt "Save G3F Coefficients", theName
	
	return theName
end

//*******************************************************

Function MtrxInitGuessToWaveMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Wave/T/Z GuessListWave = $cG3FControl+":GuessListWave"
	if (CmpStr(popStr, "New Wave...") == 0)
		Variable npnts = DimSize(GuessListWave, 0)
		String newWaveName = MtrxNewGuessWaveName()
		if (Exists(newWaveName) == 1)
			newWaveName = UniqueName(newWaveName, 1, 0)
		endif
		Make/D/N=(npnts) $newWaveName
		Wave/Z cWave = $newWaveName
		if (!WaveExists(cWave))
			return -1
		endif
	else
		Wave/Z cWave = $popStr
		if (!WaveExists(cWave))
			DoAlert 0, "Strange- the wave "+popStr+" doesn't exist"
			return -1
		endif
	endif
	cWave = str2num(GuessListWave[p][%'Guess'])
	return 0
End

//*******************************************************
//
Function/S MtrxMakeHoldString(chunk) //nRows, nCols, nLays,
	STRUCT chunkDataT &chunk
	//variable nRows, nCols, nLays, aHoldFlags
	

	String HS = ""; //="/H=\""
	Variable nHolds=0

 	assembleHold(HS, "ConstraintsGlobal", 1,  1, nHolds, chunk.fVars.Glob, chunk.CParamW)
 	assembleHold(HS, "ConstraintsRow", chunk.rows, 1, nHolds, chunk.fVars.Row, chunk.CParamW)
 	assembleHold(HS, "ConstraintsCol", chunk.cols, 1, nHolds, chunk.fVars.Col, chunk.CParamW)
 	if (chunk.fData.L.fitLines > 0)
	 	assembleHold(HS, "ConstrLayer", chunk.fData.L.fitLines, 1, nHolds, chunk.fVars.Lay, chunk.CParamW)
	 	assembleHold(HS, "ConstrLayerRow", chunk.rows,  chunk.fData.L.fitLines, nHolds, chunk.fVars.LayRow, chunk.CParamW)
	 	assembleHold(HS, "ConstrLayerCol", chunk.cols,  chunk.fData.L.fitLines, nHolds, chunk.fVars.LayCol, chunk.CParamW)
	endif

	if (nHolds == 0)
		chunk.HoldStr = ""
	else
		chunk.HoldStr = HS;
	endif
	
end



//*******************************************************

function AdjustGuesses(LocParamW, actRows, NLVar, TotalRows )
wave LocParamW;
variable actRows;
variable NLVar
variable TotalRows // currently not used

variable i,j
variable LocalPnts

	LocalPnts = DimSize(LocParamW,0)
	if (LocalPnts!=actRows)
		variable Fr, P1
		if (LocalPnts>actRows) // number reduced
			for (i=1; i< actRows;  i+=1) // stretch data 
				Fr = (LocalPnts-1)*i/(actRows-1);
				P1 = floor(Fr);
				if (Fr==P1)
					P1 -=1;
				endif
				for (j=0; j<NLVar; j+=1)
					LocParamW[i][j] = LocParamW[P1][j]+(LocParamW[P1+1][j]-LocParamW[P1][j])*(Fr-P1)
				endfor
				// first point is always inherited
			endfor
			Redimension /D/N=(actRows, NLVar) LocParamW 
		else // number increased
			Redimension /D/N=(actRows, NLVar) LocParamW 
			for (i=actRows-1; i>0; i-=1) // stretch data 
				Fr = (LocalPnts-1)*i/(actRows-1);
				P1 = floor(Fr);
				if (Fr==P1)
					P1 -=1;
				endif
				for (j=0; j<NLVar; j+=1)
					LocParamW[i][j] = LocParamW[P1][j]+(LocParamW[P1+1][j]-LocParamW[P1][j])*(Fr-P1)
				endfor
				// first point is always inherited
			endfor
		endif
	endif
end 



//*******************************************************



// this requires revisions for STRCUT parameters 
function CalculateGuesses(LocParamW, TotalRows, NLVar, NLayers, SetGuessFunctionS, MWaveS, dimension, XWaveS, colLimWaveS )	
	wave LocParamW; 
	variable TotalRows; 
	variable NLVar;
	variable dimension;
	variable NLayers;
	string SetGuessFunctionS;
	string  MWaveS;
	string  XWaveS;
	string  colLimWaveS;
	
	Redimension /D/N=(TotalRows,NLVar, NLayers) LocParamW
	
	if ((strlen(SetGuessFunctionS) <=0 ) || (cmpstr(SetGuessFunctionS, "_none_")== 0))
		LocParamW[] = p+1
		return 0;
	endif 
	
	// What type of matrix wave is it?
	variable FromListSet;
	if (WaveType($MWaveS)==0)  // this is a text - fromListSet
		FromListSet = 1;
		if (dimension !=1) // 2DFitting is disabled in this case because each pair has its own calibration
			DoAlert 0, "Col guesses cannot be calculated for a list matrix because each pair has its own calibration"
			return -1;
		endif
		wave /T MTWave = $MWaveS;
	else // numerical wave
		FromListSet =0;
		wave MWave = $MWaveS;
	endif
	// is there a column limiting wave?
	variable useColLim;
	if (strlen(colLimWaveS) <=0 ) 
		useColLim = 0;
	else
		useColLim = 1;
		if (dimension !=1) // 2DFitting is can be done only on a rectangular matrix
			DoAlert 0, "Col guesses cannot be used if ColumnLimter is used and matrix is not rectangular"
			return -1;
		endif;
		wave colLimWaveW = $colLimWaveS;
	endif
	// has XWave parameter been passed?
	variable useXWave;
	if (strlen(XWaveS) <=0 ) 
		useXWave = 0;
	else
		useXWave = 1;
		wave XWave = $XWaveS;
	endif
	
	// What type of guess setting function is it? 		
	string FInfo = FunctionInfo("ProcGlobal#"+SetGuessFunctionS);
	variable NArgs;
	NArgs = NumberByKey("N_PARAMS", FInfo) 


	// make scratch coeff wave -  used only to call function for each row/col
	string ScrCoefS = cG3FHome+":ScratchCoeff" 
	Make /D/O/N=(DimSize(LocParamW, 1)) $ScrCoefS
	WAVE ScrCoef = $ScrCoefS

	// iterate over all points in guess weave and call setting function		
	variable i;
	string CMD
	for (i=0; i< TotalRows; i+=1) 
//			print "Setting guesses for ",NameOfWave(LocParamW), " at ",  i
		ScrCoef = LocParamW[i][p]
		
		if (FromListSet) // Matrix is a list of pairs 
			// 2DFitting is disabled in this case because each pair has its own calibration
				WAVE yWave_i = $(MTWave[i][0])
				WAVE xWave_i = $(MTWave[i][1])
			
		else
			string ScrYS = cG3FHome+":ScratchYW"
			string ScrXS = cG3FHome+":ScratchXW"
			if (useColLim)
				Make /D/O /N=(colLimWaveW[i]) $ScrYS, $ScrXS
			else
				Make /D/O /N=(DimSize(MWave, dimension)) $ScrYS, $ScrXS
			endif
			WAVE yWave_i = $ScrYS
			WAVE xWave_i = $ScrYS
			switch (dimension)
				case 0:
					yWave_i = MWave[p][i]
					break;
				case 1:
					yWave_i = MWave[i][p]
					break;
				default:
					DoAlert 0, "Guesses cannot be calculated for dimension ["+num2str(dimension)+"]";
					return -1;
			endswitch;
			// this should select type of ZWave - 1D or matrix
		endif
		CMD = 	"\""+SetGuessFunctionS+"\", "+GetWavesDataFolder(ScrCoef, 4)+", "+GetWavesDataFolder(yWave_i, 4)+", "+GetWavesDataFolder(xWave_i, 4); 		
		if (NArgs == 4) 
			if (UseXWave) 
				CMD += ", "+ num2str(XWave[i]);
			else
				CMD += ", "+ num2str(i); 
			endif
			EXECUTE "ProcGlobal#G3F_Guess2D_Proxy("+CMD+")"
		else 
			EXECUTE "ProcGlobal#G3F_Guess_Proxy("+CMD+")"
		endif
		LocParamW[i][] = ScrCoef[q]  
	endfor
end



//*******************************************************
function CopyLGuessValues (varDim, HoldWName)
	STRUCT fitVarDimT &varDim;
	string HoldWName
	
	if (strlen(HoldWName) <= 0)
		abort "Empty name provided for hold wave in CopyLGuessValues"
	endif 
	string HoldWPath = cG3FHome+":"+HoldWName;
	
	if (waveexists(varDim.ParW))
		variable NPnts = dimsize(varDim.ParW, 0);
		variable NVars = dimsize(varDim.ParW, 1);
		variable NLays = dimsize(varDim.ParW, 2);
		variable i, j, k, o;
		
		if (nLays < 1)
			nLays = 1;
		endif
		if (NVars < 1)
			NVars = 1;
		endif
		
		if (varDim.hold)
			Make /O/D/N=(NVars * NPnts * NLays) $HoldWPath 
			Wave varDim.HeldW = $HoldWPath
			for ( k = 0, o=0; k< nLays; k+= 1) 
				for (i = 0; i < NPnts; i += 1)
					for (j = 0; j < NVars; j += 1, o+=1)
						varDim.HeldW[o] = varDim.ParW[i][j][k]
					endfor
				endfor
			endfor
			varDim.linSize = 0;
		else
			Make /O/D/N=(0) $HoldWPath 
			varDim.linSize = NPnts * NVars * NLays;
		endif
	else
		Wave varDim.HeldW = $""
		varDim.linSize = 0;
	endif 
	
	varDim.linOffset = 0; // reset
	return 1;
end
