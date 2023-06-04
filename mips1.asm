### 			BITMAP SETTINGS			    ###	
###							    ###
###	Unit Width in pixels: 8 			    ###
###	Unit Heigh in Pixels: 8				    ###
###	Display Width in Pixels: 512			    ###
###	Display Height in Pixels: 256  			    ###
###	Base address for display 0x10010000 (static data)   ###
							  
.data

frameBuffer: 	.space 	0x80000		#512 wide x 256 high pixels
xVel:		.word	0		# x velocity start 0
yVel:		.word	0		# y velocity start 0
ghostVelX: .word 0
ghostVelY: .word 0
xPos:		.word	50		# x position
yPos:		.word	27		# y position
ghostX:         .word 45
ghostY:         .word 25
foodX:		.word	32		# food x position
foodY:		.word	16		# food y position
pacmanUp:	.word	0x0000ff00	# green pixel for when pacman moving up
pacmanDown:	.word	0x0100ff00	# green pixel for when pacman moving down
pacmanLeft:	.word	0x0200ff00	# green pixel for when pacman moving left
pacmanRight:	.word	0x0300ff00	# green pixel for when pacman moving right
pacman:		.word	0x00ffff00	# yellow pixel for Pacman
ghost:           .word  0xffff00ff 
xConversion:	.word	64		# x value for converting xPos to bitmap display
yConversion:	.word	4		# y value for converting (x, y) to bitmap display


.text
main:

### DRAW BACKGROUND SECTION

	la 	$t0, frameBuffer	# load frame buffer address
	li 	$t1, 8192		# save 512*256 pixels
        li $t2, 0x008B4513	# load brown color (darker shade)


l1:
	sw   	$t2, 0($t0)
	addi 	$t0, $t0, 4 	# advance to next pixel position in display
	addi 	$t1, $t1, -1	# decrement number of pixels
	bnez 	$t1, l1		# repeat while number of pixels is not zero
	
### DRAW BORDER SECTION
	### DRAW WALLS SECTION
	
# Wall 1 (horizontal)
la	$t0, frameBuffer	# load frame buffer address
addi	$t0, $t0, 4800	# set starting pixel position
addi	$t1, $zero, 32	# t1 = 30 length of row
li $t2, 0x00000000	# load black color

drawWall1:
	sw	$t2, 0($t0)	# color Pixel black
	addi	$t0, $t0, 4	# go to next pixel
	addi	$t1, $t1, -1	# decrease pixel count
	bnez	$t1, drawWall1	# repeat until pixel count == 0

# Wall 2 (vertical)
la	$t0, frameBuffer	# load frame buffer address
addi	$t0, $t0, 1100	# set starting pixel position
addi	$t1, $zero, 16	# t1 = 64 length of column

drawWall2:
	sw	$t2, 0($t0)	# color Pixel black
	addi	$t0, $t0, 300	# go to next pixel
	addi	$t1, $t1, -1	# decrease pixel count
	bnez	$t1, drawWall2	# repeat until pixel count == 0

	# top wall section
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t1, $zero, 64	# t1 = 64 length of row
        li $t2, 0x00000000	# load black color
        
  drawWall3: 
	sw	$t2, 0($t0)	# color Pixel black
	addi	$t0, $t0, 64	# go to next pixel
	addi	$t1, $t1, -1	# decrease pixel count
	bnez	$t1, drawWall3	# repeat until pixel count == 0

	# top wall section
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t1, $zero, 64	# t1 = 64 length of row
        li $t2, 0x00000000	# load black color
     
  
### DRAW BORDER SECTION

drawBorderTop:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 4		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderTop	# repeat until pixel count == 0
	
	# Bottom wall section
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t0, $t0, 7936		# set pixel to be near the bottom left
	addi	$t1, $zero, 64		# t1 = 512 length of row

drawBorderBot:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 4		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderBot	# repeat until pixel count == 0
	
	# left wall section
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t1, $zero, 256		# t1 = 256 length of column
	addi	$t2, $zero, 0		# t2 = 0
drawBorderLeft:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 256		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderLeft	# repeat unitl pixel count == 0
	
	# Right wall section
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t0, $t0, 508		# make starting pixel top right
	addi	$t1, $zero, 255		# t1 = 512 length of col
drawBorderRight:
	sw	$t2, 0($t0)		# color Pixel black
	addi	$t0, $t0, 256		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderRight	# repeat unitl pixel count == 0
	la	$t0, frameBuffer	# load frame buffer address

	### draw initial food
	jal 	drawFood
