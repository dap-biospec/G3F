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


function SetInRanges (in3D, sSetID)
	STRUCT inDataT &in3D;
	string sSetID
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Check on matrix and Z-claibration waves
	SVAR MWaveS = $cG3FControl+":MatrixWave"
	if(Exists(MWaveS)!=1)
		DoAlert 0, "Select matrix wave"
		return -1
	endif
	
	in3D.baseName = MWaveS + sSetID
	
	//variable FromListSet;
	variable MatrixRows
	variable MatrixCols;
	variable MatrixLays
	if (WaveType($MWaveS)>0)
		WAVE in3D.MNWave = $MWaveS
		WAVE /T in3D.MTWave = $""
		in3D.FromListSet = 0;
		MatrixRows = DimSize(in3D.MNWave,0) 
		MatrixCols = DimSize(in3D.MNWave,1) 
		MatrixLays = DimSize(in3D.MNWave,2) 
	else
		// WAVE /T MTWave = $MWaveS
		WAVE /T in3D.MTWave = $MWaveS
		WAVE in3D.MNWave = $""
		in3D.FromListSet=1;
		MatrixRows = DimSize(in3D.MTWave,0) 
		MatrixCols = CheckNamePairs(in3D.MTWave)
		MatrixLays = 1; // Needs check! DimSize(MWave,2) 
	endif
	
	// Check and fix ranges
	if (!CheckRanges( cG3FControl+":XFrom", cG3FControl+":XTo", cG3FControl+":XThin", MatrixRows-1, "Please verify point range"))
		return -1;
	endif
	NVAR inX_From_ = $cG3FControl+":XFrom"
	NVAR inX_To_ = $cG3FControl+":XTo"
	NVAR inX_Thin_ = $cG3FControl+":XThin"
	ControlInfo  /W=G3FitPanel  AverageXChBox
	variable AverageX_ =  (V_Value && (inX_Thin_ > 1));
	in3D.X.from = inX_From_;
	in3D.X.to = inX_To_;
	in3D.X.thin = inX_Thin_;
	in3D.X.ave = AverageX_;
	in3D.X.mtxLines = MatrixRows



	if (!CheckRanges( cG3FControl+":ZFrom", cG3FControl+":ZTo",  cG3FControl+":ZThin", MatrixCols-1, "Please verify rows range"))
		return -1;
	endif
	NVAR inZ_From_ = $cG3FControl+":ZFrom"
	NVAR inZ_To_ = $cG3FControl+":ZTo"
	NVAR inZ_Thin_ = $cG3FControl+":ZThin"
	ControlInfo  /W=G3FitPanel  AverageZChBox
	variable AverageZ_ = (V_Value && (inZ_Thin_ > 1))
	in3D.Z.from = inZ_From_;
	in3D.Z.to = inZ_To_;
	in3D.Z.thin = inZ_Thin_;
	in3D.Z.ave = AverageZ_;
	in3D.Z.mtxLines = MatrixCols


	if (!CheckRanges( cG3FControl+":LFrom", cG3FControl+":LTo", cG3FControl+":LThin", MatrixRows-1, "Please verify layers range"))
		return -1;
	endif
	NVAR inL_From_ = $cG3FControl+":LFrom"
	NVAR inL_To_ = $cG3FControl+":LTo"
	NVAR inL_Thin_ = $cG3FControl+":LThin"
	//ControlInfo  /W=G3FitPanel  AverageLChBox
	variable AverageL_ =  (V_Value && (inL_Thin_ > 1));
	
	in3D.L.from = inL_From_;
	in3D.L.to = inL_To_;
	in3D.L.thin = inL_Thin_;
	in3D.L.ave = AverageL_;	
	in3D.L.mtxLines = MatrixLays

	return 0
end


//**************************************** Layers ****************************************
//
function prepLInput(in3D, fitData, outSet, MinReport)
	STRUCT inDataT &in3D;
	STRUCT fitDataT &fitData;
	STRUCT outDataT &outSet;
	variable MinReport

	if (in3D.L.MtxLines < 1)
		WAVE in3D.L.maskW = $""
		WAVE in3D.L.clbW = $""		
		WAVE fitData.L.fitClbW = $""
		fitData.L.fitLines = 0;
		return 0;
	endif 

	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Optional Layer mask wave
	
	SVAR LMaskS = $cG3FControl+":LMask"
	variable useLMask = 0;
	
	if (cmpstr(LMaskS, "_none_") == 0 || strlen(LMaskS)==0)
		if (!MinReport)
			print "not using L mask"
		endif
		WAVE in3D.L.maskW = $""
	else
		if(Exists(LMaskS)!=1)
			DoAlert 0, "L mask ["+LMaskS+"]not found"
			return -1
		endif
		WAVE in3D.L.maskW = $LMaskS
		if (in3D.L.mtxLines != DimSize(in3D.L.maskW,0))
			DoAlert 0, "Mismatch in dimension of matrix layers ("+Num2Str(in3D.L.mtxLines)+") and mask ("+Num2Str(DimSize(in3D.L.maskW,0))+") waves"
			return -1
		endif
		useLMask = 1;
	endif
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Prepare Layer calibration
		SVAR LWaveFitS = $cG3FControl+":LWaveFit" 	//fitData.LWave wave must exist and its name in LWaveFitS variable
		LWaveFitS = in3D.baseName + "_LAY_FIT"
		WAVE fitData.L.fitClbW = $LWaveFitS 
		if (Exists(LWaveFitS)==1) // clb exists
			if (DimSize($LWaveFitS, 0) != in3D.L.mtxLines) // different number of layers - make a new one
				Make /O/N=(in3D.L.mtxLines, 6) $LWaveFitS
				fitData.L.fitClbW[][2]=0; // reset display....
	//			UpdateProfileOverlay = 0;
			else // old dimension ... just keep it....
			endif
		else // WaveX does not exist...
			MAKE /N=(in3D.L.mtxLines, 6) $LWaveFitS
			WAVE fitData.L.fitClbW = $LWaveFitS
			fitData.L.fitClbW[][2]=0; // reset display....
	//		UpdateProfileOverlay = 0;
		endif
		
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Optional Layer calibration wave
	
	SVAR LWaveS = $cG3FControl+":LWave"
	variable useLWave;
	
	if (cmpstr(LWaveS, "_none_") == 0 || strlen(LWaveS)==0)
		if (!MinReport)
			print "not using L calibration"
		endif
		useLWave = 0;
		WAVE  in3D.L.clbW = $""
	else
		useLWave = 1;
		if(Exists(LWaveS)!=1)
			DoAlert 0, "L calibration wave ["+LWaveS+"]not found"
			return -1
		endif
		WAVE in3D.L.clbW = $LWaveS
		
		if (in3D.L.mtxLines != DimSize(in3D.L.clbW,0))
			DoAlert 0, "Mismatch in dimension of matrix layers ("+Num2Str(in3D.L.mtxLines)+") and spectral calibration ("+Num2Str(DimSize(in3D.L.clbW,0))+") waves"
			return -1
		endif
	endif
	
	fitData.L.fitLines = AssembleClbFromMatrix(in3D.L,fitData.L.fitClbW);

	return 0
