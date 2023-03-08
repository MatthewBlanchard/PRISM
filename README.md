# PRISM

PRISM is an open source permissively licensed roguelike engine and example game written in Lua. The example game "Beneath the Garden" is used as a testbed for the featureset of the engine.

## Getting Started

To get started with PRISM, follow these steps:

1.  Clone the repository to your local machine using `git clone https://github.com/MatthewBlanchard/PRISM.git`
2.  Install the open source [LÖVE game framework](https://love2d.org/).
3.  Drag the PRISM file onto the LOVE executable or (with love in your PATH) navigate to the folder containing the repo and run `love PRISM` in your shell of choice.

## Features

PRISM's goal is to be a flexible, hackable, open source roguelike engine. To this end it was designed with a very unopinionated actor/component system, and an action system heavily inspired by [Bob Nystrom's talk on roguelike architecture](https://youtu.be/JxI3Eu5DPwE).

* All actors are made of the same stuff. From the player to a potion they are all Actors composed with Components. This allows for some really interesting mechanics like parsnip people you can eat, or little slimes that explode when thrown.
* Code for features is neatly encapsulated in Actions, Components, and Conditions and it's easy to add new features without going too deeply into systems.

## Goals
PRISM has the following long-term goals:
* Split the engine from the example game and put the dependency on LOVE behind a 'feature flag'. This would allow developers to use the engine without love and use some other media solution, or the recommended path of jumping right in with LOVE.
* Document the main game objects, and refactor code from earlier in the project for better developer ergonomics.
* Create an AI framework that will make adding complex monster behaviors easier, and tame the if-then chains found in the current ai controllers.
* Create a set of map generators that allow developers to create and procedurally place presets and other features. 

## License

PRISM is licensed under the MIT license.

## Contributing

We welcome contributions to PRISM! Open an issue or pull request to begin a discussion.

## Acknowledgements

We would like to thank the following people for their contributions to PRISM:

Rynelf

Dim

Matthew Blanchard
