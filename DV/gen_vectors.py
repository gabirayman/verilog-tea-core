import secrets
import os
import sys


# --- TEA Implementation for reference ---
def encrypt(v, k):
    v0, v1 = v[0], v[1]
    delta = 0x9e3779b9
    sum_val = 0
    for _ in range(32):
        sum_val = (sum_val + delta) & 0xFFFFFFFF
        v0 = (v0 + (((v1 << 4) + k[0]) ^ (v1 + sum_val) ^ ((v1 >> 5) + k[1]))) & 0xFFFFFFFF
        v1 = (v1 + (((v0 << 4) + k[2]) ^ (v0 + sum_val) ^ ((v0 >> 5) + k[3]))) & 0xFFFFFFFF
    return [v0, v1]

# def generate_data_file(num_samples):
#     # 1. Write the Verilog Header with the count
#     with open("test_params.vh", "w") as f:
#         f.write(f"`define NUM_TESTS {num_samples}\n")

#     filename = "tea_tests.mem"
#     with open(filename, 'w') as f:
#         for _ in range(num_samples):
#             pt = [secrets.randbits(32), secrets.randbits(32)]
#             key = [secrets.randbits(32) for _ in range(4)]
#             ct = encrypt(pt, key)
            
#             # Concatenate into one big hex string: 128 + 64 + 64 = 256 bits total
#             key_hex = f"{key[0]:08x}{key[1]:08x}{key[2]:08x}{key[3]:08x}"
#             pt_hex  = f"{pt[0]:08x}{pt[1]:08x}"
#             ct_hex  = f"{ct[0]:08x}{ct[1]:08x}"
            
#             f.write(f"{key_hex}{pt_hex}{ct_hex}\n")

#     print(f"Generated {num_samples} test vectors in {filename}")

def generate_data_file(num_samples):
    # --- Location-Aware Path Logic ---
    cwd = os.getcwd()
    
    # Check if we are currently inside the DV folder
    if os.path.basename(cwd) == "DV":
        output_dir = "common"
    # Check if DV exists in our current folder (we are likely at Root)
    elif os.path.exists("DV"):
        output_dir = "DV/common"
    else:
        # Fallback: Just use current directory
        output_dir = "."
        print("WARNING: 'DV' directory not found. Generating files in current directory.")

    # Ensure the directory exists
    if output_dir != "." and not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Define full paths
    header_path = os.path.join(output_dir, "test_params.vh")
    mem_path = os.path.join(output_dir, "tea_tests.mem")

    # 1. Write the Verilog Header
    with open(header_path, "w") as f:
        f.write(f"`define NUM_TESTS {num_samples}\n")

    # 2. Write the .mem file
    with open(mem_path, 'w') as f:
        for _ in range(num_samples):
            pt = [secrets.randbits(32), secrets.randbits(32)]
            key = [secrets.randbits(32) for _ in range(4)]
            # Assuming your encrypt() function is defined above
            ct = encrypt(pt, key)
            
            key_hex = f"{key[0]:08x}{key[1]:08x}{key[2]:08x}{key[3]:08x}"
            pt_hex  = f"{pt[0]:08x}{pt[1]:08x}"
            ct_hex  = f"{ct[0]:08x}{ct[1]:08x}"
            
            f.write(f"{key_hex}{pt_hex}{ct_hex}\n")

    print(f"Generated {num_samples} test vectors.")
    print(f"Target Directory: {os.path.abspath(output_dir)}")

if __name__ == "__main__":
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 10
    generate_data_file(n)