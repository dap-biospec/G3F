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


//***********************************************************************************************

//***********************************************************************************************
//          F E E D B A C K    P R O F I L E S  
//***********************************************************************************************

structure FeedbackTypeT 
	variable i;
	string name;
	string indexCaption;
	string indexVar; 
	string plotVar;
	string plotCaption;
	string selectVar;
	string selectCaption;
	variable selectI;
endstructure 


function GetFeedbackType( FT, dimN)
	STRUCT FeedbackTypeT &FT;
	variable dimN
	
	FT.i = dimN;
	switch (dimN)
		case 0:
			FT.name = "Row";
			FT.indexVar = "X";
			FT.plotVar = "Z";
			FT.indexCaption = "Rows";
			FT.plotCaption = "Columns";
			FT.selectVar = "L";
			FT.selectCaption = "Layer";
			FT.selectI = 2;
			break;
		case 1:
			FT.name = "Col";
			FT.indexVar = "Z";
			FT.plotVar = "X"
			FT.indexCaption = "Columns";
			FT.plotCaption = "Rows";
			FT.selectVar = "L";
			FT.selectCaption = "Layer";
			FT.selectI = 2;
			break;
		case 2:
			FT.name = "Lay";
			FT.indexVar = "L";
			FT.plotVar = ""
			FT.indexCaption = "Layers";
			FT.plotCaption = "??";
			FT.selectVar = "";
			FT.selectCaption = "";
			FT.selectI = -1;
			break;
		default: 
			FT.i = -1;		
			FT.indexVar = "";
			FT.plotVar = ""
			FT.indexCaption = "";
			FT.selectVar = "";
			FT.selectCaption = "";
			FT.selectI = -1;
			return 0
	endswitch
	return 1;
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
Function ShowScrollWindow(dimN)
	variable dimN;
	
	STRUCT FeedbackTypeT FT;
	if (!GetFeedbackType(FT, dimN))
		return 0;
	endif
	

	string winNameS = "G3F_FB_"+FT.indexVar+FT.plotVar+"Scroll" 
	string ProcNameBase = FT.indexVar+FT.plotVar;
	if (wintype(winNameS) != 0)
		DoWindow/F $winNameS
		return 1;
	endif
	string baseName = cG3FControl+":Scroll"+FT.indexVar+FT.plotVar
	Variable /G  $baseName+"Pos"
	NVAR ProfClbPos =  $baseName+"Pos"
	Variable /G  $baseName+"Clb"
	NVAR ProfileClb =  $baseName+"Clb"
	Variable /G  $baseName+"Mate"
	NVAR ProfileMate =  $baseName+"Mate"
	Variable /G  $baseName+"Sel"
	NVAR ProfileSelect =  $baseName+"Sel"


	PauseUpdate; Silent 1		// building window...
	DoWindow /K $winNameS
	Display /W=(100,50,650,250) /N=$winNameS as "G3F: "+FT.Name+" vs. "+FT.plotVar+"  Scroller"
		
	ShowTools
	ControlBar 27
	SetVariable SetOrgPos,pos={10,2},size={130,16},proc=$"ScrollOriginalPosProc", userData=num2Str(FT.i), title="original "+FT.indexVar+"#"
	SetVariable SetOrgPos,limits={0,0,0},value= $baseName+"Mate",bodyWidth= 70
	SetVariable SetFitPos,pos={155,2},size={90,16},proc=$"ScrollFittedPosProc", userData=num2Str(FT.i), title="fit #"
	SetVariable SetFitPos,limits={0,0,1},value= $baseName+"Pos",bodyWidth= 70
	SetVariable SetClbPos,pos={260,2},size={115,16},proc=$"ScrollCalibratedPosProc", userData=num2Str(FT.i), title="Calibration"
	SetVariable SetClbPos,limits={-inf,inf,0},value= $baseName+"Clb",bodyWidth= 60

	SetVariable SetSelPos,pos={390,2},size={120,16},proc=$"ScrollSelectPosProc", userData=num2Str(FT.i), title="for "+FT.selectCaption+" #"
	SetVariable SetSelPos,limits={0,0,1},value= $baseName+"Sel",bodyWidth= 70


	CheckBox OverlayCheck,pos={550,2},size={50,14},proc=$"ScrollOverlaySuperimposeProc", userData=num2Str(FT.i), title="overlay"
	CheckBox OverlayCheck,value= 0, disable = 2
	Button PrevOverlay,pos={525,1},size={20,20},proc=$"ScrollOverlayPrevProc", userData=num2Str(FT.i), title=" < "
	Button NextOverlay,pos={610,1},size={20,20},proc=$"ScrollOverlayNextProc", userData=num2Str(FT.i), title=" > "
	
	// Need to find fitted data and update ranges!
	SVAR MatrixWN = $cG3FControl+":MatrixWave"
	NVAR From = $cG3FControl+":"+FT.indexVar+"From"
	NVAR To = $cG3FControl+":"+FT.indexVar+"To"
	NVAR Thin = $cG3FControl+":"+FT.indexVar+"Thin"
	SetVariable SetOrgPos,limits={From,To,Thin}
	SVAR MatrixFitWN = $cG3FControl+":MatrixWaveFit"
	if (waveexists($MatrixFitWN))
		SetVariable SetFitPos,limits={0,dimSize($MatrixFitWN, FT.i)-1,1}
		SetVariable SetSelPos,limits={0,dimSize($MatrixFitWN, FT.selectI)-1,1}
	else
		SetVariable SetFitPos,limits={0,0,0}
		SetVariable SetSelPos,limits={0,0,0}
	endif 
	DoUpdateScroll(FT)	
	Label/W=$winNameS bottom FT.plotCaption+" calibration" 
	end
	

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Single, scrolling profile
Function DoUpdateScroll(FT)
	STRUCT FeedbackTypeT &FT;

	SVAR MWaveS = $cG3FControl+":MatrixWave"
	SVAR MWaveFitS = $cG3FControl+":MatrixWaveFit"
	SVAR LWaveFitS = $cG3FControl+":LWaveFit"
	
	SVAR sSetID = $cG3FControl+":setID";
	string MWaveThinS = MWaveS+sSetID+"_ThinRng";
	
	
	string 	winNameS = "G3F_FB_"+FT.indexVar+FT.plotVar+"Scroll"
	SVAR MainDimClbFitS = $cG3FControl+":"+FT.indexVar+"WaveFit"
	SVAR PlotDimClbS = $cG3FControl+":"+FT.plotVar+"Wave"
	SVAR PlotDimClbFitS = $cG3FControl+":"+FT.plotVar+"WaveFit"
	
	
	string OrgWaveS;
	variable UseOrig;

	if ((Exists(MWaveThinS)!=1)||(Exists(PlotDimClbFitS)!=1)) // both are required to plot thinned matrix!
		if(Exists(MWaveS)!=1)
			DoAlert 0, "Can not update profiles without matrix wave"
			return -1
		else
			OrgWaveS = MWaveS;
			UseOrig=1;
		endif
	else 
		OrgWaveS = MWaveThinS; 
		UseOrig=0;
	endif
	
	WAVE MWave = $OrgWaveS

	string baseName = cG3FControl+":Scroll"+FT.indexVar+FT.plotVar
	NVAR ProfClbPos =  $baseName+"Pos"
	NVAR ProfClbVal =  $baseName+"Clb"
	NVAR ProfMate =  $baseName+"Mate"
	NVAR ProfSelect =  $baseName+"Sel"


	WAVE MWaveFit = $MWaveFitS 
	if(Exists(MainDimClbFitS)==1)
		WAVE MainDimClbFit = $MainDimClbFitS
		
		 if (ProfClbPos >= DimSize(MainDimClbFit,0))
	 		ProfClbPos = DimSize(MainDimClbFit,0) -1;
		 endif
		// Check for original data 
		NVAR SelFrom = $cG3FControl+":"+FT.selectVar+"From"
		NVAR SelThin = $cG3FControl+":"+FT.selectVar+"Thin"
		
		ProfClbVal = MainDimClbFit[ProfClbPos][0];
		ProfMate = MainDimClbFit[ProfClbPos][1];
		variable PlotPos = UseOrig ?  ProfMate : ProfClbPos;
		if (UseOrig)
			WAVE clbWave = $PlotDimClbS
		else 
			WAVE clbWave = $PlotDimClbFitS;
		endif 
		switch (FT.i)
			case 0:
				UpdateScrollXZTrace(winNameS, NameOfWave(MWave), MWave, PlotPos, clbWave, SelFrom + ProfSelect * SelThin, 0);
				break;
			case 1:
				UpdateScrollZXTrace(winNameS, NameOfWave(MWave), MWave, PlotPos, clbWave, SelFrom + ProfSelect * SelThin, 0);
				break;
		endswitch;
		
		// Check for fitted data
		if ((Exists(MWaveFitS)==1) && (Exists(PlotDimClbFitS)==1))
			switch (FT.i)
				case 0:
					UpdateScrollXZTrace(winNameS, NameOfWave(MWaveFit), MWaveFit, ProfClbPos, $PlotDimClbFitS, ProfSelect, 1);
					break;
				case 1:
					UpdateScrollZXTrace(winNameS, NameOfWave(MWaveFit), MWaveFit, ProfClbPos, $PlotDimClbFitS, ProfSelect, 1);
					break;
			endswitch;
		else
			RemoveFromGraph /W=$winNameS MWaveFit 
		endif
		CheckBox OverlayCheck win=$winNameS, disable=0, value= MainDimClbFit[ProfClbPos][2]
	else
		RemoveFromGraph /W=$winNameS /Z MWave
		RemoveFromGraph /W=$winNameS /Z MWaveFit
		ProfClbVal = NAN
		ProfMate = NAN
		CheckBox OverlayCheck win=$winNameS, disable=2, value=0
	endif
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//

