#! /bin/bash

slave=$(cat /srv/slave)
secret=$(cat /srv/secret)
if [ -z "$slave" -o -z "$secret" ]; then
  echo "You must place credentials for Jenkins in /srv/slave and /srv/secret" 2> /dev/null
  exit 1
fi

java -jar /apk/slave.jar -jnlpUrl http://ci.cgeo.org/computer/$slave/slave-agent.jnlp -secret $secret
