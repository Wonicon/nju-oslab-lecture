## 汇编代码与伪造的栈的配合

### JOS中的Trapframe：

``` assembly
_do_trap:
    ...
    pushl $trap_no
    jmp _alltraps


_alltraps:
    pushl %ds
    pushl %es
    pushal
    ...
```

    +---------------------------------------+
    | struct PushRegs tf_regs               |
    +---------------------------------------+
    | uint16_t tf_es | uint16_t tf_padding1 |
    +---------------------------------------+
    | uint16_t tf_ds | uint16_t tf_padding2 |
    +---------------------------------------+
    | uint32_t tf_trapno                    |
    +---------------------------------------+
    
``` c
struct Trapframe {
    struct PushRegs tf_regs;
    uint16_t tf_es;
    uint16_t tf_padding1;
    uint16_t tf_ds;
    uint16_t tf_padding2;
    uint32_t tf_trapno;
    ...
};
```

而在2012级的oslab中，你会发现Trapframe多了2个成员：gs和fs；
与之对应的是在do_irq.S中，多压了2个段寄存器。

``` c
struct Trapframe {
    ...
    /* below here defined by x86 hardware */
    uint32_t tf_err;
    uintptr_t tf_eip;
    uint16_t tf_cs;
    uint16_t tf_padding3;
    uint32_t tf_eflags;
    /* below here only when crossing rings, such as from user to kernel */
    uintptr_t tf_esp;
    uint16_t tf_ss;
    uint16_t tf_padding4;
};
```
你应该还发现了Trapframe中还有别的域，正如注释里面写的那样，
他们不是由我们手动压栈的，而是x86替你完成的。
另外，你应该还注意到了在iret之前的这个细节：
``` assembly
    popal
    popl %es
    popl %ds
    addl $8, %esp /*why ?*/
    iret
```
要回答这个why，你需要知道iret做了什么，如果你对nemu的这部分内容没有印象了，
可以翻看i386手册上面的iret指令的行为描述。


### JOS中在用户态的异常处理
