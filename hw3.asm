##############################################################
# Created by Dan Choe on 12/01/16
# dan.choe@stonybrook.edu
# Copyright ? 2016 DanChoe. All rights reserved.
##############################################################
.text

##############################
# PART 1 FUNCTIONS
##############################

smiley:
    	li $t0, 0xffff0000
    	li $t1, 0x0F
    	li $t2, '\0'
    	li $t5, 100	# Count loop
    	
    	BgBlack:
    	        beqz $t5, endBgBlack
    		sb $t2, 0($t0)
    		sb $t1, 1($t0)
    		addi $t0, $t0, 2
    		addi $t5, $t5, -1
    		j  BgBlack
    	endBgBlack:
		li $t2, 'b'
		li $t1, 0xB7		# eye color
    		li $t0, 0xffff002E
    		sb $t2, 0($t0)
    		sb $t1, 1($t0)
    	        li $t0, 0xffff0034
    		sb $t2, 0($t0)
    		sb $t1, 1($t0)
    		li $t0, 0xffff0042
    		sb $t2, 0($t0)
    		sb $t1, 1($t0)
    		li $t0, 0xffff0048
    		sb $t2, 0($t0)
    		sb $t1, 1($t0)
    	
		li $t2, 'e'
		li $t1, 0x1F		# mouse color
    		li $t0, 0xffff007C
    		sb $t2, 0($t0)
    		sb $t1, 1($t0)
    	        li $t0, 0xffff0086
    		sb $t2, 0($t0)
    		sb $t1, 1($t0)
    		li $t0, 0xffff00A8
    		sb $t2, 0($t0)
    		sb $t1, 1($t0)
    		li $t0, 0xffff00AA
    		sb $t2, 0($t0)
    		sb $t1, 1($t0)
    		li $t0, 0xffff0098
    		sb $t2, 0($t0)
    		sb $t1, 1($t0)
    		li $t0, 0xffff0092
    		sb $t2, 0($t0)
    		sb $t1, 1($t0)
    	#li $v0, 1
	jr $ra

##############################
# PART 2 FUNCTIONS
##############################

open_file:
    li $v0, 13
    li $a1, 0
    li $a2, 0
    syscall
    jr $ra

close_file:
    li $v0, 16
    move $a0, $a0
    syscall
    jr $ra

load_map:
	addi $sp, $sp, -4
	sw $ra, 0($sp)		# save address returning to main
	move $a0, $v0 # a0 contains the file discriptor

	la $t0, textSpace        # address of string to be printed
	la $t1 inputBuffer       #input buffer - where the syscall can put the characters it has read from the file
	li $t3 0                 #counter to read max bytes
	
	addi $sp, $sp, -4
	sw $a1, 0($sp)		# save cell_array address
	li $t4, 0	#check the value is bigger than 9
	readerloop:
		li $v0, 14	#reading the file
		la $a1, ($t1)   #allocate space for the bytes loaded
		li $a2, 1      # number of bytes to be read
		syscall  
		
		beq $v0 0 endReaderloop		# end-of-file
		beq $v0 -1 endReaderloop	# error case

		lb $t2 0($t1) #loading the bytes from the address to t1 so t2 has the character
		
		beqz $t2 endReaderloop # check if the character is null
		bgt $t2 '9' invaildCase
		blt $t2 '0' invaildCase
		beq $t2, '0', validCharacter3
		beq $t4, '0', validCharacter	# 00003  $t2 = 3
		bnez $t4, invaildCase	# $t4 has number, but it reads number again. two digit number
		j validCharacter
		
		invaildCase:
			beq $t2 ' ' validCharacterCheck
			beq $t2 '\r' validCharacterCheck2
			beq $t2 '\t' validCharacterCheck2
			beq $t2 '\n' validCharacterCheck
			#j endReaderloop # if character is not space or newline, then end the loop (we handle null at the beginning)
			j InvaildEndCellBombLoop2
			
		validCharacter:
			move $t4, $t2
			j readerloop
		validCharacterCheck:
			beqz $t4, readerloop
			sb $t4 0($t0) 		#put the character in the array
			addi $t0, $t0, 1 	#moving the pointer by 1 byte
			addi $t3 $t3 1 		#incrementing the counter for number of characters in string
			li $t4, 0
			j readerloop
		validCharacterCheck2:		
			j readerloop
		validCharacter3:
			#move $t4, $t2
			bgt $t4, '0', InvaildEndCellBombLoop2
			j validCharacter
			
	endReaderloop:
		sb $t4 0($t0) 		#put the character in the array
		addi $t3 $t3 1
		addi $sp, $sp, -4
		sw $t3, 0($sp)		# number of string from the file
	
	breakVt100Loop:	
	# read 2 char from array, and add a bomb  -  repeat
	la $t4, textSpace
	li $t5, 0 			# counter for printing characters	
	read2charLoop:
		li $t0, 0xffff0000
		li $t1, 2			# for multiplication
		li $t6, 10			# for multiplication
		
		lb $t2 0($t4)
		beqz $t2 Endread2charLoop
		lb $t3 1($t4)
		addi $t4 $t4 2
	        
	        addi $t2 $t2 -48
	        addi $t3 $t3 -48	# (i*10)*2 + (j*2) + base address
	        
	        multu $t2, $t6		# lo = $t2 * 10
	        mflo  $t2
	        multu $t2, $t1		# lo = $t2 * 2
	        mflo  $t2
	        multu $t3, $t1		# lo = $t3 * 2
	        mflo  $t3
	        add $t6 $t3 $t2		# $t6 = (i*10)*2 + (j*2)
	        add $t0 $t0 $t6		# $t0 = $t6 + base		# set bomb location
	        
		addaBomb:
			li $t2, 'b'
			li $t1, 0xB7		# set bomb color
    			sb $t2, 0($t0)		# save bomb symbol
    			sb $t1, 1($t0)		# save bomb color
	j read2charLoop
	
	Endread2charLoop:		# Cells array
	lw $t0, 4($sp) # cells_array address 100
	
	li $t1, 0x00
	li $t2, 100	# number of cell
	
	initialCellLoop:
		beqz $t2, endinitialCellLoop
		sb $t1 0($t0) #put the character in the array
		addi $t0, $t0, 1 #moving the pointer by 1 byte
		addi $t2, $t2, -1
		j initialCellLoop
	
	endinitialCellLoop:	
	la $t4, textSpace
	lw $t1, 0($sp) # number of string from the file
	bgt $t1, 200, InvaildEndCellBombLoop
	CellBombLoop:
		ble $t1, 0, EndCellBombLoop
		lw $t0, 4($sp) # cells_array address 100
		li $t6, 10			# for multiplication
		
		lb $t2 0($t4)
		lb $t3 1($t4)
		addi $t4 $t4 2
	        addi $t1 $t1 -2			# number of string from file
	        
	        addi $t2 $t2 -48
	        addi $t3 $t3 -48		 # (i*10) + (j) + base address
	        move $t8, $t2
	        move $t9, $t3 
	        
	        multu $t2, $t6		# lo = $t2 * 10
	        mflo  $t2
	        add $t5 $t3 $t2		# $t6 = (i*10) + (j)
	        add $t0 $t0 $t5		# $t0 = $t5 + base(t0: cells_array)	set bomb location
	        
	        addBombCell:
	        	lb $t3, 0($t0)
	        	bge $t3, 32, repeatPosition
			li $t3, 0x20
			sb $t3, 0($t0)
			
		# adjacent 8cells	
		addi $t2 $t8 -1
		addi $t3 $t9 -1
		jal addAdjBombCell
		
		addi $t2 $t8 -1
		move $t3 $t9
		jal addAdjBombCell
		
		addi $t2 $t8 -1
		addi $t3 $t9 1
		jal addAdjBombCell
		
		move $t2 $t8
		addi $t3 $t9 -1
		jal addAdjBombCell
		
		move $t2 $t8
		addi $t3 $t9 1
		jal addAdjBombCell
		
		addi $t2 $t8 1
		addi $t3 $t9 -1
		jal addAdjBombCell
		
		addi $t2 $t8 1
		move $t3 $t9
		jal addAdjBombCell
		
		addi $t2 $t8 1
		addi $t3 $t9 1
		jal addAdjBombCell
		j CellBombLoop
		
		addAdjBombCell:
			beq $t2, -1, invaildcell
			beq $t3, -1, invaildcell
			beq $t2, 10, invaildcell
			beq $t3, 10, invaildcell
			multu $t2, $t6		# lo = $t2 * 10
			mflo  $t2
			add $t5 $t3 $t2		# $t6 = (i*10) + (j)
			lw $t0, 4($sp) # cells_array address 100
			add $t0 $t0 $t5		# $t0 = $t6 + base		# set bomb location
			lb $t3, 0($t0)
			addi $t3, $t3, 1 
			sb $t3, 0($t0)
		jr $ra
		
		repeatPosition:	# if the cell is already has boomb, do not increase size of adjboombcell
			j CellBombLoop
		
		invaildcell: 
			jr $ra
	
	EndCellBombLoop:
		lw $s2, 4($sp)
		lw $ra, 8($sp) # return to main
		addi $sp, $sp, 12
		li $v0, 0
   		jr $ra
   	InvaildEndCellBombLoop:
		lw $ra, 8($sp) # return to main
		addi $sp, $sp, 12
		li $v0, -1
   		jr $ra
   	InvaildEndCellBombLoop2:
		lw $ra, 4($sp) # return to main
		addi $sp, $sp, 12
		li $v0, -1	
