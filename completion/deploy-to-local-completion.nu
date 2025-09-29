# Nushell completion for deploy-to-local

# Get list of available Mule applications
def get-mule-apps [] {
    if ($env.MULE_PROJECTS_HOME? | is-empty) {
        return []
    }
    
    let projects_dir = $env.MULE_PROJECTS_HOME
    
    if not ($projects_dir | path exists) {
        return []
    }
    
    # Find all directories with pom.xml that have mule-application packaging
    ls $projects_dir 
    | where type == dir 
    | get name
    | each { |dir|
        let pom_file = $"($dir)/pom.xml"
        if ($pom_file | path exists) {
            # Check if it's a Mule application
            let content = open $pom_file
            if ($content | str contains "<packaging>mule-application</packaging>") {
                $dir | path basename
            }
        }
    }
    | compact
}

# Completion for deploy-to-local
export extern "deploy-to-local" [
    app_name?: string@get-mule-apps  # Application name to deploy
    --list(-l)                        # List available applications
    --help(-h)                        # Show help message
]