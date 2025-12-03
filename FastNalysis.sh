#!/bin/bash

NO_FORMAT="\033[0m";
F_BOLD="\033[1m";
C_CYAN1="\033[38;5;51m";
C_GREEN1="\033[38;5;46m"
C_DARKVIOLET="\033[48;5;128m"
C_RED="\033[38;5;9m"

FILETYPE=""

banner() {
  clear;
  echo -e "${F_BOLD}${C_GREEN1}${C_DARKVIOLET}";
  echo "                                                                                                ";
  echo "  /\$\$\$\$\$\$\$\$                   /\$\$     /\$\$   /\$\$           /\$\$                     /\$\$           ";
  echo " | \$\$_____/                  | \$\$    | \$\$\$ | \$\$          | \$\$                    |__/           ";
  echo " | \$\$    /\$\$\$\$\$\$   /\$\$\$\$\$\$\$ /\$\$\$\$\$\$  | \$\$\$\$| \$\$  /\$\$\$\$\$\$ | \$\$ /\$\$   /\$\$  /\$\$\$\$\$\$\$ /\$\$  /\$\$\$\$\$\$\$ ";
  echo " | \$\$\$\$\$|____  \$\$ /\$\$_____/|_  \$\$_/  | \$\$ \$\$ \$\$ |____  \$\$| \$\$| \$\$  | \$\$ /\$\$_____/| \$\$ /\$\$_____/ ";
  echo " | \$\$__/ /\$\$\$\$\$\$\$|  \$\$\$\$\$\$   | \$\$    | \$\$  \$\$\$\$  /\$\$\$\$\$\$\$| \$\$| \$\$  | \$\$|  \$\$\$\$\$\$ | \$\$|  \$\$\$\$\$\$  ";
  echo " | \$\$   /\$\$__  \$\$ \\____  \$\$  | \$\$ /\$\$| \$\$\\  \$\$\$ /\$\$__  \$\$| \$\$| \$\$  | \$\$ \\____  \$\$| \$\$ \\____  \$\$ ";
  echo " | \$\$  |  \$\$\$\$\$\$\$ /\$\$\$\$\$\$\$/  |  \$\$\$\$/| \$\$ \\  \$\$|  \$\$\$\$\$\$\$| \$\$|  \$\$\$\$\$\$\$ /\$\$\$\$\$\$\$/| \$\$ /\$\$\$\$\$\$\$/ ";
  echo " |__/   \\_______/|_______/    \\___/  |__/  \\__/ \\_______/|__/ \\____  \$\$|_______/ |__/|_______/  ";
  echo "  @UmbraDeorum                                                /\$\$  | \$\$                         ";
  echo "                                                             || \$\$\$\$\$\$/                         ";
  echo "                                                              \\______/                          ";
  echo "                                                                                                ";
  echo -e "${NO_FORMAT}";
  echo ""
  echo ""

}

# Call the id_filetype function with the filename passed as an argument
if [ -z "$1" ]; then
    banner
    echo -e "${C_CYAN1}Usage:\n\n   $0 ${NO_FORMAT}<target_file> <args>"
    echo ""
    exit 1
fi

