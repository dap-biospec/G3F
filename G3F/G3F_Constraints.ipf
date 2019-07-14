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

//***********************************  
//
// Constraints
//
//***********************************

Function doConstraintsPrepareWaves(NVars, sConstraintsListWave, sConstraintsSelectionWave, labelOffset, GuessWave, AltLabel, ColLabel)
			string sConstraintsListWave
			string sConstraintsSelectionWave
			Wave/T /Z GuessWave
			variable NVars
			string AltLabel
			string ColLabel
			variable labelOffset
			
			variable oldNVar = 0
			
			if (!(WaveExists($sConstraintsListWave) ))
				Make/O/N=(NVars,7)/T $sConstraintsListWave=""
				wave /T ConstraintsListWave = $sConstraintsListWave
			else
				wave /T ConstraintsListWave = $sConstraintsListWave
				oldNVar = DimSize(ConstraintsListWave, 1)==7 ? DimSize(ConstraintsListWave, 0) : 0				
			endif 
			
			if (!(WaveExists($sConstraintsSelectionWave) ))

//				Make/O/N=(NVars,7)/T ConstraintsListWave=""
				Make/O/N=(NVars,7) $sConstraintsSelectionWave
				wave ConstraintsSelectionWave = $sConstraintsSelectionWave
				ConstraintsSelectionWave[][6] = 32		// hold checkbox
			else
				wave ConstraintsSelectionWave = $sConstraintsSelectionWave
			endif 

			if ( oldNVar != NVars) // || (DimSize(ConstraintsGlobalListWave, 1)!=7))
				redimension /N=(NVars, 7) ConstraintsListWave
				redimension /N=(NVars, 7) ConstraintsSelectionWave
			endif
			
			ConstraintsListWave[][0] = "K"+num2istr(p+labelOffset)
			if (waveExists(GuessWave))
				ConstraintsListWave[][1] = GuessWave[p+labelOffset][1]
			else
				ConstraintsListWave[oldNVar,][1] = AltLabel+" ["+num2Str(p)+"]"
			endif 
			ConstraintsListWave[][3] = "< K"+num2istr(p+labelOffset)+" <"
			
			if (oldNVar < NVars)

				ConstraintsListWave[oldNVar,][6] = ""
			endif
			ConstraintsSelectionWave[][0] = 2		// K labels, can be edited
			ConstraintsSelectionWave[][1] = 2		// coefficient labels, can be edited
			ConstraintsSelectionWave[][2] = 2		// editable- greater than constraints
			ConstraintsSelectionWave[][3] = 0		// "< Kn <"
			ConstraintsSelectionWave[][4] = 2		// editable- less than constraints
			ConstraintsSelectionWave[][5] = 2		// epsilon
//			ConstraintsSelectionWave[][6] = 32		// hold checkbox
			if (oldNVar < NVars)
				ConstraintsSelectionWave[oldNVar,][6] = 32
			endif
			SetDimLabel 1, 0, 'Kn', ConstraintsListWave
			SetDimLabel 1, 1, $ColLabel, ConstraintsListWave
			SetDimLabel 1, 2, 'Min', ConstraintsListWave
			SetDimLabel 1, 3, ' ', ConstraintsListWave
			SetDimLabel 1, 4, 'Max', ConstraintsListWave
			SetDimLabel 1, 5, 'Epsilon', ConstraintsListWave
			SetDimLabel 1, 6, 'Hold', ConstraintsListWave

end


//********************************************
// Prepare constraint params and panel
//

