from flask import Flask, jsonify, request
import os
import boto3

app = Flask(__name__)

@app.route("/")
def root():
    return jsonify({
        "message": "Hello from Bonmoja ECS!",
        "headers": dict(request.headers),
        "env": {k: v for k, v in os.environ.items() if k.startswith("AWS_")},
    })

@app.route("/health")
def health():
    return jsonify({"status": "ok"})

@app.route("/aws")
def aws_demo():
    try:
        client = boto3.client("sts")
        identity = client.get_caller_identity()
        return jsonify({"aws_identity": identity})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080) 