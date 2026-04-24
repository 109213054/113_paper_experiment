from pathlib import Path
import csv
import matplotlib.pyplot as plt

CSV_PATH = Path("results/raw/batch_metrics_50.csv")
OUTPUT_PATH = Path("results/figures/pk_size_fixbuyer_50.png")

FIXED_BUYERS = [10, 20, 30]
X_SELLERS = [5, 10, 15, 20, 25, 30]


def load_csv_rows(csv_path: Path):
    if not csv_path.exists():
        raise FileNotFoundError(f"CSV file not found: {csv_path}")

    rows = []
    with csv_path.open("r", encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)

        required_fields = {
            "phase",
            "fixed_role",
            "fixed_value",
            "nSeller",
            "nBuyer",
            "mode",
            "proof_size_bytes",
            "pk_size_bytes",
            "vk_size_bytes",
            "prove_time_ms_avg",
            "verify_time_ms_avg",
        }

        if reader.fieldnames is None:
            raise ValueError("CSV header is missing.")

        missing = required_fields - set(reader.fieldnames)
        if missing:
            raise ValueError(f"CSV missing required fields: {missing}")

        for row in reader:
            rows.append(row)

    return rows


def main():
    rows = load_csv_rows(CSV_PATH)
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

    plt.figure(figsize=(10, 6))

    found_any = False

    for buyer in FIXED_BUYERS:
        filtered = [
            row for row in rows
            if row["fixed_role"] == "buyer"
            and int(row["fixed_value"]) == buyer
        ]

        point_map = {
            int(row["nSeller"]): int(row["pk_size_bytes"])
            for row in filtered
        }

        xs = [x for x in X_SELLERS if x in point_map]

        # 轉 MB + 保留兩位小數
        ys = [round(point_map[x] / (1024 * 1024), 2) for x in xs]

        if xs:
            found_any = True
            plt.plot(xs, ys, marker="o", linewidth=2, label=f"Buyer = {buyer}")

    if not found_any:
        raise ValueError("No data found for fixed buyers.")

    plt.xlabel("Number of Sellers")
    plt.ylabel("Proving Key Size (MB)")  # 單位為 MB
    plt.title("Proving Key Size vs Number of Sellers (Fixed Buyers)")
    plt.xticks(X_SELLERS)
    plt.grid(True)
    plt.legend()

    plt.savefig(OUTPUT_PATH, bbox_inches="tight")
    plt.close()

    print(f"Saved: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()

