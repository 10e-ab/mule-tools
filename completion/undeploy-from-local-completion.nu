# Nushell completion for undeploy-from-local

# Get list of deployed Mule applications
def get-deployed-apps [] {
    if ($env.MULE_SERVER_HOME? | is-empty) {
        return []
    }
    
    let apps_dir = $"($env.MULE_SERVER_HOME)/apps"
    
    if not ($apps_dir | path exists) {
        return []
    }
    
    mut apps = []
    
    # Get apps from JAR files
    try {
        let jars = ls $"($apps_dir)/*.jar"
        for jar in $jars {
            let app_name = ($jar.name | path basename | str replace '.jar' '')
            # Skip libraries
            if not ($app_name | str starts-with 'lib-') {
                $apps = ($apps | append $app_name)
            }
        }
    }
    
    # Get apps from directories (in case JAR is already removed)
    try {
        let dirs = ls $apps_dir | where type == dir
        for dir in $dirs {
            let app_name = ($dir.name | path basename)
            # Skip libraries and avoid duplicates
            if not ($app_name | str starts-with 'lib-') and not ($app_name in $apps) {
                $apps = ($apps | append $app_name)
            }
        }
    }
    
    return $apps
}

# Completion for undeploy-from-local
export extern "undeploy-from-local" [
    app_name?: string@get-deployed-apps  # Application name to undeploy
    --list(-l)                          # List all deployed apps
    --all                                # Remove all deployed apps
    --others                             # Remove all apps except current
    --force(-f)                          # Force removal
    --help                               # Show help message
]