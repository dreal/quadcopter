function m = generatemonomials(X, degree)

	degreepool = [];
	for i = 1:length(X)
		degreepool = [degreepool, 0:1:degree];
	end

	degreecombinations = combnk(degreepool, length(X));

	numcombinations = size( degreecombinations, 1 );

	m = sym([]);
	mcounter = 1;
	for i = 1:numcombinations
		sumdegrees = sum( degreecombinations(i,:) );
		if ( (sumdegrees > 0) && (sumdegrees <= degree) ) 
			degreepermutations = []; % clear it if there was previous data
			degreepermutations = perms( degreecombinations(i, :) );

			numpermutations = size(degreepermutations, 1);
			for j = 1:numpermutations
				m( mcounter ) = sym(1);
				for k = 1:length(X)
					m( mcounter ) = m( mcounter )*X(k)^sym(degreepermutations(j,k));
				end
				mcounter = mcounter + 1;
			end
		end
	end
	m = unique( m );
	m = m.';
end
