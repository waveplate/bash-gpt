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

# check if prefix is a directory
if [ ! -d $BASHGPT_PREFIX ]; then
    echo "Error: $BASHGPT_PREFIX is not a directory"
    exit 1
fi

# check if BASHRC is a file
if [ ! -f $BASHGPT_BASHRC ]; then
    echo "Error: $2 is not a file"
    exit 1
fi

#check if SHORTCUT_KEY is a single character
if [ ${#BASHGPT_SHORTCUT_KEY} -ne 1 ]; then
    echo ${#BASHGPT_SHORTCUT_KEY}
    echo "Error: '$BASHGPT_SHORTCUT_KEY' is not a single character"
    exit 1
fi

cp -r bash-gpt $BASHGPT_PREFIX

# remove existing source
sed -Ei '/^\. .+\/bash-gpt\/bin\/init$/d' $BASHGPT_BASHRC

# remove all existing entries
for KEY in ${KEYS[@]}; do
  sed -Ei "/^export $KEY=.+$/d" $BASHGPT_BASHRC
done

# add new entries
for KEY in ${KEYS[@]}; do
  echo "export $KEY='${!KEY}'" >> $BASHGPT_BASHRC
done

# add new source
echo ". $BASHGPT_PREFIX/bash-gpt/bin/init" >> $BASHGPT_BASHRC

echo "installation successful"
