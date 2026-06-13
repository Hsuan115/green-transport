from flask import Flask, jsonify
from flask_cors import CORS

from final.backend.routes.auth_route import auth
from final.backend.routes.transport_route import transport
from final.backend.routes.record_route import record
from final.backend.routes.analysis_route import analysis
from final.backend.routes.feedback_route import feedback

app = Flask(__name__)
CORS(app, supports_credentials=True)

app.secret_key = "your_secret_key"


# 註冊路由
app.register_blueprint(auth)
app.register_blueprint(transport)
app.register_blueprint(record)
app.register_blueprint(analysis)
app.register_blueprint(feedback)


@app.route("/")
def index():
    return jsonify({
        "status": "success",
        "message": "Carbon footprint API is running"
    })


if __name__ == "__main__":
    app.run(
        port=3000,
        debug=True
    )

