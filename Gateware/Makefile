TARGET = out.vcd pdm.dat out pdm.csv
CC = iverilog -g2012
PY = python3
TEST = tests/pdm.sv
TESTPY = tests/pdm.py
GRAPHPY = src/ref.py
SRC = src/cic.v src/fir.v



all: build

test: build
	$(PY) $(TESTPY)
	./out

graph: test
	$(PY) $(GRAPHPY)

build: $(SRC) $(TEST)
	$(CC) $(SRC) $(TEST) -o out

clean:
	rm -f $(TARGET) 
