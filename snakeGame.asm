;////////////////////SYSTEM PROGRAMMING TERM PROJECT///////////////////////////
;
; ***	Emin Yüce	
; 
;
; -This program is a snake game that programmed in 16-bit real-address mode in assembly language. It includes four edges which surround
;  game area, a snake that moves consistently, a food which is created randomly, and two walls in the following level
; -Snake is a struct array that consists of x and y coordinates. To print the snake on the console, single 'o' character is used.
; -Food consists of 'x' character, and is created randomly on the screen. When the snake eat the food, it grows up and the food
;  created again.0 
; -Game is controlled with w,a,s,d. (w = north, a = west, s = south, d = east)   w	 esc = exit the game
;															   a s d
; -	    

TITLE Snake

INCLUDE Irvine16.inc


snakeLength=15			; Keep the max length of the snake
stones=4			; Keep the length of the wall

up_=1				; Up
down_=2				; Down
left_=3				; Left
right_=4				; Right

true=5				; boolean true
false=6				; boolean false


;Data Segment____________________________________________________________
.data

; Struct of the snake
Snake_ STRUCT
x BYTE ?
y BYTE ?
Snake_ ENDS

; Struct of the stone
Stone_ STRUCT
xPos BYTE ?
yPos BYTE ?
Stone_ ENDS

;------------------------------------------------------------------------
;Procedures Prototype
PrintConsole PROTO
DuvarBas PROTO
Elemanlar  PROTO, currX:BYTE,currY:BYTE
;------------------------------------------------------------------------

snake Snake_ snakeLength DUP(<?,?>)
wall Stone_ stones DUP(<?,?>)
wall2 Stone_ stones DUP(<?,?>)

;------------------------------------------------------------------------
; Coordinate variables
;------------------------------------------------------------------------
Xpos BYTE ?	
Ypos BYTE ?
Xcu BYTE ?
Ycu BYTE ?
eatX BYTE ?
eatY BYTE ?
yStone BYTE 8
xStone BYTE 60
xStone2 BYTE 20
yStone2 BYTE 8

;------------------------------------------------------------------------
; Messages
;------------------------------------------------------------------------
s DWORD 9
char BYTE 'a'
message BYTE "                           GAME OVER      ",0
messe BYTE "                             GAME OVER      ",0
mes BYTE "CONGRATULATION, You win",0
mes2 BYTE "CONGRATULATION, You win",0
messa BYTE "              WELCOME TO SNAKE GAME",0
messa2 BYTE "                 You can play the game by using",0
messa3 BYTE "                 w(up),a(left),s(down),d(right) and esc(exit) buttons",0
level2Message BYTE "Level 2 is beginning",0
isLevel byte 0
yourScore BYTE "Your Score  :",0
eat BYTE ?
isMeal BYTE ?
t DWORD ?
Bonus DWORD 0
speed DWORD 2000
;________________________________________________________________________


;Code Segment____________________________________________________________
.code

main PROC
	mov ax,@data
	mov ds,ax

	;-----------------------------------------------
	;//////// Print the game start message \\\\\\\\\
	mov dl,10
	mov dh,10
	call Gotoxy
	mov edx,OFFSET messa
	call WriteString
	call Crlf
	mov edx,OFFSET messa2
	call WriteString
	call Crlf
	mov edx,OFFSET messa3
	call WriteString
	call Crlf
	call WaitMsg

	mov eax,0

begin_level:

	mov eax,0

	cmp isLevel,1
	jne noLevel

	mov ecx,0
	mov esi,0
	mov edi,0

	mov ecx,stones
	mov esi,OFFSET wall
	mov al,0

DUVAR:
	mov al,yStone
	mov (wall[esi]).yPos,al
	inc yStone
	mov al,xStone
	mov (wall[esi]).xPos,al

	mov al,yStone2
	mov (wall2[esi]).yPos,al
	inc yStone2
	mov al,xStone2
	mov (wall2[esi]).xPos,al

	add esi, TYPE wall
	Loop DUVAR

	mov esi,OFFSET snake

	call DuvarBas
	mov char,left_

noLevel:

	mov Xpos,35
	mov Ypos,12

	mov isMeal,false
	mov esi,OFFSET snake
	mov ecx,s

;/////////////////The first length of snake//////////////////////
L2:
	mov al,Xpos
	mov (snake[esi]).x,al
	mov al,Ypos
	mov (snake[esi]).y,al
	inc Xpos
	add esi,TYPE snake

	Loop L2
;/////////////////////////////////////////////////////////////

	mov esi,OFFSET snake

