.model small
.stack 100h
.data
    msg db "Enter a number from 0-999: $"
    msgBinary db "The number in binary format is: $"
    msgHexa db "The number in Hexadecimal format is: $" 
    msgRoman db "The number in Roman format is: $"
    num db 3 dup('?') 
    newline db 0Dh, 0Ah, '$'
    result db 5 dup(0)

.code
main proc
    mov ax, @data
    mov ds, ax

    
    lea dx, msg
    mov ah, 09h
    int 21h

   
    mov cx, 3          
    lea di, num
    mov [di], 0
    mov [di+1], 0 
    mov [di+2], 0

read_loop:
    mov ah, 01h        
    int 21h
    cmp al, 0Dh
    je EnterPressed
    sub al, '0'        
    mov [di], al       
    inc di
    loop read_loop     
    
EnterPressed: 
    cmp cx, 1
    je two_digits
    cmp cx, 2
    je one_digit
    mov al, [num]
    mov bl, 100
    mul bl ; ax = al*bl
    mov dx, ax
    mov al, [num+1]     
    mov bl, 10
    mul bl
    add dx, ax
    mov al, [num+2]
    mov bl, 1
    mul bl
    add dx, ax
    mov bx, dx 
    jmp print_binary
    
two_digits: 
    mov al, [num]     
    mov bl, 10
    mul bl
    add dx, ax
    mov al, [num+1]
    mov bl, 1
    mul bl
    add dx, ax
    mov bx, dx 
    jmp print_binary
    
one_digit:
    mov al, [num]
    mov bl, 1
    mul bl
    add dx, ax
    mov bx, dx
     
    
    
print_binary:
    call convertBinary
    

call convertHexa
call romanAll 



    
    mov ah, 4Ch
    int 21h

main endp


convertBinary proc
    push bx
    mov cx, 6
    binary_loop:
        shl bx, 1
        loop binary_loop
    mov cx, 10
    lea dx, newLine
    mov ah, 09h
    int 21h
    lea dx, msgBinary
    mov ah, 09h
    int 21h
    print_loop:
        shl bx, 1 
        jc CarrySet 
        mov byte ptr result, '0'
        mov byte ptr result+1, '$'
        jmp Done

        CarrySet:
            mov byte ptr result, '1'
            mov byte ptr result+1, '$'

        Done:
            lea dx, result
            mov ah, 09h
            int 21h
        loop print_loop  
    pop bx
convertBinary endp 

convertHexa proc
    lea dx, newLine
    mov ah, 09h
    int 21h 
    lea dx, msgHexa
    mov ah, 09h
    int 21h
    push bx
    and bx, 0000001100000000b
    shr bx, 8
    add bl, '0'
    mov dl, bl
    mov ah, 02h
    int 21h 
    pop bx
    push bx
    and bx, 0000000011110000b
    shr bx, 4  
    cmp bx, 9
    jbe printF
    add bx, 7
    
    printF:
        add bl, '0'
        mov dl, bl
        mov ah, 02h
        int 21h  
    
    pop bx
    push bx
    and bx, 0000000000001111b  
    cmp bx, 9
    jbe printL
    add bx, 7
    
    printL:
        add bl, '0'
        mov dl, bl
        mov ah, 02h
        int 21h
        
    pop bx       
convertHexa endp  



romanAll proc
    lea dx, newLine
    mov ah, 09h
    int 21h
    lea dx, msgRoman
    mov ah, 09h
    int 21h
    push bx
    mov ax, bx
    mov cx, 100
    xor dx, dx
    div cx ; ax = bx/100
    mov bx, ax
    cmp bx, 0
    je tens  
    call romanHundred
    push dx  
    lea dx, result
    mov ah, 09h
    int 21h
    pop dx
    
    tens:
        mov ax, dx
        xor dx, dx
        mov cx, 10
        div cx ; ax = dx/10
        mov bx, ax
        cmp bx, 0 
        je ones 
        call romanTens
        push dx  
        lea dx, result
        mov ah, 09h
        int 21h 
        pop dx
    ones:
        mov bx, dx
        cmp bx, 0
        je finishAll 
        call roman 
        lea dx, result
        mov ah, 09h
        int 21h
        
        
    finishAll:
        jmp endProgram
        pop bx
        romanAll endp


