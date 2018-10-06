# rlenv

Scaffold reinforcement learning experiment environment

## Setup

```bash
mkdir your_new_workspace && cd $_
curl -fsSL https://coord-e.github.io/rlenv/bootstrap.sh | bash
```

## Usage

```bash
# To train the model:
pipenv run train --name humanoid --env RoboschoolHumanoid-v1 --timesteps 1e4

# To plot the result:
pipenv run plot

# To play with trained model:
pipenv run play --name humanoid
```

## Structure

```
rlenv/ (submodule)
baselines/ (submodule)
roboschool/ (submodule)
Pipfile
Pipfile.lock
.rlenv.toml
.gitignore
.gitmodules
```



