
__bhslt_prefix=""
__bhslt_current_match=""
__bhslt_readline_line=""
__bhslt_readline_point=-1

__bhslt_clear_state() {
    __bhslt_prefix=""
    __bhslt_current_match=""
    __bhslt_readline_line=""
    __bhslt_readline_point=-1
}

__bhslt_check_state() {
    if [ "${READLINE_LINE}" != "$__bhslt_readline_line" ] || [ "${READLINE_POINT}" != "$__bhslt_readline_point" ] ; then
        __bhslt_clear_state
    fi
}

__bhslt_search_backward() {
    __bhslt_check_state

    if [ "$__bhslt_current_match" = "" ]; then
        __bhslt_prefix="${READLINE_LINE:0:$READLINE_POINT}"
    fi

    { coproc FC_FD { fc -lnr -$HISTSIZE ; } } 2>/dev/null
    local PREFIX_LEN=${#__bhslt_prefix}
    local FOUND=0
    local MATCHED_LINE=""
    declare -A HISTORY_HASH
    if [ "$__bhslt_current_match" = "" ]; then
        FOUND=1
    fi
    while read -u ${FC_FD[0]} LINE; do
        if [ "$LINE" != "" ] && [ -z "${HISTORY_HASH[$LINE]}" ] && [ "${LINE:0:$PREFIX_LEN}" = "$__bhslt_prefix" ]; then
            HISTORY_HASH[$LINE]="1"

            if [ $FOUND -eq 0 ]; then
                if [ "$__bhslt_current_match" = "$LINE" ]; then
                    FOUND=1
                fi
            else
                MATCHED_LINE="$LINE"
                read -u ${FC_FD[0]} -d ''
                break
            fi
        fi
    done
    wait $FC_FD_PID 2>/dev/null

    if [ "$MATCHED_LINE" != "" ]; then
        READLINE_LINE="${MATCHED_LINE}"
        READLINE_POINT="${#READLINE_LINE}"
        __bhslt_current_match="${MATCHED_LINE}"
        __bhslt_readline_line=$READLINE_LINE
        __bhslt_readline_point=$READLINE_POINT
    fi
}

__bhslt_search_forward() {
    __bhslt_check_state

    if [ "$__bhslt_current_match" = "" ]; then
        return
    fi

    { coproc FC_FD { fc -lnr -$HISTSIZE ; } } 2>/dev/null
    local PREFIX_LEN=${#__bhslt_prefix}
    declare -A HISTORY_HASH
    local LAST_MATCHED_LINE=""
    while read -u ${FC_FD[0]} LINE; do
        if [ "$LINE" != "" ] && [ -z "${HISTORY_HASH[$LINE]}" ] && [ "${LINE:0:$PREFIX_LEN}" = "$__bhslt_prefix" ]; then
            HISTORY_HASH[$LINE]="1"

            if [ "$__bhslt_current_match" = "$LINE" ]; then
                read -u ${FC_FD[0]} -d ''
                break
            else
                LAST_MATCHED_LINE="$LINE"
            fi
        fi
    done
    wait $FC_FD_PID 2>/dev/null

    if [ "$LAST_MATCHED_LINE" != "" ]; then
        READLINE_LINE="${LAST_MATCHED_LINE}"
        READLINE_POINT="${#READLINE_LINE}"
        __bhslt_current_match="${LAST_MATCHED_LINE}"
        __bhslt_readline_line=$READLINE_LINE
        __bhslt_readline_point=$READLINE_POINT
    fi
}

export PROMPT_COMMAND=__bhslt_clear_state

bind -x '"\ep": __bhslt_search_backward'
bind -x '"\en": __bhslt_search_forward'
