from pathlib import Path
import csv
import matplotlib.pyplot as plt

CSV_PATH = Path("results/raw/batch_metrics_50.csv")
OUTPUT_PATH = Path("results/figures/proof_size_fixbuyer_50.png")

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

    for buyer in FIXED_BUYERS:
        filtered = [
            row for row in rows
            if row["fixed_role"] == "buyer"
            and int(row["fixed_value"]) == buyer
        ]

        point_map = {
            int(row["nSeller"]): int(row["proof_size_bytes"])
            for row in filtered
        }

        xs = [x for x in X_SELLERS if x in point_map]
        ys = [point_map[x] for x in xs]

        if xs:
            found_any = True
            ax.plot(
                xs,
                ys,
                marker=markers[buyer],
                color=colors[buyer],
                label=f"Buyer = {buyer}",
            )

            for x, y in zip(xs, ys):
                ax.annotate(
                    str(y),
                    (x, y),
                    textcoords="offset points",
                    xytext=(5, 5),
                    ha="left",
                    fontsize=8,
                    color=colors[buyer],
                )

    if not found_any:
        raise ValueError("No data found for fixed buyers.")

    ax.grid(True)
    ax.set_xticks(X_SELLERS)
    ax.set_ylim(790, 830)
    ax.set_yticks(list(range(790, 831, 5)))
    ax.set_xlabel("Number of Sellers")
    ax.set_ylabel("Proof Size (bytes)")
    ax.set_title("Proof Size vs Number of Sellers (Fixed Buyers)")
    ax.legend()

    plt.savefig(OUTPUT_PATH, bbox_inches="tight")
    plt.close()

    print(f"Saved: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
