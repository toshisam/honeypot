#!/usr/bin/python
#
# Uses web.py to capture data from dionea honeypots using the built in http_submit option
# 
# 10/22/2011
# Greg Martin - gregcmartin@gmail.com
# 
#
import web
import sys
import datetime
import socket
import unicodedata


# Submit URL
urls = (
  '/submit', 'attack_submit'
)

# Convert int to IP addy
def inttoip(ip):
    return socket.inet_ntoa(hex(ip)[2:].zfill(8).decode('hex'))

# Timestamp
def gettime():
    t=datetime.datetime.now()
    now = t.strftime('%d-%m-%Y %H:%M:%S')
    return now

# Logging
def ofile(x):
    f = open('attack_submit.log', 'a')
    f.write('\n'+x)
    f.close

# HTTP POST
class attack_submit:
    def POST(self):
        udata = web.input(honeypot = [])
        # Set submit properties
        url =  udata.url
        filetype = udata.filetype
        filename = udata.filename
        trigger = udata.trigger
        target_port = udata.target_port
        source_host = inttoip(int(udata.source_host))
        honeypot = udata.honeypot
        md5 = udata.md5
        sha512 = udata.sha512
        email = udata.email
        target_host = inttoip(int(udata.target_host))
        # Log entry
        for i in udata:
            print udata[i]
        ofile(gettime()+','+url+','+target_port+','+source_host+','+md5+','+email+','+target_host)
        # DB insert code goes here
        #
        return 'successfully collected attack'


if __name__ == "__main__": 
    app = web.application(urls, globals())
    app.run()
