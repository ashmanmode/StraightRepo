function distanceToLine = proximityToSegment(x1,x2,y1,y2,x,y)
lineLength = sqrt((x1-x2)^2+(y1-y2)^2);
edge1Length = sqrt((x1-x)^2+(y1-y)^2);
edge2Length = sqrt((x2-x)^2+(y2-y)^2);
if (lineLength^2+edge2Length^2<edge1Length^2)+...
        (lineLength^2+edge1Length^2<edge2Length^2) % I was silly....
    distanceToLine = max([lineLength edge1Length edge2Length]);
    return;
end;
xp2 = x2-x1;
if xp2 == 0
    distanceToLine = abs(x-x1);
    return;
end;
yp2 = y2-y1;
xp = x-x1;
yp = y-y1;
a = yp2/xp2;
xx = (xp+yp*a)/(1+a^2);
l2 = (xp-xx)^2+(yp-a*xx)^2;
distanceToLine = sqrt(l2);