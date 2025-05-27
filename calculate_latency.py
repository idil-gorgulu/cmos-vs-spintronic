import pandas as pd
import networkx as nx
import sys

def get_gate_delays():
    return {
        "AND": 13.7,
        "OR": 19.7,
        "NOT": 5.23,
        "XOR": 45.23,
        "XNOR": 45.23 + 5.23,
        "BUF": 0.0  # Assume buffer has no delay
    }

def build_graph(df):
    G = nx.DiGraph()
    for _, row in df.iterrows():
        gate_id = str(row["ID"]).strip()
        input1 = str(row["Input1"]).strip()
        input2 = str(row["Input2"]).strip()

        if input1 != '-' and pd.notna(input1):
            G.add_edge(input1, gate_id)
        if input2 != '-' and pd.notna(input2):
            G.add_edge(input2, gate_id)
    return G

def apply_delays(df, G):
    gate_delays = get_gate_delays()
    fanout_count = {node: len(list(G.successors(node))) for node in G.nodes}

    for _, row in df.iterrows():
        gate_id = str(row["ID"]).strip()
        gate_type = str(row["Type"]).strip().upper()
        base_delay = gate_delays.get(gate_type, 0)
        duplication_penalty = max(fanout_count.get(gate_id, 0) - 1, 0) * 0.35
        effective_delay = base_delay + duplication_penalty

        for input_col in ["Input1", "Input2"]:
            input_node = str(row[input_col]).strip()
            if input_node != '-' and pd.notna(input_node):
                if G.has_edge(input_node, gate_id):
                    G[input_node][gate_id]['weight'] = effective_delay

def longest_path_latency(G, primary_inputs, output_nodes):
    longest_path = []
    max_latency = 0.0

    for src in primary_inputs:
        if src not in G:
            continue
        for output in output_nodes:
            if nx.has_path(G, src, output):
                try:
                    subgraph = G.subgraph(nx.descendants(G, src) | {src})
                    path = nx.dag_longest_path(subgraph, weight='weight')
                    latency = sum(subgraph[path[i]][path[i + 1]]['weight'] for i in range(len(path) - 1))
                    if latency > max_latency:
                        longest_path = path
                        max_latency = latency
                except nx.NetworkXNoPath:
                    continue
    return longest_path, max_latency

def analyze_circuit(file_path):
    df = pd.read_csv(file_path)
    df_clean = df[["ID", "Input1", "Type", "Input2"]].copy()
    G = build_graph(df_clean)
    apply_delays(df_clean, G)

    all_nodes = list(G.nodes)

    if "A0" in all_nodes and "B0" in all_nodes:
        # Likely an adder
        primary_inputs = sorted([n for n in all_nodes if n.startswith("A") or n.startswith("B") or n == "Cin"])
        output_nodes = [n for n in all_nodes if n.startswith("SUM") or n.startswith("C")]
    elif any(n.startswith("I") for n in all_nodes):
        # Likely a multiplexer
        primary_inputs = [n for n in all_nodes if n.startswith("I")]
        output_nodes = [n for n in all_nodes if n == "Y"]
    else:
        # Default to ALU-style fixed naming
        primary_inputs = ["A0", "B0", "A1", "B1", "A2", "B2", "A3", "B3"]
        output_nodes = [n for n in all_nodes if str(n).startswith("13")]

    path, latency = longest_path_latency(G, primary_inputs, output_nodes)

    print(f"File: {file_path}")
    print(f"Primary Inputs: {primary_inputs}")
    print(f"Output Nodes: {output_nodes}")
    print(f"Critical Path: {path}")
    print(f"Total Latency: {latency:.2f} ns\n")

    return {
        "critical_path": path,
        "total_latency_ns": latency
    }

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python calculate_latency.py <path_to_csv>")
    else:
        analyze_circuit(sys.argv[1])
