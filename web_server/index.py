#!/usr/bin/env python
##
##  This script has been created for moug's project. Moug's project is owned
##  by Capucine Thery. This script has been wrote by Loic Juillet.
##

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

SCORE_RED           = 5
SCORE_BLUE          = 5

################################## SERVER ######################################

#   PRINT SCORES
@app.route("/end", methods=['GET'])
def End():
    global SCORE_RED, SCORE_BLUE

    return render_template("end.html", red=SCORE_RED, blue=SCORE_BLUE)

#   RETURN SETTINGS FOR TIMER IN MINUTES
@app.route("/settings-home", methods=['GET'])
def SettingsHome():
    global LIMIT_TIME

    content = str(LIMIT_TIME)
    return jsonify(content=content)

#   DISPLAY MOUG FACE
@app.route("/moug", methods=['GET'])
def Moug():
    return render_template("moug.html")

#   GET TRUE OR FALSE ACCORDING TO THE GAME STATUS
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

#   RESET ALL GLOBAL VARS FOR GAME
@app.route("/reset", methods=['GET'])
def Reset():
    global STATUS, TIME, LIMIT_TIME, LIMIT_PLAYER, SCORE_RED, SCORE_BLUE

    STATUS = False
    TIME = None
    LIMIT_TIME = 0
    LIMIT_PLAYER = 0
    SCORE_RED = 0
    SCORE_BLUE = 0

    content = "ok"
    return jsonify(content=content)

#   STOP GAME COUNTER AND SET STATUS TO FALSE
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

#   START GAME COUNTER AND SET STATUS TO TRUE
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

#   LIST DEVICES IP CONNECTED
@app.route("/list", methods=['GET'])
def List():
    global CLIENTS, TEAM_RED, TEAM_BLUE

    return jsonify(content="list",
                   traffic=len(CLIENTS),
                   clients=CLIENTS,
                   teamBlue=TEAM_BLUE,
                   teamRed=TEAM_RED)

################################## CLIENT ######################################

#   RETURN TEAM COLOR
@app.route("/team", methods=['GET'])
def Team():
    global TEAM_RED, TEAM_BLUE
    content = "Something went wrong..."

    client = request.environ['REMOTE_ADDR']
    if client in TEAM_RED :
        content = "RED"
    elif client in TEAM_BLUE :
        content = "BLUE"
    return content


#   RETURN SETTINGS FOR TIMER IN MINUTES
@app.route("/settings", methods=['GET'])
def Settings():
    global LIMIT_TIME

    content = str(LIMIT_TIME)
    return content

#   RETURN OK IF THE GAME HAS STARTED
@app.route("/wait", methods=['GET'])
def Wait():
    global STATUS
    content = "nope"

    if STATUS == True :
        content = "ok"
    return content

#   COLLECT SCORE
@app.route("/score/<int:score>", methods=['GET'])
def Score(score):
    global CLIENTS, TEAM_RED, TEAM_BLUE, SCORE_RED, SCORE_BLUE
    content = "Something went wrong..."

    client = request.environ['REMOTE_ADDR']
    if client in CLIENTS :
        if client in TEAM_RED :
            SCORE_RED = SCORE_RED + score
            content = str(score) + 'pts for TEAM_RED'
        elif client in TEAM_BLUE :
            SCORE_BLUE = SCORE_BLUE + score
            content = str(score) + 'pts for TEAM_BLUE'
    print content
    return content

#   CONNECTION
@app.route("/connection", methods=['GET'])
def Connection():
    global CLIENTS, TEAM_RED, TEAM_BLUE, NEXT_TEAM
    content = "Something went wrong..."
    team = ""

    client = request.environ['REMOTE_ADDR']
    if client in CLIENTS :
        content = "Already connected as "
        if client in TEAM_RED :
            team = "RED"
        elif client in TEAM_BLUE :
            team = "BLUE"
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
    return team

#   DISCONNECTION
@app.route("/disconnection", methods=['GET'])
def Disconnection():
    global CLIENTS
    content = "Something went wrong..."

    client = request.environ['REMOTE_ADDR']
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
    return content

################################## UTILS #######################################

#   APPLY GAME SETTINGS
@app.route("/tutorial", methods=['POST'])
def Tutorial():
    global LIMIT_TIME, LIMIT_PLAYER
    id_game = request.form['id-game'];
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
                           id_game=id_game,
                           duration=LIMIT_TIME,
                           participants=LIMIT_PLAYER)

#   SET GAME RULES
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


#   404 HANDLER
@app.errorhandler(404)
def page_not_found(error):
    return render_template('err404.html'), 404


if __name__ == "__main__":
    app.debug = True
    app.run(host='0.0.0.0', port=80)