function UpdateScrollXZTrace(winNameS, traceNameS, MWave, PlotPos, clbWave, iLay, dispType)
	string winNameS
	string traceNameS
	wave MWave
	variable PlotPos 
	wave clbWave
	variable iLay
	variable dispType

	CheckDisplayed /W=$winNameS MWave
	if (V_flag) 
		ReplaceWave /W=$winNameS trace=$traceNameS, MWave[PlotPos][][iLay]
	else
		AppendToGraph /W=$winNameS MWave[PlotPos][][iLay] vs clbWave[][0]
		setScrollStyle(winNameS, traceNameS, dispType);
	endif
end 

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function UpdateScrollZXTrace(winNameS, traceNameS, MWave, PlotPos, clbWave, iLay, dispType)
	string winNameS
	string traceNameS
	wave MWave
	variable PlotPos 
	wave clbWave
	variable iLay
	variable dispType 

	CheckDisplayed /W=$winNameS MWave
	if (V_flag) 
		ReplaceWave /W=$winNameS trace=$traceNameS, MWave[][PlotPos][iLay]
	else
		AppendToGraph /W=$winNameS MWave[][PlotPos][iLay] vs clbWave[][0]
		setScrollStyle(winNameS, traceNameS, dispType);
	endif
end 

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function setScrollStyle(winNameS, traceNameS, dispType)
	string winNameS
	string traceNameS
	variable dispType 
	switch (dispType)
		case 0:
			ModifyGraph /W=$winNameS mode($traceNameS)=3, marker($traceNameS)=8, rgb($traceNameS)=(0,0,65280)
			break;
		case 1:
			ModifyGraph /W=$winNameS mode($traceNameS)=0
			break;
	endswitch 
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Set feedback by position in original data

