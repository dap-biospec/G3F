---
title: 'G3F: Global, Multidimensional Spectral Regression Analysis'
tags:
  - Igor Pro
  - chemistry
  - spectroscopy  
  - multivariable fitting
  - multidimensional fitting
  - multidimensional data sets
  - non-linear global regression
  - simulation software
authors: 
 - name: Allison M. Stettler
   orcid: 0000-0002-8910-1929
   affiliation: 1
 - name: Christopher W. John
   orcid: 0000-0003-1713-1229
   affiliation: 1
 - name: Yegor D. Proshlyakov
   affiliation: 1
 - name: Denis A. Proshlyakov
   orcid: 0000-0003-4625-0323
   affiliation: 1
affiliations:
 - name: Department of Chemistry, Michigan State University
   index: 1
date: 13 July 2019
bibliography: paper.bib

---

# Summary

## Rationale:
Multi-dimensional non-linear global regression permits the investigation of quantitative relationships in complex datasets and to examine validity of proposed models. However, traditional multi-dimensional regression requires predictable variation of all parameters along every fitted dimension. This constraint may be difficult to satisfy if, for example:

- When noise in any particular dimension exceed the signal of interest, such as with large polynomial variation of baselines due to thermal fluctuations, sample variability, or other of interference.  
- When a common signal is too complex for rational description using a reduced set of variables, such as encountered with multiple bands in high-resolution spectra. The unknown spectra of one or more species involved in a predictable process may be better described by a large set of independent coefficients that vary between discrete sampled energies (frequency, wavelength, mass, charge etc.) than by a limited set of Gaussian or Lorentzian peaks. 
- When observables cannot be accurately described using a trivial band shape or distribution, for example, when a normally distributed signal is broadened by spectral resolution with a rectangular profile. 
- When spectral overlap does not allow to achieve experimental resolution of several distinct signals, especially when their individual properties are not known.
- When describing intensity an inhomogeneous kinetic process, a process with unknown kinetics, or when kinetics may be too complex be described with a reasonable number of phases.

Common to these examples is the need to describe a multi-dimensional experimental dataset not only using globally invariable parameters (frequencies, temperature, rate constants), but with variable vectors of parameters that are applicable to one or more dimensions (local parameters).  

## Concept:

The G3F package for IgorPro was initially developed to simultaneously analyze vibrational spectra of multiple isotopomers with overlapping modes in time-resolved Raman studies on enzyme TauD, where simple improvement of signal via time averaging was not possible. [@Grzyska: 2010] Analysis of a frequency vs. time 2D dataset with uniform properties of predictable vibrational bandshapes (global) and unknown speciation plots (local to each time point)  allowed to resolve superimposed vibrations of two different species while improving resolution via signal sharing  between spectra. Also included were variable polynomial baseline, local to spectra. Similar approach was later used in analysis of Raman spectra of methane monooxygenase. [@Banerjee:2015] In more recent studies, it was expanded to obtain completely unknown difference infrared spectra of a redox transition with an unknown potential over a variable polynomial background.[@John: 2019a] [@John: 2019b] In this case, analysis involved two orthogonal parametric vectors (frequency-dependent amplitudes vs. polynomial baselines). 

## Implementation:

G3F uses IgorPro’s internal non-linear regression engine to recursively minimize residual error. G3F handles folding of complex global and local data into a form suitable for built-in engine. Fitted data can be a 2D (columns) or 3D (layers) matrix with each dimension described by its own independent variable (calibration) and an optional set of zero or more fitted parametric vectors (row, column, and layer local variables). In addition to layer-uniform row and column variables, G3F provides for a layer-localized LayRow and LayColumn local fitted variables. In line with conventional fitting, G3F implements concepts of subranges and data mask in each of three fitted dimensions. To reduce computational load of covariance analysis over large sets of local variables (thousands), G3F introduces the concept of data thinning, which allows to box-average or drop equally-spaced data points along different dimensions independently.

While the majority of preparation, verification, and reporting are transparent to the end user, G3F requires minimal knowledge or IgorPro programming for the user to be able to define the desired model in code. G3F used GUI control panel that allows the user to select a conforming fitting function. G3F recognizes multiple templates of user-supplied fitting functions depending on the dimensionality of data and the need for additional parameters, as described in the API and User Manual.   
To allow analysis of complex processes, such as continuous-time Markov processes [@Anderson:2011; @Zhang:2018], for example, G3F supports bi-phasic approach where the process is calculated first using only global parameters and local parameters are fitted to this process second. This results in dramatic reduction on computational load if prediction of the process requires extensive numerical integrations, for example. Once generated, the process description will be re-used over multiple iterations until any of global parameters change.  Process generation and local parameters fitting is also accomplished via user-supplied templated functions.      

Internally, G3F uses the concept of proxy functions. From IgorPro standpoint, the same proxy function is always executed for every fitting iteration. This proxy function analyzes data configuration and eventually calls specific user-supplied function using function references. The use of proxy functions allows to assemble most of G3F code in an independent module, de-cluttering general procedure namespace. Fitting and process (where possible) calculations are parallelized. 

In addition to handling data folding and fitting calls, G3F include a number of utilities helpful in the process of multidimensional fitting and the analysis of results. If allows to automatically alternate fitting of dimensional variable subsets, which can greatly facilitate convergence of initial guesses of local parameters are far from optimal. G3F provides several options for obtaining visual feedback on fitness of model to experimental data. 

# Acknowledgments
This work was supported by the National Institutes of Health grants GM096132 and EY028049.

# References
