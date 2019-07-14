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

strconstant cG3FVer = "1.0a4"
strconstant cG3FHome = "root:Packages:G3Fit"
strconstant cG3FControl = "root:Packages:G3Fit:Control"
strconstant cG3FName = "3D-Global Nonlinear Regression Analysis"

 
Menu "Analysis"
	Submenu "Global 3D Spectral Regression"
		"Control Panel", /Q, G3F#G3FitMenu ()
		Submenu "Scroller"
			"Row", /Q, G3F#ShowScrollWindow(0)
			"Col", /Q, G3F#ShowScrollWindow(1)
		end
		Submenu "Feedback overlay"
			"Row", /Q, G3F#ShowOverlayWindow(0)
			"Col", /Q, G3F#ShowOverlayWindow(1)
		end 	
		Submenu "Locals overlay"
			"Row", /Q, G3F#ShowLocalsWindow(0)
			"Col", /Q, G3F#ShowLocalsWindow(1)
			"Lay", /Q, G3F#ShowLocalsWindow(2)
		end 	
		Submenu "Source-fit overlay"
			"Row", /Q, G3F#ShowTrackingWindow(0) 
			"Col", /Q, G3F#ShowTrackingWindow(1) 
			"Lay", /Q, G3F#ShowTrackingWindow(2) 
		end 	
		
		"Unload", /Q, G3F#UnloadG3Fit()
	end
end

function G3FitStartupHookInternal (refNum, fileNameStr, pathNameStr, fileTypeStr, fileCreatorStr, fileKind)
		Variable refNum,fileKind
	String fileNameStr,pathNameStr,fileTypeStr,fileCreatorStr
	print "Starting G3Fit ......"
	if (!DataFolderExists( cG3FHome))
		return 0
	endif
	 G3FitStartup()
end


function  G3FitStartup ()
//	 SetVariable nThreadsCtrl limits={1,ThreadProcessorCount,1}
	 NVAR nthreads = $cG3FControl+":nThreads";
	nthreads = ThreadProcessorCount;
	NVAR useThreads = $cG3FControl+":useThreads";
	if (useThreads > nThreads)
		useThreads = nThreads;
	endif
	SetVariable nThreadsCtrl, win=G3FitPanel, limits={1,nThreads,1}

	if (wintype("G3FitPanel")==7)
		string panelVer = 	GetUserData("G3FitPanel", "", "ver" )
		if (cmpstr(panelVer, cG3FVer)!=0)
			Print "G3F panel versions mismatch: saved with experiment ["+panelVer+"], loaded from procedure ["+cG3FVer+"]."	
			DoWindow /K G3FitPanel
			strswitch(panelVer) 
				default:
				case "1.2b3":		
					InitG3FitGlobals()
				case "1.2b4":
					MakePhaseOverlayStyleWave();
				case "1.2b5":
					MakeGuessKEditable();
				case "1.2b6":
					MakeRefWaves();
			endswitch
			fMTXvsMTX_FitPanel()
		endif
	endif
	// check panel version and re-build if necessary
	Dialog2Vars()
	
end



function G3FitMenu()
	if (wintype("G3FitPanel") == 0)
		InitG3FitPanel()
	else
		DoWindow/F G3FitPanel
	endif
end

Function InitG3FitPanel()
	Execute/P "COMPILEPROCEDURES ";
	Silent 1; PauseUpdate
	
	if (wintype("G3FitPanel") == 0)
		InitG3FitGlobals()
		fMTXvsMTX_FitPanel()
		G3FitStartup ();
		MtrxSetNumGlobParamsProc("",0,"","")
	else
		DoWindow/F G3FitPanel
	endif
end




Function UnloadG3Fit()
	if (WinType("G3FitPanel") == 7)
		DoWindow/K G3FitPanel
	endif
	if (WinType("G3FitGraph") != 0)
		DoWindow/K G3FitGraph
	endif
	if (DatafolderExists(cG3FHome))
		KillDatafolder $cG3FHome
	endif
	Execute/P "DELETEINCLUDE  <Matrix Fit>"
	Execute/P "COMPILEPROCEDURES "
end


Function InitG3FitGlobals()
	
	String saveFolder = GetDataFolder(1)
	variable HomeFolderExists=DatafolderExists(cG3FHome);
	
	if (!HomeFolderExists)
		NewDataFolder/O/S root:Packages
		NewDataFolder/O/S G3Fit
	endif
	
	variable CtrlFolderExists=DatafolderExists(cG3FControl);

	if (!CtrlFolderExists)
		NewDataFolder/O/S $cG3FControl
	endif
	
	SetDataFolder $cG3FHome;
	Variable/G V_FitTol
	Variable/G V_FitMaxIters


	SetDataFolder $cG3FControl;
	
	String /G setID;
	
	Variable/G DimFlags
	Variable/G VarFlags
	Variable/G MiscFlags
	
	Variable/G NumGlobVar
	
	Variable/G NumRowVar
	Variable/G NumSimVar
	Variable/G NumColVar
	Variable/G NumLayVar
	Variable/G NumLayRowVar
	Variable/G NumLayColVar

	Variable/G XFrom
	Variable/G XTo
	Variable/G XThin
	Variable/G ZFrom
	Variable/G ZTo
	Variable/G ZThin
	Variable/G LFrom
	Variable/G LTo
	Variable/G LThin
	Variable/G LocalOnlyChunks
	Variable/G useThreads = ThreadProcessorCount;
	Variable/G ProcessMT
	Variable/G DefEpsilon
	Variable/G autoCycles
	Variable /G CorrNoSim
	Variable /G mainOptions
	Variable /G corrOptions

	String /G SimFunction
	String /G FitFunction
	String /G CorrFunction
	String /G MatrixWave
	String /G MatrixWaveFit
	
	String /G XMask
	String /G XWave
	String /G XWaveFit
	String /G XRefWave

	String /G ZMask
	String /G ZWave
	String /G ZWaveFit
	String /G ZRefWave
	
	String /G LMask
	String /G LWave
	String /G LWaveFit

	String /G ColLimWaveName
	String /G AddtlDataWN
	string /G ProcessWName
	
	String /G SetRowGuessFunction
	String /G SetColGuessFunction
	String /G SetLayGuessFunction
	String /G SetLayRowGuessFunction
	String /G SetLayColGuessFunction
	
	String /G Desktop

	Variable/G FeedbackLayer	

	Variable/G nThreads = ThreadProcessorCount;
	
	
	
	Variable/G HoldOverride
	Variable /G cpuTime
	Variable /G stepCount
	String/G TopGraph

	if (!HomeFolderExists)
		setID = "";
		V_FitTol = 0.01
		V_FitMaxIters = 40
		LocalOnlyChunks = 20;
		autoCycles = 10;
		FitFunction=""
		MatrixWave=""
		XWave=""
		XRefWave=""
		XWaveFit = "";
		ZWave=""
		ZRefWave=""
		ZWaveFit = "";
		ColLimWaveName=""
		MatrixWaveFit="";
		SetRowGuessFunction=""
		SetColGuessFunction=""
		SetLayGuessFunction=""
		SetLayColGuessFunction=""
		SetLayRowGuessFunction=""
		TopGraph=""

		Make/N=1/O/T GuessListWave  ="No Data Sets Selected"
		Make/N=1/O/U/B GuessListSelection=0
	
		Make/N=1/O/T ConstraintsGlobalListWave //="No Data Sets Selected"
		Make/N=1/O/U/B ConstraintsGlobalSelectionWave=0

		Make/N=1/O/T ConstraintsRowListWave //="No Data Sets Selected"
		Make/N=1/O/U/B ConstraintsRowSelectionWave=0

		Make/N=1/O/T ConstraintsColListWave //="No Data Sets Selected"
		Make/N=1/O/U/B ConstraintsColSelectionWave=0

		// missing Layer constraints? 
		
		MakeProfileOverlayStyleWave()
		MakePhaseOverlayStyleWave();
	endif
	// this is upgrade - has to be  regardless
	string RowListWN = cG3FControl+":FeedbackRowListWave";
	string RowSelWN = cG3FControl+":FeedbackRowSelectionWave";
	variable needSet = 0;
	if (!waveexists($RowListWN) ||  !waveExists($RowSelWN))
		needSet = 1;
	elseif (dimsize($RowListWN, 1)!= 4 || wavetype($RowListWN,1) != 2)
		needSet = 1;
	elseif (dimsize($RowSelWN, 1) != 4 || wavetype($RowSelWN,1) != 1)
		needSet = 1;
	endif 
	if (needSet)
		Make/N=(1,4)/T/O  $RowListWN=""
		Make/N=(1,4)/O $RowSelWN=6
	endif
	SetDimLabel 1,0,'Clb', $RowListWN
	SetDimLabel 1,1,'Frame', $RowListWN
	SetDimLabel 1,2,'Base1', $RowListWN
	SetDimLabel 1,3,'Base2', $RowListWN

	string ColListWN = cG3FControl+":FeedbackColListWave";
	string ColSelWN = cG3FControl+":FeedbackColSelectionWave";
	needSet = 0;
	if (!waveexists($ColListWN) || !waveExists($ColSelWN))
		needSet = 1;
	elseif (dimsize($ColListWN, 1)!= 4 || wavetype($ColListWN,1) != 2)
		needSet = 1;
	elseif (dimsize($ColSelWN, 1) != 4 || wavetype($ColSelWN,1) != 1)
		needSet = 1;
	endif 
	if (needSet)
		Make/N=(1,4)/T/O  $ColListWN=""
		Make/N=(1,4)/O $ColSelWN=6
	endif
	SetDimLabel 1,0,'Clb', $ColListWN
	SetDimLabel 1,1,'Frame', $ColListWN
	SetDimLabel 1,2,'Base1', $ColListWN
	SetDimLabel 1,3,'Base2', $ColListWN
	
	SetDataFolder $saveFolder
	Execute  "SetIgorHook AfterFileOpenHook = G3F_StartupHook"
