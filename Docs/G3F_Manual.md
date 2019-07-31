## G3F MANUAL

### Introduction

The G3F (Global 3-dimensional Fit) is a simulation and fitting package for IgorPro. It allows to perform global spectral regression using flexible combinations of global parameters and dimensionally local (spectral) parameters on up to 3-dimensional matrix datasets.

**How to use this manual:** This manual summarizes the capabilities of the G3F software IgorPro macro. The functions of all features are briefly summarized and documented for easy reference. Basic knowledge of Igor Pro operation and data structures within Igor Pro is assumed. **For quick help, hover over functions on the control panel for simple tooltips.**

For further detail on individual functions, consult the [G3F API](https://github.com/dap-biospec/G3F/blob/master/Docs/G3F_API.md)

### **Installation**

The G3F package consists of several files:

- G3F\_Main.ipf
- G3F\_Auxillary.ipf
- G3F\_Desktop.ipf
- G3F\_DoTheFit.ipf
- G3F\_Feedback.ipf
- G3F\_FitFlow.ipf
- G3F\_Guesses.ipf
- G3F\_List&amp;Set.ipf
- G3F\_Setup.ipf
- G3F\_Struct.ipf

Download all files from [G3F folder](https://github.com/dap-biospec/G3F/blob/master/G3F/) and save in one local folder.

From the top menu IgorPro:<br/>
File -> Open File -> Procedure…

Navigate to and select the G3F\_Main.ipf file to load. Complile G3F\_Main.ipf - this will load all dependnet procedure files listed above.

**Opening main G3F control panel:**

From the top menu IgorPro:<br/>
Analysis -> Global 3D Spectral Regression -> Control Panel


### Data Structure

The overall data structure of the datasets handled by G3F is shown below:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Docs/G3FManualPictures/3D_DataStructure_B.JPG)

Data sets consist of &quot;layers&quot; of matrices with &quot;row&quot;, &quot;column&quot; and &quot;layer&quot; calibrations. The 2D layers of this data structure are shown conceptually below:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Docs/G3FManualPictures/DataStructure_Simple.JPG)

