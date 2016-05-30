#!/usr/bin/env python

from datetime       import datetime, time
from flask          import Flask, jsonify, request, render_template

app                 = Flask(__name__)

STATUS              = False
TIME                = None

LIMIT_TIME          = 0
LIMIT_PLAYER        = 0

CLIENTS             = []
TEAM_RED            = []
TEAM_BLUE           = []
NEXT_TEAM           = "RED"

SCORE_RED           = 0
SCORE_BLUE          = 0


#
#   GET TRUE OR FALSE ACCORDING TO THE GAME STATUS
#
@app.route("/status", methods=['GET'])
def Status():
    global CLIENTS, STATUS, TIME, TIME_LOCK, LAST_UPDATE
    content = "Something went wrong"
    time = datetime.now()

    if STATUS == True :
        offset = time - TIME
        content = "Game has been started for " + str(offset.seconds / 60) + "m "\
                  + str(offset.seconds % 60) + "s"
    else :
        content = "No game instantiated"
    return jsonify(content=content,
                   clients=CLIENTS,
                   status=STATUS)


#
#   STOP GAME COUNTER AND SET STATUS TO FALSE
#
@app.route("/stop", methods=['GET'])
def Stop():
    global CLIENTS, STATUS, TIME
    content = "Something went wrong"
    now = datetime.now()

    if STATUS == True :
        offset = now - TIME
        STATUS = False
        content = "Game lasts " + str(offset.seconds / 60) + "m "\
                  + str(offset.seconds % 60) + "s"
    else :
        content = "No game instantiated"
    return jsonify(content=content)


#
#   START GAME COUNTER AND SET STATUS TO TRUE
#
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


#
#   LIST DEVICES IP CONNECTED
#
@app.route("/list", methods=['GET'])
def List():
    global CLIENTS, TEAM_RED, TEAM_BLUE

    return jsonify(content="list",
                   traffic=len(CLIENTS),
                   clients=CLIENTS,
                   teamBlue=TEAM_BLUE,
                   teamRed=TEAM_RED)


#
#   CONNECTION AND DISCONNECTION
#
@app.route("/connection", methods=['GET'])
def Connection():
    global CLIENTS, TEAM_RED, TEAM_BLUE, NEXT_TEAM
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
                TEAM_RED.append(client)
                NEXT_TEAM = "BLUE"
                content = content + "RED"
                team = "RED"
            elif NEXT_TEAM == "BLUE" :
                TEAM_BLUE.append(client)
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
            if client in TEAM_RED :
                TEAM_RED.remove(client)
                content = content + "RED"
            elif client in TEAM_BLUE :
                TEAM_BLUE.remove(client)
                content = content + "BLUE"
            else :
                content = content + "NEUTRAL"
        else :
            content = "Was not connected"
    return jsonify(content=content)


#
#   APPLY GAME SETTINGS
#
@app.route("/tutorial", methods=['POST'])
def Tutorial():
    global LIMIT_TIME, LIMIT_PLAYER
    duration = request.form['duree']
    participants = request.form['participants']
    content = "Something went wrong..."

    if duration > 0 and participants > 0 :
        LIMIT_TIME = duration
        LIMIT_PLAYER = participants
        content = "Setted up for " + str(LIMIT_PLAYER) + " player and for "\
                  + str(LIMIT_TIME) + " minutes"
    return render_template("tutorial.html",
                           content=content,
                           duration=LIMIT_TIME,
                           participants=LIMIT_PLAYER)


#
#   SET GAME RULES
#
@app.route("/", methods=['GET'])
def Index():
    global CLIENTS, TEAM_RED, TEAM_BLUE, STATUS, TIME
    content = "Something went wrong..."
    now = datetime.now()

    if STATUS == True :
        if TIME is not None :
            offset = now - TIME
            content = "Game has started " + str(offset.seconds / 60) + "m "\
                      + str(offset.seconds % 60) + "s ago"
    else :
        content = "No game instantiated"
    return render_template("index.html",
                           content=content,
                           traffic=len(CLIENTS),
                           teamRed=TEAM_RED,
                           teamBlue=TEAM_BLUE,
                           status=STATUS)


#
#   404 HANDLER
#
@app.errorhandler(404)
def page_not_found(error):
    return render_template('err404.html'), 404


if __name__ == "__main__":
    app.debug = True
    app.run(host='0.0.0.0', port=80)
