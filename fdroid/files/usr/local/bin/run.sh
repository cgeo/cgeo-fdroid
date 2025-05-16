#! /bin/bash

if [ -z "$JENKINS_NODE_NAME" ]; then
  JENKINS_NODE_NAME_FILE=${JENKINS_NODE_NAME_FILE:-/srv/slave}
  JENKINS_NODE_NAME=$(cat $JENKINS_NODE_NAME_FILE)
fi
if [ -z "$JENKINS_NODE_SECRET" ]; then
  JENKINS_NODE_SECRET_FILE=${JENKINS_NODE_SECRET_FILE:-/srv/secret}
  JENKINS_NODE_SECRET=$(cat $JENKINS_NODE_SECRET_FILE)
fi

if [ -z "$JENKINS_NODE_NAME" -o -z "$JENKINS_NODE_SECRET" ]; then
  echo "No credentials detected. Please check README for the ways to provide them." 2> /dev/null
  exit 1
fi

# https://stackoverflow.com/a/67606115/944936
java \
  --add-opens java.base/java.util=ALL-UNNAMED \
  --add-opens java.base/java.lang.reflect=ALL-UNNAMED \
  --add-opens java.base/java.text=ALL-UNNAMED \
  --add-opens java.desktop/java.awt.font=ALL-UNNAMED \
  -jar /apk/slave.jar \
  -jnlpUrl https://ci.cgeo.org/computer/$JENKINS_NODE_NAME/slave-agent.jnlp \
  -secret $JENKINS_NODE_SECRET
