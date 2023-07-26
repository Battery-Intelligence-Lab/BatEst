function CSC = initial_CSC(params,V,SOCest)
% A function to estimate the CSC from a known voltage and SOC value. The
% inputs are the parameters structure params, the voltage V, and the SOC
% estimate SOCest. UpFun and UnFun are the positive and negative half-cell
% OCPs as functions of the SOC (based on the negative electrode).

% Unpack parameters
[nu, miu, UpFun, UnFun, OCV] = ...
    struct2array(params, {'nu','miu','UpFun','UnFun','OCV'});

% Estimate the equilibrium SOC corresponding to the given voltage
opts = optimoptions('fsolve','Display','off');
if isa(OCV,'function_handle')
    CSC = SOCest;
else
    CSC = fsolve(@(x) UpFun(SOCest,nu,miu)-UnFun(x)-V,SOCest,opts);
end

end
