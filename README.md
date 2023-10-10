# GD50 2023

> CS50's Introduction to Game Development

This repo is for CS50's coure on game development. The directory structure is split into a directory for live-coding of the lectures, and the psets directory is for submitting homework aka "Problem Sets".

## Project Organization

```sh
.
├── README.md       # This file
├── lectures        # My implementations while watching lectures
└── psets           # Problem sets
```

## Lectures

These are my personal implementations of the games that I worked on while watching the lectures, I find it easier to understand the concepts if I am able to write them out, and play with variables, and debug the game as it is being developed.

## Problem Sets

### Dependencies

These are the homework assignments that require modifying an existing codebase. I don't copy the code 1:1 in my code while following lectures, so this allows me to work on psets using provided examples. Since I am using my own git repo for managing this course, and I don't want to work with git subtrees or submodules, I use the [submit50](https://cs50.readthedocs.io/submit50/) tool to submit the psets.

The tool runs in Python, I don't want to install it globally so I want to use a [venv](https://docs.python.org/3/library/venv.html). Therefore, to submit a problem set I need to install and activate the virtual environment prior.

```sh
# Create virtual environment (only needed when pulling the repo for the first time)
python3 -m psets/env

# Activate the virtual environment
source psets/env/bin/activate

# Install `submit50` (only needed on first pull)
pip3 install submit50
```

### Using the submit50 tool

To submit work with `submit50`, `cd` to the work’s directory and execute:

```sh
# Log level is optional but helps to understand underlying Git mechanics
submit50 --log-level info|debug <slug>

# For example on Pong
cd psets/pong
submit50 games50/projects/2018/x/pong
```

### Finishing the assignment

Unlike CS50 there is no automated grading mechanism, so be sure to following the problem set instructions and submit the form and any other requirements needed. Once finished, grading can take up to three weeks to grade.

## Course Progress

- My gradebook can be found at https://cs50.me/cs50g
- My submissions can be found at https://submit.cs50.io/courses/33

Despite the course ending in June 2024, the gradebook will reset on January 9, so I need to finish each week without delay to prevent having to do more work to revalidate my archived submissions.

- Week 1: Pong - Oct 1 - Oct 7
- Week 2: Flappy Bird - Oct 8 - Oct 14
- Week 3: Breakout - Oct 15 - Oct 21
- Week 4: Match-3 - Oct 22 - Oct 28
- Week 5: Mario - Oct 29 - Nov 4
- Week 6: Zelda - Nov 5 - Nov 11
- Week 7: Angry Birds - Nov 12 - Nov 18
- Week 8: Pokemon - Nov 19 - Nov 25
- Week 9: Helicopter - Nov 26 - Dec 2
- Week 10: Dreadhalls - Dec 3 - Dec 9
- Week 11: Portal - Dec 10 - Dec 16
- Week 12: Final Project - Dec 17 - Jan 8

## Additional Tools

- Sound effects: https://www.bfxr.net/
- Sprite editor: https://www.aseprite.org/
