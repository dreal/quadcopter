(* *)
ClearAll["Global`*"];


Ix = 7.5*10^(-3); 
Iy = 7.5*10^(-3);  
Iz = 1.3*10^(-2);  
Jr = 6.5*10^(-5);  
b = 3.13*10^(-5);  
d = 7.5*10^(-7);   
l = 0.23;          
m = 0.65;          
g = 9.81;          
dt = 0.01;         


phidot = x4; thetadot = x5; psidot = x6;
phi = x1; theta = x2; psi = x3;

(*phidot*)		x1dot = f1;
(*thetadot*)		x2dot = f2;
(*psidot*)		x3dot = f3;
(*phidotdot*)		x4dot = f4;
(*thetadotdot*)		x5dot = f5;
(*psidotdot*)		x6dot = f6;
(*xdot*)		x7dot = f7;
(*ydot*)		x8dot = f8;
(*zdot*)		x9dot = f9;
(*xdotdot*)		x10dot = f10;
(*ydotdot*)		x11dot = f11;
(*zdotdot*)		x12dot = f12;

f1 = x4 + G1;
f2 = x5 + G2;
f3 = x6 + G3;
f4 = ( ((Iy - Iz)/Ix)*(thetadot)*(psidot)) + (Jr/Ix *thetadot*Omega)+ G4;
f5 = ( ((Iz - Ix)/Iy )*(phidot)*(psidot)) - ((Jr/Iy)*phidot*Omega) + G5 ;
f6 = ( ((Ix - Iy)/Iz)*(phidot)*(thetadot)) + G6;
f7 = x10 + G7;
f8 = x11 + G8;
f9 = x12 + G9;
f10 = G10;
f11 = G11;
f12 = g - G12;

(**** Input scheme ****)
G1 = 0
G2 = 0
G3 = 0
G4 = (l/Ix)*u22;
G5 = (l/Iy*u32);
G6 = u42*(1/Iz);
G7 = 0;
G8 = 0;
G9 = 0;
G10 = ((Cos[phi]*Sin[theta]*Cos[psi]) + Sin[phi]*Sin[psi])*(u12/m);
G11 = ((Cos[phi]*Sin[theta]*Sin[psi]) - (Sin[phi]*Cos[psi]))*(u12/m);
G12 = ((u12)/m)*Cos[phi]*Cos[theta];

Omega = d*omegasqr5;
omegasqr5 = -omegasqr1 + omegasqr2 - omegasqr3 + omegasqr4;
omegasqr1 = (U1/(4*b)) + (U3/(2*b*l)) - (U4/(4*d));
omegasqr2 = (U1/(4*b)) - (U2/(2*b*l)) + (U4/(4*d));
omegasqr3 = (U1/(4*b)) - (U3/(2*b*l)) - (U4/(4*d));
omegasqr4 = (U1/(4*b)) + (U2/(2*b*l)) + (U4/(4*d));

u12 = (b)*(omegasqr1 + omegasqr2 + omegasqr3 + omegasqr4);
u22 = (b)*(-omegasqr2 + omegasqr4);
u32 = (b)*(omegasqr1 - omegasqr3);
u42 = (d)*(-omegasqr1 + omegasqr2 -omegasqr3 + omegasqr4);
(***********************************************************)

f = {f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12};
X = {x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12};
U = {U1, U2, U3, U4};

zx = {x1->0, x2->0, x3->0, x4->0, x5->0, x6->0, x7->0, x8->0, x9->0, x10->0, x11->0, x12->0};
(* *)
f1zx = f1/.zx; f2zx = f2/.zx; f3zx = f3/.zx; f4zx = f4/.zx; f5zx = f5/.zx; f6zx = f6/.zx; f7zx = f7/.zx; f8zx = f8/.zx; f9zx = f9/.zx; f10zx = f10/.zx; f11zx = f11/.zx; f12zx = f12/.zx; 

zu = Flatten[FindInstance[(f1zx == 0) && (f2zx == 0) && (f3zx == 0) && (f4zx == 0) && (f5zx == 0) && (f6zx == 0) && (f7zx == 0) && (f8zx == 0) && (f9zx == 0) && (f10zx) == 0 && (f11zx) == 0 && (f12zx) == 0 , U, Reals]];

zxu = Join[ zx, zu ]


dfdX = Grad[f, X];
dfdU = Grad[f, U];

A0 = dfdX/.zxu;
B0 = dfdU/.zxu;

ssm = StateSpaceModel[ {A0, B0} ];
ctrb = MatrixRank[ ControllabilityMatrix[ ssm ] ];

Q = 100*IdentityMatrix[12];
R = 1*IdentityMatrix[4];


K = LQRegulatorGains[ ssm, {Q, R} ];

Acl = A0 - B0.K
P = LyapunovSolve[Transpose[Acl], -IdentityMatrix[12] ];

