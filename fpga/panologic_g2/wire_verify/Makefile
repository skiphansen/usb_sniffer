PROJECT=wire_verify
PART=xc6slx150-2-fgg484
CABLE ?= jtaghs2

TOOL_PATH ?= /opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64
CORES_PATH = ../../cores
CORES_README = ${CORES_PATH}/README.md

all: ${CORES_README} ${PROJECT}_routed.bit

project/${PROJECT}.prj:
	mkdir -p project
	echo "verilog work \"../${PROJECT}.v\"" >> project/${PROJECT}.prj

${PROJECT}.ngc: project/${PROJECT}.prj	
	cp ${PROJECT}.* project/
	mkdir -p project/xst/projnav.tmp/
	cd project; ${TOOL_PATH}/xst -intstyle ise -ifn ${PROJECT}.xst -ofn ${PROJECT}.syr
        
${PROJECT}.ngd: ${PROJECT}.ngc
	cd project; ${TOOL_PATH}/ngdbuild -intstyle ise -dd _ngo -nt timestamp \
	-uc ${PROJECT}.ucf -p ${PART} ${PROJECT}.ngc ${PROJECT}.ngd

${PROJECT}.ncd: ${PROJECT}.ngd
	cd project; ${TOOL_PATH}/map -w -intstyle ise -p ${PART} \
	-detail -ir off -ignore_keep_hierarchy -pr b -timing -ol high -logic_opt on  \
	-o ${PROJECT}.ncd ${PROJECT}.ngd ${PROJECT}.pcf 

${PROJECT}_routed.ncd: ${PROJECT}.ncd
	cd project; ${TOOL_PATH}/par -w -intstyle ise -ol high ${PROJECT}.ncd ${PROJECT}_routed.ncd ${PROJECT}.pcf

${PROJECT}_routed.bit: ${PROJECT}_routed.ncd
	cd project; ${TOOL_PATH}/bitgen -f ${PROJECT}.ut ${PROJECT}_routed.ncd

${CORES_README}:
	git submodule init
	git submodule update

load:
	xc3sprog -c ${CABLE} project/${PROJECT}_routed.bit

clean:
	@rm -rf project
