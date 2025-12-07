# Vigil Local

A Vigil Local container image with probe script support.

## About Vigil

[Vigil](https://github.com/valeriansaliou/vigil) is an open-source Status Page you can host on your infrastructure, used to monitor all your servers and apps, and visible to your users (on a domain of your choice, eg. status.example.com).

[Vigil Local](https://github.com/valeriansaliou/vigil-local) is an (optional) slave daemon that you can use to report internal service health to your Vigil-powered status page master server. It is designed to be used behind a firewall, and to monitor hosts bound to a local loop or LAN network, that are not available to your main Vigil status page. It can prove useful as well if you want to fully isolate your Vigil status page from your internal services.

## About This Code

Valerian Saliou, the author of Vigil, makes a container image available on Docker Hub as [valeriansaliou/vigil-local](https://hub.docker.com/r/valeriansaliou/vigil-local/). It is built `FROM scratch`, which means probe scripts don't work.

This code builds a container image for `vigil-local` **with a BusyBox shell to support probe scripts**. It supports only `x86_64` for now.

## Run

To use this image, you need to create a configuration file first. See the "Configuration" section of Valerian's [repo](https://github.com/valeriansaliou/vigil-local), or the [`vigil-local.cfg.example`](vigil-local.cfg.example) sample file in this repo.

An image build from this code is available in the [GitHub container registry](https://github.com/clifford2/vigil-local-container/pkgs/container/vigil-local).

You can run it with:

```sh
podman run -d --rm \
  --name vigil-local \
  -v ./vigil-local.cfg:/etc/vigil-local.cfg:ro,Z \
  ghcr.io/clifford2/vigil-local:v1.2.6-1.20251207
```
