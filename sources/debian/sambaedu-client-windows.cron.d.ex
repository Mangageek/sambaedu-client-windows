#
# Regular cron jobs for the sambaedu-client-windows package
#
0 4	* * *	root	[ -x /usr/bin/sambaedu-client-windows_maintenance ] && /usr/bin/sambaedu-client-windows_maintenance
