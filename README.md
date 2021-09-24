# Pipeline_CPU_with_cache
A pipeline cpu which can execute the risc-v instruction\
write in verilog\
5 stage CPU - cache controller - Data Memory\
1. Modules Explanation :\
a. PC.v、IFID.v、IDEX.v、EXMEM.v、MEMWB.v\
In these modules, an input signal mem_stall_i from dcache is added to\
control the stall, that is, doing nothing when mem_stall_i is true.\
b.\
dcache_controller.v\
In the module, it connects to the CPU, Memory and dcache_sram.\
At first, it gets the address and data from cpu, dcache_sram and memory,\
and with the current states, it decides what is the next state and controls s\
mem_enable, mem_write, cache_write and write_back signals. The picture\
below shows the five state finite machine.\
At initial, it’s idle. When some cpu_req in and data not hit in dcache_sram,\
it changes to Miss state. Then it access memory and distinguish whether\
the data in dcache_sram is dirty or not. If it’s dirty, it WriteBack to memory\
and changes to ReadMiss state when writeback job is done. If it’s clean, it’s\
a ReadMiss, and bring the data to read from memory, then changes state\
to ReadMissOK when job is done. Finally, it turns back to the idle state.\
c.\
dcache_sram.v\
In this module, it reads or writes data in cache. At first, it checks the input\
tag is the same as tag in cache or not, then decides it’s hit in way0, way1 or\
miss with the help of valid bit in tag[addr_i][0/1][24]. And output the\
data and tag in way0 or way1. So we consider hit first, and if both way full,\
we consider least recent not used bit to handle the output. For write data,\
the distinguish process is the same read data, but it assigns the input dataand tag to the data and tag in the cache to store, and if it’s write hit, it set\
dirty bit. Finally, for lru, it updates when negative clock edge.\
d.\
Data_Memory.v\
This module has two state, IDLE and WAIT. If memory is enable, it change\
state from idle to wait and count the waiting cycle. In Wait state, if it\
already has ten cycles, it goes back to idle state or keeps in waiting state\
and count the cycle. When it’s positive edge, it read or write data in\
memory when acl_o is true.\
e. CPU.v\
In this module, it is almost the same as project1, but change the data\
memory to dcahce controller.\
f. testbench.v\
In the module, it connects cpu and offset data memory, and initialize them.\
Then it outputs the data in registers and memory every cycle. It also counts
the number of hit/miss in cache.\
