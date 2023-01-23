.ORIG x3000

LDI R6, STACK_PTR
LD R0, GET_SIZE_STRING_PTR ;get size
PUTS
;int GetNum()
JSR GetNum
ADD R3, R0, #0 ;save size
LD R0, GET_MAZE_STRING_PTR 

LD R1, PTR_ARRAY
STR R1, R6, #-2			; loading the first parameter to the stack - ARRAY
STR R3, R6, #-1			; loading the second parameter to the stack - SIZE
ADD R6, R6, #-2			; Update R6
JSR GetMatrix		    ; calling to the function
ADD R6, R6, #2			; folding the stack

ADD R2, R0, #0 ;save matrix pointer
ADD R3, R3, #-1 ;(R3,R3) - the last index in the matrix
LD R0, FIND_PATH_STRING_PTR ;print that the matrix is legal
PUTS
AND R0, R0, #0


STR R0, R6, #-4 ;i=0
STR R0, R6, #-3 ;j=0
STR R3, R6, #-2 ;last_index
STR R2, R6, #-1 ;matrix ptr
ADD R6, R6, #-4 ;update R6

;int SearchPath(int i, int j, int last_index, int* matrix) - if found path and mark (*) and return 1, else 0
JSR SearchPath
ADD R6, R6, #4
ADD R0, R0, #0 ;save return val
BRz END ;if we found a legal path, return val = 1
ADD R0, R0, #9
OUT
LD R0, FOUND_STRING_PTR 
PUTS
AND R0, R0, #0
ADD R0, R0, #10
OUT
 
ADD R3, R3, #1

STR R1, R6, #-2			; loading the first parameter to the stack - ARRAY
STR R3, R6, #-1			; loading the second parameter to the stack - SIZE
ADD R6, R6, #-2			; Update R6
JSR printMatrix		    	; calling to the function
ADD R6, R6, #2			; folding the stack
BR DONE

END:
	ADD R0, R0, #10
	OUT 
    	LD R0, NOT_FOUND_STRING_PTR ;if we didnt found a path
    	PUTS

DONE

HALT
PTR_ARRAY .fill ARRAY
GET_SIZE_STRING_PTR .FILL GET_SIZE_STRING
GET_MAZE_STRING_PTR .FILL GET_MAZE_STRING
FIND_PATH_STRING_PTR .FILL FIND_PATH_STRING
NOT_FOUND_STRING_PTR .FILL NOT_FOUND_STRING
FOUND_STRING_PTR .FILL FOUND_STRING
STACK_PTR .FILL STACK

