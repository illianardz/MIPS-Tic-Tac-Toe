# MIPS Tic-Tac-Toe Game

This project implements a Tic-Tac-Toe game in MIPS assembly language, featuring a two-player mode where a human player competes against the computer. It utilizes a 2D array to store the game state and includes various functionalities such as input validation, error handling, and dynamic game state updates based on player interactions.

## Core Components
- **Computer Algorithm**: Handles the computer's game decisions.
- **Interface**: Manages input/output operations for game interactions.
- **Winning Condition**: Checks for a winner after each move.
- **Game State Storage**: Uses a 2D array to track the moves on the game board.

## Gameplay Walkthrough
1. **Initialization**: On start, the game initializes the board and displays the rules.
2. **Player Move**: Players choose 'X' or 'O' and input their move by specifying the row and column.
3. **Validation**: The game checks if the chosen spot is free; if not, it prompts for another choice.
4. **Winning Condition Check**: After each move, the game checks for a win condition.
5. **Computer Move**: If no win is detected, the computer makes its move based on a simple random strategy.
6. **End Phase**: The game ends when a player wins or all spots are filled, displaying the final board and the outcome.

## Algorithms and Techniques
- **Game Loop**: Manages the sequence of gameplay actions, including player input, computer moves, and win checking.
- **Random Move Generation**: The computer uses a basic random generator for move selection.
- **System Calls**: Used for display outputs and user inputs.
- **Control Flow**: Utilizes jump, link, and branch instructions for function calls and loop controls.
