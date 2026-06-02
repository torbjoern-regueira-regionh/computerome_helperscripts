#!/bin/bash
# RStudio Server launcher for Computerome
# Installs RStudio and prints the ready-to-use SSH tunnel command

# Color codes
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

module unload rstudio-server/2026.04.0-526 2>/dev/null
module unload tools 2>/dev/null
module load tools 2>/dev/null
module load rstudio-server/2026.04.0-526 2>/dev/null

echo ""
echo -e "${CYAN}============================================================${RESET}"
echo -e "${CYAN}  Starting RStudio Server...${RESET}"
echo -e "${CYAN}============================================================${RESET}"
echo ""

# Spinner while install runs in background
touch /tmp/$(echo $$).rstudio
sudo /services/tools/rstudio-server/2026.04.0-526/rstudio-srv-2026.04.0-526-R-4.6.0.sh > /tmp/rstudio_output.txt 2>&1 &
PID=$!

SPINNER=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
i=0
while kill -0 $PID 2>/dev/null; do
    printf "\r  ${CYAN}${SPINNER[$i]}${RESET}  Please wait, installing RStudio Server..."
    i=$(( (i+1) % 10 ))
    sleep 0.1
done
printf "\r  ${GREEN}✔${RESET}  Done!                                        \n"

OUTPUT=$(cat /tmp/rstudio_output.txt)
rm -f /tmp/rstudio_output.txt

echo ""
# echo $OUTPUT # Uncomment if you want to debug

NODE=$(hostname)
USER=$(whoami)
LOCAL_PORT=$(echo "$OUTPUT" | grep -oP '(?<=-L )\d+')
REMOTE_PORT=$(echo "$OUTPUT" | grep -oP '(?<=:)\d+(?= )' | tail -1)

echo ""
echo -e "${YELLOW}${BOLD}============================================================${RESET}"
echo -e "${YELLOW}${BOLD}  SSH tunnel command (run this on your LOCAL machine):${RESET}"
echo ""
echo -e "${YELLOW}${BOLD}  ssh -L ${LOCAL_PORT}:${NODE}:${REMOTE_PORT} ${USER}@ssh.computerome.dk${RESET}"
echo -e "${YELLOW}${BOLD}============================================================${RESET}"
echo ""
echo -e "${YELLOW}${BOLD}  Server will be available at: http://localhost:${LOCAL_PORT}${RESET}"
echo ""
echo ""