##############################
# PART 3 FUNCTIONS
##############################

init_display:
	li $t0, 0xffff0002
    	li $t1, 0x77 # grey and black
    	li $t2, '\0'
    	li $t5, 99	# Count loop
	
	initLoop:				# set display as gray cells
    	        beqz $t5, EndinitLoop
    		sb $t2, 0($t0)
    		sb $t1, 1($t0)
    		addi $t0, $t0, 2
    		addi $t5, $t5, -1
    		j  initLoop
	
	EndinitLoop:				# set cursor
		li $t0, 0xffff0000
		li $t3, 0
		la $t1, cursor_row
		la $t2, cursor_col
		sb $t3, 0($t1)
		sb $t3, 0($t2)
		li $t1, 0xB0 # bg is yellow, fg is unmodified
    		#li $t2, '\0'	#unmodified
		lb $t1, 1($t0)
		andi $t1, $t1, 0x0F
		addi $t1, $t1, 0xB0
    		sb $t1, 1($t0)
    jr $ra

set_cell:
    move $t0, $a0	#cursor_row
    move $t1, $a1	#cursor_col
    #return case check
    blt $t0, 0, invaildSetCell
    bgt $t0, 9, invaildSetCell
    blt $t1, 0, invaildSetCell
    bgt $t1, 9, invaildSetCell
     
    move $t2, $a2	# symbol
    move $t3, $a3	# fg
    lw $t4, 0($sp)	

    
    #return case check
    blt $t3, 0, invaildSetCell
    bgt $t3, 15, invaildSetCell
    blt $t4, 0x00, invaildSetCell	# bg
    bgt $t4, 0xF0, invaildSetCell # bg
    
   	li $t6, 10
	mul $t0, $t0, $t6		# lo = $t2 * 10
	li $t6, 2
	mul $t0, $t0, $t6		# lo = $t2 * 2
	mul $t1, $t1, $t6		# lo = $t3 * 2
	add $t0, $t0, $t1		# $t0 = (i*10)*2 + (j*2)
	li $t6, 0xffff0000
	add $t6, $t0, $t6		# $t6 = $t0 + base
	
	add $t3, $t3, $t4	# bg +  fg
	sb $t2, 0($t6)	# symbol
    	sb $t3, 1($t6)	# color
    li $v0, 0
    jr $ra
    
	invaildSetCell:
    	li $v0, -1
   	 jr $ra
    

