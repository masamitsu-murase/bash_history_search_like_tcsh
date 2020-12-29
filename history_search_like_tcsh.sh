
__bhslt_python_path="python"
__bhslt_python_src_path="/path/to/search_history.py"

__bhslt_coproc_fd="None"
__bhslt_readline_line=""
__bhslt_readline_point=-1

__bhslt_clear_state() {
    if [ "$__bhslt_coproc_fd" != "None" ] ; then
        __bhslt_readline_line=""
        __bhslt_readline_point=-1
        echo '<quit>' >&${__bhslt_coproc_fd[1]}
        wait $__bhslt_coproc_fd_PID 2>/dev/null
        __bhslt_coproc_fd="None"
    fi
}

__bhslt_check_state() {
    if [ "${READLINE_LINE}" != "$__bhslt_readline_line" ] || [ "${READLINE_POINT}" != "$__bhslt_readline_point" ] ; then
        __bhslt_clear_state
    fi
}

__bhslt_search_backward() {
    __bhslt_check_state

    if [ "$__bhslt_coproc_fd" = "None" ] ; then
        export BHSLT_PREFIX="${READLINE_LINE:0:$READLINE_POINT}"
        { coproc __bhslt_coproc_fd { $__bhslt_python_path $__bhslt_python_src_path ; } } 2>/dev/null
        unset BHSLT_PREFIX
        HISTTIMEFORMAT=' ' history >&${__bhslt_coproc_fd[1]}
        echo '<history end>' >&${__bhslt_coproc_fd[1]}
    else
        echo '<previous match>' >&${__bhslt_coproc_fd[1]}
    fi
    read -u ${__bhslt_coproc_fd[0]} match_command

    READLINE_LINE="${match_command:0:-1}"
    READLINE_POINT="${#READLINE_LINE}"
    __bhslt_readline_line=$READLINE_LINE
    __bhslt_readline_point=$READLINE_POINT
}

__bhslt_search_forward() {
    __bhslt_check_state

    if [ "$__bhslt_coproc_fd" != "None" ] ; then
        echo '<next match>' >&${__bhslt_coproc_fd[1]}
        read -u ${__bhslt_coproc_fd[0]} match_command

        READLINE_LINE="${match_command:0:-1}"
        READLINE_POINT="${#READLINE_LINE}"
        __bhslt_readline_line=$READLINE_LINE
        __bhslt_readline_point=$READLINE_POINT
    fi
}

export PROMPT_COMMAND=__bhslt_clear_state

bind -x '"\ep": __bhslt_search_backward'
bind -x '"\en": __bhslt_search_forward'
