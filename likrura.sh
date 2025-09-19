#!/usr/bin/env bash

set -eo pipefail
[[ $TRACE ]] && set -x

readonly VERSION="2.0.0"
readonly OPENSSL_CIPHER_TYPE="aes-256-cbc"

show_version() {
  echo "likrura $VERSION"
}

show_help() {
  cat <<EOF
Usage: $0 <command> <file>

Commands:
  encrypt <file>      Encrypt a file
  decrypt <file.aes>  Decrypt a previously encrypted file
  help                Show this help message
  version             Show version info

You will be prompted for a password each time.
EOF
}

encrypt_file() {
  local input_file="$1"
  if [[ -z "$input_file" ]]; then
    echo "No file specified to encrypt." >&2
    exit 2
  fi
  if [[ ! -f "$input_file" ]]; then
    echo "File not found: $input_file" >&2
    exit 4
  fi
  local output_file="${input_file}.aes"

  # Prompt for password securely
  read -s -p "Enter encryption password: " password
  echo
  read -s -p "Confirm encryption password: " password2
  echo
  if [[ "$password" != "$password2" ]]; then
    echo "Passwords do not match." >&2
    exit 1
  fi

  printf "%s" "$password" | openssl "$OPENSSL_CIPHER_TYPE" -salt -pbkdf2 -in "$input_file" -out "$output_file" -pass stdin
  echo "Encrypted to: $output_file"
}

decrypt_file() {
  local encrypted_file="$1"
  if [[ -z "$encrypted_file" ]]; then
    echo "No file specified to decrypt." >&2
    exit 2
  fi
  if [[ ! -f "$encrypted_file" ]]; then
    echo "File not found: $encrypted_file" >&2
    exit 5
  fi
  local output_file="${encrypted_file%.aes}"

  read -s -p "Enter decryption password: " password
  echo

  printf "%s" "$password" | openssl "$OPENSSL_CIPHER_TYPE" -d -salt -pbkdf2 -in "$encrypted_file" -out "$output_file" -pass stdin
  echo "Decrypted to: $output_file"
}

main() {
  local command="$1"
  shift || true

  case "$command" in
    encrypt)
      encrypt_file "$@"
      ;;
    decrypt)
      decrypt_file "$@"
      ;;
    version)
      show_version
      ;;
    help|"")
      show_help
      ;;
    *)
      echo "Unknown command: $command" >&2
      show_help >&2
      exit 3
      ;;
  esac
}

if [[ "$0" == "$BASH_SOURCE" ]]; then
  main "$@"
fi