Function ScrollOriginalPosProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	
	if (sva.eventCode != 1 && sva.eventCode != 8)
		return 0;
	endif

	ScrollOriginalPos(sva.userData, sva.dval);
end


//~~~~~~~~~~~~~~~~~~~
Function ScrollOriginalPos(dimStr, dVal)
	variable dVal
	string dimStr
	
	STRUCT FeedbackTypeT FT;
	if (!GetFeedbackType(FT, str2num(dimStr)))
		return 0;
	endif
	
	string baseName = cG3FControl+":Scroll"+FT.indexVar+FT.plotVar
	NVAR ProfClbPos = $baseName+"Pos"
	SVAR MainDimClbFitS = $cG3FControl+":"+FT.indexVar+"WaveFit"
	
	if (Exists(MainDimClbFitS)==1)
		WAVE MainDimClbFit = $MainDimClbFitS
		variable points = DimSize(MainDimClbFit, 0)
		if (dVal < MainDimClbFit[0][1])  // check limits
			ProfClbPos = 0;
		elseif (dVal>MainDimClbFit[points-1][1])
			ProfClbPos = points -1
		else // look for the closest match
			variable i, pos, found
			for(i=1, found =0; i< points;i+=1, found +=1)	
				if (dVal < MainDimClbFit[i][1]) 
					break;
				endif
			endfor		
			if (dVal >= (MainDimClbFit[found][1] + MainDimClbFit[found+1][1])/2)			
				found +=1	
			endif					
			ProfClbPos = found 
		endif
	endif
	 DoUpdateScroll(FT)	 
End


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Set feedback by position in fitted data
Function ScrollFittedPosProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	if (sva.eventCode != 1 && sva.eventCode != 8)
		return 0;
	endif
		
	ScrollFittedPos(sva.userData);
end

//~~~~~~~~~~~~~~~~~~~
Function ScrollFittedPos(dimStr)
	string dimStr;
	
	STRUCT FeedbackTypeT FT;
	if (!GetFeedbackType(FT, str2num(dimStr)))
		return 0;
	endif

	SVAR MainDimClbFitS = $cG3FControl+":"+FT.indexVar+"WaveFit"
	if (Exists(MainDimClbFitS)== 1)
		WAVE MainDimClbFit = $MainDimClbFitS
		string baseName = cG3FControl+":Scroll"+FT.indexVar+FT.plotVar
		NVAR ProfClbPos = $baseName+"Pos"
		 if (ProfClbPos >= DimSize(MainDimClbFit,0)) // just check the upper limit // Igor 8 fix
	 		ProfClbPos = DimSize(MainDimClbFit,0) -1; // Igor 8 fix
		endif
	endif
	DoUpdateScroll(FT)	 
End

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Set feedback by calibrated value
Function ScrollCalibratedPosProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	if (sva.eventCode != 1 && sva.eventCode != 8)
		return 0;
	endif
		
	ScrollCalibratedPos(sva.userData, sva.dval)
end	

//~~~~~~~~~~~~~~~~~~~
Function ScrollCalibratedPos(dimStr, dVal)
	string dimStr;
	variable dVal
	
	STRUCT FeedbackTypeT FT;
	if (!GetFeedbackType(FT, str2num(dimStr)))
		return 0;
	endif

	SVAR MainDimClbFitS = $cG3FControl+":"+FT.indexVar+"WaveFit"

	variable newPos = FitClb2Pos(dval, MainDimClbFitS)

	if (newPos < 0 )
		return 0;
	endif
	DoUpdateScroll(FT)
	return 1
End


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Set feedback by position in fitted data
Function ScrollSelectPosProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	if (sva.eventCode != 1 && sva.eventCode != 8)
		return 0;
	endif
		
	ScrollSelectPos(sva.userData);
end

//~~~~~~~~~~~~~~~~~~~
Function ScrollSelectPos(dimStr)
	string dimStr;
	
	STRUCT FeedbackTypeT FT;
	if (!GetFeedbackType(FT, str2num(dimStr)))
		return 0;
	endif

	SVAR MainDimClbFitS = $cG3FControl+":"+FT.selectVar+"WaveFit"
	if (Exists(MainDimClbFitS)== 1)
		WAVE MainDimClbFit = $MainDimClbFitS
		string baseName = cG3FControl+":Scroll"+FT.indexVar+FT.plotVar
		NVAR ProfSelPos = $baseName+"Sel"
		 if (ProfSelPos >= DimSize(MainDimClbFit,0)) // just check the upper limit // Igor 8 fix
	 		ProfSelPos = DimSize(MainDimClbFit,0) -1; // Igor 8 fix
		endif
	endif
	DoUpdateScroll(FT)	 
End


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// marks current profile for feedback overlay 
// called upon checking display option in the feedback window
Function ScrollOverlaySuperimposeProc(cba) : CheckBoxControl
	STRUCT WMCheckBoxAction &cba
	if (cba.eventCode != 2)
		return 0;
	endif
	
	
	ScrollOverlaySuperimpose(cba.userData, cba.checked)	
	end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
Function  ScrollOverlaySuperimpose(dimStr, checked)	
	string dimStr
	variable checked

	STRUCT FeedbackTypeT FT;
	if (!GetFeedbackType(FT, str2Num(dimStr)))
		return 0;
	endif
	
	
	string baseName = cG3FControl+":Scroll"+FT.indexVar+FT.plotVar
	NVAR ProfClbPos = $baseName+"Pos"
	SVAR RefWaveFitS = $cG3FControl+":"+FT.indexVar+"WaveFit"
	if (Exists(RefWaveFitS)==1)
		WAVE RefWaveFit = $RefWaveFitS
		if (RefWaveFit[ProfClbPos][2] != checked)
			RefWaveFit[ProfClbPos][2] = checked
			DoUpdateOverlay(FT, 0)
		endif
	endif
End

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// scroll to previous flagged profile
Function  ScrollOverlayPrevProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	if (ba.eventCode != 2)
		return 0;
	endif
	
	ScrollOverlayPrev(ba.userData)	
	end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