;int SearchPath(int i, int j, int last_index, int* matrix)
SearchPath:
	ADD R6, R6, #-6
    	STR R1, R6, #0 ;R1 - i
	STR R2, R6, #1 ;R2 - j
	STR R3, R6, #2 ;R3 - last index
    	STR R4, R6, #3 ;R4 - matrix ptr
	STR R5, R6, #4 ;R5 - matrix corrent cell
	STR R7, R6, #5 

	AND R0, R0, #0
    	LDR R1, R6, #6 ;R1 - i val
    	LDR R2, R6, #7 ;R1 - j val
    	LDR R3, R6, #8 ;R3 - last index
    	LDR R4, R6, #9 ;R4 - matrix ptr
	
    	;test if we in a legal cell 1 or 0
    	;matrix(i,j) = first_cell_add + i + j*row_size
    	ADD R5, R4, R1 
    	ADD R3, R3, #1
	ADD R4, R0, #0 ;save ret val

    	STR R3, R6, #-2 ;load for mul
    	STR R2, R6, #-1
    	ADD R6, R6, #-2
    	JSR Mul
    	ADD R6, R6, #2
	
	ADD R3, R3, #-1
    	ADD R5, R0, R5 ;R5 = first_cell_add + i + j*row_size
	ADD R0, R4, #0

    	LDR R4, R5, #0  ;MATRIX[i][j] val
    	BRz END_SEARCH ;if the cell is 0 - return
 	
    	;test if we reched (n,n) - done if 1
    	NOT R3, R3
    	ADD R3, R3, #1 ;R3 = -last_index    
    	ADD R4, R3, R1 
    	BRnp SEARCH_RIGHT ;test if we in the matrix[n][n]=1 return true
    	ADD R4, R3, R2 
    	BRz RETURN_TRUE

	;recu search in matrix[i+1][j]
	SEARCH_RIGHT:
		LDR R3, R6, #8 ;R3 - last index
        	NOT R3, R3
        	ADD R3, R3, #1 
        	ADD R3, R3, R1
        	BRz SEARCH_DOWN ;if i = col_len
		LDR R4, R5, #1
		BRz SEARCH_DOWN ;if zreo
		LDI R3, WAS_MINUS_PTR ;if was in him 
		ADD R3, R4, R3
		BRz SEARCH_DOWN

		LDI R3, FOUND_ALREADY_PTR ;if we have a legal path with him
		ADD R4, R4, R3
		BRz END_SEARCH
		
		LDI R3, WAS_IN_PTR ;if was in him an
		STR R3, R5, #0 ;sing that we was in him
		LDR R3, R6, #8 ;R3 - last index
    		LDR R4, R6, #9 ;R4 - matrix ptr
        	ADD R1, R1, #1

        	STR R1, R6, #-4 ;i=i+1
        	STR R2, R6, #-3 ;j=j
        	STR R3, R6, #-2 ;last_index
        	STR R4, R6, #-1 ;matrix ptr
        	ADD R6, R6, #-4 ;update R6
        	JSR SearchPath
        	ADD R6, R6, #4

        	ADD R1, R1, #-1
        	ADD R0, R0, #0 ;if we didnt found a path
        	BRnp RETURN_TRUE

	;recu search in matrix[i][j+1]
	SEARCH_DOWN:
		LDR R3, R6, #8 ;R3 - last index
        	NOT R3, R3
        	ADD R3, R3, #1 
        	ADD R3, R3, R2
       		BRz SEARCH_UP ;if j = col_len

		LDR R3, R6, #8 ;R3 - last index
		ADD R3, R3, #1
		ADD R4, R5, R3 ;add of down cel
		LDR R4, R4, #0
		BRz SEARCH_UP ;if zreo
		LDI R3, WAS_MINUS_PTR ;if was in him 
		ADD R4, R4, R3
		BRz SEARCH_UP

		LDI R3, FOUND_ALREADY_PTR ;if we have a legal path with him
		ADD R4, R4, R3
		BRz END_SEARCH

		LDI R3, WAS_IN_PTR ;if was in him an
		STR R3, R5, #0 ;sing that we was in him

		LDR R3, R6, #8 ;R3 - last index
    		LDR R4, R6, #9 ;R4 - matrix ptr
        	ADD R2, R2, #1

        	STR R1, R6, #-4 ;i=i
        	STR R2, R6, #-3 ;j=j+1
        	STR R3, R6, #-2 ;last_index
        	STR R4, R6, #-1 ;matrix ptr
        	ADD R6, R6, #-4 ;update R6
        	JSR SearchPath
        	ADD R6, R6, #4

        	ADD R2, R2, #-1
        	ADD R0, R0, #0 ;if we didnt found a path
        	BRnp RETURN_TRUE

	;recu search in matrix[i][j-1]
	SEARCH_UP:
        	ADD R2, R2, #0 ;if exists row up
        	BRz SEARCH_LEFT ;if j != 0
		LDR R3, R6, #8 ;R3 - last index
		ADD R3, R3, #1
		NOT R3, R3
		ADD R3, R3, #1
		ADD R4, R5, R3 ;add of up cel
		LDR R4, R4, #0
		BRz SEARCH_LEFT ;if zreo
		LDI R3, WAS_MINUS_PTR ;if was in him 
		ADD R4, R4, R3
		BRz SEARCH_LEFT
		LDI R3, FOUND_ALREADY_PTR ;if we have a legal path with him
		ADD R4, R4, R3
		BRz END_SEARCH

		ADD R2, R2, #-1
		LDI R3, WAS_IN_PTR ;if was in him an
		STR R3, R5, #0 ;sing that we was in him
		LDR R3, R6, #8 ;R3 - last index
    		LDR R4, R6, #9 ;R4 - matrix ptr
        	STR R1, R6, #-4 ;i=i
        	STR R2, R6, #-3 ;j=j-1
        	STR R3, R6, #-2 ;last_index
        	STR R4, R6, #-1 ;matrix ptr
        	ADD R6, R6, #-4 ;update R6
        	JSR SearchPath
        	ADD R6, R6, #4

        	ADD R2, R2, #1
        	ADD R0, R0, #0 ;if we didnt found a path
        	BRnp RETURN_TRUE
	
	SEARCH_LEFT:
        	;recu search in matrix[i-1][j]
        	ADD R1, R1, #0 ;if exists col left
        	BRz END_SEARCH
		LDR R4, R5, #-1
		BRz END_SEARCH ;if zreo
		LDI R3, WAS_MINUS_PTR ;if was in him 
		ADD R3, R4, R3
		BRz END_SEARCH
		
		LDI R3, FOUND_ALREADY_PTR ;if we have a legal path with him
		ADD R4, R4, R3
		BRz END_SEARCH

		LDI R3, WAS_IN_PTR ;if was in him an
		STR R3, R5, #0 ;sing that we was in him
		LDR R3, R6, #8 ;R3 - last index
    		LDR R4, R6, #9 ;R4 - matrix ptr
        	ADD R1, R1, #-1
        	STR R1, R6, #-4 ;i=i-1
        	STR R2, R6, #-3 ;j=j
        	STR R3, R6, #-2 ;last_index
        	STR R4, R6, #-1 ;matrix ptr
        	ADD R6, R6, #-4 ;update R6
        	JSR SearchPath
        	ADD R6, R6, #4

        	ADD R1, R1, #1 
        	ADD R0, R0, #0 ;if we didnt found a path
        	BRz END_SEARCH ;else
    
	RETURN_TRUE:
		LDI R3, FOUND_PTR ;if we found
        	STR R3, R5, #0 ;matrix[i][j] = true
        	AND R0, R0, #0 ;return 1
		ADD R0, R0, #1

	END_SEARCH:
        	LDR R1, R6, #0 
	    	LDR R2, R6, #1 
	    	LDR R3, R6, #2 
        	LDR R4, R6, #3 
	    	LDR R5, R6, #4 
	    	LDR R7, R6, #5
        	ADD R6, R6, #6

