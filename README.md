# PAKman

[![CI](https://github.com/upmaru/pakman/actions/workflows/ci.yml/badge.svg)](https://github.com/upmaru/pakman/actions/workflows/ci.yml)

This action allows you to build your software into an distributable self-contained package. It is designed to be used with [instellar.app](https://instellar.app)

![Packing Man](cover.png)

## Basic Usage

This is an example configuration. However you should be using the application configuration wizard on the OspMaru app.

```yml
name: 'Deployment'

on:
  push:
    branches:
      - main
      - master
      - develop

jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - name: 'Checkout'
        uses: actions/checkout@v4
        with:
          ref: ${{ github.ref }}
          fetch-depth: 0

      - name: Setup Pakman
        uses: upmaru/pakman@v8
        with:
          alpine: v3.18

      - name: Bootstrap Configuration
        run: |
          pakman bootstrap
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

      - name: Upload Artifact
        uses: actions/upload-artifact@v4
        with:
          name: ${{ runner.arch }}
          path: /home/runner/packages

  deploy:
    name: Deploy
    needs: build
    runs-on: ubuntu-latest
    steps: 
      - name: Checkout
        uses: actions/checkout@v4

      - uses: actions/download-artifact@v4
        with: 
          path: /home/runner/artifacts

      - name: Setup Pakman
        uses: upmaru/pakman@v8
        with:
          alpine: v3.18

      - name: Merge Artifact
        run: |
          cp -R /home/runner/artifacts/X64/. /home/runner/packages/
          sudo zip -r /home/runner/packages.zip "$HOME"/packages
        shell: alpine.sh {0}

      - name: Push
        run: pakman push
        shell: alpine.sh {0}
        env:
          WORKFLOW_REF: ${{ github.ref }}
          WORKFLOW_SHA: ${{ github.sha }}
          INSTELLAR_ENDPOINT: https://opsmaru.com
          INSTELLAR_PACKAGE_TOKEN: ${{secrets.INSTELLAR_PACKAGE_TOKEN}}
          INSTELLAR_AUTH_TOKEN: ${{secrets.INSTELLAR_AUTH_TOKEN}}
```
