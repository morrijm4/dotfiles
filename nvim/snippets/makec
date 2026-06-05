CC = gcc
CMD = cmd
SRC = main.c
DEBUG_FLAGS = -g -fsanitize=address -fno-omit-frame-pointer 
CFLAGS = -Wall -Wextra -o $(CMD) $(DEBUG_FLAGS)

$(CMD): $(SRC)
	$(CC) $(CFLAGS) $(SRC)

run: $(CMD)
	./$(CMD)

clean:
	rm $(CMD)

install: $(CMD)
	cp $(CMD) /usr/local/bin

flags:
	echo "$(CFLAGS)" | tr ' ' '\n' > compile_flags.txt
