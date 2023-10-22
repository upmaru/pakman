# PAKman

[![CI](https://github.com/upmaru/pakman/actions/workflows/ci.yml/badge.svg)](https://github.com/upmaru/pakman/actions/workflows/ci.yml)

This action allows you to build your software into an distributable self-contained package. It is designed to be used with [instellar.app](https://instellar.app)

![Packing Man](cover.png)

## Basic Usage

This is an example configuration. However you should be using the application configuration wizard on [opsmaru.com](https://opsmaru.com)

```yml
name: 'Deployment'

on:
  push:
    branches:
      - main
      - master
      - develop

jobs:
  build_and_deploy:
    name: Build and Deploy
    runs-on: ubuntu-latest
    steps:
      - name: 'Checkout'
        uses: actions/checkout@v3
        with:
          ref: ${{ github.event.workflow_run.head_branch }}
          fetch-depth: 0

      - name: 'Setup PAKman'
        uses: upmaru/pakman@v8
        with:
          # specify which version of alpine to use
          # choose from edge | v3.18 | v3.17 | v3.16 | v3.15
          alpine: v3.18

      - name: Bootstrap Configuration
        run: ~/.mix/escripts/pakman --command bootstrap
        shell: alpine.sh {0}
        env:
          ABUILD_PRIVATE_KEY: ${{secrets.ABUILD_PRIVATE_KEY}}
          ABUILD_PUBLIC_KEY: ${{secrets.ABUILD_PUBLIC_KEY}}

      - name: 'Build Package'
        run: |
          cd "$GITHUB_WORKSPACE"/.apk/"$GITHUB_REPOSITORY" || exit

          abuild snapshot
          abuild -r
        shell: alpine.sh {0}

      - name: 'Archive Package'
        run: sudo zip -r packages.zip "$HOME"/packages
        shell: alpine.sh {0}

      - name: 'Create Deployment'
        run: ~/.mix/escripts/pakman --command create_deployment --archive packages.zip
        shell: alpine.sh {0}
        env:
          WORKFLOW_REF: ${{ github.ref }}
          WORKFLOW_SHA: ${{ github.sha }}
          INSTELLAR_ENDPOINT: https://opsmaru.com
          INSTELLAR_PACKAGE_TOKEN: ${{secrets.INSTELLAR_PACKAGE_TOKEN}}
          INSTELLAR_AUTH_TOKEN: ${{secrets.INSTELLAR_AUTH_TOKEN}}
```
