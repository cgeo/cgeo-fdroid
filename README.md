# Configuration

In order to configure the two channels ("mainline" / "nightly"), you have to
prepare two directories which should contains the file `config.py`. (Those
directories and files will be automatically created for you at first launch
of script `fdroid-update.sh`. However you have to set the password in the files
to unlock the signing key.)

This image is intended to be used as a Jenkins executor. You may want to bind
the `/apk/repo` directory to the host filesystem.

You need to have a directory containing:
* `slave` file: containing the name of the executor
* `secret` file: containing the executor secret
* `keystore.jks` file: which contains the repository signing key

Then you can launch the container:

```
APK_REPO=/path/to/repos
CONFS=/path/to/confs
docker run -v $APK_REPO:/apk/repo -v $CONFS/confs:/srv cgeo/fdroid
```

# Usage

Configure your Jenkins job to launch the script `fdroid-update.sh`.

`fdroid-update.sh` need one parameter representing the repo to update. It can be
`mainline` or `nightly`.

Ex:
```
fdroid-update.sh mainline
```
