function [pcmd,dev] = printopt(varargin)
%PRINTOPT Printer defaults.
%	PRINTOPT is a MATLAB file that you or your system manager can
%	edit to indicate your default printer type and destination.
%
%	[PCMD,DEV] = PRINTOPT returns two strings, PCMD and DEV.
%	PCMD is a string containing the print command that
%	PRINT uses to spool a file to the printer. Its default is:
%
%	   Unix:      lpr -r
%	   Windows:   COPY /B LPT1:
%	   Macintosh: lpr -r (Mac OS X 10.2 and higher)
%                     Print -Mps (Mac OS X 10.1)
%
%   Note: Solaris users who do not use BSD printing, i.e. lpr,
%   need to  edit this file and uncomment the line to specify 'lp -c'.
%
%	DEV is a string containing the default device option for 
%	the PRINT command. Its default is:
%
%	   Unix:      -dps2
%	   Windows:   -dwin
%	   Macintosh: -dps2
%
%	See also PRINT.


%   Copyright 1984-2011 The MathWorks, Inc.
%   The MathWorks, Inc. grants permission for Licensee to modify
%   this file.  Licensee's use of such modified file is subject
%   to the terms and conditions of The MathWorks, Inc. Software License
%   Booklet.
%   

% Initialize options to empty matrices
pcmd = []; dev = [];

% This file automatically defaults to the dev and pcmd shown above
% in the online help text. If you would like to set the dev or pcmd
% default to be different from those shown above, enter it after this
% paragraph.  For example, pcmd = 'lpr -s -r -Pfred' would change the 
% default for Unix systems to send output to a printer named fred.
% Note that pcmd is ignored by the Windows drivers.
% See PRINT.M for a complete list of available devices.

%---> Put your own changes to the defaults here (if needed)

% ----------- Do not modify anything below this line ---------------
% The code below this line automatically computes the defaults 
% promised in the table above unless they have been overridden.

if isempty(pcmd)

    % For Unix and Mac OS X 10.2+
    pcmd = 'lpr -r';

    % For Windows
    if ispc
        def_printer = system_dependent('getdefaultprinter');
        if ~isempty(def_printer) && ~strcmp(def_printer,'FILE:')
            pcmd = ['COPY /B %s ' def_printer];
        else
            pcmd = 'COPY /B %s LPT1:'; 
        end
    end


    % For Solaris
    %cname = computer;
    %if strcmp(cname(1:3),'SOL'), pcmd = 'lp -c'; end
end

if isempty(dev)

    % For Windows
    if ispc
       dev = '-dwin'; 
    else
    % For Unix, and Macintosh
       if nargin 
          usingMATLABClasses = (graphicsversion(varargin{1}, 'handlegraphics') ~= 1); 
       else 
          usingMATLABClasses = feature('HGUsingMATLABClasses');
       end
       if ~usingMATLABClasses
           dev = '-dps2';
       else
           dev = '-dprn'; 
       end
    end
end
