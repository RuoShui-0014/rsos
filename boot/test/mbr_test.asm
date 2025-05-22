[bits 16]
SECTION MBR vstart=0x7c00
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov fs, ax
	mov sp, 0x7c00
	mov ax, 0xb800
	mov gs, ax

;上卷全部行进行清空
	mov ax, 0x0600
	mov bx, 0x0700
	mov cx, 0x0000
	mov dx, 0x184f
	int 0x10

    mov di, 0x00
    mov si, MBR_STR
.show_text:
    mov al, [si]
    cmp al, 0
    je .stop
    mov byte [gs:di], al
    mov byte [gs:di+1], 0xa4
    inc si
    add di, 2
    jmp .show_text

.stop:
    jmp $

    MBR_STR db 'This is rs os mbr start!test', 0
	times 510-($-$$) db 0
	db 0x55, 0xaa
