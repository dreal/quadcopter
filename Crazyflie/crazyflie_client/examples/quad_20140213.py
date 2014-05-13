# -*- coding: utf-8 -*-
#
#     ||          ____  _ __
#  +------+      / __ )(_) /_______________ _____  ___
#  | 0xBC |     / __  / / __/ ___/ ___/ __ `/_  / / _ \
#  +------+    / /_/ / / /_/ /__/ /  / /_/ / / /_/  __/
#   ||  ||    /_____/_/\__/\___/_/   \__,_/ /___/\___/
#
#  Copyright (C) 2014 Bitcraze AB
#
#  Crazyflie Nano Quadcopter Client
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA  02110-1301, USA.

"""
Simple example that connects to the first Crazyflie found, logs the Stabilizer
and prints it to the console. After 10s the application disconnects and exits.
"""

import sys
sys.path.append("../lib")
import cflib.crtp
import logging
import time
from threading import Timer
from threading import Thread
import cflib.crtp
from cfclient.utils.logconfigreader import LogConfig
from cflib.crazyflie import Crazyflie

# Only output errors from the logging framework
logging.basicConfig(level=logging.ERROR)

g_acc_x = 0
g_acc_y = 0
g_acc_z = 0
g_gyro_x = 0
g_gyro_y = 0
g_gyro_z = 0
g_roll = 0
g_pitch = 0
g_yaw = 0

