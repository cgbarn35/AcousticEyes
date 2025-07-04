TARGET = out.vcd pdm.dat out
CC = iverilog -g2012
PY = python3
TEST = tests/pdm_example.sv
TESTPY = tests/pdm.py
SRC = src/cic3r32.v



all: build

test: build
	$(PY) $(TESTPY)
	./out

build: $(SRC) $(TEST)
	$(CC) $(SRC) $(TEST) -o out

clean:
	rm -f $(TARGET) 
