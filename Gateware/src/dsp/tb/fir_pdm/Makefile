DUT = pdm
HZ ?= 10
CC = iverilog -P $(DUT).FreqSet=$(HZ) -g2012 
PY ?= python3

RTL_DIR = ../../rtl
BUILD_DIR = ../../../../build

VERILOG_SOURCES += $(RTL_DIR)/cic.v
VERILOG_SOURCES += $(RTL_DIR)/fir.v
VERILOG_SOURCES += $(RTL_DIR)/mac.v
VERILOG_SOURCES += $(RTL_DIR)/clkdiv.v
VERILOG_SOURCES += $(DUT).sv 

PYTHON_SOURCES += $(DUT).py

OUTPUT_SOURCES += out.py #Bad term TODO?

#module parameters
#TODO

all: output

$(DUT): $(VERILOG_SOURCES)
	$(CC) $(VERILOG_SOURCES) -o $(BUILD_DIR)/$(DUT)

$(DUT).vcd: $(DUT) 
	$(PY) $(PYTHON_SOURCES)
	./$(BUILD_DIR)/$(DUT)

output: $(DUT).vcd
	$(PY) $(OUTPUT_SOURCES)


#music UTILIZES music.sv, music.py, out.py, cic.v, fir.v, clkdiv.v, fir_comb.v
#using music is going through 
#iverilog -g2012 cic.v fir.v fir_comb.v music.sv 
#python3 music.py 
#python3 ref.py
