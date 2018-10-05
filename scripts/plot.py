from glob import glob
from pathlib import Path
import sys
import os
import argparse
from pick import pick

import numpy as np
import matplotlib.pyplot as plt

def plot(ax, name, is_detailed):
    def load(path):
        data = np.genfromtxt(path, dtype=float, delimiter=',', names=True)
        return np.array([data['total_timesteps'], data['eprewmean']]).T

    basedirs = glob('results/{}*'.format(name))
    basedir, _ = pick(basedirs, 'choose the result directory to use')

    if is_detailed:
        csvs = glob('{}/logs*/*.monitor.csv'.format(basedir))
        data = [np.loadtxt(csv, skiprows=2, delimiter=',', usecols=(0,1)) for csv in csvs]
        uselen = min(d.shape[0] for d in data)
        data_shaped = np.array([d[:uselen] for d in data]).T

        rewards = data_shaped[0]
        timesteps = [t / 1e6 for t in np.mean(data_shaped[1], axis=1).cumsum()] # Show in (M)
    else:
        csvs = glob('{}/logs*/progress.csv'.format(basedir))
        data = [load(csv) for csv in csvs]
        uselen = min(d.shape[0] for d in data)
        data_shaped = np.array([d[:uselen] for d in data]).T

        timesteps = np.mean(data_shaped[0], axis=1) / 1e6 # Show in (M)
        rewards = data_shaped[1]

    rewards_mean = np.mean(rewards, axis=1)
    rewards_std = np.std(rewards, axis=1)

    ax.plot(timesteps, rewards_mean, alpha=2/3, label=name)
    ax.fill_between(timesteps, rewards_mean - rewards_std, rewards_mean + rewards_std, alpha=1/3)


parser = argparse.ArgumentParser()

parser.add_argument("-w", "--width", type=int, default=6, help="The width of figure")
parser.add_argument("-H", "--height", type=int, default=4, help="The height of figure")
parser.add_argument("-d", "--detailed", action="store_true",
                            help="Use 0.0.monitor.csv")

parser.add_argument("name", nargs='+', help="result id")
args = parser.parse_args()

fig = plt.figure(figsize=(args.width, args.height))
ax = fig.add_subplot(111)

ax.set_xlabel("Number of Timesteps (M)")
ax.set_ylabel("Episodic Reward")

ax.xaxis.set_major_formatter(plt.FormatStrFormatter('%.1f'))

for name in args.name:
    plot(ax, name, args.detailed)

plt.legend()

plt.tight_layout()

outdir = Path("results/") / "plot"
if not outdir.is_dir():
    outdir.mkdir()

plt.savefig(str(outdir / ("_".join(args.name)+".png")))

plt.show()