RET
FOUND_PTR .FILL FOUND
FOUND_ALREADY_PTR .FILL FOUND_ALREADY
WAS_IN_PTR .FILL WAS_IN
WAS_MINUS_PTR .FILL MINUS_WAS

;int Mul(int first, int second)
Mul:
	ADD R6, R6, #-6 
	STR R1, R6, #0 ;R1 - save first num
	STR R2, R6, #1 ;R2 - save mul result
	STR R3, R6, #2 ;R3 - save first num val
	STR R4, R6, #3 ;R4 - save mul result
	STR R5, R6, #4 ;R5 - flag for mul sign
	STR R7, R6, #5 

	AND R4, R4, #0; resets registers
	AND R3, R3, #0
	AND R2, R2, #0
	AND R5, R5, #0

	LDR R0, R6, #6 ;save first num val
	LDR R1, R6, #7 ;save second num val 
	ADD R0, R0, #0; if one is zero, end mul return zero
	BRz END_MUL
	ADD R1, R1, #0; if one is zero, end mul return zero
	BRz END_MUL

	ADD R2, R0, #0
	ADD R3, R1, #0

	ADD R2, R2, #0; if R0 negative - test msb is 1, turn into posi and save old sign (in R5)
	BRp WHILE_LOOP
	NOT R2, R2; turn R0 to positive
	ADD R2, R2, #1

	WHILE_LOOP:
		AND R5, R2, R2; while we still need to mul - R2 - counter > 0
		BRz END_LOOP
		ADD R4, R4, R3; mul_res = mul_res + R3
		ADD R2, R2, #-1
		BR WHILE_LOOP

	END_LOOP:
		ADD R0, R0, #0; if R0 was negative (R5 == R0) negatiev->neg * neg / neg * posi - need to change sign
		BRp END_MUL
		NOT R4, R4
		ADD R4, R4, #1

	END_MUL:
		ADD R0, R4, #0 ;save return val 
	    	LDR R1, R6, #0 
	    	LDR R2, R6, #1 
	   	LDR R3, R6, #2
        	LDR R4, R6, #3 
	    	LDR R5, R6, #4 
	    	LDR R7, R6, #5
        	ADD R6, R6, #6 ;pop 
