.data
	board: .word row1, row2, row3	# Address references for each "sub-array"

	row1: .word 0, 0, 0
	row2: .word 0, 0, 0
	row3: .word 0, 0, 0	
	
	dash: .byte '-'
	charX: .byte 'X'
	charO: .byte 'O'

	Rules1: .asciiz "Tic Tac Toe Game: The Rules are simple, the player will choose O or X and will start by picking one of the 9 squares.\n"
	Rules2: .asciiz "To pick your square, enter the row and column number (0-2) of your desired square. Below are the row and column numbers.\n"
	ExampleBoard1: .asciiz "  0 1 2\n"
	ExampleBoard2: .asciiz "0 - - -\n"
	ExampleBoard3: .asciiz "1 - - -\n"
	ExampleBoard4: .asciiz "2 - - -\n"
	Rules3: .asciiz "The computer will then play their move with the symbol the player did not pick.\n"
	Rules4: .asciiz "The game ends when one of the rows, columns, or diagonals are filled with one of the same symbol.\n"
	Rules5: .asciiz "The game will draw if no one wins and all of the squares are filled.\n"
	Rules6: .asciiz "\nWill you play as X or O?\nPlayer choice : "
	ComputerChoice: .asciiz "\nComputer Choice : "
	newLine: .asciiz "\n"
	space: .asciiz " "
	invalidMovePrompt: .asciiz "You have chosen a square that already has a move or is out of bounds, please try again"
	InvalidInput: .asciiz "\nINVALID INPUT:, Please Enter X or O (case-sensitive)\n"
	ErrorMessage: .asciiz "Unexpected Error Occurred"
	GameTieMessage: .asciiz "\nGame is a Tie. Better Luck Next Time!\n\n"
	
	# Strings for Module DisplayBoard
	currentBoard: .asciiz "Board is currently : \n"
	
	# Strings for Module getPlayerInput
	playerRowPrompt: .asciiz "\nPlease enter the ROW index for your move: "
	playerColPrompt: .asciiz "Please enter the COLUMN index for your move: "
	
	# Strings for Module ComputerThinkingAnimation
	computerIsThinkingString: .asciiz "\nComputer is choosing "
	period: .asciiz ". "
	line: .asciiz "__________________________________________________\n"
	
	# Strings for Module CheckWin
	winnerX: .asciiz "\n----------   Player X has WON!!!   -----------\n\n"
	winnerO: .asciiz "\n----------   Player O has WON!!!   -----------\n\n"

.text

.globl main

