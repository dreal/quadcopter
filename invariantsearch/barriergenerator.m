
function [success, barrier] = barriergenerator( X, f, degree, Xlower, Xupper, Xexcludelower, Xexcludeupper, precision, samplenumber, maxiterations) 

	[~, myname] = system('hostname');
	myname = strtrim( myname ); % remove newline at end

	generateWorkspace();
	%% Generate a monomial vector. Candidate will be z'*p, for p parameter vector
	Z = monomials(X, 1:degree);
	
	Xsamples = generateInitialSamples( X, Xlower, Xupper, samplenumber );

	success = 0;
	iterations = 0;
	while ( (success == 0) && (iterations < maxiterations) )
		[A,b] = generateSampleConstraints( Xsamples, X, Z, f);
		V = generateCandidate( Z, A, b, precision );
		dVdt = vpa(jacobian(V, X)*f(X));

		[V, Xsamples] = improveWithOptimizer( V, Xsamples, Xlower, Xupper, X, Z, f, maxiterations, precision );
		dVdt = vpa(jacobian(V, X)*f(X));

		[posresult, negresult] = querySolver( V, dVdt, X, Xlower, Xupper, Xexcludelower, Xexcludeupper );

		if ( strcmp(posresult, 'unsat') && strcmp(negresult,'unsat' ) )
			fprintf('Candidate validated successfully!\n');
			fprintf('Validated: %s\n', char(V));
			success = 1;
		elseif ( iterations < maxiterations )
			fprintf('Candidate validation failed, seeing what I can learn from the dReal fallout.\n');
			
			if ( strcmp( posresult, 'sat' ) )
				fprintf('Function was not positive. Extracting counterexample\n');
				poscex = extractCEX( sprintf('../drealqueries/%s/functionpositivity.smt2.model', myname) );
				Xsamples = appendSample( Xsamples, poscex );
			else
				fprintf('Function was positive\n');
			end
		
			if ( strcmp( negresult, 'sat' ) )
				fprintf('Derivative was not negative. Extracting counterexample\n');
				negcex = extractCEX(sprintf('../drealqueries/%s/derivativenegativity.smt2.model',myname) ); 
				Xsamples = appendSample( Xsamples, negcex );
				
			else
				fprintf('Derivative was negative\n');
			end
		else 
			fprintf('Validation failed, maximum number of iterations reached, giving up.\n');
		end
		
		iterations = iterations + 1;
	end

	if ( success == 0 )
		fprintf('Validation failed--returning only a candidate solution.\n');
	end

	barrier = V;	
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function generateWorkspace()
	addpath(genpath('SOSTOOLS.300'));
% Set up the local workspace for this machine
	[~, myname] = system('hostname');
	myname = strtrim( myname ); % remove newline at end
	discard = system(sprintf('mkdir ../drealqueries/%s', myname));
	discard = system(sprintf('rm ../drealqueries/%s/*', myname)); %clear it if it exists from a previous run
end

function Xsamples = generateInitialSamples( X, Xlower, Xupper, samplenumber )
	for i = 1:length(X) %initialize empty sample arrays
		gensamples = sprintf('x%isamples = [];', i);
		eval(gensamples);
	end
	
	for i = 1:length(X)
		gensamples = sprintf('x%isamples = linspace( Xlower(%i), Xupper(%i), samplenumber );', i, i, i);
		eval(gensamples);
	end

	crosssamplegen = 'Xsamples = setprod( ';
	for i = 1:length(X)
		crosssamplegen = [crosssamplegen, sprintf('x%isamples,', i)];
	end
	crosssamplegen = [crosssamplegen(1:length(crosssamplegen)-1), ');']; 
	eval(crosssamplegen);
end

function extendedSamples = appendSample( sampleList, newSample )
	fprintf('Appending sample...\n');
	extendedSamples = [sampleList; newSample];
end

function [A,b] = generateSampleConstraints( Xsamples, X, Z, f )
	fprintf('Generating constraints...\n');

	dZdX = jacobian(Z, X);
	derivAt = [];
	gradAt = [];
	Acounter = 1;
	for i = 1:size( Xsamples, 1 )
		gradAt(:,:,i) = subs( dZdX, X, transpose(Xsamples(i, :)) );
		derivAt(:,:,i) = gradAt(:,:,i)*f(Xsamples(i,:));
		A( Acounter, : ) = derivAt(:, :, i)';
		A( Acounter + 1, : ) = subs(-Z, X, transpose(Xsamples(i, :)) );
		Acounter = Acounter + 2;
	end
	
	b = zeros( size(A,1), 1);
end

