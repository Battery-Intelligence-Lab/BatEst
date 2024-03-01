function SOC = initial_SOC(params,V,SOCest)
% A function to estimate the steady-state SOC from a known voltage. The
% inputs are the parameters structure params, the voltage V, and the SOC
% estimate SOCest. UpFun and UnFun are the positive and negative half-cell
% OCPs as functions of the SOC (based on the negative electrode).

% Unpack parameters
[nu, miu, UpFun, UnFun, OCV] = ...
    struct2array(params, {'nu','miu','UpFun','UnFun','OCV'});

% Estimate the equilibrium SOC corresponding to the given voltage
opts = optimoptions('fsolve','Display','off');
if isa(OCV,'function_handle')
    [SOC, ~, exitflag] = fsolve(@(x) OCV(x,nu,miu)-V,SOCest,opts);
else
    [SOC, ~, exitflag] = fsolve(@(x) UpFun(x,nu,miu)-UnFun(x)-V,SOCest,opts);
end
if exitflag<0
    error(['Initial SOC not found: fsolve returned exitflag' num2str(exitflag)]);
end

end
