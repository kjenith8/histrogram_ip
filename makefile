#author 		: Jenith
#File Name 		: make.mk
#version 		: 0.1
#Description	: Just to see how make file works

txt_files ?= a.txt b.txt c.txt

py_files ?= $(shell find . -name "*.py")

file_create : $(txt_files) $(py_files)
	$(greetings)

define greetings
	@echo "Hello World"
endef


$(py_files):
	touch $@
$(txt_files): 
	touch $@

clean:
	rm -f *.txt *.py

info:
	echo "Here is the info"

.PHONY:
	info

.DEFAULT:
	@echo "No such target"

.SILENT: info

.IGNORE : clean
