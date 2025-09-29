#!/bin/bash

# Bash completion for deploy-to-local script

_deploy_to_local_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Options
    opts="--list -l --help -h"
    
    # If previous word is the script name or we're at position 1
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        # Get application names from MULE_PROJECTS_HOME if set
        if [ -n "$MULE_PROJECTS_HOME" ] && [ -d "$MULE_PROJECTS_HOME" ]; then
            # Find all Mule application directories
            local apps=""
            for dir in "$MULE_PROJECTS_HOME"/*/; do
                if [ -f "${dir}pom.xml" ]; then
                    # Check if it's a Mule application
                    if grep -q "<packaging>mule-application</packaging>" "${dir}pom.xml" 2>/dev/null; then
                        apps="${apps} $(basename "$dir")"
                    fi
                fi
            done
            
            # Combine options and app names
            local all_completions="${opts} ${apps}"
            COMPREPLY=( $(compgen -W "${all_completions}" -- ${cur}) )
        else
            # Only options if MULE_PROJECTS_HOME is not set
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        fi
    fi
    
    return 0
}

# Register the completion function for deploy-to-local
complete -F _deploy_to_local_completion deploy-to-local