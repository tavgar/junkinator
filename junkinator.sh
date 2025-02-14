#!/usr/bin/env bash

SCRIPT_NAME="junkinator"
INSTALL_PATH="/usr/local/bin/$SCRIPT_NAME"

if [ "$1" = "install" ]; then
  echo "Installing $SCRIPT_NAME to $INSTALL_PATH..."
  # Copy this script to /usr/local/bin and make it executable
  sudo cp "$0" "$INSTALL_PATH"
  sudo chmod +x "$INSTALL_PATH"
  echo "Installation successful. Now you can run '$SCRIPT_NAME' from anywhere."
  exit 0
fi

# ---------------------------
# Main script logic (if not installing)
# ---------------------------

# Prompt for the project path
read -rp "Enter the project path: " PROJECT_PATH

# Validate the path
if [ ! -d "$PROJECT_PATH" ]; then
  echo "Error: '$PROJECT_PATH' is not a valid directory."
  exit 1
fi

# Move into the specified directory
cd "$PROJECT_PATH" || exit

# Name of the output file
OUTPUT_FILE="project_dump.txt"

# 1. Write header and project tree
echo "The project tree:" > "$OUTPUT_FILE"
tree -a >> "$OUTPUT_FILE" 2>/dev/null

echo "----" >> "$OUTPUT_FILE"

# 2. Append file contents
find . -type f | while read -r file; do

  # Optional: skip dumping the project_dump.txt or this script (if it's in the same directory)
  if [[ "$file" == "./$OUTPUT_FILE" || "$file" == "./$SCRIPT_NAME" ]]; then
    continue
  fi

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
echo "  $PROJECT_PATH/$OUTPUT_FILE"