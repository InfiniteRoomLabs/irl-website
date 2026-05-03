FROM mcr.microsoft.com/devcontainers/typescript-node:1-22-bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        fish \
        just \
        jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN chsh -s /usr/bin/fish node

USER node

RUN mkdir -p /home/node/.config/fish
