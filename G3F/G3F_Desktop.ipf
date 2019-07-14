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



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
Function SaveButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if (wintype("G3F_SavePanel") == 0)
				MakeSavePanel()
			else
				DoWindow/F G3F_SavePanel
			endif
			break
	endswitch

	return 0
End

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
Function RestoreButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			if (wintype("G3F_RestorePanel") == 0)
				MakeRestorePanel()
			else
				DoWindow/F G3F_RestorePanel
			endif
			// click code here
			break
	endswitch

	return 0
End


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
Function /S RestoreDesktopList () 
	SVAR DesktopS = $cG3FControl+":Desktop"

	execute /Z "ProcGlobal#G3F_WaveList2SVar(\""+cG3FControl+":t_GlobList\", \"*\", \";\",\"DIMS:2,MINCOLS:2,MAXCOLS:2,TEXT:1\")"
	SVAR theContents = $cG3FControl+":t_GlobList"
	return theContents
end
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
Function /S SaveDesktopList () 
	return "_new_;"+	RestoreDesktopList();
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
Function SaveDesktopPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if (cmpstr(popStr, "_new_"))
				SetVariable NewDesktopName, win=G3F_SavePanel, disable=1 
			else
				SetVariable NewDesktopName, win=G3F_SavePanel, disable=0
			endif
			
			break
	endswitch

	return 0
End

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
Function SaveDesktopButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			switch (DoSaveDesktop())
				case 0:  // cancel operation 
				case 1:  // success 
					DoWindow/K G3F_SavePanel
					break
				case -1: // choose another
					break
			endswitch 
			break
	endswitch

	return 0
End

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
Function CancelSaveButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if (WinType("G3F_SavePanel") == 7)
				DoWindow/K G3F_SavePanel
			endif
			break
	endswitch

	return 0
End

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
Function RestoreDesktopButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			switch (DoRestoreDesktop())
				case 0:  // cancel operation 
				case 1:  // success 
					DoWindow/K G3F_RestorePanel
					break
				case -1: // choose another
					break
			endswitch 
			break
	endswitch

	return 0
End

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
Function CancelRestoreButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if (WinType("G3F_RestorePanel") == 7)
				DoWindow/K G3F_RestorePanel
			endif
			break
	endswitch

	return 0
End

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function SaveSParam(w, key, value)
	wave /T w
	string key
	string value

	variable rowN = dimsize(w, 0)

	InsertPoints /M=0 rowN, 1, w
	w[rowN][0]=key
	w[rowN][1]=value
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function SaveSCtrlParam(w, key, name)
	wave /T w
	string key
	string name

	variable rowN = dimsize(w, 0)

	InsertPoints /M=0 rowN, 1, w
	SVAR value = $cG3FControl+":"+name;
	w[rowN][0]=key
	w[rowN][1]=value
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function SaveNParam(w, key, value)
	wave /T w
	string key
	variable value

	variable rowN = dimsize(w, 0)

	InsertPoints /M=0 rowN, 1, w
	w[rowN][0]=key
	w[rowN][1]=num2str(value)
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function SaveNCtrlParam(w, key, name)
	wave /T w
	string key
	string name

	variable rowN = dimsize(w, 0)

	InsertPoints /M=0 rowN, 1, w
	NVAR value = $cG3FControl+":"+name;
	w[rowN][0]=key
	w[rowN][1]=num2str(value)
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function /T FindSParam(desk, key)
	WAVE /T desk
	string key
	
	variable i;
	for (i=0; i<dimsize(desk,0); i++)
		if (!cmpstr(desk[i][0], key, 0))
			return desk[i][1]; 
		endif 
	endfor  	
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function ReadSParam(s, strName)
	string s
	string strName
	
	if (exists(strName)!=2)
		string /G $strName
	endif
	
	SVAR str  = $strName

	str = s;
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function ReadSCtrlParam(s, strName)
	string s
	string strName
	string fullname =  cG3FControl+":"+ strName

	if (exists(fullname)!=2)
		string /G $fullName
	endif
	
	SVAR str  = $fullname

	str = s;
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function ReadNParam(s, varName, defValue)
	string s
	string varName
	variable defValue
	
	if (exists(varName)!=2)
		variable /G $varName
	endif

	NVAR var = $varName

	variable newVal = str2num	(s);
	if (numtype(newVal))
		var = defValue;
	else
		var = newVal;
	endif
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function ReadNCtrlParam(s, varName, defValue)
	string s
	string varName
	variable defValue
	string fullname = cG3FControl+":"+ varName
	
	if (exists(fullname)!=2)
		variable /G $fullName
	endif

	NVAR var = $fullname

	variable newVal = str2num	(s);
	if (numtype(newVal))
		var = defValue;
	else
		var = newVal;
	endif
