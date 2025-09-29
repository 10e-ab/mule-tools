#!/bin/bash

# Bash completion for undeploy-from-local script

_undeploy_from_local_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Options
    opts="--list -l --all --others --force -f --force-all -F --clear-data -c --help"
    
    # If previous word is the script name or we're at position 1
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        # Get deployed application names from MULE_SERVER_HOME if set
        if [ -n "$MULE_SERVER_HOME" ] && [ -d "$MULE_SERVER_HOME/apps" ]; then
            # Find all deployed apps (JAR files and directories)
            local apps=""
            
            # Get apps from JAR files
            for jar in "$MULE_SERVER_HOME/apps"/*.jar; do
                if [ -f "$jar" ]; then
                    app_name=$(basename "$jar" .jar)
                    # Skip libraries
                    if [[ ! "$app_name" =~ ^lib- ]]; then
                        apps="${apps} ${app_name}"
                    fi
                fi
            done
            
            # Get apps from directories (in case JAR is already removed)
            for dir in "$MULE_SERVER_HOME/apps"/*/; do
                if [ -d "$dir" ]; then
                    app_name=$(basename "$dir")
                    # Skip libraries and avoid duplicates
                    if [[ ! "$app_name" =~ ^lib- ]] && [[ ! " $apps " =~ " $app_name " ]]; then
                        apps="${apps} ${app_name}"
                    fi
                fi
            done
            
            # Combine options and app names
            local all_completions="${opts} ${apps}"
            COMPREPLY=( $(compgen -W "${all_completions}" -- ${cur}) )
        else
            # Only options if MULE_SERVER_HOME is not set
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        fi
    elif [[ ${COMP_CWORD} -eq 2 ]]; then
        # If first argument was an app name or -f/--force/-F/--force-all, offer appropriate options
        if [[ "$prev" != "--list" && "$prev" != "-l" && "$prev" != "--all" && "$prev" != "--others" && "$prev" != "--help" ]]; then
            if [[ "$prev" == "-f" || "$prev" == "--force" || "$prev" == "-F" || "$prev" == "--force-all" ]]; then
                # After force flags, offer app names
                if [ -n "$MULE_SERVER_HOME" ] && [ -d "$MULE_SERVER_HOME/apps" ]; then
                    local apps=""
                    for jar in "$MULE_SERVER_HOME/apps"/*.jar; do
                        if [ -f "$jar" ]; then
                            app_name=$(basename "$jar" .jar)
                            if [[ ! "$app_name" =~ ^lib- ]]; then
                                apps="${apps} ${app_name}"
                            fi
                        fi
                    done
                    COMPREPLY=( $(compgen -W "${apps}" -- ${cur}) )
                fi
            else
                # After app name, offer --force, --force-all and --clear-data
                COMPREPLY=( $(compgen -W "--force -f --force-all -F --clear-data -c" -- ${cur}) )
            fi
        fi
    elif [[ ${COMP_CWORD} -eq 3 ]]; then
        # For third position, offer remaining flags that haven't been used
        local used_force=false
        local used_force_all=false
        local used_clear=false
        for word in "${COMP_WORDS[@]}"; do
            if [[ "$word" == "--force" || "$word" == "-f" ]]; then
                used_force=true
            fi
            if [[ "$word" == "--force-all" || "$word" == "-F" ]]; then
                used_force_all=true
                used_force=true  # force-all implies force
            fi
            if [[ "$word" == "--clear-data" || "$word" == "-c" ]]; then
                used_clear=true
            fi
        done
        
        local remaining=""
        # Only offer regular force if neither force nor force-all has been used
        if [ "$used_force" = false ] && [ "$used_force_all" = false ]; then
            remaining="$remaining --force -f --force-all -F"
        elif [ "$used_force" = true ] && [ "$used_force_all" = false ]; then
            # If only regular force was used, don't offer force-all
            remaining=""
        fi
        if [ "$used_clear" = false ]; then
            remaining="$remaining --clear-data -c"
        fi
        
        if [ -n "$remaining" ]; then
            COMPREPLY=( $(compgen -W "$remaining" -- ${cur}) )
        fi
    fi
    
    return 0
}

# Register the completion function for undeploy-from-local
complete -F _undeploy_from_local_completion undeploy-from-local