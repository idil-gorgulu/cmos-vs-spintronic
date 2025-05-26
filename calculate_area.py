import os
import json

def calculate_area_from_json(file_path):
    # Constants
    CELL_WIDTH_NM = 300
    CELL_HEIGHT_NM = 300
    CELL_AREA_UM2 = (CELL_WIDTH_NM / 1000) * (CELL_HEIGHT_NM / 1000)  # µm²

    # Load JSON data
    with open(file_path, 'r') as f:
        data = json.load(f)

    blocks = data.get("blocks", [])
    if not blocks:
        return None, None, None, None

    num_rows = len(blocks)
    num_cols = max(len(row) for row in blocks) if num_rows > 0 else 0
    total_cells = num_rows * num_cols
    total_area_um2 = total_cells * CELL_AREA_UM2

    return os.path.basename(file_path), num_rows, num_cols, total_area_um2

def process_subcircuits_folder(folder_path="subcircuits"):
    if not os.path.exists(folder_path):
        print(f"Error: Folder '{folder_path}' does not exist.")
        return

    print(f"{'File':<30} {'Rows':<10} {'Cols':<10} {'Area (µm²)':<12}")
    print("-" * 50)

    for filename in os.listdir(folder_path):
        if filename.endswith(".json"):
            file_path = os.path.join(folder_path, filename)
            result = calculate_area_from_json(file_path)
            if result[0]:
                name, rows, cols, area = result
                print(f"{name:<30} {rows:<10} {cols:<10} {area:<12.2f}")

if __name__ == "__main__":
    process_subcircuits_folder("subcircuits")
