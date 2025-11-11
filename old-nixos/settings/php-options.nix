{ name }:
''
  error_log = /var/log/${name}/php-error.log
  error_reporting = -1
  log_errors = On
  log_errors_max_len = 0
  upload_max_filesize = 50M
  post_max_size = 50M
  memory_limit = 512M
  max_execution_time = 300
''
