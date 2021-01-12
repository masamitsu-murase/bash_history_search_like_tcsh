# Version 1.2.0

__bhslt_current_match_index=-1
__bhslt_history_array=()
__bhslt_readline_line=""
__bhslt_readline_point=-1

__bhslt_clear_state() {
    __bhslt_current_match_index=-1
    __bhslt_history_array=()
    __bhslt_readline_line=""
    __bhslt_readline_point=-1
}

__bhslt_check_state() {
    if [[ "${READLINE_LINE}" != "$__bhslt_readline_line" || ${READLINE_POINT} -ne $__bhslt_readline_point ]]; then
        __bhslt_clear_state
    fi
}

__bhslt_search_backward() {
    __bhslt_check_state

    if [[ $__bhslt_current_match_index -eq -1 ]]; then
        local PREFIX="${READLINE_LINE:0:$READLINE_POINT}"

        local FC=$(POSIXLY_CORRECT="1" fc -lnr -${HISTSIZE:-1000})
        local PREFIX_LEN=${#PREFIX}
        declare -A HISTORY_HASH
        declare -a BLOCK_LINES=()
        local IFS=$'\n'
        local GLOBIGNORE='*'
        local LINE=""

        BLOCK_LINES=($FC)

        local i
        for ((i=0; i<${#BLOCK_LINES[@]}; i++)); do
            LINE="${BLOCK_LINES[$i]:1}"
            if [[ -n "$LINE" && -z "${HISTORY_HASH[$LINE]}" && "${LINE:0:$PREFIX_LEN}" == "$PREFIX" ]]; then
                HISTORY_HASH[$LINE]="1"
                __bhslt_history_array+=( "$LINE" )
            fi
        done

        if [[ ${#__bhslt_history_array[@]} -gt 0 ]]; then
            __bhslt_current_match_index=0
            READLINE_LINE="${__bhslt_history_array[$__bhslt_current_match_index]}"
            READLINE_POINT=${#READLINE_LINE}
            __bhslt_readline_line=$READLINE_LINE
            __bhslt_readline_point=$READLINE_POINT
        fi
    else
        if [[ $__bhslt_current_match_index+1 -lt ${#__bhslt_history_array[@]} ]]; then
            __bhslt_current_match_index=$(($__bhslt_current_match_index+1))
            READLINE_LINE="${__bhslt_history_array[$__bhslt_current_match_index]}"
            READLINE_POINT=${#READLINE_LINE}
            __bhslt_readline_line=$READLINE_LINE
            __bhslt_readline_point=$READLINE_POINT
        fi
    fi
}

__bhslt_search_forward() {
    __bhslt_check_state

    if [[ $__bhslt_current_match_index -gt 0 ]]; then
        __bhslt_current_match_index=$(($__bhslt_current_match_index-1))
        READLINE_LINE="${__bhslt_history_array[$__bhslt_current_match_index]}"
        READLINE_POINT=${#READLINE_LINE}
        __bhslt_readline_line=$READLINE_LINE
        __bhslt_readline_point=$READLINE_POINT
    fi
}
