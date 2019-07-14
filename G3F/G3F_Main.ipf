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
#pragma IgorVersion=8.0
#pragma version =  20190710

#include  ":G3F_Setup", version>= 20190710
#include  ":G3F_Constraints", version>=20190710
#include  ":G3F_Guesses", version>=20190710
#include  ":G3F_List&Set", version>= 20190710
#include  ":G3F_Auxillary", version>= 20190710
#include  ":G3F_Struct", version>= 20190710
#include  ":G3F_FitFlow", version>= 20190710
#include  ":G3F_DoTheFit", version>= 20190710
#include  ":G3F_Feedback", version>=20190710
#include  ":G3F_Desktop", version>=20190710



function G3F_StartupHook (refNum, fileNameStr, pathNameStr, fileTypeStr, fileCreatorStr, fileKind)
	Variable refNum,fileKind
	String fileNameStr,pathNameStr,fileTypeStr,fileCreatorStr
	G3F#G3FitStartupHookInternal(refNum, fileNameStr, pathNameStr, fileTypeStr, fileCreatorStr, fileKind);
end


//###################################################################
//
// Proxy functions to access global lists of waves and functions 
//
//~~~~~~~~~~~~~~~~~~~~~~~~~
function G3F_FunctionList2SVar(svarName, matchStr, sepStr, optStr)
	string svarName
	string matchStr
	string sepStr
	string optStr

	switch (exists(svarName))
		case 0: 
			string /G $svarName;
		case 2:
			break;
		default:
			return 0;
	endswitch

	SVAR List = $svarName
	List = FunctionList(matchStr, sepStr, optStr) 
end

