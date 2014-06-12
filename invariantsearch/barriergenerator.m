
function [success, barrier] = barriergenerator( X, f, degree, Xlower, Xupper, Xexcludelower, Xexcludeupper, precision, samplenumber, maxiterations) 	
	overallstart = clock();

	[~, myname] = system('hostname');
	myname = strtrim( myname ); % remove newline at end

	generateWorkspace();
	%% Generate a monomial vector. Candidate will be z'*p, for p parameter vector
	Z = monomials(X, 1:degree);
	
	Xsamples = generateInitialSamples( X, Xlower, Xupper, samplenumber );
	A = []; b = [];
	[A, b] = appendSampleConstraints( A, b, X, Z, f, Xsamples );

	success = 0;
	iterations = 0;
	
	while ( (success == 0) && (iterations < maxiterations) )
		LOG(sprintf('Starting iteration %i\n', iterations));
		%[A,b] = generateSampleConstraints( Xsamples, X, Z, f);
		V = generateCandidate( Z, A, b, precision );
		dVdt = vpa(jacobian(V, X)*f(X));

		[V, Xsamples, A, b] = improveWithOptimizer( V, Xsamples, Xlower, Xupper, A, b, X, Z, f, maxiterations, precision );
		dVdt = vpa(jacobian(V, X)*f(X));

		startdreal = clock();
		[posresult, negresult] = querySolver( V, dVdt, X, Xlower, Xupper, Xexcludelower, Xexcludeupper );
		stopdreal = clock();
		fprintf(sprintf('Consulting dReal took %i\n', etime(stopdreal, startdreal)));


		if ( strcmp(posresult, 'unsat') && strcmp(negresult,'unsat' ) )
			fprintf('Candidate validated successfully!\n');
			LOG('Candidate validated successfully!\n');
			fprintf('Validated: %s\n', char(V));
			LOG(sprintf('Validated: %s', char(V)));
			success = 1;
		elseif ( iterations < maxiterations )
			fprintf('Candidate validation failed, seeing what I can learn from the dReal fallout.\n');
			LOG('Candidate validation failed, seeing what I can learn from the dReal fallout.');
			
			if ( strcmp( posresult, 'sat' ) )
				fprintf('Function was not positive. Extracting counterexample\n');
				LOG('Function was not positive. Extracting counterexample');
				poscex = extractCEX( sprintf('../drealqueries/%s/functionpositivity.smt2.model', myname) );
				Xsamples = appendSample( Xsamples, poscex );
				[A, b] = appendSampleConstraints( A, b, X, Z, f, poscex );
			else
				fprintf('Function was positive\n');
				LOG('Function was positive');
			end
		
			if ( strcmp( negresult, 'sat' ) )
				fprintf('Derivative was not negative. Extracting counterexample\n');
				LOG('Derivative was not negative. Extracting counterexample');
				negcex = extractCEX(sprintf('../drealqueries/%s/derivativenegativity.smt2.model',myname) ); 
				Xsamples = appendSample( Xsamples, negcex );
				[A, b] = appendSampleConstraints( A, b, X, Z, f, negcex );
				
			else
				fprintf('Derivative was negative\n');
				LOG('Derivative was negative');
			end
		else 
			fprintf('Validation failed, maximum number of iterations reached, giving up.\n');
			LOG('Validation failed, maximum number of iterations reached, giving up.');
		end
		
		iterations = iterations + 1;
	end

	if ( success == 0 )
		fprintf('Validation failed--returning only a candidate solution.\n');
		LOG('Validation failed--returning only a candidate solution.');
	end

	barrier = V;	

	overallstop = clock();
	fprintf(sprintf('Total elapsed time was', etime(overallstop, overallstart)));
	LOG(sprintf('Total elapsed time was', etime(overallstop, overallstart)));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LOG( stringtolog )
	[~, myname] = system('hostname');
	myname = strtrim( myname ); % remove newline at end

	logfile = fopen( sprintf('../drealqueries/%s/logfile', myname), 'a' );
	fprintf( logfile, '%s\n', stringtolog );
	fclose( logfile );

end
	

function generateWorkspace()
	addpath(genpath('SOSTOOLS.300'));
% Set up the local workspace for this machine
	[~, myname] = system('hostname');
	myname = strtrim( myname ); % remove newline at end
	discard = system(sprintf('mkdir ../drealqueries/%s', myname));
	discard = system(sprintf('rm ../drealqueries/%s/*', myname)); %clear it if it exists from a previous run
	% Clear logfile
	logfile = fopen( sprintf('../drealqueries/%s/logfile', myname), 'w' );
	fprintf( logfile, 'Initialized on %s\n', date );
	fclose(logfile);
end

function Xsamples = generateInitialSamples( X, Xlower, Xupper, samplenumber )

	fprintf('Generating initial samples...\n');
	LOG('Generating initial samples...\n');
	start = clock();
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

	stop = clock();
	fprintf(sprintf('Generating initial samples took %i time units\n', etime(stop, start)));
	LOG(sprintf('Generating initial samples took %i time units\n', etime(stop, start)));
end

function extendedSamples = appendSample( sampleList, newSample )
	fprintf('Appending sample...\n');
	LOG('Appending sample...');
	extendedSamples = [sampleList; newSample];
end

