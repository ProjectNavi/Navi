# vi: set ts=8 sw=8 sts=8 noexpandtab:
TARGET_ARCH				:= arm
TARGET_CPU				:= s5pc210
TARGET_BOARD			:= smdkc210
CROSS_PREFIX            := arm-linux-gnueabihf-

CC                      := $(CROSS_PREFIX)gcc
AS                      := $(CROSS_PREFIX)as
LD                      := $(CROSS_PREFIX)ld
NM                      := $(CROSS_PREFIX)nm
STRIP                   := $(CROSS_PREFIX)strip
OBJCOPY                 := $(CROSS_PREFIX)objcopy
SIZE                    := $(CROSS_PREFIX)size
CP                      := /bin/cp -f
RM                      := /bin/rm -rf


INCLUDES                := -I. -I$(TOPDIR)/include
DEFINES                 := -D__ARCH_$(TARGET_ARCH)__ -D__CPU_$(TARGET_CPU)__ -D__BOARD_$(TARGET_BOARD)__
DEFINES                 += -DOS_RAM_BASE=0x40100000
DEFINES                 += -DDEBUG

CFLAGS                  := -nostdinc 
#CFLAGS                	+= -O2 -fomit-frame-pointer
CFLAGS					+= -march=armv7-a -mcpu=cortex-a9 -mtune=cortex-a9
CFLAGS					+= -mabi=aapcs-linux
CFLAGS                  += -fno-strict-aliasing -fno-common -fno-builtin -fno-stack-protector
CFLAGS                  += -W -Wall -Wstrict-prototypes
CFLAGS                  += -Wno-unused -Wno-sign-compare
CFLAGS                  += $(INCLUDES)
CFLAGS                  += $(DEFINES)
CFLAGS                  += -ggdb
#CFLAGS                  += -save-temps

OFLAGS                  := -O binary -R .note -R .comment -S
LDFLAGS                 := -nostdlib -nostartfiles -nodefaultlibs -static -X
LDRELOC                 := -r
LIBGCC                  := $(shell $(CC) -print-libgcc-file-name)
LDSCRIPT                := -T $(TOPDIR)/script/$(TARGET_CPU)/boot.lds
KERNELLDSCRIPT                := -T $(TOPDIR)/script/kernel/kernel.lds

.SUFFIXES : .o .c .S

%.o:%.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o:%.S
	$(CC) $(CFLAGS) -c $< -o $@
