from os import getenv

from dotenv import load_dotenv
from flask import Flask
from flask import current_app
from flask import json
from flask import jsonify
from flask import make_response
from flask import request
from flask_mail import Mail
from flask_mail import Message
from werkzeug.middleware.proxy_fix import ProxyFix


load_dotenv()

app = Flask(__name__)
app.config.update(
    DEBUG=getenv("FLASK_DEBUG") == "True",
    MAIL_SERVER=getenv("FLASK_MAIL_SERVER"),
    MAIL_PORT=getenv("FLASK_MAIL_PORT"),
    MAIL_USE_SSL=getenv("FLASK_MAIL_USE_SSL"),
    MAIL_DEBUG=False,
    MAIL_USERNAME=getenv("FLASK_MAIL_USERNAME"),
    MAIL_PASSWORD=getenv("FLASK_MAIL_PASSWORD"),
    MAIL_RECIPIENT=getenv("FLASK_MAIL_RECIPIENT"),
    MAIL_SENDER=getenv("FLASK_MAIL_SENDER")
)
app.wsgi_app = ProxyFix(app.wsgi_app)

mail = Mail(app)


@app.after_request
def after(response):
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Headers"] = "*"
    return response


@app.route("/rfq", methods=["POST"])
def send_rfq():
    payload = request.json
    payload = json.loads(json.htmlsafe_dumps(payload))

    if payload is None:
        resp = jsonify(error="invalid data")
        return make_response(resp, 400)

    if "email" not in payload:
        resp = jsonify(error="missing email")
        return make_response(resp, 400)

    if "note" not in payload:
        resp = jsonify(error="missing note")
        return make_response(resp, 400)

    if "configuration" not in payload:
        resp = jsonify(error="missing configuration")
        return make_response(resp, 400)

    sender = current_app.config["MAIL_SENDER"]
    recipient = current_app.config["MAIL_RECIPIENT"]

    msg = Message(
        "RFQ for Sinara hardware from {}".format(payload["email"]),
        sender=sender,
        recipients=[recipient, payload["email"]])
    msg.body = ("From: {}\nConfiguration: {}\nNote: {}"
        .format(payload["email"], payload["configuration"], payload["note"]))

    with mail.connect() as conn:
        conn.send(msg)

    return jsonify("ok")
