#!/bin/bash

# 创建myseq数据库和数据表
USER="user"
PASS="user"
mysql -u $USER -p $PASS <<EOF 2 > dev/null
CREATE DATABASE student;
EOF

[ $? -eq 0 ] && echo Created DB || echo DB already exist
mysql -u $USER -p$PASS students << EOF 2> /dev/null
CREATE TABLE students(
id int,
make 
	)