reveal_map:
	move $t7, $a1   # cells_array address 100
	beq $a0, -1, lostGame
	beq $a0, 0, EndreadCellArray #ongoing
	beq $a0, 1, smiley
	
	lostGame:	# reveal all cells, then reveal explored boomb
    	lb $t1, 0($t7)
    	li $t8, 0
    	readCellArray:
    		beq $t8, 100, EndreadCellArray
    		lb $t1, 0($t7)	# holds value of cell array
    		#sb $t1, 0($t7)	# save as revealed
    		
    		blt $t8, 10, donotDiv	# less than 10
    		
    		li $t2, 10	# Get i and js
    		div $t8, $t2
    		mfhi	$t2	# j
   		mflo	$t3	# i
    		move $a0, $t3	# row
   		move $a1, $t2	# col
    		addi $t7, $t7, 1
    		addi $t8, $t8, 1	# $t5 = i, ith to what cell shows
    		j afterDivide
    		
    		donotDiv:
    		li $a0, 0	# row
   		move $a1, $t8	# col
    		addi $t7, $t7, 1
    		addi $t8, $t8, 1	# $t5 = i, ith to what cell shows
    		
    		afterDivide:
    		andi $t2, $t1, 0x10
    		beq $t2, 0x10, addFlag
    		# if it has boom and flag, reveal flag
    		andi $t2, $t1, 0x20
    		beq $t2, 0x20, addBoom
    		andi $t1, $t1, 0x0F
    		j num
    	
    		addFlag:
    			andi $t2, $t1, 0x20	# has flag & bomb
    			beq $t2, 0x20, correctPositionFlag
    			# has flag & numb - wrong position - Bg: BrightRed, Fg:BrightBlue
    			li $t3, 'f'
    			li $t4, 0xC
    			li $t5, 0x90
    			j setCellValue
    		correctPositionFlag:	#bg: BrightGreen, Fg:BrightBlue	
    			li $t3, 'f'
    			li $t4, 0xC
    			li $t5, 0xA0
    			j setCellValue
    			
    		addBoom:	# bg:black, fg:grey
    			li $t3, 'b'
    			li $t4, 0x7
    			li $t5, 0x00
    			j setCellValue
		
		addNum0:
			li $t3, '\0'
			li $t4, 0xF		# num -fg - white
			li $t5, 0x00		# num -bg - black
    			j setCellValue
    		addNum1:
			li $t3, '1'
    			j setCellValue
    		addNum2:
			li $t3, '2'
    			j setCellValue
    		addNum3:
			li $t3, '3'
    			j setCellValue
    		addNum4:
			li $t3, '4'
    			j setCellValue
    		addNum5:
			li $t3, '5'
    			j setCellValue
    		addNum6:
			li $t3, '6'
    			j setCellValue
    		addNum7:
			li $t3, '7'
    			j setCellValue
    		addNum8:
			li $t3, '8'
    			j setCellValue
    		addNum9:
			li $t3, '9'
    			j setCellValue
		
    		setCellValue:	# set cursor row, col from above
    			move $a2, $t3		# new character
    			move $a3, $t4		# new foreground
    			addi $sp, $sp, -8	# new background
    			sw $ra 4($sp)
    			sw $t5 0($sp)
    			jal set_cell
    			
    			lw $ra 4($sp)
    			addi $sp, $sp, 8
    			j readCellArray
    		
    		num:
    			li $t4, 0xD		# num -fg - brightMagenta
			li $t5, 0x00		# num -bg - black
    			beq $t1, 0, addNum0
    			beq $t1, 1, addNum1
    			beq $t1, 2, addNum2
    			beq $t1, 3, addNum3
    			beq $t1, 4, addNum4
    			beq $t1, 5, addNum5
    			beq $t1, 6, addNum6
    			beq $t1, 7, addNum7
    			beq $t1, 8, addNum8
    			
    	EndreadCellArray:	# explore boomb, then end reveal all cells
    		la $t1, cursor_row
   		la $t2, cursor_col
   		lb $a0, 0($t1)
		lb $a1, 0($t2)
		li $a2, 'e'		# exploded boomb
    		li $a3, 0xF		# foreground - white
    		addi $sp, $sp, -8	# background - bright red
    		li $t5, 0x90
    		sw $ra 4($sp)
    		sw $t5 0($sp)
    		jal set_cell
    		beq $v0, -1, getReturnNegative
    		lw $ra 4($sp)
    		addi $sp, $sp, 8
    jr $ra

##############################
# PART 4 FUNCTIONS
##############################

