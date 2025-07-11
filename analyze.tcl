# Load technology LEF (hiểu hình học của lớp metal/pin)
read_lef ~/sky130_workspace/open_pdks/sky130/sky130A/libs.ref/sky130_fd_sc_hdll/techlef/sky130_fd_sc_hdll__nom.tlef

# Load standard cell LEF (dùng script có sẵn)
source ~/sky130_workspace/open_pdks/sky130/sky130A/libs.ref/sky130_fd_sc_hdll/lef/load_lef.tcl

# Load Liberty (cho timing và power, corner typical: tt_025C_1v80)
read_liberty ~/sky130_workspace/open_pdks/sky130/sky130A/libs.ref/sky130_fd_sc_hdll/lib/sky130_fd_sc_hdll__tt_025C_1v80.lib

# Load synthesized Verilog netlist
read_verilog TOP_NUMBER_mapped.v

# Chỉ định top module
link_design TOP_NUMBER

# Tạo clock 10 kHz (chu kỳ = 100000 ns)
create_clock -name CLK -period 100000 [get_ports CLK]

# ------------------ Floorplan ------------------

# Khởi tạo mặt bằng với site rõ ràng
initialize_floorplan -site unithd -utilization 0.5 -core_space 10 -aspect_ratio 1.0

# ------------------ Placement ------------------

# Thêm tap cells để tránh DRC
tapcell -distance 14 -tapcell_master sky130_fd_sc_hdll__tap_1

# Đặt vị trí cell
global_placement

# ------------------ Routing ------------------

# Global routing
global_routing

# Detailed routing
detailed_routing

# ------------------ Export Layout ------------------

write_def TOP_NUMBER.def
write_gds TOP_NUMBER.gds

# ------------------ Phân tích và Ghi Log ------------------

report_checks -path_delay min_max -fields {endpoint_slack path delay} > timing.rpt
report_power > power.rpt
report_design_area > area.rpt

# ------------------ GUI ------------------

gui_start
