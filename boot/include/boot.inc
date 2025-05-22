MBR_BASE_ADDR            equ 0x7c00
LOADER_BASE_ADDR         equ 0x0900
LOADER_START_SECTOR      equ 0x02

PAGE_DIR_TABLE_ADDR      equ 0x100000

MEMORY_BASE			equ		0x00
MEMORY_LIMIT		equ		((1024 * 1024 * 1024 * 4) / (1024 * 4)) - 1

code_selector	    equ		0x01 << 3
data_selector	    equ		0x02 << 3