#############################################################PART 1
###		  THE GAME LOOP                          ###	
###	                                                 ###	
#############################################################

gameLoop:
	
	### UPDATE PACMAN'S POSITION SECTION
	
	lw 	$t3, xPos		# Load current x position
	lw 	$t4, xVel		# Load current x velocity
	add 	$t3, $t3, $t4		# Calculate new x position
	sw 	$t3, xPos		# Store new x position
	
	lw 	$t3, yPos		# Load current y position
	lw 	$t4, yVel		# Load current y velocity
	add 	$t3, $t3, $t4		# Calculate new y position
	sw 	$t3, yPos		# Store new y position
	
	### UPDATE GHOST'S POSITION SECTION
	
	lw	$t3, ghostX		# Load current ghost x position
	lw	$t4, ghostVelX		# Load current ghost x velocity
	add	$t3, $t3, $t4		# Calculate new ghost x position
	sw	$t3, ghostX		# Store new ghost x position
	
	lw	$t3, ghostY		# Load current ghost y position
	lw	$t4, ghostVelY		# Load current ghost y velocity
	add	$t3, $t3, $t4		# Calculate new ghost y position
	sw	$t3, ghostY		# Store new ghost y position
	
	### HANDLE GHOST COLLISION SECTION
	
	lw	$t3, ghostX		# Load current ghost x position
	blt	$t3, 10, handleCollision	# If ghost x < 10, ghost is out of bounds
	
	lw	$t3, ghostX		# Load current ghost x position
	bgt	$t3, 246, handleCollision	# If ghost x > 246, ghost is out of bounds
	
	lw	$t3, ghostY		# Load current ghost y position
	blt	$t3, 10, handleCollision	# If ghost y < 10, ghost is out of bounds
	
	lw	$t3, ghostY		# Load current ghost y position
	bgt	$t3, 238, handleCollision	# If ghost y > 238, ghost is out of bounds
	### HANDLE INPUT SECTION
	
	# Check for user input
	# Assume that when arrow keys are pressed, x and y velocities are updated accordingly
	# Arrow keys input handling code goes here...
	
	# Check if Pacman is out of bounds (colliding with walls)
	lw	$t3, xPos		# Load current x position
	bgt	$t3, 246, handleCollision	# If x > 246, Pacman is out of bounds
	
	lw	$t3, xPos		# Load current x position
	blt	$t3, 10, handleCollision	# If x < 10, Pacman is out of bounds
	
	lw	$t3, yPos		# Load current y position
	bgt	$t3, 238, handleCollision	# If y > 238, Pacman is out of bounds
	
	lw	$t3, yPos		# Load current y position
	blt	$t3, 10, handleCollision	# If y < 10, Pacman is out of bounds
	
	### DRAW GHOST SECTION
	
	la	$t0, frameBuffer	# Load frame buffer address
	lw	$t1, ghostX		# Load ghost x position
	lw	$t2, ghostY		# Load ghost y position
	
	lw	$t3, xConversion	# Load x conversion factor
	mult	$t1, $t3		# Multiply ghost x position by conversion factor
	mflo	$t1			# Store result in $t1
	
	lw	$t3, yConversion	# Load y conversion factor
	mult	$t2, $t3		# Multiply ghost y position by conversion factor
	mflo	$t2			# Store result in $t2
	
	add	$t0, $t0, $t1		# Add x position to frame buffer address
	add	$t0, $t0, $t2		# Add y position to frame buffer address
	
	lw	$t3, ghost	# Load ghost color
	sw	$t3, 0($t0)		# Store ghost pixel on the bitmap display
	

	### DRAW PACMAN SECTION
	
	la 	$t0, frameBuffer		# load frame buffer address
	lw 	$t1, xPos			# load x position
	lw 	$t2, yPos			# load y position
	
	lw 	$t4, xConversion		# load x conversion factor
	mul 	$t1, $t1, $t4		# multiply x position by conversion factor
	
	lw 	$t4, yConversion		# load y conversion factor
	mul 	$t2, $t2, $t4		# multiply y position by conversion factor
	
	add 	$t0, $t0, $t1		# add x position to frame buffer address
	add 	$t0, $t0, $t2		# add y position to frame buffer address
	
