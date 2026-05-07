import os
import pandas as pd
import matplotlib.pyplot as plt

# =========================
# Paths
# 腳本位置: hardhat/scripts/plots/plot_gas_verify_ours.py
# 專案根目錄: ../../..
# =========================
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
CSV_PATH = os.path.join(PROJECT_ROOT, "results", "processed", "gas_summary_comparewithothers.csv")
FIG_DIR = os.path.join(PROJECT_ROOT, "results", "figures")
OUTPUT_PATH = os.path.join(FIG_DIR, "plot_gas_verify_ours.png")

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
# 1. metric = Gas_verify_success
# 2. nSeller = 1
# 3. nBuyer = 10,20,30,40
# =========================
target_buyers = [10, 20, 30, 40]

ours_df = df[
    (df["metric"] == "Gas_verify_success") &
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
        f"Expected 4 rows for Gas_verify_success with nSeller=1 and nBuyer in {target_buyers}, "
        f"but got {len(ours_df)} rows.\nFiltered data:\n{ours_df}"
    )

x_vals = ours_df["nBuyer"].tolist()
ours_gas_raw = ours_df["gasUsed"].astype(int).tolist()

# =========================
# Scale Y axis to ×10^5 gas
# =========================
scale = 1e5
ours_y = [v / scale for v in ours_gas_raw]

# =========================
# Colors
# =========================
OURS_COLOR = "#1f77b4"     # Matplotlib default blue

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
    label="ours"
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

plt.xlabel("Number of Buyers")
plt.ylabel(r"Gas ($\times 10^5$)")
plt.title("Gas Cost for ZKP Verification")
plt.xticks([10, 20, 30, 40], ["n=10", "n=20", "n=30", "n=40"])
plt.ylim(0, 15)

plt.legend()
plt.grid(True)

plt.tight_layout()
plt.savefig(OUTPUT_PATH, dpi=300)
plt.close()

print("Figure saved to:", OUTPUT_PATH)
print("Our data used:")

print_cols = ["metric", "caseTag", "nSeller", "nBuyer", "gasUsed"]

if "sourceFile" in ours_df.columns:
    print_cols.append("sourceFile")

print(ours_df[print_cols])
