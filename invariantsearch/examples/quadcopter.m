clear all; close all;
addpath(genpath('..'));
tic;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
syms x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13;
X = [x1; x2; x3; x4; x5; x6; x7; x8; x9; x10; x11; x12; x13];

Ix  =   (7.5*10^(-3))
Iy  =   (7.5*10^(-3))
Iz  =   (1.3*10^(-2))
Jr  =   (6.5*10^(-5))
b   =   (3.13*10^(-5))
dia =   (7.5*10^(-7))
l   =   0.23
m   =   0.65
g   =   9.81

U1   = @(X) (0.000000000000000040040329806638157622061132068177*X(3) - 0.000000000000000004006260662349088113459483121302*X(6) + 0.000000000000000040199263120208627223437034754057*X(5) + 0.00000000000016481994537721932724351482870661*X(2) + 0.00000000000098891967226331596346108897223964*X(7) + 0.0000000000079113573781065277076887117779171*X(10) + 4.11553517599868712295574368909*X(9) + 2.5199605312384134592207374225836*X(12) + 3.1622776601683793319988935444327*X(13))

U2   = @(X) (189.73665961010275991993361266596*X(8) - 31.630275731249675175149604910985*X(4) - 31.622776601683793319988935444327*X(1) + 1517.8932768808220793594689013277*X(11))

U3   = @(X) (0.00000000000000070138917281910823366567033228324*X(6) + 0.00000000000000043749598496085489029482841870694*X(3) - 31.630275731249682280576962511986*X(5) - 31.622776601683793319988935444327*X(2) - 189.73665961010275991993361266596*X(7) - 1517.8932768808220793594689013277*X(10) - 0.0000000000000070356585091052359927346895193447*X(9) - 0.0000000000000034839309111753163949802837487703*X(12) - 0.000000000000011331008570360934389675285377061*X(13))

U4   = @(X) (0.00000000000000040464873271944341320474427745137*X(5) - 1.0*X(3) - 1.0129165771177819355131077827537*X(6) + 0.00000000000023878030692159577841250980175465*X(2) + 0.0000000000014326818415295746704750588105279*X(7) + 0.000000000011461454732236597363800470484223*X(10) - 0.00000000000000031636295750377493337137733115377*X(9) + 0.00000000000000020031329352465790704239314222127*X(12) - 0.00000000000000010038228518403374163714875500275*X(13))

omegasqr1   = @(X)  (U1(X)/(4*b)) + (U3(X)/(2*b*l)) - (U4(X)/(4*dia))
omegasqr2   = @(X)  (U1(X)/(4*b)) - (U2(X)/(2*b*l)) + (U4(X)/(4*dia))
omegasqr3   = @(X)  (U1(X)/(4*b)) - (U3(X)/(2*b*l)) - (U4(X)/(4*dia))
omegasqr4   = @(X)  (U1(X)/(4*b)) + (U2(X)/(2*b*l)) + (U4(X)/(4*dia))
omegasqr5   = @(X)  (-omegasqr1(X) + omegasqr2(X) - omegasqr3(X) + omegasqr4(X))
Omega       = @(X)  (dia*omegasqr5(X))

u12  = @(X) ((b)*(omegasqr1(X) + omegasqr2(X) + omegasqr3(X) + omegasqr4(X)))
u22  = @(X) ((b)*(-omegasqr2(X) + omegasqr4(X)))
u32  = @(X) ((b)*(omegasqr1(X) - omegasqr3(X)))
u42  = @(X) ((dia)*(-omegasqr1(X) + omegasqr2(X) -omegasqr3(X) + omegasqr4(X)))

g1  = @(X)  0
g2  = @(X)  0
g3  = @(X)  0
g4  = @(X)  ((l/Ix) * u22(X))
g5  = @(X)  ((l/Iy * u32(X)))
g6  = @(X)  (u42(X) * (1/Iz))
g7  = @(X)  0
g8  = @(X)  0
g9  = @(X)  0
g10 = @(X)  (((cos(X(1))*sin(X(2))*cos(X(3))) + sin(X(1))*sin(X(3)))*(u12(X)/m))
g11 = @(X)  (((cos(X(1))*sin(X(2))*sin(X(3))) - (sin(X(1))*cos(X(3))))*(u12(X)/m))
g12 = @(X)  (((u12(X))/m)*cos(X(1))*cos(X(2)))

