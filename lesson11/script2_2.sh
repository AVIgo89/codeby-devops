#!/bin/bash
# Script to create myfolder with 5 test files in user's home directory

# Constants
readonly TARGET_DIR="/home/user/DevOps/codeby-devops/lesson11/myfolder"
readonly FILE1="${TARGET_DIR}/file1.txt"
readonly FILE2="${TARGET_DIR}/file2.txt"
readonly FILE3="${TARGET_DIR}/file3.txt"
readonly FILE4="${TARGET_DIR}/file4.txt"
readonly FILE5="${TARGET_DIR}/file5.txt"
readonly FILE2_PERMISSIONS=777
readonly RANDOM_STR_LENGTH=20

# Function to generate random alphanumeric string
generate_random_string() {
    local length=$1
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "${length}"
    return 0
}

# Main execution
main() {
    # Create target directory if it doesn't exist
    mkdir -p "${TARGET_DIR}" || {
        echo "Error: Failed to create directory ${TARGET_DIR}" >&2
        return 1
    }

    # File 1: Contains greeting and current timestamp
    {
        echo "Hello, World!"
        date
    } > "${FILE1}" || {
        echo "Error: Failed to write ${FILE1}" >&2
        return 1
    }

    # File 2: Empty file with 777 permissions
    touch "${FILE2}" || {
        echo "Error: Failed to create ${FILE2}" >&2
        return 1
    }
    chmod "${FILE2_PERMISSIONS}" "${FILE2}" || {
        echo "Error: Failed to set permissions on ${FILE2}" >&2
        return 1
    }

    # File 3: Single line with random characters
    local random_str
    random_str=$(generate_random_string "${RANDOM_STR_LENGTH}")
    echo "${random_str}" > "${FILE3}" || {
        echo "Error: Failed to write ${FILE3}" >&2
        return 1
    }

    # Files 4-5: Empty files
    touch "${FILE4}" "${FILE5}" || {
        echo "Error: Failed to create files 4-5" >&2
        return 1
    }

    echo "Success: Directory ${TARGET_DIR} created with all files."
    return 0
}

# Execute main function
main "$@"
exit $?
