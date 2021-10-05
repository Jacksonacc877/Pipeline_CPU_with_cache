# Pipeline_CPU_with_cache
A pipeline cpu which can execute the risc-v instruction\
write in verilog\
5 stage CPU - cache controller - Data Memory

Modules Explanation :
----
## 1. CPU.v
This is the top level , and connects other submodule to Data_Memory.

### a. PC.v, IFID.v, IDEX.v, EXMEM.v, MEMWB.v
In these modules, an input signal mem_stall_i from dcache is added to control the stall, that is, doing nothing when mem_stall_i is true.

#### PC.v
>The module reads clock signals, reset bit, start bit and next cycle PC as input, then output the current cycle PC. When clock signal is in rising edge or reset signal in falling edge, the module will check whether it is triggered by reset signal. If it is, current PC(pc_o) will be set to 0, and if not, pc_o will be updated only when start bit equals to 1.

#### IFID.v
>The module is used to store the IF stage input, branch signal and stall signal from Hazard_Unit, then it will decide which PC and instruction will output in rising edge and start signal = 1.

#### IDEX.v
>The module stores lots of data from Control, Registers, Imm_Gen and instruction out from IFID register, and output the same data in the next rising edge and start signal = 1.

#### EXMEM.v
>The module stores signals and Rd address from IDEX stage, ALU result and mux_forwardB result, then output the same data in the next rising edge and start signal = 1.

#### MEMWB.v
>The module reads signal ALU result and Rd address from EXMEM stage and data from Data_Memory, then output the same data in the next rising edge and start signal = 1.


### b. dcache_controller.v, dcache_sram.v
#### dcache_controller.v
>In the module, it connects to the CPU, Memory and dcache_sram. At first, it gets the address and data from cpu, dcache_sram and memory,
and with the current states, it decides what is the next state and controls mem_enable, mem_write, cache_write and write_back signals. The picture
below shows the five state finite machine.
![image](https://user-images.githubusercontent.com/65355492/135979004-170203fa-ecb9-4a04-b6ac-adad01e925df.png)

>At initial, it’s idle. When some cpu_req in and data not hit in dcache_sram, it changes to Miss state. Then it access memory and distinguish whether the data in dcache_sram is dirty or not. If it’s dirty, it WriteBack to memory and changes to ReadMiss state when writeback job is done. If it’s clean, it’s a ReadMiss, and bring the data to read from memory, then changes state to ReadMissOK when job is done. Finally, it turns back to the idle state.

#### dcache_sram.v 
>In this module, it reads or writes data in cache. At first, it checks the input tag is the same as tag in cache or not, then decides it’s hit in way0, way1 or miss with the help of valid bit in tag[addr_i][0/1][24]. And output the data and tag in way0 or way1. So we consider hit first, and if both way full, we consider least recent not used bit to handle the output. For write data, the distinguish process is the same read data, but it assigns the input dataand tag to the data and tag in the cache to store, and if it’s write hit, it set dirty bit. Finally, for lru, it updates when negative clock edge.

### c. Instruction_Memory.v
>The module reads the address from PC, and find the instruction in memory as output

### d. ALU.v, Control.v, ALU_Control.v
#### Control.v
>The module fetches the opcode in instruction and NoOp from Hazard_Unit as input, and then output the ALUOp, ALUSrc, RegWrite, Mem2Reg, MemR, MemW, Branch signals.  If NoOp is 0, that is no hazard, then use opcode to decide which instruction it is and control the signal. There are 6 types: RTYPE, ITYPE, LW, SW BEQ and NOP.  Also, if NoOp is 1, it will output the NOP type signal. 

#### ALU_Control.v
>This module reads function7 and function3 in instruction with the input of ALUOp from Control, then it decides which computation it will execute, and output ALUCtrl to ALU.

#### ALU.v
>This module has two data input and one signal input(ALUCtrl from ALU_Control).  After calculation according to ALUCtrl, the module will output the result(data_o).  There are 7 insturctions in ALU, that is add, and, xor, sub, sll, srai, mul.

### e. Hazard_Unit.v, Forward_Unit.v
#### Hazard_Unit.v
>The module reads IFID stage two Rs and IDEX stage Rd and signal MemR as input, then it will decide whether the instruction cause a hazard to stall or not, finally output PCWrite, Stall and NoOp signal to stall one cycle.

#### Forward_Unit.v
>The module reads IDEX stage Rs, EXMEM stage Rd and RegW signal and MEMWB stage Rd and RegW signal to decide which hazard it met, and forward data to avoid such situation with two output signals to control two MUX4.

### f. Imm_Gen.v, Shifter.v, AND.v, Adder.v, MUX32.v, MUX4.v, beq.v
#### Imm_Gen.v
>This module reads the instruction, then it checks the opcode part in instruction to decide which type of immediate it should output, finally it fetch the immediate part, do sign extend to 32bits and output.

#### Shifter.v
>The module shift input data left logically 1 bit, then output result.

#### AND.v
>The module do AND computation in two input, then output the result.

#### Adder.v
>This module do ADD computation in two input, then output the result.

#### MUX32.v
>The module reads two 32bits data input and decide which should be output through select signal.

#### MUX4.v
>The module reads four 32bits data input and decide which should be output through select signal.

#### beq.v
>The module checks whether two input is the same, and output 1 when the same; Otherwise, 0.

## 2. Data_Memory.v
>This module has two state, IDLE and WAIT. If memory is enable, it change state from idle to wait and count the waiting cycle. In Wait state, if it already has ten cycles, it goes back to idle state or keeps in waiting state and count the cycle. When it’s positive edge, it read or write data in memory when acl_o is true.



## 3. testbench.v
>In the module, it connects cpu and offset data memory, and initialize them. Then it outputs the data in registers and memory every cycle. It also counts the number of hit/miss in cache.

Datapath
---
![image](https://user-images.githubusercontent.com/65355492/135976594-e7894744-966d-4a91-acca-3d8af87f9c0f.png)
