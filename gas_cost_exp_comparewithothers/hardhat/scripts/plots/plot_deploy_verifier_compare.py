import os
import pandas as pd
import matplotlib.pyplot as plt

# =========================
# Paths
# 腳本位置: hardhat/scripts/plots/plot_deploy_verifier_compare.py
# 專案根目錄: ../../..
# =========================
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
CSV_PATH = os.path.join(PROJECT_ROOT, "results", "processed", "gas_summary_comparewithothers.csv")
FIG_DIR = os.path.join(PROJECT_ROOT, "results", "figures")
OUTPUT_PATH = os.path.join(FIG_DIR, "deploy_verifier_compare.png")

os.makedirs(FIG_DIR, exist_ok=True)

print("PROJECT_ROOT =", PROJECT_ROOT)
print("CSV_PATH =", CSV_PATH)
print("OUTPUT_PATH =", OUTPUT_PATH)

# =========================
# Load CSV
# =========================
df = pd.read_csv(CSV_PATH)

# =========================
# Filter our data
# 條件：
# 1. metric = Gas_deploy_verifier
# 2. nSeller = 1
# 3. nBuyer = 10,20,30,40
# =========================
target_buyers = [10, 20, 30, 40]

ours_df = df[
    (df["metric"] == "Gas_deploy_verifier") &
    (df["nSeller"] == 1) &
    (df["nBuyer"].isin(target_buyers))
].copy()

ours_df = ours_df.sort_values(by=["nBuyer"]).drop_duplicates(
    subset=["nBuyer"],
    keep="last"
)

# 重新依 nBuyer 排序
ours_df = ours_df.sort_values(by="nBuyer")

if len(ours_df) != 4:
    raise ValueError(
        f"Expected 4 rows for Gas_deploy_verifier with nSeller=1 and nBuyer in {target_buyers}, "
        f"but got {len(ours_df)} rows.\nFiltered data:\n{ours_df}"
    )

x_vals = ours_df["nBuyer"].tolist()
ours_gas_raw = ours_df["gasUsed"].astype(int).tolist()

# =========================
# Jiang et al. data
# Deploy(gas): n=10,20,30,40
# =========================
jiang_x = [10, 20, 30, 40]
jiang_gas_raw = [1595337, 1595361, 1594970, 1595661]

# =========================
# Scale Y axis to ×10^5 gas
# =========================
scale = 1e5
ours_y = [v / scale for v in ours_gas_raw]
jiang_y = [v / scale for v in jiang_gas_raw]

# =========================
# Colors
# =========================
OURS_COLOR = "#1f77b4"     # Matplotlib default blue
JIANG_COLOR = "#ff7f0e"    # Matplotlib default orange

# =========================
# Plot
# =========================
plt.figure(figsize=(8, 5))

plt.plot(
    x_vals,
    ours_y,
    marker="o",
    color=OURS_COLOR,
    linewidth=2,
    label="Ours"
)

plt.plot(
    jiang_x,
    jiang_y,
    marker="s",
    color=JIANG_COLOR,
    linewidth=2,
    label="Jiang et al."
)

# 標示 ours 每個點的數值
for x, y, raw in zip(x_vals, ours_y, ours_gas_raw):
    plt.annotate(
        f"{y:.2f}",
        (x, y),
        textcoords="offset points",
        xytext=(0, 8),
        ha="center",
        color=OURS_COLOR,
        fontsize=10
    )

# 標示 Jiang et al. 每個點的數值
for x, y, raw in zip(jiang_x, jiang_y, jiang_gas_raw):
    plt.annotate(
        f"{y:.2f}",
        (x, y),
        textcoords="offset points",
        xytext=(0, -14),
        ha="center",
        color=JIANG_COLOR,
        fontsize=10
    )

plt.xlabel("Number of Buyers")
plt.ylabel(r"Gas ($\times 10^5$)")
plt.title("Deployment Gas of Verifier Smart Contract")

plt.xticks([10, 20, 30, 40], ["n=10", "n=20", "n=30", "n=40"])
plt.ylim(0.0, 40.0)

plt.legend()
plt.grid(True)

plt.tight_layout()
plt.savefig(OUTPUT_PATH, dpi=300)
plt.close()

print("Figure saved to:", OUTPUT_PATH)
print("Our data used:")
print(ours_df[["metric", "caseTag", "nSeller", "nBuyer", "gasUsed", "sourceFile"]])