Function  ScrollOverlayPrev(dimStr)	
	string dimStr

	STRUCT FeedbackTypeT FT;
	if (!GetFeedbackType(FT, str2Num(dimStr)))
		return 0;
	endif
	
	string baseName = cG3FControl+":Scroll"+FT.indexVar+FT.plotVar
	NVAR ProfClbPos = $baseName+"Pos"
	SVAR RefWaveFitS = $cG3FControl+":"+FT.indexVar+"WaveFit"
	if (Exists(RefWaveFitS)==1)
		WAVE RefWaveFit = $RefWaveFitS
		if (ProfClbPos == 0)
			return 0;
		endif
		variable points = DimSize(RefWaveFit, 0)
		variable i, pos, found = -1
		for(i=ProfClbPos-1; i>=0;i-=1)	
			if (RefWaveFit[i][2]!=0) 
				found = i;
				break;
			endif
		endfor
		if (found > 0)		
			ProfClbPos = found 
			DoUpdateScroll(FT)	 
		else
	//		did not find any flagged profiles, stay where you were...
		endif
	endif
End

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// scroll to next flagged profile
Function  ScrollOverlayNextProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	if (ba.eventCode != 2)
		return 0;
	endif
	
	ScrollOverlayNext(ba.userData)	
	end

	
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
Function  ScrollOverlayNext(dimStr)	
	string dimStr

	STRUCT FeedbackTypeT FT;
	if (!GetFeedbackType(FT, str2Num(dimStr)))
		return 0;
	endif
	
	string baseName = cG3FControl+":Scroll"+FT.indexVar+FT.plotVar
	NVAR ProfClbPos = $baseName+"Pos"
	SVAR RefWaveFitS = $cG3FControl+":"+FT.indexVar+"WaveFit"
	if (Exists(RefWaveFitS)==1)
		WAVE RefWaveFit = $RefWaveFitS
		variable points = DimSize(RefWaveFit, 0)
		if (ProfClbPos >= points -1)
			return 0;
		endif
		variable i, pos, found = -1
		for(i=ProfClbPos+1; i< points;i+=1)	
			if (RefWaveFit[i][2]!=0) 
				found = i;
				break;
			endif
		endfor
		if (found > 0)		
			ProfClbPos = found 
			DoUpdateScroll(FT)	 
		else
	//		did not find any flagged profiles, stay where you were...
		endif
	endif
End


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function MakeOverlayWindow(FT)
	STRUCT FeedbackTypeT &FT;
	
	string winNameS = "G3F_FB_"+FT.indexVar+FT.plotVar+"ProfOverlay"
	DoWindow /K $winNameS
	Display /W=(770.4,54.2,1182.6,261.8) /N=$winNameS as "G3F: "+FT.name+" vs "+FT.plotVar+" Feedback Overlay"
	Legend /N=OverlayLegend  /T={55, 100, 145} "no references"
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
Function ShowOverlayWindow(dim)
	variable dim;

	STRUCT FeedbackTypeT FT;
	if (!GetFeedbackType(FT, dim))
		return 0;
	endif
	
	string winNameS = "G3F_FB_"+FT.indexVar+FT.plotVar+"ProfOverlay"

	if (wintype(winNameS) == 0)
		DoUpdateOverlay(FT, 1)
	else
		DoWindow/F $winNameS
	endif
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
Function DoUpdateOverlay(FT, must)
	STRUCT FeedbackTypeT &FT;
	variable must // force creating window

	string winNameS = "G3F_FB_"+FT.indexVar+FT.plotVar+"ProfOverlay"
	
	// Check if window exists
	switch (WinType(winNameS))
		case 0:  // not in use - make it 
			if (must)
				MakeOverlayWindow(FT);
			else
				return 0;
			endif
		case 1: //  Ok - it's a window 
			break;
		default:
			if (must)
				DoAlert 0, "Name \""+winNameS+"\" is used by a non-graph window. Feedback Overlay cannot be updated..." 
				return 0;
			endif
	endswitch 
	
	NVAR iLay = $cG3FControl+":FeedbackLayer"
	SVAR  RefWaveFitS =$cG3FControl+":"+FT.indexVar+"WaveFit" 
	variable i, pnts, r
	if (Exists(RefWaveFitS)!=1)
		print "RefWaveFitS=["+RefWaveFitS+"] was not found"
		return -1
	endif
	
	WAVE RefWaveFit = $RefWaveFitS
	SVAR MWaveS = $cG3FControl+":MatrixWave"
	WAVE MWave = $MWaveS

	NVAR RefThin = $cG3FControl+":"+FT.indexVar+"Thin"
	NVAR DimFlags = $cG3FControl+":DimFlags"
	variable doAve;
	switch (FT.i)
		case 0:
			doAve = DimFlags & AveThinX;
			break;
		case 1:
			doAve = DimFlags & AveThinZ;
			break;
		case 2:
			doAve = DimFlags & AveThinL;
			break;
		default:
			return 0
	endswitch



	SVAR ClbWaveS = $cG3FControl+":"+FT.plotVar+"Wave"
	WAVE ClbWave = $ClbWaveS
	SVAR MWaveFitS = $cG3FControl+":MatrixWaveFit"
	WAVE MWaveFit = $MWaveFitS
	SVAR ClbWaveFitS = $cG3FControl+":"+FT.plotVar+"WaveFit"
	WAVE ClbWaveFit = $ClbWaveFitS
		
	string ShortWNameS;
	string ShortMWaveFitS;
		
	WAVE OP =  $cG3FControl+":OverlayParams"
	
	pnts = DimSize(RefWaveFit,0);
	variable d= 0 
	string OTraceName, FTraceName
	
	variable ClbFrame, B1, B2
	// Original data
	if(WaveExists(MWave)  && WaveExists(MWaveFit) )
		
		string OrgProfOvrlS = cG3FHome+":Feedbak_"+FT.name+"Ref" 
		make  /O /N=(DimSize(MWave, 1), 0) $OrgProfOvrlS
		wave OrgProfOvrl= $OrgProfOvrlS
		ShortWNameS = NameOfWave(OrgProfOvrl)

		do // purge displayed data
			CheckDisplayed /W=$winNameS OrgProfOvrl
			if (V_flag) // trace is there
				RemoveFromGraph /W=$winNameS $ShortWNameS
			endif
		while (V_flag) // still displayed
		
		
		string FitProfOvrlS = cG3FHome+":Feedbak_"+FT.name+"Fit" 
		make  /O /N=(DimSize(MWaveFit, 1), 0) $FitProfOvrlS
		wave FitProfOvrl= $FitProfOvrlS

		ShortMWaveFitS = NameOfWave(FitProfOvrl)
		do // purge displayed fits
			CheckDisplayed /W=$winNameS FitProfOvrl
			if (V_flag) // trace is there
				RemoveFromGraph /W=$winNameS $ShortMWaveFitS
			endif
		while (V_flag)	
				
		variable ODFrom, ODTo // Original Data main position bracket
		variable OB1From, OB1To // Original data low Base bracket
		variable OB2From, OB2To // Original data low Base bracket
		variable FDFrom, FDTo // Original Data main position bracket
		variable FB1From, FB1To // Original data low Base bracket
		variable FB2From, FB2To // Original data low Base bracket

		variable B1Fr; // used to calulate realtive baseline 
		variable ThinAdj;
		