function [A,b] = generateSampleConstraints( Xsamples, X, Z, f )
	fprintf('Generating sample constraints...\n');
	LOG('Generating sample constraints...\n');

	start = clock();

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
	
	stop = clock();
	fprintf(sprintf('Generating sample constraints took %i time units\n', etime(stop, start)));
	LOG(sprintf('Generating sample constraints took %i time units\n', etime(stop, start)));
end

function [A, b] = appendSampleConstraints( A, b, X, Z, f, newSamples )
	fprintf('Appending sample constraints...\n');
	LOG('Appending sample constraints...');

	start = clock();

	dZdX = jacobian(Z, X);
	derivAt = [];
	gradAt = [];
	Acounter = size(A,1) + 1;
	for i = 1:size( newSamples, 1 )
		gradAt(:,:,i) = subs( dZdX, X, transpose(newSamples(i, :)) );
		derivAt(:,:,i) = gradAt(:,:,i)*f(newSamples(i,:));
		A( Acounter, : ) = derivAt(:, :, i)';
		A( Acounter + 1, : ) = subs(-Z, X, transpose(newSamples(i, :)) );
		Acounter = Acounter + 2;
	end

	b = [b; zeros(size(A,1) - length(b), 1)];

	stop = clock();
	fprintf(sprintf('Appending sample constraints took %i time units\n', etime(stop, start)));
	LOG(sprintf('Appending sample constraints took %i time units\n', etime(stop, start)));


end

function V = generateCandidate( Z, A, b, precision )
	fprintf('Generating candidate...\n');
	LOG('Generating candidate...');
	start = clock();

	objective = zeros( length(Z), 1);
	[x, fval, exitflag, output, lambda] = linprog( objective, A, b);
	
	if ( exitflag == 1 )
		fprintf('Candidate successfully computed\n');
		LOG('Candidate successfully computed');
	else
		fprintf('Optimizer reported errors, check exitflag and output\n');
		LOG('Optimizer reported errors, check exitflag and output');
	end
	
	% Round to the desired precision
	x = x*(10^precision);
	x = round(x);
	x = x/(10^precision);
	
	V = vpa(Z.'*x);
	stop = clock();
	fprintf(sprintf('Generating candidate took %i time units\n', etime(stop,start)));
	LOG(sprintf('Generating candidate took %i time units\n', etime(stop,start)));
end

function [V, Xsamples, A, b] = improveWithOptimizer( V, Xsamples, Xlower, Xupper, A, b, X, Z, f, maxiterations, precision )
	
	iterations = 0;
	success = 0;

	while ( (iterations < maxiterations) && (success == 0) )

		Vfunc = matlabFunction( V, 'vars', {X} );

		dVdt = vpa(jacobian(V, X)*f(X));
		minusdVfunc = matlabFunction( -dVdt, 'vars', {X} );

		startpos = clock();
		[posminx, posmin, posexitflag, posoutput] = fmincon(Vfunc, zeros(length(X), 1), [], [], [], [], Xlower, Xupper);
		endpos = clock();
		fprintf(sprintf('Checking positivity with optimizer took %i', etime(endpos, startpos)))
		LOG(sprintf('Checking positivity with optimizer took %i', etime(endpos, startpos)))
		startneg = clock();
		[negmaxx, negmax, negexitflag, negoutput] = fmincon(minusdVfunc, zeros(length(X), 1), [], [], [], [], Xlower, Xupper);
		endneg = clock();
		fprintf(sprintf('Checking negativity with optimizer took %i', etime(endneg, startneg)))
		LOG(sprintf('Checking negativity with optimizer took %i', etime(endneg, startneg)))

		if ( posmin < 0 )
			fprintf('Improving function positivity with optimizer counterexample...\n');
			LOG('Improving function positivity with optimizer counterexample...');
			Xsamples = appendSample( Xsamples, transpose(posminx) )
			[A, b] = appendSampleConstraints( A, b, X, Z, f, transpose(posminx) );
			success = 0;
		else
			fprintf('Function positivity succeeds w.r.t. optimizer.\n');
			LOG('Function positivity succeeds w.r.t. optimizer.');
			success = 1;
		end

		if ( negmax < 0 )
			fprintf('Improving derivative negativity with optimizer counterexample...\n');
			LOG('Improving derivative negativity with optimizer counterexample...');
			Xsamples = appendSample( Xsamples, transpose(negmaxx) )
			[A, b] = appendSampleConstraints( A, b, X, Z, f, transpose(negmaxx ));
			success = success & 0;
		else
			fprintf('Derivative negativity succeeds w.r.t. optimizer\n');
			LOG('Derivative negativity succeeds w.r.t. optimizer');
			success = success & 1;
		end

		if ( success == 0 )
			%[A, b] = generateSampleConstraints( Xsamples, X, Z, f );
			V = generateCandidate(Z, A, b, precision )
			fprintf('Generated new candidate through optimizer feedback: %s', char(V) );
			LOG(sprintf('Generated new candidate through optimizer feedback: %s', char(V) ));
			
		end

	end

	if ( success == 1 )
		fprintf('Candidate is approved by the optimizer\n');
		LOG('Candidate is approved by the optimizer');
	else
		fprintf('Candidate is not yet at its best w.r.t. optimizer, but maximum iterations have been reached\n');
		LOG('Candidate is not yet at its best w.r.t. optimizer, but maximum iterations have been reached');
	end
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

