#!/bin/bash

# define variable names
KEYS=(BASHGPT_PREFIX BASHGPT_BASHRC BASHGPT_SHORTCUT_KEY BASHGPT_OPENAI_KEY BASHGPT_MODEL BASHGPT_TEMPERATURE BASHGPT_MAX_TOKENS BASHGPT_TEMPLATE)

# check if number of arguments is correct
if [ $# -lt 4 ] || [ $# -gt 8 ]; then
    echo "Usage: $0 PREFIX BASHRC SHORTCUT_KEY OPENAI_KEY [MODEL] [TEMPERATURE] [MAX_TOKENS] [TEMPLATE]"
    echo -e "\tPREFIX: the path to install bash-gpt"
    echo -e "\tBASHRC: the path to your .bashrc file"
    echo -e "\tSHORTCUT_KEY: the key to trigger bash-gpt"
    echo -e "\tOPENAI_KEY: the key to access OpenAI API"
    echo -e "\tMODEL: the model to use (default: text-davinci-003)"
    echo -e "\tTEMPERATURE: the temperature to use (default: 0)"
    echo -e "\tMAX_TOKENS: the maximum number of tokens to generate (default: 100)"
    echo -e "\tTEMPLATE: the prompt template to use (default: 'here is the bash command in a code block: {{TEXT}}')'"
    echo "Example: $0 /usr/local/ ~/.bashrc \" \" 1234567890abcdef1234567890abcdef"
    exit 1
fi

# set defaults
BASHGPT_MODEL=${5:-text-davinci-003}
BASHGPT_TEMPERATURE=${6:-0}
BASHGPT_MAX_TOKENS=${7:-100}
BASHGPT_TEMPLATE='here is the bash command in a code block: {{TEXT}}'

# create variables from arguments
for (( i=1; i<=$#; i++ )); do
    eval ${KEYS[$i-1]}='${!i}'
done

# check if prefix is a directory and is writable
if [ ! -d $BASHGPT_PREFIX ] || [ ! -w $BASHGPT_PREFIX ]; then
    echo "Error: $BASHGPT_PREFIX is not a directory or not writable (did you forget to use sudo?)"
    exit 1
fi

# check if BASHRC is a file and is writable
if [ ! -f $BASHGPT_BASHRC ] || [ ! -w $BASHGPT_BASHRC ]; then
    echo "Error: $BASHGPT_BASHRC is not a file or not writable"
    exit 1
fi

#check if SHORTCUT_KEY is a single character
if [ ${#BASHGPT_SHORTCUT_KEY} -ne 1 ]; then
    echo ${#BASHGPT_SHORTCUT_KEY}
    echo "Error: '$BASHGPT_SHORTCUT_KEY' is not a single character"
    exit 1
fi

cp -r bash-gpt $BASHGPT_PREFIX
echo "* copied bash-gpt to $BASHGPT_PREFIX"

REMOVED=()

# remove all existing entries
for KEY in ${KEYS[@]}; do
    # check if entry exists
    if grep -qE "^export $KEY=.+$" $BASHGPT_BASHRC; then
        REMOVED+=($KEY)
        sed -Ei "/^export $KEY=.+$/d" $BASHGPT_BASHRC
    fi
done

# add new entries
for KEY in ${KEYS[@]}; do
    # escape single quotes in ${!KEY}
    VALUE=$(echo ${!KEY} | sed "s/'/\\\'/g")
    # add entry to BASHRC
    echo "export $KEY='$VALUE'" >> $BASHGPT_BASHRC

    # check if KEY is in the REMOVED array
    if [[ " ${REMOVED[@]} " =~ " ${KEY} " ]]; then
        echo "* updated $KEY export in $BASHGPT_BASHRC"
    else
        echo "* added $KEY export to $BASHGPT_BASHRC"
    fi
done

# check if source exists in BASHRC
if grep -qE "^\. .+\/bash-gpt\/bin\/init$" $BASHGPT_BASHRC; then
    echo "* updated bash-gpt source in $BASHGPT_BASHRC"
else
    echo "* added bash-gpt source to $BASHGPT_BASHRC"
fi

# remove existing source if present
sed -Ei '/^\. .+\/bash-gpt\/bin\/init$/d' $BASHGPT_BASHRC

# add new source
echo ". $BASHGPT_PREFIX/bash-gpt/bin/init" >> $BASHGPT_BASHRC

echo "installation successful"