end

//**************************************** Columns ****************************************
//
function prepZInput(in3D, fitData, outSet, MinReport)
	STRUCT inDataT &in3D;
	STRUCT fitDataT &fitData;
	STRUCT outDataT &outSet;
	variable MinReport

	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Optional Col mask wave
	
	SVAR ZMaskS = $cG3FControl+":ZMask"
	
	if (cmpstr(ZMaskS, "_none_") == 0 || strlen(ZMaskS)==0)
		if (!MinReport)
			print "not using Z mask"
		endif
		WAVE in3D.Z.maskW = $""
	else
		if(Exists(ZMaskS)!=1)
			DoAlert 0, "Z mask ["+ZMaskS+"]not found"
			return -1
		endif
		WAVE in3D.Z.maskW = $ZMaskS	
		if (in3D.X.mtxLines != DimSize(in3D.Z.maskW,0))
			DoAlert 0, "Mismatch in dimension of matrix columns ("+Num2Str(in3D.L.mtxLines)+") and mask ("+Num2Str(DimSize(in3D.Z.maskW,0))+") waves"
			return -1
		endif
	endif
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Prepare Temporal calibration 
	if (in3D.FromListSet) // We do not need ZWave here, but What about ZWaveFit?
		//Need to ZWaveFIt with optional matrix for point-by-point calibration
		WAVE fitData.Z.fitClbW = CWave // this is input ClbWave!
	
	else // need ZWave
		SVAR ZWaveS = $cG3FControl+":ZWave" // Used in feedback also
		if(Exists(ZWaveS)!=1)
			DoAlert 0, "Select temporal calibration wave"
			return -1
		endif
		WAVE in3D.Z.clbW = $ZWaveS
		WAVE ZWave = $ZWaveS
		if ( DimSize(ZWave,1)>1) // ZWave is a matrix!
			if (in3D.X.mtxLines != DimSize(ZWave,0) || (in3D.Z.mtxLines!= DimSize(ZWave,1) && (in3D.L.mtxLines > 1 && ((in3D.Z.mtxLines*in3D.L.mtxLines)!= DimSize(ZWave,1)))))
				DoAlert 0, "Mismatch in dimensions of matrix and temporal calibration waves"
				return -1
			endif
		else // ZWave is a simple wave, its rows must match columns in matrix
			if (in3D.Z.mtxLines!= DimSize(ZWave,0) && (in3D.L.mtxLines > 1 && ((in3D.Z.mtxLines*in3D.L.mtxLines)!= DimSize(ZWave,0))))
				DoAlert 0, "Mismatch in dimensions of matrix and temporal calibration waves"
				return -1
			endif
		endif
		SVAR ZWaveFitS = $cG3FControl+":ZWaveFit"
		ZWaveFitS = GetWavesDataFolder(ZWave, 4) +"_FIT" // NameOfWave(ZWave) 
		if (Exists(ZWaveFitS)==1) // wave is there already
			WAVE fitData.Z.fitClbW = $ZWaveFitS 
			if (DimSize($ZWaveFitS, 1) != fitData.Z.fitLines) //  different number of points - make a new one
				Make /O/N=(fitData.Z.fitLines, 3) $ZWaveFitS
				fitData.Z.fitClbW[][2] = 0; // reset display register.... 
			else // good number of points - keep it
			endif
		else // does not exist...
			MAKE /N=(fitData.Z.fitLines, 3) $ZWaveFitS
			WAVE fitData.Z.fitClbW = $ZWaveFitS 
	
			fitData.Z.fitClbW[][2]=0;
		endif
	endif
	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~ Assemble Clb
	fitData.Z.fitLines = AssembleClbFromMatrix(in3D.Z,fitData.Z.fitClbW);

	return 0
end


