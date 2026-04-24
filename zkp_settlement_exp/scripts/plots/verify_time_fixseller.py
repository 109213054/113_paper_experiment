from pathlib import Path
import csv
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

CSV_PATH = Path("results/raw/batch_metrics_50.csv")
OUTPUT_PATH = Path("results/figures/verify_time_fixseller_50.png")

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
    all_y_values = []

    for idx, seller in enumerate(FIXED_SELLERS):
        ax = axes[idx]

        filtered = [
            row for row in rows
            if row["fixed_role"] == "seller"
            and int(row["fixed_value"]) == seller
        ]

        point_map = {
            int(row["nBuyer"]): float(row["verify_time_ms_avg"]) / 1000
            for row in filtered
        }

        xs = [x for x in X_BUYERS if x in point_map]
        ys = [point_map[x] for x in xs]

        if xs:
            found_any = True
            all_y_values.extend(ys)

            ax.plot(xs, ys, marker="o", linewidth=2)

            mean_val = sum(ys) / len(ys)
            ax.axhline(mean_val, linestyle="--", linewidth=1)

            for x, y in zip(xs, ys):
                ax.text(x, y, f"{y:.4f}", fontsize=8, ha="center", va="bottom")

        ax.set_title(f"Seller = {seller}")
        ax.tick_params(labelbottom=True)
        ax.set_xticks(X_BUYERS)

    if not found_any:
        raise ValueError("No data found.")

    y_min = 0.275
    y_max = 0.350

    for ax in axes:
        ax.set_ylim(y_min, y_max)
        ax.yaxis.set_major_locator(ticker.MultipleLocator(0.01))

        ax.grid(True, axis="y", linestyle="--", linewidth=0.5)

    axes[-1].set_xlabel("Number of Buyers")
    fig.text(0.04, 0.5, "Average Verification Time (s)", va="center", rotation="vertical")

    plt.suptitle("Average Verification Time vs Number of Buyers (Fixed Sellers)", y=0.92)

    plt.savefig(OUTPUT_PATH, bbox_inches="tight")
    plt.close()

    print(f"Saved: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()


