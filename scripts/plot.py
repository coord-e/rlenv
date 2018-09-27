from glob import glob
import sys

import numpy as np
from natsort import natsorted
import matplotlib.pyplot as plt


def smooth(n, ary):
    return np.convolve(ary, np.ones(n)/n, mode='same')

name = sys.argv[1]

csvs = glob('results/{}/logs/*.monitor.csv'.format(name))
assert len(csvs) == 1
data = np.loadtxt(csvs[0], skiprows=2, delimiter=',', usecols=(0,1)).T
timesteps = data[1].cumsum()

fig = plt.figure(figsize=(12, 8))
ax = fig.add_subplot(111)

ax.set_xlabel("Number of Timesteps")
ax.set_ylabel("Episodic Reward")

ax.plot(timesteps, smooth(100, data[0]))

plt.legend()

# plt.show()
plt.tight_layout()
plt.savefig("foo.png")
