import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation


# Approximate, schematic circuit shape (not an official circuit map)
track_points = np.array([
    [0, 0], [1, 0.2], [2, 0.7], [3.5, 0.8], [4.3, 1.5],
    [4.8, 2.6], [4.5, 3.5], [3.7, 3.8], [3.0, 3.4],
    [2.5, 2.7], [1.8, 2.5], [1.1, 2.8], [0.5, 3.6],
    [-0.5, 3.8], [-1.3, 3.2], [-1.2, 2.4], [-0.5, 1.8],
    [-0.8, 1.0], [-0.4, 0.3], [0, 0]
], dtype=float)

# Interpolate the track so the cars move smoothly
segment_lengths = np.sqrt(np.sum(np.diff(track_points, axis=0) ** 2, axis=1))
cumulative_distance = np.concatenate(([0], np.cumsum(segment_lengths)))
track_length = cumulative_distance[-1]
sample_distance = np.linspace(0, track_length, 1000)

track_x = np.interp(sample_distance, cumulative_distance, track_points[:, 0])
track_y = np.interp(sample_distance, cumulative_distance, track_points[:, 1])

drivers = pd.DataFrame({
    "Driver": ["Max", "Lewis", "Charles","Abhi"],
    "Team": ["Red Bull", "Mercedes", "Ferrari","Force India"],
    "Colour": ["#3671C6", "#27F4D2", "#E8002D","#FFC0CB"],
    "Progress": [0.08, 0.07, 0.04,0.03],  # fraction of one lap
    "Speed": [0.0020, 0.0018, 0.0017,0.002]  # simulated progress per frame
})

fig, ax = plt.subplots(figsize=(10, 7))
fig.patch.set_facecolor("#10141c")
ax.set_facecolor("#10141c")

# Track outline
ax.plot(track_x, track_y, color="#6d7480", linewidth=18,
        solid_capstyle="round", zorder=1)
ax.plot(track_x, track_y, color="#d8dde6", linewidth=2,
        linestyle="--", alpha=0.9, zorder=2)

car_dots = []
car_labels = []

for _, driver in drivers.iterrows():
    dot, = ax.plot([], [], "o", markersize=12,
                   color=driver["Colour"],
                   markeredgecolor="white", markeredgewidth=1.2,
                   zorder=5)
    label = ax.text(0, 0, driver["Driver"], color="white",
                    fontsize=9, weight="bold", zorder=6)
    car_dots.append(dot)
    car_labels.append(label)

leaderboard = ax.text(
    0.02, 0.98, "", transform=ax.transAxes,
    va="top", ha="left", color="white", fontsize=11,
    family="monospace",
    bbox=dict(boxstyle="round,pad=0.6", facecolor="#202735",
              edgecolor="#4a5261", alpha=0.95),
    zorder=10
)

lap_text = ax.text(
    0.98, 0.98, "Grand Prix",
    transform=ax.transAxes, va="top", ha="right",
    color="#f5d547", fontsize=12, weight="bold"
)

ax.set_title(" RACE TRACKER", color="white",
             fontsize=18, weight="bold", pad=18)
ax.set_aspect("equal")
ax.set_xlim(track_x.min() - 1.5, track_x.max() + 1.5)
ax.set_ylim(track_y.min() - 1.2, track_y.max() + 1.2)
ax.axis("off")


def update(frame):
    # Advance each driver's simulated position by a small amount
    drivers["Progress"] = (drivers["Progress"] + drivers["Speed"]) % 1.0

    # Sort by progress around the lap for the leaderboard
    order = drivers.sort_values("Progress", ascending=False).reset_index(drop=True)

    for i, driver in drivers.iterrows():
        distance = driver["Progress"] * track_length
        x = np.interp(distance, sample_distance, track_x)
        y = np.interp(distance, sample_distance, track_y)

        car_dots[i].set_data([x], [y])
        car_labels[i].set_position((x + 0.12, y + 0.12))

    lines = ["POS  DRIVER      GAP  "]
    leader_progress = order.loc[0, "Progress"]

    for pos, driver in order.iterrows():
        gap_fraction = (leader_progress - driver["Progress"]) % 1.0
        # Display a simple illustrative gap, not real timing data
        gap_seconds = gap_fraction * 95
        if pos == 0:
            gap = "LEADER"
        else:
            gap = f"+{gap_seconds:.1f}s"
        lines.append(f"{pos + 1:<4} {driver['Driver']:<11} {gap}")

    leaderboard.set_text("\n".join(lines))
    return car_dots + car_labels + [leaderboard]


animation = FuncAnimation(
    fig, update, interval=50, blit=False, cache_frame_data=False
)

plt.show()
