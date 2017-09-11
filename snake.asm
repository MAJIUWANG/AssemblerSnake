assume cs:code,ds:data
;A program for snake                   贪吃蛇游戏      
data segment
      dw 160*25 dup(0)
      int_vet dw 0,0
      key_flag db 0
      direct db 1,0
      sna_b db 10,4,10,3,10,2,10,1,100 dup(0)
      buff db 0,0
      food_pos db 0,0
      food_flag db 0    
data ends 
code segment
         start:  mov ax,data
                 mov ds,ax

                 mov si,0
                 mov ax,0
                 mov es,ax

                 push es:[4*9]
                 pop int_vet[si]
                 push es:[4*9+2]
                 pop int_vet[si+2]

                 cli
                 mov word ptr es:[4*9],offset int9
                 mov es:[4*9+2],cs
                 sti

                 jmp start1

           int9: push ax
                 push bx
                 push si

                 mov si,0
                 in al,60h

                 pushf
                 pushf
                 pop bx
                 and bh,11111100b
                 push bx
                 popf
                 call dword ptr int_vet[si]

                 cmp al,0c8h
                 jne right_key
                 mov key_flag[si],al
                 jmp int9ret

    right_key:   cmp al,0cdh
                 jne left_key
                 mov key_flag[si],al
                 jmp int9ret

     left_key:   cmp al,0cbh
                 jne down_key
                 mov key_flag[si],al
                 jmp int9ret

     down_key:   cmp al,0d0h
                 jne esc_key
                 mov key_flag[si],al
                 jmp int9ret

      esc_key:   cmp al,81h
                 jne int9ret
                 mov key_flag[si],al
                 jmp int9ret

      int9ret:   pop si                
                 pop bx
                 pop ax
                 iret 
                 
       start1:   call draw_wall

                 mov dl,10
                 mov dh,4
                 mov bx,2   
                 mov si,0

                 call init

       main_s:   cmp food_flag[si],1
                 je conti
                 call food
                 inc bx
                
        conti:   call show_snake
                 call delay     
                 call press_key
      
          con:   add dh,direct[si]
                 add dl,direct[si+1]

                 call snake_move        
                 jmp main_s


      main_end:  mov ax,0
                 mov es,ax
                 push int_vet[si]
                 pop es:[4*9]
                 push int_vet[si+2]
                 pop es:[4*9+2]

                 mov ax,4c00h
                 int 21h

       sna_die:  jmp main_end

         food:   push ax
                 push bx
                 push si
                 push dx

                 mov si,0
                 mov bh,1
                 mov bl,160

                 call rand   
                 mov dl,food_pos[si]
                 mov dh,food_pos[si+1]

                 mov food_flag[si],bh

                 mov al,dl
                 mul bl
                 mov dl,dh
                 mov dh,0
                 add ax,dx
                 add ax,dx
                 mov si,ax
                                 
                 mov byte ptr ds:[si],3

      food_end:  pop dx
                 pop si
                 pop bx
                 pop ax
                 ret

          rand:  push cx
                 push dx
                 push ax
                 push si

                 mov si,0

                 mov ah,0
                 int 1ah

                 mov ax,dx
                 and ah,00000011b
                 mov dl,23
                 div dl
                 inc ah
                 mov food_pos[si],ah
                              
                 mov ah,0
                 int 1ah
                 mov ax,dx
                 and ah,00000011b
                 mov dl,77
                 div dl
                 inc ah
                 mov food_pos[si+1],ah

                 pop si
                 pop ax
                 pop dx
                 pop cx 
                 ret

    press_key:   push ax

                 mov al,key_flag[si]
           up:   cmp al,0c8h
                 jne left
                 mov byte ptr direct[si+1],0ffh
                 mov byte ptr direct[si],0

                 pop ax
                 jmp con

           left: cmp al,0cbh
                 jne right
                 mov byte ptr direct[si],0ffh
                 mov byte ptr direct[si+1],0

                 pop ax
                 jmp con

          right: cmp al,0cdh
                 jne down
                 mov byte ptr direct[si],1
                 mov byte ptr direct[si+1],0

                 pop ax
                 jmp con

           down: cmp al,0d0h
                 jne esc1
                 mov byte ptr direct[si+1],1
                 mov byte ptr direct[si],0

                 pop ax
                 jmp far ptr con

           esc1: cmp al,81h
                 je  near1
                 jmp esc_end

         near1:  pop ax
                 jmp far ptr  main_end

       esc_end:  pop ax
                 ret
        
          init:  push si
                 push ax
                                                  
                 mov si,160*10+2
                 mov byte ptr ds:[si],22
                 add si,2
                 mov byte ptr ds:[si],22
                 add si,2
                 mov byte ptr ds:[si],22
                 add si,2
                 mov byte ptr ds:[si],64

                 pop ax
                 pop si
                 ret

    snake_move:  push ax                     ; bx --- length of snake
                 push bx
                 push cx
                 push dx
                 push si
                 push di

                 push bx
                 mov bl,160
                 mov di,0

                 mov ah,0
                 mov al,dl
                 mul bl
                 mov bl,dh
                 mov bh,0
                 add ax,bx
                 add ax,bx
                 mov si,ax

                 mov al,ds:[si]
                 cmp al,0
                 je move_con

                 call snake_state

      move_con:  mov byte ptr ds:[si],64
                                        
                 mov ds:buff[di],dl
                 mov ds:buff[di+1],dh

                 pop bx
            ;update snake_body position data
                 mov di,bx
                 dec di
                 add di,di

                 push dx          

                 mov dl,ds:sna_b[di+2]                         ;cls snake_end
                 mov dh,ds:sna_b[di+1+2]

                 mov cl,160
                 
                 mov ah,0
                 mov al,dl
                 mul cl
                 mov cl,dh
                 mov ch,0
                 add ax,cx
                 add ax,cx
                 mov si,ax
                 mov byte ptr ds:[si],' '
                                
                 pop dx

                 mov cx,bx

   change_sna_b: mov al,ds:sna_b[di]
                 mov ds:sna_b[di+2],al
                 mov al,ds:sna_b[di+1]
                 mov ds:sna_b[di+1+2],al
                 sub di,2
                 loop  change_sna_b

                 mov di,0
                 mov al,ds:buff[di]
                 mov ds:sna_b[di],al
                 mov al,ds:buff[di+1]
                 mov ds:sna_b[di+1],al

                 mov cx,bx
                 mov bl,160
                 dec cx
                 add di,2

        move_s:  mov dl,ds:sna_b[di]
                 mov dh,ds:sna_b[di+1]

                 mov ah,0
                 mov al,dl
                 mul bl
                 mov bl,dh
                 mov bh,0
                 add ax,bx
                 add ax,bx
                 mov si,ax
                 mov byte ptr ds:[si],22
          
                 mov bl,160

                 add di,2

                 loop move_s

                 pop di
                 pop si
                 pop dx
                 pop cx
                 pop bx
                 pop ax
                 ret

         snake_state:   push ax
                        cmp al,3
                        jne sna_eat_self
                        mov byte ptr food_flag,0
                        jmp state_end

        sna_eat_self:   cmp al,22
                        jne sna_hit_wall
                        pop ax
                        call sna_die

        sna_hit_wall:   cmp al,'*'
                        jne state_end
                        pop ax
                        call sna_die

           state_end:   pop ax
                        ret

         delay:   push cx
                  push ax

                  mov cx,02fffh
              s:  push cx
                  mov cx,02fffh
             s1:  mov ax,0
                  loop s1

                  pop cx
                  loop s

                  pop ax
                  pop cx
                  ret

    show_snake: push ax
                push cx
                push ds
                push si
                push es
                push di
                                   
                mov si,0  
                mov ax,0b800h
                mov es,ax
                mov di,0

                mov cx,80*25
  show_snake_s: mov al,ds:[si]
                mov es:[di],al
                add si,2
                add di,2
                loop show_snake_s

                pop di
                pop es
                pop si
                pop ds
                pop cx
                pop ax
                ret

  draw_wall:    push bx
                push cx
                push si

                mov bx,0
                mov si,0
                mov cx,79
       wall_s1: mov byte ptr ds:[bx+si],'*'
                add bx,2
                loop wall_s1

                mov cx,24
       wall_s4: mov byte ptr ds:[bx+si],'*'
                add si,160
                loop wall_s4

                mov cx,79                
       wall_s3: mov byte ptr ds:[bx+si],'*'
                sub bx,2
                loop wall_s3

                mov cx,24
       wall_s2: mov byte ptr ds:[bx+si],'*'
                sub si,160
                loop wall_s2

                pop si
                pop cx
                pop bx
                ret
code ends
end start