class Quad:
    """
    Simple logging example class that logs the Stabilizer from a supplied
    link uri and disconnects after 5s.
    """
    def __init__(self, link_uri):
        """ Initialize and run the example with the specified link_uri """

        # Create a Crazyflie object without specifying any cache dirs
        self._cf = Crazyflie()

        # Connect some callbacks from the Crazyflie API
        self._cf.connected.add_callback(self._connected)
        self._cf.disconnected.add_callback(self._disconnected)
        self._cf.connection_failed.add_callback(self._connection_failed)
        self._cf.connection_lost.add_callback(self._connection_lost)

        print "Connecting to %s" % link_uri

        # Try to connect to the Crazyflie
        self._cf.open_link(link_uri)

        # Variable used to keep main loop occupied until disconnect
        self.is_connected = True

    def _connected(self, link_uri):
        """ This callback is called form the Crazyflie API when a Crazyflie
        has been connected and the TOCs have been downloaded."""
        print "Connected to %s" % link_uri

        Thread(target=self._control).start()

        ########################################################################
        # Set up Stabilizer Logger
        ########################################################################
        self._lg_stab = LogConfig(name="Stabilizer", period_in_ms=10)
        self._lg_stab.add_variable("stabilizer.roll", "float")
        self._lg_stab.add_variable("stabilizer.pitch", "float")
        self._lg_stab.add_variable("stabilizer.yaw", "float")
        self._cf.log.add_config(self._lg_stab)
        if self._lg_stab.valid:
            # This callback will receive the data
            self._lg_stab.data_received_cb.add_callback(self._log_stab_data)
            # This callback will be called on errors
            self._lg_stab.error_cb.add_callback(self._log_error)
            # Start the logging
            self._lg_stab.start()
        else:
            print("Could not add logconfig since some variables are not in TOC")

        ########################################################################
        # Set up Acc Logger
        ########################################################################
        self._lg_acc = LogConfig(name="Acc", period_in_ms=10)
        self._lg_acc.add_variable("acc.x", "float")
        self._lg_acc.add_variable("acc.y", "float")
        self._lg_acc.add_variable("acc.z", "float")
        self._cf.log.add_config(self._lg_acc)
        if self._lg_acc.valid:
            # This callback will receive the data
            self._lg_acc.data_received_cb.add_callback(self._log_acc_data)
            # This callback will be called on errors
            self._lg_acc.error_cb.add_callback(self._log_error)
            # Start the logging
            self._lg_acc.start()
        else:
            print("Could not add logconfig since some variables are not in TOC")

        ########################################################################
        # Set up Gyro Logger
        ########################################################################
        self._lg_gyro = LogConfig(name="Gyro", period_in_ms=10)
        self._lg_gyro.add_variable("gyro.x", "float")
        self._lg_gyro.add_variable("gyro.y", "float")
        self._lg_gyro.add_variable("gyro.z", "float")
        self._cf.log.add_config(self._lg_gyro)
        if self._lg_gyro.valid:
            # This callback will receive the data
            self._lg_gyro.data_received_cb.add_callback(self._log_gyro_data)
            # This callback will be called on errors
            self._lg_gyro.error_cb.add_callback(self._log_error)
            # Start the logging
            self._lg_gyro.start()
        else:
            print("Could not add logconfig since some variables are not in TOC")


    def _control(self):
        global g_roll, g_yaw, g_pitch;
        global g_acc_x, g_acc_y, g_acc_z;
        while True:
            print "Acc  : x    = %10f, y   = %10f, z     = %10f" % (g_acc_x, g_acc_y, g_acc_z)
            print "Gyro : x    = %10f, y   = %10f, z     = %10f" % (g_gyro_x, g_gyro_y, g_gyro_z)
            # print "Stab : roll = %10f, yaw = %10f, pitch = %10f" % (g_roll, g_yaw, g_pitch)
            time.sleep(0.1)
        # thrust_mult = 1
        # thrust_step = 500
        # thrust = 20000
        # pitch = 0
        # roll = 0
        # yawrate = 0
        # while thrust >= 20000:
        #     self._cf.commander.send_setpoint(roll, pitch, yawrate, thrust)
        #     time.sleep(0.1)
        #     if thrust >= 25000:
        #         thrust_mult = -1
        #     thrust += thrust_step * thrust_mult
        # self._cf.commander.send_setpoint(0, 0, 0, 0)
        # Make sure that the last packet leaves before the link is closed
        # since the message queue is not flushed before closing
        # time.sleep(0.1)
        # self._cf.close_link()

    def _log_error(self, logconf, msg):
        """Callback from the log API when an error occurs"""
        print "Error when logging %s: %s" % (logconf.name, msg)

    def _log_stab_data(self, timestamp, data, logconf):
        """Callback froma the log API when data arrives"""
        global g_roll, g_yaw, g_pitch;
        (g_roll, g_yaw, g_pitch) = (data["stabilizer.roll"], data["stabilizer.yaw"], data["stabilizer.pitch"])

    def _log_acc_data(self, timestamp, data, logconf):
        """Callback froma the log API when data arrives"""
        global g_acc_x, g_acc_y, g_acc_z;
        (g_acc_x, g_acc_y, g_acc_z) = (data["acc.x"], data["acc.y"], data["acc.z"])

    def _log_gyro_data(self, timestamp, data, logconf):
        """Callback froma the log API when data arrives"""
        global g_gyro_x, g_gyro_y, g_gyro_z;
        (g_gyro_x, g_gyro_y, g_gyro_z) = (data["gyro.x"], data["gyro.y"], data["gyro.z"])

    def _connection_failed(self, link_uri, msg):
        """Callback when connection initial connection fails (i.e no Crazyflie
        at the speficied address)"""
        print "Connection to %s failed: %s" % (link_uri, msg)
        self.is_connected = False

    def _connection_lost(self, link_uri, msg):
        """Callback when disconnected after a connection has been made (i.e
        Crazyflie moves out of range)"""
        print "Connection to %s lost: %s" % (link_uri, msg)

    def _disconnected(self, link_uri):
        """Callback when the Crazyflie is disconnected (called in all cases)"""
        print "Disconnected from %s" % link_uri
        self.is_connected = False

if __name__ == '__main__':
    # Initialize the low-level drivers (don't list the debug drivers)
    cflib.crtp.init_drivers(enable_debug_driver=False)
    # Scan for Crazyflies and use the first one found
    print "Scanning interfaces for Crazyflies..."
    available = cflib.crtp.scan_interfaces()
    print "Crazyflies found:"
    for i in available:
        print i[0]

    if len(available) > 0:
        le = Quad(available[0][0])
    else:
        print "No Crazyflies found, cannot run example"

    # The Crazyflie lib doesn't contain anything to keep the application alive,
    # so this is where your application should do something. In our case we
    # are just waiting until we are disconnected.
    while le.is_connected:
        time.sleep(1)