perform_action:
	addi $sp $sp -4
	sw $a0 0($sp)	# cells_array
	move $fp, $sp
	
	addi $sp $sp -4
	sw $ra 0($sp)
	
	# $t0 = load address of current cursor in cells_array
    	la $t1, cursor_row
   	la $t2, cursor_col
   	lb $t1, 0($t1)
	lb $t2, 0($t2)
    
    beq $a1, 'f', flag
    beq $a1, 'F', flag
    beq $a1, 'r', reveal
    beq $a1, 'R', reveal
    beq $a1, 'w', moveUp
    beq $a1, 'W', moveUp
    beq $a1, 'a', moveLeft
    beq $a1, 'A', moveLeft
    beq $a1, 's', moveDown
    beq $a1, 'S', moveDown
    beq $a1, 'd', moveRight
    beq $a1, 'D', moveRight
    
	j invaildpoint
    
    flag:
    	addi $sp $sp -4
    	sw $ra 0($sp)
    	
    	lw $a0, 0($fp)	#load back cells_array
    	move $a1, $t1
   	move $a2, $t2
    	jal getAddressCellsArray	 # a0 : cells_array / a1 : row / a2 : col ------ return $v0
    	
    	lw $ra 0($sp)
    	addi $sp $sp 4
    	
    	lb $t0, 0($v0)
    	andi $t1, $t0, 0x40	# check it has reveal
    	beq $t1, 0x40, invaildpoint
    	
    	andi $t1, $t0, 0x10	# check it has a flag or not
    	beq $t1, 0x10, hasFlag
    	addi $t1, $t0, 0x10	# add Flag
    	sb $t1, 0($v0)
    	
    	la $t1, cursor_row
   	la $t2, cursor_col
   	lb $a0, 0($t1)
   	lb $a1, 0($t2)
    	li $a2, 'f'		# new character
    	li $a3, 0xC		# new fg - bright blue
    	li $t5, 0xB0		# new bg - yellow (default: grey 7)
    	addi $sp, $sp, -8	# new background
    	sw $ra, 4($sp)	#return address
    	sw $t5, 0($sp)
    			
    	jal set_cell
    	beq $v0, -1, getReturnNegative
    	
    	lw $ra, 4($sp)	#load back return address
   	addi $sp, $sp, 8
   	li $v0, 0
   	jr $ra
   	getReturnNegative:
    	lw $ra, 0($sp)	#load back return address
   	addi $sp, $sp, 4
   	li $v0, -1
   	jr $ra
   	
    	hasFlag:
    		addi $t0, $t0, -16	# unFlag
    		sb $t0, 0($v0)
    		
    		la $t1, cursor_row
   		la $t2, cursor_col
   		lb $a0, 0($t1)
		lb $a1, 0($t2)
    		li $a2, '\0'		# new character
    		li $a3, 0x7		# new fg - white
    		li $t5, 0xB0		# new bg - yellow (default: grey 7)
    		addi $sp, $sp, -8	# new background
    		sw $ra, 4($sp)	#return address
    		sw $t5, 0($sp)
    			
    		jal set_cell
    		beq $v0, -1, getReturnNegative
    		lw $ra, 4($sp)	#load back return address
   		addi $sp, $sp, 8
   		li $v0, 0
   		jr $ra

   reveal:
    	addi $sp $sp -4
    	sw $ra 0($sp)
    	lw $a0, 0($fp)	#load back cells_array
    	move $a1, $t1
   	move $a2, $t2
    	jal getAddressCellsArray	 # a0 : cells_array / a1 : row / a2 : col ------ return $v0
    	
    	lw $ra 0($sp)
    	addi $sp $sp 4
    	
    	lb $t0, 0($v0)
    	doReveal:
    	andi $t1, $t0, 0x20	# check it has a bomb
    	beq $t1, 0x20, hasBombYouDie
   	
    	andi $t1, $t0, 0x10	# check it has a flag or not
    	beq $t1, 0x10, hasFlagAndReveal
    	andi $t1, $t0, 0x40	# check it is revealed already
    	beq $t1, 0x40, invaildpoint
    	addi $t0, $t0, 0x40	# add reveal bit
    	sb $t0, 0($v0)
    	andi $t1, $t0, 0x0F	# check the number value
    
    	beq $t1, 0, singleNum0	# hidden cell! call search_cell
   	beq $t1, 1, singleNum1
    	beq $t1, 2, singleNum2
   	beq $t1, 3, singleNum3
    	beq $t1, 4, singleNum4
    	beq $t1, 5, singleNum5
    	beq $t1, 6, singleNum6
    	beq $t1, 7, singleNum7
    	beq $t1, 8, singleNum8	
    	
    	singleNum0Cursor:
    		li $a2, '\0'
    		j nextStep
    	
    	singleNum0:
    		#addi $t0, $t0, -0x40	# add reveal bit
    		#sb $t0, 0($v0)
    		li $a2, '\0'
    		addi $sp, $sp, -4	# new background
    		sw $ra, 0($sp)	#return address
    		
    		lw $a0, 0($fp)
    		la $t1, cursor_row
   		la $t2, cursor_col
   		lb $a1, 0($t1)
   		lb $a2, 0($t2)	
    		jal search_cells
    		
    		lw $ra, 0($sp)	#load back return address
   		addi $sp, $sp, 4
   		
   		la $t1, cursor_row
   		la $t2, cursor_col
   		lb $a0, 0($t1)
   		lb $a1, 0($t2)
    		li $a2, '\0'		# new character
    		li $a3, 0xF		# new fg - white
    		li $t5, 0xB0		# new bg - yellow (default: grey 7)
    		addi $sp, $sp, -8	# new background
    		sw $ra, 4($sp)	#return address
    		sw $t5, 0($sp)
    			
    		jal set_cell
    		beq $v0, -1, getReturnNegative	
    		lw $ra, 4($sp)	#load back return address
   		addi $sp, $sp, 8
   		
    		li $v0, 0
   		jr $ra
    	singleNum1:
    		li $a2, '1'
    		j nextStep
    	singleNum2:
    		li $a2, '2'
    		j nextStep
    	singleNum3:
    		li $a2, '3'
    		j nextStep
    	singleNum4:
    		li $a2, '4'
    		j nextStep
    	singleNum5:
    		li $a2, '5'
    		j nextStep
    	singleNum6:
    		li $a2, '6'
    		j nextStep
    	singleNum7:
    		li $a2, '7'
    		j nextStep
    	singleNum8:
    		li $a2, '8'
    		j nextStep
    	
    	nextStep:
    		la $t1, cursor_row
   		la $t2, cursor_col
   		lb $a0, 0($t1)
   		lb $a1, 0($t2)
    		#li $a2, 'f'		# new character
    		li $a3, 0xD		# new fg - bright magenta
    		li $t5, 0xB0		# new bg - yellow (default: grey 7)
    		addi $sp, $sp, -8	# new background
    		sw $ra, 4($sp)	#return address
    		sw $t5, 0($sp)
    			
    		jal set_cell
    		beq $v0, -1, getReturnNegative	
    		lw $ra, 4($sp)	#load back return address
   		addi $sp, $sp, 8
   		li $v0, 0
   		jr $ra
   	
   	hasFlagAndReveal:
    		addi $t0, $t0, -0x10	# unFlag
    		#addi $t0, $t0, 0x40	# reveal
    		sb $t0, 0($v0)
    		j doReveal # value check / boomb or number
   
    hasBombYouDie:
    	addi $t0, $t0, 0x40	# add 0x40 as reveal on bomb-cell
    	sb $t0, 0($v0)
    	move $a1, $a0
    	li $v0, 0
   	jr $ra
    	
    moveUp:
    	la $t3, cursor_row
    	la $t2, cursor_col
    	lb $t1, 0($t3)
    	lb $t2, 0($t2)
    	
    	beq $t1, 0, invaildpoint
    	
    	addi $sp $sp -4
    	sw $ra 0($sp)
    	jal resetCurrentCell
    	lw $ra 0($sp)
    	addi $sp $sp 4
    	
    	la $t3, cursor_row
    	la $t2, cursor_col
    	lb $t1, 0($t3)
    	lb $t2, 0($t2)
    	addi $t1, $t1, -1
    	sb $t1, 0($t3)
    	
    	j sameNext
    
    moveDown:
    	la $t3, cursor_row
    	la $t2, cursor_col
    	lb $t1, 0($t3)
    	lb $t2, 0($t2)
    	
    	beq $t1, 9, invaildpoint
    	
    	addi $sp $sp -4
    	sw $ra 0($sp)
    	jal resetCurrentCell
    	lw $ra 0($sp)
    	addi $sp $sp 4
    	
    	la $t3, cursor_row
    	la $t2, cursor_col
    	lb $t1, 0($t3)
    	lb $t2, 0($t2)
    	addi $t1, $t1, 1
    	sb $t1, 0($t3)
    
    	j sameNext
    
    moveLeft:
    	la $t1, cursor_row
    	la $t3, cursor_col
    	lb $t1, 0($t1)
    	lb $t2, 0($t3)
    	
    	beq $t2, 0, invaildpoint
    	
    	addi $sp $sp -4
    	sw $ra 0($sp)
    	jal resetCurrentCell
    	lw $ra 0($sp)
    	addi $sp $sp 4
    	
    	la $t1, cursor_row
    	la $t3, cursor_col
    	lb $t1, 0($t1)
    	lb $t2, 0($t3)
    	
    	addi $t2, $t2, -1
    	sb $t2, 0($t3)		# updated cursor_col
    	
    	j sameNext
    
    moveRight:
    	la $t1, cursor_row
    	la $t3, cursor_col
    	lb $t1, 0($t1)
    	lb $t2, 0($t3)
    	
    	beq $t2, 9, invaildpoint
    	
    	addi $sp $sp -4
    	sw $ra 0($sp)
    	jal resetCurrentCell
    	lw $ra 0($sp)
    	addi $sp $sp 4
    	
    	la $t1, cursor_row
    	la $t3, cursor_col
    	lb $t1, 0($t1)
    	lb $t2, 0($t3)
    	
    	addi $t2, $t2, 1
    	sb $t2, 0($t3)		# updated cursor_col
    	
    	sameNext:
    	# if the new cell is revealed, do not change, but yellow
    	addi $sp $sp -4
    	sw $ra 0($sp)
    	lw $a0, 0($fp)	#load back cells_array
    	move $a1, $t1
   	move $a2, $t2
    	jal getAddressCellsArray	 # a0 : cells_array / a1 : row / a2 : col ------ return $v0
    	
    	lw $ra 0($sp)
    	addi $sp $sp 4
    	
    	lb $t0, 0($v0)
    	andi $t1, $t0, 0x10	# check it has a flag or not
    	beq $t1, 0x10, hasFlagYellow
    	andi $t1, $t0, 0x40	# check it has a number
    	beq $t1, 0x40, hasNumYellow
    	
    	j onlyYellows
    	
    	hasFlagYellow:
    		la $t1, cursor_row
   		la $t2, cursor_col
   		lb $a0, 0($t1)
   		lb $a1, 0($t2)
    		li $a2, 'f'		# new character
    		li $a3, 0xC		# new fg - bright blue
    		li $t5, 0xB0		# new bg - yellow (default: grey 7)
    		addi $sp, $sp, -8	# new background
    		sw $ra, 4($sp)	#return address
    		sw $t5, 0($sp)
    			
    		jal set_cell
    		beq $v0, -1, getReturnNegative	
    		lw $ra, 4($sp)	#load back return address
   		addi $sp, $sp, 8
   		li $v0, 0
   		jr $ra
    	
    	hasNumYellow:
    		andi $t1, $t0, 0x0F	# check the number value
    		beq $t1, 0, singleNum0Cursor
   		beq $t1, 1, singleNum1
    		beq $t1, 2, singleNum2
   		beq $t1, 3, singleNum3
    		beq $t1, 4, singleNum4
    		beq $t1, 5, singleNum5
    		beq $t1, 6, singleNum6
    		beq $t1, 7, singleNum7
    		beq $t1, 8, singleNum8
    	
    	onlyYellows:	# unreveal - yellow&Grey
    		la $t1, cursor_row
   		la $t2, cursor_col
   		lb $a0, 0($t1)
   		lb $a1, 0($t2)
    		li $a2, '\0'		# new character
    		li $a3, 0x7		# new fg - grey
    		li $t5, 0xB0		# new bg - yellow (default: grey 7)
    		addi $sp, $sp, -8	# new background
    		sw $ra, 4($sp)	#return address
    		sw $t5, 0($sp)
    			
    		jal set_cell
    		beq $v0, -1, getReturnNegative	
    		lw $ra, 4($sp)	#load back return address
   		addi $sp, $sp, 8
   		li $v0, 0
   		jr $ra
	
	invaildpoint:
		li $v0, -1
		jr $ra
		
	resetCurrentCell:
		lw $a0, 0($fp)	#load back cells_array
		la $t1, cursor_row
   		la $t2, cursor_col
   		lb $t1, 0($t1)
		lb $t2, 0($t2)
		
		li $t5, 10
		mul $t3, $t1, $t5
 		add $t5, $t3, $t2		# $t6 = (i*10) + (j)
		add $t5, $a0, $t5		# $t0 = $t5 + a0 (cells_array)
		lb $t3, 0($t5)
		
		andi $t4, $t3, 0x40		# check whether it has reveal
    		beq $t4, 0x40, revealedKeepSymbolNocursor
    		andi $t4, $t3, 0x10		# check whether it has flag
    		beq $t4, 0x10, flaggdKeepSymbolNocursor
		
		move $a0, $t1
   		move $a1, $t2
    		li $a2, '\0'		# new character
    		li $a3, 0x0		# new fg - black
    		li $t5, 0x70		# new bg - grey
    		addi $sp, $sp, -8	# new background
    		sw $ra, 4($sp)	#return address
    		sw $t5, 0($sp)
    			
    		jal set_cell
    		beq $v0, -1, getReturnNegative	
    		lw $ra, 4($sp)	#load back return address
   		addi $sp, $sp, 8
   		li $v0, 0
   		jr $ra
   		
   		flaggdKeepSymbolNocursor:
   			move $a0, $t1
   			move $a1, $t2
    			li $a2, 'f'		# new character
    			li $a3, 0xC		# new fg - bright blue
    			li $t5, 0x70		# new bg - grey
    			addi $sp, $sp, -8	# new background
    			sw $ra, 4($sp)	#return address
    			sw $t5, 0($sp)
    			
    			jal set_cell
    			beq $v0, -1, getReturnNegative
    			lw $ra, 4($sp)	#load back return address
    			addi $sp, $sp, 8
   			li $v0, 0
   			jr $ra
   		revealedKeepSymbolNocursor:
   			andi $t3, $t3, 0x0F	# noflag, so keep shows the number
			li $a3, 0xD		# num -fg - bright magenta
			li $t5, 0x00		# num -bg - black
    			beq $t3, 0, NumZeroNocursor
    			beq $t3, 1, NumOneNocursor
    			beq $t3, 2, NumTwoNocursor
    			beq $t3, 3, NumThreeNocursor
    			beq $t3, 4, NumFourNocursor
    			beq $t3, 5, NumFiveNocursor
    			beq $t3, 6, NumSixNocursor
    			beq $t3, 7, NumSevenNocursor
    			beq $t3, 8, NumEightNocursor
   		NumZeroNocursor:
    			li $a2, '\0'
    			li $a3, 0xF		# num -fg - white
			li $t5, 0x00		# num -bg - black
    			j end2
    		NumOneNocursor:
    			li $a2, '1'
    			j end2
    		NumTwoNocursor:
    			li $a2, '2'
    			j end2
    		NumThreeNocursor:
    			li $a2, '3'
    			j end2
    		NumFourNocursor:
    			li $a2, '4'
    			j end2
    		NumFiveNocursor:
    			li $a2, '5'
    			j end2
    		NumSixNocursor:
    			li $a2, '6'
    			j end2
    		NumSevenNocursor:
    			li $a2, '7'
    			j end2
    		NumEightNocursor:
    			li $a2, '8'
    			j end2
    		end2:
    			move $a0, $t1
   			move $a1, $t2
    			addi $sp, $sp, -8	# new background
    			sw $ra, 4($sp)	#return address
    			sw $t5, 0($sp)
    			
    			jal set_cell
    			beq $v0, -1, getReturnNegative
    			lw $ra, 4($sp)	#load back return address
   			addi $sp, $sp, 8
   			li $v0, 0
   			jr $ra

