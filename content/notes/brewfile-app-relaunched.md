+++
title = "Brewfile app relaunched"
date = 2022-12-15
[taxonomies]
tags=["Brewfile.app", "Ruby", "Homebrew"]
+++

I've relaunched this app![^1] The short version is that it's the [gitignore.io](https://gitignore.io) equivalent for Homebrew Brewfiles.

There's work to do, but, it's in a reliable and reproducible state.

Previously, it was on a VPS running FreeBSD and was using jails with Nginx and Puma. Now, it's still on a VPS, but it's running Debian and is using containers with Caddy and Puma.

I do not regret using FreeBSD and jails. I learnt from it and would consider using them again, project-dependent.

---

[^1]: [brewfile.app](https://brewfile.app)
