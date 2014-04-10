1. 所有instruction如果format正确的话(registers是从r0~r15中选的，以及immediate不overflow)，都能parse出来
2. 使用方法:
	a. cd to assembler/
	b. run java Assemble <input file> <outputfile>
		Example: java Assemble test.txt out1
3. parse结果会生成在.lst结尾的文件里

****** TODO *******
1. test corner cases, 保证所有invalid instructions都会报错(现在只有部分能正确报错)
2. test labels, 当使用label时，branch和jump能生成正确的relative PC
3. 没想好，貌似没了