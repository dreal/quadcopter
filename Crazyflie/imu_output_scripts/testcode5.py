import logging

import cflib.crtp
from cfclient.utils.logconfigreader import LogConfig
from cfclient.utils.logconfigreader import LogVariable
from cflib.crazyflie import Crazyflie

logging.basicConfig(level=logging.DEBUG)


class Main:
    """
    Class is required so that methods can access the object fields.
    """
    def __init__(self):
        """
        Connect to Crazyflie, initialize drivers and set up callback.
 
        The callback takes care of logging the accelerometer values.
        """
        self.crazyflie = Crazyflie()
        cflib.crtp.init_drivers()

        self.crazyflie.connectSetupFinished.add_callback(
                                                    self.connectSetupFinished)

        self.crazyflie.open_link("radio://0/10/250K")

    def connectSetupFinished(self, linkURI):
        """
        Configure the logger to log accelerometer values and start recording.
 
        The logging variables are added one after another to the logging
        configuration. Then the configuration is used to create a log packet
        which is cached on the Crazyflie. If the log packet is None, the
        program exits. Otherwise the logging packet receives a callback when
        it receives data, which prints the data from the logging packet's
        data dictionary as logging info.
        """
        # Set stabilizer logging config
        acc_log_conf = LogConfig("acc", 10)
        acc_log_conf.addVariable(LogVariable("acc.x", "float"))
        acc_log_conf.addVariable(LogVariable("acc.y", "float"))
        acc_log_conf.addVariable(LogVariable("acc.z", "float"))

        # Now that the connection is established, start logging
        self.acc_log = self.crazyflie.log.create_log_packet(acc_log_conf)

        if self.acc_log is not None:
            self.acc_log.dataReceived.add_callback(self.log_acc_data)
            self.acc_log.start()
        else:
            print("acc.x/y/z not found in log TOC")

    def log_acc_data(self, data):

        logging.info("Acceleration: X=%.2f, Y=%.2f, Z=%.2f" %
                        (data["acc.x"], data["acc.y"], data["acc.z"]))

Main()