The dimensionality of this data structure is further expanded with Layer-Column (LCP2D) and Layer-Row (LRP2D) dimensions, as shown below:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Docs/G3FManualPictures/DataStructure_2.png)
 
 An alternative depiction of this data structure with emphasis on the roles of global parameters and local parameters is shown below:

 ![alt text](https://github.com/dap-biospec/G3F/blob/master/Docs/G3FManualPictures/DataStructure_3.jpg)
 
Row, column, and layer locals are calculated parameters, whereas global parameters are parameters which remain consistent throughout the data set.

### Summary of G3F User Interface

![alt text](https://github.com/dap-biospec/G3F/blob/master/Docs/G3FManualPictures/ControlPanel.png)

The main control panel of the G3F macro is split into several different sections, each of which are detailed below:

**Reference Data:**

This section is composed of additional data needed for fitting calculations. This is an optional feature for fitting.

- Global reference data: optional numeric wave passed to process, fitting, and post-processing functions

**Method:**

- Process function: Process functions allow the user to predict a process that can later be used in fitting. An example would be the prediction of concentration changes over time by integration of system of ordinary differential equations.


A process function should use global and/or local parameters because it is executed over every iteration of fitting. If it does not, process should be predicted once before fitting is executed.

Once the process is generated, it is passed to the fitting function that performs additional calculations using process values. An example may be extracting unknown spectra or properties of Gaussian bands (fitting) from complex kinetic model (process). Syntax of process functions is similar to that of fitting functions, except for taking an additional parameter for the output process wave, which can be 2D. Fitting function syntax is covered in section V of this manual.

- Last Process:
  - Fit to function: This is the fitting function that is being used for 3DF fit. This function defines the global variables and local variables used in the fit.

- Post-processing: Post-processing functions can perform additional processing after all fittings have been performed. These functions must be supplied by the user.

**Dataset:**

This section covers the input data parameters.

- Data: This is the matrix of data that needs fitting.

- Root: The location of the data in Igor.

- Col limit: Row-by-row limit to number of columns of a rectangular matrix to be used in modeling. This is necessary if the number of data columns in each row is not equal.

**Masks:**

Masks are used to block out signals from fitting. Sections of data may be &quot;masked&quot; and therefore not considered for the fit. An example of this concept is spectroscopic data when fitting a baseline – peak signals must be excluded from the baseline fit in order to preserve meaningful data through the baseline fit.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Docs/G3FManualPictures/Mask_Example.jpg)

- Z(Col): This allows the user to specify a mask wave for the column dimension of data sets

- X(Row): This allows the user to specify a mask wave for the row dimension of data sets

- L(Lay): This allows the user to specify a mask wave for the layer dimension of data sets

**Calibrations:**

Calibrations are essential for generating meaningful traces from fits. When a calibration wave is selected, row points and column points of the data set are calibrated. For example, if a data set has row positions that correspond to frequencies in IR or Raman spectrum, the row points 1, 2,3,…N must be calibrated to correspond to specific frequencies; to do this, a 1D frequency calibration must be specified.

- Z(Col): Calibration wave for the column dimension in data sets.

- X(Row): Calibration wave for the row dimension in data sets.

- L(Lay): Calibration wave for the layer dimension in data sets.

- Make thinned: Thinned calibration waves are waves that are generated following a fit; these &quot;thinned&quot; waves correspond to the specific fit generated for a data set. Checking boxes for a desired dimension will make a 1D wave for modelling from fit.

- Thinned waves for X, Z and L dimensions can be generated in this dialog box by checking the appropriate box.

**Range:**

The specific ranges in fitting is crucial in the G3F process, as this affects both accuracy and time-consumption of the fit. A powerful tool in this section is &quot;thinning.&quot; Thinning allows a smaller subset of representative, equally spaced rows to be used in analysis by either **averaging** or **dropping values.** This greatly speeds up calculations without loss of resolution. This is available in **all** dimensions. **The choice of how much thinning and whether or not the values are averaged or dropped depends on the data set and is up to the user.**

- X(row): The user can specify the range of the fit in the row dimension here.

- Z(col): The user can specify the range of the fit in the column dimension.

- L(col): the user can specify the range of the fit in the layer dimension.

**Global Variables:**

Global variables are variables that pertain to all collections of data sets that are being fitted. Some examples of this in spectroscopy are: band locations, bandwidth, relative shifts between isotopes.

The drop-down menu here specifies how many global variables are being fitted. This must equal those specified in the fitting function, otherwise an error message is generated and the fit will not succeed.

**Initial Guesses:**

- This displays the list of all global variables. The user can input manual guesses here.

- Wave to list: A wave can be loaded here to import guesses for global variables.

- List to wave: The user-defined guesses can be exported to a wave.

**Local Variables:**

Local variables are parameters that are specific to different data sets. As mentioned above, these variables are calculated by the fit and stored in separate waves for easy plotting and analysis by the user. An example of a local variable is the intensity of a specific peak in a spectrum at a specific point in time.

- Recycle: Local variables can be re-used from previous fits as initial guesses. If the data range is resized values of per-column local guesses are interpolated. Otherwise, values are reset using specified guessing function.

- Row (X) Locals: The user can specify the number of local variables in a fit for rows. These variables apply to all layers.

- Col (Z) Locals: The user can specify the number of local variables in a fit for columns. These variables apply to all layers

- Lay (L) Locals: The user can specify the number of local variables in a fit for

- LayRow (X) Locals: The user can specify the number of local variables in a fit for layer rows. This is different for each layer.

- LayCol (L) Locals: The user can specify the number of local variables in a fit for layer columns. This is different for each layer.

**Options:**

This section allows the user to modify the benchmarks of the &quot;goodness&quot; of fit, and total allowed fitting iterations for convergence to be reached.

- ChiSq convergence limit: This is the value which ChiSq must differ by between iterations for the fit to be considered converged. ChiSq is shorthand for Chi squared, which is a metric used to measure the &quot;goodness&quot; of fit – the lower Chi squared, the less difference between the fit and the data, the better the fit.

- Max iterations: This is the number of allowed iterations for the fit to reach convergence. If this is exceeded, an error will be displayed informing the user that maximum iterations have been reached without convergence of the fit.

- Residuals: As in classical multivariational fitting, residuals are the differences between the fit and the data. By checking this box, residuals are saved and stored for analysis by the user.

- Constraints: These are constraints on fit. Two tabs underneath titled &quot;matrix constraints&quot; and &quot;layer constraints&quot; allow the user to constrain these dimensions separately if needed. These are discussed in further detail below.

- Epsilon: This is a troubleshooting diagnostic which determines whether the fit will converge. The partial derivatives of the fit at each data point are calculated; the sign of these derivatives dictate the direction of the fit on the Chi squared surface.

- Matrix Constraints: This allows the user to set ranges for global variables and local variables in **the matrix**. An allowable epsilon value can be specified here. Individual variables can be &quot;held&quot; which will force the variable to keep the specified value on the &quot;Initial Guesses&quot; panel.

- Layer Constraints: This allows the user to set ranges for layer local variables. Layer column and layer row local variable ranges may also be set or held here. Epsilon values may also be set here.

- Split locals: Upon the completion of the fit, separate 1D waves are generated or updated for each local variable in addition to two 2D local waves for row and column variables. The content of these waves is not re-used in the analysis.

- Sigma: Upon completion, generate or update separate 1-D sigma waves for each local variable in addition to 2-D sigma waves for row and column variables
- Trim: When the number of local variables changes, this function checks for and deletes separate unused waves of locals.

- Minimal Reporting: This function limits the amount of history information reported in the command prompt upon the completion of the fit. This is useful for auto-cycling holds.

- No dialog: When checked, this prevents the fitting dialog from being displayed during analysis in the command prompt. This may speed up very simple models, but does not provide real-time updates on the progress and current values.

**Hold Override:**

This section allows the user to override specific holds for each dimension, global and local variables by checking the corresponding boxes.

- Chunk Size: To increase efficiency of the fit, &quot;chunks&quot; of data may be fitted at a time rather than the entirety of the dataset. This greatly decreases the amount of time required for the fit to converge.

**Autocycle Hold:**

This section allows the user to hold variables after a predetermined number of automatic cycles.

- cycles: Sets the number of automatic cycles to be performed using one of combinations detailed below.
- Global – Row – Col: Alternate analysis of one group at a time between Global, Row local and Column local variables.
- Global – Col :Alternate analysis of one group at a time between Global and Column local variables.
- Row – Col: Alternate analysis of one group at a time between  Row local and Column local variables.
- Global – Row: Alternate analysis of one group at a time between Global and Row local variables.

**Debugging:**

This section includes debugging tools for analyzing and troubleshooting errors in the command prompt.

- Log: Throughout iterations, parameters are saved in a fit log wave located in the G3F folder. Useful for troubleshooting singular and NAN errors but may slow down calculation and increase the size of the experiment.

- Save: This function saves the parameters of the fitlog.

- Keep: This function keeps the parameters in the fitlog.

**Global Fit:**

There are two important functions in this section: &quot;Do fit now!&quot; And &quot;simulate&quot;. These commands initiate the fitting process or simulate initial guesses with data for troubleshooting.

- Simulate: As above, this command simulates a trace given the function and the initial guesses. The &quot;use _ threads&quot; option limits the number of threads used by the fitting and process functions during calculations for time management purposes. This parameter cannot be larger than the number of actual logical threads.

- Do fit now!: This command initiates the fit. Following the completion of the fit, a data structure containing the fitted variables (both local and global) is generated for easy extraction, plotting and analysis.

**Feedback Positions :**

This section is to gives visual feedback of fitness of the calculated results to the reference data.

- Add/Remove (X): These buttons allow the operator to add or remove rows for real-time monitoring.
- Reset (X): Resets feedback marks. When selected, rows flagged for feedback will be cleared before filling from this list; otherwise current positions are added to those marked previously.
- Clb/Frame/Base1/Base2 (X): Values are in row calibration.
  -  Clb: central position
  -  [Optional: Frame - averaging frame for this row; Base 1 - reference point or baseline point 1;  Base 2 - baseline point 2]
- Add/Remove (Z): These buttons allow the operator to add or remove columns for real-time monitoring.
- Reset (Z): Resets feedback marks. When selected, columns flagged for feedback will be cleared before filling from this list; otherwise current positions are added to those marked previously
- Clb/Frame/Base1/Base2 (X): Values are in row calibration.
  -  Clb: central position
  -  [Optional: Frame - averaging frame for this column; Base 1 - reference point or baseline point 1;  Base 2 - baseline point 2]
- Layer: Select layer to be used in feedback plots
- Update: Update feedback plots now.

Additional feedback features are available from the main G3F menu. To access these:

   Analysis -> Global 3D Spectral Regression -> Feedback Overlay -> Col OR Row

Selecting Col or Row generates a plot with Col or Row overlays from feedback commands. This allows the user to monitor the column OR row feedback in real time.

**Desktop:**

This section allows for specific configurations to be saved to the desktop for easy loading.

- Save: The current fitting configuration is saved into a desktop wave. As stated above, this allows the user to save a specific configuration for future use.

- Restore: This function restores current configuration from a desktop wave.

### Fitting Functions

For the G3F model to function, specific syntax for fitting functions must be observed. There are three types of processes present in fitting functions: direct, process and local process. Direct fitting functions fit the experimental data given the user-defined model and input parameters. Process functions allow the user to predict a process that can later be used in fitting simulations given the user-defined model and input parameters. Local Process fitting functions calculate and fit local parameters. An example fitting function template is shown below. See the [API](https://github.com/dap-biospec/G3F/blob/master/Docs/G3F_API.md#template-functions) for further examples:

    ThreadSafe function YourFittingFunction_3D(wY, wCClb, wRClb,  wLClb , wGP, wCP2D, wRP2D,  wLP2D, wLCP2D, wLRP2D , row,  lay , dFrom, dTo) :FitFunc
    wave wY; // calculated Y wave
    wave wCClb; // column calibration
    wave wRClb; // row calibration
    wave wLClb; // layer calibration
    wave wGP; // global parameters wave
    wave wCP2D; // Col parameters wave
    wave wRP2D; // Row parameters wave
    wave wLP2D; // Layer-global parameters wave
    wave wLCP2D; // Layer-Col parameters wave
    wave wLRP2D; // Layer-Row parameters wave
    variable row; // current row
    variable lay; // current layer
    variable dFrom; // start offset in of data calculated here in the linear data wave
    variable dTo; // end offset in of data calculated here in the linear data wave


    variable i, iCP=0;
    for (i = dFrom; i<= dTo; i+=1, iCP+=1)
            // your code here
            wY[i] = … // your assignment
            … = wLP2D[lay][0] // access layer-global parameter 0
            … = wLCP2D[iCP][1][lay]  // access column local parameter 1 for current row
            … = wLRP2D[row][2][lay] // access row local parameter 2 for current row
    endfor

    end

**To access global variables:**

    variable Gw_a = wGP[0]
    variable n162_a = wGP[1]
    variable d182_a = wGP[2]
    variable d1618_a = wGP[3]

**To access local variables:**

     variable i, iCP=0;
	    for (i = dFrom; i<= dTo; i+=1, iCP+=1)
			    variable Tcal = wCClb[iCP];
       //user-defined model here...
     endfor
       

To implement local variables in the fitting function, an example procedure is shown below:

    ThreadSafe function RRShift_PeroxyOxyAbs_DAP_2D(wY, wCClb, wRClb, wGP, wCP2D, wRP2D, row, dFrom, dTo) :FitFunc

        wave wY; // calculated Y wave
        wave wCClb; // column calibraion, not used here
        wave wRClb; // wavelength calibration for shift position
        wave wGP; // global parameters wave, always starts with 0
        wave wCP2D; // Col paramters wave
        wave wRP2D; // Row paramters wave
        variable row; // current row
        variable dFrom; // start offset in of data calculated here in the linear data wave
        variable dTo; // end offset in of data calculated here in the linear data wave

The column parameters wave and row parameters wave will contain calculated local variables.

        variable i, iCP=0;
        for (i = dFrom; i<= dTo; i+=1, iCP+=1)
               variable wl = wRClb[i]
               wY[i]  = I_a * wCP2D[iCP][0] * wGP[wCClb[i]+4] * lorentzian(wl, n162_a, Gw_a)
               wY[i] += I_a * wCP2D[iCP][1] * wGP[wCClb[i]+4] * lorentzian(wl, n162_a - d182_a, Gw_a)
               wY[i] += I_a * wCP2D[iCP][2] * wGP[wCClb[i]+4] * lorentzian(wl, n162_a - d1618_a, Gw_a)
               wY[i] += 1.0* wCP2D[iCP][3] * wRP2D[row][0]
               wY[i] +=  wCP2D[iCP][4] + wCP2D[iCP][5]*wl + wCP2D[iCP][6]*wl^2 + wCP2D[iCP][7]*wl^3
         endfor

This procedure is a simple Lorentzian function for several isotopes with local variables ([iCp][1, 2, ..N]) describing the amplitude. The line: `wY[i]  = I_a * wCP2D[iCP][0] * wGP[wCClb[i]+4] * lorentzian(wl, n162_a, Gw_a)` describes the intensity ( `I_a`) modified by a local 2D column parameter ( `wCP2D[iCP][0]`). The following statement (`wGP[wCClb[i]+4]`) describes the column calibration parameter, followed by the lorenztian model with global parameters.

### Demo Experiment

To demonstrate the efficacy of G3F, an example NPSV experiment is provided with the G3F package.  [Demo Experiment](https://github.com/dap-biospec/G3F/tree/master/Demo) This demo models the extraction of the redox profile of myoglobin with different spectra taken at different applied potentials. In addition to different applied potentials, different compositions of 2 different electrochemical mediators (methylene green, thioninie acetate) are present in this data. In order to analyze the redox profiles of myoglobin only, the data must be deconvoluted. This analysis is demonstrated in three separate ways in order to familiarize the user with the flexibility of the G3F package in data analysis.

- [Example #1: Direct Fitting](#direct-fitting)
- [Example #2: Process Fitting](#process-fitting)
- [Example #3: Calculating Fits Using Local Variables](#calculating-fits-using-local-variables)

**Installing and Opening:**

Download G3F as described in the [Installation section](https://github.com/dap-biospec/G3F/blob/master/Docs/G3F_Manual.md#installation).

Download folder and save as a sibling folder of the G3F folder.

Open Demo_G3F.pxp

Experiment should load G3F code automatically. If G3F_main.ipf cannot be found, IgorPro will present a dialog that will allow the user to navigate to the G3F folder.

Demo experiment will also load the SpecEchem_4Spec_ForOxd_2.ipf procedure from the Demo folder with the example of user-supplied fitting function. 

Open the main control panel, and type in the values for the global variables:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_1_Demo.png)

The control panel should be set up for package testing.

### **Direct Fitting**

In this example, the data will be fitted directly using a fitting function and global variables for known parameters of analytes (ie: standard reduction potentials, number of electrons transferred). Individual spectra corresponding to each analyte and the Nernstian profile of myoglobin are calculated using local variables.

**Loading Raw Data and Fitting Function**

Go to the **Dataset** section on the control panel. Use the drop-down menu to select &quot;Oxidation.&quot; This loads the raw data matrix of oxidation data.

Go to the **Fit to function** drop-down menu. Select &quot;SpecEChem_4Spec_ForOxd_2D&quot;

**Running the Fit:**

The global parameters displayed on the control panel correspond to the redox potentials and electron transfer coefficients of each mediator.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_2_Demo.png)

As there are 2 mediators and myoglobin present, the data must be deconvoluted to isolate the spectrum and Nernstian profile of myoglobin. To do this, four local parameters are set (methylene green has two electron transfer steps), each corresponding to a spectrum specific to the analyte.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_3_Demo.png)

In this experiment, all baselines are set to zero (Col(Z) Locals). These are not used in this simulation.

Next, holds must be set on known parameters. The electron transfer coefficients correspond to the number of electrons transferred per mediator and are known.

Go to the **Matrix Constraints** button.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_4_Demo.png)

Hold all variables (K0 through K5; K8 through K10) by checking the **Hold** field. These correspond to the electron transfer coefficients and redox potentials of the mediators – all of which are known. The last two fields correspond to the electron transfer coefficient and redox potential of myoglobin. When finished, press **Done**.

Since the spectra of the known mediators and the anlyte will be calculated using row locals, it is necessary to provide guesses for these variables. To do this, open the data browser and select MediatorSpectra. Highlight the spectra as shown and copy it.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_18_Demo.PNG)

Paste this spectra into the Oxidation_RowLoc field.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_6_Demo.png)

Go to the **Options** tab. Check the box called **Epsilon**. This allows for the application of epsilon to matrix constraints. While not required, 2D or 3D global fits will **generally fail if epsilon is ignored**.

To perform the fit, click **Do Fit Now!** The program will run for a few minutes and generate the fitted data.

**Data Extraction and Plotting**

Now that the simulation has been performed, the separate spectra can be plotted and compared.

Go to the Data Browser field and select Oxidation\_RowLoc

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_5_Demo.png)

