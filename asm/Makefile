OBJDIR := obj
EXEDIR := exe
NAME := main
TARGET := $(EXEDIR)/$(NAME)
RUN_NAME := $(NAME)

all: $(TARGET)

$(TARGET): $(OBJDIR)/$(NAME).o
	mkdir -p $(EXEDIR)
	ld -v -macosx_version_min 10.13 -e _start -static $(OBJDIR)/$(NAME).o -o $(TARGET)

$(OBJDIR)/$(NAME).o: $(NAME).s
	mkdir -p $(OBJDIR)
	nasm -f macho64 -o $(OBJDIR)/$(NAME).o $(NAME).s

run: $(EXEDIR)/$(RUN_NAME)
	./$(EXEDIR)/$(RUN_NAME)

clean:
	rm -rf $(OBJDIR) $(EXEDIR)

.PHONY: all run clean