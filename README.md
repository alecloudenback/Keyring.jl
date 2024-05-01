# Keyring

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://alecloudenback.github.io/Keyring.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://alecloudenback.github.io/Keyring.jl/dev/)
[![Build Status](https://github.com/alecloudenback/Keyring.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/alecloudenback/Keyring.jl/actions/workflows/CI.yml?query=branch%3Amaster)

## Quickstart

```julia
using Keyring

set_credential("my_target", "my_username", "my_secret")

c = get_credential("my_target")

c.target # "my_target"
c.username # "my_username"
c.secret # "my_secret"
```

## Supported platforms:

- Windows

