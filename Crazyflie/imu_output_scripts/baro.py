import logging

import cflib.crtp
from cfclient.utils.logconfigreader import LogConfig
from cfclient.utils.logconfigreader import LogVariable
from cflib.crazyflie import Crazyflie

logging.basicConfig(level=logging.DEBUG)


class Main:
    """
    Class is required so that methods can baroess the object fields.
    """
    def __init__(self):
        """
        Connect to Crazyflie, initialize drivers and set up callback.

        The callback takes care of logging the baroerometer values.
        """
        self.crazyflie = Crazyflie()
        cflib.crtp.init_drivers()

        self.crazyflie.connectSetupFinished.add_callback(
                                                    self.connectSetupFinished)

        self.crazyflie.open_link("radio://0/10/250K")

    def connectSetupFinished(self, linkURI):
        """
        Configure the logger to log baroerometer values and start recording.

        The logging variables are added one after another to the logging
        configuration. Then the configuration is used to create a log packet
        which is cached on the Crazyflie. If the log packet is None, the
        program exits. Otherwise the logging packet receives a callback when
        it receives data, which prints the data from the logging packet's
        data dictionary as logging info.
        """
        # Set baroerometer logging config
        baro_log_conf = LogConfig("baro", 10)
        baro_log_conf.addVariable(LogVariable("baro.asl", "float"))
        baro_log_conf.addVariable(LogVariable("baro.aslRaw", "float"))
        baro_log_conf.addVariable(LogVariable("baro.aslLong", "float"))
        baro_log_conf.addVariable(LogVariable("baro.temp", "float"))
        baro_log_conf.addVariable(LogVariable("baro.pressure", "float"))



        # Now that the connection is established, start logging
        self.baro_log = self.crazyflie.log.create_log_packet(baro_log_conf)

        if self.baro_log is not None:
            self.baro_log.dataReceived.add_callback(self.log_baro_data)
            self.baro_log.start()
        else:
            print("baro.stuffs not found in log TOC")

    def log_baro_data(self, data):
        logging.info("Barometer: asl=%.2f, aslRaw=%.2f, aslLong=%.2f, temp=%.2f, pressure=%.2f" %
                     (data["baro.asl"], data["baro.aslRaw"], data["baro.aslLong"], data["baro.temp"], data["baro.pressure"]))

Main()

