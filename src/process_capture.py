import psutil
import hashlib
import time

hash_cache = {}
cache_duration = 60  # seconds

def capture_process():
    global hash_cache
    processes = psutil.process_iter(['pid', 'name', 'exe'])
    for process in processes:
        try:
            exe_path = process.info['exe']
            print("Process:",exe_path)
            if exe_path and 'exe' in exe_path:
                hash_value = hash_executable(exe_path)
                print(hash_value)
                store_hash(hash_value)
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass

def hash_executable(exe_path):
    try:
        hasher = hashlib.sha256()
        with open(exe_path, 'rb') as exe_file:
            buf = exe_file.read()
            hasher.update(buf)
        return hasher.hexdigest()
    except FileNotFoundError:
        return None

def store_hash(hash_value):
    global hash_cache
    current_time = time.time()
    clean_cache(current_time)
    if hash_value not in hash_cache:
        hash_cache[hash_value] = (current_time, 1)
        print("Hash not in cache, storing ")
    else:
        hash_cache[hash_value] = (hash_cache[hash_value][0], hash_cache[hash_value][1] + 1)
        print("Hash already in cache, updating")

def clean_cache(current_time):
    global hash_cache
    keys_to_remove = [k for k, v in hash_cache.items() if current_time - v[0] > cache_duration]
    print("Remove key")
    for key in keys_to_remove:
        del hash_cache[key]

def manual_clean_cache():
    clean_cache(time.time())

def is_in_cache(hash_value):
    print("is in cache", hash_value in hash_cache)
    return hash_value in hash_cache

def get_cache_count(hash_value):
    if hash_value in hash_cache:
        print("hash_count", hash_cache[hash_value][1])
        return hash_cache[hash_value][1]
    return 0

def reset_cache():
    global hash_cache
    hash_cache = {}

if __name__ == "__main__":
    capture_process()
    print("hash_cache",hash_cache)