;////////////////////// Game Loop \\\\\\\\\\\\\\\\\\\\\\
Game_Start:


	call ClrScr

	;////////////////////// isMeal
	;////////////////////// Check the food is whether eaten or not
	;////////////////////// If food is eaten (isMeal) is false then generate a new food
	cmp isMeal,false
	jne atla
	mov eax,24
	call RandomRange
	mov dh,al   ;ROW
	mov eax,79
	call RandomRange
	mov dl, al   ;Coloumn
	call Gotoxy
	mov eatY,dh
	mov eatX,dl
	jmp atla2

;////////////////////// If food has not eaten yet 
;		    then print the food on screen with same coordinates
atla:
	mov dh,eatY
	mov dl,eatX
	call Gotoxy
	
atla2:
	mov ah,2
	mov dl,15
	int 21h
	mov isMeal,true
	
	;////////////////////// Check whether the food is eaten or not 
	;////////////////////// If it is eaten, then (isMeal) is false
	mov al,(snake[esi]).x
	cmp eatX,al
	jne atla3
	mov al,(snake[esi]).y
	cmp eatY,al
	jne atla3
	inc s
	add Bonus,2
	mov isMeal,false
	
	;////////////////////// Check the snake is long enough to win the level
	cmp s,SnakeLength
	je cik2
	
atla3:
;//////////////////////Accident/////Collision///

	mov al,(snake[esi]).x
	mov ah,(snake[esi]).y
	
	mov ecx,s
	
	
kaza:

	add esi,TYPE snake

	cmp al,(snake[esi]).x
	jne isKaza
	cmp ah,(snake[esi]).y
	je cik
	
isKaza:
	Loop kaza

;////////////////////// Second Level \\\\\\\\\\\\\\\\\\\\\\
	cmp isLevel,1
	jne go1
	mov esi,OFFSET snake

	mov al,(snake[esi]).x
	mov ah,(snake[esi]).y

	mov esi,OFFSET wall
	mov ecx,stones
;/////////////////////// Did snake crash the walls?
kaza2:
	cmp al,(wall[esi]).xPos
	jne git_
	cmp ah,(wall[esi]).yPos
	jne git_
	jmp cik
;/////////////////////// Game Over
git_:
	cmp al,(wall2[esi]).xPos
	jne git2_
	cmp ah,(wall2[esi]).yPos
	jne git2_
	jmp cik

git2_:
	add esi,TYPE wall
	Loop kaza2
	
	mov esi,OFFSET snake
	
go1:

;////////////////////// Collision \\\\\\\\\\\\\\\\\\\\\\

	mov esi,OFFSET snake

;////////////////////// Is snake out ?
	mov al,(snake[esi]).x
	mov ah,(snake[esi]).y

	cmp al,79
	je cik
	cmp al,0
	je cik
	cmp ah,0
	je cik
	cmp ah,24
	je cik

	;////////////////////// Get the character using int21h fcn 6
	;////////////////////// Keep the character in 'char' variable

	mov al,0
	mov ah,6
	mov dl,0FFh
	int 21h
	jz skip
	mov char,al
skip:
	;////////////////////// Compare the 'char' value with arrow keys (a,s,d,f)
	;////////////////////// If any keys pressed, use the last 'char' value
	cmp char,'w'
	je UP
	cmp char,'s'
	je DOWN
	cmp char,'a'
	je LEFT
	cmp char,'d'
	je RIGHT
	cmp char,1Bh ;/////////////Press ESC to terminate the game//////
	je cik
	
	jmp kalan ;////////////////////// Use the last 'char' value

	call PrintConsole ; Print the snake to screen
	cmp isLevel,1
	jne git
	call DuvarBas ;If level is 2, print also the wall
git:

;////////////////////// if the key is UP, w
UP:
	mov al,(snake[esi]).x
	mov ah,(snake[esi]).y
	mov Xcu,al
	mov Ycu,ah

	mov al,(snake[esi]).y
	dec al
	mov (snake[esi]).y,al
	mov char,up_

	INVOKE Elemanlar,Xcu,Ycu

	call PrintConsole
	cmp isLevel,1
	jne git2
	call DuvarBas
git2:
	jmp devam

;////////////////////// if the key is DOWN, s
DOWN:
	mov al,(snake[esi]).x
	mov ah,(snake[esi]).y
	mov Xcu,al
	mov Ycu,ah

	mov al,(snake[esi]).y
	inc al
	mov (snake[esi]).y,al
	mov char,down_
	
	INVOKE Elemanlar,Xcu,Ycu

	call PrintConsole
	cmp isLevel,1
	jne git3
	call DuvarBas
