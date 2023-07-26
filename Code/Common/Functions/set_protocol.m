function params = set_protocol(params,sol)
% A function to either set manually or load the protocol from data.
% Note that the input(s) uu are dimensionless. Time is in seconds.
% The vectors must be column vectors.

if nargin==1
    % Load parameters
    [mn, hr, Crate, Um, Vcut, Vrng, CtoK, TtoK, Trng] = ...
        struct2array(params, {'mn','hr','Crate','Um','Vcut','Vrng', ...
                              'CtoK','TtoK','Trng'});
    
    % Manually define or load the protocol
    [tt, uu] = cell_protocol(params);
    
    % Rescale the inputs
    uu(:,1) = uu(:,1)/Um;
    uu(:,2) = (uu(:,2)+CtoK-TtoK)/Trng;
    uu(:,3) = (uu(:,3)-Vcut)/Vrng;
    

elseif nargin==2
    % Extract the protocol
    tt = sol.tsol;
    uu = sol.usol;
    
    % Update the initial conditions
    params = set_initial_states(params,sol);
    
else
    error('Unexpected number of inputs.');
    
end

% Make sure that the vectors are column vectors
if size(tt,2)>1 || size(uu,1)~=size(tt,1)
    error('The vectors ''tt'' and ''uu'' must be column vectors.');
end

% Pack up protocol
params.tt = tt; % time period (s)
params.uu(:,1) = uu(:,1); % dimensionless current (between -1 and 1)
params.uu(:,2) = uu(:,2); % dimensionless temperature (between 0 and 1)
params.uu(:,3) = uu(:,3); % dimensionless voltage (between 0 and 1)

end
