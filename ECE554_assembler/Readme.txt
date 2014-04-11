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
5. 所有生成的文件(*.lst和*.coe)都会在/src里