//**************************************** Rows ****************************************
//
function prepXInput(in3D, fitData, outSet, MinReport)
	STRUCT inDataT &in3D;
	STRUCT fitDataT &fitData;
	STRUCT outDataT &outSet;
	variable MinReport

	fitData.X.fitLines = trunc((in3D.X.to - in3D.X.from + 1) / in3D.X.thin); // until reduced due to mask
	

	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Optional Row mask wave
	
	SVAR XMaskS = $cG3FControl+":XMask"
	variable useXMask = 0;
	
	if (cmpstr(XMaskS, "_none_") == 0 || strlen(XMaskS)==0)
		if (!MinReport)
			print "not using X mask"
		endif
		WAVE in3D.X.maskW = $""
	else
		if(Exists(XMaskS)!=1)
			DoAlert 0, "X masl ["+XMaskS+"]not found"
			return -1
		endif
		WAVE in3D.X.maskW = $XMaskS
		if (in3D.X.mtxLines != DimSize(in3D.X.maskW,0))
			DoAlert 0, "Mismatch in dimension of matrix rows ("+Num2Str(in3D.L.mtxLines)+") and mask ("+Num2Str(DimSize(in3D.X.maskW,0))+") waves"
			return -1
		endif
		useXMask = 1;
	endif
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Prepare Spectral calibration
		SVAR XWaveFitS = $cG3FControl+":XWaveFit"
		//fitData.XWave wave must exist and its name in XWaveFitS variable
		XWaveFitS = in3D.baseName + "_ROW_FIT"
		WAVE fitData.X.fitClbW = $XWaveFitS 
		if (Exists(XWaveFitS)==1) // clb exists
			if (DimSize($XWaveFitS, 0) != fitData.X.fitLines) // different number of points - make a new one
				Make /O/N=(fitData.X.fitLines, 6) $XWaveFitS
				fitData.X.fitClbW[][2]=0; // reset display....
			else // old dimension ... just keep it....
			endif
		else // WaveX does not exist...
			MAKE /N=(fitData.X.fitLines, 6) $XWaveFitS
			WAVE fitData.X.fitClbW = $XWaveFitS
			fitData.X.fitClbW[][2]=0; // reset display....
		endif
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Optional Row calibration wave
	
	SVAR XWaveS = $cG3FControl+":XWave"
	variable useXWave;
	
	if (cmpstr(XWaveS, "_none_") == 0 || strlen(XWaveS)==0)
		if (!MinReport)
			print "not using X calibration"
		endif
		useXWave = 0;
		WAVE in3D.X.clbW = $""
	else
		useXWave = 1;
		if(Exists(XWaveS)!=1)
			DoAlert 0, "X calibration wave ["+XWaveS+"]not found"
			return -1
		endif
		WAVE in3D.X.clbW = $XWaveS
		if (in3D.X.mtxLines != DimSize(in3D.X.clbW,0))
			DoAlert 0, "Mismatch in dimension of matrix ("+Num2Str(in3D.X.mtxLines)+") and spectral calibration ("+Num2Str(DimSize(in3D.X.clbW,0))+") waves"
			return -1
		endif
	endif
	
	
	fitData.X.fitLines = AssembleClbFromMatrix(in3D.X,fitData.X.fitClbW); //fitData.X.fitLines
	return 0
end



//**************************************** Optional Data Reference waves ****************************************
//
function prepRefInput(in3D, fitData, outSet, MinReport)
	STRUCT inDataT &in3D;
	STRUCT fitDataT &fitData;
	STRUCT outDataT &outSet;
	variable MinReport

	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Optional Col Reference wave
		variable NZRefData = 0;
		SVAR ZRefWS = $cG3FControl+":ZRefWave"
		if (cmpstr(ZRefWS, "_none_") != 0 && strlen(ZRefWS)!=0)
			if(Exists(ZRefWS)!=1)
				DoAlert 0, "Z reference wave not found"
				return -1
			endif
			if (in3D.Z.mtxLines != DimSize($ZRefWS,0))
				DoAlert 0, "Mismatch in dimension of matrix ("+Num2Str(in3D.Z.mtxLines)+") and COL reference ("+Num2Str(DimSize($ZRefWS,0))+") waves"
				return -1
			endif
			NZRefData =  DimSize($ZRefWS, 1);
			if (NZRefData == 0) // Ref is a 1D wave, reported as having 0 columns
				NZRefData += 1; 
			endif 
			WAVE in3D.Z.refW = $ZRefWS
			string ZRefFitS = in3D.baseName+"_CRef_Fit";
			make /O /N=(fitData.Z.fitLines,  NZRefData) $ZRefFitS
			WAVE 	in3D.Z.refW = $ZRefFitS //ZRefFitW
		else
			WAVE in3D.Z.refW = $""
		endif
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Optional Row Reference wave
		variable NXRefData = 0;
		SVAR XRefWS = $cG3FControl+":XRefWave"
		variable useXRefW;
		if (cmpstr(XRefWS, "_none_") != 0 && strlen(XRefWS)!=0)
			if(Exists(XRefWS)!=1)
				DoAlert 0, "X reference wave not found"
				return -1
			endif
			if (in3D.X.mtxLines != DimSize($XRefWS,0))
				DoAlert 0, "Mismatch in dimension of matrix ("+Num2Str(in3D.X.mtxLines)+") and row reference ("+Num2Str(DimSize($XRefWS,0))+") waves"
				return -1
			endif
			NXRefData =  DimSize($XRefWS, 1);
			if (NXRefData == 0) // Ref is a 1D wave, reported as having 0 columns
				NXRefData += 1; 
			endif 
			WAVE in3D.X.refW = $XRefWS
			string XRefFitS =  in3D.baseName+"_RRef_Fit";
			make /O /N=(fitData.X.fitLines,  NXRefData) $XRefFitS
			WAVE in3D.X.refW = $XRefFitS //XRefFitW
		else
			WAVE in3D.X.refW = $""
		endif
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Optional Column Reference wave - NOT IMPLEMENTED
	WAVE in3D.Z.refW = $""

	return 0
end