RET


;int GetNum()
GetNum:
    	ADD R6, R6, #-4 
	STR R1, R6, #0 ;R1 - save 10 - for Mul
	STR R2, R6, #1 ;R2 - save mul result
	STR R5, R6, #2 ;R5 - for alu actions
	STR R7, R6, #3 
	
	AND R2, R2, #0
	AND R1, R1, #0
    	AND R5, R5, #0
	ADD R1, R1, #10

	GET_NUM_LOOP: 
		GETC ;get char
		OUT ;print char
		ADD R0, R0, #-10 ;if its enter - end loop
		BRz END_PRINT
		ADD R0, R0, #10

		LOOP_TESTS:
            		LDI R5, MINUS_ASCII_PTR ;save ascii minus val in R5
			ADD R0, R0, R5 ;new digit val
			ADD R5, R0, #0	
			ADD R2, R2, #0 ;if its user first num (after minus or without)
			BRz FIRST_NUM		
			
			STR R2, R6, #-2 ;lode first num ;old num
            		STR R1, R6, #-1 ;load second num ;10
            		ADD R6, R6, #-2 
			JSR Mul ;old_val*10 

			ADD R6, R6, #2 ;return and close 
			ADD R2, R0, R5 ;old*10 + new_digit 
			BR GET_NUM_LOOP

		FIRST_NUM:
			ADD R2, R0, #0
			BR GET_NUM_LOOP
		
	END_PRINT:
		ADD R0, R2, #0 ;save return value
	    	LDR R1, R6, #0 ;R1 - save 10 - for Mul
	    	LDR R2, R6, #1 ;R2 - save mul result
	    	LDR R5, R6, #2 ;R5 - for alu actions
	    	LDR R7, R6, #3 
		ADD R6, R6, #4 ;pop 

RET
MINUS_PTR .FILL MINUS
MINUS_ASCII_PTR .FILL MINUS_ASCII

