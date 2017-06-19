# 使用Go语言作为多语言项目的核心库
在一个涉及到多个编程语言的项目中，我们通常的做法是写一个C语言的库作为核心库，并被其他语言（例如Python或者Go语言）来调用。近些年由于Go语言在语法以及并发编程方面简单可靠的特性，正在被越来越多的项目所采用，下面就介绍一下如何使用Go语言作为核心库并被C和Python语言中调用。

## 使用Go语言编写一个核心库
### 什么是Cgo
  [Cgo](https://golang.org/cmd/cgo/)是Go语言提供的内部工具，它使得Go语言编写的程序可以直接调用C的代码，甚至编译成动态（静态）链接库以供其他语言调用。

### 实现一个可供外部调用的加法函数
  ```golang
  package main

  // #include <stdio.h>
  import "C"

  //export add
  func add(a, b C.int) C.int {
  	return a + b
  }
  func main() {}
  ```
  - `import "C"`, *C*是Cgo内置的package，当Go代码中包含这个关键字时表示代码中会使用C的类库。
  - `//#include <stdio.h>`, 在`import "C"`上面的注释会被当做Cgo添加到生成的头文件中

### 使用`go build`将Go代码编译为可供C代码调用的动态链接库
  ```bash
  go build -buildmode=c-shared -o libmath.so math.go
  ```
  执行成功后会在当前目录生成`math.h`和`math.so`两个文件
  ```bash
    |--math.go
    |--math.h
    `--math.so
  ```
### Cgo的内存管理
  Cgo允许我们在Go语言中声明一个C类型的变量，但由于Go的内存管理并不知道C的内存分配情况，所以通常需要我们手动调用`C.free`来释放C中的内存。
  ```golang
  // #include <stdio.h>
  // #include <stdlib.h>
  import "C"
  import "unsafe"

  func Print(s string) {
      cs := C.CString(s)
      C.fputs(cs, (*C.FILE)(C.stdout))
      C.free(unsafe.Pointer(cs))
  }
  ```
  - `C.CString`会将Go的字符串转换成为C语言的字符串，这个操作会使用C语言申请一块内存，我们要记得在函数结束时调用`C.free`来释放C语言申请的内存。
  - `unsafe.Pointer`相当于C语言中的`void*`, `C.CString`会返回一个指针来指向`char*`的首地址。
## 在C语言中调用`math.add`
  ```c
  #include "libmath.h"
  int main() {
    printf("Call Go math.add(1,2) is: %d\n ", add(1,2));
    return 0;
  }
  ```
  编译上述C语言代码
  ```bash
  g++ ./main.cpp -o main -L ../ -I ../ -lmath
  ```

## 在Python中调用`math.add`
  [cyptes](https://docs.python.org/2.7/library/ctypes.html)使Python可以调用动态链接库中的函数，并且提供了与C语言兼容的数据类型。
  ```python
  import ctypes
  math = ctypes.cdll.LoadLibrary("../libmath.so")
  print "Call Go math.add(1,2) is %d" % math.add(1,2)
  ```
# 参考链接
- https://golang.org/cmd/cgo/
- https://blog.golang.org/c-go-cgo
- https://docs.python.org/2.7/library/ctypes.html
