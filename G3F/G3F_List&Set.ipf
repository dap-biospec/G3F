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

strconstant G3F_Direct_TPL_list 			= "G3F_Direct_1D_TPL;G3F_Direct_2D_TPL;G3F_Direct_3D_TPL";
strconstant G3F_DirectEp_TPL_list 		= "G3F_Direct_Ep_1D_TPL;G3F_Direct_Ep_2D_TPL;G3F_Direct_Ep_3D_TPL";
strconstant G3F_DirectEpXZp_TPL_list 	= "G3F_Direct_EpXZp_1D_TPL;G3F_Direct_EpXZp_2D_TPL;G3F_Direct_EpXZp_3D_TPL";
strconstant G3FProcLoc_TPL_list 			= "G3F_ProcLocal_1D_TPL;G3F_ProcLocal_2D_TPL;G3F_ProcLocal_3D_TPL";
strconstant G3FProcLocEp_TPL_list 		= "G3F_ProcLocal_Ep_1D_TPL;G3F_ProcLocal_Ep_2D_TPL;G3F_ProcLocal_Ep_3D_TPL";
strconstant G3FProcLocEpXZp_TPL_list 	= "G3F_ProcLocal_EpXZp_1D_TPL;G3F_ProcLocal_EpXZp_2D_TPL;G3F_ProcLocal_EpXZp_3D_TPL";

//******************************************************************************
Function FixPopupControl(RefStrName, ListStr, control)
	string RefStrName, control, ListStr 
	variable index = 1;
	
	RefStrName =cG3FControl + ":"+RefStrName
	if (strlen(RefStrName))
			string ItemName;
			SVAR thatStr = $RefStrName;
			if (strlen(thatStr))
				variable itemType = exists(thatStr);
				if (itemType == 1) // wave
					wave RefWave = $thatStr
					index = WhichListItem(nameofwave(RefWave), ListStr)
				else
					itemType = exists("ProcGlobal#"+thatStr)
					switch (itemType) 
						case 3: // function 
						case 4: // operation
						case 6: // user-defined function
							index = WhichListItem(thatStr, ListStr)
							break;
						default:
							thatStr = "";
							print RefStrName,"=[",thatStr, "] could not be identified"
							index = -1;
					endswitch
				endif
			else
				index = -1
			endif
			if (index == -1)
				thatStr="";
				index =1
			else
				index +=1;
			endif
	endif
 	PopupMenu $control win=G3FitPanel, mode = index 
end

Function PopupControlProc_TPL(valStr)
	string valStr;
end


Function FixPopupControlProc(RefStrName, ListStr, control, procN)
	string RefStrName, control, ListStr 
	FUNCREF PopupControlProc_TPL procN;
	FixPopupControl(RefStrName, ListStr, control);	
	
	SVAR thatStr = $cG3FControl + ":"+RefStrName;
	procN(thatStr);
	
end 
//---------------------------------------------------------------------
Function FixCheckControl(RefStrName, Flag, control)
	string RefStrName, control
	variable Flag 
	variable index = 1;
	
	RefStrName =cG3FControl + ":"+RefStrName
	if (strlen(RefStrName) && exists(RefStrName)==2)
			NVAR BitField = $RefStrName
			variable checked = BitField & Flag;
			
			CheckBox $control value=checked
			
	endif
end

