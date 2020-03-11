# RISC-V CPU 大作业 report

### 1.简介

本次大作业主要目的是实现一个基于riscv架构，rv32i指令集的cpu。

>- IF-ID-EX-MEM-WB standard pipeline
>- full data forwarding
>- static branch prediction (not taken)
>- pass FPGA test 200MHz
>- 512Byte I-cache

主要使用verilog硬件设计语言编写，使用Xilinx Vivado进行仿真测试和综合

### 2.架构示意图及说明





#### 说明

- Stall-ctrl：控制模块，可以通过暂停流水线寄存器实现流水的暂停
- Icache：Direct-map指令缓存，用于暂存取到的指令，实现hit时能够2周期快速得到指令
- Memory-controller：内存管理模块，管理instruction的读取和data的读写
- pc_reg：pc模块，记录要取的指令在内存中的地址，会自动+4或者是根据ex得到的跳转命令的目标地址进行修改
- IF, ID, EX, MEM, IF/ID, ID/EX, EX/MEM, MEM/WB, reg_file, 都是常规写法

### 3.一些实现

#### data forwarding 的实现

- 从ex和mem分别连线到id，判断是否是需要的data，如果是直接给出数据即可，不需要再通过reg_file，即实现了full data forwarding

#### 取指和访存的管理

- 由于memory只有一个端口，所以这是一个非常典型的Structure Hazard。实现了一个memory-controller模块对这两个访问统一管理。使用enable和busy标识进行memory-controller，mem和if的通讯。

#### 分支语句的实现

- 并没有实现BTB，实现的是静态预测不跳转。当发现预测错误，即指令跳转，就清空流水线寄存器，并且重新读区指令数据。

### 4.遇到的困难

- 当取指令和访存同时需要操作的时候，会出现很混乱的局面，最后通过优先保证取指令来协调
- 还有很多调试中碰到的小bug，比如判断stall的顺序不对，比如data forwarding的时候碰到load指令，需要发出id暂停，再比如一个寄存器的值在多个组合电路中被赋值，再比如BGE用>，还有zero delay问题，导致出现fatal error，使得simulation中止，无法继续。
- 上板时碰到的latch问题，如果在组合逻辑中，某些寄存器变量没有在所有的逻辑情况中出现，则会在综合时出现锁存器问题。需要把cache的修改转成时序电路，并且保证*的时候不同逻辑情下左值寄存器个数一致。
- 上板的最大问题是，板子坏了。

### 4.小建议

强烈建议明年更新板子QAQ。还有就是下发的hci好像会有一些warning，虽然不影响我最后的运行。