game_status:
	move $t0, $a0	# $a0,	cells_array
	li $t5, 0	# Count loop
	li $t4, 0	# if it is not zero, ongoing
	checkCellsArray:				# set display as gray cells
    	        beq $t5, 100, EndCHECKs
    		lb $t2, 0($t0)

    		andi $t3, $t2, 0x20	# check boomb 
    		beq $t3, 0x20, hasBoomb
    		
    		andi $t3, $t2, 0x10	# noboomb, but check flag
    		beq $t3, 0x10, ongoingAdd	# hasFlagButBoomb, ongoing case
    		# noboom/noflag/has numbers, but no reveal case - incomplete
    		
    		andi $t3, $t2, 0x40	# check reveal
    		bne $t3, 0x40, ongoingAdd	# if it has a number and revealed, just continue loop, otherwise ongoing
    		j continueChecking	# noboomb
    		
    		ongoingAdd:
    			addi $t4, $t4, 1
    			j continueChecking
    		
    		hasBoomb:
    			andi $t3, $t2, 0x40	# has revealed - game lost! exploded bomb
    			beq $t3, 0x40, invaild
    			
    			andi $t3, $t2, 0x10	# check flag 
    			bne $t3, 0x10, ongoingAdd#NoFlagButBoomb	# incomplete
    			
    			# has boomb, has flag - skip
    			j continueChecking
    		NoFlagButBoomb:
    			li $v0, 0		# has boomb, but no flag - incomplete
    			jr $ra			# ongoing - incomplete
    		ongoing:
    			li $v0, 0		# has flag, but no boomb - incomplete
    			jr $ra			# ongoing - incomplete
    		invaild:	
    			li $v0, -1
    			jr $ra
    		continueChecking:
    			addi $t0, $t0, 1
    			addi $t5, $t5, 1
    			j  checkCellsArray
    EndCHECKs:
    		bnez $t4, ongoing
    		li $v0, 1	# game won
		jr $ra

