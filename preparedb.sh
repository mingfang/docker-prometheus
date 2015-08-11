mysql_install_db
mysqld_safe & mysqladmin --wait=5 ping 
#mysql -v < mysql.ddl
cd /promdash
./bin/env bin/bundle exec rake db:create
./bin/env bin/bundle exec rake db:migrate
mysqladmin shutdown
