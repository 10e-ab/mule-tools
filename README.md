# Mule Tools

A collection of command-line tools to enhance MuleSoft development workflow, including automated testing, deployment, and notification capabilities.

## Project Structure

```
mule-tools/
├── bin/                                      # Executable scripts
│   ├── munit                                # Enhanced MUnit test runner
│   ├── deploy-to-local                      # Deploy apps to local runtime
│   └── undeploy-from-local                  # Remove deployed apps
└── completion/                               # Shell completion files
    ├── deploy-to-local-completion-setup.sh  # Setup script for deploy completion
    ├── deploy-to-local-completion.bash      # Bash completion for deploy
    ├── deploy-to-local-completion.nu        # Nushell completion for deploy
    ├── munit-completion.bash                # Bash completion for munit
    ├── munit-completion.nu                  # Nushell completion for munit
    ├── undeploy-from-local-completion.bash  # Bash completion for undeploy
    └── undeploy-from-local-completion.nu    # Nushell completion for undeploy
```

## Tools Overview

- **munit** - Enhanced MUnit test runner with support for multiple tests and change detection
- **deploy-to-local** - Deploy Mule applications to local runtime server
- **undeploy-from-local** - Remove deployed applications from local runtime server

All tools include built-in support for desktop notifications when used with **mule-reactor-notifier** (available at [mule-reactor](https://github.com/your-username/mule-reactor))

## Prerequisites

- Ruby (for munit command)
- Bash shell
- Maven
- MuleSoft Anypoint Studio or Mule Runtime

### Required Environment Variables

```bash
# Mule runtime server location (required for deploy/undeploy)
export MULE_SERVER_HOME="/path/to/mule-runtime"

# Mule projects directory (optional, for app name completion)
export MULE_PROJECTS_HOME="/path/to/mule/projects"

# Mule installation (optional, for clear-data functionality)
export MULE_HOME="/path/to/mule/installation"
```

## Installation

1. **Clone or copy the tools to your system:**
   ```bash
   # Add the bin directory to your PATH
   export PATH="$HOME/projects/mule-tools/bin:$PATH"
   ```

2. **Install shell completions (optional but recommended):**

   ### Bash Completions
   ```bash
   # Add to ~/.bashrc or ~/.bash_profile
   source ~/projects/mule-tools/completion/munit-completion.bash
   source ~/projects/mule-tools/completion/deploy-to-local-completion.bash
   source ~/projects/mule-tools/completion/undeploy-from-local-completion.bash
   ```

   ### Nushell Completions
   ```bash
   # Copy completion files to Nushell config directory
   cp ~/projects/mule-tools/completion/*.nu ~/.config/nushell/completions/

   # Add to ~/.config/nushell/config.nu
   source ~/.config/nushell/completions/munit-completion.nu
   source ~/.config/nushell/completions/deploy-to-local-completion.nu
   source ~/.config/nushell/completions/undeploy-from-local-completion.nu
   ```

3. **Make scripts executable (if not already):**
   ```bash
   chmod +x ~/projects/mule-tools/bin/munit
   chmod +x ~/projects/mule-tools/bin/deploy-to-local
   chmod +x ~/projects/mule-tools/bin/undeploy-from-local
   ```

4. **Install the notifier (optional, for desktop notification support):**

   All mule-tools commands have built-in notification support that integrates with mule-reactor-notifier. To enable desktop notifications for build results, test outcomes, and deployment status, install the notifier from the [mule-reactor repository](https://github.com/your-username/mule-reactor#installation).

## Command Documentation

### munit

Enhanced MUnit test runner with smart test detection and multiple file support.

#### Usage
```bash
# Run all tests
munit

# Run specific test file
munit test-suite.xml

# Run multiple test files
munit test1.xml test2.xml test3.xml

# Run tests for modified files since last commit
munit --stale
munit -s

# Run a specific test file
munit test-suite.xml
```

#### Options
- `-h, --help` - Display help and exit
- `-s, --stale` - Run tests for files modified since last commit

#### Features
- **Multiple test support**: Run several test files in one command
- **Smart completion**: Tab completion shows available test files from `src/test/munit/`
- **Change detection**: `--stale` flag automatically runs tests for modified files
- **Implementation mapping**: Automatically finds test files for modified implementation files
  - Maps `implementation.xml` → `implementation-test-suite.xml` or `implementation-suite.xml`

#### Examples
```bash
# Run tests for recent changes
munit --stale

# Run specific tests
munit health-test-suite.xml api-test-suite.xml

# Run all tests matching a pattern (uses regex)
munit "*api*.xml"
```

### deploy-to-local

Deploy Mule applications to your local runtime server.

#### Usage
```bash
# Deploy current directory's application
deploy-to-local

# Deploy specific application by name
deploy-to-local my-app

# List available and deployed applications
deploy-to-local --list
deploy-to-local -l
```

#### Options
- `-l, --list` - List available and deployed applications
- `-h, --help` - Show help message

#### Features
- **Smart detection**: Automatically finds and deploys the JAR from `target/` directory
- **Application name support**: Deploy by app name using `$MULE_PROJECTS_HOME`
- **Property file management**: Copies `local.properties` if present
- **Desktop notifications**: Notifies on deployment success/failure
- **Status listing**: Shows which apps are available vs deployed

#### Examples
```bash
# Deploy from current directory
cd ~/projects/my-mule-app
deploy-to-local

# Deploy by name from anywhere
deploy-to-local customer-api

# Check deployment status
deploy-to-local --list
```

### undeploy-from-local

Remove deployed Mule applications from your local runtime server.

#### Usage
```bash
# Undeploy current directory's application
undeploy-from-local

# Undeploy specific application
undeploy-from-local my-app

# Remove all deployed applications
undeploy-from-local --all

# List deployed applications
undeploy-from-local --list
undeploy-from-local -l
```

#### Options
- `-l, --list` - List all deployed apps with their status
- `--all` - Remove all deployed applications
- `--others` - Remove all apps except the current one
- `-f, --force` - Force removal (delete anchor, wait, then delete folder)
- `-F, --force-all` - Force removal with rm -rf (more aggressive)
- `-c, --clear-data` - Clear app data from `$MULE_SERVER_HOME/.mule`
- `-h, --help` - Show help message

#### Features
- **Smart undeployment**: Removes JAR, anchor files, and optionally app folders
- **Force modes**: Regular and aggressive force removal options
- **Data cleanup**: Option to clear app data from `.mule` directory
- **Batch operations**: Remove all or all-except-current apps
- **Safety checks**: Validates paths before removal

#### Examples
```bash
# Undeploy current app
undeploy-from-local

# Force undeploy with data cleanup
undeploy-from-local my-app -f -c

# Remove all apps except current
undeploy-from-local --others

# Aggressive removal of stuck app
undeploy-from-local problematic-app -F
```

## Shell Completion

### Bash
Tab completion is available for all commands:
- **munit**: Completes test file names from `src/test/munit/`, supports multiple selections
- **deploy-to-local**: Completes application names from `$MULE_PROJECTS_HOME`
- **undeploy-from-local**: Completes deployed application names

### Nushell
Full completion support for all commands:
- **munit**: Completes test file names from `src/test/munit/`
- **deploy-to-local**: Completes application names from `$MULE_PROJECTS_HOME`
- **undeploy-from-local**: Completes deployed application names

## Troubleshooting

### Environment Variables Not Set
```bash
# Check if variables are set
echo $MULE_SERVER_HOME
echo $MULE_PROJECTS_HOME

# Set them in your shell profile
export MULE_SERVER_HOME="/Applications/mule-runtime-4.x"
export MULE_PROJECTS_HOME="$HOME/projects/mule"
```

### Completion Not Working
```bash
# Reload bash completions
source ~/.bashrc

# For Nushell, restart the shell or reload config
source $nu.config-path
```

### Permission Denied
```bash
# Make scripts executable
chmod +x ~/projects/mule-tools/bin/*
```

### Notifications Not Working
```bash
# Check if notifier is accessible
which mule-reactor-notifier

# Ensure it's in PATH or linked
ln -s ~/projects/mule-reactor/mule-reactor-notifier /usr/local/bin/
```

## Contributing

These tools are designed to be simple and extensible. Feel free to modify them for your specific needs.

## License

These tools are provided as-is for MuleSoft development productivity.