git3:


	jmp devam
;////////////////////// if the key is LEFT, a
LEFT:
	mov al,(snake[esi]).x
	mov ah,(snake[esi]).y
	mov Xcu,al
	mov Ycu,ah
	
	mov al,(snake[esi]).x
	dec al
	mov (snake[esi]).x,al
	mov char,left_
	
	INVOKE Elemanlar,Xcu,Ycu
	
	call PrintConsole
	cmp isLevel,1
	jne git4
	call DuvarBas
git4:
	jmp devam

;////////////////////// if the key is RIGHT, d
RIGHT:
	mov al,(snake[esi]).x
	mov ah,(snake[esi]).y
	mov Xcu,al
	mov Ycu,ah
	
	mov al,(snake[esi]).x
	inc al
	mov (snake[esi]).x,al
	mov char,right_
	
	INVOKE Elemanlar,Xcu,Ycu

	call PrintConsole
	cmp isLevel,1
	jne git5
	call DuvarBas
git5:
	jmp devam
	
;///////////////// If user doesn't press any key \\\\\\\\\\\\\
;///////////////// Compare the last value of 'char' variable
;///////////////// Keep going with it
kalan:
	cmp char,up_
	jne bir
	mov al,(snake[esi]).x
	mov ah,(snake[esi]).y
	mov Xcu,al
	mov Ycu,ah
	
	mov al,(snake[esi]).y
	dec al
	mov (snake[esi]).y,al
	mov char,up_
	
	INVOKE Elemanlar,Xcu,Ycu

	call PrintConsole
	cmp isLevel,1
	jne git6
	call DuvarBas
git6:

bir:
	cmp char,left_
	jne iki
	mov al,(snake[esi]).x
	mov ah,(snake[esi]).y
	mov Xcu,al
	mov Ycu,ah
	
	mov al,(snake[esi]).x
	dec al
	mov (snake[esi]).x,al
	mov char,left_
	
	INVOKE Elemanlar,Xcu,Ycu
	
	call PrintConsole
	cmp isLevel,1
	jne git7
	call DuvarBas
git7:

iki:
	cmp char,down_
	jne uc
	mov al,(snake[esi]).x
	mov ah,(snake[esi]).y
	mov Xcu,al
	mov Ycu,ah
	
	mov al,(snake[esi]).y
	inc al
	mov (snake[esi]).y,al
	mov char,down_

	INVOKE Elemanlar,Xcu,Ycu
	
	call PrintConsole
	cmp isLevel,1
	jne git8
	call DuvarBas
git8:

uc:
	cmp char,right_
	jne devam
	mov al,(snake[esi]).x
	mov ah,(snake[esi]).y
	mov Xcu,al
	mov Ycu,ah
	
	mov al,(snake[esi]).x
	inc al
	mov (snake[esi]).x,al
	mov char,right_
	
	INVOKE Elemanlar,Xcu,Ycu
	call PrintConsole
	cmp isLevel,1
	jne git9
	call DuvarBas
git9:

devam:

	mov eax,speed ;///////////////// Snake speed
	call Delay

	jmp Game_Start

;///////////////// Level is over \\\\\\\\\\\\\\\
;///////////////// If the level is 1, pass to the level 2
;///////////////// If it is 2, game is over
cik:
	cmp isLevel,1
	je cik3
	mov dl,35
	mov dh,12
	call GotoXy

	call ClrScr
	;///////////////// Level 1 is over message
	mov edx,OFFSET message
	call WriteString
	call Crlf
	
	;///////////////// First level score
	mov edx, OFFSET yourScore
	call WriteString
	mov eax,bonus
	call WriteInt
	call Crlf
	
	call WaitMsg
	jmp over

;///////////////// If the level is 2	
cik3:
	mov dl,35
	mov dh,12
	call GotoXy
	call ClrScr
	
	;///////////////// Game Over message
	mov edx,OFFSET messe
	call WriteString
	call Crlf
	
	;///////////////// Total game score
	mov edx, OFFSET yourScore
	call WriteString
	mov eax,bonus
	call WriteInt
	call Crlf
	
	call WaitMsg
	jmp over