//		ControlInfo AverageXChBox
		if ((doAve) && (RefThin > 1))
			ThinAdj = (RefThin -1)/2
		else
			ThinAdj = 0;
		endif
		
		Textbox /J /C /N=OverlayLegend /w=$winNameS  "clb\tpoint\toriginal\tfit"
		
		for (i=0, d=0; i<pnts; i+=1) // iterate over all rows
			string newLS="";
			if (RefWaveFit[i][2]) // i's row is flagged for plotting
				if (!numType(RefWaveFit[i][3]))
					ClbFrame = RefWaveFit[i][3]/2
				else
					ClbFrame = 0;
				endif

				FDFrom	= FitClb2Pos(RefWaveFit[i][2] - ClbFrame, RefWaveFitS); 
				FDTo 	= FitClb2Pos(RefWaveFit[i][2] + ClbFrame, RefWaveFitS); 
				ODFrom	= 	round (RefWaveFit[FDFrom	][1] - ThinAdj)
				ODTo 	= 	round (RefWaveFit[FDTo		][1] + ThinAdj)
				if (!numType(RefWaveFit[i][4])) // there is at least a base...
					FB1From 	= FitClb2Pos(RefWaveFit[i][4] - ClbFrame, RefWaveFitS); 
					FB1To		= FitClb2Pos(RefWaveFit[i][4] + ClbFrame, RefWaveFitS); 
					OB1From 	= 	round (RefWaveFit[FB1From	][1] - ThinAdj)
					OB1To 		= 	round (RefWaveFit[FB1To	][1] + ThinAdj)
					if (!numType(RefWaveFit[i][5])) // there is second base...
						FB2From  	= FitClb2Pos(RefWaveFit[i][5] - ClbFrame, RefWaveFitS); 
						FB2To 	  	= FitClb2Pos(RefWaveFit[i][5] + ClbFrame, RefWaveFitS); 
						OB2From 	= 	round (RefWaveFit[FB2From	][1] - ThinAdj)
						OB2To 		= 	round (RefWaveFit[FB2To	][1] + ThinAdj)
					else
						FB2From  = NAN
						FB2To 	  = NAN
						OB2From = 	NAN
						OB2To 	= 	NAN
					endif
				else
						FB1From  = NAN
						FB1To 	  = NAN
						OB1From = 	NAN
						OB1To 	= 	NAN
						FB2From  = NAN
						FB2To 	  = NAN
						OB2From = 	NAN
						OB2To 	= 	NAN
				endif


				if (RefWaveFit[i][5] == RefWaveFit[i][4])
					B1Fr = 1
				else
					B1Fr  = (RefWaveFit[i][0] -  RefWaveFit[i][4]) / ( RefWaveFit[i][5] -  RefWaveFit[i][4])
				endif
				if (!numtype(ODFrom) && !numtype(ODTo))			// frame is valid, can compute
					// Append column to display wave
					if (d >= DimSize(OrgProfOvrl, 1) )
						Insertpoints /M=1 d, 1, $OrgProfOvrlS
					endif 
					if (numtype(OB1From) || numtype(OB1To) ) // base 1 is invalid ...
						OrgProfOvrl[][d] = mean3D__(FT.i, MWave, ODFrom, ODTo, p, iLay)
					elseif (numtype(OB2From) || numtype(OB2To) || (B1Fr == 1)) // no second base, just the first 
						OrgProfOvrl[][d] = mean3D__(FT.i, MWave, ODFrom, ODTo, p, iLay) -  mean3D__(FT.i, MWave, OB1From, OB1To, p, iLay) 
					else // both bases are valid....
						OrgProfOvrl[][d] = mean3D__(FT.i, MWave, ODFrom, ODTo, p, iLay) -  (1-B1Fr) * mean3D__(FT.i, MWave, OB1From, OB1To, p, iLay) - B1Fr * mean3D__(FT.i, MWave, OB2From, OB2To, p, iLay)
					endif
				else 
					print "Invalid original data frame for "+FT.name+" ", i
				endif

				if (!numtype(FDFrom) && !numtype(FDTo))			// frame is valid, can compute
					// Append column to display wave
					if (d >= DimSize(FitProfOvrl, 1) )
						Insertpoints /M=1 d, 1, $FitProfOvrlS
					endif 
					if (numtype(FB1From) || numtype(FB1To)) // base 1 is invalid ...
						FitProfOvrl[][d] = mean3D__(FT.i, MWaveFit, FDFrom, FDTo, p, iLay)
					elseif (numtype(OB2From) || numtype(OB2To) || (B1Fr == 1)) // no second base, just the first 
						FitProfOvrl[][d] = mean3D__(FT.i, MWaveFit, FDFrom, FDTo, p, iLay) -  mean3D__(FT.i, MWaveFit, FB1From, FB1To, p, iLay) 
					else // both bases are valid....
						FitProfOvrl[][d] = mean3D__(FT.i, MWaveFit, FDFrom, FDTo, p, iLay) -  (1-B1Fr) * mean3D__(FT.i, MWaveFit, FB1From, FB1To, p, iLay) - B1Fr * mean3D__(FT.i, MWaveFit, FB2From, FB2To, p, iLay) 
					endif
				else
					print "Invalid fitted data frame for "+FT.name+" ", i
				endif

				
				// display original wave
				if (WaveExists(ClbWave) && WaveExists(ClbWaveFit) )  // why is this here??	
					AppendToGraph /W=$winNameS OrgProfOvrl[][d] vs ClbWave
					AppendToGraph /W=$winNameS FitProfOvrl[][d] vs ClbWaveFit[][0]
					
				else
					AppendToGraph /W=$winNameS OrgProfOvrl[][d] 
					AppendToGraph /W=$winNameS FitProfOvrl[][d] 
				endif
				if (d >0 )
					sprintf OTraceName, "%s#%u",  ShortWNameS, d
					sprintf FTraceName, "%s#%u",  ShortMWaveFitS, d
				else
					OTraceName = ShortWNameS
					FTraceName = ShortMWaveFitS
				endif
				ModifyGraph /W=$winNameS rgb($OTraceName)= (OP[d][0][0],OP[d][1][0],OP[d][2][0]), lsize($OTraceName) = OP[d][3][0], lstyle($OTraceName)=OP[d][4][0],marker($OTraceName)=OP[d][5][0],mode($OTraceName)=OP[d][6][0]
				ModifyGraph /W=$winNameS rgb($FTraceName)= (OP[d][0][1],OP[d][1][1],OP[d][2][1]), lsize($FTraceName) = OP[d][3][1], lstyle($FTraceName)=OP[d][4][1],marker($FTraceName)=OP[d][5][1],mode($FTraceName)=OP[d][6][1]


				sprintf newLS, "%d\t%u",  RefWaveFit[i][0], RefWaveFit[i][1]
				NewLS += "\t\\s("+OTraceName+")"
				NewLS += "\t\\s("+FTraceName+")"


				AppendText /N=OverlayLegend /w=$winNameS NewLS
 					
				d+=1
				endif
			endfor
		if (d==0)
			Legend /C /N=OverlayLegend /w=$winNameS  "No data to display"
		else 
			Label /w=$winNameS bottom FT.plotCaption + " calibration"
		endif
	elseif (!WaveExists(MWave))
		Legend /C /N=OverlayLegend /w=$winNameS  "Original Matrix wave was not found..."
	elseif (!WaveExists(MWaveFit))
		Legend /C /N=OverlayLegend /w=$winNameS  "Fitted data wave was not found..."
	endif
	return 0	
