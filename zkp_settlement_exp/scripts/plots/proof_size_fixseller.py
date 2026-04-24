from pathlib import Path
import csv
import matplotlib.pyplot as plt

CSV_PATH = Path("results/raw/batch_metrics_50.csv")
OUTPUT_PATH = Path("results/figures/proof_size_fixseller_50.png")

FIXED_SELLERS = [10, 20, 30]
X_BUYERS = [5, 10, 15, 20, 25, 30]


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

    fig, axes = plt.subplots(3, 1, figsize=(10, 10), sharex=True, sharey=True)

    found_any = False

    for idx, seller in enumerate(FIXED_SELLERS):
        ax = axes[idx]

        filtered = [
            row for row in rows
            if row["fixed_role"] == "seller"
            and int(row["fixed_value"]) == seller
        ]

        point_map = {
            int(row["nBuyer"]): int(row["proof_size_bytes"])
            for row in filtered
        }

        xs = [x for x in X_BUYERS if x in point_map]
        ys = [point_map[x] for x in xs]

        if xs:
            found_any = True

            ax.plot(xs, ys, marker="o")

            # mean 線
            mean_val = sum(ys) / len(ys)
            ax.axhline(mean_val, linestyle="--", linewidth=1)

        ax.set_title(f"Seller = {seller}")
        ax.grid(True)

        # 每張圖都顯示 x 軸刻度
        ax.tick_params(labelbottom=True)

    if not found_any:
        raise ValueError("No data found for fixed sellers.")

    # 固定 y 軸範圍
    y_min = 790
    y_max = 830

    for ax in axes:
        ax.set_ylim(y_min, y_max)
        ax.set_yticks(list(range(y_min, y_max + 1, 5)))

    # 每張圖都設 x ticks
    for ax in axes:
        ax.set_xticks(X_BUYERS)

    axes[-1].set_xlabel("Number of Buyers")
    fig.text(0.04, 0.5, "Proof Size (bytes)", va='center', rotation='vertical')

    plt.suptitle("Proof Size vs Number of Buyers (Fixed Sellers)", y=0.92)

    plt.savefig(OUTPUT_PATH, bbox_inches="tight")
    plt.close()

    print(f"Saved: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()


