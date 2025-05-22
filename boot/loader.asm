%include "boot.inc"

SECTION loader vstart=LOADER_BASE_ADDR
    ;上卷全部行进行清空
    mov ax, 0x0600
    mov bx, 0x0700
    mov cx, 0x0000
    mov dx, 0x184f
    int 0x10

; 准备进入保护模式
loader_start:
	; 打开A20
	in al, 0x92
	or al, 0000_0010b
	out 0x92, al

	; 加载GDT
	lgdt [gdt_ptr]

	; cr0的0位置为1
	mov eax, cr0
	or eax, 0x00000001
	mov cr0, eax

    ; 刷新流水线，避免分支预测的影响,这种cpu优化策略，最怕jmp跳转
	jmp dword code_selector: protect_mode

[bits 32]
protect_mode:
	mov ax, data_selector
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov esp, 0x10000	; 修改栈顶

    call print_loader
	call setup_page

	jmp $

print_loader:
    mov byte [0xb8000], 'L'
    mov byte [0xb8001], 0xa4
    mov byte [0xb8002], 'O'
    mov byte [0xb8003], 0xa4
    mov byte [0xb8004], 'A'
    mov byte [0xb8005], 0xa4
    mov byte [0xb8006], 'D'
    mov byte [0xb8007], 0xa4
    mov byte [0xb8008], 'E'
    mov byte [0xb8009], 0xa4
    mov byte [0xb800a], 'R'
    mov byte [0xb800b], 0xa4
    ret
setup_page:
; 构建页目录表
    mov ecx, 1024
    mov esi, 0
clear_page_dir:
    mov dword [PAGE_DIR_TABLE_ADDR + esi], 0
    add esi, 4
    loop clear_page_dir

    mov eax, PAGE_DIR_TABLE_ADDR
    ret

MEMORY_BASE			equ		0x00
MEMORY_LIMIT		equ		((1024 * 1024 * 1024 * 4) / (1024 * 4)) - 1

GDT_BASE:									; 全局描述符表起始地址，第一个段描述符8字节都为0
	dq		0x00
CODE_DESC:
	dw		MEMORY_LIMIT & 0xffff			; 界限 0 ~ 15 位
	dw		MEMORY_BASE & 0x0000ffff		; 基地址 0 ~ 15 位
	db		(MEMORY_BASE >> 16) & 0xff		; 基地址 16 ~ 23 位
	db		0b_1_00_1_1010					; 段类型
	db		0b_1_1_0_0_0000 | (MEMORY_LIMIT >> 16) & 0x0f
	db		(MEMORY_BASE >> 24) & 0xff		; 基地址 24 ~ 31 位
DATA_DESC:
	dw		MEMORY_LIMIT & 0xffff			; 界限 0 ~ 15 位
	dw		MEMORY_BASE & 0x0000ffff		; 基地址 0 ~ 15 位
	db		(MEMORY_BASE >> 16) & 0xff		; 基地址 16 ~ 23 位
	db		0b_1_00_1_0010					; 段类型
	db		0b_1_1_0_0_0000 | (MEMORY_LIMIT >> 16) & 0x0f
	db		(MEMORY_BASE >> 24) & 0xff		; 基地址 24 ~ 31 位
GDT_END:

; GDT 相关内容
gdt_ptr			dw		GDT_END - GDT_BASE - 1	; 界限值
				dd		GDT_BASE				; 全局描述符地址

code_selector	equ		0x01 << 3
data_selector	equ		0x02 << 3