animate_text() {
  banner
  local text="$1"
  local delay="${2:-0.03}"

  for (( i=0; i<${#text}; i++ )); do
      echo -n "${text:$i:1}"
      sleep "$delay"
  done
  echo
}

id_filetype() {
  FILETYPE=$(file "$1")
  if [[ "$FILETYPE" == *"compressed"* ]]; then
    FILETYPE=$(file -z "$1")
  else
    FILETYPE=$(file "$1")
  fi

  echo "$FILETYPE"
}

get_elf_header() {
  readelf -h $1
}

get_security() {
  pwn checksec $1 # 2>&1 | awk '/^\[.\] .*\047.*\047$/{found=1} found{print}'
}

get_dependencies() {
  ldd -v $1
}

parse_symbols_demangle() {
  nm -D --demangle "$1" | \
  awk '{
    if ($1 ~ /^(T|t|I|i)$/ || $2 ~ /^(T|t|I|i)$/)
      print "\033[1;32m" $0 "\033[0m"
    else if ($1 ~ /^(B)$/ || $2 ~ /^(B)$/)
      print "\033[1;31m" $0 "\033[0m"
    else if ($1 ~ /^.*GLIBC.*$/ || $2 ~ /^.*GLIBC.*$/)
      print "\033[1;36m" $0 "\033[0m"
    else
      print $0
  }'
}

get_strings_from_data_sections() {
  strings -d -n 6 $1
}

initial_explore() {
  xxd $1 | head -n 20
}

system_calls() {
  strace "$@"
}

library_calls() {
  ltrace -i -C "$@"
}

_valgrind() {
  valgrind -s --leak-check=full --show-leak-kinds=all --track-origins=yes "$@"
}

_objdump_disas() {
  objdump -d "$1"
}

_objdump_section_headers() {
  objdump -h "$1"
}

_r2_decomp() {

  # First pass: get list of user-defined functions
  FUNCS=$(r2 -e bin.relocs.apply=true -q "$1" 2>/dev/null <<EOF
aaa
afl~!imp,!entry,!_init,!_fini,!_dl,!frame_dummy
q
EOF
  )

  # Extract function names (last column)
  FUNC_NAMES=$(echo "$FUNCS" | awk '{print $NF}' | grep -E '^(sym\.|main)' | grep -v '^\.')

  # Second pass: decompile each function
  r2 -e bin.relocs.apply=true -q "$1" 2>/dev/null <<EOF
aaa
$(for func in $FUNC_NAMES; do
    echo "echo \"=== $func ===\";"
    echo "s $func;"
    echo "pdg;"
    echo "echo;"
done)
q
EOF

}

# Function to highlight dangerous functions
highlight_dangerous() {
  sed -E "s/([^_a-zA-Z0-9]|^)(vsnprintf|sscanf|strncpy|vsprintf|sprintf|memcpy|__isoc99_scanf|strlen|strtok|alloca|strcpy|strcat|printf|scanf|srand|malloc|random|system|chmod|chown|popen|gets|rand|exec)(\()/\1\x1b[38;5;9m\2\x1b[0m\3/g; s/([^_a-zA-Z0-9]|^)(vsnprintf|sscanf|strncpy|vsprintf|sprintf|memcpy|__isoc99_scanf|strlen|strtok|alloca|strcpy|strcat|printf|scanf|srand|malloc|random|system|chmod|chown|popen|gets|rand|exec)(@GLIBC|@|$)/\1\x1b[38;5;9m\2\x1b[0m\3/g; s/(Stack:      Executable|NX:         NX unknown|RELRO:      No RELRO|RWX:        Has RWX segments|Stripped:   No|Stack:      No canary found|PIE:        No PIE|[uU]sername|[Pp]assword|[fF]lag|[hH]ash|Uninitialised value was created by a stack allocation|Bad permissions|Jump to the invalid address|Conditional jump or move depends on uninitialised value\(s\)|Invalid write of size|uninitialised value|Invalid free\(\)|Source and destination overlap|Invalid read of size|=> not found)/\x1b[38;5;9m\1\x1b[0m/g"
}

_main() {
  echo -e "\n${C_CYAN1}Filename: ${NO_FORMAT} $1"

  echo -e "\n${C_CYAN1}Filetype:${NO_FORMAT}\n"
  FILETYPE=$(id_filetype "$1" | awk -F ':' '{print $2}' | sed 's/^ //g')
  echo "$FILETYPE"
  echo ""

  if [[ "$FILETYPE" == "ELF"* ]]; then
    echo -e "\n${C_CYAN1}ELF Execution Header:${NO_FORMAT}\n"
  else
    echo -e "\n${C_RED}Not an ELF executable.${NO_FORMAT}"
    exit 1
  fi

  get_elf_header "$1"
  echo ""

  echo -e "\n${C_CYAN1}Security:${NO_FORMAT}\n"
  get_security "$1"
  echo ""

  echo -e "\n${C_CYAN1}Dependencies:${NO_FORMAT}\n"
  get_dependencies "$1"
  echo ""

  echo -e "\n${C_CYAN1}Symbols:${NO_FORMAT}\n"
  parse_symbols_demangle "$1"
  echo ""

  echo -e "\n${C_CYAN1}Data section strings (len>5):${NO_FORMAT}\n"
  get_strings_from_data_sections "$1"
  echo ""

  echo -e "\n${C_CYAN1}Preliminary explore (rows:20):${NO_FORMAT}\n"
  initial_explore "$1"
  echo ""

  echo -e "\n${C_CYAN1}System calls' tracing:${NO_FORMAT}\n"
  system_calls "$@"
  echo ""

  echo -e "\n${C_CYAN1}Libary calls' tracing:${NO_FORMAT}\n"
  library_calls "$@"
  echo ""

  echo -e "\n${C_CYAN1}Memory leaks' check:${NO_FORMAT}\n"
  _valgrind "$@"
  echo ""

  echo -e "\n${C_CYAN1}Section headers:${NO_FORMAT}\n"
  _objdump_section_headers "$1"
  echo ""

  echo -e "\n${C_CYAN1}Disassembly of executable sections:${NO_FORMAT}\n"
  _objdump_disas "$1"
  echo ""

  echo -e "\n${C_CYAN1}Decompilation of user-defined functions:${NO_FORMAT}\n"
  _r2_decomp "$1"
  echo ""
}

animate_text "Initiating analysis..."
sleep 1
_main "$@" 2>&1 | highlight_dangerous
