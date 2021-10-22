NAME = fps-game
STACKLIBFILE = $(shell stack path --local-install-root)/lib/lib$(NAME).so
GODOTPROJECT = $(shell stack path --project-root)/game

all: stack
stack:
	stack build --fast --force-dirty
	cp $(STACKLIBFILE) $(GODOTPROJECT)/lib
stack-run:
	stack build
	cp $(STACKLIBFILE) $(GODOTPROJECT)/lib
	godot -e --path ./game
stack-watch:
	stack build --file-watch --fast --exec "cp $(STACKLIBFILE) $(GODOTPROJECT)/lib"
project-watch:
	stack exec godot-haskell-project-generator game src
updatelib:
	cp $(STACKLIBFILE) $(GODOTPROJECT)/lib