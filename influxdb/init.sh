#!/bin/sh

influx -execute="CREATE DATABASE ndr_management"
influx -execute="CREATE CONTINUOUS QUERY "cq_security_ops_10m" ON ndr_management BEGIN SELECT count(event_type) as count_event_type,count(level) as count_level, count(action) as count_action INTO "e_security_ops_10m" FROM threat_secops_event GROUP BY time(10m),* END" -database=ndr_management
influx -execute="CREATE CONTINUOUS QUERY "cq_security_ops_1h" ON ndr_management BEGIN SELECT count(event_type) as count_event_type,count(level) as count_level, count(action) as count_action INTO "e_security_ops_1h" FROM threat_secops_event GROUP BY time(1h),* END" -database=ndr_management
influx -execute="CREATE CONTINUOUS QUERY "cq_security_ops_2h" ON ndr_management BEGIN SELECT count(event_type) as count_event_type,count(level) as count_level, count(action) as count_action INTO "e_security_ops_2h" FROM threat_secops_event GROUP BY time(2h),* END" -database=ndr_management
influx -execute="CREATE CONTINUOUS QUERY "cq_security_ops_12h" ON ndr_management BEGIN SELECT count(event_type) as count_event_type,count(level) as count_level, count(action) as count_action INTO "e_security_ops_12h" FROM threat_secops_event GROUP BY time(12h),* END" -database=ndr_management
influx -execute="CREATE CONTINUOUS QUERY "cq_security_ops_2d" ON ndr_management BEGIN SELECT count(event_type) as count_event_type,count(level) as count_level, count(action) as count_action INTO "e_security_ops_2d" FROM threat_secops_event GROUP BY time(2d),* END" -database=ndr_management
