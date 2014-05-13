#!/usr/bin/python

import math
import time
import sys
import copy
from copy import deepcopy

#Declaration of variables#
angles = [[0,0,0],[0,0,0],[0,0,0]]
pangles = [[0,0,0],[0,0,0],[0,0,0]]
dangles = [[0,0,0],[0,0,0],[0,0,0]]

cart = [[0,0,0],[0,0,0],[0,0,0]]
pcart = [[0,0,0],[0,0,0],[0,0,0]]
dcart = [[0,0,0],[0,0,0],[0,0,0]]
length = 100

u = [0]*4

#Quadcopter constants#
Ix = 7.5*10**-3
Iy = 7.5*10**-3
Iz = 1.3*10**-2
Jr = 6.5*10**-5
b = 3.13*10**-5
d = 7.5*10**-7
l = 0.23
m = 0.65
g = 9.81
dt = 0.01

#Gains#
kpp = 0.8
kdp = 0.4
kpt = 1.2
kdt = 0.4
kpps = 1
kdps = 0.4
kpz = 100
kdz = 20

#Desired Values
dcart = [[0,0,0],[0,0,0],[1,0,0]]
dangles = [[0,0,0],[0,0,0],[math.pi/6,0,0]]

def main():
	global angles
	global pangles
	global cart
	global pcart

	for i in range(0, length):
		time.sleep(.01)
		PD_Cont()
		quadsysfun()
		#Update pangles and pcart
	        #pangles = copy.deepcopy(angles)
        	#pcart = copy.deepcopy(cart)
	

#if __name__=="__main__":
#	main()


#def PD_Cont(angles,pangles,dangles,cart,pcart,dcart,dt):
def PD_Cont():
	global angles
	global pangles 
	global dangles
	global cart
	global pcart
	global dcart
	global dt
	#U1#
	eZ = dcart[2][0] - cart[2][0]
	zcomb = m*(eZ*kpz-((cart[2][0]-pcart[2][0])/dt)*kdz)
	phithetacomb = math.cos(angles[0][0])*math.cos(angles[1][0])
	u[0] = 1 - (zcomb/phithetacomb)
	
	#U2#
	ephi = dangles[0][0] - angles[0][0]
	u[1] = (ephi*kpp) - ((angles[0][0]-pangles[0][0])/dt)*kdp
	#U3#
	etheta = dangles[1][0] - angles[1][0]
	u[2] = (etheta*kpt) - ((angles[1][0]-pangles[1][0])/dt)*kdt
	
	#U4#
	epsi = dangles[2][0] - angles[2][0]
	u[3] = (epsi*kpps) - ((angles[2][0]-pangles[2][0])/dt)*kdps
	return 


