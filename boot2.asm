BITS 16
 
ORG 9000h

	mov			ecx, 10
    jmp 		Second_Stage
 
%include "functions_16.asm"

SwitchVGAMode:
    mov     	ax, 0013h
    int     	10h
    ret

DrawPixel:
    mov    	 	ah, 0Ch
    mov     	bh, 0
    int     	10h
    ret

Abs_Func:
    cmp 		ax, 0                           
    jl  		Neg_Func                         
    ret                                 

Neg_Func:
    neg 		ax                              
    ret 

Entry:									;Defines variables // Brensham Algorithm
    mov     	word [x0], ax            
    mov     	word [y0], bx               
    mov     	word [x1], cx
    mov     	word [y1], dx
    mov     	word [colour], si

    mov     	ax, [x1]      			;dx = abs(x1 - x0)              
    sub     	ax, [x0]                   
    call    	Abs_Func                    
    mov     	[dx0], ax                   

    mov     	ax, [y1]     			;dy = abs(y1 - y0)               
    sub     	ax, [y0]                    
    call    	Abs_Func                     
    mov     	[dy0], ax                   

    mov     	ax, [x0]          		;if x0 < x1 then sx = 1 else sx = -1          
    cmp     	ax, [x1]                    
    jl      	Set_X_One                 
    mov     	word [sx0], -1             

    jmp     	Set_Direction_Y

    call 		_Loop

_Loop:
    mov     	cx, [x0]                    
    mov     	dx, [y0]                    
    mov     	al, [colour]               
    call    	DrawPixel              		

    mov     	ax, [x0]                    
    cmp     	ax, [x1]                    
    je      	Check_Y            

Continue:								;Continue the Loop
    mov     	ax, [er0]   			;e2 = 2 * er0                
    add     	ax, [er0]                   
    mov     	word [e2], ax              
    
    mov     	ax, [e2]             	;if e2 > -dy then      
    mov     	bx, [dy0]                   
    neg    		bx                          
    cmp     	ax, bx                     
    jg      	Update_X

Count:
	add			ax, 50
	add			cx, 50
	inc			al
	dec 		ecx
	jnz			Entry
	
Check_DX:
    mov     	ax, [e2]               	;if e2 < dx then    
    cmp     	ax, [dx0]                  
    jl      	Update_Y                
    jmp 		_Loop                  

Quit:
    ret                                 

Update_X:
    mov     	ax, [er0]             	;er0 = er0 - dy      
    sub     	ax, [dy0]                   
    mov     	word [er0], ax              

    mov     	ax, [x0]                    
    add     	ax, [sx0]                  
    mov     	word [x0], ax               

    jmp     	Check_DX

Update_Y:
    mov     	ax, [er0]   			;er0 = er0 + dx                
    add     	ax, [dx0]                   
    mov     	word [er0], ax              

    mov     	ax, [y0]                    
    add     	ax, [sy0]                   
    mov    		word [y0], ax              

    jmp     	_Loop

Check_Y:
    mov     ax, [y0]                    
    sub     ax, [y1]                    
    je      Quit             

Set_Direction_Y:
    mov     	ax, [y0]       			;if y0 < y1 then sx = 1 else sx = -1             
    cmp     	ax, [y1]                    
    jl      	Set_Y_One                 
    mov     	word [sy0], -1             
    jmp     	Set_er0


Set_X_One:
    mov     	word [sx0],  1   		;sx = 1           
    jmp     	Set_Direction_Y

Set_Y_One:
    mov     	word [sy0],  1      	;sy = 1        
    jmp     	Set_er0


Set_er0:
    mov     	ax, [dx0]      			;er0 = dx - dy             
    sub     	ax, [dy0]                   
    mov     	[er0], ax                  
    jmp     	_Loop                                

Second_Stage:
    mov 		si, second_stage_msg	;Output our greeting message
    call 		Console_WriteLine_16
    call SwitchVGAMode
	mov ecx, 10

	add			ax, 10          		;X Start
	add			bx, 10         		;Y Start
	add			cx, 10	         		;X Endpoint         
	add			dx, 10	         		;Y Endpoint
	add			si, 1	          		;Colour
	
	call		Entry

	For_Loop:
    	mov			ax, 15          		;X Start
		mov			bx, 15          		;Y Start
		mov			cx, 150	         		;X Endpoint         
		mov			dx, 20	         		;Y Endpoint
		mov			si, 2	          		;Colour
    	call Entry
    
    	dec ecx
    	cmp ecx, 0
    	je  Stop
		jmp	For_Loop
	Stop:
    	ret

endloop:
    jmp     	endloop

;Data

x0:     		dw 0   					;X Start                         
x1:     		dw 0                	;X Endpoint    

y0:     		dw 0                	;Y Start
y1:     		dw 0                	;Y Endpoint    

dx0:    		dw 0               		;Delta X            
dy0:    		dw 0               		;Delta Y    

sx0:    		dw 0                            
sy0:    		dw 0                           

er0:    		dw 0 

e2:     		dw 0                            

colour: 		db 0                           


second_stage_msg	db 'Second stage loaded', 0
 
	times 3584-($-$$) db 0	