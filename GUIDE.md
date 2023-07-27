# User Guide for BatEst

This guide provides a step-by-step explanation of how to make use of the main features of battery-estimator in MATLAB:

1. Simulating a battery model for a given input.
2. Estimating model parameters from data.

## Contents

- Quick Start Guide

- How to Edit the Input Files

- How to Edit or Create a Model

- How to Analyse the Output

- Common Errors

- How to Cite this Code


# Quick Start Guide

Learn how to use the code by carrying out the following example steps.


## Step 0. Setup

Download or clone the git repository from GitHub. Open Matlab and make the folder containing the [main_one.m](main_one.m) file the current folder.


## Step 1. Simulation of the default EHMT

Firstly, this code can be used to simulate the internal states and output of a simple battery model.

Enter `main_one;` in the command window. The program should now run using the default set of simulation settings, model parameters and experimental protocol for the input current. Notes on amending these inputs are given below.

Once the simulation is complete, you should see four figures appear. The final figure (on top) displays the input current, the output voltage and the states. The default model is the equivalent hydraulic model with temperature (EHMT) which contains four states (SOC, CSC, Ts, and Tc) [1]. Figures 1-3 show the form of the underlying model functions, namely the Arrhenius relations, the open-circuit potentials and the reaction overpotentials as functions of temperature, current and state of charge. To change the output of the code to only display the results and not the model functions, enter `open code_switches` in the command window and change the value of `plot_model` to `false`. To turn off all plotting, one could also change `plot_results` but let's leave it turned on for now.

Reference [1]: L. D. Couto et al., IEEE Transactions on Control Systems Technology, 30(5):1990-2001 (2022).


## Step 2. Simulation of a modified EHMT

In order to change one or more of the input parameters, enter `open cell_parameters` or `open model_parameters` in the command window. The first will open the [cell_parameters.m](Code/Common/cell_parameters.m) file which contains general cell properties, while the second opens the [model_parameters.m](Code/Model/EHMT/model_parameters.m) file which contain the parameters which are specific to the current model, the EHMT. As an example, we can change the negative electrode capacity `Qn` (a model parameter) to another value such as 5 Ah. Note that, in this code, the state of charge is scaled by the negative electrode capacity `Qn`, while the nominal cell capacity `Qnom` is a separate parameter (a cell parameter) which is used only to compute the C-rate. Feel free to change another of the constant parameters.

If you would also like to change the input current profile, enter `open cell_protocol` to open [cell_protocol.m](Code/Common/cell_protocol.m). We can then change the input profile for the current from a constant value to a linearly increasing current profile using, for example, `u1 = @(t) t/t_end; % current (A)`. This function will then be used to create the first column of the vector `uu`.

To run the simulation with updated parameters values and the new input current, enter `main_one;` in the command window. Check that the plots have changed as expected.

Once you have completed this example, reset the parameters that you changed, for example by discarding any changes in GitHub Desktop.

Next, let's demonstrate the second main functionality of the code: parameter estimation. The code contains a number of different methods for estimating unknown parameters from data.


## Step 3. Comparison between model and data

If you would like to load your own data, please first read the `DATA_PREP_GUIDE` on how to prepare your data. Alternatively, an example dataset made available by T. Raj and D. A. Howey [2] is stored within the repository. Load this dataset with the command `Dataset = import_parquet('Data/Examples/Raj2020_Cycling.parquet');`.

Reference [2]: T. Raj, Path Dependent Battery Degradation Dataset Part 1, University of Oxford (2020). doi.org/10.1002/batt.202000160.

To run a comparison, we need to change the simulation settings. Enter `open main_one` and change the `Target` from `Simulate` to `Compare`. We can also change which model we are using here. Change the `ModelName` from `EHMT` to `ROCV`, which corresponds to an equivalent circuit model a resistor in series with an OCV source.

Now run a comparison of the data to the default simulation of the equivalent circuit model by entering `main_one(Dataset);` in the command window - note that it is now necessary to pass the `Dataset` as an input.

We can see that the default simulation does not compare very well to the data. This motivates our use of parameter estimation to obtain a better fit.


## Step 4. Estimation of 2 of the parameters in the ROCV model

Our equivalent circuit model `ROCV` has 2 parameters, namely the capacity `Qn` and the series resistance `Rs`, as well as 2 optional parameters: the negative/positive electrode capacity ratio (`nu`) and cyclable lithium/positive electrode capacity ratio (`miu`) if using separate electrode open-circuit potentials (OCPs) rather than an OCV function - this choice is made in [cell_parameters.m](Code/Common/cell_parameters.m).

In the file `main_one.m`, let us now change the `Target` to `Parameter`, i.e. we would like to estimate the parameters as well as simulate and plot the data. For this `Target`, we also need to choose the `Estimator`. Let's keep this set to `PEM`, which stands for prediction error minimisation. This method is provided as a built-in function for MATLAB and is able to estimate initial states as well as constant parameters.

