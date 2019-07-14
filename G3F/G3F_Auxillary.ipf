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

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
Function UpdateFeedbackButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	if ( ba.eventCode == 2)
		UpdateOverlayFeedback(0); 
	endif 
	return 0
End

//******************************************************************
// Framework functions
//
//******************************************************************


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// search position in the specified column by calibration value 
Function BinarySearchCol(w, value, col) 
	wave w
	variable value;
	variable col;
	
	variable min_i = 0;
	variable minDelta = abs(value - w[0][col]);
	variable last = DimSize(w, 0) - 1;
	
	variable i
	for(i=1; i<= last;i+=1)	
		variable aDelta = 	abs(value - w[i][col]);
		if (aDelta < minDelta)
			minDelta = aDelta;
			min_i = i;
		endif
	endfor
	
	if (min_i == 0)
		if (w[0][col] < w[1][col]) // ascending  
			if (value < w[0][col])
				return -1; 
			endif 
		else // descending
			if (value > w[0][col])
				return -1; 
			endif 
		endif
	elseif (min_i == last)
		if (w[last - 1][col] < w[last][col]) // ascending  
			if (value > w[last][col])
				return -2; 
			endif 
		else // descending
			if (value < w[last][col])
				return -2; 
			endif 
		endif
	endif
	return min_i;
	
		
end

//********************
//
function Mean2D(w, p1, p2, q1, q2)
wave w // has to be a wave
variable p1, p2, q1, q2

variable nP = dimsize(w, 0);
variable nQ = dimsize(w, 1);
variable tmp;
if (p1 > p2)
	tmp = p1;
	p1 = p2 
	p2 = tmp;
endif
if (q1 > q2)
	tmp = q1;
	q1 = q2 
	q2 = tmp;
endif
if ((p2 < 0) || (q2 < 0) || (p1 >= nP) || (q1 >= nQ)) // one of requested ranges are entirely outside dimentions of wave
	return nan;
endif
if (p1 < 0)  
	p1 = 0; 
endif
if (q1 < 0)  
	q1 = 0; 
endif
if (p2 >= nP)  
	p2 = nP - 1; 
endif
if (q2 >= nQ) 
	q2 = nQ - 1; 
endif
// now add values

//variable pnts = 0;
variable ave = 0;
variable i, j

for (i=p1; i<=p2; i+=1)
	for (j=q1; j<= q2; j+=1)
		ave += w[i][j]
	endfor	
endfor
return  ave / ((p2 - p1 +1) * (q2-q1 +1))
end


//********************
//
function Mean3D(w, p1, p2, q1, q2, r)
wave w // has to be a wave
variable p1, p2, q1, q2, r

variable nP = dimsize(w, 0);
variable nQ = dimsize(w, 1);
variable nR = dimsize(w, 2);
variable tmp;
if (p1 > p2)
	tmp = p1;
	p1 = p2 
	p2 = tmp;
endif
if (q1 > q2)
	tmp = q1;
	q1 = q2 
	q2 = tmp;
endif
if ((p2 < 0) || (q2 < 0) || (p1 >= nP) || (q1 >= nQ) || (nR > 0 && (r < 0 || r>= nR))) // one of requested ranges are entirely outside dimentions of wave
	return nan;
endif
if (p1 < 0)  
	p1 = 0; 
endif
if (q1 < 0)  
	q1 = 0; 
endif
if (p2 >= nP)  
	p2 = nP - 1; 
endif
if (q2 >= nQ) 
	q2 = nQ - 1; 
endif
// now add values

//variable pnts = 0;
variable ave = 0;
variable i, j

for (i=p1; i<=p2; i+=1)
	for (j=q1; j<= q2; j+=1)
		ave += w[i][j][r]
	endfor	
endfor
return  ave / ((p2 - p1 +1) * (q2-q1 +1))
end



//********************
//
function Mean3D_mask(w, p1, p2, q1, q2, r, mX, mZ )
	wave w // has to be a wave
	variable p1, p2
	variable q1, q2
	variable  r
	wave mX, mZ


	variable nP = dimsize(w, 0);
	variable nQ = dimsize(w, 1);
	variable nR = dimsize(w, 2);
	
	if(nQ==0) 
		nQ = 1;
	endif
	if(nR==0) 
		nR = 1;
	endif

	variable tmp;
	if (p1 > p2)
		tmp = p1;
		p1 = p2 
		p2 = tmp;
	endif
	if (q1 > q2)
		tmp = q1;
		q1 	= q2 
		q2 = tmp;
	endif
	if ((p2 < 0) || (q2 < 0) || (p1 >= nP) || (nQ > 1 && (q1 >= nQ)) || (nR > 1 && (r < 0 || r>= nR))) // one of requested ranges are entirely outside dimentions of wave
		return Inf;
	endif
	
	if (p1 < 0)  
		p1 = 0; 
	endif
	if (q1 < 0)  
		q1 = 0; 
	endif
	if (p2 >= nP)  
		p2 = nP - 1; 
	endif
	if (q2 >= nQ) 
		q2 = nQ - 1; 
	endif
	
	// check mask
	variable useXmask = waveexists(mX)
	variable useZmask = waveexists(mZ)
	
	// now add values
	variable npnts = 0;
	variable ave = 0;
	variable i, j

	if (!(useXMask || useZmask))
			for (i=p1; i<=p2; i+=1)
			for (j=q1; j<= q2; j+=1)
				ave += w[i][j][r]
			endfor	
		endfor
		npnts = ((p2 - p1 +1) * (q2-q1 +1));
	elseif (useXMask)
		if (dimsize(mX,0) <= p2)
			return inf;
		endif 
		for (i=p1; i<=p2; i+=1)
			if (mX[i] != 0 )
				for (j=q1; j<= q2; j+=1)
					ave += w[i][j][r]
				endfor	
				npnts += q2 - q1 + 1;
			endif
		endfor
	elseif (useZmask)
		if (dimsize(mZ,0) <= q2)
			return inf;
		endif 
		for (j=q1; j<= q2; j+=1)
			if (mZ[j] != 0 )
				for (i=p1; i<=p2; i+=1)
					ave += w[i][j][r]
				endfor	
				npnts += p2 - p1 + 1;
			endif
		endfor
	else // useXMask && useZmask
		if ((dimsize(mX,0) <= p2) || (dimsize(mZ,0) <= q2))
			return inf;
		endif 
		for (i=p1; i<=p2; i+=1)
			if (mX[i] != 0 )
				for (j=q1; j<= q2; j+=1)
					if (mZ[j] != 0 )
						ave += w[i][j][r]
						npnts += 1;
					endif
				endfor	
			endif
		endfor
	endif	
	if (npnts)
		return  ave / npnts
	endif
	return NaN		
