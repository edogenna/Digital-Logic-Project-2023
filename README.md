# [Digital Logic](https://www11.ceda.polimi.it/schedaincarico/schedaincarico/controller/scheda_pubblica/SchedaPublic.do?&evn_default=evento&c_classe=788722&polij_device_category=DESKTOP&__pj0=0&__pj1=9cc3f34aabe22aeab794c35ef361f0cf) 2023, Course Final Project

This project is the final test of the "Digital Logic" course at the Polytechnic of Milan, A.Y. 2022/23.
I did this project in pairs collaborating with my university mate [Samuele Galli](https://github.com/SamuGalli).


Evaluation: 30 / 30

- [Docs](#docs)
- [Project Description](#project-description)
- [Testbench](#testbench)
- [Software Used](#software-used)


## Docs

Project: [FILE](project.vhd)

Description of the problem: [ITA](doc/Tema_ITA.pdf) ,  [ENG](doc/Tema_ENG.pdf)

Final report: [ITA](doc/Report_ITA.pdf) ,  [ENG](doc/Report_ENG.pdf)


## Project Description

The objective of the project is to realize a HW component that, having received
as input a memory address and information regarding the required
output channel, prints the contents of the address on the specified channel.

Seven interfaces are presented, including 2 primary inputs (W and START),
both 1 bit, and 5 outputs (Z0, Z1, Z2, Z3, DONE), of which, the first 4 (8
bits), on which all bits of the memory word are to be reported, and DONE
1 bit. There is also a reset signal (RESET) and a clock signal (CLK),
unique to the component.

The specification calls for implementing a hardware module in VHDL that
interfaces with a memory and receives information via a one-bit serial input
about a memory location whose contents are to be routed to one of four
available output channels.



## Testbench

| test | description |
|---|---|
| [0bit](testbench/tb_address_0bit.vhd) | corner case with length of address 0 |
| [16bit](testbench/tb_address_16bit.vhd) | corner case with length of address 0 |
| [data](testbench/tb_data0.vhd) | generic test |
| [reset](testbench/tb_long.vhd) | reset during processing |
| [long](testbench/tb_reset.vhd) | stress test |

## Software Used
- Xilinx Vivado
