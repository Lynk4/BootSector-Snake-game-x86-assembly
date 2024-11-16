;; SETUP
org 7C00h

jmp setup_game

;; CONSTANTS
VIDMEM 		equ	0B800h
SCREENW 	equ	80
SCREENH 	equ	25
WINCOND 	equ	10
BGCOLOR 	equ	1020h
APPLECOLOR 	equ	4020h
SNAKECOLOR 	equ 2020h
TIMER      	equ 046Ch
SNAKEXARRAY equ 1000h
SNAKEYARRAY equ 2000h
UP 			equ	0
DOWN		equ 1
LEFT 		equ 2
RIGHT		equ 3


;;VARIABLES
playerX: dw 40
playerY: dw 12
appleX:  dw 16
appleY:  dw 8
direction: db 4
snakeLength: dw 1


;;LOGIC-----------
setup_game:
    ;; Set video mode - VGA mode  03h (80x25 text mode, 16 colors)
	mov ax, 0003h
	int 10h
	
	;; Set up video memory
	mov ax, VIDMEM
	mov es, ax
	
	;; Set 1st sanake segment "head"
	mov ax, [playerX]
	mov word [SNAKEXARRAY], ax
	mov ax, [playerY]
	mov word [SNAKEYARRAY], ax

;; HIDE CURSUR
	mov ah, 02h
	mov dx, 2600h ;DH=ROW DL=COL 
	int 10h
;; GAME LOOP
game_loop:
	;; Clear screen every loop iteration
	mov ax, BGCOLOR
	xor di, di
	mov cx, SCREENW*SCREENH
	rep stosw 
	
	;; Draw snake
	xor bx, bx
	xor cx, [snakeLength]
	mov ax, SNAKECOLOR
	.snake_loop:
		imul di, [SNAKEYARRAY+bx], SCREENW*2  ; Y POSITION OF SNAKE, 2 BYTES
		imul dx, [SNAKEXARRAY+bx], 2  
		add di, dx
		stosw
		inc bx
		inc bx
	loop .snake_loop


	;; Draw apple
	imul di, [appleY], SCREENW*2
	imul dx, [appleX], 2
	add di, dx
	mov ax, APPLECOLOR
	stosw
	

	;; MOVE snake in current direction
	mov al, [direction]
	cmp al, UP
	je move_up
	cmp al, DOWN
	je move_down
	cmp al, LEFT
	je move_left
	cmp al, RIGHT
	je move_right
	
	jmp update_snake


	move_up:
		dec word [playerY]  ;move up 1 row
		jmp update_snake

	move_down:
		inc word [playerY]  ;move down 1 row
        jmp update_snake

	move_left:
		dec word [playerX]  ;move left 1 row
        jmp update_snake
	
	move_right:
		inc word [playerX]  ;move right 1 row
      
	;; update snake position..... 
	update_snake:
		;; update all snake segments past head
		imul bx, [snakeLength], 2
		.snake_loop:
			mov ax, [SNAKEXARRAY-2+bx]
			mov word [SNAKEXARRAY+bx], ax
			mov ax, [SNAKEYARRAY-2+bx]
            mov word [SNAKEYARRAY+bx], ax

			dec bx
			dec bx
		jnz .snake_loop

	;; store updated values to head....
	mov ax, [playerX]
	mov word [SNAKEXARRAY], ax
	mov ax, [playerY]
	mov word [SNAKEYARRAY], ax

	;; Lose conditions
	;; 1) hit borders
	cmp word [playerY], -1  ;top of screen
	je game_lost
	cmp word [playerY], SCREENH ; Bottom of screen
	je game_lost
	cmp word [playerX], -1 ; Left screen
	je game_lost
	cmp word [playerX], SCREENW ; Right of screen
	je game_lost

	;; 2) hit parrt of snake
	cmp word [snakeLength], 1
	je get_player_input

	mov bx, 2                 ; Array indexes, start at 2nd array
	mov cx, [snakeLength]  ; Loop counter........
	check_hit_snake_loop:
		mov ax, [playerX]
		cmp ax, [SNAKEXARRAY+bx]
		jne .increment

		mov ax, [playerY]
		cmp ax, [SNAKEYARRAY+bx]
		je game_lost            ; hit snake body........

		.increment:
			inc bx
			inc bx
	loop check_hit_snake_loop	


	get_player_input:
		mov bl, [direction] ; save current direction
		
		mov ah, 1
		int 16h     ;get Keyboard status
		jz  check_apple		; if no key was pressed move on..
		
		xor ah, ah
		int 16h    ; get keystrokes, AH=scancode, AL=asciichar entered
		cmp al, 'w'
		je w_pressed
		cmp al, 's'
        je s_pressed
		cmp al, 'a'
        je a_pressed
		cmp al, 'd'
        je d_pressed
		
		jmp check_apple

		w_pressed:
			mov bl, UP
			jmp check_apple
		
		s_pressed:
			mov bl, DOWN
            jmp check_apple

		a_pressed:
			mov bl, LEFT
            jmp check_apple

		d_pressed:
			mov bl, RIGHT
            jmp check_apple
	
	;; did player hit apple?........
	check_apple:
		mov byte [direction], bl
		
		mov ax, [playerX]
		cmp ax, [appleX]
		jne delay_loop

		mov ax, [playerY]
		cmp ax, [appleY]
		jne delay_loop
; hit apple , increase snake length.............
		inc word [snakeLength]
		cmp word [snakeLength], WINCOND
		je game_won
	
	next_apple:
		;; random X position
		xor ah, ah
		int 1Ah   ;timer ticks 
		mov ax, dx
		xor dx, dx
		mov cx, SCREENW
		div cx
		mov word [appleX], dx

		;; random Y pos
		xor ah, ah
        int 1Ah   ;timer ticks 
        mov ax, dx
        xor dx, dx
        mov cx, SCREENH
        div cx
        mov word [appleY], dx

	;; check if apple spawn
	xor bx, bx
	mov cx, [snakeLength]
	.check_loop:
		mov ax, [appleX]
		cmp ax, [SNAKEXARRAY+bx]
		jne .increment

		mov ax, [appleY]
        cmp ax, [SNAKEYARRAY+bx]
        je next_apple

		.increment:
			inc bx
			inc bx
	loop .check_loop

	
	delay_loop:
		mov bx, [TIMER]
		inc bx
		inc bx
		.delay:
			cmp [TIMER], bx
			jl .delay

jmp game_loop

;; GAME END CONDITIONS
game_won:
	mov dword [ES:0000], 1F491F57h ;WI 
    mov dword [ES:0004], 1F211F4Eh ;N!
	jmp reset

game_lost:
	mov dword [ES:0000], 1F4F1F4ch ;LO 
	mov dword [ES:0004], 1F451F53h ;SE

;; RESET
reset:
	xor ah, ah
	int 16h

	jmp 0FFFFh:0000h    ; reboot
;;	int 19h              ;alternative restart qemu
;;BOOT SECTOR PADDING
times 510 - ($-$$) db 0

dw 0AA55h

