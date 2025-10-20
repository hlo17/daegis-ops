_guardian() {
  local cur prev
  COMPREPLY=(); cur="${COMP_WORDS[COMP_CWORD]}"; prev="${COMP_WORDS[COMP_CWORD-1]}"
  local subs="status beacon park close closeout docs 6docs regen auto diff explain help -h --help menu"
  COMPREPLY=( $(compgen -W "${subs}" -- "$cur") )
}
complete -F _guardian guardian