end
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//

function ReadCheckBox(s, boxName, defValue)
	string s
	string boxName
	variable defValue

	variable nValue = str2num(s)
	if (numtype(nValue)!=0)
		nValue = defValue
	endif

	CheckBox  $boxName win=G3FitPanel, value=nValue
	end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function ReadStrSetParam(s, setName)
	string s
	string setName

	// CheckBox  $boxName win=G3FitPanel, value=nValue
	SetVariable $setName win=G3FitPanel, value=_STR:s
	
end



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function SaveGlobals(w)
	wave /T w
	variable rowN = dimsize(w, 0)

	wave /T GuessListWave =  $cG3FControl+":GuessListWave"
	wave /T ConstrWave =  $cG3FControl+":ConstraintsGlobalListWave"
	variable Globs = dimsize(GuessListWave, 0)
	variable i
	string VarSet
	for (i=0; i< Globs; i+=1)
		InsertPoints /M=0 rowN+i, 1, w
		VarSet = GuessListWave[i][2]
		VarSet += ";"+ConstrWave[i][2]
		VarSet += ";"+ConstrWave[i][4]
		VarSet += ";"+ConstrWave[i][5]
		VarSet += ";"+ConstrWave[i][6] +";"
		w[rowN+i][0]="GlobalVar_"+num2str(i);
		w[rowN+i][1]=VarSet
		
	endfor
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function RestoreGlobals(key, value)
	string key, value	
	
	variable varN
	sscanf key, "GlobalVar_%i", varN
	if (V_flag!=1)
		return 0;
	endif
	
	wave /T GuessListWave =  $cG3FControl+":GuessListWave"
	wave /T ConstrWave =  $cG3FControl+":ConstraintsGlobalListWave"

	if (varN <= dimsize(GuessListWave, 0))
		GuessListWave[varN][2] = stringFromList(0, value)
	endif
	if (varN <= dimsize(ConstrWave, 0))
		ConstrWave[varN][2] = stringFromList(1, value)
		ConstrWave[varN][4] = stringFromList(2, value)
		ConstrWave[varN][5] = stringFromList(3, value)
		ConstrWave[varN][6]  = stringFromList(4, value)
	endif
	return 1;
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function SaveLocals(w, waveN, dim, name, folder)
	wave /T w
	string waveN, dim, name, folder
	variable rowN = dimsize(w, 0)

	wave /T ConstrWave =  $cG3FControl+":"+waveN+"ListWave"
	variable Lines = dimsize(ConstrWave, 0)
	variable i
	string VarSet
	for (i=0; i< Lines; i+=1)
		InsertPoints /M=0 rowN+i, 1, w
		VarSet = ConstrWave[i][2]
		VarSet += ";"+ConstrWave[i][4]
		VarSet += ";"+ConstrWave[i][5]
		VarSet += ";"+ConstrWave[i][6] +";"
		w[rowN+i][0]=name+num2str(i);
		w[rowN+i][1]=VarSet
	endfor
	
	SVAR dataWaveN = $cG3FControl+":MatrixWave"
	string locWaveN = dataWaveN+"_"+dim+"Loc";
	if (waveexists($locWaveN))
		string backWaveN = folder + ":" + nameofWave($locWaveN);
		duplicate /O $locWaveN $backWaveN
	endif 
	
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function RestoreLocals(key, value, match, waveN, dim, folder)
	string key, value	
	string match, dim, waveN,folder
	
	variable varN
	sscanf key, match+"%i", varN
	if (V_flag!=1)
		return 0;
	endif
	wave /T ConstrWave =  $cG3FControl+":"+waveN+"ListWave"

	if (varN <= dimsize(ConstrWave, 0))
		ConstrWave[varN][2] = stringFromList(0, value)
		ConstrWave[varN][4] = stringFromList(1, value)
		ConstrWave[varN][5] = stringFromList(2, value)
		ConstrWave[varN][6]  = stringFromList(3, value)
	endif
	SVAR dataWaveN = $cG3FControl+":MatrixWave"
	string locWaveN = dataWaveN+"_"+dim+"Loc";
	string backWaveN = folder + ":" + nameofWave($locWaveN);
	if (waveexists($backWaveN))
		duplicate /O $backWaveN $locWaveN 
	else
		killwaves/Z $locWaveN
	endif	
	return 1;
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function SaveConstr(w, wName, fieldName)
	wave /T w
	string wName, fieldName
	variable rowN = dimsize(w, 0)

	wave /T ConstrWave =  $cG3FControl+":"+wName+"ListWave"
	variable Lines = dimsize(ConstrWave, 0)
	variable i
	string VarSet
	for (i=0; i< Lines; i+=1)
		InsertPoints /M=0 rowN+i, 1, w
		VarSet = ConstrWave[i][2]
		VarSet += ";"+ConstrWave[i][4]
		VarSet += ";"+ConstrWave[i][5]
		VarSet += ";"+ConstrWave[i][6] +";"
		w[rowN+i][0]=fieldName+num2str(i);
		w[rowN+i][1]=VarSet
	endfor
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function RestoreConstr(key, value, match, fieldName)
	string key, value	
	string match, fieldName
	
	variable varN
	sscanf key, match+"%i", varN
	if (V_flag!=1)
		return 0;
	endif
	wave /T ConstrWave =  $cG3FControl+":"+fieldName+"ListWave"

	if (varN <= dimsize(ConstrWave, 0))
		ConstrWave[varN][2] = stringFromList(0, value)
		ConstrWave[varN][4] = stringFromList(1, value)
		ConstrWave[varN][5] = stringFromList(2, value)
		ConstrWave[varN][6]  = stringFromList(3, value)
	endif
	return 1;
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//