end

//********************
//
function Mean2D_P(w, p1, p2, q0)
	wave w // has to be a wave
	variable p1, p2, q0

	variable nP = dimsize(w, 0);
	variable tmp;
	if (p1 > p2)
		tmp = p1;
		p1 = p2 
		p2 = tmp;
	endif

	if ((p2 < 0)  || (p1 >= nP) || (q0 > dimsize(w, 1)) || (q0 < 0)) // one of requested ranges are entirely outside dimentions of wave
		return nan;
	endif
	if (p1 < 0)  
		p1 = 0; 
	endif
	if (p2 >= nP)  
		p2 = nP - 1; 
	endif

	variable ave = 0;
	variable i

	for (i=p1; i<=p2; i+=1)
		ave += w[i][q0]
	endfor
	return  ave / (p2 - p1 +1) 
end

//********************
//
function Mean3D_P(w, p1, p2, q0, r)
	wave w // has to be a wave
	variable p1, p2, q0, r

	variable nP = dimsize(w, 0);
	variable tmp;
	if (p1 > p2)
		tmp = p1;
		p1 = p2 
		p2 = tmp;
	endif

	if ((p2 < 0)  || (p1 >= nP) || (q0 > dimsize(w, 1)) || (q0 < 0)) // one of requested ranges are entirely outside dimentions of wave
		return nan;
	endif
	if (p1 < 0)  
		p1 = 0; 
	endif
	if (p2 >= nP)  
		p2 = nP - 1; 
	endif

	variable ave = 0;
	variable i

	for (i=p1; i<=p2; i+=1)
		ave += w[i][q0][r]
	endfor
	return  ave / (p2 - p1 +1) 
end


//********************
//
function Mean3D_P_mask(w, p1, p2, q0, r, m)
	wave w // has to be a wave
	variable p1 // from point in w
	variable p2 // to point in w
	variable q0 // col in w
	variable r // chunk in w
	wave m

	variable nP = dimsize(w, 0);
	variable tmp;
	if (p1 > p2)
		tmp = p1;
		p1 = p2 
		p2 = tmp;
	endif

	if ((p2 < 0)  || (p1 >= nP) || (q0 > dimsize(w, 1)) || (q0 < 0)) // one of requested ranges are entirely outside dimentions of wave
		return nan;
	endif
	if (p1 < 0)  
		p1 = 0; 
	endif
	if (p2 >= nP)  
		p2 = nP - 1; 
	endif

	if (waveexists(m) && (p2 >= dimsize(m,0)))
		return nan
	endif

	variable ave = 0;
	variable i
	variable n = 0

	for (i=p1; i<=p2; i+=1) 
		if (!waveexists(m) || (m[i] != 0))
			ave += w[i][q0][r]
			n += 1
		endif
	endfor
	if (n==0)
		return NaN
	endif
	return  ave / n //(p2 - p1 +1) 
end


//********************
//
function Mean2D_Q(w, p0, q1, q2)
	wave w // has to be a wave
	variable q1, q2, p0

	variable nQ = dimsize(w, 1);
	variable tmp;
	if (q1 > q2)
		tmp = q1;
		q1 = q2 
		q2 = tmp;
	endif

	if ((q2 < 0)  || (q1 >= nQ) || (p0 >= dimsize(w, 0)) || (p0 < 0)) // one of requested ranges are entirely outside dimentions of wave
		return nan;
	endif
	if (q1 < 0)  
		q1 = 0; 
	endif
	if (q2 >= nQ)  
		q2 = nQ - 1; 
	endif

	variable ave = 0;
	variable i

	for (i=q1; i<=q2; i+=1)
		ave += w[p0][i]
	endfor
	return  ave / (q2 - q1 +1) 
end


//********************
//
function Mean2D_Q_mask(w, p0, q1, q2, m)
	wave w // has to be a wave
	variable q1, q2 // col range
	variable p0 // point index
	wave m // mask

	variable nQ = dimsize(w, 1);
	variable tmp;
	if (q1 > q2)
		tmp = q1;
		q1 = q2 
		q2 = tmp;
	endif

	if ((q2 < 0)  || (q1 >= nQ) || (p0 >= dimsize(w, 0)) || (p0 < 0)) // one of requested ranges are entirely outside dimentions of wave
		return nan;
	endif
	if (q1 < 0)  
		q1 = 0; 
	endif
	if (q2 >= nQ)  
		q2 = nQ - 1; 
	endif

	if (waveexists(m) && (q2 >= dimsize(m,0)))
		return nan
	endif
	
	variable ave = 0;
	variable i
	variable n = 0
		
	for (i=q1; i<=q2; i+=1) 
		if (!waveexists(m) || (m[i] != 0))
			ave += w[p0][i]
			n += 1
		endif
	endfor
	if (n==0)
		return NaN
	endif
	return  ave / n //(p2 - p1 +1) 
