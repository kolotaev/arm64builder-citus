# Build the Citus extension for Postgres on the ARM-64 Platform

_For now there is no officially provided Citus extensions for ARM-64 architectures. That's why this repo exists._

This repo allows you to build installable Citus extension for arm64 Debian Linux.

The resulting deb package can potentially be installed on Ubuntu Linux as well.

It allows you to:
- build any version of Citus
- for any version of Postgres
- for any Debian distributive

Please, consult Citus <-> Postgres compatibility [matrix](https://www.citusdata.com/faq).

By inheritance, this fork allows you to build a predefined Citus 10.2.5 for Postgres 14 for ARM-64 Ubuntu. But this feature is not maintained and works as long as the original repository code works.

## Requirements

+ git
+ buildah
+ podman

## Example

For any Debian build:

```bash
git clone this repo
debian/build-citus.sh -p 16 -c 12.1.0 -d 11
# Where:
# p - is a Postgres major version
# c - is a Citus full version (refer to Citus VCS tags)
# d - is a Debian major version
```
