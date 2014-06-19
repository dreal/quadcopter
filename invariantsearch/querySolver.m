
function [posresult, negresult] = querySolver( V, dVdt, X, Xlower, Xupper, exclusionRadius )
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
	tinyBallString = '(> (+ ';
	for i = 1:length(X)
		tinyBallString = sprintf('%s (^ %s 2)', tinyBallString, char(X(i)));
	end
	tinyBallString = sprintf('%s ) %f )', tinyBallString, exclusionRadius);
	fprintf( positivequery, '(assert %s )\n', tinyBallString);
	fprintf( negativequery, '(assert %s )\n', tinyBallString);
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
	system(sprintf('cd ../drealqueries/%s; ../dreal --model --precision=0.00001 functionpositivity.smt2 > positivityresult', myname));
	system(sprintf('cd ../drealqueries/%s; ../dreal --model derivativenegativity.smt2 > negativityresult', myname));

	posres = fopen(sprintf('../drealqueries/%s/positivityresult',myname), 'r');
	negres = fopen(sprintf('../drealqueries/%s/negativityresult',myname), 'r');
	posresult = fgetl( posres );
	negresult = fgetl( negres );
	fclose(posres); fclose(negres);
	
end
