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

- Add a systemd user service, that should be running at least once during the day
- Enable the rebasing to locally hosted insecure images, necessary since I don't
  know how to sign the images at the moment
- Copies an `atom-atic.sh` shell script at your `~/.local/bin/atom-atic.sh`
    - The script ensures your host has a local registry container running, it's the one
      that stores the built image and subsequently serves it to `rpm-ostree rebase ...`
- Build your image
- Create local registry
- Push image to it
- Rebase to it
