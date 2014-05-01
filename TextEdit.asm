TITLE Text Editor

;  Author:  MANUEL LEUNG WU
;  Date:	5/23/2012

.model              small
.stack              100h

WINDESC             STRUCT
                    foreColor	  BYTE   ?
					backColor	  BYTE   ?
					upperRow	  BYTE   ?
                    leftCol		  BYTE   ?
                    lowerRow	  BYTE   ?
                    rightCol	  BYTE   ?
					banner		  BYTE   40 dup(0)
					;add1		  BYTE   ?
					;add2		  BYTE   ?
                    
WINDESC             ENDS
				
putc				MACRO		  char:req
					mov		  	  ax, char
					push		  ax
					call 		  putchar
					ENDM
			
puthl				MACRO		  x:req, y:req			
					mov		  	  ax, x
					push		  ax
					mov 		  bx, y
					push 		  bx
					call 		  setcp
					call 		  drawhorline
					ENDM
				
putvl 				MACRO 		  x:req, y:req
					mov		  	  ax, x
					push		  ax
					mov 		  bx, y
					push 		  bx
					call 		  setcp
					call 		  drawverline
					ENDM
				
char 				MACRO		  pos:req, char:req
					mov 		  ax, pos
					push		  ax
					call		  curpos
					mov		  	  bx, char
					push		  bx
					call		  putchar
					ENDM
				
curp				MACRO		  pos:req
					mov 		  ax, pos
					push 		  ax
					call 		  curpos
					ENDM
				
getp				MACRO
					mov			  ax, 0300h
					mov 		  bh, 0
					int 		  10h
					ENDM
					
setpl				MACRO
					mov			  ax, 0200h
					mov			  bh, 0
					int			  10h
					ENDM
					
exit                MACRO
					call 		  clrscr
                    mov           ax, 4C00h
                    int           21h
                    ENDM
					
quit				MACRO
					exit
					ENDM

.data 

application         WINDESC       <07h, 10h, 05h, 05h, 15h, 45h, " Manuel ">

.code

curpos              PROC         
                    push          bp
                    mov           bp, sp
                    push          ax
                    push          bx
                    push          dx

                    mov           ax, 0200h
                    mov           dx, [bp+4]
					mov           bh, 0
                    int           10h

                    pop           dx
                    pop           bx
                    pop           ax
                    pop           bp
                    ret           2
curpos              ENDP
				
getpos				PROC
					push          bp
                    mov           bp, sp
                    push          ax
                    push          bx
                    push          dx
					
					mov			  ax, 0300h
					mov 		  bh, 0
					int 		  10h
					
					pop           dx
                    pop           bx
                    pop           ax
                    pop           bp
                    ret           2
getpos				ENDP	
			
putchar             PROC         
                    push          bp
                    mov           bp, sp
                    push          ax
                    push          bx
                    push		  cx
                    push		  dx
					
					mov			  ax, 0900h
					mov			  al, [bp+4]
					mov			  bh, 0
					mov			  bl, 013h
					mov			  cx, 1
					int			  10h

                    pop           dx
                    pop           cx
                    pop           bx
                    pop           ax
                    pop           bp
                    ret           2
putchar             ENDP
			
setcp				PROC
					push          bp
                    mov           bp, sp
                    push          ax
                    push          bx
                    push          dx
					
					mov 		  dl, [bp+6]
					mov 	  	  dh, [bp+4]
					mov 		  ax, 0200h
					int 		  10h
					
					pop           dx
                    pop           bx
                    pop           ax
                    pop           bp
                    ret           2
setcp				ENDP
			
drawhorline         PROC         
                    push          bp
                    mov           bp, sp
                    push          ax
                    push          bx
                    push		  cx
                    push		  dx
					
					mov			  ax, 0900h
					mov			  al, 0C4h
					mov			  bh, 0
					mov			  bl, 013h
					mov			  cx, 65
					int			  10h
					
                    pop           dx
                    pop           cx
                    pop           bx
                    pop           ax
                    pop           bp
                    ret           2
drawhorline         ENDP
			
drawverline 		PROC
					push          bp
                    mov           bp, sp
                    push          ax
                    push          bx
                    push          cx
                    push          dx
					
					mov 		  cx, 15
					l1:
					push 		  cx
					getp
					inc 		  dh
					setpl
					putc  		  0b3h
					pop 		  cx
					loop 		  l1
					
					pop           dx
                    pop           cx
                    pop           bx
                    pop           ax
                    pop           bp
					ret 		  2
drawverline 		ENDP
				
banner				PROC
					push          bp
                    mov           bp, sp
                    push          ax
                    push          bx
                    push          cx
                    push          dx
					push          si

					mov			  si, [bp+4]
					lp:
					mov 		  al, [si]
					cmp 		  al, 0
					je			  fin
					putc 		  ax
			 		add			  si, 1
					getp
					add			  dl, 1
					setpl
					jmp			  lp
					fin:

					pop 		  si
					pop           dx
                    pop           cx
                    pop           bx
                    pop           ax
                    pop           bp
					ret			  2
banner				ENDP	
				
