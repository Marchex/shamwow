export FILE='data/rhel1.txt'
echo "---$FILE---"
bin/console -P $password --user REDACTED --ssh --from $FILE --sshtasks Chef_version
exit
bin/console -P $password --user REDACTED --ssh --from $FILE --sshtasks Chef_version
bin/console -P $password --user REDACTED --ssh --from $FILE --sshtasks Chef_run
bin/console -P $password --user REDACTED --ssh --from $FILE --sshtasks Chef_upgrade
bin/console -P $password --user REDACTED --ssh --from $FILE --sshtasks Chef_stop
bin/console -P $password --user REDACTED --ssh --from $FILE --sshtasks Chef_run
bin/console -P $password --user REDACTED --ssh --from $FILE --sshtasks Chef_start
bin/console -P $password --user REDACTED --ssh --from $FILE --sshtasks Chef_version