romanHundred proc
    cmp bx, 1
    je firstVal
    cmp bx, 2
    je secondVal
    cmp bx, 3
    je thirdVal
    cmp bx, 4
    je fourthVal
    cmp bx, 5
    je fiveVal
    cmp bx, 6
    je sixVal
    cmp bx, 7
    je sevenVal
    cmp bx, 8
    je eightVal      
    mov byte ptr result, 'C' 
    mov byte ptr result+1, 'M' 
    mov byte ptr result+2, '$' 
    jmp finish 
    firstVal:
        mov byte ptr result, 'C'  
        mov byte ptr result+1, '$'
        jmp finish 
    secondVal:
       mov byte ptr result, 'C' 
       mov byte ptr result+1, 'C' 
       mov byte ptr result+2, '$'
        jmp finish
    thirdVal:
        mov byte ptr result, 'C' 
        mov byte ptr result+1, 'C'
        mov byte ptr result+2, 'C' 
        mov byte ptr result+3, '$'
        jmp finish
    fourthVal:
        mov byte ptr result, 'C' 
        mov byte ptr result+1, 'D'
        mov byte ptr result+2, '$'
        jmp finish 
    fiveVal:
        mov byte ptr result, 'D' 
        mov byte ptr result+1, '$'
        jmp finish
    sixVal:
        mov byte ptr result, 'D' 
        mov byte ptr result+1, 'C'
        mov byte ptr result+2, '$'
        jmp finish 
    sevenVal:
        mov byte ptr result, 'D' 
        mov byte ptr result+1, 'C'
        mov byte ptr result+2, 'C'
        mov byte ptr result+3, '$' 
        jmp finish
    eightVal:
        mov byte ptr result, 'D' 
        mov byte ptr result+1, 'C'
        mov byte ptr result+2, 'C'
        mov byte ptr result+3, 'C'
        mov byte ptr result+4, '$'
    finish: 
        ret
        romanHundred endp

romanTens proc
    cmp bx, 1
    je firstVal2
    cmp bx, 2
    je secondVal2
    cmp bx, 3
    je thirdVal2
    cmp bx, 4
    je fourthVal2
    cmp bx, 5
    je fiveVal2
    cmp bx, 6
    je sixVal2
    cmp bx, 7
    je sevenVal2
    cmp bx, 8
    je eightVal2      
    mov byte ptr result, 'X'
    mov byte ptr result+1, 'C'
    mov byte ptr result+2, '$'
    jmp finish2 
    firstVal2:
        mov byte ptr result, 'X'
        mov byte ptr result+1, '$'
        jmp finish2 
    secondVal2:
    mov byte ptr result, 'X'
        mov byte ptr result+1, 'X'
        mov byte ptr result+2, '$'
        jmp finish2
    thirdVal2:
        mov byte ptr result, 'X'
        mov byte ptr result+1, 'X'
        mov byte ptr result+2, 'X'
        mov byte ptr result+3, '$'
        jmp finish2
    fourthVal2:
        mov byte ptr result, 'X'
        mov byte ptr result+1, 'L'
        mov byte ptr result+2, '$'
        jmp finish2 
    fiveVal2:
        mov byte ptr result, 'L'
        mov byte ptr result+1, '$'
        jmp finish2
    sixVal2:
        mov byte ptr result, 'L'
        mov byte ptr result+1, 'X'
        mov byte ptr result+2, '$'
        jmp finish2 
    sevenVal2:
        mov byte ptr result, 'L'
        mov byte ptr result+1, 'X'
        mov byte ptr result+2, 'X'
        mov byte ptr result+3, '$'
        jmp finish2
    eightVal2:
        mov byte ptr result, 'L'
        mov byte ptr result+1, 'X'
        mov byte ptr result+2, 'X'
        mov byte ptr result+3, 'X'
        mov byte ptr result+4, '$'
    finish2:
        ret
        romanTens endp


roman proc
    cmp bx, 1
    je firstVal3
    cmp bx, 2
    je secondVal3
    cmp bx, 3
    je thirdVal3
    cmp bx, 4
    je fourthVal3
    cmp bx, 5
    je fiveVal3
    cmp bx, 6
    je sixVal3
    cmp bx, 7
    je sevenVal3
    cmp bx, 8
    je eightVal3      
    mov byte ptr result, 'I'
    mov byte ptr result+1, 'X'
    mov byte ptr result+2, '$'
    jmp finish3 
    firstVal3:
        mov byte ptr result, 'I'
        mov byte ptr result+1, '$'
        jmp finish3 
    secondVal3:
        mov byte ptr result, 'I'
        mov byte ptr result+1, 'I'
        mov byte ptr result+2, '$'
        jmp finish3
    thirdVal3:
        mov byte ptr result, 'I'
        mov byte ptr result+1, 'I'
        mov byte ptr result+2, 'I'
        mov byte ptr result+3, '$'
        jmp finish3
    fourthVal3:
        mov byte ptr result, 'I'
        mov byte ptr result+1, 'V'
        mov byte ptr result+2, '$'
        jmp finish3 
    fiveVal3:
        mov byte ptr result, 'V'
        mov byte ptr result+1, '$'
        jmp finish3
    sixVal3:
        mov byte ptr result, 'V'
        mov byte ptr result+1, 'I'
        mov byte ptr result+2, '$'
        jmp finish3 
    sevenVal3:
        mov byte ptr result, 'V'
        mov byte ptr result+1, 'I'
        mov byte ptr result+2, 'I'
        mov byte ptr result+3, '$'
        jmp finish3
    eightVal3:
        mov byte ptr result, 'V'
        mov byte ptr result+1, 'I'
        mov byte ptr result+2, 'I'
        mov byte ptr result+3, 'I'
        mov byte ptr result+4, '$'
    finish3:
        ret
        roman endp

        

    
endProgram:
        
   
    
end main
        
    