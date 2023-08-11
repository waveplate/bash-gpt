# bash-gpt (0.1.1)

![bash-gpt](https://i.imgur.com/IXYboy2.gif)

*bash-gpt* is a bash extension that rewrites a natural language command into an actual command when you press a keyboard shortcut

*bash-gpt* only depends on `sed`, `awk` and `curl`

> *note: sorry! now fixed as of 2023/8/7 -- openai added whitespaces to their JSON which broke the regexp for parsing it*

# quick install
`sudo ./install.sh /usr/local ~/.bashrc " " <YOUR_OPENAI_API_KEY>`

or

`./install.sh ~ ~/.bashrc " " <YOUR_OPENAI_API_KEY>`

# uninstall
`./uninstall.sh [BASHRC]`

if `BASHRC` is not specified, it will attempt to uninstall using the `BASHRC` in your `BASHGPT_BASHRC` environment variable

# example #1
once installed, open a new shell and type a natural language command

`$ find all executable files in /usr created within the last day`

press Ctrl-[space]

`$ find /usr -type f -executable -mtime -1`

```
/usr/local/bash-gpt/bin/init
/usr/local/bash-gpt/bin/gpt
```

# more examples

| natural language | generated command |
| --- | --- |
replace every instance of foo with baz in my_file.txt | `sed -i 's/foo/baz/g' my_file.txt`
flip my_video.mp4 vertically, scale it to 720p and save it as my_output.mp4 | `ffmpeg -i my_video.mp4 -vf "vflip,scale=720:-1" my_output.mp4`

# install script usage
`Usage: ./install.sh PREFIX BASHRC SHORTCUT_KEY OPENAI_KEY [MODEL] [TEMPERATURE] [MAX_TOKENS] [TEMPLATE]`

| usage | description | example/default value |
| --- | --- | --- |
| PREFIX | The path to install bash-gpt | `/usr/local`
| BASHRC | The path to your `.bashrc` file | `~/.bashrc`
| SHORTCUT_KEY | The key to trigger bash-gpt (CTRL-KEY)| `" "`
| OPENAI_KEY | The key to access OpenAI API | `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`
| MODEL | The model to use | `text-davinci-003`
| TEMPERATURE | The temperature to use | `0`
| MAX_TOKENS | The maximum number of tokens to generate (smaller is faster) | `100`
| TEMPLATE | The prompt template to use (`{{TEXT}}` is replaced with the natural language query) | `here is the bash command in a code block: {{TEXT}}`

# customisation

#### update permanently
to make changes to the default `MODEL`, `TEMPERATURE`, `MAX_TOKENS` or `TEMPLATE` you can run the `install.sh` again and it will update your `.bashrc`

#### update temporarily
you can make temporary changes to these parameters like so

`$ export BASHGPT_MODEL=<MODEL>`

`$ export BASHGPT_TEMPERATURE=<TEMPERATURE>`

`$ export BASHGPT_MAX_TOKENS=<MAX_TOKENS>`

`$ export BASHGPT_TEMPLATE=<TEMPLATE>`

# models

| template | description | max tokens | notes |
| --- | --- | --- | --- |
| text-davinci-003 | Can do any language task with better quality, longer output, and consistent instruction-following than the curie, babbage, or ada models. Also supports inserting completions within text. | 4,097 tokens | default, fastest
| text-davinci-002 | Similar capabilities to text-davinci-003 but trained with supervised fine-tuning instead of reinforcement learning | 4,097 tokens | not great for code
| gpt-3.5-turbo | Most capable GPT-3.5 model and optimized for chat at 1/10th the cost of text-davinci-003. Will be updated with our latest model iteration. | 4,096 tokens | good model, but slow
| gpt-4 | More capable than any GPT-3.5 model, able to do more complex tasks, and optimized for chat. Will be updated with our latest model iteration. | 8,192 tokens | slow, not available to all users
| gpt-4-32k | Same capabilities as the base gpt-4 mode but with 4x the context length. Will be updated with our latest model iteration. | 32,768 tokens | slow, not available to all users
| code-cushman-001 | Almost as capable as Davinci Codex, but slightly faster. This speed advantage may make it preferable for real-time applications. | 2,048 tokens | fastest model, but deprecated as of march 23rd 2023
| code-davinci-002 | Most capable Codex model. Particularly good at translating natural language to code. In addition to completing code, also supports inserting completions within code. | 8,001 tokens | best code model, but deprecated as of march 23rd 2023
