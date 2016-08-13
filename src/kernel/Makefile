ifndef TOPDIR
TOPDIR := ../..
endif

include $(TOPDIR)/Config.mk

TARGET      := kernel.bin.o

OBJS        += $(patsubst %.S, %.o, $(wildcard *.S))
OBJS        += $(patsubst %.c, %.o, $(wildcard *.c))


all : kernel
	$(LD) -r -o $(TARGET) -b binary kernel.bin
	$(NM) Kernel | grep -v '\(compiled\)\|\(\.o$$\)\|\( [aUw] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)' | sort > Symbols.map
	cp $(TARGET) ../

kernel: compile $(OBJS)
	$(LD) $(KERNELLDSCRIPT) $(OBJS) -o Kernel -N
	#$(LD) $(OBJS) -o Kernel -Ttext 0x40100000 -N
	$(OBJCOPY) Kernel kernel.bin -O binary

compile:
	@for dir in $(SUBDIRS); do \
	make -C $$dir || exit $?; \
	done

clean:
	@for dir in $(SUBDIRS); do \
	make -C $$dir clean; \
	done
	rm -rf *.o *.i *.s *.bin Kernel *.map $(TARGET)