Clicking on this brings up a set of data:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_6_Demo.png)

This fitted data set corresponds to each individual spectrum of each mediator and myoglobin. To plot this data for easy comparison, go to

Windows ->New Graph…

Select Oxidation\_RowLoc in the left field, and Oxidation\_ROW\_FIT in the right field. Add the four mediator spectra as shown below.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_7_Demo.png)

Click **Do It.**  This should generate a plot of each individual mediator and myoglobin:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_8_Demo.png)

To extract the Nernstian profiles, go to the **Feedback positions** field on the main control panel. Alter the field as shown below:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_9_Demo.png)

Click **Do Fit!** This will generate Nernstian curve waves for both experimental data and fits. To plot this data, go to:

Windows -> New Graph…

Plot the waves Oxidation_PRef vs. EOx (Raw oxidation data), Oxidation_Fit_PFit vs. EOx_Fit (fitted oxidation data), Reduction_PRef vs. ERd (Raw reduction data), and Reduction_Fit_PFit vs. ERd_Fit (fitted reduction data).

The resulting graph should look like this:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_10_Demo.png)

The upper trace (colored blue in the figure) is the oxidation, and the lower trace (colored red) is the reduction of myoglobin.

By formatting the raw data as dots and keeping the fit solid, a graph should be generated like this:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_11_Demo.png)

