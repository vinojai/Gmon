#! /usr/bin/python

# To kick off the script, run the following from the python directory:
#   PYTHONPATH=`pwd` python garagemon.py start

import pdb
import logging
import time
import sqlite3
import os
from daemon import runner
import pycurl
import pifacedigitalio as piface

curl = pycurl.Curl()
##sql = sqlite3.connect('/var/sqlite/garagemon.db')

class App():
   
    def __init__(self):
        self.stdin_path = '/dev/null'
        #self.stdout_path = '/dev/tty'
        #self.stderr_path = '/dev/tty'
        self.stdout_path = '/dev/null'
        self.stderr_path = '/dev/null'	
        self.pidfile_path =  '/var/run/garagemon.pid'
        self.pidfile_timeout = 5
           
    def run(self):
        print "begin"
        conn = sqlite3.connect('/var/sqlite/garagemon.db')
        ## I'm alive! Determine the last known door position
        c.execute('SELECT current_position FROM position')
        status = c.fetchone()
        doorState = "unknown"
        doorOpenCtr = 0
        piface.init()
        while True:
            ## Ping the router to keep the wifi alive
            response = os.system("ping -c 1 " + "10.0.0.1")

            if doorState is "open" and doorOpenCtr is 10:
                curl.setopt(curl.URL, 'http://localhost/evaluatestillopen')
                curl.perform()                            

            piface.digital_write_pullup(0, 1)
            ## Door open state
            if (piface.digital_read(0) == 0 and doorState is "closed") or doorState is "unknown":
                curl.setopt(curl.URL, 'http://localhost/evaluateopen')
                curl.perform() 
                doorState = "open";
                ## Set the little led lights
                # piface.digital_write(1, 0)
                # piface.digital_write(0, 1)
                doorOpenCtr = 0;
            ## Door closed state
            elif (piface.digital_read(0) > 0  and doorState is "open") or doorState is "unknown":
                curl.setopt(curl.URL, 'http://localhost/evaluateclosed')
                curl.perform()
                doorState = "closed";
                # Set the little led lights
                # piface.digital_write(0, 0)
                # piface.digital_write(1, 1)
            piface.digital_write_pullup(0, 0)
            # logger.debug("Debug message")
            # logger.info("Info message")
            # logger.warn("Warning message")
            # logger.error("Error message")
            # logger.info("Info message")
            # logger.info ('Memory usage: %s (kb)' % resource.getrusage(resource.RUSAGE_SELF).ru_maxrss)
            time.sleep(10)
            ## Increment the door open counter so we can be reminded once. 
            if doorState is "open":
                doorOpenCtr = doorOpenCtr + 1

app = App()
logger = logging.getLogger("DaemonLog")
logger.setLevel(logging.INFO)
formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
handler = logging.FileHandler("/var/log/garagemon/daemon.log")
handler.setFormatter(formatter)
logger.addHandler(handler)

daemon_runner = runner.DaemonRunner(app)
#This ensures that the logger file handle does not get closed during daemonization
daemon_runner.daemon_context.files_preserve=[handler.stream]
daemon_runner.do_action()