function SaveFeedback(w, match, name)
	wave /T w
	string match, name
	
	variable rowN = dimsize(w, 0)

	wave /T FeedbackWave =  $cG3FControl+":"+name
	variable Lines = dimsize(FeedbackWave, 0)
	variable i
	string VarSet
	for (i=0; i< Lines; i+=1)
		InsertPoints /M=0 rowN+i, 1, w
		VarSet = FeedbackWave[i][0]
		VarSet += ";"+FeedbackWave[i][1]
		VarSet += ";"+FeedbackWave[i][2]
		VarSet += ";"+FeedbackWave[i][3]+";"
		w[rowN+i][0]=match+num2str(i);
		w[rowN+i][1]=VarSet
	endfor
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function RestoreFeedback(key, value, match, listName, selectName, mode)
	string key, value	
	string match, listName, selectName
	variable mode
		
	variable varN
	sscanf key, match+"%i", varN
	if (V_flag!=1)
		return 0;
	endif
	
	string listWName = cG3FControl+":"+listName
	string selectWName = cG3FControl+":"+selectName
	
	wave /T ListWave = $listWName
	wave SelectWave =  $selectWName
	
	variable haveLines = dimsize(ListWave, 0)
	redimension /N=(havelines+1, -1)  $listWName,  $selectWName

	ListWave[havelines][0] = stringFromList(0, value)
	ListWave[havelines][1] = stringFromList(1, value)
	ListWave[havelines][2] = stringFromList(2, value)
	ListWave[havelines][3]  = stringFromList(3, value)
	SelectWave[havelines][] = mode
	return 1;
end
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//