//~~~~~~~~~~~~~~~~~~~~~~~~~
function G3F_WaveList2SVar(svarName, matchStr, sepStr, optStr)
	string svarName
	string matchStr
	string sepStr
	string optStr

	switch (exists(svarName))
		case 0: 
			string /G $svarName;
		case 2:
			break;
		default:
			return 0;
	endswitch

	SVAR List = $svarName
	List = WaveList(matchStr, sepStr, optStr) 
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function /WAVE G3F_LocPFold (wCP, NPoints, NCVar, CPO , suffix, msg)
	wave wCP
	variable NPoints, NCVar, CPO
	string suffix 
	string msg
	
	
	string sCPFold = GetWavesDataFolder(wCP,2)+suffix; //"_Fld";
	if (NCVar > 0)
		make /O/N=(NPoints, NCVar) $sCPFold
		wave wCPFold = $sCPFold
		wCPFold[][] = wCP[CPO+p*NCVar+q]
	else 
		make /O/N=(0, 0) $sCPFold
		wave wCPFold = $sCPFold
	endif
	if (G3F#CheckError(msg))
		return NULL;
	endif		
	return wCPFold
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function /WAVE G3F_LocPLFold (wCP, NPoints, NCVar, NLays, CPO , suffix, msg)
	wave wCP
	variable NPoints, NCVar, NLays, CPO
	string suffix 
	string msg
	
	
	string sCPFold = GetWavesDataFolder(wCP,2)+suffix; //"_Fld";
	if (NCVar > 0)
		make /O/N=(NPoints, NCVar,NLays) $sCPFold
		wave wCPFold = $sCPFold
		wCPFold[][][] = wCP[CPO+p*NCVar+q + r*(NCVar * NPoints)]
	else 
		make /O/N=(0, 0) $sCPFold
		wave wCPFold = $sCPFold
	endif
	if (G3F#CheckError(msg))
		return NULL;
	endif		
	return wCPFold
end




////~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//// Common structure for G3F_DirectXxYy and G3F_ProcessXxYy proxy functions



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
STRUCTURE G3F_Linear_Var
	wave wP; // linear parameters wave
	variable PO //offset in wP to the first parameter 
endstructure 


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
STRUCTURE G3F_Linear_Var_3D_Set
	STRUCT G3F_Linear_Var G;
	STRUCT G3F_Linear_Var R;
	STRUCT G3F_Linear_Var C;
	STRUCT G3F_Linear_Var L;
	STRUCT G3F_Linear_Var LR;
	STRUCT G3F_Linear_Var LC;
endstructure

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
STRUCTURE G3F_Linear_Var_2D_Set
	STRUCT G3F_Linear_Var G;
	STRUCT G3F_Linear_Var R;
	STRUCT G3F_Linear_Var C;
endstructure

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
STRUCTURE G3F_Folded_Var_3D_Set
	wave wG;
	wave wR;
	wave wC;
	wave wL;
	wave wLR;
	wave wLC;
endstructure

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
STRUCTURE G3F_Folded_Var_2D_Set
	wave wG;
	wave wR;
	wave wC;
endstructure


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
STRUCTURE G3F_Comm_Param_Set
	wave wY // calculated Y wave
	wave wCClb // Column calibration in original data, usually time or concentration
	wave wRClb // Row calibration in original data, usually wavelength
	wave wLClb // Layer calibration in original data, usually composition or temperature
	wave wSim // process wave or NULL wave
	wave wEP // extra params wave or NULL wave
	wave wXZp // X-Z parametric wave or NULL wave; requires wEP  
endstructure

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Common structure for G3F_DirectXxYy and G3F_ProcessXxYy proxy functions
//
STRUCTURE G3F_Proxy_Param_Set
	wave ColNumWave; // column number limiting wave or null
	variable NPoints // total number of points in data wave

	variable NRows // total number of fitted rows in data wave
	variable NCols // total number of fitted columns in data wave
	variable NLays // total number of fitted layers in data wave


	variable NRVar // number of RowLoc variables (per row)
	variable NCVar // number of ColLoc variables (per column)
	variable NLVar // number of LayLoc variables (per row)
	variable NLRVar // number of LayRowLoc variables (per row)
	variable NLCVar // number of LayColLoc variables (per row)

	variable options; // misc flags
	variable useThreads // how many threads to use
	
	variable debugKeep; 
	variable debugSave; 
 	
EndStructure



	
//###################################################################
// Direct calculaitons interface
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Proxy function for multi-threaded calculations using G3F_DirectXxYy_ZD_TPL template from G3F module
// G3F_Direct_MT_Proxy


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_Fold_2D_params(p, v, f)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Linear_Var_3D_Set &v
	STRUCT G3F_Folded_Var_3D_Set &f

	wave f.wG = v.G.wP; // globals do not need folding
	
	wave f.wC = G3F_LocPFold (v.C.wP, p.NCols, p.NCVar, v.C.PO , "_CFld", " G3F fold CP ");
	if (!waveexists(f.wC))
		return 0;
	endif
	
	wave f.wR = G3F_LocPFold (v.R.wP, p.NRows, p.NRVar, v.R.PO , "_RFld", " G3F fold RP ");
	if (!waveexists(f.wR))
		return 0;
	endif

	wave f.wL = $""
	wave f.wLC = $""
	wave f.wLR = $""
	return 1;
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_Fold_3D_params(p, v, f)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Linear_Var_3D_Set &v
	STRUCT G3F_Folded_Var_3D_Set &f

	if (!G3F_Fold_2D_params(p, v, f))
		return 0;
	endif 

	wave f.wL = G3F_LocPFold (v.L.wP, p.NLays, p.NLVar, v.L.PO , "_LFld", " G3F fold LP ");
	if (!waveexists(f.wL))
		return 0;
	endif

	wave f.wLC = G3F_LocPLFold (v.LC.wP, p.NCols, p.NLCVar, p.NLays, v.LC.PO ,  "_LCFld", " G3F fold LCP ");
	if (!waveexists(f.wLC))
		return 0;
	endif
	
	wave f.wLR = G3F_LocPLFold (v.LR.wP, p.NRows, p.NLRVar, p.NLays, v.LR.PO , "_LRFld", " G3F fold LRP ");
	if (!waveexists(f.wLR))
		return 0;
	endif		
	return 1;
end



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
constant prxNone = 0x01;
constant prxSim = 0x01;
constant prx3D = 0x02;
constant prxEP = 0x04;
constant prxXZP = 0x08;

function G3F_Proxy_report(call, c, f, funcInfo, aRow, aLay, iFrom, iTo, flags) 
	variable call
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Folded_Var_3D_Set &f

	string &funcInfo
	variable aRow, aLay, iFrom, iTo
	variable flags;

	string tgtName = "G3FCmd_"
	if (call == 0) 
		tgtName += "first"
	else
		tgtName += "last"
	endif 
	string /g $tgtName
	SVAR G3FCmd_first= $tgtName
	G3FCmd_first = StringByKey("NAME", funcInfo)+"(";
	G3FCmd_first += GetWavesDataFolder(c.wY,4)+", ";
	if (flags & prxSim)
		G3FCmd_first += GetWavesDataFolder(c.wSim,4)+", ";
	endif 
	G3FCmd_first += GetWavesDataFolder(c.wCClb,4)+", ";
	G3FCmd_first += GetWavesDataFolder(c.wRClb,4)+", ";
	if (flags & prx3D)
		G3FCmd_first += GetWavesDataFolder(c.wLClb,4)+", ";
	endif
	
	G3FCmd_first += GetWavesDataFolder(f.wG,4)+", ";
	G3FCmd_first += GetWavesDataFolder(f.wC,4)+", ";
	G3FCmd_first += GetWavesDataFolder(f.wR,4)+", ";
	if (flags & prx3D)
		G3FCmd_first += GetWavesDataFolder(f.wL,4)+", ";
		G3FCmd_first += GetWavesDataFolder(f.wLC,4)+", ";
		G3FCmd_first += GetWavesDataFolder(f.wLR,4)+", ";
	endif
	G3FCmd_first += num2str(aRow)+", ";
	if (flags & prx3D)
		G3FCmd_first += num2str(aLay)+", ";
	endif 
	G3FCmd_first += num2str(iFrom)+", ";
	G3FCmd_first += num2str(iTo)
	if (flags & prxEP)
		G3FCmd_first +=	", "+GetWavesDataFolder(c.wEP,4);

	endif 
	if (flags & prxXZP)
		G3FCmd_first +=	", "+GetWavesDataFolder(c.wXZp,4);
	endif 
	G3FCmd_first += ")";
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_Purge_Fold_Waves(f)
	STRUCT G3F_Folded_Var_3D_Set &f
	wave C = f.wC;
	wave R = f.wR;
	wave L = f.wL;
	wave LC = f.wLC;
	wave LR = f.wLR;
	
	killwaves /Z C, R, L, LC, LR
end





//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for direct calculation using linear local params passed in a strcuture
//
ThreadSafe Function G3F_Direct_1D_Str_TPL(c, v, row, lay, dFrom, dTo)
STRUCT G3F_Comm_Param_Set &c
STRUCT G3F_Linear_Var_3D_Set &v

//wave c.wY // calculated Y wave
//wave c.wCClb // Column calibration in original data, usually time or concentration
//wave c.wRClb // Row calibration in original data, usually wavelength
//wave c.wLClb // Layer calibration in original data, usually wavelength
//
//wave f.G.wP // global parameters wave, always starts with 0
//wave f.G.PO // not used
//wave f.R.wP // a linear Row parameters wave
//wave f.R.PO // offset in f.R.wP to the first Row Parameter
//wave f.C.wP // a linear Col parameters wave
//wave f.C.PO // offset in f.C.wP to the first Col Parameter
//same for f.L ect.   

variable row //
variable lay //
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template MatrixLocAllAtOnce2DG2TS(pw, yw, xw, zw, lOffs, dFrom, dTo) invoked"
	wave wY = c.wY;
	wY = 1.212121212
	return nan
end



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for direct calculation using 2D local params passed in a strcuture
//
ThreadSafe Function G3F_Direct_3D_Str_TPL(c, f, row, lay, dFrom, dTo)
STRUCT G3F_Comm_Param_Set &c
STRUCT G3F_Folded_Var_3D_Set &f

//wave c.wY // calculated Y wave
//wave c.wCClb // Column calibration in original data, usually time or concentration
//wave c.wRClb // Row calibration in original data, usually wavelength
//wave c.wLClb // Layer calibration in original data, usually wavelength
//
//wave f.wG // global parameters wave, always starts with 0
//wave f.wR // a 2D Row parameters wave row - fitted point, col - param #
//wave f.wC //  a 2D Row parameters wave column - fitted point, col - param #
//wave f.wL // 
//wave f.wLR // 
//wave f.wLC //  

variable row //
variable lay //
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template MatrixLocAllAtOnce2DG2TS(pw, yw, xw, zw, lOffs, dFrom, dTo) invoked"
	wave wY = c.wY;
	wY = 1.212121212
	return nan
end




function G3F_Direct_MT_Proxy(LocFuncName, options, useThreads,  NPoints, NRows, NCols, NLays, RPO, CPO, LPO, LRPO, LCPO, NRVar, NCVar, NLVar, NLRVar, NLCVar, ColNumWave, wY, wRClb, wCClb, wLClb, wGP, wRP, wCP, wLP, wLRP, wLCP, wEPN, wXZpN, dbgKeep, dbgSave)
	string LocFuncName
	variable options
	variable useThreads
	variable NPoints
	variable NRows
	variable NCols
	variable NLays
	variable RPO
	variable NRVar
	variable NCVar
	variable CPO 
	wave ColNumWave;
	wave wY // calculated Y wave
	wave wCClb // Column calibration in original data, usually time or concentration
	wave wRClb // Row calibration in original data, usually wavelength
	wave wLClb // Layer calibration in original data, usually another parameter
	wave wGP // global parameters wave, always starts with 0
	wave wRP // Row parameters wave
	wave wCP // Col parameters wave
	string wEPN // name of extra params wave or none
	string wXZpN // names of X-Z parametric wave; wEP must be used   

	wave wLP // Layer parameters wave
	variable NLVar // number of LayLoc variables (per row)
	variable LPO // offset in wLP to the first Lay Parameter 

	wave wLRP // LayRow parameters wave
	variable NLRVar // number of LayRowLoc variables (per row)
	variable LRPO // offset in wLRP to the first Lay Parameter 

	wave wLCP // LayCol parameters wave
	variable NLCVar // number of LayColLoc variables (per row)
	variable LCPO // offset in wLCP to the first Lay Parameter 
	variable dbgKeep, dbgSave


	// structure cannot be passed across module, so it has to be assembeld here...	
	STRUCT G3F_Proxy_Param_Set p
	wave p.ColNumWave=ColNumWave; // column number limiting wave or null
	p.options=options // misc flags
	p.useThreads=useThreads // how many threads to use
	p.NPoints=NPoints // total number of points in data wave
	p.NRows=NRows // total number of fitted rows in data wave
	p.NCols=NCols // total number of fitted columns in data wave
	p.NLays=NLays // total number of fitted layers in data wave
	p.NRVar=NRVar // number of RowLoc variables (per row)
	p.NCVar=NCVar // number of ColLoc variables (per column)
	p.NLVar=NLVar // number of LayLoc variables (per row)
	p.NLRVar=NLRVar // number of LayRowLoc variables (per row)
	p.NLCVar=NLCVar // number of LayColLoc variables (per row)
	p.debugKeep =  dbgKeep; 
	p.debugSave = dbgSave; 


	STRUCT G3F_Linear_Var_3D_Set v
	v.R.PO=RPO // offset in wRP to the first Row Parameter 
	v.C.PO=CPO; // offset in wCP to the first Col Parameter
	v.L.PO=LPO // offset in wLP to the first Lay Parameter 
	v.LR.PO=LRPO // offset in wLRP to the first Lay Parameter 
	v.LC.PO=LCPO // offset in wLCP to the first Lay Parameter 
	wave v.G.wP=wGP // global parameters wave, always starts with 0
	wave v.R.wP=wRP // Row parameters wave
	wave v.C.wP=wCP // Col parameters wave
	wave v.L.wP=wLP // Layer parameters wave
	wave v.LR.wP=wLRP // LayRow parameters wave
	wave v.LC.wP=wLCP // LayCol parameters wave


	STRUCT G3F_Comm_Param_Set c 
	wave c.wY=wY // calculated Y wave
	wave c.wCClb=wCClb // Column calibration in original data, usually time or concentration
	wave c.wRClb=wRClb // Row calibration in original data, usually wavelength
	wave c.wLClb=wLClb // Layer calibration in original data, maybe trial or composition
	wave c.wEP = $wEPN;	// name of extra params wave or null wave
	wave c.wXZp = $wXZpN; // names of X-Z parametric wave or null wave; requires wEP 
	wave c.wSim = NULL;


	variable pStart, cStart
	
   	if (options & 1) // first row is special
   		if (options & 2) // do first rowl but use fixed params
   		else // just skip first col locals
   		endif
   		pStart = 1;
   	else
   		pStart = 0;
   	endif
   	
   	if (options & 4) // first col is special
   		if (options & 8) // do first col but use fixed params
   			// to do calculation we need local col parameter for the first col; this is not included in col locals
   		else // just skip first col locals
   		endif
   		cStart = 1
   	else
   		cStart = 0
   	endif
   	
	if (WaveExists(c.wEP)) // With extra parameter wave
		if (WaveExists(c.wXZp))
				if (G3F_Direct_EpXZp_3D_MT_Proxy(p, c, v, $LocFuncName, pStart, cStart))
					return 1;
				elseif (G3F_Direct_EpXZp_2D_MT_Proxy(p, c, v, $LocFuncName, pStart, cStart))
					return 1;
				elseif (G3F_Direct_EpXZp_1D_MT_Proxy( p, c, v,  $LocFuncName, pStart, cStart))
					return 1
				endif
		else // no wXp or wZp
			if (G3F_Direct_Ep_3D_MT_Proxy( p, c, v, $LocFuncName, pStart, cStart))
				return 1;
			elseif (G3F_Direct_Ep_2D_MT_Proxy( p, c, v, $LocFuncName, pStart, cStart))
				return 1;
			elseif (G3F_Direct_Ep_1D_MT_Proxy( p, c, v,  $LocFuncName, pStart, cStart))
				return 1
			endif
		endif 
	else // without extra parameter wave
		if (G3F_Direct_3D_MT_Proxy( p, c, v, $LocFuncName, pStart, cStart))
			return 1;
		elseif (G3F_Direct_2D_MT_Proxy( p, c, v,  $LocFuncName, pStart, cStart))
			return 1;
		elseif (G3F_Direct_1D_MT_Proxy( p, c, v,  $LocFuncName, pStart, cStart))
			return 1;
		endif
	endif
	
	return 0;
end


// handlers
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_Direct_3D_MT_Proxy(p, c, v, theLocFunc3D, pStart, cStart)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v
	FUNCREF G3F_Direct_3D_TPL theLocFunc3D 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc3D);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif
	
	STRUCT G3F_Folded_Var_3D_Set f
	if (!G3F_Fold_3D_params(p, v, f))
		return 0;
	endif 
		
	variable result = 1
	variable LinFrom = 0, LinTo
	variable aRow;
	variable aLay;
	
	variable saved = p.debugSave ? 0 : 1;
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aLay = 0; aLay < p.NLays; aLay+=1)
			for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
				for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
					LinTo = LinFrom + p.ColNumWave[aRow] -1;
					// strcutures cannot be passed across preemptive threads, so, we a stuck with passing waves and values 
					ThreadStart mt, t,  theLocFunc3D(c.wY, c.wCClb, c.wRClb, c.wLClb, f.wG, f.wC, f.wR, f.wL, f.wLC, f.wLR, aRow, aLay, LinFrom + cStart, LinTo) 
					if (!saved)
						G3F_Proxy_report(0, c, f, funcInfo,  aRow, aLay, LinFrom + cStart, LinTo, prx3D)				
						saved = 1;
					endif 
					LinFrom = LinTo +1; 
				endfor // threads
				do
					tgs= ThreadGroupWait(mt, 20)
				while( tgs != 0 )
				if (G3F#CheckError(" _3D fit function "+StringByKey("NAME", funcInfo)))
					result = 0;
					break;
				endif				
			endfor
		endfor
		variable dummy= ThreadGroupRelease(mt)
		if (p.debugSave)
			G3F_Proxy_report(1, c, f, funcInfo,  aRow, aLay, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prx3D) 					
		endif
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			// since MT version cannot pass structures by reference, we will use same mechanism here.
			theLocFunc3D(c.wY, c.wCClb, c.wRClb, c.wLClb, f.wG, f.wC, f.wR, f.wL, f.wLC, f.wLR, aRow, aLay, LinFrom + cStart, LinTo)	
			if (!saved)
				G3F_Proxy_report(0, c, f, funcInfo,  aRow, aLay, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prx3D)	 					
				saved = 1;
			endif

			if (G3F#CheckError(" _2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	if (!p.debugKeep)
		G3F_Purge_Fold_Waves (f)
	endif
	return result	
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_Direct_Ep_3D_MT_Proxy(p, c, v, theLocFunc3D, pStart, cStart)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v
	FUNCREF G3F_Direct_Ep_3D_TPL theLocFunc3D 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc3D);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif
	
	STRUCT G3F_Folded_Var_3D_Set f
	if (!G3F_Fold_3D_params(p, v, f))
		return 0;
	endif 
		
	variable result = 1
	variable LinFrom = 0, LinTo
	variable aRow;
	variable aLay;
	
	variable saved = p.debugSave ? 0 : 1;
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aLay = 0; aLay < p.NLays; aLay+=1)
			for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
				for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
					LinTo = LinFrom + p.ColNumWave[aRow] -1;
					// strcutures cannot be passed across preemptive threads, so, we a stuck with passing waves and values 
					ThreadStart mt, t,  theLocFunc3D(c.wY, c.wCClb, c.wRClb, c.wLClb, f.wG, f.wC, f.wR, f.wL, f.wLC, f.wLR, aRow, aLay, LinFrom + cStart, LinTo, c.wEP) 
					if (!saved)
						G3F_Proxy_report(0, c, f, funcInfo,  aRow, aLay, LinFrom + cStart, LinTo, prx3D | prxEP)				
						saved = 1;
					endif 
					LinFrom = LinTo +1; 
				endfor // threads
				do
					tgs= ThreadGroupWait(mt, 20)
				while( tgs != 0 )
				if (G3F#CheckError(" Ep_3D fit function "+StringByKey("NAME", funcInfo)))
					result = 0;
					break;
				endif				
			endfor
		endfor
		variable dummy= ThreadGroupRelease(mt)
		if (p.debugSave)
			G3F_Proxy_report(1, c, f, funcInfo,  aRow, aLay, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prx3D | prxEP) 					
		endif
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			// since MT version cannot pass structures by reference, we will use same mechanism here.
			theLocFunc3D(c.wY, c.wCClb, c.wRClb, c.wLClb, f.wG, f.wC, f.wR, f.wL, f.wLC, f.wLR, aRow, aLay, LinFrom + cStart, LinTo, c.wEP)	
			if (!saved)
				G3F_Proxy_report(0, c, f, funcInfo,  aRow, aLay, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prx3D | prxEP)	 					
				saved = 1;
			endif

			if (G3F#CheckError(" Ep_2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	if (!p.debugKeep)
		G3F_Purge_Fold_Waves (f)
	endif
	return result	
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_Direct_EpXZp_3D_MT_Proxy(p, c, v, theLocFunc3D, pStart, cStart)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v
	FUNCREF G3F_Direct_EpXZp_3D_TPL theLocFunc3D 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc3D);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif
	
	STRUCT G3F_Folded_Var_3D_Set f
	if (!G3F_Fold_3D_params(p, v, f))
		return 0;
	endif 
		
	variable result = 1
	variable LinFrom = 0, LinTo
	variable aRow;
	variable aLay;
	
	variable saved = p.debugSave ? 0 : 1;
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aLay = 0; aLay < p.NLays; aLay+=1)
			for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
				for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
					LinTo = LinFrom + p.ColNumWave[aRow] -1;
					// strcutures cannot be passed across preemptive threads, so, we a stuck with passing waves and values 
					ThreadStart mt, t,  theLocFunc3D(c.wY, c.wCClb, c.wRClb, c.wLClb, f.wG, f.wC, f.wR, f.wL, f.wLC, f.wLR, aRow, aLay, LinFrom + cStart, LinTo, c.wEP, c.wXZP) 
					if (!saved)
						G3F_Proxy_report(0, c, f, funcInfo,  aRow, aLay, LinFrom + cStart, LinTo, prx3D | prxEP | prxXZP)				
						saved = 1;
					endif 
					LinFrom = LinTo +1; 
				endfor // threads
				do
					tgs= ThreadGroupWait(mt, 20)
				while( tgs != 0 )
				if (G3F#CheckError(" EpXZp_3D fit function "+StringByKey("NAME", funcInfo)))
					result = 0;
					break;
				endif				
			endfor
		endfor
		variable dummy= ThreadGroupRelease(mt)
		if (p.debugSave)
			G3F_Proxy_report(1, c, f, funcInfo,  aRow, aLay, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prx3D | prxEP | prxXZP) 					
		endif
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			// since MT version cannot pass structures by reference, we will use same mechanism here.
			theLocFunc3D(c.wY, c.wCClb, c.wRClb, c.wLClb, f.wG, f.wC, f.wR, f.wL, f.wLC, f.wLR, aRow, aLay, LinFrom + cStart, LinTo, c.wEP, c.wXZP)	
			if (!saved)
				G3F_Proxy_report(0, c, f, funcInfo,  aRow, aLay, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prx3D | prxEP | prxXZP)	 					
				saved = 1;
			endif

			if (G3F#CheckError(" EpXZp_2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	if (!p.debugKeep)
		G3F_Purge_Fold_Waves (f)
	endif
	return result	
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_Direct_2D_MT_Proxy(p, c, v, theLocFunc2D, pStart, cStart)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v
	FUNCREF G3F_Direct_2D_TPL theLocFunc2D 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc2D);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif

	STRUCT G3F_Folded_Var_3D_Set f
	if (!G3F_Fold_2D_params(p, v, f))
		return 0;
	endif 
		
	variable result = 1
	variable LinFrom = 0, LinTo
	variable aRow;
	
	variable saved = p.debugSave ? 0 : 1;
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
			for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
				LinTo = LinFrom + p.ColNumWave[aRow] -1;
				ThreadStart mt, t,  theLocFunc2D(c.wY,  c.wCClb, c.wRClb,  f.wG, f.wC, f.wR,  aRow, LinFrom + cStart, LinTo)
				if (!saved)
					G3F_Proxy_report(0, c, f, funcInfo,  aRow, NaN, LinFrom + cStart, LinTo, prxNone)				
					saved = 1;
				endif 
				LinFrom = LinTo +1; 
			endfor // threads
			do
				tgs= ThreadGroupWait(mt, 20)
			while( tgs != 0 )
			if (G3F#CheckError(" _2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
		endfor
		variable dummy= ThreadGroupRelease(mt)
		if (p.debugSave)
			G3F_Proxy_report(1, c, f, funcInfo,  aRow, NaN,  LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prxNone) 					
		endif
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			theLocFunc2D(c.wY,  c.wCClb, c.wRClb,  f.wG, f.wC, f.wR,  aRow, LinFrom + cStart, LinTo)
			if (!saved)
				G3F_Proxy_report(0, c, f, funcInfo,  aRow, NaN, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prxNone)	 					
				saved = 1;
			endif
			if (G3F#CheckError(" _2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	if (!p.debugKeep)
		G3F_Purge_Fold_Waves (f)
	endif
	return result	
end



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_Direct_Ep_2D_MT_Proxy(p, c, v, theLocFunc2D, pStart, cStart)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v
	FUNCREF G3F_Direct_Ep_2D_TPL theLocFunc2D 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc2D);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif

	STRUCT G3F_Folded_Var_3D_Set f
	if (!G3F_Fold_2D_params(p, v, f))
		return 0;
	endif 
		
	variable result = 1
	variable LinFrom = 0, LinTo
	variable aRow;
	
	variable saved = p.debugSave ? 0 : 1;
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
			for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
				LinTo = LinFrom + p.ColNumWave[aRow] -1;
				ThreadStart mt, t,  theLocFunc2D(c.wY,  c.wCClb, c.wRClb,  f.wG, f.wC, f.wR, aRow, LinFrom + cStart, LinTo, c.wEP)
				if (!saved)
					G3F_Proxy_report(0, c, f, funcInfo,  aRow, NaN, LinFrom + cStart, LinTo, prxEP)				
					saved = 1;
				endif 
				LinFrom = LinTo +1; 
			endfor // threads
			do
				tgs= ThreadGroupWait(mt, 20)
			while( tgs != 0 )
			if (G3F#CheckError(" Ep_2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
		endfor
		variable dummy= ThreadGroupRelease(mt)
		if (p.debugSave)
			G3F_Proxy_report(1, c, f, funcInfo,  aRow, NaN,  LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prxEP) 					
		endif
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			theLocFunc2D(c.wY,  c.wCClb, c.wRClb,  f.wG, f.wC, f.wR, aRow, LinFrom + cStart, LinTo, c.wEP)
			if (!saved)
				G3F_Proxy_report(0, c, f, funcInfo,  aRow, NaN, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prxEP)	 					
				saved = 1;
			endif
			if (G3F#CheckError(" Ep_2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	if (!p.debugKeep)
		G3F_Purge_Fold_Waves (f)
	endif
	return result	
end



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_Direct_EpXZp_2D_MT_Proxy(p, c, v, theLocFunc2D, pStart, cStart)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v
	FUNCREF G3F_Direct_EpXZp_2D_TPL theLocFunc2D 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc2D);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif

	STRUCT G3F_Folded_Var_3D_Set f
	if (!G3F_Fold_2D_params(p, v, f))
		return 0;
	endif 
		
	variable result = 1
	variable LinFrom = 0, LinTo
	variable aRow;
	
	variable saved = p.debugSave ? 0 : 1;
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
			for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
				LinTo = LinFrom + p.ColNumWave[aRow] -1;
				ThreadStart mt, t,  theLocFunc2D(c.wY,  c.wCClb, c.wRClb,  f.wG, f.wC, f.wR, aRow, LinFrom + cStart, LinTo, c.wEP, c.wXZP)
				if (!saved)
					G3F_Proxy_report(0, c, f, funcInfo,  aRow, NaN, LinFrom + cStart, LinTo, prxEP | prxXZP)				
					saved = 1;
				endif 
				LinFrom = LinTo +1; 
			endfor // threads
			do
				tgs= ThreadGroupWait(mt, 20)
			while( tgs != 0 )
			if (G3F#CheckError(" EpXZp_2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
		endfor
		variable dummy= ThreadGroupRelease(mt)
		if (p.debugSave)
			G3F_Proxy_report(1, c, f, funcInfo,  aRow, NaN,  LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prxEP | prxXZP) 					
		endif
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			theLocFunc2D(c.wY,  c.wCClb, c.wRClb,  f.wG, f.wC, f.wR, aRow, LinFrom + cStart, LinTo, c.wEP, c.wXZP)
			if (!saved)
				G3F_Proxy_report(0, c, f, funcInfo,  aRow, NaN, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prxEP| prxXZP)	 					
				saved = 1;
			endif
			if (G3F#CheckError(" EpXZp_2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	if (!p.debugKeep)
		G3F_Purge_Fold_Waves (f)
	endif
	return result	
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_Direct_1D_MT_Proxy(p, c, v, theLocFunc, pStart, cStart)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v
	FUNCREF G3F_Direct_1D_TPL theLocFunc 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif
		
	variable result = 1
	variable LinFrom = 0, LinTo
	variable aRow;
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aRow = pStart; aRow < p.NPoints && result > 0; )
			for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
				LinTo = LinFrom + p.ColNumWave[aRow] -1;
				ThreadStart mt, t,  theLocFunc(c.wY,  c.wCClb, c.wRClb, v.G.wP, v.C.wP, v.C.PO, v.R.wP, v.R.PO + p.NRVar * aRow, LinFrom+cStart, LinTo)
				LinFrom = LinTo +1; 
			endfor // threads
			do
				tgs= ThreadGroupWait(mt, 20)
			while( tgs != 0 )
			if (G3F#CheckError(" 1D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
		endfor
		variable dummy= ThreadGroupRelease(mt)
	else  //Single thread
		for ( aRow = pStart; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			theLocFunc(c.wY,  c.wCClb, c.wRClb, v.G.wP, v.C.wP, v.C.PO, v.R.wP, v.R.PO + p.NRVar * aRow, LinFrom + cStart, LinTo)
			if (G3F#CheckError(" 1D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	return result	
end



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_Direct_Ep_1D_MT_Proxy(p, c, v, theLocFunc, pStart, cStart)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v
	FUNCREF G3F_Direct_Ep_1D_TPL theLocFunc 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif
		
	variable LinFrom = 0, LinTo
	variable result = 1
	variable aRow;

	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
			for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
				LinTo = LinFrom + p.ColNumWave[aRow] -1;
					ThreadStart mt, t,  theLocFunc(c.wY,  c.wCClb, c.wRClb, v.G.wP, v.C.wP, v.C.PO, v.R.wP, v.R.PO + p.NRVar * aRow, LinFrom + cStart, LinTo, c.wEP)
					LinFrom = LinTo +1; 
			endfor // threads
			do
				tgs= ThreadGroupWait(mt, 20)
			while( tgs != 0 )
			if (G3F#CheckError(" Ep_1D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
		endfor
		variable dummy= ThreadGroupRelease(mt)
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			theLocFunc(c.wY,  c.wCClb, c.wRClb, v.G.wP, v.C.wP, v.C.PO, v.R.wP, v.R.PO + p.NRVar * aRow, LinFrom + cStart, LinTo, c.wEP)
			if (G3F#CheckError(" Ep_1D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	
	return result	
end



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_Direct_EpXZp_1D_MT_Proxy(p, c, v, theLocFunc, pStart, cStart)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v

	FUNCREF G3F_Direct_EpXZp_1D_TPL theLocFunc 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif
		
	variable LinFrom = 0, LinTo
	variable aRow;
	variable result = 1
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
			for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
				LinTo = LinFrom + p.ColNumWave[aRow] -1;
					ThreadStart mt, t,  theLocFunc(c.wY,  c.wCClb, c.wRClb, v.G.wP, v.C.wP, v.C.PO, v.R.wP, v.R.PO + p.NRVar * aRow, LinFrom + cStart, LinTo, c.wEP, c.wXZp)
					LinFrom = LinTo +1; 
			endfor // threads
			do
				tgs= ThreadGroupWait(mt, 20)
			while( tgs != 0 )
			if (G3F#CheckError(" EpXZp_1D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
		endfor
		variable dummy= ThreadGroupRelease(mt)
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			theLocFunc(c.wY,  c.wCClb, c.wRClb, v.G.wP, v.C.wP, v.C.PO, v.R.wP, v.R.PO + p.NRVar * aRow, LinFrom + cStart, LinTo, c.wEP, c.wXZp)
			if (G3F#CheckError(" EpXZp_1D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	
	return result	
end

// templates

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for direct calculation using 2D Col and Row local params
//
ThreadSafe Function G3F_Direct_3D_TPL(wY, wCClb, wRClb, wLClb, wGP, wCP2D, wRP2D, wLP2D, wLCP2D, wLRP2D, row, lay, dFrom, dTo)
wave wY // calculated Y wave
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wLClb // Layer calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP2D // a 2D Row parameters wave row - fitted point, col - param #
wave wCP2D //  a 2D Row parameters wave column - fitted point, col - param #
wave wLP2D // 
wave wLRP2D // 
wave wLCP2D //  
variable row // current row
variable lay // current layer
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template G3F_Direct_3D_TPL(pw, yw, xw, zw, lOffs, dFrom, dTo) invoked"
	wY = 1.212121212
	return nan
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for direct calculation using 2D Col and Row local params w/extra data wave
//
ThreadSafe Function G3F_Direct_Ep_3D_TPL(wY, wCClb, wRClb, wLClb, wGP, wCP2D, wRP2D, wLP2D, wLCP2D, wLRP2D, row, lay, dFrom, dTo, wEP)
wave wY // calculated Y wave
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wLClb // Layer calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP2D // a 2D Row parameters wave row - fitted point, col - param #
wave wCP2D //  a 2D Row parameters wave column - fitted point, col - param #
wave wLP2D // 
wave wLRP2D // 
wave wLCP2D //  
variable row // current row
variable lay // current layer
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
wave wEP // extra global params wave

//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template G3F_Direct_Ep_3D_TPL(pw, yw, xw, zw, lOffs, dFrom, dTo) invoked"
	wY = 1.212121212
	return nan
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for direct calculation using 2D Col and Row local params w/extra data and X & Z parametric waves
//
ThreadSafe Function G3F_Direct_EpXZp_3D_TPL(wY, wCClb, wRClb, wLClb, wGP, wCP2D, wRP2D, wLP2D, wLCP2D, wLRP2D, row, lay, dFrom, dTo, wEP, wXZp)
wave wY // calculated Y wave
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wLClb // Layer calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP2D // a 2D Row parameters wave row - fitted point, col - param #
wave wCP2D //  a 2D Row parameters wave column - fitted point, col - param #
wave wLP2D // 
wave wLRP2D // 
wave wLCP2D //  
variable row // current row
variable lay // current layer
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
wave wEP // extra global params wave
wave wXZP // extra X:Z params wave

//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template G3F_Direct_EpXZp_3D_TPL(pw, yw, xw, zw, lOffs, dFrom, dTo) invoked"
	wY = 1.212121212
	return nan
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for direct calculation using 2D Col and Row local params
//
ThreadSafe Function G3F_Direct_2D_TPL(wY, wCClb, wRClb, wGP, wCP2D, wRP2D, row, dFrom, dTo)
wave wY // calculated Y wave
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP2D // a 2D Row parameters wave row - fitted point, col - param #
wave wCP2D //  a 2D Row parameters wave column - fitted point, col - param #
variable row // current row
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template G3F_Direct_2D_TPL(pw, yw, xw, zw, lOffs, dFrom, dTo) invoked"
	wY = 1.212121212
	return nan
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for direct calculation w/extra data 
//
ThreadSafe Function G3F_Direct_Ep_2D_TPL(wY, wCClb, wRClb, wGP, wCP, wRP, row, dFrom, dTo, wED)
wave wY // calculated Y wave
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP // Row parameters wave
// variable RPO; // offset in wRP to the first Row Parameter
wave wCP // Col parameters wave
//variable CPO; // offset in wCP to the first Col Parameter
variable row // current row
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
wave wED // extra data wave 
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template G3F_Direct_Ep_2D_TPL(pw, yw, xw, zw, lOffs, dFrom, dTo) invoked"
	wY = 1.212121212
	return nan
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for direct calculation w/extra data and X & Z parametric waves
//
ThreadSafe Function G3F_Direct_EpXZp_2D_TPL(wY, wCClb, wRClb, wGP, wCP, wRP, row, dFrom, dTo, wED, wXZp)
wave wY // calculated Y wave
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP // Row parameters wave
// variable RPO; // offset in wRP to the first Row Parameter
wave wCP // Col parameters wave
// variable CPO; // offset in wCP to the first Col Parameter
variable row // current row
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
wave wED // extra data wave 
wave wXZp // X-Y parametric wave

//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template G3F_Direct_EpXZp_2D_TPL(wY, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo, wED, wXZp) invoked"
	wY = 1.212121212
	return nan
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for direct calculation
//
ThreadSafe Function G3F_Direct_1D_TPL(wY, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo)
wave wY // calculated Y wave
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP // Row parameters wave
variable RPO; // offset in wRP to the first Row Parameter
wave wCP // Col parameters wave
variable CPO; // offset in wCP to the first Col Parameter
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template G3F_Direct_1D_TPL(pw, yw, xw, zw, lOffs, dFrom, dTo) invoked"
	wY = 1.212121212
	return nan
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for direct calculation w/extra data 
//
ThreadSafe Function G3F_Direct_Ep_1D_TPL(wY, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo, wED)
wave wY // calculated Y wave
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP // Row parameters wave
variable RPO; // offset in wRP to the first Row Parameter
wave wCP // Col parameters wave
variable CPO; // offset in wCP to the first Col Parameter
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
wave wED // extra data wave 
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template G3F_Direct_Ep_1D_TPL(pw, yw, xw, zw, lOffs, dFrom, dTo) invoked"
	wY = 1.212121212
	return nan
end



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for direct calculation w/extra data and X & Z parametric waves
//
ThreadSafe Function G3F_Direct_EpXZp_1D_TPL(wY, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo, wED, wXZp)
wave wY // calculated Y wave
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP // Row parameters wave
variable RPO; // offset in wRP to the first Row Parameter
wave wCP // Col parameters wave
variable CPO; // offset in wCP to the first Col Parameter
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
wave wED // extra data wave 
wave wXZp // X-Y parametric wave

//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template G3F_Direct_EpXZp_1D_TPL(wY, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo, wED, wXZp) invoked"
	wY = 1.212121212
	return nan
end






//###################################################################
// Process / simulation  calculaitons interface
//
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//  Process access
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Proxy function for multi-threaded calculations using G3F_Process_MT_TPL template from G3F module
//
function G3F_Process_MT_Proxy(useThreads, SimFuncName, wGP, wY, wCClb, wEPN, wXZpN)
	variable useThreads
	string SimFuncName
	wave wGP // global parameters wave, always starts with 0
	wave wY // calculated Y wave
	wave wCClb // Column calibration in original data, usually time or concentration
	string wEPN // name of extra params wave or none
	string wXZpN  // names of X-Z  parametric wave; wEP must be used   
	
	variable result = 1;
	// How many points per tread?
	variable yPnts = DimSize(wY, 0);
	if (useThreads > 1)
		variable LinFrom = 0, LinTo
		//variable aRow
		variable perTread = ceil(yPnts / useThreads);
		variable mt= ThreadGroupCreate(useThreads)
		variable t, tgs
		if (strlen(wEPN))
			wave wEP = $wEPN
			string groupS
			if (WaveExists($wXZpN))
				groupS = "MT EpXZp";
				wave wXZp = $wXZpN;
				FUNCREF G3F_Process_EpXZp_MT_TPL theSimEpXZpFuncMT = $SimFuncName
				for(t=0; t<(useThreads -1); t+=1) // start n-1 treads
					LinTo = LinFrom + perTread-1;
					ThreadStart mt, t,  theSimEpXZpFuncMT(wGP, wY, wCClb, LinFrom, LinTo, wEP, wXZp )
					LinFrom = LinTo +1; 
				endfor // threads
				ThreadStart mt, t,  theSimEpXZpFuncMT(wGP, wY, wCClb, LinFrom, yPnts-1, wEP, wXZp ) // start last tread with the balance of points
			else
				groupS = "MT Ep";
				FUNCREF G3F_Process_Ep_MT_TPL theSimEpFuncMT = $SimFuncName
				for(t=0; t<(useThreads -1); t+=1) // start n-1 treads
					LinTo = LinFrom + perTread-1;
					ThreadStart mt, t,  theSimEpFuncMT(wGP, wY, wCClb, LinFrom, LinTo, wEP)
					LinFrom = LinTo +1; 
				endfor // threads
				ThreadStart mt, t,  theSimEpFuncMT(wGP, wY, wCClb, LinFrom, yPnts-1, wEP) // start last tread with the balance of points
			endif
			do
				tgs= ThreadGroupWait(mt, 20)//MTWait)
			while( tgs != 0 )
			if (G3F#CheckError(groupS+" sim function "+SimFuncName))
				result = 0;
			endif				
		else
			FUNCREF G3F_Process_MT_TPL theSimFuncMT = $SimFuncName
			for(t=0; t<(useThreads -1); t+=1) // start n-1 treads
				LinTo = LinFrom + perTread-1;
				ThreadStart mt, t,  theSimFuncMT(wGP, wY, wCClb, LinFrom, LinTo)
				LinFrom = LinTo +1; 
			endfor // threads
			ThreadStart mt, t,  theSimFuncMT(wGP, wY, wCClb, LinFrom, yPnts-1) // start last tread with the balance of points
			do
				tgs= ThreadGroupWait(mt, 20)//MTWait)
			while( tgs != 0 )
			if (G3F#CheckError("MT sim function "+SimFuncName))
				result = 0;
			endif				
			
		endif
		variable dummy= ThreadGroupRelease(mt)
	else // do not use threads
		if (strlen(wEPN))
			wave wEP =  $wEPN
			if (WaveExists($wXZpN))
				wave wXZp = $wXZpN;
				FUNCREF G3F_Process_EpXZp_MT_TPL theSimEpXZpFuncST = $SimFuncName
				theSimEpXZpFuncST( wGP, wY, wCClb, 0, yPnts - 1, wEP, wXZp) // All Grlobal params
				if (G3F#CheckError("MT EpXZp(n=1) sim function "+SimFuncName))
					result = 0;
				endif						
			else 
				FUNCREF G3F_Process_Ep_MT_TPL theSimEpFuncST = $SimFuncName
				theSimEpFuncST( wGP, wY, wCClb, 0, yPnts - 1, wEP) // All Grlobal params
				if (G3F#CheckError("MT Ep(n=1) sim function "+SimFuncName))
					result = 0;
				endif						
			endif
		else
			FUNCREF G3F_Process_MT_TPL theSimFuncST = $SimFuncName
			theSimFuncST( wGP, wY, wCClb, 0, yPnts - 1 ) // All Grlobal params
			if (G3F#CheckError("MT(n=1) sim function "+SimFuncName))
				result = 0;
			endif						
		endif
	endif
	return result
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for Multi-threaded process calculation with ExtraParam
//
ThreadSafe Function G3F_Process_Ep_MT_TPL(pw, yw, xw, dFrom, dTo, wEP)
	Wave pw, yw, xw, wEP
	variable dFrom, dTo  // start offset in  all data waves
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Involked template G3F_Process_Ep_MT_TPL(("+nameofwave(pw)+", "+ nameofwave(yw)+", "+ nameofwave(xw)+", "+num2str(dFrom)+" - "+num2str(dTo)+" ]"
	yw = 1.212121212
	return nan
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for Multi-threaded process calculation with ExtraParam, X & Z parametric waves
//
ThreadSafe Function G3F_Process_EpXZp_MT_TPL(pw, yw, xw, dFrom, dTo, wEP, wXZp)
	Wave pw, yw, xw, wEP
	wave wXZp // X-Y parametric wave
 	variable dFrom, dTo  // start offset in  all data waves
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Involked template G3F_Process_EpXZp_MT_TPL(("+nameofwave(pw)+", "+ nameofwave(yw)+", "+ nameofwave(xw)+", "+num2str(dFrom)+" - "+num2str(dTo)+" ]"
	yw = 1.212121212
	return nan
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for Multi-threaded process calculation
//
ThreadSafe Function G3F_Process_MT_TPL(pw, yw, xw, dFrom, dTo)
	Wave pw, yw, xw
	variable dFrom, dTo  // start offset in  all data waves
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Involked template G3F_Process_MT_TPL("+nameofwave(pw)+", "+ nameofwave(yw)+", "+ nameofwave(xw)+", "+num2str(dFrom)+" - "+num2str(dTo)+" ]"
	yw = 1.212121212
	return nan
end

//=================================================================
// Proxy function for Uni-threaded access to G3F_Process_TPL from G3F module
//
function G3F_Process_Proxy(SimFuncName, GlobW, procW, inxw, wEPN, wXZpN)
	string SimFuncName;
	wave GlobW, procW, inxw
	string wEPN // name of extra params wave or none
	string wXZpN  // name of X-Z  parametric wave; wEP must be used   

	if (strlen(wEPN))
		wave wEP = $wEPN
		if (WaveExists($wXZpN))
			wave wXZp = $wXZpN;
			FUNCREF G3F_Process_EpXZp_TPL theSimEpXZpFunc = $SimFuncName
			theSimEpXZpFunc( GlobW, procW, inxw,wEP, wXZp) // All Global params
			if (G3F#CheckError("ST EpXZp(n=1) sim function "+SimFuncName))
				return 0;
			endif						
		else
			FUNCREF G3F_Process_Ep_TPL theSimEpFunc = $SimFuncName
			theSimEpFunc( GlobW, procW, inxw,wEP) // All Global params
			if (G3F#CheckError("ST Ep(n=1) sim function "+SimFuncName))
				return 0;
			endif						
		endif
	else
		FUNCREF G3F_Process_TPL theSimFunc = $SimFuncName
		theSimFunc( GlobW, procW, inxw) // All Global params
		if (G3F#CheckError("ST (n=1) sim function "+SimFuncName))
			return 0;
		endif						
	endif
	return 1
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for Uni-threaded simulation
//
ThreadSafe Function G3F_Process_TPL(pw, yw, xw)
	Wave pw, yw, xw
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Involked template G3F_Process_TPL("+nameofwave(pw)+", "+ nameofwave(yw)+", "+ nameofwave(xw)+" ]"
	yw = 1.212121212
	return nan
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for Uni-threaded simulation with ExtraParam wave
//
ThreadSafe Function G3F_Process_Ep_TPL(pw, yw, xw, wEP)
	Wave pw, yw, xw, wEP
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Involked template G3F_Process_Ep_TPL("+nameofwave(pw)+", "+ nameofwave(yw)+", "+ nameofwave(xw)+" ]"
	yw = 1.212121212
	return nan
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Template function for Uni-threaded simulation with ExtraParam wave, X and Z parametric waves
//
ThreadSafe Function G3F_Process_EpXZp_TPL(pw, yw, xw, wEP, wXZp)
	Wave pw, yw, xw, wEP
	wave wXZp // X-Y parametric wave
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Involked template G3F_Process_EpXZp_TPL("+nameofwave(pw)+", "+ nameofwave(yw)+", "+ nameofwave(xw)+" ]"
	yw = 1.212121212
	return nan
end



//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//  Locals  access
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Proxy function for multi-threaded calculations using G3F_ProcLocal_TPL template from G3F module
//

function G3F_ProcLocal_MT_Proxy(LocFuncName, options, useThreads,  NPoints, NRows, NCols, NLays, RPO, CPO, LPO, LRPO, LCPO, NRVar, NCVar, NLVar, NLRVar, NLCVar, ColNumWave, wY, wRClb, wCClb, wLClb, wGP, wRP, wCP, wLP, wLRP, wLCP, wEPN, wXZpN, wSim, dbgKeep, dbgSave)
	string LocFuncName
	variable options
	variable useThreads
	variable NPoints
	variable NRows
	variable NCols
	variable NLays
	variable RPO
	variable NRVar
	variable NCVar
	variable CPO 
	wave ColNumWave;
	wave wY // calculated Y wave
	wave wCClb // Column calibration in original data, usually time or concentration
	wave wRClb // Row calibration in original data, usually wavelength
	wave wLClb // Layer calibration in original data, usually another parameter
	wave wGP // global parameters wave, always starts with 0
	wave wRP // Row parameters wave
	wave wCP // Col parameters wave
	string wEPN // name of extra params wave or none
	string wXZpN // names of X-Z parametric wave; wEP must be used   
	wave wLP // Layer parameters wave
	variable NLVar // number of LayLoc variables (per row)
	variable LPO // offset in wLP to the first Lay Parameter 

	wave wLRP // LayRow parameters wave
	variable NLRVar // number of LayRowLoc variables (per row)
	variable LRPO // offset in wLRP to the first Lay Parameter 

	wave wLCP // LayCol parameters wave
	variable NLCVar // number of LayColLoc variables (per row)
	variable LCPO // offset in wLCP to the first Lay Parameter 
	variable dbgKeep, dbgSave
	
	wave wSim // Simulated process

	// structure cannot be passed across module, so it has to be assembeld here...	
	STRUCT G3F_Proxy_Param_Set p
	wave p.ColNumWave=ColNumWave; // column number limiting wave or null
	p.options=options // misc flags
	p.useThreads=useThreads // how many threads to use
	p.NPoints=NPoints // total number of points in data wave
	p.NRows=NRows // total number of fitted rows in data wave
	p.NCols=NCols // total number of fitted columns in data wave
	p.NLays=NLays // total number of fitted layers in data wave
	p.NRVar=NRVar // number of RowLoc variables (per row)
	p.NCVar=NCVar // number of ColLoc variables (per column)
	p.NLVar=NLVar // number of LayLoc variables (per row)
	p.NLRVar=NLRVar // number of LayRowLoc variables (per row)
	p.NLCVar=NLCVar // number of LayColLoc variables (per row)
	p.debugKeep =  dbgKeep; 
	p.debugSave = dbgSave; 

	STRUCT G3F_Linear_Var_3D_Set v
	v.R.PO=RPO // offset in wRP to the first Row Parameter 
	v.C.PO=CPO; // offset in wCP to the first Col Parameter
	v.L.PO=LPO // offset in wLP to the first Lay Parameter 
	v.LR.PO=LRPO // offset in wLRP to the first Lay Parameter 
	v.LC.PO=LCPO // offset in wLCP to the first Lay Parameter 
	wave v.G.wP=wGP // global parameters wave, always starts with 0
	wave v.R.wP=wRP // Row parameters wave
	wave v.C.wP=wCP // Col parameters wave
	wave v.L.wP=wLP // Layer parameters wave
	wave v.LR.wP=wLRP // LayRow parameters wave
	wave v.LC.wP=wLCP // LayCol parameters wave
	

	STRUCT G3F_Comm_Param_Set c 
	wave c.wY=wY // calculated Y wave
	wave c.wCClb=wCClb // Column calibration in original data, usually time or concentration
	wave c.wRClb=wRClb // Row calibration in original data, usually wavelength
	wave c.wLClb=wLClb // Layer calibration in original data, maybe trial or composition
	wave c.wEP = $wEPN;	// name of extra params wave or null wave
	wave c.wXZp = $wXZpN; // names of X-Z parametric wave or null wave; requires wEP 
	wave c.wSim = wSim;

 	
	variable pStart, cStart
	
   	if (options & 1) // first row is special
   		if (options & 2) // do first rowl but use fixed params
   		else // just skip first col locals
   		endif
   		pStart = 1;
   	else
   		pStart = 0;
   	endif
   	
   	if (options & 4) // first col is special
   		if (options & 8) // do first col but use fixed params
   			// to do calculation we need local col parameter for the first col; this is not included in col locals
   		else // just skip first col locals
   		endif
   		cStart = 1
   	else
   		cStart = 0
   	endif
   	
	if (WaveExists(c.wEP)) // With extra parameter wave
		if (WaveExists(c.wXZp))
				if (G3F_ProcLocal_EpXZp_3D_MT_Proxy(p, c, v, $LocFuncName, pStart, cStart))
					return 1;
				elseif (G3F_ProcLocal_EpXZp_2D_MT_Proxy(p, c, v, $LocFuncName, pStart, cStart))
					return 1;
				elseif (G3F_ProcLocal_EpXZp_1D_MT_Proxy( p, c, v,  $LocFuncName, pStart, cStart))
					return 1
				endif
		else // no wXp or wZp
			if (G3F_ProcLocal_Ep_3D_MT_Proxy( p, c, v, $LocFuncName, pStart, cStart))
				return 1;
			elseif (G3F_ProcLocal_Ep_2D_MT_Proxy( p, c, v, $LocFuncName, pStart, cStart))
				return 1;
			elseif (G3F_ProcLocal_Ep_1D_MT_Proxy( p, c, v,  $LocFuncName, pStart, cStart))
				return 1
			endif
		endif 
	else // without extra parameter wave
		if (G3F_ProcLocal_3D_MT_Proxy( p, c, v, $LocFuncName, pStart, cStart))
			return 1;
		elseif (G3F_ProcLocal_2D_MT_Proxy( p, c, v,  $LocFuncName, pStart, cStart))
			return 1;
		elseif (G3F_ProcLocal_1D_MT_Proxy( p, c, v,  $LocFuncName, pStart, cStart))
			return 1;
		endif
	endif
	
	return 0;
end






//###################################################################
//
//******************************************************************
//  Local Guesses funciton
//****************************************************************** 
// Provide a guess function for each fit function or their group
//
//************ 
// local gusees for 1D functions
//
//~~~~~~~~~~~~~~~~~~~
// Proxy
function G3F_Guess_Proxy(guessFuncName, lpw, yw, xw) 
	string guessFuncName
	wave &lpw
	wave yw
	wave xw

	FUNCREF G3FLocGs_Generic SetGuessFunction = $guessFuncName;
	SetGuessFunction(lpw, yw, xw)
end


// Generic / template guess function
//
function G3FLocGs_Generic(lpw, yw, xw) 
	wave &lpw // parameters wave to set
	wave yw; // data to fitted
	wave xw; // calibration data
	// locals parameters wave is a matrix with dimensions [rows to be fit]X[number of local variables for each row]
	// Generic form initializes paramteres to non-zero
	// this initialization may not work well for anything but simplest functions
	lpw=0.5 + (p / DimSize(lpw, 0))
	Print "GFLocGs_Generic Invoked "
end

//************ 
// local gusees for 2D functions
//
//~~~~~~~~~~~~~~~~~~~
// Proxy
function G3F_Guess2D_Proxy(guessFuncName, lpw, yw, xw, zv) 
	string guessFuncName
	wave &lpw
	wave yw
	wave xw
	variable zv; // calibration data - second dimension, usually along rows

	FUNCREF G3F_LocGs_Generic_2D SetGuessFunction = $guessFuncName;
	SetGuessFunction(lpw, yw, xw, zv)
end

function G3F_LocGs_Generic_2D(lpw, yw, xw, zv) 
	wave &lpw // parameters wave to set
	wave yw; // data to fitted
	wave xw; // calibration data - first dimenzion, usually along columns
	variable zv; // calibration data - second dimension, usually along rows
	// Same as GFLocGs_Generic but passes along second calibration wave	
	lpw = 0.5 + (p / DimSize(lpw, 0))
	Print "GFLocGs_Generic_2D Invoked "
end


//***********************************************************************************************
//function  G3F_AutoCycle_Proxy(AutoCycleFuncS, cycle)
//	string AutoCycleFuncS
//	variable cycle;
//	FUNCREF G3FAutoCycle_TPL cyceFunc = $AutoCycleFuncS;
//	
//	cyceFunc(cycle)
//end 

//***********************************************************************************************
//function  G3FAutoCycle_TPL(cycle)
//	variable cycle;
//	abort "AutoCyclePrototype is called. This should not happen (BUG)";
//end 
//
//









//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_ProcLocal_3D_MT_Proxy(p, c, v, theLocFunc3D, pStart, cStart)

	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v
	FUNCREF G3F_ProcLocal_3D_TPL theLocFunc3D 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc3D);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif
	
	STRUCT G3F_Folded_Var_3D_Set f
	if (!G3F_Fold_3D_params(p, v, f))
		return 0;
	endif 
		
	variable result = 1
	variable LinFrom = 0, LinTo
	variable aRow;
	variable aLay;
	
	variable saved = p.debugSave ? 0 : 1;
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aLay = 0; aLay < p.NLays; aLay+=1)
			for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
				for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
					LinTo = LinFrom + p.ColNumWave[aRow] -1;
					// strcutures cannot be passed across preemptive threads, so, we a stuck with passing waves and values 
					ThreadStart mt, t,  theLocFunc3D(c.wY, c.wSim, c.wCClb, c.wRClb, c.wLClb, f.wG, f.wC, f.wR, f.wL, f.wLC, f.wLR, aRow, aLay, LinFrom + cStart, LinTo) 
					if (!saved)
						G3F_Proxy_report(0, c, f, funcInfo,  aRow, aLay, LinFrom + cStart, LinTo, prxSim | prx3D )				
						saved = 1;
					endif 
					LinFrom = LinTo +1; 
				endfor // threads
				do
					tgs= ThreadGroupWait(mt, 20)
				while( tgs != 0 )
				if (G3F#CheckError(" ProcLocal_3D fit function "+StringByKey("NAME", funcInfo)))
					result = 0;
					break;
				endif				
			endfor
		endfor
		variable dummy= ThreadGroupRelease(mt)
		if (p.debugSave)
			G3F_Proxy_report(1, c, f, funcInfo,  aRow, aLay, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prxSim | prx3D ) 					
		endif
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			// since MT version cannot pass structures by reference, we will use same mechanism here.
			theLocFunc3D(c.wY, c.wSim, c.wCClb, c.wRClb, c.wLClb, f.wG, f.wC, f.wR, f.wL, f.wLC, f.wLR, aRow, aLay, LinFrom + cStart, LinTo)	
			if (!saved)
				G3F_Proxy_report(0, c, f, funcInfo,  aRow, aLay, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo,  prxSim | prx3D )	 					
				saved = 1;
			endif

			if (G3F#CheckError(" ProcLocal_2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	if (!p.debugKeep)
		G3F_Purge_Fold_Waves (f)
	endif
	return result	
end










//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_ProcLocal_Ep_3D_MT_Proxy(p, c, v, theLocFunc3D, pStart, cStart)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v
	FUNCREF G3F_ProcLocal_Ep_3D_TPL theLocFunc3D 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc3D);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif
	
	STRUCT G3F_Folded_Var_3D_Set f
	if (!G3F_Fold_3D_params(p, v, f))
		return 0;
	endif 
		
	variable result = 1
	variable LinFrom = 0, LinTo
	variable aRow;
	variable aLay;
	
	variable saved = p.debugSave ? 0 : 1;
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aLay = 0; aLay < p.NLays; aLay+=1)
			for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
				for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
					LinTo = LinFrom + p.ColNumWave[aRow] -1;
					// strcutures cannot be passed across preemptive threads, so, we a stuck with passing waves and values 
					ThreadStart mt, t,  theLocFunc3D(c.wY, c.wSim, c.wCClb, c.wRClb, c.wLClb, f.wG, f.wC, f.wR, f.wL, f.wLC, f.wLR, aRow, aLay, LinFrom + cStart, LinTo, c.wEP) 
					if (!saved)
						G3F_Proxy_report(0, c, f, funcInfo,  aRow, aLay, LinFrom + cStart, LinTo, prxSim | prx3D | prxEP)				
						saved = 1;
					endif 
					LinFrom = LinTo +1; 
				endfor // threads
				do
					tgs= ThreadGroupWait(mt, 20)
				while( tgs != 0 )
				if (G3F#CheckError(" ProcLocal_Ep_3D fit function "+StringByKey("NAME", funcInfo)))
					result = 0;
					break;
				endif				
			endfor
		endfor
		variable dummy= ThreadGroupRelease(mt)
		if (p.debugSave)
			G3F_Proxy_report(1, c, f, funcInfo,  aRow, aLay, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo,  prxSim | prx3D | prxEP) 					
		endif
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			// since MT version cannot pass structures by reference, we will use same mechanism here.
			theLocFunc3D(c.wY, c.wSim, c.wCClb, c.wRClb, c.wLClb, f.wG, f.wC, f.wR, f.wL, f.wLC, f.wLR, aRow, aLay, LinFrom + cStart, LinTo, c.wEP)	
			if (!saved)
				G3F_Proxy_report(0, c, f, funcInfo,  aRow, aLay, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo,  prxSim | prx3D | prxEP)	 					
				saved = 1;
			endif

			if (G3F#CheckError(" ProcLocal_Ep_2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	if (!p.debugKeep)
		G3F_Purge_Fold_Waves (f)
	endif
	return result	
end






//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//

function G3F_ProcLocal_EpXZp_3D_MT_Proxy(p, c, v, theLocFunc3D, pStart, cStart)
		   
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v
	FUNCREF G3F_ProcLocal_EpXZp_3D_TPL theLocFunc3D 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc3D);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif
	
	STRUCT G3F_Folded_Var_3D_Set f
	if (!G3F_Fold_3D_params(p, v, f))
		return 0;
	endif 
		
	variable result = 1
	variable LinFrom = 0, LinTo
	variable aRow;
	variable aLay;
	
	variable saved = p.debugSave ? 0 : 1;
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aLay = 0; aLay < p.NLays; aLay+=1)
			for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
				for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
					LinTo = LinFrom + p.ColNumWave[aRow] -1;
					// strcutures cannot be passed across preemptive threads, so, we a stuck with passing waves and values 
					ThreadStart mt, t,  theLocFunc3D(c.wY, c.wSim, c.wCClb, c.wRClb, c.wLClb, f.wG, f.wC, f.wR, f.wL, f.wLC, f.wLR, aRow, aLay, LinFrom + cStart, LinTo, c.wEP, c.wXZP) 
					if (!saved)
						G3F_Proxy_report(0, c, f, funcInfo,  aRow, aLay, LinFrom + cStart, LinTo, prxSim | prx3D | prxEP | prxXZP)				
						saved = 1;
					endif 
					LinFrom = LinTo +1; 
				endfor // threads
				do
					tgs= ThreadGroupWait(mt, 20)
				while( tgs != 0 )
				if (G3F#CheckError(" ProcLocal_EpXZp_3D fit function "+StringByKey("NAME", funcInfo)))
					result = 0;
					break;
				endif				
			endfor
		endfor
		variable dummy= ThreadGroupRelease(mt)
		if (p.debugSave)
			G3F_Proxy_report(1, c, f, funcInfo,  aRow, aLay, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prxSim |prx3D | prxEP | prxXZP) 					
		endif
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			// since MT version cannot pass structures by reference, we will use same mechanism here.
			theLocFunc3D(c.wY, c.wSim, c.wCClb, c.wRClb, c.wLClb, f.wG, f.wC, f.wR, f.wL, f.wLC, f.wLR, aRow, aLay, LinFrom + cStart, LinTo, c.wEP, c.wXZP)	
			if (!saved)
				G3F_Proxy_report(0, c, f, funcInfo,  aRow, aLay, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prxSim |prx3D | prxEP | prxXZP)	 					
				saved = 1;
			endif

			if (G3F#CheckError(" ProcLocal_EpXZp_2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	if (!p.debugKeep)
		G3F_Purge_Fold_Waves (f)
	endif
	return result	
end






//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_ProcLocal_2D_MT_Proxy(p, c, v, theLocFunc2D, pStart, cStart)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v
	FUNCREF G3F_ProcLocal_2D_TPL theLocFunc2D 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc2D);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif
	
	STRUCT G3F_Folded_Var_3D_Set f
	if (!G3F_Fold_2D_params(p, v, f))
		return 0;
	endif 
		
	variable result = 1
	variable LinFrom = 0, LinTo
	variable aRow;
	
	variable saved = p.debugSave ? 0 : 1;
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
			for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
				LinTo = LinFrom + p.ColNumWave[aRow] -1;
				ThreadStart mt, t,  theLocFunc2D(c.wY, c.wSim, c.wCClb, c.wRClb,  f.wG, f.wC, f.wR, aRow, LinFrom + cStart, LinTo)
				if (!saved)
					G3F_Proxy_report(0, c, f, funcInfo,  aRow, NaN, LinFrom + cStart, LinTo, prxSim )				
					saved = 1;
				endif 
				LinFrom = LinTo +1; 
			endfor // threads
			do
				tgs= ThreadGroupWait(mt, 20)
			while( tgs != 0 )
			if (G3F#CheckError(" ProcLocal_2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
		endfor
		variable dummy= ThreadGroupRelease(mt)
		if (p.debugSave)
			G3F_Proxy_report(1, c, f, funcInfo,  aRow, NaN,  LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prxSim ) 					
		endif
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			theLocFunc2D(c.wY, c.wSim, c.wCClb, c.wRClb,  f.wG, f.wC, f.wR, aRow, LinFrom + cStart, LinTo)
			if (!saved)
				G3F_Proxy_report(0, c, f, funcInfo,  aRow, NaN, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prxSim )	 					
				saved = 1;
			endif
			if (G3F#CheckError(" ProcLocal_2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	if (!p.debugKeep)
		G3F_Purge_Fold_Waves (f)
	endif
	return result
end


/
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_ProcLocal_Ep_2D_MT_Proxy(p, c, v, theLocFunc2D, pStart, cStart)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v
	FUNCREF G3F_ProcLocal_Ep_2D_TPL theLocFunc2D 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc2D);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif
	
	STRUCT G3F_Folded_Var_3D_Set f
	if (!G3F_Fold_2D_params(p, v, f))
		return 0;
	endif 
		
	variable result = 1
	variable LinFrom = 0, LinTo
	variable aRow;
	
	variable saved = p.debugSave ? 0 : 1;
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
			for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
				LinTo = LinFrom + p.ColNumWave[aRow] -1;
				ThreadStart mt, t,  theLocFunc2D(c.wY, c.wSim, c.wCClb, c.wRClb,  f.wG, f.wC, f.wR, aRow, LinFrom + cStart, LinTo, c.wEP)
				if (!saved)
					G3F_Proxy_report(0, c, f, funcInfo,  aRow, NaN, LinFrom + cStart, LinTo, prxSim | prxEP )				
					saved = 1;
				endif 
				LinFrom = LinTo +1; 
			endfor // threads
			do
				tgs= ThreadGroupWait(mt, 20)
			while( tgs != 0 )
			if (G3F#CheckError(" ProcLocal_Ep_2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
		endfor
		variable dummy= ThreadGroupRelease(mt)
		if (p.debugSave)
			G3F_Proxy_report(1, c, f, funcInfo,  aRow, NaN,  LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prxSim | prxEP) 					
		endif
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			theLocFunc2D(c.wY, c.wSim, c.wCClb, c.wRClb,  f.wG, f.wC, f.wR, aRow, LinFrom + cStart, LinTo, c.wEP)
			if (!saved)
				G3F_Proxy_report(0, c, f, funcInfo,  aRow, NaN, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prxSim | prxEP)	 					
				saved = 1;
			endif
			if (G3F#CheckError(" ProcLocal_Ep_2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	if (!p.debugKeep)
		G3F_Purge_Fold_Waves (f)
	endif
	return result	
end



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_ProcLocal_EpXZp_2D_MT_Proxy(p, c, v, theLocFunc2D, pStart, cStart)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v
	FUNCREF G3F_ProcLocal_EpXZp_2D_TPL theLocFunc2D 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc2D);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif
	
	STRUCT G3F_Folded_Var_3D_Set f
	if (!G3F_Fold_2D_params(p, v, f))
		return 0;
	endif 
		
	variable result = 1
	variable LinFrom = 0, LinTo
	variable aRow;
	
	variable saved = p.debugSave ? 0 : 1;
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
			for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
				LinTo = LinFrom + p.ColNumWave[aRow] -1;
				ThreadStart mt, t,  theLocFunc2D(c.wY, c.wSim, c.wCClb, c.wRClb,  f.wG, f.wC, f.wR, aRow, LinFrom + cStart, LinTo, c.wEP, c.wXZP)
				if (!saved)
					G3F_Proxy_report(0, c, f, funcInfo,  aRow, NaN, LinFrom + cStart, LinTo, prxSim | prxEP | prxXZP)				
					saved = 1;
				endif 
				LinFrom = LinTo +1; 
			endfor // threads
			do
				tgs= ThreadGroupWait(mt, 20)
			while( tgs != 0 )
			if (G3F#CheckError(" ProcLocal_EpXZp_2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
		endfor
		variable dummy= ThreadGroupRelease(mt)
		if (p.debugSave)
			G3F_Proxy_report(1, c, f, funcInfo,  aRow, NaN,  LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prxSim | prxEP | prxXZP) 					
		endif
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			theLocFunc2D(c.wY, c.wSim, c.wCClb, c.wRClb,  f.wG, f.wC, f.wR, aRow, LinFrom + cStart, LinTo, c.wEP, c.wXZP)
			if (!saved)
				G3F_Proxy_report(0, c, f, funcInfo,  aRow, NaN, LinTo -p.ColNumWave[aRow]+1 + cStart, LinTo, prxSim | prxEP| prxXZP)	 					
				saved = 1;
			endif
			if (G3F#CheckError(" ProcLocal_EpXZp_2D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	if (!p.debugKeep)
		G3F_Purge_Fold_Waves (f)
	endif
	return result	
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_ProcLocal_1D_MT_Proxy(p, c, v, theLocFunc, pStart, cStart)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v
	FUNCREF G3F_ProcLocal_1D_TPL theLocFunc 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif
		
	variable result = 1
	variable LinFrom = 0, LinTo
	variable aRow;
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
			for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
				LinTo = LinFrom + p.ColNumWave[aRow] -1;
				ThreadStart mt, t,  theLocFunc(c.wY, c.wSim, c.wCClb, c.wRClb, v.G.wP, v.C.wP, v.C.PO, v.R.wP, v.R.PO + p.NRVar * aRow, LinFrom + cStart, LinTo)
				LinFrom = LinTo +1; 
			endfor // threads
			do
				tgs= ThreadGroupWait(mt, 20)
			while( tgs != 0 )
			if (G3F#CheckError(" ProcLocal_1D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
		endfor
		variable dummy= ThreadGroupRelease(mt)
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			theLocFunc(c.wY, c.wSim, c.wCClb, c.wRClb, v.G.wP, v.C.wP, v.C.PO, v.R.wP, v.R.PO + p.NRVar * aRow, LinFrom + cStart, LinTo)
			if (G3F#CheckError(" ProcLocal_1D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	return result	
end
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_ProcLocal_Ep_1D_MT_Proxy(p, c, v, theLocFunc, pStart, cStart)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v

	FUNCREF G3F_ProcLocal_Ep_1D_TPL theLocFunc 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif
		
	variable LinFrom = 0, LinTo
	variable result = 1
	variable aRow = pStart;
		
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
			for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
				LinTo = LinFrom + p.ColNumWave[aRow] -1;
				ThreadStart mt, t,  theLocFunc(c.wY, c.wSim, c.wCClb, c.wRClb, v.G.wP, v.C.wP, v.C.PO, v.R.wP, v.R.PO + p.NRVar * aRow, LinFrom + cStart, LinTo, c.wEP)
				LinFrom = LinTo +1; 
			endfor // threads
			do
				tgs= ThreadGroupWait(mt, 20)
			while( tgs != 0 )
			if (G3F#CheckError(" ProcLocal_Ep_1D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
		endfor
		variable dummy= ThreadGroupRelease(mt)
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			theLocFunc(c.wY, c.wSim, c.wCClb, c.wRClb, v.G.wP, v.C.wP, v.C.PO, v.R.wP, v.R.PO + p.NRVar * aRow, LinFrom + cStart, LinTo, c.wEP)
			if (G3F#CheckError(" ProcLocal_Ep_1D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	
	return result	
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function G3F_ProcLocal_EpXZp_1D_MT_Proxy(p, c, v, theLocFunc, pStart, cStart)
	STRUCT G3F_Proxy_Param_Set &p
	STRUCT G3F_Comm_Param_Set &c 
	STRUCT G3F_Linear_Var_3D_Set &v

	FUNCREF G3F_ProcLocal_EpXZp_1D_TPL theLocFunc 
	variable pStart, cStart

	string funcInfo = FUNCREFInfo(theLocFunc);
	if ( stringmatch(StringByKey("ISPROTO", funcInfo),"1"))
		return 0;
	endif
		
	variable LinFrom = 0, LinTo
	variable aRow = pStart;
	variable result = 1
		
	if (p.useThreads > 1) // Multi-thread
		variable t, tgs, mt= ThreadGroupCreate(p.useThreads)
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; )
			for(t=0; (t<p.useThreads) && (aRow< p.NPoints); t+=1, aRow+=1)
				LinTo = LinFrom + p.ColNumWave[aRow] -1;
					ThreadStart mt, t,  theLocFunc(c.wY, c.wSim, c.wCClb, c.wRClb, v.G.wP, v.C.wP, v.C.PO, v.R.wP, v.R.PO + p.NRVar * aRow, LinFrom + cStart, LinTo, c.wEP, c.wXZp)
					LinFrom = LinTo +1; 
			endfor // threads
			do
				tgs= ThreadGroupWait(mt, 20)
			while( tgs != 0 )
			if (G3F#CheckError(" ProcLocal_EpXZp_1D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
		endfor
		variable dummy= ThreadGroupRelease(mt)
	else  //Single thread
		for ( aRow = pStart ; aRow < p.NPoints && result > 0; aRow+=1)
			LinTo = LinFrom + p.ColNumWave[aRow] -1;
			theLocFunc(c.wY, c.wSim, c.wCClb, c.wRClb, v.G.wP, v.C.wP, v.C.PO, v.R.wP, v.R.PO + p.NRVar * aRow, LinFrom + cStart, LinTo, c.wEP, c.wXZp)
			if (G3F#CheckError(" ProcLocal_EpXZp_1D fit function "+StringByKey("NAME", funcInfo)))
				result = 0;
				break;
			endif				
			LinFrom = LinTo +1; 
		endfor	
	endif 
	
	return result	
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Template function for locals calculation process fitting
//
ThreadSafe Function G3F_ProcLocal_3D_TPL(wY, wSim, wCClb,  wRClb, wLClb, wGP, wCP2D, wRP2D, wLP2D, wLCP2D, wLRP2D, row, lay, dFrom, dTo)
wave wY // calculated Y wave
wave wSim // Simulated process
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wLClb // Layer calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP2D // a 2D Row parameters wave row - fitted point, col - param #
wave wCP2D //  a 2D Row parameters wave column - fitted point, col - param #
wave wLP2D // 
wave wLRP2D // 
wave wLCP2D //  
variable row // current row
variable lay // current layer
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template  G3F_ProcLocal_3D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo) invoked"
	wY = 1.212121212
	return nan
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Template function for locals calculation process fitting
//
ThreadSafe Function G3F_ProcLocal_Ep_3D_TPL(wY, wSim, wCClb, wRClb, wLClb, wGP, wCP2D, wRP2D, wLP2D, wLCP2D, wLRP2D, row, lay,  dFrom, dTo, wEP)
wave wY // calculated Y wave
wave wSim // Simulated process
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wLClb // Layer calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP2D // a 2D Row parameters wave row - fitted point, col - param #
wave wCP2D //  a 2D Row parameters wave column - fitted point, col - param #
wave wLP2D // 
wave wLRP2D // 
wave wLCP2D //  
variable row // current row
variable lay // current layer
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
wave wEP
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template G3F_ProcLocal_Ep_3D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo, wEP) invoked"
	wY = 1.212121212
	return nan
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Template function for locals calculation process fitting
//
ThreadSafe Function G3F_ProcLocal_EpXZp_3D_TPL(wY, wSim, wCClb,wRClb, wLClb, wGP, wCP2D, wRP2D, wLP2D, wLCP2D, wLRP2D, row, lay,  dFrom, dTo, wEP, wXZp)
wave wY // calculated Y wave
wave wSim // Simulated process
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wLClb // Layer calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP2D // a 2D Row parameters wave row - fitted point, col - param #
wave wCP2D //  a 2D Row parameters wave column - fitted point, col - param #
wave wLP2D // 
wave wLRP2D // 
wave wLCP2D //  
variable row // current row
variable lay // current layer
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
wave wEP // Extra parameters wave
wave wXZp // X-Y parametric wave
	print "Template G3F_ProcLocal_EpXZp_3D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP2D, wRP2D,  dFrom, dTo, wEP, wXZp) invoked"
	wY = 1.212121212
	return nan
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Template function for locals calculation process fitting
//
ThreadSafe Function G3F_ProcLocal_2D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP2D, wRP2D, row, dFrom, dTo)
wave wY // calculated Y wave
wave wSim // Simulated process
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP2D // a 2D Row parameters wave row - fitted point, col - param #
wave wCP2D //  a 2D Row parameters wave column - fitted point, col - param #
variable row // current row
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template  G3F_ProcLocal_2D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo) invoked"
	wY = 1.212121212
	return nan
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Template function for locals calculation process fitting
//
ThreadSafe Function G3F_ProcLocal_Ep_2D_TPL(wY, wSim, wCClb,  wRClb, wGP, wCP2D, wRP2D, row, dFrom, dTo, wEP)
wave wY // calculated Y wave
wave wSim // Simulated process
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP2D // a 2D Row parameters wave row - fitted point, col - param #
wave wCP2D //  a 2D Row parameters wave column - fitted point, col - param #
variable row // current row
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
wave wEP
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template G3F_ProcLocal_Ep_2D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo, wEP) invoked"
	wY = 1.212121212
	return nan
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Template function for locals calculation process fitting
//
ThreadSafe Function G3F_ProcLocal_EpXZp_2D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP2D, wRP2D, row, dFrom, dTo, wEP, wXZp)
wave wY // calculated Y wave
wave wSim // Simulated process
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP2D // a 2D Row parameters wave row - fitted point, col - param #
wave wCP2D //  a 2D Row parameters wave column - fitted point, col - param #
variable row // current row
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
wave wEP // Extra parameters wave
wave wXZp // X-Y parametric wave
	print "Template G3F_ProcLocal_EpXZp_2D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP2D, wRP2D,  dFrom, dTo, wEP, wXZp) invoked"
	wY = 1.212121212
	return nan
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Template function for locals calculation process fitting
//
ThreadSafe Function G3F_ProcLocal_1D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo)
wave wY // calculated Y wave
wave wSim // Simulated process
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP // Row parameters wave
variable RPO; // offset in wRP to the first Row Parameter
wave wCP // Col parameters wave
variable CPO; // offset in wCP to the first Col Parameter
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template  G3F_ProcLocal_1D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo) invoked"
	wY = 1.212121212
	return nan
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Template function for locals calculation process fitting
//
ThreadSafe Function G3F_ProcLocal_Ep_1D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo, wEP)
wave wY // calculated Y wave
wave wSim // Simulated process
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP // Row parameters wave
variable RPO; // offset in wRP to the first Row Parameter
wave wCP // Col parameters wave
variable CPO; // offset in wCP to the first Col Parameter
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
wave wEP
//	DoAlert 0, "Matrix Fit is running the template fitting function for some reason."
	print "Template G3F_ProcLocal_Ep_1D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo, wEP) invoked"
	wY = 1.212121212
	return nan
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Template function for locals calculation process fitting
//
ThreadSafe Function G3F_ProcLocal_EpXZp_1D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo, wEP, wXZp)
wave wY // calculated Y wave
wave wSim // Simulated process
wave wCClb // Column calibration in original data, usually time or concentration
wave wRClb // Row calibration in original data, usually wavelength
wave wGP // global parameters wave, always starts with 0
wave wRP // Row parameters wave
variable RPO; // offset in wRP to the first Row Parameter
wave wCP // Col parameters wave
variable CPO; // offset in wCP to the first Col Parameter
variable dFrom // start offset in of data calculated here in the linear data wave 
variable dTo // end offset in of data calculated here in the linear data wave 
wave wEP // Extra parameters wave
wave wXZp // X-Y parametric wave
	print "Template G3F_ProcLocal_EpXZp_1D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo, wEP, wXZp) invoked"
	wY = 1.212121212
	return nan
end