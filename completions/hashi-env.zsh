if [[ ! -o interactive ]]; then
    return
fi

compctl -K _hashi-env hashi-env

_hashi-env() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(hashi-env commands)"
  else
    completions="$(hashi-env completions ${words[2,-2]})"
  fi

  reply=(${(ps:\n:)completions})
}