GetMatrix: ; int** GetMatrix(int **ARRAY, int SIZE)
    	; restoring the registers
	ADD R6, R6, #-6
	STR R7, R6, #0
	STR R5, R6, #1
	STR R4, R6, #2
	STR R3, R6, #3
	STR R2, R6, #4
	STR R1, R6, #5
	
	; the body of the function
	AGAIN_GetMatrix: ; if needed to enter numbers again because of a error
	AND R0, R0, #0
	ST R0, FLAG_getMetrix
    	LDR R1, R6, #6			; R1 <- ARRAY
    	LDR R2, R6, #7			; R2 <- SIZE
    
    	LD R0, POINTER_GET_MATRIX_STRING ; printing the massage
    	PUTS
    	LDI R0, POINTER_PLUS_ENTER
    	OUT
	; tracking the current row
    	AND R4, R4, #0 
    	AND R3, R3, #0
        AND R5, R5, #0
	ADD R5, R5, R2 ; counter of the rows
		ADD R3, R3, R1 ; pointer to the current cell
		ST R1, METRIX_POINTER
    	GETC ; first input has to be 1
    	OUT
    	LDI R1, POINTER_MINUS_ASCII
    	ADD R0, R0, R1
    	ADD R0, R0, #-1
	
    	BRz FIRST_NUMBER_VALID ; checking if the first number is 1(else this is error)
        	AND R0, R0, #0
        	ADD R0, R0, #1
        	ST R0, FLAG_getMetrix ; change the flag to 1(there is an error)
    	FIRST_NUMBER_VALID:
    	ADD R0, R0, #1
    	STR R0, R3, #0 ; storing the first number into the array
		ADD R3, R3, #1
        	LOOP_INPUT: ; enter to the whole row the input that the user insert	
			GETC
            		OUT
            		LDI R1, POINTER_MINUS_SPACE ; check if space
            		ADD R0, R0, R1
            		BRz LOOP_INPUT
            		LDI R1, POINTER_PLUS_SPACE
            		ADD R0, R0, R1
            		LDI R1, POINTER_MINUS_ENTER ; check if enter
            		ADD R0, R0, R1
            		BRz END_ROW
            		LDI R1, POINTER_PLUS_ENTER
            		ADD R0, R0, R1
            		LDI R1, POINTER_MINUS_ASCII
            		ADD R0, R0, R1
            		BRzp DIGIT_IS_VALID1 ; check if the digit is 1 or 0
                		AND R0, R0, #0
                		ADD R0, R0, #1
                		ST R0, FLAG_getMetrix ; change the flag to 1 if there is an error
            		DIGIT_IS_VALID1:
            		ADD R0, R0, #-2
            		BRn DIGIT_IS_VALID2 ; check if the digit is 1 or 0
                		AND R0, R0, #0
                		ADD R0, R0, #1
                		ST R0, FLAG_getMetrix ; change the flag to 1 if there is an error
            		DIGIT_IS_VALID2:
            		ADD R0, R0, #2    
            		STR R0, R3, #0
            		ADD R3, R3, #1
            	BR LOOP_INPUT ; input the next numer
		END_ROW:
			ADD R5, R5, #-1 ; counter down of the number of rows
            		BRp LOOP_INPUT
    			ADD R3, R3, #-1
    			LDR R0, R3, #0 ; load the last number and check if the 1 or error
    			BRnp LAST_NUMBER_VALID
        			AND R0, R0, #0
        			ADD R0, R0, #1
        			ST R0, FLAG_getMetrix ; change the flag to 1 if there is an error
    			LAST_NUMBER_VALID:
    			LD R0, FLAG_getMetrix
    			BRnz VALID ; in a case of error, print the massage and go back to the function and input again
				LD R0, POINTER_MAZE_ERROR
				PUTS
				AND R0, R0, #0
				ADD R0, R0, #10 ; print enter
				OUT
        			BR AGAIN_GetMatrix ; enter the metrix again in case of an error
    	VALID:
	LD R0, METRIX_POINTER ; load pointer to the beggining of the array
    	; restoring the registers
    	LDR R7, R6, #0
    	LDR R5, R6, #1
    	LDR R4, R6, #2
    	LDR R3, R6, #3
    	LDR R2, R6, #4
    	LDR R1, R6, #5

    	ADD R6, R6, #6		; pop stack frame = #local variables + #register save
RET

METRIX_POINTER .fill #0
POINTER_MAZE_ERROR .fill MAZE_ERROR
POINTER_GET_MATRIX_STRING .fill GET_MATRIX_STRING
FLAG_getMetrix .fill #0
POINTER_MINUS_SPACE .fill MINUS_SPACE
POINTER_PLUS_SPACE .fill PLUS_SPACE
POINTER_MINUS_ENTER .fill MINUS_ENTER
POINTER_PLUS_ENTER .fill PLUS_ENTER
POINTER_MINUS_ASCII .fill MINUS_ASCII
POINTER_PLUS_ASCII .fill PLUS_ASCII

