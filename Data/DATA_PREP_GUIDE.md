# Data Preparation Guide

This guide explains how to prepare your battery cycler data as an input to be analysed using this code.

## Contents

- Battery cycler data

- How to convert data into the Parquet file format

- How the code imports the data into Matlab

- Example data


# Battery cycler data

Time series data from a battery cycler is usually saved as columnar data, including common fields (in any order) such as (or similar to):
- Test_Time_s
- Cycle_Index
- Step_Index
- Current_A
- Voltage_V
- Temperature_C

The temperature data is assumed to correspond to the ambient temperature unless an External_Temp_C is also defined, in which case Temperature_C is assumed to be surface temperature data and External_Temp_C becomes the ambient temperature.

The Cycle_Index and Step_Index are required for identifying and extracting certain steps in the experiment protocol (such as a charging phase). The cycle and step numbers defined in `cell_parameters.m` are used to locate and load only the relevant rows of data corresponding to the chosen cycle and step. If your data does not contain informative cycle and step numbers, you are advised to add this systematically using, for example, Matlab's `find` to locate the ``first`` and ``last`` rows which satisfy appropriate logical expressions relating to each step.


# How to convert data into the Parquet file format

If you have your data stored in another file format such as CSV or NPY, then it is helpful to convert this data into the compressed, but easily accessible Parquet file format for faster loading and smaller file sizes.

To do this, please see our [file-format-conversion](https://github.com/Battery-Intelligence-Lab/file-format-conversion) repository.


# How the code imports the data into Matlab

Any Parquet file including columns for time, cycle number, step number, current, voltage and (optionally) temperature can be loaded into Matlab using the `import_parquet.m` function which can be found in Data/Examples (or Matlab's `parquetread` if the file already has the column names expected by the code). The `import_parquet.m` function takes a file name as its only input and can be edited to cope with a different set of column names.

To modify the column names according to the data you have, open `import_parquet.m` and modify the list of names in `column_names_from_file`. To load your data, define the `filename` as a string and then enter `Dataset = import_parquet(filename);` into the command line. This will load your Parquet file as a table called `Dataset`.

The `Dataset` table can be passed to the `main.m` function of the code as an input. Within the code, the contents of the table are loaded into a structure (called `true_sol`) using the `unpack_data.m` function which can be found in Code/Common/Functions.


# Example data

Some example datasets are stored in Data/Examples. Please see Data/Examples/README for more information about the source of the data.