Function MatrixConstraintsPrepareWaves()
	NVAR NGVar = $cG3FControl+":NumGlobVar"
	NVAR NRVar = $cG3FControl+":NumRowVar"
	NVAR NCVar = $cG3FControl+":NumColVar"
	NVAR NLVar = $cG3FControl+":NumLayVar"
	NVAR NLRVar = $cG3FControl+":NumLayRowVar"
	NVAR NLCVar = $cG3FControl+":NumLayColVar"
	Wave/T/Z GuessListWave = $cG3FControl+":GuessListWave"

	variable i

	String saveDF = GetDatafolder(1)
	SetDatafolder $cG3FControl

	doConstraintsPrepareWaves(NGVar, "ConstraintsGlobalListWave", "ConstraintsGlobalSelectionWave", 0, GuessListWave, "", "Global var")
	doConstraintsPrepareWaves(NRVar, "ConstraintsRowListWave", "ConstraintsRowSelectionWave", NGVar, NULL, "RP", "ROW var")
	doConstraintsPrepareWaves(NCVar, "ConstraintsColListWave", "ConstraintsColSelectionWave", NGVar+NRVar, NULL,"CP", "COL var")

	Wave/Z/T MoreConstraintsListWave
	if (!WaveExists(MoreConstraintsListWave))
		Make/N=(1,1)/T/O  MoreConstraintsListWave=""
		Make/N=(1,1)/O MoreConstraintsSelectionWave=6
		SetDimLabel 1,0,'Enter Constraint Expressions', MoreConstraintsListWave
	endif
	MoreConstraintsSelectionWave=6
	
	SetDatafolder $saveDF	
end

//********************************************
//
Function LayerConstraintsPrepareWaves()
	NVAR NGVar = $cG3FControl+":NumGlobVar"
	NVAR NRVar = $cG3FControl+":NumRowVar"
	NVAR NCVar = $cG3FControl+":NumColVar"
	NVAR NLVar = $cG3FControl+":NumLayVar"
	NVAR NLRVar = $cG3FControl+":NumLayRowVar"
	NVAR NLCVar = $cG3FControl+":NumLayColVar"

	variable i

	String saveDF = GetDatafolder(1)
	SetDatafolder $cG3FControl

	doConstraintsPrepareWaves(NLVar,  "ConstrLayerListWave",    "ConstrLayerSelectionWave", NGVar+NRVar+NCVar, NULL, "LP", "LAYER var")
	doConstraintsPrepareWaves(NLRVar, "ConstrLayerRowListWave", "ConstrLayerRowSelectionWave", NGVar+NRVar+NLVar+NLVar, NULL, "LRP", "LayROW var")
	doConstraintsPrepareWaves(NLCVar, "ConstrLayerColListWave", "ConstrLayerColSelectionWave", NGVar+NRVar+NLVar+NLRVar, NULL, "LCP", "LayCol var")

	Wave/Z/T ConstrLayerMoreListWave
	if (!WaveExists(ConstrLayerMoreListWave))
		Make/N=(1,1)/T/O  ConstrLayerMoreListWave=""
		Make/N=(1,1)/O ConstrLayerMoreSelectionWave=6
		SetDimLabel 1,0,'Enter Constraint Expressions', ConstrLayerMoreListWave
	endif
	ConstrLayerMoreSelectionWave=6
	
	SetDatafolder $saveDF	
end



//********************************************
Function MatrixConstraintsEditProc(ctrlName) : ButtonControl
	String ctrlName
	Variable checked

	SVAR MatrixW = $cG3FControl+":MatrixWave"
	if (Exists(MatrixW) != 1)
		CheckBox ConstraintsCheckBox, win=G3FitPanel, value=0
		DoAlert 0, "You cannot add constraints until you have selected data sets"
		ModifyControl DoFitButton disable=0
		return 0
	endif
	MatrixConstraintsPrepareWaves();
	ModifyControl DoFitButton disable=2
	if (WinType("G3FitConstraintPanel") > 0)
		SetWindow G3FitConstraintPanel, hide=0, needUpdate=1
		DoWindow/F G3FitConstraintPanel
	else
		fG3FitConstraintPanel()
	endif
	ModifyControl DoFitButton disable=0
End

