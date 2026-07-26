# Picotron Arkanoid

A remake of the classic **Arkanoid** arcade game developed in **Picotron** using **Lua**.

The goal of this project is to recreate the original gameplay while keeping the code clean, modular, and easy to understand. It is also a personal learning project focused on game development with Picotron.

## Features

* Classic Arkanoid gameplay
* Paddle and ball physics
* Brick collision system
* Score and lives management
* Level loading from text maps
* Retro-inspired HUD
* Clean and modular Lua code

## Controls

| Key          | Action          |
| ------------ | --------------- |
| Left / Right | Move paddle     |
| X            | Launch the ball |
| Esc          | Quit            |

## Project Structure

```
picotron-arkanoid/
│
├── main.lua          # Entry point
├── game.lua          # Game loop
├── paddle.lua        # Paddle logic
├── ball.lua          # Ball movement and collisions
├── bricks.lua        # Brick management
├── levels.lua        # Level loading
├── hud.lua           # HUD rendering
├── constants.lua     # Game constants
└── sprites/          # Graphics
```

> The project structure may evolve as development progresses.

## Goals

* Recreate the feel of the original Arkanoid
* Keep the code readable and well organized
* Use function references instead of large conditional state machines whenever possible
* Follow consistent coding conventions
* Learn more about Picotron development

## Building

Open the project with **Picotron** and run:

```
load main.lua
run
```

(or simply open the cartridge if using the Picotron editor.)

## Development

This project is written entirely in **Lua** for **Picotron**.

Coding conventions:

* Variables, functions and comments are written in English.
* Small, focused functions.
* Modular architecture.
* Readable code over clever code.

## Roadmap

* [x] Paddle movement
* [x] Ball physics
* [x] Brick collision
* [x] HUD
* [ ] Multiple levels
* [ ] Power-ups
* [ ] Sound effects
* [ ] Music
* [ ] High score table
* [ ] Title screen
* [ ] Game Over screen

## Acknowledgements

This project is inspired by **Arkanoid**, originally created by **Taito** in 1986.

It is a non-commercial fan project created for educational purposes and to explore game development with Picotron.

## License

This project is released under the MIT License.