//**************************************** Dataset ****************************************
//
function prepDataInput(in3D, fitData, outSet, MinReport)
	STRUCT inDataT &in3D;
	STRUCT fitDataT &fitData;
	STRUCT outDataT &outSet;
	variable MinReport

	//*******************************************************
	// prepare residual wave for output
	string sResidual = in3D.baseName+"_Residual" 
	Make /D/O/N=(fitData.X.fitLines, fitData.Z.fitLines, fitData.L.fitLines) $sResidual // for the output
	WAVE outSet.oResW = $sResidual
	
	
	//*******************************************************
	// prepare destination wave for output
	//
	SVAR MWaveFitS = $cG3FControl+":MatrixWaveFit" // for the output 
	MWaveFitS = in3D.baseName + "_Fit"; 
	Make /D/O/N=(fitData.X.fitLines, fitData.Z.fitLines, fitData.L.fitLines) $MWaveFitS
	WAVE outSet.oFitW = $MWaveFitS

	variable actLayers = (fitData.L.fitLines > 0) ? fitData.L.fitLines : 1; // in case there are 0 layers
	// Prepare chunks
	NVAR NChunkSize = $cG3FControl+":LocalOnlyChunks"
	if (fitData.HoldOverride == 5) // fitting rows only...
		if (NChunkSize <1)
			fitData.NumChunks  = 1
		else
			fitData.NumChunks =  round (fitData.X.fitLines / NChunkSize)
		endif
		fitData.ChunkSize = round ((fitData.X.fitLines * actLayers) / fitData.NumChunks)
	else
		fitData.NumChunks = 0
		fitData.ChunkSize = fitData.X.fitLines * actLayers
	endif
	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~ optional Column limiter wave
	SVAR ColLimWaveName = $cG3FControl+":ColLimWaveName" // string contaning name of column limit wave
	variable  useColLim;  
	wave in3D.colLimWaveW = $"";	
	if (in3D.FromListSet || (strlen(ColLimWaveName) <=0) || (cmpstr(ColLimWaveName, "_none_") == 0) )
		useColLim = 0;
	else
		if (!exists (ColLimWaveName) == 1) 
			DoAlert 0, "Specified column limiting wave ("+ColLimWaveName+") "
			return -1
		endif
		useColLim = 1;
		wave in3D.colLimWaveW = $ColLimWaveName;
		if (dimsize(in3D.colLimWaveW, 0) != fitData.X.fitLines)
			DoAlert 0, "Mismatch in X dimension of matrix ("+Num2Str(fitData.X.fitLines)+") and column limiting ("+Num2Str(DimSize(in3D.colLimWaveW,0))+") waves"
			return -1
		endif 
		if (!MinReport)
			Print "Column range limited per ["+ColLimWaveName+"]"	
		endif
	endif
	
	// ColLimWave is always made
	string ColNumWaveS = cG3FHome+":ColNum"
	Make /O/N=(fitData.X.fitLines) $ColNumWaveS
	wave ColNumWave = $ColNumWaveS
	WAVE fitData.ColNumWave = ColNumWave
	
	// Original thinned wave
	Make /D/O/N=(fitData.X.fitLines, fitData.Z.fitLines, fitData.L.fitLines) $in3D.baseName+"_ThinRng" // for the output
	WAVE fitData.fThinW = $in3D.baseName+"_ThinRng"
	WAVE outSet.oThinW = fitData.fThinW
	
	
	
	//~~~~~~~~~~~~~~~~~ assemble data
	if (in3D.FromListSet) // We do not need ZWave here, but What about fitData.ZWave?
		AssembleDataFromList(in3D, fitData);
	else // need ZWave
		AssembleDataFromMatrix(in3D, fitData);
	endif

	return 0
end


//**************************************** Dataset ****************************************
//
function prepFitChunk(in3D, fitData, outSet, chunk, MinReport)
	STRUCT inDataT &in3D;
	STRUCT fitDataT &fitData;
	STRUCT outDataT &outSet;
	STRUCT chunkDataT &chunk;
	variable MinReport
	
	// names of chunk data waves
	string LinWaveS = cG3FHome+":ChunkLinW"
	string ResWaveS =  cG3FHome+":ChunkResW"
	string DestWaveS =  cG3FHome+":ChunkDestW"
	string ClbWaveS = cG3FHome+":ChunkClbW"
	string CParamWaveS = cG3FHome+":ChunkCoeffW";
	string XZRefWaveS = cG3FHome+":ChunkXZRefW"

	Make /D/O/N=(fitData.ChunkSize * fitData.Z.fitLines) $LinWaveS, $ResWaveS, $DestWaveS

	WAVE chunk.CLinW = $LinWaveS
	WAVE chunk.CDestW = $DestWaveS // simulated wave
	

	ControlInfo DoResidualCheck
	if (V_value) 
		Make /D/O/N=(fitData.ChunkSize * fitData.Z.fitLines) $ResWaveS
		WAVE chunk.CResW = $ResWaveS;
	else
		killwaves /Z $ResWaveS
		WAVE chunk.CResW = $"";
	endif


	Make /D/O/N=(fitData.ChunkSize * fitData.Z.fitLines, 3) $ClbWaveS
	WAVE chunk.CClbW = $ClbWaveS

	
	variable NXRefData = 0
	if (waveexists(in3D.X.refW))
		NXRefData = dimSize(in3D.X.refW, 1)
	endif 
	variable NZRefData = 0
	if (waveexists(in3D.Z.refW))
		NZRefData = dimSize(in3D.Z.refW, 1)
	endif 
	
	if ((NXRefData + NZRefData)> 0)
		Make /D/O/N=(fitData.ChunkSize * fitData.Z.fitLines, NXRefData + NZRefData) $XZRefWaveS
	else
		killwaves /Z $XZRefWaveS
	endif 
	
	WAVE chunk.CXZRefW = $XZRefWaveS	
	
	Make /O/D/N=(0) $CParamWaveS;
	WAVE chunk.CParamW= $CParamWaveS;	

	return 0
end


