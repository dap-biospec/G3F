### Demo Experiment

To demonstrate the efficacy of G3F, an example NPSV experiment is provided with the G3F package.  [Demo Experiment](https://github.com/dap-biospec/G3F/tree/master/Demo) This demo models the extraction of the redox profile of myoglobin with different spectra taken at different applied potentials. In addition to different applied potentials, different compositions of 2 different electrochemical mediators (methylene green, thioninie acetate) are present in this data. In order to analyze the redox profiles of myoglobin alone, the data must be deconvoluted. This analysis is demonstrated in three separate ways in order to familiarize the user with the flexibility of the G3F package.

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

Hold all variables (K0 through K5) by checking the **Hold** field. These correspond to the electron transfer coefficients and redox potentials of the mediators – all of which are known. The last two fields correspond to the electron transfer coefficient and redox potential of myoglobin. When finished, press **Done**.

To perform the fit, click **Do Fit Now!** The program will run for a few minutes and generate the fitted data.

**Data Extraction and Plotting**

Now that the simulation has been performed, the separate spectra can be plotted and compared.

Go to the Data Browser field and select Oxidation\_RowLoc

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_5_Demo.png)

Clicking on this brings up a set of data:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_6_Demo.png)

This fitted data set corresponds to each individual spectrum of each mediator and myoglobin. To plot this data for easy comparison, go to

Windows ->New Graph…

Select Oxidation\_RowLocal in the left field, and Oxidation\_ROW\_FIT in the right field. Add the four mediator spectra as shown below.

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

Hold all variables (K0 through K5) by checking the **Hold** field. These correspond to the electron transfer coefficients and redox potentials of the mediators – all of which are known. The last two fields correspond to the electron transfer coefficient and redox potential of myoglobin. When finished, press **Done**.

To perform the fit, click **Do Fit Now!** The program will run for a few minutes and generate the fitted data.

**Data Extraction and Plotting**

Now that the simulation has been performed, the separate spectra can be plotted and compared.

Go to the Data Browser field and select Oxidation\_RowLoc

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_5_Demo.png)

Clicking on this brings up a set of data:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_6_Demo.png)

This fitted data set corresponds to each individual spectrum of each mediator and myoglobin. The user is encouraged to compare these results to those of the direct fitting process as a performance check. If the fit was successful, these data sets should be the same.

To plot this data as described in the first example, go to

Windows ->New Graph…

Select Oxidation\_RowLocal in the left field, and Oxidation\_ROW\_FIT in the right field. Add the four mediator spectra as shown below.

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

From these traces, the redox potential of myoglobin can be determined. The multidimensional data has been successfully deconvoluted and gives the same results as in the first example.


### **Calculating Fits using Local Variables**

In this example, the population of myoglobin will be calculated using local variables. All mediators in this calculation will be treated as known and will be modeled using global variables; the population of myoglobin will be calculated as a local variable. Individual spectra corresponding to each analyte and the Nernstian profile of myoglobin are calculated using local variables.

**Loading Raw Data and Fitting Function**

Go to the **Dataset** section on the control panel. Use the drop-down menu to select &quot;Oxidation.&quot; This loads the raw data matrix of oxidation data.

Go to the **Fit to function** drop-down menu. Select &quot;Loose\_SpecEChem\_4Spec\_ForOxd\_2D&quot; This function will calculate the populations of three of the analytes using global variables and fit the population of the fourth using local variables. In order for this to work, the setup for the fit on the control panel will need to be reconfigured.

**Setup**

Go to the **Global Variables** tab. Change the number on the dropdown menu (&quot; **Fitted**&quot;) to **6**. This is the number of global variables we will fit – in this case, the standard reduction potential and number of electrons transferred- of the mediators in the mixture. Click **Set**. A dialogue box will then appear:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_12_Demo.PNG)

Click **No**. This will adjust the number of fitted global variables without requiring the user to input guesses.

Go to the **Local Variables** tab. Go to the **Col(Z) Locals** field. Change the number on the dropdown menu to **7**. This is a necessary adjustment which will allow for the calculation of the population of myoglobin using local variables.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_13_Demo.PNG)

Go to the **Options** tab. Check the box called **Epsilon**. This allows for the application of epsilon to matrix constraints. While not required, 2D or 3D global fits will **generally fail if epsilon is ignored**.

Click the **matrix constraints** button. Add in epsilon values as shown.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_14_Demo.PNG)

Click **Done**.

Since three of the four analytes are known, their global variables can be treated as known quantities and must be held constant. To do this, go to the **Hold override** tab and check the **Global** box – this will hold all global variables constant.

At the end of setup, the control panel should look like this:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_15_Demo.PNG)

Since G3F calculates local variables by treating data waves as vectors, reasonable guesses for locals must be given for the fit to work. To do this, first open the **Data browser** and open the **Oxidation\_sim** wave from Example #2. If the **Keep** field was checked during Example 2, this wave will contain population calculations for analytes. If this wave is not present, re-run Example 2 with the **Keep** field in the **Method** tab checked.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_16_Demo.PNG)

Copy the fourth column of this wave.  Next, open **Oxidation\_ColLoc** and scroll to the 7th column. Paste the data from **Oxidation\_sim** here.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_17_Demo.PNG)

Now the fit can be run as in Examples 1 and 2.

**Running the Fit:**

The global parameters displayed on the control panel correspond to the redox potentials and electron transfer coefficients of each mediator.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_2_Demo.png)

As there are 2 mediators and myoglobin present, the data must be deconvoluted to isolate the spectrum and Nernstian profile of myoglobin. To do this, four local parameters are set (methylene green has two electron transfer steps), each corresponding to a spectrum specific to the analyte.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_3_Demo.png)

In this experiment, all baselines are set to zero (Col(Z) Locals). These are not used in this simulation.

Next, holds must be set on known parameters. The electron transfer coefficients correspond to the number of electrons transferred per mediator and are known.

Go to the **Matrix Constraints** button.

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_4_Demo.png)

Hold all variables (K0 through K5) by checking the **Hold** field. These correspond to the electron transfer coefficients and redox potentials of the mediators – all of which are known. The last two fields correspond to the electron transfer coefficient and redox potential of myoglobin. When finished, press **Done**.

To perform the fit, click **Do Fit Now!** The program will run for a few minutes and generate the fitted data.

**Data Extraction and Plotting**

Now that the simulation has been performed, the separate spectra can be plotted and compared.

Go to the Data Browser field and select Oxidation\_RowLoc

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_5_Demo.png)

Clicking on this brings up a set of data:

![alt text](https://github.com/dap-biospec/G3F/blob/master/Demo/DemoPictures/Pic_6_Demo.png)

This fitted data set corresponds to each individual spectrum of each mediator and myoglobin. To plot this data for easy comparison, go to

Windows ->New Graph…

Select Oxidation\_RowLocal in the left field, and Oxidation\_ROW\_FIT in the right field. Add the four mediator spectra as shown below.

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