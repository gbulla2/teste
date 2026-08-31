SetFactory("OpenCASCADE");
mm=1e-3;
Lpatch=DefineNumber[22*mm, Name "Parameters/Lpatch"];
Wpatch=38.37*mm;
h=3*mm; feedx=-6*mm; feedw=2*mm;
boardL=78*mm; boardW=66*mm;
boxL=120*mm; boxW=104*mm; zbot=-24*mm; boxH=62*mm;
lc=5*mm; lcFine=2*mm;

Box(1)={-boxL/2,-boxW/2,zbot,boxL,boxW,boxH};
Box(2)={-boardL/2,-boardW/2,0,boardL,boardW,h};
Box(3)={feedx-feedw/2,-feedw/2,0,feedw,feedw,h};
v()=BooleanFragments{Volume{1,2,3}; Delete;}{};

Rectangle(100)={-Lpatch/2,-Wpatch/2,h,Lpatch,Wpatch};
v2()=BooleanFragments{Volume{v()}; Delete;}{Surface{100}; Delete;};

Physical Volume("Air",1000)={4};
Physical Volume("Substrate",1001)={5};
Physical Volume("PortVol",1002)={3};

gnd()=Surface In BoundingBox{-boardL/2-1e-7,-boardW/2-1e-7,-1e-7,boardL/2+1e-7,boardW/2+1e-7,1e-7};
pat()=Surface In BoundingBox{-Lpatch/2-1e-7,-Wpatch/2-1e-7,h-1e-7,Lpatch/2+1e-7,Wpatch/2+1e-7,h+1e-7};
Physical Surface("PEC",2000)={gnd(),pat()};

sx1()=Surface In BoundingBox{-boxL/2-1e-7,-boxW/2-1e-7,zbot-1e-7,-boxL/2+1e-7,boxW/2+1e-7,zbot+boxH+1e-7};
sx2()=Surface In BoundingBox{ boxL/2-1e-7,-boxW/2-1e-7,zbot-1e-7, boxL/2+1e-7,boxW/2+1e-7,zbot+boxH+1e-7};
sy1()=Surface In BoundingBox{-boxL/2-1e-7,-boxW/2-1e-7,zbot-1e-7,boxL/2+1e-7,-boxW/2+1e-7,zbot+boxH+1e-7};
sy2()=Surface In BoundingBox{-boxL/2-1e-7, boxW/2-1e-7,zbot-1e-7,boxL/2+1e-7, boxW/2+1e-7,zbot+boxH+1e-7};
sz1()=Surface In BoundingBox{-boxL/2-1e-7,-boxW/2-1e-7,zbot-1e-7,boxL/2+1e-7,boxW/2+1e-7,zbot+1e-7};
sz2()=Surface In BoundingBox{-boxL/2-1e-7,-boxW/2-1e-7,zbot+boxH-1e-7,boxL/2+1e-7,boxW/2+1e-7,zbot+boxH+1e-7};
Physical Surface("ABC",2002)={sx1(),sx2(),sy1(),sy2(),sz1(),sz2()};

// Use the four pre-existing vertical edges of the 2 mm x 2 mm port prism.
// They are already conformal with both the z=0 ground and z=h patch surfaces.
// One shared global coefficient on this group imposes the same terminal voltage
// on all four edge paths; the associated global current is their total current.
eps=1e-7;
xlo=feedx-feedw/2; xhi=feedx+feedw/2;
ylo=-feedw/2; yhi=feedw/2;
pe1()=Curve In BoundingBox{xlo-eps,ylo-eps,-eps,xlo+eps,ylo+eps,h+eps};
pe2()=Curve In BoundingBox{xlo-eps,yhi-eps,-eps,xlo+eps,yhi+eps,h+eps};
pe3()=Curve In BoundingBox{xhi-eps,ylo-eps,-eps,xhi+eps,ylo+eps,h+eps};
pe4()=Curve In BoundingBox{xhi-eps,yhi-eps,-eps,xhi+eps,yhi+eps,h+eps};
Physical Curve("PortEdge",3000)={pe1(),pe2(),pe3(),pe4()};

Mesh.MeshSizeMin=1*mm; Mesh.MeshSizeMax=lc;
Field[1]=Box; Field[1].VIn=lcFine; Field[1].VOut=lc;
Field[1].XMin=-boardL/2-5*mm; Field[1].XMax=boardL/2+5*mm;
Field[1].YMin=-boardW/2-5*mm; Field[1].YMax=boardW/2+5*mm;
Field[1].ZMin=-4*mm; Field[1].ZMax=9*mm;
Background Field=1;
