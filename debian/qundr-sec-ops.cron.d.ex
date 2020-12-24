#
# Regular cron jobs for the qundr-sec-ops package
#
0 4	* * *	root	[ -x /usr/bin/qundr-sec-ops_maintenance ] && /usr/bin/qundr-sec-ops_maintenance
