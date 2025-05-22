%include "boot.inc"

; jmp 0:0x7c00
; 即 cs:ip
SECTION MBR vstart=MBR_BASE_ADDR
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov fs, ax
	mov sp, MBR_BASE_ADDR
	mov ax, 0xb800
	mov gs, ax
	call show_text
	jmp will_loader

show_text:
;上卷全部行进行清空
	mov ax, 0x0600
	mov bx, 0x0700
	mov cx, 0x0000
	mov dx, 0x184f
	int 0x10

    mov di, 0x00
    mov si, mbr_str
print:
    mov al, [si]
    cmp al, 0
    je return_place
    mov byte [gs:di], al
    mov byte [gs:di+1], 0xa4
    inc si
    add di, 2
    jmp print
return_place:
    ret


will_loader:
	; 调用函数前准备数据
	mov eax, LOADER_START_SECTOR		; 起始扇区lba地址，即扇区编号
	mov bx, LOADER_BASE_ADDR		; 读取的数据写入到的地址
	mov cx, 1				; 待读入的扇区数
	call read_disk_m_16			; 执行读取loader程序
	jmp LOADER_BASE_ADDR			; 跳转到loader程序执行

; 功能：从硬盘中读取loader程序
read_disk_m_16:
	mov esi, eax				; 备份eax
	mov di, cx				    ; 备份cx
; 读写硬盘
; 第一步，设置读取的扇区数
	mov dx, 0x01f2
	mov al, cl
	out dx, al				    ; 读取的扇区数
	mov eax, esi				; 恢复 ax
; 第二步，将LBA地址存入0x1f3~0x1f6
; 将LAB地址7~0位写入端口 0x01f3
	mov dx, 0x01f3
	out dx, al

; 将LAB地址8~15位写入端口 0x01f4
	mov cl, 8
	shr eax, cl
	mov dx, 0x01f4
	out dx, al

; 将LABD地址16~23位写入端口 0x01f5
	shr eax, cl
	mov dx, 0x01f5
	out dx, al

; 将LAB地址24~27位
	shr eax, cl
	and al, 0x0f				; 获取lba第24~27位
	or al, 0xe0				    ; 设置7~4位为1110，表示lba模式
	mov dx, 0x01f6
	out dx, al

; 第三步，向0x01f7端口写入读命令，0x20
	mov dx, 0x01f7
	mov al, 0x20
	out dx, al

; 第四步，检测硬盘状态
.not_ready:
	nop
	in al, dx
	and al, 0x88				; 第3位为1，表示硬盘控制器已经准备好传输数据
						        ; 第7位为1， 表示硬盘忙
	cmp al, 0x08
	jnz .not_ready				; 如未备好，则继续等待

; 第5步，从0x01f0端口开始读取数据
	mov ax, di
	mov dx, 256
	mul dx
	mov cx, ax			; 循环次数保存在cx中用于限制读取数据的次数
	mov dx, 0x01f0
.go_on_read:
	in ax, dx
	mov [bx], ax
	add bx, 2
	loop .go_on_read
	ret

    mbr_str db 'MBR, START!', 0
	times 510-($-$$) db 0
	db 0x55, 0xaa
