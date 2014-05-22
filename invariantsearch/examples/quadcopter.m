clear all; close all;
addpath(genpath('SOSTOOLS.300'));
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

% To how many decimal places should coefficients be computed?
precision = 3;
% Number of initial samples
samplenumber = 1;
% Max number of iterations
maxiterations = 150;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set up the local workspace for this machine
[~, myname] = system('hostname');
myname = strtrim( myname ); % remove newline at end
discard = system(sprintf('mkdir drealqueries/%s', myname));
discard = system(sprintf('rm drealqueries/%s/*', myname)); %clear it if it exists from a previous run

%% Generate a monomial vector. Candidate will be z'*p, for p parameter vector
Z = monomials(X, degree);
dZdX = jacobian(Z, X);

success = 0;
iterations = 0;
for i = 1:length(X) %initialize empty sample arrays
	gensamples = sprintf('x%isamples = [];', i);
	eval(gensamples);
end
%% Initialize with a random initial point
%for i = 1:length(X)
%	gensamples = sprintf('x%isamples = [x%isamples, (abs(x%iupper) + abs(x%ilower))*rand + x%ilower]', i, i, i, i, i);
%	eval(gensamples);
%end
% Generate some sample points, uniformly distributed
for i = 1:length(X)
	gensamples = sprintf('x%isamples = linspace( x%ilower, x%iupper, samplenumber );', i, i, i);
	eval(gensamples);
end
while ( (success == 0) && (iterations < maxiterations) )

fprintf( 'Starting iteration %i\n', iterations );

%% Generate some sample points, uniformly distributed
%for i = 1:length(X)
%	gensamples = sprintf('x%isamples = linspace( x%ilower, x%iupper, samplenumber );', i, i, i);
%	eval(gensamples);
%end

% Generate samples randomly, on demand, as optimzation fails
%for i = 1:length(X)
%	gensamples = sprintf('x%isamples = [x%isamples, (abs(x%iupper) + abs(x%ilower))*rand + x%ilower]', i, i, i, i, i);
%	eval(gensamples);
%end


clear Xsamples;
crosssamplegen = 'Xsamples = setprod( ';
for i = 1:length(X)
	crosssamplegen = [crosssamplegen, sprintf('x%isamples,', i)];
end
crosssamplegen = [crosssamplegen(1:length(crosssamplegen)-1), ');']; 
eval(crosssamplegen);



derivAt = [];
gradAt = [];
Acounter = 0;
for i = 1:size( Xsamples, 1 )
	fprintf('Iteration %i: Evaluating sample %i of %i...\n', iterations, i, size(Xsamples, 1));
	gradAt(:,:,i) = subs( dZdX, X, transpose(Xsamples(i, :)) );
	derivAt(:,:,i) = gradAt(:,:,i)*f(Xsamples(i,:));
	Acounter = Acounter + 2;
	A( Acounter, : ) = derivAt(:, :, i)';
	A( Acounter + 1, : ) = subs(-Z, X, transpose(Xsamples(i, :)) );
end

b = zeros( Acounter + 1, 1);
objective = zeros( length(Z), 1);

fprintf('Iteration %i: Starting optimization\n', iterations);
[x, fval, exitflag, output, lambda] = linprog( objective, A, b);

if ( exitflag == 1 )
	fprintf('Iteration %i: Candidate successfully computed\n', iterations);
else
	fprintf('Iteration %i: Optimizer reported errors, check exitflag and output\n', iterations);
end

% Round to the desired precision
x = x*(10^precision);
x = round(x);
x = x/(10^precision);