%x1	         d/dt[X(1)]       = X(4);
%x2                d/dt[X(2)]     = X(5);
%x3                d/dt[X(3)]       = X(6);
%x4                d/dt[X(4)]     = (((Iy - Iz)/Ix)*(X(5))*(X(6))) + (Jr/Ix * X(5) * Omega(X))+ g4(X);
%x5                d/dt[X(5)]   = (((Iz - Ix)/Iy )*(X(4))*(X(6))) - ((Jr/Iy)*X(4)*Omega(X)) + g5(X);
%x6                d/dt[X(6)]     = (((Ix - Iy)/Iz)*(X(4))*(X(5))) + g6(X);
%x7                d/dt[X(7)]         = X(10);
%x8                d/dt[X(8)]         = X(11);
%x9                d/dt[X(9)]         = X(12);
%x10                d/dt[X(10)]       = g10(X);
%x11                d/dt[X(11)]       = g11(X);
%x12                d/dt[X(12)]       = g - g12(X);
%x13               d/dt[X(13)]     = X(9);
%(time, ignore)                d/dt[tau] = 1;

% Declare variables and dynamics

f = @(X) [... 
	X(4);
	X(5);
	X(6);
	(((Iy - Iz)/Ix)*(X(5))*(X(6))) + (Jr/Ix * X(5) * Omega(X))+ g4(X);
	(((Iz - Ix)/Iy )*(X(4))*(X(6))) - ((Jr/Iy)*X(4)*Omega(X)) + g5(X);
	(((Ix - Iy)/Iz)*(X(4))*(X(5))) + g6(X);
	X(10);
	X(11);
	X(12);
	g10(X);
	g11(X);
	g - g12(X);
	X(9)
	];

degree = 2; %desired highest degree for the template monomials

% Region of interest
x1lower = -0.5; x1upper = 0.5;
x2lower = -0.5; x2upper = 0.5;
x3lower = -0.5; x3upper = 0.5;
x4lower = -0.5; x4upper = 0.5;
x5lower = -0.5; x5upper = 0.5;
x6lower = -0.5; x6upper = 0.5;
x7lower = -0.5; x7upper = 0.5;
x8lower = -0.5; x8upper = 0.5;
x9lower = -0.5; x9upper = 0.5;
x10lower = -0.5; x10upper = 0.5;
x11lower = -0.5; x11upper = 0.5;
x12lower = -0.5; x12upper = 0.5;
x13lower = -0.5; x13upper = 0.5;
Xlower = [ x1lower; x2lower; x3lower; x4lower; x5lower; x6lower; x7lower; x8lower; x9lower; x10lower; x11lower; x12lower; x13lower ];
Xupper = [ x1upper; x2upper; x3upper; x4upper; x5upper; x6upper; x7upper; x8upper; x9upper; x10upper; x11upper; x12upper; x13upper ];
% Exclusion zone
x1excludelower = -0.01; x1excludeupper = 0.01;
x2excludelower = -0.01; x2excludeupper = 0.01;
x3excludelower = -0.01; x3excludeupper = 0.01;
x4excludelower = -0.01; x4excludeupper = 0.01;
x5excludelower = -0.01; x5excludeupper = 0.01;
x6excludelower = -0.01; x6excludeupper = 0.01;
x7excludelower = -0.01; x7excludeupper = 0.01;
x8excludelower = -0.01; x8excludeupper = 0.01;
x9excludelower = -0.01; x9excludeupper = 0.01;
x10excludelower = -0.01; x10excludeupper = 0.01;
x11excludelower = -0.01; x11excludeupper = 0.01;
x12excludelower = -0.01; x12excludeupper = 0.01;
x13excludelower = -0.01; x13excludeupper = 0.01;
Xexcludelower = [ x1excludelower; x2excludelower; x3excludelower; x4excludelower; x5excludelower; x6excludelower; x7excludelower; x8excludelower; x9excludelower; x10excludelower; x11excludelower; x12excludelower; x13excludelower ];
Xexcludeupper = [ x1excludeupper; x2excludeupper; x3excludeupper; x4excludeupper; x5excludeupper; x6excludeupper; x7excludeupper; x8excludeupper; x9excludeupper; x10excludeupper; x11excludeupper; x12excludeupper; x13excludeupper ];

% To how many decimal places should coefficients be computed?
precision = 1;
% Number of initial samples
samplenumber = 1;
% Max number of iterations
maxiterations = 150;


[success, barrier] =barriergenerator( X, f, degree, Xlower, Xupper, Xexcludelower, Xexcludeupper, precision, samplenumber, maxiterations)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
