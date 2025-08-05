CC = iverilog -g2012
PY = python3

RTL_DIR = ../../rtl
BUILD_DIR = ../../../../build

DUT = fifo
VERILOG_SOURCES += $(RTL_DIR)/sync_fifo.v
VERILOG_SOURCES += $(DUT).sv 

#PYTHON_SOURCES += $(DUT).py

#OUTPUT_SOURCES += out.py #Bad term TODO?

#module parameters
#TODO

all: $(DUT).vcd

$(DUT): $(VERILOG_SOURCES)
	$(CC) $(VERILOG_SOURCES) -o $(BUILD_DIR)/$(DUT)

$(DUT).vcd: $(DUT)
	$(BUILD_DIR)/$(DUT)

#music UTILIZES music.sv, music.py, out.py, cic.v, fir.v, clkdiv.v, fir_comb.v
#using music is going through 
#iverilog -g2012 cic.v fir.v fir_comb.v music.sv 
#python3 music.py 
#python3 ref.py
