CREATE DATABASE IF NOT EXISTS carbon_footprint; -- 建立一個名為 carbon_footprint 的資料庫
USE carbon_footprint;                           -- 告訴 MySQL 接下來的動作都要在這個資料庫執行

/* =========================================
   DROP TABLE
   ========================================= */
-- DROP TABLE IF EXISTS Traffic_Records;
-- DROP TABLE IF EXISTS Feedback_Forms;
-- DROP TABLE IF EXISTS Vehicles;
-- DROP TABLE IF EXISTS Users;

/* =========================================
   SELECT TABLE 
   查看資料
   ========================================= */
SELECT * FROM Users;
SELECT * FROM Vehicles;
SELECT * FROM Feedback_Forms;
SELECT * FROM Traffic_Records;

/* =========================================
   CREATE TABLE 
   建立各項欄位
   ========================================= */
-- 1. 建立「使用者」資料表 (Users)
-- 綱要: 使用者(-使用者ID, 使用者名稱, 使用者密碼)
CREATE TABLE Users (
    user_id INT NOT NULL,
    username VARCHAR(50) NOT NULL,
    user_password VARCHAR(255) NOT NULL
);

-- 2. 建立「交通工具」資料表 (Vehicles)
-- 綱要: 交通工具(-交通工具ID, 交通工具, 每公里的碳排放量(kg))
CREATE TABLE Vehicles (
    vehicle_id INT NOT NULL,
    vehicle_name VARCHAR(50) NOT NULL,
    emission_per_km DECIMAL(10, 4) NOT NULL
);

-- 3. 建立「回饋表單」資料表 (Feedback_Forms)
-- 綱要: 回饋表單(-表單ID, -使用者ID, 問題內容)
CREATE TABLE Feedback_Forms (
    form_id INT NOT NULL,
    user_id INT NOT NULL,
    question_content TEXT NOT NULL
);

-- 4. 建立「歷史交通紀錄」資料表 (Traffic_Records)
-- 綱要: 歷史交通紀錄(-紀錄ID, 使用者ID, 交通工具ID, 使用公里數, 使用日期, 碳排放量)
CREATE TABLE Traffic_Records (
    record_id INT NOT NULL,
    user_id INT NOT NULL,         
    vehicle_id INT NOT NULL,     
    distance_km DECIMAL(10, 2) NOT NULL,
    usage_date DATE NOT NULL,
    carbon_emission DECIMAL(10, 4) NOT NULL
);



-- Add PK to Users
ALTER TABLE Users 
ADD CONSTRAINT PK_Users 
PRIMARY KEY (user_id);

-- Add PK to Vehicles
ALTER TABLE Vehicles 
ADD CONSTRAINT PK_Vehicles 
PRIMARY KEY (vehicle_id);

-- Add PK to Feedback_Forms (Composite Key)
ALTER TABLE Feedback_Forms 
ADD CONSTRAINT PK_Feedback_Forms 
PRIMARY KEY (form_id);

-- Add PK to Traffic_Records
ALTER TABLE Traffic_Records 
ADD CONSTRAINT PK_Traffic_Records 
PRIMARY KEY (record_id);

ALTER TABLE Users MODIFY user_id INT AUTO_INCREMENT;
ALTER TABLE Vehicles MODIFY vehicle_id INT AUTO_INCREMENT;
ALTER TABLE Traffic_Records MODIFY record_id INT AUTO_INCREMENT;


-- Add FK to Feedback_Forms referencing Users
ALTER TABLE Feedback_Forms 
ADD CONSTRAINT FK_Feedback_Forms_Users 
FOREIGN KEY (user_id) REFERENCES Users(user_id) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Add FKs to Traffic_Records referencing Users and Vehicles
ALTER TABLE Traffic_Records 
ADD CONSTRAINT FK_Traffic_Records_Users 
FOREIGN KEY (user_id) REFERENCES Users(user_id) 
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Traffic_Records 
ADD CONSTRAINT FK_Traffic_Records_Vehicles 
FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id) 
ON DELETE CASCADE ON UPDATE CASCADE;



-- Ensure vehicle carbon emissions are not negative
ALTER TABLE Vehicles
ADD CONSTRAINT CK_Vehicles_emission
CHECK (emission_per_km >= 0);

-- Ensure travel distance is not negative
ALTER TABLE Traffic_Records
ADD CONSTRAINT CK_Traffic_Records_distance
CHECK (distance_km >= 0);

-- Ensure calculated carbon emission is not negative
ALTER TABLE Traffic_Records
ADD CONSTRAINT CK_Traffic_Records_emission
CHECK (carbon_emission >= 0);

-- 修改

-- alter table Feedback_Forms
-- drop primary key;

alter table Feedback_Forms
modify form_id int auto_increment;

-- alter table Feedback_Forms
-- add primary key (form_id);


/* =========================================
   模擬使用者資料 - Users
   ========================================= */
