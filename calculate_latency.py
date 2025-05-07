import pandas as pd
import networkx as nx

def analyze_circuit(file_path, primary_inputs, output_prefix):
    """
    Calculates the weighted longest path with duplication penalties
    for a given logic circuit described in a file. 

    """
    
    # read data
    if file_path.endswith('.csv'):
        df = pd.read_csv(file_path)
    else:
        df = pd.read_excel(file_path)

    # clean data
    df_clean = df[["ID", "Input1", "Type", "Input2"]].copy()

    # build graph
    G = nx.DiGraph()
    for _, row in df_clean.iterrows():
        gate_id = str(row["ID"]).strip()
        input1 = str(row["Input1"]).strip()
        input2 = str(row["Input2"]).strip()

        if input1 != '-' and pd.notna(input1):
            G.add_edge(input1, gate_id)
        if input2 != '-' and pd.notna(input2):
            G.add_edge(input2, gate_id)

    # determine gate delays
    gate_delays = {"AND": 13.7, "OR": 19.7, "NOT": 5.23, "XOR": 45.23}

    # calculate number of duplications for each node
    fanout_count = {node: len(list(G.successors(node))) for node in G.nodes}

    # calculate total delays for each node
    for _, row in df_clean.iterrows():
        gate_id = str(row["ID"]).strip()
        gate_type = str(row["Type"]).strip().upper()
        base_delay = gate_delays.get(gate_type, 0)

        # duplication penalty: (fanout - 1) * 0.35 ns
        duplication_penalty = max(fanout_count.get(gate_id, 0) - 1, 0) * 0.35
        effective_delay = base_delay + duplication_penalty

        for input_col in ["Input1", "Input2"]:
            input_node = str(row[input_col]).strip()
            if input_node != '-' and pd.notna(input_node):
                if G.has_edge(input_node, gate_id):
                    G[input_node][gate_id]['weight'] = effective_delay


    # identify output gates
    output_gates = [n for n in G.nodes if str(n).startswith(output_prefix)]

    # solve the weighted longest path problem
    longest_path = []
    max_latency = 0

    for src in primary_inputs:
        if src not in G:
            continue
        for output in output_gates:
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

    return {
        "critical_path": longest_path,
        "total_latency_ns": max_latency,
    }

# implementation for alu
file_path = "ALU_logic_gates.csv"  # Your original table
primary_inputs = ["A0", "B0", "A1", "B1", "A2", "B2", "A3", "B3"]
output_prefix = "13"

result = analyze_circuit(file_path, primary_inputs, output_prefix)

# show results
print(result)
