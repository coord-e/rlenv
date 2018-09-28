from glob import glob
from pathlib import Path
import sys
import os

import numpy as np
from natsort import natsorted
import matplotlib.pyplot as plt


def smooth(n, ary):
    return np.convolve(ary, np.ones(n)/n, mode='same')

name = sys.argv[1]

csvs = glob('results/{}/logs/*.monitor.csv'.format(name))
assert len(csvs) == 1
data = np.loadtxt(csvs[0], skiprows=2, delimiter=',', usecols=(0,1)).T
timesteps = [t / 1e6 for t in data[1].cumsum()] # Show in (M)

fig = plt.figure(figsize=(12, 8))
ax = fig.add_subplot(111)

ax.set_xlabel("Number of Timesteps (M)")
ax.set_ylabel("Episodic Reward")

ax.xaxis.set_major_formatter(plt.FormatStrFormatter('%.1f'))

for i in [0, 2]:
    rewards = smooth(10**i, data[0])
    ax.plot(timesteps, rewards, color='blue', alpha=(i+1)/3)

plt.legend()

# plt.show()
plt.tight_layout()

outdir = Path("results/") / name / "plot"
if not outdir.is_dir():
    outdir.mkdir()

plt.savefig(str(outdir / "plot.png"))