end

//********************
//
function Mean3D_Q(w, p0, q1, q2, r)
	wave w // has to be a wave
	variable q1, q2, p0, r

	variable nQ = dimsize(w, 1);
	variable tmp;
	if (q1 > q2)
		tmp = q1;
		q1 = q2 
		q2 = tmp;
	endif

	if ((q2 < 0)  || (q1 >= nQ) || (p0 >= dimsize(w, 0)) || (p0 < 0)) // one of requested ranges are entirely outside dimentions of wave
		return nan;
	endif
	if (q1 < 0)  
		q1 = 0; 
	endif
	if (q2 >= nQ)  
		q2 = nQ - 1; 
	endif

	variable ave = 0;
	variable i


	for (i=q1; i<=q2; i+=1)
		ave += w[p0][i][r]
	endfor
	return  ave / (q2 - q1 +1) 
end


//********************
//
function mean3D__(dim, mtx, from, to, dim1, dim2)
	variable dim;
	wave mtx;
	variable from
	variable to
	variable dim1;
	variable dim2;
	variable tmp;
	
	switch (dim)
		case 0:
			return mean3D_X(mtx, from, to, dim1, dim2);
		case 1:
			return mean3D_Z(mtx, from, to, dim1, dim2);
		case 2:
			return mean3D_L(mtx, from, to, dim1, dim2);
		endswitch;
	return NaN;
end

//********************
//
function mean3D_X(mtx, from, to, col, lay)
	wave mtx;
	variable from
	variable to
	variable col;
	variable lay;
	variable tmp;

	if (col<0 || col>= dimsize(mtx, 1))
		return 0;
	endif
	
	if (from > to) 
		tmp = from
		from=to 
		to= tmp
	endif

	if (from < 0)
		from = 0;
	endif

	if (dimsize(mtx, 0) <= to)
		to = dimsize(mtx, 0) -1;
	endif

	if (to < from) 
		return 0
	endif

	variable result = 0; 

	variable i;
	if (dimsize(mtx, 2) < 1)
		if (lay != 0)
			return 0;
		endif 
		for (i=from; i<=to; i+=1)
			result += mtx[i][col]
		endfor
	else
		if (lay<0 || lay>= dimsize(mtx, 2))
			return 0;
		endif	
		for (i=from; i<=to; i+=1)
			result += mtx[i][col][lay]
		endfor
	endif
	result  /= to-from + 1
	return result;
end

//********************
//
function mean3D_Z(mtx, from, to, row, lay)
	wave mtx;
	variable from
	variable to
	variable row;
	variable lay;

end

//********************
//
function mean3D_L(mtx, from, to, row, col)
	wave mtx;
	variable from
	variable to
	variable row;
	variable col;

end


//-------------------------------------------------------------
//
function SetGlobGuesses(aLocName, varDim, in3D) //colLimWaveW //BaseNameS

	STRUCT fitVarDimT &varDim
	STRUCT inDataT &in3D
	string aLocName
	variable NActRows,  NTotRows, NLayers 
	wave /Z ZWave
	
	
	NVAR NLocVar= $cG3FControl+":Num"+aLocName+"Var"
	varDim.nVars = NLocVar 
	
	string BaseName = aLocName+"Loc"
	string ParamsWaveS = in3D.BaseName+"_"+BaseName


	if (exists (ParamsWaveS) != 1) // no such wave 
		Make /O/D/N=(varDim.NVars) $ParamsWaveS
	endif
	
	WAVE varDim.ParW = $ParamsWaveS
	Redimension /D/N=(varDim.NVars) varDim.ParW
	
	Make /O/D/N=(varDim.NVars) $in3D.BaseName+"_"+BaseName+"Sigma"
	WAVE varDim.SigmaW = $in3D.BaseName+"_"+BaseName+"Sigma"
	
	Wave/U/B  GuessListSelection=$cG3FControl+":GuessListSelection"
	Wave/T GuessListWave = $cG3FControl+":GuessListWave"
	
	variable i
	for (i = 0; i < varDim.nVars; i += 1)
		varDim.ParW[i] = str2num(GuessListWave[i][2])
	endfor

end


