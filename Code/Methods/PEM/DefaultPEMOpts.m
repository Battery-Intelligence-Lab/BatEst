function [SimOpts, EstOpts] = DefaultPEMOpts
% Set the default simulation options for PEM.

SimOpts = struct('Solver','Auto', 'RelTol',1e-3, 'AbsTol',1e-5, ...
                 'MinStep','Auto', 'MaxStep','Auto', 'MaxOrder',3, ...
                 'InitialStep','Auto', 'FixedStep','Auto');

EstOpts = nlgreyestOptions('Display','on', ...
                           'SearchMethod','lsqnonlin', ...
                           'EstimateCovariance',false);

Advanced = optimset('lsqnonlin');
Advanced.TolFun = 1e-3;
Advanced.TolX = 1e-3;
Advanced.MaxIter = 20;
EstOpts.SearchOptions.Advanced = Advanced;
EstOpts.SearchOptions.FunctionTolerance = Advanced.TolFun;
EstOpts.SearchOptions.StepTolerance = Advanced.TolX;
EstOpts.SearchOptions.MaxIterations = Advanced.MaxIter;

EstOpts.GradientOptions.MinDifference = 1e-5;

end
