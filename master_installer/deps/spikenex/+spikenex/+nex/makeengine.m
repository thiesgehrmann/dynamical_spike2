function makeengine
% MAKEENGINE  Builds the NEX I/O mex file.
%
% Syntax:
% MAKEENGINE
%
% Description:
% Nex I/O functionality is driven by a mex file.  This function builds the
% mex files for the current system (Windows, Mac, or Linux).  The mex file
% will be called nexengine and created in the +nex directory.

% Get the full path to where the source code is.
w = what('+nex');
srcPath = fullfile(w.path, 'src');

% Path to the local header files.
includePath = sprintf('-I%s', srcPath);

% Name of the primary .cpp file.
mainCPP = fullfile(srcPath, 'nexengine.cpp');

% Output directory of the mex binary, i.e. the compiled engine.
outputDir = sprintf('-outdir %s', w.path);

% f = sprintf('mex -v %s -largeArrayDims %s %s', outputDir, includePath, mainCPP);
% eval(f);
feval(@mex, '-largearraydims', '-v', includePath, '-outdir', outputDir, mainCPP);
