# Vigil Local

## About Vigil

[Vigil](https://github.com/valeriansaliou/vigil) is an open-source Status Page you can host on your infrastructure, used to monitor all your servers and apps, and visible to your users (on a domain of your choice, eg. status.example.com).

[Vigil Local](https://github.com/valeriansaliou/vigil-local) is an (optional) slave daemon that you can use to report internal service health to your Vigil-powered status page master server. It is designed to be used behind a firewall, and to monitor hosts bound to a local loop or LAN network, that are not available to your main Vigil status page. It can prove useful as well if you want to fully isolate your Vigil status page from your internal services.

## About This Code

This is a simple container image for `vigil-local`, with a shell to support probe scripts. It supports only `x86_64` for now.

Valerian Saliou, the author of Vigil, makes a container image available on Docker Hub as [valeriansaliou/vigil-local](https://hub.docker.com/r/valeriansaliou/vigil-local/). His image is most likely more up to date than this one, but it is built `FROM scratch`, which means probe scripts don't work.

## Run

An image build from this code is available on Docker Hub as [cliffordw/vigil-local](https://hub.docker.com/r/cliffordw/vigil-local).

You can run it with:

```sh
podman run -d --rm --name vigil-local -v $PWD/vigil-local.cfg:/etc/vigil-local.cfg:ro,Z docker.io/cliffordw/vigil-local:v1.2.0-1
```
