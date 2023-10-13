#!/bin/sh
set -e

#Check if every required variable is set
for variable in "DB_TYPE" "DB_PORT" "DB_HOST" "DB_NAME" "GIT_URL" "GIT_EMAIL" "GIT_NAME"; do
	eval value="\$$variable"
	if [ -z "$value" ]
	then
		echo "$variable env var is not set"
		exit 1
	fi
done

git config --global user.email "$GIT_URL"
git config --global user.name "$GIT_NAME"

mkdir -p backup
cd backup

echo "initialising Git"
GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git clone -q --depth 1 $GIT_URL .

case $DB_TYPE in
	mysql)
	echo "dumping MariaDB/MySQL DB"
	mysqldump -h $DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASS $DB_NAME > backup.sql
	;;
	postgres)
	echo "dumping Postgress DB"
	PGPASSWORD=$DB_PASS pg_dumpall -h $DB_HOST -p $DB_PORT -U $DB_USER > backup.sql
	;;
esac

echo "commiting file to Git"
git add backup.sql
git commit -m "$(date)"

echo "sending files to upstream"
GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git diff-index --quiet HEAD || git push --set-upstream origin main

echo "backup done on $(date)"