INSERT INTO Users (user_id, username, user_password) VALUES 
(1, 'UserA', '1A1A1A'),
(2, 'UserB', '2B2B2B'),
(3, 'UserC', '3C3C3C'),
(4, 'UserD', '4D4D4D'),
(5, 'UserE', '5E5E5E'),
(6, 'UserF', '6F6F6F'),
(7, 'UserG', '7G7G7G'),
(8, 'UserH', '8H8H8H'),
(9, 'UserI', '9I9I9I'),
(10, 'UserJ', '10J10J10J');

/* =========================================
   碳排放係數資料 - Vehicles
   ========================================= */
INSERT INTO Vehicles (vehicle_id, vehicle_name, emission_per_km) VALUES 
(DEFAULT,'步行', 0.0000),
(DEFAULT,'自行車', 0.0000),
(DEFAULT,'電動機車', 0.0170),
(DEFAULT,'高鐵', 0.0280),
(DEFAULT,'捷運', 0.0300),
(DEFAULT,'電動公車', 0.0340),
(DEFAULT,'火車', 0.0400),
(DEFAULT,'電動小客車', 0.0400),
(DEFAULT,'燃油客運', 0.0770),
(DEFAULT,'燃油公車', 0.0780),
(DEFAULT,'燃油機車', 0.0790),
(DEFAULT,'燃油小客車', 0.1040);

/* =========================================
   模擬回饋表單資料 - Feedback_Forms
   ========================================= */
INSERT INTO Feedback_Forms (user_id, question_content) VALUES 
(2, '請問未來會增加「電動自行車」的碳排放選項嗎？'),
(5, '系統介面很清楚，但我找不到修改個人密碼的地方。'),
(7, '希望能新增將歷史交通紀錄匯出成 Excel 檔案的功能，方便做報告。'),
(8, '為什麼高鐵的碳排量比火車還要低？這個數據有包含發電的碳排嗎？'),
(8, '許願可以開發一個「月度碳排放趨勢圖表」，這樣比較好追蹤自己的減碳進度！');

INSERT INTO Feedback_Forms (user_id, question_content) VALUES 
(2, 't請問未來會增加「電動自行車」的碳排放選項嗎？'),
(5, 't系統介面很清楚，但我找不到修改個人密碼的地方。'),
(7, 't希望能新增將歷史交通紀錄匯出成 Excel 檔案的功能，方便做報告。'),
(8, 't為什麼高鐵的碳排量比火車還要低？這個數據有包含發電的碳排嗎？'),
(8, 't許願可以開發一個「月度碳排放趨勢圖表」，這樣比較好追蹤自己的減碳進度！');


/* =========================================
   模擬使用資料 - Traffic_Records
   ========================================= */
INSERT INTO Traffic_Records (user_id, vehicle_id, distance_km, usage_date, carbon_emission) VALUES 
-- ==========================================
-- User 1: 捷運(5)、步行(1)、高鐵(4) 
-- ==========================================
(1, 5, 8.5, '2026-01-15', 0.2550),
(1, 1, 1.2, '2026-01-15', 0.0000),
(1, 5, 8.5, '2026-01-16', 0.2550),  
(1, 4, 150.0, '2026-02-20', 4.2000),
(1, 1, 0.8, '2026-02-20', 0.0000),
(1, 5, 12.0, '2026-03-10', 0.3600);

-- ==========================================
-- User 2: 燃油機車(11)、燃油小客車(12)、步行(1) 
-- ==========================================
INSERT INTO Traffic_Records (user_id, vehicle_id, distance_km, usage_date, carbon_emission) VALUES 
(2, 11, 5.5, '2026-01-05', 0.4345),
(2, 11, 5.5, '2026-01-06', 0.4345),
(2, 12, 45.0, '2026-02-14', 4.6800),
(2, 1, 0.5, '2026-02-14', 0.0000),
(2, 12, 45.0, '2026-04-04', 4.6800),
(2, 11, 12.0, '2026-05-18', 0.9480);

-- ==========================================
-- User 3: 電動機車(3)、捷運(5)、自行車(2) 
-- ==========================================
INSERT INTO Traffic_Records (user_id, vehicle_id, distance_km, usage_date, carbon_emission) VALUES 
(3, 3, 8.0, '2026-03-01', 0.1360),
(3, 5, 15.5, '2026-03-02', 0.4650),
(3, 2, 3.0, '2026-03-02', 0.0000),
(3, 3, 8.0, '2026-04-15', 0.1360),
(3, 2, 2.5, '2026-06-10', 0.0000);

-- ==========================================
-- User 4: 燃油公車(10)、火車(7)、步行(1) 
-- ==========================================
INSERT INTO Traffic_Records (user_id, vehicle_id, distance_km, usage_date, carbon_emission) VALUES 
(4, 10, 6.5, '2026-01-22', 0.5070),
(4, 7, 65.0, '2026-01-23', 2.6000),
(4, 1, 1.5, '2026-01-23', 0.0000),
(4, 10, 6.5, '2026-04-08', 0.5070),
(4, 7, 65.0, '2026-05-20', 2.6000);