main:
	# Print rules and prompt player choice
	la $a0, Rules1
	li $v0, 4
	syscall
	la $a0, Rules2
	li $v0, 4
	syscall
	la $a0, ExampleBoard1
	li $v0, 4
	syscall
	la $a0, ExampleBoard2
	li $v0, 4
	syscall
	la $a0, ExampleBoard3
	li $v0, 4
	syscall
	la $a0, ExampleBoard4
	li $v0, 4
	syscall
	la $a0, Rules3
	li $v0, 4
	syscall
	la $a0, Rules4
	li $v0, 4
	syscall
	la $a0, Rules5
	li $v0, 4
	syscall
	
	# Store Player Choice (X or O) in $s0
	# Store Computer Choice (X or O) in $s1 
	
	promptUser:
		la $a0, Rules6
		li $v0, 4
		syscall
		
		li $v0, 12
		syscall
		
		move $s0, $v0	# Store Player Choice (X or O) in $s0
		li $a0, 'X'
		li $a1, 'O'
		beq $s0, $a0, pickedX
		beq $s0, $a1, pickedO
		la $a0, InvalidInput
		li $v0, 4
		syscall
		j promptUser	#vRetry input
		
		pickedX:
			li $s1, 'O'	# Computer choice
			j next
		
		pickedO:
			li $s1, 'X'	# Computer choice
			
	# Print player choices	
	next:
		la $a0, ComputerChoice
		li $v0, 4
		syscall
	
		la $a0, ($s1)
		li $v0, 11
		syscall
	
		la $a0, newLine
		li $v0, 4
		syscall
		la $a0, newLine
		li $v0, 4
		syscall
	
		# GAMEPLAY
	
		jal DisplayBoard

	# Player always goes first
	# First move input & validation done outside of loop to simplify logic
	PlayerFirstMove:
		jal GetPlayerMove
		move $a0, $v0
		move $a1, $v1
	
		# Validate if a0 or a1 is out of bounds (ie < 0 or > 2)
		bgt $a0, 2, invalidFirstMove
		bgt $a1, 2, invalidFirstMove
		blt $a0, 0, invalidFirstMove
		blt $a1, 0, invalidFirstMove
	
		jal StoreMove
	
		li $s3, 4	# Loop countdown variable
		
	Loop:
		jal ComputerThinkingAnimation
	
		jal GenerateComputerMove
		move $a0, $v0
		move $a1, $v1
		jal StoreComputerMove
		jal CheckWin
		
		# Cosmetic and UX commands to improve readability and slow game down
		la $a0, line
		li $v0, 4
		syscall
		li $a0, 500
		li $v0, 32
		syscall
		jal DisplayBoard
		
		PlayerMove:	
			jal GetPlayerMove		
			move $a0, $v0
			move $a1, $v1
		
			# Validate if a0 or a1 is out of bounds (ie < 0 or > 2)
			bgt $a0, 2, invalidMove
			bgt $a1, 2, invalidMove
			blt $a0, 0, invalidMove
			blt $a1, 0, invalidMove		
				
			jal GetValueAt		# Validate Player Input
			bnez $v0, invalidMove	# If space is not free, jump to invalidMove and retry

			jal StoreMove
			jal CheckWin
		
			# Update loop sentinel
			sub $s3, $s3, 1
			beqz $s3, LoopEnd
			j Loop
		
	# If player move is invalid (filled/out of bounds) jump back to start
	invalidMove:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
	
		la $a0, invalidMovePrompt
		li $v0, 4
		syscall
		j PlayerMove
	
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
	
	# Edge case, if 1st move is invalid, must jump to before loop to ensure game continuity
	invalidFirstMove:
		la $a0, invalidMovePrompt
		li $v0, 4
		syscall
		j PlayerFirstMove
		
	# If loop has ended with jumping to PlayerWin / ComputerWin, then game is a tie
	LoopEnd:
		li $a0, 1000
		li $v0, 32
		syscall
	
		la $a0, line
		li $v0, 4
		syscall
	
		la $a0, GameTieMessage
		li $v0, 4
		syscall
	
		jal DisplayBoard
	
		li $v0, 10
		syscall
	
	# Displays the current board, looping through the 2d array
	DisplayBoard:
		addi $sp, $sp, -4	# Push return address to stack
		sw $ra, ($sp)
		
		la $a0, currentBoard
		li $v0, 4
		syscall
		
		la $t0, board		# Load array address in t0
		lw $t0, 0($t0)
		move $t1, $zero		# t1=count
		addi $t2, $zero, 9	# t2=length
		
		loop:
			addi $t1, $t1, 1
			bgt $t1, $t2, exitloop	# (while count<=length, or 9)
			lw $t3, 0($t0)		# t3 is current value (temp)
			beqz $t3, isZero
			beq $t3, 1, isX 
			beq $t3, 2, isO
			
			# If value is neither 0,1, or 2 then print error
			la $a0, ErrorMessage
			li $v0, 4
			j exitloop
			
			isO:	# Print O and space character
				li $a0, 'O'
				li $v0, 11
				syscall
				la $a0, space
				li $v0, 4
				syscall	
				j innerbranch1
			
			isX:	# Print X and space character
				li $a0, 'X'
				li $v0, 11
				syscall
				la $a0, space
				li $v0, 4
				syscall				
				j innerbranch1				
			
			isZero:	# Print - and space character
				li $a0, '-'
				li $v0, 11
				syscall
				la $a0, space
				li $v0, 4
				syscall				
				j innerbranch1				
			
			innerbranch1:	# Test if newline is needed
				li $t4, 3
				div $t1, $t4 
				mfhi $a0		# a0 = Counter % 3
				beqz $a0, printNewLine	# New line is needed if remainder is 0
				j innerbranch2
			
			printNewLine:	# Prints new line
				la $a0, newLine
				li $v0, 4
				syscall				
				j innerbranch2				
			
			innerbranch2:	# Increment address and loop
				addi $t0, $t0, 4
				j loop
		
		# Restore and return to address
		exitloop:
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
	