//********************************************
Function LayerConstraintsEditProc(ctrlName) : ButtonControl
	String ctrlName
	Variable checked

	SVAR MatrixW = $cG3FControl+":MatrixWave"
	if (Exists(MatrixW) != 1)
		CheckBox LayerConstraintsCheckBox, win=G3FitPanel, value=0
		DoAlert 0, "You cannot add constraints until you have selected data sets"
		ModifyControl DoFitButton disable=0
		return 0
	endif
	LayerConstraintsPrepareWaves();
	ModifyControl DoFitButton disable=2
	if (WinType("G3FitConstraintPanel") > 0)
		SetWindow G3FitConstraintPanel, hide=0, needUpdate=1
		DoWindow/F G3FitConstraintPanel
	else
		fG3FitLayerConstraintPanel()
	endif
	ModifyControl DoFitButton disable=0
End


//********************************************
// Build panel
//
Function fG3FitConstraintPanel()

	NewPanel /W=(45,94,551,705) /N=G3FitConstraintPanel as "G3F Constraints" 
	DoWindow/C G3FitConstraintPanel
	AutoPositionWindow /R=G3FitPanel
	variable VO = 0

	GroupBox SimpleConstraintsGroup,pos={5,7},size={494,457},title="Simple Constraints"
	Button SimpleConstraintsClearB,pos={21,24},size={138,20},proc=MtrxSimpleConstraintsClearBProc,title="Clear List"
	ListBox GlobalConstraintsList,pos={12,50},size={480,180},frame=2
	ListBox GlobalConstraintsList,listWave=$cG3FControl+":ConstraintsGlobalListWave"
	ListBox GlobalConstraintsList,selWave=$cG3FControl+":ConstraintsGlobalSelectionWave"
	ListBox GlobalConstraintsList,mode= 7,editStyle= 1,widths={30,120,50,50,50}

	VO = 235	
	ListBox RowConstraintsList,pos={12,VO+0},size={480,110},frame=2
	ListBox RowConstraintsList,listWave=$cG3FControl+":ConstraintsRowListWave"
	ListBox RowConstraintsList,selWave=$cG3FControl+":ConstraintsRowSelectionWave"
	ListBox RowConstraintsList,mode= 7,editStyle= 1,widths={30,120,50,50,50}
	
	VO=350
	ListBox ColConstraintsList,pos={12,VO+0},size={480,110},frame=2
	ListBox ColConstraintsList,listWave=$cG3FControl+":ConstraintsColListWave"
	ListBox ColConstraintsList,selWave=$cG3FControl+":ConstraintsColSelectionWave"
	ListBox ColConstraintsList,mode= 7,editStyle= 1,widths={30,120,50,50,50}

	VO = 465
	GroupBox AdditionalConstraintsGroup,pos={5,VO+0},size={496,143},title="Additional Constraints"
	ListBox moreConstraintsList,pos={12,VO+39},size={482,98},frame=2
	ListBox moreConstraintsList,listWave=$cG3FControl+":MoreConstraintsListWave"
	ListBox moreConstraintsList,selWave=$cG3FControl+":MoreConstraintsSelectionWave"
	ListBox moreConstraintsList,mode= 4,editStyle= 1
	Button NewConstraintLineButton,pos={18,VO+17},size={138,20},proc=MtrxNewConstraintLineBProc,title="Add a Line"
	Button RemoveConstraintLineButton01,pos={182,VO+17},size={138,20},proc=MtrxRemoveConstraintLineBProc,title="Remove Selection"
	Button G3FitConstraintsDoneB,pos={175,24},size={300,20},proc=G3FitConstraintsDoneBProc,title="Done", fColor=(19456,39168,0)
	
	Pauseforuser G3FitConstraintPanel
EndMacro