keyb 				PROC
					push          bp
                    mov           bp, sp
                    push          ax
                    push          bx
                    push          cx
                    push          dx
					
					L1:	
					call		  mice
					;keyboard int
					mov			  ah, 11h
					int			  16h
					jz 			  L1
					
					mov 		  ah, 10h
					int 		  16h
					
					;compare if control+x is entered to terminate
					cmp 		  al, 18h
					je	 		  endinput
					
					;compare directional keys 
					cmp 		  ah, 48h
					je			  uparrow
					
					cmp 		  ah, 50h
					je	 		  downarrow
					
					cmp		      ah, 4bh
					je	 		  leftarrow
					
					cmp 		  ah, 4dh
					je	 		  rightarrow
					
					;compare if any other key besides arrows pressed
					jne 		  keyboard
					
					uparrow:      ;UP if not 06h ROW (DH)
					cmp 		  dh, 06h
					je 			  l1
					dec 		  dh
					setpl
					jmp 		  L1
					
					downarrow:    ;DOWN if not 14h ROW (DH)
					cmp 		  dh, 14h
					je 			  l1
					inc 		  dh
					setpl
					jmp 		  L1
					
					leftarrow:    ;LEFT if not 06h COLUMN (DL)
					cmp 		  dl, 06h
					je 			  leftup
					dec 		  dl
					setpl
					jmp 		  L1
					
					rightarrow:   ;RIGHT if not 44h COLUMN (DL)
					cmp 		  dl, 44h
					je 			  rightdown
					inc 		  dl
					setpl
					jmp 		  L1
					
					leftup:		  ;if LEFT received at 06h go UP and move to 43h
					cmp 		  dh, 06h
					je			  L1
					mov 		  dl, 44h
					dec 		  dh
					setpl
					jmp 		  leftarrow
					
					rightdown:	  ;if RIGHT received at 
					cmp 		  dh, 14h
					je 			  L1
					mov 		  dl, 06h
					inc 		  dh
					setpl
					jmp 		  rightarrow
					
					keyboard:
					;keyboard interrupt
					;print char
					putc 		  ax	
					getp
					;compare the current column position to last position possible
					;if equal we jump to loop l2				
					cmp 		  dl, 44h
					je 			  L2
					;if not equal we 
					;setp inc the dl/column
					inc 		  dl
					setpl
					jmp 		  L1
						L2:
						;compare if its the last row
						cmp 	  dh, 14h
						je 		  L1 
						;if true we keep jumping to L1 so DH/columns doesnt increase
						;if not true
						;setp dl(6) and inc dh/row
						inc 	  dh
						mov 	  dl, 06h
						setpl
					jmp L1
					
					endinput:
					quit
					
					pop           dx
                    pop           cx
                    pop           bx
                    pop           ax
                    pop           bp
                    ret           2
keyb 				ENDP

mice				PROC
					push          bp
                    mov           bp, sp
					push 		  ax
					push 		  bx
					push 		  cx
					push		  dx
					
					mov 		  ah, 0
					mov		   	  al, 6
					mov 		  bx, 0
					int 		  33h
					;dec*8
					cmp			  cx, 536 ;columns
					jne			  L1
					cmp 		  dx, 40 ;rows
					jne 		  L1
					
					mov 		  ax, 0
					int 		  33h
					
					quit
					L1:
					
					pop           dx
                    pop           cx
                    pop           bx
                    pop           ax
					pop           bp
					ret 		  2
mice				ENDP

makewin             PROC
                    push          bp
                    mov           bp, sp
                    push          ax
                    push          bx
                    push          cx
                    push          dx
                    push          si
					
                    mov           si, [bp+4]
					
                    mov           ax, 0600h
                    mov           bh, (WINDESC PTR[si]).backColor
                    mov           ch, (WINDESC PTR[si]).upperRow
                    mov           cl, (WINDESC PTR[si]).leftCol
                    mov           dh, (WINDESC PTR[si]).lowerRow
                    mov           dl, (WINDESC PTR[si]).rightCol
                    int           10h
					
                    push          cx
                    call          curpos
					
					;lines
					puthl	5, 5
					char	0505h, 0DAh
					putvl	5, 5
					char	0545h, 0BFh
					putvl	45h, 5
					puthl	5, 15h
					char	1505h, 0C0h
					char	1545h, 0D9h
					
					; X + title line
					char	0542h, 0B4h
					char 	0543h, 'X'
					char 	0544h, 0C3h
					char 	0510h, 0B4h
					curp 	0511h
					mov 		  ax, (OFFSET application)+6
					push 		  ax
					call 		  banner
					char 	0519h, 0C3h
					
					;keyboard
					curp 	0606h
					call 		  keyb
					
					
                    pop           si
                    pop           dx
                    pop           cx
                    pop           bx
                    pop           ax
                    pop           bp
                    ret           2
makewin             ENDP

clrscr				PROC
					push          bp
                    mov           bp, sp
                    push          ax
                    push          bx
                    push          cx
                    push          dx
					
					mov			  ax, 0600h
					mov 		  cx, 0
					mov			  dx, 184Fh
					int			  10h
					mov 		  ah, 2
					mov			  bh, 0
					mov			  dx, 0
					int 		  10h
					
					pop           dx
                    pop           cx
                    pop           bx
                    pop           ax
                    pop           bp
                    ret           2
clrscr				ENDP

main                PROC

					mov           ax, @data
                    mov           ds, ax
					call 		  clrscr
                    mov           ax, OFFSET application
                    push          ax
                    call          makewin

                    exit                              
main                ENDP

                    END           main