# HashiCorp Version Management

hashi-env lets you easily switch between multiple versions of the HashiCorp suite of tools. It's simple, unobtrusive, and follows the UNIX tradition of single-purpose tools that do one thing well.

This project was forked from pyenv and direnv, and modified for use with golang binaries.

Works with:

- [Terraform](https://www.terraform.io/)
- [Packer](https://www.packer.io/)
- [Consul](https://www.consul.io/)
- [Nomad](https://www.nomadproject.io/)
- [Vault](https://www.vaultproject.io/)
- [envconsul](https://github.com/hashicorp/envconsul)
- [consul-template](https://github.com/hashicorp/consul-template)

### hashi-env does...

- Let you change the global version of the above HashiCorp tools, on a per-user basis.
- Provide support for per-project versions of the above HashiCorp tools.
- Allow you to override the tool version with an environment variable (e.g., `TERRAFORM_VERSION`).
- Install and uninstall multiple versions of the above HashiCorp tools at the same time.
- Support Bash, KSH, ZSH, Fish, and may work with any other shell supporting Bash-like syntax.
- Not need to be loaded into your shell. Instead, hashi-env's shim approach works by adding a directory to your $PATH.

### Requirements:

- GNU coreutils
- curl
- bash

---

## Table of Contents

- [**How it works**](#how-it-works)
  - [Understanding PATH](#understanding-path)
  - [Understanding Shims](#understanding-shims)
  - [Choosing a Version](#choosing-a-version)
  - [Locating the Installation](#locating-the-installation)
- [**Installation**](#installation)
  - [Basic GitHub Checkout](#basic-github-checkout)
    - [Upgrading](#upgrading)
    - [Uninstalling](#uninstalling)
    - [Advanced Configuration](#advanced-configuration)
    - [Uninstalling Tool Versions](#uninstalling-tool-versions)
- [**Command Reference**](#command-reference)
- [**Development**](#development)
  - [Version History](#version-history)
  - [License](#license)

---

## How it works

At a high level, hashi-env intercepts commands using shim executables injected into your `PATH`, determines which version of the HashiCorp product has been specified by your application, and passes your commands along to the correct installation.

### Understanding PATH

When you run a command like `terraform` or `consul`, your operating system searches through a list of directories to find an executable file with that name. This list of directories lives in an environment variable called `PATH`, with each directory in the list separated by a colon:

```
/usr/local/bin:/usr/bin:/bin
```

Directories in `PATH` are searched from left to right, so a matching executable in a directory at the beginning of the list takes precedence over another one at the end. In this example, the `/usr/local/bin` directory will be searched first, then `/usr/bin`, then `/bin`.

### Understanding Shims

hashi-env works by inserting a directory of _shims_ at the front of your `PATH`:

```
$(hashi-env root)/shims:/usr/local/bin:/usr/bin:/bin
```

Through a process called _rehashing_, hashi-env maintains shims in that directory to match every installed HashiCorp tool.

Shims are lightweight executables that simply pass your command along to hashi-env. So with hashi-env installed, when you run, say, `terraform`, your operating system will do the following:

- Search your `PATH` for an executable file named `terraform`
- Find the hashi-env shim for `terraform` at the beginning of your `PATH`
- Run the shim named `terraform`, which in turn passes the command along to hashi-env

### Choosing a Version

When you execute a shim, hashi-env determines which tool version to use by reading it from the following sources, in this order:

1. The TERRAFORM_VERSION environment variable (if specified)
2. The application-specific `.terraform-version` file in the current directory (if present). You can modify the current directory's `.terraform-version` file with the `hashi-env local` command.
3. The first `.terraform-version` file found (if any) by searching each parent directory, until reaching the root of your filesystem.
4. The global `$(hashi-env root)/version` file. You can modify this file using the `hashi-env global` command. If the global version file is not present, hashi-env assumes you want to use the "system" version of the tool. (In other words, whatever version would run if hashi-env weren't in your `PATH`.)

### Locating the Installation

Once hashi-env has determined which version of the tool your application has specified, it passes the command along to the corresponding tool itself.

Each Terraform version is installed into its own directory under `$(hashi-env root)/versions`.

For example, you might have these versions installed:

- `$(hashi-env root)/versions/terraform-0.9.5/`
- `$(hashi-env root)/versions/terraform-0.11.14/`
- `$(hashi-env root)/versions/terraform-0.12.23/`
- `$(hashi-env root)/versions/terraform-0.12.24/`
- `$(hashi-env root)/versions/terraform-0.13.4/`

As far as hashi-env is concerned, version names are simply the directories in `$(hashi-env root)/versions`.

---

## Installation

### Basic GitHub Checkout

This will get you going with the latest version of hashi-env and make it easy to fork and contribute any changes back upstream.

1. **Check out hashi-env where you want it installed.** A good place to choose is `$HOME/.hashi-env` (but you can install it somewhere else).

      git clone https://github.com/thelonelyghost/hashi-env.git ~/.hashi-env

2. **Add `~/.hashi-env/bin` to your `$PATH`** for access to the `hashi-env` command-line utility.

   - For **bash**:
     ~~~ bash
     echo 'export PATH="$HOME/.hashi-env/bin:$PATH"' >> ~/.bash_profile
     ~~~

   - For **Ubuntu Desktop**:
     ~~~ bash
     echo 'export PATH="$HOME/.hashi-env/bin:$PATH"' >> ~/.bashrc
     ~~~

   - For **zsh**:
     ~~~ zsh
     echo 'export PATH="$HOME/.hashi-env/bin:$PATH"' >> ~/.zshrc
     ~~~

   - For **Fish shell**:
     ~~~ fish
     set -Ux fish_user_paths $HOME/.hashi-env/bin $fish_user_paths
     ~~~

3. **Add `eval "$(hashi-env init -)"` to your shell** to enable autocompletion and shims. Please make sure `eval "$(hashi-env init -)"` is placed toward the end of the shell configuration file since it manipulates `PATH` during the initialization.
   ```sh
   echo -e 'if command -v hashi-env 1>/dev/null 2>&1; then\n  eval "$(hashi-env init -)"\nfi' >> ~/.bash_profile
   ```
   - **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.
   - **fish note**: Use `hashi-env init - | source` instead of `eval (hashi-env init -)`.
   - **Ubuntu and Fedora note**: Modify your `~/.bashrc` file instead of `~/.bash_profile`.

   **General warning**: There are some systems where the `BASH_ENV` variable is configured to point to `.bashrc`. On such systems you should almost certainly put the above mentioned line `eval "$(hashi-env init -)"` into `.bash_profile`, and **not** into `.bashrc`. Otherwise you may observe strange behaviour, such as `hashi-env` getting into an infinite loop. See [pyenv/pyenv#264](https://github.com/pyenv/pyenv/issues/264) for details.

4. **Restart your shell so the path changes take effect.** You can now begin using hashi-env.
   ```sh
   exec "$SHELL"
   ```

5. **Install HashiCorp product versions into `$(hashi-env root)/versions`.** For example, to download and install Consul 1.8.0, run:
    ```sh
    hashi-env install consul 1.8.0
    ```

#### Upgrading

If you've installed hashi-env using the instructions above, you can upgrade your installation at any time using git.

To upgrade to the latest development version of hashi-env, use `git pull`:

```sh
cd $(hashi-env root)
git pull
```

To upgrade to a specific release of hashi-env, check out the corresponding tag:

```sh
cd $(hashi-env root)
git fetch
git tag
git checkout v0.1.0
```

#### Uninstalling

The simplicity of hashi-env makes it easy to temporarily disable it, or uninstall from the system.

1. To **disable** hashi-env managing your HashiCorp product versions, simply remove the `hashi-env init` line from your shell startup configuration. This will remove hashi-env shims directory from PATH, and future invocations like `nomad` will execute the system Nomad version, as before hashi-env.

  `hashi-env` will still be accessible on the command line, but your Python apps won't be affected by version switching.

2. To completely **uninstall** hashi-env, perform step (1) and then remove its root directory. This will **delete all Terraform, Consul, Vault, Nomad, Packer, envconsul, and consul-template versions** that were installed under `` $(hashi-env root)/versions/ `` directory:
    ```sh
    rm -rf $(hashi-env root)
    ```

#### Advanced Configuration

Skip this section unless you must know what every line in your shell profile is doing.

`hashi-env init` is the only command that crosses the line of loading extra commands into your shell. Coming from rvm, some of you might be opposed to this idea. Here's what `hashi-env init` actually does:

1. **Sets up your shims path.** This is the only requirement for hashi-env to function properly. You can do this by hand by prepending `$(hashi-env root)/shims` to your `$PATH`.

2. **Installs autocompletion.** This is entirely optional but pretty useful. Sourcing `$(hashi-env root)/completions/hashi-env.bash` will set that up. There is also a `$(hashi-env root)/completions/hashi-env.zsh` for Zsh users.

3. **Rehashes shims.** From time to time you'll need to rebuild your shim files. Doing this on init makes sure everything is up to date. You can always run `hashi-env rehash` manually.

4. **Installs the sh dispatcher.** This bit is also optional, but allows hashi-env and plugins to change variables in your current shell, making commands like `hashi-env shell` possible. The sh dispatcher doesn't do anything crazy like override `cd` or hack your shell prompt, but if for some reason you need `hashi-env` to be a real script rather than a shell function, you can safely skip it.

To see exactly what happens under the hood for yourself, run `hashi-env init -`.

### Uninstalling Tool Versions

As time goes on, you will accumulate tool versions in your `$(hashi-env root)/versions` directory.

To remove old versions, `hashi-env remove` command to automate the removal process.

Alternatively, simply `rm -rf` the directory of the version you want to remove.

---

## Command Reference

See [COMMANDS.md](COMMANDS.md).

---

## Environment variables

You can affect how hashi-env operates with the following settings:

name | default | description
-----|---------|------------
`TERRAFORM_VERSION` | | Specifies the terraform version to be used.
`CONSUL_VERSION` | | Specifies the consul version to be used.
`NOMAD_VERSION` | | Specifies the nomad version to be used.
`VAULT_VERSION` | | Specifies the vault version to be used.
`PACKER_VERSION` | | Specifies the packer version to be used.
`ENVCONSUL_VERSION` | | Specifies the envconsul version to be used.
`CONSUL_TEMPLATE_VERSION` | | Specifies the consul-template version to be used.
`HASHIENV_DEBUG` | | Outputs debug information.<br>Also as: `hashi-env --debug <subcommand>`

---

## Development

The hashi-env source code is [hosted on GitHub](https://github.com/thelonelyghost/hashi-env). It's clean, modular, and easy to understand, even if you're not a shell hacker.

Tests, once written, will be executed using [Bats](https://github.com/bats-core/bats-core):

    bats test
    bats/test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue tracker](https://github.com/thelonelyghost/hashi-env/issues).

### Version History

See [CHANGELOG.md](CHANGELOG.md).

### License

[The MIT License](LICENSE)