end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// 
Function SetFeedbackLayerProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			STRUCT FeedbackTypeT X_FT;
			GetFeedbackType(X_FT, 0);
			DoUpdateOverlay(X_FT, 0)
			
			STRUCT FeedbackTypeT Z_FT;
			GetFeedbackType(Z_FT, 1);
			DoUpdateOverlay(Z_FT, 0)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// search position by calibration value
Function FitClb2Pos(value, ClbWaveN)
	variable value;
	string ClbWaveN;
	
	if (Exists(ClbWaveN)!=1)
 		return -3;
	endif 
	WAVE ClbWaveFit = $ClbWaveN
	
	variable pos = BinarySearchCol(ClbWaveFit, value, 0)
	if (pos == -1)
		return 0;
	elseif (pos == -2)
		return dimsize(ClbWaveFit,0) -1;
	endif 
	return pos;
end





//***********************************************************************************************
//         Setup  
//***********************************************************************************************



//#####################################################################################
// Edit feedback list in G3Fit panel
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UI control over feedback list
//
Function MtrxNewRowFeedbackLineBProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	if (ba.eventCode != 2)
		return 0;
	endif
	
	STRUCT FeedbackTypeT FT;
	if (!GetFeedbackType(FT, 0))
		return 0;
	endif
	
	AddFeedbackLine(FT);
End

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UI control over feedback list
//
Function MtrxNewColFeedbackLineBProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	if (ba.eventCode != 2)
		return 0;
	endif
	
	STRUCT FeedbackTypeT FT;
	if (!GetFeedbackType(FT, 1))
		return 0;
	endif
	
	AddFeedbackLine(FT);
	end
	
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function AddFeedbackLine(FT)
	STRUCT FeedbackTypeT &FT;

	Wave/Z/T FeedbackListWave = $cG3FControl+":Feedback"+FT.name+"ListWave"
	Wave/Z FeedbackSelectionWave = $cG3FControl+":Feedback"+FT.name+"SelectionWave"
	Variable nLines = DimSize(FeedbackListWave, 0)
	InsertPoints nLines, 1, FeedbackListWave, FeedbackSelectionWave
	FeedbackListWave[nLines][] = ""
	FeedbackSelectionWave[nLines][] = 2
	Redimension/N=(nLines+1,4) FeedbackListWave, FeedbackSelectionWave
End

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UI control over feedback list
//
Function MtrxRemoveRowFeedbackLineBProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	if (ba.eventCode != 2)
		return 0;
	endif
	
	STRUCT FeedbackTypeT FT;
	if (!GetFeedbackType(FT, 0))
		return 0;
	endif
	
	RemoveFeedbackLine(FT)
	end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// UI control over feedback list
