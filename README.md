# PAKman

[![CI](https://github.com/upmaru/pakman/actions/workflows/ci.yml/badge.svg)](https://github.com/upmaru/pakman/actions/workflows/ci.yml)

This action allows you to build your software into an distributable self-contained package. It is designed to be used with [instellar.app](https://instellar.app)

![Packing Man](cover.png)

## Versions

You can choose from multiple version of alpine by choosing the tag

- `pakman@alpine-edge-7.2` - uses alpine:edge image
- `pakman@alpine-3.17-7.2` - uses alpine:3.17 image
- `pakman@alpine-3.16-7.2` - uses alpine:3.16 image
- `pakman@alpine-3.15-7.2` - uses alpine:3.15 image
- `pakman@alpine-3.14-7.2` - uses alpine:3.14 image

## Example Projects

We've created example projects that show you how to configure your project to work with this github action.

- [Elixir / Phoenix](https://github.com/upmaru-stage/rdio) - Includes CI configuration as well as deployment configuration
  - [.github/workflows/deployment.yml](https://github.com/upmaru-stage/rdio/blob/develop/.github/workflows/deployment.yml)
  - [instellar.yml](https://github.com/upmaru-stage/rdio/blob/develop/instellar.yml)

- [Ruby on Rails](https://github.com/upmaru-stage/locomo) - Includes only deployment configuration
  - [.github/workflows/deployment.yml](https://github.com/upmaru-stage/locomo/blob/main/.github/workflows/deployment.yml)
  - [instellar.yml](https://github.com/upmaru-stage/locomo/blob/main/instellar.yml)
  
- [Python Django](https://github.com/upmaru-stage/monty) - Includes only deployment configuration
  - [.github/workflows/deployment.yml](https://github.com/upmaru-stage/monty/blob/main/.github/workflows/deployment.yml)
  - [instellar.yml](https://github.com/upmaru-stage/monty/blob/main/instellar.yml)

- [Next.js](https://github.com/upmaru-stage/nimbus) - Includes only deployment configuration
  - [.github/workflows/deployment.yml](https://github.com/upmaru-stage/nimbus/blob/main/.github/workflows/deployment.yml)
  - [instellar.yml](https://github.com/upmaru-stage/nimbus/blob/main/instellar.yml)

