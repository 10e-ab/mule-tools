#!/bin/bash

echo "Setting up bash completion for deploy-to-local and undeploy-from-local..."

DEPLOY_COMPLETION="$HOME/bin/deploy-to-local-completion.bash"
UNDEPLOY_COMPLETION="$HOME/bin/undeploy-from-local-completion.bash"

if [ ! -f "$DEPLOY_COMPLETION" ]; then
    echo "Error: Deploy completion file not found at $DEPLOY_COMPLETION"
    exit 1
fi

if [ ! -f "$UNDEPLOY_COMPLETION" ]; then
    echo "Error: Undeploy completion file not found at $UNDEPLOY_COMPLETION"
    exit 1
fi

# Detect shell configuration file
if [ -f "$HOME/.bash_profile" ]; then
    SHELL_RC="$HOME/.bash_profile"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ] && [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
else
    echo "Could not find shell configuration file (.bash_profile, .bashrc, or .zshrc)"
    echo ""
    echo "Please manually add these lines to your shell configuration:"
    echo "source $DEPLOY_COMPLETION"
    echo "source $UNDEPLOY_COMPLETION"
    exit 1
fi

# Check and add deploy completion
if ! grep -q "deploy-to-local-completion.bash" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# Bash completion for deploy-to-local" >> "$SHELL_RC"
    echo "[ -f $DEPLOY_COMPLETION ] && source $DEPLOY_COMPLETION" >> "$SHELL_RC"
    echo "Added deploy-to-local completion to $SHELL_RC"
else
    echo "deploy-to-local completion already set up"
fi

# Check and add undeploy completion
if ! grep -q "undeploy-from-local-completion.bash" "$SHELL_RC" 2>/dev/null; then
    echo "# Bash completion for undeploy-from-local" >> "$SHELL_RC"
    echo "[ -f $UNDEPLOY_COMPLETION ] && source $UNDEPLOY_COMPLETION" >> "$SHELL_RC"
    echo "Added undeploy-from-local completion to $SHELL_RC"
else
    echo "undeploy-from-local completion already set up"
fi

echo ""
echo "To enable immediately, run:"
echo "  source $DEPLOY_COMPLETION"
echo "  source $UNDEPLOY_COMPLETION"
echo ""
echo "Or restart your terminal."