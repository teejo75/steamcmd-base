# SteamCMD Base Docker Image
This image (and README) is based on work by [CM2Walki](https://github.com/CM2Walki/steamcmd) and is updated and customized for use with my own images. I would have used CM2Walki's image directly, but I wanted one based on Trixie, and at the time of creating this, he has not yet made one.

This image should be mostly compatible with his, although I have customised some of the included packages.

This README is also based on his README, although I have removed portions that are not relevant to this image.

# What is SteamCMD?
SteamCMD is a command-line version of the Steam client. Its primary use is to install and update various dedicated servers available on Steam using a command-line interface. It works with games that use the SteamPipe content system. This image can be used as a base image for Steam-based dedicated servers (Source: [developer.valvesoftware.com](https://developer.valvesoftware.com/wiki/SteamCMD)).

# How to use this image
While it's recommended to use this image as a base image for other game servers, you can also run it in an interactive shell using the following command:
```console
$ docker run -it --name=steamcmd teejo75/steamcmd-base bash
$ gosu steam:steam ./steamcmd.sh +force_install_dir /home/steam/squad-dedicated +login anonymous +app_update 403240 +quit
```
This can prove useful if you are just looking to test a certain game server installation.

Running with named volumes:
```console
$ docker volume create steamcmd_login_volume # Optional: Location of login session
$ docker volume create steamcmd_volume # Optional: Location of SteamCMD installation

$ docker run -it \
    -v "steamcmd_login_volume:/home/steam/Steam" \
    -v "steamcmd_volume:/home/steam/steamcmd" \
    teejo75/steamcmd-base bash
```
This setup is necessary if you have to download a non-anonymous appID or upload a steampipe build. For an example check out:
https://hub.docker.com/r/cm2network/steampipe/

## Configuration
The `steamcmd.sh` can be found in the following directory: `/home/steam/steamcmd`

This image's default user is `root`, but SteamCMD is installed as the `steam` user. You should execute SteamCMD and your game service as the `steam` user. The gosu package is installed by default.
_Note: Running the `steamcmd.sh` as `root` will fail because the owner is the user `steam`, either swap the active user using `su steam` or use chown to change the ownership of the directory._

## Image Info

This image is also available via ghcr.io/teejo75/steamcmd-base

The image will automatically update on the 1st day of the month to account for security updates.

If you have an image that uses this image as a base, and you would like your build workflow to trigger whenever this image updates, then open an issue with the name of your repo.

See [Action Repository Dispatch](https://github.com/peter-evans/repository-dispatch).

In your build workflow, add an event as follows:
```yaml
on:
    repository_dispatch:
        types: [steamcmd-base-updated]
```

And so you know what triggered the workflow, you can add the following job before your main build job:

```yaml
jobs:
  echo-base-update:
    if: github.event_name == 'repository_dispatch'
    runs-on: ubuntu-latest
    steps:
      - name: Echo base image update
        run: echo "Base image steamcmd-base has been updated, triggering rebuild of this image. ImageID ${{ github.event.client_payload.imageid }} Digest ${{ github.event.client_payload.digest }}"

```