##############################
# PART 5 FUNCTIONS
##############################

search_cells:
	addi $sp, $sp, -8
    	sw $a0, 4($sp)	#save returnAddress
    	sw $a0, 0($sp)	#save cells_array
    
    move $fp, $sp
    move $t0, $a1
    move $t1, $a2
    
    addi $sp, $sp, -8
    sw $t0, 4($sp)	#push cursor_row i
    sw $t1, 0($sp)	#push cursor_col j
    
    whileLoop:		# while(sp!=fp)
    	beq $fp, $sp, EndwhileLoop
    	
	lw $t1, 0($sp)	#pop cursor_col j
    	lw $t0, 4($sp)	#pop cursor_row i
    	addi $sp, $sp, 8
    	
    	addi $sp, $sp, -4
    	sw $ra, 0($sp)	#return address
   	move $a0, $t0
   	move $a1, $t1
    	jal gettingValueCellsArray	# $t3 get the returning value
    	lw $ra, 0($sp)	#load back return address
   	######### if the popped cell is revealed, jump to whileLoop again to pop next one
   
    	addi $sp, $sp, -8
    	sw $t3, 0($sp)	#save $t3 value
    	sw $t0, 4($sp)	#save current row
    	sw $t1, 8($sp)	#save current col
    	
    	andi $t4, $t3, 0x10		# if(!cell[row][col].isFlag())
    	bne $t4, 0x10, RevealTheCell	# cell[row][col].reveal
    	# after reveal. keep going
    	keepGoing:
    	lw $t3, 0($sp)	#load $t3 value
    	lw $t0, 4($sp)	#load $t3 value
    	lw $t1, 8($sp)	#load $t3 value
    	addi $sp, $sp, 12
    	
    	andi $t4, $t3, 0x0F
    	bnez $t4, whileLoop 	# if(cell[row][col].getNumber == 0) if not, goBackWhileLoop 
    	
    		# If row+1<10 && cell[row+1][col].isHidden() && !cell[row+1][col].isFlag()
    		addi $t4, $t0, 1
    		bge $t4, 10, resetSecondIf
    	
    		addi $sp, $sp, -4
    		sw $ra, 0($sp)	#return address
    		move $a0, $t4	# row + 1 from above
   		move $a1, $t1
    		jal gettingValueCellsArray	# $t3 get the returning value / $t0=$a0 / $t1=$a1
    		lw $ra, 0($sp)	#load back return address
   		addi $sp, $sp, 4
   	
   		andi $t4, $t3, 0x40
   		beq $t4, 0x40, resetSecondIf
   		andi $t4, $t3, 0x10
   		beq $t4, 0x10, resetSecondIf
   			addi $sp, $sp, -8	# push (row+1) push(col)
   			sw $t0, 4($sp)	#cursor_row i
    			sw $t1, 0($sp)	#cursor_col j
    			resetSecondIf:
    			addi $t0, $t0, -1	# restore original value
   			j SecondIf
   	SecondIf:	# If col+1<10 && cell[row][col+1].isHidden() && !cell[row][col+1].isFlag()
    		addi $t4, $t1, 1
    		bge $t4, 10, ThirdIf
    	
    		addi $sp, $sp, -4
    		sw $ra, 0($sp)	#return address
    		move $a0, $t0
   		move $a1, $t4
    		jal gettingValueCellsArray	# $t3 get the returning value
    		lw $ra, 0($sp)	#load back return address
   		addi $sp, $sp, 4
   	
   		andi $t4, $t3, 0x40
   		beq $t4, 0x40, resetThirdIf
   		andi $t4, $t3, 0x10
   		beq $t4, 0x10, resetThirdIf
   			addi $sp, $sp, -8	# push (row) push(col+1)
   			sw $t0, 4($sp)	#cursor_row i
    			sw $t1, 0($sp)	#cursor_col j
    			resetThirdIf:
    			addi $t1, $t1, -1	# restore original value
   			j ThirdIf
   	ThirdIf:	# If row-1 >= 0 && cell[row-1][col].isHidden() && !cell[row-1][col].isFlag()
    		addi $t4, $t0, -1
    		blt $t4, 0, FourthIf
    	
    		addi $sp, $sp, -4
    		sw $ra, 0($sp)	#return address
    		move $a0, $t4
   		move $a1, $t1
    		jal gettingValueCellsArray	# $t3 get the returning value
    		lw $ra, 0($sp)	#load back return address
   		addi $sp, $sp, 4
   	
   		andi $t4, $t3, 0x40
   		beq $t4, 0x40, resetFourthIf
   		andi $t4, $t3, 0x10
   		beq $t4, 0x10, resetFourthIf
   			addi $sp, $sp, -8	# push (row-1) push(col)
   			sw $t0, 4($sp)	#cursor_row i
    			sw $t1, 0($sp)	#cursor_col j
    			resetFourthIf:
    			addi $t0, $t0, 1	# restore original value
    			j FourthIf	
   	FourthIf:	# If col-1 >= 0 && cell[row][col-1].isHidden() && !cell[row][col-1].isFlag()
    		addi $t4, $t1, -1
    		blt $t4, 0, FifthIf
    	
    		addi $sp, $sp, -4
    		sw $ra, 0($sp)	#return address
    		move $a0, $t0
   		move $a1, $t4
    		jal gettingValueCellsArray	# $t3 get the returning value
    		lw $ra, 0($sp)	#load back return address
   		addi $sp, $sp, 4
   	
   		andi $t4, $t3, 0x40
   		beq $t4, 0x40, resetFifthIf
   		andi $t4, $t3, 0x10
   		beq $t4, 0x10, resetFifthIf
   			addi $sp, $sp, -8	# push (row) push(col-1)
   			sw $t0, 4($sp)	#cursor_row i
    			sw $t1, 0($sp)	#cursor_col j
    			resetFifthIf:
    			addi $t1, $t1, 1	# restore original value
    			j FifthIf
   	FifthIf:	# If row-1 >= 0 && col-1 >=0 && cell[row-1][col-1].isHidden() && !cell[row-1][col-1].isFlag()
    		addi $t3, $t0, -1
    		blt $t3, 0, SixthIf
    		addi $t4, $t1, -1
    		blt $t4, 0, SixthIf
    	
    		addi $sp, $sp, -4
    		sw $ra, 0($sp)	#return address
    		move $a0, $t3
   		move $a1, $t4
    		jal gettingValueCellsArray	# $t3 get the returning value
    		lw $ra, 0($sp)	#load back return address
   		addi $sp, $sp, 4
   	
   		andi $t4, $t3, 0x40
   		beq $t4, 0x40, resetSixthIf
   		andi $t4, $t3, 0x10
   		beq $t4, 0x10, resetSixthIf
   			addi $sp, $sp, -8	# push (row-1) push(col-1)
   			sw $t0, 4($sp)	#cursor_row i
    			sw $t1, 0($sp)	#cursor_col j
    			resetSixthIf:
    			addi $t0, $t0, 1	# restore original value
    			addi $t1, $t1, 1	# restore original value
    			j SixthIf
    	SixthIf:	# If row-1 >= 0 && col+1 < 10 && cell[row-1][col+1].isHidden() && !cell[row-1][col+1].isFlag()
    		addi $t3, $t0, -1
    		blt $t3, 0, SeventhIf
    		addi $t4, $t1, 1
    		bge $t4, 10, SeventhIf
    	
    		addi $sp, $sp, -4
    		sw $ra, 0($sp)	#return address
    		move $a0, $t3
   		move $a1, $t4
    		jal gettingValueCellsArray	# $t3 get the returning value
    		lw $ra, 0($sp)	#load back return address
   		addi $sp, $sp, 4
   	
   		andi $t4, $t3, 0x40
   		beq $t4, 0x40, resetSeventhIf
   		andi $t4, $t3, 0x10
   		beq $t4, 0x10, resetSeventhIf
   			addi $sp, $sp, -8	# push (row-1) push(col+1)
   			sw $t0, 4($sp)	#cursor_row i
    			sw $t1, 0($sp)	#cursor_col j
    			resetSeventhIf:
    			addi $t0, $t0, 1	# restore original value
    			addi $t1, $t1, -1	# restore original value
    			j SeventhIf
    	SeventhIf:	# If row+1 < 10 && col-1 >= 0 && cell[row+1][col-1].isHidden() && !cell[row+1][col-1].isFlag()
    		addi $t3, $t0, 1
    		bge $t3, 10, EighthIf
    		addi $t4, $t1, -1
    		blt $t4, 0, EighthIf
    	
    		addi $sp, $sp, -4
    		sw $ra, 0($sp)	#return address
    		move $a0, $t3
   		move $a1, $t4
    		jal gettingValueCellsArray	# $t3 get the returning value
    		lw $ra, 0($sp)	#load back return address
   		addi $sp, $sp, 4
   	
   		andi $t4, $t3, 0x40
   		beq $t4, 0x40, resetEighthIf
   		andi $t4, $t3, 0x10
   		beq $t4, 0x10, resetEighthIf
   			addi $sp, $sp, -8	# push (row+1) push(col-1)
   			sw $t0, 4($sp)	#cursor_row i
    			sw $t1, 0($sp)	#cursor_col j
    			resetEighthIf:
    			addi $t0, $t0, -1	# restore original value
    			addi $t1, $t1, 1	# restore original value
    			j EighthIf
    	EighthIf:	# If row+1 < 10 && col+1 < 10 && cell[row+1][col+1].isHidden() && !cell[row+1][col+1].isFlag()
    		addi $t3, $t0, 1
    		bge $t3, 10, doElse
    		addi $t4, $t1, 1
    		bge $t4, 10, doElse
    	
    		addi $sp, $sp, -4
    		sw $ra, 0($sp)	#return address
    		move $a0, $t3
   		move $a1, $t4
    		jal gettingValueCellsArray	# $t3 get the returning value
    		lw $ra, 0($sp)	#load back return address
   		addi $sp, $sp, 4
   	
   		andi $t4, $t3, 0x40
   		beq $t4, 0x40, resetdoElse
   		andi $t4, $t3, 0x10
   		beq $t4, 0x10, resetdoElse
   			addi $sp, $sp, -8	# push (row+1) push(col+1)
   			sw $t0, 4($sp)	#cursor_row i
    			sw $t1, 0($sp)	#cursor_col j
    			resetdoElse:
    			addi $t0, $t0, -1	# restore original value
    			addi $t1, $t1, -1	# restore original value
    	doElse:
    		j whileLoop
    	RevealTheCell:	#call set_cell
    		andi $t4, $t3, 0x20		# ! bomb
    		beq $t4, 0x20, keepGoing	# cell[row][col].reveal
    		move $a0, $t0
    		move $a1, $t1
    		
    		andi $t3, $t3, 0x0F
    		li $t4, 0xD		# num -fg - bright magenta
		li $t5, 0x00		# num -bg - black
    		beq $t3, 0, RevealNumZero
    		beq $t3, 1, RevealNumOne
    		beq $t3, 2, RevealNumTwo
    		beq $t3, 3, RevealNumThree
    		beq $t3, 4, RevealNumFour
    		beq $t3, 5, RevealNumFive
    		beq $t3, 6, RevealNumSix
    		beq $t3, 7, RevealNumSeven
    		beq $t3, 8, RevealNumEight
    		
    		RevealNumZero:
    			li $t3, '\0'
    			li $t4, 0xF		# num -fg - white
			li $t5, 0x00		# num -bg - black
    			j Revealend
    		RevealNumOne:
    			li $t3, '1'
    			j Revealend
    		RevealNumTwo:
    			li $t3, '2'
    			j Revealend
    		RevealNumThree:
    			li $t3, '3'
    			j Revealend
    		RevealNumFour:
    			li $t3, '4'
    			j Revealend
    		RevealNumFive:
    			li $t3, '5'
    			j Revealend
    		RevealNumSix:
    			li $t3, '6'
    			j Revealend
    		RevealNumSeven:
    			li $t3, '7'
    			j Revealend
    		RevealNumEight:
    			li $t3, '8'
    			j Revealend
    		
    		Revealend:
    			move $a2, $t3		# new character
    			move $a3, $t4		# new foreground
    			addi $sp, $sp, -8	# new background
    			sw $ra, 4($sp)	#return address
    			sw $t5, 0($sp)
    			
    			jal set_cell
    			
    			lw $ra, 4($sp)	#load back return address
   			addi $sp, $sp, 8
    			### set the value of this position is revealed
   			lw $t0, 4($sp)	#load row value
    			lw $t1, 8($sp)	#load col value
   			
   			addi $sp $sp -4
    			sw $ra 0($sp)
    	
    			lw $a0, 4($fp)	#load back cells_array
    			move $a1, $t0
   			move $a2, $t1
    			jal getAddressCellsArray	 # a0 : cells_array / a1 : row / a2 : col ------ return $v0
    	
    			lw $ra 0($sp)
    			addi $sp $sp 4
    			lb $a1, 0($v0)
    			move $a3, $a1
    			
    			andi $a3, $a1, 0x40	# check it is revealed already
    			beq $a3, 0x40, keepGoing
    			addi $a1, $a1, 0x40
   			sb $a1, 0($v0)
   			
    			j keepGoing
    EndwhileLoop:
    	addi $sp, $sp, 8
    	jr $ra
    		