V = char(vpa(Z.'*x));
dVdt = char(vpa(jacobian(Z.'*x)*f(X)));
fprintf( 'Iteration %i: The candidate function is %s\n', iterations, V );
fprintf( 'Iteration %i: Its derivative is %s\n', iterations, dVdt );
iterations = iterations + 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Send it over to dReal

fprintf('Iteration %i: Generating dReal queries...\n', iterations);
positivequery = fopen( sprintf('drealqueries/%s/functionpositivity.smt2', myname), 'w+' );
negativequery = fopen( sprintf('drealqueries/%s/derivativenegativity.smt2', myname), 'w+' );

% Header
fprintf( positivequery, '(set-logic QF_NRA)\n\n' );
fprintf( negativequery, '(set-logic QF_NRA)\n\n' );

% Declare vars
for i = 1:length(X)
	fprintf( positivequery, '(declare-fun %s () Real)\n', char(X(i)) );
	fprintf( negativequery, '(declare-fun %s () Real)\n', char(X(i)) );
end
fprintf( positivequery, '\n' );
fprintf( negativequery, '\n' );

% Declare region of interest
for i = 1:length(X)
	eval( sprintf('this_lowerbound = x%ilower;', i) );
	eval( sprintf('this_upperbound = x%iupper;', i) );

	fprintf( positivequery, '(assert (<= %f %s))\n', this_lowerbound, char(X(i)) );
	fprintf( negativequery, '(assert (<= %f %s))\n', this_lowerbound, char(X(i)) );
	fprintf( positivequery, '(assert (>= %f %s))\n', this_upperbound, char(X(i)) );
	fprintf( negativequery, '(assert (>= %f %s))\n', this_upperbound, char(X(i)) );
end
fprintf( positivequery, '\n' );
fprintf( negativequery, '\n' );

% Declare the exclusion zone
for i = 1:length(X)
	eval( sprintf('this_lowerexclude = x%iexcludelower;', i) );
	eval( sprintf('this_upperexclude = x%iexcludeupper;', i) );

	fprintf( positivequery, '(assert (or (>= %f %s) (<= %f %s)))\n', this_lowerexclude, char(X(i)), this_upperexclude, char(X(i)) );
	fprintf( negativequery, '(assert (or (>= %f %s) (<= %f %s)))\n', this_lowerexclude, char(X(i)), this_upperexclude, char(X(i)) );
end
fprintf( positivequery, '\n' );
fprintf( negativequery, '\n' );

% Generate query --- remember, proof is by refutation of the negation, so negation goes here
ifx2pfxIN = fopen( sprintf('drealqueries/%s/infile', myname), 'w+' );
fprintf( ifx2pfxIN, '%s <= 0', V );
fclose( ifx2pfxIN );
system( sprintf('cd infix2prefix; java Infix2Prefix ../drealqueries/%s/infile > ../drealqueries/%s/outfile', myname, myname ));
ifx2pfxOUT = fopen( sprintf('drealqueries/%s/outfile', myname), 'r' );
fprintf( positivequery, '(assert %s )\n\n', fgetl( ifx2pfxOUT) );
fclose( ifx2pfxOUT );

ifx2pfxIN = fopen( sprintf('drealqueries/%s/infile', myname), 'w+' );
fprintf( ifx2pfxIN, '%s > 0', dVdt );
fclose( ifx2pfxIN );
system( sprintf('cd infix2prefix; java Infix2Prefix ../drealqueries/%s/infile > ../drealqueries/%s/outfile', myname, myname ));
ifx2pfxOUT = fopen( sprintf('drealqueries/%s/outfile', myname), 'r' );
fprintf( negativequery, '(assert %s )\n\n', fgetl( ifx2pfxOUT ) );
fclose( ifx2pfxOUT );

% End of file
fprintf( positivequery, '(check-sat)\n' );
fprintf( negativequery, '(check-sat)\n' );
fprintf( positivequery, '(exit)\n\n' );
fprintf( negativequery, '(exit)\n\n' );
fclose( positivequery );
fclose( negativequery );

fprintf('Iteration %i: dReal queries generated, running dReal...\n', iterations);

% Now run dReal --- NOTE that dReal needs to be in your path, and named "dreal"
system(sprintf('cd drealqueries/%s; ../dreal --model functionpositivity.smt2 > positivityresult', myname));
system(sprintf('cd drealqueries/%s; ../dreal --model derivativenegativity.smt2 > negativityresult', myname));

fprintf('Iteration %i: dReal computation terminated, checking output...\n', iterations);

posres = fopen(sprintf('drealqueries/%s/positivityresult',myname), 'r');
negres = fopen(sprintf('drealqueries/%s/negativityresult',myname), 'r');
posresult = fgetl( posres );
negresult = fgetl( negres );
if ( strcmp(posresult, 'unsat') && strcmp(negresult,'unsat' ) )
	fprintf('Iteration %i: Candidate validated successfully!\n', iterations);
	fprintf('Validated: %s\n', V);
	success = 1;
elseif ( iterations < maxiterations )
	fprintf('Candidate validation failed, seeing what I can learn from the dReal fallout.\n');
	
	if ( strcmp( posresult, 'sat' ) )
		fprintf('Function was not positive. Extracting counterexample\n');
		poscex = fopen(sprintf('drealqueries/%s/functionpositivity.smt2.model',myname), 'r'); 
		fgetl( poscex ); % discard human-friendly header
		clear cex_output; clear cex_lo; clear cex_hi;
		cex_output = textscan(poscex, '%s : [%f, %f];');
		fclose(poscex);
		cex_label = cex_output{1}; cex_lo = cex_output{2}; cex_hi = cex_output{3};

		assert( length(cex_output{2}) == length(X), 'Something went wrong when trying to parse function positivity counterexample\n');
		for i = 1:length(X)
			clear cexindex;
			cexindex = find(strcmp( sprintf('x%i', i), cex_label));
			gensamples = sprintf('x%isamples = [x%isamples (cex_lo(%i) + cex_hi(%i))/2]', i, i, cexindex, cexindex);
			eval(gensamples);
		end

	else
		fprintf('Function was positive\n');
	end

	if ( strcmp( negresult, 'sat' ) )
		fprintf('Derivative was not negative. Extracting counterexample\n');
		negcex = fopen(sprintf('drealqueries/%s/derivativenegativity.smt2.model',myname), 'r'); 
		fgetl( negcex ); % discard human-friendly header
		clear cex_output; clear cex_lo; clear cex_hi;
		cex_output = textscan(negcex, '%s : [%f, %f];');
		fclose(negcex);
		cex_label = cex_output{1}; cex_lo = cex_output{2}; cex_hi = cex_output{3};

		assert( length(cex_output{2}) == length(X), 'Something went wrong when trying to parse derivative negativity counterexample\n');
		for i = 1:length(X)
			clear cexindex;
			cexindex = find(strcmp( sprintf('x%i', i), cex_label));
			gensamples = sprintf('x%isamples = [x%isamples (cex_lo(%i) + cex_hi(%i))/2]', i, i, cexindex, cexindex);
			eval(gensamples);
		end
	else
		fprintf('Derivative was negative\n');
	end

	fprintf('Learned from counterexample, running next iteration\n');

else 
	fprintf('Validation failed, maximum number of iterations reached, giving up.\n');
end


end

toc;