From these traces, the redox potential of myoglobin can be determined. The multidimensional data has been successfully deconvoluted.

### **Process Fitting**

In this example, the data will be fitted using a process function and a fitting function. The populations of analytes will be calculated using only global variables at each potential value; these values will be stored in a process wave. This process wave will then be passed to a fitting function and individual spectra corresponding to each analyte and the Nernstian profile of myoglobin are then calculated. This approach is intended to save computational power by pre-processing data before fitting.

**Loading Raw Data and Fitting Function**

Go to the **Dataset** section on the control panel. Use the drop-down menu to select &quot;Oxidation.&quot; This loads the raw data matrix of oxidation data.

Go to the **Process function** drop-down menu. Select &quot;Process\_SpecEChem\_4Spec\_ForOxd\_2D&quot; This function will calculate the populations of analytes and store this in a process wave which will be passed to the fitting function to generate the same fits as those demonstrated in #1. **Ensure the 'Keep' field is checked!!** This ensures that the simulation wave will be saved; this can be used in troubleshooting, and this wave will be used in Example 3 to provide initial guesses for local variables!

Go to the **Fit to function** drop-down menu. Select &quot;ProcessFit\_4Spec\_ForOxd\_2D.&quot; This will calculate the intensities of the spectra of myoglobin and mediators.

