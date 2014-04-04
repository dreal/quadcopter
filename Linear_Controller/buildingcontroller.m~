clc
clear all
close all

global Jr Ix Iy Iz b d l m g Kpz Kdz Kpp Kdp Kpt Kdt Kpps Kdps ZdF PhidF ThetadF PsidF ztime phitime thetatime psitime Zinit Phiinit Thetainit Psiinit Uone Utwo Uthree Ufour Ez Ep Et Eps

% of the PD controller

kpp = 0.8;
kdp = 0.4;

kpt = 1.2;
kdt = 0.4;

kpps = 1;
kdps = 0.4;

kpz = 100;
kdz = 20;
Gains = [kpp kdp kpt kdt kpps kdps kpz kdz];
disp(Gains);
% Quadrotor constants
Ix = 7.5*10^(-3);  % Quadrotor moment of inertia around X axis
Iy = 7.5*10^(-3);  % Quadrotor moment of inertia around Y axis
Iz = 1.3*10^(-2);  % Quadrotor moment of inertia around Z axis
Jr = 6.5*10^(-5);  % Total rotational moment of inertia around the propeller axis
b = 3.13*10^(-5);  % Thrust factor
d = 7.5*10^(-7);  % Drag factor
l = 0.23;  % Distance to the center of the Quadrotor
m = 0.65;  % Mass of the Quadrotor in Kg
g = 9.81;   % Gravitational acceleration


% A0 =  [0    0    0    1    0    0    0    0    0    0    0    0;
%                      0    0    0    0    1    0    0    0    0    0    0    0;
%                      0    0    0    0    0    1    0    0    0    0    0    0;
%                      0    0    0    0    0   0   0    0    0    0    0    0;
%                      0    0    0    0   0    0   0    0    0    0    0    0;
%                      0    0    0    0    0    0    0    0    0    0    0    0];
%                      %0    0    0    0    0    0    0    0    0    1    0    0;
%                      %0    0    0    0    0    0    0    0    0    0    1    0;
%                     % 0    0    0    0    0    0    0    0    0    0    0    1;
%                     % 0   0   0   0    0    0    0    0    0    0    0    0;
%                     % 0   0   0   0    0    0    0    0    0    0    0    0;
%                      %0   0   0    0    0    0    0    0    0    0    0    0];
 A0 =  [0    0    0    1    0    0    0 0 0;
                     0    0    0    0    1    0 0 0 0 ;
                     0    0    0    0    0    1 0 0 0;
                     0    0    0    0    0   0  0 0 0;
                     0    0    0    0   0    0  0 0 0;
                     0    0    0    0    0    0 0 0 0;
                     0 0 0 0 0 0 0 1 0;
                     0 0 0 0 0 0 0 0 0;
                     0 0 0 0 0 0 1 0 0
                     ];
                     
B0 =  [0         0         0         0;
                     0         0         0         0;
                     0         0         0         0;
                     0         133.333   0         0;
                     0         0         133.333   0;
                     0         0         0         76.9231;
                     %0         0         0         0;
                     %0         0         0         0;
                     %0         0         0         0;
                     %0        0         0         0;
                     0        0         0         0;
                      -1.53846   0          0          0;
                      0 0 0 0
                      ];


q = ss(A0,B0,eye(9), zeros(9,4));
Qn = [
1000 0 0 0 0 0 0 0 0;    
0 1000 0 0 0 0 0 0 0;
0 0 1 0 0 0 0 0 0;
0 0 0 1000 0 0 0 0 0;
0 0 0 0 1000 0 0 0 0;
0 0 0 0 0 1 0 0 0;
0 0 0 0 0 0 1 0 0;
0 0 0 0 0 0 0 1 0;
0 0 0 0 0 0 0 0 10
];
Rn = eye(4);
Nn = zeros(9,4);

K0 = lqr(q, Qn, Rn, Nn);