//**************************************** Simulation, Fitting and corretion functions ****************************************
//
function prepFitFunctions(in3D, chunk, MinReport)
	STRUCT inDataT &in3D;
	STRUCT chunkDataT &chunk;
	variable MinReport
	
	// Check for simulation function and prepare simulation wave, if necessary
	SVAR UserSimFunc_=$cG3FControl+":SimFunction"
	chunk.UserSimFunc = UserSimFunc_
	string LastGlobWN = cG3FHome+":LastGlobs"
	if (strlen(chunk.UserSimFunc)==0 ) // this is a direct fit
		wave chunk.ProcLastGlobals = $"" 
		if (waveexists($LastGlobWN))
			killwaves /Z $LastGlobWN
		endif 
		if (waveexists(chunk.ProcW))
			killwaves /Z $GetWavesDataFolder(chunk.ProcW,4)
		endif
		wave chunk.ProcW = $"" 
	else // this is a sim/process fit 
		NVAR NSVar_ = $cG3FControl+":NumSimVar" 
		string ProcWN_ = in3D.baseName+"_sim" 		 
		make /O /N=(chunk.fData.Z.fitLines, NSVar_) $ProcWN_
		wave chunk.ProcW = $ProcWN_ 
		// is this Process that can be caclulated or has to be simulated?
		// NVAR ProcMT = $cG3FControl+":ProcessMT"
//		ControlInfo MTProcessCheckBox
//		if (V_disable)
//			chunk.ProcMT = -1;
//		else
//			chunk.ProcMT = V_value;
//		endif
		ControlInfo ReuseProcessCheckBox
		if (V_disable)
			chunk.ProcessReuse = -1;
			wave chunk.ProcLastGlobals = $"" 
			killwaves /Z $LastGlobWN
		else
			chunk.ProcessReuse = V_value;
			make /O/D /N=(chunk.fVars.Glob.nVars) $LastGlobWN 
			wave chunk.ProcLastGlobals = $LastGlobWN
			chunk.ProcLastGlobals[] = NAN;
		endif
	endif		

	//~~~~~~~~~~~~~~~~~~~~ 
	// Check for and prepare fit function
	SVAR UserFitFunc_=$cG3FControl+":FitFunction"
	chunk.UserFitFunc = UserFitFunc_
	if (strlen(chunk.UserSimFunc)==0 && strlen(chunk.UserFitFunc)==0)
		Doalert 0, "No fit or sim funcitons selected. There is nothign to be done!"
		return -1
	endif
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Prepare special variables which will control the fit
	NVAR G_FitTol = $cG3FHome+":V_FitTol"
	NVAR G_FitMaxIters = $cG3FHome+":V_FitMaxIters"
	variable /G V_FitNumIters=0
	variable /G V_FitTol = G_FitTol
	variable /G V_FitMaxIters = G_FitMaxIters
	NVAR V_FitTol = V_FitTol 
	NVAR V_FitMaxIters = V_FitMaxIters 
	NVAR V_FitNumIters = V_FitNumIters 

	NVAR useThreads_ = $cG3FControl+":useThreads"
	chunk.useThreads = useThreads_;
	NVAR ProcMT_ = $cG3FControl+":ProcessMT"
	chunk.ProcMT = ProcMT_;
	NVAR ProcessResue_ = $cG3FControl+":ProcessReuse"	
	chunk.ProcessReuse = ProcessResue_
	
	//~~~~~~~~~~~~~~~~~~~~ 
	// Check for correction function
	SVAR UserCorrFunc_=$cG3FControl+":CorrFunction"
	chunk.UserCorrFunc = UserCorrFunc_	
	NVAR CorrNoSim_=$cG3FControl+":CorrNoSim"
	chunk.CorrNoSim = CorrNoSim_


	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// report fit parameters
	if (!MinReport)
		Printf "2D Global fit of '%s' " , in3D.basename 
		if (strlen(chunk.UserSimFunc)>0)
			Printf "using process '%s' and local '%s' functions", chunk.UserSimFunc, chunk.UserFitFunc
		else
			Printf "to function  '%s' ", chunk.UserFitFunc
		endif 
		printf " to the limit of %g\r", V_FitTol 
	endif

end 

//**************************************** Dataset ****************************************
//
function /T copyGuesses(in3D, fitData, var, chunk, aHoldOverride, MinReport)
	STRUCT inDataT &in3D;
	STRUCT fitDataT &fitData;
	STRUCT fitVarsT &var;
	STRUCT chunkDataT &chunk;
	variable aHoldOverride
	variable MinReport

	variable i
	//*********************************************************************************
	// Hold override
	variable fromList = in3D.FromListSet  || waveexists(in3D.colLimWaveW)
	if (aHoldOverride) // use overriden parameters
		var.Glob.hold = aHoldOverride & 0x1;
		var.Row.hold = aHoldOverride & 0x2;
		var.Col.hold = (aHoldOverride & 0x4) && !fromList;
		var.Lay.hold = (aHoldOverride & 0x8) && !fromList;
		var.LayRow.hold = (aHoldOverride & 0x10) && !fromList;
		var.LayCol.hold = (aHoldOverride & 0x20) && !fromList;
		
	else // read settings in User interface
		ControlInfo /W=G3FitPanel HoldGlobCheck
		var.Glob.hold = V_value;

		ControlInfo /W=G3FitPanel HoldRowCheck
		var.Row.hold = V_value;

		// cannot do COL and all LAYXXX locals on a non-rectangular matrix 
		ControlInfo /W=G3FitPanel HoldColCheck
		var.Col.hold = V_value && !fromList; 

		ControlInfo /W=G3FitPanel HoldLayCheck
		var.Lay.hold = V_value && !fromList; 
			
		ControlInfo /W=G3FitPanel HoldLayRowCheck
		var.LayRow.hold = V_value && !fromList; 

		ControlInfo /W=G3FitPanel HoldLayColCheck
		var.LayCol.hold = V_value && !fromList; 
	endif


	CopyLGuessValues (var.Glob, "HeldGlobCoeff");
	CheckError("Setup Glob guesses");

	if (!MinReport)
		string GlobReport;
		if (var.Glob.hold)
			GlobReport  = "Global prameters held at {"
			for (i=0; i< var.Glob.nVars; i+=1)
				GlobReport += num2str(var.Glob.HeldW[i])
				if (i<var.Glob.nVars-1)
					GlobReport +=  ", "
				endif
			endfor
			GlobReport+= "}; "
		else
			GlobReport  = "Initial global prameters are {"
			for (i=0; i< var.Glob.nVars; i+=1)
				GlobReport += num2str(var.Glob.ParW[i])
				if (i<var.Glob.nVars-1)
					GlobReport +=  ", "
				endif
			endfor
			GlobReport+= "};"
		endif
		printf "%s" GlobReport
	endif
	
	CheckError("Setup global guesses");
	
	
	// Row guessess 
	CopyLGuessValues (var.Row, "HeldRowCoeff");
	CheckError("Setup Row guesses");
	
	// Col guessess 
	CopyLGuessValues (var.Col, "HeldColCoeff");
	CheckError("Setup Col guesses");

	// Lay guessess 
	CopyLGuessValues (var.Lay, "HeldLayCoeff");
	CheckError("Setup Lay guesses");

	// LayRow guessess 
	CopyLGuessValues (var.LayRow, "HeldLayRowCoeff");
	CheckError("Setup LayRow guesses");

	// LayCol guessess 
	CopyLGuessValues (var.LayCol, "HeldLayColCoeff");
	CheckError("Setup LayCol guesses");

	string LocReport  = "";
	if ((var.Row.hold))  
		LocReport += "Row ";
	endif;
	if ((var.Col.hold))  
		if (strlen(LocReport))
			LocReport += "and "
		endif
		LocReport += "Col ";
	endif;
	if ((var.Lay.hold))  
		LocReport += "Lay ";
		if (strlen(LocReport))
			LocReport += "and "
		endif
	endif;
	if ((var.LayRow.hold))  
		if (strlen(LocReport))
			LocReport += "and "
		endif
		LocReport += "LayRow ";
	endif;
	if ((var.LayCol.hold))  
		if (strlen(LocReport))
			LocReport += "and "
		endif
		LocReport += "LayCol ";
	endif;

	if (!MinReport && strlen(LocReport)) 
		printf "%sLocals are held", LocReport 
	endif
