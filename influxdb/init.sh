#!/bin/sh

influx -execute="CREATE DATABASE ndr_management"
influx -execute="CREATE CONTINUOUS QUERY "cq_threat_10m" ON ndr_management BEGIN SELECT count(event_type) as count_event_type,count(level) as count_level INTO "e_threat_10m" FROM threat_event_2 GROUP BY time(10m),* END" -database=ndr_management
influx -execute="CREATE CONTINUOUS QUERY "cq_threat_1h" ON ndr_management BEGIN SELECT count(event_type) as count_event_type,count(level) as count_level INTO "e_threat_1h" FROM threat_event_2 GROUP BY time(1h),* END" -database=ndr_management
influx -execute="CREATE CONTINUOUS QUERY "cq_threat_2h" ON ndr_management BEGIN SELECT count(event_type) as count_event_type,count(level) as count_level INTO "e_threat_2h" FROM threat_event_2 GROUP BY time(2h),* END" -database=ndr_management
influx -execute="CREATE CONTINUOUS QUERY "cq_threat_12h" ON ndr_management BEGIN SELECT count(event_type) as count_event_type,count(level) as count_level INTO "e_threat_12h" FROM threat_event_2 GROUP BY time(12h),* END" -database=ndr_management
influx -execute="CREATE CONTINUOUS QUERY "cq_threat_2d" ON ndr_management BEGIN SELECT count(event_type) as count_event_type,count(level) as count_level INTO "e_threat_2d" FROM threat_event_2 GROUP BY time(2d),* END" -database=ndr_management
