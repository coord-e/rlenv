# The new reinforcement learning project

This project is bootstrapped with [coord-e/rlenv](https://github.com/coord-e/rlenv)

## Usage

To start training:

```bash
# pipenv run train <experiment name> --env <gym environment> --alg <algorithm> --network <network>
pipenv run train humanoid --env RoboschoolHumanoid-v1 --alg ppo2 --network mlp
```

Then, you can plot the result with `pipenv run plot`

```bash
# pipenv run plot <experiment name list>
pipenv run plot humanoid
```

All results are stored under `results/` directory.
