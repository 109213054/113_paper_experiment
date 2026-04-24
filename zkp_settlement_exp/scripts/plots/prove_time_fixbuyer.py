from pathlib import Path
import csv
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

CSV_PATH = Path("results/raw/batch_metrics_50.csv")
OUTPUT_PATH = Path("results/figures/prove_time_fixbuyer_50.png")

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

    for idx, buyer in enumerate(FIXED_BUYERS):
        ax = axes[idx]

        filtered = [
            row for row in rows
            if row["fixed_role"] == "buyer"
            and int(row["fixed_value"]) == buyer
        ]

        point_map = {
            int(row["nSeller"]): float(row["prove_time_ms_avg"]) / 1000
            for row in filtered
        }

        xs = [x for x in X_SELLERS if x in point_map]
        ys = [point_map[x] for x in xs]

        if xs:
            found_any = True

            ax.plot(xs, ys, marker="o", linewidth=2)

            for x, y in zip(xs, ys):
                ax.text(
                    x,
                    y,
                    f"{y:.3f}",
                    fontsize=8,
                    ha="center",
                    va="bottom",
                )

        ax.set_title(f"Buyer = {buyer}")
        ax.tick_params(labelbottom=True)
        ax.set_xticks(X_SELLERS)

    if not found_any:
        raise ValueError("No data found for fixed buyers.")

    y_min = 0.9
    y_max = 3.0

    for ax in axes:
        ax.set_ylim(y_min, y_max)

        # 主刻度：0.15 s = 150 ms
        ax.yaxis.set_major_locator(ticker.MultipleLocator(0.15))

        # 輔助刻度：0.075 s = 75 ms
        ax.yaxis.set_minor_locator(ticker.MultipleLocator(0.075))

        # 主格線與輔助格線
        ax.grid(True, which="major", axis="y", linestyle="--", linewidth=0.7)
        ax.grid(True, which="minor", axis="y", linestyle=":", linewidth=0.4)
        ax.grid(True, which="major", axis="x", linestyle="--", linewidth=0.5)

    axes[-1].set_xlabel("Number of Sellers")
    fig.text(
        0.04,
        0.5,
        "Average Proving Time (s)",
        va="center",
        rotation="vertical",
    )

    plt.suptitle(
        "Average Proving Time vs Number of Sellers (Fixed Buyers)",
        y=0.92,
    )

    plt.savefig(OUTPUT_PATH, bbox_inches="tight")
    plt.close()

    print(f"Saved: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()

