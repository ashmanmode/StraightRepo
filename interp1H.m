function yi = interp1H(x,y,xi,dmy1,dmy2)
%   Fast linear interpolation for TANDEM-STRAIGHT
%   yi = interp1H(x,y,xi,dmy1,dmy2)
%   Note: This doesn't do any input check. Use with care.

%   Designed and coded by Hideki Kawahara
%   10/Dec./2007

deltaX = x(2)-x(1);
xi = max(x(1),min(x(end),xi));
xiBase = floor((xi-x(1))/deltaX);
xiFraction = (xi-x(1))/deltaX-xiBase;
deltaY = [diff(y);0];
yi = y(xiBase+1)+deltaY(xiBase+1).*xiFraction;