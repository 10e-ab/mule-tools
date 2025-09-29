# Nushell completion for munit command

# Get list of MUnit test files
def "get-munit-tests" [] {
    let munit_dir = "src/test/munit"

    if not ($munit_dir | path exists) {
        return []
    }

    mut tests = []

    # Get all XML files in the munit directory
    try {
        let files = ls $munit_dir | where name =~ '\.xml$'
        for file in $files {
            let test_name = ($file.name | path basename)
            $tests = ($tests | append $test_name)
        }
    } catch {
        # Return empty list if no files found
        return []
    }

    return $tests
}

# Completion for munit
# Note: Due to Nushell limitations, custom completion only works for the first test file
# Additional files can be typed manually or copy-pasted
export extern "munit" [
    ...test_files: string@"get-munit-tests"  # MUnit test files (completion works for first file only)
    --help(-h)                               # Show help message
    --version                                 # Show version
    --stale(-s)                               # Run tests for files modified since last commit
]