#def quadsysfun(u, angles, pangles, cart, pcart):
def quadsysfun():
	global u
	global angles
	global pangles
	global cart
	global pcart

	x1 = u[0]/(4*b)
	x2 = u[1]/(2*b*l)
	x3 = u[2]/(2*b*l)
	x4 = u[3]/(4*d)

	omegasqr1 = x1+x3+x4
	omegasqr2 = x1-x2+x4
	omegasqr3 = x1-x3-x4
	omegasqr4 = x1+x2+x4
	omegasqr5 = -omegasqr1+omegasqr2-omegasqr3+omegasqr4
	OMEGA = omegasqr5*d


	omegasqr1cal = omegasqr1+omegasqr2+omegasqr3+omegasqr4
	omegasqr2cal = -omegasqr2+omegasqr4
	omegasqr3cal = omegasqr1-omegasqr3
	omegasqr4cal = -omegasqr1+omegasqr2-omegasqr3+omegasqr4
	

	U1_2 = omegasqr1cal*b
	U2_2 = omegasqr2cal*b
	U3_2 = omegasqr3cal*b
	U4_2 = omegasqr4cal*d
	#print U1_2
	#print U2_2
	#print U3_2
	#print U4_2

	#putting previous angles and carts into pangles and pcart#
        #Update pangles and pcart
        pangles = copy.deepcopy(angles)
        pcart = copy.deepcopy(cart)

	#Part 2: Angles block (inputs:phi dot, theta dot, psi dot, U2, U3, U4,
	#OMEGA; outputs: phi dot dot, theta dot dot, psi dot dot)
	#phi
	p0 = ((Iy-Iz)/Ix)*angles[1][1]*angles[2][1];
	p1 = (Jr/Ix)*angles[1][1]*OMEGA;
	p2 = (l/Ix)*U2_2;
	angles[0][2] = p0+p1+p2;
	
	##psi#
	p3 = ((Iz-Ix)/Iy)*angles[0][1]*angles[2][1];
	p4 = (Jr/Iy)*angles[0][1]*OMEGA;
	p5 = (l/Iy)*U3_2;
	angles[1][2] = p3-p4+p5;
        

	p6 = ((Ix-Iy)/Iz)*angles[0][1]*angles[1][1];
	p7 = (1/Iz)*U4_2;
	angles[2][2] = p6+p7;
	

	##Part 3: Outputs and looping (takes integration of angles to loop angle
	#dots (velocities) to the Angles block and a second integrtation for the PD
	#Controller block and displacement block (using Trapezoidal rule to
	#approximate integration)
	#print ("Pangles:")
        #print pangles
	#print angles

	#Angular velocity calculations#
	angles[0][1] = pangles[0][1]+(dt*((pangles[0][2]+angles[0][2])/2))
	angles[1][1] = pangles[1][1]+(dt*((pangles[1][2]+angles[1][2])/2))
	angles[2][1] = pangles[2][1]+(dt*((pangles[2][2]+angles[2][2])/2))

	##Angular position calculation#
	angles[0][0] = pangles[0][0]+(dt*((pangles[0][1]+angles[0][1])/2))
	angles[1][0] = pangles[1][0]+(dt*((pangles[1][1]+angles[1][1])/2))
	angles[2][0] = pangles[2][0]+(dt*((pangles[2][1]+angles[2][1])/2))
	print ("Angles:")
	print angles
	##Part 4: Displacement block (inputs:phi,theta,psi,U1; outputs: xdotdot,
	#ydotdot, zdotdot)#

	p20 = math.cos(angles[0][0])*math.sin(angles[1][0])*math.cos(angles[2][0])
	p21 = math.sin(angles[0][0])*math.sin(angles[2][0])
	p22 = math.cos(angles[0][0])*math.sin(angles[1][0])*math.sin(angles[2][0])
	p23 = math.sin(angles[0][0])*math.cos(angles[2][0])
	p24 = math.cos(angles[0][0])*math.cos(angles[1][0])

	cart[0][2] = (U1_2/m)*(p20+p21)
	cart[1][2] = (U1_2/m)*(p22-p23)
	cart[2][2] = g - ((U1_2/m)*p24)
	#print ("Pcart:")
	#print pcart

	##Part 5: Outputs of Coordinates#
	##Calculate xdot, ydot, and zdot#
	cart[0][1] = pcart[0][1]+(dt*((pcart[0][2]+cart[0][2])/2))
	cart[1][1] = pcart[1][1]+(dt*((pcart[1][2]+cart[1][2])/2))
	cart[2][1] = pcart[2][1]+(dt*((pcart[2][2]+cart[2][2])/2))

	##Calculate x, y, and z#
	cart[0][0] = pcart[0][0]+(dt*((pcart[0][1]+cart[0][1])/2))
	cart[1][0] = pcart[1][0]+(dt*((pcart[1][1]+cart[1][1])/2))
	cart[2][0] = pcart[2][0]+(dt*((pcart[2][1]+cart[2][1])/2))
	print ("Cart:")
	print cart
	#pangles = angles
	#pcart = cart
	#print ("Pangles:")
	#print pangles
	#print ("Pcart:")
	#print pcart


	return



if __name__=="__main__":
        main()










