TOPDIR	= $(shell pwd)

SUBDIRS                 := common
TARGET                  := navi.img
ELF                     := navi.elf

include                 $(TOPDIR)/Config.mk

all: compile $(TARGET) result

$(ELF): $(addsuffix /target.o,$(SUBDIRS))
	$(LD) $(LDFLAGS) $(LDSCRIPT) -N $^ $(LIBGCC) -o $@
	$(NM) $(ELF) | grep -v '\(compiled\)\|\(\.o$$\)\|\( [aUw] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)' | sort > Symbols.map

$(TARGET): $(ELF)
	$(OBJCOPY) $(OFLAGS) $^ $@

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