lw $t3, pacman
sw $t3, 0($t0)

	lw	$t3, 0xffff0004		# get keypress from keyboard input
	
	### Sleep for 66 ms so frame rate is about 15
	addi	$v0, $zero, 32	# syscall sleep
	addi	$a0, $zero, 66	# 66 ms
	syscall
	
	beq	$t3, 100, moveRight	# if key press = 'd' branch to moveright
	beq	$t3, 97, moveLeft	# else if key press = 'a' branch to moveLeft
	beq	$t3, 119, moveUp	# if key press = 'w' branch to moveUp
	beq	$t3, 115, moveDown	# else if key press = 's' branch to moveDown
	beq	$t3, 0, moveUp		# start game moving up
	
	moveUp:
	lw	$s3, pacmanUp	# s3 = direction of pacman
	add	$a0, $s3, $zero	# a0 = direction of pacman
	jal	updatePacman
	
	# move the pacman
	jal 	updatePacmanHeadPosition
	
	j	exitMoving 	

moveDown:
	lw	$s3, pacmanDown	# s3 = direction of pacman
	add	$a0, $s3, $zero	# a0 = direction of pacman
	jal	updatePacman
	
	# move the pacman
	jal 	updatePacmanHeadPosition
	
	j	exitMoving
	
moveLeft:
	lw	$s3, pacmanLeft	# s3 = direction of pacman
	add	$a0, $s3, $zero	# a0 = direction of pacman
	jal	updatePacman
	
	# move the pacman
	jal 	updatePacmanHeadPosition
	
	j	exitMoving
	
moveRight:
	lw	$s3, pacmanRight	# s3 = direction of pacman
	add	$a0, $s3, $zero	# a0 = direction of pacman
	jal	updatePacman
	
	# move the pacman
	jal 	updatePacmanHeadPosition

	j	exitMoving

exitMoving:
	### REPEAT GAME LOOP SECTION
	
	j 	gameLoop # loop back to beginning

updatePacman:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updatePacman frame pointer
	
	### DRAW HEAD
	lw	$t0, xPos		# t0 = xPos of pacman
	lw	$t1, yPos		# t1 = yPos of pacman
	lw	$t2, xConversion	# t2 = 64
	mult	$t1, $t2		# yPos * 64
	mflo	$t3			# t3 = yPos * 64
	add	$t3, $t3, $t0		# t3 = yPos * 64 + xPos
	lw	$t2, yConversion	# t2 = 4
	mult	$t3, $t2		# (yPos * 64 + xPos) * 4
	mflo	$t0			# t0 = (yPos * 64 + xPos) * 4
	
	la 	$t1, frameBuffer	# load frame buffer address
	add	$t0, $t1, $t0		# t0 = (yPos * 64 + xPos) * 4 + frame address
	lw	$t4, 0($t0)		# save original val of pixel in t4
	sw	$a0, 0($t0)		# store direction plus color on the bitmap display
	
	
	### Set Velocity
	lw	$t2, pacmanUp			# load word pacman up = 0x0000ff00
	beq	$a0, $t2, setVelocityUp		# if head direction and color == pacman up branch to setVelocityUp
	
	lw	$t2, pacmanDown			# load word pacman up = 0x0100ff00
	beq	$a0, $t2, setVelocityDown	# if head direction and color == pacman down branch to setVelocityUp
	
	lw	$t2, pacmanLeft			# load word pacman up = 0x0200ff00
	beq	$a0, $t2, setVelocityLeft	# if head direction and color == pacman left branch to setVelocityUp
	
	lw	$t2, pacmanRight			# load word pacman up = 0x0300ff00
	beq	$a0, $t2, setVelocityRight	# if head direction and color == pacman right branch to setVelocityUp
	
	setVelocityUp:
	addi	$t5, $zero, 0		# set x velocity to zero
	addi	$t6, $zero, -1	 	# set y velocity to -1
	sw	$t5, xVel		# update xVel in memory
	sw	$t6, yVel		# update yVel in memory
	j exitVelocitySet
	
setVelocityDown:
	addi	$t5, $zero, 0		# set x velocity to zero
	addi	$t6, $zero, 1 		# set y velocity to 1
	sw	$t5, xVel		# update xVel in memory
	sw	$t6, yVel		# update yVel in memory
	j exitVelocitySet
	
setVelocityLeft:
	addi	$t5, $zero, -1		# set x velocity to -1
	addi	$t6, $zero, 0 		# set y velocity to zero
	sw	$t5, xVel		# update xVel in memory
	sw	$t6, yVel		# update yVel in memory
	j exitVelocitySet
	