**Running the Fit:**

The global parameters displayed on the control panel correspond to the redox potentials and electron transfer coefficients of each mediator.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_2_Demo.png)

As there are 2 mediators and myoglobin present, the data must be deconvoluted to isolate the spectrum and Nernstian profile of myoglobin. To do this, four local parameters are set (methylene green has two electron transfer steps), each corresponding to a spectrum specific to the analyte.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_3_Demo.png)

In this experiment, all baselines are set to zero (Col(Z) Locals). These are not used in this simulation.

Next, holds must be set on known parameters. The electron transfer coefficients correspond to the number of electrons transferred per mediator and are known.

Go to the **Matrix Constraints** button.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_4_Demo.png)

Hold all variables (K0 through K5; K8 through K10) by checking the **Hold** field. These correspond to the electron transfer coefficients and redox potentials of the mediators – all of which are known. The last two fields correspond to the electron transfer coefficient and redox potential of myoglobin. When finished, press **Done**.

Since the spectra of the known mediators and the anlyte will be calculated using row locals, it is necessary to provide guesses for these variables. To do this, open the data browser and select MediatorSpectra. Highlight the spectra as shown and copy it.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_18_Demo.PNG)

Paste this spectra into the Oxidation_RowLoc field.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_6_Demo.png)

Go to the **Options** tab. Check the box called **Epsilon**. This allows for the application of epsilon to matrix constraints. While not required, 2D or 3D global fits will **generally fail if epsilon is ignored**.

