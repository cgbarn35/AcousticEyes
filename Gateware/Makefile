TARGET = out.vcd
CC = iverilog 
TEST = tests/pdm_example.sv
SRC = src/cic3r32.v



all: build

test: build
	./out

build: $(SRC) $(TEST)
	$(CC) $(SRC) $(TEST) -o out

clean:
	rm -f $(TARGET) 
