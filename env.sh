#!/usr/bin/env bash

# --- vendored from https://github.com/bashup/realpaths
__rp_dirname() { REPLY=.; ! [[ $1 =~ /+[^/]+/*$ ]] || REPLY="${1%${BASH_REMATCH[0]}}"; REPLY=${REPLY:-/}; }
__rp_absolute() {
	REPLY=$PWD; local eg=extglob; ! shopt -q $eg || eg=; ${eg:+shopt -s $eg}
	while (($#)); do case $1 in
		//|//[^/]*) REPLY=//; set -- "${1:2}" "${@:2}" ;;
		/*) REPLY=/; set -- "${1##+(/)}" "${@:2}" ;;
		*/*) set -- "${1%%/*}" "${1##${1%%/*}+(/)}" "${@:2}" ;;
		''|.) shift ;;
		..) __rp_dirname "$REPLY"; shift ;;
		*) REPLY="${REPLY%/}/$1"; shift ;;
	esac; done; ${eg:+shopt -u $eg}
}
# ---

# DISCLAIMER: this was adapted from https://github.com/direnv/direnv/blob/3c5d9470b89b7933587bcf68d8a556a9a9a518e8/stdlib.sh

# Usage: expand_path <rel_path> [<relative_to>]
#
# Outputs the absolute path of <rel_path> relative to <relative_to> or the
# current directory.
#
# Example:
#
#    cd /usr/local/games
#    expand_path ../foo
#    # output: /usr/local/foo
#
expand_path() {
  local REPLY; __rp_absolute ${2+"$2"} ${1+"$1"}; echo "$REPLY"
}

: ${HASHIENV_LOG_FORMAT:=hashi-env: %s}
: ${HASHIENV_ROOT:=$(expand_path ${BASH_SOURCE[0]%/*})}
color_normal=$(tput sgr0)
color_error=$(tput setaf 1)
products=('packer' 'terraform' 'vault' 'consul' 'nomad' 'boundary' 'waypoint' 'envconsul' 'consul-template' 'levant')
export HASHIENV_ROOT

: ${DEFAULT_VERSIONS_DIR:=${HASHIENV_ROOT}/versions}

: ${TERRAFORM_VERSIONS:=$DEFAULT_VERSIONS_DIR}
: ${PACKER_VERSIONS:=$DEFAULT_VERSIONS_DIR}
: ${CONSUL_VERSIONS:=$DEFAULT_VERSIONS_DIR}
: ${NOMAD_VERSIONS:=$DEFAULT_VERSIONS_DIR}
: ${VAULT_VERSIONS:=$DEFAULT_VERSIONS_DIR}
: ${CONSUL_TEMPLATE_VERSIONS:=$DEFAULT_VERSIONS_DIR}
: ${ENVCONSUL_VERSIONS:=$DEFAULT_VERSIONS_DIR}
: ${LEVANT_VERSIONS:=$DEFAULT_VERSIONS_DIR}
export TERRAFORM_VERSIONS PACKER_VERSIONS CONSUL_VERSIONS NOMAD_VERSIONS VAULT_VERSIONS CONSUL_TEMPLATE_VERSIONS ENVCONSUL_VERSIONS LEVANT_VERSIONS

PATH="$(expand_path "$HASHIENV_ROOT/scripts"):${PATH}"
