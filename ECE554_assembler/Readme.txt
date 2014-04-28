1. 所有instruction如果format正确的话(registers是从r0~r15中选的，以及immediate不overflow)，都能parse出来
2. 使用方法:
	a. cd to /src
	b. run java Assemble <input file> <outputfile> -m <lst|coe>
		Example: java Assemble add1.asm add1 -m lst
        这个命令会生成add1_lst.lst
        Example: java Assemble add1.asm add1 -m coe
        这个命令会生成add1_coe.coe
    c. input file都在/src/Test文件里
3. 选择lst作为参数会生成详细的结果到.lst文件里，包括pc, binary和hex,主要用来验证
4. 选择coe作为参数会生成coe格式的结果到.coe文件里，这个就是我们要导入的文件了
5. 选择sim作为参数会生成sim格式的文件, assembler会先对整个程序跑一遍, 然后把每一条instruction的执行结果[registers的改变和memory的改变]以及当前和下一条instruction都打印出来, 直到程序结束. 最后打出跑过了多少条instructions
    举个栗子：
        next inst: add r3, r2, r1	// r3 = r2, r3 will always be a copy of r2
        current inst: ldi r2, 9	// r2 <-64, r2 contains C
        ***********************************
        *******   View registers   ********
        ***********************************
        R0: hex: 0 decimal: 0
        R1: hex: 0 decimal: 0
        R2: hex: 9 decimal: 9
        R3: hex: 0 decimal: 0
        R4: hex: 0 decimal: 0
        R5: hex: 0 decimal: 0
        R6: hex: 0 decimal: 0
        R7: hex: 0 decimal: 0
        R8: hex: 0 decimal: 0
        R9: hex: 0 decimal: 0
        R10: hex: 0 decimal: 0
        R11: hex: 0 decimal: 0
        R12: hex: 0 decimal: 0
        R13: hex: 0 decimal: 0
        R14: hex: 0 decimal: 0
        R15: hex: 0 decimal: 0
        这里能看到当前执行的instruction, 和下一条理应执行的instruction, 以及所有registers的改变
        
    branch, ldr, str也同理, 不过str会打出改变了那个memory而不是打出所有registers.
        举个栗子：
        next inst: ldr r2, r0, 2      // r2 = 5
        current inst: str r1, r0, 2      // mem[102] = 5
        ***********************************
        ********   Memory update   ********
        ***********************************
        memory[102] = 5
    大概就是这样
        
6. 所有生成的文件(*.lst和*.coe)都会在/src里