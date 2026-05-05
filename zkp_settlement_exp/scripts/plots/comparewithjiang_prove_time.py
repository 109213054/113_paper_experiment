from pathlib import Path
import csv
import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import matplotlib.ticker as ticker


CSV_PATH = Path("results/raw/comparewithjiang_metrics_50.csv")
OUTPUT_PATH = Path("results/figures/comparewithjiang_prove_time.png")

X_VALUES = [10, 20, 30, 40]
X_FIELD = "nBuyer"

FIXED_ROLE = "buyer"
NSELLER_VALUE = 1

JIANG_PROVE_TIME_MS = {
    10: 9460.12,
    20: 9531.84,
    30: 13660.94,
    40: 13590.18,
}


def load_csv_rows(csv_path: Path):
    if not csv_path.exists():
        raise FileNotFoundError(f"CSV file not found: {csv_path}")

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
            raise ValueError(f"CSV missing required fields: {sorted(missing)}")

        return list(reader)


def main():
    rows = load_csv_rows(CSV_PATH)
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

    my_values = {x: [] for x in X_VALUES}

    for row in rows:
        fixed_role = row["fixed_role"].strip()
        n_seller = int(row["nSeller"].strip())
        x = int(row[X_FIELD].strip())

        if fixed_role != FIXED_ROLE:
            continue

        if n_seller != NSELLER_VALUE:
            continue

        if x not in X_VALUES:
            continue

        prove_time_s = float(row["prove_time_ms_avg"].strip()) / 1000.0
        my_values[x].append(prove_time_s)

    my_point_map = {
        x: sum(values) / len(values)
        for x, values in my_values.items()
        if values
    }

    my_xs = [x for x in X_VALUES if x in my_point_map]
    my_ys = [my_point_map[x] for x in my_xs]

    if not my_xs:
        raise ValueError(
            "No CSV data found for Our protocol. "
            "Please check FIXED_ROLE, NSELLER_VALUE, and X_FIELD."
        )

    jiang_xs = X_VALUES
    jiang_ys = [JIANG_PROVE_TIME_MS[x] / 1000.0 for x in jiang_xs]

    fig, ax = plt.subplots(figsize=(10, 6))

    ax.plot(
        my_xs,
        my_ys,
        marker="o",
        linewidth=2,
        label="Our protocol",
    )

    ax.plot(
        jiang_xs,
        jiang_ys,
        marker="s",
        linewidth=2,
        label="Jiang et al.",
    )

    for x, y in zip(my_xs, my_ys):
        ax.annotate(
            f"{y:.3f}",
            (x, y),
            textcoords="offset points",
            xytext=(0, 6),
            fontsize=8,
            ha="center",
            va="bottom",
        )

    for x, y in zip(jiang_xs, jiang_ys):
        ax.annotate(
            f"{y:.3f}",
            (x, y),
            textcoords="offset points",
            xytext=(0, 6),
            fontsize=8,
            ha="center",
            va="bottom",
        )

    ax.set_xticks(X_VALUES)

    all_ys = my_ys + jiang_ys
    ax.set_ylim(0, max(all_ys) * 1.15)

    ax.yaxis.set_major_locator(ticker.MaxNLocator(nbins=8))
    ax.yaxis.set_minor_locator(ticker.AutoMinorLocator())

    ax.grid(True, which="major", axis="y", linestyle="--", linewidth=0.7)
    ax.grid(True, which="minor", axis="y", linestyle=":", linewidth=0.4)
    ax.grid(True, which="major", axis="x", linestyle="--", linewidth=0.5)

    ax.set_xlabel("Number of aggregated transactions n")
    ax.set_ylabel("Proof generation time (s)")
    ax.set_title("Proof Generation Time Comparison")
    ax.legend()

    fig.savefig(OUTPUT_PATH, bbox_inches="tight", dpi=300)
    plt.close(fig)

    print(f"Saved: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
