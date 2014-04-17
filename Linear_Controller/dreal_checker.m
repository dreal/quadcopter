clear all
close all

%syms Ix Iy Iz Jr b d l m g dt Omega 
length = 1:100000;
history = zeros(length,13);


%starting variables
phi = 0;
theta = 0;
psi = 0;
d_phi = 0;
d_theta = 0;
d_psi = 0;


x = 0;
y = 0;
z = 0;
int_z = 0;
d_x = 0;
d_y = 0;
d_z = 0;



Ix = 7.5*10^(-3);
Iy = 7.5*10^(-3);
Iz = 1.3*10^(-2);
Jr = 6.5*10^(-5);
b = 3.13*10^(-5);
d = 7.5*10^(-7);
l = 0.23;
m = 0.65;
g = 9.81;
dt = 0.00001;





for t=length
    
    

U1 = 0.000000000000000040040329806638157622061132068177*psi - 0.000000000000000004006260662349088113459483121302*d_psi + 0.000000000000000040199263120208627223437034754057*d_theta + 0.00000000000016481994537721932724351482870661*theta + 0.00000000000098891967226331596346108897223964*x + 0.0000000000079113573781065277076887117779171*d_x + 4.11553517599868712295574368909*z + 2.5199605312384134592207374225836*d_z + 3.1622776601683793319988935444327*int_z;
U2 = 189.73665961010275991993361266596*y - 31.630275731249675175149604910985*d_phi - 31.622776601683793319988935444327*phi + 1517.8932768808220793594689013277*d_y;
U3 = 0.00000000000000070138917281910823366567033228324*d_psi + 0.00000000000000043749598496085489029482841870694*psi - 31.630275731249682280576962511986*d_theta - 31.622776601683793319988935444327*theta - 189.73665961010275991993361266596*x - 1517.8932768808220793594689013277*d_x - 0.0000000000000070356585091052359927346895193447*z - 0.0000000000000034839309111753163949802837487703*d_z - 0.000000000000011331008570360934389675285377061*int_z;
U4 = 0.00000000000000040464873271944341320474427745137*d_theta - 1.0*psi - 1.0129165771177819355131077827537*d_psi + 0.00000000000023878030692159577841250980175465*theta + 0.0000000000014326818415295746704750588105279*x + 0.000000000011461454732236597363800470484223*d_x - 0.00000000000000031636295750377493337137733115377*z + 0.00000000000000020031329352465790704239314222127*d_z - 0.00000000000000010038228518403374163714875500275*int_z;

omegasqr1 = (U1/(4*b)) + (U3/(2*b*l)) - (U4/(4*d));
omegasqr2 = (U1/(4*b)) - (U2/(2*b*l)) + (U4/(4*d));
omegasqr3 = (U1/(4*b)) - (U3/(2*b*l)) - (U4/(4*d));
omegasqr4 = (U1/(4*b)) + (U2/(2*b*l)) + (U4/(4*d));
omegasqr5 = -omegasqr1 + omegasqr2 - omegasqr3 + omegasqr4;
Omega = d*omegasqr5;

u12 = (b)*(omegasqr1 + omegasqr2 + omegasqr3 + omegasqr4);
u22 = (b)*(-omegasqr2 + omegasqr4);
u32 = (b)*(omegasqr1 - omegasqr3);
u42 = (d)*(-omegasqr1 + omegasqr2 -omegasqr3 + omegasqr4);
    
    

g1 = 0;
g2 = 0;
g3 = 0;
g4 = (l/Ix)*u22;
g5 = (l/Iy*u32);
g6 = u42*(1/Iz);
g7 = 0;
g8 = 0;
g9 = 0;
g10 = ((cos(phi)*sin(theta)*cos(psi)) + sin(phi)*sin(psi))*(u12/m);
g11 = ((cos(phi)*sin(theta)*sin(psi)) - (sin(phi)*cos(psi)))*(u12/m);
g12 = ((u12)/m)*cos(phi)*cos(theta);
%(*d_phi*)              x1dot = f1;
%(*d_theta*)            x2dot = f2;
%(*d_psi*)              x3dot = f3;
%(*d_phidot*)           x4dot = f4;
%(*d_thetadot*)         x5dot = f5;
%(*d_psidot*)           x6dot = f6;
%(*xdot*)                x7dot = f7;
%(*ydot*)                x8dot = f8;
%(*zdot*)                x9dot = f9;
%(*xdotdot*)             x10dot = f10;
%(*ydotdot*)             x11dot = f11;
%(*zdotdot*)             x12dot = f12;



phi = phi + dt*d_phi;
theta = theta + dt*d_theta;
psi = psi + dt*d_psi;

d_phi = d_phi + dt*((((Iy - Iz)/Ix)*(d_theta)*(d_psi)) + (Jr/Ix *d_theta*Omega)+ g4);
d_theta = d_theta + dt*(( ((Iz - Ix)/Iy )*(d_phi)*(d_psi)) - ((Jr/Iy)*d_phi*Omega) + g5);
d_psi = d_psi + dt*( (((Ix - Iy)/Iz)*(d_phi)*(d_theta)) + g6);


x = x + dt*d_x;
y = y + dt*d_y;
z = z + dt*d_z;

d_x = d_x + dt*g10;
d_y = d_y + dt*g11;
d_z = d_z + dt*(g - g12);

int_z = int_z + dt*z;

f = [phi theta psi d_phi d_theta d_psi x y z d_x d_y d_z int_z];

    for j=1:13
    history(t,j) = f(j);
    end



end

figure
%Plots phi or f1
plot(length,history(:,1))
title('Phi plot')
xlabel('Time [depends on dt]')
ylabel('Phi [rads]')


figure
%Plots theta
plot(length,history(:,2))
title('Theta plot')
xlabel('Time [depends on dt]')
ylabel('Theta [rads]')


figure 
%Plots psi
plot(length,history(:,3))
title('Psi plot')
xlabel('Time [depends on dt]')
ylabel('Psi [rads]')

figure
%Plots phi or f1
plot(length,history(:,7))
title('X plot')
xlabel('Time [depends on dt]')
ylabel('X [m]')


figure
%Plots theta
plot(length,history(:,8))
title('Y plot')
xlabel('Time [depends on dt]')
ylabel('Y [m]')


figure 
%Plots psi
plot(length,history(:,9))
title('Z plot')
xlabel('Time [depends on dt]')
ylabel('Z [m]')