;///////////////// Congratulations! \\\\\\\\\\\\\\\\\
;///////////////// Show the level 1 is over message and the score
;///////////////// Pass to the level 2
cik2:
	cmp isLevel,1
	je yuce

	mov dl,35
	mov dh,12
	call GotoXy
	
	call ClrScr
	mov edx,OFFSET mes
	call WriteString
	call Crlf
	mov edx, OFFSET yourScore
	call WriteString
	mov eax,bonus
	call WriteInt
	call Crlf
		

	mov edx,OFFSET level2Message
	call WriteString
	call Crlf

	call WaitMsg

	inc isLevel
	mov s,12
	mov speed,1300
	jmp begin_level

;///////////////// Congratulations! \\\\\\\\\\\\\\\\\
;///////////////// Show the level 2 is over message and the total score
;///////////////// Game over	
yuce:
	mov dl,35
	mov dh,12
	call GotoXy

	call ClrScr
	mov edx,OFFSET mes2
	call WriteString
	call Crlf
	mov edx, OFFSET yourScore
	call WriteString
	mov eax,bonus
	call WriteInt
	call Crlf	

	call WaitMsg
	jmp over
over:

exit
main ENDP
;________________________________________________________________________

;-----------------------------------------------
PrintConsole PROC
;
; Print snake to console relative to it's x any y coordinate
; Use the second function of interrupt 21 to print the characters
; Receives: nothing
; Returns: nothing
;-----------------------------------------------
	pushad

	mov ecx,s
	mov esi,OFFSET snake
	
L1:
	mov dl,(snake[esi]).x
	mov dh,(snake[esi]).y
	call Gotoxy

	mov ah,2
	mov dl,'o'
	int 21h
	
	add esi,TYPE snake
	LOOP L1
	
	popad
	ret
PrintConsole ENDP
;-----------------------------------------------

;-----------------------------------------------
Elemanlar  PROC, currX:BYTE,currY:BYTE
;
; Print four character on the screen as the wall
; Check the current direction and print the character in terms of it
; Receives: currX, currY
;		  currX = The x coordinate of the head of the snake
;		  currY = The y coordinate of the head of the snake		  

; Returns: nothing
;-----------------------------------------------
	pushad

	mov ecx,s	
	mov esi,OFFSET snake
	
	;///////////////// If the key is up
	cmp char,up_
	jne emin1
	
L4:
	add esi,TYPE snake
	mov al,currX
	mov ah,currY
	mov bl,(snake[esi]).x
	mov bh,(snake[esi]).y
	mov (snake[esi]).x,al
	mov (snake[esi]).y,ah
	mov currX,bl
	mov currY,bh
	Loop L4

	jmp emin_cik
	
emin1:
	
	;///////////////// If the key is left
	cmp char,left_
	jne emin2
L5:
	add esi,TYPE snake
	mov al,currX
	mov ah,currY
	mov bl,(snake[esi]).x
	mov bh,(snake[esi]).y
	mov (snake[esi]).x,al
	mov (snake[esi]).y,ah
	mov currX,bl
	mov currY,bh
	Loop L5
	jmp emin_cik

emin2:

	;///////////////// If the key is down
	cmp char,down_
	jne emin3

L6:
	add esi,TYPE snake
	mov al,currX
	mov ah,currY
	mov bl,(snake[esi]).x
	mov bh,(snake[esi]).y
	mov (snake[esi]).x,al
	mov (snake[esi]).y,ah
	mov currX,bl
	mov currY,bh
	Loop L6
	jmp emin_cik

emin3:

	;///////////////// If the key is right
	cmp char,right_
	jne emin_cik	
L7:
	add esi,TYPE snake
	mov al,currX
	mov ah,currY
	mov bl,(snake[esi]).x
	mov bh,(snake[esi]).y
	mov (snake[esi]).x,al
	mov (snake[esi]).y,ah
	mov currX,bl
	mov currY,bh
	Loop L7

	jmp emin_cik

emin_cik:

	popad
	ret
Elemanlar ENDP
;-----------------------------------------------

;-----------------------------------------------
DuvarBas PROC
;
; Print four character on the screen as the wall
; Receives: nothing
; Returns: nothing
;-----------------------------------------------
	pushad

	mov esi,OFFSET wall
	mov ecx,stones

Ismail:
	mov dl,(wall[esi]).xPos
	mov dh,(wall[esi]).yPos
	call GotoXy

	mov ah,2
	mov dl,189
	int 21h
	
	mov dl,(wall2[esi]).xPos
	mov dh,(wall2[esi]).yPos
	call GotoXy

	mov ah,2
	mov dl,189
	int 21h
	

	add esi,TYPE wall
	Loop Ismail

	popad

	ret
DuvarBas ENDP
;-----------------------------------------------


END main