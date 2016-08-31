export FILE='data/day.16.ubuntu.out'
echo "---$FILE---"
bin/console --user jcarter --ssh --from $FILE --sshtasks Chef_version
bin/console --user jcarter --ssh --from $FILE --sshtasks Chef_whyrun
bin/console --user jcarter --ssh --from $FILE --sshtasks Chef_upgrade
bin/console --user jcarter --ssh --from $FILE --sshtasks Chef_stop
bin/console --user jcarter --ssh --from $FILE --sshtasks Chef_whyrun
bin/console --user jcarter --ssh --from $FILE --sshtasks Chef_start
bin/console --user jcarter --ssh --from $FILE --sshtasks Chef_verify_running_version
bin/console --user jcarter --ssh --from $FILE --sshtasks Chef_version