Function fG3FitLayerConstraintPanel()

	NewPanel /W=(45,94,551,705) /N=G3FitLayerConstraintPanel as "G3F Layer Constraints" 
	DoWindow/C G3FitLayerConstraintPanel
	AutoPositionWindow /R=G3FitPanel

	variable VO = 0

	GroupBox SimpleConstraintsGroup,pos={5,7},size={494,457},title="Simple Constraints"
	Button SimpleConstraintsClearB,pos={21,24},size={138,20},proc=LayerSimpleConstraintsClearBProc,title="Clear List"
	ListBox LayerConstraintsList,pos={12,49},size={480,180},frame=2
	ListBox LayerConstraintsList,listWave=$cG3FControl+":ConstrLayerListWave"
	ListBox LayerConstraintsList,selWave=$cG3FControl+":ConstrLayerSelectionWave"
	ListBox LayerConstraintsList,mode= 7,editStyle= 1,widths={30,120,50,50,50}

	VO = 235	
	ListBox RowConstraintsList,pos={12,VO+0},size={480,110},frame=2
	ListBox RowConstraintsList,listWave=$cG3FControl+":ConstrLayerRowListWave"
	ListBox RowConstraintsList,selWave=$cG3FControl+":ConstrLayerRowSelectionWave"
	ListBox RowConstraintsList,mode= 7,editStyle= 1,widths={30,120,50,50,50}
	
	VO = 350	
	ListBox ColConstraintsList,pos={12,VO+0},size={480,110},frame=2
	ListBox ColConstraintsList,listWave=$cG3FControl+":ConstrLayerColListWave"
	ListBox ColConstraintsList,selWave=$cG3FControl+":ConstrLayerColSelectionWave"
	ListBox ColConstraintsList,mode= 7,editStyle= 1,widths={30,120,50,50,50}
	
	VO = 465	
	GroupBox AdditionalConstraintsGroup,pos={5,VO+0},size={496,143},title="Additional Constraints"
	ListBox moreConstraintsList,pos={12,VO+39},size={482,98},frame=2
	ListBox moreConstraintsList,listWave=$cG3FControl+":ConstrLayerMoreListWave"
	ListBox moreConstraintsList,selWave=$cG3FControl+":ConstrLayerMoreSelectionWave"
	ListBox moreConstraintsList,mode= 4,editStyle= 1
	Button NewConstraintLineButton,pos={18,VO+17},size={138,20},proc=LayerNewConstraintLineBProc,title="Add a Line"
	Button RemoveConstraintLineButton01,pos={182,VO+17},size={138,20},proc=LayerRemoveConstraintLineBProc,title="Remove Selection"
	Button G3FitConstraintsDoneB,pos={175,24},size={300,20},proc=G3FitLayerConstraintsDoneBProc,title="Done", fColor=(19456,39168,0)
	
	Pauseforuser G3FitLayerConstraintPanel
EndMacro

//********************************************
// Empty all simple constraints
//
Function MtrxSimpleConstraintsClearBProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/Z/T ConstraintsGlobalListWave = $cG3FControl+":ConstraintsGlobalListWave"
	ConstraintsGlobalListWave[][2] = ""
	ConstraintsGlobalListWave[][4] = ""
	Wave/Z/T ConstraintsRowListWave = $cG3FControl+":ConstraintsRowListWave"
	ConstraintsRowListWave[][2] = ""
	ConstraintsRowListWave[][4] = ""
	Wave/Z/T ConstraintsColListWave = $cG3FControl+":ConstraintsColListWave"
	ConstraintsColListWave[][2] = ""
	ConstraintsColListWave[][4] = ""
End

//********************************************
// Add special constraint line
//
Function MtrxNewConstraintLineBProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/Z/T MoreConstraintsListWave = $cG3FControl+":MoreConstraintsListWave"
	Wave/Z MoreConstraintsSelectionWave = $cG3FControl+":MoreConstraintsSelectionWave"
	Variable nRows = DimSize(MoreConstraintsListWave, 0)
	InsertPoints nRows, 1, MoreConstraintsListWave, MoreConstraintsSelectionWave
	MoreConstraintsListWave[nRows] = ""
	MoreConstraintsSelectionWave[nRows] = 6
	Redimension/N=(nRows+1,1) MoreConstraintsListWave, MoreConstraintsSelectionWave
End

