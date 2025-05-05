#!/usr/bin/env bash

SCRIPT_NAME="junkinator"
INSTALL_PATH="/usr/local/bin/$SCRIPT_NAME"

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [install] [--ignore "pattern1,pattern2,..."] [project_path]

Commands:
  install                 Install the script to $INSTALL_PATH

Options:
  -i, --ignore PATTERNS   Comma-separated list of file or directory patterns to ignore (e.g., "node_modules,*.log")
  -h, --help              Show this help message

Arguments:
  project_path            Optional path to the project directory (defaults to current directory)
EOF
  exit 1
}

# Default ignore list (empty)
IGNORE_PATTERNS=""
PROJECT_PATH="."

# Parse flags and arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    install)
      echo "Installing $SCRIPT_NAME to $INSTALL_PATH..."
      sudo cp "$0" "$INSTALL_PATH"
      sudo chmod +x "$INSTALL_PATH"
      echo "Installation successful. Now you can run '$SCRIPT_NAME' from anywhere."
      exit 0
      ;;
    -i|--ignore)
      shift
      [[ -z "$1" ]] && echo "Error: --ignore requires a comma-separated list of patterns." && usage
      IGNORE_PATTERNS="$1"
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      PROJECT_PATH="$1"
      shift
      break
      ;;
  esac
done

# Validate the path
if [ ! -d "$PROJECT_PATH" ]; then
  echo "Error: '$PROJECT_PATH' is not a valid directory."
  exit 1
fi

# Move into the specified directory
cd "$PROJECT_PATH" || exit

# Name of the output file
OUTPUT_FILE="project_dump.txt"

# Prepare tree ignore flag
TREE_IGNORE_FLAG=""
if [[ -n "$IGNORE_PATTERNS" ]]; then
  TREE_IGNORE_FLAG="-I '$IGNORE_PATTERNS'"
fi

# 1. Write header and project tree
echo "The project tree:" > "$OUTPUT_FILE"
# shellcheck disable=SC2086
eval tree -a $TREE_IGNORE_FLAG >> "$OUTPUT_FILE" 2>/dev/null

echo "----" >> "$OUTPUT_FILE"

# 2. Append file contents
IFS=',' read -r -a IGNORE_ARRAY <<< "$IGNORE_PATTERNS"
find_args=()
for pat in "${IGNORE_ARRAY[@]}"; do
  find_args+=( -path "./$pat" -prune -o )
done
find_args+=( -type f -print )

eval find . "${find_args[@]}" | while read -r file; do
  # Skip output file and script itself
  [[ "$file" == "./$OUTPUT_FILE" || "$file" == "./$SCRIPT_NAME" ]] && continue

  # Print file path
  echo "$file" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  # Dump file contents
  cat "$file" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  # Separator between files
  echo "---" >> "$OUTPUT_FILE"
done

echo ""
echo "Done! The project tree and file contents have been saved to:"
echo "  $(pwd)/$OUTPUT_FILE"
