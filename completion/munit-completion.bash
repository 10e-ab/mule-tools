#!/bin/bash

# Bash completion for munit command

_munit_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Get the current directory
    local current_dir=$(pwd)
    local munit_dir="${current_dir}/src/test/munit"

    # Check if previous argument was an option flag
    local is_after_option=false
    if [[ "$prev" =~ ^-- ]]; then
        is_after_option=true
    fi

    # Check if we're in a Mule project with munit tests
    if [ -d "$munit_dir" ]; then
        # Find all XML test files in src/test/munit
        local test_files=""

        # Get all XML files in the munit directory
        for file in "$munit_dir"/*.xml; do
            if [ -f "$file" ]; then
                # Extract just the filename without path
                local filename=$(basename "$file")
                # Check if this file has already been specified
                local already_specified=false
                for word in "${COMP_WORDS[@]:1:$((COMP_CWORD-1))}"; do
                    if [[ "$word" == "$filename" ]]; then
                        already_specified=true
                        break
                    fi
                done
                # Only add if not already specified
                if [ "$already_specified" = false ]; then
                    test_files="${test_files} ${filename}"
                fi
            fi
        done

        # Offer test files and options based on position and context
        if [[ ${COMP_CWORD} -eq 1 ]]; then
            # First argument: offer test files and options
            local options="--help --version --stale -s"
            local all_completions="${test_files} ${options}"
            COMPREPLY=( $(compgen -W "${all_completions}" -- ${cur}) )
        else
            # Additional arguments: offer more test files if any remain
            if [ -n "$test_files" ]; then
                COMPREPLY=( $(compgen -W "${test_files}" -- ${cur}) )
            fi
        fi
    else
        # If not in a Mule project, just offer help options
        if [[ ${COMP_CWORD} -eq 1 ]]; then
            local options="--help --version"
            COMPREPLY=( $(compgen -W "${options}" -- ${cur}) )
        fi
    fi

    return 0
}

# Register the completion function for munit
complete -F _munit_completion munit