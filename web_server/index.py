#!/usr/bin/env python

from datetime       import datetime, time
from time           import sleep
from flask          import Flask, jsonify, request, render_template

import thread, threading

app                 = Flask(__name__)

CLIENTS             = []
STATUS              = False
TIME                = None
SCORE_RED           = 0
RED_TEAM            = []
SCORE_BLUE          = 0
BLUE_TEAM           = []
NEXT_TEAM           = "RED"

@app.route("/status", methods=['GET'])
def Status():
    global CLIENTS, STATUS, TIME, TIME_LOCK, LAST_UPDATE
    content = "Something went wrong"
    time = datetime.now()

    if STATUS == True :
        offset = time - TIME
        content = "Game has been started for " + str(offset.seconds / 60) + "m " + str(offset.seconds % 60) + "s"
    else :
        content = "No game instantiated"
    return jsonify(content=content,
                   clients=CLIENTS,
                   status=STATUS)

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
    else :
        content = "Game has already started"
    return jsonify(content=content)

@app.route("/list", methods=['GET'])
def List():
    global CLIENTS, RED_TEAM, BLUE_TEAM

    return jsonify(content="list",
                   traffic=len(CLIENTS),
                   clients=CLIENTS,
                   teamBlue=BLUE_TEAM,
                   teamRed=RED_TEAM)

@app.route("/connection", methods=['GET'])
def Connection():
    global CLIENTS, RED_TEAM, BLUE_TEAM, NEXT_TEAM
    content = "Something went wrong..."
    team = ""

    client = request.environ['REMOTE_ADDR']
    if client == '127.0.0.1' :
        content = "Welcome home"
    else :
        if client in CLIENTS :
            content = "Already connected"
        else :
            CLIENTS.append(client)
            content = "Connected as "
            if NEXT_TEAM == "RED" :
                RED_TEAM.append(client)
                NEXT_TEAM = "BLUE"
                content = content + "RED"
                team = "RED"
            elif NEXT_TEAM == "BLUE" :
                BLUE_TEAM.append(client)
                NEXT_TEAM = "RED"
                content = content + "BLUE"
                team = "BLUE"
            else :
                content = "Something went wrong with NEXT_TEAM..."
    return jsonify(content=content,
                   team=team)

@app.route("/disconnection", methods=['GET'])
def Disconnection():
    global CLIENTS
    content = "Something went wrong..."

    client = request.environ['REMOTE_ADDR']
    if client == '127.0.0.1' :
        content = "Welcome home"
    else :
        if client in CLIENTS :
            CLIENTS.remove(client)
            content = "Disconnected from "
            if client in RED_TEAM :
                RED_TEAM.remove(client)
                content = content + "RED"
            elif client in BLUE_TEAM :
                BLUE_TEAM.remove(client)
                content = content + "BLUE"
            else :
                content = content + "NEUTRAL"
        else :
            content = "Was not connected"
    return jsonify(content=content)

@app.route("/", methods=['GET'])
def Index():
    global CLIENTS, RED_TEAM, BLUE_TEAM, STATUS, TIME
    content = "Something went wrong..."
    now = datetime.now()

    if STATUS == True :
        if TIME is not None :
            offset = now - TIME
            content = "Game has started " + str(offset.seconds / 60) + "m " + str(offset.seconds % 60) + "s ago"
    else :
        content = "No game instantiated"
    return render_template("index.html",
                           content=content,
                           traffic=len(CLIENTS),
                           teamRed=RED_TEAM,
                           teamBlue=BLUE_TEAM,
                           status=STATUS)

@app.errorhandler(404)
def page_not_found(error):
    return render_template('err404.html'), 404

if __name__ == "__main__":
    app.debug = True
    app.run(host='0.0.0.0', port=80)
