# rbtree-whitespace
This is a fun project implementing a red-black tree data structure in the whitespace programming language.

## prerequisites
To compile the code yourself, you need a whitespace assembler ([blacktime](https://github.com/threeifbywhiskey/blacktime)). To run, you need a whitespace interpreter ([satan](https://github.com/milankowww/satan])). Please note that the original satan distribution contains a bug in an instruction critical to the successful program execution. For this reason, you will need to use my version of satan, which contains the necessary fix.

Download:
```sh
git clone https://github.com/milankowww/satan.git
git clone https://github.com/threeifbywhiskey/blacktime.git
```
Build:
```
(just follow the original instructions)
```

## building and running the program
```sh
make
```
## examining the code

You don't need to download and build the compiler. If you only want to marvel at beauty of whitespace programming language, see the [assembled version](https://github.com/milankowww/rbtree-whitespace/blob/master/rbtree.white). And here is the [source code](https://github.com/milankowww/rbtree-whitespace/blob/master/rbtree.asm).

Enjoy!
