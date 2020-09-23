--##############################################################################
--#  Create table
--##############################################################################

CREATE TABLE nifi_sensors
(
 sensor_id INT,
 sensor_ts TIMESTAMP, 
 sensor_0 DOUBLE,
 sensor_1 DOUBLE,
 sensor_2 DOUBLE,
 sensor_3 DOUBLE,
 sensor_4 DOUBLE,
 sensor_5 DOUBLE,
 sensor_6 DOUBLE,
 sensor_7 DOUBLE,
 sensor_8 DOUBLE,
 sensor_9 DOUBLE,
 sensor_10 DOUBLE,
 sensor_11 DOUBLE,
 is_healthy INT,
 PRIMARY KEY (sensor_ID, sensor_ts)
)
PARTITION BY HASH PARTITIONS 16
STORED AS KUDU
TBLPROPERTIES ('kudu.num_tablet_replicas' = '1');

--##############################################################################
--#  Create table
--##############################################################################

CREATE TABLE sensors
(
 sensor_id INT,
 sensor_ts TIMESTAMP, 
 sensor_0 DOUBLE,
 sensor_1 DOUBLE,
 sensor_2 DOUBLE,
 sensor_3 DOUBLE,
 sensor_4 DOUBLE,
 sensor_5 DOUBLE,
 sensor_6 DOUBLE,
 sensor_7 DOUBLE,
 sensor_8 DOUBLE,
 sensor_9 DOUBLE,
 sensor_10 DOUBLE,
 sensor_11 DOUBLE,
 is_healthy INT,
 PRIMARY KEY (sensor_ID, sensor_ts)
)
PARTITION BY HASH PARTITIONS 16
STORED AS KUDU
TBLPROPERTIES ('kudu.num_tablet_replicas' = '1');

--##############################################################################
--#  Create view
--##############################################################################

create view nifi_sensor_descriptive AS

(SELECT
  x.sensor_id
  ,x.sensor_ts
  ,x.sensor_0
  ,x.sensor_1
  ,x.sensor_2
  ,x.sensor_3
  ,x.sensor_4
  ,x.sensor_5
  ,x.sensor_6
  ,x.sensor_7
  ,x.sensor_8
  ,x.sensor_9
  ,x.sensor_10
  ,x.sensor_11
  ,x.is_healthy
  , decode(x.is_healthy, 1, "Good", 0, "Bad") as sensor_state
FROM default.sensors x);

--##############################################################################
--#  Create view
--##############################################################################

create view sensor_descriptive AS

(SELECT
  x.sensor_id
  ,x.sensor_ts
  ,x.sensor_0
  ,x.sensor_1
  ,x.sensor_2
  ,x.sensor_3
  ,x.sensor_4
  ,x.sensor_5
  ,x.sensor_6
  ,x.sensor_7
  ,x.sensor_8
  ,x.sensor_9
  ,x.sensor_10
  ,x.sensor_11
  ,x.is_healthy
  , decode(x.is_healthy, 1, "Good", 0, "Bad") as sensor_state
FROM default.sensors x);
