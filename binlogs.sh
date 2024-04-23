#!/bin/bash

#Setting Help text block
if [[ $1 == "-h" || $1 == "--help"|| $# -eq 0 ]]; then
  echo "Usage: $(basename $0) [DATABASE NAME]"
  echo "Options:"
  echo "  DATABASE NAME			Replace with the database name you want to replay bin logs for
  echo "  -h, --help			Display this help message"
  exit 0
else
fi

# Setting Bin log variables based on database name
$DATABASE=$1
$BINLOGSTARTPOS='grep "MASTER_LOG_POS=" $DATABASE | awk -F\= {'print $3'} | rev |cut -c1|rev'
$BINLOGPREFIX='grep "MASTER_LOG_FILE=" $DATABASE | awk -F'= {'print $2'}|awk -F \. {'print $1'}'
$BINLOGSTARTFILE='grep "MASTER_LOG_FILE=" $DATABASE | awk -F'= {'print $2'}|awk -F \. {'print $2'}'
$BINLOGSECONDFILE=(($BINLOGSTARTFILE+1))
$BINLOGENDFILE='ls -t $BINLOGPREFIX* |tail -n1 | awk -F'= {'print $2'}|awk -F \. {'print $2'}'

#Displaying output message
echo "Replaying bin logs and removing use statements"

# Replaying initial binlog
mysqlbinlog --database=$DATABASE --start-position=$BINLOGSTARTPOS --stop-datetime='`date +%d/%b/%Y +%T`' "$BINLOGPREFIX"."$BINLOGSTARTFILE" >> "$DATABASE"-BINLOGS.sql
sed -i '/^[uU][sS][eE] /d' "$DATABASE"-BINLOGS.sql

# Looping for through remaining bin logs.
for BINLOG in {"$BINLOGSECONDFILE".."$BINLOGENDFILE"}; 
	do mysqlbinlog --database=$DATABASE --stop-datetime="`date +%d/%b/%Y +%T`" $BINLOG >> "$DATABASE"-BINLOGS."$BINLOG".sql; 
	sed -i '/^[uU][sS][eE] /d' "$DATABASE"-BINLOGS."$BINLOG".sql;
done

#Displaying update message
echo "Merging bin logs"
for REPLAYEDLOG in {"$BINLOGSECONDFILE".."$BINLOGENDFILE"};
	do cat "$DATABASE"-BINLOGS."$REPLAYEDLOG".sql >> ""$DATABASE"-BINLOGS.sql";
done

# Print output
echo "Bin log replaying complete"

# Print instructions

echo "To import your database, please first import the full database backup called "$DATABASE".sql."
echo "Once the full database has been imported, please then import your binary logs called "$DATABASE"-BINLOGS.sql."
echo "Once imported you will have a fully copy of your base to the requested point in time."
