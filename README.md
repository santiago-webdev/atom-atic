# Atom-atic

This is a project very similar to [zerolayer](https://github.com/akdev1l/zerolayer),
with the difference been that I use a local registry to serve the image instead of
an oci archived image, but the concept is more or less the same.

First, create a configuration file, namely this is going to be a `Containerfile`:

```bash
mkdir -p "$XDG_CONFIG_HOME/atom-atic"
touch "$XDG_CONFIG_HOME/atom-atic/Containerfile"
```

Run the install.sh, which does the following:

- Enable the rebasing to locally hosted insecure images, necessary since I don't
know how to sign the images at the moment
- Copy the `atom-atic.sh` shell script to `~/.local/bin/atom-atic.sh`
- Add a systemd user service that runs this script the every two days
- Run the script `atom-atic.sh` manually once
    - Ensure your host has a local registry running, it'll be the one that stores
    the built image and subsequently serves it to `rpm-ostree rebase ...`
        - For this point I might include a "atom-atic" registry shipped as a quadlet
        in the future, because if you try to upgrade and the registry is not
        running it will fail instead of printing `No upgrade available.`
    - Build your image reading the config usually stored at `~/.config/atom-atic/Containerfile`
    - Push it to the registry
- Rebase to the newly built image

And that's about it, you should check if the service `rpm-ostreed-automatic` is
enabled, since this would be the service that actually updates the computer

```bash
systemctl enable rpm-ostreed-automatic.timer
```