gettingValueCellsArray:
	move $t0, $a0	# row
	move $t1, $a1	# col
	lw $a0 4($fp)		# $t3 holds the cell's value
	li $t5, 10		# get the value of cells_array
	mul $t2, $t0, $t5
 	add $t2 $t2 $t1		# $t6 = (i*10) + (j)
	add $t2 $a0 $t2		# $t0 = $t0 + a0 (cells_array)
    	lb $t3 0($t2)		# $t3 holds the cell's value
    	jr $ra
    	
# a0 : cells_array / a1 : row / a2 : col ------ return $v0
getValueCellsArray:
	move $t0, $a1	# row
	move $t1, $a2	# col
	li $t5, 10		# get the value of cells_array
	mul $t2, $t0, $t5
 	add $t2, $t2, $t1		# $t6 = (i*10) + (j)
	add $t2, $a0, $t2		# $t0 = $t0 + a0 (cells_array)
    	lb $v0 0($t2)		# $t3 holds the cell's value
    	jr $ra
getAddressCellsArray:
	move $t0, $a1	# row
	move $t1, $a2	# col
	li $t5, 10		# get the value of cells_array
	mul $t2, $t0, $t5
 	add $t2, $t2, $t1		# $t6 = (i*10) + (j)
	add $t2, $a0, $t2		# $t0 = $t0 + a0 (cells_array)
    	move $v0, $t2		# $t3 holds the cell's value
    	jr $ra

#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary
cursor_row: .word -1
cursor_col: .word -1

#place any additional data declarations here
textSpace: .space 400     #space to store strings to be read
inputBuffer: .space 1      #buffer to take value
