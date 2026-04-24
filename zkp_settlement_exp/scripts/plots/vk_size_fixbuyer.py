from pathlib import Path
import csv
import matplotlib.pyplot as plt

CSV_PATH = Path("results/raw/batch_metrics_50.csv")
OUTPUT_PATH = Path("results/figures/vk_size_fixbuyer_50.png")

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

    fig, axes = plt.subplots(3, 1, figsize=(10, 10), sharex=True, sharey=True)

    found_any = False
    all_y_values = []

    for idx, buyer in enumerate(FIXED_BUYERS):
        ax = axes[idx]

        filtered = [
            row for row in rows
            if row["fixed_role"] == "buyer"
            and int(row["fixed_value"]) == buyer
        ]

        point_map = {
            int(row["nSeller"]): int(row["vk_size_bytes"])
            for row in filtered
        }

        xs = [x for x in X_SELLERS if x in point_map]
        ys = [point_map[x] / (1024 * 1024) for x in xs]

        if xs:
            found_any = True
            all_y_values.extend(ys)

            bars = ax.bar(xs, ys, width=3)

            for bar, y in zip(bars, ys):
                ax.text(
                    bar.get_x() + bar.get_width() / 2,
                    y,
                    f"{y:.5f}",
                    ha="center",
                    va="bottom",
                    fontsize=8,
                )

        ax.set_title(f"Buyer = {buyer}")
        ax.grid(True, axis="y")
        ax.tick_params(labelbottom=True)
        ax.set_xticks(X_SELLERS)

    if not found_any:
        raise ValueError("No data found for fixed buyers.")

    y_min = min(all_y_values)
    y_max = max(all_y_values)
    padding = (y_max - y_min) * 0.5 if y_max > y_min else 0.0005

    for ax in axes:
        ax.set_ylim(y_min - padding, y_max + padding)

    axes[-1].set_xlabel("Number of Sellers")
    fig.text(0.04, 0.5, "Verification Key Size (MB)", va="center", rotation="vertical")

    plt.suptitle("Verification Key Size vs Number of Sellers (Fixed Buyers)", y=0.92)

    plt.savefig(OUTPUT_PATH, bbox_inches="tight")
    plt.close()

    print(f"Saved: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()