function DoSaveDesktop ()
	SVAR DesktopS = $cG3FControl+":Desktop"
	controlinfo /W=G3F_SavePanel SaveDesktopPopup
	string saveFolder
	if (cmpstr(S_Value, "_new_")) // a wave name selected
		DesktopS = S_Value;
		// get folder name 
		wave /T Desktop = $DesktopS
		saveFolder = FindSParam(Desktop, "LocFolder");
		if (strlen(saveFolder))
			if (!DataFolderExists(saveFolder))
				DoAlert 0, "Previous variables folder was not found. Please check \"LocFolder\" field in desktop wave."
				return -1;
			endif
		else
			NewDataFolder/O $DesktopS
			saveFolder = DesktopS ; //GetDataFolder(1) + DesktopS	
		endif 
		redimension /N=(0, 2) Desktop
	else // new name selected
		if (strlen(DesktopS)==0)
			DoAlert 0, " Please provide new desktop name"
			return -1;
		endif
		switch (Exists(DesktopS))
			case 0: // not in use
				// check for folder with this name
				if (DataFolderExists(DesktopS))
					DoAlert 0, "A data folder with specified name already exists. Please select another name."
					return -1;
				endif 
 				break;
			case 1:  // existing wave
				DoAlert 1, "Wave with this name already exist. Ovewrite?"
				if (V_flag == 2)
					return -1;
				endif
				break
			default: 
				DoAlert 0, "Specified name is in use for a non-wave object. Please select another name"
				return -1;
			endswitch
		// Can we make wave?
		make /O /T /N=(0,2) $DesktopS
		if (exists(DesktopS)!=1)
			DoAlert 0, "Cannot create  wave with such name. Please modify desktop name and try again"
			return -1
		endif
		wave /T Desktop = $DesktopS
		saveFolder = ":"+DesktopS //GetDataFolder(1) + DesktopS // +"_Vars";
		NewDataFolder/O $saveFolder
	endif
	if (!DataFolderExists(saveFolder))
		DoAlert 0, "Cannot create  folder with such name. Please modify desktop name and try again"
		return -1
	endif	

	// have name and clear to save

 // Data 
	SaveSCtrlParam(Desktop, "setID", "setID")
	SaveSParam(Desktop, "LocFolder", saveFolder)

	SaveNCtrlParam(Desktop, "DimFlags", "DimFlags")
	SaveNCtrlParam(Desktop, "VarFlags", "VarFlags")
	SaveNCtrlParam(Desktop, "MiscFlags", "MiscFlags")

	SaveSCtrlParam(Desktop, "GlobalData",  "AddtlDataWN" )
	SaveSCtrlParam(Desktop, "XRefWave", "XRefWave")
	SaveSCtrlParam(Desktop, "ZRefWave", "ZRefWave")

	SaveSCtrlParam(Desktop, "ProcessFunction", "SimFunction")
	SaveSCtrlParam(Desktop, "FitFunction", "FitFunction")
	SaveSCtrlParam(Desktop, "CorrFunction", "CorrFunction")
	
	
	SaveSCtrlParam(Desktop, "MatrixWave", "MatrixWave")
	SaveSCtrlParam(Desktop, "PerRowLimit", "ColLimWaveName")

	SaveSCtrlParam(Desktop, "XMask", "XMask")
	SaveSCtrlParam(Desktop, "XWave", "XWave")
	SaveNCtrlParam(Desktop, "XFrom", "XFrom")
	SaveNCtrlParam(Desktop, "XTo", "XTo")
	SaveNCtrlParam(Desktop, "XThin", "XThin")

	SaveSCtrlParam(Desktop, "ZMask", "ZMask")
	SaveSCtrlParam(Desktop, "ZWave", "ZWave")
	SaveNCtrlParam(Desktop, "ZFrom", "ZFrom")
	SaveNCtrlParam(Desktop, "ZTo", "ZTo")
	SaveNCtrlParam(Desktop, "ZThin", "ZThin")

	SaveSCtrlParam(Desktop, "LMask", "LMask")
	SaveSCtrlParam(Desktop, "LWave", "LWave")
	SaveNCtrlParam(Desktop, "LFrom", "LFrom")
	SaveNCtrlParam(Desktop, "LTo", 	"LTo")
	SaveNCtrlParam(Desktop, "LThin", "LThin")



	SaveSCtrlParam(Desktop, "RowGuessFunction", "SetRowGuessFunction")
	SaveSCtrlParam(Desktop, "ColGuessFunction", "SetColGuessFunction")
	SaveSCtrlParam(Desktop, "LayGuessFunction", "SetLayGuessFunction")
	SaveSCtrlParam(Desktop, "LayRowGuessFunction", "SetLayColGuessFunction")
	SaveSCtrlParam(Desktop, "LayColGuessFunction", "SetLayRowGuessFunction")

