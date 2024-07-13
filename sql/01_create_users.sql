CREATE USER orc_client_user@'%' IDENTIFIED BY 'orc_client_password';
# SUPER, PROCESS, REPLICATION SLAVE, RELOAD 권한은 Orchestator가 MySQL 서버에 접속하여 복제 구성의 상태를 확인하거나 변경하는 데 필요
GRANT SUPER, PROCESS, REPLICATION SLAVE, RELOAD ON *.* TO orc_client_user@'%';
grant drop on _pseudo_gtid_.* to 'orc_client_user'@'%';
flush privileges;
# Orchestrator가 복제 상태를 확인하는 데 필요
GRANT SELECT ON mysql.slave_master_info TO orc_client_user@'%';