//-------------------------------------------------------------
//
function SetLocGuesses(holdFlag, aLocName, varDim, GuessFVarName, NActRows, NTotRows, NLayers, in3D, dim, ZWave) //colLimWaveW //BaseNameS

	variable holdFlag
	STRUCT fitVarDimT &varDim
	STRUCT inDataT &in3D
	string aLocName
	string GuessFVarName
	variable NActRows,  NTotRows, NLayers 
	variable dim
	wave /Z ZWave
	
	
	NVAR NLocVar= $cG3FControl+":Num"+aLocName+"Var"
	varDim.nVars = NLocVar 
	
	string BaseName = aLocName+"Loc"
	
	NVAR VarFlags = $cG3FControl+":VarFlags";
	variable UseColLocGuesses = VarFlags & holdFlag;
	
	string ParamsWaveS = in3D.BaseName+"_"+BaseName

	if (NTotRows <= 0 )
		WAVE varDim.ParW = $""
		WAVE varDim.SigmaW = $""
		return 1
	endif 
	
	if (exists (ParamsWaveS) != 1) // no such wave 
		UseColLocGuesses = 0
		Make /O/D/N=(NActRows, varDim.NVars, NLayers) $ParamsWaveS
	endif
	WAVE varDim.ParW = $ParamsWaveS
	Make /O/D/N=(NActRows, varDim.NVars, NLayers) $in3D.BaseName+"_"+BaseName+"Sigma"
	WAVE varDim.SigmaW = $in3D.BaseName+"_"+BaseName+"Sigma"
	SVAR sGuessFunction =  $cG3FControl+":"+GuessFVarName

	if (DimSize(varDim.ParW, 1) != varDim.NVars)  // wrong number of coeficients - erase regardless 
		if (UseColLocGuesses != 0) 
			DoAlert 2, "The number of "+BaseName+" variables has changed. You may have selected a new function and local guesses are likely incorrect.\rDo you  want to calculate inital values using guessing function "+sGuessFunction+"?"
			switch (V_flag)
				case 1:  // Ok
					UseColLocGuesses = 0
					break;
				case 3: // cancel
					return 0;
			endswitch 
		endif 
	endif 
	Redimension /D/N=(NActRows, varDim.NVars, NLayers) varDim.ParW

	if (UseColLocGuesses) 
		AdjustGuesses(varDim.ParW, NActRows, varDim.NVars, NTotRows); // this is not handling changes in layers!
	else
		string CXWaveS;
		if (!in3D.FromListSet)
			CXWaveS = nameofwave(ZWave) ;
		else
			CXWaveS = "";
		endif
	
		string CColLimWaveS;
		if (waveexists(in3D.colLimWaveW)) 
			 CColLimWaveS = nameofwave(in3D.colLimWaveW) ;
		else
			 CColLimWaveS = "";
		endif 

		// these define the number of rows to be corrected which may be different form total number of cols
		if (in3D.FromListSet)
			CalculateGuesses(varDim.ParW, NActRows, varDim.NVars, NLayers, sGuessFunction,nameofwave(in3D.MTWave), dim, CXWaveS,  CColLimWaveS );	
		else
			CalculateGuesses(varDim.ParW, NActRows, varDim.NVars, NLayers, sGuessFunction, nameofwave(in3D.MNWave), dim, CXWaveS,  CColLimWaveS );	
		endif
	endif	
end


//-------------------------------------------------------------
//
function assembleContraints(G3FitConstraintWave, setName, nRows,  nLays, nextRow, offset, varDim)
	wave /T G3FitConstraintWave
	string setName
	variable nRows, nLays
	variable &nextRow, &offset
	STRUCT fitVarDimT &varDim
//	variable aHoldFlags
	

	if (nLays < 1)
		nLays = 1;
	endif

	variable i, r, k
	String constraintExpression
	
	Wave/Z/T ConstraintsRowListWave = $cG3FControl+":"+setName+"ListWave"
	WAVE /Z ConstraintsRowSelectionWave=$cG3FControl+":"+setName+"SelectionWave"

	if (!(varDim.hold) && waveexists(ConstraintsRowListWave) && waveexists(ConstraintsRowSelectionWave)) // ROW Locals  are NOT held 
		Variable nRowConstr=DimSize(ConstraintsRowListWave, 0)
		//NVAR nRowVars  =  $cG3FControl+":Num"+setName+"Var"
		for (k = 0; k < nLays; k += 1)
			for (r = 0; r < nRows; r += 1)
				for (i=0; (i < nRowConstr && i < varDim.nVars); i += 1)
					if (!(ConstraintsRowSelectionWave[i][6] & 16)) // param is not held 
						if (strlen(ConstraintsRowListWave[i][2]) > 0)
							InsertPoints nextRow, 1, G3FitConstraintWave
							sprintf constraintExpression, "K%d > %s", i+r*nRowConstr+offset, ConstraintsRowListWave[i][2]
							G3FitConstraintWave[nextRow] = constraintExpression
							nextRow += 1
						endif
						if (strlen(ConstraintsRowListWave[i][4]) > 0)
							InsertPoints nextRow, 1, G3FitConstraintWave
							sprintf constraintExpression, "K%d < %s", i+r*nRowConstr+offset, ConstraintsRowListWave[i][4]
							G3FitConstraintWave[nextRow] = constraintExpression
							nextRow += 1
						endif
					endif
				endfor
			endfor
		endfor
		offset += varDim.nVars * nRows * nLays;
	endif
end


//-------------------------------------------------------------
//
// from Contraints
function assembleMoreContraints(G3FitConstraintWave, MoreConstraintsListWave, nextRow, varDim1, varDim2, varDim3 )
	wave /T G3FitConstraintWave
	Wave/Z/T MoreConstraintsListWave 
	variable &nextRow
	STRUCT fitVarDimT &varDim1
	STRUCT fitVarDimT &varDim2
	STRUCT fitVarDimT &varDim3

	
	variable i
		
	if ( !(varDim1.hold && varDim2.hold && varDim3.hold) && waveexists(MoreConstraintsListWave)) // Any group is  NOT held 
		variable nPnts = DimSize(MoreConstraintsListWave, 0)
		for (i = 0; i < nPnts; i += 1)
			if (strlen(MoreConstraintsListWave[i]) > 0)
				InsertPoints nextRow, 1, G3FitConstraintWave
				G3FitConstraintWave[nextRow] = MoreConstraintsListWave[i]
				nextRow += 1
			endif
		endfor
	endif
end


