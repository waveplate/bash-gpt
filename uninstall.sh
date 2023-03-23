#!/bin/bash

# define variable names
KEYS=(BASHGPT_PREFIX BASHGPT_BASHRC BASHGPT_SHORTCUT_KEY BASHGPT_OPENAI_KEY BASHGPT_MODEL BASHGPT_TEMPERATURE BASHGPT_MAX_TOKENS BASHGPT_TEMPLATE)

# if BASHGPT_BASHRC isn't set and no arguments are provided, print usage
if [ -z $BASHGPT_BASHRC ] && [ $# -eq 0 ]; then
    echo "Usage: $0 [BASHRC]"
    echo -e "\tBASHRC: the path to your .bashrc file"
    echo "Example: $0 ~/.bashrc"
    exit 1
fi

# if BASHRC argument is provided, set BASHGPT_BASHRC
if [ $# -eq 1 ]; then
    BASHGPT_BASHRC=$1
fi

# check if BASHRC is a file
if [ ! -f $BASHGPT_BASHRC ]; then
    echo "Error: $BASHGPT_BASHRC is not a file"
    exit 1
fi

# load values from BASHRC in case we need them (we do for BASHGPT_PREFIX and BASHGPT_BASHRC)
for KEY in ${KEYS[@]}; do
    VALUE=$(grep -E "^export $KEY=.+$" $BASHGPT_BASHRC | sed -E "s/^export $KEY=(.+)$/\1/" | sed -E "s/^'//;s/'$//")
    declare $KEY="$VALUE"
done

# check if BASHGPT_PREFIX is set
if [ -z $BASHGPT_PREFIX ]; then
    echo "* BASHGPT_PREFIX is not set (continuing anyway)"
else
    # check if BASHGPT_PREFIX is a directory and BASHGPT_PREFIX/bash-gpt exists
    if [ ! -d $BASHGPT_PREFIX ] || [ ! -d $BASHGPT_PREFIX/bash-gpt ]; then
        echo "* $BASHGPT_PREFIX is not a directory or $BASHGPT_PREFIX/bash-gpt does not exist (continuing anyway)"
    else
        # check if BASHGPT_PREFIX/bash-gpt can be deleted, if not use sudo to delete it
        if [ -w $BASHGPT_PREFIX/bash-gpt ]; then
            rm -rf $BASHGPT_PREFIX/bash-gpt
            echo "* removed $BASHGPT_PREFIX/bash-gpt"
        else
            sudo rm -rf $BASHGPT_PREFIX/bash-gpt
            echo "* removed $BASHGPT_PREFIX/bash-gpt"
        fi
    fi
fi

# remove all existing entries
for KEY in ${KEYS[@]}; do
    # check if BASHRC contains key
    if grep -qE "^export $KEY=.+$" $BASHGPT_BASHRC; then
        sed -Ei "/^export $KEY=.+$/d" $BASHGPT_BASHRC
        echo "* removed export for $KEY from $BASHGPT_BASHRC"
    else
        echo "* $BASHGPT_BASHRC does not contain $KEY (continuing anyway)"
    fi
done

# check if BASHRC contains source
if grep -qE "^\. .+\/bash-gpt\/bin\/init$" $BASHGPT_BASHRC; then
    sed -Ei '/^\. .+\/bash-gpt\/bin\/init$/d' $BASHGPT_BASHRC
    echo "* removed source from $BASHGPT_BASHRC"
else
    echo "* $BASHGPT_BASHRC does not contain source (continuing anyway)"
fi

echo "successfully uninstalled"
