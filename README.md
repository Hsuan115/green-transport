# 交通碳足跡系統 - 測試與安裝指南

## 1. 資料庫設定 (MySQL)
1. 啟動本機 MySQL 伺服器。
2. 匯入 `backend/database/final.sql` 以建立資料庫、資料表與預設測試資料。
3. 開啟 `backend/database/db.py`，找到資料庫連線設定，並在空白的 `password=""` 欄位中填入本機的 MySQL 密碼。

## 2. 後端設定 (Flask)
1. 開啟終端機並進入 `backend` 資料夾。
2. 安裝所需套件：
   ```bash
   pip install flask flask-cors pymysql
   ```
3. 啟動伺服器：
   ```bash
   python app.py
   ```
   *(註：Flask 後端必須運行於 `http://127.0.0.1:3000`，API 才能正確連線)。*

## 3. 前端設定 (VS Code Live Server)
1. 在 VS Code 中開啟 `frontend` 資料夾。
2. 於擴充套件市場安裝 **Live Server**。
3. 右鍵點擊 `index.html`，選擇 **Open with Live Server**。
4. 網站將會自動在瀏覽器中開啟（通常運行於 port `5500`）。
5. 可透過註冊新帳號或直接登入來測試系統功能。


# Carbon Footprint Tracker - Setup & Testing Guide

## 1. Database Setup (MySQL)
1. Start the local MySQL server.
2. Import `backend/database/final.sql` to generate the database, tables, and dummy data.
3. Open `backend/database/db.py`. Find the database connection code and enter the local MySQL password into the empty `password=""` field.

## 2. Backend Setup (Flask)
1. Open a terminal and navigate to the `backend` folder.
2. Install the required packages:
   ```bash
   pip install flask flask-cors pymysql
   ```
3. Start the server:
   ```bash
   python app.py
   ```
   *(Note: The Flask backend must run on `http://127.0.0.1:3000` for the API to connect properly).*

## 3. Frontend Setup (VS Code Live Server)
1. Open the `frontend` folder in VS Code.
2. Install the **Live Server** extension from the VS Code marketplace.
3. Right-click on `index.html` and select **Open with Live Server**.
4. The website will automatically open in the browser (typically on port `5500`).
5. Test the application by registering a new user or logging in.

---
