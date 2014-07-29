#! /usr/bin/python

# To kick off the script, run the following from the python directory:
#   PYTHONPATH=`pwd` python dooraction.py start
import sqlite3
import logging
import time
import os
from daemon import runner
import pycurl
import pifacedigitalio as piface

conn = sqlite3.connect('/var/sqlite/garagemon.db')

c = conn.cursor()
c.execute('SELECT command FROM dooraction WHERE completion_time is NULL')
command = c.fetchone()
#print command

c.execute('SELECT current_position FROM position')
status = c.fetchone()
#print status

if status != command:
	piface.init()
	piface.digital_write(0,1)
	time.sleep(1)
	piface.digital_write(0,0)
	## Set db completion_time