To perform the fit, click **Do Fit Now!** The program will run for a few minutes and generate the fitted data.

**Data Extraction and Plotting**

Now that the simulation has been performed, the separate spectra can be plotted and compared.

Go to the Data Browser field and select Oxidation\_RowLoc

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_5_Demo.png)

Clicking on this brings up a set of data:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_6_Demo.png)

This fitted data set corresponds to each individual spectrum of each mediator and myoglobin. To plot this data for easy comparison, go to

Windows ->New Graph…

Select Oxidation\_RowLoc in the left field, and Oxidation\_ROW\_FIT in the right field. Add the four mediator spectra as shown below.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_7_Demo.png)

Click **Do It.**  This should generate a plot of each individual mediator and myoglobin:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_8_Demo.png)

To extract the Nernstian profiles, go to the **Feedback positions** field on the main control panel. Alter the field as shown below:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_9_Demo.png)

Click **Do Fit!** This will generate Nernstian curve waves for both experimental data and fits. To plot this data, go to:

Windows -> New Graph…

Plot the waves Oxidation_PRef vs. EOx (Raw oxidation data), Oxidation_Fit_PFit vs. EOx_Fit (fitted oxidation data), Reduction_PRef vs. ERd (Raw reduction data), and Reduction_Fit_PFit vs. ERd_Fit (fitted reduction data).

