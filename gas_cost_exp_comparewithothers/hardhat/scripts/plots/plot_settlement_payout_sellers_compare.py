import os
import pandas as pd
import matplotlib.pyplot as plt

# =========================
# Paths
# 腳本位置: hardhat/scripts/plots/plot_settlement_payout_sellers_compare.py
# 專案根目錄: ../../..
# =========================
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
CSV_PATH = os.path.join(PROJECT_ROOT, "results", "processed", "gas_summary_comparewithothers.csv")
FIG_DIR = os.path.join(PROJECT_ROOT, "results", "figures")
OUTPUT_PATH = os.path.join(FIG_DIR, "settlement_payout_sellers_compare.png")

os.makedirs(FIG_DIR, exist_ok=True)

print("PROJECT_ROOT =", PROJECT_ROOT)
print("CSV_PATH =", CSV_PATH)
print("OUTPUT_PATH =", OUTPUT_PATH)

# =========================
# Load CSV
# =========================
df = pd.read_csv(CSV_PATH)

# =========================
# Required metrics in CSV
# Ours:
#   deploy settlement: Gas_deploy_settlement
#   payout: Gas_payout_only
# =========================
required_cols = ["metric", "gasUsed"]
for col in required_cols:
    if col not in df.columns:
        raise ValueError(f"Missing required column: {col}")

ours_deploy_df = df[df["metric"] == "Gas_deploy_settlement"].copy()
ours_payout_df = df[df["metric"] == "Gas_payout_only"].copy()

if ours_deploy_df.empty:
    raise ValueError("Cannot find metric = Gas_deploy_settlement in CSV.")

if ours_payout_df.empty:
    raise ValueError("Cannot find metric = Gas_payout_only in CSV.")

# =========================
# Extract Ours gas values
# deploy settlement 在 CSV 中約為 527598, 527586, 527562, 527550
# 平均後為 527574
#
# payout 在 CSV 中主要為 33762
# 使用眾數避免單一 outlier，例如 33784
# =========================
ours_deploy_raw = int(round(ours_deploy_df["gasUsed"].astype(int).mean()))
ours_payout_base_raw = int(ours_payout_df["gasUsed"].astype(int).mode().iloc[0])

# =========================
# PriVET data from table
# =========================
privet_deploy_raw = 310000
privet_payout_base_raw = 58000

# =========================
# X axis: Number of Sellers
# =========================
n_sellers = [1, 5, 10, 15]

# =========================
# Gas calculation
# deploy settlement: fixed horizontal line
# payout: base gas * number of sellers
# =========================
ours_deploy_raw_list = [ours_deploy_raw for _ in n_sellers]
privet_deploy_raw_list = [privet_deploy_raw for _ in n_sellers]

ours_payout_raw_list = [ours_payout_base_raw * n for n in n_sellers]
privet_payout_raw_list = [privet_payout_base_raw * n for n in n_sellers]

# =========================
# Scale Y axis to ×10^5 gas
# =========================
scale = 1e5

ours_deploy_y = [v / scale for v in ours_deploy_raw_list]
ours_payout_y = [v / scale for v in ours_payout_raw_list]

privet_deploy_y = [v / scale for v in privet_deploy_raw_list]
privet_payout_y = [v / scale for v in privet_payout_raw_list]

# =========================
# Colors
# =========================
OURS_COLOR = "#1f77b4"      # blue
PRIVET_COLOR = "#ff7f0e"    # orange

# =========================
# Plot
# =========================
plt.figure(figsize=(8, 5))

# Ours - deploy settlement: blue triangle
plt.plot(
    n_sellers,
    ours_deploy_y,
    marker="^",
    color=OURS_COLOR,
    linewidth=2,
    linestyle="--",
    label="Ours - Deploy Settlement"
)

# Ours - payout: blue square
plt.plot(
    n_sellers,
    ours_payout_y,
    marker="s",
    color=OURS_COLOR,
    linewidth=2,
    linestyle="-",
    label="Ours - Payout"
)

# PriVET - deploy settlement: orange circle
plt.plot(
    n_sellers,
    privet_deploy_y,
    marker="o",
    color=PRIVET_COLOR,
    linewidth=2,
    linestyle="--",
    label="PriVET - Deploy Settlement"
)

# PriVET - payout: orange diamond
plt.plot(
    n_sellers,
    privet_payout_y,
    marker="D",
    color=PRIVET_COLOR,
    linewidth=2,
    linestyle="-",
    label="PriVET - Payout"
)

# =========================
# Annotate values
# 顯示 y 軸縮放後的數值，也就是 ×10^5 gas
# =========================
def annotate_points(x_list, y_list, color, offset_y):
    for x, y in zip(x_list, y_list):
        plt.annotate(
            f"{y:.2f}",
            (x, y),
            textcoords="offset points",
            xytext=(0, offset_y),
            ha="center",
            color=color,
            fontsize=9
        )

annotate_points(n_sellers, ours_deploy_y, OURS_COLOR, 8)
annotate_points(n_sellers, ours_payout_y, OURS_COLOR, -14)

annotate_points(n_sellers, privet_deploy_y, PRIVET_COLOR, 8)
annotate_points(n_sellers, privet_payout_y, PRIVET_COLOR, -14)

# =========================
# Labels and style
# =========================
plt.xlabel("Number of Sellers")
plt.ylabel(r"Gas ($\times 10^5$)")
plt.title("Deploy Settlement and Payout Gas Comparison")

plt.xticks(n_sellers, [f"n={n}" for n in n_sellers])

all_y = ours_deploy_y + ours_payout_y + privet_deploy_y + privet_payout_y
plt.ylim(0.0, max(all_y) * 1.15)

plt.legend()
plt.grid(True)

plt.tight_layout()
plt.savefig(OUTPUT_PATH, dpi=300)
plt.close()

print("Figure saved to:", OUTPUT_PATH)

print("\nOurs deploy settlement rows used:")
print(ours_deploy_df[["metric", "caseTag", "nSeller", "nBuyer", "gasUsed", "sourceFile"]])

print("\nOurs payout rows used:")
print(ours_payout_df[["metric", "caseTag", "nSeller", "nBuyer", "gasUsed", "sourceFile"]])

print("\nValues used:")
print("Ours deploy settlement gas =", ours_deploy_raw)
print("Ours payout base gas       =", ours_payout_base_raw)
print("PriVET deploy settlement   =", privet_deploy_raw)
print("PriVET payout base gas     =", privet_payout_base_raw)
