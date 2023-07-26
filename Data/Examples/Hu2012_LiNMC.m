function OCV = Hu2012_LiNMC
% An example OCV function taken from equation (21) of this paper:
% A. Aitio and D. A.Howey, Proceedings of the ASME 2020, Dynamic Systems
% and Control Conference, 2020. doi.org/10.1115/DSCC2020-3180.

OCV = @(soc,nu,miu) 3.64+0.55*soc-0.72*soc.^2+0.75*soc.^3;

end