//********************************************
// Remove special constraint line
//
Function MtrxRemoveConstraintLineBProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/Z/T MoreConstraintsListWave = $cG3FControl+":MoreConstraintsListWave"
	Wave/Z MoreConstraintsSelectionWave = $cG3FControl+":MoreConstraintsSelectionWave"
	Variable nRows = DimSize(MoreConstraintsListWave, 0)
	Variable i = 0
	do
		if (MoreConstraintsSelectionWave[i] & 1)
			if (nRows == 1)
				MoreConstraintsListWave[0] = ""
				MoreConstraintsSelectionWave[0] = 6
			else
				DeletePoints i, 1, MoreConstraintsListWave, MoreConstraintsSelectionWave
				nRows -= 1
			endif
		else
			i += 1
		endif
	while (i < nRows)
	Redimension/N=(nRows,1) MoreConstraintsListWave, MoreConstraintsSelectionWave
End

//********************************************
// Close constraints dialog
//
Function G3FitConstraintsDoneBProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K G3FitConstraintPanel
	Wave/T GuessListWave= $cG3FControl+":GuessListWave"
	Wave/T  ConstraintsGlobalListWave=$cG3FControl+":ConstraintsGlobalListWave"
	Wave ConstraintsGlobalSelectionWave=$cG3FControl+":ConstraintsGlobalSelectionWave"
	variable i;
	for (i=0; i<dimsize(GuessListWave, 0) && i< dimsize(ConstraintsGlobalSelectionWave, 0); i+=1)
			if (ConstraintsGlobalSelectionWave[i][6] == 48)	// held!
				GuessListWave[i][0] = "-"+num2istr(i)
			else
				GuessListWave[i][0] = "V"+num2istr(i)
			endif 	
			GuessListWave[i][1] = ConstraintsGlobalListWave[i][1] // copy label that may have been edited
	endfor
	
End



//********************************************
// Build panel
//



//********************************************
// Empty all simple constraints
//
Function LayerSimpleConstraintsClearBProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/Z/T ConstrLayerListWave = $cG3FControl+":ConstrLayerListWave"
	ConstrLayerListWave[][2] = ""
	ConstrLayerListWave[][4] = ""
	Wave/Z/T ConstrLayerRowListWave = $cG3FControl+":ConstrLayerRowListWave"
	ConstrLayerRowListWave[][2] = ""
	ConstrLayerRowListWave[][4] = ""
	Wave/Z/T ConstrLayerColListWave = $cG3FControl+":ConstrLayerColListWave"
	ConstrLayerColListWave[][2] = ""
	ConstrLayerColListWave[][4] = ""
End

//********************************************
// Add special constraint line
//
Function LayerNewConstraintLineBProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/Z/T MoreConstraintsListWave = $cG3FControl+":ConstrLayerMoreListWave"
	Wave/Z MoreConstraintsSelectionWave = $cG3FControl+":ConstrLayerMoreSelectionWave"
	Variable nRows = DimSize(MoreConstraintsListWave, 0)
	InsertPoints nRows, 1, MoreConstraintsListWave, MoreConstraintsSelectionWave
	MoreConstraintsListWave[nRows] = ""
	MoreConstraintsSelectionWave[nRows] = 6
	Redimension/N=(nRows+1,1) MoreConstraintsListWave, MoreConstraintsSelectionWave
End

//********************************************
// Remove special constraint line
//
Function LayerRemoveConstraintLineBProc(ctrlName) : ButtonControl
	String ctrlName

	Wave/Z/T MoreConstraintsListWave = $cG3FControl+":ConstrLayerMoreListWave"
	Wave/Z MoreConstraintsSelectionWave = $cG3FControl+":ConstrLayerMoreSelectionWave"
	Variable nRows = DimSize(MoreConstraintsListWave, 0)
	Variable i = 0
	do
		if (MoreConstraintsSelectionWave[i] & 1)
			if (nRows == 1)
				MoreConstraintsListWave[0] = ""
				MoreConstraintsSelectionWave[0] = 6
			else
				DeletePoints i, 1, MoreConstraintsListWave, MoreConstraintsSelectionWave
				nRows -= 1
			endif
		else
			i += 1
		endif
	while (i < nRows)
	Redimension/N=(nRows,1) MoreConstraintsListWave, MoreConstraintsSelectionWave