The resulting graph should look like this:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_10_Demo.png)

The upper trace (colored blue in the figure) is the oxidation, and the lower trace (colored red) is the reduction of myoglobin.

By formatting the raw data as dots and keeping the fit solid, a graph should be generated like this:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_11_Demo.png)

From these traces, the redox potential of myoglobin can be determined. The multidimensional data has been successfully deconvoluted.

### **Calculating Fits using Local Variables**

In this example, the population of myoglobin will be calculated using local variables. All mediators in this calculation will be treated as known and will be modeled using global variables; the population of myoglobin will be calculated as a local variable. Individual spectra corresponding to each analyte and the Nernstian profile of myoglobin are calculated using local variables.

**Loading Raw Data and Fitting Function**

Go to the **Dataset** section on the control panel. Use the drop-down menu to select &quot;Oxidation.&quot; This loads the raw data matrix of oxidation data.

**If continuing from Example #2, set the Process function drop-down box to "none"!**

Go to the **Fit to function** drop-down menu. Select &quot;Loose\_SpecEChem\_4Spec\_ForOxd\_2D&quot; This function will calculate the populations of three of the analytes using global variables and fit the population of the fourth using local variables. In order for this to work, the setup for the fit on the control panel will need to be reconfigured.

**Setup**

Go to the **Global Variables** tab. Change the number on the dropdown menu (&quot; **Fitted**&quot;) to **6**. This is the number of global variables we will fit – in this case, the standard reduction potential and number of electrons transferred- of the mediators in the mixture. Click **Set**. A dialogue box will then appear:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_12_Demo.PNG)

Click **No**. This will adjust the number of fitted global variables without requiring the user to input guesses.

Go to the **Local Variables** tab. Go to the **Col(Z) Locals** field. Change the number on the dropdown menu to **7**. This is a necessary adjustment which will allow for the calculation of the population of myoglobin using local variables.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_13_Demo.PNG)

