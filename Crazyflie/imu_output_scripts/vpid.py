import logging

import cflib.crtp
from cfclient.utils.logconfigreader import LogConfig
from cfclient.utils.logconfigreader import LogVariable
from cflib.crazyflie import Crazyflie

logging.basicConfig(level=logging.DEBUG)


class Main:
    """
    Class is required so that methods can vpidess the object fields.
    """
    def __init__(self):
        """
        Connect to Crazyflie, initialize drivers and set up callback.

        The callback takes care of logging the vpiderometer values.
        """
        self.crazyflie = Crazyflie()
        cflib.crtp.init_drivers()

        self.crazyflie.connectSetupFinished.add_callback(
                                                    self.connectSetupFinished)

        self.crazyflie.open_link("radio://0/8/250K")

    def connectSetupFinished(self, linkURI):
        """
        Configure the logger to log vpiderometer values and start recording.

        The logging variables are added one after another to the logging
        configuration. Then the configuration is used to create a log packet
        which is cached on the Crazyflie. If the log packet is None, the
        program exits. Otherwise the logging packet receives a callback when
        it receives data, which prints the data from the logging packet's
        data dictionary as logging info.
        """
        # Set vpiderometer logging config
        vpid_log_conf = LogConfig("vpid", 10)
        vpid_log_conf.addVariable(LogVariable("vpid.pid", "float"))
        vpid_log_conf.addVariable(LogVariable("vpid.p", "float"))
        vpid_log_conf.addVariable(LogVariable("vpid.i", "float"))
        vpid_log_conf.addVariable(LogVariable("vpid.d", "float"))


        # Now that the connection is established, start logging
        self.vpid_log = self.crazyflie.log.create_log_packet(vpid_log_conf)

        if self.vpid_log is not None:
            self.vpid_log.dataReceived.add_callback(self.log_vpid_data)
            self.vpid_log.start()
        else:
            print("vpid.stuffs not found in log TOC")

    def log_vpid_data(self, data):
        logging.info("PID gains: pid=%.2f, p=%.2f, i=%.2f, d=%.2f" %
                     (data["vpid.pid"], data["vpid.p"], data["vpid.i"], data["vpid.d"]))

Main()