End

//********************************************
// Close constraints dialog
//
Function G3FitLayerConstraintsDoneBProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K G3FitLayerConstraintPanel
	Wave/T GuessListWave= $cG3FControl+":LayerGuessListWave"
	Wave ConstrLayerSelectionWave=$cG3FControl+":ConstrLayerSelectionWave"
	variable i;
	for (i=0; i<dimsize(GuessListWave, 0) && i< dimsize(ConstrLayerSelectionWave, 0); i+=1)
			GuessListWave[i][0] = "K"+num2istr(i)
			if (ConstrLayerSelectionWave[i][6] == 48)	// held!
				GuessListWave[i][0] += "*"
			endif 	
	endfor
	
End



//********************************************
// Build constraint wave for fitting
//
Function/S G3FitMakeConstraintWave(chunk) //chunk.rows, chunk.cols, chunk.fData.L.fitLines)
	STRUCT chunkDataT &chunk

//	variable chunk.rows, chunk.cols, chunk.fData.L.fitLines
	
	ControlInfo /W=G3FitPanel ConstraintsCheckBox
	if (!V_value)
		return "";
	endif

	string ConstraintsWaveS = cG3FHome+":ConstraintWave"
	Make/O/T/N=0 $ConstraintsWaveS
	Wave/T chunk.CConstrW = $ConstraintsWaveS
	Variable nextRow = 0
	variable offset = 0;

 	assembleContraints(chunk.CConstrW, "ConstraintsGlobal", 1,  1, nextRow, offset, chunk.fVars.Glob)
 	
 	assembleContraints(chunk.CConstrW, "ConstraintsRow",  chunk.rows,  1, nextRow, offset, chunk.fVars.Row )
 	
 	assembleContraints(chunk.CConstrW, "ConstraintsCol",  chunk.cols,  1, nextRow, offset, chunk.fVars.Col )

 	assembleContraints(chunk.CConstrW, "ConstrLayer", chunk.fData.L.fitLines,  1, nextRow, offset, chunk.fVars.Lay )

 	assembleContraints(chunk.CConstrW, "ConstrLayerRow",  chunk.rows,  chunk.fData.L.fitLines, nextRow, offset, chunk.fVars.LayRow )
 	
 	assembleContraints(chunk.CConstrW, "ConstrLayerCol",  chunk.cols,  chunk.fData.L.fitLines, nextRow, offset, chunk.fVars.LayCol )

	Wave/Z/T MoreConstraintsListWave = $cG3FControl+":MoreConstraintsListWave"
	assembleMoreContraints(chunk.CConstrW, MoreConstraintsListWave, nextRow, chunk.fVars.Glob, chunk.fVars.Row, chunk.fVars.Col) //0x1 | 0x2 | 0x4 
 	
	Wave/Z/T MoreConstraintsListWave = $cG3FControl+":ConstrLayerMoreListWave"
	assembleMoreContraints(chunk.CConstrW, MoreConstraintsListWave, nextRow, chunk.fVars.Lay, chunk.fVars.LayRow, chunk.fVars.LayCol) //0x8 | 0x10 | 0x20
	
 	//return ConstraintsWaveS
 	
 	
 end
 	

//********************************************
// Build Epsilon wave for fitting
//
Function/S G3FitMakeEpsilonWave(chunk) //chunk.rows, chunk.cols, chunk.fData.L.fitLines)
	STRUCT chunkDataT &chunk

