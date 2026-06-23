from datetime import date

from flask import Blueprint, request, jsonify

from database.db import get_db_connection

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


# 用交通工具名稱查詢交通紀錄
@record.route("/api/records/vehicle", methods=["GET"])
def get_records_by_vehicle():
    try:
        user_id = request.args.get("user_id")
        vehicle_name = request.args.get("vehicle_name")

        if not user_id or not vehicle_name:
            return jsonify({"error": "缺少使用者或交通工具名稱"}), 400

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # 使用 LIKE 進行模糊搜尋，讓使用者只輸入部分字詞（例如"車"）也能查到
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
              AND v.vehicle_name LIKE %s
            ORDER BY tr.usage_date ASC
            """,
            (user_id, f"%{vehicle_name}%")
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
    
    
# 刪除單筆交通紀錄
@record.route("/api/records/<int:record_id>", methods=["DELETE"])
def delete_record(record_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # 執行 SQL 刪除指令
        cursor.execute(
            """
            DELETE FROM Traffic_Records
            WHERE record_id = %s
            """,
            (record_id,)
        )
        
        conn.commit()
        
        # 取得被刪除的資料筆數
        deleted_count = cursor.rowcount

        cursor.close()
        conn.close()

        # 如果筆數為 0，代表沒找到該紀錄
        if deleted_count == 0:
            return jsonify({
                "status": "error",
                "message": "找不到該筆紀錄"
            }), 404

        return jsonify({
            "status": "success",
            "message": "刪除成功"
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