printMatrix: ; VOID printMatrix(int **arr, int length)
    	; storing the registers
	ADD R6, R6, #-6
	STR R7, R6, #0
	STR R5, R6, #1
	STR R4, R6, #2
	STR R3, R6, #3
	STR R2, R6, #4
	STR R1, R6, #5

	LDR R1, R6, #6			; R1 <- ARRAY
	LDR R2, R6, #7			; R2 <- SIZE
    
	; start of the function content
	AND R4, R4, #0
	AND R5, R5, #0
	ADD R5, R5, R2 ; storing the size of the array in R5

	COL_LOOP_printMatrix:
		AND R3, R3, #0
		ADD R3, R3, R2
		ROW_LOOP_printMatrix: ; printing all the current row(depend on size value that the user gave)
        		LDR R0, R1, #0
			ADD R0 ,R0, #-2
			BRnp NOT_TWO
				ADD R0, R0, #-1 ; if the value is 2, we switch to 1
			NOT_TWO:
			ADD R0, R0, #2
        		LDI R4, POINTER_PLUS_ASCII
        		ADD R0, R0, R4
        		OUT
        		ADD R3, R3, #-1 ; counter down
        	BRz IF_ROW_ENDED
			LDI R0, POINTER_PLUS_SPACE
	    		OUT ; space between the numberS
        		ADD R1, R1, #1
    		BR ROW_LOOP_printMatrix
		IF_ROW_ENDED:
			ADD R1, R1, #1 ; mobing to the next cell in the metrix
	    		ADD R5, R5, #-1 ; counter down of the number of rows
	    		BRz IF_PRINTING_ENDED
	    		LD R0, PLUS_ENTER
        		OUT
	BR COL_LOOP_printMatrix
    	IF_PRINTING_ENDED:
	; end of the function content

        ; restoring the registers
	LDR R7, R6, #0
	LDR R5, R6, #1
	LDR R4, R6, #2
	LDR R3, R6, #3
	LDR R2, R6, #4
	LDR R1, R6, #5

	ADD R6, R6, #6		; pop stack frame = #local variables + #register save
RET

; labels that we use in all of the functions -------------
MINUS_SPACE .fill #-32
MINUS_ENTER .fill #-10
MINUS_ASCII .fill #-48
PLUS_SPACE .fill #32
PLUS_ENTER .fill #10
PLUS_ASCII .fill #48

FOUND .FILL #-6
FOUND_ALREADY .FILL #6
ENTER_ASCII .fill #10
MINUS .FILL #-45
STACK .FILL XBFFF
WAS_IN .FILL #2
MINUS_WAS .FILL #-2

; --------------------------------------------------------
; STRINGS ------------------------------------------------
WELCOME_STRING .STRINGZ "Enter an integer number: "
GET_SIZE_STRING .STRINGZ "Please enter a number between 2 to 20: "
GET_MAZE_STRING .STRINGZ "Please enter the maze matrix:"
FIND_PATH_STRING .STRINGZ "The mouse is hopeful he will find his cheese..."
NOT_FOUND_STRING .STRINGZ "OH NO! It seems the mouse has no luck in this maze..."
FOUND_STRING .STRINGZ "Yummy! The mouse has found the cheese!"
BETWEENFUNC .stringz "pass function"
GET_MATRIX_STRING .stringz "Please enter the maze matrix:"
MAZE_ERROR .stringz "Illegal maze! Please try again:"
; --------------------------------------------------------
ARRAY   .blkw #20 #-1 ; row 1
		.blkw #20 #-1 ; row 2
		.blkw #20 #-1 ; row 3
		.blkw #20 #-1 ; row 4
		.blkw #20 #-1 ; row 5
		.blkw #20 #-1 ; row 6
		.blkw #20 #-1 ; row 7
		.blkw #20 #-1 ; row 8
		.blkw #20 #-1 ; row 9
		.blkw #20 #-1 ; row 10
		.blkw #20 #-1 ; row 11
		.blkw #20 #-1 ; row 12
		.blkw #20 #-1 ; row 13
		.blkw #20 #-1 ; row 14
		.blkw #20 #-1 ; row 15
		.blkw #20 #-1 ; row 16
		.blkw #20 #-1 ; row 17
		.blkw #20 #-1 ; row 18
		.blkw #20 #-1 ; row 19
		.blkw #20 #-1 ; row 20
; ---------------------------------------------------------

.END