function V = generateCandidate( Z, A, b, precision )
	fprintf('Generating candidate...\n');

	objective = zeros( length(Z), 1);
	[x, fval, exitflag, output, lambda] = linprog( objective, A, b);
	
	if ( exitflag == 1 )
		fprintf('Candidate successfully computed\n');
	else
		fprintf('Optimizer reported errors, check exitflag and output\n');
	end
	
	% Round to the desired precision
	x = x*(10^precision);
	x = round(x);
	x = x/(10^precision);
	
	V = vpa(Z.'*x);
end

function [V, Xsamples] = improveWithOptimizer( V, Xsamples, Xlower, Xupper, X, Z, f, maxiterations, precision )
	
	iterations = 0;
	success = 0;

	while ( (iterations < maxiterations) && (success == 0) )

		Vfunc = matlabFunction( V, 'vars', {X} );

		dVdt = vpa(jacobian(V, X)*f(X));
		minusdVfunc = matlabFunction( -dVdt, 'vars', {X} );

		[posminx, posmin, posexitflag, posoutput] = fmincon(Vfunc, zeros(length(X), 1), [], [], [], [], Xlower, Xupper);
		[negmaxx, negmax, negexitflag, negoutput] = fmincon(minusdVfunc, zeros(length(X), 1), [], [], [], [], Xlower, Xupper);

		if ( posmin < 0 )
			fprintf('Improving function positivity with optimizer counterexample...\n');
			Xsamples = appendSample( Xsamples, transpose(posminx) )
			success = 0;
		else
			fprintf('Function positivity succeeds w.r.t. optimizer.\n');
			success = 1;
		end

		if ( negmax < 0 )
			fprintf('Improving derivative negativity with optimizer counterexample...\n');
			Xsamples = appendSample( Xsamples, transpose(negmaxx) )
			success = success & 0;
		else
			fprintf('Derivative negativity succeeds w.r.t. optimizer\n');
			success = success & 1;
		end

		if ( success == 0 )
			[A, b] = generateSampleConstraints( Xsamples, X, Z, f );
			V = generateCandidate(Z, A, b, precision )
			fprintf('Generated new candidate through optimizer feedback: %s', char(V) );
			
		end

	end

	if ( success == 1 )
		fprintf('Candidate is approved by the optimizer\n');
	else
		fprintf('Candidate is not yet at its best w.r.t. optimizer, but maximum iterations have been reached\n');
	end
end

function [posresult, negresult] = querySolver( V, dVdt, X, Xlower, Xupper, Xexcludelower, Xexcludeupper )
	[~, myname] = system('hostname');
	myname = strtrim(myname);

	positivequery = fopen( sprintf('../drealqueries/%s/functionpositivity.smt2', myname), 'w+' );
	negativequery = fopen( sprintf('../drealqueries/%s/derivativenegativity.smt2', myname), 'w+' );
	
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
		eval( sprintf('this_lowerbound = Xlower(%i);', i) );
		eval( sprintf('this_upperbound = Xupper(%i);', i) );
	
		fprintf( positivequery, '(assert (<= %f %s))\n', this_lowerbound, char(X(i)) );
		fprintf( negativequery, '(assert (<= %f %s))\n', this_lowerbound, char(X(i)) );
		fprintf( positivequery, '(assert (>= %f %s))\n', this_upperbound, char(X(i)) );
		fprintf( negativequery, '(assert (>= %f %s))\n', this_upperbound, char(X(i)) );
	end
	fprintf( positivequery, '\n' );
	fprintf( negativequery, '\n' );
	
	% Declare the exclusion zone
	for i = 1:length(X)
		eval( sprintf('this_lowerexclude = Xexcludelower(%i);', i) );
		eval( sprintf('this_upperexclude = Xexcludeupper(%i);', i) );
	
		fprintf( positivequery, '(assert (or (>= %f %s) (<= %f %s)))\n', this_lowerexclude, char(X(i)), this_upperexclude, char(X(i)) );
		fprintf( negativequery, '(assert (or (>= %f %s) (<= %f %s)))\n', this_lowerexclude, char(X(i)), this_upperexclude, char(X(i)) );
	end
	fprintf( positivequery, '\n' );
	fprintf( negativequery, '\n' );
	
	% Generate dReal query --- remember, proof is by refutation of the negation, so negation goes here
	ifx2pfxIN = fopen( sprintf('../drealqueries/%s/infile', myname), 'w+' );
	fprintf( ifx2pfxIN, '%s <= 0', char(V) );
	fclose( ifx2pfxIN );
	system( sprintf('cd ../infix2prefix; java Infix2Prefix ../drealqueries/%s/infile > ../drealqueries/%s/outfile', myname, myname ));
	ifx2pfxOUT = fopen( sprintf('../drealqueries/%s/outfile', myname), 'r' );
	fprintf( positivequery, '(assert %s )\n\n', fgetl( ifx2pfxOUT) );
	fclose( ifx2pfxOUT );
	
	ifx2pfxIN = fopen( sprintf('../drealqueries/%s/infile', myname), 'w+' );
	fprintf( ifx2pfxIN, '%s > 0', char(dVdt) );
	fclose( ifx2pfxIN );
	system( sprintf('cd ../infix2prefix; java Infix2Prefix ../drealqueries/%s/infile > ../drealqueries/%s/outfile', myname, myname ));
	ifx2pfxOUT = fopen( sprintf('../drealqueries/%s/outfile', myname), 'r' );
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
	system(sprintf('cd ../drealqueries/%s; ../dreal --model functionpositivity.smt2 > positivityresult', myname));
	system(sprintf('cd ../drealqueries/%s; ../dreal --model derivativenegativity.smt2 > negativityresult', myname));

	posres = fopen(sprintf('../drealqueries/%s/positivityresult',myname), 'r');
	negres = fopen(sprintf('../drealqueries/%s/negativityresult',myname), 'r');
	posresult = fgetl( posres );
	negresult = fgetl( negres );
	fclose(posres); fclose(negres);
	
end

function cex = extractCEX( filename )

	cexfile = fopen( filename, 'r'); 
	fgetl( cexfile ); % discard human-friendly header
	clear cex_output; clear cex_lo; clear cex_hi;
	cex_output = textscan( cexfile, '%s : [%f, %f];');
	fclose( cexfile );
	cex_label = cex_output{1}; cex_lo = cex_output{2}; cex_hi = cex_output{3};

	%assert( length(cex_output{2}) == length(X), 'Something went wrong when trying to parse function positivity counterexample\n');
	cex = [];
	for i = 1:length(cex_lo)
		cexindex = find(strcmp( sprintf('x%i', i), cex_label));
		cex = [cex, (cex_lo(cexindex) + cex_hi(cexindex))/2];
	end
end

