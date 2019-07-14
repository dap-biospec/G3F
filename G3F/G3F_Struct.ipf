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




//-------------------------------------------------------------
//
// Input data structure
//
STRUCTURE inDataDimT
	variable from;
	variable to;
	variable thin;
	variable ave;
	variable mtxLines; 
	WAVE clbW;
	WAVE refW;
	WAVE maskW;
endstructure

//-------------------------------------------------------------
//

STRUCTURE inDataT
	STRUCT inDataDimT X;
	STRUCT inDataDimT Z;
	STRUCT inDataDimT L;
	string baseName;
	variable FromListSet;
	WAVE colLimWaveW
	WAVE MNWave;
	WAVE /T MTWave;
endstructure

//-------------------------------------------------------------
//
// fitted parameters strcuture
//
STRUCTURE fitVarDimT
	WAVE ParW; // this is a 2-3D parameters wave
	WAVE HeldW; // this is a linear wave of just the necessary parameters in the sequence of [var][point][layer]
	WAVE SigmaW;
	variable nVars;
	variable hold; // boolean: 0 - fitted, other held
	variable linSize; // total number of variables to fit for this dimension
	variable linOffset; // offset of the first parameter in the fitted or held parameters wave 
	WAVE linW; // reference only to the wave to be used in calculation
endstructure

//-------------------------------------------------------------
//
STRUCTURE fitVarsT
	STRUCT fitVarDimT Glob;
	STRUCT fitVarDimT Row;
	STRUCT fitVarDimT Col;
	STRUCT fitVarDimT Lay;
	STRUCT fitVarDimT LayRow;
	STRUCT fitVarDimT LayCol;
endstructure


//-------------------------------------------------------------
//
// this structure describes thinned/trimmed 3D data
//

//-------------------------------------------------------------
//

STRUCTURE fitDataDimT
	WAVE fitClbW;
	variable fitLines;	
endstructure

//-------------------------------------------------------------
//
STRUCTURE fitDataT
	WAVE fThinW
	WAVE ColNumWave
	WAVE XYRefWave
	variable NumChunks
	variable ChunkSize
	variable HoldOverride
	
	STRUCT fitDataDimT X;
	STRUCT fitDataDimT Z;
	STRUCT fitDataDimT L;
endstructure

//-------------------------------------------------------------
//
// this structure describes linear chunk of data and parameters ready to fiy
STRUCTURE chunkDataT
	// references for Igor internal operation
	WAVE pw // should be the same as CParamW
	WAVE yw // should be the saem as CDestW
	WAVE xw // should be the same as CClbW
	STRUCT WMFitInfoStruct fi
	
	WAVE CParamW //inpw
	WAVE CDestW //inyw
	WAVE CClbW //inxw
	WAVE CLinW
	WAVE CXZRefW
	WAVE CResW
	WAVE AddtlDataW
	
	variable V_ChiSq
	variable V_npnts
	
	variable rows 
	variable cols
	
	string UserSimFunc
	string UserFitFunc
	string UserCorrFunc; //=$cG3FControl+":CorrFunction" - not used?
	variable CorrNoSim;
	
	STRUCT fitDataT fData;
	STRUCT fitVarsT fVars;	
	string HoldStr;
	wave /T CConstrW;
	wave CEpsW;
	
	variable mainOptions; // = $cG3FControl+":mainOptions" // dummy variable
	variable corrOptions; // = $cG3FControl+":corrOptions" // indicates "skip 1st " option
	variable useThreads; 
	
	variable ProcessReuse;
	WAVE ProcLastGlobals;
	WAVE ProcW;
	variable ProcMT;
	
	// logging and debugging	
	variable DbgKeep;
	variable DbgSave;
	variable logCount;
	variable logSize;
	WAVE logW;
	variable cpuTime
	variable startTime
	variable stepCount
	
endstructure

//-------------------------------------------------------------
//
STRUCTURE outDim
	WAVE clbW; // thinned
	WAVE refW; // thinhed 
endstructure

//-------------------------------------------------------------
//
STRUCTURE outDataT
	WAVE oThinW 	// ThinnedW, same as fitDataT.fThinW
	WAVE oFitW		 // MWaveFit
	WAVE oResW		 // ResidualsW
	STRUCT outDim X;
	STRUCT outDim Z;
	STRUCT outDim L;
endstructure

//-------------------------------------------------------------
//  Bitfield constants for storage of flags

constant MakeThinX 	= 0x001;
constant MakeThinZ 	= 0x002;
constant MakeThinL 	= 0x004;
constant AveThinX 		= 0x100;
constant AveThinZ 		= 0x200;
constant AveThinL 		= 0x400;

constant RecycleGlob 		= 0x001; // phony
constant RecycleRow 		= 0x002;
constant RecycleCol 		= 0x004;
constant RecycleLay 		= 0x008;
constant RecycleLayRow 	= 0x010;
constant RecycleLayCol 	= 0x020;

constant HoldGlob 			= 0x0100;
constant HoldRow 			= 0x0200;
constant HoldCol 			= 0x0400;
constant HoldLay 			= 0x0800;
constant HoldLayRow 		= 0x1000;
constant HoldLayCol 		= 0x2000;
constant HoldNone 			= 0x8000;
constant No1stCol 			= 0x10000; 


constant KeepLastSim 			= 0x00000001;
constant ReuseLastSim 			= 0x00000002;
constant MTProcess 				= 0x00000004;
constant reserved_00000008	= 0x00000008;
constant reserved_00000010	= 0x00000010;
constant reserved_00000020	= 0x00000020;
constant reserved_00000040	= 0x00000040;
constant reserved_00000080	= 0x00000080;
constant DoResiduals			= 0x00000100;
constant DoConstraints			= 0x00000200;
constant DoEpsilon				= 0x00000400;
constant reserved_00000800	= 0x00000000;
constant SplitLocals			= 0x00001000;
constant SplitSigma				= 0x00002000;
constant DelExtra				= 0x00004000;
constant reserved_00008000	= 0x00008000;
constant MinReport				= 0x00010000;
constant QuietReport			= 0x00020000;
constant SupressDlg				= 0x00040000;
constant reserved_00080000 	= 0x00080000;
constant EnableDev				= 0x00100000;
constant EnableLog				= 0x00200000;
constant DbgSave 				= 0x00400000;
constant DbgKeep					= 0x00800000;
constant reserved_01000000	= 0x01000000;
constant reserved_02000000 	= 0x02000000;
constant reserved_04000000 	= 0x04000000;
constant reserved_08000000 	= 0x08000000;
constant FeedbackRowClear 	= 0x10000000;
constant FeedbackColClear 	= 0x20000000;
constant reserved_40000000 	= 0x40000000;
constant reserved_80000000 	= 0x80000000;




//constant reserved_000000 		= 0x00000000;

