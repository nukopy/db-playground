SHOW STATUS like 'Uptime';

SHOW STATUS like 'Threads_connected';

SELECT
	*
FROM
	performance_schema.global_variables
WHERE
	variable_name = 'admin_port';

SELECT
	variable_name,
	variable_value
FROM
	performance_schema.global_variables
WHERE
	variable_name = 'pid_file';

SHOW DATABASES;
