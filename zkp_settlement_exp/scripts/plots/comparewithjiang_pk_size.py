import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter
from pathlib import Path

# Data
buyers = [10, 20, 30, 40]

ours_bytes = [31488, 59648, 87808, 115968]
jiang_bytes = [101120, 187520, 273920, 360320]

# Convert bytes to MB
MB = 1_000_000
ours_mb = [x / MB for x in ours_bytes]
jiang_mb = [x / MB for x in jiang_bytes]

# color
OURS_COLOR = '#1F77B4'
JIANG_COLOR = '#FF7F0E'

# Plot
plt.figure(figsize=(8, 5))

plt.plot(
    buyers,
    ours_mb,
    marker='o',
    color=OURS_COLOR,
    linewidth=2,
    markersize=8,
    label='ours'
)

plt.plot(
    buyers,
    jiang_mb,
    marker='^',
    color=JIANG_COLOR,
    linewidth=2,
    markersize=8,
    label='Jiang et al.'
)

# Add value labels
for x, y in zip(buyers, ours_mb):
    plt.text(x, y, f'{y:.2f}', ha='center', va='bottom', fontsize=10)

for x, y in zip(buyers, jiang_mb):
    plt.text(x, y, f'{y:.2f}', ha='center', va='bottom', fontsize=10)

# Labels and title
plt.xlabel('Number of Buyers', fontsize=12)
plt.ylabel('Size (MB)', fontsize=12)
plt.title('Proving Key Size Comparison', fontsize=14)

# Axis settings
plt.xticks(buyers)
plt.gca().yaxis.set_major_formatter(FormatStrFormatter('%.2f'))

plt.grid(True, linestyle='--', alpha=0.6)
plt.legend()
plt.tight_layout()

# Save figure
output_path = Path("results/figures/comparewithjiang_pk_size.png")
output_path.parent.mkdir(parents=True, exist_ok=True)

plt.savefig(output_path, dpi=300)
plt.show()

print(f"Saved figure to: {output_path}")