This time run the code using `out = main(Dataset);`. By including the output `out` in this call, we will be able to retrieve the estimated parameters. The progress of the optimiser will be displayed as it running.

Once the code has run, `out` will be a table containing the results. The estimated values can be found under their parameter names, e.g. `Qn` or `Rs`. The values named `c0_1` to `c0_4` should be between 0 and 1 and they correspond to the dimensionless values returned directly from the optimiser (in the order listed above). Also stored are the initial values of each state and the root mean square error (RMSE) between a simulation using the estimated parameters and the data.

Note that MATLAB's `Fmincon` and `PEM` are local optimisation methods and so they are not guaranteed to find the best fit. Giving informed initial guesses in the `model_parameters.m` file is likely to greatly improve the results as well as the computation time. But how do we improve the initial estimates? Let us first test the method against another estimation problem and then go through a step-by-step approach which is designed to improve the estimates.


## Step 5. Estimation of a subset of the parameters in the ROCV model with added noise

In the file `main_one.m`, set the parameter `Noise = true;`. We can also change which parameters are being treated as unknowns by changing the uncertainties. To do this, `open set_model` and update the entries in the `uncert` corresponding to the parameter list on the line above. Any variables with an uncertainty of zero will not be estimated to reduce the computation time.

Run the parameter estimation using `out = main_one(Dataset);`.

Once you have completed this example, reset `Noise = false;` and `uncert = [0.05; 1; 0; 0];`.

You may now be interested to compare results using different estimation Methods and Models. To see the complete set of Method/Model combinations included in this version of the code, open the folder `Code`. Here there is a folder called `Method` which contains one subfolder for each method and `Model` which likewise contains one subfolder for each model containing the model definition and the files we have been editing (such as `model_parameters.m` and `set_model.m`). In this way, the file structure allows you to see which options are available. The structure of the code is depicted in the [CodeStructure](Code/CodeStructure) diagram.


## Step 6. Step-by-step estimation of the 7 RORC parameters

To perform a step-by-step estimatin, we can use the iterative `main.m`, rather than `main_one.m`. The aim here is to parameterise an equivalent circuit model `RORC` consisting of a resistor, an OCV source and an RC pair in series. The `RORC` has 6 unknown parameters by default, namely the negative electrode capacity (`Qn`), negative/positive electrode capacity ratio (`nu`), cyclable lithium/positive electrode capacity ratio (`miu`), RC-pair time constant (`tau1`), RC-pair capacitance (`C1`), and the series resistance (`Rs`).

By considering the form of the model, we find that different subsets of these parameters are idenitifable from different measurements, e.g. from a pseudo-OCV measurement we cannot identify the dynamic parameters but the electrode stoichiometry parameters (`Qn`, `nu` and `miu`), which control the relative ``stretch and shift`` of the electrode OCPs, can be reliably estimated. The example dataset `Raj2020_Tests.parquet`, stored in Data/Examples, contains battery test data from a pseudo-OCV measurement as well as CCCV capacity tests and relaxation periods. In this example, we identify the 6 parameters using 3 steps:

1. Identify the electrode stoichiometry parameters (`Qn`, `nu` and `miu`) from the charging branch of the pseudo-OCV measurement found under `Cycle_Index==0` and `Step_Index==10` in the Dataset. Label this dataset with `DataType = 'Pseudo-OCV charge'`.
2. Identify the RC-pair time constant (`tau1`) from the relaxation step found under `Cycle_Index==0` and `Step_Index==5`. Label this dataset with `DataType = 'Relaxation'`.
3. Identify the dynamic parameters (`C1` and `Rs`) from the second CCCV capacity test found under `Cycle_Index==0` and `Step_Index==6`. Label this dataset with `DataType = 'CCCV charge'`.

Note that, in practice, there is a difference between the value of the negative electrode capacity (`Qn`) determined from a pseudo-OCV measurement and from a dynamic measurement. This discrepancy may arise from voltage hysteresis or measurement error. In order to deal with this discrepancy in a principled way and prevent it from affecting the estimation of the dynamic parameters, we compute a coulombic efficiency `CE` equal to the ratio between the integrated charge throughput during a dynamic charge/discharge measurement `QT` to the change in stored charge expected from the corresponding change in steady-state voltage (given the OCV function). This parameter is computed within [`unpack_data.m`](Code/Common/Functions/unpack_data.m) and passed to the parameter set by [`inform_params.m`](Code/Common/Functions/inform_params.m).

