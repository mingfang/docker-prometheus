CREATE DATABASE prometheus;
CREATE USER 'prometheus' IDENTIFIED BY 'prometheus';
GRANT ALL ON prometheus.* TO 'prometheus'@'%' IDENTIFIED BY 'prometheus';
GRANT ALL ON prometheus.* TO 'prometheus'@'localhost' IDENTIFIED BY 'prometheus';
FLUSH PRIVILEGES;
