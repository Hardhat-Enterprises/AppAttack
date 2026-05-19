#!/bin/bash

automate_reporting(){

#asking user for input file with validation
while true; do
  read -p "Enter input file location: " INPUT_FILE
  #check if string is empty OR if file does NOT exist
  if [[ -z "$INPUT_FILE" ]]; then
    echo "Please enter a path to the input file"
  elif [[ ! -f "$INPUT_FILE" ]]; then
    echo "File does not exist at '$INPUT_FILE'"
  else 
    break
  fi
done

#asking user for tool name with validation. tool names can only be nmap, hydra, or nikto
while true; do
  read -p "Enter tool name (nmap, hydra, or nikto): " TOOL_NAME

  #converting tool name to lowercase to prevent parsing errors
  TOOL_NAME=$(echo "$TOOL_NAME" | tr '[:upper:]' '[:lower:]')

  if [[ -z "$TOOL_NAME" ]]; then
    echo "Please enter the name of the tool." 
  elif [[ "$TOOL_NAME" != "nmap" && "$TOOL_NAME" != "hydra" && "$TOOL_NAME" != "nikto" ]]; then
        echo "'$TOOL_NAME' is invalid. Please choose from: nmap, hydra, nikto."
  else 
    break
  fi
done


timestamp=$(date +%F_%H-%M-%S)
AUTOMATED_REPORTING_OUTPUT_DIR="$OUTPUT_DIR/automated_reporting"
mkdir -p $AUTOMATED_REPORTING_OUTPUT_DIR


# parse results based on tool
parse_results() {
  case "$TOOL_NAME" in
    nmap)
      grep -E "^[0-9]+/tcp.*open" "$INPUT_FILE" || echo "No open ports found";
      ;;
    hydra)
      grep -E ":.*login:" "$INPUT_FILE" || echo "No valid credentials found";
      ;;
    nikto)
      grep "OSVDB" "$INPUT_FILE" || echo "No vulnerabilities found";
      ;;
    *)
      cat "$INPUT_FILE";
      ;;
  esac
}

output_txt() {
    OUTPUT_FILE="$AUTOMATED_REPORTING_OUTPUT_DIR/${TOOL_NAME}_report-${timestamp}.txt"
    echo "# Automated Consolidated Report" >> "$OUTPUT_FILE"
    echo "_Generated on $(date)_" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    echo "##$TOOL_NAME" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    parse_results | while read -r line; do
      if [[ -n "$line" ]]; then
        echo "- **$line**" >> "$OUTPUT_FILE"
      fi
    done
    echo "" >> "$OUTPUT_FILE"
    
}

output_txt

echo "You can find your completed report at '$OUTPUT_FILE'"
}