In order to perform this step-by-step estimation, `open cell_parameters` and uncomment the lines:
```
if j==1
    cycle_step = [0;10];
    DataType = 'Pseudo-OCV charge';
elseif j==2
    cycle_step = [0;5];
    DataType = 'Relaxation';
elseif j>2
    cycle_step = [0;6];
    DataType = 'CCCV charge';
end
```

Now we are ready to run the 3-step estimation of the `RORC` parameters using `out = main;`. There is no need to pass any dataset this time because `main.m` locates and loads the Dataset using the index of available datasets in Data/Examples/Test_Index.parquet. Feel free to use this parquet table as a template to store details of your own datasets.


## Step 7. Step-by-step estimation of the 7 EHM parameters

Finally, let's parameterise the equivalent hydraulic model  (`EHM`) with constant temperature. The `EHM` has 7 unknown parameters by default, namely the negative electrode capacity (`Qn`), negative/positive electrode capacity ratio (`nu`), cyclable lithium/positive electrode capacity ratio (`miu`), diffusion time constant (`tau_ref`), negative electrode surface/particle volume ratio (`b`), reference exchange current in the positive electrode (`Ip_ref`), reference exchange current in the negative electrode (`In_ref`), and the film resistance (`Rf`).

In this example, we identify the 7 parameters using a similar set of steps:

1. Identify the electrode stoichiometry parameters (`Qn`, `nu` and `miu`) from the `Pseudo-OCV charge` data.`
2. Identify the diffusion time constant (`tau_ref`) from the relaxation step from the `Relaxation` data.
3. Identify the dynamic parameters (`b`,`In_ref` and `Rf`, but not `Ip_ref` because it is unidentifiable from this dataset) from the `CCCV charge` data.

Again, we also compute a coulombic efficiency `CE` to cope with any discrepancy in charge throughtput due to model or experimental error.

Run the 3-step estimation of the `EHM` parameters using `out = main;` and find the output saved in /Data.


# How to Edit the Input Files

There are a number of input files that can be modified. The input files which are common to all Models are [cell_parameters.m](Code/Common/cell_parameters.m) and [cell_protocol.m](Code/Common/cell_protocol.m). The input files which are specific to each Model are `model_parameters.m` and `set_model.m`.

## a) How to Change the Input Profiles

The input profiles for current (and optionally also ambient temperature and voltage) can be changed within [cell_protocol.m](Code/Common/cell_protocol.m). The inputs can be entered as functions or vectors of points corresponding to the time points `tt`. Note however, that if any Dataset is specified, then the inputs will be taken directly from the Dataset instead.

## b) How to Change the Simulation Settings/Parameters

To change a setting or a value of a model-specific parameter, locate and edit the Model/ `model_parameters.m` file. The code is not guaranteed to obtain a solution for all combinations of parameter values and simulations protocols, please refer to the section on Common Errors for advice on avoiding known causes of failure.

## c) How to Change which Parameters to Estimate

The choice of parameters to estimate is made according to the uncertainty valuse in `uncert` vector in the Model/ `set_model.m`. Any variables with an uncertainty of zero will not be estimated to reduce the computation time.

## d) How to Import a Dataset

Data can be imported into MATLAB from a number of different file formats. For analysis via `unpack_data.m`, the data must be converted to a MATLAB table with the expected set of column headers. See the [DATA_PREP_GUIDE](Data/DATA_PREP_GUIDE.md) for guidelines on the expected data import process.

## e) How to Change the Electrode OCP Functions

Depending on the model it is necessary to either define one OCV function or two electrode OCPs as functions of stoichiometry. These functions can be define using Matlab .m functions or by loading from data. In either case, store the functions or data somewhere on the file path (e.g. Data/Examples) and define the `OCP_filename`(s) in [cell_parameters.m](Code/Common/cell_parameters.m). The selected functions are later passed to optimiser via the common function [OCV_function.m](Code/Common/Functions/OCV_function.m) or [electrode_potentials.m](Code/Common/Functions/electrode_potentials.m).


# How to Edit or Create a Model

Duplicate an existing Model by simply making a copy of one of the existing Model sufolders. Rename the subfolder with the name of your new model, then edit the model file-by-file, starting with the model definition in `set_model.m`. The first state should be the state of charge and the last line(s) should be the output, with the voltage as the first output. The first parameter should be the negative electrode stoichiometry `Qn` on which the state of charge is based.


# How to Analyse the Output

The solution is saved into one output file. This output table contains all the model parameters and can be saved using [save_output.m](Code/Common/Functions/save_output.m). Multiple saved output files can be compiled into one table using [compile_output.m](Code/Common/Postprocessing/compile_output.m).


# Common Errors

Please report any unexpected errors by creating an Issue on the GitHub website, add details of the problem (including the error message and MATLAB version number). For other enquiries, please contact nicola.courtier(at)eng.ox.ac.uk.


# How to Cite this Code

Please cite the Zenodo DOI (coming soon).

