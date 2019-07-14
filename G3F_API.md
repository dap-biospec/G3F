
### **G3F API**

**Introduction:** Most of G3F functionality is accomplished via G3F Control Panel GUI interface with the exception of user-supplied calculation functions. G3F supports multiple types of calculations, that may require the user two supply a calculation function that will comply with a particular template format. Such templates are listed at the beginning of this API document. Further explanation and examples can be found in the G3F Manual. G3F is thread-aware and requires the threadsafe keyword for user-supplied functions to be recognized. Template functions cannot be used directly. For development purposes, create a clone of the function without TPL suffix.

This API covers two sections: user-supplied function templates, and internal functions used by the G3F module up to the execution of the user-supplied function. For the explanation of standard Igor keywords, please consult Igor Pro manual. For further explanation of the G3F package, consult the [G3F Manual](https://github.com/dap-biospec/G3F/blob/master/G3F_Manual.md)

### **TABLE OF CONTENTS:**

[I:User-Supplied Functions](#user-supplied-functions)

 - [I:A: Template Functions](#template-functions)
   - [I:A:i: Direct](#direct-fitting-function-templates)
   - [I:A:ii: Process](#process-fitting-function-templates)
   - [I:A:iii: Local Process](#local-process-fitting-function-templates)
   - [I:A:iiii: Local Guessing](#local-guessing-function-templates)

[II: Internal Functions](#internal-functions)
 - [II:A: Common Data Structures](#common-data-structures)
 - [II:B: Proxy Functions](#proxy-functions)
   - [II:B:i: Direct](#direct-proxy-functions)
   - [II:B:ii: Process](#process-proxy-functions)
   - [II:B:iii: Local Process](#local-process-proxy-functions)
 - [II:C: Service Functions](#service-functions)
 - [II:D: Misc Functions](#misc-functions)

### User Supplied Functions  
These are all functions that must be supplied by the user in order to perfom calculations for quantitative models. Templates are provided for easy integration into models.

#### Template Functions  
These functions are all templates that MUST be modified by a user to perform calculations per quantitative model. These functions fit data, calculate simulations of the user-defined model, and calculate local parameters. For more information, see  [Fitting Functions](https://github.com/dap-biospec/G3F/blob/master/G3F_Manual.md#fitting-functions) 

#### Direct Fitting Function Templates  
Template direct functions for handling the fitting of data. Direct functions perform direct fitting on experimental data sets.

- `ThreadSafe Function G3F_Direct_1D_TPL(wY, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo)`
  - **Description:** 1D direct calculation function template. Calculated results should be stored in the wY parameter wave.
  - **Parameters:**
  
       `wave wY` : calculated Y wave  
       `wave wCClb` : Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP`: Row parameters wave  
       `variable RPO`: offset in wRP to the first Row Parameter  
       `wave wCP`: Col parameters wave  
       `variable CPO`: offset in wCP to the first Col Parameter  
       `variable dFrom`: start offset in of data calculated here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  

  - **Return Value:** None
  <br/><br/>
  
- `ThreadSafe Function G3F_Direct_Ep_1D_TPL(wY, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo, wED)`
  - **Description:** 1D direct calculation function template with extra data. Calculated results should be stored in the wY parameter wave.
  - **Parameters:**

       `wave wY`: calculated Y wave  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wGP:` global parameters wave, always starts with 0  
       `wave wRP:` Row parameters wave  
       `variable RPO:` offset in wRP to the first Row Parameter  
       `wave wCP:` Col parameters wave  
       `variable CPO:` offset in wCP to the first Col Parameter  
       `variable dFrom:` start offset in of data calculated here in the linear data wave  
       `variable dTo:` end offset in of data calculated here in the linear data wave  
       `wave wED:` extra data wave  

  - **Return Value:** None
  <br/><br/>


- `ThreadSafe Function G3F_Direct_EpXZp_1D_TPL(wY, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo, wED, wXZp)`
  - **Description:** 1D template function for direct calculations with extra data and a parametric X-Y wave. Calculated results should be stored in the wY parameter wave.
  - **Parameters:**

       `wave wY`: calculated Y wave  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP`: Row parameters wave  
       `variable RPO`: offset in wRP to the first Row Parameter  
       `wave wCP`: Col parameters wave  
       `variable CPO`: offset in wCP to the first Col Parameter  
       `variable dFrom`: start offset in of data calculated here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  
       `wave wED`: extra data wave  
       `wave wXZp`: X-Y parametric wave  

  - **Return Value:** None
     <br/><br/>
  
  

- `ThreadSafe Function G3F_Direct_2D_TPL(wY, wCClb, wRClb, wGP, wCP2D, wRP2D, row, dFrom, dTo)`
  - **Description:** 2D template function for direct calculation using  Col and Row local params. . Calculated results should be stored in the wY parameter wave.
  
  - **Parameters:**

       `wave wY`: calculated Y wave  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP2D`: a 2D Row parameters wave row - fitted point, col - param #  
       `wave wCP2D`: a 2D Row parameters wave column - fitted point, col - param #  
       `variable row`: current row  
       `variable dFrom`: start offset in of data calculated here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_Direct_Ep_2D_TPL(wY, wCClb, wRClb, wGP, wCP, wRP, row, dFrom, dTo, wED)`
  - **Description:** 2D template function for direct calculation using  Col and Row local params. . Calculated results should be stored in the wY parameter wave.
  
  - **Parameters:**

       `wave wY`: calculated Y wave  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP`: Row parameters wave  
       `wave wCP`: Col parameters wave  
       `variable row`: current row  
       `variable dFrom`: start offset in of data calculated here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  
       `wave wED`: extra data wave  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_Direct_EpXZp_2D_TPL(wY, wCClb, wRClb, wGP, wCP, wRP, row, dFrom, dTo, wED, wXZp)`
  - **Description:** 2D template function for direct calculation using  Col and Row local params with X-Z parametric waves. . Calculated results should be stored in the wY parameter wave.
  
  - **Parameters:**

       `wave wY`: calculated Y wave  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP`: Row parameters wave  
       `wave wCP`: Col parameters wave  
       `variable row`: current row  
       `variable dFrom`: start offset in of data calculated here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  
       `wave wED`: extra data wave  
       `wave wXZp`: X-Y parametric  wave  

  - **Return Value:** None
     <br/><br/>


- `ThreadSafe Function G3F_Direct_3D_TPL(wY, wCClb, wRClb, wLClb, wGP, wCP2D, wRP2D, wLP2D, wLCP2D, wLRP2D, row, lay, dFrom, dTo)`
  - **Description:** 3D template function for direct calculation using 2D Col and Row local params. Calculated results should be stored in the wY parameter wave.
  
  - **Parameters:**

       `wave wY`: calculated Y wave  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wLClb`: Layer calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP2D`: a 2D Row parameters wave row - fitted point, col - param #  
       `wave wCP2D`: a 2D Row parameters wave column - fitted point, col - param #  
       `wave wLP2D`: s 2D Layer parameters wave layer – fitted point, col – param #  
       `wave wLRP2D`: a 2D Layer parameters wave row – fitted point, col – param #  
       `wave wLCP2D`: a 2D Layer parameters wave column – fitted point, col – param #  
       `variable row`: current row  
       `variable lay`: current layer  
       `variable dFrom`: start offset in of data calculated here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_Direct_Ep_3D_TPL(wY, wCClb, wRClb, wLClb, wGP, wCP2D, wRP2D, wLP2D, wLCP2D, wLRP2D, row, lay, dFrom, dTo, wEP)`
  - **Description:** Template function for direct calculation using 2D Col and Row local params with extra data wave. Calculated results should be stored in the wY parameter wave.
  - **Parameters:**

       `wave wY`: calculated Y wave  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wLClb`: Layer calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP2D`: a 2D Row parameters wave row - fitted point, col - param #  
       `wave wCP2D`: a 2D Row parameters wave column - fitted point, col - param #  
       `wave wLP2D`: a 2D Layer parameters wave layer – fitted point, col – param #  
       `wave wLRP2D`: a 2D Layer parameters wave row – fitted point, col – param #  
       `wave wLCP2D`: a 2D Layer parameters wave column – fitted point, col – param #  
       `variable row`: current row  
       `variable lay`: current layer  
       `variable dFrom`: start offset in of data calculated here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave
       `wave wEP`: extra global params wave  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_Direct_EpXZp_3D_TPL(wY, wCClb, wRClb, wLClb, wGP, wCP2D, wRP2D, wLP2D, wLCP2D, wLRP2D, row, lay, dFrom, dTo, wEP, wXZp)`
  - **Description:** 3D template function for direct calculation using 2D Col and Row local params w/extra data and X &; Z parametric waves. Calculated results should be stored in the wY parameter wave.
  - **Parameters:**

       `wave wY`: calculated Y wave  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wLClb`: Layer calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP2D`: a 2D Row parameters wave row - fitted point, col - param #  
       `wave wCP2D`: a 2D Row parameters wave column - fitted point, col - param #  
       `wave wLP2D`: a 2D Layer parameters wave layer – fitted point, col – param #  
       `wave wLRP2D`: a 2D Layer parameters wave row – fitted point, col – param #  
       `wave wLCP2D`: a 2D Layer parameters wave column – fitted point, col – param #  
       `variable row`: current row  
       `variable lay`: current layer  
       `variable dFrom`: start offset in of data calculated here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  
       `wave wEP`: extra global params wave  
       `wave wXZP`: extra X:Z parameter wave  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_Direct_1D_Str_TPL(c, v, row, lay, dFrom, dTo)`
  - **Description:** Template function for direct calculation using linear local params passed in a structure
  - **Parameters:**

       `STRUCT G3F_Comm_Param_Set &c`: command parameter structure  
       `STRUCT G3F_Linear_Var_3D_Set &v`: linear variable structure  
       `variable row`: current row  
       `variable lay`: current layer  
       `variable dFrom`: start offset in of data calculated here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_Direct_3D_Str_TPL(c, f, row, lay, dFrom, dTo)`
  - **Description:** Template function for direct calculation using 2D local params passed in a structure
  - **Parameters:**

       `STRUCT G3F_Comm_Param_Set &c`: command parameter structure  
       `STRUCT G3F_Folded_Var_3D_Set &f`: linear variable structure  
       `variable row`: current row  
       `variable lay`: current layer  
       `variable dFrom`: start offset in of data calculated here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  

  - **Return Value:** None
     <br/><br/>
  

#### Process Fitting Function Templates  
Template process functions for calculating simulations. Process functions allow the user to predict a process that can later be used in fitting simulations given the user-defined model and input parameters.

- `ThreadSafe Function G3F_Process_TPL(pw, yw, xw)`
  - **Description:** Template process function for uni-threaded simulations
  - **Parameters:**

       `Wave pw`: global parameters wave  
       `Wave yw`: output calculated process wave  
       `Wave xw`: process calibration wave (i.e. time)  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_Process_Ep_TPL(pw, yw, xw, wEP)`
  - **Description:** Template process function for uni-threaded simulations with an extra parameter wave.
  - **Parameters:**

       `Wave pw`: global parameters wave  
       `Wave yw`: output calculated process wave  
       `Wave xw`: process calibration wave (i.e. time)  
       `Wave wEP`: extra parameters wave  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_Process_EpXZp_TPL(pw, yw, xw, wEP, wXZp)`
  - **Description:** Template process function for uni-threaded simulations with an extra parameter wave and X and Z parametric waves.
  - **Parameters:**

       `Wave pw`: global parameters wave  
       `Wave yw`: output calculated process wave  
       `Wave xw`: process calibration wave (i.e. time)  
       `Wave wEP`: extra parameters wave  
       `wave wXZp`: These are input parameters for the X-Z parametric wave.  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_Process_MT_TPL(pw, yw, xw, dFrom, dTo)`
  - **Description:** Template function for multi-threaded process calculations.
  - **Parameters:**

       `Wave pw`: global parameters wave  
       `Wave yw`: output calculated process wave  
       `Wave xw`: process calibration wave (i.e. time)  
       `variable dFrom, dTo`: start offset in  all data waves  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_Process_Ep_MT_TPL(pw, yw, xw, dFrom, dTo, wEP)`
  - **Description:** Template function for multi-threaded process calculations with extra parameter wave.
  - **Parameters:**

       `Wave pw`: global parameters wave  
       `Wave yw`: output calculated process wave  
       `Wave xw`: process calibration wave (i.e. time)  
       `Wave wEP`: extra parameters wave variable  
       `dFrom, dTo`: start offset in  all data waves  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_Process_EpXZp_MT_TPL(pw, yw, xw, dFrom, dTo, wEP, wXZp)`
  - **Description:** Template function for multi-threaded process calculations with extra parameter wave and X-Z parametric wave.

  - **Parameters:**

       `Wave pw`: global parameters wave  
       `Wave yw`: output calculated process wave  
       `Wave xw`: process calibration wave (i.e. time)wave  
       `wXZp`: X-Z parametric wave  
       `variable dFrom, dTo`: start offset in  all data waves  

  - **Return Value:** None
     <br/><br/>
  

#### Local Process Fitting Function Templates  
Template local process functions for calculating the fitting of local parameters from simulations and experimental data.

- `ThreadSafe Function G3F_ProcLocal_1D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo)`
  - **Description:** Template function for 1D locals calculation process fitting. Calculated results should be stored in the wY parameter wave.
  
  - **Parameters:**
  
       `wave wY`: calculated Y wave  
       `Wave wSim`: simulated process  
       `wave wCClb`: column calibration in original data, usually time or concentration  
       `wave wRClb`: row calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP`: row parameters wave  
       `variable RPO`: offset in wRP to the first row parameter  
       `wave wCP`: column parameters wave  
       `variable CPO`: offset in wCP to first column parameter  
       `variable dFrom`: start offset here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_ProcLocal_Ep_1D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo, wEP)`

  - **Description:** Template function for 1D locals calculation process fitting with extra parameters wave. Calculated results should be stored in the wY parameter wave.

  - **Parameters:**

       `wave wY`: calculated Y wave  
       `Wave wSim`: simulated process  
       `wave wCClb`: column calibration in original data, usually time or concentration  
       `wave wRClb`: row calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP`: row parameters wave  
       `variable RPO`: offset in wRP to the first row parameter  
       `wave wCP`: column parameters wave  
       `variable CPO`: offset in wCP to first column parameter  
       `variable dFrom`: start offset here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  
       `wave wEP`: extra parameters wave  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_ProcLocal_EpXZp_1D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP, CPO, wRP, RPO,  dFrom, dTo, wEP, wXZp)`
  - **Description:** Template function for 1D locals calculation process fitting with extra parameters wave and x-y parametric wave. Calculated results should be stored in the wY parameter wave.
  - **Parameters:**

       `wave wY`: calculated Y wave  
       `Wave wSim`: simulated process  
       `wave wCClb`: column calibration in original data, usually time or concentration  
       `wave wRClb`: row calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP`: row parameters wave  
       `variable RPO`: offset in wRP to the first row parameter  
       `wave wCP`: column parameters wave  
       `variable CPO`: offset in wCP to first column parameter  
       `variable dFrom`: start offset here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  
       `wave wEP`: extra parameters wave  
       `wave wXZp`: X-Y parametric wave  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_ProcLocal_2D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP2D, wRP2D, row, dFrom, dTo)`
  - **Description:** Template function for 2D locals calculation process.Calculated results should be stored in the wY parameter wave.
  - **Parameters:**

       `wave wY`: calculated Y wave  
       `wave wSim`: Simulated process  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP2D`: a 2D Row parameters wave row - fitted point, col - param #  
       `wave wCP2D`: a 2D Row parameters wave column - fitted point, col - param #  
       `variable row`: current row  
       `variable dFrom`: start offset in of data calculated here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_ProcLocal_Ep_2D_TPL(wY, wSim, wCClb,  wRClb, wGP, wCP2D, wRP2D, row, dFrom, dTo, wEP)`
  - **Description:** Template function for 2D locals calculation process with extra parameters wave. Calculated results should be stored in the wY parameter wave.

  - **Parameters:**

       `wave wY`: calculated Y wave  
       `wave wSim`: Simulated process  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP2D`: a 2D Row parameters wave row - fitted point, col - param #  
       `wave wCP2D`: a 2D Row parameters wave column - fitted point, col - param #  
       `variable row`: current row  
       `variable dFrom`: start offset in of data calculated here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  
       `wave EP`: extra parameters wave  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_ProcLocal_EpXZp_2D_TPL(wY, wSim, wCClb, wRClb, wGP, wCP2D, wRP2D, row, dFrom, dTo, wEP, wXZp)`
  - **Description:** Template function for 2D locals calculation process with extra parameters wave and X-Y parameter wave. Calculated results should be stored in the wY parameter wave.

  - **Parameters:**

       `wave wY`: calculated Y wave  
       `wave wSim`: Simulated process  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP2D`: a 2D Row parameters wave row - fitted point, col - param #  
       `wave wCP2D`: a 2D Row parameters wave column - fitted point, col - param #  
       `variable row`: current row  
       `variable dFrom`: start offset in of data calculated here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  
       `wave EP`: extra parameters wave  
       `wave wXZp`: X-Y parametric wave  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_ProcLocal_3D_TPL(wY, wSim, wCClb,  wRClb, wLClb, wGP, wCP2D, wRP2D, wLP2D, wLCP2D, wLRP2D, row, lay, dFrom, dTo)`

  - **Description:** Template function for 3D locals calculation process.Calculated results should be stored in the wY parameter wave.

  - **Parameters:**

       `wave wY`: calculated Y wave  
       `wave wSim`: Simulated process  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wLClb`: Layer calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP2D`: a 2D Row parameters wave row - fitted point, col - param #  
       `wave wCP2D`: a 2D Row parameters wave column - fitted point, col - param #  
       `wave wLP2D`: a 2D Layer parameter wave layer – fitted point, col – param#  
       `wave wLRP2D`: a 2D Layer parameter wave row – fitted point, col – param#  
       `wave wLCP2D`: a 2D Layer parameter wave column – fitted point, col- param#  
       `variable row`: current row  
       `variable lay`: current layer  
       `variable dFrom`: start offset in of data calculated here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  

  - **Return Value:** None
     <br/><br/>


- `ThreadSafe Function G3F_ProcLocal_Ep_3D_TPL(wY, wSim, wCClb, wRClb, wLClb, wGP, wCP2D, wRP2D, wLP2D, wLCP2D, wLRP2D, row, lay,  dFrom, dTo, wEP)`

  - **Description:** Template function for 3D locals calculation process with extra parameter wave. . Calculated results should be stored in the wY parameter wave.

  - **Parameters:**
  
       `wave wY`: calculated Y wave  
       `wave wSim`: Simulated process  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wLClb`: Layer calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP2D`: a 2D Row parameters wave row - fitted point, col - param #  
       `wave wCP2D`: a 2D Row parameters wave column - fitted point, col - param #  
       `wave wLP2D`: a 2D Layer parameter wave layer – fitted point, col – param#  
       `wave wLRP2D`: a 2D Layer parameter wave row – fitted point, col – param#  
       `wave wLCP2D`: a 2D Layer parameter wave column – fitted point, col- param#  
       `variable row`: current row  
       `variable lay`: current layer  
       `variable dFrom`: start offset in of data calculated here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  
       `wave wEP`: extra parameters wave.  

  - **Return Value:** None
     <br/><br/>
  

- `ThreadSafe Function G3F_ProcLocal_EpXZp_3D_TPL(wY, wSim, wCClb,wRClb, wLClb, wGP, wCP2D, wRP2D, wLP2D, wLCP2D, wLRP2D, row, lay,  dFrom, dTo, wEP, wXZp)`

  - **Description:** Template function for 3D locals calculation process with extra parameter wave with X-Y parameter wave. Calculated results should be stored in the wY parameter wave.

  - **Parameters:**

       `wave wY`: calculated Y wave  
       `wave wSim`: Simulated process  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wLClb`: Layer calibration in original data, usually wavelength  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP2D`: a 2D Row parameters wave row - fitted point, col - param #  
       `wave wCP2D`: a 2D Row parameters wave column - fitted point, col - param #  
       `wave wLP2D`: a 2D Layer parameter wave layer – fitted point, col – param#  
       `wave wLRP2D`: a 2D Layer parameter wave row – fitted point, col – param#  
       `wave wLCP2D`: a 2D Layer parameter wave column – fitted point, col- param#  
       `variable row`: current row  
       `variable lay`: current layer  
       `variable dFrom`: start offset in of data calculated here in the linear data wave  
       `variable dTo`: end offset in of data calculated here in the linear data wave  
       `wave wEP`: extra parameters wave.  
       `Wave wXZp`: X-Y parameters wave.  

  - **Return Value:** None
     <br/><br/>
  

#### Local Guessing Function Templates  
Template functions for guessing local variables.

- `function G3FLocGs_Generic(lpw, yw, xw)`
  - **Description:** Generic 1D local guessing function.
  - **Parameters:**

       `wave &lpw`: parameters wave to set  
       `wave yw`: data to be fitted  
       `wave xw`: calibration data  

  - **Return Value:** None
     <br/><br/>
  

- `function G3F_LocGs_Generic_2D(lpw, yw, xw, zv)`
  - **Description:** Generic 2D local guessing function
  - **Parameters:**

       `wave &lpw`: parameters wave to set  
       `wave yw`: data to be fitted  
       `wave xw`: calibration data - first dimension, usually along columns  
       `variable zv`: calibration data - second dimension, usually along rows  

  - **Return Value:** None
     <br/><br/>


### Internal Functions  
These are all functions that are internal to G3F and cannot be called directly. The user does not need to supply these functions, and they are included with the G3F package.

#### Common Data Structures  
Data structures which are common throughout G3F. These inlude data structure inputs, fitted parameter structures, trimmed, thinned, and chunk data inputs, folded parameters, linear parameters and proxy function inputs.

- **Input 1D data structure** : inputs data into a 1D structure  
`STRUCTURE inDataDimT`: structure name  
         `variable from`: input from a point in dataset  
         `variable to`: input to a point in dataset  
         `variable thin`: data thinning  
         `variable ave`: averaging  
         `variable mtxLines`: number of lines in matrix  
         `WAVE clbW`: calibration wave  
         `WAVE refW`: reference wave  
         `WAVE maskW`: mask wave  
`endstructure`  
       <br/><br/>

- **Input 3D data structure** : inputs data into a 3D structure


    `STRUCTURE inDataT` : name of structure  
     `STRUCT inDataDimT X`: row dimension inputs  
     `STRUCT inDataDimT Z`: column dimension inputs  
     `STRUCT inDataDimT L`: layer dimension inputs  
     `string baseName`: name of dataset  
     `variable FromListSet`: imports from a data list  
     `WAVE colLimWaveW`: column number limit wave  
     `WAVE MNWave`: fitted data supplied as a 2D or 3D matrix wave  
     `WAVE /T MTWave`; fitted data supplied as a list of 1D waves, possibly of different lengths.  
       `endstructure`
          <br/><br/>

- **Fitted parameters structures** : contains fitted parameters.


    `STRUCTURE fitVarDimT`  
     `WAVE ParW`: this is a 2-3D parameters wave  
     `WAVE HeldW`: this is a linear wave of just the necessary parameters in the sequence of [var][point][layer]  
     `WAVE SigmaW`: sigma wave  
     `variable nVars`: number of variables  
     `variable hold`: boolean: 0 - fitted, other held  
     `variable linSize`: total number of variables to fit for this dimension  
     `variable linOffset`: offset of the first parameter in the fitted or held parameters wave  
     `WAVE linW`: reference only to the wave to be used in calculation  
       `Endstructure`
       <br/><br/>

   `STRUCTURE fitVarsT`  
     `STRUCT fitVarDimT Glob`: global fits  
     `STRUCT fitVarDimT Row`: row local fits  
     `STRUCT fitVarDimT Col`: column local fits  
     `STRUCT fitVarDimT Lay`: layer local fits  
     `STRUCT fitVarDimT LayRow`: layer-row local fits  
     `STRUCT fitVarDimT LayCol`: layer-column local fits  
    `Endstructure`  
       <br/><br/>

- **Thinned/Trimmed Data** : contains thinned or trimmed data.

   `STRUCTURE fitDataDimT`  
     `WAVE fitClbW`: calibration wave  
     `WAVE fitIdxW`: fitted data  
     `variable fitLines`: number of variables fitted  
    `endstructure`  

    `STRUCTURE fitDataT`  
     `WAVE fThinW`: thinned wave  
     `WAVE ColNumWave`: column number  
     `WAVE XYRefWave`: XY reference wave  
     `variable NumChunks`: number of chunks  
     `variable ChunkSize`: size of chunks  
     `variable HoldOverride`: hold override  
     `STRUCT fitDataDimT X`: row parameters  
     `STRUCT fitDataDimT Z`: column parameters  
     `STRUCT fitDataDimT L`: layer parameters  
   `Endstructure`  
      <br/><br/>

- **Linear chunks of data and parameters ready to fit** : contains linear chunks of data and parameters ready for fit.

   `STRUCTURE chunkDataT`

     `WAVE pw`: dummy (Expected by Igor), use individual parameter waves below  
     `WAVE yw`: output wave storing results of calculations  
     `WAVE xw`: dummy (Expected by Igor), use individual calibration waves below  
     `STRUCT WMFitInfoStruct fi`: Igor curve fitting information structure.  
     `WAVE CParamW`: linear parameters wave  
     `WAVE CDestW`: 2D or 3D final destination wave  
     `WAVE CClbW`: linear calibration wave  
     `WAVE CLinW`: linear calculated destination wave  
     `WAVE CResW`: residual wave  
     `WAVE /WAVE ExtraW`: extra params wave in  
     `variable V_ChiSq`: ChiSq parameter  
     `variable V_npnts`: number of points  
     `variable rows`: number of rows in the chunk  
     `variable cols`: number of rows in the chunk  
     `string UserSimFunc`: user simulation (process) function name  
     `string UserFitFunc`: user fit function name  
     `variable CorrNoSim`: flag indicating if post-processing function requires process wav  
     `STRUCT fitDataT fData`: data structure, see fitDataT  
     `STRUCT fitVarsT fVars`; variables structure, see fitVarsT  
     `string HoldStr`: variables hold string  
     `wave /T CConstrW`: constraints wave  
     `wave CEpsW`: extra params wave  
     `variable mainOptions`: dummy variable  
     `variable corrOptions`: indicates &quot;skip 1st &quot; option  
     `variable useThreads`: indicates number of threads to use  
     `variable ProcessReuse`: flag indicating that process results can be reused  
     `WAVE ProcLastGlobals`: backup of the last globals used for calculating the process  
     `WAVE ProcW`: calculated process wave, if used  
     `variable ProcMT`; flag indicting that process calculation can be done over multiple threads  

     **logging and debugging**

     `variable DbgKeep`: keep debug log  
     `variable DbgSave`: save debug log  
     `variable logCount`: log counter  
     `variable logSize`: size of log  
     `WAVE logW`: log wave  
     `variable cpuTime`: cpu time for fit  
     `variable startTime`: start time  
     `variable stepCount`: number of steps to complete fit  
   `endstructure`  
      <br/><br/>

- **Thinned data structure** : contains the thinned data and calibration waves.

   `STRUCTURE outDim`

     `WAVE clbW`: thinned calibration wave

     `WAVE refW`: thinned reference wave

   `Endstructure`

   `STRUCTURE outDataT`: thinned data  
     `WAVE oThinW`: ThinnedW, same as fitDataT.fThinW  
     `WAVE oFitW`: MWaveFit  
     `WAVE oResW`: Residuals Wave  
     `STRUCT outDim X`: output row dimensions  
     `STRUCT outDim Z`: output column dimensions  
     `STRUCT outDim L`: output layer dimensions  
   `endstructure`  
      <br/><br/>

- **Common Parameter Structure** : contains all parameters common to data sets

   `STRUCTURE G3F_Comm_Param_Set`  
     `wave wY`: calculated Y wave  
     `wave wCClb`: Column calibration in original data, usually time or concentration  
     `wave wRClb`: Row calibration in original data, usually wavelength or frequency  
     `wave wLClb`: Layer calibration in original data, usually composition or temperature  
     `wave wSim`: process wave or NULL wave  
     `wave /WAVE wEP`: extra params wave or NULL wave  
    `endstructure`  
       <br/><br/>

- **Folded Variable 2D Structure** : contains 2D variables for folding

    `STRUCTURE G3F_Folded_Var_2D_Set`  
     `wave wG`: global variables wave  
     `wave wR`: row variables wave  
     `wave wC`: column variables wave  
   `endstructure`  
      <br/><br/>

- **Folded Variable 3D Structure** : contains 3D variables for folding

    `STRUCTURE G3F_Folded_Var_3D_Set`  
     `wave wG`: global variables wave  
     `wave wR`: row variables wave  
     `wave wC`: colum variables wave  
     `wave wL`: layer variables wave  
     `wave wLR`: layer rows variables wave  
     `wave wLC`: layer columns variables wave  
   `endstructure`  
      <br/><br/>

- **Linear Variables Structure** : contains linear 1D parameters and offset

    `STRUCTURE G3F_Linear_Var`  
     `wave wP`: linear parameters wave  
     `variable PO`: offset in linear parameters wave to the first parameter  
    `endstructure`  
       <br/><br/>

- **Linear Variables 2D Structure** : contains linear 2D parameters

    `STRUCTURE G3F_Linear_Var_2D_Set`  
     `STRUCT G3F_Linear_Var G`: global structure  
     `STRUCT G3F_Linear_Var R`: row structure  
     `STRUCT G3F_Linear_Var C`: column structure  
    `endstructure`  
       <br/><br/>

- **Linear Variables 3D Structure** : contains linear 3D parameters

    `STRUCTURE G3F_Linear_Var_3D_Set`  
     `STRUCT G3F_Linear_Var G`: global structure  
     `STRUCT G3F_Linear_Var R`: row structure  
     `STRUCT G3F_Linear_Var C`: column structure  
     `STRUCT G3F_Linear_Var L`: layer structure  
     `STRUCT G3F_Linear_Var LR`: layer rows structure  
     `STRUCT G3F_Linear_Var LC`: layer column structure  
    `endstructure`
       <br/><br/>

- **Common Structure for G3F Direct and G3F Process Proxy Functions** : contains parameters for fitting and simulation proxy functions.

    `STRUCTURE G3F_Proxy_Param_Set`  
     `wave ColNumWave`: column number limiting wave or null  
     `variable NPoints`: total number of points in data wave  
     `variable NRows`: total number of fitted rows in data wave  
     `variable NCols`: total number of fitted columns in data wave  
     `variable NLays`: total number of fitted layers in data wave  
     `variable NRVar`: number of RowLoc variables  
     `variable NCVar`: number of ColLoc variables  
     `variable NLVar`: number of LayLoc variables  
     `variable NLRVar`: number of LayRowLoc variables  
     `variable NLCVar`: number of LayColLoc variables  
     `variable options`: misc flags  
     `variable useThreads`: maximal number of CPU threads to use  
     `variable debugKeep`: keep debug data  
     `variable debugSave`;: save debug data  
   `EndStructure`  
      <br/><br/>

### Proxy Functions  
These are functions which input template functions and perform functions on input data.

#### Direct Proxy Functions  
These are functions which input direct fitting templates and perform fitting on experimental data.

- `function G3F_Direct_MT_Proxy(LocFuncName, options, useThreads,  NPoints, NRows, NCols, NLays, RPO, CPO, LPO, LRPO, LCPO, NRVar, NCVar, NLVar, NLRVar, NLCVar, ColNumWave, wY, wRClb, wCClb, wLClb, wGP, wRP, wCP, wLP, wLRP, wLCP, wEPN, wXZpN, dbgKeep, dbgSave)`
  - **Description:** Proxy function for multi-threaded calculations using user-supplied function matching one of G3F_ProcLocal_XX_XX_MT_TPL templates. Calculated results are stored in the wY parameter wave.
  - **Parameters:**

       `string LocFuncName`: name of the local function  
       `variable options`: misc flags  
       `variable useThreads`: specifies the number of threads to use  
       `variable NPoints`: number of points  
       `variable NRows`: number of rows  
       `variable NCols`: number of columns  
       `variable NLays`: number of layers  
       `variable RPO`: offset in wRP to the first Row Parameter  
       `variable NRVar`: number of row variables  
       `variable NCVar`: number of column variables  
       `variable CPO`: offset in wCP to the first Col Parameter  
       `wave ColNumWave`; column number limiting wave or null  
       `wave wY`: calculated Y wave  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wLClb`: Layer calibration in original data, usually another parameter  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP`: Row parameters wave  
       `wave wCP`: Col parameters wave  
       `string wEPN`: name of extra params wave or none  
       `string wXZpN`: names of X-Z parametric wave; wEP must be used  
       `wave wLP`: Layer parameters wave  
       `variable NLVar`: number of LayLoc variables (per row)  
       `variable LPO`: offset in wLP to the first Lay Parameter  
       `wave wLRP`: LayRow parameters wave  
       `variable NLRVar`: number of LayRowLoc variables (per row)  
       `variable LRPO`: offset in wLRP to the first Lay Parameter  
       `wave wLCP`: LayCol parameters wave  
       `variable NLCVar`: number of LayColLoc variables (per row)  
       `variable LCPO`: offset in wLCP to the first Lay Parameter  
       `variable dbgKeep`,: debugging data to be kept  
       `variable dbgSave`: debugging data to be saved  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

- `function G3F_Direct_1D_MT_Proxy(p, c, v, theLocFunc, pStart, cStart)`
  - **Description:** 1D proxy function for local multi-threaded direct calculations. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing common parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_Direct_1D_TPL theLocFunc`: reference to 1D template. Direct calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

- `function G3F_Direct_2D_MT_Proxy(p, c, v, theLocFunc2D, pStart, cStart)`
  - **Description:** 2D proxy function for local multi-threaded direct calculations. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing common parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_Direct_2D_TPL theLocFunc2D`: reference to 2D template. Direct calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>


- `function G3F_Direct_3D_MT_Proxy(p, c, v, theLocFunc3D, pStart, cStart)`
  - **Description:** 2D proxy function for local multi-threaded direct calculations. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing command parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_Direct_3D_TPL theLocFunc3D`: reference to 2D template. Direct calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

- `function G3F_Direct_Ep_1D_MT_Proxy(p, c, v, theLocFunc, pStart, cStart)`
  - **Description:** 1D proxy function for local multi-threaded direct calculations with extra parameter wave. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing command parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_Direct_Ep_1D_TPL theLocFunc`: reference to 1D template with extra parameter wave. Direct calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>


- `function G3F_Direct_Ep_2D_MT_Proxy(p, c, v, theLocFunc2D, pStart, cStart)`
  - **Description:** 2D proxy function for local multi-threaded direct calculations with extra parameter wave. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing command parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_Direct_Ep_2D_TPL theLocFunc2D`: reference to 2D template with extra parameter wave. Direct calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>


- `function G3F_Direct_Ep_3D_MT_Proxy(p, c, v, theLocFunc3D, pStart, cStart)`
  - **Description:** 3D proxy function for local multi-threaded direct calculations with extra parameter wave. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing command parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_Direct_Ep_3D_TPL theLocFunc3D`:reference to 2D template with extra parameter wave. Direct calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

- `function G3F_Direct_EpXZp_1D_MT_Proxy(p, c, v, theLocFunc, pStart, cStart)`
  - **Description:** 1D proxy function for local multi-threaded direct calculations with extra parameter wave and X-Z parametric wave. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing command parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_Direct_EpXZp_1D_TPL theLocFunc`: reference to 1D template with extra parameter wave and X-Z parametric wave. Direct calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>


- `function G3F_Direct_EpXZp_2D_MT_Proxy(p, c, v, theLocFunc2D, pStart, cStart)`
  - **Description:** 2D proxy function for local multi-threaded direct calculations with extra parameter wave and X-Z parametric wave. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing command parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_Direct_EpXZp_2D_TPL theLocFunc2D`: reference to 2D template with extra parameter wave and X-Z parametric wave. Direct calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

- `function G3F_Direct_EpXZp_3D_MT_Proxy(p, c, v, theLocFunc3D, pStart, cStart)`
  - **Description:** 3D proxy function for local multi-threaded direct calculations with extra parameter wave and X-Z parametric wave. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing command parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`:structure containing linear variables  
       `FUNCREF G3F_Direct_EpXZp_3D_TPL theLocFunc3D`: reference to 3D template with extra parameter wave and X-Z parametric wave. Direct calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

#### Process Proxy Functions  
These are functions which input process simulation templates and perform simulations of the given model.

- `function G3F_Process_Proxy(SimFuncName, GlobW, procW, inxw, wEPN, wXZpN)`
  - **Description:** Proxy function for Uni-threaded access to G3F_Process_TPL from G3F module. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `string SimFuncName`: This is the name given to the simulated data  
       `wave GlobW, procW, inxw`: These are the input waves for the proxy function (global, process, and column calibration waves respectively)  
       `string wEPN`: name of extra params wave or none  
       `string wXZpN` : name of X-Z  parametric wave; wEP must be used  
       `FUNCREF G3F_Process_EpXZp_TPL theSimEpXZpFunc = $SimFuncName`: This is the function template referenced for simulation (extra parameter wave, X-Z parametric wave).  
       `FUNCREF G3F_Process_Ep_TPL theSimEpFunc = $SimFuncName`: This is the function template referenced for simulation (extra parameter wave)  
       `FUNCREF G3F_Process_TPL theSimFunc = $SimFuncName`: This is the function template referenced for simulation.  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

- `function G3F_Process_MT_Proxy(useThreads, SimFuncName, wGP, wY, wCClb, wEPN, wXZpN)`
  - **Description:** Proxy function for multi-threaded calculations using user-supplied function matching one of G3F_ProcLocal_XX_XX_MT_TPL templates. Calculated results are stored in the wY parameter wave.
  - **Parameters:**

       `variable useThreads`: determines the number of threads to use  
       `string SimFuncName`: This is the name given to the simulated data  
       `wave wGP` : global parameters wave, always starts with 0  
       `wave wY`: calculated Y wave  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `string wEPN`: name of extra params wave or none  
       `string wXZpN`: names of X-Z  parametric wave; wEP must be used  
       `FUNCREF G3F_Process_EpXZp_MT_TPL theSimEpXZpFuncMT = $SimFuncName`: This is the function template referenced for simulation (extra parameter wave, X-Z parametric wave).  
       `FUNCREF G3F_Process_Ep_MT_TPL theSimEpFuncMT = $SimFuncName`: This is the function template referenced for simulation (extra parameter wave)  
       `FUNCREF G3F_Process_MT_TPL theSimFuncMT = $SimFuncName`: This is the function template referenced for simulation.  
       
  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

#### Local Process Proxy Functions  
These are functions which input local process templates and perform local parameter calculations from simulations and experimental data.

- `function G3F_ProcLocal_MT_Proxy(LocFuncName, options, useThreads,  NPoints, NRows, NCols, NLays, RPO, CPO, LPO, LRPO, LCPO, NRVar, NCVar, NLVar, NLRVar, NLCVar, ColNumWave, wY, wRClb, wCClb, wLClb, wGP, wRP, wCP, wLP, wLRP, wLCP, wEPN, wXZpN, wSim, dbgKeep, dbgSave)`
  - **Description:** Proxy function for multi-threaded calculations using user-supplied function matching one of G3F_ProcLocal_XX_XX_MT_TPL templates. Calculated results are stored in the wY parameter wave.
  - **Parameters:**

       `string LocFuncName`: name of the local function  
       `variable options`: misc flags  
       `variable useThreads`: specifies the number of threads to use  
       `variable NPoints`: number of points  
       `variable NRows`: number of rows  
       `variable NCols`: number of columns  
       `variable NLays`: number of layers  
       `variable RPO`: offset in wRP to the first Row Parameter  
       `variable NRVar`: number of row variables  
       `variable NCVar`: number of column variables  
       `variable CPO`: offset in wCP to the first Col Parameter  
       `wave ColNumWave`: column number limiting wave or null  
       `wave wY`: calculated Y wave  
       `wave wCClb`: Column calibration in original data, usually time or concentration  
       `wave wRClb`: Row calibration in original data, usually wavelength  
       `wave wLClb`: Layer calibration in original data, usually another parameter  
       `wave wGP`: global parameters wave, always starts with 0  
       `wave wRP`: Row parameters wave  
       `wave wCP`: Col parameters wave  
       `string wEPN`: name of extra params wave or none  
       `string wXZpN`: names of X-Z parametric wave; wEP must be used  
       `wave wLP`: Layer parameters wave  
       `variable NLVar`: number of LayLoc variables (per row)  
       `variable LPO`: offset in wLP to the first Lay Parameter  
       `wave wLRP`: LayRow parameters wave  
       `variable NLRVar`: number of LayRowLoc variables (per row)  
       `variable LRPO`: offset in wLRP to the first Lay Parameter  
       `wave wLCP`: LayCol parameters wave  
       `variable NLCVar`: number of LayColLoc variables (per row)  
       `variable LCPO`: offset in wLCP to the first Lay Parameter  
       `variable dbgKeep, dbgSave`: debugging data to be kept or saved  
       `wave wSim`: Simulated process  

  - **Return Value:** 1 on success or 0 on error.
     <br/><br/>
  

- `function G3F_ProcLocal_1D_MT_Proxy(p, c, v, theLocFunc, pStart, cStart)`
  - **Description:** 1D proxy function for local multi-threaded calculations. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing command parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_ProcLocal_1D_TPL theLocFunc`: reference to 1D template. Locals calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

- `function G3F_ProcLocal_2D_MT_Proxy(p, c, v, theLocFunc2D, pStart, cStart)`
  - **Description:** 2D proxy function for local multi-threaded calculations. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing command parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_ProcLocal_2D_TPL theLocFunc2D`: reference to 2D template. Locals calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  
  
- `function G3F_ProcLocal_3D_MT_Proxy(p, c, v, theLocFunc3D, pStart, cStart)`
  - **Description:** 3D proxy function for local multi-threaded calculations. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing command parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_ProcLocal_3D_TPL theLocFunc3D`: reference to 3D template. Locals calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

- `function G3F_ProcLocal_Ep_1D_MT_Proxy(p, c, v, theLocFunc, pStart, cStart)`
  - **Description:** 1D proxy function for local multi-threaded calculations. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing command parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_ProcLocal_Ep_1D_TPL theLocFunc`: reference to 1D template with extra parameter wave. Locals calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

- `function G3F_ProcLocal_Ep_2D_MT_Proxy(p, c, v, theLocFunc2D, pStart, cStart)`
  - **Description:** 2D proxy function for local multi-threaded calculations. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`:structure containing command parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_ProcLocal_Ep_2D_TPL theLocFunc2D`: reference to 2D template with extra parameter wave. Locals calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

- `function G3F_ProcLocal_Ep_3D_MT_Proxy(p, c, v, theLocFunc3D, pStart, cStart)`
  - **Description:** 3D proxy function for local multi-threaded calculations. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing command parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_ProcLocal_Ep_3D_TPL theLocFunc3D`: reference to 3D template with extra parameter wave. Locals calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

- `function G3F_ProcLocal_EpXZp_1D_MT_Proxy(p, c, v, theLocFunc, pStart, cStart)`
  - **Description:** Proxy function for local multi-threaded calculations. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing command parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_ProcLocal_EpXZp_1D_TPL theLocFunc`: reference to 1D template with extra parameter wave and X-Z parameter wave. Locals calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

- `function G3F_ProcLocal_EpXZp_2D_MT_Proxy(p, c, v, theLocFunc2D, pStart, cStart)`
  - **Description:** 2D proxy function for local multi-threaded calculations Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing command parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_ProcLocal_EpXZp_2D_TPL theLocFunc2D`: reference to 2D template with extra parameter wave and X-Z parameter wave. Locals calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

- `function G3F_ProcLocal_EpXZp_3D_MT_Proxy(p, c, v, theLocFunc3D, pStart, cStart)`
  - **Description:** 2D proxy function for local multi-threaded calculations. Calculated results are stored in the c.wY wave of the chunk data structure.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: structure containing proxy parameters  
       `STRUCT G3F_Comm_Param_Set &c`: structure containing command parameters  
       `STRUCT G3F_Linear_Var_3D_Set &v`: structure containing linear variables  
       `FUNCREF G3F_ProcLocal_EpXZp_3D_TPL theLocFunc3D`: reference to 2D template with extra parameter wave and X-Z parameter wave. Locals calculation process fitting.  
       `variable pStart`: row start  
       `variable cStart`: column start  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

#### Service Functions  
These are all functions which control data fitting and model simulation options (ie: autocycling, data ranges, holds). These functions are for the most part accessible from the G3F control panel GUI.

**Do Fit Button Function:**

- `Function DoFitButtonProc(ctrlName) : ButtonControl`
  - **Description:** User control which intiates the Do Fit function.
  - **Parameters:**

       `String ctrlName`: name of control on DoFit button

  - **Return Value:** `DoFit(ctrlName, 0, 0)`: Controls DoFit process on GUI.
     <br/><br/>
  

**Simulate Function:**

- `Function SimulateFitButtonProc(ctrlName) : ButtonControl`
  - **Description:** GUI control of main simulation function
  - **Parameters:**

       `String ctrlName`: name of control on Simulate button

  - **Return Value:** DoFit(ctrlName, (0x1 | 0x2 | 0x4 | 0x8 | 0x10| 0x20),1) : Simulation initiated.
     <br/><br/>
  

**Holding Functions**

- `Function DoFitRowOnlyButtonProc(ctrlName) : ButtonControl`
  - **Description:** GUI control of fitting only rows
  - **Parameters:**

       `String ctrlName`: name of control on holding button on GUI

  - **Return Value:** `DoFit(ctrlName, 2, 0)`: Fits only rows.
     <br/><br/>
  
  
- `Function DoFitColOnlyButtonProc(ctrlName) : ButtonControl`
  - **Description:** GUI control of fitting only columns
  - **Parameters:**

       `String ctrlName`: name of control on holding button on GUI

  - **Return Value:** result of the DoFit() execution.
     <br/><br/>
  

**Range Functions**

- `Function CheckRanges(PFromS, PToS, PThinS, PMax, ErrorMsg )`
  - **Description:** Function checks and adjusts the ranges of variables.
  - **Parameters:**

       `string PFromS`: Beginning of range  
       `string PToS`: End of range  
       `string PThinS`: Thinning in range  
       `variable  PMax`; Maximum value  
       `string ErrorMsgf`: error message  

  - **Return Value:** 1 on success or 0 on error
     <br/><br/>
  

**Autocycle Functions:**

- `Function AutoCycleButtonProc(ctrlName) : ButtonControl`
  - **Description:** Determines the autocycle for each dimension.
  - **Parameters:**

       `String ctrlName`: name of control on autocycle button on GUI

  - **Return Value:** result of the DoFit() execution
     <br/><br/>
  

- `function  AutoCycleGlobRow(cycle)`
  - **Description:** Autocycle global variables function in the row dimension.
  - **Parameters:**

       `variable cycle`: determines number of cycles

  - **Return Value:** result of the DoFit() execution
     <br/><br/>
  

- `function  AutoCycleGlobCol(cycle)`
  - **Description:** Autocycle global variables function in the column dimension.
  - **Parameters:**

       `variable cycle`: determines number of cycles

  - **Return Value:** result of the DoFit() execution
     <br/><br/>
  

- `function  AutoCycleColRow(cycle)`
  - **Description:** Function fits local variable column and row only.
  - **Parameters:**
  
       `variable cycle`: determines number of cycles
         
  - **Return Value:** result of the DoFit() execution
     <br/><br/>
  

- `function  AutoCycleGlobRowCol(cycle)`
  - **Description:** Function fits global variables, and column and row local variables.
  - **Parameters:**

       `variable cycle`: determines number of cycles.

  - **Return Value:** result of the DoFit() execution
     <br/><br/>
  

- `function  FitSeries (cycles, AutoCycleFuncS)`
  - **Description:** Fits a series of autocycled functions.
  - **Parameters:**

       `variable cycles`: determines number of cycles  
       `string AutoCycleFuncS`: string of autocycle functions  

  - **Return Value:** result of the DoFit() execution
     <br/><br/>
  

- function  X_FitSeries (cycles)
  - **Description:** Determines which parameters are held.
  - **Parameters:**

       `variable cycles`: determines number of cycles.

  - **Return Value:** result of the DoFit() execution
     <br/><br/>
  

Do Fit Function

- Function DoFit(ctrlName, aHoldOverride, Simulate)
  - **Description:** The fitting operation is performed by this function per GUI settings. Fitting/calculation results are saved in new waves in the current data folder.
  - **Parameters:**

       `string ctrlName`: name of Do Fit control  
       `variable aHoldOverride`: hold override variable  
       `variable Simulate`: simulation variable  

  - **Return Value:** 1 or success, 0 or -1 on error.
     <br/><br/>
  

#### Misc Functions  
These are functions which perform misc. operations (i.e. local parameter folding, local guesses, list access).

**Local Folding worker functions**

- `function /WAVE G3F_LocPFold (wCP, NPoints, NCVar, CPO , suffix, msg)`
  - **Description:** Local variable folding function (columns).
  - **Parameters:**

       `wave wCP`: Col parameters wave  
       `variable NPoints`: number of points  
       `variable NCVar`: number of column variables  
       `variable CPO`:offset in wCP to the first Col Parameter  
       `string suffix`: suffix appended to folded column parameter wave  
       `string msg`: error message  

  - **Return Value:** Folded column local wave
     <br/><br/>
  

- `function /WAVE G3F_LocPLFold (wCP, NPoints, NCVar, NLays, CPO , suffix, msg)`
  - **Description:** Local variable folding function (2D, column and layer locals)
  - **Parameters:**

   `wave wCP`: Col parameters wave  
   `variable NPoints`: number of points  
   `variable NCVar`: number of column variables  
   `variable NLays` :number of layers    
   `variable CPO`: offset in wCP to the first Col Parameter    
   `string suffix`: suffix appended to folded 2D parameter wave  
   `string msg`: error message  
   
  - **Return Value:** Folded 2D local wave
     <br/><br/>
  

**Parameter Folding Functions:**

- `function G3F_Fold_2D_params(p, v, f)`
  - **Description:** This function folds parameters for use in 2D proxy functions. Folded parameters are stored in the  f.wLC, and f.wLR fields.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: proxy parameter structure  
       `STRUCT G3F_Linear_Var_3D_Set &v`: linear variable structure  
       `STRUCT G3F_Folded_Var_3D_Set &f`: folded variable structure  

  - **Return Value:** 1 on success or 0 on error.
     <br/><br/>
  

- `function G3F_Fold_3D_params(p, v, f)`
  - **Description:** This function folds parameters for use in 3D proxy functions. Folded parameters are stored in the f.wL, f.wLC, and f.wLR fields.
  - **Parameters:**

       `STRUCT G3F_Proxy_Param_Set &p`: proxy parameter structure  
       `STRUCT G3F_Linear_Var_3D_Set &v`: linear variable structure  
       `STRUCT G3F_Folded_Var_3D_Set &f`: folded variable structure  

  - **Return Value:** 1 on success or 0 on error.
     <br/><br/>
  

**Local Guessing Proxy Functions**

- `function G3F_Guess_Proxy(guessFuncName, lpw, yw, xw)`
  - **Description:** Proxy local variable calculations
  - **Parameters:**

       `string guessFuncName`: name of guessing function  
       `wave &lpw`: parameters wave to set  
       `wave yw`: data to be fitted  
       `wave xw`: calibration data – first dimension, usually along columns  
       `FUNCREF G3FLocGs_Generic SetGuessFunction = $guessFuncName`; reference to template generic 1D local guessing function.  

  - **Return Value:** Real variable containing calculated local guesses
     <br/><br/>
  

- `function G3F_Guess2D_Proxy(guessFuncName, lpw, yw, xw, zv)`
  - **Description:** 2D proxy local variable calculations.
  - **Parameters:**

       `string guessFuncName`: name of guessing function  
       `wave &lpw`: parameters wave to set  
       `wave yw`: data to be fitted  
       `wave xw`: calibration data – first dimension, usually along columns  
       `variable zv`: calibration data - second dimension, usually along rows  
       `FUNCREF G3F_LocGs_Generic_2D SetGuessFunction = $guessFuncName`; reference to template generic 1D local guessing function.  

  - **Return Value:** Real variable containing calculated 2D local guesses.
     <br/><br/>
  

**List Access Functions**

- `function G3F_FunctionList2SVar(svarName, matchStr, sepStr, optStr)`
  - **Description:** proxy function to access function list
  - **Parameters:**

       `string svarName`: global string variable for functions  
       `string matchStr`: matches function name  
       `string sepStr`:  
       `string optStr`:  

  - **Return Value:** no return value; A list of matching wave names stored in the global string named per svarName parameter.
     <br/><br/>
  

- `function G3F_WaveList2SVar(svarName, matchStr, sepStr, optStr)`
  - **Description:** proxy function to access wave list
  - **Parameters:**

       `string svarName`: global string variable for waves  
       `string matchStr`: matches wave name  
       `string sepStr`  
       `string optStr`  

  - **Return Value:** no return value; A list of matching wave names stored in the global string named per svarName parameter.
     <br/><br/>
