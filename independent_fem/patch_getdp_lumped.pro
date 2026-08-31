// Full-wave Maxwell FEM with an explicit two-terminal voltage port.
// Convention exp(+i omega t).
// The single conformal PortEdge replaces one ordinary edge DOF by a global
// terminal-voltage DOF V.  Its energy-dual global unknown I is the terminal
// current.  This is the discrete saddle-point/circuit formulation
//
//        A e + i*omega*c I = 0
//        c^T e               = -Vp
//
// where c is the Nedelec basis associated with the bottom-to-top port edge.
Group {
  Air = Region[1000];
  Substrate = Region[1001];
  PortVol = Region[1002];
  PEC = Region[2000];
  ABC = Region[2002];
  PortEdge = Region[3000];
  Vol = Region[{Air,Substrate,PortVol}];
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
    Vp={1.0, Name "Parameters/terminal voltage patch-ground [V]"}
  ];
  epsilon[Air]=eps0;
  epsilon[Substrate]=epsr*eps0;
  epsilon[PortVol]=epsr*eps0;
  epsilon[ABC]=eps0;
  mu[]=mu0;
  nu[]=1/mu0;
  omega=2*Pi*f;
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
  // PortEdge is oriented from ground (z=0) to patch (z=h).  The Nedelec
  // coefficient is integral E.dl, while V_patch-ground=-integral E.dl.
  { Name PortVoltage;
    Case {
      { Region PortEdge; Type Assign; Value -Vp; }
    }
  }
  { Name PortCurrent; Case { } }
}

FunctionSpace {
  { Name HcurlE; Type Form1;
    BasisFunction {
      // Ordinary edge basis everywhere except the dedicated terminal edge.
      { Name se; NameOfCoef ee; Function BF_Edge;
        Support DomHcurl; Entity EdgesOf[All, Not PortEdge]; }
      // The port edge is represented by a single global voltage coefficient.
      { Name sp; NameOfCoef vp; Function BF_GroupOfEdges;
        Support DomHcurl; Entity GroupsOfEdgesOf[PortEdge]; }
    }
    GlobalQuantity {
      { Name Voltage; Type AliasOf; NameOfCoef vp; }
      { Name Current; Type AssociatedWith; NameOfCoef vp; }
    }
    Constraint {
      { NameOfCoef ee; EntityType EdgesOf; NameOfConstraint eBC; }
      { NameOfCoef Voltage; EntityType GroupsOfEdgesOf; NameOfConstraint PortVoltage; }
      { NameOfCoef Current; EntityType GroupsOfEdgesOf; NameOfConstraint PortCurrent; }
    }
  }
}

Formulation {
  { Name FullWave; Type FemEquation;
    Quantity {
      { Name e; Type Local; NameOfSpace HcurlE; }
      { Name V; Type Global; NameOfSpace HcurlE [Voltage]; }
      { Name I; Type Global; NameOfSpace HcurlE [Current]; }
    }
    Equation {
      Integral { [ nu[]*Dof{d e}, {d e} ]; In Vol; Integration Int; Jacobian Jac; }
      Integral { [ -omega^2*epsilon[]*Dof{e}, {e} ]; In Vol; Integration Int; Jacobian Jac; }
      // Silver-Muller for exp(+i omega t): +i*k/mu * <Et,Et'>.
      Integral { [ i[]*omega*Sqrt[epsilon[]/mu[]]*Dof{e}, {e} ]; In SurInf; Integration Int; Jacobian Jac; }
      // Energy-dual terminal current.  This is the +i*omega*c*I block.
      GlobalTerm { [ i[]*omega*Dof{I}, {V} ]; In PortEdge; }
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
      { Name V; Value { Term { [ {V} ]; In PortEdge; } } }
      { Name I; Value { Term { [ {I} ]; In PortEdge; } } }
    }
  }
}

PostOperation {
  { Name Port; NameOfPostProcessing Wav;
    Operation {
      Print[V, OnRegion PortEdge, Format RegionTable, File "port_V.txt"];
      Print[I, OnRegion PortEdge, Format RegionTable, File "port_I.txt"];
    }
  }
}