// Functions
	SaveNCtrlParam(Desktop, "NumGlobVar", "NumGlobVar")
	SaveNCtrlParam(Desktop, "NumSimVar", "NumSimVar")
	
	
	SaveNCtrlParam(Desktop, "NumRowVar", "NumRowVar")
	SaveNCtrlParam(Desktop, "NumColVar", "NumColVar")
	SaveNCtrlParam(Desktop, "NumLayVar", "NumLayVar")
	SaveNCtrlParam(Desktop, "NumLayColVar","NumLayColVar")
	SaveNCtrlParam(Desktop, "NumLayRowVar", "NumLayRowVar")


// options
	NVAR FitTol = $cG3FHome+":V_FitTol"
	SaveNParam(Desktop, "FitTolerance", FitTol)
	NVAR MaxIter =  $cG3FHome+":V_FitMaxIters"
	SaveNParam(Desktop, "MaxIterations", MaxIter)
	SaveNCtrlParam(Desktop, "ProcessMT", "ProcessMT")
	SaveNCtrlParam(Desktop, "nThreads", "nThreads")
	SaveNCtrlParam(Desktop, "useThreads", "useThreads")
	SaveNCtrlParam(Desktop, "mainOptions", "mainOptions")
	SaveNCtrlParam(Desktop, "corrOptions", "corrOptions")
	SaveNCtrlParam(Desktop, "DefEpsilon", "DefEpsilon")
	SaveNCtrlParam(Desktop, "CorrNoSim", "CorrNoSim")
	SaveNCtrlParam(Desktop, "autoCycles", "autoCycles")
	
	// constraints and epsilon
	SaveGlobals(Desktop);
	SaveLocals(Desktop, "ConstraintsRow", "Row", 	"RowLocalVar_", saveFolder);
	SaveLocals(Desktop, "ConstraintsCol", "Col", 	"ColLocalVar_", saveFolder);
	SaveLocals(Desktop, "ConstrLayer", "Lay", 	"LayLocalVar_", saveFolder);
	SaveLocals(Desktop, "ConstrLayerRow", "LayRow", "LayRowLocalVar_", saveFolder);
	SaveLocals(Desktop, "ConstrLayerCol", "LayCol", "LayColLocalVar_", saveFolder);
	SaveConstr(Desktop, "MoreConstraints", "MoreConstraints_");
	SaveConstr(Desktop, "ConstrLayerMore", "MoreLayerConstraints_");
	
	// save Profile feedback settings 
	SaveFeedback(Desktop,"FeedbackRow_", "FeedbackListWave")
	// save Spectral feedback settings 

	KillWindow G3F_SavePanel

