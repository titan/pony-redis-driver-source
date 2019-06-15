NAME=redis

include .config
ESCAPED_BUILDDIR = $(shell echo '${BUILDDIR}' | sed 's%/%\\/%g')
TARGET=$(BUILDDIR)/$(NAME)
SRCS=$(NAME).pony
FSMS=lexer.pony syntax.pony
TEST=tester.pony

vpath %.pony $(BUILDDIR)
vpath %.txt $(BUILDDIR)
vpath %.org .

all: $(SRCS) $(FSMS)

$(SRCS): %.pony: %.org
	sed 's/$$$\{BUILDDIR}/$(ESCAPED_BUILDDIR)/g' $< | sed 's/$$$\{NAME}/$(NAME)/g' | org-tangle -

$(FSMS): %.pony: %.txt
	fsmc.py -t pony $(addprefix $(BUILDDIR)/, $(notdir $<)) $(FSMFLAGS)

$(subst pony,txt,$(FSMS)): $(NAME).org
	sed 's/$$$\{BUILDDIR}/$(ESCAPED_BUILDDIR)/g' $< | sed 's/$$$\{NAME}/$(NAME)/g' | org-tangle -

$(TEST): %.pony: %.org
	sed 's/$$$\{BUILDDIR}/$(ESCAPED_BUILDDIR)/g' $< | sed 's/$$$\{NAME}/$(NAME)/g' | sed 's/$$$\{HOST}/$(HOST)/g' | sed 's/$$$\{PORT}/$(PORT)/g' | org-tangle -

test: $(TARGET)

$(TARGET): $(SRCS) $(FSMS) $(TEST)
	cd $(BUILDDIR); ponyc; cd -

clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean
