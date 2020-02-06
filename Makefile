VIVADO_VER   := 2019.1
project_path := ./fw/vivado-prj/ 
prj_name     := template
bitstream    := $(project_path)$(prj_name).bit
synth        := $(project_path)post_synth.dcp
route        := $(project_path)post_route.dcp

.PHONY: all ips bd prj bitstream clean synth route 

all: help
synth: $(synth)
route: $(route)
bitstream: $(bitstream)

clean:
	cd $(project_path) rm -f **/*.dcp; rm -f **/*.rpt; rm -f **/*.bit; rm -rf $(prj_name)

help:
	@echo "=================="
	@echo "=== How To use ==="
	@echo "=================="
	@echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
	@echo "%Made with Vivado $(VIVADO_VER)%"
	@echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
	@echo "Ensure you have properly source Vivado 2019.1"
	@echo "		help - display this message"
	@echo "		ips  - Generate the IP cores that will be used in this project"
	@echo "		bd   - Generate the Block Design portion of this design"
	@echo "		package - Generate the project and run syn and impl, this will also generate reports."
	@echo "		system  - Generate Everything"
	@echo "		 ////CAUTION - Ensure ips have been made first\\\\"
	@echo ""
	@echo ""
	@echo ""
	@echo ""
	@echo ""
	@echo ""

ips:
	@echo "=================="
	@echo "=== Making IPs ==="
	@echo "=================="
	cd $(project_path); vivado -mode batch -source manage_ip.tcl

bd:
	@echo "=================="
	@echo "=== Making BD  ==="
	@echo "=================="
	cd $(project_path); vivado -mode batch -source psProc.tcl

package:
	@echo "========================"
	@echo "=== Making Top Lvel  ==="
	@echo "========================"
	cd $(project_path); vivado -mode batch -source package.tcl

system: ips bd package
	@echo "========================"
	@echo "===    Making All    ==="
	@echo "========================"
