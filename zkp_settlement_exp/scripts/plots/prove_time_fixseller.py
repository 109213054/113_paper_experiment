from pathlib import Path
import csv
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

CSV_PATH = Path("results/raw/batch_metrics_50.csv")
OUTPUT_PATH = Path("results/figures/prove_time_fixseller_50.png")

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

    fig, ax = plt.subplots(figsize=(10, 6))

    found_any = False

    markers = {
        10: "o",
        20: "s",
        30: "^",
    }

    colors = {
        10: "tab:blue",
        20: "tab:orange",
        30: "tab:green",
    }

    for seller in FIXED_SELLERS:
        filtered = [
            row for row in rows
            if row["fixed_role"] == "seller"
            and int(row["fixed_value"]) == seller
        ]

        point_map = {
            int(row["nBuyer"]): float(row["prove_time_ms_avg"]) / 1000
            for row in filtered
        }

        xs = [x for x in X_BUYERS if x in point_map]
        ys = [point_map[x] for x in xs]

        if xs:
            found_any = True

            ax.plot(
                xs,
                ys,
                marker=markers[seller],
                linewidth=2,
                color=colors[seller],
                label=f"Seller = {seller}",
            )

            for x, y in zip(xs, ys):
                ax.annotate(
                    f"{y:.3f}",
                    (x, y),
                    textcoords="offset points",
                    xytext=(0, 6),
                    fontsize=8,
                    ha="center",
                    va="bottom",
                    color=colors[seller],
                )

    if not found_any:
        raise ValueError("No data found for fixed sellers.")

    y_min = 0.9
    y_max = 3.0

    ax.set_ylim(y_min, y_max)
    ax.set_xticks(X_BUYERS)
    ax.yaxis.set_major_locator(ticker.MultipleLocator(0.15))
    ax.yaxis.set_minor_locator(ticker.MultipleLocator(0.075))

    ax.grid(True, which="major", axis="y", linestyle="--", linewidth=0.7)
    ax.grid(True, which="minor", axis="y", linestyle=":", linewidth=0.4)
    ax.grid(True, which="major", axis="x", linestyle="--", linewidth=0.5)

    ax.set_xlabel("Number of Buyers")
    ax.set_ylabel("Average Proving Time (s)")
    ax.set_title("Average Proving Time vs Number of Buyers (Fixed Sellers)")
    ax.legend()

    plt.savefig(OUTPUT_PATH, bbox_inches="tight")
    plt.close()

    print(f"Saved: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