end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function DoRestoreDesktop ()
	controlinfo /W=G3F_RestorePanel RestoreDesktopPopup
	if (Exists(S_Value)!=1)
		DoAlert 0, "Cannot find this desktop..."
		return -1;
	endif
	
	string key
	string value
	wave /T Desktop = $S_Value
	variable lines = dimsize(Desktop, 0)

	// find folders
	string saveFolder = FindSParam(Desktop, "LocFolder");
	variable confirmed = 0 ;
	if (strlen(saveFolder))
		if (!DataFolderExists(saveFolder))
			DoAlert 1, "The following folder used to save desktop cannot be found. Do you want to proceeed with restoring settings without local parameters?\r\n"+saveFolder
			if (V_flag !=1)
				return -1;
			endif
			confirmed = 1;
		endif 
	endif 

	if (!confirmed)
		DoAlert 1, "Are you sure you want to override current settings with those in selected desktop?."
		if (V_flag !=1)
			return -1;
		endif
	endif 
	
	variable i

	MrtxMakeGuessList(quiet=1);
	
	ControlInfo /W=G3F_RestorePanel  RestoreProfilesCheck
	variable RestoreProfiles = V_Value;
	if (RestoreProfiles) // purge current
		string rowListWName = cG3FControl+":FeedbackRowListWave"
		string rowSelectWName = cG3FControl+":FeedbackRowSelectionWave"
		string colListWName = cG3FControl+":FeedbackColListWave"
		string colSelectWName = cG3FControl+":FeedbackColSelectionWave"
		redimension /N=(0, -1)  $rowListWName,  $rowSelectWName, $colListWName, $colSelectWName
	endif
	
	for (i=0; i< lines; i+=1)
		key = Desktop[i][0]
		value = Desktop[i][1]
		strswitch (key)
			 // Data 
			case "setID":
				ReadSCtrlParam(value,"setID")
				break;
 			case "DimFlags":
				ReadNCtrlParam(value,"DimFlags", 0)
				break;
 			case "VarFlags":
				ReadNCtrlParam(value,"VarFlags", 0)
				break;
 			case "MiscFlags":
				ReadNCtrlParam(value,"MiscFlags", 0)
				break;
			case "GlobalData":
				ReadSCtrlParam(value,"AddtlDataWN")
				break;
			case "XRefWave":		
				ReadSCtrlParam(value,"XRefWave"); 	
				break;
			case "ZRefWave":		
				ReadSCtrlParam(value,"ZRefWave"); 	
				break;
			case "ProcessFunction": 
				ReadSCtrlParam(value,"SimFunction");	
				break;
			case "FitFunction": 	
				ReadSCtrlParam(value,"FitFunction");	
				break;
			case "CorrFunction":
				ReadSCtrlParam(value,"CorrFunction")
				break;
			case "MatrixWave":
				ReadSCtrlParam(value,"MatrixWave")
				break;
			case "PerRowLimit":
				ReadSCtrlParam(value,"ColLimWaveName")
				break;
			case "XMask":
				ReadSCtrlParam(value,"XMask")
				break;
			case "XWave":
				ReadSCtrlParam(value,"XWave")
				break;
			case "XFrom":
				ReadNCtrlParam(value,"XFrom", 0)
				break;
			case "XTo":
				ReadNCtrlParam(value,"XTo", 0)
				break;
			case "XThin":
				ReadNCtrlParam(value,"XThin", 1)
				break;
			case "ZMask":
				ReadSCtrlParam(value,"ZMask")
				break;
			case "ZWave":
				ReadSCtrlParam(value,"ZWave")
				break;
			case "ZFrom":
				ReadNCtrlParam(value,"ZFrom", 0)
				break;
			case "ZTo":
				ReadNCtrlParam(value,"ZTo", 0)
				break;
			case "ZThin":
				ReadNCtrlParam(value,"ZThin", 1)
				break;
			case "LMask":
				ReadSCtrlParam(value,"LMask")
				break;
			case "LWave":
				ReadSCtrlParam(value,"LWave")
				break;
			case "LFrom":
				ReadNCtrlParam(value,"LFrom", 0)
				break;
			case "LTo":
				ReadNCtrlParam(value,"LTo", 0)
				break;
			case "LThin":
				ReadNCtrlParam(value,"LThin", 1)
				break;
			case "RowGuessFunction":
				ReadSCtrlParam(value,"SetRowGuessFunction")
				break;
			case "ColGuessFunction":
				ReadSCtrlParam(value,"SetColGuessFunction")
				break;
			case "LayGuessFunction":
				ReadSCtrlParam(value,"SetLayGuessFunction")
				break;
			case "LayRowGuessFunction":
				ReadSCtrlParam(value,"SetLayRowGuessFunction")
				break;
			case "LayColGuessFunction":
				ReadSCtrlParam(value,"SetLayColGuessFunction")
				break;
			case "NumGlobVar":
				ReadNCtrlParam(value,"NumGlobVar", 0)
				break;
			case "NumSimVar":
				ReadNCtrlParam(value,"NumSimVar", 0)
				break;
			case "NumRowVar":
				ReadNCtrlParam(value,"NumRowVar", 0)
				break;
			case "NumColVar":
				ReadNCtrlParam(value,"NumColVar", 0)
				break;
			case "NumLayVar":
				ReadNCtrlParam(value,"NumLayVar", 0)
				break;
			case "NumLayColVar":
				ReadNCtrlParam(value,"NumLayColVar", 0)
				break;
			case "NumLayRowVar":
				ReadNCtrlParam(value,"NumLayRowVar", 0)
				break;
			case "FitTolerance":
				ReadNCtrlParam(value, cG3FHome+":V_FitTol", 0)
				break;
			case "MaxIterations":
				ReadNCtrlParam(value, cG3FHome+":V_FitMaxIters", 0)
				break;
			case "ProcessMT":
				ReadNCtrlParam(value,"ProcessMT", 0)
				break;
			case "nThreads":
				ReadNCtrlParam(value,"nThreads", 0)
				break;
			case "useThreads":
				ReadNCtrlParam(value,"useThreads", 0)
				break;
			case "mainOptions":
				ReadNCtrlParam(value,"mainOptions", 0)
				break;
			case "corrOptions":
				ReadNCtrlParam(value,"corrOptions", 0)
				break;
			case "DefEpsilon":
				ReadNCtrlParam(value,"DefEpsilon", 1E-6)
				break;
			case "CorrNoSim":
				ReadNCtrlParam(value,"CorrNoSim", 0)
				break;
			case "autoCycles":
				ReadNCtrlParam(value,"autoCycles", 0)
				break;

				
			default:
				if (RestoreGlobals(key, value))
				elseif (RestoreLocals(key, value,  "RowLocalVar_", "ConstraintsRow", "Row", saveFolder))
				elseif (RestoreLocals(key, value,  "ColLocalVar_", "ConstraintsCol", "Col", saveFolder))
				elseif (RestoreLocals(key, value,  "LayLocalVar_", "ConstrLayer", "Lay", saveFolder))
				elseif (RestoreLocals(key, value,  "LayRowLocalVar_", "ConstrLayerRow", "LayRow", saveFolder))
				elseif (RestoreLocals(key, value,  "LayColLocalVar_", "ConstrLayerCol", "LayCol", saveFolder))
				elseif (RestoreConstr(key, value,  "MoreConstraints_", "MoreConstraints"))
				elseif (RestoreConstr(key, value,  "MoreLayerConstraints_", "ConstrLayerMore"))
				elseif (RestoreProfiles && RestoreFeedback(key, value, "FeedbackRow_", "FeedbackRowListWave",  "FeedbackRowSelectionWave", 2))
				
				// no key match - no action
				endif
			endswitch
		endfor
		
		Dialog2Vars();
		KIllWindow G3F_RestorePanel
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function MakeSavePanel()
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1001,696,1322,796) /N=G3F_SavePanel as "Save G3F desktop"
	ModifyPanel /W=G3F_SavePanel fixedSize=1
	SetDrawLayer UserBack

	PopupMenu SaveDesktopPopup,pos={25,10},size={165,23},proc=SaveDesktopPopMenuProc,title="Save desktop as"
	PopupMenu SaveDesktopPopup,mode=1,popvalue="_new_",value= #"SaveDesktopList()"
	SetVariable NewDesktopName,pos={12,36},size={259,18},bodyWidth=150,title="new desktop name"
	SetVariable NewDesktopName,value= $cG3FControl+":Desktop"
	Button SaveDesktopButton,pos={92,72},size={50,20},proc=SaveDesktopButtonProc,title="Save"
	Button CancelDesktopButton,pos={180,72},size={50,20},proc=CancelSaveButtonProc,title="Cancel"
	
	PauseForUser G3F_SavePanel
EndMacro

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function MakeRestorePanel()
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1001,696,1322,796) /N=G3F_RestorePanel as "Restore G3F desktop"
	ModifyPanel /W=G3F_RestorePanel fixedSize=1
	SetDrawLayer UserBack

	PopupMenu RestoreDesktopPopup,pos={25,10},size={165,23}, title="Restore desktop from"
	PopupMenu RestoreDesktopPopup,mode=1, value= #"RestoreDesktopList()"
	CheckBox 	RestoreProfilesCheck,pos={27,41},size={106,15},title="Restore profiles", value= 1
	Button RetsoreDesktopButton,pos={92,72},size={50,20},proc=RestoreDesktopButtonProc,title="Restore"
	Button CancelDesktopButton,pos={180,72},size={50,20},proc=CancelRestoreButtonProc,title="Cancel"

	PauseForUser G3F_RestorePanel
EndMacro
