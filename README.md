# history-search like tcsh

I developed this script to learn the usage of `coproc` on bash.

## Overview

This bash script provides `bhslt_search_backward` and `bhslt_search_forward`.  
They are similar to `history-search-backward` and `history-search-forward` in bash, but they **put cursor at the end of the line**.  
This behavior is based on tcsh.

## How to use

Add the following lines to `.bashrc`.
```sh
source /path/to/history_search_like_tcsh.sh
export PROMPT_COMMAND=bhslt_clear_state
bind -x '"\ep": bhslt_search_backward'
bind -x '"\en": bhslt_search_forward'
```

If your `.bashrc` already sets a function to `PROMPT_COMMAND`, you should also call `bhslt_clear_state` in the function.

# License

Copyright 2020 Masamitsu MURASE

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
