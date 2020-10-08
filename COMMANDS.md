# Command Reference

Like `git`, the `hashi-env` command delegates to subcommands based on its first argument.

The most common subcommands are:

* [`hashi-env commands`](#hashi-env-commands)
* [`hashi-env list`](#hashi-env-list)
* [`hashi-env list-remote`](#hashi-env-list-remote)
* [`hashi-env local`](#hashi-env-local)
* [`hashi-env global`](#hashi-env-global)
* [`hashi-env install`](#hashi-env-install)
* [`hashi-env remove`](#hashi-env-remove)
* [`hashi-env rehash`](#hashi-env-rehash)

## `hashi-env commands`

Lists all available hashi-env commands.

## `hashi-env list`

Lists all tool versions known to hashi-env.

    $ hashi-env list
    ============================
    >>>  TERRAFORM
    v0.13.4

    ============================
    >>>  VAULT
    v1.5.4

    ============================
    >>>  CONSUL
    v1.8.4

    $ hashi-env list consul
    v1.8.4

## `hashi-env list-remote`

Lists all versions of a given tool available to hashi-env for install.

    $ hashi-env list-remote terraform
    0.1.0
    0.1.1
    ... [truncated]
    0.12.28
    0.12.29
    0.13.0
    0.13.1
    0.13.2
    0.13.3
    0.13.4

    $ hashi-env list-remote --alpha terraform
    0.1.0
    0.1.1
    0.2.0
    ... [truncated]
    0.12.28
    0.12.29
    0.13.0-rc1
    0.13.0-beta3
    0.13.0-beta2
    0.13.0-beta1
    0.13.0
    0.13.1
    0.13.2
    0.13.3
    0.13.4
    0.14.0-alpha20201007
    0.14.0-alpha20200923
    0.14.0-alpha20200910

## `hashi-env local`

Displays the currently active version of a tool, along with information on how it was set

    $ hashi-env local
    packer: v1.6.5 (by PACKER_VERSION)
    vault: v1.5.4 (by ~/src/my-project/.vault-version)
    terraform: v0.13.0 (by ~/.hashi-env/versions)
    $ hashi-env local --bare terraform
    v0.13.0

Sets a local application-specific version of the specified tool by writing the version name to a `.<tool>-version` file (e.g., `.terraform-version`) in the current directory. This version overrides the global version, and can be overridden itself by setting the `<TOOL>_VERSION` (e.g., `NOMAD_VERSION`) environment variable.

    $ hashi-env local consul 1.8.0

When run without a version number, `hashi-env local` reports the currently configured local version of the specified tool.

## `hashi-env global`

Sets the global version of the specified tool to be used in all shells by writing the version name to the `~/.hashi-env/version` file. This version can be overridden by an application-specific `.<tool>-version` file, or by setting the `<TOOL>_VERSION` environment variable.

    $ hashi-env global terraform 0.13.4

The special version name `system` tells hashi-env to use the system-provided version of the tool (detected by searching your `$PATH`).

When run without a version number, `hashi-env global` reports the currently configured global version for that tool.

## `hashi-env install`

Install a tool version.

    Usage: hashi-env install <product> [<version>]

To list the all available versions of a tool, see [`hashi-env list-remote`](#hashi-env-list-remote). Then install the desired versions:

    $ hashi-env install terraform 0.13.4
    $ hashi-env install consul 1.8
    $ hashi-env install vault
    $ hashi-env list
    ============================
    >>>  TERRAFORM
    v0.13.4

    ============================
    >>>  VAULT
    v1.5.4

    ============================
    >>>  CONSUL
    v1.8.4

## `hashi-env remove`

Uninstall a specific version of a tool.

    Usage: hashi-env remove <product> <version>

## `hashi-env rehash`

Installs shims for all binaries known to hashi-env (i.e., `~/.hashi-env/versions/<tool>-*/<tool>`). Run this command after you install a new version of a tool.

    $ hashi-env rehash
