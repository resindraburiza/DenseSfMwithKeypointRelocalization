%SUBFIG   Pajdla: Opens figure in the specified part of the screen
%
%       function  f = subfig(rows,cols,ord,f)
%                           [left bottom height width]
%
%	rows	= number of row figures per screen
%	cols	= number of column figures per screen
%	ord	= order of figure (row oriented index), see SUBPLOT.
%	f	= figure handle
%
%       See also FIGURE, SUBPLOT.

%	Author: Tomas Pajdla, Tomas.Pajdla@esat.kuleuven.ac.be 
%			08/03/94 ESAT-MI2, KU Leuven
%	Documentation:                 	 	  
%	Language: 	Matlab 4.1, (c) MathWorks
%       Last change  : $Id: subfig.m,v 1.2 2005/09/24 14:39:15 pajdla Exp $
%       Status       : Ready ($Source: /home/cvs/Matlab/utils/subfig.m,v $)  			 
%
function f = subfig(rows,cols,ord,f)
if nargin < 4
    f	 = figure('Visible','off');
end
p = get(0,'userdata');
os = computer;
os = os(1:3);
if isfield(p,'screenposition');
    screen = getfield(p,'screenposition');
else
    screen = get(0, 'ScreenSize');
    switch os
        case 'MAC'
            screen = screen + [43  0 -43 -22];
        otherwise
            screen = screen + [ 0 23   0 -23];
    end
end
switch os
    case 'MAC'
        hSize = 17;
    otherwise
        hSize = 23;
end
if nargin > 2
    sW     = screen(3);
    sH     = screen(4);
    fW     = sW/cols;
    fH     = (sH+(rows-1)*hSize)/rows;
    i      = ceil(ord/cols);
    j      = rem(ord-1,cols);
    left   =             j * fW + screen(1);
    bottom = screen(2) + screen(4) - i * fH; 
else
    left   = rows(1)+screen(1);
    bottom = rows(2)+screen(2);
    fH     = rows(3);
    fW     = rows(4);
    f      = cols;
    i      = 1;
end
if i>1
    bottom = bottom + (i-1)*hSize;
end
set(f,'OuterPosition',[left bottom fW fH]);
set(f,'Visible','on');
return