setVelocityRight:
	addi	$t5, $zero, 1		# set x velocity to 1
	addi	$t6, $zero, 0 		# set y velocity to zero
	sw	$t5, xVel		# update xVel in memory
	sw	$t6, yVel		# update yVel in memory
	j exitVelocitySet
	
exitVelocitySet:
	
	### Head location checks
	li 	$t2, 0x00ff0000		# load red color
	bne	$t2, $t4, headNotFood	# if head location is not the food branch away
	
	jal 	newFoodLocation
	jal	drawFood
	j	exitUpdatePacman
	
	exitUpdatePacman:
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code
	
	updatePacmanHeadPosition:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updatePacman frame pointer	
	
	lw	$t3, xVel	# load xVel from memory
	lw	$t4, yVel	# load yVel from memory
	lw	$t5, xPos	# load xPos from memory
	lw	$t6, yPos	# load yPos from memory
	add	$t5, $t5, $t3	# update x pos
	add	$t6, $t6, $t4	# update y pos
	sw	$t5, xPos	# store updated xpos back to memory
	sw	$t6, yPos	# store updated ypos back to memory
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code
	
	
#############################################################PART2
###	       HANDLE COLLISION FUNCTION                 ###	
###	                                                 ###	
#############################################################

handleCollision:

	# Collision handling code goes here...
	# You can implement logic to handle collisions with walls, ghosts, pellets, etc.
	
	# Reset Pacman's position to the center of the screen
	li 	$t3, 50			# Set x position to 50
	sw 	$t3, xPos
	
	li 	$t3, 27			# Set y position to 27
	sw 	$t3, yPos
	
	# Reset Pacman's velocity to 0
	li 	$t3, 0			# Set x velocity to 0
	sw 	$t3, xVel
	
	li 	$t3, 0			# Set y velocity to 0
	sw 	$t3, yVel
	
	# Repeat game loop
	j 	gameLoop
	headNotFood:

        li $t2, 0x008B4513	# load brown color (darker shade)
	
	addi 	$v0, $zero, 10	# exit the program
	syscall
	drawFood:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updatePacman frame pointer
	
	lw	$t0, foodX		# t0 = xPos of food
	lw	$t1, foodY		# t1 = yPos of food
	lw	$t2, xConversion	# t2 = 64
	mult	$t1, $t2		# foodY * 64
	mflo	$t3			# t3 = foodY * 64
	add	$t3, $t3, $t0		# t3 = foodY * 64 + foodX
	lw	$t2, yConversion	# t2 = 4
	mult	$t3, $t2		# (yPos * 64 + foodX) * 4
	mflo	$t0			# t0 = (foodY * 64 + foodX) * 4
	
	la 	$t1, frameBuffer	# load frame buffer address
	add	$t0, $t1, $t0		# t0 = (foodY * 64 + foodX) * 4 + frame address
	li	$t4, 0x00ff0000
	sw	$t4, 0($t0)		# store direction plus color on the bitmap display
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code	

       newFoodLocation:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updatePacman frame pointer
	
	redoRandom:		
	addi	$v0, $zero, 42	# random int 
	addi	$a1, $zero, 63	# upper bound
	syscall
	add	$t1, $zero, $a0	# random foodX
	
	addi	$v0, $zero, 42	# random int 
	addi	$a1, $zero, 31	# upper bound
	syscall
	add	$t2, $zero, $a0	# random foodY
	
	lw	$t3, xConversion	# t3 = 64
	mult	$t2, $t3		# random foodY * 64
	mflo	$t4			# t4 = random foodY * 64
	add	$t4, $t4, $t1		# t4 = random foodY * 64 + random foodX
	lw	$t3, yConversion	# t3 = 4
	mult	$t3, $t4		# (random foodY * 64 + random foodX) * 4
	mflo	$t4			# t1 = (random foodY * 64 + random foodX) * 4
	
	la 	$t0, frameBuffer	# load frame buffer address
	add	$t0, $t4, $t0		# t0 = (foodY * 64 + foodX) * 4 + frame address
	lw	$t5, 0($t0)		# t5 = value of pixel at t0
	
	li	$t6, 0x00d3d3d3		# load light gray color
	beq	$t5, $t6, goodFood	# if loction is a good sqaure branch to goodFood
	j redoRandom
	
	goodFood:
	sw	$t1, foodX
	sw	$t2, foodY	

	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code  PART3
