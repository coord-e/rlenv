from glob import glob
from pathlib import Path
import sys
import os

import numpy as np
import matplotlib.pyplot as plt


def smooth(n, ary):
    return np.convolve(ary, np.ones(n)/n, mode='same')

name = sys.argv[1]

csvs = glob('results/{}/logs*/*.monitor.csv'.format(name))
data = [np.loadtxt(csv, skiprows=2, delimiter=',', usecols=(0,1)) for csv in csvs]
uselen = min(d.shape[0] for d in data)
data_shaped = np.array([d[:uselen] for d in data]).T

rewards = data_shaped[0]
timesteps = [t / 1e6 for t in np.mean(data_shaped[1], axis=1).cumsum()] # Show in (M)

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
