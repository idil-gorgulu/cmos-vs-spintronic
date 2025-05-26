import pandas as pd

def generate_mux_csv(n, filename):
    """
    Generates a logic-level CSV representation of an n-to-1 multiplexer
    using 2x1 MUX trees built from AND, OR, NOT gates.
    """
    assert n >= 2 and (n & (n - 1)) == 0
    inputs = [f"I{i}" for i in range(n)]
    selectors = [f"S{i}" for i in range((n-1).bit_length())]

    gates = []
    gate_id = 1
    buf_id = 1

    def build_mux_tree(inp_list, sel_index):
        nonlocal gate_id
        nonlocal gates

        if len(inp_list) == 1:
            return inp_list[0]

        left = build_mux_tree(inp_list[:len(inp_list)//2], sel_index + 1)
        right = build_mux_tree(inp_list[len(inp_list)//2:], sel_index + 1)

        not_id = f"G{gate_id}"; gate_id += 1
        gates.append({"ID": not_id, "Input1": selectors[sel_index], "Type": "NOT", "Input2": "-"})

        and1_id = f"G{gate_id}"; gate_id += 1
        gates.append({"ID": and1_id, "Input1": left, "Type": "AND", "Input2": not_id})

        and2_id = f"G{gate_id}"; gate_id += 1
        gates.append({"ID": and2_id, "Input1": right, "Type": "AND", "Input2": selectors[sel_index]})

        or_id = f"G{gate_id}"; gate_id += 1
        gates.append({"ID": or_id, "Input1": and1_id, "Type": "OR", "Input2": and2_id})

        return or_id

    final_output = build_mux_tree(inputs, 0)
    gates.append({"ID": "Y", "Input1": final_output, "Type": "BUF", "Input2": "-"})

    df = pd.DataFrame(gates)
    df.to_csv(filename, index=False)
    print(f"Saved {filename}")

# Generate the MUX files
#generate_mux_csv(4, "4x1mux.csv")
#generate_mux_csv(8, "8x1mux.csv")
#generate_mux_csv(16, "16x1mux.csv")
generate_mux_csv(32, "32x1mux.csv")
generate_mux_csv(64, "64x1mux.csv")