// from Contraints
//-------------------------------------------------------------
//
function assembleEpsilon(EpsilonWave, setName, nRows, nLays, nTotEntries, DefEpsilon, varDim)
	wave EpsilonWave
	string setName
	variable nRows, nLays
	variable &nTotEntries
	variable DefEpsilon
	STRUCT fitVarDimT &varDim
//	variable aHoldFlags


	WAVE /Z ConstraintsSetSelectionWave =$cG3FControl+":"+setName+"SelectionWave"
	Wave/Z/T ConstraintsSetListWave = $cG3FControl+":"+setName+"ListWave"

	if (nLays < 1)
		nLays = 1;
	endif

	variable i, r, k
	
		
		if (!(varDim.hold) && waveexists(ConstraintsSetListWave) && waveexists(ConstraintsSetSelectionWave)) // Row locals are NOT held 
			variable nSetEntries=DimSize(ConstraintsSetListWave, 0)
			redimension /N=(nTotEntries+nRows*varDim.nVars*nLays) EpsilonWave
			for (k=0 ; k< nLays	; k+= 1)
				for (r = 0; r < nRows; r += 1)
					for (i=0; (i < varDim.nVars && i < nSetEntries); i += 1, nTotEntries += 1)
						if ((i < varDim.nVars) && (!(ConstraintsSetSelectionWave[i][6] & 16)) && (strlen(ConstraintsSetListWave[i][5]) > 0))
							EpsilonWave[nTotEntries] = str2num(ConstraintsSetListWave[i][5])
						endif
						if (numtype (EpsilonWave[nTotEntries]) || EpsilonWave[nTotEntries] == 0)
							EpsilonWave[nTotEntries] = DefEpsilon
						endif
					endfor
				endfor
			endfor
		endif
end

// from Guesses
//-------------------------------------------------------------
//
function assembleHold(HS, setName, nRows, nLays, nHolds, varDim, CParamW)
	string &HS
	string setName
	variable nRows,  nLays //nRowVars,
	variable &nHolds
	STRUCT fitVarDimT &varDim
	wave CParamW;
	
	if (varDim.hold) // all Set are held 
		return 0
	endif
	
	variable i, j, k

	WAVE /Z ConstraintsSetSelectionWave =$cG3FControl+":"+setName+"SelectionWave"
	if (!waveExists(ConstraintsSetSelectionWave))
		abort "Required constraint selection wave ["+cG3FControl+":"+setName+"SelectionWave"+"] is not found!"
	endif 
	
	variable HoldStrLen = strlen(HS);
	Variable nSetVars=DimSize(ConstraintsSetSelectionWave, 0)
	for (k = 0; k < nLays; k += 1)
		for (j=0; j<nRows; j+=1)
			for (i=0; (i<nSetVars && i < varDim.nVars); i+=1)
				if (ConstraintsSetSelectionWave[i][6] & 16)
					HS += "1"
					nHolds += 1
				else // ensure that value is valid
					if (NumType(CParamW[HoldStrLen])!=0) // inf or nan supplied for a fitted variable
						abort ("An in valid value was supplied for "+setName+" at offset "+num2str(i)+":"+num2str(j)+":"+num2str(k))
					endif 
					HS += "0"
				endif
				HoldStrLen += 1;
			endfor
		endfor
	endfor
end

//-------------------------------------------------------------
//
function Guess2FitCoef(linCoefWave, varDim, nRows, NLays,  linCoefOffset)
	STRUCT fitVarDimT &varDim
	wave linCoefWave
	variable  nRows,  NLays
	variable &linCoefOffset

	variable i, j, k

	if (varDim.hold)  // copy only fitted locals 
		varDim.linOffset = 0;
		WAVE varDim.linW = varDim.heldW;
	else // copy only fitted locals 
		Redimension /D/N=(linCoefOffset + nRows * varDim.nVars * (NLays > 0 ? NLays : 1)) linCoefWave
		varDim.linOffset = linCoefOffset;
		WAVE varDim.linW = linCoefWave;
		variable paramLays = dimsize(varDim.ParW, 2);
		variable paramCols = dimsize(varDim.ParW, 1);
		variable paramRows = dimsize(varDim.ParW, 0);
		
		for (k=0; k < NLays || k < 1; k+=1)
			for (i=0; i<nRows; i+=1)
				for (j=0; j<varDim.nVars; j+=1, linCoefOffset+=1)
					if (paramLays > 0)
						linCoefWave[linCoefOffset]=varDim.ParW[i][j][k]
					elseif (paramCols > 0)
						linCoefWave[linCoefOffset]=varDim.ParW[i][j]
					else
						linCoefWave[linCoefOffset]=varDim.ParW[j]
					endif
				endfor
			endfor
		endfor
		
	endif	
end 

//-------------------------------------------------------------
//
function FitCoeff2Guess(linCoefWave, varDim, nRows, NLays,  linCoefOffset, rowOffs)
	STRUCT fitVarDimT &varDim
	wave linCoefWave
	variable nRows, NLays 
	variable &linCoefOffset
	variable rowOffs
	

	variable i, j, k
		variable paramLays = dimsize(varDim.ParW, 2);
		variable paramCols = dimsize(varDim.ParW, 1);
		variable paramRows = dimsize(varDim.ParW, 0);
	
	if (!varDim.hold) // only fitted locals are copied	back
		for (k=0; k<NLays || k < 1; k+=1) // at least once
			for (i=0; i<nRows; i+=1)
				for (j=0; j<varDim.nVars; j+=1, linCoefOffset+=1)
					if (paramLays > 0)
						varDim.ParW[i+rowOffs][j][k] = linCoefWave[linCoefOffset]
					elseif (paramCols > 0)
						varDim.ParW[i+rowOffs][j] = linCoefWave[linCoefOffset]
					else
						varDim.ParW[j] = linCoefWave[linCoefOffset]
					endif
					//varDim.ParW[i+rowOffs][j][k] = linCoefWave[linCoefOffset]
				endfor
			endfor
		endfor
	endif
	
