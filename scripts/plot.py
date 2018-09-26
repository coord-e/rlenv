from glob import glob
import sys

import numpy as np
from natsort import natsorted


name = sys.argv[1]

csvs = natsorted(glob('results/{}/logs/*.monitor.csv'.format(name)))
data = np.concatenate([np.loadtxt(f, skiprows=2, delimiter=',') for f in csvs])