//----------------------------
//
Function CheckFuncProto(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
end

//----------------------------
//
Function CheckFuncProcProto(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
end

	
//---------------------------------------------------------------------
Function FixFuncCheckControl(RefStrName, Flag, ctrlName, popupName)
	string RefStrName, ctrlName,popupName
	variable Flag 
	variable index = 1;
	
	RefStrName =cG3FControl + ":"+RefStrName
	if (strlen(RefStrName) && exists(RefStrName)==2)
			NVAR BitField = $RefStrName
			variable checked = BitField & Flag;
			CheckBox $ctrlName value=checked
			if (strlen(popupName))
				if (checked)
					PopupMenu $popupName win=G3FitPanel, disable=1
				else
					PopupMenu $popupName win=G3FitPanel, disable=0
				endif
			endif
	endif
end
	
//---------------------------------------------------------------------
//
Function FixProcCheckControl(RefStrName, Flag, ctrlName, ProcFunc)
	string RefStrName, ctrlName
	variable Flag 
	FUNCREF CheckFuncProcProto ProcFunc;
	variable index = 1;
	
	RefStrName =cG3FControl + ":"+RefStrName
	if (strlen(RefStrName) && exists(RefStrName)==2)
			NVAR BitField = $RefStrName
			variable checked = BitField & Flag;
			CheckBox $ctrlName value=checked
			STRUCT WMCheckboxAction cba;
			cba.ctrlName = ctrlName;
			cba.checked = checked ? 1 : 0;
			cba.eventCode = 0xFF;
			ProcFunc(cba);	
	endif
end



//---------------------------------------------------------------------
//
structure FuncInfoT
	string NAME;
	string TYPE;
	string THREAD_SAFE;
	string RETURNTYPE;
	variable N_PARAMS;
	string PARAM_TYPES;
	
	string INDEPENDENTMODULE;
	string MODULE;
	string PROCWIN;
	string SPECIAL;
	string SUBTYPE;
	variable PROCLINE;
	string VISIBLE;
	variable N_OPT_PARAMS;
endstructure
	
//---------------------------------------------------------------------
//
Function GetFunctionInfo(FName, isGlobal, s)
	string FName
	variable isGLobal;
	STRUCT FuncInfoT &s;

	string FInfo;
	if (isGlobal)
		FInfo = FunctionInfo("ProcGlobal#"+FName);
	else
		FInfo = FunctionInfo(FName);
	endif
	
	s.NAME = stringbykey("NAME", FInfo);
	s.TYPE = stringbykey("TYPE", FInfo);
	s.THREAD_SAFE = stringbykey("THREADSAFE", FInfo);
	s.RETURNTYPE = stringbykey("RETURNTYPE", FInfo);
	s.N_PARAMS = numberbykey("N_PARAMS", FInfo);
	s.PARAM_TYPES = "";
	
	variable i;
	for (i = 0 ; i < s.N_PARAMS; i++)
		s.PARAM_TYPES += stringbykey("PARAM_"+num2str(i)+"_TYPE", FInfo);
		if (i < s.N_PARAMS-1)
			s.PARAM_TYPES+=";";
		endif
	endfor
	
	s.INDEPENDENTMODULE = stringbykey("INDEPENDENTMODULE", FInfo);
	s.MODULE = stringbykey("MODULE", FInfo);
	s.PROCWIN = stringbykey("PROCWIN", FInfo);
	s.SPECIAL = stringbykey("SPECIAL", FInfo);
	s.SUBTYPE = stringbykey("SUBTYPE", FInfo);
	s.PROCLINE = numberbykey("PROCLINE", FInfo);
	s.VISIBLE = stringbykey("VISIBLE", FInfo);
	s.N_OPT_PARAMS = numberbykey("N_OPT_PARAMS", FInfo);	

end

//---------------------------------------------------------------------
//
Function CheckFunctionRef(theFName, refFName, subtypeS)
	string theFName
	string refFName
	string subtypeS
	
	STRUCT FuncInfoT theFInfo;
	STRUCT FuncInfoT refFInfo;
	
	GetFunctionInfo(theFName, 1, theFInfo);	
	GetFunctionInfo(refFName, 1, refFInfo);	
	
	if (	cmpstr(theFInfo.THREAD_SAFE,refFInfo.THREAD_SAFE) || \
			cmpstr(theFInfo.RETURNTYPE, refFInfo.RETURNTYPE) || \
			theFInfo.N_PARAMS != refFInfo.N_PARAMS || \
			cmpstr(theFInfo.PARAM_TYPES,refFInfo.PARAM_TYPES) || \
			theFInfo.N_OPT_PARAMS != refFInfo.N_OPT_PARAMS || \
			(strlen(subtypeS) && cmpStr(theFInfo.SUBTYPE, subtypeS)) 	)
		return 0;
	endif
	return 1;
end

//---------------------------------------------------------------------
//
Function CheckFunctionRefList(theFName, refFNameList, subtypeS)
	string theFName
	string refFNameList
	string subtypeS

	string refFName
	STRUCT FuncInfoT theFInfo;
	STRUCT FuncInfoT refFInfo;
	variable i = 0;
	
	GetFunctionInfo(theFName, 1, theFInfo);	
	if (strlen(subtypeS) && cmpStr(theFInfo.SUBTYPE, subtypeS)) 	
		return 0;
	endif 
	
	do
		refFName= StringFromList(i++,refFNameList)
		if (strlen(refFName) == 0 )
			return 0;
		endif
		GetFunctionInfo(refFName, 1, refFInfo);	

		if (	cmpstr(theFInfo.THREAD_SAFE,refFInfo.THREAD_SAFE) || \
				cmpstr(theFInfo.RETURNTYPE, refFInfo.RETURNTYPE) || \
				theFInfo.N_PARAMS != refFInfo.N_PARAMS || \
				cmpstr(theFInfo.PARAM_TYPES,refFInfo.PARAM_TYPES) || \
				theFInfo.N_OPT_PARAMS != refFInfo.N_OPT_PARAMS  \
				)
			continue; // try next
		endif
		// it's a match
		return 1;		
	while (1)	// exit is via return statement
end 

//#########################################
// Process function popup procedure
//

Function SimFunctionMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	SVAR FName=$cG3FControl+":SimFunction"
	
//	has is changed?
	if (!cmpstr(FName, "_none_") || (strlen(FName)==0))
		FName = "";
	endif 
	variable reset = 0;
	if (!cmpstr(popStr, "_none_") || !strlen(popStr)) // _none_ was selected
			if (strlen(FName) > 0)
				reset = 1;
			endif
			FName = "";
			CheckBox KeepLastSimCheckBox win=G3FitPanel, disable=1
			CheckBox MTProcessCheckBox win=G3FitPanel, disable=1
			CheckBox ReuseProcessCheckBox win=G3FitPanel, disable=1
			SetVariable SetNumSimVar win=G3FitPanel, disable =1
	else  // anything other than _none_ 
			if (strlen(FName) == 0)
				reset = 1;
			endif
			FName = popStr;
			if ( CheckFunctionRefList(FName, "G3F_Process_TPL;G3F_Process_Ep_TPL;G3F_Process_EpXZp_TPL", "Fitfunc"))
				CheckBox MTProcessCheckBox win=G3FitPanel, disable=1
			elseif ( CheckFunctionRefList(FName, "G3F_Process_MT_TPL;G3F_Process_Ep_MT_TPL;G3F_Process_EpXZp_MT_TPL", "Fitfunc"))
				CheckBox MTProcessCheckBox win=G3FitPanel, disable=0
			endif

			CheckBox KeepLastSimCheckBox win=G3FitPanel, disable=0
			CheckBox ReuseProcessCheckBox win=G3FitPanel, disable=0
			SetVariable SetNumSimVar win=G3FitPanel, disable =0
	endif
	if (reset)
		SVAR UserFitFunc=$cG3FControl+":FitFunction"
		UserFitFunc = "";
		PopupMenu FitFunctionPopup win=G3FitPanel, mode = 1
		SVAR CorrFunc=$cG3FControl+":CorrFunction"
		CorrFunc = "";
		PopupMenu CorrFunctionPopup win=G3FitPanel, mode = 1
	endif
	return 0
End



//---------------------------------------------------------------------
// List sim functions
//
Function/S ListMatrixSimFunctions()
	
	string theList="_none_;",  XFuncs
	
	execute /Z "ProcGlobal#G3F_FunctionList2SVar(\""+cG3FControl+":t_GlobList\", \"*\", \";\",\"KIND:2,WIN:[ProcGlobal]\")"
	SVAR UserFuncs = $cG3FControl+":t_GlobList"

	string FName;
	string FInfo
	string FSubtype
	variable i,nArgs;

	SVAR AddtlDataWN=$cG3FControl+":AddtlDataWN"
	SVAR XRefWN=$cG3FControl+":XRefWave";
	SVAR ZRefWN=$cG3FControl+":ZRefWave";

	do
		FName= StringFromList(i,UserFuncs)
		if (strlen(FName) == 0 )
			break
		endif
		
		if(strlen(AddtlDataWN) <=0)
			if ( CheckFunctionRefList(FName, "G3F_Process_TPL;G3F_Process_MT_TPL", "Fitfunc"))
				theList += FName+";"
			endif
		else
			if (strlen(XRefWN) || strlen(ZRefWN) )
				if ( CheckFunctionRefList(FName, "G3F_Process_EpXZp_TPL;G3F_Process_EpXZp_MT_TPL", "Fitfunc"))
					theList += FName+";"
				endif
			else
				if ( CheckFunctionRefList(FName, "G3F_Process_Ep_TPL;G3F_Process_Ep_MT_TPL", "Fitfunc"))
					theList += FName+";"
				endif
			endif
		endif
		i += 1
	while (1)	// exit is via break statement
	if (strlen(theList) == 0)
		theList = "\\M1(No Sim Functions"
	endif
	
	return theList
end


//---------------------------------------------------------------------
//
Function FixMatrixSimFunctions()
	SVAR UserSimFunc= $cG3FControl+":SimFunction"
	SimFunctionMenuProc("SimFunctionPopup", -1, UserSimFunc);
	FixPopupControl("SimFunction", ListMatrixSimFunctions(), "SimFunctionPopup");
end


//#########################################
// Matrix function popup procedure
//
Function FitFunctionMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	SVAR UserFitFunc=$cG3FControl+":FitFunction"
	SVAR UserCorrFunc=$cG3FControl+":CorrFunction"

	if (!cmpstr(popStr, ">> choose fit function! <<"))
		UserFitFunc ="";
	else
		if (strlen(UserCorrFunc) && !cmpstr(UserCorrFunc, popStr))
			DoAlert 0, "Funciton "+popstr+" has been already selected for post-processing"
			UserFitFunc = "";
			PopupMenu FitFunctionPopup win=G3FitPanel, mode = 1
		else
			UserFitFunc = popStr;
		endif
	endif

End


//---------------------------------------------------------------------
// List matrix functions
//
Function/S ListG3FitFunctions()
	string theList="", XFuncs
	SVAR UserFitFunc=$cG3FControl+":FitFunction"
	SVAR UserCorrFunc=$cG3FControl+":CorrFunction"

	if (strlen(UserFitFunc) == 0)
		theList=">> choose fit function! <<;";
	endif
	
	execute /Z "ProcGlobal#G3F_FunctionList2SVar(\""+cG3FControl+":t_GlobList\", \"!G3F_*\", \";\",\"KIND:2,WIN:[ProcGlobal]\")"
	SVAR UserFuncs = $cG3FControl+":t_GlobList"

	string FName;
	string FInfo
	string FSubtype
	variable i,nArgs;

	SVAR UserSimFunc=$cG3FControl+":SimFunction"
	SVAR AddtlDataWN=$cG3FControl+":AddtlDataWN"
	SVAR XRefWN=$cG3FControl+":XRefWave";
	SVAR ZRefWN=$cG3FControl+":ZRefWave";


	do
		FName= StringFromList(i,UserFuncs)
		if (strlen(FName) == 0 )
			break
		endif
		if (cmpstr(FName, UserCorrFunc))
			if ((strlen(UserSimFunc)<=0) && (strlen(AddtlDataWN) <=0))
				if ( CheckFunctionRefList(FName, G3F_Direct_TPL_list , "Fitfunc"))
					theList += FName+";"
				endif
			elseif ((strlen(UserSimFunc)<=0) && (strlen(AddtlDataWN) > 0))
				if (strlen(XRefWN) || strlen(ZRefWN) )
					if ( CheckFunctionRefList(FName, G3F_DirectEpXZp_TPL_list , "Fitfunc"))
						theList += FName+";"
					endif
				else
					if ( CheckFunctionRefList(FName, G3F_DirectEp_TPL_list , "Fitfunc"))
						theList += FName+";"
					endif
				endif
			elseif ((strlen(UserSimFunc)> 0) && (strlen(AddtlDataWN) <= 0))
				if ( CheckFunctionRefList(FName, G3FProcLoc_TPL_list, "Fitfunc"))
					theList += FName+";"
				endif
			else
				if (strlen(XRefWN) || strlen(ZRefWN) )
					if ( CheckFunctionRefList(FName, G3FProcLocEpXZp_TPL_list, "Fitfunc"))
						theList += FName+";"
					endif
				else
					if ( CheckFunctionRefList(FName, G3FProcLocEp_TPL_list, "Fitfunc"))
						theList += FName+";"
					endif
				endif
			endif
		endif

		i += 1
	while (1)	// exit is via break statement
	if (strlen(theList) == 0)
		theList = "\\M1(No Fit Functions"
	endif
	return theList
end

//******************************************************************************
//
Function CorrFunctionMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	SVAR UserSimFunc=$cG3FControl+":SimFunction"
	SVAR UserCorrFunc=$cG3FControl+":CorrFunction"
	SVAR UserFitFunc=$cG3FControl+":FitFunction"
	NVAR CorrNoSim=$cG3FControl+":CorrNoSim"
	
	CorrNoSim = 1	
	if (!cmpstr(popStr, "_none_") || (strlen(popStr)==0))
		UserCorrFunc = "";
	else
		if (strlen(UserFitFunc) && !cmpstr(UserFitFunc, popStr))
			DoAlert 0, "Post-processing function should be different from Fitting function"
			UserCorrFunc = "";
			PopupMenu CorrFunctionPopup win=G3FitPanel, mode = 1
		else
			// Check the use is SimWave in Corr function
			if (	CheckFunctionRefList(popStr, G3FProcLoc_TPL_list +";"+G3FProcLocEp_TPL_list +";"+G3FProcLocEpXZp_TPL_list, "Fitfunc"))
				if (strlen(UserSimFunc)<=0)
					DoAlert 0, "Specify Process function first if  Post-processing function needs to use process wave"
					UserCorrFunc = "";
					PopupMenu CorrFunctionPopup win=G3FitPanel, mode = 1
				else
					CorrNoSim = 0; // Selected function uses process wave
					UserCorrFunc = popStr;
				endif
			else // Everything else is a direct calulation 
				UserCorrFunc = popStr;
			endif
		endif
	endif
	return 0
End


//---------------------------------------------------------------------
//
Function/S ListCorrFunctions()
	string theList="_none_;", XFuncs
	SVAR CorrFunc=$cG3FControl+":CorrFunction"
	
	execute /Z "ProcGlobal#G3F_FunctionList2SVar(\""+cG3FControl+":t_GlobList\", \"*\", \";\",\"KIND:2\")"
	SVAR UserFuncs = $cG3FControl+":t_GlobList"

	string FName;
	string FInfo
	string FSubtype
	variable i,nArgs;

	SVAR UserSimFunc=$cG3FControl+":SimFunction"
	SVAR UserFitFunc=$cG3FControl+":FitFunction"
	SVAR AddtlDataWN=$cG3FControl+":AddtlDataWN"
	SVAR XRefWN=$cG3FControl+":XRefWave";
	SVAR ZRefWN=$cG3FControl+":ZRefWave";
	do
		FName= StringFromList(i,UserFuncs)
		if (strlen(FName) == 0)
			break
		endif
		if ( cmpstr(FName, UserFitFunc))
			if ((strlen(UserSimFunc)<=0) && (strlen(AddtlDataWN) <=0))
				if (CheckFunctionRefList(FName, G3F_Direct_TPL_list, "Fitfunc"))
					theList += FName+";"
				endif
			elseif ((strlen(UserSimFunc)<=0) && (strlen(AddtlDataWN) > 0))
				if (strlen(XRefWN) || strlen(ZRefWN) )
					if (CheckFunctionRefList(FName, G3F_DirectEpXZp_TPL_list, "Fitfunc"))
						theList += FName+";"
					endif
				else
					if (CheckFunctionRefList(FName, G3F_DirectEp_TPL_list, "Fitfunc"))
						theList += FName+";"
					endif
				endif
			elseif ((strlen(UserSimFunc)> 0) && (strlen(AddtlDataWN) <= 0))
				if (	CheckFunctionRefList(FName, G3FProcLoc_TPL_list +";"+G3F_Direct_TPL_list, "Fitfunc"))
					theList += FName+";"
				endif
			else
				if (strlen(XRefWN) || strlen(ZRefWN) )
					if (	CheckFunctionRefList(FName, G3FProcLocEpXZp_TPL_list +";"+G3F_DirectEpXZp_TPL_list, "Fitfunc"))
						theList += FName+";"
					endif
				else
					if (	CheckFunctionRefList(FName, G3FProcLocEp_TPL_list +";"+G3F_DirectEp_TPL_list, "Fitfunc"))
						theList += FName+";"
					endif
				endif
			endif
		endif
		i += 1
	while (1)	// exit is via break statement
	if (strlen(theList) == 0)
		theList = "\\M1(No Fit Functions"
	endif
	return theList
end

//******************************************************************************
//
//******************************************************************************


Function/S ChooseMatrixWaveMenuContents()
	SVAR MWaveS = $cG3FControl+":MatrixWave"

	execute /Z "ProcGlobal#G3F_WaveList2SVar(\""+cG3FControl+":t_GlobList\", \"*\", \";\",\"DIMS:2\")"
	SVAR theContents = $cG3FControl+":t_GlobList"
	string s2DWaves = theContents;
	execute /Z "ProcGlobal#G3F_WaveList2SVar(\""+cG3FControl+":t_GlobList\", \"*\", \";\",\"DIMS:3\")"
	if (strlen(theContents)>0)
		if (strlen(s2DWaves)>0)
			s2DWaves += ";"
		endif
		s2DWaves += theContents
	endif 

	if (strlen(s2DWaves))
		if (strlen(MWaveS) == 0)
			s2DWaves=">> choose matrix <<;" + s2DWaves;
		endif
		return s2DWaves
	else
		return ">> none found <<"
	endif
end


//---------------------------------------------------------------------
//
Function ChooseMatrixPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR MWaveS = $cG3FControl+":MatrixWave"
	if (!cmpstr(popStr, ">> choose matrix <<") || !cmpstr(popStr, ">> none found <<"))
		MWaveS = "";
		return 0;
	endif	

	// store full name in MWave
	String CDF=GetDataFolder(1)
	MWaveS = CDF + popStr


	NVAR XFrom = $cG3FControl+":XFrom"
	NVAR XTo = $cG3FControl+":XTo"
	NVAR ZFrom = $cG3FControl+":ZFrom"
	NVAR ZTo = $cG3FControl+":ZTo"

	variable MatrixRows=DimSize($MWaveS,0)
	variable MatrixCols 

	if (WaveType($MWaveS)>0) // selected wave is numerical 
		MatrixCols =DimSize($MWaveS,1)
		PopupMenu ChooseZClbWPopup disable=0
		PopupMenu ChooseColLimWavePopup disable=0
	else // selected is a list of wave name pairs
		MatrixCols = CheckNamePairs($MWaveS)
		if (MatrixCols <= 0 ) // set does not conform!
			MWaveS = "_unconforming_set_";
			MtrxResetWaves()	
			return -1;		
		endif
		PopupMenu ChooseZClbWPopup disable=1
		PopupMenu ChooseColLimWavePopup disable=1
		Checkbox AverageXChBox disable=1 
	endif
	if ((XTo > MatrixRows -1) || (XTo == 0) || (XTo==XFrom))
		XTo = MatrixRows-1
	endif
	if (XFrom > XTo)
		XFrom = 0
	endif
	if ((ZTo > MatrixCols -1) || (ZTo == 0) || (ZTo == ZFrom))
		ZTo = MatrixCols-1
	endif
	if (ZFrom > ZTo)
		ZFrom = 0
	endif
End


//******************************************************************************
//
Function ChooseZMaskPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR RefStr = $cG3FControl+":ZMask"
	if (cmpstr(popStr, ">> choose Col(Z) mask <<")  && cmpstr(popStr, ">> none found <<"))
		RefStr = GetDataFolder(1) + popStr
	else
		RefStr = "";
	endif	
End
//~~~~~~~~~~~~~~~~~~~~~~~
//
Function/S ChooseZMaskPopContents()
	SVAR RefStr = $cG3FControl+":ZMask"

	execute /Z "ProcGlobal#G3F_WaveList2SVar(\""+cG3FControl+":t_GlobList\", \"*\", \";\",\"DIMS:1\")"
	SVAR theContents = $cG3FControl+":t_GlobList"
	return "_none_;" +theContents
end
//~~~~~~~~~~~~~~~~~~~~~~~
//
Function ChooseZClbWPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR RefStr = $cG3FControl+":ZWave"
	if (cmpstr(popStr, ">> choose Col(Z) calibration <<")  && cmpstr(popStr, ">> none found <<"))
		RefStr = GetDataFolder(1) + popStr
	else
		RefStr = "";
	endif	
End
//~~~~~~~~~~~~~~~~~~~~~~~
//
Function/S ChooseZClbWPopContents()
	SVAR RefStr = $cG3FControl+":ZWave"

	execute /Z "ProcGlobal#G3F_WaveList2SVar(\""+cG3FControl+":t_GlobList\", \"*\", \";\",\"\")"
	SVAR theContents = $cG3FControl+":t_GlobList"
	if (strlen(theContents))
		if (strlen(RefStr) == 0)
			theContents=">> choose Col(Z) calibration <<;" + theContents;
		endif
		return theContents
	else
		return ">> none found <<"
	endif
end//~~~~~~~~~~~~~~~~~~~~~~~
//
Function ChooseZRefWPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr


	SVAR UserFitFunc=$cG3FControl+":FitFunction"
	SVAR UserCorrFunc=$cG3FControl+":CorrFunction"
	SVAR UserSimFunc=$cG3FControl+":SimFunction"
	SVAR ZRefWave = $cG3FControl+":ZRefWave"
	SVAR XRefWave = $cG3FControl+":XRefWave"
	
//	has is changed?
	if (!cmpstr(ZRefWave, "_none_") || (strlen(ZRefWave)==0))
		ZRefWave = "";
	endif 
	variable reset = 0;
	if (!cmpstr(popStr, "_none_") || !strlen(popStr)) // _none_ was selected
			if (strlen(ZRefWave) > 0 && strlen(XRefWave)==0) // ZRefWave is already zero and XRefW is being set to zero
				reset = 1;
			endif
			ZRefWave = "";
	else  // anything other than _none_ 
			if (strlen(ZRefWave) == 0 &&  strlen(XRefWave) == 0) // both were zero
				reset = 1;
			endif
			ZRefWave = popStr;
	endif
	if (reset)
		UserFitFunc = "";
		PopupMenu FitFunctionPopup win=G3FitPanel, mode = 1
		UserCorrFunc = "";
		PopupMenu CorrFunctionPopup win=G3FitPanel, mode = 1
		UserSimFunc = "";
		PopupMenu SimFunctionPopup win=G3FitPanel, mode = 1
	endif

	String CDF=GetDataFolder(1)
	if (cmpstr(popStr, "_none_") == 0)
		ZRefWave = "";
	else
		ZRefWave = CDF + popStr
	endif
End


//~~~~~~~~~~~~~~~~~~~~~~~
//
Function/S ChooseZRefWPopContents()

	SVAR RefStr = $cG3FControl+":ZRefWave"
	execute /Z "ProcGlobal#G3F_WaveList2SVar(\""+cG3FControl+":t_GlobList\", \"*\", \";\",\"\")"
	SVAR theContents = $cG3FControl+":t_GlobList"
	
	return "_none_;" +theContents
end

//******************************************************************************

Function ChooseXMaskPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String CDF=GetDataFolder(1)
	SVAR XWave = $cG3FControl+":XMask"
	if (cmpstr(popStr, "_none_") == 0)
		XWave = "";
	else
		XWave = CDF + popStr
	endif
End
//~~~~~~~~~~~~~~~~~~~~~~~
//
Function/S ChooseXMaskPopContents()

	SVAR RefStr = $cG3FControl+":XMask"
	execute /Z "ProcGlobal#G3F_WaveList2SVar(\""+cG3FControl+":t_GlobList\", \"*\", \";\",\"DIMS:1\")"
	SVAR theContents = $cG3FControl+":t_GlobList"
	return "_none_;" +theContents
end

//******************************************************************************


Function ChooseXClbWPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String CDF=GetDataFolder(1)
	SVAR XWave = $cG3FControl+":XWave"
	if (cmpstr(popStr, "_none_") == 0)
		XWave = "";
	else
		XWave = CDF + popStr
	endif
End
//~~~~~~~~~~~~~~~~~~~~~~~
//
Function/S ChooseXClbWPopContents()

	SVAR RefStr = $cG3FControl+":XWave"
	execute /Z "ProcGlobal#G3F_WaveList2SVar(\""+cG3FControl+":t_GlobList\", \"*\", \";\",\"DIMS:1\")"
	SVAR theContents = $cG3FControl+":t_GlobList"
	
	return "_none_;" +theContents
end

//******************************************************************************


Function ChooseLMaskPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String CDF=GetDataFolder(1)
	SVAR XWave = $cG3FControl+":LMask"
	if (cmpstr(popStr, "_none_") == 0)
		XWave = "";
	else
		XWave = CDF + popStr
	endif
End
//~~~~~~~~~~~~~~~~~~~~~~~
//
Function/S ChooseLMaskPopContents()

	SVAR RefStr = $cG3FControl+":LMask"
	execute /Z "ProcGlobal#G3F_WaveList2SVar(\""+cG3FControl+":t_GlobList\", \"*\", \";\",\"DIMS:1\")"
	SVAR theContents = $cG3FControl+":t_GlobList"
	return "_none_;" +theContents
end

//~~~~~~~~~~~~~~~~~~~~~~~

Function ChooseLClbWPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String CDF=GetDataFolder(1)
	SVAR XWave = $cG3FControl+":LWave"
	if (cmpstr(popStr, "_none_") == 0)
		XWave = "";
	else
		XWave = CDF + popStr
	endif
End
//~~~~~~~~~~~~~~~~~~~~~~~
//
Function/S ChooseLClbWPopContents()

	SVAR RefStr = $cG3FControl+":LWave"
	execute /Z "ProcGlobal#G3F_WaveList2SVar(\""+cG3FControl+":t_GlobList\", \"*\", \";\",\"DIMS:1\")"
	SVAR theContents = $cG3FControl+":t_GlobList"
	return "_none_;" +theContents
end

//~~~~~~~~~~~~~~~~~~~~~~~
//
Function ChooseXRefWPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr


	SVAR UserFitFunc=$cG3FControl+":FitFunction"
	SVAR UserCorrFunc=$cG3FControl+":CorrFunction"
	SVAR UserSimFunc=$cG3FControl+":SimFunction"
	SVAR XRefWave = $cG3FControl+":XRefWave"
	SVAR ZRefWave = $cG3FControl+":ZRefWave"
	
//	has is changed?
	if (!cmpstr(XRefWave, "_none_") || (strlen(XRefWave)==0))
		XRefWave = "";
	endif 
	variable reset = 0;
	if (!cmpstr(popStr, "_none_") || !strlen(popStr)) // _none_ was selected
			if (strlen(XRefWave) > 0 && strlen(ZRefWave)==0) // ZRefWave is already zero and XRefW is being set to zero
				reset = 1;
			endif
			XRefWave = "";
	else  // anything other than _none_ 
			if (strlen(XRefWave) == 0 &&  strlen(ZRefWave) == 0) // both were zero
				reset = 1;
			endif
			XRefWave = popStr;
	endif
	if (reset)
		UserFitFunc = "";
		PopupMenu FitFunctionPopup win=G3FitPanel, mode = 1
		UserCorrFunc = "";
		PopupMenu CorrFunctionPopup win=G3FitPanel, mode = 1
		UserSimFunc = "";
		PopupMenu SimFunctionPopup win=G3FitPanel, mode = 1
	endif

	String CDF=GetDataFolder(1)
	if (cmpstr(popStr, "_none_") == 0)
		XRefWave = "";
	else
		XRefWave = CDF + popStr
	endif
End



//~~~~~~~~~~~~~~~~~~~~~~~
//
Function/S ChooseXRefWPopContents()

	SVAR RefStr = $cG3FControl+":XRefWave"
	execute /Z "ProcGlobal#G3F_WaveList2SVar(\""+cG3FControl+":t_GlobList\", \"*\", \";\",\"\")"
	SVAR theContents = $cG3FControl+":t_GlobList"
	
	return "_none_;" +theContents
end

//******************************************************************************

Function ChooseColLimWavePopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String CDF=GetDataFolder(1)
	SVAR ColLimWave = $cG3FControl+":ColLimWaveName"
	if (cmpstr(popStr, "_none_") == 0)
		ColLimWave = "_none_";
	else
		ColLimWave = CDF + popStr
	endif
End

//~~~~~~~~~~~~~~~~~~~~~~~
//
Function/S ChooseColLimPopupContents()

	SVAR RefStr = $cG3FControl+":ColLimWaveName"
	execute /Z "ProcGlobal#G3F_WaveList2SVar(\""+cG3FControl+":t_GlobList\", \"*\", \";\",\"DIMS:1\")"
	SVAR theContents = $cG3FControl+":t_GlobList"
	return "_none_;" +theContents
end


//******************************************************************************

Function AddtlDataPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	AddtlDataPopMenu(popStr);

end

//~~~~~~~~~~~~~~~~~~~~~~~
//
Function AddtlDataPopMenu(popStr) 
	String popStr
	SVAR UserFitFunc=$cG3FControl+":FitFunction"
	SVAR UserCorrFunc=$cG3FControl+":CorrFunction"
	SVAR UserSimFunc=$cG3FControl+":SimFunction"
	SVAR AddtlDataWN = $cG3FControl+":AddtlDataWN"
	
//	has is changed?
	if (!cmpstr(AddtlDataWN, "_none_") || (strlen(AddtlDataWN)==0))
		AddtlDataWN = "";
	endif 
	variable reset = 0;
	if (!cmpstr(popStr, "_none_") || !strlen(popStr)) // _none_ was selected
			if (strlen(AddtlDataWN) > 0)
				reset = 1;
			endif
			AddtlDataWN = "";
	else  // anything other than _none_ 
			if (strlen(AddtlDataWN) == 0)
				reset = 1;
			endif
			AddtlDataWN = popStr;
	endif
	if (reset)
		UserFitFunc = "";
		PopupMenu FitFunctionPopup win=G3FitPanel, mode = 1
		UserCorrFunc = "";
		PopupMenu CorrFunctionPopup win=G3FitPanel, mode = 1
		UserSimFunc = "";
		PopupMenu SimFunctionPopup win=G3FitPanel, mode = 1
	endif

	String CDF=GetDataFolder(1)
	if (!cmpstr(AddtlDataWN, "_none_") || (strlen(AddtlDataWN)==0))
		AddtlDataWN = "";
		PopupMenu ChooseZRefWPopup win=G3FitPanel, disable=1
		PopupMenu ChooseXRefWPopup win=G3FitPanel, disable=1
	else
		AddtlDataWN = CDF + popStr
		PopupMenu ChooseZRefWPopup win=G3FitPanel, disable=0
		PopupMenu ChooseXRefWPopup win=G3FitPanel, disable=0
	endif
End

//~~~~~~~~~~~~~~~~~~~~~~~
//
Function/S AddtlDataPopupContents()

	SVAR RefStr = $cG3FControl+":AddtlDataWN"
	execute /Z "ProcGlobal#G3F_WaveList2SVar(\""+cG3FControl+":t_GlobList\", \"*\", \";\",\"\")"
	SVAR theContents = $cG3FControl+":t_GlobList"
	return "_none_;" +theContents
end



//#########################################
//
//---------------------------------------------------------------------
//
Function RecycleGuessesCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	
	if (cba.eventCode == 2)
		variable aFlag = str2num(GetUserData(cba.win, cba.ctrlName, "flag")) 
		string aCtrl = GetUserData(cba.win, cba.ctrlName, "list") 
		if (cba.checked)
			PopupMenu $aCtrl win=G3FitPanel, disable=1
		else
			PopupMenu $aCtrl win=G3FitPanel, disable=0
		endif
		string fieldName = cG3FControl+":"+GetUserData(cba.win, cba.ctrlName, "field") 
		if (exists(fieldName) == 2)
			NVAR VarField = $fieldName 
			VarField = cba.checked ? (VarField | aFlag) : (VarField & ~aFlag)
		endif
	endif
End


//---------------------------------------------------------------------
//
Function StdCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	
	if (cba.eventCode == 2)
		variable aFlag = str2num(GetUserData(cba.win, cba.ctrlName, "flag")) 
		string fieldName = cG3FControl+":"+GetUserData(cba.win, cba.ctrlName, "field") 
		if (exists(fieldName) == 2)
			NVAR VarField = $fieldName 
			VarField = cba.checked ? (VarField | aFlag) : (VarField & ~aFlag)
		endif
	endif
End

//*******************************
//
//*******************************
//-------------------------------------------
//Local rows Guesses function popup procdure
//
Function RowGuessMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	string /G $cG3FControl+":SetRowGuessFunction"
	SVAR SetRowGuessFunction=$cG3FControl+":SetRowGuessFunction"
	SetRowGuessFunction = popStr
End

// List local Row Guesses functions
//
Function/S ListRowGuessFunctions()
	execute /Z "ProcGlobal#G3F_FunctionList2SVar(\""+cG3FControl+":t_GlobList\", \"GFRLoc*\", \";\",\"KIND:2,WIN:[ProcGlobal]\")"
	SVAR UserFuncs = $cG3FControl+":t_GlobList"
	
	return "_none_;"+UserFuncs
end

//-------------------------------------------
//Local column  Guesses function popup procdure
//
Function ColGuessMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string /G $cG3FControl+":SetColGuessFunction"
	SVAR SetColGuessFunction=$cG3FControl+":SetColGuessFunction"
	SetColGuessFunction = popStr
End


// List local Column Guesses functions
//
Function/S ListColGuessFunctions()
	execute /Z "ProcGlobal#G3F_FunctionList2SVar(\""+cG3FControl+":t_GlobList\", \"GFCLoc*\", \";\",\"KIND:2,WIN:[ProcGlobal]\")"
	SVAR UserFuncs = $cG3FControl+":t_GlobList"

	return "_none_;"+UserFuncs
end

//-------------------------------------------
//Local Layer  Guesses function popup procdure
//
Function LayGuessMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string /G $cG3FControl+":SetLayGuessFunction"
	SVAR GuessFunctionN=$cG3FControl+":SetLayGuessFunction"
	GuessFunctionN = popStr
End


// List local Layer Guesses functions
//
Function/S ListLayGuessFunctions()
	execute /Z "ProcGlobal#G3F_FunctionList2SVar(\""+cG3FControl+":t_GlobList\", \"GFLLoc*\", \";\",\"KIND:2,WIN:[ProcGlobal]\")"
	SVAR UserFuncs = $cG3FControl+":t_GlobList"

	return "_none_;"+UserFuncs
end

//-------------------------------------------
//Local Layer-Row Guesses function popup procdure
//
Function LayRowGuessMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string /G $cG3FControl+":SetLayRowGuessFunction"
	SVAR GuessFunctionN=$cG3FControl+":SetLayRowGuessFunction"
	GuessFunctionN = popStr
End


// List local LayRower Guesses functions
//
Function/S ListLayRowGuessFunctions()
	execute /Z "ProcGlobal#G3F_FunctionList2SVar(\""+cG3FControl+":t_GlobList\", \"GFLRLoc*\", \";\",\"KIND:2,WIN:[ProcGlobal]\")"
	SVAR UserFuncs = $cG3FControl+":t_GlobList"

	return "_none_;"+UserFuncs
end

//-------------------------------------------
//Local Layer-Col Guesses function popup procdure
//
Function LayColGuessMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string /G $cG3FControl+":SetLayColGuessFunction"
	SVAR GuessFunctionN=$cG3FControl+":SetLayColGuessFunction"
	GuessFunctionN = popStr
End


// List local LayColer Guesses functions
//
Function/S ListLayColGuessFunctions()
	execute /Z "ProcGlobal#G3F_FunctionList2SVar(\""+cG3FControl+":t_GlobList\", \"GFLCLoc*\", \";\",\"KIND:2,WIN:[ProcGlobal]\")"
	SVAR UserFuncs = $cG3FControl+":t_GlobList"

	return "_none_;"+UserFuncs
end



//*******************************************************************************
//
Function MtrxResetWaves()
// WaveX?
//WaveZ?
//DestWave?

end

//*******************************************************************************
//
Function SetVarsButtonProc(ctrlName) : ButtonControl
	String ctrlName
	MrtxMakeGuessList();
End

//*******************************************************************************
//
Function MrtxMakeGuessList([quiet])
	variable quiet
	NVAR NGVar = $cG3FControl+":NumGlobVar"
	NVAR NLVar = $cG3FControl+":NumLayVar"

	variable doReset = 0;

	if (!quiet)
		DoAlert 1, "Reset guess values and labels?" 
		if (V_Flag == 1)
			doReset = 1;
		endif
	endif	
	
	variable result = MakeAGuessList(NGVar, "Guess", "GlobGuessList", "Global vars", doReset)
	if (!result)
		return 0;
	endif
	return result;
End



function MakeAGuessList(NVars, varNameS, ctrlNameS, aLabel, doReset)
	variable NVars;
	string varNameS
	string ctrlNameS;
	string aLabel
	variable doReset
	

	string GuessWaveS = cG3FControl+":"+varNameS +  "ListWave"
	
	variable oldSize = 0
	if (!waveExists($GuessWaveS) || (dimsize($GuessWaveS, 1)!=3))
		Make/N=(NVars, 3)/T/O $GuessWaveS
	else
		oldSize = DimSize($GuessWaveS, 0);
		if (oldSize != NVars)
			redimension /N=(NVars, 3) $GuessWaveS
		endif
	endif
	
	Wave/T GuessListWave = $GuessWaveS
	
	Make/N=(NVars, 3)/O/U/B $cG3FControl+":"+varNameS +"ListSelection"=0
	Wave/U/B GuessListSelection = $cG3FControl+":"+varNameS +"ListSelection"
	
	if (doReset)
		oldSize = 0;
	endif

	Variable i
	
	for (i = oldSize;  i < NVars; i += 1)
		GuessListWave[i][0] = "K"+num2istr(i)
		GuessListWave[i][1] = aLabel+num2istr(i)
		GuessListWave[i][2] = "0"
	endfor
	
	GuessListSelection[][0] = 0			// labels for the coefficients
	GuessListSelection[][1] = 2			// labels for the coefficients
	GuessListSelection[][2] = 2			// editable field to enter initial guesses
	
	SetDimLabel 1,0,'Parm',GuessListWave
	SetDimLabel 1,1,'Label',GuessListWave
	SetDimLabel 1,2,'Guess',GuessListWave
	
	//string ctrlName = name+"List"
	
	ListBox $ctrlNameS,win=G3FitPanel,listWave=GuessListWave, mode=7
	ListBox $ctrlNameS,win=G3FitPanel,selWave=GuessListSelection,editstyle=1
	ListBox $ctrlNameS,win=G3FitPanel,widths={30, 110,70}


	return 1	
	
end

