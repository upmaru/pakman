# PAKman

[![CI](https://github.com/upmaru/pakman/actions/workflows/ci.yml/badge.svg)](https://github.com/upmaru/pakman/actions/workflows/ci.yml)

This action allows you to build your software into an distributable self-contained package. This github action should be able to build any language / framework into a distributable alpine package.

![Packing Man](cover.png)

## Example Projects

We've created example projects that show you how to configure your project to work with this github action.

- [Elixir / Phoenix](https://github.com/upmaru-stage/rdio) - Includes CI configuration as well as deployment configuration
  - [.github/workflows/deployment.yml](https://github.com/upmaru-stage/rdio/blob/main/.github/workflows/deployment.yml)
  - [instellar.yml](https://github.com/upmaru-stage/rdio/blob/main/instellar.yml)

- [Ruby on Rails](https://github.com/upmaru-stage/locomo) - Includes only deployment configuration
  - [.github/workflows/deployment.yml](https://github.com/upmaru-stage/locomo/blob/main/.github/workflows/deployment.yml)
  - [instellar.yml](https://github.com/upmaru-stage/locomo/blob/main/instellar.yml)
  
- [Python Django](https://github.com/upmaru-stage/monty) - Includes only deployment configuration
  - [.github/workflows/deployment.yml](https://github.com/upmaru-stage/monty/blob/main/.github/workflows/deployment.yml)
  - [instellar.yml](https://github.com/upmaru-stage/monty/blob/main/instellar.yml)


