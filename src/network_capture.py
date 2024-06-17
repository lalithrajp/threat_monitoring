import hashlib
import time
from scapy.all import sniff

# Cache to store packet hashes
packet_cache = {}
cache_duration = 60  # seconds
duplicate_count = 0

def hash_packet(packet):
    """Generate a SHA256 hash for the given packet."""
    hasher = hashlib.sha256()
    hasher.update(bytes(packet))
    return hasher.hexdigest()

def store_packet_hash(packet_hash):
    """Store packet hash in the cache with a timestamp."""
    global packet_cache, duplicate_count
    current_time = time.time()
    clean_cache(current_time)
    if packet_hash not in packet_cache:
        packet_cache[packet_hash] = current_time
        print(f"Stored packet hash: {packet_hash}")
    else:
        duplicate_count += 1
        print(f"Duplicate packet hash detected: {packet_hash}")

def clean_cache(current_time):
    """Clean up old packet hashes from the cache."""
    global packet_cache
    keys_to_remove = [k for k, v in packet_cache.items() if current_time - v > cache_duration]
    for key in keys_to_remove:
        del packet_cache[key]
    print(f"Cleaned cache: {key}")

def packet_callback(packet):
    """Callback function for each captured packet."""
    packet_hash = hash_packet(packet)
    store_packet_hash(packet_hash)

def start_packet_capture(interface, duration=None):
    """Start capturing packets on the specified interface for a given duration."""
    print(f"Starting packet capture on interface: {interface}")
    try:
        if duration:
            sniff(iface=interface, prn=packet_callback, store=False, timeout=duration)
        else:
            sniff(iface=interface, prn=packet_callback, store=False)
    except KeyboardInterrupt:
        print("\nPacket capture interrupted by user")
        display_cache_details()
    print("Packet capture ended")

def display_cache_details():
    """Display the details of packet hashes in the cache."""
    global packet_cache
    print("Packet hashes in cache:")
    for i, (hash_value, timestamp) in enumerate(packet_cache.items(), start=1):
        print(f"{i}. Hash: {hash_value}, Timestamp: {timestamp}")

if __name__ == "__main__":

    # Use the correct interface name obtained from the previous step
    interface_name = "\\Device\\NPF_Loopback"
    
    # Start capturing packets indefinitely, can be stopped with Ctrl+C
    start_packet_capture(interface_name)
