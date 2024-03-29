# G3F
**Note:** This software requires IgorPro v. 8.0 to run.

The G3F is a **Global, Multidimensional Spectral Regression Analysis** package for IgorPro. It allows to apply flexible combinations of global parameters and dimensionally local (spectral) parameters to 2- and 3-dimensional data matrices.

**LOADING AND OPENING G3F IN IGOR PRO:**

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

Download all files from [G3F folder](https://github.com/dap-biospec/G3F/tree/master/G3F) and save in one local folder.

From the top menu IgorPro:<br/>
File -> Open File -> Procedure…

Navigate to and select the G3F\_Main.ipf file to load. Complile G3F\_Main.ipf - this will load all dependnet procedure file slisted above.

**Opening main G3F control panel:**

From the top menu IgorPro:<br/>
Analysis -> Global 3D Spectral Regression -> Control Panel


For further details on G3F structure and function, please see:<br/>
[G3F API](https://github.com/dap-biospec/G3F/blob/master/Docs/G3F_API.md)<br/>
[G3F Manual](https://github.com/dap-biospec/G3F/blob/master/Docs/G3F_Manual.md)

A [Demo Experiment](https://github.com/dap-biospec/G3F/tree/master/Demo) is included with this package. The tutorial is in the [Demo Experiment](https://github.com/dap-biospec/G3F/blob/master/Docs/G3F_Manual.md#demo-experiment) section of the manual.

**Performance testing:**
A performance test is included with this package in the [Demo](https://github.com/dap-biospec/G3F/tree/master/Demo) folder. This is intended to allow users to test user-defined functions against control data.

## Community Guidelines
Bug reports and requests for improvements, and new features are welcomed! Please feel free to make a post to [Biospec Github Issue Tracker](https://github.com/dap-biospec/G3F/issues) or contact Denis A. Proshlyakov, [dapro@chemistry.msu.edu](mailto:dapro@chemistry.msu.edu)
