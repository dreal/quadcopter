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
 
        self.crazyflie.connectSetupFinished.add_callback(self.connectSetupFinished)
 
        self.crazyflie.open_link("radio://0/8/250K")
 
    def connectSetupFinished(self, linkURI):
        
	# Set accelerometer logging config
        motor_log_conf = LogConfig("motor", 10)
        motor_log_conf.addVariable(LogVariable("motor.m4", "int32_t"))
	motor_log_conf.addVariable(LogVariable("motor.m1", "int32_t"))
	motor_log_conf.addVariable(LogVariable("motor.m2", "int32_t")) 
	motor_log_conf.addVariable(LogVariable("motor.m3", "int32_t"))      
 
        # Now that the connection is established, start logging
        self.motor_log = self.crazyflie.log.create_log_packet(motor_log_conf)
 
        if self.motor_log is not None:
		self.motor_log.dataReceived.add_callback(self.log_motor_data)
		self.motor_log.start()
        else:
		print("motor.m1/m2/m3/m4 not found in log TOC")
		self.crazyflie.close_link()

    def log_motor_data(self,data):
        thrust_mult = 3
        thrust_step = 500
        thrust = 20000
        pitch = 0
        roll = 0
        yawrate = 0
        while thrust >= 20000:
            self.crazyflie.commander.send_setpoint(roll, pitch, yawrate, thrust)
            time.sleep(0.1)
            if (thrust >= 50000):
                time.sleep(.01)
                thrust_mult = -1
            thrust = thrust + (thrust_step * thrust_mult)
        self.crazyflie.commander.send_setpoint(0,0,0,0)
        # Make sure that the last packet leaves before the link is closed
        # since the message queue is not flushed before closing
        time.sleep(0.1)



	
    def log_motor_data(self, data):
        logging.info("Motors: m1=%.2f, m2=%.2f, m3=%.2f, m4=%.2f" %                        (data["motor.m1"], data["motor.m2"], data["motor.m3"], data["motor.m4"]))



    
Main()
