function __fish_hashi-env_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'hashi-env' ]
    return 0
  end
  return 1
end

function __fish_hashi-env_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c hashi-env -n '__fish_hashi-env_needs_command' -a '(hashi-env commands)'
for cmd in (hashi-env commands)
  complete -f -c hashi-env -n "__fish_hashi-env_using_command $cmd" -a \
    "(hashi-env completions (commandline -opc)[2..-1])"
end