//
Function MtrxRemoveColFeedbackLineBProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	if (ba.eventCode != 2)
		return 0;
	endif
	
	STRUCT FeedbackTypeT FT;
	if (!GetFeedbackType(FT, 1))
		return 0;
	endif
	
	RemoveFeedbackLine(FT)
	end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function RemoveFeedbackLine(FT)
	STRUCT FeedbackTypeT &FT;

	Wave/Z/T FeedbackListWave = $cG3FControl+":Feedback"+FT.name+"ListWave"
	Wave/Z FeedbackSelectionWave = $cG3FControl+":Feedback"+FT.name+"SelectionWave"
	Variable nLines = DimSize(FeedbackListWave, 0)
	Variable i = 0
	do
		if (FeedbackSelectionWave[i] & 1)
			if (nLines == 1)
				FeedbackListWave[0] = ""
				FeedbackSelectionWave[0] = 6
			else
				DeletePoints i, 1, FeedbackListWave, FeedbackSelectionWave
				nLines -= 1
			endif
		else
			i += 1
		endif
	while (i < nLines)
	Redimension/N=(nLines,4) FeedbackListWave, FeedbackSelectionWave
End

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// called at the end of DoTheFit...
//
Function UpdateScrollFeedback(dimN)
	variable dimN;
	
	STRUCT FeedbackTypeT FT;
	GetFeedbackType(FT, dimN);
	
	NVAR dimFrom = $cG3FControl+":"+FT.indexVar+"From"
	NVAR dimTo = $cG3FControl+":"+FT.indexVar+"To"
	NVAR dimThin = $cG3FControl+":"+FT.indexVar+"Thin"
	SVAR fitClbWN = $cG3FControl+":"+FT.indexVar+"Wave"
	
	variable nFitRows = dimsize($fitClbWN, 0);


	string winNameS = "G3F_FB_"+FT.name+"Scroll"
	if (WinType(winNameS) !=1 )
		return 0
	endif
	SetVariable SetFitPos limits = {0,nFitRows,1}, win=$winNameS
	SetVariable SetOrgPos limits = {dimFrom,dimTo,dimThin}, win=$winNameS

	string baseName = cG3FControl+":Scroll"+FT.indexVar+FT.plotVar
	 NVAR ProfClbPos = $baseName+"Pos"
	 if (ProfClbPos >= nFitRows)
	 	ProfClbPos = nFitRows -1;
	 endif
	 DoUpdateScroll(FT);
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// called at the end of DoTheFit to adjust display elements to new results...
//
function UpdateFeedback() 
	NVAR LFrom = $cG3FControl+":LFrom"
	NVAR LTo = $cG3FControl+":LTo"
	SetVariable FeedbackLayerCtrl win=G3FitPanel, limits={LFrom, LTo, 1}
	UpdateScrollFeedback(0)
	UpdateScrollFeedback(1)

	UpdateOverlayFeedback(0) 
	UpdateOverlayFeedback(1) 
end 

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function UpdateOverlayFeedback(dim) 
	variable dim
	STRUCT FeedbackTypeT FT;
	if (!GetFeedbackType(FT, dim))
		return 0;
	endif

	variable UpdateProfileOverlay=0

	SVAR RefWaveFitS = $cG3FControl+":"+FT.indexVar+"WaveFit"
	if (!strlen(RefWaveFitS))
		DoUpdateOverlay(FT, 0);	
		return 0;
	endif
	WAVE RefWaveFit = $RefWaveFitS 
	if (Exists(RefWaveFitS)==1) // clb exists
		if (DimSize($RefWaveFitS, 1) != 6) // different number of points - make a new one
			Redimension /N=(-1, 6) $RefWaveFitS
		else // old dimension ... just keep it....
		endif
	else // WaveX does not exist...
		doAlert 0, "Fitted "+FT.indexVar+" calibration wave is not found. Try performin simulation or fit first."
		return 0;  
	endif

	
	Wave/Z/T FeedbackListWave = $cG3FControl+":Feedback"+FT.name+"ListWave"
	Wave/Z   FeedbackSelectionWave = $cG3FControl+":Feedback"+FT.name+"SelectionWave"
	Variable nPnts=DimSize(FeedbackListWave, 0)
	variable askedClb, i , j
	
	ControlInfo /W=G3FitPanel $"Feedback"+FT.name+"ClearListCheck"
	if (V_Value) // is reset list option checked?
		RefWaveFit[][2]=0;
		RefWaveFit[][3,]=NAN;
		UpdateProfileOverlay = 1;
	else // make sure display reflects all selected positions
		for (i=0; i<dimsize(RefWaveFit, 0); i++)
			if (RefWaveFit[i][2]==0 || numtype(RefWaveFit[i][2])) // This row is not flagged for feedback
				RefWaveFit[i][2]=0;
				RefWaveFit[i][3,]=NAN;
			else // it is a number - make sure it is in the display list
				variable found  = 0
				for (j=0; j<nPnts && !found; j++)
					askedClb=str2num(FeedbackListWave[j][0]); // calibrated position already in the list
					if (numtype(askedClb) == 0)
						if (askedClb == RefWaveFit[i][2]) // previously asked calibrated postion at flagged point is equal to requested. 
							found = 1;
						endif 
					endif 
				endfor
				if (!found) // it was not found - clear in the wave
					RefWaveFit[i][2] = 0;
					RefWaveFit[i][3,5] = NaN;
				endif 
			endif 
		endfor 	
		
	endif
	for ( i=0; i < nPnts; i += 1)
		askedClb=str2num(FeedbackListWave[i][0])
		if (numtype(askedClb) == 0)
			variable newPos = FitClb2Pos(askedClb, RefWaveFitS)
			if (newPos < 0 )
				break;
			endif
			
			if (RefWaveFit[newPos][2] != 1)
				UpdateProfileOverlay = 1;
			endif
			RefWaveFit[newPos][2] = askedClb;

			variable aksedFrame = str2num(FeedbackListWave[i][1])
			if (numtype(aksedFrame) == 0)
				RefWaveFit[newPos][3] = aksedFrame;
			else
				RefWaveFit[newPos][3] = NAN;
			endif
			
			variable aksedB1 = str2num(FeedbackListWave[i][2])
			if (numtype(aksedB1) == 0)
				RefWaveFit[newPos][4] = aksedB1;
			else
				RefWaveFit[newPos][4] = NAN;
			endif
			
			variable aksedB2 = str2num(FeedbackListWave[i][3])
			if (numtype(aksedB2) == 0)
				RefWaveFit[newPos][5] = aksedB2;
			else
				RefWaveFit[newPos][5] = NAN;
			endif
		endif
	endfor
		DoUpdateOverlay(FT, 0)				
