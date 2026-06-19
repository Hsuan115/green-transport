# 修改後：請確認 record_route.py 的第一行改成這樣
from flask import Blueprint, request, jsonify, session
from database.db import get_db_connection
from datetime import date
record = Blueprint("record", __name__)


# 新增一筆交通紀錄
@record.route("/api/records", methods=["POST"])
def add_record():
    try:
        data = request.get_json()

        user_id = data.get("user_id")
        vehicle_id = data.get("vehicle_id")
        distance_km = data.get("distance_km")
        usage_date = data.get("usage_date", date.today().strftime("%Y-%m-%d"))

        if distance_km is None or vehicle_id is None:
            return jsonify({"error": "缺少交通工具與公里數"}), 400

        try:
            distance_km = float(distance_km)
            if distance_km <= 0:
                return jsonify({"error": "公里數必須大於 0"}), 400
        except ValueError:
            return jsonify({"error": "公里數必須是數字"}), 400

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT emission_per_km
            FROM Vehicles
            WHERE vehicle_id = %s
            """,
            (vehicle_id,)
        )
        vehicle = cursor.fetchone()

        if not vehicle:
            cursor.close()
            conn.close()
            return jsonify({"error": "找不到該交通工具選項"}), 404

        emission_per_km = float(vehicle["emission_per_km"])
        calculated_emission = distance_km * emission_per_km

        cursor.execute(
            """
            INSERT INTO Traffic_Records
            (user_id, vehicle_id, distance_km, usage_date, carbon_emission)
            VALUES (%s, %s, %s, %s, %s)
            """,
            (
                user_id,
                vehicle_id,
                distance_km,
                usage_date,
                calculated_emission
            )
        )
        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({
            "status": "success",
            "message": "交通紀錄新增成功",
            "data": {
                "user_id": user_id,
                "vehicle_id": vehicle_id,
                "usage_date": usage_date,
                "distance_km": distance_km,
                "carbon_emission": round(calculated_emission, 4)
            }
        }), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500




# 用日期範圍查詢交通紀錄
@record.route("/api/records", methods=["GET"])
def get_records_by_date():
    try:
        user_id = request.args.get("user_id")
        start_date = request.args.get("start")
        end_date = request.args.get("end")

        if not user_id or not start_date or not end_date:
            return jsonify({"error": "缺少使用者、開始日期或結束日期"}), 400

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute(
            """
            SELECT
                tr.record_id,
                tr.usage_date,
                v.vehicle_name,
                tr.distance_km,
                tr.carbon_emission
            FROM Traffic_Records tr
            JOIN Vehicles v ON tr.vehicle_id = v.vehicle_id
            WHERE tr.user_id = %s
              AND tr.usage_date BETWEEN %s AND %s
            ORDER BY tr.usage_date ASC
            """,
            (user_id, start_date, end_date)
        )
        records = cursor.fetchall()

        for row in records:
            row["usage_date"] = row["usage_date"].strftime("%Y-%m-%d")
            row["distance_km"] = float(row["distance_km"])
            row["carbon_emission"] = float(row["carbon_emission"])

        cursor.close()
        conn.close()

        return jsonify({
            "status": "success",
            "message": f"成功查詢到 {len(records)} 筆紀錄",
            "data": records
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# 於 routes/record_route.py 中新增
@record.route("/api/records/<int:record_id>", methods=["DELETE"])
def delete_record(record_id):
    if "user_id" not in session:
        return jsonify({"status": "error", "message": "尚未登入"}), 401
    
    conn = get_db_connection()
    cursor = conn.cursor()
    # 增加 user_id 檢查，確保使用者只能刪除自己的資料
    cursor.execute("DELETE FROM Traffic_Records WHERE record_id = %s AND user_id = %s", 
                   (record_id, session["user_id"]))
    conn.commit()
    
    deleted = cursor.rowcount > 0
    cursor.close()
    conn.close()
    
    if deleted:
        return jsonify({"status": "success", "message": "刪除成功"})
    else:
        return jsonify({"status": "error", "message": "找不到該紀錄或無權刪除"}), 404


