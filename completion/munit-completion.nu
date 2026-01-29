# Nushell completion for munit command

# Extract test names from an MUnit XML file
def "get-test-names-from-file" [file: string] {
    if not ($file | path exists) {
        return []
    }

    # Read file and extract test names from munit:test name="..." attributes
    try {
        open --raw $file
        | lines
        | where $it =~ '<munit:test'
        | each { |line|
            $line | parse -r 'name="(?P<name>[^"]+)"' | get name | first
        }
        | flatten
    } catch {
        []
    }
}

# Get list of MUnit test files and individual tests
def "get-munit-tests" [] {
    let munit_dir = "src/test/munit"

    if not ($munit_dir | path exists) {
        return []
    }

    mut completions = []

    try {
        let files = ls $munit_dir | where name =~ '\.xml$'
        for file in $files {
            let filename = ($file.name | path basename)
            let test_names = (get-test-names-from-file $file.name)
            let test_count = ($test_names | length)

            # Add the file itself
            $completions = ($completions | append {value: $filename, description: $"($test_count) tests"})

            # Add individual tests for this file (file#testName format)
            for test_name in $test_names {
                $completions = ($completions | append {value: $"($filename)#($test_name)", description: $"test in ($filename)"})
            }
        }
    } catch {
        return []
    }

    $completions
}

# Completion for munit
# Run MUnit tests for Mule applications
#
# Examples:
#   munit                           - Run all tests
#   munit test-suite.xml            - Run specific test suite
#   munit test-suite.xml#testName   - Run specific test within suite
#   munit test1.xml test2.xml       - Run multiple test suites
#   munit -s                        - Run tests for modified files
#   munit -h                        - Show detailed help
#
# Note: Type file.xml# and press Tab to see available test names within that file
export extern "munit" [
    ...test_files: string@"get-munit-tests"  # MUnit test files - supports file.xml or file.xml#testName syntax
    --stale(-s)                              # Run tests for files modified since last commit
]