%% test screen flip with version of MGL / metal
%
% ds 2023-02-03

mglOpen()
mglVisualAngleCoordinates(57,[16 12]);
mglVFlip
mglTextSet('Helvetica',32,[1 1 1],0,0,0,0,0,0,0);
mglTextDraw('Vertically flipped',[0 0]);
mglFlush;

%%
mglClose
