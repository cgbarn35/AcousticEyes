TARGET = pdm pdm.vcd pdm.dat pdm.csv pdm.mem music music.dat fir.wav
CC = iverilog -g2012
PY = python3
PDM = tests/pdm.sv
MUSIC = tests/music.sv
PDMPY = tests/pdm.py
GRAPHPY = src/ref.py
MUSICPY = src/wavOut.py
SRC = src/cic.v src/fir.v src/clkdiv.v


all: build

music: $(SRC) $(MUSIC) music.dat
	$(CC) $(SRC) $(MUSIC) -o music
	./music
	$(PY) $(MUSICPY)

graph: test
	$(PY) $(GRAPHPY)

test: build
	$(PY) $(PDMPY)
	./pdm

music.dat: 
	$(PY) tests/music.py

build: $(SRC) $(PDM) #TODO ADD MORE BUILDING HERE
	$(CC) $(SRC) $(PDM) -o pdm

clean:
	rm -f $(TARGET) 