end

//**************************************** Simulation, Fitting and corretion functions ****************************************
//
function prepLogging(chunk)
	STRUCT chunkDataT &chunk;

	
	ControlInfo /W=G3FitPanel LogCheckBox
	if (V_value)
		NVAR VFitOptions = V_FitOptions
		VFitOptions = VFitOptions | 8
		chunk.logCount = 0;
		string logName = cG3FHome+":fitLog"
		make /O /N=(0,0) $logName
		wave chunk.logW = $logName
		chunk.logSize = 0
	else
		chunk.logCount = -1;
	endif
end 


//-------------------------------------------------------------
//
function simulateChunk(chunk)
		STRUCT chunkDataT &chunk

		WAVE chunk.pw = chunk.CParamW;
		WAVE chunk.yw = chunk.CDestW;
		WAVE chunk.xw = chunk.CClbW;
		
		string simcmd
		if (StrLen(chunk.UserSimFunc)==0)
			 G3FitFunc_2D_Struct(chunk);
			 simcmd = "G3F#G3FitFunc_2D_Struct";
		else
			 G2SimFunc_2D_Struct(chunk);
			 simcmd = "G3F#G2SimFunc_2D_Struct";
		endif 
		printf "Calculating >>"+simcmd+ "( "+nameofwave(chunk.CParamW)+", "+nameofwave(chunk.CDestW)+", ... )<<\r"

		Variable err = GetRTError(0)
		switch (err) 
			case 0: 
				break;
			case 145: 
				Printf "-!- Out-of-range error occured in %s! Check parameter offset and/or index for possible overrun. -!-\r",chunk.UserFitFunc 
				break;
			default:
				String message = GetErrMessage(err, 3)
				Printf "-!- Error %d in function %s: %s -!-\r", err, chunk.UserFitFunc, message
		endswitch 
		err = GetRTError(1)	
		if (waveexists(chunk.CResW))
			chunk.CResW = chunk.CLinW - chunk.CDestW;
		endif
		chunk.V_ChiSq = NaN
		chunk.V_npnts = 0
end

//-------------------------------------------------------------
//
function fitChunk(chunk, ChunkNo) 
		STRUCT chunkDataT &chunk
		variable ChunkNo

		
		if (StrLen(chunk.UserSimFunc)==0)
			FuncFit /C/Q/N/H=chunk.HoldStr G3FitFunc_2D_Struct, chunk.CParamW, chunk.CLinW /STRC=chunk /R=chunk.CResW /D=chunk.CDestW /E=chunk.CEpsW /C=chunk.CConstrW /NWOK
		else
			FuncFit /C/Q/N/H=chunk.HoldStr G2SimFunc_2D_Struct, chunk.CParamW, chunk.CLinW /STRC=chunk /R=chunk.CResW /D=chunk.CDestW /E=chunk.CEpsW /C=chunk.CConstrW /NWOK 
		endif 
		if (ChunkNo==1)
			string FullCommand = "FuncFit /Q/N " 
			if (strlen(chunk.HoldStr)>0)
				print "Holding =[", chunk.HoldStr, "]"
				FullCommand += "/H=\".. above..\" ";
			endif
			if (StrLen(chunk.UserSimFunc)==0)
				FullCommand += "G3F#G3FitFunc_2D_Struct";
			else
				FullCommand += "G3F#G2SimFunc_2D_Struct";
			endif

			FullCommand += ", "+nameofwave(chunk.CParamW)+", "+nameofwave(chunk.CLinW)+" /X="+nameofwave(chunk.CClbW)+" /R="+nameofwave(chunk.CResW);
			FullCommand += " /D="+nameofwave(chunk.CDestW)+ " /C="+ nameofwave(chunk.CConstrW) + " /E="+  nameofwave(chunk.CEpsW); 
			print ">>", FullCommand, "<<"
		endif
	chunk.V_ChiSq = V_ChiSq
	chunk.V_npnts = V_npnts
