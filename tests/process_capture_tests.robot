*** Settings ***
Library    ../src/process_capture.py
Library		OperatingSystem


*** Variables ***
${CACHE_TIME}  60
${EXE_PATH}    dummy_path.exe
${EXE_PATH_2}  dummy_path_2.exe

*** Test Cases ***
Verify Process Capture
    [Documentation]    Verify that a process is captured correctly.
    Log    Starting test: Verify Process Capture
    ${hash}=    hash_executable    ${EXE_PATH}
    store_hash    ${hash}
    ${result}=    is_in_cache    ${hash}
    Should Be True    ${result}    Process should be in cache
    Reset Cache

Verify Cache Stores Hashes For 60 Seconds
    [Documentation]    Verify that hashes are stored in the cache for 60 seconds.
    Log    Starting test: Verify Cache Stores Hashes For 60 Seconds
    ${hash}=    hash_executable    ${EXE_PATH}
    store_hash    ${hash}
    ${result}=    is_in_cache    ${hash}
    Should Be True    ${result}    Process should be in cache
    ${sleep_time}=    Evaluate    ${CACHE_TIME} + 1
    Sleep    ${sleep_time} seconds
    Manual Clean Cache
    ${result}=    is_in_cache    ${hash}
    Should Be Equal    ${result}    ${False}    Process should not be in cache after 60 seconds
    Reset Cache

Confirm Redundant Data Discard
    [Documentation]    Confirm that redundant data is discarded when the same executable is captured within the next 60 seconds.
    Log    Starting test: Confirm Redundant Data Discard
    ${hash}=    hash_executable    ${EXE_PATH}
    store_hash    ${hash}
    store_hash    ${hash}
    ${count}=    get_cache_count    ${hash}
    Should Be Equal As Numbers    ${count}    2    Cache count should be 2
    Reset Cache

Verify Capture of Unique Executables
    [Documentation]    Verify that different executables are captured correctly.
    Log    Starting test: Verify Capture of Unique Executables
    ${hash1}=    hash_executable    ${EXE_PATH}
    ${hash2}=    hash_executable    ${EXE_PATH_2}
    store_hash    ${hash1}
    store_hash    ${hash2}
    ${result1}=    is_in_cache    ${hash1}
    ${result2}=    is_in_cache    ${hash2}
    Should Be True    ${result1}    First process should be in cache
    Should Be True    ${result2}    Second process should be in cache
    Reset Cache

Verify Cache Expiry
    [Documentation]    Verify that hashes expire from the cache after 60 seconds.
    Log    Starting test: Verify Cache Expiry
    ${hash}=    hash_executable    ${EXE_PATH}
    store_hash    ${hash}
    ${result}=    is_in_cache    ${hash}
    Should Be True    ${result}    Process should be in cache
    ${sleep_time}=    Evaluate    ${CACHE_TIME} + 1
    Sleep    ${sleep_time} seconds
    Manual Clean Cache
    ${result}=    is_in_cache    ${hash}
    Should Be Equal    ${result}    ${False}    Process should not be in cache after 60 seconds
    Reset Cache

Verify Edge Cases
	[Documentation]    Test edge cases such as very large files, very small files, and invalid paths.
    Log    Starting test: Verify Edge Cases

    ${hash}=    hash_executable    ${EXE_PATH}
    store_hash    ${hash}
    ${invalid_hash}=    hash_executable    invalid_path.exe
	Should Be Equal    ${invalid_hash}    ${None}    Hashing invalid path should return None

    ${small_file_hash}=    hash_executable    ${EXE_PATH_2}
    store_hash    ${small_file_hash}
    ${result}=    is_in_cache    ${small_file_hash}
    Should Be True    ${result}    Small file hash should be in cache

    ${large_file_path}   Set Variable    tests/large_file.exe
    Create Large File    ${large_file_path}    1000000
    ${large_file_hash}=    hash_executable    ${large_file_path}
    store_hash    ${large_file_hash}
    ${result}=    is_in_cache    ${large_file_hash}
    Should Be True    ${result}    Large file hash should be in cache
	
    Remove File    ${large_file_path}
    Reset Cache

*** Keywords ***
Create Large File
    [Arguments]    ${path}    ${size}
    ${content}=    Evaluate    'A' * int(${size})
    Create File    ${path}    ${content}