//	variable chunk.rows, chunk.cols, chunk.fData.L.fitLines
	
	ControlInfo EpsilonCheckBox
	if (!V_value)
		return "";
	endif

	NVAR DefEpsilon  = $cG3FControl+":DefEpsilon"
	if (DefEpsilon <=0)
		DefEpsilon = 1e-6;
	endif
	

	string EpsilonWaveS = cG3FHome+":EpsilonWave"
	Make/O/N=(0)  $EpsilonWaveS
	Wave chunk.CEpsW = $EpsilonWaveS

	chunk.CEpsW =NAN
	variable nTotEntries= 0;
	
	assembleEpsilon(chunk.CEpsW, "ConstraintsGlobal", 1,  1, nTotEntries, DefEpsilon, chunk.fVars.Glob )
	assembleEpsilon(chunk.CEpsW, "ConstraintsRow",  chunk.rows,  1, nTotEntries, DefEpsilon, chunk.fVars.Row )
	assembleEpsilon(chunk.CEpsW, "ConstraintsCol",  chunk.cols,  1, nTotEntries, DefEpsilon, chunk.fVars.Col )
	assembleEpsilon(chunk.CEpsW, "ConstrLayer",  chunk.fData.L.fitLines,  1, nTotEntries, DefEpsilon, chunk.fVars.Lay )

//	NVAR nLayRowVars  =  $cG3FControl+":NumLayRowVar"
	assembleEpsilon(chunk.CEpsW, "ConstrLayerRow",  chunk.rows,  chunk.fData.L.fitLines, nTotEntries, DefEpsilon, chunk.fVars.LayRow )
	
//	NVAR nLayColVars  =  $cG3FControl+":NumLayColVar"
	assembleEpsilon(chunk.CEpsW, "ConstrLayerCol",  chunk.cols,  chunk.fData.L.fitLines, nTotEntries, DefEpsilon, chunk.fVars.LayCol )
	
	//return EpsilonWaveS	
end 



//********************************************
//
Function HoldOverrideCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	if ( cba.eventCode != 2)  // mouse up
		return 0;
	endif 
	Variable checked = cba.checked
	NVAR VarField = $cG3FControl+":VarFlags"

	variable setVar;
	variable clearVar;
	strswitch (cba.ctrlName)
		case "HoldNoneCheck": 
			setVar = HoldNone
			clearVar = cba.checked ? HoldGlob | HoldRow | HoldCol | HoldLay | HoldLayRow | HoldLayCol  : 0;
			break
		case "HoldGlobCheck": 
			setVar = HoldGlob;
			clearVar = cba.checked ? HoldNone : 0;
			break
		case "HoldRowCheck": 
			setVar = HoldRow
			clearVar = cba.checked ? HoldNone : 0;
			break
		case "HoldColCheck": 
			setVar = HoldCol
			clearVar = cba.checked ? HoldNone : 0;
			break
		case "HoldLayCheck": 
			setVar = HoldLay
			clearVar = cba.checked ? HoldNone : 0;
			break
		case "HoldLayRowCheck": 
			setVar = HoldLayRow
			clearVar = cba.checked ? HoldNone : 0;
			break
		case "HoldLayColCheck": 
			setVar = HoldLayCol
			clearVar = cba.checked ? HoldNone : 0;
			break
		default:
			break
	endswitch
	
	//variable invClear = ~clearVar

	VarField = cba.checked ? (VarField | setVar) : (VarField & ~setVar)
	VarField = VarField  & ~clearVar
	
	strswitch (cba.ctrlName)
		case "HoldNoneCheck": 
			CheckBox HoldGlobCheck value=0
			CheckBox HoldRowCheck value=0
			CheckBox HoldColCheck value=0
			CheckBox HoldLayCheck value=0
			CheckBox HoldLayRowCheck value=0
			CheckBox HoldLayColCheck value=0
			break
		case "HoldGlobCheck": 
		case "HoldRowCheck": 
		case "HoldColCheck": 
		case "HoldLayCheck": 
		case "HoldLayRowCheck": 
		case "HoldLayColCheck": 
			CheckBox HoldNoneCheck value=0
			break
		default:
			break
	endswitch

	return 0
End




