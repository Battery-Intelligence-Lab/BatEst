function save_plot(fighandle,filename,overwrite)
% A function to save a Matlab figure as both a .fig and .png. The inputs
% are the figure handle, the desired name (and path) of the figure and the
% option to overwrite any existing files.

if nargin==2
    overwrite = false;
end

if ~overwrite && isfile([filename '.fig'])
    warning('This file already exists, do you want to overwrite it?');
    OK = input('Overwrite? Y=1/N=0 \n');
else
    OK = true;
end

if OK
    saveas(fighandle,[filename '.fig'])
    saveas(fighandle,[filename '.png'])
    close(figure(fighandle));
else
    warning('File was not saved.');
end

end