# Prompts user for row and col. Returns values in v0 and v1 respectively
# The stack is used to temporaryily store data while v0 is used for syscall

GetPlayerMove:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a0, playerRowPrompt	# Prompt for row and read int
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	
	addi $sp, $sp, -4	# Push row entry to stack
	sw $v0, 0($sp)
	
	la $a0, playerColPrompt	# Prompt for col and read int
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	
	addi $sp, $sp, -4	# Push col entry to stack
	sw $v0, 0($sp)
	
	lw $v1, 0($sp)	# Pop col from stack
	addi $sp, $sp, 4
	lw $v0, 0($sp)	# Pop row from stack
	addi $sp, $sp, 4	
	
	lw $ra, 0($sp)	# Return to caller
	addi $sp, $sp, 4
	jr $ra

# StoreMove(int row, int col)...StoreMove has parameters int row, int col stored in $a0, $a1
StoreMove:
	addi $sp, $sp, -4	# Push return address to stack
	sw $ra, ($sp)

	la $t0, board
	sll $t1, $a0, 2		# t1 = row * 4
	add $t0, $t0, $t1	# t0 now points to specified row -> t0 = t1 + Address
	lw $t2, 0($t0)		# t2 points to base address of row

	sll $t1, $a1, 2		# t1 = col * 4
	add $t3, $t2, $t1	# t3 points to col within address row
	lw $t4, 0($t3)		# t4 has item in board[row][col]
	
	move $t1, $s0		# Move is valid, load players icon
	beq $s0, 88, storeX
	beq $s0, 79, storeO
	
	storeX:
		li $t5, 1
		sw $t5, 0($t3)
		j end
	
	storeO:
		li $t5, 2
		sw $t5, 0($t3)	# Store move at respective 2d array address
	
	end:
		lw $ra 0($sp)	# Pop ra from stack
		addi $sp, $sp, 4
		jr $ra

StoreComputerMove:
	addi $sp, $sp, -4	# Push return address to stack
	sw $ra, ($sp)

	la $t0, board
	sll $t1, $a0, 2		# t1 = row * 4
	add $t0, $t0, $t1	# t0 now points to specified row -> t0 = t1 + Address
	lw $t2, 0($t0)		# t2 points to base address of row

	sll $t1, $a1, 2		# t1 = col * 4
	add $t3, $t2, $t1	# t3 points to col within address row
	lw $t4, 0($t3)		# t4 has item in board[row][col]

	move $t1, $s0			# Move is valid, load players icon
	beq $s0, 88, player2StoreO	# If player1 icon is X, then store a O
	beq $s0, 79, player2StoreX	# If player1 icon is O, then store a X
	
	player2StoreO:
		li $t5, 2
		sw $t5, 0($t3)		# Store move at respective 2d array address
		j player2End
		
	player2StoreX:
		li $t5, 1
		sw $t5, 0($t3)
		
	player2End:
		lw $ra 0($sp)		# Pop ra from stack
 		addi $sp, $sp, 4
		jr $ra

