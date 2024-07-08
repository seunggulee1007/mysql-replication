#!/bin/bash -e

# (1) 환경변수로 마스터와 슬레이브를 지정
if [ ! -z "$MYSQL_MASTER" ]; then
  echo "This container is master"
  exit 0
fi

echo "Prepare as slave"

# (2) 필수 환경변수 확인
if [ -z "$MYSQL_MASTER_HOST" ] || [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_REPL_USER" ] || [ -z "$MYSQL_REPL_PASSWORD" ]; then
  echo "Required environment variables are not set" 1>&2
  exit 1
fi

# (3) 슬레이브에서 마스터와 통신 가능 여부 확인
TIMEOUT=60
while [ $TIMEOUT -gt 0 ]; do
  if mysql -h $MYSQL_MASTER_HOST -u root -p$MYSQL_ROOT_PASSWORD -e "quit" > /dev/null 2>&1; then
    echo "MySQL master is ready!"
    break
  else
    echo "MySQL master is not ready"
  fi
  sleep 3
  TIMEOUT=$((TIMEOUT-3))
done

if [ $TIMEOUT -le 0 ]; then
  echo "MySQL master is not reachable, exiting"
  exit 1
fi

# (4) 마스터에 레플리케이션용 사용자 생성 및 권한 부여
IP=$(hostname -i)
IFS='.'
set -- $IP
SOURCE_IP="$1.$2.%.%"
mysql -h $MYSQL_MASTER_HOST -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE USER IF NOT EXISTS '$MYSQL_REPL_USER'@'$SOURCE_IP' IDENTIFIED BY '$MYSQL_REPL_PASSWORD';"
mysql -h $MYSQL_MASTER_HOST -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT REPLICATION SLAVE ON *.* TO '$MYSQL_REPL_USER'@'$SOURCE_IP';"

# (5) 마스터의 binlog 포지션 정보 확인
MASTER_STATUS_FILE=/tmp/master-status
mysql -h $MYSQL_MASTER_HOST -u root -p$MYSQL_ROOT_PASSWORD -e "SHOW MASTER STATUS\G" > $MASTER_STATUS_FILE
BINLOG_FILE=$(grep "File:" $MASTER_STATUS_FILE | awk '{print $2}')
BINLOG_POSITION=$(grep "Position:" $MASTER_STATUS_FILE | awk '{print $2}')

if [ -z "$BINLOG_FILE" ] || [ -z "$BINLOG_POSITION" ]; then
  echo "Failed to get binlog file or position from master" 1>&2
  exit 1
fi

echo "BINLOG_FILE=$BINLOG_FILE"
echo "BINLOG_POSITION=$BINLOG_POSITION"

# (6) 레플리케이션 시작
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "RESET SLAVE;"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CHANGE MASTER TO MASTER_HOST='$MYSQL_MASTER_HOST', MASTER_USER='$MYSQL_REPL_USER', MASTER_PASSWORD='$MYSQL_REPL_PASSWORD', MASTER_LOG_FILE='$BINLOG_FILE', MASTER_LOG_POS=$BINLOG_POSITION;"
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "START SLAVE;"

echo "Slave started"