Go to the **Options** tab. Check the box called **Epsilon**. This allows for the application of epsilon to matrix constraints. While not required, 2D or 3D global fits will **generally fail if epsilon is ignored**.

Click the **matrix constraints** button. **Uncheck all global variables**

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_14_Demo.PNG)

Click **Done**.

Since three of the four analytes are known, their global variables can be treated as known quantities and must be held constant. To do this, go to the **Hold override** tab and check the **Global** box – this will hold all global variables constant.

Go to the **Hold override** tab. Uncheck **Local COL**

At the end of setup, the control panel should look like this:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_15_Demo.PNG)

Since G3F calculates local variables by treating data waves as vectors, reasonable guesses for locals must be given for the fit to work. To do this, first press the **Simulate** button. A dialog box will appear:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_22_Demo.PNG)

Click **No**.

Open the **Data browser** and open the **Oxidation\_sim** wave from Example #2. If the **Keep** field was checked during Example 2, this wave will contain population calculations for analytes. If this wave is not present, re-run Example 2 with the **Keep** field in the **Method** tab checked.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_16_Demo.PNG)

Copy the fourth column of this wave.  Next, open **Oxidation\_ColLoc** and scroll to the 7th column. Paste the data from **Oxidation\_sim** here.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_17_Demo.PNG)

Now the fit can be run as in Examples 1 and 2.

**Running the Fit:**

The global parameters displayed on the control panel correspond to the redox potentials and electron transfer coefficients of each mediator.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_21_Demo.PNG)

As there are 2 mediators and myoglobin present, the data must be deconvoluted to isolate the spectrum and Nernstian profile of myoglobin. To do this, four local parameters are set (methylene green has two electron transfer steps), each corresponding to a spectrum specific to the analyte.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_20_Demo.PNG)

Go to the **Matrix Constraints** button.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_19_Demo.PNG)

Hold the mediator spectra row locals (K6 through K8) by checking the **Hold** field. When finished, press **Done**.

Since the spectra of the known mediators and the analyte will be calculated using row locals, it is necessary to provide guesses for these variables. To do this, open the data browser and select MediatorSpectra. Highlight the spectra as shown and copy it.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_18_Demo.PNG)

Paste this spectra into the Oxidation_RowLoc field.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_6_Demo.png)

To perform the fit, click **Do Fit Now!** The program will run for a few minutes and generate the fitted data.

**Data Extraction and Plotting**

Now that the simulation has been performed, the separate spectra can be plotted and compared.

Go to the Data Browser field and select Oxidation\_RowLoc

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_5_Demo.png)

Clicking on this brings up a set of data:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_6_Demo.png)

This fitted data set corresponds to each individual spectrum of each mediator and myoglobin. To plot this data for easy comparison, go to

Windows ->New Graph…

Select Oxidation\_RowLoc in the left field, and Oxidation\_ROW\_FIT in the right field. Add the four mediator spectra as shown below.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_7_Demo.png)

Click **Do It.**  This should generate a plot of each individual mediator and myoglobin:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_8_Demo.png)

To extract the Nernstian profiles, go to the **Feedback positions** field on the main control panel. Alter the field as shown below:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_9_Demo.png)

Click **Do Fit!** This will generate Nernstian curve waves for both experimental data and fits. To plot this data, go to:

Windows -> New Graph…

Plot the waves Oxidation_PRef vs. EOx (Raw oxidation data), Oxidation_Fit_PFit vs. EOx_Fit (fitted oxidation data), Reduction_PRef vs. ERd (Raw reduction data), and Reduction_Fit_PFit vs. ERd_Fit (fitted reduction data).

The resulting graph should look like this:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_10_Demo.png)

The upper trace (colored blue in the figure) is the oxidation, and the lower trace (colored red) is the reduction of myoglobin.

By formatting the raw data as dots and keeping the fit solid, a graph should be generated like this:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_11_Demo.png)

From these traces, the redox potential of myoglobin can be determined. The multidimensional data has been successfully deconvoluted as in Example 1 and Example 2.

