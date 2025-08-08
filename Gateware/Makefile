DSP_RTL_DIR = src/dsp/rtl
DSP_TB_DIR =  src/dsp/tb
MISC_RTL_DIR = src/misc/rtl
BUILD_DIR = build

music:
	make -C $(DSP_TB_DIR)/fir_music/ FREQ=$(FREQ)
	audacity $(BUILD_DIR)/out.wav
pdm:
	make -C $(DSP_TB_DIR)/fir_pdm/
comp: 
	make -C $(DSP_TB_DIR)/fir_comp/
pdm_c: 
	make -C $(DSP_TB_DIR)/fir_pdm_comb/
fifo:
	make -C $(DSP_TB_DIR)/fir_fifo/
clean:
	rm build/*



.PHONY: music pdm
