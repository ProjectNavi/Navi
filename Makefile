TOPDIR	= $(shell pwd)

SUBDIRS                 := src
TARGET                  := navi.img
ELF                     := navi.elf

include                 $(TOPDIR)/Config.mk

all: compile $(TARGET) result

$(ELF): $(addsuffix /target.o,$(SUBDIRS))
	cp $^ $@
	$(NM) $(ELF) | grep -v '\(compiled\)\|\(\.o$$\)\|\( [aUw] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)' | sort > Symbols.map

$(TARGET): $(ELF)
	$(OBJCOPY) $(OFLAGS) $^ $@

# Emulator
run: all
	gnome-terminal --hide-menubar -e "qemu-system-arm -M smdkc210 -display none -serial stdio -kernel $(TARGET)" &

result:
	@$(SIZE) $(ELF)

compile:
	@for dir in $(SUBDIRS); do \
	make -C $$dir || exit $?; \
	done

clean:
	@for dir in $(SUBDIRS); do \
	make -C $$dir clean; \
	done
	rm -rf *.o *.i *.s *.map $(TARGET) $(ELF)