# Generates two random ints corresponding to board row and column
# Internally checks if the space is available, loops and generates new #'s is space is unavailable
# Returns result [row][col] in $v0 and $v1 respectively. No Parameters Passed in.
GenerateComputerMove:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $v0, 30	# Service 30, gets time since epoch, returns in a0
	syscall
	move $a1, $a0
	li $v0, 40	# Set seed based on $a1
	syscall
		
	innerCompGenLoop:
		jal RandomNumGen
		move $t6, $v0	# Temp. storage for row as $a0 will be used again
		
		jal RandomNumGen
		move $t7, $v0	# Temp. storage for col as $a0 will be used again
		
		move $a0, $t6
		move $a1, $t7
		
		jal GetValueAt	# Check if board location already in use, run again and generate new board move
		bnez $v0, innerCompGenLoop
	
		move $v0, $t6	# Otherwise, return to caller
		move $v1, $t7
	
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra

# Random Number Generator, no parameter. Returns random int in range 0 <= [int] < [UpperBound]. (upper bound stored as int in a1)
# Returns Random Number in $v0
RandomNumGen:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $a1, 3
	li $v0, 42	# Generate random number
	syscall
	move $v0, $a0
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
# Paramters row, col stored in $a0, $a1 respectively.
# Returns value at board[row][col] in $v0
# No input validation as GetMove is an internal function (user-input mistakes not applicable)
GetValueAt:
	addi $sp, $sp, -12	# Push parameters a0 and a1 into stack, we want to preserve original values
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $ra, 8($sp)		# Push ra to stack as well
	
	la $t0, board	
	sll $a0, $a0, 2		# a0 = row * 4
	add $t0, $t0, $a0	# t0 = address + row * 4
	lw $t1, 0($t0)		# t1 now points to address in board[row]
	
	sll $a1, $a1, 2		# a1 = col * 4
	add $t1, $t1, $a1	# t1 now points to board[row][col]
	lw $v0, 0($t1)
	
	lw $a0, 0($sp)		# Pop a0 from stack
	addi $sp, $sp, 4
	
	lw $a1, 0($sp)		# Pop a1 from stack
	addi $sp, $sp, 4
	
	lw $ra, 0($sp)		# Pop ra from stack
	addi $sp, $sp, 4
	jr $ra

# Just a short animation to make the game more enjoyable
ComputerThinkingAnimation:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	la $a0, computerIsThinkingString
	li $v0, 4
	syscall
	
	li $a0, 1000
	li $v0, 32
	syscall
	la $a0, period
	li $v0, 4
	syscall
	
	li $a0, 500
	li $v0, 32
	syscall
	la $a0, period
	li $v0, 4
	syscall
	
	li $a0, 500
	li $v0, 32
	syscall
	la $a0, period
	li $v0, 4
	syscall
	
	la $a0, newLine
	li $v0, 4
	syscall	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