end

Function MtrxSetNumGlobParamsProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	// !!! All this does nothing for now...
	
	NVAR NGParams=$cG3FControl+":NumGlobVar"
	NVAR NLParams=$cG3FControl+":NumLayVar"
	
	MatrixSetParams()
End

Function MtrxSetNumRowParamsProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	// !!! All this does nothing for now...

	MatrixSetParams()
End

Function MtrxSetNumColParamsProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	// !!! All this does nothing for now...
	
	MatrixSetParams()
End

Function MtrxSetNumLayParamsProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	// !!! All this does nothing for now...
	
	MatrixSetParams()
End

Function MtrxSetNumLayColParamsProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	// !!! All this does nothing for now...
	
	MatrixSetParams()
End

Function MtrxSetNumLayRowParamsProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	// !!! All this does nothing for now...
	
	MatrixSetParams()
End

Function MatrixSetParams()

	NVAR NGParams=$cG3FControl+":NumGlobVar"
	NVAR NLVar=$cG3FControl+":NumLayVar"
	NVAR NLRVar=$cG3FControl+":NumLayRowVar"
	NVAR NLCVar=$cG3FControl+":NumLayColVar"
	NVAR NRVar=$cG3FControl+":NumRowVar"
	NVAR NCVar=$cG3FControl+":NumColVar"
	

end


Function EnableIMDevCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	Variable checked = cba.checked
	NVAR BitField = $cG3FControl+":MiscFlags"
	switch( cba.eventCode )
		case 2: // mouse up
			BitField = checked ? (BitField | EnableDev) : (BitField & ~EnableDev);
			Execute "SetIgorOption IndependentModuleDev = "+num2str(checked)
			break			
		case 0xFF: // programmatic 
			BitField = checked ? (BitField | EnableDev) : (BitField & ~EnableDev);
			Execute "SetIgorOption IndependentModuleDev = "+num2str(checked)
			break
		default:
			return 0;
	endswitch

	if (checked)
		Print "*** IMDevelopment is enabled ***";
	endif 

	return 0
End



Function/S MtrxListPsblInitialGuessWaves()

	Wave/T/Z GuessListWave = $cG3FControl+":GuessListWave"
	NVAR NGVar =	 	$cG3FControl+":NumGlobVar"
	NVAR NLVar = 	$cG3FControl+":NumLayVar"
	NVAR NLayRVar = $cG3FControl+":NumLayRowVar"
	NVAR NLayCVar = $cG3FControl+":NumLayColVar"
	NVAR NRVar = 	$cG3FControl+":NumRowVar"
	NVAR NCVar = 	$cG3FControl+":NumColVar"
	variable TotalParams= NGVar + NRVar + NCVar + NLVar + NLayRVar + NLayCVar


	if ( (!WaveExists(GuessListWave)) || (TotalParams <= 0) )
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




// this wave is used in profile ovelray plots
function MakeProfileOverlayStyleWave()
	
	Make/N=(16,7,2)/O $cG3FControl+"OverlayParams"
	WAVE OverlayParams = $cG3FControl+"OverlayParams"
	SetDimLabel 0,-1,'trace', OverlayParams
	SetDimLabel 1,-1,'param', OverlayParams
	SetDimLabel 2,-1,'group', OverlayParams	
	
	OverlayParams[0][0][] = 65280 // #1 red
	
	OverlayParams[1][0][] = 65280 //#2 orange
	OverlayParams[1][1][] = 32768 

	OverlayParams[2][1][] = 65280 //#3 green
	
	OverlayParams[3][1][] = 65280 //#4 cyan
	OverlayParams[3][2][] = 65280 //#4

	OverlayParams[4][1][] = 32768 //#5 LtBlue 
	OverlayParams[4][2][] = 65280 //#5
	

	OverlayParams[5][2][] = 65280 //#6 blue
	
	OverlayParams[6][0][] = 32768 //#7 viol
	OverlayParams[6][1][] = 65280 //#7 viol
	
	OverlayParams[7][0][] = 65280 //#8 purple
	OverlayParams[7][1][] = 65280 //#8 	
	
	OverlayParams[8,15][0,3][] = OverlayParams[p-8][q]
	
	
	OverlayParams[][3][0] = 0.5 // line size
	OverlayParams[0,3][4][0] = 0 // line style
	OverlayParams[4,7][4][0] = 1 // line style
	OverlayParams[7,11][4][0] = 4 // line style
	OverlayParams[12,15][4][0] = 11 // line style

	OverlayParams[0][5][0] = 8 // marker
	OverlayParams[1][5][0] = 5 // marker
	OverlayParams[2][5][0] = 6 // marker
	OverlayParams[3][5][0] = 22 // marker
	OverlayParams[4][5][0] = 7 // marker
	OverlayParams[5][5][0] = 45 // marker
	OverlayParams[6][5][0] = 4 // marker
	OverlayParams[7][5][0] = 3 // marker
	OverlayParams[8][5][0] = 19 // marker
	OverlayParams[9][5][0] = 16 // marker
	OverlayParams[10][5][0] = 17 // marker
	OverlayParams[11][5][0] = 23 // marker
	OverlayParams[12][5][0] = 18 // marker
	OverlayParams[13][5][0] = 46 // marker
	OverlayParams[14][5][0] = 15 // marker
	OverlayParams[15][5][0] = 14 // marker



	OverlayParams[][6][0] = 3 // mode
	
	OverlayParams[][3][1] = 1.5 // line size
	OverlayParams[][4][1] = OverlayParams[p][4][0] // line style
	OverlayParams[][5][1] = OverlayParams[p][5][0] //0 // marker
	OverlayParams[][6][1] = 0 // mode
	
end

// this wave is used in profile ovelray plots
function MakePhaseOverlayStyleWave()
//	print "Making PhaseOveralyParams..."
	string POStr = cG3FControl+":PhaseOverlayParams"
	Make/N=(8,3)/O $POStr
	SetDimLabel 0,-1,'trace', $POStr
	SetDimLabel 1,-1,'param', $POStr
	WAVE PhaseOverlayParams = $POStr
	PhaseOverlayParams[0][0][] = 65280 // #1 red
	
	PhaseOverlayParams[1][1][] = 49152 //#2 green

	PhaseOverlayParams[2][1][] =32768  //#3 aqua
	PhaseOverlayParams[2][2][] =32768  //
	
	PhaseOverlayParams[3][2][] = 65280 //#4 blue

	PhaseOverlayParams[4][0][] = 65280 //#8 pink
	PhaseOverlayParams[4][2][] = 65280 //#8 	

	PhaseOverlayParams[5][0][] = 65280 //#5 orange 
	PhaseOverlayParams[5][1][] = 32768 //#5
	

	PhaseOverlayParams[6][1][] = 49152 //#6 light blue
	PhaseOverlayParams[6][2][] = 65280 //
	
	
	PhaseOverlayParams[7][0][] = 32768 //#7 viol
	PhaseOverlayParams[7][1][] = 49152 //
	
	PhaseOverlayParams[7][0][] = 49152 //#8 brick
	
end

function MakeGuessKEditable() 
	wave GuessSelectionWave =  $cG3FControl+":GuessListSelection"
	GuessSelectionWave[][0]=2;
	wave GSelectionWave =  $cG3FControl+":ConstraintsGlobalSelectionWave"
	GSelectionWave[][0]=2;
	wave RSelectionWave =  $cG3FControl+":ConstraintsRowSelectionWave"
	RSelectionWave[][0,1]=2;
	wave CSelectionWave =  $cG3FControl+":ConstraintsColSelectionWave"
	CSelectionWave[][0,1]=2;
end


function MakeRefWaves()
	String /G $cG3FControl+":XRefWave";
	String /G $cG3FControl+":ZRefWave";
end

//******************************************************************* 
// Prep funciton
//******************************************************************* 

function BuildUnevenMatrix (NamesList, SetName)
string NamesList
string SetName
prompt NamesList, "Text list of name pairs", popup, WaveList("*",";","DIMS:2 MINCOLS:2 MAXCOLS:2 TEXT:1")
prompt SetName, "Dataset name"

if (strlen(SetName)<=0)
	DoAlert 0, "Dataset name cannot be blank"
	return -1
endif 

variable nRows = DimSize($NamesList, 0);
if (nRows <=0)
	DoAlert 0, "Dataset does not contain wave names pairs"
	return -1 
endif
	
variable maxPnts = CheckNamePairs($NamesList)
if (maxPnts > 0)
	BuildMatrixFromDataSet($NamesList, maxPnts, SetName)
	print "Max points "+num2str(maxPnts)+" in "+num2str(nRows)+" rows"
else
	return -1;
endif
endmacro

//******************************************************
// Check is name pairs conform and return max column count
//
function CheckNamePairs(NamesList)
	WAVE /T NamesList 
	variable maxPnts =0;
	variable i;
	string xName, yName;
	for ( i=0; i< DimSize(NamesList, 0); i+=1) 
		yName = NamesList[i][0]);
		xName = NamesList[i][1];
		if (!WaveExists($xName)) // Igor 8 fix
			DoAlert 0, "Wave ["+xName+"] was not found"
			return -1 
		endif
		if (!WaveExists($yName)) // Igor 8 fix
			DoAlert 0, "Wave ["+yName+"] was not found"
			return -1 
		endif
		
		if (WaveDims($xName)!=0)
			DoAlert 0, "Wave ["+xName+"] has more that one dimension, this is not allowed"
			return -1 
		endif
		if (WaveDims($yName)!=0)
			DoAlert 0, "Wave ["+yName+"] has more that one dimension, this is not allowed"
			return -1 
		endif
		if (maxPnts < numpnts($yName))
			maxPnts = numpnts($yName);
		endif	
	endfor
	return maxPnts;
end

//**********************************************
// Make a rectangular matrix and calibration from a list of name pairs
//
function BuildMatrixFromDataSet(NamesList, maxPnts, SetName)
	WAVE /T NamesList 
	variable maxPnts
	string SetName
	
	string sDS_X = "GF_"+SetName+"_X";
	string sDS_Y = "GF_"+SetName+"_Y";
	string sDS_N = "GF_"+SetName+"_N";
	
	make /o /N=(DimSize(NamesList, 0), maxPnts) $sDS_X, $sDS_Y
	make /o /N=(DimSize(NamesList, 0)) $sDS_N
	
	wave DS_X = $sDS_X
	wave DS_Y = $sDS_Y
	wave DS_N = $sDS_N;
	variable i;
	for (i=0; i< DimSize(NamesList, 0); i+=1) 
		WAVE yWave = $(NamesList[i][0])
		WAVE xWave = $(NamesList[i][1])
		DS_Y[i][] = yWave[q];
		DS_X[i][] = xWave[q];
		DS_N[i] = numPnts(xWave)
	endfor

end

function fMTXvsMTX_FitPanel() // major revision for 2D implementation
	// revision 2008-11-03
	if (wintype("G3FitPanel") != 0)
		DoWindow/F G3FitPanel
		return 0;
	endif
	variable VO = 0, HO=0;
	
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(90,75,1123,685) /N=G3FitPanel as cG3FName //"2D-Global Nonlinear Regression Analysis  v1.2b" //1110 // 600
	ModifyPanel /W=G3FitPanel fixedSize=1
	SetWindow G3FitPanel userdata(ver)=cG3FVer
	SetDrawLayer UserBack
	
	VO=0
	HO=0
	GroupBox GlobParamGroup,pos={HO+03,VO},size={300,92},title="Reference data"
	GroupBox GlobParamGroup,help={"Additional data needed for calculations."}
	PopupMenu AddtlParamsPopup,pos={HO+0,VO+18},size={300,23},bodyWidth=250,proc=G3F#AddtlDataPopMenuProc,title="Global",value= #"G3F#AddtlDataPopupContents()"
	PopupMenu AddtlParamsPopup,help={"Global data is an optional numeric wave that is passed to the process, if any, fitting, and post-processing funcitons\rAny number of numeric values in any order can be passed in global data wave. You are responsibe for interpreting values."}
	PopupMenu ChooseZRefWPopup,pos={HO+0,VO+42},size={300,23},bodyWidth=250,proc=G3F#ChooseZRefWPopMenuProc,title="Z (Col)",value= #"G3F#ChooseZRefWPopContents()", disable=1
	PopupMenu ChooseZRefWPopup,help={"An optional wave with parametric values for each column of data to be used in calculations; can be a 1D or a 2D wave."}
	PopupMenu ChooseXRefWPopup,pos={HO+0,VO+66},size={300,23},bodyWidth=250,proc=G3F#ChooseXRefWPopMenuProc,title="X (Row)",value= #"G3F#ChooseXRefWPopContents()", disable=1
	PopupMenu ChooseXRefWPopup,help={"An optional wave with parametric values for each row of data to be used in calculations; can be a 1D or a 2D wave."}

	VO=95
	HO=0
	GroupBox MethodGroup,pos={HO+3,VO},size={300,117},title="Method",help={"Method area defines the model that should be applied to data"}
	PopupMenu SimFunctionPopup,pos={HO+0,VO+18},size={300,23},bodyWidth=200,proc=G3F#SimFunctionMenuProc,title="Process function ",value= #"G3F#ListMatrixSimFunctions()"
	PopupMenu SimFunctionPopup,help={"An optional process calculation function. This selection defines which finctions are available for \"Fit to funciton\" and \"Post-processing\" selections."}
	DrawText 7,VO+55,"Last process:"
	CheckBox KeepLastSimCheckBox,pos={HO+83,VO+40},size={45,15},title="keep", proc=G3F#StdCheckProc, userdata(flag)=num2str(KeepLastSim), userdata(field)="MiscFlags" 
	CheckBox KeepLastSimCheckBox,help={"Preserves calculated process used in last calculation. Process wave saved in current data folder is named after data wave with \"_sim\" suffix."}
	CheckBox ReuseProcessCheckBox,pos={HO+133,VO+40},size={50,15},title="reuse", proc=G3F#StdCheckProc, userdata(flag)=num2str(ReuseLastSim), userdata(field)="MiscFlags" 
	CheckBox ReuseProcessCheckBox,help={"Allow to use process wave from previous calculation unless any of the global parameters have chnaged."}
	CheckBox MTProcessCheckBox,pos={HO+191,VO+40},size={110,15},title="MT process calc.", proc=G3F#StdCheckProc, userdata(flag)=num2str(MTProcess), userdata(field)="MiscFlags" 
	CheckBox MTProcessCheckBox,help={"Enables multi-threaded caclulation for multi-threaded process functions. Not available for functions that cunform to single-thread template."}
	PopupMenu FitFunctionPopup,pos={HO+0,VO+64},size={300,23},bodyWidth=200,proc=G3F#FitFunctionMenuProc,title="Fit to function ",value= #"G3F#ListG3FitFunctions()"
	PopupMenu FitFunctionPopup,help={"The main calculation function. Only functions matching above selections in the use of global data and process calculation are listed here."}
	PopupMenu CorrFunctionPopup,pos={HO+0,VO+89},size={300,23},bodyWidth=200,proc=G3F#CorrFunctionMenuProc,title="Post-processing",value= #"G3F#ListCorrFunctions()"
	PopupMenu CorrFunctionPopup,help={"Optional post-processing. Only functions matching above selction in the use of process calcualtuion are listed. Correction functions do not have to use global data if such wave is selected above, but cannot use it if \"_none_\" is selected"}

	VO=215
	HO=0
	GroupBox DataGroup,pos={HO+3,VO},size={300,85},title="Dataset"
	GroupBox DataGroup,help={"Data group describes the form of original data to be modelled."}
	PopupMenu ChooseMatrixPopup,pos={HO+0,VO+18},size={300,23},bodyWidth=250,proc=G3F#ChooseMatrixPopMenuProc,title="Data",value= #"G3F#ChooseMatrixWaveMenuContents()"
	PopupMenu ChooseMatrixPopup,help={"The experimental data to be modelled. Data can be in the form of a 2D rectangular matix or a 2-column text wave listing pairs of 1-D X and Y data of matching lengths."}
	SetVariable SetMatrixWave,pos={HO+5,VO+40},size={293,18},title=" ",frame=0,value= $cG3FControl+":MatrixWave"
	SetVariable SetMatrixWave,help={"Full name and path of currently seleted data wave."}
	PopupMenu ChooseColLimWavePopup,pos={HO+0,VO+59},size={300,23},bodyWidth=250,proc=G3F#ChooseColLimWavePopMenuProc,title="Col limit",value= #"G3F#ChooseColLimPopupContents()"
	PopupMenu ChooseColLimWavePopup,help={"Row-by-row limit to the number of columns of a rectangular matrix to be used in modelling. Necessary if the number of meaninful data columns in each row in not equal."}
	
	VO=302
	HO=0
	GroupBox MaskParamGroup,pos={HO+3,VO},size={300,96},title="Masks"
	GroupBox MaskParamGroup,help={"Data masks"}
	PopupMenu ChooseZMaskPopup,pos={HO+0,VO+19},size={300,23},bodyWidth=250,proc=G3F#ChooseZMaskPopMenuProc,title="Z (Col)",value= #"G3F#ChooseZMaskPopContents()"
	PopupMenu ChooseZMaskPopup,help={"Wave with parametric values for each column of data. Z calibraiton can be in the form of a 1D wave for entire columns or a 2D matrix definigng of Z calibration values row-by-row."}

	PopupMenu ChooseXMaskPopup,pos={HO+0,VO+44},size={300,23},bodyWidth=250,proc=G3F#ChooseXMaskPopMenuProc,title="X (Row)",value= #"G3F#ChooseXMaskPopContents()"
	PopupMenu ChooseXMaskPopup,help={"An optional calibration wave with parametric value for each row of data. Only 1D waves can be used."}

	PopupMenu ChooseLMaskPopup,pos={HO+0,VO+69},size={300,23},bodyWidth=250,proc=G3F#ChooseLMaskPopMenuProc,title="L (Lay)",value= #"G3F#ChooseLMaskPopContents()"
	PopupMenu ChooseLMaskPopup,help={"An optional calibration wave with parametric value for each layer of data. Only 1D waves can be used."}

	
	VO=402
	HO=0
	// strings: ZWave ...
	GroupBox ClbParamGroup,pos={HO+3,VO},size={300,116},title="Calibrations"
	GroupBox ClbParamGroup,help={"Calibration waves needed for modelling."}
	PopupMenu ChooseZClbWPopup,pos={HO+0,VO+19},size={300,23},bodyWidth=250,proc=G3F#ChooseZClbWPopMenuProc,title="Z (Col)",value= #"G3F#ChooseZClbWPopContents()"
	PopupMenu ChooseZClbWPopup,help={"Wave with parametric values for each column of data. Z calibraiton can be in the form of a 1D wave for entire columns or a 2D matrix definigng of Z calibration values row-by-row."}

	PopupMenu ChooseXClbWPopup,pos={HO+0,VO+44},size={300,23},bodyWidth=250,proc=G3F#ChooseXClbWPopMenuProc,title="X (Row)",value= #"G3F#ChooseXClbWPopContents()"
	PopupMenu ChooseXClbWPopup,help={"An optional calibration wave with parametric value for each row of data. Only 1D waves can be used."}

	PopupMenu ChooseLClbWPopup,pos={HO+0,VO+69},size={300,23},bodyWidth=250,proc=G3F#ChooseLClbWPopMenuProc,title="L (Lay)",value= #"G3F#ChooseLClbWPopContents()"
	PopupMenu ChooseLClbWPopup,help={"An optional calibration wave with parametric value for each layer of data. Only 1D waves can be used."}

	DrawText HO+7,VO+93+15,"Make thinned:"
	CheckBox MakeXClbCheckBox,pos={HO+100,VO+93},size={60,15},title="X-Clb", proc=G3F#StdCheckProc, userdata(flag)=num2str(MakeThinX), userdata(field)="DimFlags"  //proc=G3F#DimFieldCheckProc, userdata=num2str(MakeThinX)
	CheckBox MakeXClbCheckBox,help={"Create separate wave 1D containing X calibration for fitted data."}
	CheckBox MakeZClbCheckBox,pos={HO+160,VO+93},size={60,15},title="Z-Clb", proc=G3F#StdCheckProc, userdata(flag)=num2str(MakeThinZ), userdata(field)="DimFlags"
	CheckBox MakeZClbCheckBox,help={"Create separate wave 1D containing Z calibration for fitted data."}
	CheckBox MakeLClbCheckBox,pos={HO+220,VO+93},size={60,15},title="L-Clb", proc=G3F#StdCheckProc, userdata(flag)=num2str(MakeThinL), userdata(field)="DimFlags"
	CheckBox MakeLClbCheckBox,help={"Create separate wave 1D containing L calibration for fitted data."}
	
	VO = 520;
	HO=0
	GroupBox RangeGroup,pos={HO+3,VO},size={300,87},title="Range"
	GroupBox RangeGroup,help={"Sub-range of original data to be used in modelling."}
	VO+=18
	SetVariable SetXFrom,pos={HO+6,VO},size={120,18},bodyWidth=50,title="X (row) from",format="%u",limits={0,inf,1},value= $cG3FControl+":XFrom"
	SetVariable SetXTo,pos={HO+128,VO},size={64,18},bodyWidth=50,title="to",format="%u",limits={0,inf,1},value= $cG3FControl+":XTo"
	SetVariable SetXThin,pos={HO+194,VO},size={64,18},bodyWidth=40,title="thin",format="%u",limits={1,inf,1},value= $cG3FControl+":XThin"
	SetVariable SetXThin,help={"Allows a smaller subset of representaitve, equally-spaced rows to be used in analysis by either averaging or dropping values. Can GREATLY speed up calculations without loss of resolution."}
	CheckBox AverageXChBox,pos={HO+260,VO+1},size={40,15},title="ave.", proc=G3F#StdCheckProc, userdata(flag)=num2str(AveThinX), userdata(field)="DimFlags"
	CheckBox AverageXChBox,help={"Average \"Thin\" number of values when thinning of 2 or greater is specified. Clearing this box forces to simply ignore all but one value out \"Thin\" data values."}
	VO+=22
	SetVariable SetZFrom,pos={HO+10,VO},size={116,18},bodyWidth=50,title="Z (col) from",format="%u",limits={0,inf,1},value= $cG3FControl+":ZFrom"
	SetVariable SetZFrom,help={""}
	SetVariable SetZTo,pos={HO+128,VO},size={64,18},bodyWidth=50,title="to",format="%u",limits={0,inf,1},value= $cG3FControl+":ZTo"
	SetVariable SetZTo,help={""}
	SetVariable SetZThin,pos={HO+194,VO},size={64,18},bodyWidth=40,title="thin",format="%u",limits={1,inf,1},value= $cG3FControl+":ZThin"
	SetVariable SetZThin,help={"Although uncommon for Z dimension, allows a smaller subset of representaitve, equally-spaced rows to be used in analysis by either averaging or dropping values. Can GREATLY speed up calculations without loss of resolution."}
	CheckBox AverageZChBox,pos={HO+260,VO+1},size={40,15},title="ave.",  proc=G3F#StdCheckProc, userdata(flag)=num2str(AveThinZ), userdata(field)="DimFlags"
	CheckBox AverageZChBox,help={"Average \"Thin\" number of values when thinning of 2 or greater is specified. Clearing this box forces to simply ignore all but one value out \"Thin\" data values."}
	VO+=22
	SetVariable SetLFrom,pos={HO+10,VO},size={116,18},bodyWidth=50,title="L (col) from",format="%u",limits={0,inf,1},value= $cG3FControl+":LFrom"
	SetVariable SetLFrom,help={""}
	SetVariable SetLTo,pos={HO+128,VO},size={64,18},bodyWidth=50,title="to",format="%u",limits={0,inf,1},value= $cG3FControl+":LTo"
	SetVariable SetLTo,help={""}
	SetVariable SetLThin,pos={HO+194,VO},size={64,18},bodyWidth=40,title="thin",format="%u",limits={1,inf,1},value= $cG3FControl+":LThin"
	SetVariable SetLThin,help={"Although uncommon for L dimension, allows a smaller subset of representaitve, equally-spaced rows to be used in analysis by either averaging or dropping values. Can GREATLY speed up calculations without loss of resolution."}
	CheckBox AverageLChBox,pos={HO+260,VO+1},size={40,15},title="ave.",  proc=G3F#StdCheckProc, userdata(flag)=num2str(AveThinL), userdata(field)="DimFlags"
	CheckBox AverageLChBox,help={"Average \"Thin\" number of values when thinning of 2 or greater is specified. Clearing this box forces to simply ignore all but one value out \"Thin\" data values."}
	
	VO=0
	HO=0
	GroupBox GlobalVariabesGroup,pos={HO+309,VO},size={261,525},title="Global Variables"
	GroupBox GlobalVariabesGroup,help={"Control over global variable"}
	SetVariable SetNumGlobVar,pos={HO+322,VO+18},size={84,18},bodyWidth=50,proc=G3F#MtrxSetNumGlobParamsProc,title="Fitted",limits={1,inf,1},value= $cG3FControl+":NumGlobVar"
	SetVariable SetNumGlobVar,help={"The number of global variables used in the model."}
	SetVariable SetNumSimVar,pos={HO+406,VO+18},size={110,18},bodyWidth=50,title="Process",limits={0,inf,1},value= $cG3FControl+":NumSimVar"
	SetVariable SetNumSimVar,help={"The number of process variables used in the model is deremined by the Process function. This number is not related to global variables although values are cacluated from global variables."}
	Button SetVarsButton,pos={HO+523,VO+18},size={35,18},proc=G3F#SetVarsButtonProc,title="set"
	Button SetVarsButton,help={"Configures the interface for the specified number of global and process variables."}
	
	VO= 40;
	GroupBox GlobGuessesGroupBox,pos={HO+314,VO},size={249,480},title="Initial Guesses"
	GroupBox GlobGuessesGroupBox,help={"Initial and final values for the global variables."}
	ListBox GlobGuessList,pos={HO+318,VO+40},size={240,435},frame=2,listWave=$cG3FControl+":GuessListWave",selWave=$cG3FControl+":GuessListSelection",mode= 7,editStyle= 1,widths={30,110,70}
	ListBox GlobGuessList,help={""}
	PopupMenu InitGuessToWaveMenu,pos={HO+453,VO+18},size={101,21},proc=G3F#MtrxInitGuessToWaveMenuProc,title="List To Wave",mode=0,value= #"G3F#MtrxListPsblInitialGuessWaves()+\"-;New Wave...\""
	PopupMenu InitGuessToWaveMenu,help={"Save current list of global variable values to a wave."}
	PopupMenu WaveToInitGuessMenu,pos={HO+321,VO+18},size={101,21},proc=G3F#MtrxWaveToInitGuessMenuProc,title="Wave To List",mode=0,value= #"G3F#MtrxListPsblInitialGuessWaves()"
	PopupMenu WaveToInitGuessMenu,help={"Restore the list of global variable values from a wave."}
	
	VO= 0 //295
	HO= 575 //308
	GroupBox LocalVariablesGroup,pos={HO,VO},size={261,275},title="Local variables"
	GroupBox LocalVariablesGroup,help={"Control over local variables. "}
	VO += 20
	SetVariable SetNumRowVar,pos={HO+20,VO},size={134,18},bodyWidth=50,proc=G3F#MtrxSetNumRowParamsProc,title="Row(X) Locals",limits={0,inf,1},value= $cG3FControl+":NumRowVar"
	SetVariable SetNumRowVar,help={"The number of per-row variables is determined by the selected fitting funciton."}
	CheckBox UseRowGuessesCheckBox,pos={HO+155,VO},size={56,15},proc=G3F#RecycleGuessesCheckProc,title="recycle",help={"Use values for locals from previous fit as initial guess"}, userdata(flag)=num2str(RecycleRow), userdata(list)="SetRowGuessPopup", userdata(field)="VarFlags"
	CheckBox UseRowGuessesCheckBox,help={"Use the results of previous calculation as initial guesses; if data range is resized values of per-row local guesses are interpolated. Otherwise, values are reset using specified guessing funciton."}
	PopupMenu SetRowGuessPopup,pos={HO+32,VO+22},size={225,23},bodyWidth=190, proc=G3F#RowGuessMenuProc,title="F(row):",value= #"G3F#ListRowGuessFunctions()"
	PopupMenu SetRowGuessPopup,help={"Function that calculates and sets intitial per-row local variables from scratch using dataset and calibration. Selected function must match the number variables an type of model used."}
	VO+=50
	DrawLine HO+4,VO-2,HO+253,VO-2
	SetVariable SetNumColVar,pos={HO+20,VO},size={134,18},bodyWidth=50,proc=G3F#MtrxSetNumColParamsProc,title="Col(Z) Locals",limits={0,inf,1},value= $cG3FControl+":NumColVar"
	SetVariable SetNumColVar,help={"The number of per-column variables is determined by the selected fitting funciton."}
	CheckBox UseColGuessesCheckBox,pos={HO+155,VO},size={56,15},proc=G3F#RecycleGuessesCheckProc,title="recycle",help={"Use values for locals from previous fit as initial guess"}, userdata(flag)=num2str(RecycleCol), userdata(list)="SetColGuessPopup", userdata(field)="VarFlags"
	CheckBox UseColGuessesCheckBox,help={"Use the results of previous calculation as initial guesses; if data range is resized values of per-column local guesses are interpolated. Otherwise, values are reset using specified guessing funciton."}
	CheckBox ColNo1stCheckBox,pos={HO+210,VO},size={52,15},title="no 1st", proc=G3F#StdCheckProc, userdata(flag)=num2str(No1stCol), userdata(field)="VarFlags"
	CheckBox ColNo1stCheckBox,help={"Do not correct the the first column in the columns range. May prevent multiple solutions if model uses row offset local parameter."}
	PopupMenu SetColGuessPopup,pos={HO+32,VO+22},size={225,23},bodyWidth=190, proc=G3F#ColGuessMenuProc,title="F(col):",value= #"G3F#ListColGuessFunctions()"
	PopupMenu SetColGuessPopup,help={"Function that calculates and sets intitial per-column local variables from scratch using dataset and calibration. Selected function must match the number variables an type of model used."}
	
	VO += 50
	DrawLine HO+4,VO-2,HO+253,VO-2
	SetVariable SetNumLayVar,pos={HO+20,VO},size={134,18},bodyWidth=50,proc=G3F#MtrxSetNumLayParamsProc,title="Lay(L) Locals",limits={0,inf,1},value= $cG3FControl+":NumLayVar"
	SetVariable SetNumLayVar,help={"The number of per-Lay variables is determined by the selected fitting funciton."}
	CheckBox UseLayGuessesCheckBox,pos={HO+155,VO},size={56,15},proc=G3F#RecycleGuessesCheckProc,title="recycle",help={"Use values for locals from previous fit as initial guess"}, userdata(flag)=num2str(RecycleLay), userdata(list)="SetLayGuessPopup", userdata(field)="VarFlags"
	CheckBox UseLayGuessesCheckBox,help={"Use the results of previous calculation as initial guesses; if data range is resized values of per-Lay local guesses are interpolated. Otherwise, values are reset using specified guessing funciton."}
	PopupMenu SetLayGuessPopup,pos={HO+32,VO+22},size={225,23},bodyWidth=190, proc=G3F#LayGuessMenuProc,title="F(Lay):",value= #"G3F#ListLayGuessFunctions()"
	PopupMenu SetLayGuessPopup,help={"Function that calculates and sets intitial per-Lay local variables from scratch using dataset and calibration. Selected function must match the number variables an type of model used."}

	VO += 50
	DrawLine HO+4,VO-2,HO+253,VO-2
	SetVariable SetNumLayRowVar,pos={HO+20,VO},size={134,18},bodyWidth=50,proc=G3F#MtrxSetNumLayRowParamsProc,title="LayRow(X) Locals",limits={0,inf,1},value= $cG3FControl+":NumLayRowVar"
	SetVariable SetNumLayRowVar,help={"The number of per-LayRow variables is determined by the selected fitting funciton."}
	CheckBox UseLayRowGuessesCheckBox,pos={HO+155,VO},size={56,15},proc=G3F#RecycleGuessesCheckProc,title="recycle",help={"Use values for locals from previous fit as initial guess"}, userdata(flag)=num2str(RecycleLayRow), userdata(list)="SetLayRowGuessPopup", userdata(field)="VarFlags"
	CheckBox UseLayRowGuessesCheckBox,help={"Use the results of previous calculation as initial guesses; if data range is resized values of per-LayRow local guesses are interpolated. Otherwise, values are reset using specified guessing funciton."}
	PopupMenu SetLayRowGuessPopup,pos={HO+32,VO+22},size={225,23},bodyWidth=190, proc=G3F#LayRowGuessMenuProc,title="F(LayRow):",value= #"G3F#ListLayRowGuessFunctions()"
	PopupMenu SetLayRowGuessPopup,help={"Function that calculates and sets intitial per-LayRow local variables from scratch using dataset and calibration. Selected function must match the number variables an type of model used."}

	VO += 50
	DrawLine HO+4,VO-2,HO+253,VO-2
	SetVariable SetNumLayColVar,pos={HO+20,VO},size={134,18},bodyWidth=50,proc=G3F#MtrxSetNumLayColParamsProc,title="LayCol(L) Locals",limits={0,inf,1},value= $cG3FControl+":NumLayColVar"
	SetVariable SetNumLayColVar,help={"The number of per-LayCol variables is determined by the selected fitting funciton."}
	CheckBox UseLayColGuessesCheckBox,pos={HO+155,VO},size={56,15},proc=G3F#RecycleGuessesCheckProc,title="recycle",help={"Use values for locals from previous fit as initial guess"}, userdata(flag)=num2str(RecycleLayCol), userdata(list)="SetLayColGuessPopup", userdata(field)="VarFlags"
	CheckBox UseLayColGuessesCheckBox,help={"Use the results of previous calculation as initial guesses; if data range is resized values of per-LayCol local guesses are interpolated. Otherwise, values are reset using specified guessing funciton."}
	PopupMenu SetLayColGuessPopup,pos={HO+32,VO+22},size={225,23},bodyWidth=190, proc=G3F#LayColGuessMenuProc,title="F(LayCol):",value= #"G3F#ListLayColGuessFunctions()"
	PopupMenu SetLayColGuessPopup,help={"Function that calculates and sets intitial per-LayCol local variables from scratch using dataset and calibration. Selected function must match the number variables an type of model used."}

	
	VO= 275
	HO = 575
	GroupBox OptionsGroup,pos={HO,VO},size={261,195},title="Options"
	GroupBox OptionsGroup,help={"Miscellanious fitting options."}
	SetVariable FitLimitCtrl,pos={HO+11,VO+15},size={203,18},title="ChiSq convergence limit",limits={1e-12,0.1,0.0001},value= $cG3FHome+":V_FitTol"
	SetVariable FitLimitCtrl,help={"The maximal reduction in chi-square between iterations that indicates a satisfactory fit. Small values may produce better fit but require a large number of iterations."}
	SetVariable SetFitMaxIters,pos={HO+11,VO+35},size={120,18},title="Max iterations",limits={2,500,1},value= $cG3FHome+":V_FitMaxIters"
	SetVariable SetFitMaxIters,help={"The limit on the number of iterations at which analysis should be stopped regardless of convergence."}
	CheckBox DoResidualCheck,pos={HO+7,VO+62},size={125,15},title="Residuals", proc=G3F#StdCheckProc, userdata(flag)=num2str(DoResiduals), userdata(field)="MiscFlags"
	CheckBox DoResidualCheck,help={"When checked, a residual wave named after data wave with a '\_residual\" suffix is calculated after the analysis. "}
	CheckBox ConstraintsCheckBox,pos={HO+97,VO+62},size={91,15},title="Constraints", proc=G3F#StdCheckProc, userdata(flag)=num2str(DoConstraints), userdata(field)="MiscFlags"
	CheckBox ConstraintsCheckBox,help={"Use constraints and hold settings specified in the constraints dialod."}
	CheckBox EpsilonCheckBox,pos={HO+187,VO+62},size={72,15},title="Epsilon", proc=G3F#StdCheckProc, userdata(flag)=num2str(DoEpsilon), userdata(field)="MiscFlags"
	CheckBox EpsilonCheckBox,help={"Use epsilon values specified in the constraints dialod. Epsilon specifies that size of a step for each variable that is made during each iteration. One of the most common source of singular error."}
	Button EditConstraintsButton,pos={HO+7,VO+83},size={110,22},proc=G3F#MatrixConstraintsEditProc,title="matrix constraints"
	Button EditConstraintsButton,help={"Opens matrix constraints dialog."}
	Button EditLayerConstraintsButton,pos={HO+7+115,VO+83},size={110,22},proc=G3F#LayerConstraintsEditProc,title="layer constraints"
	Button EditLayerConstraintsButton,help={"Opens layer constraints dialog."}
	CheckBox SplitLocals,pos={HO+7,VO+110},size={77,15},title="split locals",help={"Make individual waves for each of local variables"}, proc=G3F#StdCheckProc, userdata(flag)=num2str(SplitLocals), userdata(field)="MiscFlags"
	CheckBox SplitLocals,help={"Upon completion, generate or update separate 1-D waves for each local variable in addition to two 2-D locals waves for row and column variables. Content of these waves is not re-used in the analysis."}
	CheckBox SplitLocalsSigma,pos={HO+97,VO+110},size={115,15},title="... sigma", proc=G3F#StdCheckProc, userdata(flag)=num2str(SplitSigma), userdata(field)="MiscFlags"
	CheckBox SplitLocalsSigma,help={"Upon completion, generate or update separate 1-D sigma waves for each local variable in addition to two 2-D sigma waves for row and column variables."}
	CheckBox DelExtraLocals,pos={HO+187,VO+110},size={97,15},title="trim",help={"Delete locals that are not used in this fitting"}, proc=G3F#StdCheckProc, userdata(flag)=num2str(DelExtra), userdata(field)="MiscFlags"
	CheckBox DelExtraLocals,help={"When the number of local variables change, check for and delete unused separate locals waves."}
	CheckBox MinReportCheckBox,pos={HO+7,VO+135},size={113,15},title="Minimal reporting", proc=G3F#StdCheckProc, userdata(flag)=num2str(MinReport), userdata(field)="MiscFlags"
	CheckBox MinReportCheckBox,help={"Limit amout of information reported in the history area upon completion. This Is useful for auto-cycling holds."}
	CheckBox DoNotReportCheckBox,pos={HO+7,VO+154},size={47,15},title="Quiet", proc=G3F#StdCheckProc, userdata(flag)=num2str(QuietReport), userdata(field)="MiscFlags"
	CheckBox DoNotReportCheckBox,help={"currently does nothing."}
	CheckBox SupressDialogCheckBox,pos={HO+7,VO+173},size={71,15},title="No dialog", proc=G3F#StdCheckProc, userdata(flag)=num2str(SupressDlg), userdata(field)="MiscFlags"
	CheckBox SupressDialogCheckBox,help={"Prevents the fitting dialog from being displayed during analysis. This may speed up very simple models, but will not provide real-time updates on the progress and current values."}

	CheckBox EnableDevCheck,pos={HO+165,VO+155},size={100,15},proc=G3F#EnableIMDevCheckProc,title="Development"//,value= 0	
	CheckBox EnableDevCheck,help={"Shows full list of procedure files included in independent modules."}
	Button InfoButton,pos={HO+238,VO+173},size={18,18},proc=G3F#InfoButtonProc,title="\\K(0,12800,52224)\\f03\\F'Times'i",fSize=20,fColor=(65535,65535,65535)
	Button InfoButton,help={"About current version of analysis."}
	SetDrawEnv fstyle= 1;
	DrawText HO+165,VO+190,"ver. "+cG3FVer

	
	VO = 470
	HO = 575
	GroupBox DebugGroup,pos={HO,VO},size={174,45},title="Debugging"
	GroupBox DebugGroup,help={"Debugging options."}
	CheckBox LogCheckBox,pos={HO+12,VO+18},size={35,15},title="log", proc=G3F#StdCheckProc, userdata(flag)=num2str(EnableLog), userdata(field)="MiscFlags"
	CheckBox LogCheckBox,help={"Thoughout iterations, parameters are saved in a fitlog wave located in the G3F folder. Useful for troubleshooting Singular and NAN errors but may slow down calculation and swell exepriment size."}
	CheckBox DbgSaveCheckBox,pos={HO+62,VO+18},size={35,15},title="save", proc=G3F#StdCheckProc, userdata(flag)=num2str(DbgSave), userdata(field)="MiscFlags"
	CheckBox DbgSaveCheckBox,help={"."}
	CheckBox DbgKeepCheckBox,pos={HO+112,VO+18},size={35,15},title="keep", proc=G3F#StdCheckProc, userdata(flag)=num2str(DbgKeep), userdata(field)="MiscFlags" 
	CheckBox DbgKeepCheckBox,help={"."}
	
	
	VO=525 // 265
	HO = 530
	GroupBox HoldGroup,pos={HO,VO},size={268,80},title="Hold override"
	GroupBox HoldGroup,help={"Holding allows to exclude entire groups of variables from the analysis and use initial values as global, static data. Hold settings in the Constraints dialog are overriden here."}
	CheckBox HoldGlobCheck,pos={HO+8,VO+18},size={54,15},proc=G3F#HoldOverrideCheckProc,title="Global"//,value= 1
	CheckBox HoldGlobCheck,help={"Do not vary globals variables if checked. When cleared, hold setting in global section of the Constraints dialog apply."}
	CheckBox HoldRowCheck,pos={HO+8,VO+38},size={80,15},proc=G3F#HoldOverrideCheckProc,title="Local ROW"//,value= 1
	CheckBox HoldRowCheck,help={"Do not vary row variables if checked. When cleared, hold setting in row section of the Constraints dialog apply."}
	CheckBox HoldColCheck,pos={HO+8,VO+58},size={76,15},proc=G3F#HoldOverrideCheckProc,title="Local COL"//,value= 1
	CheckBox HoldColCheck,help={"Do not vary column variables if checked. When cleared, hold setting in column section of the Constraints dialog apply."}

	CheckBox HoldLayCheck,pos={HO+100,VO+18},size={76,15},proc=G3F#HoldOverrideCheckProc,title="Layer-global"//,value= 1
	CheckBox HoldLayCheck,help={"Do not vary layer variables if checked. When cleared, hold setting in layer section of the Constraints dialog apply."}

	CheckBox HoldLayRowCheck,pos={HO+100,VO+38},size={76,15},proc=G3F#HoldOverrideCheckProc,title="Layer ROW"//,value= 1
	CheckBox HoldLayRowCheck,help={"Do not vary Layer-row variables if checked. When cleared, hold setting in Layer-row section of the Constraints dialog apply."}
	
	CheckBox HoldLayColCheck,pos={HO+100,VO+58},size={76,15},proc=G3F#HoldOverrideCheckProc,title="Layer COL"//,value= 1
	CheckBox HoldLayColCheck,help={"Do not vary Layer-column variables if checked. When cleared, hold setting in Layer-column section of the Constraints dialog apply."}

	CheckBox HoldNoneCheck,pos={HO+192,VO+18},size={46,15},proc=G3F#HoldOverrideCheckProc,title="none"//,value= 0
	CheckBox HoldNoneCheck,help={"Do not hold anyting. Only settings in the Constraints dialog (if any) apply."}
	
	DrawText HO+192,VO+38+15,"chunk size:"

	SetVariable ChunkSize,pos={HO+202,VO+58},size={40,18},bodyWidth=40,title=" ",value= $cG3FControl+":LocalOnlyChunks"
	SetVariable ChunkSize,help={"The number of rows to be caclulated together (a chunk) when only row local variabeles are analyzed. If either global or column variable are NOT held entide data range is analyzed."}

	VO=525 //365
	HO = 800
	GroupBox AutoCycleGroup,pos={HO,VO},size={218,80},title="Autocycle hold"
	SetVariable autoCycleSetVar,pos={HO+7,VO+18},size={95,18},bodyWidth=50,title="# cycles",limits={2,inf,1},value= $cG3FControl+":autoCycles"
	SetVariable autoCycleSetVar,help={"Set the number of automatic cycles to be perfomed using one of combinations below."}
	Button AutoCycleGRCButton,pos={HO+3,VO+38},size={105,20},proc=G3F#AutoCycleButtonProc,title="Global - Row - Col"
	Button AutoCycleGRCButton,help={"Alternate analysis of one group at a time between Global, Row local and Column local variables."}
	Button AutoCycleGRButton,pos={HO+110,VO+58},size={105,20},proc=G3F#AutoCycleButtonProc,title="Global - Row"
	Button AutoCycleGRButton,help={"Alternate analysis of one group at a time between Global and Row local variables."}
	Button AutoCycleGCButton,pos={HO+110,VO+38},size={105,20},proc=G3F#AutoCycleButtonProc,title="Global - Col"
	Button AutoCycleGCButton,help={"Alternate analysis of one group at a time between Global and Column local variables."}
	Button AutoCycleRCButton,pos={HO+3,VO+58},size={105,20},proc=G3F#AutoCycleButtonProc,title="Row - Col"
	Button AutoCycleRCButton,help={"Alternate analysis of one group at a time between  Row local and Column local variables."}
	
	VO=0
	HO = 842
	SetDrawEnv fstyle= 1;
	DrawText HO+4,VO+38,"X:"
	GroupBox FeedbackGroup,pos={HO,VO},size={189,525},title="Feedback positions"
	GroupBox FeedbackGroup,help={"Profile Feedback allows to calculate charactristic profiles (rows) upon completion and visually compare to original data."}
	Button NewRowFeedbackLineButton,pos={HO+20,VO+20},size={54,18},proc=G3F#MtrxNewRowFeedbackLineBProc,title="Add"
	Button NewRowFeedbackLineButton,help={"Add a new line to the list."}
	Button RemoveRowFeedbackLineButton,pos={HO+73,VO+20},size={54,18},proc=G3F#MtrxRemoveRowFeedbackLineBProc,title="Remove"
	Button RemoveRowFeedbackLineButton,help={"Remove current line from the list."}
	CheckBox FeedbackRowClearListCheck,pos={HO+140,VO+21},size={46,15},title="reset", proc=G3F#StdCheckProc, userdata(flag)=num2str(FeedbackRowClear), userdata(field)="MiscFlags" 
	CheckBox FeedbackRowClearListCheck,help={"Reset feeback marks. When selected, rows flagged for feedback will be cleared before filling from this list; otherwise current positins are added to those marked previously."}
	ListBox FeedbackRowList,pos={HO+6,VO+38},size={177,215},frame=2,listWave=$cG3FControl+":FeedbackRowListWave" ,selWave=$cG3FControl+":FeedbackRowSelectionWave",mode= 4,editStyle= 1
	ListBox FeedbackRowList,help={"Values are in row calibration. Clb: central position; [Optional: Frame - averaging frame for this row; Base 1 - reference point or baseline point 1;  Base 2 - baseline point 2 ]"}

	VO=243
	SetDrawEnv fstyle= 1;
	DrawText HO+4,VO+38,"Z:"
	Button NewColFeedbackLineButton,pos={HO+20,VO+20},size={54,18},proc=G3F#MtrxNewColFeedbackLineBProc,title="Add"
	Button NewColFeedbackLineButton,help={"Add a new line to the list."}
	Button RemoveColFeedbackLineButton,pos={HO+73,VO+20},size={54,18},proc=G3F#MtrxRemoveColFeedbackLineBProc,title="Remove"
	Button RemoveColFeedbackLineButton,help={"Remove current line from the list."}
	CheckBox FeedbackColClearListCheck,pos={HO+140,VO+21},size={46,15},title="reset", proc=G3F#StdCheckProc, userdata(flag)=num2str(FeedbackColClear), userdata(field)="MiscFlags" 
	CheckBox FeedbackColClearListCheck,help={"Reset feeback marks. When selected, Cols flagged for feedback will be cleared before filling from this list; otherwise current positins are added to those marked previously."}
	ListBox FeedbackColList,pos={HO+6,VO+38},size={177,215},frame=2,listWave=$cG3FControl+":FeedbackColListWave" ,selWave=$cG3FControl+":FeedbackColSelectionWave",mode= 4,editStyle= 1
	ListBox FeedbackColList,help={"Values are in Col calibration. Clb: central position; [Optional: Frame - averaging frame for this Col; Base 1 - reference point or baseline point 1;  Base 2 - baseline point 2 ]"}
	
	VO=502
	SetVariable FeedbackLayerCtrl,pos={HO+5,VO},size={90,18},title="Layer",limits={0,0,1},value= $cG3FControl+":FeedbackLayer"
	SetVariable FeedbackLayerCtrl,help={"Select layer to be used in feedback plots"}
	Button UpdateFeedbackButton,pos={HO+100,VO},size={65,18},proc=G3F#UpdateFeedbackButtonProc,title="Update"
	Button UpdateFeedbackButton,help={"Update feedback plots now."}

	VO=470
	HO = 750
	GroupBox DesktopGroup,pos={HO,VO},size={85,55},title="Desktop"
	GroupBox FeedbackGroup,help={"Save and restore current set"}

	Button SaveButton,pos={HO+5,VO+15},size={70,17},proc=SaveButtonProc,title="Save"
	Button SaveButton,help={"Saves current configuration into a desktop wave."}
	Button RestoreButton,pos={HO+5,VO+34},size={70,17},proc=RestoreButtonProc,title="Restore"
	Button RestoreButton,help={"Restores current configuration from a desktop wave."}

	VO=525
	HO = 309 //577
	GroupBox FitGlobalsGroup,pos={HO,VO},size={218,81},title="Global fit"
	GroupBox FitGlobalsGroup,help={""}
	Button DoFitButton,pos={HO+5,VO+18},size={100,30},proc=G3F#DoFitButtonProc,title="Do fit now!", fColor=(19456,39168,0)
	Button DoFitButton,help={"Your main button. When all groups of variables are held, performs a simple calulation using current parameters instead of regression analysis."}
	Button SimFitButton,pos={HO+5,VO+51},size={55,22},proc=G3F#SimulateFitButtonProc,title="simulate"
	Button SimFitButton,help={"Performs a simple calulation using current parameters instead of regression analysis, regardless of hold settings."}
	SetVariable setIdCtrl,pos={HO+110,VO+23},size={100,18},title="set ID", value= $cG3FControl+":setId"
	SetVariable setIdCtrl,help={""}
	SetVariable nThreadsCtrl,pos={HO+66,VO+53},size={65,18},title="use",limits={1,4,1},value= $cG3FControl+":useThreads"
	SetVariable nThreadsCtrl,help={"Limit the number of threads used by fitting and process functions during calculations. Cannot be larger than the number of actual logical threads."}
	SetVariable showNThreadsCtrl,pos={HO+135,VO+53},size={88,18}, bodywidth=30, disable=2,title="threads /",frame=0,limits={1,-1,0},value= $cG3FControl+":nThreads",noedit= 1
	SetVariable showNThreadsCtrl,help={"The number of actual logical threads available on this computer."}
end




Function InfoButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			NewPanel /W=(250,200,615,294)  /N=G3FitAbout as "About G3F"
			SetDrawEnv fsize= 14
			DrawText 22,33,"2-D Global Spectral Nonlinear Regression Analysis"
			SetDrawEnv fsize= 14
			DrawText 138,60,"version "+cG3FVer
			Button CloseButton,pos={141,67},size={50,20},proc=G3F#ButtonProc,title="Close"
			// click code here
			PauseForUser G3FitAbout
			break
	endswitch

	return 0
End

Function ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			DoWindow /K G3FitAbout
			// click code here
			break
	endswitch

	return 0
End




function Dialog2Vars()
	// this section matches selection in the popup control with corresponsing global variables
	FixMatrixSimFunctions()
	FixPopupControl("FitFunction",ListG3FitFunctions(), "FitFunctionPopup");
	FixPopupControl("CorrFunction",ListCorrFunctions(), "CorrFunctionPopup");

	FixPopupControl("MatrixWave", ChooseMatrixWaveMenuContents(), "ChooseMatrixPopup");
	FixPopupControl("ColLimWaveName", ChooseColLimPopupContents(), "ChooseColLimWavePopup");
	FixPopupControlProc("AddtlDataWN", AddtlDataPopupContents(), "AddtlParamsPopup", AddtlDataPopMenu); //AddtlDataPopMenu(popStr)
	
	FixPopupControl("ZWave", ChooseZClbWPopContents(), "ChooseZClbWPopup");
	FixPopupControl("ZRefWave", ChooseZRefWPopContents(), "ChooseZRefWPopup");
	FixPopupControl("XWave", ChooseXClbWPopContents(), "ChooseXClbWPopup");
	FixPopupControl("XRefWave", ChooseXRefWPopContents(), "ChooseXRefWPopup");
	FixPopupControl("SetRowGuessFunction",  ListRowGuessFunctions(), "SetRowGuessPopup");
	FixPopupControl("SetColGuessFunction",  ListColGuessFunctions(), "SetColGuessPopup");

	// read DimFlags
	FixCheckControl("DimFlags", MakeThinX, "MakeXClbCheckBox")
	FixCheckControl("DimFlags", MakeThinZ, "MakeZClbCheckBox")
	FixCheckControl("DimFlags", MakeThinL, "MakeLClbCheckBox")
	FixCheckControl("DimFlags", AveThinX, "AverageXChBox")
	FixCheckControl("DimFlags", AveThinZ, "AverageZChBox")
	FixCheckControl("DimFlags", AveThinL, "AverageLChBox")

	// read VarFlags
	FixFuncCheckControl("VarFlags", RecycleRow, "UseRowGuessesCheckBox", "SetRowGuessPopup")
	FixFuncCheckControl("VarFlags", RecycleCol, "UseColGuessesCheckBox", "SetColGuessPopup")
	FixFuncCheckControl("VarFlags", RecycleLay, "UseLayGuessesCheckBox", "SetLayGuessPopup")
	FixFuncCheckControl("VarFlags", RecycleLayRow, "UseLayRowGuessesCheckBox", "SetLayRowGuessPopup")
	FixFuncCheckControl("VarFlags", RecycleLayCol, "UseLayColGuessesCheckBox", "SetLayColGuessPopup")

	FixCheckControl("VarFlags", HoldGlob, "HoldGlobCheck")
	FixCheckControl("VarFlags", HoldRow, "HoldRowCheck")
	FixCheckControl("VarFlags", HoldCol, "HoldColCheck")
	FixCheckControl("VarFlags", HoldLay, "HoldLayCheck")
	FixCheckControl("VarFlags", HoldLayRow, "HoldLayRowCheck")
	FixCheckControl("VarFlags", HoldLayCol, "HoldLayColCheck")
	FixCheckControl("VarFlags", HoldNone, "HoldNoneCheck")
	FixCheckControl("VarFlags", No1stCol, "ColNo1stCheckBox")

	
		
	FixCheckControl("MiscFlags", KeepLastSim, "KeepLastSimCheckBox");
	FixCheckControl("MiscFlags", ReuseLastSim, "ReuseProcessCheckBox");
	FixCheckControl("MiscFlags", MTProcess, "MTProcessCheckBox");
	FixCheckControl("MiscFlags", DoResiduals, "DoResidualCheck");
	FixCheckControl("MiscFlags", DoConstraints	, "ConstraintsCheckBox");
	FixCheckControl("MiscFlags", DoEpsilon, "EpsilonCheckBox");
	FixCheckControl("MiscFlags", SplitLocals, "SplitLocals");
	FixCheckControl("MiscFlags", SplitSigma, "SplitLocalsSigma");
	FixCheckControl("MiscFlags", DelExtra, "DelExtraLocals");
	FixCheckControl("MiscFlags", MinReport, "MinReportCheckBox");
	FixCheckControl("MiscFlags", QuietReport, "DoNotReportCheckBox");
	FixCheckControl("MiscFlags", SupressDlg, "SupressDialogCheckBox");
	FixProcCheckControl("MiscFlags", EnableDev, "EnableDevCheck", EnableIMDevCheckProc);
	FixCheckControl("MiscFlags", EnableLog, "LogCheckBox");
	FixCheckControl("MiscFlags", DbgSave, "DbgSaveCheckBox");
	FixCheckControl("MiscFlags", DbgKeep, "DbgKeepCheckBox");
	FixCheckControl("MiscFlags", FeedbackRowClear	, "FeedbackRowClearListCheck");
		
	
end

