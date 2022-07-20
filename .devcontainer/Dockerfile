# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.238.1/containers/debian/.devcontainer/base.Dockerfile

# [Choice] Debian version (use bullseye on local arm64/Apple Silicon): bullseye, buster
FROM ocaml/opam:debian-11-ocaml-4.14

# ** [Optional] Uncomment this section to install additional packages. **
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
SHELL ["/bin/bash", "-c"]
USER opam
RUN sudo apt install -y pkg-config libev-dev libssl-dev
RUN opam install -y dune ocaml-lsp-server ocamlformat
