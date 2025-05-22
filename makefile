OUT_DIR = out
OBJ_DIR = out/obj

BOOT_DIR = boot
MBR_BIN = mbr.bin
LOADER_BIN = loader.bin
IMG = master.img

MBR_TEST_BIN = mbr_test.bin
IMG_TEST = fd2_88m_test.img

master:
	#bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat master.img
	dd if=/dev/zero of=$(OUT_DIR)/$(IMG) bs=512 count=32768

mbr:
	nasm -I $(BOOT_DIR)/include/ -o $(OBJ_DIR)/$(MBR_BIN) $(BOOT_DIR)/mbr.asm
	dd if=$(OBJ_DIR)/$(MBR_BIN) of=$(OUT_DIR)/$(IMG) bs=512 count=1 conv=notrunc

mbr_test:
	nasm -o $(OBJ_DIR)/$(MBR_TEST_BIN) $(BOOT_DIR)/test/mbr_test.asm
	dd if=$(OBJ_DIR)/$(MBR_TEST_BIN) of=$(OUT_DIR)/$(IMG_TEST) bs=512 count=1 conv=notrunc

loader:
	nasm -I $(BOOT_DIR)/include/ -o $(OBJ_DIR)/$(LOADER_BIN) $(BOOT_DIR)/loader.asm
	dd if=$(OBJ_DIR)/$(LOADER_BIN) of=$(OUT_DIR)/$(IMG) bs=512 count=1 seek=2 conv=notrunc

clean:
	rm $(OBJ_DIR)/$(MBR_BIN) $(OBJ_DIR)/$(LOADER_BIN) $(OUT_DIR)/$(IMG)

	#rm $(OBJ_DIR)/$(MBR_TEST_BIN) $(OUT_DIR)/$(IMG_TEST)
