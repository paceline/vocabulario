# MySQL.  Versions 4.1 and 5.0 are recommended.
#
# Install the MySQL driver:
#   gem install mysql
# On Mac OS X:
#   sudo gem install mysql -- --with-mysql-dir=/usr/local/mysql
# On Mac OS X Leopard:
#   sudo env ARCHFLAGS="-arch i386" gem install mysql -- --with-mysql-config=/usr/local/mysql/bin/mysql_config
#       This sets the ARCHFLAGS environment variable to your native architecture
# On Windows:
#   gem install mysql
#       Choose the win32 build.
#       Install MySQL and put its /bin directory on your path.
#
# And be sure to use new-style password hashing:
#   http://dev.mysql.com/doc/refman/5.0/en/old-client.html
development:
  adapter: mysql
  encoding: utf8
  database: <%= application %>_development
  username: root
  password:
  host: localhost

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  adapter: mysql
  encoding: utf8
  database: <%= application %>_test
  username: root
  password:
  host: localhost

production:
  adapter: mysql
  encoding: utf8
  database: <%= application %>_production
  username: root
  password: 
  host: localhost

staging:
  adapter: mysql
  encoding: utf8
  database: <%= application %>_staging
  username: root
  password: 
  host: localhost