end


//-------------------------------------------------------------
//
function FitSigma2Guess(linSigmaWave, varDim, nRows, NLays,  linCoefOffset, rowOffs)
	STRUCT fitVarDimT &varDim
	wave linSigmaWave
	variable nRows,  NLays 
	variable &linCoefOffset
	variable rowOffs
	

	variable i, j, k
	
	if (!varDim.hold) // only fitted LayCOL locals are copied	
		for (k=0; k<NLays || k < 1; k+=1) // at least once
			for (i=0; i<nRows; i+=1)
				for (j=0; j<varDim.nVars; j+=1, linCoefOffset+=1)
					varDim.SigmaW[i+rowOffs][j][k] = linSigmaWave[linCoefOffset]
				endfor
			endfor
		endfor
	endif
	
end



//-------------------------------------------------------------
//
function MaskedRangeHasValues(in1D, fromP, toP)
	STRUCT inDataDimT &in1D;
	variable fromP, toP
	
	variable ave = 0
	variable found = 0;
	variable currX_Offs
	if (!in1D.ave)
		toP = fromP;
	endif 

	if (waveexists(in1D.maskW))
		for (currX_Offs = fromP; currX_Offs <= toP ; currX_Offs +=  1 )  // iterate
			if (in1D.maskW[currX_Offs]!= 0) // single valid value is sufficient
				ave += currX_Offs;
				found +=1
			endif
		endfor
	else // no mask, all values are valid
		for (currX_Offs = fromP; currX_Offs <= toP ; currX_Offs +=  1 )  // iterate
			ave += currX_Offs;
		endfor
		found = toP - fromP + 1;
	endif
	if (found)
		return ave/found;
	else
		return NaN;
	endif
end

//-------------------------------------------------------------
//

function AssembleDataFromList (in3D, fitData) 
	STRUCT inDataT &in3D
	STRUCT fitDataT &fitData
	//wave  colLimWaveW // optional limiting wave

	variable outN_Rows = dimsize(fitData.fThinW,0);
	variable outN_Cols = dimsize(fitData.fThinW,1);
	variable outN_Lays = dimsize(fitData.fThinW,2);
	variable aL, aP, aQ // loop indices
	
	variable i_out_Offset = 0 // offset of current layer start in the linear output wave
	variable outZ_Len =0;
	
	fitData.fThinW = NaN;
	variable hasXData
	variable hasYData
	variable iL = 0, iP = 0 , iQ = 0 // thinned wave indices
	variable aT = 0; // thinned set index
	variable maxN_Cols = 0;
	variable maxN_Rows = 0;

	variable nT = 1; 
	if (in3D.X.thin > 1 && in3D.X.ave)
		nT = in3D.X.thin;
	endif 
	
	for (aL = 0, iL = 0; iL < outN_Lays; aL+=1) 
		variable inL_Offs = in3D.L.from + (aL * in3D.L.thin ) // in wave layer offset from 0 
		hasYData = MaskedRangeHasValues(in3D.Z, inL_Offs, inL_Offs + in3D.L.thin -1)  
		if (numtype(hasYdata) == 0)
			if (iL > 0) 
				abort "List matrix assembly does not support 3D data"
			endif 
		
			for (aP = 0, iP = 0; iP<outN_Rows; aP+=1) 	//fill in data waves
				variable inX_Offs = in3D.X.from + (aP * in3D.X.thin) // in wave point offset from 0
				hasYData = MaskedRangeHasValues(in3D.X, inX_Offs, inX_Offs + in3D.X.thin -1)  
				if (numtype(hasYdata) == 0)
				
					variable outN_Cols_lim = outN_Cols;
					if (waveexists(in3D.colLimWaveW) && (in3D.colLimWaveW[inX_Offs] > 0) &&  (outN_Cols_lim > in3D.colLimWaveW[inX_Offs]))
						outN_Cols_lim = in3D.colLimWaveW[inX_Offs]	
					endif 
					for (aQ = 0, iQ = 0; iQ < outN_Cols_lim; aQ +=1)
						variable inZ_Offs = in3D.Z.from + (aQ * in3D.Z.thin) // in wave column offset from 0
						variable vX = 0, vY = 0, nV = 0; 
						for (aT = 0; aT < nT; aT +=1 ) 
							WAVE yWave_i = $(in3D.MTWave[inX_Offs + aT][0][aL])
							WAVE xWave_i = $(in3D.MTWave[inX_Offs + aT][1][aL])
							if ( !in3D.Z.ave) // no averaging
								hasYData = Mean3D_mask   (	yWave_i, 	inZ_Offs, 	inZ_Offs,						0,	0, aL, in3D.X.maskW, in3D.Z.maskW )
								hasxData = Mean3D_mask   (	XWave_i, 	inZ_Offs, 	inZ_Offs,						0,	0, aL, in3D.X.maskW, in3D.Z.maskW )
							elseif (in3D.Z.ave) // Average Z only 
								hasYData = Mean3D_mask   (	yWave_i, 	inZ_Offs, 	inZ_Offs + in3D.Z.thin - 1,	0,	0, aL, in3D.X.maskW, in3D.Z.maskW )
								hasxData = Mean3D_mask   (	XWave_i, 	inZ_Offs, 	inZ_Offs + in3D.Z.thin - 1,	0,	0, aL, in3D.X.maskW, in3D.Z.maskW )
							endif
							if (numtype(hasYData) == 0 && numtype(hasXData) == 0)
								vY += hasYData;
								vX += hasXData;
								nV += 1;
							endif
						endfor // thinning
						if (nV > 0)
							fitData.fThinW[iP][iQ][iL] = hasYData / nV;
							fitData.Z.fitClbW[iP][iQ][iL] = hasXData / nV;
							iQ +=1;
						endif
					endfor // cols
					if (iL == 0 || fitData.ColNumWave[iP] < iQ)					
						fitData.ColNumWave[iP] = iQ
					endif
					if (iQ > maxN_Cols)
						maxN_Cols = iQ
					endif
					iP +=1;
				endif
			endFor // points 
			if (iP > maxN_Rows)
				maxN_Rows = iP;
			endif
			iL +=1;
		endif
	endfor // layers
	// trim data to just useable dimensions
	redimension /N=(maxN_Rows, maxN_Cols, iL) fitData.fThinW
	redimension /N=(maxN_Rows) fitData.ColNumWave
