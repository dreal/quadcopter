import logging

import cflib.crtp
from cfclient.utils.logconfigreader import LogConfig
from cfclient.utils.logconfigreader import LogVariable
from cflib.crazyflie import Crazyflie

logging.basicConfig(level=logging.DEBUG)


class Main:
    """
    Class is required so that methods can gyroess the object fields.
    """
    def __init__(self):
        """
        Connect to Crazyflie, initialize drivers and set up callback.

        The callback takes care of logging the gyroerometer values.
        """
        self.crazyflie = Crazyflie()
        cflib.crtp.init_drivers()

        self.crazyflie.connectSetupFinished.add_callback(
                                                    self.connectSetupFinished)

        self.crazyflie.open_link("radio://0/7/250K")

    def connectSetupFinished(self, linkURI):
        """
        Configure the logger to log gyroerometer values and start recording.

        The logging variables are added one after another to the logging
        configuration. Then the configuration is used to create a log packet
        which is cached on the Crazyflie. If the log packet is None, the
        program exits. Otherwise the logging packet receives a callback when
        it receives data, which prints the data from the logging packet's
        data dictionary as logging info.
        """
        # Set gyroerometer logging config
        gyro_log_conf = LogConfig("gyro", 10)
        gyro_log_conf.addVariable(LogVariable("gyro.x", "float"))
        gyro_log_conf.addVariable(LogVariable("gyro.y", "float"))
        gyro_log_conf.addVariable(LogVariable("gyro.z", "float"))

        # Now that the connection is established, start logging
        self.gyro_log = self.crazyflie.log.create_log_packet(gyro_log_conf)

        if self.gyro_log is not None:
            self.gyro_log.dataReceived.add_callback(self.log_gyro_data)
            self.gyro_log.start()
        else:
            print("gyro.x/y/z not found in log TOC")

    def log_gyro_data(self, data):
        logging.info("Gyrometer: x=%.2f, y=%.2f, z=%.2f" %
                     (data["gyro.x"], data["gyro.y"], data["gyro.z"]))

Main()