end



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function ShowTrackingWindow(dim)// , name, caption)
	variable dim
	
	STRUCT FeedbackTypeT FT;
	if (!GetFeedbackType(FT, dim))
		return 0;
	endif

	string WindowName = "G3FTrack_"+FT.name
	if (wintype(WindowName) != 0)
		DoWindow/F $WindowName
		return 0;
	endif
	
//	PauseUpdate; Silent 1		// building window...
	WAVE LinWave = $cG3FHome+":ChunkLinW";
	WAVE DestWave = $cG3FHome+":ChunkDestW";
	WAVE ClbWave = $cG3FHome+":ChunkClbW";
	String fldrSav0= GetDataFolder(1)
	SetDataFolder $cG3FHome 
	Display /W=(70.5,65.75,537.75,356.75) /N=$WindowName LinWave, DestWave vs ClbWave[*][dim] as "G3F: Tracking - "+FT.plotCaption
	SetDataFolder fldrSav0
	ModifyGraph /W=$WindowName wbRGB=(0,0,0),gbRGB=(0,0,0)
	ModifyGraph /W=$WindowName mode=2
	ModifyGraph /W=$WindowName lSize(ChunkLinW)=3
	ModifyGraph /W=$WindowName rgb(ChunkLinW)=(0,12800,52224),rgb(ChunkDestW)=(65280,65280,0)
	ModifyGraph /W=$WindowName axRGB=(65535,65535,65535)
	ModifyGraph /W=$WindowName tlblRGB=(65535,65535,65535)
	ModifyGraph /W=$WindowName alblRGB=(65535,65535,65535)
	TextBox /W=$WindowName /C/N=text0/F=0/B=1/A=LB/X=43.08/Y=87.81 "\\Z18\\K(65535,65535,65535)\\K(65280,65280,48896)Fitting "+FT.indexCaption+" overlay"
	Legend /W=$WindowName /C/N=text1/J/F=0/B=1/A=LB/X=70.76/Y=72.50 "\\K(65280,65280,48896)\\s(ChunkLinW) Experiment\r\\s(ChunkDestW) Calculated"
	Label /W=$WindowName bottom FT.plotCaption + " calibration"
end


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
function ShowLocalsWindow(dim)
	variable dim
	
	STRUCT FeedbackTypeT FT;
	if (!GetFeedbackType(FT, dim))
		return 0;
	endif


	SVAR MWaveS = $cG3FControl+":MatrixWave"
	if(Exists(MWaveS)!=1)
		DoAlert 0, "Matrix wave should be selected and first fitting done to diplay locals."
		return -1
	endif
	wave MWave = $MWaveS
	string WindowName = ("G3F_"+FT.name+"Loc_"+nameofwave(MWave))[0, 30]
	if (wintype(WindowName) != 0)
		DoWindow/F $WindowName
		return 0;
	endif
	
	// see if set ID is applied
	SVAR sSetID = $cG3FControl+":setID";
	
	string LocVarsS = MWaveS+sSetID+"_"+FT.name+"Loc"
	if (exists (LocVarsS) != 1) // no such wave
		DoAlert 0, FT.name+" Locals wave was not found. Maybe first fitting  has not been performed yet."
		return -1; 
	endif

	WAVE LocVarsW = $LocVarsS
	
	SVAR XWaveFitS = $cG3FControl+":"+FT.indexVar+"WaveFit"

	variable i;

	WAVE OP =  $cG3FControl+":PhaseOverlayParams"

	string OTraceName, ShortWNameS = NameOfWave($LocVarsS);
	
	Display /W=(252.75,107.75,681.75,444.5) /n=$WindowName  as FT.name+" locals for "+MWaveS
	for (i=0; i< dimsize(LocVarsW, 1); i+=1)
		if (Exists(XWaveFitS)==1) // clb exists
				AppendToGraph  /W=$WindowName $LocVarsS[*][i] vs $XWaveFitS[*][0]
		else
				AppendToGraph /W=$WindowName $LocVarsS[*][i] 
		endif
		if (i >0 )
			sprintf OTraceName, "%s#%u",  ShortWNameS, i
		else
			OTraceName = ShortWNameS
		endif
		ModifyGraph /W=$WindowName rgb($OTraceName)= (OP[i][0],OP[i][1],OP[i][2])
	endfor


	ModifyGraph lSize=2
	ModifyGraph zero(left)=1
	ModifyGraph lblMargin(left)=4
	ModifyGraph axOffset(left)=-4
	Label left "intensity"
	Label bottom FT.name+" clb"

	string legendS = ""
	legendS = "\\s("+nameofwave(LocVarsW)+") loc 0"
	for (i=1; i< dimsize(LocVarsW, 1); i+=1)
		legendS += "\r\\s("+nameofwave(LocVarsW)+"#"+num2str(i)+") loc "+num2str(i)
	endfor
	Legend/C/N=text1/J/F=0/B=1/A=LB/X=70/Y=80 legendS 
end 

