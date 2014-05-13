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
gravity = 9.81;          
dt = 0.01;         


phidot = x4; thetadot = x5; psidot = x6;
phi = x1; theta = x2; psi = x3;

(*phidot*)		x1dot	= f1	+	g1.U;
(*thetadot*)		x2dot	= f2	+	g2.U;
(*psidot*)		x3dot	= f3	+	g3.U;
(*phidotdot*)		x4dot	= f4	+	g4.U;
(*thetadotdot*)		x5dot	= f5	+	g5.U;
(*psidotdot*)		x6dot	= f6	+	g6.U;
(*xdot*)		x7dot	= f7	+	g7.U;
(*ydot*)		x8dot	= f8	+	g8.U;
(*zdot*)		x9dot	= f9	+	g9.U;
(*xdotdot*)		x10dot	= f10	+	g10.U;
(*ydotdot*)		x11dot	= f11	+	g11.U;
(*zdotdot*)		x12dot	= f12	+	g12.U;

f1 = x4;
f2 = x5;
f3 = x6;
f4 = ( ((Iy - Iz)/Ix)*(thetadot)*(psidot)) + (Jr/Ix *thetadot*Omega);
f5 = ( ((Iz - Ix)/Iy )*(phidot)*(psidot)) - ((Jr/Iy)*phidot*Omega);
f6 = ( ((Ix - Iy)/Iz)*(phidot)*(thetadot));
f7 = x10;
f8 = x11;
f9 = x12;
f10 = 0;
f11 = 0;
f12 = gravity;

(**** Input scheme ****)
g1 = {0, 0, 0, 0};
g2 = {0, 0, 0, 0};
g3 = {0, 0, 0, 0};
g4 = {0, (l/Ix), 0, 0};
g5 = {0, 0, (l/Iy), 0};
g6 = {0, 0, 0, (1/Iz)};
g7 = {0, 0, 0, 0};
g8 = {0, 0, 0, 0};
g9 = {0, 0, 0, 0};
g10 = {((Cos[phi]*Sin[theta]*Cos[psi]) + Sin[phi]*Sin[psi])*(1/m), 0, 0, 0};
g11 = {((Cos[phi]*Sin[theta]*Sin[psi]) - (Sin[phi]*Cos[psi]))*(1/m), 0, 0, 0};
g12 = -{((11)/m)*Cos[phi]*Cos[theta], 0, 0, 0};

Omega = u42;

f = {f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12};
g = {g1, g2, g3, g4, g5, g6, g7, g8, g9, g10, g11, g12};
X = {x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12};
U = {u12, u22, u32, u42};
G1 = g[[All, 1]]
G2 = g[[All, 2]]
G3 = g[[All, 3]]
G4 = g[[All, 4]]

zx = {x1->0, x2->0, x3->0, x4->0, x5->0, x6->0, x7->0, x8->0, x9->0, x10->0, x11->0, x12->0};
zu = {u12->0, u22->0, u32->0, u42->0};
zxu = {x1->0, x2->0, x3->0, x4->0, x5->0, x6->0, x7->0, x8->0, x9->0, x10->0, x11->0, x12->0, u12->0, u22->0, u32->0, u42->0};

h1 = x7;  h2 = x8; h3 = x9; h4 = x3;

Lfh1 = Grad[ h1, X ].f
Lfh2 = Grad[ h2, X ].f
Lfh3 = Grad[ h3, X ].f
Lfh4 = Grad[ h4, X ].f

(* Lg_i h1 *)
Lg1h1 = Grad[h1, X].G1;
Lg2h1 = Grad[h1, X].G2;
Lg3h1 = Grad[h1, X].G3;
Lg4h1 = Grad[h1, X].G4;

(* Lg_i 2 h1 *)
LfTWOh1 = Grad[ Lfh1, X ].f
Lg1TWOh1 = Grad[Lfh1, X].G1;
Lg2TWOh1 = Grad[Lfh1, X].G2;
Lg3TWOh1 = Grad[Lfh1, X].G3;
Lg4TWOh1 = Grad[Lfh1, X].G4;
(* Lg_i h1 *)
LfTHREEh1 = Grad[ LfTWOh1, X ].f
Lg1THREEh1 = Grad[LfTWOh1, X].G1;
Lg2THREEh1 = Grad[LfTWOh1, X].G2;
Lg3THREEh1 = Grad[LfTWOh1, X].G3;
Lg4THREEh1 = Grad[LfTWOh1, X].G4;

(* Lg_i h1 *)
LfTHREEh1 = Grad[ LfTWOh1, X ].f
Lg1FOURh1 = Grad[LfTHREEh1, X].G1;
Lg2FOURh1 = Grad[LfTHREEh1, X].G2;
Lg3FOURh1 = Grad[LfTHREEh1, X].G3;
Lg4FOURh1 = Grad[LfTHREEh1, X].G4;


(*gamma1 = 

A = {
	{   },
	{   },
	{   },
	{   },
};*)
	




		
