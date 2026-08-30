// Independent frequency-domain Maxwell benchmark for the finite PCB patch.
// Convention: exp(+i omega t), matching the official GetDP full-wave tutorial.
Group {
  Domain = Region[1000];
  Substrate = Region[1001];
  PortVol = Region[1002];
  PEC = Region[2000];
  ABC = Region[2002];
  Vol = Region[Domain];
  SurInf = Region[ABC];
  DomHcurl = Region[{Vol,SurInf}];
}

Function {
  eps0=8.8541878176e-12;
  mu0=4*Pi*1e-7;
  i[]=Complex[0,1];
  DefineConstant[
    f={2.4e9, Name "Parameters/Frequency [Hz]"},
    epsr={4.3, Name "Parameters/epsr"},
    feedw={2e-3, Name "Parameters/feed width [m]"},
    feedx={-6e-3, Name "Parameters/feed x [m]"},
    h={3e-3, Name "Parameters/substrate h [m]"}
  ];
  epsilon[Region[Domain]]=eps0;
  epsilon[Region[Substrate]]=epsr*eps0;
  epsilon[Region[ABC]]=eps0;
  mu[]=mu0;
  nu[]=1/mu0;
  omega=2*Pi*f;
  // 1-A impressed current through the feed prism: Jz=I/A.
  Jsrc[Region[PortVol]]=Vector[0,0,1/(feedw*feedw)];
}

Jacobian {
  { Name Jac;
    Case {
      { Region SurInf; Jacobian Sur; }
      { Region Vol; Jacobian Vol; }
    }
  }
}

Integration {
  { Name Int;
    Case {
      { Type Gauss;
        Case {
          { GeoElement Triangle; NumberOfPoints 4; }
          { GeoElement Tetrahedron; NumberOfPoints 4; }
        }
      }
    }
  }
}

Constraint {
  { Name eBC;
    Case {
      { Region PEC; Type Assign; Value 0.; }
    }
  }
}

FunctionSpace {
  { Name HcurlE; Type Form1;
    BasisFunction {
      { Name se; NameOfCoef ee; Function BF_Edge;
        Support DomHcurl; Entity EdgesOf[All]; }
    }
    Constraint {
      { NameOfCoef ee; EntityType EdgesOf; NameOfConstraint eBC; }
    }
  }
}

Formulation {
  { Name FullWave; Type FemEquation;
    Quantity {
      { Name e; Type Local; NameOfSpace HcurlE; }
    }
    Equation {
      Integral { [ nu[]*Dof{d e}, {d e} ]; In Vol; Integration Int; Jacobian Jac; }
      Integral { [ -omega^2*epsilon[]*Dof{e}, {e} ]; In Vol; Integration Int; Jacobian Jac; }
      // Official GetDP Silver-Muller sign for exp(+i omega t).
      Integral { [ i[]*omega*Sqrt[epsilon[]/mu[]]*Dof{e}, {e} ]; In SurInf; Integration Int; Jacobian Jac; }
      // curl nu curl E - omega^2 eps E = -i omega J.
      Integral { [ i[]*omega*Jsrc[], {e} ]; In PortVol; Integration Int; Jacobian Jac; }
    }
  }
}

Resolution {
  { Name Wav;
    System { { Name Sys; NameOfFormulation FullWave; Type Complex; } }
    Operation { Generate[Sys]; Solve[Sys]; SaveSolution[Sys]; }
  }
}

PostProcessing {
  { Name Wav; NameOfFormulation FullWave;
    Quantity {
      { Name e; Value { Term { [ {e} ]; In Vol; Jacobian Jac; } } }
    }
  }
}

PostOperation {
  { Name Port; NameOfPostProcessing Wav;
    Operation {
      Print[e, OnLine{{feedx,0,0}{feedx,0,h}}{31}, Format Table, File "port_line.txt"];
    }
  }
}
