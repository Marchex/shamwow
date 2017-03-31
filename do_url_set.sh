export FILE='data/syd1.txt'
echo "---$FILE---"
#bin/console -P $password --user jcarter --ssh --from $FILE --sshtasks Chef_server_url
#bin/console -P $password --user jcarter --ssh --from $FILE --sshtasks Chef_run
bin/console -P $password --user jcarter --ssh --from $FILE --sshtasks Chef_set_url_onpremises
bin/console -P $password --user jcarter --ssh --from $FILE --sshtasks Chef_stop
bin/console -P $password --user jcarter --ssh --from $FILE --sshtasks Chef_run
#bin/console -P $password --user jcarter --ssh --from $FILE --sshtasks Chef_start
bin/console -P $password --user jcarter --ssh --from $FILE --sshtasks Chef_server_url
