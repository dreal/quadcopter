import logging

import cflib.crtp
from cfclient.utils.logconfigreader import LogConfig
from cfclient.utils.logconfigreader import LogVariable
from cflib.crazyflie import Crazyflie

logging.basicConfig(level=logging.DEBUG)


class Main:
    """
    Class is required so that methods can magess the object fields.
    """
    def __init__(self):
        """
        Connect to Crazyflie, initialize drivers and set up callback.

        The callback takes care of logging the magerometer values.
        """
        self.crazyflie = Crazyflie()
        cflib.crtp.init_drivers()

        self.crazyflie.connectSetupFinished.add_callback(
                                                    self.connectSetupFinished)

        self.crazyflie.open_link("radio://0/7/250K")

    def connectSetupFinished(self, linkURI):
        """
        Configure the logger to log magerometer values and start recording.

        The logging variables are added one after another to the logging
        configuration. Then the configuration is used to create a log packet
        which is cached on the Crazyflie. If the log packet is None, the
        program exits. Otherwise the logging packet receives a callback when
        it receives data, which prints the data from the logging packet's
        data dictionary as logging info.
        """
        # Set magerometer logging config
        mag_log_conf = LogConfig("mag", 10)
        mag_log_conf.addVariable(LogVariable("mag.x", "float"))
        mag_log_conf.addVariable(LogVariable("mag.y", "float"))
        mag_log_conf.addVariable(LogVariable("mag.z", "float"))

        # Now that the connection is established, start logging
        self.mag_log = self.crazyflie.log.create_log_packet(mag_log_conf)

        if self.mag_log is not None:
            self.mag_log.dataReceived.add_callback(self.log_mag_data)
            self.mag_log.start()
        else:
            print("mag.x/y/z not found in log TOC")

    def log_mag_data(self, data):
        logging.info("Magnometer: x=%.2f, y=%.2f, z=%.2f" %
                     (data["mag.x"], data["mag.y"], data["mag.z"]))

Main()

