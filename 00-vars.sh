# ========================================
# Description
# ========================================
# Generic working variables.


# ========================================
# User Specific
# ========================================
# Partitions and mount points.
sddisk="/dev/nvme0n1"
sdboot="${sddisk}p1"
sddata="${sddisk}p2"
sdswap="${sddisk}p3"
sdroot="${sddisk}p4"
rddata="luksData"
rdswap="luksSwap"
rdroot="luksRoot"
dmdata="/dev/mapper/${rddata}"
dmswap="/dev/mapper/${rdswap}"
dmroot="/dev/mapper/${rdroot}"


# ========================================
# Global Variables
# ========================================
scriptName="$(basename -- $0)"
scriptBase="${scriptName%.*}"
scriptTitle="Configure Arch Linux"

# Color variables.
colBlack="\033[0;30m"
colRed="\033[0;31m"
colGreen="\033[0;32m"
colBlue="\033[0;34m"
colYellow="\033[0;33m"
colMagenta="\033[0;35m"
colCyan="\033[0;36m"

bgBlack="\033[0;40m"
bgRed="\033[0;41m"
bgGreen="\033[0;42m"
bgYellow="\033[0;43m"
bgBlue="\033[0;44m"
bgMagenta="\033[0;45m"
bgCyan="\033[0;46m"

# Clear the color after that.
colClear="\033[0m"

# Catch ctrl-c.
trap Cancel INT


# ========================================
# Functions
# ========================================
# Display help.
function Help() {
    echo -e "\033[4m${scriptTitle}\033[m"
    echo "Platform: $(uname)"
    echo
    echo "Options:"
    echo "  -h      Print this help."
    echo
}

# Exit with error.
function ExitAbnormal() {
    Help
    exit 1
}

# Prints.
# Colour formatting:
#   Start sequence: \033[Color1;Color2m
#   Stop sequence:  \033[0m
function PrintInfo() {
    echo -e "${colCyan}[INFO]${colClear} ${1}"
}

function PrintNote() {
    echo -e "${colMagenta}[INFO]${colClear} ${1}"
}

function PrintWarning() {
    echo -e "${colRed}[WARNING]${colClear} ${1}"
}

function PrintSuccess() {
    echo -e "${colGreen}${1}${colClear}"
}

function Prompt() {
    read -p "Enter (y) to continue or (n) to skip: " ans
}

# Cancel.
function Cancel() {
    PrintWarning "-- Process Interupted --"
    PrintWarning "Terminating...."
    exit 0
}