end


//-------------------------------------------------------------
//
// to-do - handle matrix calibration and colLims
function AssembleClbFromMatrix (inDim, CWave) 
	STRUCT inDataDimT &inDim
	wave CWave

	variable aP // loop indices
	variable capacity = dimsize(CWave, 0);
	
	variable i_out_Offset = 0 
	variable outZ_Len =0;
	
		for (aP = inDim.from ; (aP <= inDim.to) && (i_out_Offset < capacity); aP+=inDim.thin) 	
			variable	curr = MaskedRangeHasValues(inDim, aP, aP +inDim.thin -1);
			if (numtype(curr) == 0)
				CWave[i_out_Offset][1] = curr;
				if (waveexists(inDim.clbW))
					curr = NaN;
					if (inDim.ave)
						curr= 	Mean3D_mask	( 	inDim.clbW, 	aP,		aP+ inDim.thin - 1,  	0, 0,	0,	inDim.maskW, $"" )  
					else
						curr= 	Mean3D_mask	( 	inDim.clbW, 	aP,		aP,  						0, 0,	0,	inDim.maskW, $"" )  
					endif	
					CWave[i_out_Offset][0] = curr;
				else
					CWave[i_out_Offset][0] = CWave[i_out_Offset][0];
				endif
				i_out_Offset += 1;
			endif 
		endFor // points in this layer 

	if (i_out_Offset < capacity)
		redimension /N=(i_out_Offset , -1) CWave			
	endif
	return i_out_Offset; // total used length of output wave
end
//-------------------------------------------------------------
//

function AssembleDataFromMatrix(in3D, fitData) //fThinW, ColNumWave,
	STRUCT inDataT &in3D
	STRUCT fitDataT &fitData

	variable outN_Rows = dimsize(fitData.fThinW,0);
	variable outN_Cols = dimsize(fitData.fThinW,1);
	variable outN_Lays = dimsize(fitData.fThinW,2);
	variable aL, aP, aQ // loop indices
	
	variable i_out_Offset = 0 // offset of current layer start in the linear output wave
	variable outZ_Len =0;
	
	fitData.fThinW = NaN;
	variable hasData
	variable iL = 0, iP = 0 , iQ = 0 // thinned wave indices
	variable maxN_Cols = 0;
	variable maxN_Rows = 0;
	
	for (aL = 0, iL = 0; (iL < outN_Lays || iL == 0); aL+=1) 
		variable inL_Offs = in3D.L.from + (aL * in3D.L.thin ) // in wave layer offset from 0 
		hasData = MaskedRangeHasValues(in3D.Z, inL_Offs, inL_Offs + in3D.L.thin -1)  
		if (numtype(hasdata) == 0)
			for (aP = 0, iP = 0; iP<outN_Rows; aP+=1) 	//fill in data waves
				variable inX_Offs = in3D.X.from + (aP * in3D.X.thin) // in wave point offset from 0
				hasData = MaskedRangeHasValues(in3D.X, inX_Offs, inX_Offs + in3D.X.thin -1)  
				if (numtype(hasdata) == 0)
					variable outN_Cols_lim = outN_Cols;
					if (waveexists(in3D.colLimWaveW) && (in3D.colLimWaveW[inX_Offs] > 0) &&  (outN_Cols_lim > in3D.colLimWaveW[inX_Offs]))
						outN_Cols_lim = in3D.colLimWaveW[inX_Offs]	
					endif 
					for (aQ = 0, iQ = 0; iQ < outN_Cols_lim; aQ +=1)
						variable inZ_Offs = in3D.Z.from + (aQ * in3D.Z.thin) // in wave column offset from 0
						if (!in3D.X.ave && !in3D.Z.ave) // no averaging
							hasData = Mean3D_mask   (	in3D.MNWave, 	inX_Offs, 	inX_Offs, 						inZ_Offs, 	inZ_Offs, 						aL, in3D.X.maskW, in3D.Z.maskW )
						elseif (in3D.X.ave && !in3D.Z.ave) // Average X only
							hasData = Mean3D_mask   (	in3D.MNWave, 	inX_Offs, 	inX_Offs + in3D.X.thin -1, 	inZ_Offs, 	inZ_Offs,						 	aL, in3D.X.maskW, in3D.Z.maskW )
						elseif (!in3D.X.ave && in3D.Z.ave) // Average Z only 
							hasData = Mean3D_mask   (	in3D.MNWave, 	inX_Offs, 	inX_Offs, 						inZ_Offs, 	inZ_Offs + in3D.Z.thin - 1, 	aL, in3D.X.maskW, in3D.Z.maskW )
						else // average X and Z
							hasData = Mean3D_mask   (	in3D.MNWave, 	inX_Offs, 	inX_Offs + in3D.X.thin -1, 	inZ_Offs, 	inZ_Offs + in3D.Z.thin - 1 , 	aL, in3D.X.maskW, in3D.Z.maskW )
						endif
						if (numtype(hasData) == 0)
							fitData.fThinW[iP][iQ][iL] = hasData;
							iQ +=1;
						endif
					endfor // cols
					if (iL == 0 || fitData.ColNumWave[iP] < iQ)					
						fitData.ColNumWave[iP] = iQ
					endif
					if (iQ > maxN_Cols)
						maxN_Cols = iQ
					endif
					iP +=1;
				endif
			endFor // points 
			if (iP > maxN_Rows)
				maxN_Rows = iP;
			endif
			iL +=1;
		endif
	endfor // layers
	// trim data to just useable dimensions
	redimension /N=(maxN_Rows, maxN_Cols, iL) fitData.fThinW
	redimension /N=(maxN_Rows) fitData.ColNumWave
	
