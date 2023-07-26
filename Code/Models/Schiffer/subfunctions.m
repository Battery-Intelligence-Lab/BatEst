function params = subfunctions(params)
% A function that is used to load any subfunctions required by the model.
% Find the relevant subfunctions in the Code/Models/MODEL/subfunctions
% folder and in Code/Common/Functions.

% Define the open-circuit voltage (V) via a parameterised function
% Note that nu/miu are not used, but needed to keep number of inputs to 3
params.OCV = @(SOC,nu,miu) 1.92 + 0.15*log10(SOC) + 0.06*log10(SOC).^2 ...
                  + 0.07*log10(SOC).^3 + 0.03*log10(SOC).^4;
% params.OCVp = @(SOC) 1.628 + 0.074*log10(SOC) + 0.033*log10(SOC).^2 ...
%                   + 0.043*log10(SOC).^3 + 0.022*log10(SOC).^4;

end
