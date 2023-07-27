The Data/Examples/ folder contains example datasets which can be used to test the code.

Datasets in the parquet file format can be loaded into Matlab using the command:
`Dataset = import_parquet('Name_of_Dataset.parquet');`
Note that `import_parquet` is an alternative to Matlab's `parquetread` which can be used in cases where it is undesirable to rename the column variables in the file.
See Data/DATA_PREP_GUIDE for more information.

The datasets are:

- `Raj2020_NCA.parquet` contains data from [1] for the open-circuit potential (OCP) as a function of stoichiometry for the positive electrode
- `Raj2020_Graphite.parquet` contains data from [1] for the open-circuit potential (OCP) as a function of stoichiometry for the negative electrode
- `Test_Index.parquet` is a table containing the metadata for the following tests
- `Raj2020_Tests.parquet` contains data from [1] for a pseudo-OCV measurement two CCCV capacity tests
- `Raj2020_Cycling.parquet` contains data from [1] for some discharge/charge cycling tests
These datatsets are taken from Trishna Raj's public data [1] which is available from the Oxford Research Archive at:
https://ora.ox.ac.uk/objects/uuid:de62b5d2-6154-426d-bcbb-30253ddb7d1e
Specifically, the half-cell data is from CH_HC_cathode and DCH_HC_anode, and the full-cell test data is extracted from Group 2, Cell 3, files TPG2-Cell3 and TPG2.03-Cell3. Please cite the reference if you use this data in your research.

Note that `Test_Index.parquet` can be used as a template for listing additional test datasets.

- `LGM50_NMC811.m` is a function for the open-circuit potential (OCP) as a function of stoichiometry for the positive electrode in an LGM50 cell
- `LGM50_GraphiteSiOx.m` is a function for the open-circuit potential (OCP) as a function of stoichiometry for the negative electrode in an LGM50 cell
These functions are taken from equations (8)-(9) of reference [2],

- `Hu2012_LiNMC.m` is a function for the open-circuit voltage (OCV) as a function of state of charge taken from equation (21) of reference [3].

References:
[1] T. Raj, Path Dependent Battery Degradation Dataset Part 1, University of Oxford (2020). doi.org/10.1002/batt.202000160.
[2] C.-H. Chen et al., Journal of The Electrochemical Society, 167:080534 (2020). doi.org/10.1149/1945-7111/ab9050.
[3] A. Aitio and D. A. Howey, Proceedings of the ASME 2020, Dynamic Systems and Control Conference (2020). doi.org/10.1115/DSCC2020-3180.