# This function checks if any player has won by accessing the 2d board array directly
# If somewon won, its prints a message and ends the program, otherwise it returns to the caller.
CheckWin:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	la $t1, row1	# Load address of first row into register $t1
	la $t2, row2	# Load address of second row into register $t2
	la $t3, row3	# Load address of third row into register $t3
	li $t7, 1	# Integer 1 represents X
	li $t8, 1	# Load character 'X' into register $t7
	li $t7, 2	# Integer 2 represents O
	li $t9, 2	# Load character 'O' into register $t7

	lw $t4, ($t1)		# Load value at [0][0] into $t4
	lw $t5, 4($t1)		# Load value at [0][1] into $t5
	lw $t6, 8($t1)		# Load value at [0][2] into $t6
	beq $t4, $t8, Row1_X	# If value in [0][0] equals 'X', check the rest of the row for 'X'
	beq $t4, $t9, Row1_O	# If value in [0][0] equals 'O', check the rest of the row for 'X'
	j CheckRow2
  
	Row1_X:
		bne $t4, $t5, CheckRow2	 # If value in [0][1] is not equal to 'X', check the next row
		bne $t4, $t6, CheckRow2	 # If value in [0][2] is not equal to 'X', check the next row
		j WinnerX		 # Player 'X' wins because all 3 row values are 'X'

	Row1_O:
		bne $t4, $t5, CheckRow2
		bne $t4, $t6, CheckRow2
		j WinnerO
  
	CheckRow2:
		lw $t4, ($t2)
		lw $t5, 4($t2)
		lw $t6, 8($t2)
		beq $t4, $t8, Row2_X
		beq $t4, $t9, Row2_O
		j CheckRow3

	Row2_X:
		bne $t4, $t5, CheckRow3
		bne $t4, $t6, CheckRow3
		j WinnerX

	Row2_O:
		bne $t4, $t5, CheckRow3
		bne $t4, $t6, CheckRow3
		j WinnerO

	CheckRow3:
		lw $t4, ($t3)
		lw $t5, 4($t3)
		lw $t6, 8($t3)
		beq $t4, $t8, Row3_X
		beq $t4, $t9, Row3_O
		j CheckCol1

	Row3_X:
		bne $t4, $t5, CheckCol1
		bne $t4, $t6, CheckCol1
		j WinnerX

	Row3_O:
		bne $t4, $t5, CheckCol1
		bne $t4, $t6, CheckCol1
		j WinnerO
  
	CheckCol1:
		lw $t4, ($t1)
		lw $t5, ($t2)
		lw $t6, ($t3)
		beq $t4, $t8, Col1_X
		beq $t4, $t9, Col1_O
		j CheckCol2

	Col1_X:
		bne $t4, $t5, CheckCol2
		bne $t4, $t6, CheckCol2
		j WinnerX

	Col1_O:
		bne $t4, $t5, CheckCol2
		bne $t4, $t6, CheckCol2
		j WinnerO
  
	CheckCol2:
		lw $t4, 4($t1)
		lw $t5, 4($t2)
		lw $t6, 4($t3)
		beq $t4, $t8, Col2_X
		beq $t4, $t9, Col2_O
		j CheckCol3

	Col2_X:
		bne $t4, $t5, CheckCol3
		bne $t4, $t6, CheckCol3
		j WinnerX

	Col2_O:
		bne $t4, $t5, CheckCol3
		bne $t4, $t6, CheckCol3
		j WinnerO
  
	CheckCol3:
		lw $t4, 8($t1)
		lw $t5, 8($t2)
		lw $t6, 8($t3)
		beq $t4, $t8, Col3_X
		beq $t4, $t9, Col3_O
		j CheckDiag1

	Col3_X:
		bne $t4, $t5, CheckDiag1
		bne $t4, $t6, CheckDiag1
		j WinnerX

	Col3_O:
		bne $t4, $t5, CheckDiag1
		bne $t4, $t6, CheckDiag1
		j WinnerO

	CheckDiag1:
		lw $t4, ($t1)
		lw $t5, 4($t2)
		lw $t6, 8($t3)
		beq $t4, $t8, Diag1_X
		beq $t4, $t9, Diag1_O
		j CheckDiag2

	Diag1_X:
		bne $t4, $t5, CheckDiag2
		bne $t4, $t6, CheckDiag2
		j WinnerX

	Diag1_O:
		bne $t4, $t5, CheckDiag2
		bne $t4, $t6, CheckDiag2
		j WinnerO

	CheckDiag2:
		lw $t4, 8($t1)
		lw $t5, 4($t2)
		lw $t6, ($t3)
		beq $t4, $t8, Diag2_X
		beq $t4, $t9, Diag2_O
		j End

	Diag2_X:
		bne $t4, $t5, End
		bne $t4, $t6, End
		j WinnerX

	Diag2_O:
		bne $t4, $t5, End
		bne $t4, $t6, End
		j WinnerO

# Winning statement for 'X'
WinnerX:
	li $a0, 750	# Cosmetic pause for UX
	li $v0, 32
	syscall

	la $a0, winnerX
	li $v0, 4
	syscall
	
	jal DisplayBoard

	li $v0, 10
	syscall

# Winning statement for 'O'
WinnerO:
	li $a0, 750	# Cosmetic pause for UX
	li $v0, 32
	syscall
		
	la $a0, winnerO
	li $v0, 4
	syscall

	jal DisplayBoard

	li $v0, 10
	syscall

# Temporary end of program statement
End:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra