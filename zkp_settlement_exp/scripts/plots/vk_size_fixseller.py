from pathlib import Path
import csv
import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter

CSV_PATH = Path("results/raw/batch_metrics_50.csv")
OUTPUT_PATH = Path("results/figures/vk_size_fixseller_50.png")

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

    hatches = {
        10: "///",
        20: "\\\\\\",
        30: "xx",
    }

    colors = {
        10: "tab:blue",
        20: "tab:orange",
        30: "tab:green",
    }

    bar_width = 1.5
    offsets = {
        10: -bar_width,
        20: 0,
        30: bar_width,
    }

    for seller in FIXED_SELLERS:
        filtered = [
            row for row in rows
            if row["fixed_role"] == "seller"
            and int(row["fixed_value"]) == seller
        ]

        point_map = {
            int(row["nBuyer"]): int(row["vk_size_bytes"])
            for row in filtered
        }

        xs = [x for x in X_BUYERS if x in point_map]
        ys = [point_map[x] / (1024 * 1024) for x in xs]
        bar_xs = [x + offsets[seller] for x in xs]

        if xs:
            found_any = True

            bars = ax.bar(
                bar_xs,
                ys,
                width=bar_width,
                label=f"Seller = {seller}",
                facecolor="none",
                edgecolor=colors[seller],
                hatch=hatches[seller],
                linewidth=1.5,
            )

            for bar, y in zip(bars, ys):
                ax.annotate(
                    f"{y:.6f}",
                    (bar.get_x() + bar.get_width() / 2, y),
                    textcoords="offset points",
                    xytext=(0, 4),
                    ha="center",
                    va="bottom",
                    fontsize=8,
                    color=colors[seller],
                    rotation=90,
                )

    if not found_any:
        raise ValueError("No data found for fixed sellers.")

    ax.grid(True, axis="y")
    ax.set_xticks(X_BUYERS)
    ax.set_ylim(0.002588, 0.002637)
    ax.set_yticks([
        0.002590,
        0.002595,
        0.002600,
        0.002605,
        0.002610,
        0.002615,
        0.002620,
        0.002625,
        0.002630,
        0.002635,
    ])
    ax.yaxis.set_major_formatter(FormatStrFormatter("%.6f"))
    ax.set_xlabel("Number of Buyers")
    ax.set_ylabel("Verification Key Size (MB)")
    ax.set_title("Verification Key Size vs Number of Buyers (Fixed Sellers)")
    ax.legend()

    plt.savefig(OUTPUT_PATH, bbox_inches="tight")
    plt.close()

    print(f"Saved: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