end


//-------------------------------------------------------------
//

function makedThinnedDim(in3D, outDim, aFitW, ctrlNameS, waveSuffixS)
	STRUCT inDataT &in3D
	STRUCT outDim &outDim
	string ctrlNameS, waveSuffixS
	WAVE aFitW 

	ControlInfo /W=G3FitPanel $ctrlNameS
	string sThinnedClbW = in3D.baseName+waveSuffixS
	if (V_value) 
		if (waveexists($sThinnedClbW))
			redimension /n=(dimsize(aFitW,0)) $sThinnedClbW
		else
			make /n=(dimsize(aFitW,0)) $sThinnedClbW
		endif
		WAVE outDim.clbW = $sThinnedClbW
		outDim.clbW = aFitW[p][0]
		
	else
		killwaves /z $sThinnedClbW
	endif		
	
end


//******************************************************************
//
function CheckError(source)
	string source
	variable err = GetRTError(0)
	string msg;
	switch (err) 
		case 0: 
			return 0;
		case 145:
			sPrintf msg, "-!- Out-of-range error occured in %s! Check parameter offset and/or index for possible overrun. -!-\r",source //, GetErrMessage(err, 3) //GetRTErrMessage()\
			break;
		default:
			sPrintf msg, "-!- Error %d in %s: %s -!-\r", err, source, GetErrMessage(err, 3)
	endswitch 

	if (err)
		err = GetRTError(1)	
		print ""+msg
		Abort msg
	endif
	return err;
end

//***********************************************************************************************
//
Function G3FitFunc_2D_Struct(s)
	STRUCT chunkDataT &s;

	variable timerID = startMSTimer
	
	// Log fit params
	if (s.logCount >= 0)
		if (s.logCount >= s.logSize)
			s.logSize += 10;
			redimension /N =(dimsize(s.pw, 0), s.logSize) s.logW
		endif
		s.logW[][s.logCount] = s.pw[p]
		s.logCount += 1
	endif

	string AddtlDataStr  = "\"";
	if (waveexists(s.AddtlDataW))
		AddtlDataStr  +=GetWavesDataFolder(s.AddtlDataW,4);
	endif 
	AddtlDataStr +="\", \"";
	if (waveexists(s.CXZRefW))
		AddtlDataStr +=GetWavesDataFolder(s.CXZRefW,4)
	endif 
	AddtlDataStr +="\" ";
	string DbgStr  =""+num2str(s.DbgKeep)+", "+num2str(s.DbgSave)+" ";


	string preCmd, numCMD, strCMD, fitCMD, corrCMD

	preCMD= "ProcGlobal#G3F_Direct_MT_Proxy("
	
	fitCMD =  " \""+s.UserFitFunc+"\", "+num2str(s.mainOptions)+", "
	corrCMD = " \""+s.UserCorrFunc+"\", "+num2str(s.corrOptions)+", "

	numCMD = num2str(s.useThreads)+", "
	numCMD += num2str(s.rows)+", "
	numCMD += num2str(s.fData.X.fitLines)+", "
	numCMD += num2str(s.fData.Z.fitLines)+", "
	numCMD += num2str(s.fData.L.fitLines)+", "
	numCMD += num2str(s.fVars.Row.linOffset)+",  "//RowWaveOffset
	numCMD += num2str(s.fVars.Col.linOffset)+",  " //ColWaveOffset
	numCMD += num2str(s.fVars.Lay.linOffset)+",  " //LayWaveOffset
	numCMD += num2str(s.fVars.LayRow.linOffset)+",  " //LayRowWaveOffset
	numCMD += num2str(s.fVars.LayCol.linOffset)+",  " //LayColWaveOffset
	numCMD += num2str(s.fVars.Row.nVars)+",  "
	numCMD += num2str(s.fVars.Col.nVars)+",  "
	numCMD += num2str(s.fVars.Lay.nVars)+",  "
	numCMD += num2str(s.fVars.LayRow.nVars)+",  "
	numCMD += num2str(s.fVars.LayCol.nVars)+",  "
	
	strCMD = GetWavesDataFolder(s.fData.ColNumWave,4)+", "
	strCMD += GetWavesDataFolder(s.yw, 4)+", "
//		strCMD += GetWavesDataFolder(s.CClbW, 4)+", "  // not s.xw
	strCMD += GetWavesDataFolder(s.fData.X.fitClbW, 4)+", "  // not s.xw
	strCMD += GetWavesDataFolder(s.fData.Z.fitClbW, 4)+", " //s.inzw
	if (waveexists(s.fData.L.fitClbW))
		strCMD += GetWavesDataFolder(s.fData.L.fitClbW, 4)+", " //s.inlw
	else
		strCMD +="$\"\", "
	endif
	strCMD += GetWavesDataFolder(s.fVars.Glob.linW, 4)+", " //GlobParWName
	strCMD += GetWavesDataFolder(s.fVars.Row.linW, 4)+", " //RowParWName
	strCMD += GetWavesDataFolder(s.fVars.Col.linW, 4)+" , " //ColParWName
	if (waveexists(s.fVars.Lay.linW))
		strCMD += GetWavesDataFolder(s.fVars.Lay.linW, 4)+", " //LayParWName
		strCMD += GetWavesDataFolder(s.fVars.LayRow.linW, 4)+", " //LayRowParWName
		strCMD += GetWavesDataFolder(s.fVars.LayCol.linW, 4)+", " //LayColParWName
	else
		strCMD +="$\"\", $\"\", $\"\", "
	endif 
	strCMD += AddtlDataStr+", "
	strCMD += DbgStr

