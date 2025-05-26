import pandas as pd

# Define energy per operation in joules (maximum values from table)
ENERGY_TABLE = {
    "AND": 2.59e-18,
    "OR": 5.10e-18,
    "NOT": 5.20e-18,
    "XNOR": 9.60e-18,
    "XOR": 9.60e-18 + 5.20e-18,  # XNOR + inverter
    "BUF": 0.0,  # Assume buffer has negligible switching energy
    "NAND": 5.50e-18,
    "NOR": 2.98e-18
}

# Clock period in seconds (40 ns)
CLOCK_PERIOD = 40e-9

def calculate_power(csv_path):
    df = pd.read_csv(csv_path)

    total_energy = 0.0

    for _, row in df.iterrows():
        gate_type = str(row["Type"]).strip().upper()
        energy = ENERGY_TABLE.get(gate_type, 0.0)
        total_energy += energy

    average_power = total_energy / CLOCK_PERIOD  # P = E / T
    average_power_nanowatts = average_power * 1e9

    print(f"File: {csv_path}")
    print(f"Total energy: {total_energy:.2e} J")
    print(f"Average power: {average_power_nanowatts:.2f} nW")
    return average_power_nanowatts

# Example usage
if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python calculate_power.py <path_to_csv>")
    else:
        calculate_power(sys.argv[1])