-- ==========================================
-- User 5: 電動小客車(8)、高鐵(4)、捷運(5) 
-- ==========================================
INSERT INTO Traffic_Records (user_id, vehicle_id, distance_km, usage_date, carbon_emission) VALUES 
(5, 8, 25.0, '2026-02-10', 1.0000),
(5, 5, 10.0, '2026-02-11', 0.3000),
(5, 4, 280.0, '2026-03-15', 7.8400),
(5, 8, 15.0, '2026-05-01', 0.6000),
(5, 5, 10.0, '2026-06-25', 0.3000),
(5, 12, 15.5, '2026-01-08', 1.6120),
(5, 5, 12.0, '2026-01-20', 0.3600),
(5, 8, 30.0, '2026-01-28', 1.2000),
(5, 4, 340.0, '2026-02-18', 9.5200),
(5, 5, 8.5, '2026-02-19', 0.2550),
(5, 3, 5.0, '2026-03-05', 0.0850),
(5, 8, 22.0, '2026-03-22', 0.8800),
(5, 5, 14.0, '2026-04-10', 0.4200),
(5, 4, 160.0, '2026-04-15', 4.4800),
(5, 7, 45.0, '2026-04-16', 1.8000),
(5, 8, 18.0, '2026-05-12', 0.7200),
(5, 5, 10.5, '2026-05-20', 0.3150),
(5, 4, 280.0, '2026-06-05', 7.8400),
(5, 8, 40.0, '2026-06-12', 1.6000),
(5, 12, 10.0, '2026-06-28', 1.0400);

-- ==========================================
-- User 6: 自行車(2)、捷運(5)、燃油客運(9) 
-- ==========================================
INSERT INTO Traffic_Records (user_id, vehicle_id, distance_km, usage_date, carbon_emission) VALUES 
(6, 2, 4.0, '2026-03-12', 0.0000),
(6, 5, 18.0, '2026-03-12', 0.5400),
(6, 9, 120.0, '2026-04-03', 9.2400),
(6, 5, 18.0, '2026-04-06', 0.5400),
(6, 2, 4.0, '2026-06-28', 0.0000);

-- ==========================================
-- User 7: 燃油機車(11)、火車(7)、步行(1) 
-- ==========================================
INSERT INTO Traffic_Records (user_id, vehicle_id, distance_km, usage_date, carbon_emission) VALUES 
(7, 11, 7.5, '2026-01-18', 0.5925),
(7, 7, 40.0, '2026-02-28', 1.6000),
(7, 1, 1.0, '2026-02-28', 0.0000),
(7, 11, 7.5, '2026-04-12', 0.5925),
(7, 7, 40.0, '2026-05-05', 1.6000);

-- ==========================================
-- User 8: 電動公車(6)、捷運(5)、自行車(2) 
-- ==========================================
INSERT INTO Traffic_Records (user_id, vehicle_id, distance_km, usage_date, carbon_emission) VALUES 
(8, 6, 5.0, '2026-02-05', 0.1700),
(8, 5, 14.0, '2026-02-05', 0.4200),
(8, 2, 2.0, '2026-03-08', 0.0000),
(8, 6, 5.0, '2026-05-15', 0.1700),
(8, 5, 14.0, '2026-06-18', 0.4200);

-- ==========================================
-- User 9: 燃油小客車(12)、燃油公車(10)、步行(1) 
-- ==========================================
INSERT INTO Traffic_Records (user_id, vehicle_id, distance_km, usage_date, carbon_emission) VALUES 
(9, 12, 30.0, '2026-01-30', 3.1200),
(9, 10, 8.0, '2026-02-02', 0.6240),
(9, 1, 0.6, '2026-02-02', 0.0000),
(9, 12, 30.0, '2026-04-20', 3.1200),
(9, 10, 8.0, '2026-06-05', 0.6240);

-- ==========================================
-- User 10: 電動機車(3)、高鐵(4)、捷運(5) 
-- ==========================================
INSERT INTO Traffic_Records (user_id, vehicle_id, distance_km, usage_date, carbon_emission) VALUES 
(10, 3, 10.0, '2026-01-10', 0.1700),
(10, 5, 22.0, '2026-01-12', 0.6600),
(10, 4, 180.0, '2026-03-25', 5.0400),
(10, 3, 10.0, '2026-05-10', 0.1700),
(10, 5, 22.0, '2026-06-22', 0.6600),
(10, 5, 15.0, '2026-02-05', 0.4500),
(10, 3, 12.5, '2026-02-18', 0.2125),
(10, 6, 8.0, '2026-03-01', 0.2720),
(10, 4, 150.0, '2026-03-12', 4.2000),
(10, 8, 35.0, '2026-04-10', 1.4000),
(10, 5, 20.0, '2026-04-25', 0.6000),
(10, 3, 9.0, '2026-05-05', 0.1530),
(10, 12, 18.0, '2026-05-20', 1.8720),
(10, 4, 300.0, '2026-06-01', 8.4000),
(10, 5, 15.0, '2026-06-15', 0.4500); 