end


//-------------------------------------------------------------
//

function AssembleLinearChunk (fitData, chunk, outX_Skip) //XRefW, ZRefW,
	STRUCT fitDataT &fitData
	STRUCT chunkDataT &chunk
	variable outX_Skip // chunk offset (skip) along points 

	variable aL, aP // loop indices
	
	variable outZ_Len =0;
	variable outN_Lays = dimsize(fitData.fThinW, 2);
	variable outN_Cols = dimsize(fitData.fThinW, 1);
	variable outN_Rows = dimsize(fitData.fThinW, 0);
	
	
	variable i_out_Offset = 0 // offset of current layer start in the linear output wave
	for (aL = 0; aL < outN_Lays; aL+=1) 
		for (aP=0; aP<outN_Rows; aP+=1) 	
			variable outN_Cols_lim = fitData.ColNumWave[aP] // column may contain invalid points or there may have been a limter wave supplied
			
			// assemble input data from thinned marix
			chunk.CLinW[i_out_Offset, i_out_Offset + outN_Cols_lim - 1] 		= fitData.fThinW[aP][p - i_out_Offset][aL];
			// assemble Z calibration
			chunk.CClbW[i_out_Offset, i_out_Offset + outN_Cols_lim - 1][1] 	= fitData.Z.fitClbW[p - i_out_Offset][0]
			// assemble X calibration
			chunk.CClbW[i_out_Offset, i_out_Offset + outN_Cols_lim - 1][0] 	= fitData.X.fitClbW[aP][0]
			// assemble L calibration
			if (waveexists(fitData.L.fitClbW))
				chunk.CClbW[i_out_Offset, i_out_Offset + outN_Cols_lim - 1][2] = fitData.L.fitClbW[aL][0]
			else
				chunk.CClbW[i_out_Offset, i_out_Offset + outN_Cols_lim - 1][2] = NaN
			endif 
			
			i_out_Offset += outN_Cols;
		endFor // points in this layer 
	endfor // data layers
	return i_out_Offset
end





//-------------------------------------------------------------
//
function AssembleMatrix_RefWave (chunk, in3D, XZRefWave, XRefW, ZRefW, inX_Offs, outLin_Offs, inL_Len)
	STRUCT chunkDataT &chunk
	STRUCT inDataT &in3D
	wave XZRefWave, XRefW, ZRefW
	variable  inX_Offs, outLin_Offs, inL_Len


	variable nrf = 0;
	variable i,j
	variable curr;
	if (WaveExists(in3D.X.refW))
		variable NXRefData = DimSize(in3D.X.refW, 1);
		for (i=0; i< NXRefData; i+=1)
			if (in3D.X.ave)
				curr = Mean3D_mask	( 	XRefW, 	inX_Offs,		inX_Offs+ in3D.X.thin - 1,  	0, 0,	0,	in3D.X.maskW, $"" )  
			else
				curr = Mean3D_mask	( 	XRefW, 	inX_Offs,		inX_Offs,						  	0, 0,	0,	in3D.X.maskW, $"" )  
			endif 
			if (numtype (curr) == 0)
				XZRefWave[outLin_Offs,outLin_Offs + inL_Len -1][nrf] = curr;
				nrf +=1
			endif
		endfor
	endif



	if (WaveExists(in3D.Z.refW))
		variable NZRefData = DimSize(in3D.Z.refW, 1);
		for (i=0; i< NZRefData; i+=1, nrf+=1)
			for (j=0; j< inL_Len; j+=1)
				if (in3D.Z.ave)											
						curr = Mean3D_mask	( 	ZRefW, 	in3D.Z.from+j*in3D.Z.thin,	in3D.Z.from + (j+1)*in3D.Z.thin - 1,  	i, i,	0,	in3D.Z.maskW, $"" )  
				else
						curr = Mean3D_mask	( 	ZRefW, 	in3D.Z.from+j*in3D.Z.thin,	in3D.Z.from + j*in3D.Z.thin,			  	i, i,	0,	in3D.Z.maskW, $"" )  
				endif
				if (numtype (curr) == 0)
					XZRefWave[outLin_Offs+j][nrf] = curr;
				endif
			endfor
		endfor
	endif
	// do we need to resize ref data wave?
	
	
	SVAR AddtlDataWN_ 	= $cG3FControl+":AddtlDataWN"
	WAVE chunk.AddtlDataW = $AddtlDataWN_
return nrf
end

//-------------------------------------------------------------
//




