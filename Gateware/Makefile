TARGET = pdm pdm.vcd pdm.dat pdm.csv pdm.mem music music.dat fir.wav
CC = iverilog -g2012
PY = python3
PDM = tests/pdm.sv
PDMPY = tests/pdm.py
GRAPHPY = src/ref.py
MUSIC = tests/music.sv
MUSICPY = tests/music.py
WAVPY = src/wavOut.py
SRC = src/cic.v src/fir.v src/clkdiv.v src/fir_comb.v


all: build

music: $(SRC) $(MUSIC) music.dat
	$(CC) $(SRC) $(MUSIC) -o music
	./music
	$(PY) $(WAVPY)

graph: pdm.vcd
	$(PY) $(GRAPHPY)

pdm: $(SRC) $(PDM) 
	$(CC) $(SRC) $(PDM) -o pdm

pdm.vcd: pdm $(PDMPY)
	$(PY) $(PDMPY)
	./pdm

music.dat: $(MUSICPY)
	$(PY) $(MUSICPY)

clean:
	rm -f $(TARGET) 
