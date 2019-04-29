# Configuration

In order to configure the two channels ("mainline" / "nightly"), you have to
prepare two directories which should contains the file `config.py`. (Those
directories and files will be automatically created for you at first launch
of script `fdroid-update.sh`. However you have to set the password in the files
to unlock the signing key.)

This image is intended to be used as a Jenkins executor. You may want to bind
the `/apk/repo` directory to the host filesystem.

You need to have a directory containing:
* `keystore.jks` file: which contains the repository signing key

Jenkins agent need some credentials to authenticate to the Jenkins server. Those
can be defined using environment variable or files.

Environment:
* JENKINS_NODE_NAME
* JENKINS_NODE_SECRET

Or using a file:
* JENKINS_NODE_NAME_FILE (Default: /srv/slave)
* JENKINS_NODE_SECRET_FILE (Default: /srv/secret)

Then you can launch the container:

```
APK_REPO=/path/to/repos
CONFS=/path/to/confs
JENKINS_NODE_NAME=node-name
JENKINS_NODE_SECRET=node-secret
docker run -e JENKINS_NODE_NAME=$JENKINS_NODE_NAME -e JENKINS_NODE_SECRET=$JENKINS_NODE_SECRET -v $APK_REPO:/apk/repo -v $CONFS/confs:/srv cgeo/fdroid
```

# Usage

Configure your Jenkins job to launch the script `fdroid-update.sh`.

`fdroid-update.sh` need one parameter representing the repo to update. It can be
`mainline` or `nightly`.

Ex:
```
fdroid-update.sh mainline
```
