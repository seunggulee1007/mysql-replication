FROM mysql:5.7

# (1) 패키지 업데이트 및 wget 설치
# RUN yum update -y
RUN yum install -y wget
RUN yum install -y hostname
RUN yum install -y vim

# (2) entrykit 설치
RUN wget https://github.com/progrium/entrykit/releases/download/v0.4.0/entrykit_0.4.0_linux_x86_64.tgz
RUN tar -xvzf entrykit_0.4.0_linux_x86_64.tgz
RUN rm entrykit_0.4.0_linux_x86_64.tgz
RUN mv entrykit /usr/local/bin/
RUN entrykit --symlink

# (3) 스크립트 및 각종 설정 파일 복사
COPY add-server-id.sh /usr/local/bin/
COPY etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/
COPY etc/mysql/conf.d/mysql.cnf /etc/mysql/conf.d/
COPY init.d/prepare.sh /docker-entrypoint-initdb.d
COPY init.d/01_create_users.sql /docker-entrypoint-initdb.d

# (4) 스크립트, mysqld 실행
ENTRYPOINT [ \
  "prehook", \
    "sh /usr/local/bin/add-server-id.sh", \
    "--", \
  "docker-entrypoint.sh" \
]

CMD ["mysqld"]
