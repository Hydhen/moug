#!/usr/bin/env python

from datetime       import datetime, time
from time           import sleep
from flask          import Flask, jsonify, request
import thread, threading

app                 = Flask(__name__)

CLIENTS             = []
STATUS              = False
TIME                = None
LAST_UPDATE         = None
TIME_LOCK           = thread.allocate_lock()
SCORE_RED           = 0
SCORE_BLUE          = 0

def HandleGame():
    global TIME, TIME_LOCK
    now = datetime.now()

    while True :
        LAST_UPDATE = now
        offset = now - TIME
        print "HandleGame: " + "Game has been started for " + str(offset.seconds / 60) + "m " + str(offset.seconds % 60) + "s"
        sleep(5)

@app.route("/status", methods=['GET'])
def Status():
    global CLIENTS, STATUS, TIME, TIME_LOCK, LAST_UPDATE
    content = "Something went wrong"
    time = datetime.now()
    last_lock = None
    last_lock_str = ""

    last_lock = LAST_UPDATE
    if last_lock is not None :
        last_lock_str = str(last_lock.second / 60) + "m " + str(last_lock.second % 60) + "s"
    else :
        last_lock_str = "Never"
    if STATUS == True :
        offset = time - TIME
        content = "Game has been started for " + str(offset.seconds / 60) + "m " + str(offset.seconds % 60) + "s"
    else :
        content = "No game instantiated"
    return jsonify(content=content,
                   clients=CLIENTS,
                   status=STATUS,
                   lastUpdate=last_lock_str)

@app.route("/stop", methods=['GET'])
def Stop():
    global CLIENTS, STATUS, TIME
    content = "Something went wrong"
    now = datetime.now()

    if STATUS == True :
        offset = now - TIME
        STATUS = False
        content = "Game last " + str(offset.seconds / 60) + "m " + str(offset.seconds % 60) + "s"
    else :
        content = "No game instantiated"
    return jsonify(content=content)

@app.route("/start", methods=['GET'])
def Start():
    global CLIENTS, STATUS, TIME, TIME_LOCK
    content = "Something went wrong"

    if STATUS == False :
        TIME = datetime.now()
        STATUS = True
        content = "Game start"
        thread = threading.Thread(target=HandleGame)
        thread.start()
    else :
        content = "Game has already started"
    return jsonify(content=content)

@app.route("/list", methods=['GET'])
def List():
    global CLIENTS

    return jsonify(content="list",
                   traffic=len(CLIENTS),
                   clients=CLIENTS)

@app.route("/connexion", methods=['GET'])
def Connexion():
    global CLIENTS
    content = "Something went wrong..."

    client = request.environ['REMOTE_ADDR']
    if client in CLIENTS :
        content = "Already connected"
    else :
        CLIENTS.append(client)
        content = "Connected"
    return jsonify(content=content)

@app.route("/disconnexion", methods=['GET'])
def Disconnexion():
    global CLIENTS
    content = "Something went wrong..."

    client = request.environ['REMOTE_ADDR']
    if client in CLIENTS :
        CLIENTS.remove(client)
        content = "Disconnected"
    else :
        content = "Was not connected"
    return jsonify(content=content)

if __name__ == "__main__":
    app.debug = True
    app.run(host='0.0.0.0', port=80)
