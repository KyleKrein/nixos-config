# helps to find files that will be deleted after the reboot when using impermanence
{
  writeShellScriptBin,
  fd,
  lib,
}:
writeShellScriptBin "root-files" ''
  ${lib.getExe fd} --one-file-system --base-directory / --type f --hidden --exclude "{tmp,etc/passwd}"
''
# https://www.reddit.com/r/NixOS/comments/1d1apm0/comment/l5tgbwz/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

