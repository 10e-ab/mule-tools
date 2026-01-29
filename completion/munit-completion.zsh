#compdef munit

# Zsh completion for munit command

# Extract test names from an MUnit XML file
_munit_get_test_names() {
    local file="$1"
    if [[ -f "$file" ]]; then
        # Extract test names from munit:test name="..." attributes
        sed -n 's/.*<munit:test[^>]*name="\([^"]*\)".*/\1/p' "$file" 2>/dev/null
    fi
}

_munit() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    local munit_dir="src/test/munit"

    _arguments -C \
        '(-h --help)'{-h,--help}'[Display help and exit]' \
        '(-s --stale)'{-s,--stale}'[Run tests for files modified since last commit]' \
        '*:test file:->testfiles'

    case $state in
        testfiles)
            local -a completions

            # Check if we're in a Mule project with munit tests
            if [[ -d "$munit_dir" ]]; then
                # Check if user is typing a test name after file#
                if [[ "$words[CURRENT]" == *"#"* ]]; then
                    local file_part="${words[CURRENT]%%#*}"
                    local full_path="${munit_dir}/${file_part}"

                    if [[ -f "$full_path" ]]; then
                        local test_names
                        test_names=($(_munit_get_test_names "$full_path"))
                        for test_name in $test_names; do
                            completions+=("${file_part}#${test_name}:test in ${file_part}")
                        done
                    fi
                else
                    # Add test files with test count
                    for file in "$munit_dir"/*.xml(N); do
                        if [[ -f "$file" ]]; then
                            local filename="${file:t}"
                            local test_names
                            test_names=($(_munit_get_test_names "$file"))
                            local test_count=${#test_names[@]}

                            # Add the file itself
                            completions+=("${filename}:${test_count} tests")

                            # Add individual tests
                            for test_name in $test_names; do
                                completions+=("${filename}#${test_name}:test in ${filename}")
                            done
                        fi
                    done
                fi

                _describe -t tests 'MUnit tests' completions
            fi
            ;;
    esac
}

_munit "$@"
