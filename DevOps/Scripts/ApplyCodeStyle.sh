#!/bin/bash

declare -r -x ALL_SCOPE="All"
declare -r -x AZURE_MODE="Azure"
declare -r -x BRANCH_SCOPE="Branch"
declare -r -x FORMAT_MODE="Format"
declare -r -x HEAD_SCOPE="Head"
declare -r -x INPUT_SCOPE="Input"
declare -r -x MODIFIED_SCOPE="Modified"
declare -r -x STAGED_SCOPE="Staged"
declare -r -x VERIFY_MODE="Verify"

declare -r -x ACCEPTED_FILES_EXPRESSION='\.(c|h)(pp)?$'
declare -r -x BROKEN_COMMENT_FILTER='s/^(\s*\/\*+\*)\/\/(\*+)\s*$/\1**\2/'
declare -r -x DENIED_COPYRIGHT_EXPRESSION='Copyright\s?\(c\) .{4,10} (IAR Systems|Real Time Engineers Ltd|STMicroelectronics|Texas Instruments Incorporated)'
declare -r -x DENIED_FILES_EXPRESSION='^(Application_BLEMCU(((_TIN)?/Libraries))|Utilities/SystemTest/boost|Application_MCU/(Libraries|Source/HMI/(generated|touchgfx/framework))|Bootloader_AMCU/Libraries|CommonLibraries/(CMSIS|Crc|ExchangeDefinition|IPCdefinitions|Linker|littlefs|Persistence|STM32H7xx_HAL_Driver|TINDriver))'
declare -r -x SKIP_COPYRIGHT_CHECK_EXPRESSION='^Application_BLEMCU/Source/(PROFILES/truma_profile|Application/multi_role_MBT)\.(cpp|h)$'
declare -r -x SUBVERSION_FILTER='/^\s*\\b SVN Info:/d;/^\s*\$Revision:/d;/^\s*\$LastChangedBy:/d;/^\s*\$Date:/d'
declare -r -x WARNING_FILTER='s/^(.+):([[:digit:]]+):([[:digit:]]+): error:\s*(.+)\s*\[-Wclang-format-violations\]$/##vso[task.logissue type=error;sourcepath=\1;linenumber=\2;columnnumber=\3;]\4/'

function apply_style() {
    if test_external_file "$@"; then
        echo_error "$@: Ignored file since it was not created by Truma!"
        return 0
    fi

    if [ "${mode}" = "${AZURE_MODE}" ]; then
        verify_files "$@" 2> >(sed --regexp-extended "${WARNING_FILTER}" >&2)
        return $?
    fi

    if [ "${mode}" = "${FORMAT_MODE}" ]; then
        # Remove subversion specific headers
        sed --in-place --regexp-extended "${SUBVERSION_FILTER}" "$@"
        # Remove closing and opening comments on single line (...*//*...)
        sed --in-place --regexp-extended "${BROKEN_COMMENT_FILTER}" "$@"
        clang-format -i --style=file "$@"
        unix2dos --quiet --oldfile "$@"
        return 0
    fi

    if [ "${mode}" = "${VERIFY_MODE}" ]; then
        verify_files "$@"
        return $?
    fi

    echo_error "${mode}: No such mode"
    return 1
}

function echo_error() {
    echo >&2 $@
}

function git_files() {
    git "$@" | grep --regexp='^[^D][[:blank:]]' | cut -f2-
}

function select_files() {
    if [ "${scope}" = "${ALL_SCOPE}" ]; then
        git ls-tree -r --full-name --full-tree --name-only HEAD
        return
    fi

    if [ "${scope}" = "${BRANCH_SCOPE}" ]; then
        git_files diff --name-status ${branch} HEAD
        return
    fi

    if [ "${scope}" = "${HEAD_SCOPE}" ]; then
        git_files diff-tree --name-status --no-commit-id -r HEAD
        return
    fi

    if [ "${scope}" = "${INPUT_SCOPE}" ]; then
        cat /dev/stdin
        return
    fi

    if [ "${scope}" = "${MODIFIED_SCOPE}" ]; then
        git_files diff --name-status HEAD
        return
    fi

    if [ "${scope}" = "${STAGED_SCOPE}" ]; then
        git_files diff --name-status --staged HEAD
        return
    fi

    echo_error "${scope}: No such scope"
    exit 1
}

function test_external_file() {
    for file in "$@"; do
        if [[ $file =~ $SKIP_COPYRIGHT_CHECK_EXPRESSION ]]; then
            continue
        fi

        if grep --extended-regexp --ignore-case --regexp="${DENIED_COPYRIGHT_EXPRESSION}" "$@" >/dev/null; then
            return 0
        fi
    done

    return 1
}

function verify_files() {
    clang-format --dry-run --style=file --Werror "$@"
    return $?
}

mode=${FORMAT_MODE}
scope=${MODIFIED_SCOPE}

for argument in "$@"; do
    case ${argument} in
    --all)
        scope=${ALL_SCOPE}
        ;;
    --azure)
        mode=${AZURE_MODE}
        ;;
    --branch=*)
        branch=${argument#--branch=}
        scope=${BRANCH_SCOPE}
        ;;
    --format)
        mode=${FORMAT_MODE}
        ;;
    --head)
        scope=${HEAD_SCOPE}
        ;;
    --input)
        scope=${INPUT_SCOPE}
        ;;
    --modified)
        scope=${MODIFIED_SCOPE}
        ;;
    --staged)
        scope=${STAGED_SCOPE}
        ;;
    --verify)
        mode=${VERIFY_MODE}
        ;;
    *)
        echo_error "${argument}: No such argument!"
        exit 1
        ;;
    esac
done

readonly mode
readonly scope
clang-format --version

export -f apply_style
export -f echo_error
export -f test_external_file
export -f verify_files
export mode
select_files \
    | grep --extended-regexp --ignore-case --regexp="${ACCEPTED_FILES_EXPRESSION}" \
    | grep --extended-regexp --invert-match --regexp="${DENIED_FILES_EXPRESSION}" \
    | xargs --max-procs=$(nproc) -I {} bash -c 'apply_style "$@"' _ {}
readonly result=$?
if [ $result -ne 0 -a "${mode}" = "${AZURE_MODE}" ]; then
    echo "##vso[task.complete result=Failed;]FAILED"
    exit 0
fi
exit $result