//		print "\r\n"+preCMD +fitCMD+ numCMD + strCMD+")"
//		print "\r\n X:"+nameofwave(s.xw)+" ["+num2str(s.xw[0])+" - "+num2str(s.xw[dimsize(s.xw,0)-1])+"] "+num2str(dimsize(s.xw, 0))
//		print "\r\n X:"+nameofwave(s.fData.X.fitClbW)+" ["+num2str(s.fData.X.fitClbW[0])+" - "+num2str(s.fData.X.fitClbW[dimsize(s.fData.X.fitClbW,0)-1])+"] "+num2str(dimsize(s.fData.X.fitClbW, 0))
	Execute preCMD +fitCMD+ numCMD + strCMD+")"
	if (strlen(s.UserCorrFunc))
		Execute preCMD +fitCMD+ numCMD + strCMD+")"
	endif 

	variable currTime = stopMSTimer(timerID);
	s.cpuTime += currTime;
	s.stepCount += 1
end


//******************************************************************
//
Function G2SimFunc_2D_Struct(s)
	STRUCT chunkDataT &s;
	
	variable timerID = startMSTimer
	
	//Variable  i


	// Log fit params
	if (s.logCount >= 0)
		if (s.logCount >= s.logSize)
			s.logSize += 10;
			redimension /N =(dimsize(s.pw, 0), s.logSize) s.logW
		endif
		s.logW[][s.logCount] = s.pw[p]
		s.logCount += 1
	endif

	string AddtlDataStr  ="\""+GetWavesDataFolder(s.AddtlDataW,4)+"\", \""+GetWavesDataFolder(s.CXZRefW,4)+"\" ";
	string DbgStr  =""+num2str(s.DbgKeep)+", "+num2str(s.DbgSave)+" ";

	if (s.ProcessReuse) 
		variable i
		for (i=0; i<s.fVars.Glob.nVars; i+=1)
			if ((s.ProcLastGlobals[i] - s.fVars.Glob.linW[i]) !=0 )
				s.ProcLastGlobals[i] = s.fVars.Glob.linW[i]
				s.ProcessReuse = 0;
			endif
		endfor
	endif

	string preCMD, postCMD
	variable procThreads;
	if (!s.ProcessReuse)	
		if (s.ProcMT<0)
			preCMD =  "ProcGlobal#G3F_Process_Proxy(\""+s.UserSimFunc+"\", "+GetWavesDataFolder(s.fVars.Glob.linW, 4)+", "+GetWavesDataFolder(s.ProcW, 4)+", "+GetWavesDataFolder(s.CClbW, 4)+", "+AddtlDataStr+")"
		else
			if (s.ProcMT)
				procThreads = s.useThreads;
			else
				procThreads = 1;
			endif 
			preCMD =  "ProcGlobal#G3F_Process_MT_Proxy("+num2str(procThreads)+",\""+GetWavesDataFolder(s.fVars.Glob.linW, 4)+"\", "+GetWavesDataFolder(s.fVars.Glob.linW, 4)+", "+GetWavesDataFolder(s.ProcW, 4)+", "+GetWavesDataFolder(s.CClbW, 4)+", "+AddtlDataStr+")"
		endif
		execute preCMD
	endif
	

		string preFitCmd, numCMD, strCMD, fitCMD, corrCMD
		preFitCMD= "ProcGlobal#G3F_ProcLocal_MT_Proxy("
		
		fitCMD =  " \""+s.UserFitFunc+"\", "+num2str(s.mainOptions)+", "

		numCMD = num2str(s.useThreads)+", "
		numCMD += num2str(s.rows)+", "
		numCMD += num2str(s.fData.X.fitLines)+", "
		numCMD += num2str(s.fData.Z.fitLines)+", "
		numCMD += num2str(s.fVars.Row.linOffset)+",  "//RowWaveOffset
		numCMD += num2str(s.fVars.Col.linOffset)+",  " //ColWaveOffset
		numCMD += num2str(s.fVars.Row.nVars)+",  "
		numCMD += num2str(s.fVars.Col.nVars)+",  "
		
		strCMD  = GetWavesDataFolder(s.fData.ColNumWave,4)+", "
		strCMD += GetWavesDataFolder(s.yw, 4)+", "
		strCMD += GetWavesDataFolder(s.fData.X.fitClbW, 4)+", "  // not s.xw
		strCMD += GetWavesDataFolder(s.fData.Z.fitClbW, 4)+", " //s.inzw
		strCMD += GetWavesDataFolder(s.fVars.Glob.linW, 4)+", " //GlobParWName
		strCMD += GetWavesDataFolder(s.fVars.Row.linW, 4)+", " //RowParWName
		strCMD += GetWavesDataFolder(s.fVars.Col.linW, 4)+" , " //ColParWName
		strCMD += AddtlDataStr+", "
		strCMD += DbgStr+", "
		strCMD += GetWavesDataFolder(s.ProcW, 4)

		
		Execute preCMD +fitCMD+ numCMD + strCMD+", "+GetWavesDataFolder(s.ProcW,4) +")"
		if (strlen(s.UserCorrFunc))
			corrCMD = " \""+s.UserCorrFunc+"\", "+num2str(s.corrOptions)+", "
			string preCorrCMD, postCorrCMD
			if (s.CorrNoSim)
				preCorrCMD = "ProcGlobal#G3F_Direct_MT_Proxy("
				postCorrCMD = "";
				print "call G3F_Direct_MT_Proxy (opt 1)"
				Execute preCorrCMD +fitCMD+ numCMD + strCMD+")"
			else
				preCorrCMD = "ProcGlobal#G3F_ProcLocal_MT_Proxy("
				postCorrCMD = ", "+GetWavesDataFolder(s.ProcW,4);
				print "call G3F_ProcLocal_MT_Proxy (opt 2)"
			endif
			Execute preCorrCMD +fitCMD+ numCMD + strCMD + postCorrCMD+")"
		endif 


	variable currTime = stopMSTimer(timerID);
	s.cpuTime += currTime;
	s.stepCount += 1
end