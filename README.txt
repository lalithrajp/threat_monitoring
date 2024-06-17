Threat Monitoring Script

Version requirement: Python 3.8 or higher
Packages: pip install -r requirements.txt

Script Execution: python src/process_capture.py
                  python src/network_capture.py
Test Execution:   robot tests/

Notes:

- The `process_capture.py` script captures running processes, hashes their executables and caches these hashes for 60 seconds to prevent redundant data storage.
- The `network_capture.py` script captures packets through selected interface, hashes their executables and caches these hashes for 60 seconds to prevent redundant data storage.
- The Robot Framework tests verify that the process capture and caching mechanisms work as expected.
