SetFactory("OpenCASCADE");
mm=1e-3;
Lpatch = DefineNumber[29.15*mm, Name "Parameters/Lpatch"];
Wpatch = DefineNumber[38.37*mm, Name "Parameters/Wpatch"];
h = 3*mm;
feedx = -6*mm;
feedw = 2*mm;
boardL=78*mm; boardW=66*mm;
boxL=120*mm; boxW=104*mm; zbot=-24*mm; boxH=62*mm;
lc=5*mm; lcFine=2.0*mm;

// Outer air and dielectric slab.  Fragmentation creates a conformal dielectric/air interface.
Box(1)={-boxL/2,-boxW/2,zbot,boxL,boxW,boxH};
Box(2)={-boardL/2,-boardW/2,0,boardL,boardW,h};
v() = BooleanFragments{ Volume{1}; Delete; }{ Volume{2}; Delete; };

// Embed a zero-thickness patch rectangle on the top dielectric interface so the mesh has its edges.
Rectangle(100)={-Lpatch/2,-Wpatch/2,h,Lpatch,Wpatch};
// Split the top interface by the patch surface.
vv() = BooleanFragments{ Volume{v()}; Delete; }{ Surface{100}; Delete; };

// Identify volumes geometrically after fragmentation.
sub() = Volume In BoundingBox{-boardL/2-1e-7,-boardW/2-1e-7,1e-7, boardL/2+1e-7,boardW/2+1e-7,h-1e-7};
allv() = Volume In BoundingBox{-boxL/2-1e-7,-boxW/2-1e-7,zbot-1e-7, boxL/2+1e-7,boxW/2+1e-7,zbot+boxH+1e-7};
Physical Volume("Domain",1000)={allv()};
Physical Volume("Substrate",1001)={sub()};

// PEC ground: dielectric lower face over board footprint.
gnd() = Surface In BoundingBox{-boardL/2-1e-7,-boardW/2-1e-7,-1e-7, boardL/2+1e-7,boardW/2+1e-7,1e-7};
// PEC patch: split portion of top interface.
pat() = Surface In BoundingBox{-Lpatch/2-1e-7,-Wpatch/2-1e-7,h-1e-7, Lpatch/2+1e-7,Wpatch/2+1e-7,h+1e-7};
Physical Surface("PEC",2000)={gnd(),pat()};

// Exterior absorbing boundary: all surfaces of outer box selected by bounding shells.
sx1()=Surface In BoundingBox{-boxL/2-1e-7,-boxW/2-1e-7,zbot-1e-7,-boxL/2+1e-7,boxW/2+1e-7,zbot+boxH+1e-7};
sx2()=Surface In BoundingBox{ boxL/2-1e-7,-boxW/2-1e-7,zbot-1e-7, boxL/2+1e-7,boxW/2+1e-7,zbot+boxH+1e-7};
sy1()=Surface In BoundingBox{-boxL/2-1e-7,-boxW/2-1e-7,zbot-1e-7,boxL/2+1e-7,-boxW/2+1e-7,zbot+boxH+1e-7};
sy2()=Surface In BoundingBox{-boxL/2-1e-7, boxW/2-1e-7,zbot-1e-7,boxL/2+1e-7, boxW/2+1e-7,zbot+boxH+1e-7};
sz1()=Surface In BoundingBox{-boxL/2-1e-7,-boxW/2-1e-7,zbot-1e-7,boxL/2+1e-7,boxW/2+1e-7,zbot+1e-7};
sz2()=Surface In BoundingBox{-boxL/2-1e-7,-boxW/2-1e-7,zbot+boxH-1e-7,boxL/2+1e-7,boxW/2+1e-7,zbot+boxH+1e-7};
Physical Surface("ABC",2002)={sx1(),sx2(),sy1(),sy2(),sz1(),sz2()};

// Current port is represented by the dielectric elements whose centroids lie in this small prism.
// We tag it through an additional volume intersected with the substrate.
Box(300)={feedx-feedw/2,-feedw/2,0,feedw,feedw,h};
pp()=BooleanFragments{ Volume{sub()}; Delete; }{ Volume{300}; Delete; };
port()=Volume In BoundingBox{feedx-feedw/2-1e-7,-feedw/2-1e-7,1e-7,feedx+feedw/2+1e-7,feedw/2+1e-7,h-1e-7};
Physical Volume("PortVol",1002)={port()};
// Re-identify all substrate pieces after source fragmentation.
sub2()=Volume In BoundingBox{-boardL/2-1e-7,-boardW/2-1e-7,1e-7, boardL/2+1e-7,boardW/2+1e-7,h-1e-7};
Physical Volume("SubstrateAll",1003)={sub2()};
all2()=Volume In BoundingBox{-boxL/2-1e-7,-boxW/2-1e-7,zbot-1e-7, boxL/2+1e-7,boxW/2+1e-7,zbot+boxH+1e-7};
Physical Volume("DomainAll",1004)={all2()};

Mesh.MeshSizeMin=1.2*mm;
Mesh.MeshSizeMax=lc;
Field[1]=Box; Field[1].VIn=lcFine; Field[1].VOut=lc; Field[1].XMin=-boardL/2-5*mm; Field[1].XMax=boardL/2+5*mm; Field[1].YMin=-boardW/2-5*mm; Field[1].YMax=boardW/2+5*mm; Field[1].ZMin=-4*mm; Field[1].ZMax=9*mm;
Background Field=1;
