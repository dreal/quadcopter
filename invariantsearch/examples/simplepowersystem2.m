clear all; close all;
addpath(genpath('SOSTOOLS.300'));
tic;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sin and cos are replaced by state variables
% somewhat ad-hoc, since I manually added the constraints for the appropriate z-vars

% Parameters
Pm = 1; J = 20; Td0prime = 8; xd = 1.8; xdprime = 0.3;
alpha = 0.8771; beta = 0.34907; gamma = 1;
efd = 0.5644;

% Declare variables and dynamics
syms x1 x2 x3 x4 x5;
X = [x1; x2; x3; x4; x5];

f = @(X) [ (1/Td0prime)*(-(X(1) + alpha) - (xd - xdprime)*(X(1)+alpha - cos(X(2) + beta))/xdprime + efd);
	377*X(3);
	(1/J)*((Pm - (X(1) + alpha)*sin(X(2) + beta))/xdprime );
	-X(5)*377*X(3);
	X(4)*377*X(3);
	];

degree = 2; %desired highest degree for the template monomials

% Region of interest
x1lower = -0.1; x1upper = 0.1;
x2lower = -0.1; x2upper = 0.1;
x3lower = -0.1; x3upper = 0.1;
x4lower = -1; x4upper = 1;
x5lower = -1; x5upper = 1;
% Exclusion zone
x1excludelower = -0.01; x1excludeupper = 0.01;
x2excludelower = -0.01; x2excludeupper = 0.01;
x3excludelower = -0.01; x3excludeupper = 0.01;
x4excludelower = -0.01; x4excludeupper = 0.01;
x5excludelower = -0.01; x5excludeupper = 0.01;

% To how many decimal places should coefficients be computed?
precision = 4;
% Number of initial samples
samplenumber = 5;
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

%%FIXME --- dirty hack to encode the sin-cos constraints
beq = 1;
x4sqidx = find(Z == x4^2);
x5sqidx = find(Z == x5^2);
Aeq(1,:) = zeros( length(Z), 1);
Aeq(1,x4sqidx) = 1; A(1, x5sqidx) = 1;

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
	fprintf('Iteration %i: Evaluating sample %i of %i...\n', iterations, i, size(Xsamples,1));
	gradAt(:,:,i) = subs( dZdX, X, transpose(Xsamples(i, :)) );
	derivAt(:,:,i) = gradAt(:,:,i)*f(Xsamples(i,:));
	Acounter = Acounter + 2;
	A( Acounter, : ) = derivAt(:, :, i)';
	A( Acounter + 1, : ) = subs(-Z, X, transpose(Xsamples(i, :)) );
end

b = zeros( Acounter + 1, 1);
objective = zeros( length(Z), 1);

fprintf('Initializing optimization procedure...\n');
[x, fval, exitflag, output, lambda] = linprog( objective, A, b, Aeq, beq);

if ( exitflag == 1 )
	fprintf('Candidate successfully computed\n');
else
	fprintf('Optimizer reported errors, check exitflag and output\n');
end

% Round to the desired precision
x = x*(10^precision);
x = round(x);
x = x/(10^precision);

V = char(vpa(Z.'*x));
dVdt = char(vpa(jacobian(Z.'*x, X)*f(X)));
fprintf( 'The candidate function is %s\n', V );
fprintf( 'Its derivative is %s\n', dVdt );
iterations = iterations + 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Send it over to dReal

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

% Now run dReal --- NOTE that dReal needs to be in your path, and named "dreal"
system(sprintf('cd drealqueries/%s; ../dreal --model functionpositivity.smt2 > positivityresult', myname));
system(sprintf('cd drealqueries/%s; ../dreal --model derivativenegativity.smt2 > negativityresult', myname));

posres = fopen(sprintf('drealqueries/%s/positivityresult',myname), 'r');
negres = fopen(sprintf('drealqueries/%s/negativityresult',myname), 'r');
posresult = fgetl( posres );
negresult = fgetl( negres );
if ( strcmp(posresult, 'unsat') && strcmp(negresult,'unsat' ) )
	fprintf('Candidate validated successfully!\n');
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
