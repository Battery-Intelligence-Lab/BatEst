# BatEst

Matlab code for battery simulations and parameter estimation.

Please read the [GUIDE](GUIDE.md) to get started.

[![DOI](https://zenodo.org/badge/670707813.svg)](https://zenodo.org/badge/latestdoi/670707813)


# Use Cases

BatEst can be used to parameterise low-order battery models from time-series data.


# Requirements and Other Information

Requirements:
- Matlab (version R2023a)
- Optimization Toolbox (version 9.5)
- System Identification Toolbox (version 10.1)
- Signal Processing Toolbox (version 9.2)

This code was first created at the University of Oxford in 2022. See [AUTHORS](AUTHORS.md) for a list of contributors and [LICENSE](LICENSE) for the conditions of use.

If you encounter a problem or any unexpected results, please create an Issue on the GitHub website, add details of the problem (including the error message and MATLAB version number). For other enquiries, please contact nicola.courtier(at)eng.ox.ac.uk.


# How to Cite this Code

Please cite the Zenodo DOI, which can be found on the GitHub page.


# Technical Features

The main scripts are:
- `main_one.m` is for running a single simulation or optimisation step
- `main_multi.m` is for running batches of simulations or optimisation steps
- `reset_path.m` adds necessary subfunctions to the MATLAB path

The Code folder contains all subfunctions and Data contains some example datasets. Please see Code/CodeStructure for a diagram showing how the other functions are used.
