### Demo Experiment

To demonstrate the efficacy of G3F, an example NPSV experiment is provided with the G3F package.  [Demo Experiment](https://github.com/dap-biospec/G3F/tree/master/Demo)This demo models the extraction of the redox profile of myoglobin with different spectra taken at different applied potentials. In addition to different applied potentials, different compositions of 2 different electrochemical mediators (methylene green, thioninie acetate) are present in this data. In order to analyze the redox profiles of myoglobin alone, the data must be deconvoluted.

**Installing and Opening:**

Download G3F as described in the Installation section.

Download folder and save as a sibling folder of the G3F folder.

Open Demo\_G3F.pxp

Experiment should load G3F code automatically. If G3F\_main.ipf cannot be found, IgorPro will present a dialog that will allow to navigate to the G3F folder.

Demo experiment will also load the SpecEchem\_4Spec\_ForOxd\_2.ipf procedure from the Demo folder with the example of user-supplied fitting function. 

The main control panel should look like this:

![alt text](https://github.com/dap-biospec/G3F/blob/master/DemoPictures/Pic_1_Demo.png)

The control panel should be set up for package testing.

**Loading Raw Data and Fitting Function**

Go to the **Dataset** section on the control panel. Use the drop-down menu to select &quot;Oxidation.&quot; This loads the raw data matrix of oxidation data.

Go to the **Fit to function** drop-down menu. Select &quot;SpecEChem_4Spec_ForOxd_2D&quot;

**Running the Fit:**

The global parameters displayed on the control panel correspond to the redox potentials and electron transfer coefficients of each mediator.

![alt text](https://github.com/dap-biospec/G3F/blob/master/DemoPictures/Pic_2_Demo.png)

As there are 2 mediators and myoglobin present, the data must be deconvoluted to isolate the spectrum and Nernstian profile of myoglobin. To do this, four local parameters are set (methylene green has two electron transfer steps), each corresponding to a spectrum specific to the analyte.

![alt text](https://github.com/dap-biospec/G3F/blob/master/DemoPictures/Pic_3_Demo.png)

In this experiment, all baselines are set to zero (Col(Z) Locals). These are not used in this simulation.

Next, holds must be set on known parameters. The electron transfer coefficients correspond to the number of electrons transferred per mediator and are known.

Go to the **Matrix Constraints** button.

![alt text](https://github.com/dap-biospec/G3F/blob/master/DemoPictures/Pic_4_Demo.png)

Hold all variables (K0 through K5) by checking the **Hold** field. These correspond to the electron transfer coefficients and redox potentials of the mediators – all of which are known. The last two fields correspond to the electron transfer coefficient and redox potential of myoglobin. When finished, press **Done**.

To perform the fit, click **Do Fit Now!** The program will run for a few minutes and generate the fitted data.

**Data Extraction and Plotting**

Now that the simulation has been performed, the separate spectra can be plotted and compared.

Go to the Data Browser field and select Oxidation\_RowLoc

![alt text](https://github.com/dap-biospec/G3F/blob/master/DemoPictures/Pic_5_Demo.png)

Clicking on this brings up a set of data:

![alt text](https://github.com/dap-biospec/G3F/blob/master/DemoPictures/Pic_6_Demo.png)

This fitted data set corresponds to each individual spectrum of each mediator and myoglobin. To plot this data for easy comparison, go to

Windows ->New Graph…

Select Oxidation\_RowLocal in the left field, and Oxidation\_ROW\_FIT in the right field. Add the four mediator spectra as shown below.

![alt text](https://github.com/dap-biospec/G3F/blob/master/DemoPictures/Pic_7_Demo.png)

Click **Do It.**  This should generate a plot of each individual mediator and myoglobin:

![alt text](https://github.com/dap-biospec/G3F/blob/master/DemoPictures/Pic_8_Demo.png)

To extract the Nernstian profiles, go to the **Feedback positions** field on the main control panel. Alter the field as shown below:

![alt text](https://github.com/dap-biospec/G3F/blob/master/DemoPictures/Pic_9_Demo.png)

Click **Do Fit!** This will generate Nernstian curve waves for both experimental data and fits. To plot this data, go to:

Windows -> New Graph…

Plot the waves Oxidation_PRef vs. EOx (Raw oxidation data), Oxidation_Fit_PFit vs. EOx_Fit (fitted oxidation data), Reduction_PRef vs. ERd (Raw reduction data), and Reduction_Fit_PFit vs. ERd_Fit (fitted reduction data).

The resulting graph should look like this:

![alt text](https://github.com/dap-biospec/G3F/blob/master/DemoPictures/Pic_10_Demo.png)

The upper trace (colored blue in the figure) is the oxidation, and the lower trace (colored red) is the reduction of myoglobin.

By formatting the raw data as dots and keeping the fit solid, a graph should be generated like this:

![alt text](https://github.com/dap-biospec/G3F/blob/master/DemoPictures/Pic_11_Demo.png)

From these traces, the redox potential of myoglobin can be determined. The multidimensional data has been successfully deconvoluted.
