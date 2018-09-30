from glob import glob
from pathlib import Path
import sys
import os

import numpy as np
import matplotlib.pyplot as plt

name = sys.argv[1]

def load(path):
    data = np.genfromtxt(path, dtype=float, delimiter=',', names=True)
    return np.array([data['total_timesteps'], data['eprewmean']]).T

csvs = glob('results/{}/logs*/progress.csv'.format(name))
data = [load(csv) for csv in csvs]
uselen = min(d.shape[0] for d in data)
data_shaped = np.array([d[:uselen] for d in data]).T

timesteps = np.mean(data_shaped[0], axis=1) / 1e6 # Show in (M)
rewards = data_shaped[1]

fig = plt.figure(figsize=(12, 8))
ax = fig.add_subplot(111)

ax.set_xlabel("Number of Timesteps (M)")
ax.set_ylabel("Episodic Reward")

ax.xaxis.set_major_formatter(plt.FormatStrFormatter('%.1f'))

rewards_mean = np.mean(rewards, axis=1)
rewards_std = np.std(rewards, axis=1)

ax.plot(timesteps, rewards_mean, color='blue', alpha=1)
ax.fill_between(timesteps, rewards_mean - rewards_std, rewards_mean + rewards_std, color="blue", alpha=1/3)

plt.legend()

# plt.show()
plt.tight_layout()

outdir = Path("results/") / name / "plot"
if not outdir.is_dir():
    outdir.mkdir()

plt.savefig(str(outdir / "plot.png"))
