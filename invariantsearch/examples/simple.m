clear all; close all;
addpath(genpath('..'));
tic

syms x1 x2 x3; 
X = [x1; x2; x3];

f = @(X) [ X(2);
        -X(1);
        -X(3)];

degree = 2; %desired highest degree for the template monomials

% Region of interest
Xlower = [-10; -10; -10];
Xupper = [10; 10; 10];
% Exclusion zone
x1excludelower = -0.1; x1excludeupper = 0.1;
x2excludelower = -0.1; x2excludeupper = 0.1;
x3excludelower = -0.1; x3excludeupper = 0.1;
Xexcludelower = [-0.1; -0.1; -0.1];
Xexcludeupper = [0.1; 0.1; 0.1];


% To how many decimal places should coefficients be computed?
precision = 3;
% Number of initial samples
samplenumber = 10; 
% Max number of iterations
maxouteriterations = 150;

myfun =barriergenerator( X, f, degree, Xlower, Xupper, Xexcludelower, Xexcludeupper, precision, samplenumber, maxouteriterations)
                
toc;
