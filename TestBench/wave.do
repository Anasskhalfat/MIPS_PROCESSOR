onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/Reset
add wave -noupdate /testbench/Clk
add wave -noupdate /testbench/i1/PC/PC_Out
add wave -noupdate /testbench/i1/BTB/Hit
add wave -noupdate -radix decimal /testbench/i1/BTB/Branch_Addr
add wave -noupdate -radix hexadecimal /testbench/i1/IM/Instr
add wave -noupdate -radix decimal /testbench/i1/PCS/Mux_Out
add wave -noupdate -radix decimal /testbench/i1/RF/Read_Data_1
add wave -noupdate -radix decimal /testbench/i1/RF/Read_Data_2
add wave -noupdate -radix decimal /testbench/i1/SEU/Data_Out
add wave -noupdate -radix decimal -childformat {{/testbench/i1/ALU/OP1(31) -radix decimal} {/testbench/i1/ALU/OP1(30) -radix decimal} {/testbench/i1/ALU/OP1(29) -radix decimal} {/testbench/i1/ALU/OP1(28) -radix decimal} {/testbench/i1/ALU/OP1(27) -radix decimal} {/testbench/i1/ALU/OP1(26) -radix decimal} {/testbench/i1/ALU/OP1(25) -radix decimal} {/testbench/i1/ALU/OP1(24) -radix decimal} {/testbench/i1/ALU/OP1(23) -radix decimal} {/testbench/i1/ALU/OP1(22) -radix decimal} {/testbench/i1/ALU/OP1(21) -radix decimal} {/testbench/i1/ALU/OP1(20) -radix decimal} {/testbench/i1/ALU/OP1(19) -radix decimal} {/testbench/i1/ALU/OP1(18) -radix decimal} {/testbench/i1/ALU/OP1(17) -radix decimal} {/testbench/i1/ALU/OP1(16) -radix decimal} {/testbench/i1/ALU/OP1(15) -radix decimal} {/testbench/i1/ALU/OP1(14) -radix decimal} {/testbench/i1/ALU/OP1(13) -radix decimal} {/testbench/i1/ALU/OP1(12) -radix decimal} {/testbench/i1/ALU/OP1(11) -radix decimal} {/testbench/i1/ALU/OP1(10) -radix decimal} {/testbench/i1/ALU/OP1(9) -radix decimal} {/testbench/i1/ALU/OP1(8) -radix decimal} {/testbench/i1/ALU/OP1(7) -radix decimal} {/testbench/i1/ALU/OP1(6) -radix decimal} {/testbench/i1/ALU/OP1(5) -radix decimal} {/testbench/i1/ALU/OP1(4) -radix decimal} {/testbench/i1/ALU/OP1(3) -radix decimal} {/testbench/i1/ALU/OP1(2) -radix decimal} {/testbench/i1/ALU/OP1(1) -radix decimal} {/testbench/i1/ALU/OP1(0) -radix decimal}} -subitemconfig {/testbench/i1/ALU/OP1(31) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(30) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(29) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(28) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(27) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(26) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(25) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(24) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(23) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(22) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(21) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(20) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(19) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(18) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(17) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(16) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(15) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(14) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(13) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(12) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(11) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(10) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(9) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(8) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(7) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(6) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(5) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(4) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(3) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(2) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(1) {-height 15 -radix decimal} /testbench/i1/ALU/OP1(0) {-height 15 -radix decimal}} /testbench/i1/ALU/OP1
add wave -noupdate -radix decimal /testbench/i1/ALU/OP2
add wave -noupdate -radix decimal /testbench/i1/ALU/ALU_Result
add wave -noupdate -radix decimal /testbench/i1/DM/Address
add wave -noupdate -radix decimal /testbench/i1/DM/Write_Data
add wave -noupdate -radix decimal /testbench/i1/DM/Read_Data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {335 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 209
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {718 ps}
