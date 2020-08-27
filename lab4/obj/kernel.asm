
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:
.text
.globl kern_entry
kern_entry:
    # reload temperate gdt (second time) to remap all physical memory
    # virtual_addr 0~4G=linear_addr&physical_addr -KERNBASE~4G-KERNBASE 
    lgdt REALLOC(__gdtdesc)
c0100000:	0f 01 15 18 80 12 00 	lgdtl  0x128018
    movl $KERNEL_DS, %eax
c0100007:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010000c:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010000e:	8e c0                	mov    %eax,%es
    movw %ax, %ss
c0100010:	8e d0                	mov    %eax,%ss

    ljmp $KERNEL_CS, $relocated
c0100012:	ea 19 00 10 c0 08 00 	ljmp   $0x8,$0xc0100019

c0100019 <relocated>:

relocated:

    # set ebp, esp
    movl $0x0, %ebp
c0100019:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010001e:	bc 00 80 12 c0       	mov    $0xc0128000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c0100023:	e8 02 00 00 00       	call   c010002a <kern_init>

c0100028 <spin>:

# should never get here
spin:
    jmp spin
c0100028:	eb fe                	jmp    c0100028 <spin>

c010002a <kern_init>:
int kern_init(void) __attribute__((noreturn));

static void lab1_switch_test(void);

int
kern_init(void) {
c010002a:	55                   	push   %ebp
c010002b:	89 e5                	mov    %esp,%ebp
c010002d:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c0100030:	ba 18 bc 12 c0       	mov    $0xc012bc18,%edx
c0100035:	b8 90 8a 12 c0       	mov    $0xc0128a90,%eax
c010003a:	29 c2                	sub    %eax,%edx
c010003c:	89 d0                	mov    %edx,%eax
c010003e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100042:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100049:	00 
c010004a:	c7 04 24 90 8a 12 c0 	movl   $0xc0128a90,(%esp)
c0100051:	e8 67 b0 00 00       	call   c010b0bd <memset>

    cons_init();                // init the console
c0100056:	e8 0b 2a 00 00       	call   c0102a66 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c010005b:	c7 45 f4 60 b2 10 c0 	movl   $0xc010b260,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100062:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100065:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100069:	c7 04 24 7c b2 10 c0 	movl   $0xc010b27c,(%esp)
c0100070:	e8 61 17 00 00       	call   c01017d6 <cprintf>

    print_kerninfo();
c0100075:	e8 90 1c 00 00       	call   c0101d0a <print_kerninfo>

    grade_backtrace();
c010007a:	e8 9d 00 00 00       	call   c010011c <grade_backtrace>

    pmm_init();                 // init physical memory management
c010007f:	e8 eb 67 00 00       	call   c010686f <pmm_init>

    pic_init();                 // init interrupt controller
c0100084:	e8 bb 33 00 00       	call   c0103444 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100089:	e8 33 35 00 00       	call   c01035c1 <idt_init>

    vmm_init();                 // init virtual memory management
c010008e:	e8 88 8e 00 00       	call   c0108f1b <vmm_init>
    proc_init();                // init process table
c0100093:	e8 1b a2 00 00       	call   c010a2b3 <proc_init>
    
    ide_init();                 // init ide devices
c0100098:	e8 fa 2a 00 00       	call   c0102b97 <ide_init>
    swap_init();                // init swap
c010009d:	e8 5e 7a 00 00       	call   c0107b00 <swap_init>

    clock_init();               // init clock interrupt
c01000a2:	e8 75 21 00 00       	call   c010221c <clock_init>
    intr_enable();              // enable irq interrupt
c01000a7:	e8 06 33 00 00       	call   c01033b2 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000ac:	e8 c1 a3 00 00       	call   c010a472 <cpu_idle>

c01000b1 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b1:	55                   	push   %ebp
c01000b2:	89 e5                	mov    %esp,%ebp
c01000b4:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000be:	00 
c01000bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000c6:	00 
c01000c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000ce:	e8 7b 20 00 00       	call   c010214e <mon_backtrace>
}
c01000d3:	c9                   	leave  
c01000d4:	c3                   	ret    

c01000d5 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d5:	55                   	push   %ebp
c01000d6:	89 e5                	mov    %esp,%ebp
c01000d8:	53                   	push   %ebx
c01000d9:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000dc:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000e2:	8d 55 08             	lea    0x8(%ebp),%edx
c01000e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01000e8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000ec:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000f0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000f4:	89 04 24             	mov    %eax,(%esp)
c01000f7:	e8 b5 ff ff ff       	call   c01000b1 <grade_backtrace2>
}
c01000fc:	83 c4 14             	add    $0x14,%esp
c01000ff:	5b                   	pop    %ebx
c0100100:	5d                   	pop    %ebp
c0100101:	c3                   	ret    

c0100102 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100102:	55                   	push   %ebp
c0100103:	89 e5                	mov    %esp,%ebp
c0100105:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100108:	8b 45 10             	mov    0x10(%ebp),%eax
c010010b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010010f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100112:	89 04 24             	mov    %eax,(%esp)
c0100115:	e8 bb ff ff ff       	call   c01000d5 <grade_backtrace1>
}
c010011a:	c9                   	leave  
c010011b:	c3                   	ret    

c010011c <grade_backtrace>:

void
grade_backtrace(void) {
c010011c:	55                   	push   %ebp
c010011d:	89 e5                	mov    %esp,%ebp
c010011f:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100122:	b8 2a 00 10 c0       	mov    $0xc010002a,%eax
c0100127:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010012e:	ff 
c010012f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100133:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010013a:	e8 c3 ff ff ff       	call   c0100102 <grade_backtrace0>
}
c010013f:	c9                   	leave  
c0100140:	c3                   	ret    

c0100141 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100141:	55                   	push   %ebp
c0100142:	89 e5                	mov    %esp,%ebp
c0100144:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100147:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010014a:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010014d:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100150:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100153:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100157:	0f b7 c0             	movzwl %ax,%eax
c010015a:	83 e0 03             	and    $0x3,%eax
c010015d:	89 c2                	mov    %eax,%edx
c010015f:	a1 a0 8a 12 c0       	mov    0xc0128aa0,%eax
c0100164:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100168:	89 44 24 04          	mov    %eax,0x4(%esp)
c010016c:	c7 04 24 81 b2 10 c0 	movl   $0xc010b281,(%esp)
c0100173:	e8 5e 16 00 00       	call   c01017d6 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100178:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010017c:	0f b7 d0             	movzwl %ax,%edx
c010017f:	a1 a0 8a 12 c0       	mov    0xc0128aa0,%eax
c0100184:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100188:	89 44 24 04          	mov    %eax,0x4(%esp)
c010018c:	c7 04 24 8f b2 10 c0 	movl   $0xc010b28f,(%esp)
c0100193:	e8 3e 16 00 00       	call   c01017d6 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100198:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c010019c:	0f b7 d0             	movzwl %ax,%edx
c010019f:	a1 a0 8a 12 c0       	mov    0xc0128aa0,%eax
c01001a4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ac:	c7 04 24 9d b2 10 c0 	movl   $0xc010b29d,(%esp)
c01001b3:	e8 1e 16 00 00       	call   c01017d6 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001b8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001bc:	0f b7 d0             	movzwl %ax,%edx
c01001bf:	a1 a0 8a 12 c0       	mov    0xc0128aa0,%eax
c01001c4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001cc:	c7 04 24 ab b2 10 c0 	movl   $0xc010b2ab,(%esp)
c01001d3:	e8 fe 15 00 00       	call   c01017d6 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001d8:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001dc:	0f b7 d0             	movzwl %ax,%edx
c01001df:	a1 a0 8a 12 c0       	mov    0xc0128aa0,%eax
c01001e4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001e8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ec:	c7 04 24 b9 b2 10 c0 	movl   $0xc010b2b9,(%esp)
c01001f3:	e8 de 15 00 00       	call   c01017d6 <cprintf>
    round ++;
c01001f8:	a1 a0 8a 12 c0       	mov    0xc0128aa0,%eax
c01001fd:	83 c0 01             	add    $0x1,%eax
c0100200:	a3 a0 8a 12 c0       	mov    %eax,0xc0128aa0
}
c0100205:	c9                   	leave  
c0100206:	c3                   	ret    

c0100207 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100207:	55                   	push   %ebp
c0100208:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c010020a:	5d                   	pop    %ebp
c010020b:	c3                   	ret    

c010020c <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c010020c:	55                   	push   %ebp
c010020d:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c010020f:	5d                   	pop    %ebp
c0100210:	c3                   	ret    

c0100211 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100211:	55                   	push   %ebp
c0100212:	89 e5                	mov    %esp,%ebp
c0100214:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100217:	e8 25 ff ff ff       	call   c0100141 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010021c:	c7 04 24 c8 b2 10 c0 	movl   $0xc010b2c8,(%esp)
c0100223:	e8 ae 15 00 00       	call   c01017d6 <cprintf>
    lab1_switch_to_user();
c0100228:	e8 da ff ff ff       	call   c0100207 <lab1_switch_to_user>
    lab1_print_cur_status();
c010022d:	e8 0f ff ff ff       	call   c0100141 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100232:	c7 04 24 e8 b2 10 c0 	movl   $0xc010b2e8,(%esp)
c0100239:	e8 98 15 00 00       	call   c01017d6 <cprintf>
    lab1_switch_to_kernel();
c010023e:	e8 c9 ff ff ff       	call   c010020c <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100243:	e8 f9 fe ff ff       	call   c0100141 <lab1_print_cur_status>
}
c0100248:	c9                   	leave  
c0100249:	c3                   	ret    

c010024a <rb_node_create>:
#include <rb_tree.h>
#include <assert.h>

/* rb_node_create - create a new rb_node */
static inline rb_node *
rb_node_create(void) {
c010024a:	55                   	push   %ebp
c010024b:	89 e5                	mov    %esp,%ebp
c010024d:	83 ec 18             	sub    $0x18,%esp
    return kmalloc(sizeof(rb_node));
c0100250:	c7 04 24 10 00 00 00 	movl   $0x10,(%esp)
c0100257:	e8 63 5b 00 00       	call   c0105dbf <kmalloc>
}
c010025c:	c9                   	leave  
c010025d:	c3                   	ret    

c010025e <rb_tree_empty>:

/* rb_tree_empty - tests if tree is empty */
static inline bool
rb_tree_empty(rb_tree *tree) {
c010025e:	55                   	push   %ebp
c010025f:	89 e5                	mov    %esp,%ebp
c0100261:	83 ec 10             	sub    $0x10,%esp
    rb_node *nil = tree->nil, *root = tree->root;
c0100264:	8b 45 08             	mov    0x8(%ebp),%eax
c0100267:	8b 40 04             	mov    0x4(%eax),%eax
c010026a:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010026d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100270:	8b 40 08             	mov    0x8(%eax),%eax
c0100273:	89 45 f8             	mov    %eax,-0x8(%ebp)
    return root->left == nil;
c0100276:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100279:	8b 40 08             	mov    0x8(%eax),%eax
c010027c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010027f:	0f 94 c0             	sete   %al
c0100282:	0f b6 c0             	movzbl %al,%eax
}
c0100285:	c9                   	leave  
c0100286:	c3                   	ret    

c0100287 <rb_tree_create>:
 * Note that, root->left should always point to the node that is the root
 * of the tree. And nil points to a 'NULL' node which should always be
 * black and may have arbitrary children and parent node.
 * */
rb_tree *
rb_tree_create(int (*compare)(rb_node *node1, rb_node *node2)) {
c0100287:	55                   	push   %ebp
c0100288:	89 e5                	mov    %esp,%ebp
c010028a:	83 ec 28             	sub    $0x28,%esp
    assert(compare != NULL);
c010028d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100291:	75 24                	jne    c01002b7 <rb_tree_create+0x30>
c0100293:	c7 44 24 0c 08 b3 10 	movl   $0xc010b308,0xc(%esp)
c010029a:	c0 
c010029b:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c01002a2:	c0 
c01002a3:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
c01002aa:	00 
c01002ab:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c01002b2:	e8 a9 1e 00 00       	call   c0102160 <__panic>

    rb_tree *tree;
    rb_node *nil, *root;

    if ((tree = kmalloc(sizeof(rb_tree))) == NULL) {
c01002b7:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c01002be:	e8 fc 5a 00 00       	call   c0105dbf <kmalloc>
c01002c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01002c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002ca:	75 05                	jne    c01002d1 <rb_tree_create+0x4a>
        goto bad_tree;
c01002cc:	e9 ad 00 00 00       	jmp    c010037e <rb_tree_create+0xf7>
    }

    tree->compare = compare;
c01002d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002d4:	8b 55 08             	mov    0x8(%ebp),%edx
c01002d7:	89 10                	mov    %edx,(%eax)

    if ((nil = rb_node_create()) == NULL) {
c01002d9:	e8 6c ff ff ff       	call   c010024a <rb_node_create>
c01002de:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01002e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01002e5:	75 05                	jne    c01002ec <rb_tree_create+0x65>
        goto bad_node_cleanup_tree;
c01002e7:	e9 87 00 00 00       	jmp    c0100373 <rb_tree_create+0xec>
    }

    nil->parent = nil->left = nil->right = nil;
c01002ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002f2:	89 50 0c             	mov    %edx,0xc(%eax)
c01002f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002f8:	8b 50 0c             	mov    0xc(%eax),%edx
c01002fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002fe:	89 50 08             	mov    %edx,0x8(%eax)
c0100301:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100304:	8b 50 08             	mov    0x8(%eax),%edx
c0100307:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010030a:	89 50 04             	mov    %edx,0x4(%eax)
    nil->red = 0;
c010030d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100310:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tree->nil = nil;
c0100316:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100319:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010031c:	89 50 04             	mov    %edx,0x4(%eax)

    if ((root = rb_node_create()) == NULL) {
c010031f:	e8 26 ff ff ff       	call   c010024a <rb_node_create>
c0100324:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100327:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010032b:	75 0e                	jne    c010033b <rb_tree_create+0xb4>
        goto bad_node_cleanup_nil;
c010032d:	90                   	nop
    root->red = 0;
    tree->root = root;
    return tree;

bad_node_cleanup_nil:
    kfree(nil);
c010032e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100331:	89 04 24             	mov    %eax,(%esp)
c0100334:	e8 a1 5a 00 00       	call   c0105dda <kfree>
c0100339:	eb 38                	jmp    c0100373 <rb_tree_create+0xec>

    if ((root = rb_node_create()) == NULL) {
        goto bad_node_cleanup_nil;
    }

    root->parent = root->left = root->right = nil;
c010033b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010033e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100341:	89 50 0c             	mov    %edx,0xc(%eax)
c0100344:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100347:	8b 50 0c             	mov    0xc(%eax),%edx
c010034a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010034d:	89 50 08             	mov    %edx,0x8(%eax)
c0100350:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100353:	8b 50 08             	mov    0x8(%eax),%edx
c0100356:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100359:	89 50 04             	mov    %edx,0x4(%eax)
    root->red = 0;
c010035c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010035f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tree->root = root;
c0100365:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100368:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010036b:	89 50 08             	mov    %edx,0x8(%eax)
    return tree;
c010036e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100371:	eb 10                	jmp    c0100383 <rb_tree_create+0xfc>

bad_node_cleanup_nil:
    kfree(nil);
bad_node_cleanup_tree:
    kfree(tree);
c0100373:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100376:	89 04 24             	mov    %eax,(%esp)
c0100379:	e8 5c 5a 00 00       	call   c0105dda <kfree>
bad_tree:
    return NULL;
c010037e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100383:	c9                   	leave  
c0100384:	c3                   	ret    

c0100385 <rb_left_rotate>:
    y->_left = x;                                               \
    x->parent = y;                                              \
    assert(!(nil->red));                                        \
}

FUNC_ROTATE(rb_left_rotate, left, right);
c0100385:	55                   	push   %ebp
c0100386:	89 e5                	mov    %esp,%ebp
c0100388:	83 ec 28             	sub    $0x28,%esp
c010038b:	8b 45 08             	mov    0x8(%ebp),%eax
c010038e:	8b 40 04             	mov    0x4(%eax),%eax
c0100391:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100394:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100397:	8b 40 0c             	mov    0xc(%eax),%eax
c010039a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010039d:	8b 45 08             	mov    0x8(%ebp),%eax
c01003a0:	8b 40 08             	mov    0x8(%eax),%eax
c01003a3:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01003a6:	74 10                	je     c01003b8 <rb_left_rotate+0x33>
c01003a8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003ab:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01003ae:	74 08                	je     c01003b8 <rb_left_rotate+0x33>
c01003b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003b3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01003b6:	75 24                	jne    c01003dc <rb_left_rotate+0x57>
c01003b8:	c7 44 24 0c 44 b3 10 	movl   $0xc010b344,0xc(%esp)
c01003bf:	c0 
c01003c0:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c01003c7:	c0 
c01003c8:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01003cf:	00 
c01003d0:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c01003d7:	e8 84 1d 00 00       	call   c0102160 <__panic>
c01003dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003df:	8b 50 08             	mov    0x8(%eax),%edx
c01003e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003e5:	89 50 0c             	mov    %edx,0xc(%eax)
c01003e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003eb:	8b 40 08             	mov    0x8(%eax),%eax
c01003ee:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01003f1:	74 0c                	je     c01003ff <rb_left_rotate+0x7a>
c01003f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003f6:	8b 40 08             	mov    0x8(%eax),%eax
c01003f9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01003fc:	89 50 04             	mov    %edx,0x4(%eax)
c01003ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100402:	8b 50 04             	mov    0x4(%eax),%edx
c0100405:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100408:	89 50 04             	mov    %edx,0x4(%eax)
c010040b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010040e:	8b 40 04             	mov    0x4(%eax),%eax
c0100411:	8b 40 08             	mov    0x8(%eax),%eax
c0100414:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0100417:	75 0e                	jne    c0100427 <rb_left_rotate+0xa2>
c0100419:	8b 45 0c             	mov    0xc(%ebp),%eax
c010041c:	8b 40 04             	mov    0x4(%eax),%eax
c010041f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100422:	89 50 08             	mov    %edx,0x8(%eax)
c0100425:	eb 0c                	jmp    c0100433 <rb_left_rotate+0xae>
c0100427:	8b 45 0c             	mov    0xc(%ebp),%eax
c010042a:	8b 40 04             	mov    0x4(%eax),%eax
c010042d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100430:	89 50 0c             	mov    %edx,0xc(%eax)
c0100433:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100436:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100439:	89 50 08             	mov    %edx,0x8(%eax)
c010043c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010043f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100442:	89 50 04             	mov    %edx,0x4(%eax)
c0100445:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100448:	8b 00                	mov    (%eax),%eax
c010044a:	85 c0                	test   %eax,%eax
c010044c:	74 24                	je     c0100472 <rb_left_rotate+0xed>
c010044e:	c7 44 24 0c 6c b3 10 	movl   $0xc010b36c,0xc(%esp)
c0100455:	c0 
c0100456:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c010045d:	c0 
c010045e:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0100465:	00 
c0100466:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c010046d:	e8 ee 1c 00 00       	call   c0102160 <__panic>
c0100472:	c9                   	leave  
c0100473:	c3                   	ret    

c0100474 <rb_right_rotate>:
FUNC_ROTATE(rb_right_rotate, right, left);
c0100474:	55                   	push   %ebp
c0100475:	89 e5                	mov    %esp,%ebp
c0100477:	83 ec 28             	sub    $0x28,%esp
c010047a:	8b 45 08             	mov    0x8(%ebp),%eax
c010047d:	8b 40 04             	mov    0x4(%eax),%eax
c0100480:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100483:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100486:	8b 40 08             	mov    0x8(%eax),%eax
c0100489:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010048c:	8b 45 08             	mov    0x8(%ebp),%eax
c010048f:	8b 40 08             	mov    0x8(%eax),%eax
c0100492:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0100495:	74 10                	je     c01004a7 <rb_right_rotate+0x33>
c0100497:	8b 45 0c             	mov    0xc(%ebp),%eax
c010049a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010049d:	74 08                	je     c01004a7 <rb_right_rotate+0x33>
c010049f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004a2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01004a5:	75 24                	jne    c01004cb <rb_right_rotate+0x57>
c01004a7:	c7 44 24 0c 44 b3 10 	movl   $0xc010b344,0xc(%esp)
c01004ae:	c0 
c01004af:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c01004b6:	c0 
c01004b7:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01004be:	00 
c01004bf:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c01004c6:	e8 95 1c 00 00       	call   c0102160 <__panic>
c01004cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004ce:	8b 50 0c             	mov    0xc(%eax),%edx
c01004d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d4:	89 50 08             	mov    %edx,0x8(%eax)
c01004d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004da:	8b 40 0c             	mov    0xc(%eax),%eax
c01004dd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01004e0:	74 0c                	je     c01004ee <rb_right_rotate+0x7a>
c01004e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e5:	8b 40 0c             	mov    0xc(%eax),%eax
c01004e8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01004eb:	89 50 04             	mov    %edx,0x4(%eax)
c01004ee:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004f1:	8b 50 04             	mov    0x4(%eax),%edx
c01004f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004f7:	89 50 04             	mov    %edx,0x4(%eax)
c01004fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004fd:	8b 40 04             	mov    0x4(%eax),%eax
c0100500:	8b 40 0c             	mov    0xc(%eax),%eax
c0100503:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0100506:	75 0e                	jne    c0100516 <rb_right_rotate+0xa2>
c0100508:	8b 45 0c             	mov    0xc(%ebp),%eax
c010050b:	8b 40 04             	mov    0x4(%eax),%eax
c010050e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100511:	89 50 0c             	mov    %edx,0xc(%eax)
c0100514:	eb 0c                	jmp    c0100522 <rb_right_rotate+0xae>
c0100516:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100519:	8b 40 04             	mov    0x4(%eax),%eax
c010051c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010051f:	89 50 08             	mov    %edx,0x8(%eax)
c0100522:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100525:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100528:	89 50 0c             	mov    %edx,0xc(%eax)
c010052b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010052e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100531:	89 50 04             	mov    %edx,0x4(%eax)
c0100534:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100537:	8b 00                	mov    (%eax),%eax
c0100539:	85 c0                	test   %eax,%eax
c010053b:	74 24                	je     c0100561 <rb_right_rotate+0xed>
c010053d:	c7 44 24 0c 6c b3 10 	movl   $0xc010b36c,0xc(%esp)
c0100544:	c0 
c0100545:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c010054c:	c0 
c010054d:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0100554:	00 
c0100555:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c010055c:	e8 ff 1b 00 00       	call   c0102160 <__panic>
c0100561:	c9                   	leave  
c0100562:	c3                   	ret    

c0100563 <rb_insert_binary>:
 * rb_insert_binary - insert @node to red-black @tree as if it were
 * a regular binary tree. This function is only intended to be called
 * by function rb_insert.
 * */
static inline void
rb_insert_binary(rb_tree *tree, rb_node *node) {
c0100563:	55                   	push   %ebp
c0100564:	89 e5                	mov    %esp,%ebp
c0100566:	83 ec 38             	sub    $0x38,%esp
    rb_node *x, *y, *z = node, *nil = tree->nil, *root = tree->root;
c0100569:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010056f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100572:	8b 40 04             	mov    0x4(%eax),%eax
c0100575:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0100578:	8b 45 08             	mov    0x8(%ebp),%eax
c010057b:	8b 40 08             	mov    0x8(%eax),%eax
c010057e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    z->left = z->right = nil;
c0100581:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100584:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100587:	89 50 0c             	mov    %edx,0xc(%eax)
c010058a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010058d:	8b 50 0c             	mov    0xc(%eax),%edx
c0100590:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100593:	89 50 08             	mov    %edx,0x8(%eax)
    y = root, x = y->left;
c0100596:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100599:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010059c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059f:	8b 40 08             	mov    0x8(%eax),%eax
c01005a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (x != nil) {
c01005a5:	eb 2f                	jmp    c01005d6 <rb_insert_binary+0x73>
        y = x;
c01005a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
        x = (COMPARE(tree, x, node) > 0) ? x->left : x->right;
c01005ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01005b0:	8b 00                	mov    (%eax),%eax
c01005b2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01005b5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01005b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01005bc:	89 14 24             	mov    %edx,(%esp)
c01005bf:	ff d0                	call   *%eax
c01005c1:	85 c0                	test   %eax,%eax
c01005c3:	7e 08                	jle    c01005cd <rb_insert_binary+0x6a>
c01005c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005c8:	8b 40 08             	mov    0x8(%eax),%eax
c01005cb:	eb 06                	jmp    c01005d3 <rb_insert_binary+0x70>
c01005cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005d0:	8b 40 0c             	mov    0xc(%eax),%eax
c01005d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
rb_insert_binary(rb_tree *tree, rb_node *node) {
    rb_node *x, *y, *z = node, *nil = tree->nil, *root = tree->root;

    z->left = z->right = nil;
    y = root, x = y->left;
    while (x != nil) {
c01005d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005d9:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c01005dc:	75 c9                	jne    c01005a7 <rb_insert_binary+0x44>
        y = x;
        x = (COMPARE(tree, x, node) > 0) ? x->left : x->right;
    }
    z->parent = y;
c01005de:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01005e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005e4:	89 50 04             	mov    %edx,0x4(%eax)
    if (y == root || COMPARE(tree, y, z) > 0) {
c01005e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005ea:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
c01005ed:	74 18                	je     c0100607 <rb_insert_binary+0xa4>
c01005ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01005f2:	8b 00                	mov    (%eax),%eax
c01005f4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01005f7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01005fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005fe:	89 14 24             	mov    %edx,(%esp)
c0100601:	ff d0                	call   *%eax
c0100603:	85 c0                	test   %eax,%eax
c0100605:	7e 0b                	jle    c0100612 <rb_insert_binary+0xaf>
        y->left = z;
c0100607:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010060a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010060d:	89 50 08             	mov    %edx,0x8(%eax)
c0100610:	eb 09                	jmp    c010061b <rb_insert_binary+0xb8>
    }
    else {
        y->right = z;
c0100612:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100615:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100618:	89 50 0c             	mov    %edx,0xc(%eax)
    }
}
c010061b:	c9                   	leave  
c010061c:	c3                   	ret    

c010061d <rb_insert>:

/* rb_insert - insert a node to red-black tree */
void
rb_insert(rb_tree *tree, rb_node *node) {
c010061d:	55                   	push   %ebp
c010061e:	89 e5                	mov    %esp,%ebp
c0100620:	83 ec 28             	sub    $0x28,%esp
    rb_insert_binary(tree, node);
c0100623:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100626:	89 44 24 04          	mov    %eax,0x4(%esp)
c010062a:	8b 45 08             	mov    0x8(%ebp),%eax
c010062d:	89 04 24             	mov    %eax,(%esp)
c0100630:	e8 2e ff ff ff       	call   c0100563 <rb_insert_binary>
    node->red = 1;
c0100635:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100638:	c7 00 01 00 00 00    	movl   $0x1,(%eax)

    rb_node *x = node, *y;
c010063e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100641:	89 45 f4             	mov    %eax,-0xc(%ebp)
            x->parent->parent->red = 1;                         \
            rb_##_right##_rotate(tree, x->parent->parent);      \
        }                                                       \
    } while (0)

    while (x->parent->red) {
c0100644:	e9 6e 01 00 00       	jmp    c01007b7 <rb_insert+0x19a>
        if (x->parent == x->parent->parent->left) {
c0100649:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010064c:	8b 50 04             	mov    0x4(%eax),%edx
c010064f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100652:	8b 40 04             	mov    0x4(%eax),%eax
c0100655:	8b 40 04             	mov    0x4(%eax),%eax
c0100658:	8b 40 08             	mov    0x8(%eax),%eax
c010065b:	39 c2                	cmp    %eax,%edx
c010065d:	0f 85 ae 00 00 00    	jne    c0100711 <rb_insert+0xf4>
            RB_INSERT_SUB(left, right);
c0100663:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100666:	8b 40 04             	mov    0x4(%eax),%eax
c0100669:	8b 40 04             	mov    0x4(%eax),%eax
c010066c:	8b 40 0c             	mov    0xc(%eax),%eax
c010066f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100672:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100675:	8b 00                	mov    (%eax),%eax
c0100677:	85 c0                	test   %eax,%eax
c0100679:	74 35                	je     c01006b0 <rb_insert+0x93>
c010067b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010067e:	8b 40 04             	mov    0x4(%eax),%eax
c0100681:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100687:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010068a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100690:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100693:	8b 40 04             	mov    0x4(%eax),%eax
c0100696:	8b 40 04             	mov    0x4(%eax),%eax
c0100699:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006a2:	8b 40 04             	mov    0x4(%eax),%eax
c01006a5:	8b 40 04             	mov    0x4(%eax),%eax
c01006a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01006ab:	e9 07 01 00 00       	jmp    c01007b7 <rb_insert+0x19a>
c01006b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006b3:	8b 40 04             	mov    0x4(%eax),%eax
c01006b6:	8b 40 0c             	mov    0xc(%eax),%eax
c01006b9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01006bc:	75 1b                	jne    c01006d9 <rb_insert+0xbc>
c01006be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006c1:	8b 40 04             	mov    0x4(%eax),%eax
c01006c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01006c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01006d1:	89 04 24             	mov    %eax,(%esp)
c01006d4:	e8 ac fc ff ff       	call   c0100385 <rb_left_rotate>
c01006d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006dc:	8b 40 04             	mov    0x4(%eax),%eax
c01006df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c01006e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006e8:	8b 40 04             	mov    0x4(%eax),%eax
c01006eb:	8b 40 04             	mov    0x4(%eax),%eax
c01006ee:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c01006f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006f7:	8b 40 04             	mov    0x4(%eax),%eax
c01006fa:	8b 40 04             	mov    0x4(%eax),%eax
c01006fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100701:	8b 45 08             	mov    0x8(%ebp),%eax
c0100704:	89 04 24             	mov    %eax,(%esp)
c0100707:	e8 68 fd ff ff       	call   c0100474 <rb_right_rotate>
c010070c:	e9 a6 00 00 00       	jmp    c01007b7 <rb_insert+0x19a>
        }
        else {
            RB_INSERT_SUB(right, left);
c0100711:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100714:	8b 40 04             	mov    0x4(%eax),%eax
c0100717:	8b 40 04             	mov    0x4(%eax),%eax
c010071a:	8b 40 08             	mov    0x8(%eax),%eax
c010071d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100720:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100723:	8b 00                	mov    (%eax),%eax
c0100725:	85 c0                	test   %eax,%eax
c0100727:	74 32                	je     c010075b <rb_insert+0x13e>
c0100729:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010072c:	8b 40 04             	mov    0x4(%eax),%eax
c010072f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100735:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100738:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c010073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100741:	8b 40 04             	mov    0x4(%eax),%eax
c0100744:	8b 40 04             	mov    0x4(%eax),%eax
c0100747:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c010074d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100750:	8b 40 04             	mov    0x4(%eax),%eax
c0100753:	8b 40 04             	mov    0x4(%eax),%eax
c0100756:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100759:	eb 5c                	jmp    c01007b7 <rb_insert+0x19a>
c010075b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075e:	8b 40 04             	mov    0x4(%eax),%eax
c0100761:	8b 40 08             	mov    0x8(%eax),%eax
c0100764:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100767:	75 1b                	jne    c0100784 <rb_insert+0x167>
c0100769:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010076c:	8b 40 04             	mov    0x4(%eax),%eax
c010076f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100772:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100775:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100779:	8b 45 08             	mov    0x8(%ebp),%eax
c010077c:	89 04 24             	mov    %eax,(%esp)
c010077f:	e8 f0 fc ff ff       	call   c0100474 <rb_right_rotate>
c0100784:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100787:	8b 40 04             	mov    0x4(%eax),%eax
c010078a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100790:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100793:	8b 40 04             	mov    0x4(%eax),%eax
c0100796:	8b 40 04             	mov    0x4(%eax),%eax
c0100799:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c010079f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007a2:	8b 40 04             	mov    0x4(%eax),%eax
c01007a5:	8b 40 04             	mov    0x4(%eax),%eax
c01007a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01007af:	89 04 24             	mov    %eax,(%esp)
c01007b2:	e8 ce fb ff ff       	call   c0100385 <rb_left_rotate>
            x->parent->parent->red = 1;                         \
            rb_##_right##_rotate(tree, x->parent->parent);      \
        }                                                       \
    } while (0)

    while (x->parent->red) {
c01007b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ba:	8b 40 04             	mov    0x4(%eax),%eax
c01007bd:	8b 00                	mov    (%eax),%eax
c01007bf:	85 c0                	test   %eax,%eax
c01007c1:	0f 85 82 fe ff ff    	jne    c0100649 <rb_insert+0x2c>
        }
        else {
            RB_INSERT_SUB(right, left);
        }
    }
    tree->root->left->red = 0;
c01007c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01007ca:	8b 40 08             	mov    0x8(%eax),%eax
c01007cd:	8b 40 08             	mov    0x8(%eax),%eax
c01007d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    assert(!(tree->nil->red) && !(tree->root->red));
c01007d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01007d9:	8b 40 04             	mov    0x4(%eax),%eax
c01007dc:	8b 00                	mov    (%eax),%eax
c01007de:	85 c0                	test   %eax,%eax
c01007e0:	75 0c                	jne    c01007ee <rb_insert+0x1d1>
c01007e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01007e5:	8b 40 08             	mov    0x8(%eax),%eax
c01007e8:	8b 00                	mov    (%eax),%eax
c01007ea:	85 c0                	test   %eax,%eax
c01007ec:	74 24                	je     c0100812 <rb_insert+0x1f5>
c01007ee:	c7 44 24 0c 78 b3 10 	movl   $0xc010b378,0xc(%esp)
c01007f5:	c0 
c01007f6:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c01007fd:	c0 
c01007fe:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c0100805:	00 
c0100806:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c010080d:	e8 4e 19 00 00       	call   c0102160 <__panic>

#undef RB_INSERT_SUB
}
c0100812:	c9                   	leave  
c0100813:	c3                   	ret    

c0100814 <rb_tree_successor>:
 * rb_tree_successor - returns the successor of @node, or nil
 * if no successor exists. Make sure that @node must belong to @tree,
 * and this function should only be called by rb_node_prev.
 * */
static inline rb_node *
rb_tree_successor(rb_tree *tree, rb_node *node) {
c0100814:	55                   	push   %ebp
c0100815:	89 e5                	mov    %esp,%ebp
c0100817:	83 ec 10             	sub    $0x10,%esp
    rb_node *x = node, *y, *nil = tree->nil;
c010081a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081d:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100820:	8b 45 08             	mov    0x8(%ebp),%eax
c0100823:	8b 40 04             	mov    0x4(%eax),%eax
c0100826:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if ((y = x->right) != nil) {
c0100829:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010082c:	8b 40 0c             	mov    0xc(%eax),%eax
c010082f:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100832:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100835:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100838:	74 1b                	je     c0100855 <rb_tree_successor+0x41>
        while (y->left != nil) {
c010083a:	eb 09                	jmp    c0100845 <rb_tree_successor+0x31>
            y = y->left;
c010083c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010083f:	8b 40 08             	mov    0x8(%eax),%eax
c0100842:	89 45 f8             	mov    %eax,-0x8(%ebp)
static inline rb_node *
rb_tree_successor(rb_tree *tree, rb_node *node) {
    rb_node *x = node, *y, *nil = tree->nil;

    if ((y = x->right) != nil) {
        while (y->left != nil) {
c0100845:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100848:	8b 40 08             	mov    0x8(%eax),%eax
c010084b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010084e:	75 ec                	jne    c010083c <rb_tree_successor+0x28>
            y = y->left;
        }
        return y;
c0100850:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100853:	eb 38                	jmp    c010088d <rb_tree_successor+0x79>
    }
    else {
        y = x->parent;
c0100855:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100858:	8b 40 04             	mov    0x4(%eax),%eax
c010085b:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (x == y->right) {
c010085e:	eb 0f                	jmp    c010086f <rb_tree_successor+0x5b>
            x = y, y = y->parent;
c0100860:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100863:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100866:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100869:	8b 40 04             	mov    0x4(%eax),%eax
c010086c:	89 45 f8             	mov    %eax,-0x8(%ebp)
        }
        return y;
    }
    else {
        y = x->parent;
        while (x == y->right) {
c010086f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100872:	8b 40 0c             	mov    0xc(%eax),%eax
c0100875:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100878:	74 e6                	je     c0100860 <rb_tree_successor+0x4c>
            x = y, y = y->parent;
        }
        if (y == tree->root) {
c010087a:	8b 45 08             	mov    0x8(%ebp),%eax
c010087d:	8b 40 08             	mov    0x8(%eax),%eax
c0100880:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0100883:	75 05                	jne    c010088a <rb_tree_successor+0x76>
            return nil;
c0100885:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100888:	eb 03                	jmp    c010088d <rb_tree_successor+0x79>
        }
        return y;
c010088a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    }
}
c010088d:	c9                   	leave  
c010088e:	c3                   	ret    

c010088f <rb_tree_predecessor>:
/* *
 * rb_tree_predecessor - returns the predecessor of @node, or nil
 * if no predecessor exists, likes rb_tree_successor.
 * */
static inline rb_node *
rb_tree_predecessor(rb_tree *tree, rb_node *node) {
c010088f:	55                   	push   %ebp
c0100890:	89 e5                	mov    %esp,%ebp
c0100892:	83 ec 10             	sub    $0x10,%esp
    rb_node *x = node, *y, *nil = tree->nil;
c0100895:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100898:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010089b:	8b 45 08             	mov    0x8(%ebp),%eax
c010089e:	8b 40 04             	mov    0x4(%eax),%eax
c01008a1:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if ((y = x->left) != nil) {
c01008a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01008a7:	8b 40 08             	mov    0x8(%eax),%eax
c01008aa:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01008ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008b0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01008b3:	74 1b                	je     c01008d0 <rb_tree_predecessor+0x41>
        while (y->right != nil) {
c01008b5:	eb 09                	jmp    c01008c0 <rb_tree_predecessor+0x31>
            y = y->right;
c01008b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008ba:	8b 40 0c             	mov    0xc(%eax),%eax
c01008bd:	89 45 f8             	mov    %eax,-0x8(%ebp)
static inline rb_node *
rb_tree_predecessor(rb_tree *tree, rb_node *node) {
    rb_node *x = node, *y, *nil = tree->nil;

    if ((y = x->left) != nil) {
        while (y->right != nil) {
c01008c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008c3:	8b 40 0c             	mov    0xc(%eax),%eax
c01008c6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01008c9:	75 ec                	jne    c01008b7 <rb_tree_predecessor+0x28>
            y = y->right;
        }
        return y;
c01008cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008ce:	eb 38                	jmp    c0100908 <rb_tree_predecessor+0x79>
    }
    else {
        y = x->parent;
c01008d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01008d3:	8b 40 04             	mov    0x4(%eax),%eax
c01008d6:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (x == y->left) {
c01008d9:	eb 1f                	jmp    c01008fa <rb_tree_predecessor+0x6b>
            if (y == tree->root) {
c01008db:	8b 45 08             	mov    0x8(%ebp),%eax
c01008de:	8b 40 08             	mov    0x8(%eax),%eax
c01008e1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01008e4:	75 05                	jne    c01008eb <rb_tree_predecessor+0x5c>
                return nil;
c01008e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008e9:	eb 1d                	jmp    c0100908 <rb_tree_predecessor+0x79>
            }
            x = y, y = y->parent;
c01008eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01008f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008f4:	8b 40 04             	mov    0x4(%eax),%eax
c01008f7:	89 45 f8             	mov    %eax,-0x8(%ebp)
        }
        return y;
    }
    else {
        y = x->parent;
        while (x == y->left) {
c01008fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008fd:	8b 40 08             	mov    0x8(%eax),%eax
c0100900:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100903:	74 d6                	je     c01008db <rb_tree_predecessor+0x4c>
            if (y == tree->root) {
                return nil;
            }
            x = y, y = y->parent;
        }
        return y;
c0100905:	8b 45 f8             	mov    -0x8(%ebp),%eax
    }
}
c0100908:	c9                   	leave  
c0100909:	c3                   	ret    

c010090a <rb_search>:
 * rb_search - returns a node with value 'equal' to @key (according to
 * function @compare). If there're multiple nodes with value 'equal' to @key,
 * the functions returns the one highest in the tree.
 * */
rb_node *
rb_search(rb_tree *tree, int (*compare)(rb_node *node, void *key), void *key) {
c010090a:	55                   	push   %ebp
c010090b:	89 e5                	mov    %esp,%ebp
c010090d:	83 ec 28             	sub    $0x28,%esp
    rb_node *nil = tree->nil, *node = tree->root->left;
c0100910:	8b 45 08             	mov    0x8(%ebp),%eax
c0100913:	8b 40 04             	mov    0x4(%eax),%eax
c0100916:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100919:	8b 45 08             	mov    0x8(%ebp),%eax
c010091c:	8b 40 08             	mov    0x8(%eax),%eax
c010091f:	8b 40 08             	mov    0x8(%eax),%eax
c0100922:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int r;
    while (node != nil && (r = compare(node, key)) != 0) {
c0100925:	eb 17                	jmp    c010093e <rb_search+0x34>
        node = (r > 0) ? node->left : node->right;
c0100927:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010092b:	7e 08                	jle    c0100935 <rb_search+0x2b>
c010092d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100930:	8b 40 08             	mov    0x8(%eax),%eax
c0100933:	eb 06                	jmp    c010093b <rb_search+0x31>
c0100935:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100938:	8b 40 0c             	mov    0xc(%eax),%eax
c010093b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * */
rb_node *
rb_search(rb_tree *tree, int (*compare)(rb_node *node, void *key), void *key) {
    rb_node *nil = tree->nil, *node = tree->root->left;
    int r;
    while (node != nil && (r = compare(node, key)) != 0) {
c010093e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100941:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100944:	74 1b                	je     c0100961 <rb_search+0x57>
c0100946:	8b 45 10             	mov    0x10(%ebp),%eax
c0100949:	89 44 24 04          	mov    %eax,0x4(%esp)
c010094d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100950:	89 04 24             	mov    %eax,(%esp)
c0100953:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100956:	ff d0                	call   *%eax
c0100958:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010095b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010095f:	75 c6                	jne    c0100927 <rb_search+0x1d>
        node = (r > 0) ? node->left : node->right;
    }
    return (node != nil) ? node : NULL;
c0100961:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100964:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100967:	74 05                	je     c010096e <rb_search+0x64>
c0100969:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010096c:	eb 05                	jmp    c0100973 <rb_search+0x69>
c010096e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100973:	c9                   	leave  
c0100974:	c3                   	ret    

c0100975 <rb_delete_fixup>:
/* *
 * rb_delete_fixup - performs rotations and changes colors to restore
 * red-black properties after a node is deleted.
 * */
static void
rb_delete_fixup(rb_tree *tree, rb_node *node) {
c0100975:	55                   	push   %ebp
c0100976:	89 e5                	mov    %esp,%ebp
c0100978:	83 ec 28             	sub    $0x28,%esp
    rb_node *x = node, *w, *root = tree->root->left;
c010097b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010097e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100981:	8b 45 08             	mov    0x8(%ebp),%eax
c0100984:	8b 40 08             	mov    0x8(%eax),%eax
c0100987:	8b 40 08             	mov    0x8(%eax),%eax
c010098a:	89 45 ec             	mov    %eax,-0x14(%ebp)
            rb_##_left##_rotate(tree, x->parent);               \
            x = root;                                           \
        }                                                       \
    } while (0)

    while (x != root && !x->red) {
c010098d:	e9 06 02 00 00       	jmp    c0100b98 <rb_delete_fixup+0x223>
        if (x == x->parent->left) {
c0100992:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100995:	8b 40 04             	mov    0x4(%eax),%eax
c0100998:	8b 40 08             	mov    0x8(%eax),%eax
c010099b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010099e:	0f 85 fe 00 00 00    	jne    c0100aa2 <rb_delete_fixup+0x12d>
            RB_DELETE_FIXUP_SUB(left, right);
c01009a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009a7:	8b 40 04             	mov    0x4(%eax),%eax
c01009aa:	8b 40 0c             	mov    0xc(%eax),%eax
c01009ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01009b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009b3:	8b 00                	mov    (%eax),%eax
c01009b5:	85 c0                	test   %eax,%eax
c01009b7:	74 36                	je     c01009ef <rb_delete_fixup+0x7a>
c01009b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009bc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c01009c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009c5:	8b 40 04             	mov    0x4(%eax),%eax
c01009c8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c01009ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009d1:	8b 40 04             	mov    0x4(%eax),%eax
c01009d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01009db:	89 04 24             	mov    %eax,(%esp)
c01009de:	e8 a2 f9 ff ff       	call   c0100385 <rb_left_rotate>
c01009e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009e6:	8b 40 04             	mov    0x4(%eax),%eax
c01009e9:	8b 40 0c             	mov    0xc(%eax),%eax
c01009ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01009ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009f2:	8b 40 08             	mov    0x8(%eax),%eax
c01009f5:	8b 00                	mov    (%eax),%eax
c01009f7:	85 c0                	test   %eax,%eax
c01009f9:	75 23                	jne    c0100a1e <rb_delete_fixup+0xa9>
c01009fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009fe:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a01:	8b 00                	mov    (%eax),%eax
c0100a03:	85 c0                	test   %eax,%eax
c0100a05:	75 17                	jne    c0100a1e <rb_delete_fixup+0xa9>
c0100a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a0a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a13:	8b 40 04             	mov    0x4(%eax),%eax
c0100a16:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100a19:	e9 7a 01 00 00       	jmp    c0100b98 <rb_delete_fixup+0x223>
c0100a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a21:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a24:	8b 00                	mov    (%eax),%eax
c0100a26:	85 c0                	test   %eax,%eax
c0100a28:	75 33                	jne    c0100a5d <rb_delete_fixup+0xe8>
c0100a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a2d:	8b 40 08             	mov    0x8(%eax),%eax
c0100a30:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a39:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a42:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a46:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a49:	89 04 24             	mov    %eax,(%esp)
c0100a4c:	e8 23 fa ff ff       	call   c0100474 <rb_right_rotate>
c0100a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a54:	8b 40 04             	mov    0x4(%eax),%eax
c0100a57:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a60:	8b 40 04             	mov    0x4(%eax),%eax
c0100a63:	8b 10                	mov    (%eax),%edx
c0100a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a68:	89 10                	mov    %edx,(%eax)
c0100a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a6d:	8b 40 04             	mov    0x4(%eax),%eax
c0100a70:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a79:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a7c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a85:	8b 40 04             	mov    0x4(%eax),%eax
c0100a88:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a8f:	89 04 24             	mov    %eax,(%esp)
c0100a92:	e8 ee f8 ff ff       	call   c0100385 <rb_left_rotate>
c0100a97:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100a9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100a9d:	e9 f6 00 00 00       	jmp    c0100b98 <rb_delete_fixup+0x223>
        }
        else {
            RB_DELETE_FIXUP_SUB(right, left);
c0100aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aa5:	8b 40 04             	mov    0x4(%eax),%eax
c0100aa8:	8b 40 08             	mov    0x8(%eax),%eax
c0100aab:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ab1:	8b 00                	mov    (%eax),%eax
c0100ab3:	85 c0                	test   %eax,%eax
c0100ab5:	74 36                	je     c0100aed <rb_delete_fixup+0x178>
c0100ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100aba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ac3:	8b 40 04             	mov    0x4(%eax),%eax
c0100ac6:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100acf:	8b 40 04             	mov    0x4(%eax),%eax
c0100ad2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ad6:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ad9:	89 04 24             	mov    %eax,(%esp)
c0100adc:	e8 93 f9 ff ff       	call   c0100474 <rb_right_rotate>
c0100ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ae4:	8b 40 04             	mov    0x4(%eax),%eax
c0100ae7:	8b 40 08             	mov    0x8(%eax),%eax
c0100aea:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100af0:	8b 40 0c             	mov    0xc(%eax),%eax
c0100af3:	8b 00                	mov    (%eax),%eax
c0100af5:	85 c0                	test   %eax,%eax
c0100af7:	75 20                	jne    c0100b19 <rb_delete_fixup+0x1a4>
c0100af9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100afc:	8b 40 08             	mov    0x8(%eax),%eax
c0100aff:	8b 00                	mov    (%eax),%eax
c0100b01:	85 c0                	test   %eax,%eax
c0100b03:	75 14                	jne    c0100b19 <rb_delete_fixup+0x1a4>
c0100b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b08:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b11:	8b 40 04             	mov    0x4(%eax),%eax
c0100b14:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100b17:	eb 7f                	jmp    c0100b98 <rb_delete_fixup+0x223>
c0100b19:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b1c:	8b 40 08             	mov    0x8(%eax),%eax
c0100b1f:	8b 00                	mov    (%eax),%eax
c0100b21:	85 c0                	test   %eax,%eax
c0100b23:	75 33                	jne    c0100b58 <rb_delete_fixup+0x1e3>
c0100b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b28:	8b 40 0c             	mov    0xc(%eax),%eax
c0100b2b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b34:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100b3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b44:	89 04 24             	mov    %eax,(%esp)
c0100b47:	e8 39 f8 ff ff       	call   c0100385 <rb_left_rotate>
c0100b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b4f:	8b 40 04             	mov    0x4(%eax),%eax
c0100b52:	8b 40 08             	mov    0x8(%eax),%eax
c0100b55:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b5b:	8b 40 04             	mov    0x4(%eax),%eax
c0100b5e:	8b 10                	mov    (%eax),%edx
c0100b60:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b63:	89 10                	mov    %edx,(%eax)
c0100b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b68:	8b 40 04             	mov    0x4(%eax),%eax
c0100b6b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b74:	8b 40 08             	mov    0x8(%eax),%eax
c0100b77:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b80:	8b 40 04             	mov    0x4(%eax),%eax
c0100b83:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b87:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b8a:	89 04 24             	mov    %eax,(%esp)
c0100b8d:	e8 e2 f8 ff ff       	call   c0100474 <rb_right_rotate>
c0100b92:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100b95:	89 45 f4             	mov    %eax,-0xc(%ebp)
            rb_##_left##_rotate(tree, x->parent);               \
            x = root;                                           \
        }                                                       \
    } while (0)

    while (x != root && !x->red) {
c0100b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b9b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100b9e:	74 0d                	je     c0100bad <rb_delete_fixup+0x238>
c0100ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ba3:	8b 00                	mov    (%eax),%eax
c0100ba5:	85 c0                	test   %eax,%eax
c0100ba7:	0f 84 e5 fd ff ff    	je     c0100992 <rb_delete_fixup+0x1d>
        }
        else {
            RB_DELETE_FIXUP_SUB(right, left);
        }
    }
    x->red = 0;
c0100bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bb0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

#undef RB_DELETE_FIXUP_SUB
}
c0100bb6:	c9                   	leave  
c0100bb7:	c3                   	ret    

c0100bb8 <rb_delete>:
/* *
 * rb_delete - deletes @node from @tree, and calls rb_delete_fixup to
 * restore red-black properties.
 * */
void
rb_delete(rb_tree *tree, rb_node *node) {
c0100bb8:	55                   	push   %ebp
c0100bb9:	89 e5                	mov    %esp,%ebp
c0100bbb:	83 ec 38             	sub    $0x38,%esp
    rb_node *x, *y, *z = node;
c0100bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    rb_node *nil = tree->nil, *root = tree->root;
c0100bc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bc7:	8b 40 04             	mov    0x4(%eax),%eax
c0100bca:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100bcd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd0:	8b 40 08             	mov    0x8(%eax),%eax
c0100bd3:	89 45 ec             	mov    %eax,-0x14(%ebp)

    y = (z->left == nil || z->right == nil) ? z : rb_tree_successor(tree, z);
c0100bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bd9:	8b 40 08             	mov    0x8(%eax),%eax
c0100bdc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100bdf:	74 1f                	je     c0100c00 <rb_delete+0x48>
c0100be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100be4:	8b 40 0c             	mov    0xc(%eax),%eax
c0100be7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100bea:	74 14                	je     c0100c00 <rb_delete+0x48>
c0100bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bef:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bf3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bf6:	89 04 24             	mov    %eax,(%esp)
c0100bf9:	e8 16 fc ff ff       	call   c0100814 <rb_tree_successor>
c0100bfe:	eb 03                	jmp    c0100c03 <rb_delete+0x4b>
c0100c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c03:	89 45 e8             	mov    %eax,-0x18(%ebp)
    x = (y->left != nil) ? y->left : y->right;
c0100c06:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c09:	8b 40 08             	mov    0x8(%eax),%eax
c0100c0c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100c0f:	74 08                	je     c0100c19 <rb_delete+0x61>
c0100c11:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c14:	8b 40 08             	mov    0x8(%eax),%eax
c0100c17:	eb 06                	jmp    c0100c1f <rb_delete+0x67>
c0100c19:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c1c:	8b 40 0c             	mov    0xc(%eax),%eax
c0100c1f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    assert(y != root && y != nil);
c0100c22:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c25:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100c28:	74 08                	je     c0100c32 <rb_delete+0x7a>
c0100c2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c2d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100c30:	75 24                	jne    c0100c56 <rb_delete+0x9e>
c0100c32:	c7 44 24 0c a0 b3 10 	movl   $0xc010b3a0,0xc(%esp)
c0100c39:	c0 
c0100c3a:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c0100c41:	c0 
c0100c42:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0100c49:	00 
c0100c4a:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c0100c51:	e8 0a 15 00 00       	call   c0102160 <__panic>

    x->parent = y->parent;
c0100c56:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c59:	8b 50 04             	mov    0x4(%eax),%edx
c0100c5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100c5f:	89 50 04             	mov    %edx,0x4(%eax)
    if (y == y->parent->left) {
c0100c62:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c65:	8b 40 04             	mov    0x4(%eax),%eax
c0100c68:	8b 40 08             	mov    0x8(%eax),%eax
c0100c6b:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0100c6e:	75 0e                	jne    c0100c7e <rb_delete+0xc6>
        y->parent->left = x;
c0100c70:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c73:	8b 40 04             	mov    0x4(%eax),%eax
c0100c76:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100c79:	89 50 08             	mov    %edx,0x8(%eax)
c0100c7c:	eb 0c                	jmp    c0100c8a <rb_delete+0xd2>
    }
    else {
        y->parent->right = x;
c0100c7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c81:	8b 40 04             	mov    0x4(%eax),%eax
c0100c84:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100c87:	89 50 0c             	mov    %edx,0xc(%eax)
    }

    bool need_fixup = !(y->red);
c0100c8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c8d:	8b 00                	mov    (%eax),%eax
c0100c8f:	85 c0                	test   %eax,%eax
c0100c91:	0f 94 c0             	sete   %al
c0100c94:	0f b6 c0             	movzbl %al,%eax
c0100c97:	89 45 e0             	mov    %eax,-0x20(%ebp)

    if (y != z) {
c0100c9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c9d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100ca0:	74 5c                	je     c0100cfe <rb_delete+0x146>
        if (z == z->parent->left) {
c0100ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ca5:	8b 40 04             	mov    0x4(%eax),%eax
c0100ca8:	8b 40 08             	mov    0x8(%eax),%eax
c0100cab:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100cae:	75 0e                	jne    c0100cbe <rb_delete+0x106>
            z->parent->left = y;
c0100cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cb3:	8b 40 04             	mov    0x4(%eax),%eax
c0100cb6:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100cb9:	89 50 08             	mov    %edx,0x8(%eax)
c0100cbc:	eb 0c                	jmp    c0100cca <rb_delete+0x112>
        }
        else {
            z->parent->right = y;
c0100cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cc1:	8b 40 04             	mov    0x4(%eax),%eax
c0100cc4:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100cc7:	89 50 0c             	mov    %edx,0xc(%eax)
        }
        z->left->parent = z->right->parent = y;
c0100cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ccd:	8b 50 08             	mov    0x8(%eax),%edx
c0100cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cd3:	8b 40 0c             	mov    0xc(%eax),%eax
c0100cd6:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100cd9:	89 48 04             	mov    %ecx,0x4(%eax)
c0100cdc:	8b 40 04             	mov    0x4(%eax),%eax
c0100cdf:	89 42 04             	mov    %eax,0x4(%edx)
        *y = *z;
c0100ce2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100ce5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100ce8:	8b 0a                	mov    (%edx),%ecx
c0100cea:	89 08                	mov    %ecx,(%eax)
c0100cec:	8b 4a 04             	mov    0x4(%edx),%ecx
c0100cef:	89 48 04             	mov    %ecx,0x4(%eax)
c0100cf2:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100cf5:	89 48 08             	mov    %ecx,0x8(%eax)
c0100cf8:	8b 52 0c             	mov    0xc(%edx),%edx
c0100cfb:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    if (need_fixup) {
c0100cfe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0100d02:	74 12                	je     c0100d16 <rb_delete+0x15e>
        rb_delete_fixup(tree, x);
c0100d04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100d07:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d0e:	89 04 24             	mov    %eax,(%esp)
c0100d11:	e8 5f fc ff ff       	call   c0100975 <rb_delete_fixup>
    }
}
c0100d16:	c9                   	leave  
c0100d17:	c3                   	ret    

c0100d18 <rb_tree_destroy>:

/* rb_tree_destroy - destroy a tree and free memory */
void
rb_tree_destroy(rb_tree *tree) {
c0100d18:	55                   	push   %ebp
c0100d19:	89 e5                	mov    %esp,%ebp
c0100d1b:	83 ec 18             	sub    $0x18,%esp
    kfree(tree->root);
c0100d1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d21:	8b 40 08             	mov    0x8(%eax),%eax
c0100d24:	89 04 24             	mov    %eax,(%esp)
c0100d27:	e8 ae 50 00 00       	call   c0105dda <kfree>
    kfree(tree->nil);
c0100d2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d2f:	8b 40 04             	mov    0x4(%eax),%eax
c0100d32:	89 04 24             	mov    %eax,(%esp)
c0100d35:	e8 a0 50 00 00       	call   c0105dda <kfree>
    kfree(tree);
c0100d3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d3d:	89 04 24             	mov    %eax,(%esp)
c0100d40:	e8 95 50 00 00       	call   c0105dda <kfree>
}
c0100d45:	c9                   	leave  
c0100d46:	c3                   	ret    

c0100d47 <rb_node_prev>:
/* *
 * rb_node_prev - returns the predecessor node of @node in @tree,
 * or 'NULL' if no predecessor exists.
 * */
rb_node *
rb_node_prev(rb_tree *tree, rb_node *node) {
c0100d47:	55                   	push   %ebp
c0100d48:	89 e5                	mov    %esp,%ebp
c0100d4a:	83 ec 18             	sub    $0x18,%esp
    rb_node *prev = rb_tree_predecessor(tree, node);
c0100d4d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d50:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d54:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d57:	89 04 24             	mov    %eax,(%esp)
c0100d5a:	e8 30 fb ff ff       	call   c010088f <rb_tree_predecessor>
c0100d5f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (prev != tree->nil) ? prev : NULL;
c0100d62:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d65:	8b 40 04             	mov    0x4(%eax),%eax
c0100d68:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100d6b:	74 05                	je     c0100d72 <rb_node_prev+0x2b>
c0100d6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100d70:	eb 05                	jmp    c0100d77 <rb_node_prev+0x30>
c0100d72:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d77:	c9                   	leave  
c0100d78:	c3                   	ret    

c0100d79 <rb_node_next>:
/* *
 * rb_node_next - returns the successor node of @node in @tree,
 * or 'NULL' if no successor exists.
 * */
rb_node *
rb_node_next(rb_tree *tree, rb_node *node) {
c0100d79:	55                   	push   %ebp
c0100d7a:	89 e5                	mov    %esp,%ebp
c0100d7c:	83 ec 18             	sub    $0x18,%esp
    rb_node *next = rb_tree_successor(tree, node);
c0100d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d82:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d86:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d89:	89 04 24             	mov    %eax,(%esp)
c0100d8c:	e8 83 fa ff ff       	call   c0100814 <rb_tree_successor>
c0100d91:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (next != tree->nil) ? next : NULL;
c0100d94:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d97:	8b 40 04             	mov    0x4(%eax),%eax
c0100d9a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100d9d:	74 05                	je     c0100da4 <rb_node_next+0x2b>
c0100d9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100da2:	eb 05                	jmp    c0100da9 <rb_node_next+0x30>
c0100da4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100da9:	c9                   	leave  
c0100daa:	c3                   	ret    

c0100dab <rb_node_root>:

/* rb_node_root - returns the root node of a @tree, or 'NULL' if tree is empty */
rb_node *
rb_node_root(rb_tree *tree) {
c0100dab:	55                   	push   %ebp
c0100dac:	89 e5                	mov    %esp,%ebp
c0100dae:	83 ec 10             	sub    $0x10,%esp
    rb_node *node = tree->root->left;
c0100db1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100db4:	8b 40 08             	mov    0x8(%eax),%eax
c0100db7:	8b 40 08             	mov    0x8(%eax),%eax
c0100dba:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (node != tree->nil) ? node : NULL;
c0100dbd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100dc0:	8b 40 04             	mov    0x4(%eax),%eax
c0100dc3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100dc6:	74 05                	je     c0100dcd <rb_node_root+0x22>
c0100dc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dcb:	eb 05                	jmp    c0100dd2 <rb_node_root+0x27>
c0100dcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dd2:	c9                   	leave  
c0100dd3:	c3                   	ret    

c0100dd4 <rb_node_left>:

/* rb_node_left - gets the left child of @node, or 'NULL' if no such node */
rb_node *
rb_node_left(rb_tree *tree, rb_node *node) {
c0100dd4:	55                   	push   %ebp
c0100dd5:	89 e5                	mov    %esp,%ebp
c0100dd7:	83 ec 10             	sub    $0x10,%esp
    rb_node *left = node->left;
c0100dda:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ddd:	8b 40 08             	mov    0x8(%eax),%eax
c0100de0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (left != tree->nil) ? left : NULL;
c0100de3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100de6:	8b 40 04             	mov    0x4(%eax),%eax
c0100de9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100dec:	74 05                	je     c0100df3 <rb_node_left+0x1f>
c0100dee:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100df1:	eb 05                	jmp    c0100df8 <rb_node_left+0x24>
c0100df3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100df8:	c9                   	leave  
c0100df9:	c3                   	ret    

c0100dfa <rb_node_right>:

/* rb_node_right - gets the right child of @node, or 'NULL' if no such node */
rb_node *
rb_node_right(rb_tree *tree, rb_node *node) {
c0100dfa:	55                   	push   %ebp
c0100dfb:	89 e5                	mov    %esp,%ebp
c0100dfd:	83 ec 10             	sub    $0x10,%esp
    rb_node *right = node->right;
c0100e00:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e03:	8b 40 0c             	mov    0xc(%eax),%eax
c0100e06:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (right != tree->nil) ? right : NULL;
c0100e09:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e0c:	8b 40 04             	mov    0x4(%eax),%eax
c0100e0f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100e12:	74 05                	je     c0100e19 <rb_node_right+0x1f>
c0100e14:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e17:	eb 05                	jmp    c0100e1e <rb_node_right+0x24>
c0100e19:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e1e:	c9                   	leave  
c0100e1f:	c3                   	ret    

c0100e20 <check_tree>:

int
check_tree(rb_tree *tree, rb_node *node) {
c0100e20:	55                   	push   %ebp
c0100e21:	89 e5                	mov    %esp,%ebp
c0100e23:	83 ec 28             	sub    $0x28,%esp
    rb_node *nil = tree->nil;
c0100e26:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e29:	8b 40 04             	mov    0x4(%eax),%eax
c0100e2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (node == nil) {
c0100e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e32:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100e35:	75 37                	jne    c0100e6e <check_tree+0x4e>
        assert(!node->red);
c0100e37:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e3a:	8b 00                	mov    (%eax),%eax
c0100e3c:	85 c0                	test   %eax,%eax
c0100e3e:	74 24                	je     c0100e64 <check_tree+0x44>
c0100e40:	c7 44 24 0c b6 b3 10 	movl   $0xc010b3b6,0xc(%esp)
c0100e47:	c0 
c0100e48:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c0100e4f:	c0 
c0100e50:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
c0100e57:	00 
c0100e58:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c0100e5f:	e8 fc 12 00 00       	call   c0102160 <__panic>
        return 1;
c0100e64:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e69:	e9 af 01 00 00       	jmp    c010101d <check_tree+0x1fd>
    }
    if (node->left != nil) {
c0100e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e71:	8b 40 08             	mov    0x8(%eax),%eax
c0100e74:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100e77:	74 71                	je     c0100eea <check_tree+0xca>
        assert(COMPARE(tree, node, node->left) >= 0);
c0100e79:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e7c:	8b 00                	mov    (%eax),%eax
c0100e7e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100e81:	8b 52 08             	mov    0x8(%edx),%edx
c0100e84:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100e88:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100e8b:	89 14 24             	mov    %edx,(%esp)
c0100e8e:	ff d0                	call   *%eax
c0100e90:	85 c0                	test   %eax,%eax
c0100e92:	79 24                	jns    c0100eb8 <check_tree+0x98>
c0100e94:	c7 44 24 0c c4 b3 10 	movl   $0xc010b3c4,0xc(%esp)
c0100e9b:	c0 
c0100e9c:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c0100ea3:	c0 
c0100ea4:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
c0100eab:	00 
c0100eac:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c0100eb3:	e8 a8 12 00 00       	call   c0102160 <__panic>
        assert(node->left->parent == node);
c0100eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ebb:	8b 40 08             	mov    0x8(%eax),%eax
c0100ebe:	8b 40 04             	mov    0x4(%eax),%eax
c0100ec1:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0100ec4:	74 24                	je     c0100eea <check_tree+0xca>
c0100ec6:	c7 44 24 0c e9 b3 10 	movl   $0xc010b3e9,0xc(%esp)
c0100ecd:	c0 
c0100ece:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c0100ed5:	c0 
c0100ed6:	c7 44 24 04 84 01 00 	movl   $0x184,0x4(%esp)
c0100edd:	00 
c0100ede:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c0100ee5:	e8 76 12 00 00       	call   c0102160 <__panic>
    }
    if (node->right != nil) {
c0100eea:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100eed:	8b 40 0c             	mov    0xc(%eax),%eax
c0100ef0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100ef3:	74 71                	je     c0100f66 <check_tree+0x146>
        assert(COMPARE(tree, node, node->right) <= 0);
c0100ef5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ef8:	8b 00                	mov    (%eax),%eax
c0100efa:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100efd:	8b 52 0c             	mov    0xc(%edx),%edx
c0100f00:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100f04:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100f07:	89 14 24             	mov    %edx,(%esp)
c0100f0a:	ff d0                	call   *%eax
c0100f0c:	85 c0                	test   %eax,%eax
c0100f0e:	7e 24                	jle    c0100f34 <check_tree+0x114>
c0100f10:	c7 44 24 0c 04 b4 10 	movl   $0xc010b404,0xc(%esp)
c0100f17:	c0 
c0100f18:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c0100f1f:	c0 
c0100f20:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
c0100f27:	00 
c0100f28:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c0100f2f:	e8 2c 12 00 00       	call   c0102160 <__panic>
        assert(node->right->parent == node);
c0100f34:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f37:	8b 40 0c             	mov    0xc(%eax),%eax
c0100f3a:	8b 40 04             	mov    0x4(%eax),%eax
c0100f3d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0100f40:	74 24                	je     c0100f66 <check_tree+0x146>
c0100f42:	c7 44 24 0c 2a b4 10 	movl   $0xc010b42a,0xc(%esp)
c0100f49:	c0 
c0100f4a:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c0100f51:	c0 
c0100f52:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
c0100f59:	00 
c0100f5a:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c0100f61:	e8 fa 11 00 00       	call   c0102160 <__panic>
    }
    if (node->red) {
c0100f66:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f69:	8b 00                	mov    (%eax),%eax
c0100f6b:	85 c0                	test   %eax,%eax
c0100f6d:	74 3c                	je     c0100fab <check_tree+0x18b>
        assert(!node->left->red && !node->right->red);
c0100f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f72:	8b 40 08             	mov    0x8(%eax),%eax
c0100f75:	8b 00                	mov    (%eax),%eax
c0100f77:	85 c0                	test   %eax,%eax
c0100f79:	75 0c                	jne    c0100f87 <check_tree+0x167>
c0100f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f7e:	8b 40 0c             	mov    0xc(%eax),%eax
c0100f81:	8b 00                	mov    (%eax),%eax
c0100f83:	85 c0                	test   %eax,%eax
c0100f85:	74 24                	je     c0100fab <check_tree+0x18b>
c0100f87:	c7 44 24 0c 48 b4 10 	movl   $0xc010b448,0xc(%esp)
c0100f8e:	c0 
c0100f8f:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c0100f96:	c0 
c0100f97:	c7 44 24 04 8b 01 00 	movl   $0x18b,0x4(%esp)
c0100f9e:	00 
c0100f9f:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c0100fa6:	e8 b5 11 00 00       	call   c0102160 <__panic>
    }
    int hb_left = check_tree(tree, node->left);
c0100fab:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100fae:	8b 40 08             	mov    0x8(%eax),%eax
c0100fb1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100fb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100fb8:	89 04 24             	mov    %eax,(%esp)
c0100fbb:	e8 60 fe ff ff       	call   c0100e20 <check_tree>
c0100fc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    int hb_right = check_tree(tree, node->right);
c0100fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100fc6:	8b 40 0c             	mov    0xc(%eax),%eax
c0100fc9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100fcd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100fd0:	89 04 24             	mov    %eax,(%esp)
c0100fd3:	e8 48 fe ff ff       	call   c0100e20 <check_tree>
c0100fd8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(hb_left == hb_right);
c0100fdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100fde:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0100fe1:	74 24                	je     c0101007 <check_tree+0x1e7>
c0100fe3:	c7 44 24 0c 6e b4 10 	movl   $0xc010b46e,0xc(%esp)
c0100fea:	c0 
c0100feb:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c0100ff2:	c0 
c0100ff3:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
c0100ffa:	00 
c0100ffb:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c0101002:	e8 59 11 00 00       	call   c0102160 <__panic>
    int hb = hb_left;
c0101007:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010100a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!node->red) {
c010100d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101010:	8b 00                	mov    (%eax),%eax
c0101012:	85 c0                	test   %eax,%eax
c0101014:	75 04                	jne    c010101a <check_tree+0x1fa>
        hb ++;
c0101016:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    return hb;
c010101a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010101d:	c9                   	leave  
c010101e:	c3                   	ret    

c010101f <check_safe_kmalloc>:

static void *
check_safe_kmalloc(size_t size) {
c010101f:	55                   	push   %ebp
c0101020:	89 e5                	mov    %esp,%ebp
c0101022:	83 ec 28             	sub    $0x28,%esp
    void *ret = kmalloc(size);
c0101025:	8b 45 08             	mov    0x8(%ebp),%eax
c0101028:	89 04 24             	mov    %eax,(%esp)
c010102b:	e8 8f 4d 00 00       	call   c0105dbf <kmalloc>
c0101030:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(ret != NULL);
c0101033:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101037:	75 24                	jne    c010105d <check_safe_kmalloc+0x3e>
c0101039:	c7 44 24 0c 82 b4 10 	movl   $0xc010b482,0xc(%esp)
c0101040:	c0 
c0101041:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c0101048:	c0 
c0101049:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
c0101050:	00 
c0101051:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c0101058:	e8 03 11 00 00       	call   c0102160 <__panic>
    return ret;
c010105d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101060:	c9                   	leave  
c0101061:	c3                   	ret    

c0101062 <check_compare1>:

#define rbn2data(node)              \
    (to_struct(node, struct check_data, rb_link))

static inline int
check_compare1(rb_node *node1, rb_node *node2) {
c0101062:	55                   	push   %ebp
c0101063:	89 e5                	mov    %esp,%ebp
    return rbn2data(node1)->data - rbn2data(node2)->data;
c0101065:	8b 45 08             	mov    0x8(%ebp),%eax
c0101068:	83 e8 04             	sub    $0x4,%eax
c010106b:	8b 10                	mov    (%eax),%edx
c010106d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101070:	83 e8 04             	sub    $0x4,%eax
c0101073:	8b 00                	mov    (%eax),%eax
c0101075:	29 c2                	sub    %eax,%edx
c0101077:	89 d0                	mov    %edx,%eax
}
c0101079:	5d                   	pop    %ebp
c010107a:	c3                   	ret    

c010107b <check_compare2>:

static inline int
check_compare2(rb_node *node, void *key) {
c010107b:	55                   	push   %ebp
c010107c:	89 e5                	mov    %esp,%ebp
    return rbn2data(node)->data - (long)key;
c010107e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101081:	83 e8 04             	sub    $0x4,%eax
c0101084:	8b 10                	mov    (%eax),%edx
c0101086:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101089:	29 c2                	sub    %eax,%edx
c010108b:	89 d0                	mov    %edx,%eax
}
c010108d:	5d                   	pop    %ebp
c010108e:	c3                   	ret    

c010108f <check_rb_tree>:

void
check_rb_tree(void) {
c010108f:	55                   	push   %ebp
c0101090:	89 e5                	mov    %esp,%ebp
c0101092:	53                   	push   %ebx
c0101093:	83 ec 44             	sub    $0x44,%esp
    rb_tree *tree = rb_tree_create(check_compare1);
c0101096:	c7 04 24 62 10 10 c0 	movl   $0xc0101062,(%esp)
c010109d:	e8 e5 f1 ff ff       	call   c0100287 <rb_tree_create>
c01010a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(tree != NULL);
c01010a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01010a9:	75 24                	jne    c01010cf <check_rb_tree+0x40>
c01010ab:	c7 44 24 0c 8e b4 10 	movl   $0xc010b48e,0xc(%esp)
c01010b2:	c0 
c01010b3:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c01010ba:	c0 
c01010bb:	c7 44 24 04 b3 01 00 	movl   $0x1b3,0x4(%esp)
c01010c2:	00 
c01010c3:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c01010ca:	e8 91 10 00 00       	call   c0102160 <__panic>

    rb_node *nil = tree->nil, *root = tree->root;
c01010cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01010d2:	8b 40 04             	mov    0x4(%eax),%eax
c01010d5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01010d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01010db:	8b 40 08             	mov    0x8(%eax),%eax
c01010de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(!nil->red && root->left == nil);
c01010e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01010e4:	8b 00                	mov    (%eax),%eax
c01010e6:	85 c0                	test   %eax,%eax
c01010e8:	75 0b                	jne    c01010f5 <check_rb_tree+0x66>
c01010ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01010ed:	8b 40 08             	mov    0x8(%eax),%eax
c01010f0:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c01010f3:	74 24                	je     c0101119 <check_rb_tree+0x8a>
c01010f5:	c7 44 24 0c 9c b4 10 	movl   $0xc010b49c,0xc(%esp)
c01010fc:	c0 
c01010fd:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c0101104:	c0 
c0101105:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
c010110c:	00 
c010110d:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c0101114:	e8 47 10 00 00       	call   c0102160 <__panic>

    int total = 1000;
c0101119:	c7 45 e0 e8 03 00 00 	movl   $0x3e8,-0x20(%ebp)
    struct check_data **all = check_safe_kmalloc(sizeof(struct check_data *) * total);
c0101120:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101123:	c1 e0 02             	shl    $0x2,%eax
c0101126:	89 04 24             	mov    %eax,(%esp)
c0101129:	e8 f1 fe ff ff       	call   c010101f <check_safe_kmalloc>
c010112e:	89 45 dc             	mov    %eax,-0x24(%ebp)

    long i;
    for (i = 0; i < total; i ++) {
c0101131:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101138:	eb 38                	jmp    c0101172 <check_rb_tree+0xe3>
        all[i] = check_safe_kmalloc(sizeof(struct check_data));
c010113a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010113d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101144:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101147:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
c010114a:	c7 04 24 14 00 00 00 	movl   $0x14,(%esp)
c0101151:	e8 c9 fe ff ff       	call   c010101f <check_safe_kmalloc>
c0101156:	89 03                	mov    %eax,(%ebx)
        all[i]->data = i;
c0101158:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010115b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101162:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101165:	01 d0                	add    %edx,%eax
c0101167:	8b 00                	mov    (%eax),%eax
c0101169:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010116c:	89 10                	mov    %edx,(%eax)

    int total = 1000;
    struct check_data **all = check_safe_kmalloc(sizeof(struct check_data *) * total);

    long i;
    for (i = 0; i < total; i ++) {
c010116e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101172:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101175:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101178:	7c c0                	jl     c010113a <check_rb_tree+0xab>
        all[i] = check_safe_kmalloc(sizeof(struct check_data));
        all[i]->data = i;
    }

    int *mark = check_safe_kmalloc(sizeof(int) * total);
c010117a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010117d:	c1 e0 02             	shl    $0x2,%eax
c0101180:	89 04 24             	mov    %eax,(%esp)
c0101183:	e8 97 fe ff ff       	call   c010101f <check_safe_kmalloc>
c0101188:	89 45 d8             	mov    %eax,-0x28(%ebp)
    memset(mark, 0, sizeof(int) * total);
c010118b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010118e:	c1 e0 02             	shl    $0x2,%eax
c0101191:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101195:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010119c:	00 
c010119d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01011a0:	89 04 24             	mov    %eax,(%esp)
c01011a3:	e8 15 9f 00 00       	call   c010b0bd <memset>

    for (i = 0; i < total; i ++) {
c01011a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01011af:	eb 29                	jmp    c01011da <check_rb_tree+0x14b>
        mark[all[i]->data] = 1;
c01011b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01011b4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01011bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01011be:	01 d0                	add    %edx,%eax
c01011c0:	8b 00                	mov    (%eax),%eax
c01011c2:	8b 00                	mov    (%eax),%eax
c01011c4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01011cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01011ce:	01 d0                	add    %edx,%eax
c01011d0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
    }

    int *mark = check_safe_kmalloc(sizeof(int) * total);
    memset(mark, 0, sizeof(int) * total);

    for (i = 0; i < total; i ++) {
c01011d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01011da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01011dd:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01011e0:	7c cf                	jl     c01011b1 <check_rb_tree+0x122>
        mark[all[i]->data] = 1;
    }
    for (i = 0; i < total; i ++) {
c01011e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01011e9:	eb 3e                	jmp    c0101229 <check_rb_tree+0x19a>
        assert(mark[i] == 1);
c01011eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01011ee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01011f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01011f8:	01 d0                	add    %edx,%eax
c01011fa:	8b 00                	mov    (%eax),%eax
c01011fc:	83 f8 01             	cmp    $0x1,%eax
c01011ff:	74 24                	je     c0101225 <check_rb_tree+0x196>
c0101201:	c7 44 24 0c bb b4 10 	movl   $0xc010b4bb,0xc(%esp)
c0101208:	c0 
c0101209:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c0101210:	c0 
c0101211:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
c0101218:	00 
c0101219:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c0101220:	e8 3b 0f 00 00       	call   c0102160 <__panic>
    memset(mark, 0, sizeof(int) * total);

    for (i = 0; i < total; i ++) {
        mark[all[i]->data] = 1;
    }
    for (i = 0; i < total; i ++) {
c0101225:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101229:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010122c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010122f:	7c ba                	jl     c01011eb <check_rb_tree+0x15c>
        assert(mark[i] == 1);
    }

    for (i = 0; i < total; i ++) {
c0101231:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101238:	eb 66                	jmp    c01012a0 <check_rb_tree+0x211>
        int j = (rand() % (total - i)) + i;
c010123a:	e8 77 9a 00 00       	call   c010acb6 <rand>
c010123f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101242:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0101245:	29 d1                	sub    %edx,%ecx
c0101247:	99                   	cltd   
c0101248:	f7 f9                	idiv   %ecx
c010124a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010124d:	01 d0                	add    %edx,%eax
c010124f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        struct check_data *z = all[i];
c0101252:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101255:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010125c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010125f:	01 d0                	add    %edx,%eax
c0101261:	8b 00                	mov    (%eax),%eax
c0101263:	89 45 d0             	mov    %eax,-0x30(%ebp)
        all[i] = all[j];
c0101266:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101269:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101270:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101273:	01 c2                	add    %eax,%edx
c0101275:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101278:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
c010127f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101282:	01 c8                	add    %ecx,%eax
c0101284:	8b 00                	mov    (%eax),%eax
c0101286:	89 02                	mov    %eax,(%edx)
        all[j] = z;
c0101288:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010128b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101292:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101295:	01 c2                	add    %eax,%edx
c0101297:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010129a:	89 02                	mov    %eax,(%edx)
    }
    for (i = 0; i < total; i ++) {
        assert(mark[i] == 1);
    }

    for (i = 0; i < total; i ++) {
c010129c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01012a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012a3:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01012a6:	7c 92                	jl     c010123a <check_rb_tree+0x1ab>
        struct check_data *z = all[i];
        all[i] = all[j];
        all[j] = z;
    }

    memset(mark, 0, sizeof(int) * total);
c01012a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01012ab:	c1 e0 02             	shl    $0x2,%eax
c01012ae:	89 44 24 08          	mov    %eax,0x8(%esp)
c01012b2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01012b9:	00 
c01012ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01012bd:	89 04 24             	mov    %eax,(%esp)
c01012c0:	e8 f8 9d 00 00       	call   c010b0bd <memset>
    for (i = 0; i < total; i ++) {
c01012c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01012cc:	eb 29                	jmp    c01012f7 <check_rb_tree+0x268>
        mark[all[i]->data] = 1;
c01012ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012d1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01012d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01012db:	01 d0                	add    %edx,%eax
c01012dd:	8b 00                	mov    (%eax),%eax
c01012df:	8b 00                	mov    (%eax),%eax
c01012e1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01012e8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01012eb:	01 d0                	add    %edx,%eax
c01012ed:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        all[i] = all[j];
        all[j] = z;
    }

    memset(mark, 0, sizeof(int) * total);
    for (i = 0; i < total; i ++) {
c01012f3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01012f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012fa:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01012fd:	7c cf                	jl     c01012ce <check_rb_tree+0x23f>
        mark[all[i]->data] = 1;
    }
    for (i = 0; i < total; i ++) {
c01012ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101306:	eb 3e                	jmp    c0101346 <check_rb_tree+0x2b7>
        assert(mark[i] == 1);
c0101308:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010130b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101312:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101315:	01 d0                	add    %edx,%eax
c0101317:	8b 00                	mov    (%eax),%eax
c0101319:	83 f8 01             	cmp    $0x1,%eax
c010131c:	74 24                	je     c0101342 <check_rb_tree+0x2b3>
c010131e:	c7 44 24 0c bb b4 10 	movl   $0xc010b4bb,0xc(%esp)
c0101325:	c0 
c0101326:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c010132d:	c0 
c010132e:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
c0101335:	00 
c0101336:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c010133d:	e8 1e 0e 00 00       	call   c0102160 <__panic>

    memset(mark, 0, sizeof(int) * total);
    for (i = 0; i < total; i ++) {
        mark[all[i]->data] = 1;
    }
    for (i = 0; i < total; i ++) {
c0101342:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101346:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101349:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010134c:	7c ba                	jl     c0101308 <check_rb_tree+0x279>
        assert(mark[i] == 1);
    }

    for (i = 0; i < total; i ++) {
c010134e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101355:	eb 3c                	jmp    c0101393 <check_rb_tree+0x304>
        rb_insert(tree, &(all[i]->rb_link));
c0101357:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010135a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101361:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101364:	01 d0                	add    %edx,%eax
c0101366:	8b 00                	mov    (%eax),%eax
c0101368:	83 c0 04             	add    $0x4,%eax
c010136b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010136f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101372:	89 04 24             	mov    %eax,(%esp)
c0101375:	e8 a3 f2 ff ff       	call   c010061d <rb_insert>
        check_tree(tree, root->left);
c010137a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010137d:	8b 40 08             	mov    0x8(%eax),%eax
c0101380:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101384:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101387:	89 04 24             	mov    %eax,(%esp)
c010138a:	e8 91 fa ff ff       	call   c0100e20 <check_tree>
    }
    for (i = 0; i < total; i ++) {
        assert(mark[i] == 1);
    }

    for (i = 0; i < total; i ++) {
c010138f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101393:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101396:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101399:	7c bc                	jl     c0101357 <check_rb_tree+0x2c8>
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    rb_node *node;
    for (i = 0; i < total; i ++) {
c010139b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01013a2:	eb 74                	jmp    c0101418 <check_rb_tree+0x389>
        node = rb_search(tree, check_compare2, (void *)(all[i]->data));
c01013a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01013a7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01013ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01013b1:	01 d0                	add    %edx,%eax
c01013b3:	8b 00                	mov    (%eax),%eax
c01013b5:	8b 00                	mov    (%eax),%eax
c01013b7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01013bb:	c7 44 24 04 7b 10 10 	movl   $0xc010107b,0x4(%esp)
c01013c2:	c0 
c01013c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01013c6:	89 04 24             	mov    %eax,(%esp)
c01013c9:	e8 3c f5 ff ff       	call   c010090a <rb_search>
c01013ce:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(node != NULL && node == &(all[i]->rb_link));
c01013d1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01013d5:	74 19                	je     c01013f0 <check_rb_tree+0x361>
c01013d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01013da:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01013e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01013e4:	01 d0                	add    %edx,%eax
c01013e6:	8b 00                	mov    (%eax),%eax
c01013e8:	83 c0 04             	add    $0x4,%eax
c01013eb:	3b 45 cc             	cmp    -0x34(%ebp),%eax
c01013ee:	74 24                	je     c0101414 <check_rb_tree+0x385>
c01013f0:	c7 44 24 0c c8 b4 10 	movl   $0xc010b4c8,0xc(%esp)
c01013f7:	c0 
c01013f8:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c01013ff:	c0 
c0101400:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
c0101407:	00 
c0101408:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c010140f:	e8 4c 0d 00 00       	call   c0102160 <__panic>
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    rb_node *node;
    for (i = 0; i < total; i ++) {
c0101414:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101418:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010141b:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010141e:	7c 84                	jl     c01013a4 <check_rb_tree+0x315>
        node = rb_search(tree, check_compare2, (void *)(all[i]->data));
        assert(node != NULL && node == &(all[i]->rb_link));
    }

    for (i = 0; i < total; i ++) {
c0101420:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101427:	eb 7f                	jmp    c01014a8 <check_rb_tree+0x419>
        node = rb_search(tree, check_compare2, (void *)i);
c0101429:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010142c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101430:	c7 44 24 04 7b 10 10 	movl   $0xc010107b,0x4(%esp)
c0101437:	c0 
c0101438:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010143b:	89 04 24             	mov    %eax,(%esp)
c010143e:	e8 c7 f4 ff ff       	call   c010090a <rb_search>
c0101443:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(node != NULL && rbn2data(node)->data == i);
c0101446:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010144a:	74 0d                	je     c0101459 <check_rb_tree+0x3ca>
c010144c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010144f:	83 e8 04             	sub    $0x4,%eax
c0101452:	8b 00                	mov    (%eax),%eax
c0101454:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0101457:	74 24                	je     c010147d <check_rb_tree+0x3ee>
c0101459:	c7 44 24 0c f4 b4 10 	movl   $0xc010b4f4,0xc(%esp)
c0101460:	c0 
c0101461:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c0101468:	c0 
c0101469:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c0101470:	00 
c0101471:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c0101478:	e8 e3 0c 00 00       	call   c0102160 <__panic>
        rb_delete(tree, node);
c010147d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0101480:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101484:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101487:	89 04 24             	mov    %eax,(%esp)
c010148a:	e8 29 f7 ff ff       	call   c0100bb8 <rb_delete>
        check_tree(tree, root->left);
c010148f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101492:	8b 40 08             	mov    0x8(%eax),%eax
c0101495:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101499:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010149c:	89 04 24             	mov    %eax,(%esp)
c010149f:	e8 7c f9 ff ff       	call   c0100e20 <check_tree>
    for (i = 0; i < total; i ++) {
        node = rb_search(tree, check_compare2, (void *)(all[i]->data));
        assert(node != NULL && node == &(all[i]->rb_link));
    }

    for (i = 0; i < total; i ++) {
c01014a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01014a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01014ab:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01014ae:	0f 8c 75 ff ff ff    	jl     c0101429 <check_rb_tree+0x39a>
        assert(node != NULL && rbn2data(node)->data == i);
        rb_delete(tree, node);
        check_tree(tree, root->left);
    }

    assert(!nil->red && root->left == nil);
c01014b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01014b7:	8b 00                	mov    (%eax),%eax
c01014b9:	85 c0                	test   %eax,%eax
c01014bb:	75 0b                	jne    c01014c8 <check_rb_tree+0x439>
c01014bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01014c0:	8b 40 08             	mov    0x8(%eax),%eax
c01014c3:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c01014c6:	74 24                	je     c01014ec <check_rb_tree+0x45d>
c01014c8:	c7 44 24 0c 9c b4 10 	movl   $0xc010b49c,0xc(%esp)
c01014cf:	c0 
c01014d0:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c01014d7:	c0 
c01014d8:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c01014df:	00 
c01014e0:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c01014e7:	e8 74 0c 00 00       	call   c0102160 <__panic>

    long max = 32;
c01014ec:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
    if (max > total) {
c01014f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01014f6:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01014f9:	7e 06                	jle    c0101501 <check_rb_tree+0x472>
        max = total;
c01014fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01014fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }

    for (i = 0; i < max; i ++) {
c0101501:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101508:	eb 52                	jmp    c010155c <check_rb_tree+0x4cd>
        all[i]->data = max;
c010150a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010150d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101514:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101517:	01 d0                	add    %edx,%eax
c0101519:	8b 00                	mov    (%eax),%eax
c010151b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010151e:	89 10                	mov    %edx,(%eax)
        rb_insert(tree, &(all[i]->rb_link));
c0101520:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101523:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010152a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010152d:	01 d0                	add    %edx,%eax
c010152f:	8b 00                	mov    (%eax),%eax
c0101531:	83 c0 04             	add    $0x4,%eax
c0101534:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101538:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010153b:	89 04 24             	mov    %eax,(%esp)
c010153e:	e8 da f0 ff ff       	call   c010061d <rb_insert>
        check_tree(tree, root->left);
c0101543:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101546:	8b 40 08             	mov    0x8(%eax),%eax
c0101549:	89 44 24 04          	mov    %eax,0x4(%esp)
c010154d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101550:	89 04 24             	mov    %eax,(%esp)
c0101553:	e8 c8 f8 ff ff       	call   c0100e20 <check_tree>
    long max = 32;
    if (max > total) {
        max = total;
    }

    for (i = 0; i < max; i ++) {
c0101558:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010155c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010155f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0101562:	7c a6                	jl     c010150a <check_rb_tree+0x47b>
        all[i]->data = max;
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    for (i = 0; i < max; i ++) {
c0101564:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010156b:	eb 7f                	jmp    c01015ec <check_rb_tree+0x55d>
        node = rb_search(tree, check_compare2, (void *)max);
c010156d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101570:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101574:	c7 44 24 04 7b 10 10 	movl   $0xc010107b,0x4(%esp)
c010157b:	c0 
c010157c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010157f:	89 04 24             	mov    %eax,(%esp)
c0101582:	e8 83 f3 ff ff       	call   c010090a <rb_search>
c0101587:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(node != NULL && rbn2data(node)->data == max);
c010158a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010158e:	74 0d                	je     c010159d <check_rb_tree+0x50e>
c0101590:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0101593:	83 e8 04             	sub    $0x4,%eax
c0101596:	8b 00                	mov    (%eax),%eax
c0101598:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010159b:	74 24                	je     c01015c1 <check_rb_tree+0x532>
c010159d:	c7 44 24 0c 20 b5 10 	movl   $0xc010b520,0xc(%esp)
c01015a4:	c0 
c01015a5:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c01015ac:	c0 
c01015ad:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c01015b4:	00 
c01015b5:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c01015bc:	e8 9f 0b 00 00       	call   c0102160 <__panic>
        rb_delete(tree, node);
c01015c1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01015c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01015c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01015cb:	89 04 24             	mov    %eax,(%esp)
c01015ce:	e8 e5 f5 ff ff       	call   c0100bb8 <rb_delete>
        check_tree(tree, root->left);
c01015d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01015d6:	8b 40 08             	mov    0x8(%eax),%eax
c01015d9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01015dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01015e0:	89 04 24             	mov    %eax,(%esp)
c01015e3:	e8 38 f8 ff ff       	call   c0100e20 <check_tree>
        all[i]->data = max;
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    for (i = 0; i < max; i ++) {
c01015e8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01015ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01015ef:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01015f2:	0f 8c 75 ff ff ff    	jl     c010156d <check_rb_tree+0x4de>
        assert(node != NULL && rbn2data(node)->data == max);
        rb_delete(tree, node);
        check_tree(tree, root->left);
    }

    assert(rb_tree_empty(tree));
c01015f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01015fb:	89 04 24             	mov    %eax,(%esp)
c01015fe:	e8 5b ec ff ff       	call   c010025e <rb_tree_empty>
c0101603:	85 c0                	test   %eax,%eax
c0101605:	75 24                	jne    c010162b <check_rb_tree+0x59c>
c0101607:	c7 44 24 0c 4c b5 10 	movl   $0xc010b54c,0xc(%esp)
c010160e:	c0 
c010160f:	c7 44 24 08 18 b3 10 	movl   $0xc010b318,0x8(%esp)
c0101616:	c0 
c0101617:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c010161e:	00 
c010161f:	c7 04 24 2d b3 10 c0 	movl   $0xc010b32d,(%esp)
c0101626:	e8 35 0b 00 00       	call   c0102160 <__panic>

    for (i = 0; i < total; i ++) {
c010162b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101632:	eb 3c                	jmp    c0101670 <check_rb_tree+0x5e1>
        rb_insert(tree, &(all[i]->rb_link));
c0101634:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101637:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010163e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101641:	01 d0                	add    %edx,%eax
c0101643:	8b 00                	mov    (%eax),%eax
c0101645:	83 c0 04             	add    $0x4,%eax
c0101648:	89 44 24 04          	mov    %eax,0x4(%esp)
c010164c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010164f:	89 04 24             	mov    %eax,(%esp)
c0101652:	e8 c6 ef ff ff       	call   c010061d <rb_insert>
        check_tree(tree, root->left);
c0101657:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010165a:	8b 40 08             	mov    0x8(%eax),%eax
c010165d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101661:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101664:	89 04 24             	mov    %eax,(%esp)
c0101667:	e8 b4 f7 ff ff       	call   c0100e20 <check_tree>
        check_tree(tree, root->left);
    }

    assert(rb_tree_empty(tree));

    for (i = 0; i < total; i ++) {
c010166c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101670:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101673:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101676:	7c bc                	jl     c0101634 <check_rb_tree+0x5a5>
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    rb_tree_destroy(tree);
c0101678:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010167b:	89 04 24             	mov    %eax,(%esp)
c010167e:	e8 95 f6 ff ff       	call   c0100d18 <rb_tree_destroy>

    for (i = 0; i < total; i ++) {
c0101683:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010168a:	eb 1d                	jmp    c01016a9 <check_rb_tree+0x61a>
        kfree(all[i]);
c010168c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010168f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101696:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101699:	01 d0                	add    %edx,%eax
c010169b:	8b 00                	mov    (%eax),%eax
c010169d:	89 04 24             	mov    %eax,(%esp)
c01016a0:	e8 35 47 00 00       	call   c0105dda <kfree>
        check_tree(tree, root->left);
    }

    rb_tree_destroy(tree);

    for (i = 0; i < total; i ++) {
c01016a5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01016a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016ac:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01016af:	7c db                	jl     c010168c <check_rb_tree+0x5fd>
        kfree(all[i]);
    }

    kfree(mark);
c01016b1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01016b4:	89 04 24             	mov    %eax,(%esp)
c01016b7:	e8 1e 47 00 00       	call   c0105dda <kfree>
    kfree(all);
c01016bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01016bf:	89 04 24             	mov    %eax,(%esp)
c01016c2:	e8 13 47 00 00       	call   c0105dda <kfree>
}
c01016c7:	83 c4 44             	add    $0x44,%esp
c01016ca:	5b                   	pop    %ebx
c01016cb:	5d                   	pop    %ebp
c01016cc:	c3                   	ret    

c01016cd <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c01016cd:	55                   	push   %ebp
c01016ce:	89 e5                	mov    %esp,%ebp
c01016d0:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c01016d3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01016d7:	74 13                	je     c01016ec <readline+0x1f>
        cprintf("%s", prompt);
c01016d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01016dc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01016e0:	c7 04 24 60 b5 10 c0 	movl   $0xc010b560,(%esp)
c01016e7:	e8 ea 00 00 00       	call   c01017d6 <cprintf>
    }
    int i = 0, c;
c01016ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c01016f3:	e8 66 01 00 00       	call   c010185e <getchar>
c01016f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c01016fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01016ff:	79 07                	jns    c0101708 <readline+0x3b>
            return NULL;
c0101701:	b8 00 00 00 00       	mov    $0x0,%eax
c0101706:	eb 79                	jmp    c0101781 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0101708:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010170c:	7e 28                	jle    c0101736 <readline+0x69>
c010170e:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0101715:	7f 1f                	jg     c0101736 <readline+0x69>
            cputchar(c);
c0101717:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010171a:	89 04 24             	mov    %eax,(%esp)
c010171d:	e8 da 00 00 00       	call   c01017fc <cputchar>
            buf[i ++] = c;
c0101722:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101725:	8d 50 01             	lea    0x1(%eax),%edx
c0101728:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010172b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010172e:	88 90 c0 8a 12 c0    	mov    %dl,-0x3fed7540(%eax)
c0101734:	eb 46                	jmp    c010177c <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c0101736:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c010173a:	75 17                	jne    c0101753 <readline+0x86>
c010173c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101740:	7e 11                	jle    c0101753 <readline+0x86>
            cputchar(c);
c0101742:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101745:	89 04 24             	mov    %eax,(%esp)
c0101748:	e8 af 00 00 00       	call   c01017fc <cputchar>
            i --;
c010174d:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0101751:	eb 29                	jmp    c010177c <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c0101753:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c0101757:	74 06                	je     c010175f <readline+0x92>
c0101759:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c010175d:	75 1d                	jne    c010177c <readline+0xaf>
            cputchar(c);
c010175f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101762:	89 04 24             	mov    %eax,(%esp)
c0101765:	e8 92 00 00 00       	call   c01017fc <cputchar>
            buf[i] = '\0';
c010176a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010176d:	05 c0 8a 12 c0       	add    $0xc0128ac0,%eax
c0101772:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c0101775:	b8 c0 8a 12 c0       	mov    $0xc0128ac0,%eax
c010177a:	eb 05                	jmp    c0101781 <readline+0xb4>
        }
    }
c010177c:	e9 72 ff ff ff       	jmp    c01016f3 <readline+0x26>
}
c0101781:	c9                   	leave  
c0101782:	c3                   	ret    

c0101783 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0101783:	55                   	push   %ebp
c0101784:	89 e5                	mov    %esp,%ebp
c0101786:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0101789:	8b 45 08             	mov    0x8(%ebp),%eax
c010178c:	89 04 24             	mov    %eax,(%esp)
c010178f:	e8 fe 12 00 00       	call   c0102a92 <cons_putc>
    (*cnt) ++;
c0101794:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101797:	8b 00                	mov    (%eax),%eax
c0101799:	8d 50 01             	lea    0x1(%eax),%edx
c010179c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010179f:	89 10                	mov    %edx,(%eax)
}
c01017a1:	c9                   	leave  
c01017a2:	c3                   	ret    

c01017a3 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c01017a3:	55                   	push   %ebp
c01017a4:	89 e5                	mov    %esp,%ebp
c01017a6:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01017a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c01017b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01017b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01017b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01017ba:	89 44 24 08          	mov    %eax,0x8(%esp)
c01017be:	8d 45 f4             	lea    -0xc(%ebp),%eax
c01017c1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01017c5:	c7 04 24 83 17 10 c0 	movl   $0xc0101783,(%esp)
c01017cc:	e8 2d 90 00 00       	call   c010a7fe <vprintfmt>
    return cnt;
c01017d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01017d4:	c9                   	leave  
c01017d5:	c3                   	ret    

c01017d6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01017d6:	55                   	push   %ebp
c01017d7:	89 e5                	mov    %esp,%ebp
c01017d9:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01017dc:	8d 45 0c             	lea    0xc(%ebp),%eax
c01017df:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01017e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01017e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01017e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01017ec:	89 04 24             	mov    %eax,(%esp)
c01017ef:	e8 af ff ff ff       	call   c01017a3 <vcprintf>
c01017f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01017f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01017fa:	c9                   	leave  
c01017fb:	c3                   	ret    

c01017fc <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01017fc:	55                   	push   %ebp
c01017fd:	89 e5                	mov    %esp,%ebp
c01017ff:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0101802:	8b 45 08             	mov    0x8(%ebp),%eax
c0101805:	89 04 24             	mov    %eax,(%esp)
c0101808:	e8 85 12 00 00       	call   c0102a92 <cons_putc>
}
c010180d:	c9                   	leave  
c010180e:	c3                   	ret    

c010180f <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c010180f:	55                   	push   %ebp
c0101810:	89 e5                	mov    %esp,%ebp
c0101812:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0101815:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010181c:	eb 13                	jmp    c0101831 <cputs+0x22>
        cputch(c, &cnt);
c010181e:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101822:	8d 55 f0             	lea    -0x10(%ebp),%edx
c0101825:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101829:	89 04 24             	mov    %eax,(%esp)
c010182c:	e8 52 ff ff ff       	call   c0101783 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c0101831:	8b 45 08             	mov    0x8(%ebp),%eax
c0101834:	8d 50 01             	lea    0x1(%eax),%edx
c0101837:	89 55 08             	mov    %edx,0x8(%ebp)
c010183a:	0f b6 00             	movzbl (%eax),%eax
c010183d:	88 45 f7             	mov    %al,-0x9(%ebp)
c0101840:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0101844:	75 d8                	jne    c010181e <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c0101846:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0101849:	89 44 24 04          	mov    %eax,0x4(%esp)
c010184d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0101854:	e8 2a ff ff ff       	call   c0101783 <cputch>
    return cnt;
c0101859:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010185c:	c9                   	leave  
c010185d:	c3                   	ret    

c010185e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010185e:	55                   	push   %ebp
c010185f:	89 e5                	mov    %esp,%ebp
c0101861:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0101864:	e8 65 12 00 00       	call   c0102ace <cons_getc>
c0101869:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010186c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101870:	74 f2                	je     c0101864 <getchar+0x6>
        /* do nothing */;
    return c;
c0101872:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101875:	c9                   	leave  
c0101876:	c3                   	ret    

c0101877 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0101877:	55                   	push   %ebp
c0101878:	89 e5                	mov    %esp,%ebp
c010187a:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c010187d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101880:	8b 00                	mov    (%eax),%eax
c0101882:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0101885:	8b 45 10             	mov    0x10(%ebp),%eax
c0101888:	8b 00                	mov    (%eax),%eax
c010188a:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010188d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0101894:	e9 d2 00 00 00       	jmp    c010196b <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c0101899:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010189c:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010189f:	01 d0                	add    %edx,%eax
c01018a1:	89 c2                	mov    %eax,%edx
c01018a3:	c1 ea 1f             	shr    $0x1f,%edx
c01018a6:	01 d0                	add    %edx,%eax
c01018a8:	d1 f8                	sar    %eax
c01018aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01018ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01018b0:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01018b3:	eb 04                	jmp    c01018b9 <stab_binsearch+0x42>
            m --;
c01018b5:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01018b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01018bc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01018bf:	7c 1f                	jl     c01018e0 <stab_binsearch+0x69>
c01018c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01018c4:	89 d0                	mov    %edx,%eax
c01018c6:	01 c0                	add    %eax,%eax
c01018c8:	01 d0                	add    %edx,%eax
c01018ca:	c1 e0 02             	shl    $0x2,%eax
c01018cd:	89 c2                	mov    %eax,%edx
c01018cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01018d2:	01 d0                	add    %edx,%eax
c01018d4:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01018d8:	0f b6 c0             	movzbl %al,%eax
c01018db:	3b 45 14             	cmp    0x14(%ebp),%eax
c01018de:	75 d5                	jne    c01018b5 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c01018e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01018e3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01018e6:	7d 0b                	jge    c01018f3 <stab_binsearch+0x7c>
            l = true_m + 1;
c01018e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01018eb:	83 c0 01             	add    $0x1,%eax
c01018ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c01018f1:	eb 78                	jmp    c010196b <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c01018f3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c01018fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01018fd:	89 d0                	mov    %edx,%eax
c01018ff:	01 c0                	add    %eax,%eax
c0101901:	01 d0                	add    %edx,%eax
c0101903:	c1 e0 02             	shl    $0x2,%eax
c0101906:	89 c2                	mov    %eax,%edx
c0101908:	8b 45 08             	mov    0x8(%ebp),%eax
c010190b:	01 d0                	add    %edx,%eax
c010190d:	8b 40 08             	mov    0x8(%eax),%eax
c0101910:	3b 45 18             	cmp    0x18(%ebp),%eax
c0101913:	73 13                	jae    c0101928 <stab_binsearch+0xb1>
            *region_left = m;
c0101915:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101918:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010191b:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010191d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101920:	83 c0 01             	add    $0x1,%eax
c0101923:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0101926:	eb 43                	jmp    c010196b <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c0101928:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010192b:	89 d0                	mov    %edx,%eax
c010192d:	01 c0                	add    %eax,%eax
c010192f:	01 d0                	add    %edx,%eax
c0101931:	c1 e0 02             	shl    $0x2,%eax
c0101934:	89 c2                	mov    %eax,%edx
c0101936:	8b 45 08             	mov    0x8(%ebp),%eax
c0101939:	01 d0                	add    %edx,%eax
c010193b:	8b 40 08             	mov    0x8(%eax),%eax
c010193e:	3b 45 18             	cmp    0x18(%ebp),%eax
c0101941:	76 16                	jbe    c0101959 <stab_binsearch+0xe2>
            *region_right = m - 1;
c0101943:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101946:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101949:	8b 45 10             	mov    0x10(%ebp),%eax
c010194c:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c010194e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101951:	83 e8 01             	sub    $0x1,%eax
c0101954:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0101957:	eb 12                	jmp    c010196b <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c0101959:	8b 45 0c             	mov    0xc(%ebp),%eax
c010195c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010195f:	89 10                	mov    %edx,(%eax)
            l = m;
c0101961:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101964:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c0101967:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c010196b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010196e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0101971:	0f 8e 22 ff ff ff    	jle    c0101899 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c0101977:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010197b:	75 0f                	jne    c010198c <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c010197d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101980:	8b 00                	mov    (%eax),%eax
c0101982:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101985:	8b 45 10             	mov    0x10(%ebp),%eax
c0101988:	89 10                	mov    %edx,(%eax)
c010198a:	eb 3f                	jmp    c01019cb <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c010198c:	8b 45 10             	mov    0x10(%ebp),%eax
c010198f:	8b 00                	mov    (%eax),%eax
c0101991:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0101994:	eb 04                	jmp    c010199a <stab_binsearch+0x123>
c0101996:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c010199a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010199d:	8b 00                	mov    (%eax),%eax
c010199f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01019a2:	7d 1f                	jge    c01019c3 <stab_binsearch+0x14c>
c01019a4:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01019a7:	89 d0                	mov    %edx,%eax
c01019a9:	01 c0                	add    %eax,%eax
c01019ab:	01 d0                	add    %edx,%eax
c01019ad:	c1 e0 02             	shl    $0x2,%eax
c01019b0:	89 c2                	mov    %eax,%edx
c01019b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01019b5:	01 d0                	add    %edx,%eax
c01019b7:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01019bb:	0f b6 c0             	movzbl %al,%eax
c01019be:	3b 45 14             	cmp    0x14(%ebp),%eax
c01019c1:	75 d3                	jne    c0101996 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c01019c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019c6:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01019c9:	89 10                	mov    %edx,(%eax)
    }
}
c01019cb:	c9                   	leave  
c01019cc:	c3                   	ret    

c01019cd <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c01019cd:	55                   	push   %ebp
c01019ce:	89 e5                	mov    %esp,%ebp
c01019d0:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c01019d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019d6:	c7 00 64 b5 10 c0    	movl   $0xc010b564,(%eax)
    info->eip_line = 0;
c01019dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019df:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c01019e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019e9:	c7 40 08 64 b5 10 c0 	movl   $0xc010b564,0x8(%eax)
    info->eip_fn_namelen = 9;
c01019f0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019f3:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c01019fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019fd:	8b 55 08             	mov    0x8(%ebp),%edx
c0101a00:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0101a03:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101a06:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0101a0d:	c7 45 f4 30 d7 10 c0 	movl   $0xc010d730,-0xc(%ebp)
    stab_end = __STAB_END__;
c0101a14:	c7 45 f0 b4 03 12 c0 	movl   $0xc01203b4,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0101a1b:	c7 45 ec b5 03 12 c0 	movl   $0xc01203b5,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0101a22:	c7 45 e8 ac 50 12 c0 	movl   $0xc01250ac,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0101a29:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101a2c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0101a2f:	76 0d                	jbe    c0101a3e <debuginfo_eip+0x71>
c0101a31:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101a34:	83 e8 01             	sub    $0x1,%eax
c0101a37:	0f b6 00             	movzbl (%eax),%eax
c0101a3a:	84 c0                	test   %al,%al
c0101a3c:	74 0a                	je     c0101a48 <debuginfo_eip+0x7b>
        return -1;
c0101a3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101a43:	e9 c0 02 00 00       	jmp    c0101d08 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0101a48:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0101a4f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101a55:	29 c2                	sub    %eax,%edx
c0101a57:	89 d0                	mov    %edx,%eax
c0101a59:	c1 f8 02             	sar    $0x2,%eax
c0101a5c:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c0101a62:	83 e8 01             	sub    $0x1,%eax
c0101a65:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c0101a68:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a6b:	89 44 24 10          	mov    %eax,0x10(%esp)
c0101a6f:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c0101a76:	00 
c0101a77:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0101a7a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101a7e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0101a81:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101a88:	89 04 24             	mov    %eax,(%esp)
c0101a8b:	e8 e7 fd ff ff       	call   c0101877 <stab_binsearch>
    if (lfile == 0)
c0101a90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a93:	85 c0                	test   %eax,%eax
c0101a95:	75 0a                	jne    c0101aa1 <debuginfo_eip+0xd4>
        return -1;
c0101a97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101a9c:	e9 67 02 00 00       	jmp    c0101d08 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0101aa1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101aa4:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101aa7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101aaa:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0101aad:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ab0:	89 44 24 10          	mov    %eax,0x10(%esp)
c0101ab4:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0101abb:	00 
c0101abc:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0101abf:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101ac3:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0101ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101acd:	89 04 24             	mov    %eax,(%esp)
c0101ad0:	e8 a2 fd ff ff       	call   c0101877 <stab_binsearch>

    if (lfun <= rfun) {
c0101ad5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101ad8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101adb:	39 c2                	cmp    %eax,%edx
c0101add:	7f 7c                	jg     c0101b5b <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0101adf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101ae2:	89 c2                	mov    %eax,%edx
c0101ae4:	89 d0                	mov    %edx,%eax
c0101ae6:	01 c0                	add    %eax,%eax
c0101ae8:	01 d0                	add    %edx,%eax
c0101aea:	c1 e0 02             	shl    $0x2,%eax
c0101aed:	89 c2                	mov    %eax,%edx
c0101aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101af2:	01 d0                	add    %edx,%eax
c0101af4:	8b 10                	mov    (%eax),%edx
c0101af6:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0101af9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101afc:	29 c1                	sub    %eax,%ecx
c0101afe:	89 c8                	mov    %ecx,%eax
c0101b00:	39 c2                	cmp    %eax,%edx
c0101b02:	73 22                	jae    c0101b26 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0101b04:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101b07:	89 c2                	mov    %eax,%edx
c0101b09:	89 d0                	mov    %edx,%eax
c0101b0b:	01 c0                	add    %eax,%eax
c0101b0d:	01 d0                	add    %edx,%eax
c0101b0f:	c1 e0 02             	shl    $0x2,%eax
c0101b12:	89 c2                	mov    %eax,%edx
c0101b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b17:	01 d0                	add    %edx,%eax
c0101b19:	8b 10                	mov    (%eax),%edx
c0101b1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101b1e:	01 c2                	add    %eax,%edx
c0101b20:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b23:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0101b26:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101b29:	89 c2                	mov    %eax,%edx
c0101b2b:	89 d0                	mov    %edx,%eax
c0101b2d:	01 c0                	add    %eax,%eax
c0101b2f:	01 d0                	add    %edx,%eax
c0101b31:	c1 e0 02             	shl    $0x2,%eax
c0101b34:	89 c2                	mov    %eax,%edx
c0101b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b39:	01 d0                	add    %edx,%eax
c0101b3b:	8b 50 08             	mov    0x8(%eax),%edx
c0101b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b41:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0101b44:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b47:	8b 40 10             	mov    0x10(%eax),%eax
c0101b4a:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0101b4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101b50:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0101b53:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101b56:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101b59:	eb 15                	jmp    c0101b70 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0101b5b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b5e:	8b 55 08             	mov    0x8(%ebp),%edx
c0101b61:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c0101b64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101b67:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c0101b6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101b6d:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c0101b70:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b73:	8b 40 08             	mov    0x8(%eax),%eax
c0101b76:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c0101b7d:	00 
c0101b7e:	89 04 24             	mov    %eax,(%esp)
c0101b81:	e8 ab 93 00 00       	call   c010af31 <strfind>
c0101b86:	89 c2                	mov    %eax,%edx
c0101b88:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b8b:	8b 40 08             	mov    0x8(%eax),%eax
c0101b8e:	29 c2                	sub    %eax,%edx
c0101b90:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b93:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0101b96:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b99:	89 44 24 10          	mov    %eax,0x10(%esp)
c0101b9d:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0101ba4:	00 
c0101ba5:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0101ba8:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101bac:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0101baf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bb6:	89 04 24             	mov    %eax,(%esp)
c0101bb9:	e8 b9 fc ff ff       	call   c0101877 <stab_binsearch>
    if (lline <= rline) {
c0101bbe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101bc1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101bc4:	39 c2                	cmp    %eax,%edx
c0101bc6:	7f 24                	jg     c0101bec <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c0101bc8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101bcb:	89 c2                	mov    %eax,%edx
c0101bcd:	89 d0                	mov    %edx,%eax
c0101bcf:	01 c0                	add    %eax,%eax
c0101bd1:	01 d0                	add    %edx,%eax
c0101bd3:	c1 e0 02             	shl    $0x2,%eax
c0101bd6:	89 c2                	mov    %eax,%edx
c0101bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bdb:	01 d0                	add    %edx,%eax
c0101bdd:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0101be1:	0f b7 d0             	movzwl %ax,%edx
c0101be4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101be7:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0101bea:	eb 13                	jmp    c0101bff <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0101bec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101bf1:	e9 12 01 00 00       	jmp    c0101d08 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0101bf6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101bf9:	83 e8 01             	sub    $0x1,%eax
c0101bfc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0101bff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101c02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101c05:	39 c2                	cmp    %eax,%edx
c0101c07:	7c 56                	jl     c0101c5f <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c0101c09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c0c:	89 c2                	mov    %eax,%edx
c0101c0e:	89 d0                	mov    %edx,%eax
c0101c10:	01 c0                	add    %eax,%eax
c0101c12:	01 d0                	add    %edx,%eax
c0101c14:	c1 e0 02             	shl    $0x2,%eax
c0101c17:	89 c2                	mov    %eax,%edx
c0101c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c1c:	01 d0                	add    %edx,%eax
c0101c1e:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101c22:	3c 84                	cmp    $0x84,%al
c0101c24:	74 39                	je     c0101c5f <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0101c26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c29:	89 c2                	mov    %eax,%edx
c0101c2b:	89 d0                	mov    %edx,%eax
c0101c2d:	01 c0                	add    %eax,%eax
c0101c2f:	01 d0                	add    %edx,%eax
c0101c31:	c1 e0 02             	shl    $0x2,%eax
c0101c34:	89 c2                	mov    %eax,%edx
c0101c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c39:	01 d0                	add    %edx,%eax
c0101c3b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101c3f:	3c 64                	cmp    $0x64,%al
c0101c41:	75 b3                	jne    c0101bf6 <debuginfo_eip+0x229>
c0101c43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c46:	89 c2                	mov    %eax,%edx
c0101c48:	89 d0                	mov    %edx,%eax
c0101c4a:	01 c0                	add    %eax,%eax
c0101c4c:	01 d0                	add    %edx,%eax
c0101c4e:	c1 e0 02             	shl    $0x2,%eax
c0101c51:	89 c2                	mov    %eax,%edx
c0101c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c56:	01 d0                	add    %edx,%eax
c0101c58:	8b 40 08             	mov    0x8(%eax),%eax
c0101c5b:	85 c0                	test   %eax,%eax
c0101c5d:	74 97                	je     c0101bf6 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0101c5f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101c62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101c65:	39 c2                	cmp    %eax,%edx
c0101c67:	7c 46                	jl     c0101caf <debuginfo_eip+0x2e2>
c0101c69:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c6c:	89 c2                	mov    %eax,%edx
c0101c6e:	89 d0                	mov    %edx,%eax
c0101c70:	01 c0                	add    %eax,%eax
c0101c72:	01 d0                	add    %edx,%eax
c0101c74:	c1 e0 02             	shl    $0x2,%eax
c0101c77:	89 c2                	mov    %eax,%edx
c0101c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c7c:	01 d0                	add    %edx,%eax
c0101c7e:	8b 10                	mov    (%eax),%edx
c0101c80:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0101c83:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101c86:	29 c1                	sub    %eax,%ecx
c0101c88:	89 c8                	mov    %ecx,%eax
c0101c8a:	39 c2                	cmp    %eax,%edx
c0101c8c:	73 21                	jae    c0101caf <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0101c8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c91:	89 c2                	mov    %eax,%edx
c0101c93:	89 d0                	mov    %edx,%eax
c0101c95:	01 c0                	add    %eax,%eax
c0101c97:	01 d0                	add    %edx,%eax
c0101c99:	c1 e0 02             	shl    $0x2,%eax
c0101c9c:	89 c2                	mov    %eax,%edx
c0101c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ca1:	01 d0                	add    %edx,%eax
c0101ca3:	8b 10                	mov    (%eax),%edx
c0101ca5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101ca8:	01 c2                	add    %eax,%edx
c0101caa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cad:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0101caf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101cb2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101cb5:	39 c2                	cmp    %eax,%edx
c0101cb7:	7d 4a                	jge    c0101d03 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c0101cb9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101cbc:	83 c0 01             	add    $0x1,%eax
c0101cbf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0101cc2:	eb 18                	jmp    c0101cdc <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0101cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cc7:	8b 40 14             	mov    0x14(%eax),%eax
c0101cca:	8d 50 01             	lea    0x1(%eax),%edx
c0101ccd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cd0:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0101cd3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101cd6:	83 c0 01             	add    $0x1,%eax
c0101cd9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0101cdc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101cdf:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0101ce2:	39 c2                	cmp    %eax,%edx
c0101ce4:	7d 1d                	jge    c0101d03 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0101ce6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101ce9:	89 c2                	mov    %eax,%edx
c0101ceb:	89 d0                	mov    %edx,%eax
c0101ced:	01 c0                	add    %eax,%eax
c0101cef:	01 d0                	add    %edx,%eax
c0101cf1:	c1 e0 02             	shl    $0x2,%eax
c0101cf4:	89 c2                	mov    %eax,%edx
c0101cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101cf9:	01 d0                	add    %edx,%eax
c0101cfb:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101cff:	3c a0                	cmp    $0xa0,%al
c0101d01:	74 c1                	je     c0101cc4 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0101d03:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101d08:	c9                   	leave  
c0101d09:	c3                   	ret    

c0101d0a <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0101d0a:	55                   	push   %ebp
c0101d0b:	89 e5                	mov    %esp,%ebp
c0101d0d:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0101d10:	c7 04 24 6e b5 10 c0 	movl   $0xc010b56e,(%esp)
c0101d17:	e8 ba fa ff ff       	call   c01017d6 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0101d1c:	c7 44 24 04 2a 00 10 	movl   $0xc010002a,0x4(%esp)
c0101d23:	c0 
c0101d24:	c7 04 24 87 b5 10 c0 	movl   $0xc010b587,(%esp)
c0101d2b:	e8 a6 fa ff ff       	call   c01017d6 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c0101d30:	c7 44 24 04 46 b2 10 	movl   $0xc010b246,0x4(%esp)
c0101d37:	c0 
c0101d38:	c7 04 24 9f b5 10 c0 	movl   $0xc010b59f,(%esp)
c0101d3f:	e8 92 fa ff ff       	call   c01017d6 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0101d44:	c7 44 24 04 90 8a 12 	movl   $0xc0128a90,0x4(%esp)
c0101d4b:	c0 
c0101d4c:	c7 04 24 b7 b5 10 c0 	movl   $0xc010b5b7,(%esp)
c0101d53:	e8 7e fa ff ff       	call   c01017d6 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0101d58:	c7 44 24 04 18 bc 12 	movl   $0xc012bc18,0x4(%esp)
c0101d5f:	c0 
c0101d60:	c7 04 24 cf b5 10 c0 	movl   $0xc010b5cf,(%esp)
c0101d67:	e8 6a fa ff ff       	call   c01017d6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c0101d6c:	b8 18 bc 12 c0       	mov    $0xc012bc18,%eax
c0101d71:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0101d77:	b8 2a 00 10 c0       	mov    $0xc010002a,%eax
c0101d7c:	29 c2                	sub    %eax,%edx
c0101d7e:	89 d0                	mov    %edx,%eax
c0101d80:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0101d86:	85 c0                	test   %eax,%eax
c0101d88:	0f 48 c2             	cmovs  %edx,%eax
c0101d8b:	c1 f8 0a             	sar    $0xa,%eax
c0101d8e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d92:	c7 04 24 e8 b5 10 c0 	movl   $0xc010b5e8,(%esp)
c0101d99:	e8 38 fa ff ff       	call   c01017d6 <cprintf>
}
c0101d9e:	c9                   	leave  
c0101d9f:	c3                   	ret    

c0101da0 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0101da0:	55                   	push   %ebp
c0101da1:	89 e5                	mov    %esp,%ebp
c0101da3:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0101da9:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0101dac:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101db0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101db3:	89 04 24             	mov    %eax,(%esp)
c0101db6:	e8 12 fc ff ff       	call   c01019cd <debuginfo_eip>
c0101dbb:	85 c0                	test   %eax,%eax
c0101dbd:	74 15                	je     c0101dd4 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0101dbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dc2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101dc6:	c7 04 24 12 b6 10 c0 	movl   $0xc010b612,(%esp)
c0101dcd:	e8 04 fa ff ff       	call   c01017d6 <cprintf>
c0101dd2:	eb 6d                	jmp    c0101e41 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0101dd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101ddb:	eb 1c                	jmp    c0101df9 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0101ddd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0101de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101de3:	01 d0                	add    %edx,%eax
c0101de5:	0f b6 00             	movzbl (%eax),%eax
c0101de8:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0101dee:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101df1:	01 ca                	add    %ecx,%edx
c0101df3:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0101df5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101df9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101dfc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0101dff:	7f dc                	jg     c0101ddd <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0101e01:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0101e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101e0a:	01 d0                	add    %edx,%eax
c0101e0c:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0101e0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0101e12:	8b 55 08             	mov    0x8(%ebp),%edx
c0101e15:	89 d1                	mov    %edx,%ecx
c0101e17:	29 c1                	sub    %eax,%ecx
c0101e19:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0101e1c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101e1f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0101e23:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0101e29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101e2d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101e31:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e35:	c7 04 24 2e b6 10 c0 	movl   $0xc010b62e,(%esp)
c0101e3c:	e8 95 f9 ff ff       	call   c01017d6 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c0101e41:	c9                   	leave  
c0101e42:	c3                   	ret    

c0101e43 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0101e43:	55                   	push   %ebp
c0101e44:	89 e5                	mov    %esp,%ebp
c0101e46:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0101e49:	8b 45 04             	mov    0x4(%ebp),%eax
c0101e4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0101e4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101e52:	c9                   	leave  
c0101e53:	c3                   	ret    

c0101e54 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0101e54:	55                   	push   %ebp
c0101e55:	89 e5                	mov    %esp,%ebp
c0101e57:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0101e5a:	89 e8                	mov    %ebp,%eax
c0101e5c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0101e5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0101e62:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101e65:	e8 d9 ff ff ff       	call   c0101e43 <read_eip>
c0101e6a:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0101e6d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101e74:	e9 88 00 00 00       	jmp    c0101f01 <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0101e79:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101e7c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101e83:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e87:	c7 04 24 40 b6 10 c0 	movl   $0xc010b640,(%esp)
c0101e8e:	e8 43 f9 ff ff       	call   c01017d6 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
c0101e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101e96:	83 c0 08             	add    $0x8,%eax
c0101e99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0101e9c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0101ea3:	eb 25                	jmp    c0101eca <print_stackframe+0x76>
            cprintf("0x%08x ", args[j]);
c0101ea5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101ea8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101eaf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101eb2:	01 d0                	add    %edx,%eax
c0101eb4:	8b 00                	mov    (%eax),%eax
c0101eb6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101eba:	c7 04 24 5c b6 10 c0 	movl   $0xc010b65c,(%esp)
c0101ec1:	e8 10 f9 ff ff       	call   c01017d6 <cprintf>

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
c0101ec6:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0101eca:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0101ece:	7e d5                	jle    c0101ea5 <print_stackframe+0x51>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
c0101ed0:	c7 04 24 64 b6 10 c0 	movl   $0xc010b664,(%esp)
c0101ed7:	e8 fa f8 ff ff       	call   c01017d6 <cprintf>
        print_debuginfo(eip - 1);
c0101edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101edf:	83 e8 01             	sub    $0x1,%eax
c0101ee2:	89 04 24             	mov    %eax,(%esp)
c0101ee5:	e8 b6 fe ff ff       	call   c0101da0 <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0101eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101eed:	83 c0 04             	add    $0x4,%eax
c0101ef0:	8b 00                	mov    (%eax),%eax
c0101ef2:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0101ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ef8:	8b 00                	mov    (%eax),%eax
c0101efa:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0101efd:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0101f01:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101f05:	74 0a                	je     c0101f11 <print_stackframe+0xbd>
c0101f07:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0101f0b:	0f 8e 68 ff ff ff    	jle    c0101e79 <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c0101f11:	c9                   	leave  
c0101f12:	c3                   	ret    

c0101f13 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0101f13:	55                   	push   %ebp
c0101f14:	89 e5                	mov    %esp,%ebp
c0101f16:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0101f19:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0101f20:	eb 0c                	jmp    c0101f2e <parse+0x1b>
            *buf ++ = '\0';
c0101f22:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f25:	8d 50 01             	lea    0x1(%eax),%edx
c0101f28:	89 55 08             	mov    %edx,0x8(%ebp)
c0101f2b:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0101f2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f31:	0f b6 00             	movzbl (%eax),%eax
c0101f34:	84 c0                	test   %al,%al
c0101f36:	74 1d                	je     c0101f55 <parse+0x42>
c0101f38:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f3b:	0f b6 00             	movzbl (%eax),%eax
c0101f3e:	0f be c0             	movsbl %al,%eax
c0101f41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101f45:	c7 04 24 e8 b6 10 c0 	movl   $0xc010b6e8,(%esp)
c0101f4c:	e8 ad 8f 00 00       	call   c010aefe <strchr>
c0101f51:	85 c0                	test   %eax,%eax
c0101f53:	75 cd                	jne    c0101f22 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0101f55:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f58:	0f b6 00             	movzbl (%eax),%eax
c0101f5b:	84 c0                	test   %al,%al
c0101f5d:	75 02                	jne    c0101f61 <parse+0x4e>
            break;
c0101f5f:	eb 67                	jmp    c0101fc8 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0101f61:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0101f65:	75 14                	jne    c0101f7b <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0101f67:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0101f6e:	00 
c0101f6f:	c7 04 24 ed b6 10 c0 	movl   $0xc010b6ed,(%esp)
c0101f76:	e8 5b f8 ff ff       	call   c01017d6 <cprintf>
        }
        argv[argc ++] = buf;
c0101f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101f7e:	8d 50 01             	lea    0x1(%eax),%edx
c0101f81:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0101f84:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101f8b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f8e:	01 c2                	add    %eax,%edx
c0101f90:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f93:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0101f95:	eb 04                	jmp    c0101f9b <parse+0x88>
            buf ++;
c0101f97:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0101f9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f9e:	0f b6 00             	movzbl (%eax),%eax
c0101fa1:	84 c0                	test   %al,%al
c0101fa3:	74 1d                	je     c0101fc2 <parse+0xaf>
c0101fa5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fa8:	0f b6 00             	movzbl (%eax),%eax
c0101fab:	0f be c0             	movsbl %al,%eax
c0101fae:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101fb2:	c7 04 24 e8 b6 10 c0 	movl   $0xc010b6e8,(%esp)
c0101fb9:	e8 40 8f 00 00       	call   c010aefe <strchr>
c0101fbe:	85 c0                	test   %eax,%eax
c0101fc0:	74 d5                	je     c0101f97 <parse+0x84>
            buf ++;
        }
    }
c0101fc2:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0101fc3:	e9 66 ff ff ff       	jmp    c0101f2e <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0101fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101fcb:	c9                   	leave  
c0101fcc:	c3                   	ret    

c0101fcd <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0101fcd:	55                   	push   %ebp
c0101fce:	89 e5                	mov    %esp,%ebp
c0101fd0:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0101fd3:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0101fd6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101fda:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fdd:	89 04 24             	mov    %eax,(%esp)
c0101fe0:	e8 2e ff ff ff       	call   c0101f13 <parse>
c0101fe5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0101fe8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0101fec:	75 0a                	jne    c0101ff8 <runcmd+0x2b>
        return 0;
c0101fee:	b8 00 00 00 00       	mov    $0x0,%eax
c0101ff3:	e9 85 00 00 00       	jmp    c010207d <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0101ff8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101fff:	eb 5c                	jmp    c010205d <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0102001:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0102004:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102007:	89 d0                	mov    %edx,%eax
c0102009:	01 c0                	add    %eax,%eax
c010200b:	01 d0                	add    %edx,%eax
c010200d:	c1 e0 02             	shl    $0x2,%eax
c0102010:	05 20 80 12 c0       	add    $0xc0128020,%eax
c0102015:	8b 00                	mov    (%eax),%eax
c0102017:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010201b:	89 04 24             	mov    %eax,(%esp)
c010201e:	e8 3c 8e 00 00       	call   c010ae5f <strcmp>
c0102023:	85 c0                	test   %eax,%eax
c0102025:	75 32                	jne    c0102059 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0102027:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010202a:	89 d0                	mov    %edx,%eax
c010202c:	01 c0                	add    %eax,%eax
c010202e:	01 d0                	add    %edx,%eax
c0102030:	c1 e0 02             	shl    $0x2,%eax
c0102033:	05 20 80 12 c0       	add    $0xc0128020,%eax
c0102038:	8b 40 08             	mov    0x8(%eax),%eax
c010203b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010203e:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0102041:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102044:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102048:	8d 55 b0             	lea    -0x50(%ebp),%edx
c010204b:	83 c2 04             	add    $0x4,%edx
c010204e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102052:	89 0c 24             	mov    %ecx,(%esp)
c0102055:	ff d0                	call   *%eax
c0102057:	eb 24                	jmp    c010207d <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0102059:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010205d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102060:	83 f8 02             	cmp    $0x2,%eax
c0102063:	76 9c                	jbe    c0102001 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0102065:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102068:	89 44 24 04          	mov    %eax,0x4(%esp)
c010206c:	c7 04 24 0b b7 10 c0 	movl   $0xc010b70b,(%esp)
c0102073:	e8 5e f7 ff ff       	call   c01017d6 <cprintf>
    return 0;
c0102078:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010207d:	c9                   	leave  
c010207e:	c3                   	ret    

c010207f <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c010207f:	55                   	push   %ebp
c0102080:	89 e5                	mov    %esp,%ebp
c0102082:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0102085:	c7 04 24 24 b7 10 c0 	movl   $0xc010b724,(%esp)
c010208c:	e8 45 f7 ff ff       	call   c01017d6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0102091:	c7 04 24 4c b7 10 c0 	movl   $0xc010b74c,(%esp)
c0102098:	e8 39 f7 ff ff       	call   c01017d6 <cprintf>

    if (tf != NULL) {
c010209d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01020a1:	74 0b                	je     c01020ae <kmonitor+0x2f>
        print_trapframe(tf);
c01020a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01020a6:	89 04 24             	mov    %eax,(%esp)
c01020a9:	e8 4c 16 00 00       	call   c01036fa <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c01020ae:	c7 04 24 71 b7 10 c0 	movl   $0xc010b771,(%esp)
c01020b5:	e8 13 f6 ff ff       	call   c01016cd <readline>
c01020ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01020bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01020c1:	74 18                	je     c01020db <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c01020c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01020c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01020ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01020cd:	89 04 24             	mov    %eax,(%esp)
c01020d0:	e8 f8 fe ff ff       	call   c0101fcd <runcmd>
c01020d5:	85 c0                	test   %eax,%eax
c01020d7:	79 02                	jns    c01020db <kmonitor+0x5c>
                break;
c01020d9:	eb 02                	jmp    c01020dd <kmonitor+0x5e>
            }
        }
    }
c01020db:	eb d1                	jmp    c01020ae <kmonitor+0x2f>
}
c01020dd:	c9                   	leave  
c01020de:	c3                   	ret    

c01020df <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c01020df:	55                   	push   %ebp
c01020e0:	89 e5                	mov    %esp,%ebp
c01020e2:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c01020e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01020ec:	eb 3f                	jmp    c010212d <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c01020ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01020f1:	89 d0                	mov    %edx,%eax
c01020f3:	01 c0                	add    %eax,%eax
c01020f5:	01 d0                	add    %edx,%eax
c01020f7:	c1 e0 02             	shl    $0x2,%eax
c01020fa:	05 20 80 12 c0       	add    $0xc0128020,%eax
c01020ff:	8b 48 04             	mov    0x4(%eax),%ecx
c0102102:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102105:	89 d0                	mov    %edx,%eax
c0102107:	01 c0                	add    %eax,%eax
c0102109:	01 d0                	add    %edx,%eax
c010210b:	c1 e0 02             	shl    $0x2,%eax
c010210e:	05 20 80 12 c0       	add    $0xc0128020,%eax
c0102113:	8b 00                	mov    (%eax),%eax
c0102115:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0102119:	89 44 24 04          	mov    %eax,0x4(%esp)
c010211d:	c7 04 24 75 b7 10 c0 	movl   $0xc010b775,(%esp)
c0102124:	e8 ad f6 ff ff       	call   c01017d6 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0102129:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010212d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102130:	83 f8 02             	cmp    $0x2,%eax
c0102133:	76 b9                	jbe    c01020ee <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0102135:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010213a:	c9                   	leave  
c010213b:	c3                   	ret    

c010213c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c010213c:	55                   	push   %ebp
c010213d:	89 e5                	mov    %esp,%ebp
c010213f:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0102142:	e8 c3 fb ff ff       	call   c0101d0a <print_kerninfo>
    return 0;
c0102147:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010214c:	c9                   	leave  
c010214d:	c3                   	ret    

c010214e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c010214e:	55                   	push   %ebp
c010214f:	89 e5                	mov    %esp,%ebp
c0102151:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0102154:	e8 fb fc ff ff       	call   c0101e54 <print_stackframe>
    return 0;
c0102159:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010215e:	c9                   	leave  
c010215f:	c3                   	ret    

c0102160 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0102160:	55                   	push   %ebp
c0102161:	89 e5                	mov    %esp,%ebp
c0102163:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0102166:	a1 c0 8e 12 c0       	mov    0xc0128ec0,%eax
c010216b:	85 c0                	test   %eax,%eax
c010216d:	74 02                	je     c0102171 <__panic+0x11>
        goto panic_dead;
c010216f:	eb 48                	jmp    c01021b9 <__panic+0x59>
    }
    is_panic = 1;
c0102171:	c7 05 c0 8e 12 c0 01 	movl   $0x1,0xc0128ec0
c0102178:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c010217b:	8d 45 14             	lea    0x14(%ebp),%eax
c010217e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0102181:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102184:	89 44 24 08          	mov    %eax,0x8(%esp)
c0102188:	8b 45 08             	mov    0x8(%ebp),%eax
c010218b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010218f:	c7 04 24 7e b7 10 c0 	movl   $0xc010b77e,(%esp)
c0102196:	e8 3b f6 ff ff       	call   c01017d6 <cprintf>
    vcprintf(fmt, ap);
c010219b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010219e:	89 44 24 04          	mov    %eax,0x4(%esp)
c01021a2:	8b 45 10             	mov    0x10(%ebp),%eax
c01021a5:	89 04 24             	mov    %eax,(%esp)
c01021a8:	e8 f6 f5 ff ff       	call   c01017a3 <vcprintf>
    cprintf("\n");
c01021ad:	c7 04 24 9a b7 10 c0 	movl   $0xc010b79a,(%esp)
c01021b4:	e8 1d f6 ff ff       	call   c01017d6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
c01021b9:	e8 fa 11 00 00       	call   c01033b8 <intr_disable>
    while (1) {
        kmonitor(NULL);
c01021be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01021c5:	e8 b5 fe ff ff       	call   c010207f <kmonitor>
    }
c01021ca:	eb f2                	jmp    c01021be <__panic+0x5e>

c01021cc <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c01021cc:	55                   	push   %ebp
c01021cd:	89 e5                	mov    %esp,%ebp
c01021cf:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c01021d2:	8d 45 14             	lea    0x14(%ebp),%eax
c01021d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c01021d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01021db:	89 44 24 08          	mov    %eax,0x8(%esp)
c01021df:	8b 45 08             	mov    0x8(%ebp),%eax
c01021e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01021e6:	c7 04 24 9c b7 10 c0 	movl   $0xc010b79c,(%esp)
c01021ed:	e8 e4 f5 ff ff       	call   c01017d6 <cprintf>
    vcprintf(fmt, ap);
c01021f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01021f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01021f9:	8b 45 10             	mov    0x10(%ebp),%eax
c01021fc:	89 04 24             	mov    %eax,(%esp)
c01021ff:	e8 9f f5 ff ff       	call   c01017a3 <vcprintf>
    cprintf("\n");
c0102204:	c7 04 24 9a b7 10 c0 	movl   $0xc010b79a,(%esp)
c010220b:	e8 c6 f5 ff ff       	call   c01017d6 <cprintf>
    va_end(ap);
}
c0102210:	c9                   	leave  
c0102211:	c3                   	ret    

c0102212 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0102212:	55                   	push   %ebp
c0102213:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0102215:	a1 c0 8e 12 c0       	mov    0xc0128ec0,%eax
}
c010221a:	5d                   	pop    %ebp
c010221b:	c3                   	ret    

c010221c <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c010221c:	55                   	push   %ebp
c010221d:	89 e5                	mov    %esp,%ebp
c010221f:	83 ec 28             	sub    $0x28,%esp
c0102222:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0102228:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010222c:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102230:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102234:	ee                   	out    %al,(%dx)
c0102235:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c010223b:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c010223f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102243:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102247:	ee                   	out    %al,(%dx)
c0102248:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c010224e:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0102252:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102256:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010225a:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c010225b:	c7 05 14 bb 12 c0 00 	movl   $0x0,0xc012bb14
c0102262:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0102265:	c7 04 24 ba b7 10 c0 	movl   $0xc010b7ba,(%esp)
c010226c:	e8 65 f5 ff ff       	call   c01017d6 <cprintf>
    pic_enable(IRQ_TIMER);
c0102271:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0102278:	e8 99 11 00 00       	call   c0103416 <pic_enable>
}
c010227d:	c9                   	leave  
c010227e:	c3                   	ret    

c010227f <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c010227f:	55                   	push   %ebp
c0102280:	89 e5                	mov    %esp,%ebp
c0102282:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102285:	9c                   	pushf  
c0102286:	58                   	pop    %eax
c0102287:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010228a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010228d:	25 00 02 00 00       	and    $0x200,%eax
c0102292:	85 c0                	test   %eax,%eax
c0102294:	74 0c                	je     c01022a2 <__intr_save+0x23>
        intr_disable();
c0102296:	e8 1d 11 00 00       	call   c01033b8 <intr_disable>
        return 1;
c010229b:	b8 01 00 00 00       	mov    $0x1,%eax
c01022a0:	eb 05                	jmp    c01022a7 <__intr_save+0x28>
    }
    return 0;
c01022a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01022a7:	c9                   	leave  
c01022a8:	c3                   	ret    

c01022a9 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01022a9:	55                   	push   %ebp
c01022aa:	89 e5                	mov    %esp,%ebp
c01022ac:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01022af:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01022b3:	74 05                	je     c01022ba <__intr_restore+0x11>
        intr_enable();
c01022b5:	e8 f8 10 00 00       	call   c01033b2 <intr_enable>
    }
}
c01022ba:	c9                   	leave  
c01022bb:	c3                   	ret    

c01022bc <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c01022bc:	55                   	push   %ebp
c01022bd:	89 e5                	mov    %esp,%ebp
c01022bf:	83 ec 10             	sub    $0x10,%esp
c01022c2:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01022c8:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01022cc:	89 c2                	mov    %eax,%edx
c01022ce:	ec                   	in     (%dx),%al
c01022cf:	88 45 fd             	mov    %al,-0x3(%ebp)
c01022d2:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c01022d8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01022dc:	89 c2                	mov    %eax,%edx
c01022de:	ec                   	in     (%dx),%al
c01022df:	88 45 f9             	mov    %al,-0x7(%ebp)
c01022e2:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c01022e8:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01022ec:	89 c2                	mov    %eax,%edx
c01022ee:	ec                   	in     (%dx),%al
c01022ef:	88 45 f5             	mov    %al,-0xb(%ebp)
c01022f2:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c01022f8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01022fc:	89 c2                	mov    %eax,%edx
c01022fe:	ec                   	in     (%dx),%al
c01022ff:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0102302:	c9                   	leave  
c0102303:	c3                   	ret    

c0102304 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0102304:	55                   	push   %ebp
c0102305:	89 e5                	mov    %esp,%ebp
c0102307:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c010230a:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0102311:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102314:	0f b7 00             	movzwl (%eax),%eax
c0102317:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c010231b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010231e:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0102323:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102326:	0f b7 00             	movzwl (%eax),%eax
c0102329:	66 3d 5a a5          	cmp    $0xa55a,%ax
c010232d:	74 12                	je     c0102341 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c010232f:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0102336:	66 c7 05 e6 8e 12 c0 	movw   $0x3b4,0xc0128ee6
c010233d:	b4 03 
c010233f:	eb 13                	jmp    c0102354 <cga_init+0x50>
    } else {
        *cp = was;
c0102341:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102344:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102348:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c010234b:	66 c7 05 e6 8e 12 c0 	movw   $0x3d4,0xc0128ee6
c0102352:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0102354:	0f b7 05 e6 8e 12 c0 	movzwl 0xc0128ee6,%eax
c010235b:	0f b7 c0             	movzwl %ax,%eax
c010235e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0102362:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102366:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010236a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010236e:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c010236f:	0f b7 05 e6 8e 12 c0 	movzwl 0xc0128ee6,%eax
c0102376:	83 c0 01             	add    $0x1,%eax
c0102379:	0f b7 c0             	movzwl %ax,%eax
c010237c:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102380:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0102384:	89 c2                	mov    %eax,%edx
c0102386:	ec                   	in     (%dx),%al
c0102387:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c010238a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010238e:	0f b6 c0             	movzbl %al,%eax
c0102391:	c1 e0 08             	shl    $0x8,%eax
c0102394:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0102397:	0f b7 05 e6 8e 12 c0 	movzwl 0xc0128ee6,%eax
c010239e:	0f b7 c0             	movzwl %ax,%eax
c01023a1:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01023a5:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01023a9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01023ad:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01023b1:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c01023b2:	0f b7 05 e6 8e 12 c0 	movzwl 0xc0128ee6,%eax
c01023b9:	83 c0 01             	add    $0x1,%eax
c01023bc:	0f b7 c0             	movzwl %ax,%eax
c01023bf:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01023c3:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c01023c7:	89 c2                	mov    %eax,%edx
c01023c9:	ec                   	in     (%dx),%al
c01023ca:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c01023cd:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01023d1:	0f b6 c0             	movzbl %al,%eax
c01023d4:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c01023d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01023da:	a3 e0 8e 12 c0       	mov    %eax,0xc0128ee0
    crt_pos = pos;
c01023df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01023e2:	66 a3 e4 8e 12 c0    	mov    %ax,0xc0128ee4
}
c01023e8:	c9                   	leave  
c01023e9:	c3                   	ret    

c01023ea <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c01023ea:	55                   	push   %ebp
c01023eb:	89 e5                	mov    %esp,%ebp
c01023ed:	83 ec 48             	sub    $0x48,%esp
c01023f0:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c01023f6:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01023fa:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01023fe:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102402:	ee                   	out    %al,(%dx)
c0102403:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0102409:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c010240d:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102411:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102415:	ee                   	out    %al,(%dx)
c0102416:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c010241c:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0102420:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102424:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102428:	ee                   	out    %al,(%dx)
c0102429:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c010242f:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0102433:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102437:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010243b:	ee                   	out    %al,(%dx)
c010243c:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0102442:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0102446:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010244a:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010244e:	ee                   	out    %al,(%dx)
c010244f:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0102455:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0102459:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010245d:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102461:	ee                   	out    %al,(%dx)
c0102462:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0102468:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c010246c:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102470:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0102474:	ee                   	out    %al,(%dx)
c0102475:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010247b:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c010247f:	89 c2                	mov    %eax,%edx
c0102481:	ec                   	in     (%dx),%al
c0102482:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0102485:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0102489:	3c ff                	cmp    $0xff,%al
c010248b:	0f 95 c0             	setne  %al
c010248e:	0f b6 c0             	movzbl %al,%eax
c0102491:	a3 e8 8e 12 c0       	mov    %eax,0xc0128ee8
c0102496:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010249c:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c01024a0:	89 c2                	mov    %eax,%edx
c01024a2:	ec                   	in     (%dx),%al
c01024a3:	88 45 d5             	mov    %al,-0x2b(%ebp)
c01024a6:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c01024ac:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c01024b0:	89 c2                	mov    %eax,%edx
c01024b2:	ec                   	in     (%dx),%al
c01024b3:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c01024b6:	a1 e8 8e 12 c0       	mov    0xc0128ee8,%eax
c01024bb:	85 c0                	test   %eax,%eax
c01024bd:	74 0c                	je     c01024cb <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c01024bf:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01024c6:	e8 4b 0f 00 00       	call   c0103416 <pic_enable>
    }
}
c01024cb:	c9                   	leave  
c01024cc:	c3                   	ret    

c01024cd <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01024cd:	55                   	push   %ebp
c01024ce:	89 e5                	mov    %esp,%ebp
c01024d0:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01024d3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01024da:	eb 09                	jmp    c01024e5 <lpt_putc_sub+0x18>
        delay();
c01024dc:	e8 db fd ff ff       	call   c01022bc <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01024e1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01024e5:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01024eb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01024ef:	89 c2                	mov    %eax,%edx
c01024f1:	ec                   	in     (%dx),%al
c01024f2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01024f5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01024f9:	84 c0                	test   %al,%al
c01024fb:	78 09                	js     c0102506 <lpt_putc_sub+0x39>
c01024fd:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0102504:	7e d6                	jle    c01024dc <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0102506:	8b 45 08             	mov    0x8(%ebp),%eax
c0102509:	0f b6 c0             	movzbl %al,%eax
c010250c:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0102512:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102515:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102519:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010251d:	ee                   	out    %al,(%dx)
c010251e:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0102524:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0102528:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010252c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102530:	ee                   	out    %al,(%dx)
c0102531:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c0102537:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c010253b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010253f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102543:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0102544:	c9                   	leave  
c0102545:	c3                   	ret    

c0102546 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0102546:	55                   	push   %ebp
c0102547:	89 e5                	mov    %esp,%ebp
c0102549:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010254c:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0102550:	74 0d                	je     c010255f <lpt_putc+0x19>
        lpt_putc_sub(c);
c0102552:	8b 45 08             	mov    0x8(%ebp),%eax
c0102555:	89 04 24             	mov    %eax,(%esp)
c0102558:	e8 70 ff ff ff       	call   c01024cd <lpt_putc_sub>
c010255d:	eb 24                	jmp    c0102583 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c010255f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0102566:	e8 62 ff ff ff       	call   c01024cd <lpt_putc_sub>
        lpt_putc_sub(' ');
c010256b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0102572:	e8 56 ff ff ff       	call   c01024cd <lpt_putc_sub>
        lpt_putc_sub('\b');
c0102577:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010257e:	e8 4a ff ff ff       	call   c01024cd <lpt_putc_sub>
    }
}
c0102583:	c9                   	leave  
c0102584:	c3                   	ret    

c0102585 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0102585:	55                   	push   %ebp
c0102586:	89 e5                	mov    %esp,%ebp
c0102588:	53                   	push   %ebx
c0102589:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c010258c:	8b 45 08             	mov    0x8(%ebp),%eax
c010258f:	b0 00                	mov    $0x0,%al
c0102591:	85 c0                	test   %eax,%eax
c0102593:	75 07                	jne    c010259c <cga_putc+0x17>
        c |= 0x0700;
c0102595:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010259c:	8b 45 08             	mov    0x8(%ebp),%eax
c010259f:	0f b6 c0             	movzbl %al,%eax
c01025a2:	83 f8 0a             	cmp    $0xa,%eax
c01025a5:	74 4c                	je     c01025f3 <cga_putc+0x6e>
c01025a7:	83 f8 0d             	cmp    $0xd,%eax
c01025aa:	74 57                	je     c0102603 <cga_putc+0x7e>
c01025ac:	83 f8 08             	cmp    $0x8,%eax
c01025af:	0f 85 88 00 00 00    	jne    c010263d <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c01025b5:	0f b7 05 e4 8e 12 c0 	movzwl 0xc0128ee4,%eax
c01025bc:	66 85 c0             	test   %ax,%ax
c01025bf:	74 30                	je     c01025f1 <cga_putc+0x6c>
            crt_pos --;
c01025c1:	0f b7 05 e4 8e 12 c0 	movzwl 0xc0128ee4,%eax
c01025c8:	83 e8 01             	sub    $0x1,%eax
c01025cb:	66 a3 e4 8e 12 c0    	mov    %ax,0xc0128ee4
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01025d1:	a1 e0 8e 12 c0       	mov    0xc0128ee0,%eax
c01025d6:	0f b7 15 e4 8e 12 c0 	movzwl 0xc0128ee4,%edx
c01025dd:	0f b7 d2             	movzwl %dx,%edx
c01025e0:	01 d2                	add    %edx,%edx
c01025e2:	01 c2                	add    %eax,%edx
c01025e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01025e7:	b0 00                	mov    $0x0,%al
c01025e9:	83 c8 20             	or     $0x20,%eax
c01025ec:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01025ef:	eb 72                	jmp    c0102663 <cga_putc+0xde>
c01025f1:	eb 70                	jmp    c0102663 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c01025f3:	0f b7 05 e4 8e 12 c0 	movzwl 0xc0128ee4,%eax
c01025fa:	83 c0 50             	add    $0x50,%eax
c01025fd:	66 a3 e4 8e 12 c0    	mov    %ax,0xc0128ee4
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0102603:	0f b7 1d e4 8e 12 c0 	movzwl 0xc0128ee4,%ebx
c010260a:	0f b7 0d e4 8e 12 c0 	movzwl 0xc0128ee4,%ecx
c0102611:	0f b7 c1             	movzwl %cx,%eax
c0102614:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c010261a:	c1 e8 10             	shr    $0x10,%eax
c010261d:	89 c2                	mov    %eax,%edx
c010261f:	66 c1 ea 06          	shr    $0x6,%dx
c0102623:	89 d0                	mov    %edx,%eax
c0102625:	c1 e0 02             	shl    $0x2,%eax
c0102628:	01 d0                	add    %edx,%eax
c010262a:	c1 e0 04             	shl    $0x4,%eax
c010262d:	29 c1                	sub    %eax,%ecx
c010262f:	89 ca                	mov    %ecx,%edx
c0102631:	89 d8                	mov    %ebx,%eax
c0102633:	29 d0                	sub    %edx,%eax
c0102635:	66 a3 e4 8e 12 c0    	mov    %ax,0xc0128ee4
        break;
c010263b:	eb 26                	jmp    c0102663 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c010263d:	8b 0d e0 8e 12 c0    	mov    0xc0128ee0,%ecx
c0102643:	0f b7 05 e4 8e 12 c0 	movzwl 0xc0128ee4,%eax
c010264a:	8d 50 01             	lea    0x1(%eax),%edx
c010264d:	66 89 15 e4 8e 12 c0 	mov    %dx,0xc0128ee4
c0102654:	0f b7 c0             	movzwl %ax,%eax
c0102657:	01 c0                	add    %eax,%eax
c0102659:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c010265c:	8b 45 08             	mov    0x8(%ebp),%eax
c010265f:	66 89 02             	mov    %ax,(%edx)
        break;
c0102662:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0102663:	0f b7 05 e4 8e 12 c0 	movzwl 0xc0128ee4,%eax
c010266a:	66 3d cf 07          	cmp    $0x7cf,%ax
c010266e:	76 5b                	jbe    c01026cb <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0102670:	a1 e0 8e 12 c0       	mov    0xc0128ee0,%eax
c0102675:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c010267b:	a1 e0 8e 12 c0       	mov    0xc0128ee0,%eax
c0102680:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0102687:	00 
c0102688:	89 54 24 04          	mov    %edx,0x4(%esp)
c010268c:	89 04 24             	mov    %eax,(%esp)
c010268f:	e8 68 8a 00 00       	call   c010b0fc <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0102694:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010269b:	eb 15                	jmp    c01026b2 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c010269d:	a1 e0 8e 12 c0       	mov    0xc0128ee0,%eax
c01026a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01026a5:	01 d2                	add    %edx,%edx
c01026a7:	01 d0                	add    %edx,%eax
c01026a9:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01026ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01026b2:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c01026b9:	7e e2                	jle    c010269d <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c01026bb:	0f b7 05 e4 8e 12 c0 	movzwl 0xc0128ee4,%eax
c01026c2:	83 e8 50             	sub    $0x50,%eax
c01026c5:	66 a3 e4 8e 12 c0    	mov    %ax,0xc0128ee4
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01026cb:	0f b7 05 e6 8e 12 c0 	movzwl 0xc0128ee6,%eax
c01026d2:	0f b7 c0             	movzwl %ax,%eax
c01026d5:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01026d9:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c01026dd:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01026e1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01026e5:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c01026e6:	0f b7 05 e4 8e 12 c0 	movzwl 0xc0128ee4,%eax
c01026ed:	66 c1 e8 08          	shr    $0x8,%ax
c01026f1:	0f b6 c0             	movzbl %al,%eax
c01026f4:	0f b7 15 e6 8e 12 c0 	movzwl 0xc0128ee6,%edx
c01026fb:	83 c2 01             	add    $0x1,%edx
c01026fe:	0f b7 d2             	movzwl %dx,%edx
c0102701:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0102705:	88 45 ed             	mov    %al,-0x13(%ebp)
c0102708:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010270c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102710:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0102711:	0f b7 05 e6 8e 12 c0 	movzwl 0xc0128ee6,%eax
c0102718:	0f b7 c0             	movzwl %ax,%eax
c010271b:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c010271f:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c0102723:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102727:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010272b:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c010272c:	0f b7 05 e4 8e 12 c0 	movzwl 0xc0128ee4,%eax
c0102733:	0f b6 c0             	movzbl %al,%eax
c0102736:	0f b7 15 e6 8e 12 c0 	movzwl 0xc0128ee6,%edx
c010273d:	83 c2 01             	add    $0x1,%edx
c0102740:	0f b7 d2             	movzwl %dx,%edx
c0102743:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0102747:	88 45 e5             	mov    %al,-0x1b(%ebp)
c010274a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010274e:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102752:	ee                   	out    %al,(%dx)
}
c0102753:	83 c4 34             	add    $0x34,%esp
c0102756:	5b                   	pop    %ebx
c0102757:	5d                   	pop    %ebp
c0102758:	c3                   	ret    

c0102759 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0102759:	55                   	push   %ebp
c010275a:	89 e5                	mov    %esp,%ebp
c010275c:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010275f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102766:	eb 09                	jmp    c0102771 <serial_putc_sub+0x18>
        delay();
c0102768:	e8 4f fb ff ff       	call   c01022bc <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010276d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102771:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102777:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010277b:	89 c2                	mov    %eax,%edx
c010277d:	ec                   	in     (%dx),%al
c010277e:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0102781:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102785:	0f b6 c0             	movzbl %al,%eax
c0102788:	83 e0 20             	and    $0x20,%eax
c010278b:	85 c0                	test   %eax,%eax
c010278d:	75 09                	jne    c0102798 <serial_putc_sub+0x3f>
c010278f:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0102796:	7e d0                	jle    c0102768 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0102798:	8b 45 08             	mov    0x8(%ebp),%eax
c010279b:	0f b6 c0             	movzbl %al,%eax
c010279e:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01027a4:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01027a7:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01027ab:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01027af:	ee                   	out    %al,(%dx)
}
c01027b0:	c9                   	leave  
c01027b1:	c3                   	ret    

c01027b2 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c01027b2:	55                   	push   %ebp
c01027b3:	89 e5                	mov    %esp,%ebp
c01027b5:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01027b8:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01027bc:	74 0d                	je     c01027cb <serial_putc+0x19>
        serial_putc_sub(c);
c01027be:	8b 45 08             	mov    0x8(%ebp),%eax
c01027c1:	89 04 24             	mov    %eax,(%esp)
c01027c4:	e8 90 ff ff ff       	call   c0102759 <serial_putc_sub>
c01027c9:	eb 24                	jmp    c01027ef <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c01027cb:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01027d2:	e8 82 ff ff ff       	call   c0102759 <serial_putc_sub>
        serial_putc_sub(' ');
c01027d7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01027de:	e8 76 ff ff ff       	call   c0102759 <serial_putc_sub>
        serial_putc_sub('\b');
c01027e3:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01027ea:	e8 6a ff ff ff       	call   c0102759 <serial_putc_sub>
    }
}
c01027ef:	c9                   	leave  
c01027f0:	c3                   	ret    

c01027f1 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c01027f1:	55                   	push   %ebp
c01027f2:	89 e5                	mov    %esp,%ebp
c01027f4:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c01027f7:	eb 33                	jmp    c010282c <cons_intr+0x3b>
        if (c != 0) {
c01027f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01027fd:	74 2d                	je     c010282c <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01027ff:	a1 04 91 12 c0       	mov    0xc0129104,%eax
c0102804:	8d 50 01             	lea    0x1(%eax),%edx
c0102807:	89 15 04 91 12 c0    	mov    %edx,0xc0129104
c010280d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102810:	88 90 00 8f 12 c0    	mov    %dl,-0x3fed7100(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0102816:	a1 04 91 12 c0       	mov    0xc0129104,%eax
c010281b:	3d 00 02 00 00       	cmp    $0x200,%eax
c0102820:	75 0a                	jne    c010282c <cons_intr+0x3b>
                cons.wpos = 0;
c0102822:	c7 05 04 91 12 c0 00 	movl   $0x0,0xc0129104
c0102829:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c010282c:	8b 45 08             	mov    0x8(%ebp),%eax
c010282f:	ff d0                	call   *%eax
c0102831:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102834:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0102838:	75 bf                	jne    c01027f9 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c010283a:	c9                   	leave  
c010283b:	c3                   	ret    

c010283c <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c010283c:	55                   	push   %ebp
c010283d:	89 e5                	mov    %esp,%ebp
c010283f:	83 ec 10             	sub    $0x10,%esp
c0102842:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102848:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010284c:	89 c2                	mov    %eax,%edx
c010284e:	ec                   	in     (%dx),%al
c010284f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0102852:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0102856:	0f b6 c0             	movzbl %al,%eax
c0102859:	83 e0 01             	and    $0x1,%eax
c010285c:	85 c0                	test   %eax,%eax
c010285e:	75 07                	jne    c0102867 <serial_proc_data+0x2b>
        return -1;
c0102860:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0102865:	eb 2a                	jmp    c0102891 <serial_proc_data+0x55>
c0102867:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010286d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102871:	89 c2                	mov    %eax,%edx
c0102873:	ec                   	in     (%dx),%al
c0102874:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0102877:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c010287b:	0f b6 c0             	movzbl %al,%eax
c010287e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0102881:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0102885:	75 07                	jne    c010288e <serial_proc_data+0x52>
        c = '\b';
c0102887:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c010288e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0102891:	c9                   	leave  
c0102892:	c3                   	ret    

c0102893 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0102893:	55                   	push   %ebp
c0102894:	89 e5                	mov    %esp,%ebp
c0102896:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0102899:	a1 e8 8e 12 c0       	mov    0xc0128ee8,%eax
c010289e:	85 c0                	test   %eax,%eax
c01028a0:	74 0c                	je     c01028ae <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c01028a2:	c7 04 24 3c 28 10 c0 	movl   $0xc010283c,(%esp)
c01028a9:	e8 43 ff ff ff       	call   c01027f1 <cons_intr>
    }
}
c01028ae:	c9                   	leave  
c01028af:	c3                   	ret    

c01028b0 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c01028b0:	55                   	push   %ebp
c01028b1:	89 e5                	mov    %esp,%ebp
c01028b3:	83 ec 38             	sub    $0x38,%esp
c01028b6:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01028bc:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01028c0:	89 c2                	mov    %eax,%edx
c01028c2:	ec                   	in     (%dx),%al
c01028c3:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c01028c6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01028ca:	0f b6 c0             	movzbl %al,%eax
c01028cd:	83 e0 01             	and    $0x1,%eax
c01028d0:	85 c0                	test   %eax,%eax
c01028d2:	75 0a                	jne    c01028de <kbd_proc_data+0x2e>
        return -1;
c01028d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01028d9:	e9 59 01 00 00       	jmp    c0102a37 <kbd_proc_data+0x187>
c01028de:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01028e4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01028e8:	89 c2                	mov    %eax,%edx
c01028ea:	ec                   	in     (%dx),%al
c01028eb:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c01028ee:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c01028f2:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c01028f5:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c01028f9:	75 17                	jne    c0102912 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c01028fb:	a1 08 91 12 c0       	mov    0xc0129108,%eax
c0102900:	83 c8 40             	or     $0x40,%eax
c0102903:	a3 08 91 12 c0       	mov    %eax,0xc0129108
        return 0;
c0102908:	b8 00 00 00 00       	mov    $0x0,%eax
c010290d:	e9 25 01 00 00       	jmp    c0102a37 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0102912:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0102916:	84 c0                	test   %al,%al
c0102918:	79 47                	jns    c0102961 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010291a:	a1 08 91 12 c0       	mov    0xc0129108,%eax
c010291f:	83 e0 40             	and    $0x40,%eax
c0102922:	85 c0                	test   %eax,%eax
c0102924:	75 09                	jne    c010292f <kbd_proc_data+0x7f>
c0102926:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010292a:	83 e0 7f             	and    $0x7f,%eax
c010292d:	eb 04                	jmp    c0102933 <kbd_proc_data+0x83>
c010292f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0102933:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0102936:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010293a:	0f b6 80 60 80 12 c0 	movzbl -0x3fed7fa0(%eax),%eax
c0102941:	83 c8 40             	or     $0x40,%eax
c0102944:	0f b6 c0             	movzbl %al,%eax
c0102947:	f7 d0                	not    %eax
c0102949:	89 c2                	mov    %eax,%edx
c010294b:	a1 08 91 12 c0       	mov    0xc0129108,%eax
c0102950:	21 d0                	and    %edx,%eax
c0102952:	a3 08 91 12 c0       	mov    %eax,0xc0129108
        return 0;
c0102957:	b8 00 00 00 00       	mov    $0x0,%eax
c010295c:	e9 d6 00 00 00       	jmp    c0102a37 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c0102961:	a1 08 91 12 c0       	mov    0xc0129108,%eax
c0102966:	83 e0 40             	and    $0x40,%eax
c0102969:	85 c0                	test   %eax,%eax
c010296b:	74 11                	je     c010297e <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c010296d:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0102971:	a1 08 91 12 c0       	mov    0xc0129108,%eax
c0102976:	83 e0 bf             	and    $0xffffffbf,%eax
c0102979:	a3 08 91 12 c0       	mov    %eax,0xc0129108
    }

    shift |= shiftcode[data];
c010297e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0102982:	0f b6 80 60 80 12 c0 	movzbl -0x3fed7fa0(%eax),%eax
c0102989:	0f b6 d0             	movzbl %al,%edx
c010298c:	a1 08 91 12 c0       	mov    0xc0129108,%eax
c0102991:	09 d0                	or     %edx,%eax
c0102993:	a3 08 91 12 c0       	mov    %eax,0xc0129108
    shift ^= togglecode[data];
c0102998:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010299c:	0f b6 80 60 81 12 c0 	movzbl -0x3fed7ea0(%eax),%eax
c01029a3:	0f b6 d0             	movzbl %al,%edx
c01029a6:	a1 08 91 12 c0       	mov    0xc0129108,%eax
c01029ab:	31 d0                	xor    %edx,%eax
c01029ad:	a3 08 91 12 c0       	mov    %eax,0xc0129108

    c = charcode[shift & (CTL | SHIFT)][data];
c01029b2:	a1 08 91 12 c0       	mov    0xc0129108,%eax
c01029b7:	83 e0 03             	and    $0x3,%eax
c01029ba:	8b 14 85 60 85 12 c0 	mov    -0x3fed7aa0(,%eax,4),%edx
c01029c1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01029c5:	01 d0                	add    %edx,%eax
c01029c7:	0f b6 00             	movzbl (%eax),%eax
c01029ca:	0f b6 c0             	movzbl %al,%eax
c01029cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01029d0:	a1 08 91 12 c0       	mov    0xc0129108,%eax
c01029d5:	83 e0 08             	and    $0x8,%eax
c01029d8:	85 c0                	test   %eax,%eax
c01029da:	74 22                	je     c01029fe <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c01029dc:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01029e0:	7e 0c                	jle    c01029ee <kbd_proc_data+0x13e>
c01029e2:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01029e6:	7f 06                	jg     c01029ee <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c01029e8:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01029ec:	eb 10                	jmp    c01029fe <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c01029ee:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01029f2:	7e 0a                	jle    c01029fe <kbd_proc_data+0x14e>
c01029f4:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01029f8:	7f 04                	jg     c01029fe <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c01029fa:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01029fe:	a1 08 91 12 c0       	mov    0xc0129108,%eax
c0102a03:	f7 d0                	not    %eax
c0102a05:	83 e0 06             	and    $0x6,%eax
c0102a08:	85 c0                	test   %eax,%eax
c0102a0a:	75 28                	jne    c0102a34 <kbd_proc_data+0x184>
c0102a0c:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0102a13:	75 1f                	jne    c0102a34 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0102a15:	c7 04 24 d5 b7 10 c0 	movl   $0xc010b7d5,(%esp)
c0102a1c:	e8 b5 ed ff ff       	call   c01017d6 <cprintf>
c0102a21:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0102a27:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102a2b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0102a2f:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c0102a33:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0102a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102a37:	c9                   	leave  
c0102a38:	c3                   	ret    

c0102a39 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0102a39:	55                   	push   %ebp
c0102a3a:	89 e5                	mov    %esp,%ebp
c0102a3c:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0102a3f:	c7 04 24 b0 28 10 c0 	movl   $0xc01028b0,(%esp)
c0102a46:	e8 a6 fd ff ff       	call   c01027f1 <cons_intr>
}
c0102a4b:	c9                   	leave  
c0102a4c:	c3                   	ret    

c0102a4d <kbd_init>:

static void
kbd_init(void) {
c0102a4d:	55                   	push   %ebp
c0102a4e:	89 e5                	mov    %esp,%ebp
c0102a50:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0102a53:	e8 e1 ff ff ff       	call   c0102a39 <kbd_intr>
    pic_enable(IRQ_KBD);
c0102a58:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102a5f:	e8 b2 09 00 00       	call   c0103416 <pic_enable>
}
c0102a64:	c9                   	leave  
c0102a65:	c3                   	ret    

c0102a66 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0102a66:	55                   	push   %ebp
c0102a67:	89 e5                	mov    %esp,%ebp
c0102a69:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0102a6c:	e8 93 f8 ff ff       	call   c0102304 <cga_init>
    serial_init();
c0102a71:	e8 74 f9 ff ff       	call   c01023ea <serial_init>
    kbd_init();
c0102a76:	e8 d2 ff ff ff       	call   c0102a4d <kbd_init>
    if (!serial_exists) {
c0102a7b:	a1 e8 8e 12 c0       	mov    0xc0128ee8,%eax
c0102a80:	85 c0                	test   %eax,%eax
c0102a82:	75 0c                	jne    c0102a90 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0102a84:	c7 04 24 e1 b7 10 c0 	movl   $0xc010b7e1,(%esp)
c0102a8b:	e8 46 ed ff ff       	call   c01017d6 <cprintf>
    }
}
c0102a90:	c9                   	leave  
c0102a91:	c3                   	ret    

c0102a92 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0102a92:	55                   	push   %ebp
c0102a93:	89 e5                	mov    %esp,%ebp
c0102a95:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102a98:	e8 e2 f7 ff ff       	call   c010227f <__intr_save>
c0102a9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0102aa0:	8b 45 08             	mov    0x8(%ebp),%eax
c0102aa3:	89 04 24             	mov    %eax,(%esp)
c0102aa6:	e8 9b fa ff ff       	call   c0102546 <lpt_putc>
        cga_putc(c);
c0102aab:	8b 45 08             	mov    0x8(%ebp),%eax
c0102aae:	89 04 24             	mov    %eax,(%esp)
c0102ab1:	e8 cf fa ff ff       	call   c0102585 <cga_putc>
        serial_putc(c);
c0102ab6:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ab9:	89 04 24             	mov    %eax,(%esp)
c0102abc:	e8 f1 fc ff ff       	call   c01027b2 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0102ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ac4:	89 04 24             	mov    %eax,(%esp)
c0102ac7:	e8 dd f7 ff ff       	call   c01022a9 <__intr_restore>
}
c0102acc:	c9                   	leave  
c0102acd:	c3                   	ret    

c0102ace <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0102ace:	55                   	push   %ebp
c0102acf:	89 e5                	mov    %esp,%ebp
c0102ad1:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0102ad4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102adb:	e8 9f f7 ff ff       	call   c010227f <__intr_save>
c0102ae0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0102ae3:	e8 ab fd ff ff       	call   c0102893 <serial_intr>
        kbd_intr();
c0102ae8:	e8 4c ff ff ff       	call   c0102a39 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0102aed:	8b 15 00 91 12 c0    	mov    0xc0129100,%edx
c0102af3:	a1 04 91 12 c0       	mov    0xc0129104,%eax
c0102af8:	39 c2                	cmp    %eax,%edx
c0102afa:	74 31                	je     c0102b2d <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0102afc:	a1 00 91 12 c0       	mov    0xc0129100,%eax
c0102b01:	8d 50 01             	lea    0x1(%eax),%edx
c0102b04:	89 15 00 91 12 c0    	mov    %edx,0xc0129100
c0102b0a:	0f b6 80 00 8f 12 c0 	movzbl -0x3fed7100(%eax),%eax
c0102b11:	0f b6 c0             	movzbl %al,%eax
c0102b14:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0102b17:	a1 00 91 12 c0       	mov    0xc0129100,%eax
c0102b1c:	3d 00 02 00 00       	cmp    $0x200,%eax
c0102b21:	75 0a                	jne    c0102b2d <cons_getc+0x5f>
                cons.rpos = 0;
c0102b23:	c7 05 00 91 12 c0 00 	movl   $0x0,0xc0129100
c0102b2a:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0102b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102b30:	89 04 24             	mov    %eax,(%esp)
c0102b33:	e8 71 f7 ff ff       	call   c01022a9 <__intr_restore>
    return c;
c0102b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102b3b:	c9                   	leave  
c0102b3c:	c3                   	ret    

c0102b3d <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0102b3d:	55                   	push   %ebp
c0102b3e:	89 e5                	mov    %esp,%ebp
c0102b40:	83 ec 14             	sub    $0x14,%esp
c0102b43:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b46:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0102b4a:	90                   	nop
c0102b4b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102b4f:	83 c0 07             	add    $0x7,%eax
c0102b52:	0f b7 c0             	movzwl %ax,%eax
c0102b55:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102b59:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0102b5d:	89 c2                	mov    %eax,%edx
c0102b5f:	ec                   	in     (%dx),%al
c0102b60:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0102b63:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102b67:	0f b6 c0             	movzbl %al,%eax
c0102b6a:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0102b6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102b70:	25 80 00 00 00       	and    $0x80,%eax
c0102b75:	85 c0                	test   %eax,%eax
c0102b77:	75 d2                	jne    c0102b4b <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0102b79:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102b7d:	74 11                	je     c0102b90 <ide_wait_ready+0x53>
c0102b7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102b82:	83 e0 21             	and    $0x21,%eax
c0102b85:	85 c0                	test   %eax,%eax
c0102b87:	74 07                	je     c0102b90 <ide_wait_ready+0x53>
        return -1;
c0102b89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0102b8e:	eb 05                	jmp    c0102b95 <ide_wait_ready+0x58>
    }
    return 0;
c0102b90:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102b95:	c9                   	leave  
c0102b96:	c3                   	ret    

c0102b97 <ide_init>:

void
ide_init(void) {
c0102b97:	55                   	push   %ebp
c0102b98:	89 e5                	mov    %esp,%ebp
c0102b9a:	57                   	push   %edi
c0102b9b:	53                   	push   %ebx
c0102b9c:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0102ba2:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0102ba8:	e9 d6 02 00 00       	jmp    c0102e83 <ide_init+0x2ec>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0102bad:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102bb1:	c1 e0 03             	shl    $0x3,%eax
c0102bb4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102bbb:	29 c2                	sub    %eax,%edx
c0102bbd:	8d 82 20 91 12 c0    	lea    -0x3fed6ee0(%edx),%eax
c0102bc3:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0102bc6:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102bca:	66 d1 e8             	shr    %ax
c0102bcd:	0f b7 c0             	movzwl %ax,%eax
c0102bd0:	0f b7 04 85 00 b8 10 	movzwl -0x3fef4800(,%eax,4),%eax
c0102bd7:	c0 
c0102bd8:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0102bdc:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102be0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102be7:	00 
c0102be8:	89 04 24             	mov    %eax,(%esp)
c0102beb:	e8 4d ff ff ff       	call   c0102b3d <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0102bf0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102bf4:	83 e0 01             	and    $0x1,%eax
c0102bf7:	c1 e0 04             	shl    $0x4,%eax
c0102bfa:	83 c8 e0             	or     $0xffffffe0,%eax
c0102bfd:	0f b6 c0             	movzbl %al,%eax
c0102c00:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102c04:	83 c2 06             	add    $0x6,%edx
c0102c07:	0f b7 d2             	movzwl %dx,%edx
c0102c0a:	66 89 55 d2          	mov    %dx,-0x2e(%ebp)
c0102c0e:	88 45 d1             	mov    %al,-0x2f(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102c11:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0102c15:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0102c19:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0102c1a:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102c1e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102c25:	00 
c0102c26:	89 04 24             	mov    %eax,(%esp)
c0102c29:	e8 0f ff ff ff       	call   c0102b3d <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0102c2e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102c32:	83 c0 07             	add    $0x7,%eax
c0102c35:	0f b7 c0             	movzwl %ax,%eax
c0102c38:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0102c3c:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c0102c40:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0102c44:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0102c48:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0102c49:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102c4d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102c54:	00 
c0102c55:	89 04 24             	mov    %eax,(%esp)
c0102c58:	e8 e0 fe ff ff       	call   c0102b3d <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0102c5d:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102c61:	83 c0 07             	add    $0x7,%eax
c0102c64:	0f b7 c0             	movzwl %ax,%eax
c0102c67:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102c6b:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0102c6f:	89 c2                	mov    %eax,%edx
c0102c71:	ec                   	in     (%dx),%al
c0102c72:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0102c75:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0102c79:	84 c0                	test   %al,%al
c0102c7b:	0f 84 f7 01 00 00    	je     c0102e78 <ide_init+0x2e1>
c0102c81:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102c85:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0102c8c:	00 
c0102c8d:	89 04 24             	mov    %eax,(%esp)
c0102c90:	e8 a8 fe ff ff       	call   c0102b3d <ide_wait_ready>
c0102c95:	85 c0                	test   %eax,%eax
c0102c97:	0f 85 db 01 00 00    	jne    c0102e78 <ide_init+0x2e1>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0102c9d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102ca1:	c1 e0 03             	shl    $0x3,%eax
c0102ca4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102cab:	29 c2                	sub    %eax,%edx
c0102cad:	8d 82 20 91 12 c0    	lea    -0x3fed6ee0(%edx),%eax
c0102cb3:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0102cb6:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102cba:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0102cbd:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0102cc3:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0102cc6:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0102ccd:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102cd0:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0102cd3:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102cd6:	89 cb                	mov    %ecx,%ebx
c0102cd8:	89 df                	mov    %ebx,%edi
c0102cda:	89 c1                	mov    %eax,%ecx
c0102cdc:	fc                   	cld    
c0102cdd:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0102cdf:	89 c8                	mov    %ecx,%eax
c0102ce1:	89 fb                	mov    %edi,%ebx
c0102ce3:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0102ce6:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0102ce9:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0102cef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0102cf2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102cf5:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0102cfb:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0102cfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d01:	25 00 00 00 04       	and    $0x4000000,%eax
c0102d06:	85 c0                	test   %eax,%eax
c0102d08:	74 0e                	je     c0102d18 <ide_init+0x181>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0102d0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102d0d:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0102d13:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102d16:	eb 09                	jmp    c0102d21 <ide_init+0x18a>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0102d18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102d1b:	8b 40 78             	mov    0x78(%eax),%eax
c0102d1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0102d21:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102d25:	c1 e0 03             	shl    $0x3,%eax
c0102d28:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102d2f:	29 c2                	sub    %eax,%edx
c0102d31:	81 c2 20 91 12 c0    	add    $0xc0129120,%edx
c0102d37:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d3a:	89 42 04             	mov    %eax,0x4(%edx)
        ide_devices[ideno].size = sectors;
c0102d3d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102d41:	c1 e0 03             	shl    $0x3,%eax
c0102d44:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102d4b:	29 c2                	sub    %eax,%edx
c0102d4d:	81 c2 20 91 12 c0    	add    $0xc0129120,%edx
c0102d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d56:	89 42 08             	mov    %eax,0x8(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0102d59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102d5c:	83 c0 62             	add    $0x62,%eax
c0102d5f:	0f b7 00             	movzwl (%eax),%eax
c0102d62:	0f b7 c0             	movzwl %ax,%eax
c0102d65:	25 00 02 00 00       	and    $0x200,%eax
c0102d6a:	85 c0                	test   %eax,%eax
c0102d6c:	75 24                	jne    c0102d92 <ide_init+0x1fb>
c0102d6e:	c7 44 24 0c 08 b8 10 	movl   $0xc010b808,0xc(%esp)
c0102d75:	c0 
c0102d76:	c7 44 24 08 4b b8 10 	movl   $0xc010b84b,0x8(%esp)
c0102d7d:	c0 
c0102d7e:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0102d85:	00 
c0102d86:	c7 04 24 60 b8 10 c0 	movl   $0xc010b860,(%esp)
c0102d8d:	e8 ce f3 ff ff       	call   c0102160 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0102d92:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102d96:	c1 e0 03             	shl    $0x3,%eax
c0102d99:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102da0:	29 c2                	sub    %eax,%edx
c0102da2:	8d 82 20 91 12 c0    	lea    -0x3fed6ee0(%edx),%eax
c0102da8:	83 c0 0c             	add    $0xc,%eax
c0102dab:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102dae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102db1:	83 c0 36             	add    $0x36,%eax
c0102db4:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0102db7:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0102dbe:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102dc5:	eb 34                	jmp    c0102dfb <ide_init+0x264>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0102dc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102dca:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102dcd:	01 c2                	add    %eax,%edx
c0102dcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102dd2:	8d 48 01             	lea    0x1(%eax),%ecx
c0102dd5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102dd8:	01 c8                	add    %ecx,%eax
c0102dda:	0f b6 00             	movzbl (%eax),%eax
c0102ddd:	88 02                	mov    %al,(%edx)
c0102ddf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102de2:	8d 50 01             	lea    0x1(%eax),%edx
c0102de5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102de8:	01 c2                	add    %eax,%edx
c0102dea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ded:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0102df0:	01 c8                	add    %ecx,%eax
c0102df2:	0f b6 00             	movzbl (%eax),%eax
c0102df5:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c0102df7:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0102dfb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102dfe:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0102e01:	72 c4                	jb     c0102dc7 <ide_init+0x230>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c0102e03:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102e06:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e09:	01 d0                	add    %edx,%eax
c0102e0b:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0102e0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102e11:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102e14:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0102e17:	85 c0                	test   %eax,%eax
c0102e19:	74 0f                	je     c0102e2a <ide_init+0x293>
c0102e1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102e1e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e21:	01 d0                	add    %edx,%eax
c0102e23:	0f b6 00             	movzbl (%eax),%eax
c0102e26:	3c 20                	cmp    $0x20,%al
c0102e28:	74 d9                	je     c0102e03 <ide_init+0x26c>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0102e2a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102e2e:	c1 e0 03             	shl    $0x3,%eax
c0102e31:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102e38:	29 c2                	sub    %eax,%edx
c0102e3a:	8d 82 20 91 12 c0    	lea    -0x3fed6ee0(%edx),%eax
c0102e40:	8d 48 0c             	lea    0xc(%eax),%ecx
c0102e43:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102e47:	c1 e0 03             	shl    $0x3,%eax
c0102e4a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102e51:	29 c2                	sub    %eax,%edx
c0102e53:	8d 82 20 91 12 c0    	lea    -0x3fed6ee0(%edx),%eax
c0102e59:	8b 50 08             	mov    0x8(%eax),%edx
c0102e5c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102e60:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0102e64:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102e68:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102e6c:	c7 04 24 72 b8 10 c0 	movl   $0xc010b872,(%esp)
c0102e73:	e8 5e e9 ff ff       	call   c01017d6 <cprintf>

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0102e78:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102e7c:	83 c0 01             	add    $0x1,%eax
c0102e7f:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0102e83:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0102e88:	0f 86 1f fd ff ff    	jbe    c0102bad <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0102e8e:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0102e95:	e8 7c 05 00 00       	call   c0103416 <pic_enable>
    pic_enable(IRQ_IDE2);
c0102e9a:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0102ea1:	e8 70 05 00 00       	call   c0103416 <pic_enable>
}
c0102ea6:	81 c4 50 02 00 00    	add    $0x250,%esp
c0102eac:	5b                   	pop    %ebx
c0102ead:	5f                   	pop    %edi
c0102eae:	5d                   	pop    %ebp
c0102eaf:	c3                   	ret    

c0102eb0 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0102eb0:	55                   	push   %ebp
c0102eb1:	89 e5                	mov    %esp,%ebp
c0102eb3:	83 ec 04             	sub    $0x4,%esp
c0102eb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0102eb9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0102ebd:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c0102ec2:	77 24                	ja     c0102ee8 <ide_device_valid+0x38>
c0102ec4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0102ec8:	c1 e0 03             	shl    $0x3,%eax
c0102ecb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102ed2:	29 c2                	sub    %eax,%edx
c0102ed4:	8d 82 20 91 12 c0    	lea    -0x3fed6ee0(%edx),%eax
c0102eda:	0f b6 00             	movzbl (%eax),%eax
c0102edd:	84 c0                	test   %al,%al
c0102edf:	74 07                	je     c0102ee8 <ide_device_valid+0x38>
c0102ee1:	b8 01 00 00 00       	mov    $0x1,%eax
c0102ee6:	eb 05                	jmp    c0102eed <ide_device_valid+0x3d>
c0102ee8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102eed:	c9                   	leave  
c0102eee:	c3                   	ret    

c0102eef <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0102eef:	55                   	push   %ebp
c0102ef0:	89 e5                	mov    %esp,%ebp
c0102ef2:	83 ec 08             	sub    $0x8,%esp
c0102ef5:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ef8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0102efc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0102f00:	89 04 24             	mov    %eax,(%esp)
c0102f03:	e8 a8 ff ff ff       	call   c0102eb0 <ide_device_valid>
c0102f08:	85 c0                	test   %eax,%eax
c0102f0a:	74 1b                	je     c0102f27 <ide_device_size+0x38>
        return ide_devices[ideno].size;
c0102f0c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0102f10:	c1 e0 03             	shl    $0x3,%eax
c0102f13:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102f1a:	29 c2                	sub    %eax,%edx
c0102f1c:	8d 82 20 91 12 c0    	lea    -0x3fed6ee0(%edx),%eax
c0102f22:	8b 40 08             	mov    0x8(%eax),%eax
c0102f25:	eb 05                	jmp    c0102f2c <ide_device_size+0x3d>
    }
    return 0;
c0102f27:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102f2c:	c9                   	leave  
c0102f2d:	c3                   	ret    

c0102f2e <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0102f2e:	55                   	push   %ebp
c0102f2f:	89 e5                	mov    %esp,%ebp
c0102f31:	57                   	push   %edi
c0102f32:	53                   	push   %ebx
c0102f33:	83 ec 50             	sub    $0x50,%esp
c0102f36:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f39:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0102f3d:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0102f44:	77 24                	ja     c0102f6a <ide_read_secs+0x3c>
c0102f46:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0102f4b:	77 1d                	ja     c0102f6a <ide_read_secs+0x3c>
c0102f4d:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102f51:	c1 e0 03             	shl    $0x3,%eax
c0102f54:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102f5b:	29 c2                	sub    %eax,%edx
c0102f5d:	8d 82 20 91 12 c0    	lea    -0x3fed6ee0(%edx),%eax
c0102f63:	0f b6 00             	movzbl (%eax),%eax
c0102f66:	84 c0                	test   %al,%al
c0102f68:	75 24                	jne    c0102f8e <ide_read_secs+0x60>
c0102f6a:	c7 44 24 0c 90 b8 10 	movl   $0xc010b890,0xc(%esp)
c0102f71:	c0 
c0102f72:	c7 44 24 08 4b b8 10 	movl   $0xc010b84b,0x8(%esp)
c0102f79:	c0 
c0102f7a:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0102f81:	00 
c0102f82:	c7 04 24 60 b8 10 c0 	movl   $0xc010b860,(%esp)
c0102f89:	e8 d2 f1 ff ff       	call   c0102160 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0102f8e:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0102f95:	77 0f                	ja     c0102fa6 <ide_read_secs+0x78>
c0102f97:	8b 45 14             	mov    0x14(%ebp),%eax
c0102f9a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102f9d:	01 d0                	add    %edx,%eax
c0102f9f:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0102fa4:	76 24                	jbe    c0102fca <ide_read_secs+0x9c>
c0102fa6:	c7 44 24 0c b8 b8 10 	movl   $0xc010b8b8,0xc(%esp)
c0102fad:	c0 
c0102fae:	c7 44 24 08 4b b8 10 	movl   $0xc010b84b,0x8(%esp)
c0102fb5:	c0 
c0102fb6:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0102fbd:	00 
c0102fbe:	c7 04 24 60 b8 10 c0 	movl   $0xc010b860,(%esp)
c0102fc5:	e8 96 f1 ff ff       	call   c0102160 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0102fca:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102fce:	66 d1 e8             	shr    %ax
c0102fd1:	0f b7 c0             	movzwl %ax,%eax
c0102fd4:	0f b7 04 85 00 b8 10 	movzwl -0x3fef4800(,%eax,4),%eax
c0102fdb:	c0 
c0102fdc:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0102fe0:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102fe4:	66 d1 e8             	shr    %ax
c0102fe7:	0f b7 c0             	movzwl %ax,%eax
c0102fea:	0f b7 04 85 02 b8 10 	movzwl -0x3fef47fe(,%eax,4),%eax
c0102ff1:	c0 
c0102ff2:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0102ff6:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102ffa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103001:	00 
c0103002:	89 04 24             	mov    %eax,(%esp)
c0103005:	e8 33 fb ff ff       	call   c0102b3d <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c010300a:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c010300e:	83 c0 02             	add    $0x2,%eax
c0103011:	0f b7 c0             	movzwl %ax,%eax
c0103014:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0103018:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010301c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0103020:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0103024:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0103025:	8b 45 14             	mov    0x14(%ebp),%eax
c0103028:	0f b6 c0             	movzbl %al,%eax
c010302b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010302f:	83 c2 02             	add    $0x2,%edx
c0103032:	0f b7 d2             	movzwl %dx,%edx
c0103035:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0103039:	88 45 e9             	mov    %al,-0x17(%ebp)
c010303c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0103040:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0103044:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0103045:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103048:	0f b6 c0             	movzbl %al,%eax
c010304b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010304f:	83 c2 03             	add    $0x3,%edx
c0103052:	0f b7 d2             	movzwl %dx,%edx
c0103055:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0103059:	88 45 e5             	mov    %al,-0x1b(%ebp)
c010305c:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0103060:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0103064:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0103065:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103068:	c1 e8 08             	shr    $0x8,%eax
c010306b:	0f b6 c0             	movzbl %al,%eax
c010306e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0103072:	83 c2 04             	add    $0x4,%edx
c0103075:	0f b7 d2             	movzwl %dx,%edx
c0103078:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c010307c:	88 45 e1             	mov    %al,-0x1f(%ebp)
c010307f:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0103083:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0103087:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0103088:	8b 45 0c             	mov    0xc(%ebp),%eax
c010308b:	c1 e8 10             	shr    $0x10,%eax
c010308e:	0f b6 c0             	movzbl %al,%eax
c0103091:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0103095:	83 c2 05             	add    $0x5,%edx
c0103098:	0f b7 d2             	movzwl %dx,%edx
c010309b:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c010309f:	88 45 dd             	mov    %al,-0x23(%ebp)
c01030a2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01030a6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01030aa:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c01030ab:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01030af:	83 e0 01             	and    $0x1,%eax
c01030b2:	c1 e0 04             	shl    $0x4,%eax
c01030b5:	89 c2                	mov    %eax,%edx
c01030b7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01030ba:	c1 e8 18             	shr    $0x18,%eax
c01030bd:	83 e0 0f             	and    $0xf,%eax
c01030c0:	09 d0                	or     %edx,%eax
c01030c2:	83 c8 e0             	or     $0xffffffe0,%eax
c01030c5:	0f b6 c0             	movzbl %al,%eax
c01030c8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01030cc:	83 c2 06             	add    $0x6,%edx
c01030cf:	0f b7 d2             	movzwl %dx,%edx
c01030d2:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c01030d6:	88 45 d9             	mov    %al,-0x27(%ebp)
c01030d9:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01030dd:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01030e1:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c01030e2:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01030e6:	83 c0 07             	add    $0x7,%eax
c01030e9:	0f b7 c0             	movzwl %ax,%eax
c01030ec:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c01030f0:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c01030f4:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01030f8:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01030fc:	ee                   	out    %al,(%dx)

    int ret = 0;
c01030fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0103104:	eb 5a                	jmp    c0103160 <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0103106:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010310a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103111:	00 
c0103112:	89 04 24             	mov    %eax,(%esp)
c0103115:	e8 23 fa ff ff       	call   c0102b3d <ide_wait_ready>
c010311a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010311d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103121:	74 02                	je     c0103125 <ide_read_secs+0x1f7>
            goto out;
c0103123:	eb 41                	jmp    c0103166 <ide_read_secs+0x238>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0103125:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0103129:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010312c:	8b 45 10             	mov    0x10(%ebp),%eax
c010312f:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0103132:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0103139:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010313c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c010313f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103142:	89 cb                	mov    %ecx,%ebx
c0103144:	89 df                	mov    %ebx,%edi
c0103146:	89 c1                	mov    %eax,%ecx
c0103148:	fc                   	cld    
c0103149:	f2 6d                	repnz insl (%dx),%es:(%edi)
c010314b:	89 c8                	mov    %ecx,%eax
c010314d:	89 fb                	mov    %edi,%ebx
c010314f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0103152:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0103155:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0103159:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0103160:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0103164:	75 a0                	jne    c0103106 <ide_read_secs+0x1d8>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0103166:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103169:	83 c4 50             	add    $0x50,%esp
c010316c:	5b                   	pop    %ebx
c010316d:	5f                   	pop    %edi
c010316e:	5d                   	pop    %ebp
c010316f:	c3                   	ret    

c0103170 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0103170:	55                   	push   %ebp
c0103171:	89 e5                	mov    %esp,%ebp
c0103173:	56                   	push   %esi
c0103174:	53                   	push   %ebx
c0103175:	83 ec 50             	sub    $0x50,%esp
c0103178:	8b 45 08             	mov    0x8(%ebp),%eax
c010317b:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c010317f:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0103186:	77 24                	ja     c01031ac <ide_write_secs+0x3c>
c0103188:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c010318d:	77 1d                	ja     c01031ac <ide_write_secs+0x3c>
c010318f:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0103193:	c1 e0 03             	shl    $0x3,%eax
c0103196:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010319d:	29 c2                	sub    %eax,%edx
c010319f:	8d 82 20 91 12 c0    	lea    -0x3fed6ee0(%edx),%eax
c01031a5:	0f b6 00             	movzbl (%eax),%eax
c01031a8:	84 c0                	test   %al,%al
c01031aa:	75 24                	jne    c01031d0 <ide_write_secs+0x60>
c01031ac:	c7 44 24 0c 90 b8 10 	movl   $0xc010b890,0xc(%esp)
c01031b3:	c0 
c01031b4:	c7 44 24 08 4b b8 10 	movl   $0xc010b84b,0x8(%esp)
c01031bb:	c0 
c01031bc:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c01031c3:	00 
c01031c4:	c7 04 24 60 b8 10 c0 	movl   $0xc010b860,(%esp)
c01031cb:	e8 90 ef ff ff       	call   c0102160 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c01031d0:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c01031d7:	77 0f                	ja     c01031e8 <ide_write_secs+0x78>
c01031d9:	8b 45 14             	mov    0x14(%ebp),%eax
c01031dc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01031df:	01 d0                	add    %edx,%eax
c01031e1:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c01031e6:	76 24                	jbe    c010320c <ide_write_secs+0x9c>
c01031e8:	c7 44 24 0c b8 b8 10 	movl   $0xc010b8b8,0xc(%esp)
c01031ef:	c0 
c01031f0:	c7 44 24 08 4b b8 10 	movl   $0xc010b84b,0x8(%esp)
c01031f7:	c0 
c01031f8:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c01031ff:	00 
c0103200:	c7 04 24 60 b8 10 c0 	movl   $0xc010b860,(%esp)
c0103207:	e8 54 ef ff ff       	call   c0102160 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010320c:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0103210:	66 d1 e8             	shr    %ax
c0103213:	0f b7 c0             	movzwl %ax,%eax
c0103216:	0f b7 04 85 00 b8 10 	movzwl -0x3fef4800(,%eax,4),%eax
c010321d:	c0 
c010321e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0103222:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0103226:	66 d1 e8             	shr    %ax
c0103229:	0f b7 c0             	movzwl %ax,%eax
c010322c:	0f b7 04 85 02 b8 10 	movzwl -0x3fef47fe(,%eax,4),%eax
c0103233:	c0 
c0103234:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0103238:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010323c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103243:	00 
c0103244:	89 04 24             	mov    %eax,(%esp)
c0103247:	e8 f1 f8 ff ff       	call   c0102b3d <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c010324c:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0103250:	83 c0 02             	add    $0x2,%eax
c0103253:	0f b7 c0             	movzwl %ax,%eax
c0103256:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c010325a:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010325e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0103262:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0103266:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0103267:	8b 45 14             	mov    0x14(%ebp),%eax
c010326a:	0f b6 c0             	movzbl %al,%eax
c010326d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0103271:	83 c2 02             	add    $0x2,%edx
c0103274:	0f b7 d2             	movzwl %dx,%edx
c0103277:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c010327b:	88 45 e9             	mov    %al,-0x17(%ebp)
c010327e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0103282:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0103286:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0103287:	8b 45 0c             	mov    0xc(%ebp),%eax
c010328a:	0f b6 c0             	movzbl %al,%eax
c010328d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0103291:	83 c2 03             	add    $0x3,%edx
c0103294:	0f b7 d2             	movzwl %dx,%edx
c0103297:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c010329b:	88 45 e5             	mov    %al,-0x1b(%ebp)
c010329e:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01032a2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01032a6:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01032a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032aa:	c1 e8 08             	shr    $0x8,%eax
c01032ad:	0f b6 c0             	movzbl %al,%eax
c01032b0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01032b4:	83 c2 04             	add    $0x4,%edx
c01032b7:	0f b7 d2             	movzwl %dx,%edx
c01032ba:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01032be:	88 45 e1             	mov    %al,-0x1f(%ebp)
c01032c1:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01032c5:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01032c9:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01032ca:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032cd:	c1 e8 10             	shr    $0x10,%eax
c01032d0:	0f b6 c0             	movzbl %al,%eax
c01032d3:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01032d7:	83 c2 05             	add    $0x5,%edx
c01032da:	0f b7 d2             	movzwl %dx,%edx
c01032dd:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c01032e1:	88 45 dd             	mov    %al,-0x23(%ebp)
c01032e4:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01032e8:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01032ec:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c01032ed:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01032f1:	83 e0 01             	and    $0x1,%eax
c01032f4:	c1 e0 04             	shl    $0x4,%eax
c01032f7:	89 c2                	mov    %eax,%edx
c01032f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032fc:	c1 e8 18             	shr    $0x18,%eax
c01032ff:	83 e0 0f             	and    $0xf,%eax
c0103302:	09 d0                	or     %edx,%eax
c0103304:	83 c8 e0             	or     $0xffffffe0,%eax
c0103307:	0f b6 c0             	movzbl %al,%eax
c010330a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010330e:	83 c2 06             	add    $0x6,%edx
c0103311:	0f b7 d2             	movzwl %dx,%edx
c0103314:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0103318:	88 45 d9             	mov    %al,-0x27(%ebp)
c010331b:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010331f:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0103323:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0103324:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0103328:	83 c0 07             	add    $0x7,%eax
c010332b:	0f b7 c0             	movzwl %ax,%eax
c010332e:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0103332:	c6 45 d5 30          	movb   $0x30,-0x2b(%ebp)
c0103336:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010333a:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010333e:	ee                   	out    %al,(%dx)

    int ret = 0;
c010333f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0103346:	eb 5a                	jmp    c01033a2 <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0103348:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010334c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103353:	00 
c0103354:	89 04 24             	mov    %eax,(%esp)
c0103357:	e8 e1 f7 ff ff       	call   c0102b3d <ide_wait_ready>
c010335c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010335f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103363:	74 02                	je     c0103367 <ide_write_secs+0x1f7>
            goto out;
c0103365:	eb 41                	jmp    c01033a8 <ide_write_secs+0x238>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0103367:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010336b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010336e:	8b 45 10             	mov    0x10(%ebp),%eax
c0103371:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0103374:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c010337b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010337e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0103381:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103384:	89 cb                	mov    %ecx,%ebx
c0103386:	89 de                	mov    %ebx,%esi
c0103388:	89 c1                	mov    %eax,%ecx
c010338a:	fc                   	cld    
c010338b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c010338d:	89 c8                	mov    %ecx,%eax
c010338f:	89 f3                	mov    %esi,%ebx
c0103391:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0103394:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0103397:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c010339b:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01033a2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01033a6:	75 a0                	jne    c0103348 <ide_write_secs+0x1d8>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c01033a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01033ab:	83 c4 50             	add    $0x50,%esp
c01033ae:	5b                   	pop    %ebx
c01033af:	5e                   	pop    %esi
c01033b0:	5d                   	pop    %ebp
c01033b1:	c3                   	ret    

c01033b2 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01033b2:	55                   	push   %ebp
c01033b3:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01033b5:	fb                   	sti    
    sti();
}
c01033b6:	5d                   	pop    %ebp
c01033b7:	c3                   	ret    

c01033b8 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01033b8:	55                   	push   %ebp
c01033b9:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01033bb:	fa                   	cli    
    cli();
}
c01033bc:	5d                   	pop    %ebp
c01033bd:	c3                   	ret    

c01033be <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01033be:	55                   	push   %ebp
c01033bf:	89 e5                	mov    %esp,%ebp
c01033c1:	83 ec 14             	sub    $0x14,%esp
c01033c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01033c7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01033cb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01033cf:	66 a3 70 85 12 c0    	mov    %ax,0xc0128570
    if (did_init) {
c01033d5:	a1 00 92 12 c0       	mov    0xc0129200,%eax
c01033da:	85 c0                	test   %eax,%eax
c01033dc:	74 36                	je     c0103414 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01033de:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01033e2:	0f b6 c0             	movzbl %al,%eax
c01033e5:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01033eb:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01033ee:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01033f2:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01033f6:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c01033f7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01033fb:	66 c1 e8 08          	shr    $0x8,%ax
c01033ff:	0f b6 c0             	movzbl %al,%eax
c0103402:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0103408:	88 45 f9             	mov    %al,-0x7(%ebp)
c010340b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010340f:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0103413:	ee                   	out    %al,(%dx)
    }
}
c0103414:	c9                   	leave  
c0103415:	c3                   	ret    

c0103416 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0103416:	55                   	push   %ebp
c0103417:	89 e5                	mov    %esp,%ebp
c0103419:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010341c:	8b 45 08             	mov    0x8(%ebp),%eax
c010341f:	ba 01 00 00 00       	mov    $0x1,%edx
c0103424:	89 c1                	mov    %eax,%ecx
c0103426:	d3 e2                	shl    %cl,%edx
c0103428:	89 d0                	mov    %edx,%eax
c010342a:	f7 d0                	not    %eax
c010342c:	89 c2                	mov    %eax,%edx
c010342e:	0f b7 05 70 85 12 c0 	movzwl 0xc0128570,%eax
c0103435:	21 d0                	and    %edx,%eax
c0103437:	0f b7 c0             	movzwl %ax,%eax
c010343a:	89 04 24             	mov    %eax,(%esp)
c010343d:	e8 7c ff ff ff       	call   c01033be <pic_setmask>
}
c0103442:	c9                   	leave  
c0103443:	c3                   	ret    

c0103444 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0103444:	55                   	push   %ebp
c0103445:	89 e5                	mov    %esp,%ebp
c0103447:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c010344a:	c7 05 00 92 12 c0 01 	movl   $0x1,0xc0129200
c0103451:	00 00 00 
c0103454:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c010345a:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c010345e:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0103462:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0103466:	ee                   	out    %al,(%dx)
c0103467:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c010346d:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c0103471:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0103475:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0103479:	ee                   	out    %al,(%dx)
c010347a:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0103480:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0103484:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0103488:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010348c:	ee                   	out    %al,(%dx)
c010348d:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c0103493:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c0103497:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010349b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010349f:	ee                   	out    %al,(%dx)
c01034a0:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c01034a6:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c01034aa:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01034ae:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01034b2:	ee                   	out    %al,(%dx)
c01034b3:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c01034b9:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c01034bd:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01034c1:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01034c5:	ee                   	out    %al,(%dx)
c01034c6:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01034cc:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c01034d0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01034d4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01034d8:	ee                   	out    %al,(%dx)
c01034d9:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c01034df:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c01034e3:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01034e7:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01034eb:	ee                   	out    %al,(%dx)
c01034ec:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c01034f2:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c01034f6:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01034fa:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01034fe:	ee                   	out    %al,(%dx)
c01034ff:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c0103505:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c0103509:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010350d:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0103511:	ee                   	out    %al,(%dx)
c0103512:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c0103518:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c010351c:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0103520:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0103524:	ee                   	out    %al,(%dx)
c0103525:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c010352b:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c010352f:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0103533:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0103537:	ee                   	out    %al,(%dx)
c0103538:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c010353e:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c0103542:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0103546:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c010354a:	ee                   	out    %al,(%dx)
c010354b:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c0103551:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c0103555:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0103559:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010355d:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010355e:	0f b7 05 70 85 12 c0 	movzwl 0xc0128570,%eax
c0103565:	66 83 f8 ff          	cmp    $0xffff,%ax
c0103569:	74 12                	je     c010357d <pic_init+0x139>
        pic_setmask(irq_mask);
c010356b:	0f b7 05 70 85 12 c0 	movzwl 0xc0128570,%eax
c0103572:	0f b7 c0             	movzwl %ax,%eax
c0103575:	89 04 24             	mov    %eax,(%esp)
c0103578:	e8 41 fe ff ff       	call   c01033be <pic_setmask>
    }
}
c010357d:	c9                   	leave  
c010357e:	c3                   	ret    

c010357f <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c010357f:	55                   	push   %ebp
c0103580:	89 e5                	mov    %esp,%ebp
c0103582:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0103585:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010358c:	00 
c010358d:	c7 04 24 00 b9 10 c0 	movl   $0xc010b900,(%esp)
c0103594:	e8 3d e2 ff ff       	call   c01017d6 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c0103599:	c7 04 24 0a b9 10 c0 	movl   $0xc010b90a,(%esp)
c01035a0:	e8 31 e2 ff ff       	call   c01017d6 <cprintf>
    panic("EOT: kernel seems ok.");
c01035a5:	c7 44 24 08 18 b9 10 	movl   $0xc010b918,0x8(%esp)
c01035ac:	c0 
c01035ad:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01035b4:	00 
c01035b5:	c7 04 24 2e b9 10 c0 	movl   $0xc010b92e,(%esp)
c01035bc:	e8 9f eb ff ff       	call   c0102160 <__panic>

c01035c1 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01035c1:	55                   	push   %ebp
c01035c2:	89 e5                	mov    %esp,%ebp
c01035c4:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01035c7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01035ce:	e9 c3 00 00 00       	jmp    c0103696 <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01035d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01035d6:	8b 04 85 00 86 12 c0 	mov    -0x3fed7a00(,%eax,4),%eax
c01035dd:	89 c2                	mov    %eax,%edx
c01035df:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01035e2:	66 89 14 c5 20 92 12 	mov    %dx,-0x3fed6de0(,%eax,8)
c01035e9:	c0 
c01035ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01035ed:	66 c7 04 c5 22 92 12 	movw   $0x8,-0x3fed6dde(,%eax,8)
c01035f4:	c0 08 00 
c01035f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01035fa:	0f b6 14 c5 24 92 12 	movzbl -0x3fed6ddc(,%eax,8),%edx
c0103601:	c0 
c0103602:	83 e2 e0             	and    $0xffffffe0,%edx
c0103605:	88 14 c5 24 92 12 c0 	mov    %dl,-0x3fed6ddc(,%eax,8)
c010360c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010360f:	0f b6 14 c5 24 92 12 	movzbl -0x3fed6ddc(,%eax,8),%edx
c0103616:	c0 
c0103617:	83 e2 1f             	and    $0x1f,%edx
c010361a:	88 14 c5 24 92 12 c0 	mov    %dl,-0x3fed6ddc(,%eax,8)
c0103621:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103624:	0f b6 14 c5 25 92 12 	movzbl -0x3fed6ddb(,%eax,8),%edx
c010362b:	c0 
c010362c:	83 e2 f0             	and    $0xfffffff0,%edx
c010362f:	83 ca 0e             	or     $0xe,%edx
c0103632:	88 14 c5 25 92 12 c0 	mov    %dl,-0x3fed6ddb(,%eax,8)
c0103639:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010363c:	0f b6 14 c5 25 92 12 	movzbl -0x3fed6ddb(,%eax,8),%edx
c0103643:	c0 
c0103644:	83 e2 ef             	and    $0xffffffef,%edx
c0103647:	88 14 c5 25 92 12 c0 	mov    %dl,-0x3fed6ddb(,%eax,8)
c010364e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103651:	0f b6 14 c5 25 92 12 	movzbl -0x3fed6ddb(,%eax,8),%edx
c0103658:	c0 
c0103659:	83 e2 9f             	and    $0xffffff9f,%edx
c010365c:	88 14 c5 25 92 12 c0 	mov    %dl,-0x3fed6ddb(,%eax,8)
c0103663:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103666:	0f b6 14 c5 25 92 12 	movzbl -0x3fed6ddb(,%eax,8),%edx
c010366d:	c0 
c010366e:	83 ca 80             	or     $0xffffff80,%edx
c0103671:	88 14 c5 25 92 12 c0 	mov    %dl,-0x3fed6ddb(,%eax,8)
c0103678:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010367b:	8b 04 85 00 86 12 c0 	mov    -0x3fed7a00(,%eax,4),%eax
c0103682:	c1 e8 10             	shr    $0x10,%eax
c0103685:	89 c2                	mov    %eax,%edx
c0103687:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010368a:	66 89 14 c5 26 92 12 	mov    %dx,-0x3fed6dda(,%eax,8)
c0103691:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0103692:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0103696:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103699:	3d ff 00 00 00       	cmp    $0xff,%eax
c010369e:	0f 86 2f ff ff ff    	jbe    c01035d3 <idt_init+0x12>
c01036a4:	c7 45 f8 80 85 12 c0 	movl   $0xc0128580,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01036ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01036ae:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
c01036b1:	c9                   	leave  
c01036b2:	c3                   	ret    

c01036b3 <trapname>:

static const char *
trapname(int trapno) {
c01036b3:	55                   	push   %ebp
c01036b4:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01036b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01036b9:	83 f8 13             	cmp    $0x13,%eax
c01036bc:	77 0c                	ja     c01036ca <trapname+0x17>
        return excnames[trapno];
c01036be:	8b 45 08             	mov    0x8(%ebp),%eax
c01036c1:	8b 04 85 00 bd 10 c0 	mov    -0x3fef4300(,%eax,4),%eax
c01036c8:	eb 18                	jmp    c01036e2 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01036ca:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01036ce:	7e 0d                	jle    c01036dd <trapname+0x2a>
c01036d0:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01036d4:	7f 07                	jg     c01036dd <trapname+0x2a>
        return "Hardware Interrupt";
c01036d6:	b8 3f b9 10 c0       	mov    $0xc010b93f,%eax
c01036db:	eb 05                	jmp    c01036e2 <trapname+0x2f>
    }
    return "(unknown trap)";
c01036dd:	b8 52 b9 10 c0       	mov    $0xc010b952,%eax
}
c01036e2:	5d                   	pop    %ebp
c01036e3:	c3                   	ret    

c01036e4 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01036e4:	55                   	push   %ebp
c01036e5:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01036e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01036ea:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01036ee:	66 83 f8 08          	cmp    $0x8,%ax
c01036f2:	0f 94 c0             	sete   %al
c01036f5:	0f b6 c0             	movzbl %al,%eax
}
c01036f8:	5d                   	pop    %ebp
c01036f9:	c3                   	ret    

c01036fa <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01036fa:	55                   	push   %ebp
c01036fb:	89 e5                	mov    %esp,%ebp
c01036fd:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0103700:	8b 45 08             	mov    0x8(%ebp),%eax
c0103703:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103707:	c7 04 24 93 b9 10 c0 	movl   $0xc010b993,(%esp)
c010370e:	e8 c3 e0 ff ff       	call   c01017d6 <cprintf>
    print_regs(&tf->tf_regs);
c0103713:	8b 45 08             	mov    0x8(%ebp),%eax
c0103716:	89 04 24             	mov    %eax,(%esp)
c0103719:	e8 a1 01 00 00       	call   c01038bf <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c010371e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103721:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0103725:	0f b7 c0             	movzwl %ax,%eax
c0103728:	89 44 24 04          	mov    %eax,0x4(%esp)
c010372c:	c7 04 24 a4 b9 10 c0 	movl   $0xc010b9a4,(%esp)
c0103733:	e8 9e e0 ff ff       	call   c01017d6 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0103738:	8b 45 08             	mov    0x8(%ebp),%eax
c010373b:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c010373f:	0f b7 c0             	movzwl %ax,%eax
c0103742:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103746:	c7 04 24 b7 b9 10 c0 	movl   $0xc010b9b7,(%esp)
c010374d:	e8 84 e0 ff ff       	call   c01017d6 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0103752:	8b 45 08             	mov    0x8(%ebp),%eax
c0103755:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0103759:	0f b7 c0             	movzwl %ax,%eax
c010375c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103760:	c7 04 24 ca b9 10 c0 	movl   $0xc010b9ca,(%esp)
c0103767:	e8 6a e0 ff ff       	call   c01017d6 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c010376c:	8b 45 08             	mov    0x8(%ebp),%eax
c010376f:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0103773:	0f b7 c0             	movzwl %ax,%eax
c0103776:	89 44 24 04          	mov    %eax,0x4(%esp)
c010377a:	c7 04 24 dd b9 10 c0 	movl   $0xc010b9dd,(%esp)
c0103781:	e8 50 e0 ff ff       	call   c01017d6 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0103786:	8b 45 08             	mov    0x8(%ebp),%eax
c0103789:	8b 40 30             	mov    0x30(%eax),%eax
c010378c:	89 04 24             	mov    %eax,(%esp)
c010378f:	e8 1f ff ff ff       	call   c01036b3 <trapname>
c0103794:	8b 55 08             	mov    0x8(%ebp),%edx
c0103797:	8b 52 30             	mov    0x30(%edx),%edx
c010379a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010379e:	89 54 24 04          	mov    %edx,0x4(%esp)
c01037a2:	c7 04 24 f0 b9 10 c0 	movl   $0xc010b9f0,(%esp)
c01037a9:	e8 28 e0 ff ff       	call   c01017d6 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01037ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01037b1:	8b 40 34             	mov    0x34(%eax),%eax
c01037b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01037b8:	c7 04 24 02 ba 10 c0 	movl   $0xc010ba02,(%esp)
c01037bf:	e8 12 e0 ff ff       	call   c01017d6 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01037c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01037c7:	8b 40 38             	mov    0x38(%eax),%eax
c01037ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01037ce:	c7 04 24 11 ba 10 c0 	movl   $0xc010ba11,(%esp)
c01037d5:	e8 fc df ff ff       	call   c01017d6 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01037da:	8b 45 08             	mov    0x8(%ebp),%eax
c01037dd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01037e1:	0f b7 c0             	movzwl %ax,%eax
c01037e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01037e8:	c7 04 24 20 ba 10 c0 	movl   $0xc010ba20,(%esp)
c01037ef:	e8 e2 df ff ff       	call   c01017d6 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01037f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01037f7:	8b 40 40             	mov    0x40(%eax),%eax
c01037fa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01037fe:	c7 04 24 33 ba 10 c0 	movl   $0xc010ba33,(%esp)
c0103805:	e8 cc df ff ff       	call   c01017d6 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010380a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103811:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0103818:	eb 3e                	jmp    c0103858 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c010381a:	8b 45 08             	mov    0x8(%ebp),%eax
c010381d:	8b 50 40             	mov    0x40(%eax),%edx
c0103820:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103823:	21 d0                	and    %edx,%eax
c0103825:	85 c0                	test   %eax,%eax
c0103827:	74 28                	je     c0103851 <print_trapframe+0x157>
c0103829:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010382c:	8b 04 85 a0 85 12 c0 	mov    -0x3fed7a60(,%eax,4),%eax
c0103833:	85 c0                	test   %eax,%eax
c0103835:	74 1a                	je     c0103851 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0103837:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010383a:	8b 04 85 a0 85 12 c0 	mov    -0x3fed7a60(,%eax,4),%eax
c0103841:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103845:	c7 04 24 42 ba 10 c0 	movl   $0xc010ba42,(%esp)
c010384c:	e8 85 df ff ff       	call   c01017d6 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0103851:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103855:	d1 65 f0             	shll   -0x10(%ebp)
c0103858:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010385b:	83 f8 17             	cmp    $0x17,%eax
c010385e:	76 ba                	jbe    c010381a <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0103860:	8b 45 08             	mov    0x8(%ebp),%eax
c0103863:	8b 40 40             	mov    0x40(%eax),%eax
c0103866:	25 00 30 00 00       	and    $0x3000,%eax
c010386b:	c1 e8 0c             	shr    $0xc,%eax
c010386e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103872:	c7 04 24 46 ba 10 c0 	movl   $0xc010ba46,(%esp)
c0103879:	e8 58 df ff ff       	call   c01017d6 <cprintf>

    if (!trap_in_kernel(tf)) {
c010387e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103881:	89 04 24             	mov    %eax,(%esp)
c0103884:	e8 5b fe ff ff       	call   c01036e4 <trap_in_kernel>
c0103889:	85 c0                	test   %eax,%eax
c010388b:	75 30                	jne    c01038bd <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c010388d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103890:	8b 40 44             	mov    0x44(%eax),%eax
c0103893:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103897:	c7 04 24 4f ba 10 c0 	movl   $0xc010ba4f,(%esp)
c010389e:	e8 33 df ff ff       	call   c01017d6 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c01038a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01038a6:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01038aa:	0f b7 c0             	movzwl %ax,%eax
c01038ad:	89 44 24 04          	mov    %eax,0x4(%esp)
c01038b1:	c7 04 24 5e ba 10 c0 	movl   $0xc010ba5e,(%esp)
c01038b8:	e8 19 df ff ff       	call   c01017d6 <cprintf>
    }
}
c01038bd:	c9                   	leave  
c01038be:	c3                   	ret    

c01038bf <print_regs>:

void
print_regs(struct pushregs *regs) {
c01038bf:	55                   	push   %ebp
c01038c0:	89 e5                	mov    %esp,%ebp
c01038c2:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01038c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01038c8:	8b 00                	mov    (%eax),%eax
c01038ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01038ce:	c7 04 24 71 ba 10 c0 	movl   $0xc010ba71,(%esp)
c01038d5:	e8 fc de ff ff       	call   c01017d6 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01038da:	8b 45 08             	mov    0x8(%ebp),%eax
c01038dd:	8b 40 04             	mov    0x4(%eax),%eax
c01038e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01038e4:	c7 04 24 80 ba 10 c0 	movl   $0xc010ba80,(%esp)
c01038eb:	e8 e6 de ff ff       	call   c01017d6 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01038f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01038f3:	8b 40 08             	mov    0x8(%eax),%eax
c01038f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01038fa:	c7 04 24 8f ba 10 c0 	movl   $0xc010ba8f,(%esp)
c0103901:	e8 d0 de ff ff       	call   c01017d6 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0103906:	8b 45 08             	mov    0x8(%ebp),%eax
c0103909:	8b 40 0c             	mov    0xc(%eax),%eax
c010390c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103910:	c7 04 24 9e ba 10 c0 	movl   $0xc010ba9e,(%esp)
c0103917:	e8 ba de ff ff       	call   c01017d6 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c010391c:	8b 45 08             	mov    0x8(%ebp),%eax
c010391f:	8b 40 10             	mov    0x10(%eax),%eax
c0103922:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103926:	c7 04 24 ad ba 10 c0 	movl   $0xc010baad,(%esp)
c010392d:	e8 a4 de ff ff       	call   c01017d6 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0103932:	8b 45 08             	mov    0x8(%ebp),%eax
c0103935:	8b 40 14             	mov    0x14(%eax),%eax
c0103938:	89 44 24 04          	mov    %eax,0x4(%esp)
c010393c:	c7 04 24 bc ba 10 c0 	movl   $0xc010babc,(%esp)
c0103943:	e8 8e de ff ff       	call   c01017d6 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0103948:	8b 45 08             	mov    0x8(%ebp),%eax
c010394b:	8b 40 18             	mov    0x18(%eax),%eax
c010394e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103952:	c7 04 24 cb ba 10 c0 	movl   $0xc010bacb,(%esp)
c0103959:	e8 78 de ff ff       	call   c01017d6 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c010395e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103961:	8b 40 1c             	mov    0x1c(%eax),%eax
c0103964:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103968:	c7 04 24 da ba 10 c0 	movl   $0xc010bada,(%esp)
c010396f:	e8 62 de ff ff       	call   c01017d6 <cprintf>
}
c0103974:	c9                   	leave  
c0103975:	c3                   	ret    

c0103976 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0103976:	55                   	push   %ebp
c0103977:	89 e5                	mov    %esp,%ebp
c0103979:	53                   	push   %ebx
c010397a:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c010397d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103980:	8b 40 34             	mov    0x34(%eax),%eax
c0103983:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0103986:	85 c0                	test   %eax,%eax
c0103988:	74 07                	je     c0103991 <print_pgfault+0x1b>
c010398a:	b9 e9 ba 10 c0       	mov    $0xc010bae9,%ecx
c010398f:	eb 05                	jmp    c0103996 <print_pgfault+0x20>
c0103991:	b9 fa ba 10 c0       	mov    $0xc010bafa,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c0103996:	8b 45 08             	mov    0x8(%ebp),%eax
c0103999:	8b 40 34             	mov    0x34(%eax),%eax
c010399c:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010399f:	85 c0                	test   %eax,%eax
c01039a1:	74 07                	je     c01039aa <print_pgfault+0x34>
c01039a3:	ba 57 00 00 00       	mov    $0x57,%edx
c01039a8:	eb 05                	jmp    c01039af <print_pgfault+0x39>
c01039aa:	ba 52 00 00 00       	mov    $0x52,%edx
            (tf->tf_err & 4) ? 'U' : 'K',
c01039af:	8b 45 08             	mov    0x8(%ebp),%eax
c01039b2:	8b 40 34             	mov    0x34(%eax),%eax
c01039b5:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01039b8:	85 c0                	test   %eax,%eax
c01039ba:	74 07                	je     c01039c3 <print_pgfault+0x4d>
c01039bc:	b8 55 00 00 00       	mov    $0x55,%eax
c01039c1:	eb 05                	jmp    c01039c8 <print_pgfault+0x52>
c01039c3:	b8 4b 00 00 00       	mov    $0x4b,%eax
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01039c8:	0f 20 d3             	mov    %cr2,%ebx
c01039cb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
    return cr2;
c01039ce:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c01039d1:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01039d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01039d9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01039dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01039e1:	c7 04 24 08 bb 10 c0 	movl   $0xc010bb08,(%esp)
c01039e8:	e8 e9 dd ff ff       	call   c01017d6 <cprintf>
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c01039ed:	83 c4 34             	add    $0x34,%esp
c01039f0:	5b                   	pop    %ebx
c01039f1:	5d                   	pop    %ebp
c01039f2:	c3                   	ret    

c01039f3 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01039f3:	55                   	push   %ebp
c01039f4:	89 e5                	mov    %esp,%ebp
c01039f6:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c01039f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01039fc:	89 04 24             	mov    %eax,(%esp)
c01039ff:	e8 72 ff ff ff       	call   c0103976 <print_pgfault>
    if (check_mm_struct != NULL) {
c0103a04:	a1 0c bc 12 c0       	mov    0xc012bc0c,%eax
c0103a09:	85 c0                	test   %eax,%eax
c0103a0b:	74 28                	je     c0103a35 <pgfault_handler+0x42>
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0103a0d:	0f 20 d0             	mov    %cr2,%eax
c0103a10:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0103a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c0103a16:	89 c1                	mov    %eax,%ecx
c0103a18:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a1b:	8b 50 34             	mov    0x34(%eax),%edx
c0103a1e:	a1 0c bc 12 c0       	mov    0xc012bc0c,%eax
c0103a23:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103a27:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103a2b:	89 04 24             	mov    %eax,(%esp)
c0103a2e:	e8 f9 5b 00 00       	call   c010962c <do_pgfault>
c0103a33:	eb 1c                	jmp    c0103a51 <pgfault_handler+0x5e>
    }
    panic("unhandled page fault.\n");
c0103a35:	c7 44 24 08 2b bb 10 	movl   $0xc010bb2b,0x8(%esp)
c0103a3c:	c0 
c0103a3d:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
c0103a44:	00 
c0103a45:	c7 04 24 2e b9 10 c0 	movl   $0xc010b92e,(%esp)
c0103a4c:	e8 0f e7 ff ff       	call   c0102160 <__panic>
}
c0103a51:	c9                   	leave  
c0103a52:	c3                   	ret    

c0103a53 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c0103a53:	55                   	push   %ebp
c0103a54:	89 e5                	mov    %esp,%ebp
c0103a56:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c0103a59:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a5c:	8b 40 30             	mov    0x30(%eax),%eax
c0103a5f:	83 f8 24             	cmp    $0x24,%eax
c0103a62:	0f 84 c2 00 00 00    	je     c0103b2a <trap_dispatch+0xd7>
c0103a68:	83 f8 24             	cmp    $0x24,%eax
c0103a6b:	77 18                	ja     c0103a85 <trap_dispatch+0x32>
c0103a6d:	83 f8 20             	cmp    $0x20,%eax
c0103a70:	74 7d                	je     c0103aef <trap_dispatch+0x9c>
c0103a72:	83 f8 21             	cmp    $0x21,%eax
c0103a75:	0f 84 d5 00 00 00    	je     c0103b50 <trap_dispatch+0xfd>
c0103a7b:	83 f8 0e             	cmp    $0xe,%eax
c0103a7e:	74 28                	je     c0103aa8 <trap_dispatch+0x55>
c0103a80:	e9 0d 01 00 00       	jmp    c0103b92 <trap_dispatch+0x13f>
c0103a85:	83 f8 2e             	cmp    $0x2e,%eax
c0103a88:	0f 82 04 01 00 00    	jb     c0103b92 <trap_dispatch+0x13f>
c0103a8e:	83 f8 2f             	cmp    $0x2f,%eax
c0103a91:	0f 86 33 01 00 00    	jbe    c0103bca <trap_dispatch+0x177>
c0103a97:	83 e8 78             	sub    $0x78,%eax
c0103a9a:	83 f8 01             	cmp    $0x1,%eax
c0103a9d:	0f 87 ef 00 00 00    	ja     c0103b92 <trap_dispatch+0x13f>
c0103aa3:	e9 ce 00 00 00       	jmp    c0103b76 <trap_dispatch+0x123>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c0103aa8:	8b 45 08             	mov    0x8(%ebp),%eax
c0103aab:	89 04 24             	mov    %eax,(%esp)
c0103aae:	e8 40 ff ff ff       	call   c01039f3 <pgfault_handler>
c0103ab3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103ab6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103aba:	74 2e                	je     c0103aea <trap_dispatch+0x97>
            print_trapframe(tf);
c0103abc:	8b 45 08             	mov    0x8(%ebp),%eax
c0103abf:	89 04 24             	mov    %eax,(%esp)
c0103ac2:	e8 33 fc ff ff       	call   c01036fa <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c0103ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103aca:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103ace:	c7 44 24 08 42 bb 10 	movl   $0xc010bb42,0x8(%esp)
c0103ad5:	c0 
c0103ad6:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c0103add:	00 
c0103ade:	c7 04 24 2e b9 10 c0 	movl   $0xc010b92e,(%esp)
c0103ae5:	e8 76 e6 ff ff       	call   c0102160 <__panic>
        }
        break;
c0103aea:	e9 dc 00 00 00       	jmp    c0103bcb <trap_dispatch+0x178>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0103aef:	a1 14 bb 12 c0       	mov    0xc012bb14,%eax
c0103af4:	83 c0 01             	add    $0x1,%eax
c0103af7:	a3 14 bb 12 c0       	mov    %eax,0xc012bb14
        if (ticks % TICK_NUM == 0) {
c0103afc:	8b 0d 14 bb 12 c0    	mov    0xc012bb14,%ecx
c0103b02:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0103b07:	89 c8                	mov    %ecx,%eax
c0103b09:	f7 e2                	mul    %edx
c0103b0b:	89 d0                	mov    %edx,%eax
c0103b0d:	c1 e8 05             	shr    $0x5,%eax
c0103b10:	6b c0 64             	imul   $0x64,%eax,%eax
c0103b13:	29 c1                	sub    %eax,%ecx
c0103b15:	89 c8                	mov    %ecx,%eax
c0103b17:	85 c0                	test   %eax,%eax
c0103b19:	75 0a                	jne    c0103b25 <trap_dispatch+0xd2>
            print_ticks();
c0103b1b:	e8 5f fa ff ff       	call   c010357f <print_ticks>
        }
        break;
c0103b20:	e9 a6 00 00 00       	jmp    c0103bcb <trap_dispatch+0x178>
c0103b25:	e9 a1 00 00 00       	jmp    c0103bcb <trap_dispatch+0x178>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0103b2a:	e8 9f ef ff ff       	call   c0102ace <cons_getc>
c0103b2f:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0103b32:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0103b36:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0103b3a:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103b3e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103b42:	c7 04 24 5d bb 10 c0 	movl   $0xc010bb5d,(%esp)
c0103b49:	e8 88 dc ff ff       	call   c01017d6 <cprintf>
        break;
c0103b4e:	eb 7b                	jmp    c0103bcb <trap_dispatch+0x178>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0103b50:	e8 79 ef ff ff       	call   c0102ace <cons_getc>
c0103b55:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0103b58:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0103b5c:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0103b60:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103b64:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103b68:	c7 04 24 6f bb 10 c0 	movl   $0xc010bb6f,(%esp)
c0103b6f:	e8 62 dc ff ff       	call   c01017d6 <cprintf>
        break;
c0103b74:	eb 55                	jmp    c0103bcb <trap_dispatch+0x178>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0103b76:	c7 44 24 08 7e bb 10 	movl   $0xc010bb7e,0x8(%esp)
c0103b7d:	c0 
c0103b7e:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0103b85:	00 
c0103b86:	c7 04 24 2e b9 10 c0 	movl   $0xc010b92e,(%esp)
c0103b8d:	e8 ce e5 ff ff       	call   c0102160 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0103b92:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b95:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0103b99:	0f b7 c0             	movzwl %ax,%eax
c0103b9c:	83 e0 03             	and    $0x3,%eax
c0103b9f:	85 c0                	test   %eax,%eax
c0103ba1:	75 28                	jne    c0103bcb <trap_dispatch+0x178>
            print_trapframe(tf);
c0103ba3:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ba6:	89 04 24             	mov    %eax,(%esp)
c0103ba9:	e8 4c fb ff ff       	call   c01036fa <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0103bae:	c7 44 24 08 8e bb 10 	movl   $0xc010bb8e,0x8(%esp)
c0103bb5:	c0 
c0103bb6:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0103bbd:	00 
c0103bbe:	c7 04 24 2e b9 10 c0 	movl   $0xc010b92e,(%esp)
c0103bc5:	e8 96 e5 ff ff       	call   c0102160 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0103bca:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0103bcb:	c9                   	leave  
c0103bcc:	c3                   	ret    

c0103bcd <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0103bcd:	55                   	push   %ebp
c0103bce:	89 e5                	mov    %esp,%ebp
c0103bd0:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0103bd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bd6:	89 04 24             	mov    %eax,(%esp)
c0103bd9:	e8 75 fe ff ff       	call   c0103a53 <trap_dispatch>
}
c0103bde:	c9                   	leave  
c0103bdf:	c3                   	ret    

c0103be0 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0103be0:	1e                   	push   %ds
    pushl %es
c0103be1:	06                   	push   %es
    pushl %fs
c0103be2:	0f a0                	push   %fs
    pushl %gs
c0103be4:	0f a8                	push   %gs
    pushal
c0103be6:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0103be7:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0103bec:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0103bee:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0103bf0:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0103bf1:	e8 d7 ff ff ff       	call   c0103bcd <trap>

    # pop the pushed stack pointer
    popl %esp
c0103bf6:	5c                   	pop    %esp

c0103bf7 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0103bf7:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0103bf8:	0f a9                	pop    %gs
    popl %fs
c0103bfa:	0f a1                	pop    %fs
    popl %es
c0103bfc:	07                   	pop    %es
    popl %ds
c0103bfd:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0103bfe:	83 c4 08             	add    $0x8,%esp
    iret
c0103c01:	cf                   	iret   

c0103c02 <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c0103c02:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0103c06:	e9 ec ff ff ff       	jmp    c0103bf7 <__trapret>

c0103c0b <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0103c0b:	6a 00                	push   $0x0
  pushl $0
c0103c0d:	6a 00                	push   $0x0
  jmp __alltraps
c0103c0f:	e9 cc ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c14 <vector1>:
.globl vector1
vector1:
  pushl $0
c0103c14:	6a 00                	push   $0x0
  pushl $1
c0103c16:	6a 01                	push   $0x1
  jmp __alltraps
c0103c18:	e9 c3 ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c1d <vector2>:
.globl vector2
vector2:
  pushl $0
c0103c1d:	6a 00                	push   $0x0
  pushl $2
c0103c1f:	6a 02                	push   $0x2
  jmp __alltraps
c0103c21:	e9 ba ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c26 <vector3>:
.globl vector3
vector3:
  pushl $0
c0103c26:	6a 00                	push   $0x0
  pushl $3
c0103c28:	6a 03                	push   $0x3
  jmp __alltraps
c0103c2a:	e9 b1 ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c2f <vector4>:
.globl vector4
vector4:
  pushl $0
c0103c2f:	6a 00                	push   $0x0
  pushl $4
c0103c31:	6a 04                	push   $0x4
  jmp __alltraps
c0103c33:	e9 a8 ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c38 <vector5>:
.globl vector5
vector5:
  pushl $0
c0103c38:	6a 00                	push   $0x0
  pushl $5
c0103c3a:	6a 05                	push   $0x5
  jmp __alltraps
c0103c3c:	e9 9f ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c41 <vector6>:
.globl vector6
vector6:
  pushl $0
c0103c41:	6a 00                	push   $0x0
  pushl $6
c0103c43:	6a 06                	push   $0x6
  jmp __alltraps
c0103c45:	e9 96 ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c4a <vector7>:
.globl vector7
vector7:
  pushl $0
c0103c4a:	6a 00                	push   $0x0
  pushl $7
c0103c4c:	6a 07                	push   $0x7
  jmp __alltraps
c0103c4e:	e9 8d ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c53 <vector8>:
.globl vector8
vector8:
  pushl $8
c0103c53:	6a 08                	push   $0x8
  jmp __alltraps
c0103c55:	e9 86 ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c5a <vector9>:
.globl vector9
vector9:
  pushl $9
c0103c5a:	6a 09                	push   $0x9
  jmp __alltraps
c0103c5c:	e9 7f ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c61 <vector10>:
.globl vector10
vector10:
  pushl $10
c0103c61:	6a 0a                	push   $0xa
  jmp __alltraps
c0103c63:	e9 78 ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c68 <vector11>:
.globl vector11
vector11:
  pushl $11
c0103c68:	6a 0b                	push   $0xb
  jmp __alltraps
c0103c6a:	e9 71 ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c6f <vector12>:
.globl vector12
vector12:
  pushl $12
c0103c6f:	6a 0c                	push   $0xc
  jmp __alltraps
c0103c71:	e9 6a ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c76 <vector13>:
.globl vector13
vector13:
  pushl $13
c0103c76:	6a 0d                	push   $0xd
  jmp __alltraps
c0103c78:	e9 63 ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c7d <vector14>:
.globl vector14
vector14:
  pushl $14
c0103c7d:	6a 0e                	push   $0xe
  jmp __alltraps
c0103c7f:	e9 5c ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c84 <vector15>:
.globl vector15
vector15:
  pushl $0
c0103c84:	6a 00                	push   $0x0
  pushl $15
c0103c86:	6a 0f                	push   $0xf
  jmp __alltraps
c0103c88:	e9 53 ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c8d <vector16>:
.globl vector16
vector16:
  pushl $0
c0103c8d:	6a 00                	push   $0x0
  pushl $16
c0103c8f:	6a 10                	push   $0x10
  jmp __alltraps
c0103c91:	e9 4a ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c96 <vector17>:
.globl vector17
vector17:
  pushl $17
c0103c96:	6a 11                	push   $0x11
  jmp __alltraps
c0103c98:	e9 43 ff ff ff       	jmp    c0103be0 <__alltraps>

c0103c9d <vector18>:
.globl vector18
vector18:
  pushl $0
c0103c9d:	6a 00                	push   $0x0
  pushl $18
c0103c9f:	6a 12                	push   $0x12
  jmp __alltraps
c0103ca1:	e9 3a ff ff ff       	jmp    c0103be0 <__alltraps>

c0103ca6 <vector19>:
.globl vector19
vector19:
  pushl $0
c0103ca6:	6a 00                	push   $0x0
  pushl $19
c0103ca8:	6a 13                	push   $0x13
  jmp __alltraps
c0103caa:	e9 31 ff ff ff       	jmp    c0103be0 <__alltraps>

c0103caf <vector20>:
.globl vector20
vector20:
  pushl $0
c0103caf:	6a 00                	push   $0x0
  pushl $20
c0103cb1:	6a 14                	push   $0x14
  jmp __alltraps
c0103cb3:	e9 28 ff ff ff       	jmp    c0103be0 <__alltraps>

c0103cb8 <vector21>:
.globl vector21
vector21:
  pushl $0
c0103cb8:	6a 00                	push   $0x0
  pushl $21
c0103cba:	6a 15                	push   $0x15
  jmp __alltraps
c0103cbc:	e9 1f ff ff ff       	jmp    c0103be0 <__alltraps>

c0103cc1 <vector22>:
.globl vector22
vector22:
  pushl $0
c0103cc1:	6a 00                	push   $0x0
  pushl $22
c0103cc3:	6a 16                	push   $0x16
  jmp __alltraps
c0103cc5:	e9 16 ff ff ff       	jmp    c0103be0 <__alltraps>

c0103cca <vector23>:
.globl vector23
vector23:
  pushl $0
c0103cca:	6a 00                	push   $0x0
  pushl $23
c0103ccc:	6a 17                	push   $0x17
  jmp __alltraps
c0103cce:	e9 0d ff ff ff       	jmp    c0103be0 <__alltraps>

c0103cd3 <vector24>:
.globl vector24
vector24:
  pushl $0
c0103cd3:	6a 00                	push   $0x0
  pushl $24
c0103cd5:	6a 18                	push   $0x18
  jmp __alltraps
c0103cd7:	e9 04 ff ff ff       	jmp    c0103be0 <__alltraps>

c0103cdc <vector25>:
.globl vector25
vector25:
  pushl $0
c0103cdc:	6a 00                	push   $0x0
  pushl $25
c0103cde:	6a 19                	push   $0x19
  jmp __alltraps
c0103ce0:	e9 fb fe ff ff       	jmp    c0103be0 <__alltraps>

c0103ce5 <vector26>:
.globl vector26
vector26:
  pushl $0
c0103ce5:	6a 00                	push   $0x0
  pushl $26
c0103ce7:	6a 1a                	push   $0x1a
  jmp __alltraps
c0103ce9:	e9 f2 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103cee <vector27>:
.globl vector27
vector27:
  pushl $0
c0103cee:	6a 00                	push   $0x0
  pushl $27
c0103cf0:	6a 1b                	push   $0x1b
  jmp __alltraps
c0103cf2:	e9 e9 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103cf7 <vector28>:
.globl vector28
vector28:
  pushl $0
c0103cf7:	6a 00                	push   $0x0
  pushl $28
c0103cf9:	6a 1c                	push   $0x1c
  jmp __alltraps
c0103cfb:	e9 e0 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d00 <vector29>:
.globl vector29
vector29:
  pushl $0
c0103d00:	6a 00                	push   $0x0
  pushl $29
c0103d02:	6a 1d                	push   $0x1d
  jmp __alltraps
c0103d04:	e9 d7 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d09 <vector30>:
.globl vector30
vector30:
  pushl $0
c0103d09:	6a 00                	push   $0x0
  pushl $30
c0103d0b:	6a 1e                	push   $0x1e
  jmp __alltraps
c0103d0d:	e9 ce fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d12 <vector31>:
.globl vector31
vector31:
  pushl $0
c0103d12:	6a 00                	push   $0x0
  pushl $31
c0103d14:	6a 1f                	push   $0x1f
  jmp __alltraps
c0103d16:	e9 c5 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d1b <vector32>:
.globl vector32
vector32:
  pushl $0
c0103d1b:	6a 00                	push   $0x0
  pushl $32
c0103d1d:	6a 20                	push   $0x20
  jmp __alltraps
c0103d1f:	e9 bc fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d24 <vector33>:
.globl vector33
vector33:
  pushl $0
c0103d24:	6a 00                	push   $0x0
  pushl $33
c0103d26:	6a 21                	push   $0x21
  jmp __alltraps
c0103d28:	e9 b3 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d2d <vector34>:
.globl vector34
vector34:
  pushl $0
c0103d2d:	6a 00                	push   $0x0
  pushl $34
c0103d2f:	6a 22                	push   $0x22
  jmp __alltraps
c0103d31:	e9 aa fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d36 <vector35>:
.globl vector35
vector35:
  pushl $0
c0103d36:	6a 00                	push   $0x0
  pushl $35
c0103d38:	6a 23                	push   $0x23
  jmp __alltraps
c0103d3a:	e9 a1 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d3f <vector36>:
.globl vector36
vector36:
  pushl $0
c0103d3f:	6a 00                	push   $0x0
  pushl $36
c0103d41:	6a 24                	push   $0x24
  jmp __alltraps
c0103d43:	e9 98 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d48 <vector37>:
.globl vector37
vector37:
  pushl $0
c0103d48:	6a 00                	push   $0x0
  pushl $37
c0103d4a:	6a 25                	push   $0x25
  jmp __alltraps
c0103d4c:	e9 8f fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d51 <vector38>:
.globl vector38
vector38:
  pushl $0
c0103d51:	6a 00                	push   $0x0
  pushl $38
c0103d53:	6a 26                	push   $0x26
  jmp __alltraps
c0103d55:	e9 86 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d5a <vector39>:
.globl vector39
vector39:
  pushl $0
c0103d5a:	6a 00                	push   $0x0
  pushl $39
c0103d5c:	6a 27                	push   $0x27
  jmp __alltraps
c0103d5e:	e9 7d fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d63 <vector40>:
.globl vector40
vector40:
  pushl $0
c0103d63:	6a 00                	push   $0x0
  pushl $40
c0103d65:	6a 28                	push   $0x28
  jmp __alltraps
c0103d67:	e9 74 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d6c <vector41>:
.globl vector41
vector41:
  pushl $0
c0103d6c:	6a 00                	push   $0x0
  pushl $41
c0103d6e:	6a 29                	push   $0x29
  jmp __alltraps
c0103d70:	e9 6b fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d75 <vector42>:
.globl vector42
vector42:
  pushl $0
c0103d75:	6a 00                	push   $0x0
  pushl $42
c0103d77:	6a 2a                	push   $0x2a
  jmp __alltraps
c0103d79:	e9 62 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d7e <vector43>:
.globl vector43
vector43:
  pushl $0
c0103d7e:	6a 00                	push   $0x0
  pushl $43
c0103d80:	6a 2b                	push   $0x2b
  jmp __alltraps
c0103d82:	e9 59 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d87 <vector44>:
.globl vector44
vector44:
  pushl $0
c0103d87:	6a 00                	push   $0x0
  pushl $44
c0103d89:	6a 2c                	push   $0x2c
  jmp __alltraps
c0103d8b:	e9 50 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d90 <vector45>:
.globl vector45
vector45:
  pushl $0
c0103d90:	6a 00                	push   $0x0
  pushl $45
c0103d92:	6a 2d                	push   $0x2d
  jmp __alltraps
c0103d94:	e9 47 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103d99 <vector46>:
.globl vector46
vector46:
  pushl $0
c0103d99:	6a 00                	push   $0x0
  pushl $46
c0103d9b:	6a 2e                	push   $0x2e
  jmp __alltraps
c0103d9d:	e9 3e fe ff ff       	jmp    c0103be0 <__alltraps>

c0103da2 <vector47>:
.globl vector47
vector47:
  pushl $0
c0103da2:	6a 00                	push   $0x0
  pushl $47
c0103da4:	6a 2f                	push   $0x2f
  jmp __alltraps
c0103da6:	e9 35 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103dab <vector48>:
.globl vector48
vector48:
  pushl $0
c0103dab:	6a 00                	push   $0x0
  pushl $48
c0103dad:	6a 30                	push   $0x30
  jmp __alltraps
c0103daf:	e9 2c fe ff ff       	jmp    c0103be0 <__alltraps>

c0103db4 <vector49>:
.globl vector49
vector49:
  pushl $0
c0103db4:	6a 00                	push   $0x0
  pushl $49
c0103db6:	6a 31                	push   $0x31
  jmp __alltraps
c0103db8:	e9 23 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103dbd <vector50>:
.globl vector50
vector50:
  pushl $0
c0103dbd:	6a 00                	push   $0x0
  pushl $50
c0103dbf:	6a 32                	push   $0x32
  jmp __alltraps
c0103dc1:	e9 1a fe ff ff       	jmp    c0103be0 <__alltraps>

c0103dc6 <vector51>:
.globl vector51
vector51:
  pushl $0
c0103dc6:	6a 00                	push   $0x0
  pushl $51
c0103dc8:	6a 33                	push   $0x33
  jmp __alltraps
c0103dca:	e9 11 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103dcf <vector52>:
.globl vector52
vector52:
  pushl $0
c0103dcf:	6a 00                	push   $0x0
  pushl $52
c0103dd1:	6a 34                	push   $0x34
  jmp __alltraps
c0103dd3:	e9 08 fe ff ff       	jmp    c0103be0 <__alltraps>

c0103dd8 <vector53>:
.globl vector53
vector53:
  pushl $0
c0103dd8:	6a 00                	push   $0x0
  pushl $53
c0103dda:	6a 35                	push   $0x35
  jmp __alltraps
c0103ddc:	e9 ff fd ff ff       	jmp    c0103be0 <__alltraps>

c0103de1 <vector54>:
.globl vector54
vector54:
  pushl $0
c0103de1:	6a 00                	push   $0x0
  pushl $54
c0103de3:	6a 36                	push   $0x36
  jmp __alltraps
c0103de5:	e9 f6 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103dea <vector55>:
.globl vector55
vector55:
  pushl $0
c0103dea:	6a 00                	push   $0x0
  pushl $55
c0103dec:	6a 37                	push   $0x37
  jmp __alltraps
c0103dee:	e9 ed fd ff ff       	jmp    c0103be0 <__alltraps>

c0103df3 <vector56>:
.globl vector56
vector56:
  pushl $0
c0103df3:	6a 00                	push   $0x0
  pushl $56
c0103df5:	6a 38                	push   $0x38
  jmp __alltraps
c0103df7:	e9 e4 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103dfc <vector57>:
.globl vector57
vector57:
  pushl $0
c0103dfc:	6a 00                	push   $0x0
  pushl $57
c0103dfe:	6a 39                	push   $0x39
  jmp __alltraps
c0103e00:	e9 db fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e05 <vector58>:
.globl vector58
vector58:
  pushl $0
c0103e05:	6a 00                	push   $0x0
  pushl $58
c0103e07:	6a 3a                	push   $0x3a
  jmp __alltraps
c0103e09:	e9 d2 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e0e <vector59>:
.globl vector59
vector59:
  pushl $0
c0103e0e:	6a 00                	push   $0x0
  pushl $59
c0103e10:	6a 3b                	push   $0x3b
  jmp __alltraps
c0103e12:	e9 c9 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e17 <vector60>:
.globl vector60
vector60:
  pushl $0
c0103e17:	6a 00                	push   $0x0
  pushl $60
c0103e19:	6a 3c                	push   $0x3c
  jmp __alltraps
c0103e1b:	e9 c0 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e20 <vector61>:
.globl vector61
vector61:
  pushl $0
c0103e20:	6a 00                	push   $0x0
  pushl $61
c0103e22:	6a 3d                	push   $0x3d
  jmp __alltraps
c0103e24:	e9 b7 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e29 <vector62>:
.globl vector62
vector62:
  pushl $0
c0103e29:	6a 00                	push   $0x0
  pushl $62
c0103e2b:	6a 3e                	push   $0x3e
  jmp __alltraps
c0103e2d:	e9 ae fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e32 <vector63>:
.globl vector63
vector63:
  pushl $0
c0103e32:	6a 00                	push   $0x0
  pushl $63
c0103e34:	6a 3f                	push   $0x3f
  jmp __alltraps
c0103e36:	e9 a5 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e3b <vector64>:
.globl vector64
vector64:
  pushl $0
c0103e3b:	6a 00                	push   $0x0
  pushl $64
c0103e3d:	6a 40                	push   $0x40
  jmp __alltraps
c0103e3f:	e9 9c fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e44 <vector65>:
.globl vector65
vector65:
  pushl $0
c0103e44:	6a 00                	push   $0x0
  pushl $65
c0103e46:	6a 41                	push   $0x41
  jmp __alltraps
c0103e48:	e9 93 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e4d <vector66>:
.globl vector66
vector66:
  pushl $0
c0103e4d:	6a 00                	push   $0x0
  pushl $66
c0103e4f:	6a 42                	push   $0x42
  jmp __alltraps
c0103e51:	e9 8a fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e56 <vector67>:
.globl vector67
vector67:
  pushl $0
c0103e56:	6a 00                	push   $0x0
  pushl $67
c0103e58:	6a 43                	push   $0x43
  jmp __alltraps
c0103e5a:	e9 81 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e5f <vector68>:
.globl vector68
vector68:
  pushl $0
c0103e5f:	6a 00                	push   $0x0
  pushl $68
c0103e61:	6a 44                	push   $0x44
  jmp __alltraps
c0103e63:	e9 78 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e68 <vector69>:
.globl vector69
vector69:
  pushl $0
c0103e68:	6a 00                	push   $0x0
  pushl $69
c0103e6a:	6a 45                	push   $0x45
  jmp __alltraps
c0103e6c:	e9 6f fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e71 <vector70>:
.globl vector70
vector70:
  pushl $0
c0103e71:	6a 00                	push   $0x0
  pushl $70
c0103e73:	6a 46                	push   $0x46
  jmp __alltraps
c0103e75:	e9 66 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e7a <vector71>:
.globl vector71
vector71:
  pushl $0
c0103e7a:	6a 00                	push   $0x0
  pushl $71
c0103e7c:	6a 47                	push   $0x47
  jmp __alltraps
c0103e7e:	e9 5d fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e83 <vector72>:
.globl vector72
vector72:
  pushl $0
c0103e83:	6a 00                	push   $0x0
  pushl $72
c0103e85:	6a 48                	push   $0x48
  jmp __alltraps
c0103e87:	e9 54 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e8c <vector73>:
.globl vector73
vector73:
  pushl $0
c0103e8c:	6a 00                	push   $0x0
  pushl $73
c0103e8e:	6a 49                	push   $0x49
  jmp __alltraps
c0103e90:	e9 4b fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e95 <vector74>:
.globl vector74
vector74:
  pushl $0
c0103e95:	6a 00                	push   $0x0
  pushl $74
c0103e97:	6a 4a                	push   $0x4a
  jmp __alltraps
c0103e99:	e9 42 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103e9e <vector75>:
.globl vector75
vector75:
  pushl $0
c0103e9e:	6a 00                	push   $0x0
  pushl $75
c0103ea0:	6a 4b                	push   $0x4b
  jmp __alltraps
c0103ea2:	e9 39 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103ea7 <vector76>:
.globl vector76
vector76:
  pushl $0
c0103ea7:	6a 00                	push   $0x0
  pushl $76
c0103ea9:	6a 4c                	push   $0x4c
  jmp __alltraps
c0103eab:	e9 30 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103eb0 <vector77>:
.globl vector77
vector77:
  pushl $0
c0103eb0:	6a 00                	push   $0x0
  pushl $77
c0103eb2:	6a 4d                	push   $0x4d
  jmp __alltraps
c0103eb4:	e9 27 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103eb9 <vector78>:
.globl vector78
vector78:
  pushl $0
c0103eb9:	6a 00                	push   $0x0
  pushl $78
c0103ebb:	6a 4e                	push   $0x4e
  jmp __alltraps
c0103ebd:	e9 1e fd ff ff       	jmp    c0103be0 <__alltraps>

c0103ec2 <vector79>:
.globl vector79
vector79:
  pushl $0
c0103ec2:	6a 00                	push   $0x0
  pushl $79
c0103ec4:	6a 4f                	push   $0x4f
  jmp __alltraps
c0103ec6:	e9 15 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103ecb <vector80>:
.globl vector80
vector80:
  pushl $0
c0103ecb:	6a 00                	push   $0x0
  pushl $80
c0103ecd:	6a 50                	push   $0x50
  jmp __alltraps
c0103ecf:	e9 0c fd ff ff       	jmp    c0103be0 <__alltraps>

c0103ed4 <vector81>:
.globl vector81
vector81:
  pushl $0
c0103ed4:	6a 00                	push   $0x0
  pushl $81
c0103ed6:	6a 51                	push   $0x51
  jmp __alltraps
c0103ed8:	e9 03 fd ff ff       	jmp    c0103be0 <__alltraps>

c0103edd <vector82>:
.globl vector82
vector82:
  pushl $0
c0103edd:	6a 00                	push   $0x0
  pushl $82
c0103edf:	6a 52                	push   $0x52
  jmp __alltraps
c0103ee1:	e9 fa fc ff ff       	jmp    c0103be0 <__alltraps>

c0103ee6 <vector83>:
.globl vector83
vector83:
  pushl $0
c0103ee6:	6a 00                	push   $0x0
  pushl $83
c0103ee8:	6a 53                	push   $0x53
  jmp __alltraps
c0103eea:	e9 f1 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103eef <vector84>:
.globl vector84
vector84:
  pushl $0
c0103eef:	6a 00                	push   $0x0
  pushl $84
c0103ef1:	6a 54                	push   $0x54
  jmp __alltraps
c0103ef3:	e9 e8 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103ef8 <vector85>:
.globl vector85
vector85:
  pushl $0
c0103ef8:	6a 00                	push   $0x0
  pushl $85
c0103efa:	6a 55                	push   $0x55
  jmp __alltraps
c0103efc:	e9 df fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f01 <vector86>:
.globl vector86
vector86:
  pushl $0
c0103f01:	6a 00                	push   $0x0
  pushl $86
c0103f03:	6a 56                	push   $0x56
  jmp __alltraps
c0103f05:	e9 d6 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f0a <vector87>:
.globl vector87
vector87:
  pushl $0
c0103f0a:	6a 00                	push   $0x0
  pushl $87
c0103f0c:	6a 57                	push   $0x57
  jmp __alltraps
c0103f0e:	e9 cd fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f13 <vector88>:
.globl vector88
vector88:
  pushl $0
c0103f13:	6a 00                	push   $0x0
  pushl $88
c0103f15:	6a 58                	push   $0x58
  jmp __alltraps
c0103f17:	e9 c4 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f1c <vector89>:
.globl vector89
vector89:
  pushl $0
c0103f1c:	6a 00                	push   $0x0
  pushl $89
c0103f1e:	6a 59                	push   $0x59
  jmp __alltraps
c0103f20:	e9 bb fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f25 <vector90>:
.globl vector90
vector90:
  pushl $0
c0103f25:	6a 00                	push   $0x0
  pushl $90
c0103f27:	6a 5a                	push   $0x5a
  jmp __alltraps
c0103f29:	e9 b2 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f2e <vector91>:
.globl vector91
vector91:
  pushl $0
c0103f2e:	6a 00                	push   $0x0
  pushl $91
c0103f30:	6a 5b                	push   $0x5b
  jmp __alltraps
c0103f32:	e9 a9 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f37 <vector92>:
.globl vector92
vector92:
  pushl $0
c0103f37:	6a 00                	push   $0x0
  pushl $92
c0103f39:	6a 5c                	push   $0x5c
  jmp __alltraps
c0103f3b:	e9 a0 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f40 <vector93>:
.globl vector93
vector93:
  pushl $0
c0103f40:	6a 00                	push   $0x0
  pushl $93
c0103f42:	6a 5d                	push   $0x5d
  jmp __alltraps
c0103f44:	e9 97 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f49 <vector94>:
.globl vector94
vector94:
  pushl $0
c0103f49:	6a 00                	push   $0x0
  pushl $94
c0103f4b:	6a 5e                	push   $0x5e
  jmp __alltraps
c0103f4d:	e9 8e fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f52 <vector95>:
.globl vector95
vector95:
  pushl $0
c0103f52:	6a 00                	push   $0x0
  pushl $95
c0103f54:	6a 5f                	push   $0x5f
  jmp __alltraps
c0103f56:	e9 85 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f5b <vector96>:
.globl vector96
vector96:
  pushl $0
c0103f5b:	6a 00                	push   $0x0
  pushl $96
c0103f5d:	6a 60                	push   $0x60
  jmp __alltraps
c0103f5f:	e9 7c fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f64 <vector97>:
.globl vector97
vector97:
  pushl $0
c0103f64:	6a 00                	push   $0x0
  pushl $97
c0103f66:	6a 61                	push   $0x61
  jmp __alltraps
c0103f68:	e9 73 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f6d <vector98>:
.globl vector98
vector98:
  pushl $0
c0103f6d:	6a 00                	push   $0x0
  pushl $98
c0103f6f:	6a 62                	push   $0x62
  jmp __alltraps
c0103f71:	e9 6a fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f76 <vector99>:
.globl vector99
vector99:
  pushl $0
c0103f76:	6a 00                	push   $0x0
  pushl $99
c0103f78:	6a 63                	push   $0x63
  jmp __alltraps
c0103f7a:	e9 61 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f7f <vector100>:
.globl vector100
vector100:
  pushl $0
c0103f7f:	6a 00                	push   $0x0
  pushl $100
c0103f81:	6a 64                	push   $0x64
  jmp __alltraps
c0103f83:	e9 58 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f88 <vector101>:
.globl vector101
vector101:
  pushl $0
c0103f88:	6a 00                	push   $0x0
  pushl $101
c0103f8a:	6a 65                	push   $0x65
  jmp __alltraps
c0103f8c:	e9 4f fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f91 <vector102>:
.globl vector102
vector102:
  pushl $0
c0103f91:	6a 00                	push   $0x0
  pushl $102
c0103f93:	6a 66                	push   $0x66
  jmp __alltraps
c0103f95:	e9 46 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103f9a <vector103>:
.globl vector103
vector103:
  pushl $0
c0103f9a:	6a 00                	push   $0x0
  pushl $103
c0103f9c:	6a 67                	push   $0x67
  jmp __alltraps
c0103f9e:	e9 3d fc ff ff       	jmp    c0103be0 <__alltraps>

c0103fa3 <vector104>:
.globl vector104
vector104:
  pushl $0
c0103fa3:	6a 00                	push   $0x0
  pushl $104
c0103fa5:	6a 68                	push   $0x68
  jmp __alltraps
c0103fa7:	e9 34 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103fac <vector105>:
.globl vector105
vector105:
  pushl $0
c0103fac:	6a 00                	push   $0x0
  pushl $105
c0103fae:	6a 69                	push   $0x69
  jmp __alltraps
c0103fb0:	e9 2b fc ff ff       	jmp    c0103be0 <__alltraps>

c0103fb5 <vector106>:
.globl vector106
vector106:
  pushl $0
c0103fb5:	6a 00                	push   $0x0
  pushl $106
c0103fb7:	6a 6a                	push   $0x6a
  jmp __alltraps
c0103fb9:	e9 22 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103fbe <vector107>:
.globl vector107
vector107:
  pushl $0
c0103fbe:	6a 00                	push   $0x0
  pushl $107
c0103fc0:	6a 6b                	push   $0x6b
  jmp __alltraps
c0103fc2:	e9 19 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103fc7 <vector108>:
.globl vector108
vector108:
  pushl $0
c0103fc7:	6a 00                	push   $0x0
  pushl $108
c0103fc9:	6a 6c                	push   $0x6c
  jmp __alltraps
c0103fcb:	e9 10 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103fd0 <vector109>:
.globl vector109
vector109:
  pushl $0
c0103fd0:	6a 00                	push   $0x0
  pushl $109
c0103fd2:	6a 6d                	push   $0x6d
  jmp __alltraps
c0103fd4:	e9 07 fc ff ff       	jmp    c0103be0 <__alltraps>

c0103fd9 <vector110>:
.globl vector110
vector110:
  pushl $0
c0103fd9:	6a 00                	push   $0x0
  pushl $110
c0103fdb:	6a 6e                	push   $0x6e
  jmp __alltraps
c0103fdd:	e9 fe fb ff ff       	jmp    c0103be0 <__alltraps>

c0103fe2 <vector111>:
.globl vector111
vector111:
  pushl $0
c0103fe2:	6a 00                	push   $0x0
  pushl $111
c0103fe4:	6a 6f                	push   $0x6f
  jmp __alltraps
c0103fe6:	e9 f5 fb ff ff       	jmp    c0103be0 <__alltraps>

c0103feb <vector112>:
.globl vector112
vector112:
  pushl $0
c0103feb:	6a 00                	push   $0x0
  pushl $112
c0103fed:	6a 70                	push   $0x70
  jmp __alltraps
c0103fef:	e9 ec fb ff ff       	jmp    c0103be0 <__alltraps>

c0103ff4 <vector113>:
.globl vector113
vector113:
  pushl $0
c0103ff4:	6a 00                	push   $0x0
  pushl $113
c0103ff6:	6a 71                	push   $0x71
  jmp __alltraps
c0103ff8:	e9 e3 fb ff ff       	jmp    c0103be0 <__alltraps>

c0103ffd <vector114>:
.globl vector114
vector114:
  pushl $0
c0103ffd:	6a 00                	push   $0x0
  pushl $114
c0103fff:	6a 72                	push   $0x72
  jmp __alltraps
c0104001:	e9 da fb ff ff       	jmp    c0103be0 <__alltraps>

c0104006 <vector115>:
.globl vector115
vector115:
  pushl $0
c0104006:	6a 00                	push   $0x0
  pushl $115
c0104008:	6a 73                	push   $0x73
  jmp __alltraps
c010400a:	e9 d1 fb ff ff       	jmp    c0103be0 <__alltraps>

c010400f <vector116>:
.globl vector116
vector116:
  pushl $0
c010400f:	6a 00                	push   $0x0
  pushl $116
c0104011:	6a 74                	push   $0x74
  jmp __alltraps
c0104013:	e9 c8 fb ff ff       	jmp    c0103be0 <__alltraps>

c0104018 <vector117>:
.globl vector117
vector117:
  pushl $0
c0104018:	6a 00                	push   $0x0
  pushl $117
c010401a:	6a 75                	push   $0x75
  jmp __alltraps
c010401c:	e9 bf fb ff ff       	jmp    c0103be0 <__alltraps>

c0104021 <vector118>:
.globl vector118
vector118:
  pushl $0
c0104021:	6a 00                	push   $0x0
  pushl $118
c0104023:	6a 76                	push   $0x76
  jmp __alltraps
c0104025:	e9 b6 fb ff ff       	jmp    c0103be0 <__alltraps>

c010402a <vector119>:
.globl vector119
vector119:
  pushl $0
c010402a:	6a 00                	push   $0x0
  pushl $119
c010402c:	6a 77                	push   $0x77
  jmp __alltraps
c010402e:	e9 ad fb ff ff       	jmp    c0103be0 <__alltraps>

c0104033 <vector120>:
.globl vector120
vector120:
  pushl $0
c0104033:	6a 00                	push   $0x0
  pushl $120
c0104035:	6a 78                	push   $0x78
  jmp __alltraps
c0104037:	e9 a4 fb ff ff       	jmp    c0103be0 <__alltraps>

c010403c <vector121>:
.globl vector121
vector121:
  pushl $0
c010403c:	6a 00                	push   $0x0
  pushl $121
c010403e:	6a 79                	push   $0x79
  jmp __alltraps
c0104040:	e9 9b fb ff ff       	jmp    c0103be0 <__alltraps>

c0104045 <vector122>:
.globl vector122
vector122:
  pushl $0
c0104045:	6a 00                	push   $0x0
  pushl $122
c0104047:	6a 7a                	push   $0x7a
  jmp __alltraps
c0104049:	e9 92 fb ff ff       	jmp    c0103be0 <__alltraps>

c010404e <vector123>:
.globl vector123
vector123:
  pushl $0
c010404e:	6a 00                	push   $0x0
  pushl $123
c0104050:	6a 7b                	push   $0x7b
  jmp __alltraps
c0104052:	e9 89 fb ff ff       	jmp    c0103be0 <__alltraps>

c0104057 <vector124>:
.globl vector124
vector124:
  pushl $0
c0104057:	6a 00                	push   $0x0
  pushl $124
c0104059:	6a 7c                	push   $0x7c
  jmp __alltraps
c010405b:	e9 80 fb ff ff       	jmp    c0103be0 <__alltraps>

c0104060 <vector125>:
.globl vector125
vector125:
  pushl $0
c0104060:	6a 00                	push   $0x0
  pushl $125
c0104062:	6a 7d                	push   $0x7d
  jmp __alltraps
c0104064:	e9 77 fb ff ff       	jmp    c0103be0 <__alltraps>

c0104069 <vector126>:
.globl vector126
vector126:
  pushl $0
c0104069:	6a 00                	push   $0x0
  pushl $126
c010406b:	6a 7e                	push   $0x7e
  jmp __alltraps
c010406d:	e9 6e fb ff ff       	jmp    c0103be0 <__alltraps>

c0104072 <vector127>:
.globl vector127
vector127:
  pushl $0
c0104072:	6a 00                	push   $0x0
  pushl $127
c0104074:	6a 7f                	push   $0x7f
  jmp __alltraps
c0104076:	e9 65 fb ff ff       	jmp    c0103be0 <__alltraps>

c010407b <vector128>:
.globl vector128
vector128:
  pushl $0
c010407b:	6a 00                	push   $0x0
  pushl $128
c010407d:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0104082:	e9 59 fb ff ff       	jmp    c0103be0 <__alltraps>

c0104087 <vector129>:
.globl vector129
vector129:
  pushl $0
c0104087:	6a 00                	push   $0x0
  pushl $129
c0104089:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c010408e:	e9 4d fb ff ff       	jmp    c0103be0 <__alltraps>

c0104093 <vector130>:
.globl vector130
vector130:
  pushl $0
c0104093:	6a 00                	push   $0x0
  pushl $130
c0104095:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c010409a:	e9 41 fb ff ff       	jmp    c0103be0 <__alltraps>

c010409f <vector131>:
.globl vector131
vector131:
  pushl $0
c010409f:	6a 00                	push   $0x0
  pushl $131
c01040a1:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01040a6:	e9 35 fb ff ff       	jmp    c0103be0 <__alltraps>

c01040ab <vector132>:
.globl vector132
vector132:
  pushl $0
c01040ab:	6a 00                	push   $0x0
  pushl $132
c01040ad:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01040b2:	e9 29 fb ff ff       	jmp    c0103be0 <__alltraps>

c01040b7 <vector133>:
.globl vector133
vector133:
  pushl $0
c01040b7:	6a 00                	push   $0x0
  pushl $133
c01040b9:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01040be:	e9 1d fb ff ff       	jmp    c0103be0 <__alltraps>

c01040c3 <vector134>:
.globl vector134
vector134:
  pushl $0
c01040c3:	6a 00                	push   $0x0
  pushl $134
c01040c5:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01040ca:	e9 11 fb ff ff       	jmp    c0103be0 <__alltraps>

c01040cf <vector135>:
.globl vector135
vector135:
  pushl $0
c01040cf:	6a 00                	push   $0x0
  pushl $135
c01040d1:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c01040d6:	e9 05 fb ff ff       	jmp    c0103be0 <__alltraps>

c01040db <vector136>:
.globl vector136
vector136:
  pushl $0
c01040db:	6a 00                	push   $0x0
  pushl $136
c01040dd:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01040e2:	e9 f9 fa ff ff       	jmp    c0103be0 <__alltraps>

c01040e7 <vector137>:
.globl vector137
vector137:
  pushl $0
c01040e7:	6a 00                	push   $0x0
  pushl $137
c01040e9:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c01040ee:	e9 ed fa ff ff       	jmp    c0103be0 <__alltraps>

c01040f3 <vector138>:
.globl vector138
vector138:
  pushl $0
c01040f3:	6a 00                	push   $0x0
  pushl $138
c01040f5:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01040fa:	e9 e1 fa ff ff       	jmp    c0103be0 <__alltraps>

c01040ff <vector139>:
.globl vector139
vector139:
  pushl $0
c01040ff:	6a 00                	push   $0x0
  pushl $139
c0104101:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0104106:	e9 d5 fa ff ff       	jmp    c0103be0 <__alltraps>

c010410b <vector140>:
.globl vector140
vector140:
  pushl $0
c010410b:	6a 00                	push   $0x0
  pushl $140
c010410d:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0104112:	e9 c9 fa ff ff       	jmp    c0103be0 <__alltraps>

c0104117 <vector141>:
.globl vector141
vector141:
  pushl $0
c0104117:	6a 00                	push   $0x0
  pushl $141
c0104119:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c010411e:	e9 bd fa ff ff       	jmp    c0103be0 <__alltraps>

c0104123 <vector142>:
.globl vector142
vector142:
  pushl $0
c0104123:	6a 00                	push   $0x0
  pushl $142
c0104125:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c010412a:	e9 b1 fa ff ff       	jmp    c0103be0 <__alltraps>

c010412f <vector143>:
.globl vector143
vector143:
  pushl $0
c010412f:	6a 00                	push   $0x0
  pushl $143
c0104131:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0104136:	e9 a5 fa ff ff       	jmp    c0103be0 <__alltraps>

c010413b <vector144>:
.globl vector144
vector144:
  pushl $0
c010413b:	6a 00                	push   $0x0
  pushl $144
c010413d:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0104142:	e9 99 fa ff ff       	jmp    c0103be0 <__alltraps>

c0104147 <vector145>:
.globl vector145
vector145:
  pushl $0
c0104147:	6a 00                	push   $0x0
  pushl $145
c0104149:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c010414e:	e9 8d fa ff ff       	jmp    c0103be0 <__alltraps>

c0104153 <vector146>:
.globl vector146
vector146:
  pushl $0
c0104153:	6a 00                	push   $0x0
  pushl $146
c0104155:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c010415a:	e9 81 fa ff ff       	jmp    c0103be0 <__alltraps>

c010415f <vector147>:
.globl vector147
vector147:
  pushl $0
c010415f:	6a 00                	push   $0x0
  pushl $147
c0104161:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0104166:	e9 75 fa ff ff       	jmp    c0103be0 <__alltraps>

c010416b <vector148>:
.globl vector148
vector148:
  pushl $0
c010416b:	6a 00                	push   $0x0
  pushl $148
c010416d:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0104172:	e9 69 fa ff ff       	jmp    c0103be0 <__alltraps>

c0104177 <vector149>:
.globl vector149
vector149:
  pushl $0
c0104177:	6a 00                	push   $0x0
  pushl $149
c0104179:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c010417e:	e9 5d fa ff ff       	jmp    c0103be0 <__alltraps>

c0104183 <vector150>:
.globl vector150
vector150:
  pushl $0
c0104183:	6a 00                	push   $0x0
  pushl $150
c0104185:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c010418a:	e9 51 fa ff ff       	jmp    c0103be0 <__alltraps>

c010418f <vector151>:
.globl vector151
vector151:
  pushl $0
c010418f:	6a 00                	push   $0x0
  pushl $151
c0104191:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0104196:	e9 45 fa ff ff       	jmp    c0103be0 <__alltraps>

c010419b <vector152>:
.globl vector152
vector152:
  pushl $0
c010419b:	6a 00                	push   $0x0
  pushl $152
c010419d:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01041a2:	e9 39 fa ff ff       	jmp    c0103be0 <__alltraps>

c01041a7 <vector153>:
.globl vector153
vector153:
  pushl $0
c01041a7:	6a 00                	push   $0x0
  pushl $153
c01041a9:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c01041ae:	e9 2d fa ff ff       	jmp    c0103be0 <__alltraps>

c01041b3 <vector154>:
.globl vector154
vector154:
  pushl $0
c01041b3:	6a 00                	push   $0x0
  pushl $154
c01041b5:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c01041ba:	e9 21 fa ff ff       	jmp    c0103be0 <__alltraps>

c01041bf <vector155>:
.globl vector155
vector155:
  pushl $0
c01041bf:	6a 00                	push   $0x0
  pushl $155
c01041c1:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01041c6:	e9 15 fa ff ff       	jmp    c0103be0 <__alltraps>

c01041cb <vector156>:
.globl vector156
vector156:
  pushl $0
c01041cb:	6a 00                	push   $0x0
  pushl $156
c01041cd:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c01041d2:	e9 09 fa ff ff       	jmp    c0103be0 <__alltraps>

c01041d7 <vector157>:
.globl vector157
vector157:
  pushl $0
c01041d7:	6a 00                	push   $0x0
  pushl $157
c01041d9:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01041de:	e9 fd f9 ff ff       	jmp    c0103be0 <__alltraps>

c01041e3 <vector158>:
.globl vector158
vector158:
  pushl $0
c01041e3:	6a 00                	push   $0x0
  pushl $158
c01041e5:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c01041ea:	e9 f1 f9 ff ff       	jmp    c0103be0 <__alltraps>

c01041ef <vector159>:
.globl vector159
vector159:
  pushl $0
c01041ef:	6a 00                	push   $0x0
  pushl $159
c01041f1:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c01041f6:	e9 e5 f9 ff ff       	jmp    c0103be0 <__alltraps>

c01041fb <vector160>:
.globl vector160
vector160:
  pushl $0
c01041fb:	6a 00                	push   $0x0
  pushl $160
c01041fd:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0104202:	e9 d9 f9 ff ff       	jmp    c0103be0 <__alltraps>

c0104207 <vector161>:
.globl vector161
vector161:
  pushl $0
c0104207:	6a 00                	push   $0x0
  pushl $161
c0104209:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c010420e:	e9 cd f9 ff ff       	jmp    c0103be0 <__alltraps>

c0104213 <vector162>:
.globl vector162
vector162:
  pushl $0
c0104213:	6a 00                	push   $0x0
  pushl $162
c0104215:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c010421a:	e9 c1 f9 ff ff       	jmp    c0103be0 <__alltraps>

c010421f <vector163>:
.globl vector163
vector163:
  pushl $0
c010421f:	6a 00                	push   $0x0
  pushl $163
c0104221:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0104226:	e9 b5 f9 ff ff       	jmp    c0103be0 <__alltraps>

c010422b <vector164>:
.globl vector164
vector164:
  pushl $0
c010422b:	6a 00                	push   $0x0
  pushl $164
c010422d:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0104232:	e9 a9 f9 ff ff       	jmp    c0103be0 <__alltraps>

c0104237 <vector165>:
.globl vector165
vector165:
  pushl $0
c0104237:	6a 00                	push   $0x0
  pushl $165
c0104239:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c010423e:	e9 9d f9 ff ff       	jmp    c0103be0 <__alltraps>

c0104243 <vector166>:
.globl vector166
vector166:
  pushl $0
c0104243:	6a 00                	push   $0x0
  pushl $166
c0104245:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c010424a:	e9 91 f9 ff ff       	jmp    c0103be0 <__alltraps>

c010424f <vector167>:
.globl vector167
vector167:
  pushl $0
c010424f:	6a 00                	push   $0x0
  pushl $167
c0104251:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0104256:	e9 85 f9 ff ff       	jmp    c0103be0 <__alltraps>

c010425b <vector168>:
.globl vector168
vector168:
  pushl $0
c010425b:	6a 00                	push   $0x0
  pushl $168
c010425d:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0104262:	e9 79 f9 ff ff       	jmp    c0103be0 <__alltraps>

c0104267 <vector169>:
.globl vector169
vector169:
  pushl $0
c0104267:	6a 00                	push   $0x0
  pushl $169
c0104269:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c010426e:	e9 6d f9 ff ff       	jmp    c0103be0 <__alltraps>

c0104273 <vector170>:
.globl vector170
vector170:
  pushl $0
c0104273:	6a 00                	push   $0x0
  pushl $170
c0104275:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c010427a:	e9 61 f9 ff ff       	jmp    c0103be0 <__alltraps>

c010427f <vector171>:
.globl vector171
vector171:
  pushl $0
c010427f:	6a 00                	push   $0x0
  pushl $171
c0104281:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0104286:	e9 55 f9 ff ff       	jmp    c0103be0 <__alltraps>

c010428b <vector172>:
.globl vector172
vector172:
  pushl $0
c010428b:	6a 00                	push   $0x0
  pushl $172
c010428d:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0104292:	e9 49 f9 ff ff       	jmp    c0103be0 <__alltraps>

c0104297 <vector173>:
.globl vector173
vector173:
  pushl $0
c0104297:	6a 00                	push   $0x0
  pushl $173
c0104299:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c010429e:	e9 3d f9 ff ff       	jmp    c0103be0 <__alltraps>

c01042a3 <vector174>:
.globl vector174
vector174:
  pushl $0
c01042a3:	6a 00                	push   $0x0
  pushl $174
c01042a5:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01042aa:	e9 31 f9 ff ff       	jmp    c0103be0 <__alltraps>

c01042af <vector175>:
.globl vector175
vector175:
  pushl $0
c01042af:	6a 00                	push   $0x0
  pushl $175
c01042b1:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01042b6:	e9 25 f9 ff ff       	jmp    c0103be0 <__alltraps>

c01042bb <vector176>:
.globl vector176
vector176:
  pushl $0
c01042bb:	6a 00                	push   $0x0
  pushl $176
c01042bd:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01042c2:	e9 19 f9 ff ff       	jmp    c0103be0 <__alltraps>

c01042c7 <vector177>:
.globl vector177
vector177:
  pushl $0
c01042c7:	6a 00                	push   $0x0
  pushl $177
c01042c9:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c01042ce:	e9 0d f9 ff ff       	jmp    c0103be0 <__alltraps>

c01042d3 <vector178>:
.globl vector178
vector178:
  pushl $0
c01042d3:	6a 00                	push   $0x0
  pushl $178
c01042d5:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c01042da:	e9 01 f9 ff ff       	jmp    c0103be0 <__alltraps>

c01042df <vector179>:
.globl vector179
vector179:
  pushl $0
c01042df:	6a 00                	push   $0x0
  pushl $179
c01042e1:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01042e6:	e9 f5 f8 ff ff       	jmp    c0103be0 <__alltraps>

c01042eb <vector180>:
.globl vector180
vector180:
  pushl $0
c01042eb:	6a 00                	push   $0x0
  pushl $180
c01042ed:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01042f2:	e9 e9 f8 ff ff       	jmp    c0103be0 <__alltraps>

c01042f7 <vector181>:
.globl vector181
vector181:
  pushl $0
c01042f7:	6a 00                	push   $0x0
  pushl $181
c01042f9:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01042fe:	e9 dd f8 ff ff       	jmp    c0103be0 <__alltraps>

c0104303 <vector182>:
.globl vector182
vector182:
  pushl $0
c0104303:	6a 00                	push   $0x0
  pushl $182
c0104305:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c010430a:	e9 d1 f8 ff ff       	jmp    c0103be0 <__alltraps>

c010430f <vector183>:
.globl vector183
vector183:
  pushl $0
c010430f:	6a 00                	push   $0x0
  pushl $183
c0104311:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0104316:	e9 c5 f8 ff ff       	jmp    c0103be0 <__alltraps>

c010431b <vector184>:
.globl vector184
vector184:
  pushl $0
c010431b:	6a 00                	push   $0x0
  pushl $184
c010431d:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0104322:	e9 b9 f8 ff ff       	jmp    c0103be0 <__alltraps>

c0104327 <vector185>:
.globl vector185
vector185:
  pushl $0
c0104327:	6a 00                	push   $0x0
  pushl $185
c0104329:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c010432e:	e9 ad f8 ff ff       	jmp    c0103be0 <__alltraps>

c0104333 <vector186>:
.globl vector186
vector186:
  pushl $0
c0104333:	6a 00                	push   $0x0
  pushl $186
c0104335:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c010433a:	e9 a1 f8 ff ff       	jmp    c0103be0 <__alltraps>

c010433f <vector187>:
.globl vector187
vector187:
  pushl $0
c010433f:	6a 00                	push   $0x0
  pushl $187
c0104341:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0104346:	e9 95 f8 ff ff       	jmp    c0103be0 <__alltraps>

c010434b <vector188>:
.globl vector188
vector188:
  pushl $0
c010434b:	6a 00                	push   $0x0
  pushl $188
c010434d:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0104352:	e9 89 f8 ff ff       	jmp    c0103be0 <__alltraps>

c0104357 <vector189>:
.globl vector189
vector189:
  pushl $0
c0104357:	6a 00                	push   $0x0
  pushl $189
c0104359:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c010435e:	e9 7d f8 ff ff       	jmp    c0103be0 <__alltraps>

c0104363 <vector190>:
.globl vector190
vector190:
  pushl $0
c0104363:	6a 00                	push   $0x0
  pushl $190
c0104365:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010436a:	e9 71 f8 ff ff       	jmp    c0103be0 <__alltraps>

c010436f <vector191>:
.globl vector191
vector191:
  pushl $0
c010436f:	6a 00                	push   $0x0
  pushl $191
c0104371:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0104376:	e9 65 f8 ff ff       	jmp    c0103be0 <__alltraps>

c010437b <vector192>:
.globl vector192
vector192:
  pushl $0
c010437b:	6a 00                	push   $0x0
  pushl $192
c010437d:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0104382:	e9 59 f8 ff ff       	jmp    c0103be0 <__alltraps>

c0104387 <vector193>:
.globl vector193
vector193:
  pushl $0
c0104387:	6a 00                	push   $0x0
  pushl $193
c0104389:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c010438e:	e9 4d f8 ff ff       	jmp    c0103be0 <__alltraps>

c0104393 <vector194>:
.globl vector194
vector194:
  pushl $0
c0104393:	6a 00                	push   $0x0
  pushl $194
c0104395:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010439a:	e9 41 f8 ff ff       	jmp    c0103be0 <__alltraps>

c010439f <vector195>:
.globl vector195
vector195:
  pushl $0
c010439f:	6a 00                	push   $0x0
  pushl $195
c01043a1:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01043a6:	e9 35 f8 ff ff       	jmp    c0103be0 <__alltraps>

c01043ab <vector196>:
.globl vector196
vector196:
  pushl $0
c01043ab:	6a 00                	push   $0x0
  pushl $196
c01043ad:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01043b2:	e9 29 f8 ff ff       	jmp    c0103be0 <__alltraps>

c01043b7 <vector197>:
.globl vector197
vector197:
  pushl $0
c01043b7:	6a 00                	push   $0x0
  pushl $197
c01043b9:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01043be:	e9 1d f8 ff ff       	jmp    c0103be0 <__alltraps>

c01043c3 <vector198>:
.globl vector198
vector198:
  pushl $0
c01043c3:	6a 00                	push   $0x0
  pushl $198
c01043c5:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01043ca:	e9 11 f8 ff ff       	jmp    c0103be0 <__alltraps>

c01043cf <vector199>:
.globl vector199
vector199:
  pushl $0
c01043cf:	6a 00                	push   $0x0
  pushl $199
c01043d1:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01043d6:	e9 05 f8 ff ff       	jmp    c0103be0 <__alltraps>

c01043db <vector200>:
.globl vector200
vector200:
  pushl $0
c01043db:	6a 00                	push   $0x0
  pushl $200
c01043dd:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01043e2:	e9 f9 f7 ff ff       	jmp    c0103be0 <__alltraps>

c01043e7 <vector201>:
.globl vector201
vector201:
  pushl $0
c01043e7:	6a 00                	push   $0x0
  pushl $201
c01043e9:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01043ee:	e9 ed f7 ff ff       	jmp    c0103be0 <__alltraps>

c01043f3 <vector202>:
.globl vector202
vector202:
  pushl $0
c01043f3:	6a 00                	push   $0x0
  pushl $202
c01043f5:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01043fa:	e9 e1 f7 ff ff       	jmp    c0103be0 <__alltraps>

c01043ff <vector203>:
.globl vector203
vector203:
  pushl $0
c01043ff:	6a 00                	push   $0x0
  pushl $203
c0104401:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0104406:	e9 d5 f7 ff ff       	jmp    c0103be0 <__alltraps>

c010440b <vector204>:
.globl vector204
vector204:
  pushl $0
c010440b:	6a 00                	push   $0x0
  pushl $204
c010440d:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0104412:	e9 c9 f7 ff ff       	jmp    c0103be0 <__alltraps>

c0104417 <vector205>:
.globl vector205
vector205:
  pushl $0
c0104417:	6a 00                	push   $0x0
  pushl $205
c0104419:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c010441e:	e9 bd f7 ff ff       	jmp    c0103be0 <__alltraps>

c0104423 <vector206>:
.globl vector206
vector206:
  pushl $0
c0104423:	6a 00                	push   $0x0
  pushl $206
c0104425:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c010442a:	e9 b1 f7 ff ff       	jmp    c0103be0 <__alltraps>

c010442f <vector207>:
.globl vector207
vector207:
  pushl $0
c010442f:	6a 00                	push   $0x0
  pushl $207
c0104431:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0104436:	e9 a5 f7 ff ff       	jmp    c0103be0 <__alltraps>

c010443b <vector208>:
.globl vector208
vector208:
  pushl $0
c010443b:	6a 00                	push   $0x0
  pushl $208
c010443d:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0104442:	e9 99 f7 ff ff       	jmp    c0103be0 <__alltraps>

c0104447 <vector209>:
.globl vector209
vector209:
  pushl $0
c0104447:	6a 00                	push   $0x0
  pushl $209
c0104449:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c010444e:	e9 8d f7 ff ff       	jmp    c0103be0 <__alltraps>

c0104453 <vector210>:
.globl vector210
vector210:
  pushl $0
c0104453:	6a 00                	push   $0x0
  pushl $210
c0104455:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c010445a:	e9 81 f7 ff ff       	jmp    c0103be0 <__alltraps>

c010445f <vector211>:
.globl vector211
vector211:
  pushl $0
c010445f:	6a 00                	push   $0x0
  pushl $211
c0104461:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0104466:	e9 75 f7 ff ff       	jmp    c0103be0 <__alltraps>

c010446b <vector212>:
.globl vector212
vector212:
  pushl $0
c010446b:	6a 00                	push   $0x0
  pushl $212
c010446d:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0104472:	e9 69 f7 ff ff       	jmp    c0103be0 <__alltraps>

c0104477 <vector213>:
.globl vector213
vector213:
  pushl $0
c0104477:	6a 00                	push   $0x0
  pushl $213
c0104479:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010447e:	e9 5d f7 ff ff       	jmp    c0103be0 <__alltraps>

c0104483 <vector214>:
.globl vector214
vector214:
  pushl $0
c0104483:	6a 00                	push   $0x0
  pushl $214
c0104485:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010448a:	e9 51 f7 ff ff       	jmp    c0103be0 <__alltraps>

c010448f <vector215>:
.globl vector215
vector215:
  pushl $0
c010448f:	6a 00                	push   $0x0
  pushl $215
c0104491:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0104496:	e9 45 f7 ff ff       	jmp    c0103be0 <__alltraps>

c010449b <vector216>:
.globl vector216
vector216:
  pushl $0
c010449b:	6a 00                	push   $0x0
  pushl $216
c010449d:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01044a2:	e9 39 f7 ff ff       	jmp    c0103be0 <__alltraps>

c01044a7 <vector217>:
.globl vector217
vector217:
  pushl $0
c01044a7:	6a 00                	push   $0x0
  pushl $217
c01044a9:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01044ae:	e9 2d f7 ff ff       	jmp    c0103be0 <__alltraps>

c01044b3 <vector218>:
.globl vector218
vector218:
  pushl $0
c01044b3:	6a 00                	push   $0x0
  pushl $218
c01044b5:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01044ba:	e9 21 f7 ff ff       	jmp    c0103be0 <__alltraps>

c01044bf <vector219>:
.globl vector219
vector219:
  pushl $0
c01044bf:	6a 00                	push   $0x0
  pushl $219
c01044c1:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01044c6:	e9 15 f7 ff ff       	jmp    c0103be0 <__alltraps>

c01044cb <vector220>:
.globl vector220
vector220:
  pushl $0
c01044cb:	6a 00                	push   $0x0
  pushl $220
c01044cd:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01044d2:	e9 09 f7 ff ff       	jmp    c0103be0 <__alltraps>

c01044d7 <vector221>:
.globl vector221
vector221:
  pushl $0
c01044d7:	6a 00                	push   $0x0
  pushl $221
c01044d9:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01044de:	e9 fd f6 ff ff       	jmp    c0103be0 <__alltraps>

c01044e3 <vector222>:
.globl vector222
vector222:
  pushl $0
c01044e3:	6a 00                	push   $0x0
  pushl $222
c01044e5:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01044ea:	e9 f1 f6 ff ff       	jmp    c0103be0 <__alltraps>

c01044ef <vector223>:
.globl vector223
vector223:
  pushl $0
c01044ef:	6a 00                	push   $0x0
  pushl $223
c01044f1:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01044f6:	e9 e5 f6 ff ff       	jmp    c0103be0 <__alltraps>

c01044fb <vector224>:
.globl vector224
vector224:
  pushl $0
c01044fb:	6a 00                	push   $0x0
  pushl $224
c01044fd:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0104502:	e9 d9 f6 ff ff       	jmp    c0103be0 <__alltraps>

c0104507 <vector225>:
.globl vector225
vector225:
  pushl $0
c0104507:	6a 00                	push   $0x0
  pushl $225
c0104509:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010450e:	e9 cd f6 ff ff       	jmp    c0103be0 <__alltraps>

c0104513 <vector226>:
.globl vector226
vector226:
  pushl $0
c0104513:	6a 00                	push   $0x0
  pushl $226
c0104515:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c010451a:	e9 c1 f6 ff ff       	jmp    c0103be0 <__alltraps>

c010451f <vector227>:
.globl vector227
vector227:
  pushl $0
c010451f:	6a 00                	push   $0x0
  pushl $227
c0104521:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0104526:	e9 b5 f6 ff ff       	jmp    c0103be0 <__alltraps>

c010452b <vector228>:
.globl vector228
vector228:
  pushl $0
c010452b:	6a 00                	push   $0x0
  pushl $228
c010452d:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0104532:	e9 a9 f6 ff ff       	jmp    c0103be0 <__alltraps>

c0104537 <vector229>:
.globl vector229
vector229:
  pushl $0
c0104537:	6a 00                	push   $0x0
  pushl $229
c0104539:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c010453e:	e9 9d f6 ff ff       	jmp    c0103be0 <__alltraps>

c0104543 <vector230>:
.globl vector230
vector230:
  pushl $0
c0104543:	6a 00                	push   $0x0
  pushl $230
c0104545:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010454a:	e9 91 f6 ff ff       	jmp    c0103be0 <__alltraps>

c010454f <vector231>:
.globl vector231
vector231:
  pushl $0
c010454f:	6a 00                	push   $0x0
  pushl $231
c0104551:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0104556:	e9 85 f6 ff ff       	jmp    c0103be0 <__alltraps>

c010455b <vector232>:
.globl vector232
vector232:
  pushl $0
c010455b:	6a 00                	push   $0x0
  pushl $232
c010455d:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0104562:	e9 79 f6 ff ff       	jmp    c0103be0 <__alltraps>

c0104567 <vector233>:
.globl vector233
vector233:
  pushl $0
c0104567:	6a 00                	push   $0x0
  pushl $233
c0104569:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c010456e:	e9 6d f6 ff ff       	jmp    c0103be0 <__alltraps>

c0104573 <vector234>:
.globl vector234
vector234:
  pushl $0
c0104573:	6a 00                	push   $0x0
  pushl $234
c0104575:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010457a:	e9 61 f6 ff ff       	jmp    c0103be0 <__alltraps>

c010457f <vector235>:
.globl vector235
vector235:
  pushl $0
c010457f:	6a 00                	push   $0x0
  pushl $235
c0104581:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0104586:	e9 55 f6 ff ff       	jmp    c0103be0 <__alltraps>

c010458b <vector236>:
.globl vector236
vector236:
  pushl $0
c010458b:	6a 00                	push   $0x0
  pushl $236
c010458d:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0104592:	e9 49 f6 ff ff       	jmp    c0103be0 <__alltraps>

c0104597 <vector237>:
.globl vector237
vector237:
  pushl $0
c0104597:	6a 00                	push   $0x0
  pushl $237
c0104599:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010459e:	e9 3d f6 ff ff       	jmp    c0103be0 <__alltraps>

c01045a3 <vector238>:
.globl vector238
vector238:
  pushl $0
c01045a3:	6a 00                	push   $0x0
  pushl $238
c01045a5:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01045aa:	e9 31 f6 ff ff       	jmp    c0103be0 <__alltraps>

c01045af <vector239>:
.globl vector239
vector239:
  pushl $0
c01045af:	6a 00                	push   $0x0
  pushl $239
c01045b1:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01045b6:	e9 25 f6 ff ff       	jmp    c0103be0 <__alltraps>

c01045bb <vector240>:
.globl vector240
vector240:
  pushl $0
c01045bb:	6a 00                	push   $0x0
  pushl $240
c01045bd:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01045c2:	e9 19 f6 ff ff       	jmp    c0103be0 <__alltraps>

c01045c7 <vector241>:
.globl vector241
vector241:
  pushl $0
c01045c7:	6a 00                	push   $0x0
  pushl $241
c01045c9:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01045ce:	e9 0d f6 ff ff       	jmp    c0103be0 <__alltraps>

c01045d3 <vector242>:
.globl vector242
vector242:
  pushl $0
c01045d3:	6a 00                	push   $0x0
  pushl $242
c01045d5:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01045da:	e9 01 f6 ff ff       	jmp    c0103be0 <__alltraps>

c01045df <vector243>:
.globl vector243
vector243:
  pushl $0
c01045df:	6a 00                	push   $0x0
  pushl $243
c01045e1:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01045e6:	e9 f5 f5 ff ff       	jmp    c0103be0 <__alltraps>

c01045eb <vector244>:
.globl vector244
vector244:
  pushl $0
c01045eb:	6a 00                	push   $0x0
  pushl $244
c01045ed:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01045f2:	e9 e9 f5 ff ff       	jmp    c0103be0 <__alltraps>

c01045f7 <vector245>:
.globl vector245
vector245:
  pushl $0
c01045f7:	6a 00                	push   $0x0
  pushl $245
c01045f9:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01045fe:	e9 dd f5 ff ff       	jmp    c0103be0 <__alltraps>

c0104603 <vector246>:
.globl vector246
vector246:
  pushl $0
c0104603:	6a 00                	push   $0x0
  pushl $246
c0104605:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c010460a:	e9 d1 f5 ff ff       	jmp    c0103be0 <__alltraps>

c010460f <vector247>:
.globl vector247
vector247:
  pushl $0
c010460f:	6a 00                	push   $0x0
  pushl $247
c0104611:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0104616:	e9 c5 f5 ff ff       	jmp    c0103be0 <__alltraps>

c010461b <vector248>:
.globl vector248
vector248:
  pushl $0
c010461b:	6a 00                	push   $0x0
  pushl $248
c010461d:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0104622:	e9 b9 f5 ff ff       	jmp    c0103be0 <__alltraps>

c0104627 <vector249>:
.globl vector249
vector249:
  pushl $0
c0104627:	6a 00                	push   $0x0
  pushl $249
c0104629:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c010462e:	e9 ad f5 ff ff       	jmp    c0103be0 <__alltraps>

c0104633 <vector250>:
.globl vector250
vector250:
  pushl $0
c0104633:	6a 00                	push   $0x0
  pushl $250
c0104635:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c010463a:	e9 a1 f5 ff ff       	jmp    c0103be0 <__alltraps>

c010463f <vector251>:
.globl vector251
vector251:
  pushl $0
c010463f:	6a 00                	push   $0x0
  pushl $251
c0104641:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0104646:	e9 95 f5 ff ff       	jmp    c0103be0 <__alltraps>

c010464b <vector252>:
.globl vector252
vector252:
  pushl $0
c010464b:	6a 00                	push   $0x0
  pushl $252
c010464d:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0104652:	e9 89 f5 ff ff       	jmp    c0103be0 <__alltraps>

c0104657 <vector253>:
.globl vector253
vector253:
  pushl $0
c0104657:	6a 00                	push   $0x0
  pushl $253
c0104659:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c010465e:	e9 7d f5 ff ff       	jmp    c0103be0 <__alltraps>

c0104663 <vector254>:
.globl vector254
vector254:
  pushl $0
c0104663:	6a 00                	push   $0x0
  pushl $254
c0104665:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c010466a:	e9 71 f5 ff ff       	jmp    c0103be0 <__alltraps>

c010466f <vector255>:
.globl vector255
vector255:
  pushl $0
c010466f:	6a 00                	push   $0x0
  pushl $255
c0104671:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0104676:	e9 65 f5 ff ff       	jmp    c0103be0 <__alltraps>

c010467b <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010467b:	55                   	push   %ebp
c010467c:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010467e:	8b 55 08             	mov    0x8(%ebp),%edx
c0104681:	a1 2c bb 12 c0       	mov    0xc012bb2c,%eax
c0104686:	29 c2                	sub    %eax,%edx
c0104688:	89 d0                	mov    %edx,%eax
c010468a:	c1 f8 02             	sar    $0x2,%eax
c010468d:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0104693:	5d                   	pop    %ebp
c0104694:	c3                   	ret    

c0104695 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0104695:	55                   	push   %ebp
c0104696:	89 e5                	mov    %esp,%ebp
c0104698:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010469b:	8b 45 08             	mov    0x8(%ebp),%eax
c010469e:	89 04 24             	mov    %eax,(%esp)
c01046a1:	e8 d5 ff ff ff       	call   c010467b <page2ppn>
c01046a6:	c1 e0 0c             	shl    $0xc,%eax
}
c01046a9:	c9                   	leave  
c01046aa:	c3                   	ret    

c01046ab <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c01046ab:	55                   	push   %ebp
c01046ac:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01046ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01046b1:	8b 00                	mov    (%eax),%eax
}
c01046b3:	5d                   	pop    %ebp
c01046b4:	c3                   	ret    

c01046b5 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01046b5:	55                   	push   %ebp
c01046b6:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01046b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01046bb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01046be:	89 10                	mov    %edx,(%eax)
}
c01046c0:	5d                   	pop    %ebp
c01046c1:	c3                   	ret    

c01046c2 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01046c2:	55                   	push   %ebp
c01046c3:	89 e5                	mov    %esp,%ebp
c01046c5:	83 ec 10             	sub    $0x10,%esp
c01046c8:	c7 45 fc 18 bb 12 c0 	movl   $0xc012bb18,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01046cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01046d2:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01046d5:	89 50 04             	mov    %edx,0x4(%eax)
c01046d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01046db:	8b 50 04             	mov    0x4(%eax),%edx
c01046de:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01046e1:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01046e3:	c7 05 20 bb 12 c0 00 	movl   $0x0,0xc012bb20
c01046ea:	00 00 00 
}
c01046ed:	c9                   	leave  
c01046ee:	c3                   	ret    

c01046ef <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01046ef:	55                   	push   %ebp
c01046f0:	89 e5                	mov    %esp,%ebp
c01046f2:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01046f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01046f9:	75 24                	jne    c010471f <default_init_memmap+0x30>
c01046fb:	c7 44 24 0c 50 bd 10 	movl   $0xc010bd50,0xc(%esp)
c0104702:	c0 
c0104703:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c010470a:	c0 
c010470b:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
c0104712:	00 
c0104713:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c010471a:	e8 41 da ff ff       	call   c0102160 <__panic>
    struct Page *p = base;
c010471f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104722:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0104725:	e9 dc 00 00 00       	jmp    c0104806 <default_init_memmap+0x117>
        assert(PageReserved(p));
c010472a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010472d:	83 c0 04             	add    $0x4,%eax
c0104730:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0104737:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010473a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010473d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104740:	0f a3 10             	bt     %edx,(%eax)
c0104743:	19 c0                	sbb    %eax,%eax
c0104745:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0104748:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010474c:	0f 95 c0             	setne  %al
c010474f:	0f b6 c0             	movzbl %al,%eax
c0104752:	85 c0                	test   %eax,%eax
c0104754:	75 24                	jne    c010477a <default_init_memmap+0x8b>
c0104756:	c7 44 24 0c 81 bd 10 	movl   $0xc010bd81,0xc(%esp)
c010475d:	c0 
c010475e:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104765:	c0 
c0104766:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c010476d:	00 
c010476e:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104775:	e8 e6 d9 ff ff       	call   c0102160 <__panic>
        p->flags = 0;
c010477a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010477d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        SetPageProperty(p);
c0104784:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104787:	83 c0 04             	add    $0x4,%eax
c010478a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0104791:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104794:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104797:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010479a:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
c010479d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047a0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        set_page_ref(p, 0);
c01047a7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01047ae:	00 
c01047af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047b2:	89 04 24             	mov    %eax,(%esp)
c01047b5:	e8 fb fe ff ff       	call   c01046b5 <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
c01047ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047bd:	83 c0 10             	add    $0x10,%eax
c01047c0:	c7 45 dc 18 bb 12 c0 	movl   $0xc012bb18,-0x24(%ebp)
c01047c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01047ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01047cd:	8b 00                	mov    (%eax),%eax
c01047cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01047d2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01047d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01047d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01047db:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01047de:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01047e1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01047e4:	89 10                	mov    %edx,(%eax)
c01047e6:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01047e9:	8b 10                	mov    (%eax),%edx
c01047eb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01047ee:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01047f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01047f4:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01047f7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01047fa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01047fd:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104800:	89 10                	mov    %edx,(%eax)

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0104802:	83 45 f4 24          	addl   $0x24,-0xc(%ebp)
c0104806:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104809:	89 d0                	mov    %edx,%eax
c010480b:	c1 e0 03             	shl    $0x3,%eax
c010480e:	01 d0                	add    %edx,%eax
c0104810:	c1 e0 02             	shl    $0x2,%eax
c0104813:	89 c2                	mov    %eax,%edx
c0104815:	8b 45 08             	mov    0x8(%ebp),%eax
c0104818:	01 d0                	add    %edx,%eax
c010481a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010481d:	0f 85 07 ff ff ff    	jne    c010472a <default_init_memmap+0x3b>
        SetPageProperty(p);
        p->property = 0;
        set_page_ref(p, 0);
        list_add_before(&free_list, &(p->page_link));
    }
    nr_free += n;
c0104823:	8b 15 20 bb 12 c0    	mov    0xc012bb20,%edx
c0104829:	8b 45 0c             	mov    0xc(%ebp),%eax
c010482c:	01 d0                	add    %edx,%eax
c010482e:	a3 20 bb 12 c0       	mov    %eax,0xc012bb20
    //first block
    base->property = n;
c0104833:	8b 45 08             	mov    0x8(%ebp),%eax
c0104836:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104839:	89 50 08             	mov    %edx,0x8(%eax)
}
c010483c:	c9                   	leave  
c010483d:	c3                   	ret    

c010483e <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c010483e:	55                   	push   %ebp
c010483f:	89 e5                	mov    %esp,%ebp
c0104841:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0104844:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104848:	75 24                	jne    c010486e <default_alloc_pages+0x30>
c010484a:	c7 44 24 0c 50 bd 10 	movl   $0xc010bd50,0xc(%esp)
c0104851:	c0 
c0104852:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104859:	c0 
c010485a:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
c0104861:	00 
c0104862:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104869:	e8 f2 d8 ff ff       	call   c0102160 <__panic>
    if (n > nr_free) {
c010486e:	a1 20 bb 12 c0       	mov    0xc012bb20,%eax
c0104873:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104876:	73 0a                	jae    c0104882 <default_alloc_pages+0x44>
        return NULL;
c0104878:	b8 00 00 00 00       	mov    $0x0,%eax
c010487d:	e9 37 01 00 00       	jmp    c01049b9 <default_alloc_pages+0x17b>
    }
    list_entry_t *le, *len;
    le = &free_list;
c0104882:	c7 45 f4 18 bb 12 c0 	movl   $0xc012bb18,-0xc(%ebp)

    while((le=list_next(le)) != &free_list) {
c0104889:	e9 0a 01 00 00       	jmp    c0104998 <default_alloc_pages+0x15a>
      struct Page *p = le2page(le, page_link);
c010488e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104891:	83 e8 10             	sub    $0x10,%eax
c0104894:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(p->property >= n){
c0104897:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010489a:	8b 40 08             	mov    0x8(%eax),%eax
c010489d:	3b 45 08             	cmp    0x8(%ebp),%eax
c01048a0:	0f 82 f2 00 00 00    	jb     c0104998 <default_alloc_pages+0x15a>
        int i;
        for(i=0;i<n;i++){
c01048a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01048ad:	eb 7c                	jmp    c010492b <default_alloc_pages+0xed>
c01048af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01048b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01048b8:	8b 40 04             	mov    0x4(%eax),%eax
          len = list_next(le);
c01048bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
          struct Page *pp = le2page(le, page_link);
c01048be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048c1:	83 e8 10             	sub    $0x10,%eax
c01048c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
          SetPageReserved(pp);
c01048c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01048ca:	83 c0 04             	add    $0x4,%eax
c01048cd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01048d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01048d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01048da:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01048dd:	0f ab 10             	bts    %edx,(%eax)
          ClearPageProperty(pp);
c01048e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01048e3:	83 c0 04             	add    $0x4,%eax
c01048e6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c01048ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01048f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01048f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01048f6:	0f b3 10             	btr    %edx,(%eax)
c01048f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048fc:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01048ff:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104902:	8b 40 04             	mov    0x4(%eax),%eax
c0104905:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104908:	8b 12                	mov    (%edx),%edx
c010490a:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010490d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104910:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104913:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104916:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104919:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010491c:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010491f:	89 10                	mov    %edx,(%eax)
          list_del(le);
          le = len;
c0104921:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104924:	89 45 f4             	mov    %eax,-0xc(%ebp)

    while((le=list_next(le)) != &free_list) {
      struct Page *p = le2page(le, page_link);
      if(p->property >= n){
        int i;
        for(i=0;i<n;i++){
c0104927:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
c010492b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010492e:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104931:	0f 82 78 ff ff ff    	jb     c01048af <default_alloc_pages+0x71>
          SetPageReserved(pp);
          ClearPageProperty(pp);
          list_del(le);
          le = len;
        }
        if(p->property>n){
c0104937:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010493a:	8b 40 08             	mov    0x8(%eax),%eax
c010493d:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104940:	76 12                	jbe    c0104954 <default_alloc_pages+0x116>
          (le2page(le,page_link))->property = p->property - n;
c0104942:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104945:	8d 50 f0             	lea    -0x10(%eax),%edx
c0104948:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010494b:	8b 40 08             	mov    0x8(%eax),%eax
c010494e:	2b 45 08             	sub    0x8(%ebp),%eax
c0104951:	89 42 08             	mov    %eax,0x8(%edx)
        }
        ClearPageProperty(p);
c0104954:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104957:	83 c0 04             	add    $0x4,%eax
c010495a:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104961:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0104964:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104967:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010496a:	0f b3 10             	btr    %edx,(%eax)
        SetPageReserved(p);
c010496d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104970:	83 c0 04             	add    $0x4,%eax
c0104973:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
c010497a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010497d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104980:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0104983:	0f ab 10             	bts    %edx,(%eax)
        nr_free -= n;
c0104986:	a1 20 bb 12 c0       	mov    0xc012bb20,%eax
c010498b:	2b 45 08             	sub    0x8(%ebp),%eax
c010498e:	a3 20 bb 12 c0       	mov    %eax,0xc012bb20
        return p;
c0104993:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104996:	eb 21                	jmp    c01049b9 <default_alloc_pages+0x17b>
c0104998:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010499b:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010499e:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01049a1:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    list_entry_t *le, *len;
    le = &free_list;

    while((le=list_next(le)) != &free_list) {
c01049a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01049a7:	81 7d f4 18 bb 12 c0 	cmpl   $0xc012bb18,-0xc(%ebp)
c01049ae:	0f 85 da fe ff ff    	jne    c010488e <default_alloc_pages+0x50>
        SetPageReserved(p);
        nr_free -= n;
        return p;
      }
    }
    return NULL;
c01049b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01049b9:	c9                   	leave  
c01049ba:	c3                   	ret    

c01049bb <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c01049bb:	55                   	push   %ebp
c01049bc:	89 e5                	mov    %esp,%ebp
c01049be:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01049c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01049c5:	75 24                	jne    c01049eb <default_free_pages+0x30>
c01049c7:	c7 44 24 0c 50 bd 10 	movl   $0xc010bd50,0xc(%esp)
c01049ce:	c0 
c01049cf:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c01049d6:	c0 
c01049d7:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
c01049de:	00 
c01049df:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c01049e6:	e8 75 d7 ff ff       	call   c0102160 <__panic>
    assert(PageReserved(base));
c01049eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01049ee:	83 c0 04             	add    $0x4,%eax
c01049f1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01049f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01049fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01049fe:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104a01:	0f a3 10             	bt     %edx,(%eax)
c0104a04:	19 c0                	sbb    %eax,%eax
c0104a06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0104a09:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104a0d:	0f 95 c0             	setne  %al
c0104a10:	0f b6 c0             	movzbl %al,%eax
c0104a13:	85 c0                	test   %eax,%eax
c0104a15:	75 24                	jne    c0104a3b <default_free_pages+0x80>
c0104a17:	c7 44 24 0c 91 bd 10 	movl   $0xc010bd91,0xc(%esp)
c0104a1e:	c0 
c0104a1f:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104a26:	c0 
c0104a27:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
c0104a2e:	00 
c0104a2f:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104a36:	e8 25 d7 ff ff       	call   c0102160 <__panic>

    list_entry_t *le = &free_list;
c0104a3b:	c7 45 f4 18 bb 12 c0 	movl   $0xc012bb18,-0xc(%ebp)
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
c0104a42:	eb 13                	jmp    c0104a57 <default_free_pages+0x9c>
      p = le2page(le, page_link);
c0104a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a47:	83 e8 10             	sub    $0x10,%eax
c0104a4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(p>base){
c0104a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a50:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104a53:	76 02                	jbe    c0104a57 <default_free_pages+0x9c>
        break;
c0104a55:	eb 18                	jmp    c0104a6f <default_free_pages+0xb4>
c0104a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a5a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104a5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104a60:	8b 40 04             	mov    0x4(%eax),%eax
    assert(n > 0);
    assert(PageReserved(base));

    list_entry_t *le = &free_list;
    struct Page * p;
    while((le=list_next(le)) != &free_list) {
c0104a63:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104a66:	81 7d f4 18 bb 12 c0 	cmpl   $0xc012bb18,-0xc(%ebp)
c0104a6d:	75 d5                	jne    c0104a44 <default_free_pages+0x89>
      if(p>base){
        break;
      }
    }
    //list_add_before(le, base->page_link);
    for(p=base;p<base+n;p++){
c0104a6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a72:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a75:	eb 4b                	jmp    c0104ac2 <default_free_pages+0x107>
      list_add_before(le, &(p->page_link));
c0104a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a7a:	8d 50 10             	lea    0x10(%eax),%edx
c0104a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a80:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104a83:	89 55 d8             	mov    %edx,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0104a86:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104a89:	8b 00                	mov    (%eax),%eax
c0104a8b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104a8e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104a91:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104a94:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104a97:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104a9a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104a9d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104aa0:	89 10                	mov    %edx,(%eax)
c0104aa2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104aa5:	8b 10                	mov    (%eax),%edx
c0104aa7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104aaa:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104aad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104ab0:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104ab3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104ab6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104ab9:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104abc:	89 10                	mov    %edx,(%eax)
      if(p>base){
        break;
      }
    }
    //list_add_before(le, base->page_link);
    for(p=base;p<base+n;p++){
c0104abe:	83 45 f0 24          	addl   $0x24,-0x10(%ebp)
c0104ac2:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104ac5:	89 d0                	mov    %edx,%eax
c0104ac7:	c1 e0 03             	shl    $0x3,%eax
c0104aca:	01 d0                	add    %edx,%eax
c0104acc:	c1 e0 02             	shl    $0x2,%eax
c0104acf:	89 c2                	mov    %eax,%edx
c0104ad1:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ad4:	01 d0                	add    %edx,%eax
c0104ad6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104ad9:	77 9c                	ja     c0104a77 <default_free_pages+0xbc>
      list_add_before(le, &(p->page_link));
    }
    base->flags = 0;
c0104adb:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ade:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    set_page_ref(base, 0);
c0104ae5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104aec:	00 
c0104aed:	8b 45 08             	mov    0x8(%ebp),%eax
c0104af0:	89 04 24             	mov    %eax,(%esp)
c0104af3:	e8 bd fb ff ff       	call   c01046b5 <set_page_ref>
    ClearPageProperty(base);
c0104af8:	8b 45 08             	mov    0x8(%ebp),%eax
c0104afb:	83 c0 04             	add    $0x4,%eax
c0104afe:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0104b05:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104b08:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104b0b:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0104b0e:	0f b3 10             	btr    %edx,(%eax)
    SetPageProperty(base);
c0104b11:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b14:	83 c0 04             	add    $0x4,%eax
c0104b17:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104b1e:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104b21:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104b24:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104b27:	0f ab 10             	bts    %edx,(%eax)
    base->property = n;
c0104b2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b2d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104b30:	89 50 08             	mov    %edx,0x8(%eax)
    
    p = le2page(le,page_link) ;
c0104b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b36:	83 e8 10             	sub    $0x10,%eax
c0104b39:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if( base+n == p ){
c0104b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104b3f:	89 d0                	mov    %edx,%eax
c0104b41:	c1 e0 03             	shl    $0x3,%eax
c0104b44:	01 d0                	add    %edx,%eax
c0104b46:	c1 e0 02             	shl    $0x2,%eax
c0104b49:	89 c2                	mov    %eax,%edx
c0104b4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b4e:	01 d0                	add    %edx,%eax
c0104b50:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104b53:	75 1e                	jne    c0104b73 <default_free_pages+0x1b8>
      base->property += p->property;
c0104b55:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b58:	8b 50 08             	mov    0x8(%eax),%edx
c0104b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b5e:	8b 40 08             	mov    0x8(%eax),%eax
c0104b61:	01 c2                	add    %eax,%edx
c0104b63:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b66:	89 50 08             	mov    %edx,0x8(%eax)
      p->property = 0;
c0104b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b6c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    le = list_prev(&(base->page_link));
c0104b73:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b76:	83 c0 10             	add    $0x10,%eax
c0104b79:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c0104b7c:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104b7f:	8b 00                	mov    (%eax),%eax
c0104b81:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
c0104b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b87:	83 e8 10             	sub    $0x10,%eax
c0104b8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(le!=&free_list && p==base-1){
c0104b8d:	81 7d f4 18 bb 12 c0 	cmpl   $0xc012bb18,-0xc(%ebp)
c0104b94:	74 57                	je     c0104bed <default_free_pages+0x232>
c0104b96:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b99:	83 e8 24             	sub    $0x24,%eax
c0104b9c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104b9f:	75 4c                	jne    c0104bed <default_free_pages+0x232>
      while(le!=&free_list){
c0104ba1:	eb 41                	jmp    c0104be4 <default_free_pages+0x229>
        if(p->property){
c0104ba3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ba6:	8b 40 08             	mov    0x8(%eax),%eax
c0104ba9:	85 c0                	test   %eax,%eax
c0104bab:	74 20                	je     c0104bcd <default_free_pages+0x212>
          p->property += base->property;
c0104bad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bb0:	8b 50 08             	mov    0x8(%eax),%edx
c0104bb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bb6:	8b 40 08             	mov    0x8(%eax),%eax
c0104bb9:	01 c2                	add    %eax,%edx
c0104bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bbe:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
c0104bc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bc4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          break;
c0104bcb:	eb 20                	jmp    c0104bed <default_free_pages+0x232>
c0104bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bd0:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0104bd3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104bd6:	8b 00                	mov    (%eax),%eax
        }
        le = list_prev(le);
c0104bd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
        p = le2page(le,page_link);
c0104bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bde:	83 e8 10             	sub    $0x10,%eax
c0104be1:	89 45 f0             	mov    %eax,-0x10(%ebp)
      p->property = 0;
    }
    le = list_prev(&(base->page_link));
    p = le2page(le, page_link);
    if(le!=&free_list && p==base-1){
      while(le!=&free_list){
c0104be4:	81 7d f4 18 bb 12 c0 	cmpl   $0xc012bb18,-0xc(%ebp)
c0104beb:	75 b6                	jne    c0104ba3 <default_free_pages+0x1e8>
        le = list_prev(le);
        p = le2page(le,page_link);
      }
    }

    nr_free += n;
c0104bed:	8b 15 20 bb 12 c0    	mov    0xc012bb20,%edx
c0104bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104bf6:	01 d0                	add    %edx,%eax
c0104bf8:	a3 20 bb 12 c0       	mov    %eax,0xc012bb20
    return ;
c0104bfd:	90                   	nop
}
c0104bfe:	c9                   	leave  
c0104bff:	c3                   	ret    

c0104c00 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0104c00:	55                   	push   %ebp
c0104c01:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104c03:	a1 20 bb 12 c0       	mov    0xc012bb20,%eax
}
c0104c08:	5d                   	pop    %ebp
c0104c09:	c3                   	ret    

c0104c0a <basic_check>:

static void
basic_check(void) {
c0104c0a:	55                   	push   %ebp
c0104c0b:	89 e5                	mov    %esp,%ebp
c0104c0d:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0104c10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104c1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c20:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0104c23:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c2a:	e8 fd 15 00 00       	call   c010622c <alloc_pages>
c0104c2f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104c32:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104c36:	75 24                	jne    c0104c5c <basic_check+0x52>
c0104c38:	c7 44 24 0c a4 bd 10 	movl   $0xc010bda4,0xc(%esp)
c0104c3f:	c0 
c0104c40:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104c47:	c0 
c0104c48:	c7 44 24 04 ad 00 00 	movl   $0xad,0x4(%esp)
c0104c4f:	00 
c0104c50:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104c57:	e8 04 d5 ff ff       	call   c0102160 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104c5c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c63:	e8 c4 15 00 00       	call   c010622c <alloc_pages>
c0104c68:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104c6b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104c6f:	75 24                	jne    c0104c95 <basic_check+0x8b>
c0104c71:	c7 44 24 0c c0 bd 10 	movl   $0xc010bdc0,0xc(%esp)
c0104c78:	c0 
c0104c79:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104c80:	c0 
c0104c81:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
c0104c88:	00 
c0104c89:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104c90:	e8 cb d4 ff ff       	call   c0102160 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104c95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c9c:	e8 8b 15 00 00       	call   c010622c <alloc_pages>
c0104ca1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104ca4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104ca8:	75 24                	jne    c0104cce <basic_check+0xc4>
c0104caa:	c7 44 24 0c dc bd 10 	movl   $0xc010bddc,0xc(%esp)
c0104cb1:	c0 
c0104cb2:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104cb9:	c0 
c0104cba:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
c0104cc1:	00 
c0104cc2:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104cc9:	e8 92 d4 ff ff       	call   c0102160 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104cce:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104cd1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104cd4:	74 10                	je     c0104ce6 <basic_check+0xdc>
c0104cd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104cd9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104cdc:	74 08                	je     c0104ce6 <basic_check+0xdc>
c0104cde:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ce1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104ce4:	75 24                	jne    c0104d0a <basic_check+0x100>
c0104ce6:	c7 44 24 0c f8 bd 10 	movl   $0xc010bdf8,0xc(%esp)
c0104ced:	c0 
c0104cee:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104cf5:	c0 
c0104cf6:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
c0104cfd:	00 
c0104cfe:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104d05:	e8 56 d4 ff ff       	call   c0102160 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0104d0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d0d:	89 04 24             	mov    %eax,(%esp)
c0104d10:	e8 96 f9 ff ff       	call   c01046ab <page_ref>
c0104d15:	85 c0                	test   %eax,%eax
c0104d17:	75 1e                	jne    c0104d37 <basic_check+0x12d>
c0104d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d1c:	89 04 24             	mov    %eax,(%esp)
c0104d1f:	e8 87 f9 ff ff       	call   c01046ab <page_ref>
c0104d24:	85 c0                	test   %eax,%eax
c0104d26:	75 0f                	jne    c0104d37 <basic_check+0x12d>
c0104d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d2b:	89 04 24             	mov    %eax,(%esp)
c0104d2e:	e8 78 f9 ff ff       	call   c01046ab <page_ref>
c0104d33:	85 c0                	test   %eax,%eax
c0104d35:	74 24                	je     c0104d5b <basic_check+0x151>
c0104d37:	c7 44 24 0c 1c be 10 	movl   $0xc010be1c,0xc(%esp)
c0104d3e:	c0 
c0104d3f:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104d46:	c0 
c0104d47:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
c0104d4e:	00 
c0104d4f:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104d56:	e8 05 d4 ff ff       	call   c0102160 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0104d5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d5e:	89 04 24             	mov    %eax,(%esp)
c0104d61:	e8 2f f9 ff ff       	call   c0104695 <page2pa>
c0104d66:	8b 15 40 9a 12 c0    	mov    0xc0129a40,%edx
c0104d6c:	c1 e2 0c             	shl    $0xc,%edx
c0104d6f:	39 d0                	cmp    %edx,%eax
c0104d71:	72 24                	jb     c0104d97 <basic_check+0x18d>
c0104d73:	c7 44 24 0c 58 be 10 	movl   $0xc010be58,0xc(%esp)
c0104d7a:	c0 
c0104d7b:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104d82:	c0 
c0104d83:	c7 44 24 04 b4 00 00 	movl   $0xb4,0x4(%esp)
c0104d8a:	00 
c0104d8b:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104d92:	e8 c9 d3 ff ff       	call   c0102160 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0104d97:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d9a:	89 04 24             	mov    %eax,(%esp)
c0104d9d:	e8 f3 f8 ff ff       	call   c0104695 <page2pa>
c0104da2:	8b 15 40 9a 12 c0    	mov    0xc0129a40,%edx
c0104da8:	c1 e2 0c             	shl    $0xc,%edx
c0104dab:	39 d0                	cmp    %edx,%eax
c0104dad:	72 24                	jb     c0104dd3 <basic_check+0x1c9>
c0104daf:	c7 44 24 0c 75 be 10 	movl   $0xc010be75,0xc(%esp)
c0104db6:	c0 
c0104db7:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104dbe:	c0 
c0104dbf:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c0104dc6:	00 
c0104dc7:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104dce:	e8 8d d3 ff ff       	call   c0102160 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dd6:	89 04 24             	mov    %eax,(%esp)
c0104dd9:	e8 b7 f8 ff ff       	call   c0104695 <page2pa>
c0104dde:	8b 15 40 9a 12 c0    	mov    0xc0129a40,%edx
c0104de4:	c1 e2 0c             	shl    $0xc,%edx
c0104de7:	39 d0                	cmp    %edx,%eax
c0104de9:	72 24                	jb     c0104e0f <basic_check+0x205>
c0104deb:	c7 44 24 0c 92 be 10 	movl   $0xc010be92,0xc(%esp)
c0104df2:	c0 
c0104df3:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104dfa:	c0 
c0104dfb:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0104e02:	00 
c0104e03:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104e0a:	e8 51 d3 ff ff       	call   c0102160 <__panic>

    list_entry_t free_list_store = free_list;
c0104e0f:	a1 18 bb 12 c0       	mov    0xc012bb18,%eax
c0104e14:	8b 15 1c bb 12 c0    	mov    0xc012bb1c,%edx
c0104e1a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104e1d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104e20:	c7 45 e0 18 bb 12 c0 	movl   $0xc012bb18,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104e27:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104e2a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104e2d:	89 50 04             	mov    %edx,0x4(%eax)
c0104e30:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104e33:	8b 50 04             	mov    0x4(%eax),%edx
c0104e36:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104e39:	89 10                	mov    %edx,(%eax)
c0104e3b:	c7 45 dc 18 bb 12 c0 	movl   $0xc012bb18,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0104e42:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104e45:	8b 40 04             	mov    0x4(%eax),%eax
c0104e48:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104e4b:	0f 94 c0             	sete   %al
c0104e4e:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104e51:	85 c0                	test   %eax,%eax
c0104e53:	75 24                	jne    c0104e79 <basic_check+0x26f>
c0104e55:	c7 44 24 0c af be 10 	movl   $0xc010beaf,0xc(%esp)
c0104e5c:	c0 
c0104e5d:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104e64:	c0 
c0104e65:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c0104e6c:	00 
c0104e6d:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104e74:	e8 e7 d2 ff ff       	call   c0102160 <__panic>

    unsigned int nr_free_store = nr_free;
c0104e79:	a1 20 bb 12 c0       	mov    0xc012bb20,%eax
c0104e7e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0104e81:	c7 05 20 bb 12 c0 00 	movl   $0x0,0xc012bb20
c0104e88:	00 00 00 

    assert(alloc_page() == NULL);
c0104e8b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e92:	e8 95 13 00 00       	call   c010622c <alloc_pages>
c0104e97:	85 c0                	test   %eax,%eax
c0104e99:	74 24                	je     c0104ebf <basic_check+0x2b5>
c0104e9b:	c7 44 24 0c c6 be 10 	movl   $0xc010bec6,0xc(%esp)
c0104ea2:	c0 
c0104ea3:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104eaa:	c0 
c0104eab:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0104eb2:	00 
c0104eb3:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104eba:	e8 a1 d2 ff ff       	call   c0102160 <__panic>

    free_page(p0);
c0104ebf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104ec6:	00 
c0104ec7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104eca:	89 04 24             	mov    %eax,(%esp)
c0104ecd:	e8 c5 13 00 00       	call   c0106297 <free_pages>
    free_page(p1);
c0104ed2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104ed9:	00 
c0104eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104edd:	89 04 24             	mov    %eax,(%esp)
c0104ee0:	e8 b2 13 00 00       	call   c0106297 <free_pages>
    free_page(p2);
c0104ee5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104eec:	00 
c0104eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ef0:	89 04 24             	mov    %eax,(%esp)
c0104ef3:	e8 9f 13 00 00       	call   c0106297 <free_pages>
    assert(nr_free == 3);
c0104ef8:	a1 20 bb 12 c0       	mov    0xc012bb20,%eax
c0104efd:	83 f8 03             	cmp    $0x3,%eax
c0104f00:	74 24                	je     c0104f26 <basic_check+0x31c>
c0104f02:	c7 44 24 0c db be 10 	movl   $0xc010bedb,0xc(%esp)
c0104f09:	c0 
c0104f0a:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104f11:	c0 
c0104f12:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c0104f19:	00 
c0104f1a:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104f21:	e8 3a d2 ff ff       	call   c0102160 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0104f26:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f2d:	e8 fa 12 00 00       	call   c010622c <alloc_pages>
c0104f32:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104f35:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104f39:	75 24                	jne    c0104f5f <basic_check+0x355>
c0104f3b:	c7 44 24 0c a4 bd 10 	movl   $0xc010bda4,0xc(%esp)
c0104f42:	c0 
c0104f43:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104f4a:	c0 
c0104f4b:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0104f52:	00 
c0104f53:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104f5a:	e8 01 d2 ff ff       	call   c0102160 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104f5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f66:	e8 c1 12 00 00       	call   c010622c <alloc_pages>
c0104f6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f6e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104f72:	75 24                	jne    c0104f98 <basic_check+0x38e>
c0104f74:	c7 44 24 0c c0 bd 10 	movl   $0xc010bdc0,0xc(%esp)
c0104f7b:	c0 
c0104f7c:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104f83:	c0 
c0104f84:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0104f8b:	00 
c0104f8c:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104f93:	e8 c8 d1 ff ff       	call   c0102160 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104f98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f9f:	e8 88 12 00 00       	call   c010622c <alloc_pages>
c0104fa4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104fa7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104fab:	75 24                	jne    c0104fd1 <basic_check+0x3c7>
c0104fad:	c7 44 24 0c dc bd 10 	movl   $0xc010bddc,0xc(%esp)
c0104fb4:	c0 
c0104fb5:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104fbc:	c0 
c0104fbd:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c0104fc4:	00 
c0104fc5:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0104fcc:	e8 8f d1 ff ff       	call   c0102160 <__panic>

    assert(alloc_page() == NULL);
c0104fd1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104fd8:	e8 4f 12 00 00       	call   c010622c <alloc_pages>
c0104fdd:	85 c0                	test   %eax,%eax
c0104fdf:	74 24                	je     c0105005 <basic_check+0x3fb>
c0104fe1:	c7 44 24 0c c6 be 10 	movl   $0xc010bec6,0xc(%esp)
c0104fe8:	c0 
c0104fe9:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0104ff0:	c0 
c0104ff1:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0104ff8:	00 
c0104ff9:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0105000:	e8 5b d1 ff ff       	call   c0102160 <__panic>

    free_page(p0);
c0105005:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010500c:	00 
c010500d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105010:	89 04 24             	mov    %eax,(%esp)
c0105013:	e8 7f 12 00 00       	call   c0106297 <free_pages>
c0105018:	c7 45 d8 18 bb 12 c0 	movl   $0xc012bb18,-0x28(%ebp)
c010501f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105022:	8b 40 04             	mov    0x4(%eax),%eax
c0105025:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0105028:	0f 94 c0             	sete   %al
c010502b:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c010502e:	85 c0                	test   %eax,%eax
c0105030:	74 24                	je     c0105056 <basic_check+0x44c>
c0105032:	c7 44 24 0c e8 be 10 	movl   $0xc010bee8,0xc(%esp)
c0105039:	c0 
c010503a:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0105041:	c0 
c0105042:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0105049:	00 
c010504a:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0105051:	e8 0a d1 ff ff       	call   c0102160 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0105056:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010505d:	e8 ca 11 00 00       	call   c010622c <alloc_pages>
c0105062:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105065:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105068:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010506b:	74 24                	je     c0105091 <basic_check+0x487>
c010506d:	c7 44 24 0c 00 bf 10 	movl   $0xc010bf00,0xc(%esp)
c0105074:	c0 
c0105075:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c010507c:	c0 
c010507d:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0105084:	00 
c0105085:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c010508c:	e8 cf d0 ff ff       	call   c0102160 <__panic>
    assert(alloc_page() == NULL);
c0105091:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105098:	e8 8f 11 00 00       	call   c010622c <alloc_pages>
c010509d:	85 c0                	test   %eax,%eax
c010509f:	74 24                	je     c01050c5 <basic_check+0x4bb>
c01050a1:	c7 44 24 0c c6 be 10 	movl   $0xc010bec6,0xc(%esp)
c01050a8:	c0 
c01050a9:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c01050b0:	c0 
c01050b1:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c01050b8:	00 
c01050b9:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c01050c0:	e8 9b d0 ff ff       	call   c0102160 <__panic>

    assert(nr_free == 0);
c01050c5:	a1 20 bb 12 c0       	mov    0xc012bb20,%eax
c01050ca:	85 c0                	test   %eax,%eax
c01050cc:	74 24                	je     c01050f2 <basic_check+0x4e8>
c01050ce:	c7 44 24 0c 19 bf 10 	movl   $0xc010bf19,0xc(%esp)
c01050d5:	c0 
c01050d6:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c01050dd:	c0 
c01050de:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c01050e5:	00 
c01050e6:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c01050ed:	e8 6e d0 ff ff       	call   c0102160 <__panic>
    free_list = free_list_store;
c01050f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01050f5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01050f8:	a3 18 bb 12 c0       	mov    %eax,0xc012bb18
c01050fd:	89 15 1c bb 12 c0    	mov    %edx,0xc012bb1c
    nr_free = nr_free_store;
c0105103:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105106:	a3 20 bb 12 c0       	mov    %eax,0xc012bb20

    free_page(p);
c010510b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105112:	00 
c0105113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105116:	89 04 24             	mov    %eax,(%esp)
c0105119:	e8 79 11 00 00       	call   c0106297 <free_pages>
    free_page(p1);
c010511e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105125:	00 
c0105126:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105129:	89 04 24             	mov    %eax,(%esp)
c010512c:	e8 66 11 00 00       	call   c0106297 <free_pages>
    free_page(p2);
c0105131:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105138:	00 
c0105139:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010513c:	89 04 24             	mov    %eax,(%esp)
c010513f:	e8 53 11 00 00       	call   c0106297 <free_pages>
}
c0105144:	c9                   	leave  
c0105145:	c3                   	ret    

c0105146 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0105146:	55                   	push   %ebp
c0105147:	89 e5                	mov    %esp,%ebp
c0105149:	53                   	push   %ebx
c010514a:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0105150:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105157:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c010515e:	c7 45 ec 18 bb 12 c0 	movl   $0xc012bb18,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105165:	eb 6b                	jmp    c01051d2 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0105167:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010516a:	83 e8 10             	sub    $0x10,%eax
c010516d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c0105170:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105173:	83 c0 04             	add    $0x4,%eax
c0105176:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c010517d:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105180:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105183:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105186:	0f a3 10             	bt     %edx,(%eax)
c0105189:	19 c0                	sbb    %eax,%eax
c010518b:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c010518e:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0105192:	0f 95 c0             	setne  %al
c0105195:	0f b6 c0             	movzbl %al,%eax
c0105198:	85 c0                	test   %eax,%eax
c010519a:	75 24                	jne    c01051c0 <default_check+0x7a>
c010519c:	c7 44 24 0c 26 bf 10 	movl   $0xc010bf26,0xc(%esp)
c01051a3:	c0 
c01051a4:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c01051ab:	c0 
c01051ac:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c01051b3:	00 
c01051b4:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c01051bb:	e8 a0 cf ff ff       	call   c0102160 <__panic>
        count ++, total += p->property;
c01051c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01051c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051c7:	8b 50 08             	mov    0x8(%eax),%edx
c01051ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01051cd:	01 d0                	add    %edx,%eax
c01051cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01051d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051d5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01051d8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01051db:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01051de:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01051e1:	81 7d ec 18 bb 12 c0 	cmpl   $0xc012bb18,-0x14(%ebp)
c01051e8:	0f 85 79 ff ff ff    	jne    c0105167 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c01051ee:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c01051f1:	e8 d3 10 00 00       	call   c01062c9 <nr_free_pages>
c01051f6:	39 c3                	cmp    %eax,%ebx
c01051f8:	74 24                	je     c010521e <default_check+0xd8>
c01051fa:	c7 44 24 0c 36 bf 10 	movl   $0xc010bf36,0xc(%esp)
c0105201:	c0 
c0105202:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0105209:	c0 
c010520a:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0105211:	00 
c0105212:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0105219:	e8 42 cf ff ff       	call   c0102160 <__panic>

    basic_check();
c010521e:	e8 e7 f9 ff ff       	call   c0104c0a <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0105223:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010522a:	e8 fd 0f 00 00       	call   c010622c <alloc_pages>
c010522f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c0105232:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105236:	75 24                	jne    c010525c <default_check+0x116>
c0105238:	c7 44 24 0c 4f bf 10 	movl   $0xc010bf4f,0xc(%esp)
c010523f:	c0 
c0105240:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0105247:	c0 
c0105248:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c010524f:	00 
c0105250:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0105257:	e8 04 cf ff ff       	call   c0102160 <__panic>
    assert(!PageProperty(p0));
c010525c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010525f:	83 c0 04             	add    $0x4,%eax
c0105262:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0105269:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010526c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010526f:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105272:	0f a3 10             	bt     %edx,(%eax)
c0105275:	19 c0                	sbb    %eax,%eax
c0105277:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c010527a:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c010527e:	0f 95 c0             	setne  %al
c0105281:	0f b6 c0             	movzbl %al,%eax
c0105284:	85 c0                	test   %eax,%eax
c0105286:	74 24                	je     c01052ac <default_check+0x166>
c0105288:	c7 44 24 0c 5a bf 10 	movl   $0xc010bf5a,0xc(%esp)
c010528f:	c0 
c0105290:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0105297:	c0 
c0105298:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c010529f:	00 
c01052a0:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c01052a7:	e8 b4 ce ff ff       	call   c0102160 <__panic>

    list_entry_t free_list_store = free_list;
c01052ac:	a1 18 bb 12 c0       	mov    0xc012bb18,%eax
c01052b1:	8b 15 1c bb 12 c0    	mov    0xc012bb1c,%edx
c01052b7:	89 45 80             	mov    %eax,-0x80(%ebp)
c01052ba:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01052bd:	c7 45 b4 18 bb 12 c0 	movl   $0xc012bb18,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01052c4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01052c7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01052ca:	89 50 04             	mov    %edx,0x4(%eax)
c01052cd:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01052d0:	8b 50 04             	mov    0x4(%eax),%edx
c01052d3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01052d6:	89 10                	mov    %edx,(%eax)
c01052d8:	c7 45 b0 18 bb 12 c0 	movl   $0xc012bb18,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01052df:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01052e2:	8b 40 04             	mov    0x4(%eax),%eax
c01052e5:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c01052e8:	0f 94 c0             	sete   %al
c01052eb:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01052ee:	85 c0                	test   %eax,%eax
c01052f0:	75 24                	jne    c0105316 <default_check+0x1d0>
c01052f2:	c7 44 24 0c af be 10 	movl   $0xc010beaf,0xc(%esp)
c01052f9:	c0 
c01052fa:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0105301:	c0 
c0105302:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0105309:	00 
c010530a:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0105311:	e8 4a ce ff ff       	call   c0102160 <__panic>
    assert(alloc_page() == NULL);
c0105316:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010531d:	e8 0a 0f 00 00       	call   c010622c <alloc_pages>
c0105322:	85 c0                	test   %eax,%eax
c0105324:	74 24                	je     c010534a <default_check+0x204>
c0105326:	c7 44 24 0c c6 be 10 	movl   $0xc010bec6,0xc(%esp)
c010532d:	c0 
c010532e:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0105335:	c0 
c0105336:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c010533d:	00 
c010533e:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0105345:	e8 16 ce ff ff       	call   c0102160 <__panic>

    unsigned int nr_free_store = nr_free;
c010534a:	a1 20 bb 12 c0       	mov    0xc012bb20,%eax
c010534f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0105352:	c7 05 20 bb 12 c0 00 	movl   $0x0,0xc012bb20
c0105359:	00 00 00 

    free_pages(p0 + 2, 3);
c010535c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010535f:	83 c0 48             	add    $0x48,%eax
c0105362:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105369:	00 
c010536a:	89 04 24             	mov    %eax,(%esp)
c010536d:	e8 25 0f 00 00       	call   c0106297 <free_pages>
    assert(alloc_pages(4) == NULL);
c0105372:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0105379:	e8 ae 0e 00 00       	call   c010622c <alloc_pages>
c010537e:	85 c0                	test   %eax,%eax
c0105380:	74 24                	je     c01053a6 <default_check+0x260>
c0105382:	c7 44 24 0c 6c bf 10 	movl   $0xc010bf6c,0xc(%esp)
c0105389:	c0 
c010538a:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0105391:	c0 
c0105392:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0105399:	00 
c010539a:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c01053a1:	e8 ba cd ff ff       	call   c0102160 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01053a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01053a9:	83 c0 48             	add    $0x48,%eax
c01053ac:	83 c0 04             	add    $0x4,%eax
c01053af:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01053b6:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01053b9:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01053bc:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01053bf:	0f a3 10             	bt     %edx,(%eax)
c01053c2:	19 c0                	sbb    %eax,%eax
c01053c4:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01053c7:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01053cb:	0f 95 c0             	setne  %al
c01053ce:	0f b6 c0             	movzbl %al,%eax
c01053d1:	85 c0                	test   %eax,%eax
c01053d3:	74 0e                	je     c01053e3 <default_check+0x29d>
c01053d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01053d8:	83 c0 48             	add    $0x48,%eax
c01053db:	8b 40 08             	mov    0x8(%eax),%eax
c01053de:	83 f8 03             	cmp    $0x3,%eax
c01053e1:	74 24                	je     c0105407 <default_check+0x2c1>
c01053e3:	c7 44 24 0c 84 bf 10 	movl   $0xc010bf84,0xc(%esp)
c01053ea:	c0 
c01053eb:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c01053f2:	c0 
c01053f3:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c01053fa:	00 
c01053fb:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0105402:	e8 59 cd ff ff       	call   c0102160 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0105407:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c010540e:	e8 19 0e 00 00       	call   c010622c <alloc_pages>
c0105413:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105416:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010541a:	75 24                	jne    c0105440 <default_check+0x2fa>
c010541c:	c7 44 24 0c b0 bf 10 	movl   $0xc010bfb0,0xc(%esp)
c0105423:	c0 
c0105424:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c010542b:	c0 
c010542c:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0105433:	00 
c0105434:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c010543b:	e8 20 cd ff ff       	call   c0102160 <__panic>
    assert(alloc_page() == NULL);
c0105440:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105447:	e8 e0 0d 00 00       	call   c010622c <alloc_pages>
c010544c:	85 c0                	test   %eax,%eax
c010544e:	74 24                	je     c0105474 <default_check+0x32e>
c0105450:	c7 44 24 0c c6 be 10 	movl   $0xc010bec6,0xc(%esp)
c0105457:	c0 
c0105458:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c010545f:	c0 
c0105460:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0105467:	00 
c0105468:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c010546f:	e8 ec cc ff ff       	call   c0102160 <__panic>
    assert(p0 + 2 == p1);
c0105474:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105477:	83 c0 48             	add    $0x48,%eax
c010547a:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010547d:	74 24                	je     c01054a3 <default_check+0x35d>
c010547f:	c7 44 24 0c ce bf 10 	movl   $0xc010bfce,0xc(%esp)
c0105486:	c0 
c0105487:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c010548e:	c0 
c010548f:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0105496:	00 
c0105497:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c010549e:	e8 bd cc ff ff       	call   c0102160 <__panic>

    p2 = p0 + 1;
c01054a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01054a6:	83 c0 24             	add    $0x24,%eax
c01054a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c01054ac:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01054b3:	00 
c01054b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01054b7:	89 04 24             	mov    %eax,(%esp)
c01054ba:	e8 d8 0d 00 00       	call   c0106297 <free_pages>
    free_pages(p1, 3);
c01054bf:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01054c6:	00 
c01054c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01054ca:	89 04 24             	mov    %eax,(%esp)
c01054cd:	e8 c5 0d 00 00       	call   c0106297 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01054d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01054d5:	83 c0 04             	add    $0x4,%eax
c01054d8:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01054df:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01054e2:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01054e5:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01054e8:	0f a3 10             	bt     %edx,(%eax)
c01054eb:	19 c0                	sbb    %eax,%eax
c01054ed:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01054f0:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01054f4:	0f 95 c0             	setne  %al
c01054f7:	0f b6 c0             	movzbl %al,%eax
c01054fa:	85 c0                	test   %eax,%eax
c01054fc:	74 0b                	je     c0105509 <default_check+0x3c3>
c01054fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105501:	8b 40 08             	mov    0x8(%eax),%eax
c0105504:	83 f8 01             	cmp    $0x1,%eax
c0105507:	74 24                	je     c010552d <default_check+0x3e7>
c0105509:	c7 44 24 0c dc bf 10 	movl   $0xc010bfdc,0xc(%esp)
c0105510:	c0 
c0105511:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0105518:	c0 
c0105519:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0105520:	00 
c0105521:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0105528:	e8 33 cc ff ff       	call   c0102160 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c010552d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105530:	83 c0 04             	add    $0x4,%eax
c0105533:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c010553a:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010553d:	8b 45 90             	mov    -0x70(%ebp),%eax
c0105540:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0105543:	0f a3 10             	bt     %edx,(%eax)
c0105546:	19 c0                	sbb    %eax,%eax
c0105548:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c010554b:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c010554f:	0f 95 c0             	setne  %al
c0105552:	0f b6 c0             	movzbl %al,%eax
c0105555:	85 c0                	test   %eax,%eax
c0105557:	74 0b                	je     c0105564 <default_check+0x41e>
c0105559:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010555c:	8b 40 08             	mov    0x8(%eax),%eax
c010555f:	83 f8 03             	cmp    $0x3,%eax
c0105562:	74 24                	je     c0105588 <default_check+0x442>
c0105564:	c7 44 24 0c 04 c0 10 	movl   $0xc010c004,0xc(%esp)
c010556b:	c0 
c010556c:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0105573:	c0 
c0105574:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c010557b:	00 
c010557c:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0105583:	e8 d8 cb ff ff       	call   c0102160 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0105588:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010558f:	e8 98 0c 00 00       	call   c010622c <alloc_pages>
c0105594:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105597:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010559a:	83 e8 24             	sub    $0x24,%eax
c010559d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01055a0:	74 24                	je     c01055c6 <default_check+0x480>
c01055a2:	c7 44 24 0c 2a c0 10 	movl   $0xc010c02a,0xc(%esp)
c01055a9:	c0 
c01055aa:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c01055b1:	c0 
c01055b2:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c01055b9:	00 
c01055ba:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c01055c1:	e8 9a cb ff ff       	call   c0102160 <__panic>
    free_page(p0);
c01055c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01055cd:	00 
c01055ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01055d1:	89 04 24             	mov    %eax,(%esp)
c01055d4:	e8 be 0c 00 00       	call   c0106297 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01055d9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01055e0:	e8 47 0c 00 00       	call   c010622c <alloc_pages>
c01055e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01055e8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01055eb:	83 c0 24             	add    $0x24,%eax
c01055ee:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01055f1:	74 24                	je     c0105617 <default_check+0x4d1>
c01055f3:	c7 44 24 0c 48 c0 10 	movl   $0xc010c048,0xc(%esp)
c01055fa:	c0 
c01055fb:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0105602:	c0 
c0105603:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c010560a:	00 
c010560b:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0105612:	e8 49 cb ff ff       	call   c0102160 <__panic>

    free_pages(p0, 2);
c0105617:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c010561e:	00 
c010561f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105622:	89 04 24             	mov    %eax,(%esp)
c0105625:	e8 6d 0c 00 00       	call   c0106297 <free_pages>
    free_page(p2);
c010562a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105631:	00 
c0105632:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105635:	89 04 24             	mov    %eax,(%esp)
c0105638:	e8 5a 0c 00 00       	call   c0106297 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c010563d:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105644:	e8 e3 0b 00 00       	call   c010622c <alloc_pages>
c0105649:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010564c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105650:	75 24                	jne    c0105676 <default_check+0x530>
c0105652:	c7 44 24 0c 68 c0 10 	movl   $0xc010c068,0xc(%esp)
c0105659:	c0 
c010565a:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0105661:	c0 
c0105662:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c0105669:	00 
c010566a:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0105671:	e8 ea ca ff ff       	call   c0102160 <__panic>
    assert(alloc_page() == NULL);
c0105676:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010567d:	e8 aa 0b 00 00       	call   c010622c <alloc_pages>
c0105682:	85 c0                	test   %eax,%eax
c0105684:	74 24                	je     c01056aa <default_check+0x564>
c0105686:	c7 44 24 0c c6 be 10 	movl   $0xc010bec6,0xc(%esp)
c010568d:	c0 
c010568e:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0105695:	c0 
c0105696:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c010569d:	00 
c010569e:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c01056a5:	e8 b6 ca ff ff       	call   c0102160 <__panic>

    assert(nr_free == 0);
c01056aa:	a1 20 bb 12 c0       	mov    0xc012bb20,%eax
c01056af:	85 c0                	test   %eax,%eax
c01056b1:	74 24                	je     c01056d7 <default_check+0x591>
c01056b3:	c7 44 24 0c 19 bf 10 	movl   $0xc010bf19,0xc(%esp)
c01056ba:	c0 
c01056bb:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c01056c2:	c0 
c01056c3:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c01056ca:	00 
c01056cb:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c01056d2:	e8 89 ca ff ff       	call   c0102160 <__panic>
    nr_free = nr_free_store;
c01056d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01056da:	a3 20 bb 12 c0       	mov    %eax,0xc012bb20

    free_list = free_list_store;
c01056df:	8b 45 80             	mov    -0x80(%ebp),%eax
c01056e2:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01056e5:	a3 18 bb 12 c0       	mov    %eax,0xc012bb18
c01056ea:	89 15 1c bb 12 c0    	mov    %edx,0xc012bb1c
    free_pages(p0, 5);
c01056f0:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01056f7:	00 
c01056f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01056fb:	89 04 24             	mov    %eax,(%esp)
c01056fe:	e8 94 0b 00 00       	call   c0106297 <free_pages>

    le = &free_list;
c0105703:	c7 45 ec 18 bb 12 c0 	movl   $0xc012bb18,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010570a:	eb 1d                	jmp    c0105729 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c010570c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010570f:	83 e8 10             	sub    $0x10,%eax
c0105712:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c0105715:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0105719:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010571c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010571f:	8b 40 08             	mov    0x8(%eax),%eax
c0105722:	29 c2                	sub    %eax,%edx
c0105724:	89 d0                	mov    %edx,%eax
c0105726:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105729:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010572c:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010572f:	8b 45 88             	mov    -0x78(%ebp),%eax
c0105732:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0105735:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105738:	81 7d ec 18 bb 12 c0 	cmpl   $0xc012bb18,-0x14(%ebp)
c010573f:	75 cb                	jne    c010570c <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c0105741:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105745:	74 24                	je     c010576b <default_check+0x625>
c0105747:	c7 44 24 0c 86 c0 10 	movl   $0xc010c086,0xc(%esp)
c010574e:	c0 
c010574f:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0105756:	c0 
c0105757:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c010575e:	00 
c010575f:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0105766:	e8 f5 c9 ff ff       	call   c0102160 <__panic>
    assert(total == 0);
c010576b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010576f:	74 24                	je     c0105795 <default_check+0x64f>
c0105771:	c7 44 24 0c 91 c0 10 	movl   $0xc010c091,0xc(%esp)
c0105778:	c0 
c0105779:	c7 44 24 08 56 bd 10 	movl   $0xc010bd56,0x8(%esp)
c0105780:	c0 
c0105781:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0105788:	00 
c0105789:	c7 04 24 6b bd 10 c0 	movl   $0xc010bd6b,(%esp)
c0105790:	e8 cb c9 ff ff       	call   c0102160 <__panic>
}
c0105795:	81 c4 94 00 00 00    	add    $0x94,%esp
c010579b:	5b                   	pop    %ebx
c010579c:	5d                   	pop    %ebp
c010579d:	c3                   	ret    

c010579e <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c010579e:	55                   	push   %ebp
c010579f:	89 e5                	mov    %esp,%ebp
c01057a1:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01057a4:	9c                   	pushf  
c01057a5:	58                   	pop    %eax
c01057a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01057a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01057ac:	25 00 02 00 00       	and    $0x200,%eax
c01057b1:	85 c0                	test   %eax,%eax
c01057b3:	74 0c                	je     c01057c1 <__intr_save+0x23>
        intr_disable();
c01057b5:	e8 fe db ff ff       	call   c01033b8 <intr_disable>
        return 1;
c01057ba:	b8 01 00 00 00       	mov    $0x1,%eax
c01057bf:	eb 05                	jmp    c01057c6 <__intr_save+0x28>
    }
    return 0;
c01057c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01057c6:	c9                   	leave  
c01057c7:	c3                   	ret    

c01057c8 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01057c8:	55                   	push   %ebp
c01057c9:	89 e5                	mov    %esp,%ebp
c01057cb:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01057ce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01057d2:	74 05                	je     c01057d9 <__intr_restore+0x11>
        intr_enable();
c01057d4:	e8 d9 db ff ff       	call   c01033b2 <intr_enable>
    }
}
c01057d9:	c9                   	leave  
c01057da:	c3                   	ret    

c01057db <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01057db:	55                   	push   %ebp
c01057dc:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01057de:	8b 55 08             	mov    0x8(%ebp),%edx
c01057e1:	a1 2c bb 12 c0       	mov    0xc012bb2c,%eax
c01057e6:	29 c2                	sub    %eax,%edx
c01057e8:	89 d0                	mov    %edx,%eax
c01057ea:	c1 f8 02             	sar    $0x2,%eax
c01057ed:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c01057f3:	5d                   	pop    %ebp
c01057f4:	c3                   	ret    

c01057f5 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01057f5:	55                   	push   %ebp
c01057f6:	89 e5                	mov    %esp,%ebp
c01057f8:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01057fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01057fe:	89 04 24             	mov    %eax,(%esp)
c0105801:	e8 d5 ff ff ff       	call   c01057db <page2ppn>
c0105806:	c1 e0 0c             	shl    $0xc,%eax
}
c0105809:	c9                   	leave  
c010580a:	c3                   	ret    

c010580b <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c010580b:	55                   	push   %ebp
c010580c:	89 e5                	mov    %esp,%ebp
c010580e:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0105811:	8b 45 08             	mov    0x8(%ebp),%eax
c0105814:	c1 e8 0c             	shr    $0xc,%eax
c0105817:	89 c2                	mov    %eax,%edx
c0105819:	a1 40 9a 12 c0       	mov    0xc0129a40,%eax
c010581e:	39 c2                	cmp    %eax,%edx
c0105820:	72 1c                	jb     c010583e <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0105822:	c7 44 24 08 cc c0 10 	movl   $0xc010c0cc,0x8(%esp)
c0105829:	c0 
c010582a:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0105831:	00 
c0105832:	c7 04 24 eb c0 10 c0 	movl   $0xc010c0eb,(%esp)
c0105839:	e8 22 c9 ff ff       	call   c0102160 <__panic>
    }
    return &pages[PPN(pa)];
c010583e:	8b 0d 2c bb 12 c0    	mov    0xc012bb2c,%ecx
c0105844:	8b 45 08             	mov    0x8(%ebp),%eax
c0105847:	c1 e8 0c             	shr    $0xc,%eax
c010584a:	89 c2                	mov    %eax,%edx
c010584c:	89 d0                	mov    %edx,%eax
c010584e:	c1 e0 03             	shl    $0x3,%eax
c0105851:	01 d0                	add    %edx,%eax
c0105853:	c1 e0 02             	shl    $0x2,%eax
c0105856:	01 c8                	add    %ecx,%eax
}
c0105858:	c9                   	leave  
c0105859:	c3                   	ret    

c010585a <page2kva>:

static inline void *
page2kva(struct Page *page) {
c010585a:	55                   	push   %ebp
c010585b:	89 e5                	mov    %esp,%ebp
c010585d:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0105860:	8b 45 08             	mov    0x8(%ebp),%eax
c0105863:	89 04 24             	mov    %eax,(%esp)
c0105866:	e8 8a ff ff ff       	call   c01057f5 <page2pa>
c010586b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010586e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105871:	c1 e8 0c             	shr    $0xc,%eax
c0105874:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105877:	a1 40 9a 12 c0       	mov    0xc0129a40,%eax
c010587c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010587f:	72 23                	jb     c01058a4 <page2kva+0x4a>
c0105881:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105884:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105888:	c7 44 24 08 fc c0 10 	movl   $0xc010c0fc,0x8(%esp)
c010588f:	c0 
c0105890:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0105897:	00 
c0105898:	c7 04 24 eb c0 10 c0 	movl   $0xc010c0eb,(%esp)
c010589f:	e8 bc c8 ff ff       	call   c0102160 <__panic>
c01058a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058a7:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01058ac:	c9                   	leave  
c01058ad:	c3                   	ret    

c01058ae <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01058ae:	55                   	push   %ebp
c01058af:	89 e5                	mov    %esp,%ebp
c01058b1:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01058b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01058b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01058ba:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01058c1:	77 23                	ja     c01058e6 <kva2page+0x38>
c01058c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01058ca:	c7 44 24 08 20 c1 10 	movl   $0xc010c120,0x8(%esp)
c01058d1:	c0 
c01058d2:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c01058d9:	00 
c01058da:	c7 04 24 eb c0 10 c0 	movl   $0xc010c0eb,(%esp)
c01058e1:	e8 7a c8 ff ff       	call   c0102160 <__panic>
c01058e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058e9:	05 00 00 00 40       	add    $0x40000000,%eax
c01058ee:	89 04 24             	mov    %eax,(%esp)
c01058f1:	e8 15 ff ff ff       	call   c010580b <pa2page>
}
c01058f6:	c9                   	leave  
c01058f7:	c3                   	ret    

c01058f8 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c01058f8:	55                   	push   %ebp
c01058f9:	89 e5                	mov    %esp,%ebp
c01058fb:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c01058fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105901:	ba 01 00 00 00       	mov    $0x1,%edx
c0105906:	89 c1                	mov    %eax,%ecx
c0105908:	d3 e2                	shl    %cl,%edx
c010590a:	89 d0                	mov    %edx,%eax
c010590c:	89 04 24             	mov    %eax,(%esp)
c010590f:	e8 18 09 00 00       	call   c010622c <alloc_pages>
c0105914:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0105917:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010591b:	75 07                	jne    c0105924 <__slob_get_free_pages+0x2c>
    return NULL;
c010591d:	b8 00 00 00 00       	mov    $0x0,%eax
c0105922:	eb 0b                	jmp    c010592f <__slob_get_free_pages+0x37>
  return page2kva(page);
c0105924:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105927:	89 04 24             	mov    %eax,(%esp)
c010592a:	e8 2b ff ff ff       	call   c010585a <page2kva>
}
c010592f:	c9                   	leave  
c0105930:	c3                   	ret    

c0105931 <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0105931:	55                   	push   %ebp
c0105932:	89 e5                	mov    %esp,%ebp
c0105934:	53                   	push   %ebx
c0105935:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c0105938:	8b 45 0c             	mov    0xc(%ebp),%eax
c010593b:	ba 01 00 00 00       	mov    $0x1,%edx
c0105940:	89 c1                	mov    %eax,%ecx
c0105942:	d3 e2                	shl    %cl,%edx
c0105944:	89 d0                	mov    %edx,%eax
c0105946:	89 c3                	mov    %eax,%ebx
c0105948:	8b 45 08             	mov    0x8(%ebp),%eax
c010594b:	89 04 24             	mov    %eax,(%esp)
c010594e:	e8 5b ff ff ff       	call   c01058ae <kva2page>
c0105953:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0105957:	89 04 24             	mov    %eax,(%esp)
c010595a:	e8 38 09 00 00       	call   c0106297 <free_pages>
}
c010595f:	83 c4 14             	add    $0x14,%esp
c0105962:	5b                   	pop    %ebx
c0105963:	5d                   	pop    %ebp
c0105964:	c3                   	ret    

c0105965 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0105965:	55                   	push   %ebp
c0105966:	89 e5                	mov    %esp,%ebp
c0105968:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c010596b:	8b 45 08             	mov    0x8(%ebp),%eax
c010596e:	83 c0 08             	add    $0x8,%eax
c0105971:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0105976:	76 24                	jbe    c010599c <slob_alloc+0x37>
c0105978:	c7 44 24 0c 44 c1 10 	movl   $0xc010c144,0xc(%esp)
c010597f:	c0 
c0105980:	c7 44 24 08 63 c1 10 	movl   $0xc010c163,0x8(%esp)
c0105987:	c0 
c0105988:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010598f:	00 
c0105990:	c7 04 24 78 c1 10 c0 	movl   $0xc010c178,(%esp)
c0105997:	e8 c4 c7 ff ff       	call   c0102160 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c010599c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c01059a3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01059aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01059ad:	83 c0 07             	add    $0x7,%eax
c01059b0:	c1 e8 03             	shr    $0x3,%eax
c01059b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c01059b6:	e8 e3 fd ff ff       	call   c010579e <__intr_save>
c01059bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c01059be:	a1 08 8a 12 c0       	mov    0xc0128a08,%eax
c01059c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c01059c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059c9:	8b 40 04             	mov    0x4(%eax),%eax
c01059cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c01059cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01059d3:	74 25                	je     c01059fa <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c01059d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01059d8:	8b 45 10             	mov    0x10(%ebp),%eax
c01059db:	01 d0                	add    %edx,%eax
c01059dd:	8d 50 ff             	lea    -0x1(%eax),%edx
c01059e0:	8b 45 10             	mov    0x10(%ebp),%eax
c01059e3:	f7 d8                	neg    %eax
c01059e5:	21 d0                	and    %edx,%eax
c01059e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c01059ea:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01059ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059f0:	29 c2                	sub    %eax,%edx
c01059f2:	89 d0                	mov    %edx,%eax
c01059f4:	c1 f8 03             	sar    $0x3,%eax
c01059f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c01059fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059fd:	8b 00                	mov    (%eax),%eax
c01059ff:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105a02:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0105a05:	01 ca                	add    %ecx,%edx
c0105a07:	39 d0                	cmp    %edx,%eax
c0105a09:	0f 8c aa 00 00 00    	jl     c0105ab9 <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c0105a0f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105a13:	74 38                	je     c0105a4d <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c0105a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a18:	8b 00                	mov    (%eax),%eax
c0105a1a:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0105a1d:	89 c2                	mov    %eax,%edx
c0105a1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a22:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c0105a24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a27:	8b 50 04             	mov    0x4(%eax),%edx
c0105a2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a2d:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0105a30:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a33:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105a36:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0105a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a3c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105a3f:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0105a41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a44:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0105a47:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0105a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a50:	8b 00                	mov    (%eax),%eax
c0105a52:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0105a55:	75 0e                	jne    c0105a65 <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c0105a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a5a:	8b 50 04             	mov    0x4(%eax),%edx
c0105a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a60:	89 50 04             	mov    %edx,0x4(%eax)
c0105a63:	eb 3c                	jmp    c0105aa1 <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c0105a65:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105a68:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0105a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a72:	01 c2                	add    %eax,%edx
c0105a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a77:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c0105a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a7d:	8b 40 04             	mov    0x4(%eax),%eax
c0105a80:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105a83:	8b 12                	mov    (%edx),%edx
c0105a85:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0105a88:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0105a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a8d:	8b 40 04             	mov    0x4(%eax),%eax
c0105a90:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105a93:	8b 52 04             	mov    0x4(%edx),%edx
c0105a96:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0105a99:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a9c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105a9f:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0105aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105aa4:	a3 08 8a 12 c0       	mov    %eax,0xc0128a08
			spin_unlock_irqrestore(&slob_lock, flags);
c0105aa9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105aac:	89 04 24             	mov    %eax,(%esp)
c0105aaf:	e8 14 fd ff ff       	call   c01057c8 <__intr_restore>
			return cur;
c0105ab4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ab7:	eb 7f                	jmp    c0105b38 <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c0105ab9:	a1 08 8a 12 c0       	mov    0xc0128a08,%eax
c0105abe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105ac1:	75 61                	jne    c0105b24 <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c0105ac3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ac6:	89 04 24             	mov    %eax,(%esp)
c0105ac9:	e8 fa fc ff ff       	call   c01057c8 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0105ace:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0105ad5:	75 07                	jne    c0105ade <slob_alloc+0x179>
				return 0;
c0105ad7:	b8 00 00 00 00       	mov    $0x0,%eax
c0105adc:	eb 5a                	jmp    c0105b38 <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c0105ade:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105ae5:	00 
c0105ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ae9:	89 04 24             	mov    %eax,(%esp)
c0105aec:	e8 07 fe ff ff       	call   c01058f8 <__slob_get_free_pages>
c0105af1:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0105af4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105af8:	75 07                	jne    c0105b01 <slob_alloc+0x19c>
				return 0;
c0105afa:	b8 00 00 00 00       	mov    $0x0,%eax
c0105aff:	eb 37                	jmp    c0105b38 <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c0105b01:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105b08:	00 
c0105b09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b0c:	89 04 24             	mov    %eax,(%esp)
c0105b0f:	e8 26 00 00 00       	call   c0105b3a <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c0105b14:	e8 85 fc ff ff       	call   c010579e <__intr_save>
c0105b19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0105b1c:	a1 08 8a 12 c0       	mov    0xc0128a08,%eax
c0105b21:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0105b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b27:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105b2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b2d:	8b 40 04             	mov    0x4(%eax),%eax
c0105b30:	89 45 f0             	mov    %eax,-0x10(%ebp)

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
c0105b33:	e9 97 fe ff ff       	jmp    c01059cf <slob_alloc+0x6a>
}
c0105b38:	c9                   	leave  
c0105b39:	c3                   	ret    

c0105b3a <slob_free>:

static void slob_free(void *block, int size)
{
c0105b3a:	55                   	push   %ebp
c0105b3b:	89 e5                	mov    %esp,%ebp
c0105b3d:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c0105b40:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b43:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0105b46:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105b4a:	75 05                	jne    c0105b51 <slob_free+0x17>
		return;
c0105b4c:	e9 ff 00 00 00       	jmp    c0105c50 <slob_free+0x116>

	if (size)
c0105b51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105b55:	74 10                	je     c0105b67 <slob_free+0x2d>
		b->units = SLOB_UNITS(size);
c0105b57:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b5a:	83 c0 07             	add    $0x7,%eax
c0105b5d:	c1 e8 03             	shr    $0x3,%eax
c0105b60:	89 c2                	mov    %eax,%edx
c0105b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b65:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c0105b67:	e8 32 fc ff ff       	call   c010579e <__intr_save>
c0105b6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0105b6f:	a1 08 8a 12 c0       	mov    0xc0128a08,%eax
c0105b74:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105b77:	eb 27                	jmp    c0105ba0 <slob_free+0x66>
		if (cur >= cur->next && (b > cur || b < cur->next))
c0105b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b7c:	8b 40 04             	mov    0x4(%eax),%eax
c0105b7f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105b82:	77 13                	ja     c0105b97 <slob_free+0x5d>
c0105b84:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b87:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105b8a:	77 27                	ja     c0105bb3 <slob_free+0x79>
c0105b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b8f:	8b 40 04             	mov    0x4(%eax),%eax
c0105b92:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105b95:	77 1c                	ja     c0105bb3 <slob_free+0x79>
	if (size)
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0105b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b9a:	8b 40 04             	mov    0x4(%eax),%eax
c0105b9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ba3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105ba6:	76 d1                	jbe    c0105b79 <slob_free+0x3f>
c0105ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bab:	8b 40 04             	mov    0x4(%eax),%eax
c0105bae:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105bb1:	76 c6                	jbe    c0105b79 <slob_free+0x3f>
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
c0105bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bb6:	8b 00                	mov    (%eax),%eax
c0105bb8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0105bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bc2:	01 c2                	add    %eax,%edx
c0105bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bc7:	8b 40 04             	mov    0x4(%eax),%eax
c0105bca:	39 c2                	cmp    %eax,%edx
c0105bcc:	75 25                	jne    c0105bf3 <slob_free+0xb9>
		b->units += cur->next->units;
c0105bce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bd1:	8b 10                	mov    (%eax),%edx
c0105bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bd6:	8b 40 04             	mov    0x4(%eax),%eax
c0105bd9:	8b 00                	mov    (%eax),%eax
c0105bdb:	01 c2                	add    %eax,%edx
c0105bdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105be0:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0105be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105be5:	8b 40 04             	mov    0x4(%eax),%eax
c0105be8:	8b 50 04             	mov    0x4(%eax),%edx
c0105beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bee:	89 50 04             	mov    %edx,0x4(%eax)
c0105bf1:	eb 0c                	jmp    c0105bff <slob_free+0xc5>
	} else
		b->next = cur->next;
c0105bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bf6:	8b 50 04             	mov    0x4(%eax),%edx
c0105bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bfc:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0105bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c02:	8b 00                	mov    (%eax),%eax
c0105c04:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0105c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c0e:	01 d0                	add    %edx,%eax
c0105c10:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105c13:	75 1f                	jne    c0105c34 <slob_free+0xfa>
		cur->units += b->units;
c0105c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c18:	8b 10                	mov    (%eax),%edx
c0105c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c1d:	8b 00                	mov    (%eax),%eax
c0105c1f:	01 c2                	add    %eax,%edx
c0105c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c24:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0105c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c29:	8b 50 04             	mov    0x4(%eax),%edx
c0105c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c2f:	89 50 04             	mov    %edx,0x4(%eax)
c0105c32:	eb 09                	jmp    c0105c3d <slob_free+0x103>
	} else
		cur->next = b;
c0105c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c37:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105c3a:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0105c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c40:	a3 08 8a 12 c0       	mov    %eax,0xc0128a08

	spin_unlock_irqrestore(&slob_lock, flags);
c0105c45:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c48:	89 04 24             	mov    %eax,(%esp)
c0105c4b:	e8 78 fb ff ff       	call   c01057c8 <__intr_restore>
}
c0105c50:	c9                   	leave  
c0105c51:	c3                   	ret    

c0105c52 <check_slab>:



void check_slab(void) {
c0105c52:	55                   	push   %ebp
c0105c53:	89 e5                	mov    %esp,%ebp
c0105c55:	83 ec 18             	sub    $0x18,%esp
  cprintf("check_slab() success\n");
c0105c58:	c7 04 24 8a c1 10 c0 	movl   $0xc010c18a,(%esp)
c0105c5f:	e8 72 bb ff ff       	call   c01017d6 <cprintf>
}
c0105c64:	c9                   	leave  
c0105c65:	c3                   	ret    

c0105c66 <slab_init>:

void
slab_init(void) {
c0105c66:	55                   	push   %ebp
c0105c67:	89 e5                	mov    %esp,%ebp
c0105c69:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c0105c6c:	c7 04 24 a0 c1 10 c0 	movl   $0xc010c1a0,(%esp)
c0105c73:	e8 5e bb ff ff       	call   c01017d6 <cprintf>
  check_slab();
c0105c78:	e8 d5 ff ff ff       	call   c0105c52 <check_slab>
}
c0105c7d:	c9                   	leave  
c0105c7e:	c3                   	ret    

c0105c7f <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0105c7f:	55                   	push   %ebp
c0105c80:	89 e5                	mov    %esp,%ebp
c0105c82:	83 ec 18             	sub    $0x18,%esp
    slab_init();
c0105c85:	e8 dc ff ff ff       	call   c0105c66 <slab_init>
    cprintf("kmalloc_init() succeeded!\n");
c0105c8a:	c7 04 24 b4 c1 10 c0 	movl   $0xc010c1b4,(%esp)
c0105c91:	e8 40 bb ff ff       	call   c01017d6 <cprintf>
}
c0105c96:	c9                   	leave  
c0105c97:	c3                   	ret    

c0105c98 <slab_allocated>:

size_t
slab_allocated(void) {
c0105c98:	55                   	push   %ebp
c0105c99:	89 e5                	mov    %esp,%ebp
  return 0;
c0105c9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105ca0:	5d                   	pop    %ebp
c0105ca1:	c3                   	ret    

c0105ca2 <kallocated>:

size_t
kallocated(void) {
c0105ca2:	55                   	push   %ebp
c0105ca3:	89 e5                	mov    %esp,%ebp
   return slab_allocated();
c0105ca5:	e8 ee ff ff ff       	call   c0105c98 <slab_allocated>
}
c0105caa:	5d                   	pop    %ebp
c0105cab:	c3                   	ret    

c0105cac <find_order>:

static int find_order(int size)
{
c0105cac:	55                   	push   %ebp
c0105cad:	89 e5                	mov    %esp,%ebp
c0105caf:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0105cb2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0105cb9:	eb 07                	jmp    c0105cc2 <find_order+0x16>
		order++;
c0105cbb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
}

static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
c0105cbf:	d1 7d 08             	sarl   0x8(%ebp)
c0105cc2:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0105cc9:	7f f0                	jg     c0105cbb <find_order+0xf>
		order++;
	return order;
c0105ccb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105cce:	c9                   	leave  
c0105ccf:	c3                   	ret    

c0105cd0 <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0105cd0:	55                   	push   %ebp
c0105cd1:	89 e5                	mov    %esp,%ebp
c0105cd3:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0105cd6:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0105cdd:	77 38                	ja     c0105d17 <__kmalloc+0x47>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0105cdf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ce2:	8d 50 08             	lea    0x8(%eax),%edx
c0105ce5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105cec:	00 
c0105ced:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cf0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105cf4:	89 14 24             	mov    %edx,(%esp)
c0105cf7:	e8 69 fc ff ff       	call   c0105965 <slob_alloc>
c0105cfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c0105cff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105d03:	74 08                	je     c0105d0d <__kmalloc+0x3d>
c0105d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d08:	83 c0 08             	add    $0x8,%eax
c0105d0b:	eb 05                	jmp    c0105d12 <__kmalloc+0x42>
c0105d0d:	b8 00 00 00 00       	mov    $0x0,%eax
c0105d12:	e9 a6 00 00 00       	jmp    c0105dbd <__kmalloc+0xed>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0105d17:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105d1e:	00 
c0105d1f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d22:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d26:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0105d2d:	e8 33 fc ff ff       	call   c0105965 <slob_alloc>
c0105d32:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c0105d35:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105d39:	75 07                	jne    c0105d42 <__kmalloc+0x72>
		return 0;
c0105d3b:	b8 00 00 00 00       	mov    $0x0,%eax
c0105d40:	eb 7b                	jmp    c0105dbd <__kmalloc+0xed>

	bb->order = find_order(size);
c0105d42:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d45:	89 04 24             	mov    %eax,(%esp)
c0105d48:	e8 5f ff ff ff       	call   c0105cac <find_order>
c0105d4d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105d50:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0105d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d55:	8b 00                	mov    (%eax),%eax
c0105d57:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d5e:	89 04 24             	mov    %eax,(%esp)
c0105d61:	e8 92 fb ff ff       	call   c01058f8 <__slob_get_free_pages>
c0105d66:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105d69:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0105d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d6f:	8b 40 04             	mov    0x4(%eax),%eax
c0105d72:	85 c0                	test   %eax,%eax
c0105d74:	74 2f                	je     c0105da5 <__kmalloc+0xd5>
		spin_lock_irqsave(&block_lock, flags);
c0105d76:	e8 23 fa ff ff       	call   c010579e <__intr_save>
c0105d7b:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c0105d7e:	8b 15 24 9a 12 c0    	mov    0xc0129a24,%edx
c0105d84:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d87:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0105d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d8d:	a3 24 9a 12 c0       	mov    %eax,0xc0129a24
		spin_unlock_irqrestore(&block_lock, flags);
c0105d92:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d95:	89 04 24             	mov    %eax,(%esp)
c0105d98:	e8 2b fa ff ff       	call   c01057c8 <__intr_restore>
		return bb->pages;
c0105d9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105da0:	8b 40 04             	mov    0x4(%eax),%eax
c0105da3:	eb 18                	jmp    c0105dbd <__kmalloc+0xed>
	}

	slob_free(bb, sizeof(bigblock_t));
c0105da5:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0105dac:	00 
c0105dad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105db0:	89 04 24             	mov    %eax,(%esp)
c0105db3:	e8 82 fd ff ff       	call   c0105b3a <slob_free>
	return 0;
c0105db8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105dbd:	c9                   	leave  
c0105dbe:	c3                   	ret    

c0105dbf <kmalloc>:

void *
kmalloc(size_t size)
{
c0105dbf:	55                   	push   %ebp
c0105dc0:	89 e5                	mov    %esp,%ebp
c0105dc2:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0105dc5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105dcc:	00 
c0105dcd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dd0:	89 04 24             	mov    %eax,(%esp)
c0105dd3:	e8 f8 fe ff ff       	call   c0105cd0 <__kmalloc>
}
c0105dd8:	c9                   	leave  
c0105dd9:	c3                   	ret    

c0105dda <kfree>:


void kfree(void *block)
{
c0105dda:	55                   	push   %ebp
c0105ddb:	89 e5                	mov    %esp,%ebp
c0105ddd:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0105de0:	c7 45 f0 24 9a 12 c0 	movl   $0xc0129a24,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0105de7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105deb:	75 05                	jne    c0105df2 <kfree+0x18>
		return;
c0105ded:	e9 a2 00 00 00       	jmp    c0105e94 <kfree+0xba>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0105df2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105df5:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105dfa:	85 c0                	test   %eax,%eax
c0105dfc:	75 7f                	jne    c0105e7d <kfree+0xa3>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0105dfe:	e8 9b f9 ff ff       	call   c010579e <__intr_save>
c0105e03:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0105e06:	a1 24 9a 12 c0       	mov    0xc0129a24,%eax
c0105e0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105e0e:	eb 5c                	jmp    c0105e6c <kfree+0x92>
			if (bb->pages == block) {
c0105e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e13:	8b 40 04             	mov    0x4(%eax),%eax
c0105e16:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105e19:	75 3f                	jne    c0105e5a <kfree+0x80>
				*last = bb->next;
c0105e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e1e:	8b 50 08             	mov    0x8(%eax),%edx
c0105e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e24:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0105e26:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e29:	89 04 24             	mov    %eax,(%esp)
c0105e2c:	e8 97 f9 ff ff       	call   c01057c8 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0105e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e34:	8b 10                	mov    (%eax),%edx
c0105e36:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e39:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105e3d:	89 04 24             	mov    %eax,(%esp)
c0105e40:	e8 ec fa ff ff       	call   c0105931 <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0105e45:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0105e4c:	00 
c0105e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e50:	89 04 24             	mov    %eax,(%esp)
c0105e53:	e8 e2 fc ff ff       	call   c0105b3a <slob_free>
				return;
c0105e58:	eb 3a                	jmp    c0105e94 <kfree+0xba>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0105e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e5d:	83 c0 08             	add    $0x8,%eax
c0105e60:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e66:	8b 40 08             	mov    0x8(%eax),%eax
c0105e69:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105e6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105e70:	75 9e                	jne    c0105e10 <kfree+0x36>
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0105e72:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e75:	89 04 24             	mov    %eax,(%esp)
c0105e78:	e8 4b f9 ff ff       	call   c01057c8 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0105e7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e80:	83 e8 08             	sub    $0x8,%eax
c0105e83:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105e8a:	00 
c0105e8b:	89 04 24             	mov    %eax,(%esp)
c0105e8e:	e8 a7 fc ff ff       	call   c0105b3a <slob_free>
	return;
c0105e93:	90                   	nop
}
c0105e94:	c9                   	leave  
c0105e95:	c3                   	ret    

c0105e96 <ksize>:


unsigned int ksize(const void *block)
{
c0105e96:	55                   	push   %ebp
c0105e97:	89 e5                	mov    %esp,%ebp
c0105e99:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0105e9c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105ea0:	75 07                	jne    c0105ea9 <ksize+0x13>
		return 0;
c0105ea2:	b8 00 00 00 00       	mov    $0x0,%eax
c0105ea7:	eb 6b                	jmp    c0105f14 <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0105ea9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eac:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105eb1:	85 c0                	test   %eax,%eax
c0105eb3:	75 54                	jne    c0105f09 <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0105eb5:	e8 e4 f8 ff ff       	call   c010579e <__intr_save>
c0105eba:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0105ebd:	a1 24 9a 12 c0       	mov    0xc0129a24,%eax
c0105ec2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ec5:	eb 31                	jmp    c0105ef8 <ksize+0x62>
			if (bb->pages == block) {
c0105ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105eca:	8b 40 04             	mov    0x4(%eax),%eax
c0105ecd:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105ed0:	75 1d                	jne    c0105eef <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0105ed2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ed5:	89 04 24             	mov    %eax,(%esp)
c0105ed8:	e8 eb f8 ff ff       	call   c01057c8 <__intr_restore>
				return PAGE_SIZE << bb->order;
c0105edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ee0:	8b 00                	mov    (%eax),%eax
c0105ee2:	ba 00 10 00 00       	mov    $0x1000,%edx
c0105ee7:	89 c1                	mov    %eax,%ecx
c0105ee9:	d3 e2                	shl    %cl,%edx
c0105eeb:	89 d0                	mov    %edx,%eax
c0105eed:	eb 25                	jmp    c0105f14 <ksize+0x7e>
	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
c0105eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ef2:	8b 40 08             	mov    0x8(%eax),%eax
c0105ef5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ef8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105efc:	75 c9                	jne    c0105ec7 <ksize+0x31>
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0105efe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f01:	89 04 24             	mov    %eax,(%esp)
c0105f04:	e8 bf f8 ff ff       	call   c01057c8 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0105f09:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f0c:	83 e8 08             	sub    $0x8,%eax
c0105f0f:	8b 00                	mov    (%eax),%eax
c0105f11:	c1 e0 03             	shl    $0x3,%eax
}
c0105f14:	c9                   	leave  
c0105f15:	c3                   	ret    

c0105f16 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0105f16:	55                   	push   %ebp
c0105f17:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0105f19:	8b 55 08             	mov    0x8(%ebp),%edx
c0105f1c:	a1 2c bb 12 c0       	mov    0xc012bb2c,%eax
c0105f21:	29 c2                	sub    %eax,%edx
c0105f23:	89 d0                	mov    %edx,%eax
c0105f25:	c1 f8 02             	sar    $0x2,%eax
c0105f28:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0105f2e:	5d                   	pop    %ebp
c0105f2f:	c3                   	ret    

c0105f30 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0105f30:	55                   	push   %ebp
c0105f31:	89 e5                	mov    %esp,%ebp
c0105f33:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0105f36:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f39:	89 04 24             	mov    %eax,(%esp)
c0105f3c:	e8 d5 ff ff ff       	call   c0105f16 <page2ppn>
c0105f41:	c1 e0 0c             	shl    $0xc,%eax
}
c0105f44:	c9                   	leave  
c0105f45:	c3                   	ret    

c0105f46 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0105f46:	55                   	push   %ebp
c0105f47:	89 e5                	mov    %esp,%ebp
c0105f49:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0105f4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f4f:	c1 e8 0c             	shr    $0xc,%eax
c0105f52:	89 c2                	mov    %eax,%edx
c0105f54:	a1 40 9a 12 c0       	mov    0xc0129a40,%eax
c0105f59:	39 c2                	cmp    %eax,%edx
c0105f5b:	72 1c                	jb     c0105f79 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0105f5d:	c7 44 24 08 d0 c1 10 	movl   $0xc010c1d0,0x8(%esp)
c0105f64:	c0 
c0105f65:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0105f6c:	00 
c0105f6d:	c7 04 24 ef c1 10 c0 	movl   $0xc010c1ef,(%esp)
c0105f74:	e8 e7 c1 ff ff       	call   c0102160 <__panic>
    }
    return &pages[PPN(pa)];
c0105f79:	8b 0d 2c bb 12 c0    	mov    0xc012bb2c,%ecx
c0105f7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f82:	c1 e8 0c             	shr    $0xc,%eax
c0105f85:	89 c2                	mov    %eax,%edx
c0105f87:	89 d0                	mov    %edx,%eax
c0105f89:	c1 e0 03             	shl    $0x3,%eax
c0105f8c:	01 d0                	add    %edx,%eax
c0105f8e:	c1 e0 02             	shl    $0x2,%eax
c0105f91:	01 c8                	add    %ecx,%eax
}
c0105f93:	c9                   	leave  
c0105f94:	c3                   	ret    

c0105f95 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0105f95:	55                   	push   %ebp
c0105f96:	89 e5                	mov    %esp,%ebp
c0105f98:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0105f9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f9e:	89 04 24             	mov    %eax,(%esp)
c0105fa1:	e8 8a ff ff ff       	call   c0105f30 <page2pa>
c0105fa6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fac:	c1 e8 0c             	shr    $0xc,%eax
c0105faf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105fb2:	a1 40 9a 12 c0       	mov    0xc0129a40,%eax
c0105fb7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105fba:	72 23                	jb     c0105fdf <page2kva+0x4a>
c0105fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fbf:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105fc3:	c7 44 24 08 00 c2 10 	movl   $0xc010c200,0x8(%esp)
c0105fca:	c0 
c0105fcb:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0105fd2:	00 
c0105fd3:	c7 04 24 ef c1 10 c0 	movl   $0xc010c1ef,(%esp)
c0105fda:	e8 81 c1 ff ff       	call   c0102160 <__panic>
c0105fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fe2:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0105fe7:	c9                   	leave  
c0105fe8:	c3                   	ret    

c0105fe9 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0105fe9:	55                   	push   %ebp
c0105fea:	89 e5                	mov    %esp,%ebp
c0105fec:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0105fef:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ff2:	83 e0 01             	and    $0x1,%eax
c0105ff5:	85 c0                	test   %eax,%eax
c0105ff7:	75 1c                	jne    c0106015 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0105ff9:	c7 44 24 08 24 c2 10 	movl   $0xc010c224,0x8(%esp)
c0106000:	c0 
c0106001:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0106008:	00 
c0106009:	c7 04 24 ef c1 10 c0 	movl   $0xc010c1ef,(%esp)
c0106010:	e8 4b c1 ff ff       	call   c0102160 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0106015:	8b 45 08             	mov    0x8(%ebp),%eax
c0106018:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010601d:	89 04 24             	mov    %eax,(%esp)
c0106020:	e8 21 ff ff ff       	call   c0105f46 <pa2page>
}
c0106025:	c9                   	leave  
c0106026:	c3                   	ret    

c0106027 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0106027:	55                   	push   %ebp
c0106028:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010602a:	8b 45 08             	mov    0x8(%ebp),%eax
c010602d:	8b 00                	mov    (%eax),%eax
}
c010602f:	5d                   	pop    %ebp
c0106030:	c3                   	ret    

c0106031 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0106031:	55                   	push   %ebp
c0106032:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0106034:	8b 45 08             	mov    0x8(%ebp),%eax
c0106037:	8b 55 0c             	mov    0xc(%ebp),%edx
c010603a:	89 10                	mov    %edx,(%eax)
}
c010603c:	5d                   	pop    %ebp
c010603d:	c3                   	ret    

c010603e <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c010603e:	55                   	push   %ebp
c010603f:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0106041:	8b 45 08             	mov    0x8(%ebp),%eax
c0106044:	8b 00                	mov    (%eax),%eax
c0106046:	8d 50 01             	lea    0x1(%eax),%edx
c0106049:	8b 45 08             	mov    0x8(%ebp),%eax
c010604c:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010604e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106051:	8b 00                	mov    (%eax),%eax
}
c0106053:	5d                   	pop    %ebp
c0106054:	c3                   	ret    

c0106055 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0106055:	55                   	push   %ebp
c0106056:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0106058:	8b 45 08             	mov    0x8(%ebp),%eax
c010605b:	8b 00                	mov    (%eax),%eax
c010605d:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106060:	8b 45 08             	mov    0x8(%ebp),%eax
c0106063:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0106065:	8b 45 08             	mov    0x8(%ebp),%eax
c0106068:	8b 00                	mov    (%eax),%eax
}
c010606a:	5d                   	pop    %ebp
c010606b:	c3                   	ret    

c010606c <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c010606c:	55                   	push   %ebp
c010606d:	89 e5                	mov    %esp,%ebp
c010606f:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0106072:	9c                   	pushf  
c0106073:	58                   	pop    %eax
c0106074:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0106077:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010607a:	25 00 02 00 00       	and    $0x200,%eax
c010607f:	85 c0                	test   %eax,%eax
c0106081:	74 0c                	je     c010608f <__intr_save+0x23>
        intr_disable();
c0106083:	e8 30 d3 ff ff       	call   c01033b8 <intr_disable>
        return 1;
c0106088:	b8 01 00 00 00       	mov    $0x1,%eax
c010608d:	eb 05                	jmp    c0106094 <__intr_save+0x28>
    }
    return 0;
c010608f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106094:	c9                   	leave  
c0106095:	c3                   	ret    

c0106096 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0106096:	55                   	push   %ebp
c0106097:	89 e5                	mov    %esp,%ebp
c0106099:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010609c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01060a0:	74 05                	je     c01060a7 <__intr_restore+0x11>
        intr_enable();
c01060a2:	e8 0b d3 ff ff       	call   c01033b2 <intr_enable>
    }
}
c01060a7:	c9                   	leave  
c01060a8:	c3                   	ret    

c01060a9 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01060a9:	55                   	push   %ebp
c01060aa:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01060ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01060af:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01060b2:	b8 23 00 00 00       	mov    $0x23,%eax
c01060b7:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c01060b9:	b8 23 00 00 00       	mov    $0x23,%eax
c01060be:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c01060c0:	b8 10 00 00 00       	mov    $0x10,%eax
c01060c5:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c01060c7:	b8 10 00 00 00       	mov    $0x10,%eax
c01060cc:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c01060ce:	b8 10 00 00 00       	mov    $0x10,%eax
c01060d3:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c01060d5:	ea dc 60 10 c0 08 00 	ljmp   $0x8,$0xc01060dc
}
c01060dc:	5d                   	pop    %ebp
c01060dd:	c3                   	ret    

c01060de <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c01060de:	55                   	push   %ebp
c01060df:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c01060e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01060e4:	a3 64 9a 12 c0       	mov    %eax,0xc0129a64
}
c01060e9:	5d                   	pop    %ebp
c01060ea:	c3                   	ret    

c01060eb <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c01060eb:	55                   	push   %ebp
c01060ec:	89 e5                	mov    %esp,%ebp
c01060ee:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c01060f1:	b8 00 80 12 c0       	mov    $0xc0128000,%eax
c01060f6:	89 04 24             	mov    %eax,(%esp)
c01060f9:	e8 e0 ff ff ff       	call   c01060de <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c01060fe:	66 c7 05 68 9a 12 c0 	movw   $0x10,0xc0129a68
c0106105:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0106107:	66 c7 05 48 8a 12 c0 	movw   $0x68,0xc0128a48
c010610e:	68 00 
c0106110:	b8 60 9a 12 c0       	mov    $0xc0129a60,%eax
c0106115:	66 a3 4a 8a 12 c0    	mov    %ax,0xc0128a4a
c010611b:	b8 60 9a 12 c0       	mov    $0xc0129a60,%eax
c0106120:	c1 e8 10             	shr    $0x10,%eax
c0106123:	a2 4c 8a 12 c0       	mov    %al,0xc0128a4c
c0106128:	0f b6 05 4d 8a 12 c0 	movzbl 0xc0128a4d,%eax
c010612f:	83 e0 f0             	and    $0xfffffff0,%eax
c0106132:	83 c8 09             	or     $0x9,%eax
c0106135:	a2 4d 8a 12 c0       	mov    %al,0xc0128a4d
c010613a:	0f b6 05 4d 8a 12 c0 	movzbl 0xc0128a4d,%eax
c0106141:	83 e0 ef             	and    $0xffffffef,%eax
c0106144:	a2 4d 8a 12 c0       	mov    %al,0xc0128a4d
c0106149:	0f b6 05 4d 8a 12 c0 	movzbl 0xc0128a4d,%eax
c0106150:	83 e0 9f             	and    $0xffffff9f,%eax
c0106153:	a2 4d 8a 12 c0       	mov    %al,0xc0128a4d
c0106158:	0f b6 05 4d 8a 12 c0 	movzbl 0xc0128a4d,%eax
c010615f:	83 c8 80             	or     $0xffffff80,%eax
c0106162:	a2 4d 8a 12 c0       	mov    %al,0xc0128a4d
c0106167:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c010616e:	83 e0 f0             	and    $0xfffffff0,%eax
c0106171:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c0106176:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c010617d:	83 e0 ef             	and    $0xffffffef,%eax
c0106180:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c0106185:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c010618c:	83 e0 df             	and    $0xffffffdf,%eax
c010618f:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c0106194:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c010619b:	83 c8 40             	or     $0x40,%eax
c010619e:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c01061a3:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c01061aa:	83 e0 7f             	and    $0x7f,%eax
c01061ad:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c01061b2:	b8 60 9a 12 c0       	mov    $0xc0129a60,%eax
c01061b7:	c1 e8 18             	shr    $0x18,%eax
c01061ba:	a2 4f 8a 12 c0       	mov    %al,0xc0128a4f

    // reload all segment registers
    lgdt(&gdt_pd);
c01061bf:	c7 04 24 50 8a 12 c0 	movl   $0xc0128a50,(%esp)
c01061c6:	e8 de fe ff ff       	call   c01060a9 <lgdt>
c01061cb:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c01061d1:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01061d5:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c01061d8:	c9                   	leave  
c01061d9:	c3                   	ret    

c01061da <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c01061da:	55                   	push   %ebp
c01061db:	89 e5                	mov    %esp,%ebp
c01061dd:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c01061e0:	c7 05 24 bb 12 c0 b0 	movl   $0xc010c0b0,0xc012bb24
c01061e7:	c0 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c01061ea:	a1 24 bb 12 c0       	mov    0xc012bb24,%eax
c01061ef:	8b 00                	mov    (%eax),%eax
c01061f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01061f5:	c7 04 24 50 c2 10 c0 	movl   $0xc010c250,(%esp)
c01061fc:	e8 d5 b5 ff ff       	call   c01017d6 <cprintf>
    pmm_manager->init();
c0106201:	a1 24 bb 12 c0       	mov    0xc012bb24,%eax
c0106206:	8b 40 04             	mov    0x4(%eax),%eax
c0106209:	ff d0                	call   *%eax
}
c010620b:	c9                   	leave  
c010620c:	c3                   	ret    

c010620d <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c010620d:	55                   	push   %ebp
c010620e:	89 e5                	mov    %esp,%ebp
c0106210:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0106213:	a1 24 bb 12 c0       	mov    0xc012bb24,%eax
c0106218:	8b 40 08             	mov    0x8(%eax),%eax
c010621b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010621e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106222:	8b 55 08             	mov    0x8(%ebp),%edx
c0106225:	89 14 24             	mov    %edx,(%esp)
c0106228:	ff d0                	call   *%eax
}
c010622a:	c9                   	leave  
c010622b:	c3                   	ret    

c010622c <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c010622c:	55                   	push   %ebp
c010622d:	89 e5                	mov    %esp,%ebp
c010622f:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0106232:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0106239:	e8 2e fe ff ff       	call   c010606c <__intr_save>
c010623e:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0106241:	a1 24 bb 12 c0       	mov    0xc012bb24,%eax
c0106246:	8b 40 0c             	mov    0xc(%eax),%eax
c0106249:	8b 55 08             	mov    0x8(%ebp),%edx
c010624c:	89 14 24             	mov    %edx,(%esp)
c010624f:	ff d0                	call   *%eax
c0106251:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0106254:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106257:	89 04 24             	mov    %eax,(%esp)
c010625a:	e8 37 fe ff ff       	call   c0106096 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c010625f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106263:	75 2d                	jne    c0106292 <alloc_pages+0x66>
c0106265:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0106269:	77 27                	ja     c0106292 <alloc_pages+0x66>
c010626b:	a1 cc 9a 12 c0       	mov    0xc0129acc,%eax
c0106270:	85 c0                	test   %eax,%eax
c0106272:	74 1e                	je     c0106292 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0106274:	8b 55 08             	mov    0x8(%ebp),%edx
c0106277:	a1 0c bc 12 c0       	mov    0xc012bc0c,%eax
c010627c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106283:	00 
c0106284:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106288:	89 04 24             	mov    %eax,(%esp)
c010628b:	e8 7c 19 00 00       	call   c0107c0c <swap_out>
    }
c0106290:	eb a7                	jmp    c0106239 <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c0106292:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106295:	c9                   	leave  
c0106296:	c3                   	ret    

c0106297 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0106297:	55                   	push   %ebp
c0106298:	89 e5                	mov    %esp,%ebp
c010629a:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010629d:	e8 ca fd ff ff       	call   c010606c <__intr_save>
c01062a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01062a5:	a1 24 bb 12 c0       	mov    0xc012bb24,%eax
c01062aa:	8b 40 10             	mov    0x10(%eax),%eax
c01062ad:	8b 55 0c             	mov    0xc(%ebp),%edx
c01062b0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01062b4:	8b 55 08             	mov    0x8(%ebp),%edx
c01062b7:	89 14 24             	mov    %edx,(%esp)
c01062ba:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c01062bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062bf:	89 04 24             	mov    %eax,(%esp)
c01062c2:	e8 cf fd ff ff       	call   c0106096 <__intr_restore>
}
c01062c7:	c9                   	leave  
c01062c8:	c3                   	ret    

c01062c9 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c01062c9:	55                   	push   %ebp
c01062ca:	89 e5                	mov    %esp,%ebp
c01062cc:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c01062cf:	e8 98 fd ff ff       	call   c010606c <__intr_save>
c01062d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01062d7:	a1 24 bb 12 c0       	mov    0xc012bb24,%eax
c01062dc:	8b 40 14             	mov    0x14(%eax),%eax
c01062df:	ff d0                	call   *%eax
c01062e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c01062e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062e7:	89 04 24             	mov    %eax,(%esp)
c01062ea:	e8 a7 fd ff ff       	call   c0106096 <__intr_restore>
    return ret;
c01062ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01062f2:	c9                   	leave  
c01062f3:	c3                   	ret    

c01062f4 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c01062f4:	55                   	push   %ebp
c01062f5:	89 e5                	mov    %esp,%ebp
c01062f7:	57                   	push   %edi
c01062f8:	56                   	push   %esi
c01062f9:	53                   	push   %ebx
c01062fa:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0106300:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0106307:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c010630e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0106315:	c7 04 24 67 c2 10 c0 	movl   $0xc010c267,(%esp)
c010631c:	e8 b5 b4 ff ff       	call   c01017d6 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0106321:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106328:	e9 15 01 00 00       	jmp    c0106442 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010632d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106330:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106333:	89 d0                	mov    %edx,%eax
c0106335:	c1 e0 02             	shl    $0x2,%eax
c0106338:	01 d0                	add    %edx,%eax
c010633a:	c1 e0 02             	shl    $0x2,%eax
c010633d:	01 c8                	add    %ecx,%eax
c010633f:	8b 50 08             	mov    0x8(%eax),%edx
c0106342:	8b 40 04             	mov    0x4(%eax),%eax
c0106345:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106348:	89 55 bc             	mov    %edx,-0x44(%ebp)
c010634b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010634e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106351:	89 d0                	mov    %edx,%eax
c0106353:	c1 e0 02             	shl    $0x2,%eax
c0106356:	01 d0                	add    %edx,%eax
c0106358:	c1 e0 02             	shl    $0x2,%eax
c010635b:	01 c8                	add    %ecx,%eax
c010635d:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106360:	8b 58 10             	mov    0x10(%eax),%ebx
c0106363:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106366:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0106369:	01 c8                	add    %ecx,%eax
c010636b:	11 da                	adc    %ebx,%edx
c010636d:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0106370:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0106373:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106376:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106379:	89 d0                	mov    %edx,%eax
c010637b:	c1 e0 02             	shl    $0x2,%eax
c010637e:	01 d0                	add    %edx,%eax
c0106380:	c1 e0 02             	shl    $0x2,%eax
c0106383:	01 c8                	add    %ecx,%eax
c0106385:	83 c0 14             	add    $0x14,%eax
c0106388:	8b 00                	mov    (%eax),%eax
c010638a:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0106390:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106393:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106396:	83 c0 ff             	add    $0xffffffff,%eax
c0106399:	83 d2 ff             	adc    $0xffffffff,%edx
c010639c:	89 c6                	mov    %eax,%esi
c010639e:	89 d7                	mov    %edx,%edi
c01063a0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01063a3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01063a6:	89 d0                	mov    %edx,%eax
c01063a8:	c1 e0 02             	shl    $0x2,%eax
c01063ab:	01 d0                	add    %edx,%eax
c01063ad:	c1 e0 02             	shl    $0x2,%eax
c01063b0:	01 c8                	add    %ecx,%eax
c01063b2:	8b 48 0c             	mov    0xc(%eax),%ecx
c01063b5:	8b 58 10             	mov    0x10(%eax),%ebx
c01063b8:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c01063be:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c01063c2:	89 74 24 14          	mov    %esi,0x14(%esp)
c01063c6:	89 7c 24 18          	mov    %edi,0x18(%esp)
c01063ca:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01063cd:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01063d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01063d4:	89 54 24 10          	mov    %edx,0x10(%esp)
c01063d8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01063dc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c01063e0:	c7 04 24 74 c2 10 c0 	movl   $0xc010c274,(%esp)
c01063e7:	e8 ea b3 ff ff       	call   c01017d6 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c01063ec:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01063ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01063f2:	89 d0                	mov    %edx,%eax
c01063f4:	c1 e0 02             	shl    $0x2,%eax
c01063f7:	01 d0                	add    %edx,%eax
c01063f9:	c1 e0 02             	shl    $0x2,%eax
c01063fc:	01 c8                	add    %ecx,%eax
c01063fe:	83 c0 14             	add    $0x14,%eax
c0106401:	8b 00                	mov    (%eax),%eax
c0106403:	83 f8 01             	cmp    $0x1,%eax
c0106406:	75 36                	jne    c010643e <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0106408:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010640b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010640e:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0106411:	77 2b                	ja     c010643e <page_init+0x14a>
c0106413:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0106416:	72 05                	jb     c010641d <page_init+0x129>
c0106418:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c010641b:	73 21                	jae    c010643e <page_init+0x14a>
c010641d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106421:	77 1b                	ja     c010643e <page_init+0x14a>
c0106423:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106427:	72 09                	jb     c0106432 <page_init+0x13e>
c0106429:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0106430:	77 0c                	ja     c010643e <page_init+0x14a>
                maxpa = end;
c0106432:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106435:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106438:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010643b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c010643e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0106442:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106445:	8b 00                	mov    (%eax),%eax
c0106447:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010644a:	0f 8f dd fe ff ff    	jg     c010632d <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0106450:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106454:	72 1d                	jb     c0106473 <page_init+0x17f>
c0106456:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010645a:	77 09                	ja     c0106465 <page_init+0x171>
c010645c:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0106463:	76 0e                	jbe    c0106473 <page_init+0x17f>
        maxpa = KMEMSIZE;
c0106465:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c010646c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0106473:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106476:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106479:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010647d:	c1 ea 0c             	shr    $0xc,%edx
c0106480:	a3 40 9a 12 c0       	mov    %eax,0xc0129a40
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0106485:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c010648c:	b8 18 bc 12 c0       	mov    $0xc012bc18,%eax
c0106491:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106494:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0106497:	01 d0                	add    %edx,%eax
c0106499:	89 45 a8             	mov    %eax,-0x58(%ebp)
c010649c:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010649f:	ba 00 00 00 00       	mov    $0x0,%edx
c01064a4:	f7 75 ac             	divl   -0x54(%ebp)
c01064a7:	89 d0                	mov    %edx,%eax
c01064a9:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01064ac:	29 c2                	sub    %eax,%edx
c01064ae:	89 d0                	mov    %edx,%eax
c01064b0:	a3 2c bb 12 c0       	mov    %eax,0xc012bb2c

    for (i = 0; i < npage; i ++) {
c01064b5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01064bc:	eb 2f                	jmp    c01064ed <page_init+0x1f9>
        SetPageReserved(pages + i);
c01064be:	8b 0d 2c bb 12 c0    	mov    0xc012bb2c,%ecx
c01064c4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01064c7:	89 d0                	mov    %edx,%eax
c01064c9:	c1 e0 03             	shl    $0x3,%eax
c01064cc:	01 d0                	add    %edx,%eax
c01064ce:	c1 e0 02             	shl    $0x2,%eax
c01064d1:	01 c8                	add    %ecx,%eax
c01064d3:	83 c0 04             	add    $0x4,%eax
c01064d6:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c01064dd:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01064e0:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01064e3:	8b 55 90             	mov    -0x70(%ebp),%edx
c01064e6:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c01064e9:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01064ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01064f0:	a1 40 9a 12 c0       	mov    0xc0129a40,%eax
c01064f5:	39 c2                	cmp    %eax,%edx
c01064f7:	72 c5                	jb     c01064be <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c01064f9:	8b 15 40 9a 12 c0    	mov    0xc0129a40,%edx
c01064ff:	89 d0                	mov    %edx,%eax
c0106501:	c1 e0 03             	shl    $0x3,%eax
c0106504:	01 d0                	add    %edx,%eax
c0106506:	c1 e0 02             	shl    $0x2,%eax
c0106509:	89 c2                	mov    %eax,%edx
c010650b:	a1 2c bb 12 c0       	mov    0xc012bb2c,%eax
c0106510:	01 d0                	add    %edx,%eax
c0106512:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0106515:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c010651c:	77 23                	ja     c0106541 <page_init+0x24d>
c010651e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106521:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106525:	c7 44 24 08 a4 c2 10 	movl   $0xc010c2a4,0x8(%esp)
c010652c:	c0 
c010652d:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0106534:	00 
c0106535:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c010653c:	e8 1f bc ff ff       	call   c0102160 <__panic>
c0106541:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106544:	05 00 00 00 40       	add    $0x40000000,%eax
c0106549:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c010654c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106553:	e9 74 01 00 00       	jmp    c01066cc <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0106558:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010655b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010655e:	89 d0                	mov    %edx,%eax
c0106560:	c1 e0 02             	shl    $0x2,%eax
c0106563:	01 d0                	add    %edx,%eax
c0106565:	c1 e0 02             	shl    $0x2,%eax
c0106568:	01 c8                	add    %ecx,%eax
c010656a:	8b 50 08             	mov    0x8(%eax),%edx
c010656d:	8b 40 04             	mov    0x4(%eax),%eax
c0106570:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106573:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106576:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106579:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010657c:	89 d0                	mov    %edx,%eax
c010657e:	c1 e0 02             	shl    $0x2,%eax
c0106581:	01 d0                	add    %edx,%eax
c0106583:	c1 e0 02             	shl    $0x2,%eax
c0106586:	01 c8                	add    %ecx,%eax
c0106588:	8b 48 0c             	mov    0xc(%eax),%ecx
c010658b:	8b 58 10             	mov    0x10(%eax),%ebx
c010658e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106591:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106594:	01 c8                	add    %ecx,%eax
c0106596:	11 da                	adc    %ebx,%edx
c0106598:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010659b:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c010659e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01065a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01065a4:	89 d0                	mov    %edx,%eax
c01065a6:	c1 e0 02             	shl    $0x2,%eax
c01065a9:	01 d0                	add    %edx,%eax
c01065ab:	c1 e0 02             	shl    $0x2,%eax
c01065ae:	01 c8                	add    %ecx,%eax
c01065b0:	83 c0 14             	add    $0x14,%eax
c01065b3:	8b 00                	mov    (%eax),%eax
c01065b5:	83 f8 01             	cmp    $0x1,%eax
c01065b8:	0f 85 0a 01 00 00    	jne    c01066c8 <page_init+0x3d4>
            if (begin < freemem) {
c01065be:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01065c1:	ba 00 00 00 00       	mov    $0x0,%edx
c01065c6:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01065c9:	72 17                	jb     c01065e2 <page_init+0x2ee>
c01065cb:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01065ce:	77 05                	ja     c01065d5 <page_init+0x2e1>
c01065d0:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01065d3:	76 0d                	jbe    c01065e2 <page_init+0x2ee>
                begin = freemem;
c01065d5:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01065d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01065db:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01065e2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01065e6:	72 1d                	jb     c0106605 <page_init+0x311>
c01065e8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01065ec:	77 09                	ja     c01065f7 <page_init+0x303>
c01065ee:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c01065f5:	76 0e                	jbe    c0106605 <page_init+0x311>
                end = KMEMSIZE;
c01065f7:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01065fe:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0106605:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106608:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010660b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010660e:	0f 87 b4 00 00 00    	ja     c01066c8 <page_init+0x3d4>
c0106614:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106617:	72 09                	jb     c0106622 <page_init+0x32e>
c0106619:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010661c:	0f 83 a6 00 00 00    	jae    c01066c8 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
c0106622:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0106629:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010662c:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010662f:	01 d0                	add    %edx,%eax
c0106631:	83 e8 01             	sub    $0x1,%eax
c0106634:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106637:	8b 45 98             	mov    -0x68(%ebp),%eax
c010663a:	ba 00 00 00 00       	mov    $0x0,%edx
c010663f:	f7 75 9c             	divl   -0x64(%ebp)
c0106642:	89 d0                	mov    %edx,%eax
c0106644:	8b 55 98             	mov    -0x68(%ebp),%edx
c0106647:	29 c2                	sub    %eax,%edx
c0106649:	89 d0                	mov    %edx,%eax
c010664b:	ba 00 00 00 00       	mov    $0x0,%edx
c0106650:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106653:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0106656:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106659:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010665c:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010665f:	ba 00 00 00 00       	mov    $0x0,%edx
c0106664:	89 c7                	mov    %eax,%edi
c0106666:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c010666c:	89 7d 80             	mov    %edi,-0x80(%ebp)
c010666f:	89 d0                	mov    %edx,%eax
c0106671:	83 e0 00             	and    $0x0,%eax
c0106674:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0106677:	8b 45 80             	mov    -0x80(%ebp),%eax
c010667a:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010667d:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0106680:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0106683:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106686:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106689:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010668c:	77 3a                	ja     c01066c8 <page_init+0x3d4>
c010668e:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106691:	72 05                	jb     c0106698 <page_init+0x3a4>
c0106693:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0106696:	73 30                	jae    c01066c8 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0106698:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c010669b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c010669e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01066a1:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01066a4:	29 c8                	sub    %ecx,%eax
c01066a6:	19 da                	sbb    %ebx,%edx
c01066a8:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01066ac:	c1 ea 0c             	shr    $0xc,%edx
c01066af:	89 c3                	mov    %eax,%ebx
c01066b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01066b4:	89 04 24             	mov    %eax,(%esp)
c01066b7:	e8 8a f8 ff ff       	call   c0105f46 <pa2page>
c01066bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01066c0:	89 04 24             	mov    %eax,(%esp)
c01066c3:	e8 45 fb ff ff       	call   c010620d <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c01066c8:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01066cc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01066cf:	8b 00                	mov    (%eax),%eax
c01066d1:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01066d4:	0f 8f 7e fe ff ff    	jg     c0106558 <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c01066da:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01066e0:	5b                   	pop    %ebx
c01066e1:	5e                   	pop    %esi
c01066e2:	5f                   	pop    %edi
c01066e3:	5d                   	pop    %ebp
c01066e4:	c3                   	ret    

c01066e5 <enable_paging>:

static void
enable_paging(void) {
c01066e5:	55                   	push   %ebp
c01066e6:	89 e5                	mov    %esp,%ebp
c01066e8:	83 ec 10             	sub    $0x10,%esp
    lcr3(boot_cr3);
c01066eb:	a1 28 bb 12 c0       	mov    0xc012bb28,%eax
c01066f0:	89 45 f8             	mov    %eax,-0x8(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c01066f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01066f6:	0f 22 d8             	mov    %eax,%cr3
}

static inline uintptr_t
rcr0(void) {
    uintptr_t cr0;
    asm volatile ("mov %%cr0, %0" : "=r" (cr0) :: "memory");
c01066f9:	0f 20 c0             	mov    %cr0,%eax
c01066fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr0;
c01066ff:	8b 45 f4             	mov    -0xc(%ebp),%eax

    // turn on paging
    uint32_t cr0 = rcr0();
c0106702:	89 45 fc             	mov    %eax,-0x4(%ebp)
    cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP;
c0106705:	81 4d fc 2f 00 05 80 	orl    $0x8005002f,-0x4(%ebp)
    cr0 &= ~(CR0_TS | CR0_EM);
c010670c:	83 65 fc f3          	andl   $0xfffffff3,-0x4(%ebp)
c0106710:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106713:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile ("pushl %0; popfl" :: "r" (eflags));
}

static inline void
lcr0(uintptr_t cr0) {
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
c0106716:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106719:	0f 22 c0             	mov    %eax,%cr0
    lcr0(cr0);
}
c010671c:	c9                   	leave  
c010671d:	c3                   	ret    

c010671e <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010671e:	55                   	push   %ebp
c010671f:	89 e5                	mov    %esp,%ebp
c0106721:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0106724:	8b 45 14             	mov    0x14(%ebp),%eax
c0106727:	8b 55 0c             	mov    0xc(%ebp),%edx
c010672a:	31 d0                	xor    %edx,%eax
c010672c:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106731:	85 c0                	test   %eax,%eax
c0106733:	74 24                	je     c0106759 <boot_map_segment+0x3b>
c0106735:	c7 44 24 0c d6 c2 10 	movl   $0xc010c2d6,0xc(%esp)
c010673c:	c0 
c010673d:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0106744:	c0 
c0106745:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c010674c:	00 
c010674d:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0106754:	e8 07 ba ff ff       	call   c0102160 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0106759:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0106760:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106763:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106768:	89 c2                	mov    %eax,%edx
c010676a:	8b 45 10             	mov    0x10(%ebp),%eax
c010676d:	01 c2                	add    %eax,%edx
c010676f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106772:	01 d0                	add    %edx,%eax
c0106774:	83 e8 01             	sub    $0x1,%eax
c0106777:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010677a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010677d:	ba 00 00 00 00       	mov    $0x0,%edx
c0106782:	f7 75 f0             	divl   -0x10(%ebp)
c0106785:	89 d0                	mov    %edx,%eax
c0106787:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010678a:	29 c2                	sub    %eax,%edx
c010678c:	89 d0                	mov    %edx,%eax
c010678e:	c1 e8 0c             	shr    $0xc,%eax
c0106791:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0106794:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106797:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010679a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010679d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01067a2:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01067a5:	8b 45 14             	mov    0x14(%ebp),%eax
c01067a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01067ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01067ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01067b3:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01067b6:	eb 6b                	jmp    c0106823 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01067b8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01067bf:	00 
c01067c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01067c3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01067c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01067ca:	89 04 24             	mov    %eax,(%esp)
c01067cd:	e8 d1 01 00 00       	call   c01069a3 <get_pte>
c01067d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01067d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01067d9:	75 24                	jne    c01067ff <boot_map_segment+0xe1>
c01067db:	c7 44 24 0c 02 c3 10 	movl   $0xc010c302,0xc(%esp)
c01067e2:	c0 
c01067e3:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c01067ea:	c0 
c01067eb:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c01067f2:	00 
c01067f3:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c01067fa:	e8 61 b9 ff ff       	call   c0102160 <__panic>
        *ptep = pa | PTE_P | perm;
c01067ff:	8b 45 18             	mov    0x18(%ebp),%eax
c0106802:	8b 55 14             	mov    0x14(%ebp),%edx
c0106805:	09 d0                	or     %edx,%eax
c0106807:	83 c8 01             	or     $0x1,%eax
c010680a:	89 c2                	mov    %eax,%edx
c010680c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010680f:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0106811:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0106815:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010681c:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0106823:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106827:	75 8f                	jne    c01067b8 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0106829:	c9                   	leave  
c010682a:	c3                   	ret    

c010682b <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010682b:	55                   	push   %ebp
c010682c:	89 e5                	mov    %esp,%ebp
c010682e:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0106831:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106838:	e8 ef f9 ff ff       	call   c010622c <alloc_pages>
c010683d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0106840:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106844:	75 1c                	jne    c0106862 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0106846:	c7 44 24 08 0f c3 10 	movl   $0xc010c30f,0x8(%esp)
c010684d:	c0 
c010684e:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c0106855:	00 
c0106856:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c010685d:	e8 fe b8 ff ff       	call   c0102160 <__panic>
    }
    return page2kva(p);
c0106862:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106865:	89 04 24             	mov    %eax,(%esp)
c0106868:	e8 28 f7 ff ff       	call   c0105f95 <page2kva>
}
c010686d:	c9                   	leave  
c010686e:	c3                   	ret    

c010686f <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c010686f:	55                   	push   %ebp
c0106870:	89 e5                	mov    %esp,%ebp
c0106872:	83 ec 38             	sub    $0x38,%esp
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0106875:	e8 60 f9 ff ff       	call   c01061da <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c010687a:	e8 75 fa ff ff       	call   c01062f4 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c010687f:	e8 36 05 00 00       	call   c0106dba <check_alloc_page>

    // create boot_pgdir, an initial page directory(Page Directory Table, PDT)
    boot_pgdir = boot_alloc_page();
c0106884:	e8 a2 ff ff ff       	call   c010682b <boot_alloc_page>
c0106889:	a3 44 9a 12 c0       	mov    %eax,0xc0129a44
    memset(boot_pgdir, 0, PGSIZE);
c010688e:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0106893:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010689a:	00 
c010689b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01068a2:	00 
c01068a3:	89 04 24             	mov    %eax,(%esp)
c01068a6:	e8 12 48 00 00       	call   c010b0bd <memset>
    boot_cr3 = PADDR(boot_pgdir);
c01068ab:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c01068b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01068b3:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01068ba:	77 23                	ja     c01068df <pmm_init+0x70>
c01068bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01068bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01068c3:	c7 44 24 08 a4 c2 10 	movl   $0xc010c2a4,0x8(%esp)
c01068ca:	c0 
c01068cb:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c01068d2:	00 
c01068d3:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c01068da:	e8 81 b8 ff ff       	call   c0102160 <__panic>
c01068df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01068e2:	05 00 00 00 40       	add    $0x40000000,%eax
c01068e7:	a3 28 bb 12 c0       	mov    %eax,0xc012bb28

    check_pgdir();
c01068ec:	e8 e7 04 00 00       	call   c0106dd8 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01068f1:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c01068f6:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c01068fc:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0106901:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106904:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c010690b:	77 23                	ja     c0106930 <pmm_init+0xc1>
c010690d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106910:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106914:	c7 44 24 08 a4 c2 10 	movl   $0xc010c2a4,0x8(%esp)
c010691b:	c0 
c010691c:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
c0106923:	00 
c0106924:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c010692b:	e8 30 b8 ff ff       	call   c0102160 <__panic>
c0106930:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106933:	05 00 00 00 40       	add    $0x40000000,%eax
c0106938:	83 c8 03             	or     $0x3,%eax
c010693b:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    //linear_addr KERNBASE~KERNBASE+KMEMSIZE = phy_addr 0~KMEMSIZE
    //But shouldn't use this map until enable_paging() & gdt_init() finished.
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c010693d:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0106942:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0106949:	00 
c010694a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106951:	00 
c0106952:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0106959:	38 
c010695a:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0106961:	c0 
c0106962:	89 04 24             	mov    %eax,(%esp)
c0106965:	e8 b4 fd ff ff       	call   c010671e <boot_map_segment>

    //temporary map: 
    //virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M = phy_addr 0~4M     
    boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];
c010696a:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c010696f:	8b 15 44 9a 12 c0    	mov    0xc0129a44,%edx
c0106975:	8b 92 00 0c 00 00    	mov    0xc00(%edx),%edx
c010697b:	89 10                	mov    %edx,(%eax)

    enable_paging();
c010697d:	e8 63 fd ff ff       	call   c01066e5 <enable_paging>

    //reload gdt(third time,the last time) to map all physical memory
    //virtual_addr 0~4G=liear_addr 0~4G
    //then set kernel stack(ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0106982:	e8 64 f7 ff ff       	call   c01060eb <gdt_init>

    //disable the map of virtual_addr 0~4M
    boot_pgdir[0] = 0;
c0106987:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c010698c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0106992:	e8 dc 0a 00 00       	call   c0107473 <check_boot_pgdir>

    print_pgdir();
c0106997:	e8 69 0f 00 00       	call   c0107905 <print_pgdir>
    
    kmalloc_init();
c010699c:	e8 de f2 ff ff       	call   c0105c7f <kmalloc_init>

}
c01069a1:	c9                   	leave  
c01069a2:	c3                   	ret    

c01069a3 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01069a3:	55                   	push   %ebp
c01069a4:	89 e5                	mov    %esp,%ebp
c01069a6:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c01069a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01069ac:	c1 e8 16             	shr    $0x16,%eax
c01069af:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01069b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01069b9:	01 d0                	add    %edx,%eax
c01069bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c01069be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01069c1:	8b 00                	mov    (%eax),%eax
c01069c3:	83 e0 01             	and    $0x1,%eax
c01069c6:	85 c0                	test   %eax,%eax
c01069c8:	0f 85 af 00 00 00    	jne    c0106a7d <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c01069ce:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01069d2:	74 15                	je     c01069e9 <get_pte+0x46>
c01069d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01069db:	e8 4c f8 ff ff       	call   c010622c <alloc_pages>
c01069e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01069e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01069e7:	75 0a                	jne    c01069f3 <get_pte+0x50>
            return NULL;
c01069e9:	b8 00 00 00 00       	mov    $0x0,%eax
c01069ee:	e9 e6 00 00 00       	jmp    c0106ad9 <get_pte+0x136>
        }
        set_page_ref(page, 1);
c01069f3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01069fa:	00 
c01069fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069fe:	89 04 24             	mov    %eax,(%esp)
c0106a01:	e8 2b f6 ff ff       	call   c0106031 <set_page_ref>
        uintptr_t pa = page2pa(page);
c0106a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a09:	89 04 24             	mov    %eax,(%esp)
c0106a0c:	e8 1f f5 ff ff       	call   c0105f30 <page2pa>
c0106a11:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0106a14:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a17:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106a1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106a1d:	c1 e8 0c             	shr    $0xc,%eax
c0106a20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106a23:	a1 40 9a 12 c0       	mov    0xc0129a40,%eax
c0106a28:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0106a2b:	72 23                	jb     c0106a50 <get_pte+0xad>
c0106a2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106a30:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106a34:	c7 44 24 08 00 c2 10 	movl   $0xc010c200,0x8(%esp)
c0106a3b:	c0 
c0106a3c:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
c0106a43:	00 
c0106a44:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0106a4b:	e8 10 b7 ff ff       	call   c0102160 <__panic>
c0106a50:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106a53:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106a58:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0106a5f:	00 
c0106a60:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106a67:	00 
c0106a68:	89 04 24             	mov    %eax,(%esp)
c0106a6b:	e8 4d 46 00 00       	call   c010b0bd <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0106a70:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a73:	83 c8 07             	or     $0x7,%eax
c0106a76:	89 c2                	mov    %eax,%edx
c0106a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a7b:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0106a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a80:	8b 00                	mov    (%eax),%eax
c0106a82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106a87:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106a8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106a8d:	c1 e8 0c             	shr    $0xc,%eax
c0106a90:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106a93:	a1 40 9a 12 c0       	mov    0xc0129a40,%eax
c0106a98:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106a9b:	72 23                	jb     c0106ac0 <get_pte+0x11d>
c0106a9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106aa0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106aa4:	c7 44 24 08 00 c2 10 	movl   $0xc010c200,0x8(%esp)
c0106aab:	c0 
c0106aac:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
c0106ab3:	00 
c0106ab4:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0106abb:	e8 a0 b6 ff ff       	call   c0102160 <__panic>
c0106ac0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106ac3:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106ac8:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106acb:	c1 ea 0c             	shr    $0xc,%edx
c0106ace:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c0106ad4:	c1 e2 02             	shl    $0x2,%edx
c0106ad7:	01 d0                	add    %edx,%eax
}
c0106ad9:	c9                   	leave  
c0106ada:	c3                   	ret    

c0106adb <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0106adb:	55                   	push   %ebp
c0106adc:	89 e5                	mov    %esp,%ebp
c0106ade:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0106ae1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106ae8:	00 
c0106ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106aec:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106af0:	8b 45 08             	mov    0x8(%ebp),%eax
c0106af3:	89 04 24             	mov    %eax,(%esp)
c0106af6:	e8 a8 fe ff ff       	call   c01069a3 <get_pte>
c0106afb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0106afe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106b02:	74 08                	je     c0106b0c <get_page+0x31>
        *ptep_store = ptep;
c0106b04:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b07:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106b0a:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0106b0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106b10:	74 1b                	je     c0106b2d <get_page+0x52>
c0106b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b15:	8b 00                	mov    (%eax),%eax
c0106b17:	83 e0 01             	and    $0x1,%eax
c0106b1a:	85 c0                	test   %eax,%eax
c0106b1c:	74 0f                	je     c0106b2d <get_page+0x52>
        return pa2page(*ptep);
c0106b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b21:	8b 00                	mov    (%eax),%eax
c0106b23:	89 04 24             	mov    %eax,(%esp)
c0106b26:	e8 1b f4 ff ff       	call   c0105f46 <pa2page>
c0106b2b:	eb 05                	jmp    c0106b32 <get_page+0x57>
    }
    return NULL;
c0106b2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106b32:	c9                   	leave  
c0106b33:	c3                   	ret    

c0106b34 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0106b34:	55                   	push   %ebp
c0106b35:	89 e5                	mov    %esp,%ebp
c0106b37:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c0106b3a:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b3d:	8b 00                	mov    (%eax),%eax
c0106b3f:	83 e0 01             	and    $0x1,%eax
c0106b42:	85 c0                	test   %eax,%eax
c0106b44:	74 4d                	je     c0106b93 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0106b46:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b49:	8b 00                	mov    (%eax),%eax
c0106b4b:	89 04 24             	mov    %eax,(%esp)
c0106b4e:	e8 96 f4 ff ff       	call   c0105fe9 <pte2page>
c0106b53:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0106b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b59:	89 04 24             	mov    %eax,(%esp)
c0106b5c:	e8 f4 f4 ff ff       	call   c0106055 <page_ref_dec>
c0106b61:	85 c0                	test   %eax,%eax
c0106b63:	75 13                	jne    c0106b78 <page_remove_pte+0x44>
            free_page(page);
c0106b65:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106b6c:	00 
c0106b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b70:	89 04 24             	mov    %eax,(%esp)
c0106b73:	e8 1f f7 ff ff       	call   c0106297 <free_pages>
        }
        *ptep = 0;
c0106b78:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b7b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0106b81:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b88:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b8b:	89 04 24             	mov    %eax,(%esp)
c0106b8e:	e8 ff 00 00 00       	call   c0106c92 <tlb_invalidate>
    }
}
c0106b93:	c9                   	leave  
c0106b94:	c3                   	ret    

c0106b95 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0106b95:	55                   	push   %ebp
c0106b96:	89 e5                	mov    %esp,%ebp
c0106b98:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0106b9b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106ba2:	00 
c0106ba3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ba6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106baa:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bad:	89 04 24             	mov    %eax,(%esp)
c0106bb0:	e8 ee fd ff ff       	call   c01069a3 <get_pte>
c0106bb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0106bb8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106bbc:	74 19                	je     c0106bd7 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0106bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106bc1:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106bc5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bc8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bcf:	89 04 24             	mov    %eax,(%esp)
c0106bd2:	e8 5d ff ff ff       	call   c0106b34 <page_remove_pte>
    }
}
c0106bd7:	c9                   	leave  
c0106bd8:	c3                   	ret    

c0106bd9 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0106bd9:	55                   	push   %ebp
c0106bda:	89 e5                	mov    %esp,%ebp
c0106bdc:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0106bdf:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106be6:	00 
c0106be7:	8b 45 10             	mov    0x10(%ebp),%eax
c0106bea:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bee:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bf1:	89 04 24             	mov    %eax,(%esp)
c0106bf4:	e8 aa fd ff ff       	call   c01069a3 <get_pte>
c0106bf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0106bfc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106c00:	75 0a                	jne    c0106c0c <page_insert+0x33>
        return -E_NO_MEM;
c0106c02:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0106c07:	e9 84 00 00 00       	jmp    c0106c90 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0106c0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c0f:	89 04 24             	mov    %eax,(%esp)
c0106c12:	e8 27 f4 ff ff       	call   c010603e <page_ref_inc>
    if (*ptep & PTE_P) {
c0106c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c1a:	8b 00                	mov    (%eax),%eax
c0106c1c:	83 e0 01             	and    $0x1,%eax
c0106c1f:	85 c0                	test   %eax,%eax
c0106c21:	74 3e                	je     c0106c61 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0106c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c26:	8b 00                	mov    (%eax),%eax
c0106c28:	89 04 24             	mov    %eax,(%esp)
c0106c2b:	e8 b9 f3 ff ff       	call   c0105fe9 <pte2page>
c0106c30:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0106c33:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c36:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106c39:	75 0d                	jne    c0106c48 <page_insert+0x6f>
            page_ref_dec(page);
c0106c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c3e:	89 04 24             	mov    %eax,(%esp)
c0106c41:	e8 0f f4 ff ff       	call   c0106055 <page_ref_dec>
c0106c46:	eb 19                	jmp    c0106c61 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0106c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c4b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106c4f:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c52:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c56:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c59:	89 04 24             	mov    %eax,(%esp)
c0106c5c:	e8 d3 fe ff ff       	call   c0106b34 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0106c61:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c64:	89 04 24             	mov    %eax,(%esp)
c0106c67:	e8 c4 f2 ff ff       	call   c0105f30 <page2pa>
c0106c6c:	0b 45 14             	or     0x14(%ebp),%eax
c0106c6f:	83 c8 01             	or     $0x1,%eax
c0106c72:	89 c2                	mov    %eax,%edx
c0106c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c77:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0106c79:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c7c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c80:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c83:	89 04 24             	mov    %eax,(%esp)
c0106c86:	e8 07 00 00 00       	call   c0106c92 <tlb_invalidate>
    return 0;
c0106c8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106c90:	c9                   	leave  
c0106c91:	c3                   	ret    

c0106c92 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0106c92:	55                   	push   %ebp
c0106c93:	89 e5                	mov    %esp,%ebp
c0106c95:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0106c98:	0f 20 d8             	mov    %cr3,%eax
c0106c9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0106c9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0106ca1:	89 c2                	mov    %eax,%edx
c0106ca3:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ca6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106ca9:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0106cb0:	77 23                	ja     c0106cd5 <tlb_invalidate+0x43>
c0106cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cb5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106cb9:	c7 44 24 08 a4 c2 10 	movl   $0xc010c2a4,0x8(%esp)
c0106cc0:	c0 
c0106cc1:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c0106cc8:	00 
c0106cc9:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0106cd0:	e8 8b b4 ff ff       	call   c0102160 <__panic>
c0106cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cd8:	05 00 00 00 40       	add    $0x40000000,%eax
c0106cdd:	39 c2                	cmp    %eax,%edx
c0106cdf:	75 0c                	jne    c0106ced <tlb_invalidate+0x5b>
        invlpg((void *)la);
c0106ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ce4:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0106ce7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106cea:	0f 01 38             	invlpg (%eax)
    }
}
c0106ced:	c9                   	leave  
c0106cee:	c3                   	ret    

c0106cef <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0106cef:	55                   	push   %ebp
c0106cf0:	89 e5                	mov    %esp,%ebp
c0106cf2:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0106cf5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106cfc:	e8 2b f5 ff ff       	call   c010622c <alloc_pages>
c0106d01:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0106d04:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106d08:	0f 84 a7 00 00 00    	je     c0106db5 <pgdir_alloc_page+0xc6>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0106d0e:	8b 45 10             	mov    0x10(%ebp),%eax
c0106d11:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106d15:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d18:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d1f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106d23:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d26:	89 04 24             	mov    %eax,(%esp)
c0106d29:	e8 ab fe ff ff       	call   c0106bd9 <page_insert>
c0106d2e:	85 c0                	test   %eax,%eax
c0106d30:	74 1a                	je     c0106d4c <pgdir_alloc_page+0x5d>
            free_page(page);
c0106d32:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106d39:	00 
c0106d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d3d:	89 04 24             	mov    %eax,(%esp)
c0106d40:	e8 52 f5 ff ff       	call   c0106297 <free_pages>
            return NULL;
c0106d45:	b8 00 00 00 00       	mov    $0x0,%eax
c0106d4a:	eb 6c                	jmp    c0106db8 <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c0106d4c:	a1 cc 9a 12 c0       	mov    0xc0129acc,%eax
c0106d51:	85 c0                	test   %eax,%eax
c0106d53:	74 60                	je     c0106db5 <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c0106d55:	a1 0c bc 12 c0       	mov    0xc012bc0c,%eax
c0106d5a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106d61:	00 
c0106d62:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106d65:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106d69:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106d6c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106d70:	89 04 24             	mov    %eax,(%esp)
c0106d73:	e8 48 0e 00 00       	call   c0107bc0 <swap_map_swappable>
            page->pra_vaddr=la;
c0106d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d7b:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106d7e:	89 50 20             	mov    %edx,0x20(%eax)
            assert(page_ref(page) == 1);
c0106d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d84:	89 04 24             	mov    %eax,(%esp)
c0106d87:	e8 9b f2 ff ff       	call   c0106027 <page_ref>
c0106d8c:	83 f8 01             	cmp    $0x1,%eax
c0106d8f:	74 24                	je     c0106db5 <pgdir_alloc_page+0xc6>
c0106d91:	c7 44 24 0c 28 c3 10 	movl   $0xc010c328,0xc(%esp)
c0106d98:	c0 
c0106d99:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0106da0:	c0 
c0106da1:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0106da8:	00 
c0106da9:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0106db0:	e8 ab b3 ff ff       	call   c0102160 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c0106db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106db8:	c9                   	leave  
c0106db9:	c3                   	ret    

c0106dba <check_alloc_page>:

static void
check_alloc_page(void) {
c0106dba:	55                   	push   %ebp
c0106dbb:	89 e5                	mov    %esp,%ebp
c0106dbd:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0106dc0:	a1 24 bb 12 c0       	mov    0xc012bb24,%eax
c0106dc5:	8b 40 18             	mov    0x18(%eax),%eax
c0106dc8:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0106dca:	c7 04 24 3c c3 10 c0 	movl   $0xc010c33c,(%esp)
c0106dd1:	e8 00 aa ff ff       	call   c01017d6 <cprintf>
}
c0106dd6:	c9                   	leave  
c0106dd7:	c3                   	ret    

c0106dd8 <check_pgdir>:

static void
check_pgdir(void) {
c0106dd8:	55                   	push   %ebp
c0106dd9:	89 e5                	mov    %esp,%ebp
c0106ddb:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0106dde:	a1 40 9a 12 c0       	mov    0xc0129a40,%eax
c0106de3:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0106de8:	76 24                	jbe    c0106e0e <check_pgdir+0x36>
c0106dea:	c7 44 24 0c 5b c3 10 	movl   $0xc010c35b,0xc(%esp)
c0106df1:	c0 
c0106df2:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0106df9:	c0 
c0106dfa:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c0106e01:	00 
c0106e02:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0106e09:	e8 52 b3 ff ff       	call   c0102160 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0106e0e:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0106e13:	85 c0                	test   %eax,%eax
c0106e15:	74 0e                	je     c0106e25 <check_pgdir+0x4d>
c0106e17:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0106e1c:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106e21:	85 c0                	test   %eax,%eax
c0106e23:	74 24                	je     c0106e49 <check_pgdir+0x71>
c0106e25:	c7 44 24 0c 78 c3 10 	movl   $0xc010c378,0xc(%esp)
c0106e2c:	c0 
c0106e2d:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0106e34:	c0 
c0106e35:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0106e3c:	00 
c0106e3d:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0106e44:	e8 17 b3 ff ff       	call   c0102160 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0106e49:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0106e4e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106e55:	00 
c0106e56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106e5d:	00 
c0106e5e:	89 04 24             	mov    %eax,(%esp)
c0106e61:	e8 75 fc ff ff       	call   c0106adb <get_page>
c0106e66:	85 c0                	test   %eax,%eax
c0106e68:	74 24                	je     c0106e8e <check_pgdir+0xb6>
c0106e6a:	c7 44 24 0c b0 c3 10 	movl   $0xc010c3b0,0xc(%esp)
c0106e71:	c0 
c0106e72:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0106e79:	c0 
c0106e7a:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0106e81:	00 
c0106e82:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0106e89:	e8 d2 b2 ff ff       	call   c0102160 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0106e8e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106e95:	e8 92 f3 ff ff       	call   c010622c <alloc_pages>
c0106e9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0106e9d:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0106ea2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106ea9:	00 
c0106eaa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106eb1:	00 
c0106eb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106eb5:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106eb9:	89 04 24             	mov    %eax,(%esp)
c0106ebc:	e8 18 fd ff ff       	call   c0106bd9 <page_insert>
c0106ec1:	85 c0                	test   %eax,%eax
c0106ec3:	74 24                	je     c0106ee9 <check_pgdir+0x111>
c0106ec5:	c7 44 24 0c d8 c3 10 	movl   $0xc010c3d8,0xc(%esp)
c0106ecc:	c0 
c0106ecd:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0106ed4:	c0 
c0106ed5:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
c0106edc:	00 
c0106edd:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0106ee4:	e8 77 b2 ff ff       	call   c0102160 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0106ee9:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0106eee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106ef5:	00 
c0106ef6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106efd:	00 
c0106efe:	89 04 24             	mov    %eax,(%esp)
c0106f01:	e8 9d fa ff ff       	call   c01069a3 <get_pte>
c0106f06:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106f09:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106f0d:	75 24                	jne    c0106f33 <check_pgdir+0x15b>
c0106f0f:	c7 44 24 0c 04 c4 10 	movl   $0xc010c404,0xc(%esp)
c0106f16:	c0 
c0106f17:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0106f1e:	c0 
c0106f1f:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c0106f26:	00 
c0106f27:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0106f2e:	e8 2d b2 ff ff       	call   c0102160 <__panic>
    assert(pa2page(*ptep) == p1);
c0106f33:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f36:	8b 00                	mov    (%eax),%eax
c0106f38:	89 04 24             	mov    %eax,(%esp)
c0106f3b:	e8 06 f0 ff ff       	call   c0105f46 <pa2page>
c0106f40:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106f43:	74 24                	je     c0106f69 <check_pgdir+0x191>
c0106f45:	c7 44 24 0c 31 c4 10 	movl   $0xc010c431,0xc(%esp)
c0106f4c:	c0 
c0106f4d:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0106f54:	c0 
c0106f55:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
c0106f5c:	00 
c0106f5d:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0106f64:	e8 f7 b1 ff ff       	call   c0102160 <__panic>
    assert(page_ref(p1) == 1);
c0106f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f6c:	89 04 24             	mov    %eax,(%esp)
c0106f6f:	e8 b3 f0 ff ff       	call   c0106027 <page_ref>
c0106f74:	83 f8 01             	cmp    $0x1,%eax
c0106f77:	74 24                	je     c0106f9d <check_pgdir+0x1c5>
c0106f79:	c7 44 24 0c 46 c4 10 	movl   $0xc010c446,0xc(%esp)
c0106f80:	c0 
c0106f81:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0106f88:	c0 
c0106f89:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c0106f90:	00 
c0106f91:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0106f98:	e8 c3 b1 ff ff       	call   c0102160 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0106f9d:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0106fa2:	8b 00                	mov    (%eax),%eax
c0106fa4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106fa9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106fac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106faf:	c1 e8 0c             	shr    $0xc,%eax
c0106fb2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106fb5:	a1 40 9a 12 c0       	mov    0xc0129a40,%eax
c0106fba:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0106fbd:	72 23                	jb     c0106fe2 <check_pgdir+0x20a>
c0106fbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106fc2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106fc6:	c7 44 24 08 00 c2 10 	movl   $0xc010c200,0x8(%esp)
c0106fcd:	c0 
c0106fce:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c0106fd5:	00 
c0106fd6:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0106fdd:	e8 7e b1 ff ff       	call   c0102160 <__panic>
c0106fe2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106fe5:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106fea:	83 c0 04             	add    $0x4,%eax
c0106fed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0106ff0:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0106ff5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106ffc:	00 
c0106ffd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107004:	00 
c0107005:	89 04 24             	mov    %eax,(%esp)
c0107008:	e8 96 f9 ff ff       	call   c01069a3 <get_pte>
c010700d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107010:	74 24                	je     c0107036 <check_pgdir+0x25e>
c0107012:	c7 44 24 0c 58 c4 10 	movl   $0xc010c458,0xc(%esp)
c0107019:	c0 
c010701a:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0107021:	c0 
c0107022:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
c0107029:	00 
c010702a:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0107031:	e8 2a b1 ff ff       	call   c0102160 <__panic>

    p2 = alloc_page();
c0107036:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010703d:	e8 ea f1 ff ff       	call   c010622c <alloc_pages>
c0107042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0107045:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c010704a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0107051:	00 
c0107052:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0107059:	00 
c010705a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010705d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107061:	89 04 24             	mov    %eax,(%esp)
c0107064:	e8 70 fb ff ff       	call   c0106bd9 <page_insert>
c0107069:	85 c0                	test   %eax,%eax
c010706b:	74 24                	je     c0107091 <check_pgdir+0x2b9>
c010706d:	c7 44 24 0c 80 c4 10 	movl   $0xc010c480,0xc(%esp)
c0107074:	c0 
c0107075:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c010707c:	c0 
c010707d:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
c0107084:	00 
c0107085:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c010708c:	e8 cf b0 ff ff       	call   c0102160 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0107091:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0107096:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010709d:	00 
c010709e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01070a5:	00 
c01070a6:	89 04 24             	mov    %eax,(%esp)
c01070a9:	e8 f5 f8 ff ff       	call   c01069a3 <get_pte>
c01070ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01070b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01070b5:	75 24                	jne    c01070db <check_pgdir+0x303>
c01070b7:	c7 44 24 0c b8 c4 10 	movl   $0xc010c4b8,0xc(%esp)
c01070be:	c0 
c01070bf:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c01070c6:	c0 
c01070c7:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
c01070ce:	00 
c01070cf:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c01070d6:	e8 85 b0 ff ff       	call   c0102160 <__panic>
    assert(*ptep & PTE_U);
c01070db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01070de:	8b 00                	mov    (%eax),%eax
c01070e0:	83 e0 04             	and    $0x4,%eax
c01070e3:	85 c0                	test   %eax,%eax
c01070e5:	75 24                	jne    c010710b <check_pgdir+0x333>
c01070e7:	c7 44 24 0c e8 c4 10 	movl   $0xc010c4e8,0xc(%esp)
c01070ee:	c0 
c01070ef:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c01070f6:	c0 
c01070f7:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
c01070fe:	00 
c01070ff:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0107106:	e8 55 b0 ff ff       	call   c0102160 <__panic>
    assert(*ptep & PTE_W);
c010710b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010710e:	8b 00                	mov    (%eax),%eax
c0107110:	83 e0 02             	and    $0x2,%eax
c0107113:	85 c0                	test   %eax,%eax
c0107115:	75 24                	jne    c010713b <check_pgdir+0x363>
c0107117:	c7 44 24 0c f6 c4 10 	movl   $0xc010c4f6,0xc(%esp)
c010711e:	c0 
c010711f:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0107126:	c0 
c0107127:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
c010712e:	00 
c010712f:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0107136:	e8 25 b0 ff ff       	call   c0102160 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c010713b:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0107140:	8b 00                	mov    (%eax),%eax
c0107142:	83 e0 04             	and    $0x4,%eax
c0107145:	85 c0                	test   %eax,%eax
c0107147:	75 24                	jne    c010716d <check_pgdir+0x395>
c0107149:	c7 44 24 0c 04 c5 10 	movl   $0xc010c504,0xc(%esp)
c0107150:	c0 
c0107151:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0107158:	c0 
c0107159:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
c0107160:	00 
c0107161:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0107168:	e8 f3 af ff ff       	call   c0102160 <__panic>
    assert(page_ref(p2) == 1);
c010716d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107170:	89 04 24             	mov    %eax,(%esp)
c0107173:	e8 af ee ff ff       	call   c0106027 <page_ref>
c0107178:	83 f8 01             	cmp    $0x1,%eax
c010717b:	74 24                	je     c01071a1 <check_pgdir+0x3c9>
c010717d:	c7 44 24 0c 1a c5 10 	movl   $0xc010c51a,0xc(%esp)
c0107184:	c0 
c0107185:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c010718c:	c0 
c010718d:	c7 44 24 04 36 02 00 	movl   $0x236,0x4(%esp)
c0107194:	00 
c0107195:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c010719c:	e8 bf af ff ff       	call   c0102160 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01071a1:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c01071a6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01071ad:	00 
c01071ae:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01071b5:	00 
c01071b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01071b9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01071bd:	89 04 24             	mov    %eax,(%esp)
c01071c0:	e8 14 fa ff ff       	call   c0106bd9 <page_insert>
c01071c5:	85 c0                	test   %eax,%eax
c01071c7:	74 24                	je     c01071ed <check_pgdir+0x415>
c01071c9:	c7 44 24 0c 2c c5 10 	movl   $0xc010c52c,0xc(%esp)
c01071d0:	c0 
c01071d1:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c01071d8:	c0 
c01071d9:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
c01071e0:	00 
c01071e1:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c01071e8:	e8 73 af ff ff       	call   c0102160 <__panic>
    assert(page_ref(p1) == 2);
c01071ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01071f0:	89 04 24             	mov    %eax,(%esp)
c01071f3:	e8 2f ee ff ff       	call   c0106027 <page_ref>
c01071f8:	83 f8 02             	cmp    $0x2,%eax
c01071fb:	74 24                	je     c0107221 <check_pgdir+0x449>
c01071fd:	c7 44 24 0c 58 c5 10 	movl   $0xc010c558,0xc(%esp)
c0107204:	c0 
c0107205:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c010720c:	c0 
c010720d:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
c0107214:	00 
c0107215:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c010721c:	e8 3f af ff ff       	call   c0102160 <__panic>
    assert(page_ref(p2) == 0);
c0107221:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107224:	89 04 24             	mov    %eax,(%esp)
c0107227:	e8 fb ed ff ff       	call   c0106027 <page_ref>
c010722c:	85 c0                	test   %eax,%eax
c010722e:	74 24                	je     c0107254 <check_pgdir+0x47c>
c0107230:	c7 44 24 0c 6a c5 10 	movl   $0xc010c56a,0xc(%esp)
c0107237:	c0 
c0107238:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c010723f:	c0 
c0107240:	c7 44 24 04 3a 02 00 	movl   $0x23a,0x4(%esp)
c0107247:	00 
c0107248:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c010724f:	e8 0c af ff ff       	call   c0102160 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0107254:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0107259:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107260:	00 
c0107261:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107268:	00 
c0107269:	89 04 24             	mov    %eax,(%esp)
c010726c:	e8 32 f7 ff ff       	call   c01069a3 <get_pte>
c0107271:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107274:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107278:	75 24                	jne    c010729e <check_pgdir+0x4c6>
c010727a:	c7 44 24 0c b8 c4 10 	movl   $0xc010c4b8,0xc(%esp)
c0107281:	c0 
c0107282:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0107289:	c0 
c010728a:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
c0107291:	00 
c0107292:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0107299:	e8 c2 ae ff ff       	call   c0102160 <__panic>
    assert(pa2page(*ptep) == p1);
c010729e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01072a1:	8b 00                	mov    (%eax),%eax
c01072a3:	89 04 24             	mov    %eax,(%esp)
c01072a6:	e8 9b ec ff ff       	call   c0105f46 <pa2page>
c01072ab:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01072ae:	74 24                	je     c01072d4 <check_pgdir+0x4fc>
c01072b0:	c7 44 24 0c 31 c4 10 	movl   $0xc010c431,0xc(%esp)
c01072b7:	c0 
c01072b8:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c01072bf:	c0 
c01072c0:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
c01072c7:	00 
c01072c8:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c01072cf:	e8 8c ae ff ff       	call   c0102160 <__panic>
    assert((*ptep & PTE_U) == 0);
c01072d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01072d7:	8b 00                	mov    (%eax),%eax
c01072d9:	83 e0 04             	and    $0x4,%eax
c01072dc:	85 c0                	test   %eax,%eax
c01072de:	74 24                	je     c0107304 <check_pgdir+0x52c>
c01072e0:	c7 44 24 0c 7c c5 10 	movl   $0xc010c57c,0xc(%esp)
c01072e7:	c0 
c01072e8:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c01072ef:	c0 
c01072f0:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
c01072f7:	00 
c01072f8:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c01072ff:	e8 5c ae ff ff       	call   c0102160 <__panic>

    page_remove(boot_pgdir, 0x0);
c0107304:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0107309:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107310:	00 
c0107311:	89 04 24             	mov    %eax,(%esp)
c0107314:	e8 7c f8 ff ff       	call   c0106b95 <page_remove>
    assert(page_ref(p1) == 1);
c0107319:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010731c:	89 04 24             	mov    %eax,(%esp)
c010731f:	e8 03 ed ff ff       	call   c0106027 <page_ref>
c0107324:	83 f8 01             	cmp    $0x1,%eax
c0107327:	74 24                	je     c010734d <check_pgdir+0x575>
c0107329:	c7 44 24 0c 46 c4 10 	movl   $0xc010c446,0xc(%esp)
c0107330:	c0 
c0107331:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0107338:	c0 
c0107339:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
c0107340:	00 
c0107341:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0107348:	e8 13 ae ff ff       	call   c0102160 <__panic>
    assert(page_ref(p2) == 0);
c010734d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107350:	89 04 24             	mov    %eax,(%esp)
c0107353:	e8 cf ec ff ff       	call   c0106027 <page_ref>
c0107358:	85 c0                	test   %eax,%eax
c010735a:	74 24                	je     c0107380 <check_pgdir+0x5a8>
c010735c:	c7 44 24 0c 6a c5 10 	movl   $0xc010c56a,0xc(%esp)
c0107363:	c0 
c0107364:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c010736b:	c0 
c010736c:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c0107373:	00 
c0107374:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c010737b:	e8 e0 ad ff ff       	call   c0102160 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0107380:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0107385:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010738c:	00 
c010738d:	89 04 24             	mov    %eax,(%esp)
c0107390:	e8 00 f8 ff ff       	call   c0106b95 <page_remove>
    assert(page_ref(p1) == 0);
c0107395:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107398:	89 04 24             	mov    %eax,(%esp)
c010739b:	e8 87 ec ff ff       	call   c0106027 <page_ref>
c01073a0:	85 c0                	test   %eax,%eax
c01073a2:	74 24                	je     c01073c8 <check_pgdir+0x5f0>
c01073a4:	c7 44 24 0c 91 c5 10 	movl   $0xc010c591,0xc(%esp)
c01073ab:	c0 
c01073ac:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c01073b3:	c0 
c01073b4:	c7 44 24 04 44 02 00 	movl   $0x244,0x4(%esp)
c01073bb:	00 
c01073bc:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c01073c3:	e8 98 ad ff ff       	call   c0102160 <__panic>
    assert(page_ref(p2) == 0);
c01073c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01073cb:	89 04 24             	mov    %eax,(%esp)
c01073ce:	e8 54 ec ff ff       	call   c0106027 <page_ref>
c01073d3:	85 c0                	test   %eax,%eax
c01073d5:	74 24                	je     c01073fb <check_pgdir+0x623>
c01073d7:	c7 44 24 0c 6a c5 10 	movl   $0xc010c56a,0xc(%esp)
c01073de:	c0 
c01073df:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c01073e6:	c0 
c01073e7:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
c01073ee:	00 
c01073ef:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c01073f6:	e8 65 ad ff ff       	call   c0102160 <__panic>

    assert(page_ref(pa2page(boot_pgdir[0])) == 1);
c01073fb:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0107400:	8b 00                	mov    (%eax),%eax
c0107402:	89 04 24             	mov    %eax,(%esp)
c0107405:	e8 3c eb ff ff       	call   c0105f46 <pa2page>
c010740a:	89 04 24             	mov    %eax,(%esp)
c010740d:	e8 15 ec ff ff       	call   c0106027 <page_ref>
c0107412:	83 f8 01             	cmp    $0x1,%eax
c0107415:	74 24                	je     c010743b <check_pgdir+0x663>
c0107417:	c7 44 24 0c a4 c5 10 	movl   $0xc010c5a4,0xc(%esp)
c010741e:	c0 
c010741f:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0107426:	c0 
c0107427:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
c010742e:	00 
c010742f:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0107436:	e8 25 ad ff ff       	call   c0102160 <__panic>
    free_page(pa2page(boot_pgdir[0]));
c010743b:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0107440:	8b 00                	mov    (%eax),%eax
c0107442:	89 04 24             	mov    %eax,(%esp)
c0107445:	e8 fc ea ff ff       	call   c0105f46 <pa2page>
c010744a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107451:	00 
c0107452:	89 04 24             	mov    %eax,(%esp)
c0107455:	e8 3d ee ff ff       	call   c0106297 <free_pages>
    boot_pgdir[0] = 0;
c010745a:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c010745f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0107465:	c7 04 24 ca c5 10 c0 	movl   $0xc010c5ca,(%esp)
c010746c:	e8 65 a3 ff ff       	call   c01017d6 <cprintf>
}
c0107471:	c9                   	leave  
c0107472:	c3                   	ret    

c0107473 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0107473:	55                   	push   %ebp
c0107474:	89 e5                	mov    %esp,%ebp
c0107476:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0107479:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107480:	e9 ca 00 00 00       	jmp    c010754f <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0107485:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107488:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010748b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010748e:	c1 e8 0c             	shr    $0xc,%eax
c0107491:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107494:	a1 40 9a 12 c0       	mov    0xc0129a40,%eax
c0107499:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010749c:	72 23                	jb     c01074c1 <check_boot_pgdir+0x4e>
c010749e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01074a5:	c7 44 24 08 00 c2 10 	movl   $0xc010c200,0x8(%esp)
c01074ac:	c0 
c01074ad:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
c01074b4:	00 
c01074b5:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c01074bc:	e8 9f ac ff ff       	call   c0102160 <__panic>
c01074c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074c4:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01074c9:	89 c2                	mov    %eax,%edx
c01074cb:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c01074d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01074d7:	00 
c01074d8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01074dc:	89 04 24             	mov    %eax,(%esp)
c01074df:	e8 bf f4 ff ff       	call   c01069a3 <get_pte>
c01074e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01074e7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01074eb:	75 24                	jne    c0107511 <check_boot_pgdir+0x9e>
c01074ed:	c7 44 24 0c e4 c5 10 	movl   $0xc010c5e4,0xc(%esp)
c01074f4:	c0 
c01074f5:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c01074fc:	c0 
c01074fd:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
c0107504:	00 
c0107505:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c010750c:	e8 4f ac ff ff       	call   c0102160 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0107511:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107514:	8b 00                	mov    (%eax),%eax
c0107516:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010751b:	89 c2                	mov    %eax,%edx
c010751d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107520:	39 c2                	cmp    %eax,%edx
c0107522:	74 24                	je     c0107548 <check_boot_pgdir+0xd5>
c0107524:	c7 44 24 0c 21 c6 10 	movl   $0xc010c621,0xc(%esp)
c010752b:	c0 
c010752c:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0107533:	c0 
c0107534:	c7 44 24 04 54 02 00 	movl   $0x254,0x4(%esp)
c010753b:	00 
c010753c:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0107543:	e8 18 ac ff ff       	call   c0102160 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0107548:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c010754f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107552:	a1 40 9a 12 c0       	mov    0xc0129a40,%eax
c0107557:	39 c2                	cmp    %eax,%edx
c0107559:	0f 82 26 ff ff ff    	jb     c0107485 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c010755f:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0107564:	05 ac 0f 00 00       	add    $0xfac,%eax
c0107569:	8b 00                	mov    (%eax),%eax
c010756b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107570:	89 c2                	mov    %eax,%edx
c0107572:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0107577:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010757a:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0107581:	77 23                	ja     c01075a6 <check_boot_pgdir+0x133>
c0107583:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107586:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010758a:	c7 44 24 08 a4 c2 10 	movl   $0xc010c2a4,0x8(%esp)
c0107591:	c0 
c0107592:	c7 44 24 04 57 02 00 	movl   $0x257,0x4(%esp)
c0107599:	00 
c010759a:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c01075a1:	e8 ba ab ff ff       	call   c0102160 <__panic>
c01075a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01075a9:	05 00 00 00 40       	add    $0x40000000,%eax
c01075ae:	39 c2                	cmp    %eax,%edx
c01075b0:	74 24                	je     c01075d6 <check_boot_pgdir+0x163>
c01075b2:	c7 44 24 0c 38 c6 10 	movl   $0xc010c638,0xc(%esp)
c01075b9:	c0 
c01075ba:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c01075c1:	c0 
c01075c2:	c7 44 24 04 57 02 00 	movl   $0x257,0x4(%esp)
c01075c9:	00 
c01075ca:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c01075d1:	e8 8a ab ff ff       	call   c0102160 <__panic>

    assert(boot_pgdir[0] == 0);
c01075d6:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c01075db:	8b 00                	mov    (%eax),%eax
c01075dd:	85 c0                	test   %eax,%eax
c01075df:	74 24                	je     c0107605 <check_boot_pgdir+0x192>
c01075e1:	c7 44 24 0c 6c c6 10 	movl   $0xc010c66c,0xc(%esp)
c01075e8:	c0 
c01075e9:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c01075f0:	c0 
c01075f1:	c7 44 24 04 59 02 00 	movl   $0x259,0x4(%esp)
c01075f8:	00 
c01075f9:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0107600:	e8 5b ab ff ff       	call   c0102160 <__panic>

    struct Page *p;
    p = alloc_page();
c0107605:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010760c:	e8 1b ec ff ff       	call   c010622c <alloc_pages>
c0107611:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0107614:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0107619:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0107620:	00 
c0107621:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0107628:	00 
c0107629:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010762c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107630:	89 04 24             	mov    %eax,(%esp)
c0107633:	e8 a1 f5 ff ff       	call   c0106bd9 <page_insert>
c0107638:	85 c0                	test   %eax,%eax
c010763a:	74 24                	je     c0107660 <check_boot_pgdir+0x1ed>
c010763c:	c7 44 24 0c 80 c6 10 	movl   $0xc010c680,0xc(%esp)
c0107643:	c0 
c0107644:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c010764b:	c0 
c010764c:	c7 44 24 04 5d 02 00 	movl   $0x25d,0x4(%esp)
c0107653:	00 
c0107654:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c010765b:	e8 00 ab ff ff       	call   c0102160 <__panic>
    assert(page_ref(p) == 1);
c0107660:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107663:	89 04 24             	mov    %eax,(%esp)
c0107666:	e8 bc e9 ff ff       	call   c0106027 <page_ref>
c010766b:	83 f8 01             	cmp    $0x1,%eax
c010766e:	74 24                	je     c0107694 <check_boot_pgdir+0x221>
c0107670:	c7 44 24 0c ae c6 10 	movl   $0xc010c6ae,0xc(%esp)
c0107677:	c0 
c0107678:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c010767f:	c0 
c0107680:	c7 44 24 04 5e 02 00 	movl   $0x25e,0x4(%esp)
c0107687:	00 
c0107688:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c010768f:	e8 cc aa ff ff       	call   c0102160 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0107694:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c0107699:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01076a0:	00 
c01076a1:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c01076a8:	00 
c01076a9:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01076ac:	89 54 24 04          	mov    %edx,0x4(%esp)
c01076b0:	89 04 24             	mov    %eax,(%esp)
c01076b3:	e8 21 f5 ff ff       	call   c0106bd9 <page_insert>
c01076b8:	85 c0                	test   %eax,%eax
c01076ba:	74 24                	je     c01076e0 <check_boot_pgdir+0x26d>
c01076bc:	c7 44 24 0c c0 c6 10 	movl   $0xc010c6c0,0xc(%esp)
c01076c3:	c0 
c01076c4:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c01076cb:	c0 
c01076cc:	c7 44 24 04 5f 02 00 	movl   $0x25f,0x4(%esp)
c01076d3:	00 
c01076d4:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c01076db:	e8 80 aa ff ff       	call   c0102160 <__panic>
    assert(page_ref(p) == 2);
c01076e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01076e3:	89 04 24             	mov    %eax,(%esp)
c01076e6:	e8 3c e9 ff ff       	call   c0106027 <page_ref>
c01076eb:	83 f8 02             	cmp    $0x2,%eax
c01076ee:	74 24                	je     c0107714 <check_boot_pgdir+0x2a1>
c01076f0:	c7 44 24 0c f7 c6 10 	movl   $0xc010c6f7,0xc(%esp)
c01076f7:	c0 
c01076f8:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c01076ff:	c0 
c0107700:	c7 44 24 04 60 02 00 	movl   $0x260,0x4(%esp)
c0107707:	00 
c0107708:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c010770f:	e8 4c aa ff ff       	call   c0102160 <__panic>

    const char *str = "ucore: Hello world!!";
c0107714:	c7 45 dc 08 c7 10 c0 	movl   $0xc010c708,-0x24(%ebp)
    strcpy((void *)0x100, str);
c010771b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010771e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107722:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0107729:	e8 b8 36 00 00       	call   c010ade6 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c010772e:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0107735:	00 
c0107736:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010773d:	e8 1d 37 00 00       	call   c010ae5f <strcmp>
c0107742:	85 c0                	test   %eax,%eax
c0107744:	74 24                	je     c010776a <check_boot_pgdir+0x2f7>
c0107746:	c7 44 24 0c 20 c7 10 	movl   $0xc010c720,0xc(%esp)
c010774d:	c0 
c010774e:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c0107755:	c0 
c0107756:	c7 44 24 04 64 02 00 	movl   $0x264,0x4(%esp)
c010775d:	00 
c010775e:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c0107765:	e8 f6 a9 ff ff       	call   c0102160 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c010776a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010776d:	89 04 24             	mov    %eax,(%esp)
c0107770:	e8 20 e8 ff ff       	call   c0105f95 <page2kva>
c0107775:	05 00 01 00 00       	add    $0x100,%eax
c010777a:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c010777d:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0107784:	e8 05 36 00 00       	call   c010ad8e <strlen>
c0107789:	85 c0                	test   %eax,%eax
c010778b:	74 24                	je     c01077b1 <check_boot_pgdir+0x33e>
c010778d:	c7 44 24 0c 58 c7 10 	movl   $0xc010c758,0xc(%esp)
c0107794:	c0 
c0107795:	c7 44 24 08 ed c2 10 	movl   $0xc010c2ed,0x8(%esp)
c010779c:	c0 
c010779d:	c7 44 24 04 67 02 00 	movl   $0x267,0x4(%esp)
c01077a4:	00 
c01077a5:	c7 04 24 c8 c2 10 c0 	movl   $0xc010c2c8,(%esp)
c01077ac:	e8 af a9 ff ff       	call   c0102160 <__panic>

    free_page(p);
c01077b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01077b8:	00 
c01077b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01077bc:	89 04 24             	mov    %eax,(%esp)
c01077bf:	e8 d3 ea ff ff       	call   c0106297 <free_pages>
    free_page(pa2page(PDE_ADDR(boot_pgdir[0])));
c01077c4:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c01077c9:	8b 00                	mov    (%eax),%eax
c01077cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01077d0:	89 04 24             	mov    %eax,(%esp)
c01077d3:	e8 6e e7 ff ff       	call   c0105f46 <pa2page>
c01077d8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01077df:	00 
c01077e0:	89 04 24             	mov    %eax,(%esp)
c01077e3:	e8 af ea ff ff       	call   c0106297 <free_pages>
    boot_pgdir[0] = 0;
c01077e8:	a1 44 9a 12 c0       	mov    0xc0129a44,%eax
c01077ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c01077f3:	c7 04 24 7c c7 10 c0 	movl   $0xc010c77c,(%esp)
c01077fa:	e8 d7 9f ff ff       	call   c01017d6 <cprintf>
}
c01077ff:	c9                   	leave  
c0107800:	c3                   	ret    

c0107801 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0107801:	55                   	push   %ebp
c0107802:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0107804:	8b 45 08             	mov    0x8(%ebp),%eax
c0107807:	83 e0 04             	and    $0x4,%eax
c010780a:	85 c0                	test   %eax,%eax
c010780c:	74 07                	je     c0107815 <perm2str+0x14>
c010780e:	b8 75 00 00 00       	mov    $0x75,%eax
c0107813:	eb 05                	jmp    c010781a <perm2str+0x19>
c0107815:	b8 2d 00 00 00       	mov    $0x2d,%eax
c010781a:	a2 c8 9a 12 c0       	mov    %al,0xc0129ac8
    str[1] = 'r';
c010781f:	c6 05 c9 9a 12 c0 72 	movb   $0x72,0xc0129ac9
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0107826:	8b 45 08             	mov    0x8(%ebp),%eax
c0107829:	83 e0 02             	and    $0x2,%eax
c010782c:	85 c0                	test   %eax,%eax
c010782e:	74 07                	je     c0107837 <perm2str+0x36>
c0107830:	b8 77 00 00 00       	mov    $0x77,%eax
c0107835:	eb 05                	jmp    c010783c <perm2str+0x3b>
c0107837:	b8 2d 00 00 00       	mov    $0x2d,%eax
c010783c:	a2 ca 9a 12 c0       	mov    %al,0xc0129aca
    str[3] = '\0';
c0107841:	c6 05 cb 9a 12 c0 00 	movb   $0x0,0xc0129acb
    return str;
c0107848:	b8 c8 9a 12 c0       	mov    $0xc0129ac8,%eax
}
c010784d:	5d                   	pop    %ebp
c010784e:	c3                   	ret    

c010784f <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c010784f:	55                   	push   %ebp
c0107850:	89 e5                	mov    %esp,%ebp
c0107852:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0107855:	8b 45 10             	mov    0x10(%ebp),%eax
c0107858:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010785b:	72 0a                	jb     c0107867 <get_pgtable_items+0x18>
        return 0;
c010785d:	b8 00 00 00 00       	mov    $0x0,%eax
c0107862:	e9 9c 00 00 00       	jmp    c0107903 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0107867:	eb 04                	jmp    c010786d <get_pgtable_items+0x1e>
        start ++;
c0107869:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c010786d:	8b 45 10             	mov    0x10(%ebp),%eax
c0107870:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107873:	73 18                	jae    c010788d <get_pgtable_items+0x3e>
c0107875:	8b 45 10             	mov    0x10(%ebp),%eax
c0107878:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010787f:	8b 45 14             	mov    0x14(%ebp),%eax
c0107882:	01 d0                	add    %edx,%eax
c0107884:	8b 00                	mov    (%eax),%eax
c0107886:	83 e0 01             	and    $0x1,%eax
c0107889:	85 c0                	test   %eax,%eax
c010788b:	74 dc                	je     c0107869 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c010788d:	8b 45 10             	mov    0x10(%ebp),%eax
c0107890:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107893:	73 69                	jae    c01078fe <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0107895:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0107899:	74 08                	je     c01078a3 <get_pgtable_items+0x54>
            *left_store = start;
c010789b:	8b 45 18             	mov    0x18(%ebp),%eax
c010789e:	8b 55 10             	mov    0x10(%ebp),%edx
c01078a1:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01078a3:	8b 45 10             	mov    0x10(%ebp),%eax
c01078a6:	8d 50 01             	lea    0x1(%eax),%edx
c01078a9:	89 55 10             	mov    %edx,0x10(%ebp)
c01078ac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01078b3:	8b 45 14             	mov    0x14(%ebp),%eax
c01078b6:	01 d0                	add    %edx,%eax
c01078b8:	8b 00                	mov    (%eax),%eax
c01078ba:	83 e0 07             	and    $0x7,%eax
c01078bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01078c0:	eb 04                	jmp    c01078c6 <get_pgtable_items+0x77>
            start ++;
c01078c2:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c01078c6:	8b 45 10             	mov    0x10(%ebp),%eax
c01078c9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01078cc:	73 1d                	jae    c01078eb <get_pgtable_items+0x9c>
c01078ce:	8b 45 10             	mov    0x10(%ebp),%eax
c01078d1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01078d8:	8b 45 14             	mov    0x14(%ebp),%eax
c01078db:	01 d0                	add    %edx,%eax
c01078dd:	8b 00                	mov    (%eax),%eax
c01078df:	83 e0 07             	and    $0x7,%eax
c01078e2:	89 c2                	mov    %eax,%edx
c01078e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01078e7:	39 c2                	cmp    %eax,%edx
c01078e9:	74 d7                	je     c01078c2 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c01078eb:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01078ef:	74 08                	je     c01078f9 <get_pgtable_items+0xaa>
            *right_store = start;
c01078f1:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01078f4:	8b 55 10             	mov    0x10(%ebp),%edx
c01078f7:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c01078f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01078fc:	eb 05                	jmp    c0107903 <get_pgtable_items+0xb4>
    }
    return 0;
c01078fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107903:	c9                   	leave  
c0107904:	c3                   	ret    

c0107905 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0107905:	55                   	push   %ebp
c0107906:	89 e5                	mov    %esp,%ebp
c0107908:	57                   	push   %edi
c0107909:	56                   	push   %esi
c010790a:	53                   	push   %ebx
c010790b:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c010790e:	c7 04 24 9c c7 10 c0 	movl   $0xc010c79c,(%esp)
c0107915:	e8 bc 9e ff ff       	call   c01017d6 <cprintf>
    size_t left, right = 0, perm;
c010791a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0107921:	e9 fa 00 00 00       	jmp    c0107a20 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0107926:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107929:	89 04 24             	mov    %eax,(%esp)
c010792c:	e8 d0 fe ff ff       	call   c0107801 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0107931:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0107934:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107937:	29 d1                	sub    %edx,%ecx
c0107939:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010793b:	89 d6                	mov    %edx,%esi
c010793d:	c1 e6 16             	shl    $0x16,%esi
c0107940:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107943:	89 d3                	mov    %edx,%ebx
c0107945:	c1 e3 16             	shl    $0x16,%ebx
c0107948:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010794b:	89 d1                	mov    %edx,%ecx
c010794d:	c1 e1 16             	shl    $0x16,%ecx
c0107950:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0107953:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107956:	29 d7                	sub    %edx,%edi
c0107958:	89 fa                	mov    %edi,%edx
c010795a:	89 44 24 14          	mov    %eax,0x14(%esp)
c010795e:	89 74 24 10          	mov    %esi,0x10(%esp)
c0107962:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0107966:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010796a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010796e:	c7 04 24 cd c7 10 c0 	movl   $0xc010c7cd,(%esp)
c0107975:	e8 5c 9e ff ff       	call   c01017d6 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c010797a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010797d:	c1 e0 0a             	shl    $0xa,%eax
c0107980:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0107983:	eb 54                	jmp    c01079d9 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0107985:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107988:	89 04 24             	mov    %eax,(%esp)
c010798b:	e8 71 fe ff ff       	call   c0107801 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0107990:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0107993:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107996:	29 d1                	sub    %edx,%ecx
c0107998:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010799a:	89 d6                	mov    %edx,%esi
c010799c:	c1 e6 0c             	shl    $0xc,%esi
c010799f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01079a2:	89 d3                	mov    %edx,%ebx
c01079a4:	c1 e3 0c             	shl    $0xc,%ebx
c01079a7:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01079aa:	c1 e2 0c             	shl    $0xc,%edx
c01079ad:	89 d1                	mov    %edx,%ecx
c01079af:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c01079b2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01079b5:	29 d7                	sub    %edx,%edi
c01079b7:	89 fa                	mov    %edi,%edx
c01079b9:	89 44 24 14          	mov    %eax,0x14(%esp)
c01079bd:	89 74 24 10          	mov    %esi,0x10(%esp)
c01079c1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01079c5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01079c9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01079cd:	c7 04 24 ec c7 10 c0 	movl   $0xc010c7ec,(%esp)
c01079d4:	e8 fd 9d ff ff       	call   c01017d6 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01079d9:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c01079de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01079e1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01079e4:	89 ce                	mov    %ecx,%esi
c01079e6:	c1 e6 0a             	shl    $0xa,%esi
c01079e9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01079ec:	89 cb                	mov    %ecx,%ebx
c01079ee:	c1 e3 0a             	shl    $0xa,%ebx
c01079f1:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c01079f4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c01079f8:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c01079fb:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01079ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107a03:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107a07:	89 74 24 04          	mov    %esi,0x4(%esp)
c0107a0b:	89 1c 24             	mov    %ebx,(%esp)
c0107a0e:	e8 3c fe ff ff       	call   c010784f <get_pgtable_items>
c0107a13:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107a16:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107a1a:	0f 85 65 ff ff ff    	jne    c0107985 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0107a20:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0107a25:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107a28:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c0107a2b:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0107a2f:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0107a32:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0107a36:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107a3a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107a3e:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0107a45:	00 
c0107a46:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0107a4d:	e8 fd fd ff ff       	call   c010784f <get_pgtable_items>
c0107a52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107a55:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107a59:	0f 85 c7 fe ff ff    	jne    c0107926 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0107a5f:	c7 04 24 10 c8 10 c0 	movl   $0xc010c810,(%esp)
c0107a66:	e8 6b 9d ff ff       	call   c01017d6 <cprintf>
}
c0107a6b:	83 c4 4c             	add    $0x4c,%esp
c0107a6e:	5b                   	pop    %ebx
c0107a6f:	5e                   	pop    %esi
c0107a70:	5f                   	pop    %edi
c0107a71:	5d                   	pop    %ebp
c0107a72:	c3                   	ret    

c0107a73 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0107a73:	55                   	push   %ebp
c0107a74:	89 e5                	mov    %esp,%ebp
c0107a76:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0107a79:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a7c:	c1 e8 0c             	shr    $0xc,%eax
c0107a7f:	89 c2                	mov    %eax,%edx
c0107a81:	a1 40 9a 12 c0       	mov    0xc0129a40,%eax
c0107a86:	39 c2                	cmp    %eax,%edx
c0107a88:	72 1c                	jb     c0107aa6 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0107a8a:	c7 44 24 08 44 c8 10 	movl   $0xc010c844,0x8(%esp)
c0107a91:	c0 
c0107a92:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0107a99:	00 
c0107a9a:	c7 04 24 63 c8 10 c0 	movl   $0xc010c863,(%esp)
c0107aa1:	e8 ba a6 ff ff       	call   c0102160 <__panic>
    }
    return &pages[PPN(pa)];
c0107aa6:	8b 0d 2c bb 12 c0    	mov    0xc012bb2c,%ecx
c0107aac:	8b 45 08             	mov    0x8(%ebp),%eax
c0107aaf:	c1 e8 0c             	shr    $0xc,%eax
c0107ab2:	89 c2                	mov    %eax,%edx
c0107ab4:	89 d0                	mov    %edx,%eax
c0107ab6:	c1 e0 03             	shl    $0x3,%eax
c0107ab9:	01 d0                	add    %edx,%eax
c0107abb:	c1 e0 02             	shl    $0x2,%eax
c0107abe:	01 c8                	add    %ecx,%eax
}
c0107ac0:	c9                   	leave  
c0107ac1:	c3                   	ret    

c0107ac2 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0107ac2:	55                   	push   %ebp
c0107ac3:	89 e5                	mov    %esp,%ebp
c0107ac5:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0107ac8:	8b 45 08             	mov    0x8(%ebp),%eax
c0107acb:	83 e0 01             	and    $0x1,%eax
c0107ace:	85 c0                	test   %eax,%eax
c0107ad0:	75 1c                	jne    c0107aee <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0107ad2:	c7 44 24 08 74 c8 10 	movl   $0xc010c874,0x8(%esp)
c0107ad9:	c0 
c0107ada:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0107ae1:	00 
c0107ae2:	c7 04 24 63 c8 10 c0 	movl   $0xc010c863,(%esp)
c0107ae9:	e8 72 a6 ff ff       	call   c0102160 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0107aee:	8b 45 08             	mov    0x8(%ebp),%eax
c0107af1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107af6:	89 04 24             	mov    %eax,(%esp)
c0107af9:	e8 75 ff ff ff       	call   c0107a73 <pa2page>
}
c0107afe:	c9                   	leave  
c0107aff:	c3                   	ret    

c0107b00 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0107b00:	55                   	push   %ebp
c0107b01:	89 e5                	mov    %esp,%ebp
c0107b03:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0107b06:	e8 b0 1d 00 00       	call   c01098bb <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0107b0b:	a1 dc bb 12 c0       	mov    0xc012bbdc,%eax
c0107b10:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0107b15:	76 0c                	jbe    c0107b23 <swap_init+0x23>
c0107b17:	a1 dc bb 12 c0       	mov    0xc012bbdc,%eax
c0107b1c:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0107b21:	76 25                	jbe    c0107b48 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0107b23:	a1 dc bb 12 c0       	mov    0xc012bbdc,%eax
c0107b28:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107b2c:	c7 44 24 08 95 c8 10 	movl   $0xc010c895,0x8(%esp)
c0107b33:	c0 
c0107b34:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
c0107b3b:	00 
c0107b3c:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0107b43:	e8 18 a6 ff ff       	call   c0102160 <__panic>
     }
     

     sm = &swap_manager_fifo;
c0107b48:	c7 05 d4 9a 12 c0 60 	movl   $0xc0128a60,0xc0129ad4
c0107b4f:	8a 12 c0 
     int r = sm->init();
c0107b52:	a1 d4 9a 12 c0       	mov    0xc0129ad4,%eax
c0107b57:	8b 40 04             	mov    0x4(%eax),%eax
c0107b5a:	ff d0                	call   *%eax
c0107b5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0107b5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107b63:	75 26                	jne    c0107b8b <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0107b65:	c7 05 cc 9a 12 c0 01 	movl   $0x1,0xc0129acc
c0107b6c:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0107b6f:	a1 d4 9a 12 c0       	mov    0xc0129ad4,%eax
c0107b74:	8b 00                	mov    (%eax),%eax
c0107b76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107b7a:	c7 04 24 bf c8 10 c0 	movl   $0xc010c8bf,(%esp)
c0107b81:	e8 50 9c ff ff       	call   c01017d6 <cprintf>
          check_swap();
c0107b86:	e8 a4 04 00 00       	call   c010802f <check_swap>
     }

     return r;
c0107b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107b8e:	c9                   	leave  
c0107b8f:	c3                   	ret    

c0107b90 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0107b90:	55                   	push   %ebp
c0107b91:	89 e5                	mov    %esp,%ebp
c0107b93:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0107b96:	a1 d4 9a 12 c0       	mov    0xc0129ad4,%eax
c0107b9b:	8b 40 08             	mov    0x8(%eax),%eax
c0107b9e:	8b 55 08             	mov    0x8(%ebp),%edx
c0107ba1:	89 14 24             	mov    %edx,(%esp)
c0107ba4:	ff d0                	call   *%eax
}
c0107ba6:	c9                   	leave  
c0107ba7:	c3                   	ret    

c0107ba8 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0107ba8:	55                   	push   %ebp
c0107ba9:	89 e5                	mov    %esp,%ebp
c0107bab:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0107bae:	a1 d4 9a 12 c0       	mov    0xc0129ad4,%eax
c0107bb3:	8b 40 0c             	mov    0xc(%eax),%eax
c0107bb6:	8b 55 08             	mov    0x8(%ebp),%edx
c0107bb9:	89 14 24             	mov    %edx,(%esp)
c0107bbc:	ff d0                	call   *%eax
}
c0107bbe:	c9                   	leave  
c0107bbf:	c3                   	ret    

c0107bc0 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0107bc0:	55                   	push   %ebp
c0107bc1:	89 e5                	mov    %esp,%ebp
c0107bc3:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0107bc6:	a1 d4 9a 12 c0       	mov    0xc0129ad4,%eax
c0107bcb:	8b 40 10             	mov    0x10(%eax),%eax
c0107bce:	8b 55 14             	mov    0x14(%ebp),%edx
c0107bd1:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107bd5:	8b 55 10             	mov    0x10(%ebp),%edx
c0107bd8:	89 54 24 08          	mov    %edx,0x8(%esp)
c0107bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107bdf:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107be3:	8b 55 08             	mov    0x8(%ebp),%edx
c0107be6:	89 14 24             	mov    %edx,(%esp)
c0107be9:	ff d0                	call   *%eax
}
c0107beb:	c9                   	leave  
c0107bec:	c3                   	ret    

c0107bed <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0107bed:	55                   	push   %ebp
c0107bee:	89 e5                	mov    %esp,%ebp
c0107bf0:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0107bf3:	a1 d4 9a 12 c0       	mov    0xc0129ad4,%eax
c0107bf8:	8b 40 14             	mov    0x14(%eax),%eax
c0107bfb:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107bfe:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107c02:	8b 55 08             	mov    0x8(%ebp),%edx
c0107c05:	89 14 24             	mov    %edx,(%esp)
c0107c08:	ff d0                	call   *%eax
}
c0107c0a:	c9                   	leave  
c0107c0b:	c3                   	ret    

c0107c0c <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0107c0c:	55                   	push   %ebp
c0107c0d:	89 e5                	mov    %esp,%ebp
c0107c0f:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0107c12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107c19:	e9 5a 01 00 00       	jmp    c0107d78 <swap_out+0x16c>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0107c1e:	a1 d4 9a 12 c0       	mov    0xc0129ad4,%eax
c0107c23:	8b 40 18             	mov    0x18(%eax),%eax
c0107c26:	8b 55 10             	mov    0x10(%ebp),%edx
c0107c29:	89 54 24 08          	mov    %edx,0x8(%esp)
c0107c2d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0107c30:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107c34:	8b 55 08             	mov    0x8(%ebp),%edx
c0107c37:	89 14 24             	mov    %edx,(%esp)
c0107c3a:	ff d0                	call   *%eax
c0107c3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0107c3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107c43:	74 18                	je     c0107c5d <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0107c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107c4c:	c7 04 24 d4 c8 10 c0 	movl   $0xc010c8d4,(%esp)
c0107c53:	e8 7e 9b ff ff       	call   c01017d6 <cprintf>
c0107c58:	e9 27 01 00 00       	jmp    c0107d84 <swap_out+0x178>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0107c5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107c60:	8b 40 20             	mov    0x20(%eax),%eax
c0107c63:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0107c66:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c69:	8b 40 0c             	mov    0xc(%eax),%eax
c0107c6c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107c73:	00 
c0107c74:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107c77:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107c7b:	89 04 24             	mov    %eax,(%esp)
c0107c7e:	e8 20 ed ff ff       	call   c01069a3 <get_pte>
c0107c83:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0107c86:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c89:	8b 00                	mov    (%eax),%eax
c0107c8b:	83 e0 01             	and    $0x1,%eax
c0107c8e:	85 c0                	test   %eax,%eax
c0107c90:	75 24                	jne    c0107cb6 <swap_out+0xaa>
c0107c92:	c7 44 24 0c 01 c9 10 	movl   $0xc010c901,0xc(%esp)
c0107c99:	c0 
c0107c9a:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0107ca1:	c0 
c0107ca2:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0107ca9:	00 
c0107caa:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0107cb1:	e8 aa a4 ff ff       	call   c0102160 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0107cb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107cb9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107cbc:	8b 52 20             	mov    0x20(%edx),%edx
c0107cbf:	c1 ea 0c             	shr    $0xc,%edx
c0107cc2:	83 c2 01             	add    $0x1,%edx
c0107cc5:	c1 e2 08             	shl    $0x8,%edx
c0107cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ccc:	89 14 24             	mov    %edx,(%esp)
c0107ccf:	e8 a1 1c 00 00       	call   c0109975 <swapfs_write>
c0107cd4:	85 c0                	test   %eax,%eax
c0107cd6:	74 34                	je     c0107d0c <swap_out+0x100>
                    cprintf("SWAP: failed to save\n");
c0107cd8:	c7 04 24 2b c9 10 c0 	movl   $0xc010c92b,(%esp)
c0107cdf:	e8 f2 9a ff ff       	call   c01017d6 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0107ce4:	a1 d4 9a 12 c0       	mov    0xc0129ad4,%eax
c0107ce9:	8b 40 10             	mov    0x10(%eax),%eax
c0107cec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107cef:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107cf6:	00 
c0107cf7:	89 54 24 08          	mov    %edx,0x8(%esp)
c0107cfb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107cfe:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107d02:	8b 55 08             	mov    0x8(%ebp),%edx
c0107d05:	89 14 24             	mov    %edx,(%esp)
c0107d08:	ff d0                	call   *%eax
c0107d0a:	eb 68                	jmp    c0107d74 <swap_out+0x168>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0107d0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107d0f:	8b 40 20             	mov    0x20(%eax),%eax
c0107d12:	c1 e8 0c             	shr    $0xc,%eax
c0107d15:	83 c0 01             	add    $0x1,%eax
c0107d18:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107d1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107d1f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d26:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107d2a:	c7 04 24 44 c9 10 c0 	movl   $0xc010c944,(%esp)
c0107d31:	e8 a0 9a ff ff       	call   c01017d6 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0107d36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107d39:	8b 40 20             	mov    0x20(%eax),%eax
c0107d3c:	c1 e8 0c             	shr    $0xc,%eax
c0107d3f:	83 c0 01             	add    $0x1,%eax
c0107d42:	c1 e0 08             	shl    $0x8,%eax
c0107d45:	89 c2                	mov    %eax,%edx
c0107d47:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d4a:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0107d4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107d4f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107d56:	00 
c0107d57:	89 04 24             	mov    %eax,(%esp)
c0107d5a:	e8 38 e5 ff ff       	call   c0106297 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0107d5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d62:	8b 40 0c             	mov    0xc(%eax),%eax
c0107d65:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107d68:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107d6c:	89 04 24             	mov    %eax,(%esp)
c0107d6f:	e8 1e ef ff ff       	call   c0106c92 <tlb_invalidate>

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c0107d74:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d7b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107d7e:	0f 85 9a fe ff ff    	jne    c0107c1e <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c0107d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107d87:	c9                   	leave  
c0107d88:	c3                   	ret    

c0107d89 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0107d89:	55                   	push   %ebp
c0107d8a:	89 e5                	mov    %esp,%ebp
c0107d8c:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0107d8f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107d96:	e8 91 e4 ff ff       	call   c010622c <alloc_pages>
c0107d9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0107d9e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107da2:	75 24                	jne    c0107dc8 <swap_in+0x3f>
c0107da4:	c7 44 24 0c 84 c9 10 	movl   $0xc010c984,0xc(%esp)
c0107dab:	c0 
c0107dac:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0107db3:	c0 
c0107db4:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c0107dbb:	00 
c0107dbc:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0107dc3:	e8 98 a3 ff ff       	call   c0102160 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0107dc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0107dcb:	8b 40 0c             	mov    0xc(%eax),%eax
c0107dce:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107dd5:	00 
c0107dd6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107dd9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107ddd:	89 04 24             	mov    %eax,(%esp)
c0107de0:	e8 be eb ff ff       	call   c01069a3 <get_pte>
c0107de5:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0107de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107deb:	8b 00                	mov    (%eax),%eax
c0107ded:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107df0:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107df4:	89 04 24             	mov    %eax,(%esp)
c0107df7:	e8 07 1b 00 00       	call   c0109903 <swapfs_read>
c0107dfc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107dff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107e03:	74 2a                	je     c0107e2f <swap_in+0xa6>
     {
        assert(r!=0);
c0107e05:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107e09:	75 24                	jne    c0107e2f <swap_in+0xa6>
c0107e0b:	c7 44 24 0c 91 c9 10 	movl   $0xc010c991,0xc(%esp)
c0107e12:	c0 
c0107e13:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0107e1a:	c0 
c0107e1b:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c0107e22:	00 
c0107e23:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0107e2a:	e8 31 a3 ff ff       	call   c0102160 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0107e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107e32:	8b 00                	mov    (%eax),%eax
c0107e34:	c1 e8 08             	shr    $0x8,%eax
c0107e37:	89 c2                	mov    %eax,%edx
c0107e39:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e3c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107e40:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107e44:	c7 04 24 98 c9 10 c0 	movl   $0xc010c998,(%esp)
c0107e4b:	e8 86 99 ff ff       	call   c01017d6 <cprintf>
     *ptr_result=result;
c0107e50:	8b 45 10             	mov    0x10(%ebp),%eax
c0107e53:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107e56:	89 10                	mov    %edx,(%eax)
     return 0;
c0107e58:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107e5d:	c9                   	leave  
c0107e5e:	c3                   	ret    

c0107e5f <check_content_set>:



static inline void
check_content_set(void)
{
c0107e5f:	55                   	push   %ebp
c0107e60:	89 e5                	mov    %esp,%ebp
c0107e62:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0107e65:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107e6a:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0107e6d:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c0107e72:	83 f8 01             	cmp    $0x1,%eax
c0107e75:	74 24                	je     c0107e9b <check_content_set+0x3c>
c0107e77:	c7 44 24 0c d6 c9 10 	movl   $0xc010c9d6,0xc(%esp)
c0107e7e:	c0 
c0107e7f:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0107e86:	c0 
c0107e87:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c0107e8e:	00 
c0107e8f:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0107e96:	e8 c5 a2 ff ff       	call   c0102160 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0107e9b:	b8 10 10 00 00       	mov    $0x1010,%eax
c0107ea0:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0107ea3:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c0107ea8:	83 f8 01             	cmp    $0x1,%eax
c0107eab:	74 24                	je     c0107ed1 <check_content_set+0x72>
c0107ead:	c7 44 24 0c d6 c9 10 	movl   $0xc010c9d6,0xc(%esp)
c0107eb4:	c0 
c0107eb5:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0107ebc:	c0 
c0107ebd:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0107ec4:	00 
c0107ec5:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0107ecc:	e8 8f a2 ff ff       	call   c0102160 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0107ed1:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107ed6:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0107ed9:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c0107ede:	83 f8 02             	cmp    $0x2,%eax
c0107ee1:	74 24                	je     c0107f07 <check_content_set+0xa8>
c0107ee3:	c7 44 24 0c e5 c9 10 	movl   $0xc010c9e5,0xc(%esp)
c0107eea:	c0 
c0107eeb:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0107ef2:	c0 
c0107ef3:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0107efa:	00 
c0107efb:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0107f02:	e8 59 a2 ff ff       	call   c0102160 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0107f07:	b8 10 20 00 00       	mov    $0x2010,%eax
c0107f0c:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0107f0f:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c0107f14:	83 f8 02             	cmp    $0x2,%eax
c0107f17:	74 24                	je     c0107f3d <check_content_set+0xde>
c0107f19:	c7 44 24 0c e5 c9 10 	movl   $0xc010c9e5,0xc(%esp)
c0107f20:	c0 
c0107f21:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0107f28:	c0 
c0107f29:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0107f30:	00 
c0107f31:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0107f38:	e8 23 a2 ff ff       	call   c0102160 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0107f3d:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107f42:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0107f45:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c0107f4a:	83 f8 03             	cmp    $0x3,%eax
c0107f4d:	74 24                	je     c0107f73 <check_content_set+0x114>
c0107f4f:	c7 44 24 0c f4 c9 10 	movl   $0xc010c9f4,0xc(%esp)
c0107f56:	c0 
c0107f57:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0107f5e:	c0 
c0107f5f:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0107f66:	00 
c0107f67:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0107f6e:	e8 ed a1 ff ff       	call   c0102160 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0107f73:	b8 10 30 00 00       	mov    $0x3010,%eax
c0107f78:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0107f7b:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c0107f80:	83 f8 03             	cmp    $0x3,%eax
c0107f83:	74 24                	je     c0107fa9 <check_content_set+0x14a>
c0107f85:	c7 44 24 0c f4 c9 10 	movl   $0xc010c9f4,0xc(%esp)
c0107f8c:	c0 
c0107f8d:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0107f94:	c0 
c0107f95:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0107f9c:	00 
c0107f9d:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0107fa4:	e8 b7 a1 ff ff       	call   c0102160 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0107fa9:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107fae:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0107fb1:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c0107fb6:	83 f8 04             	cmp    $0x4,%eax
c0107fb9:	74 24                	je     c0107fdf <check_content_set+0x180>
c0107fbb:	c7 44 24 0c 03 ca 10 	movl   $0xc010ca03,0xc(%esp)
c0107fc2:	c0 
c0107fc3:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0107fca:	c0 
c0107fcb:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0107fd2:	00 
c0107fd3:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0107fda:	e8 81 a1 ff ff       	call   c0102160 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0107fdf:	b8 10 40 00 00       	mov    $0x4010,%eax
c0107fe4:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0107fe7:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c0107fec:	83 f8 04             	cmp    $0x4,%eax
c0107fef:	74 24                	je     c0108015 <check_content_set+0x1b6>
c0107ff1:	c7 44 24 0c 03 ca 10 	movl   $0xc010ca03,0xc(%esp)
c0107ff8:	c0 
c0107ff9:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0108000:	c0 
c0108001:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0108008:	00 
c0108009:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0108010:	e8 4b a1 ff ff       	call   c0102160 <__panic>
}
c0108015:	c9                   	leave  
c0108016:	c3                   	ret    

c0108017 <check_content_access>:

static inline int
check_content_access(void)
{
c0108017:	55                   	push   %ebp
c0108018:	89 e5                	mov    %esp,%ebp
c010801a:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c010801d:	a1 d4 9a 12 c0       	mov    0xc0129ad4,%eax
c0108022:	8b 40 1c             	mov    0x1c(%eax),%eax
c0108025:	ff d0                	call   *%eax
c0108027:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c010802a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010802d:	c9                   	leave  
c010802e:	c3                   	ret    

c010802f <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c010802f:	55                   	push   %ebp
c0108030:	89 e5                	mov    %esp,%ebp
c0108032:	53                   	push   %ebx
c0108033:	83 ec 74             	sub    $0x74,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0108036:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010803d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0108044:	c7 45 e8 18 bb 12 c0 	movl   $0xc012bb18,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c010804b:	eb 6b                	jmp    c01080b8 <check_swap+0x89>
        struct Page *p = le2page(le, page_link);
c010804d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108050:	83 e8 10             	sub    $0x10,%eax
c0108053:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c0108056:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108059:	83 c0 04             	add    $0x4,%eax
c010805c:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0108063:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0108066:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0108069:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010806c:	0f a3 10             	bt     %edx,(%eax)
c010806f:	19 c0                	sbb    %eax,%eax
c0108071:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0108074:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0108078:	0f 95 c0             	setne  %al
c010807b:	0f b6 c0             	movzbl %al,%eax
c010807e:	85 c0                	test   %eax,%eax
c0108080:	75 24                	jne    c01080a6 <check_swap+0x77>
c0108082:	c7 44 24 0c 12 ca 10 	movl   $0xc010ca12,0xc(%esp)
c0108089:	c0 
c010808a:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0108091:	c0 
c0108092:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0108099:	00 
c010809a:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c01080a1:	e8 ba a0 ff ff       	call   c0102160 <__panic>
        count ++, total += p->property;
c01080a6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01080aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01080ad:	8b 50 08             	mov    0x8(%eax),%edx
c01080b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01080b3:	01 d0                	add    %edx,%eax
c01080b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01080b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01080bb:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01080be:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01080c1:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c01080c4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01080c7:	81 7d e8 18 bb 12 c0 	cmpl   $0xc012bb18,-0x18(%ebp)
c01080ce:	0f 85 79 ff ff ff    	jne    c010804d <check_swap+0x1e>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c01080d4:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c01080d7:	e8 ed e1 ff ff       	call   c01062c9 <nr_free_pages>
c01080dc:	39 c3                	cmp    %eax,%ebx
c01080de:	74 24                	je     c0108104 <check_swap+0xd5>
c01080e0:	c7 44 24 0c 22 ca 10 	movl   $0xc010ca22,0xc(%esp)
c01080e7:	c0 
c01080e8:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c01080ef:	c0 
c01080f0:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c01080f7:	00 
c01080f8:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c01080ff:	e8 5c a0 ff ff       	call   c0102160 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0108104:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108107:	89 44 24 08          	mov    %eax,0x8(%esp)
c010810b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010810e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108112:	c7 04 24 3c ca 10 c0 	movl   $0xc010ca3c,(%esp)
c0108119:	e8 b8 96 ff ff       	call   c01017d6 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c010811e:	e8 51 0a 00 00       	call   c0108b74 <mm_create>
c0108123:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(mm != NULL);
c0108126:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010812a:	75 24                	jne    c0108150 <check_swap+0x121>
c010812c:	c7 44 24 0c 62 ca 10 	movl   $0xc010ca62,0xc(%esp)
c0108133:	c0 
c0108134:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c010813b:	c0 
c010813c:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c0108143:	00 
c0108144:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c010814b:	e8 10 a0 ff ff       	call   c0102160 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0108150:	a1 0c bc 12 c0       	mov    0xc012bc0c,%eax
c0108155:	85 c0                	test   %eax,%eax
c0108157:	74 24                	je     c010817d <check_swap+0x14e>
c0108159:	c7 44 24 0c 6d ca 10 	movl   $0xc010ca6d,0xc(%esp)
c0108160:	c0 
c0108161:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0108168:	c0 
c0108169:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c0108170:	00 
c0108171:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0108178:	e8 e3 9f ff ff       	call   c0102160 <__panic>

     check_mm_struct = mm;
c010817d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108180:	a3 0c bc 12 c0       	mov    %eax,0xc012bc0c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0108185:	8b 15 44 9a 12 c0    	mov    0xc0129a44,%edx
c010818b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010818e:	89 50 0c             	mov    %edx,0xc(%eax)
c0108191:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108194:	8b 40 0c             	mov    0xc(%eax),%eax
c0108197:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(pgdir[0] == 0);
c010819a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010819d:	8b 00                	mov    (%eax),%eax
c010819f:	85 c0                	test   %eax,%eax
c01081a1:	74 24                	je     c01081c7 <check_swap+0x198>
c01081a3:	c7 44 24 0c 85 ca 10 	movl   $0xc010ca85,0xc(%esp)
c01081aa:	c0 
c01081ab:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c01081b2:	c0 
c01081b3:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c01081ba:	00 
c01081bb:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c01081c2:	e8 99 9f ff ff       	call   c0102160 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c01081c7:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c01081ce:	00 
c01081cf:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c01081d6:	00 
c01081d7:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c01081de:	e8 09 0a 00 00       	call   c0108bec <vma_create>
c01081e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(vma != NULL);
c01081e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01081ea:	75 24                	jne    c0108210 <check_swap+0x1e1>
c01081ec:	c7 44 24 0c 93 ca 10 	movl   $0xc010ca93,0xc(%esp)
c01081f3:	c0 
c01081f4:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c01081fb:	c0 
c01081fc:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0108203:	00 
c0108204:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c010820b:	e8 50 9f ff ff       	call   c0102160 <__panic>

     insert_vma_struct(mm, vma);
c0108210:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108213:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108217:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010821a:	89 04 24             	mov    %eax,(%esp)
c010821d:	e8 5a 0b 00 00       	call   c0108d7c <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0108222:	c7 04 24 a0 ca 10 c0 	movl   $0xc010caa0,(%esp)
c0108229:	e8 a8 95 ff ff       	call   c01017d6 <cprintf>
     pte_t *temp_ptep=NULL;
c010822e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0108235:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108238:	8b 40 0c             	mov    0xc(%eax),%eax
c010823b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0108242:	00 
c0108243:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010824a:	00 
c010824b:	89 04 24             	mov    %eax,(%esp)
c010824e:	e8 50 e7 ff ff       	call   c01069a3 <get_pte>
c0108253:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(temp_ptep!= NULL);
c0108256:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c010825a:	75 24                	jne    c0108280 <check_swap+0x251>
c010825c:	c7 44 24 0c d4 ca 10 	movl   $0xc010cad4,0xc(%esp)
c0108263:	c0 
c0108264:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c010826b:	c0 
c010826c:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0108273:	00 
c0108274:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c010827b:	e8 e0 9e ff ff       	call   c0102160 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0108280:	c7 04 24 e8 ca 10 c0 	movl   $0xc010cae8,(%esp)
c0108287:	e8 4a 95 ff ff       	call   c01017d6 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010828c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0108293:	e9 a3 00 00 00       	jmp    c010833b <check_swap+0x30c>
          check_rp[i] = alloc_page();
c0108298:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010829f:	e8 88 df ff ff       	call   c010622c <alloc_pages>
c01082a4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01082a7:	89 04 95 40 bb 12 c0 	mov    %eax,-0x3fed44c0(,%edx,4)
          assert(check_rp[i] != NULL );
c01082ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01082b1:	8b 04 85 40 bb 12 c0 	mov    -0x3fed44c0(,%eax,4),%eax
c01082b8:	85 c0                	test   %eax,%eax
c01082ba:	75 24                	jne    c01082e0 <check_swap+0x2b1>
c01082bc:	c7 44 24 0c 0c cb 10 	movl   $0xc010cb0c,0xc(%esp)
c01082c3:	c0 
c01082c4:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c01082cb:	c0 
c01082cc:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c01082d3:	00 
c01082d4:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c01082db:	e8 80 9e ff ff       	call   c0102160 <__panic>
          assert(!PageProperty(check_rp[i]));
c01082e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01082e3:	8b 04 85 40 bb 12 c0 	mov    -0x3fed44c0(,%eax,4),%eax
c01082ea:	83 c0 04             	add    $0x4,%eax
c01082ed:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c01082f4:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01082f7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01082fa:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01082fd:	0f a3 10             	bt     %edx,(%eax)
c0108300:	19 c0                	sbb    %eax,%eax
c0108302:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0108305:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0108309:	0f 95 c0             	setne  %al
c010830c:	0f b6 c0             	movzbl %al,%eax
c010830f:	85 c0                	test   %eax,%eax
c0108311:	74 24                	je     c0108337 <check_swap+0x308>
c0108313:	c7 44 24 0c 20 cb 10 	movl   $0xc010cb20,0xc(%esp)
c010831a:	c0 
c010831b:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0108322:	c0 
c0108323:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c010832a:	00 
c010832b:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0108332:	e8 29 9e ff ff       	call   c0102160 <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0108337:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c010833b:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010833f:	0f 8e 53 ff ff ff    	jle    c0108298 <check_swap+0x269>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c0108345:	a1 18 bb 12 c0       	mov    0xc012bb18,%eax
c010834a:	8b 15 1c bb 12 c0    	mov    0xc012bb1c,%edx
c0108350:	89 45 98             	mov    %eax,-0x68(%ebp)
c0108353:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0108356:	c7 45 a8 18 bb 12 c0 	movl   $0xc012bb18,-0x58(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010835d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0108360:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0108363:	89 50 04             	mov    %edx,0x4(%eax)
c0108366:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0108369:	8b 50 04             	mov    0x4(%eax),%edx
c010836c:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010836f:	89 10                	mov    %edx,(%eax)
c0108371:	c7 45 a4 18 bb 12 c0 	movl   $0xc012bb18,-0x5c(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0108378:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010837b:	8b 40 04             	mov    0x4(%eax),%eax
c010837e:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
c0108381:	0f 94 c0             	sete   %al
c0108384:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0108387:	85 c0                	test   %eax,%eax
c0108389:	75 24                	jne    c01083af <check_swap+0x380>
c010838b:	c7 44 24 0c 3b cb 10 	movl   $0xc010cb3b,0xc(%esp)
c0108392:	c0 
c0108393:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c010839a:	c0 
c010839b:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c01083a2:	00 
c01083a3:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c01083aa:	e8 b1 9d ff ff       	call   c0102160 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c01083af:	a1 20 bb 12 c0       	mov    0xc012bb20,%eax
c01083b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
     nr_free = 0;
c01083b7:	c7 05 20 bb 12 c0 00 	movl   $0x0,0xc012bb20
c01083be:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01083c1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01083c8:	eb 1e                	jmp    c01083e8 <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c01083ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01083cd:	8b 04 85 40 bb 12 c0 	mov    -0x3fed44c0(,%eax,4),%eax
c01083d4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01083db:	00 
c01083dc:	89 04 24             	mov    %eax,(%esp)
c01083df:	e8 b3 de ff ff       	call   c0106297 <free_pages>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01083e4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01083e8:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01083ec:	7e dc                	jle    c01083ca <check_swap+0x39b>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c01083ee:	a1 20 bb 12 c0       	mov    0xc012bb20,%eax
c01083f3:	83 f8 04             	cmp    $0x4,%eax
c01083f6:	74 24                	je     c010841c <check_swap+0x3ed>
c01083f8:	c7 44 24 0c 54 cb 10 	movl   $0xc010cb54,0xc(%esp)
c01083ff:	c0 
c0108400:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0108407:	c0 
c0108408:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c010840f:	00 
c0108410:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0108417:	e8 44 9d ff ff       	call   c0102160 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c010841c:	c7 04 24 78 cb 10 c0 	movl   $0xc010cb78,(%esp)
c0108423:	e8 ae 93 ff ff       	call   c01017d6 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0108428:	c7 05 d8 9a 12 c0 00 	movl   $0x0,0xc0129ad8
c010842f:	00 00 00 
     
     check_content_set();
c0108432:	e8 28 fa ff ff       	call   c0107e5f <check_content_set>
     assert( nr_free == 0);         
c0108437:	a1 20 bb 12 c0       	mov    0xc012bb20,%eax
c010843c:	85 c0                	test   %eax,%eax
c010843e:	74 24                	je     c0108464 <check_swap+0x435>
c0108440:	c7 44 24 0c 9f cb 10 	movl   $0xc010cb9f,0xc(%esp)
c0108447:	c0 
c0108448:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c010844f:	c0 
c0108450:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0108457:	00 
c0108458:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c010845f:	e8 fc 9c ff ff       	call   c0102160 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0108464:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010846b:	eb 26                	jmp    c0108493 <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c010846d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108470:	c7 04 85 60 bb 12 c0 	movl   $0xffffffff,-0x3fed44a0(,%eax,4)
c0108477:	ff ff ff ff 
c010847b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010847e:	8b 14 85 60 bb 12 c0 	mov    -0x3fed44a0(,%eax,4),%edx
c0108485:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108488:	89 14 85 a0 bb 12 c0 	mov    %edx,-0x3fed4460(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c010848f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0108493:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0108497:	7e d4                	jle    c010846d <check_swap+0x43e>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0108499:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01084a0:	e9 eb 00 00 00       	jmp    c0108590 <check_swap+0x561>
         check_ptep[i]=0;
c01084a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084a8:	c7 04 85 f4 bb 12 c0 	movl   $0x0,-0x3fed440c(,%eax,4)
c01084af:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c01084b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084b6:	83 c0 01             	add    $0x1,%eax
c01084b9:	c1 e0 0c             	shl    $0xc,%eax
c01084bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01084c3:	00 
c01084c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01084cb:	89 04 24             	mov    %eax,(%esp)
c01084ce:	e8 d0 e4 ff ff       	call   c01069a3 <get_pte>
c01084d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01084d6:	89 04 95 f4 bb 12 c0 	mov    %eax,-0x3fed440c(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c01084dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084e0:	8b 04 85 f4 bb 12 c0 	mov    -0x3fed440c(,%eax,4),%eax
c01084e7:	85 c0                	test   %eax,%eax
c01084e9:	75 24                	jne    c010850f <check_swap+0x4e0>
c01084eb:	c7 44 24 0c ac cb 10 	movl   $0xc010cbac,0xc(%esp)
c01084f2:	c0 
c01084f3:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c01084fa:	c0 
c01084fb:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0108502:	00 
c0108503:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c010850a:	e8 51 9c ff ff       	call   c0102160 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c010850f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108512:	8b 04 85 f4 bb 12 c0 	mov    -0x3fed440c(,%eax,4),%eax
c0108519:	8b 00                	mov    (%eax),%eax
c010851b:	89 04 24             	mov    %eax,(%esp)
c010851e:	e8 9f f5 ff ff       	call   c0107ac2 <pte2page>
c0108523:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108526:	8b 14 95 40 bb 12 c0 	mov    -0x3fed44c0(,%edx,4),%edx
c010852d:	39 d0                	cmp    %edx,%eax
c010852f:	74 24                	je     c0108555 <check_swap+0x526>
c0108531:	c7 44 24 0c c4 cb 10 	movl   $0xc010cbc4,0xc(%esp)
c0108538:	c0 
c0108539:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0108540:	c0 
c0108541:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0108548:	00 
c0108549:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0108550:	e8 0b 9c ff ff       	call   c0102160 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0108555:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108558:	8b 04 85 f4 bb 12 c0 	mov    -0x3fed440c(,%eax,4),%eax
c010855f:	8b 00                	mov    (%eax),%eax
c0108561:	83 e0 01             	and    $0x1,%eax
c0108564:	85 c0                	test   %eax,%eax
c0108566:	75 24                	jne    c010858c <check_swap+0x55d>
c0108568:	c7 44 24 0c ec cb 10 	movl   $0xc010cbec,0xc(%esp)
c010856f:	c0 
c0108570:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c0108577:	c0 
c0108578:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c010857f:	00 
c0108580:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c0108587:	e8 d4 9b ff ff       	call   c0102160 <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010858c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0108590:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0108594:	0f 8e 0b ff ff ff    	jle    c01084a5 <check_swap+0x476>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c010859a:	c7 04 24 08 cc 10 c0 	movl   $0xc010cc08,(%esp)
c01085a1:	e8 30 92 ff ff       	call   c01017d6 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c01085a6:	e8 6c fa ff ff       	call   c0108017 <check_content_access>
c01085ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(ret==0);
c01085ae:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01085b2:	74 24                	je     c01085d8 <check_swap+0x5a9>
c01085b4:	c7 44 24 0c 2e cc 10 	movl   $0xc010cc2e,0xc(%esp)
c01085bb:	c0 
c01085bc:	c7 44 24 08 16 c9 10 	movl   $0xc010c916,0x8(%esp)
c01085c3:	c0 
c01085c4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c01085cb:	00 
c01085cc:	c7 04 24 b0 c8 10 c0 	movl   $0xc010c8b0,(%esp)
c01085d3:	e8 88 9b ff ff       	call   c0102160 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01085d8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01085df:	eb 1e                	jmp    c01085ff <check_swap+0x5d0>
         free_pages(check_rp[i],1);
c01085e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01085e4:	8b 04 85 40 bb 12 c0 	mov    -0x3fed44c0(,%eax,4),%eax
c01085eb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01085f2:	00 
c01085f3:	89 04 24             	mov    %eax,(%esp)
c01085f6:	e8 9c dc ff ff       	call   c0106297 <free_pages>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01085fb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01085ff:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0108603:	7e dc                	jle    c01085e1 <check_swap+0x5b2>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0108605:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108608:	89 04 24             	mov    %eax,(%esp)
c010860b:	e8 9c 08 00 00       	call   c0108eac <mm_destroy>
         
     nr_free = nr_free_store;
c0108610:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108613:	a3 20 bb 12 c0       	mov    %eax,0xc012bb20
     free_list = free_list_store;
c0108618:	8b 45 98             	mov    -0x68(%ebp),%eax
c010861b:	8b 55 9c             	mov    -0x64(%ebp),%edx
c010861e:	a3 18 bb 12 c0       	mov    %eax,0xc012bb18
c0108623:	89 15 1c bb 12 c0    	mov    %edx,0xc012bb1c

     
     le = &free_list;
c0108629:	c7 45 e8 18 bb 12 c0 	movl   $0xc012bb18,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0108630:	eb 1d                	jmp    c010864f <check_swap+0x620>
         struct Page *p = le2page(le, page_link);
c0108632:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108635:	83 e8 10             	sub    $0x10,%eax
c0108638:	89 45 c8             	mov    %eax,-0x38(%ebp)
         count --, total -= p->property;
c010863b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010863f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108642:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108645:	8b 40 08             	mov    0x8(%eax),%eax
c0108648:	29 c2                	sub    %eax,%edx
c010864a:	89 d0                	mov    %edx,%eax
c010864c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010864f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108652:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0108655:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0108658:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c010865b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010865e:	81 7d e8 18 bb 12 c0 	cmpl   $0xc012bb18,-0x18(%ebp)
c0108665:	75 cb                	jne    c0108632 <check_swap+0x603>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c0108667:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010866a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010866e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108671:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108675:	c7 04 24 35 cc 10 c0 	movl   $0xc010cc35,(%esp)
c010867c:	e8 55 91 ff ff       	call   c01017d6 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0108681:	c7 04 24 4f cc 10 c0 	movl   $0xc010cc4f,(%esp)
c0108688:	e8 49 91 ff ff       	call   c01017d6 <cprintf>
}
c010868d:	83 c4 74             	add    $0x74,%esp
c0108690:	5b                   	pop    %ebx
c0108691:	5d                   	pop    %ebp
c0108692:	c3                   	ret    

c0108693 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0108693:	55                   	push   %ebp
c0108694:	89 e5                	mov    %esp,%ebp
c0108696:	83 ec 10             	sub    $0x10,%esp
c0108699:	c7 45 fc 04 bc 12 c0 	movl   $0xc012bc04,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01086a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01086a3:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01086a6:	89 50 04             	mov    %edx,0x4(%eax)
c01086a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01086ac:	8b 50 04             	mov    0x4(%eax),%edx
c01086af:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01086b2:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c01086b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01086b7:	c7 40 14 04 bc 12 c0 	movl   $0xc012bc04,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c01086be:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01086c3:	c9                   	leave  
c01086c4:	c3                   	ret    

c01086c5 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01086c5:	55                   	push   %ebp
c01086c6:	89 e5                	mov    %esp,%ebp
c01086c8:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c01086cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01086ce:	8b 40 14             	mov    0x14(%eax),%eax
c01086d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c01086d4:	8b 45 10             	mov    0x10(%ebp),%eax
c01086d7:	83 c0 18             	add    $0x18,%eax
c01086da:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c01086dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01086e1:	74 06                	je     c01086e9 <_fifo_map_swappable+0x24>
c01086e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01086e7:	75 24                	jne    c010870d <_fifo_map_swappable+0x48>
c01086e9:	c7 44 24 0c 68 cc 10 	movl   $0xc010cc68,0xc(%esp)
c01086f0:	c0 
c01086f1:	c7 44 24 08 86 cc 10 	movl   $0xc010cc86,0x8(%esp)
c01086f8:	c0 
c01086f9:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0108700:	00 
c0108701:	c7 04 24 9b cc 10 c0 	movl   $0xc010cc9b,(%esp)
c0108708:	e8 53 9a ff ff       	call   c0102160 <__panic>
c010870d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108710:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108713:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108716:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108719:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010871c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010871f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108722:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0108725:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108728:	8b 40 04             	mov    0x4(%eax),%eax
c010872b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010872e:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0108731:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108734:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0108737:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010873a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010873d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108740:	89 10                	mov    %edx,(%eax)
c0108742:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108745:	8b 10                	mov    (%eax),%edx
c0108747:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010874a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010874d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108750:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108753:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108756:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108759:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010875c:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c010875e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108763:	c9                   	leave  
c0108764:	c3                   	ret    

c0108765 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then set the addr of addr of this page to ptr_page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0108765:	55                   	push   %ebp
c0108766:	89 e5                	mov    %esp,%ebp
c0108768:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c010876b:	8b 45 08             	mov    0x8(%ebp),%eax
c010876e:	8b 40 14             	mov    0x14(%eax),%eax
c0108771:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0108774:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108778:	75 24                	jne    c010879e <_fifo_swap_out_victim+0x39>
c010877a:	c7 44 24 0c af cc 10 	movl   $0xc010ccaf,0xc(%esp)
c0108781:	c0 
c0108782:	c7 44 24 08 86 cc 10 	movl   $0xc010cc86,0x8(%esp)
c0108789:	c0 
c010878a:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0108791:	00 
c0108792:	c7 04 24 9b cc 10 c0 	movl   $0xc010cc9b,(%esp)
c0108799:	e8 c2 99 ff ff       	call   c0102160 <__panic>
     assert(in_tick==0);
c010879e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01087a2:	74 24                	je     c01087c8 <_fifo_swap_out_victim+0x63>
c01087a4:	c7 44 24 0c bc cc 10 	movl   $0xc010ccbc,0xc(%esp)
c01087ab:	c0 
c01087ac:	c7 44 24 08 86 cc 10 	movl   $0xc010cc86,0x8(%esp)
c01087b3:	c0 
c01087b4:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c01087bb:	00 
c01087bc:	c7 04 24 9b cc 10 c0 	movl   $0xc010cc9b,(%esp)
c01087c3:	e8 98 99 ff ff       	call   c0102160 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
     /* Select the tail */
     list_entry_t *le = head->prev;
c01087c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01087cb:	8b 00                	mov    (%eax),%eax
c01087cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c01087d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01087d3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01087d6:	75 24                	jne    c01087fc <_fifo_swap_out_victim+0x97>
c01087d8:	c7 44 24 0c c7 cc 10 	movl   $0xc010ccc7,0xc(%esp)
c01087df:	c0 
c01087e0:	c7 44 24 08 86 cc 10 	movl   $0xc010cc86,0x8(%esp)
c01087e7:	c0 
c01087e8:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c01087ef:	00 
c01087f0:	c7 04 24 9b cc 10 c0 	movl   $0xc010cc9b,(%esp)
c01087f7:	e8 64 99 ff ff       	call   c0102160 <__panic>
     struct Page *p = le2page(le, pra_page_link);
c01087fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01087ff:	83 e8 18             	sub    $0x18,%eax
c0108802:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108805:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108808:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010880b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010880e:	8b 40 04             	mov    0x4(%eax),%eax
c0108811:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108814:	8b 12                	mov    (%edx),%edx
c0108816:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108819:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010881c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010881f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108822:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0108825:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108828:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010882b:	89 10                	mov    %edx,(%eax)
     list_del(le);
     assert(p !=NULL);
c010882d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0108831:	75 24                	jne    c0108857 <_fifo_swap_out_victim+0xf2>
c0108833:	c7 44 24 0c d0 cc 10 	movl   $0xc010ccd0,0xc(%esp)
c010883a:	c0 
c010883b:	c7 44 24 08 86 cc 10 	movl   $0xc010cc86,0x8(%esp)
c0108842:	c0 
c0108843:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
c010884a:	00 
c010884b:	c7 04 24 9b cc 10 c0 	movl   $0xc010cc9b,(%esp)
c0108852:	e8 09 99 ff ff       	call   c0102160 <__panic>
     *ptr_page = p;
c0108857:	8b 45 0c             	mov    0xc(%ebp),%eax
c010885a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010885d:	89 10                	mov    %edx,(%eax)
     return 0;
c010885f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108864:	c9                   	leave  
c0108865:	c3                   	ret    

c0108866 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0108866:	55                   	push   %ebp
c0108867:	89 e5                	mov    %esp,%ebp
c0108869:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c010886c:	c7 04 24 dc cc 10 c0 	movl   $0xc010ccdc,(%esp)
c0108873:	e8 5e 8f ff ff       	call   c01017d6 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0108878:	b8 00 30 00 00       	mov    $0x3000,%eax
c010887d:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0108880:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c0108885:	83 f8 04             	cmp    $0x4,%eax
c0108888:	74 24                	je     c01088ae <_fifo_check_swap+0x48>
c010888a:	c7 44 24 0c 02 cd 10 	movl   $0xc010cd02,0xc(%esp)
c0108891:	c0 
c0108892:	c7 44 24 08 86 cc 10 	movl   $0xc010cc86,0x8(%esp)
c0108899:	c0 
c010889a:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
c01088a1:	00 
c01088a2:	c7 04 24 9b cc 10 c0 	movl   $0xc010cc9b,(%esp)
c01088a9:	e8 b2 98 ff ff       	call   c0102160 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01088ae:	c7 04 24 14 cd 10 c0 	movl   $0xc010cd14,(%esp)
c01088b5:	e8 1c 8f ff ff       	call   c01017d6 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c01088ba:	b8 00 10 00 00       	mov    $0x1000,%eax
c01088bf:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c01088c2:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c01088c7:	83 f8 04             	cmp    $0x4,%eax
c01088ca:	74 24                	je     c01088f0 <_fifo_check_swap+0x8a>
c01088cc:	c7 44 24 0c 02 cd 10 	movl   $0xc010cd02,0xc(%esp)
c01088d3:	c0 
c01088d4:	c7 44 24 08 86 cc 10 	movl   $0xc010cc86,0x8(%esp)
c01088db:	c0 
c01088dc:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
c01088e3:	00 
c01088e4:	c7 04 24 9b cc 10 c0 	movl   $0xc010cc9b,(%esp)
c01088eb:	e8 70 98 ff ff       	call   c0102160 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01088f0:	c7 04 24 3c cd 10 c0 	movl   $0xc010cd3c,(%esp)
c01088f7:	e8 da 8e ff ff       	call   c01017d6 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c01088fc:	b8 00 40 00 00       	mov    $0x4000,%eax
c0108901:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0108904:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c0108909:	83 f8 04             	cmp    $0x4,%eax
c010890c:	74 24                	je     c0108932 <_fifo_check_swap+0xcc>
c010890e:	c7 44 24 0c 02 cd 10 	movl   $0xc010cd02,0xc(%esp)
c0108915:	c0 
c0108916:	c7 44 24 08 86 cc 10 	movl   $0xc010cc86,0x8(%esp)
c010891d:	c0 
c010891e:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0108925:	00 
c0108926:	c7 04 24 9b cc 10 c0 	movl   $0xc010cc9b,(%esp)
c010892d:	e8 2e 98 ff ff       	call   c0102160 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0108932:	c7 04 24 64 cd 10 c0 	movl   $0xc010cd64,(%esp)
c0108939:	e8 98 8e ff ff       	call   c01017d6 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c010893e:	b8 00 20 00 00       	mov    $0x2000,%eax
c0108943:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0108946:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c010894b:	83 f8 04             	cmp    $0x4,%eax
c010894e:	74 24                	je     c0108974 <_fifo_check_swap+0x10e>
c0108950:	c7 44 24 0c 02 cd 10 	movl   $0xc010cd02,0xc(%esp)
c0108957:	c0 
c0108958:	c7 44 24 08 86 cc 10 	movl   $0xc010cc86,0x8(%esp)
c010895f:	c0 
c0108960:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0108967:	00 
c0108968:	c7 04 24 9b cc 10 c0 	movl   $0xc010cc9b,(%esp)
c010896f:	e8 ec 97 ff ff       	call   c0102160 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0108974:	c7 04 24 8c cd 10 c0 	movl   $0xc010cd8c,(%esp)
c010897b:	e8 56 8e ff ff       	call   c01017d6 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0108980:	b8 00 50 00 00       	mov    $0x5000,%eax
c0108985:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0108988:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c010898d:	83 f8 05             	cmp    $0x5,%eax
c0108990:	74 24                	je     c01089b6 <_fifo_check_swap+0x150>
c0108992:	c7 44 24 0c b2 cd 10 	movl   $0xc010cdb2,0xc(%esp)
c0108999:	c0 
c010899a:	c7 44 24 08 86 cc 10 	movl   $0xc010cc86,0x8(%esp)
c01089a1:	c0 
c01089a2:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c01089a9:	00 
c01089aa:	c7 04 24 9b cc 10 c0 	movl   $0xc010cc9b,(%esp)
c01089b1:	e8 aa 97 ff ff       	call   c0102160 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01089b6:	c7 04 24 64 cd 10 c0 	movl   $0xc010cd64,(%esp)
c01089bd:	e8 14 8e ff ff       	call   c01017d6 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c01089c2:	b8 00 20 00 00       	mov    $0x2000,%eax
c01089c7:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c01089ca:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c01089cf:	83 f8 05             	cmp    $0x5,%eax
c01089d2:	74 24                	je     c01089f8 <_fifo_check_swap+0x192>
c01089d4:	c7 44 24 0c b2 cd 10 	movl   $0xc010cdb2,0xc(%esp)
c01089db:	c0 
c01089dc:	c7 44 24 08 86 cc 10 	movl   $0xc010cc86,0x8(%esp)
c01089e3:	c0 
c01089e4:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01089eb:	00 
c01089ec:	c7 04 24 9b cc 10 c0 	movl   $0xc010cc9b,(%esp)
c01089f3:	e8 68 97 ff ff       	call   c0102160 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01089f8:	c7 04 24 14 cd 10 c0 	movl   $0xc010cd14,(%esp)
c01089ff:	e8 d2 8d ff ff       	call   c01017d6 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0108a04:	b8 00 10 00 00       	mov    $0x1000,%eax
c0108a09:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0108a0c:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c0108a11:	83 f8 06             	cmp    $0x6,%eax
c0108a14:	74 24                	je     c0108a3a <_fifo_check_swap+0x1d4>
c0108a16:	c7 44 24 0c c1 cd 10 	movl   $0xc010cdc1,0xc(%esp)
c0108a1d:	c0 
c0108a1e:	c7 44 24 08 86 cc 10 	movl   $0xc010cc86,0x8(%esp)
c0108a25:	c0 
c0108a26:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0108a2d:	00 
c0108a2e:	c7 04 24 9b cc 10 c0 	movl   $0xc010cc9b,(%esp)
c0108a35:	e8 26 97 ff ff       	call   c0102160 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0108a3a:	c7 04 24 64 cd 10 c0 	movl   $0xc010cd64,(%esp)
c0108a41:	e8 90 8d ff ff       	call   c01017d6 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0108a46:	b8 00 20 00 00       	mov    $0x2000,%eax
c0108a4b:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0108a4e:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c0108a53:	83 f8 07             	cmp    $0x7,%eax
c0108a56:	74 24                	je     c0108a7c <_fifo_check_swap+0x216>
c0108a58:	c7 44 24 0c d0 cd 10 	movl   $0xc010cdd0,0xc(%esp)
c0108a5f:	c0 
c0108a60:	c7 44 24 08 86 cc 10 	movl   $0xc010cc86,0x8(%esp)
c0108a67:	c0 
c0108a68:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0108a6f:	00 
c0108a70:	c7 04 24 9b cc 10 c0 	movl   $0xc010cc9b,(%esp)
c0108a77:	e8 e4 96 ff ff       	call   c0102160 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0108a7c:	c7 04 24 dc cc 10 c0 	movl   $0xc010ccdc,(%esp)
c0108a83:	e8 4e 8d ff ff       	call   c01017d6 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0108a88:	b8 00 30 00 00       	mov    $0x3000,%eax
c0108a8d:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0108a90:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c0108a95:	83 f8 08             	cmp    $0x8,%eax
c0108a98:	74 24                	je     c0108abe <_fifo_check_swap+0x258>
c0108a9a:	c7 44 24 0c df cd 10 	movl   $0xc010cddf,0xc(%esp)
c0108aa1:	c0 
c0108aa2:	c7 44 24 08 86 cc 10 	movl   $0xc010cc86,0x8(%esp)
c0108aa9:	c0 
c0108aaa:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0108ab1:	00 
c0108ab2:	c7 04 24 9b cc 10 c0 	movl   $0xc010cc9b,(%esp)
c0108ab9:	e8 a2 96 ff ff       	call   c0102160 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0108abe:	c7 04 24 3c cd 10 c0 	movl   $0xc010cd3c,(%esp)
c0108ac5:	e8 0c 8d ff ff       	call   c01017d6 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0108aca:	b8 00 40 00 00       	mov    $0x4000,%eax
c0108acf:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0108ad2:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c0108ad7:	83 f8 09             	cmp    $0x9,%eax
c0108ada:	74 24                	je     c0108b00 <_fifo_check_swap+0x29a>
c0108adc:	c7 44 24 0c ee cd 10 	movl   $0xc010cdee,0xc(%esp)
c0108ae3:	c0 
c0108ae4:	c7 44 24 08 86 cc 10 	movl   $0xc010cc86,0x8(%esp)
c0108aeb:	c0 
c0108aec:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0108af3:	00 
c0108af4:	c7 04 24 9b cc 10 c0 	movl   $0xc010cc9b,(%esp)
c0108afb:	e8 60 96 ff ff       	call   c0102160 <__panic>
    return 0;
c0108b00:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108b05:	c9                   	leave  
c0108b06:	c3                   	ret    

c0108b07 <_fifo_init>:


static int
_fifo_init(void)
{
c0108b07:	55                   	push   %ebp
c0108b08:	89 e5                	mov    %esp,%ebp
    return 0;
c0108b0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108b0f:	5d                   	pop    %ebp
c0108b10:	c3                   	ret    

c0108b11 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0108b11:	55                   	push   %ebp
c0108b12:	89 e5                	mov    %esp,%ebp
    return 0;
c0108b14:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108b19:	5d                   	pop    %ebp
c0108b1a:	c3                   	ret    

c0108b1b <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0108b1b:	55                   	push   %ebp
c0108b1c:	89 e5                	mov    %esp,%ebp
c0108b1e:	b8 00 00 00 00       	mov    $0x0,%eax
c0108b23:	5d                   	pop    %ebp
c0108b24:	c3                   	ret    

c0108b25 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0108b25:	55                   	push   %ebp
c0108b26:	89 e5                	mov    %esp,%ebp
c0108b28:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0108b2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b2e:	c1 e8 0c             	shr    $0xc,%eax
c0108b31:	89 c2                	mov    %eax,%edx
c0108b33:	a1 40 9a 12 c0       	mov    0xc0129a40,%eax
c0108b38:	39 c2                	cmp    %eax,%edx
c0108b3a:	72 1c                	jb     c0108b58 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0108b3c:	c7 44 24 08 10 ce 10 	movl   $0xc010ce10,0x8(%esp)
c0108b43:	c0 
c0108b44:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0108b4b:	00 
c0108b4c:	c7 04 24 2f ce 10 c0 	movl   $0xc010ce2f,(%esp)
c0108b53:	e8 08 96 ff ff       	call   c0102160 <__panic>
    }
    return &pages[PPN(pa)];
c0108b58:	8b 0d 2c bb 12 c0    	mov    0xc012bb2c,%ecx
c0108b5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b61:	c1 e8 0c             	shr    $0xc,%eax
c0108b64:	89 c2                	mov    %eax,%edx
c0108b66:	89 d0                	mov    %edx,%eax
c0108b68:	c1 e0 03             	shl    $0x3,%eax
c0108b6b:	01 d0                	add    %edx,%eax
c0108b6d:	c1 e0 02             	shl    $0x2,%eax
c0108b70:	01 c8                	add    %ecx,%eax
}
c0108b72:	c9                   	leave  
c0108b73:	c3                   	ret    

c0108b74 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0108b74:	55                   	push   %ebp
c0108b75:	89 e5                	mov    %esp,%ebp
c0108b77:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0108b7a:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0108b81:	e8 39 d2 ff ff       	call   c0105dbf <kmalloc>
c0108b86:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0108b89:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108b8d:	74 58                	je     c0108be7 <mm_create+0x73>
        list_init(&(mm->mmap_list));
c0108b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0108b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b98:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108b9b:	89 50 04             	mov    %edx,0x4(%eax)
c0108b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ba1:	8b 50 04             	mov    0x4(%eax),%edx
c0108ba4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ba7:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0108ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bac:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0108bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bb6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0108bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bc0:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0108bc7:	a1 cc 9a 12 c0       	mov    0xc0129acc,%eax
c0108bcc:	85 c0                	test   %eax,%eax
c0108bce:	74 0d                	je     c0108bdd <mm_create+0x69>
c0108bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bd3:	89 04 24             	mov    %eax,(%esp)
c0108bd6:	e8 b5 ef ff ff       	call   c0107b90 <swap_init_mm>
c0108bdb:	eb 0a                	jmp    c0108be7 <mm_create+0x73>
        else mm->sm_priv = NULL;
c0108bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108be0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0108be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108bea:	c9                   	leave  
c0108beb:	c3                   	ret    

c0108bec <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0108bec:	55                   	push   %ebp
c0108bed:	89 e5                	mov    %esp,%ebp
c0108bef:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0108bf2:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0108bf9:	e8 c1 d1 ff ff       	call   c0105dbf <kmalloc>
c0108bfe:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0108c01:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108c05:	74 1b                	je     c0108c22 <vma_create+0x36>
        vma->vm_start = vm_start;
c0108c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c0a:	8b 55 08             	mov    0x8(%ebp),%edx
c0108c0d:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0108c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c13:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108c16:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0108c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c1c:	8b 55 10             	mov    0x10(%ebp),%edx
c0108c1f:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0108c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108c25:	c9                   	leave  
c0108c26:	c3                   	ret    

c0108c27 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0108c27:	55                   	push   %ebp
c0108c28:	89 e5                	mov    %esp,%ebp
c0108c2a:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0108c2d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0108c34:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108c38:	0f 84 95 00 00 00    	je     c0108cd3 <find_vma+0xac>
        vma = mm->mmap_cache;
c0108c3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c41:	8b 40 08             	mov    0x8(%eax),%eax
c0108c44:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0108c47:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108c4b:	74 16                	je     c0108c63 <find_vma+0x3c>
c0108c4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108c50:	8b 40 04             	mov    0x4(%eax),%eax
c0108c53:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108c56:	77 0b                	ja     c0108c63 <find_vma+0x3c>
c0108c58:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108c5b:	8b 40 08             	mov    0x8(%eax),%eax
c0108c5e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108c61:	77 61                	ja     c0108cc4 <find_vma+0x9d>
                bool found = 0;
c0108c63:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0108c6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108c70:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0108c76:	eb 28                	jmp    c0108ca0 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0108c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c7b:	83 e8 10             	sub    $0x10,%eax
c0108c7e:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0108c81:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108c84:	8b 40 04             	mov    0x4(%eax),%eax
c0108c87:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108c8a:	77 14                	ja     c0108ca0 <find_vma+0x79>
c0108c8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108c8f:	8b 40 08             	mov    0x8(%eax),%eax
c0108c92:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108c95:	76 09                	jbe    c0108ca0 <find_vma+0x79>
                        found = 1;
c0108c97:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0108c9e:	eb 17                	jmp    c0108cb7 <find_vma+0x90>
c0108ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108ca3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0108ca6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108ca9:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c0108cac:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108cb2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108cb5:	75 c1                	jne    c0108c78 <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c0108cb7:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0108cbb:	75 07                	jne    c0108cc4 <find_vma+0x9d>
                    vma = NULL;
c0108cbd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0108cc4:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108cc8:	74 09                	je     c0108cd3 <find_vma+0xac>
            mm->mmap_cache = vma;
c0108cca:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ccd:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0108cd0:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0108cd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108cd6:	c9                   	leave  
c0108cd7:	c3                   	ret    

c0108cd8 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0108cd8:	55                   	push   %ebp
c0108cd9:	89 e5                	mov    %esp,%ebp
c0108cdb:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0108cde:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ce1:	8b 50 04             	mov    0x4(%eax),%edx
c0108ce4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ce7:	8b 40 08             	mov    0x8(%eax),%eax
c0108cea:	39 c2                	cmp    %eax,%edx
c0108cec:	72 24                	jb     c0108d12 <check_vma_overlap+0x3a>
c0108cee:	c7 44 24 0c 3d ce 10 	movl   $0xc010ce3d,0xc(%esp)
c0108cf5:	c0 
c0108cf6:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c0108cfd:	c0 
c0108cfe:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0108d05:	00 
c0108d06:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c0108d0d:	e8 4e 94 ff ff       	call   c0102160 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0108d12:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d15:	8b 50 08             	mov    0x8(%eax),%edx
c0108d18:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d1b:	8b 40 04             	mov    0x4(%eax),%eax
c0108d1e:	39 c2                	cmp    %eax,%edx
c0108d20:	76 24                	jbe    c0108d46 <check_vma_overlap+0x6e>
c0108d22:	c7 44 24 0c 80 ce 10 	movl   $0xc010ce80,0xc(%esp)
c0108d29:	c0 
c0108d2a:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c0108d31:	c0 
c0108d32:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c0108d39:	00 
c0108d3a:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c0108d41:	e8 1a 94 ff ff       	call   c0102160 <__panic>
    assert(next->vm_start < next->vm_end);
c0108d46:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d49:	8b 50 04             	mov    0x4(%eax),%edx
c0108d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d4f:	8b 40 08             	mov    0x8(%eax),%eax
c0108d52:	39 c2                	cmp    %eax,%edx
c0108d54:	72 24                	jb     c0108d7a <check_vma_overlap+0xa2>
c0108d56:	c7 44 24 0c 9f ce 10 	movl   $0xc010ce9f,0xc(%esp)
c0108d5d:	c0 
c0108d5e:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c0108d65:	c0 
c0108d66:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0108d6d:	00 
c0108d6e:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c0108d75:	e8 e6 93 ff ff       	call   c0102160 <__panic>
}
c0108d7a:	c9                   	leave  
c0108d7b:	c3                   	ret    

c0108d7c <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0108d7c:	55                   	push   %ebp
c0108d7d:	89 e5                	mov    %esp,%ebp
c0108d7f:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0108d82:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d85:	8b 50 04             	mov    0x4(%eax),%edx
c0108d88:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d8b:	8b 40 08             	mov    0x8(%eax),%eax
c0108d8e:	39 c2                	cmp    %eax,%edx
c0108d90:	72 24                	jb     c0108db6 <insert_vma_struct+0x3a>
c0108d92:	c7 44 24 0c bd ce 10 	movl   $0xc010cebd,0xc(%esp)
c0108d99:	c0 
c0108d9a:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c0108da1:	c0 
c0108da2:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0108da9:	00 
c0108daa:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c0108db1:	e8 aa 93 ff ff       	call   c0102160 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0108db6:	8b 45 08             	mov    0x8(%ebp),%eax
c0108db9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0108dbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0108dc2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108dc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0108dc8:	eb 21                	jmp    c0108deb <insert_vma_struct+0x6f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c0108dca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108dcd:	83 e8 10             	sub    $0x10,%eax
c0108dd0:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0108dd3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108dd6:	8b 50 04             	mov    0x4(%eax),%edx
c0108dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ddc:	8b 40 04             	mov    0x4(%eax),%eax
c0108ddf:	39 c2                	cmp    %eax,%edx
c0108de1:	76 02                	jbe    c0108de5 <insert_vma_struct+0x69>
                break;
c0108de3:	eb 1d                	jmp    c0108e02 <insert_vma_struct+0x86>
            }
            le_prev = le;
c0108de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108de8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108deb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108dee:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108df1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108df4:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c0108df7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108dfd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108e00:	75 c8                	jne    c0108dca <insert_vma_struct+0x4e>
c0108e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108e05:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0108e08:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108e0b:	8b 40 04             	mov    0x4(%eax),%eax
                break;
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c0108e0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0108e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108e14:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108e17:	74 15                	je     c0108e2e <insert_vma_struct+0xb2>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0108e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108e1c:	8d 50 f0             	lea    -0x10(%eax),%edx
c0108e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e22:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108e26:	89 14 24             	mov    %edx,(%esp)
c0108e29:	e8 aa fe ff ff       	call   c0108cd8 <check_vma_overlap>
    }
    if (le_next != list) {
c0108e2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108e31:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108e34:	74 15                	je     c0108e4b <insert_vma_struct+0xcf>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0108e36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108e39:	83 e8 10             	sub    $0x10,%eax
c0108e3c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108e40:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e43:	89 04 24             	mov    %eax,(%esp)
c0108e46:	e8 8d fe ff ff       	call   c0108cd8 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0108e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e4e:	8b 55 08             	mov    0x8(%ebp),%edx
c0108e51:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0108e53:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e56:	8d 50 10             	lea    0x10(%eax),%edx
c0108e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108e5c:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108e5f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0108e62:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108e65:	8b 40 04             	mov    0x4(%eax),%eax
c0108e68:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108e6b:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0108e6e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108e71:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0108e74:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0108e77:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108e7a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0108e7d:	89 10                	mov    %edx,(%eax)
c0108e7f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108e82:	8b 10                	mov    (%eax),%edx
c0108e84:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108e87:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108e8a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108e8d:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0108e90:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108e93:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108e96:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0108e99:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c0108e9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e9e:	8b 40 10             	mov    0x10(%eax),%eax
c0108ea1:	8d 50 01             	lea    0x1(%eax),%edx
c0108ea4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ea7:	89 50 10             	mov    %edx,0x10(%eax)
}
c0108eaa:	c9                   	leave  
c0108eab:	c3                   	ret    

c0108eac <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0108eac:	55                   	push   %ebp
c0108ead:	89 e5                	mov    %esp,%ebp
c0108eaf:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c0108eb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0108eb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c0108eb8:	eb 36                	jmp    c0108ef0 <mm_destroy+0x44>
c0108eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ebd:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0108ec0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108ec3:	8b 40 04             	mov    0x4(%eax),%eax
c0108ec6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108ec9:	8b 12                	mov    (%edx),%edx
c0108ecb:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108ece:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0108ed1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ed4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108ed7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0108eda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108edd:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108ee0:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c0108ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ee5:	83 e8 10             	sub    $0x10,%eax
c0108ee8:	89 04 24             	mov    %eax,(%esp)
c0108eeb:	e8 ea ce ff ff       	call   c0105dda <kfree>
c0108ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108ef3:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0108ef6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108ef9:	8b 40 04             	mov    0x4(%eax),%eax
// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c0108efc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108eff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108f02:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0108f05:	75 b3                	jne    c0108eba <mm_destroy+0xe>
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
    }
    kfree(mm); //kfree mm
c0108f07:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f0a:	89 04 24             	mov    %eax,(%esp)
c0108f0d:	e8 c8 ce ff ff       	call   c0105dda <kfree>
    mm=NULL;
c0108f12:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0108f19:	c9                   	leave  
c0108f1a:	c3                   	ret    

c0108f1b <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0108f1b:	55                   	push   %ebp
c0108f1c:	89 e5                	mov    %esp,%ebp
c0108f1e:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0108f21:	e8 02 00 00 00       	call   c0108f28 <check_vmm>
}
c0108f26:	c9                   	leave  
c0108f27:	c3                   	ret    

c0108f28 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0108f28:	55                   	push   %ebp
c0108f29:	89 e5                	mov    %esp,%ebp
c0108f2b:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108f2e:	e8 96 d3 ff ff       	call   c01062c9 <nr_free_pages>
c0108f33:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c0108f36:	e8 13 00 00 00       	call   c0108f4e <check_vma_struct>
    check_pgfault();
c0108f3b:	e8 a7 04 00 00       	call   c01093e7 <check_pgfault>

 //   assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vmm() succeeded.\n");
c0108f40:	c7 04 24 d9 ce 10 c0 	movl   $0xc010ced9,(%esp)
c0108f47:	e8 8a 88 ff ff       	call   c01017d6 <cprintf>
}
c0108f4c:	c9                   	leave  
c0108f4d:	c3                   	ret    

c0108f4e <check_vma_struct>:

static void
check_vma_struct(void) {
c0108f4e:	55                   	push   %ebp
c0108f4f:	89 e5                	mov    %esp,%ebp
c0108f51:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108f54:	e8 70 d3 ff ff       	call   c01062c9 <nr_free_pages>
c0108f59:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0108f5c:	e8 13 fc ff ff       	call   c0108b74 <mm_create>
c0108f61:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0108f64:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108f68:	75 24                	jne    c0108f8e <check_vma_struct+0x40>
c0108f6a:	c7 44 24 0c f1 ce 10 	movl   $0xc010cef1,0xc(%esp)
c0108f71:	c0 
c0108f72:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c0108f79:	c0 
c0108f7a:	c7 44 24 04 b4 00 00 	movl   $0xb4,0x4(%esp)
c0108f81:	00 
c0108f82:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c0108f89:	e8 d2 91 ff ff       	call   c0102160 <__panic>

    int step1 = 10, step2 = step1 * 10;
c0108f8e:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0108f95:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108f98:	89 d0                	mov    %edx,%eax
c0108f9a:	c1 e0 02             	shl    $0x2,%eax
c0108f9d:	01 d0                	add    %edx,%eax
c0108f9f:	01 c0                	add    %eax,%eax
c0108fa1:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0108fa4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108fa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108faa:	eb 70                	jmp    c010901c <check_vma_struct+0xce>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0108fac:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108faf:	89 d0                	mov    %edx,%eax
c0108fb1:	c1 e0 02             	shl    $0x2,%eax
c0108fb4:	01 d0                	add    %edx,%eax
c0108fb6:	83 c0 02             	add    $0x2,%eax
c0108fb9:	89 c1                	mov    %eax,%ecx
c0108fbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108fbe:	89 d0                	mov    %edx,%eax
c0108fc0:	c1 e0 02             	shl    $0x2,%eax
c0108fc3:	01 d0                	add    %edx,%eax
c0108fc5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108fcc:	00 
c0108fcd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0108fd1:	89 04 24             	mov    %eax,(%esp)
c0108fd4:	e8 13 fc ff ff       	call   c0108bec <vma_create>
c0108fd9:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c0108fdc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108fe0:	75 24                	jne    c0109006 <check_vma_struct+0xb8>
c0108fe2:	c7 44 24 0c fc ce 10 	movl   $0xc010cefc,0xc(%esp)
c0108fe9:	c0 
c0108fea:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c0108ff1:	c0 
c0108ff2:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c0108ff9:	00 
c0108ffa:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c0109001:	e8 5a 91 ff ff       	call   c0102160 <__panic>
        insert_vma_struct(mm, vma);
c0109006:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109009:	89 44 24 04          	mov    %eax,0x4(%esp)
c010900d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109010:	89 04 24             	mov    %eax,(%esp)
c0109013:	e8 64 fd ff ff       	call   c0108d7c <insert_vma_struct>
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c0109018:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010901c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109020:	7f 8a                	jg     c0108fac <check_vma_struct+0x5e>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0109022:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109025:	83 c0 01             	add    $0x1,%eax
c0109028:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010902b:	eb 70                	jmp    c010909d <check_vma_struct+0x14f>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c010902d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109030:	89 d0                	mov    %edx,%eax
c0109032:	c1 e0 02             	shl    $0x2,%eax
c0109035:	01 d0                	add    %edx,%eax
c0109037:	83 c0 02             	add    $0x2,%eax
c010903a:	89 c1                	mov    %eax,%ecx
c010903c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010903f:	89 d0                	mov    %edx,%eax
c0109041:	c1 e0 02             	shl    $0x2,%eax
c0109044:	01 d0                	add    %edx,%eax
c0109046:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010904d:	00 
c010904e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0109052:	89 04 24             	mov    %eax,(%esp)
c0109055:	e8 92 fb ff ff       	call   c0108bec <vma_create>
c010905a:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c010905d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0109061:	75 24                	jne    c0109087 <check_vma_struct+0x139>
c0109063:	c7 44 24 0c fc ce 10 	movl   $0xc010cefc,0xc(%esp)
c010906a:	c0 
c010906b:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c0109072:	c0 
c0109073:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c010907a:	00 
c010907b:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c0109082:	e8 d9 90 ff ff       	call   c0102160 <__panic>
        insert_vma_struct(mm, vma);
c0109087:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010908a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010908e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109091:	89 04 24             	mov    %eax,(%esp)
c0109094:	e8 e3 fc ff ff       	call   c0108d7c <insert_vma_struct>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0109099:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010909d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01090a0:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01090a3:	7e 88                	jle    c010902d <check_vma_struct+0xdf>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c01090a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01090a8:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01090ab:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01090ae:	8b 40 04             	mov    0x4(%eax),%eax
c01090b1:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c01090b4:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c01090bb:	e9 97 00 00 00       	jmp    c0109157 <check_vma_struct+0x209>
        assert(le != &(mm->mmap_list));
c01090c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01090c3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01090c6:	75 24                	jne    c01090ec <check_vma_struct+0x19e>
c01090c8:	c7 44 24 0c 08 cf 10 	movl   $0xc010cf08,0xc(%esp)
c01090cf:	c0 
c01090d0:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c01090d7:	c0 
c01090d8:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c01090df:	00 
c01090e0:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c01090e7:	e8 74 90 ff ff       	call   c0102160 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c01090ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01090ef:	83 e8 10             	sub    $0x10,%eax
c01090f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c01090f5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01090f8:	8b 48 04             	mov    0x4(%eax),%ecx
c01090fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01090fe:	89 d0                	mov    %edx,%eax
c0109100:	c1 e0 02             	shl    $0x2,%eax
c0109103:	01 d0                	add    %edx,%eax
c0109105:	39 c1                	cmp    %eax,%ecx
c0109107:	75 17                	jne    c0109120 <check_vma_struct+0x1d2>
c0109109:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010910c:	8b 48 08             	mov    0x8(%eax),%ecx
c010910f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109112:	89 d0                	mov    %edx,%eax
c0109114:	c1 e0 02             	shl    $0x2,%eax
c0109117:	01 d0                	add    %edx,%eax
c0109119:	83 c0 02             	add    $0x2,%eax
c010911c:	39 c1                	cmp    %eax,%ecx
c010911e:	74 24                	je     c0109144 <check_vma_struct+0x1f6>
c0109120:	c7 44 24 0c 20 cf 10 	movl   $0xc010cf20,0xc(%esp)
c0109127:	c0 
c0109128:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c010912f:	c0 
c0109130:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0109137:	00 
c0109138:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c010913f:	e8 1c 90 ff ff       	call   c0102160 <__panic>
c0109144:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109147:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010914a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010914d:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0109150:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c0109153:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0109157:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010915a:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010915d:	0f 8e 5d ff ff ff    	jle    c01090c0 <check_vma_struct+0x172>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0109163:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c010916a:	e9 cd 01 00 00       	jmp    c010933c <check_vma_struct+0x3ee>
        struct vma_struct *vma1 = find_vma(mm, i);
c010916f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109172:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109176:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109179:	89 04 24             	mov    %eax,(%esp)
c010917c:	e8 a6 fa ff ff       	call   c0108c27 <find_vma>
c0109181:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma1 != NULL);
c0109184:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0109188:	75 24                	jne    c01091ae <check_vma_struct+0x260>
c010918a:	c7 44 24 0c 55 cf 10 	movl   $0xc010cf55,0xc(%esp)
c0109191:	c0 
c0109192:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c0109199:	c0 
c010919a:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c01091a1:	00 
c01091a2:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c01091a9:	e8 b2 8f ff ff       	call   c0102160 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c01091ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091b1:	83 c0 01             	add    $0x1,%eax
c01091b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01091b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01091bb:	89 04 24             	mov    %eax,(%esp)
c01091be:	e8 64 fa ff ff       	call   c0108c27 <find_vma>
c01091c3:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma2 != NULL);
c01091c6:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01091ca:	75 24                	jne    c01091f0 <check_vma_struct+0x2a2>
c01091cc:	c7 44 24 0c 62 cf 10 	movl   $0xc010cf62,0xc(%esp)
c01091d3:	c0 
c01091d4:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c01091db:	c0 
c01091dc:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c01091e3:	00 
c01091e4:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c01091eb:	e8 70 8f ff ff       	call   c0102160 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c01091f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091f3:	83 c0 02             	add    $0x2,%eax
c01091f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01091fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01091fd:	89 04 24             	mov    %eax,(%esp)
c0109200:	e8 22 fa ff ff       	call   c0108c27 <find_vma>
c0109205:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma3 == NULL);
c0109208:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010920c:	74 24                	je     c0109232 <check_vma_struct+0x2e4>
c010920e:	c7 44 24 0c 6f cf 10 	movl   $0xc010cf6f,0xc(%esp)
c0109215:	c0 
c0109216:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c010921d:	c0 
c010921e:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0109225:	00 
c0109226:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c010922d:	e8 2e 8f ff ff       	call   c0102160 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0109232:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109235:	83 c0 03             	add    $0x3,%eax
c0109238:	89 44 24 04          	mov    %eax,0x4(%esp)
c010923c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010923f:	89 04 24             	mov    %eax,(%esp)
c0109242:	e8 e0 f9 ff ff       	call   c0108c27 <find_vma>
c0109247:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma4 == NULL);
c010924a:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c010924e:	74 24                	je     c0109274 <check_vma_struct+0x326>
c0109250:	c7 44 24 0c 7c cf 10 	movl   $0xc010cf7c,0xc(%esp)
c0109257:	c0 
c0109258:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c010925f:	c0 
c0109260:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0109267:	00 
c0109268:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c010926f:	e8 ec 8e ff ff       	call   c0102160 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0109274:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109277:	83 c0 04             	add    $0x4,%eax
c010927a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010927e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109281:	89 04 24             	mov    %eax,(%esp)
c0109284:	e8 9e f9 ff ff       	call   c0108c27 <find_vma>
c0109289:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma5 == NULL);
c010928c:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0109290:	74 24                	je     c01092b6 <check_vma_struct+0x368>
c0109292:	c7 44 24 0c 89 cf 10 	movl   $0xc010cf89,0xc(%esp)
c0109299:	c0 
c010929a:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c01092a1:	c0 
c01092a2:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c01092a9:	00 
c01092aa:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c01092b1:	e8 aa 8e ff ff       	call   c0102160 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c01092b6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01092b9:	8b 50 04             	mov    0x4(%eax),%edx
c01092bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01092bf:	39 c2                	cmp    %eax,%edx
c01092c1:	75 10                	jne    c01092d3 <check_vma_struct+0x385>
c01092c3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01092c6:	8b 50 08             	mov    0x8(%eax),%edx
c01092c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01092cc:	83 c0 02             	add    $0x2,%eax
c01092cf:	39 c2                	cmp    %eax,%edx
c01092d1:	74 24                	je     c01092f7 <check_vma_struct+0x3a9>
c01092d3:	c7 44 24 0c 98 cf 10 	movl   $0xc010cf98,0xc(%esp)
c01092da:	c0 
c01092db:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c01092e2:	c0 
c01092e3:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c01092ea:	00 
c01092eb:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c01092f2:	e8 69 8e ff ff       	call   c0102160 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c01092f7:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01092fa:	8b 50 04             	mov    0x4(%eax),%edx
c01092fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109300:	39 c2                	cmp    %eax,%edx
c0109302:	75 10                	jne    c0109314 <check_vma_struct+0x3c6>
c0109304:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0109307:	8b 50 08             	mov    0x8(%eax),%edx
c010930a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010930d:	83 c0 02             	add    $0x2,%eax
c0109310:	39 c2                	cmp    %eax,%edx
c0109312:	74 24                	je     c0109338 <check_vma_struct+0x3ea>
c0109314:	c7 44 24 0c c8 cf 10 	movl   $0xc010cfc8,0xc(%esp)
c010931b:	c0 
c010931c:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c0109323:	c0 
c0109324:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c010932b:	00 
c010932c:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c0109333:	e8 28 8e ff ff       	call   c0102160 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0109338:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c010933c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010933f:	89 d0                	mov    %edx,%eax
c0109341:	c1 e0 02             	shl    $0x2,%eax
c0109344:	01 d0                	add    %edx,%eax
c0109346:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0109349:	0f 8d 20 fe ff ff    	jge    c010916f <check_vma_struct+0x221>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c010934f:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0109356:	eb 70                	jmp    c01093c8 <check_vma_struct+0x47a>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0109358:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010935b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010935f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109362:	89 04 24             	mov    %eax,(%esp)
c0109365:	e8 bd f8 ff ff       	call   c0108c27 <find_vma>
c010936a:	89 45 bc             	mov    %eax,-0x44(%ebp)
        if (vma_below_5 != NULL ) {
c010936d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0109371:	74 27                	je     c010939a <check_vma_struct+0x44c>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0109373:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0109376:	8b 50 08             	mov    0x8(%eax),%edx
c0109379:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010937c:	8b 40 04             	mov    0x4(%eax),%eax
c010937f:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0109383:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109387:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010938a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010938e:	c7 04 24 f8 cf 10 c0 	movl   $0xc010cff8,(%esp)
c0109395:	e8 3c 84 ff ff       	call   c01017d6 <cprintf>
        }
        assert(vma_below_5 == NULL);
c010939a:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010939e:	74 24                	je     c01093c4 <check_vma_struct+0x476>
c01093a0:	c7 44 24 0c 1d d0 10 	movl   $0xc010d01d,0xc(%esp)
c01093a7:	c0 
c01093a8:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c01093af:	c0 
c01093b0:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c01093b7:	00 
c01093b8:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c01093bf:	e8 9c 8d ff ff       	call   c0102160 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c01093c4:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01093c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01093cc:	79 8a                	jns    c0109358 <check_vma_struct+0x40a>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c01093ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01093d1:	89 04 24             	mov    %eax,(%esp)
c01093d4:	e8 d3 fa ff ff       	call   c0108eac <mm_destroy>

//    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vma_struct() succeeded!\n");
c01093d9:	c7 04 24 34 d0 10 c0 	movl   $0xc010d034,(%esp)
c01093e0:	e8 f1 83 ff ff       	call   c01017d6 <cprintf>
}
c01093e5:	c9                   	leave  
c01093e6:	c3                   	ret    

c01093e7 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c01093e7:	55                   	push   %ebp
c01093e8:	89 e5                	mov    %esp,%ebp
c01093ea:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01093ed:	e8 d7 ce ff ff       	call   c01062c9 <nr_free_pages>
c01093f2:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c01093f5:	e8 7a f7 ff ff       	call   c0108b74 <mm_create>
c01093fa:	a3 0c bc 12 c0       	mov    %eax,0xc012bc0c
    assert(check_mm_struct != NULL);
c01093ff:	a1 0c bc 12 c0       	mov    0xc012bc0c,%eax
c0109404:	85 c0                	test   %eax,%eax
c0109406:	75 24                	jne    c010942c <check_pgfault+0x45>
c0109408:	c7 44 24 0c 53 d0 10 	movl   $0xc010d053,0xc(%esp)
c010940f:	c0 
c0109410:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c0109417:	c0 
c0109418:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c010941f:	00 
c0109420:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c0109427:	e8 34 8d ff ff       	call   c0102160 <__panic>

    struct mm_struct *mm = check_mm_struct;
c010942c:	a1 0c bc 12 c0       	mov    0xc012bc0c,%eax
c0109431:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0109434:	8b 15 44 9a 12 c0    	mov    0xc0129a44,%edx
c010943a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010943d:	89 50 0c             	mov    %edx,0xc(%eax)
c0109440:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109443:	8b 40 0c             	mov    0xc(%eax),%eax
c0109446:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0109449:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010944c:	8b 00                	mov    (%eax),%eax
c010944e:	85 c0                	test   %eax,%eax
c0109450:	74 24                	je     c0109476 <check_pgfault+0x8f>
c0109452:	c7 44 24 0c 6b d0 10 	movl   $0xc010d06b,0xc(%esp)
c0109459:	c0 
c010945a:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c0109461:	c0 
c0109462:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0109469:	00 
c010946a:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c0109471:	e8 ea 8c ff ff       	call   c0102160 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0109476:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c010947d:	00 
c010947e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0109485:	00 
c0109486:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010948d:	e8 5a f7 ff ff       	call   c0108bec <vma_create>
c0109492:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0109495:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0109499:	75 24                	jne    c01094bf <check_pgfault+0xd8>
c010949b:	c7 44 24 0c fc ce 10 	movl   $0xc010cefc,0xc(%esp)
c01094a2:	c0 
c01094a3:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c01094aa:	c0 
c01094ab:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c01094b2:	00 
c01094b3:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c01094ba:	e8 a1 8c ff ff       	call   c0102160 <__panic>

    insert_vma_struct(mm, vma);
c01094bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01094c2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01094c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01094c9:	89 04 24             	mov    %eax,(%esp)
c01094cc:	e8 ab f8 ff ff       	call   c0108d7c <insert_vma_struct>

    uintptr_t addr = 0x100;
c01094d1:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c01094d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01094db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01094df:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01094e2:	89 04 24             	mov    %eax,(%esp)
c01094e5:	e8 3d f7 ff ff       	call   c0108c27 <find_vma>
c01094ea:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01094ed:	74 24                	je     c0109513 <check_pgfault+0x12c>
c01094ef:	c7 44 24 0c 79 d0 10 	movl   $0xc010d079,0xc(%esp)
c01094f6:	c0 
c01094f7:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c01094fe:	c0 
c01094ff:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0109506:	00 
c0109507:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c010950e:	e8 4d 8c ff ff       	call   c0102160 <__panic>

    int i, sum = 0;
c0109513:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c010951a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0109521:	eb 17                	jmp    c010953a <check_pgfault+0x153>
        *(char *)(addr + i) = i;
c0109523:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109526:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109529:	01 d0                	add    %edx,%eax
c010952b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010952e:	88 10                	mov    %dl,(%eax)
        sum += i;
c0109530:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109533:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c0109536:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010953a:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c010953e:	7e e3                	jle    c0109523 <check_pgfault+0x13c>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0109540:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0109547:	eb 15                	jmp    c010955e <check_pgfault+0x177>
        sum -= *(char *)(addr + i);
c0109549:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010954c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010954f:	01 d0                	add    %edx,%eax
c0109551:	0f b6 00             	movzbl (%eax),%eax
c0109554:	0f be c0             	movsbl %al,%eax
c0109557:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c010955a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010955e:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0109562:	7e e5                	jle    c0109549 <check_pgfault+0x162>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c0109564:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109568:	74 24                	je     c010958e <check_pgfault+0x1a7>
c010956a:	c7 44 24 0c 93 d0 10 	movl   $0xc010d093,0xc(%esp)
c0109571:	c0 
c0109572:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c0109579:	c0 
c010957a:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c0109581:	00 
c0109582:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c0109589:	e8 d2 8b ff ff       	call   c0102160 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c010958e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109591:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109594:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109597:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010959c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01095a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01095a3:	89 04 24             	mov    %eax,(%esp)
c01095a6:	e8 ea d5 ff ff       	call   c0106b95 <page_remove>
    free_page(pa2page(pgdir[0]));
c01095ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01095ae:	8b 00                	mov    (%eax),%eax
c01095b0:	89 04 24             	mov    %eax,(%esp)
c01095b3:	e8 6d f5 ff ff       	call   c0108b25 <pa2page>
c01095b8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01095bf:	00 
c01095c0:	89 04 24             	mov    %eax,(%esp)
c01095c3:	e8 cf cc ff ff       	call   c0106297 <free_pages>
    pgdir[0] = 0;
c01095c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01095cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c01095d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01095d4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c01095db:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01095de:	89 04 24             	mov    %eax,(%esp)
c01095e1:	e8 c6 f8 ff ff       	call   c0108eac <mm_destroy>
    check_mm_struct = NULL;
c01095e6:	c7 05 0c bc 12 c0 00 	movl   $0x0,0xc012bc0c
c01095ed:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c01095f0:	e8 d4 cc ff ff       	call   c01062c9 <nr_free_pages>
c01095f5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01095f8:	74 24                	je     c010961e <check_pgfault+0x237>
c01095fa:	c7 44 24 0c 9c d0 10 	movl   $0xc010d09c,0xc(%esp)
c0109601:	c0 
c0109602:	c7 44 24 08 5b ce 10 	movl   $0xc010ce5b,0x8(%esp)
c0109609:	c0 
c010960a:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0109611:	00 
c0109612:	c7 04 24 70 ce 10 c0 	movl   $0xc010ce70,(%esp)
c0109619:	e8 42 8b ff ff       	call   c0102160 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c010961e:	c7 04 24 c3 d0 10 c0 	movl   $0xc010d0c3,(%esp)
c0109625:	e8 ac 81 ff ff       	call   c01017d6 <cprintf>
}
c010962a:	c9                   	leave  
c010962b:	c3                   	ret    

c010962c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c010962c:	55                   	push   %ebp
c010962d:	89 e5                	mov    %esp,%ebp
c010962f:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0109632:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0109639:	8b 45 10             	mov    0x10(%ebp),%eax
c010963c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109640:	8b 45 08             	mov    0x8(%ebp),%eax
c0109643:	89 04 24             	mov    %eax,(%esp)
c0109646:	e8 dc f5 ff ff       	call   c0108c27 <find_vma>
c010964b:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c010964e:	a1 d8 9a 12 c0       	mov    0xc0129ad8,%eax
c0109653:	83 c0 01             	add    $0x1,%eax
c0109656:	a3 d8 9a 12 c0       	mov    %eax,0xc0129ad8
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c010965b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010965f:	74 0b                	je     c010966c <do_pgfault+0x40>
c0109661:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109664:	8b 40 04             	mov    0x4(%eax),%eax
c0109667:	3b 45 10             	cmp    0x10(%ebp),%eax
c010966a:	76 18                	jbe    c0109684 <do_pgfault+0x58>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c010966c:	8b 45 10             	mov    0x10(%ebp),%eax
c010966f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109673:	c7 04 24 e0 d0 10 c0 	movl   $0xc010d0e0,(%esp)
c010967a:	e8 57 81 ff ff       	call   c01017d6 <cprintf>
        goto failed;
c010967f:	e9 ae 01 00 00       	jmp    c0109832 <do_pgfault+0x206>
    }
    //check the error_code
    switch (error_code & 3) {
c0109684:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109687:	83 e0 03             	and    $0x3,%eax
c010968a:	85 c0                	test   %eax,%eax
c010968c:	74 36                	je     c01096c4 <do_pgfault+0x98>
c010968e:	83 f8 01             	cmp    $0x1,%eax
c0109691:	74 20                	je     c01096b3 <do_pgfault+0x87>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0109693:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109696:	8b 40 0c             	mov    0xc(%eax),%eax
c0109699:	83 e0 02             	and    $0x2,%eax
c010969c:	85 c0                	test   %eax,%eax
c010969e:	75 11                	jne    c01096b1 <do_pgfault+0x85>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c01096a0:	c7 04 24 10 d1 10 c0 	movl   $0xc010d110,(%esp)
c01096a7:	e8 2a 81 ff ff       	call   c01017d6 <cprintf>
            goto failed;
c01096ac:	e9 81 01 00 00       	jmp    c0109832 <do_pgfault+0x206>
        }
        break;
c01096b1:	eb 2f                	jmp    c01096e2 <do_pgfault+0xb6>
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c01096b3:	c7 04 24 70 d1 10 c0 	movl   $0xc010d170,(%esp)
c01096ba:	e8 17 81 ff ff       	call   c01017d6 <cprintf>
        goto failed;
c01096bf:	e9 6e 01 00 00       	jmp    c0109832 <do_pgfault+0x206>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c01096c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01096c7:	8b 40 0c             	mov    0xc(%eax),%eax
c01096ca:	83 e0 05             	and    $0x5,%eax
c01096cd:	85 c0                	test   %eax,%eax
c01096cf:	75 11                	jne    c01096e2 <do_pgfault+0xb6>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c01096d1:	c7 04 24 a8 d1 10 c0 	movl   $0xc010d1a8,(%esp)
c01096d8:	e8 f9 80 ff ff       	call   c01017d6 <cprintf>
            goto failed;
c01096dd:	e9 50 01 00 00       	jmp    c0109832 <do_pgfault+0x206>
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c01096e2:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c01096e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01096ec:	8b 40 0c             	mov    0xc(%eax),%eax
c01096ef:	83 e0 02             	and    $0x2,%eax
c01096f2:	85 c0                	test   %eax,%eax
c01096f4:	74 04                	je     c01096fa <do_pgfault+0xce>
        perm |= PTE_W;
c01096f6:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c01096fa:	8b 45 10             	mov    0x10(%ebp),%eax
c01096fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109700:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109703:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0109708:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c010970b:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0109712:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        }
   }
#endif
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c0109719:	8b 45 08             	mov    0x8(%ebp),%eax
c010971c:	8b 40 0c             	mov    0xc(%eax),%eax
c010971f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0109726:	00 
c0109727:	8b 55 10             	mov    0x10(%ebp),%edx
c010972a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010972e:	89 04 24             	mov    %eax,(%esp)
c0109731:	e8 6d d2 ff ff       	call   c01069a3 <get_pte>
c0109736:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109739:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010973d:	75 11                	jne    c0109750 <do_pgfault+0x124>
        cprintf("get_pte in do_pgfault failed\n");
c010973f:	c7 04 24 0b d2 10 c0 	movl   $0xc010d20b,(%esp)
c0109746:	e8 8b 80 ff ff       	call   c01017d6 <cprintf>
        goto failed;
c010974b:	e9 e2 00 00 00       	jmp    c0109832 <do_pgfault+0x206>
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c0109750:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109753:	8b 00                	mov    (%eax),%eax
c0109755:	85 c0                	test   %eax,%eax
c0109757:	75 35                	jne    c010978e <do_pgfault+0x162>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c0109759:	8b 45 08             	mov    0x8(%ebp),%eax
c010975c:	8b 40 0c             	mov    0xc(%eax),%eax
c010975f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109762:	89 54 24 08          	mov    %edx,0x8(%esp)
c0109766:	8b 55 10             	mov    0x10(%ebp),%edx
c0109769:	89 54 24 04          	mov    %edx,0x4(%esp)
c010976d:	89 04 24             	mov    %eax,(%esp)
c0109770:	e8 7a d5 ff ff       	call   c0106cef <pgdir_alloc_page>
c0109775:	85 c0                	test   %eax,%eax
c0109777:	0f 85 ae 00 00 00    	jne    c010982b <do_pgfault+0x1ff>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c010977d:	c7 04 24 2c d2 10 c0 	movl   $0xc010d22c,(%esp)
c0109784:	e8 4d 80 ff ff       	call   c01017d6 <cprintf>
            goto failed;
c0109789:	e9 a4 00 00 00       	jmp    c0109832 <do_pgfault+0x206>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
c010978e:	a1 cc 9a 12 c0       	mov    0xc0129acc,%eax
c0109793:	85 c0                	test   %eax,%eax
c0109795:	74 7d                	je     c0109814 <do_pgfault+0x1e8>
            struct Page *page=NULL;
c0109797:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c010979e:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01097a1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01097a5:	8b 45 10             	mov    0x10(%ebp),%eax
c01097a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01097ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01097af:	89 04 24             	mov    %eax,(%esp)
c01097b2:	e8 d2 e5 ff ff       	call   c0107d89 <swap_in>
c01097b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01097ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01097be:	74 0e                	je     c01097ce <do_pgfault+0x1a2>
                cprintf("swap_in in do_pgfault failed\n");
c01097c0:	c7 04 24 53 d2 10 c0 	movl   $0xc010d253,(%esp)
c01097c7:	e8 0a 80 ff ff       	call   c01017d6 <cprintf>
c01097cc:	eb 64                	jmp    c0109832 <do_pgfault+0x206>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
c01097ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01097d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01097d4:	8b 40 0c             	mov    0xc(%eax),%eax
c01097d7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01097da:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01097de:	8b 4d 10             	mov    0x10(%ebp),%ecx
c01097e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01097e5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01097e9:	89 04 24             	mov    %eax,(%esp)
c01097ec:	e8 e8 d3 ff ff       	call   c0106bd9 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c01097f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01097f4:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c01097fb:	00 
c01097fc:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109800:	8b 45 10             	mov    0x10(%ebp),%eax
c0109803:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109807:	8b 45 08             	mov    0x8(%ebp),%eax
c010980a:	89 04 24             	mov    %eax,(%esp)
c010980d:	e8 ae e3 ff ff       	call   c0107bc0 <swap_map_swappable>
c0109812:	eb 17                	jmp    c010982b <do_pgfault+0x1ff>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0109814:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109817:	8b 00                	mov    (%eax),%eax
c0109819:	89 44 24 04          	mov    %eax,0x4(%esp)
c010981d:	c7 04 24 74 d2 10 c0 	movl   $0xc010d274,(%esp)
c0109824:	e8 ad 7f ff ff       	call   c01017d6 <cprintf>
            goto failed;
c0109829:	eb 07                	jmp    c0109832 <do_pgfault+0x206>
        }
   }
   ret = 0;
c010982b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0109832:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109835:	c9                   	leave  
c0109836:	c3                   	ret    

c0109837 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0109837:	55                   	push   %ebp
c0109838:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010983a:	8b 55 08             	mov    0x8(%ebp),%edx
c010983d:	a1 2c bb 12 c0       	mov    0xc012bb2c,%eax
c0109842:	29 c2                	sub    %eax,%edx
c0109844:	89 d0                	mov    %edx,%eax
c0109846:	c1 f8 02             	sar    $0x2,%eax
c0109849:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c010984f:	5d                   	pop    %ebp
c0109850:	c3                   	ret    

c0109851 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0109851:	55                   	push   %ebp
c0109852:	89 e5                	mov    %esp,%ebp
c0109854:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0109857:	8b 45 08             	mov    0x8(%ebp),%eax
c010985a:	89 04 24             	mov    %eax,(%esp)
c010985d:	e8 d5 ff ff ff       	call   c0109837 <page2ppn>
c0109862:	c1 e0 0c             	shl    $0xc,%eax
}
c0109865:	c9                   	leave  
c0109866:	c3                   	ret    

c0109867 <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c0109867:	55                   	push   %ebp
c0109868:	89 e5                	mov    %esp,%ebp
c010986a:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010986d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109870:	89 04 24             	mov    %eax,(%esp)
c0109873:	e8 d9 ff ff ff       	call   c0109851 <page2pa>
c0109878:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010987b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010987e:	c1 e8 0c             	shr    $0xc,%eax
c0109881:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109884:	a1 40 9a 12 c0       	mov    0xc0129a40,%eax
c0109889:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010988c:	72 23                	jb     c01098b1 <page2kva+0x4a>
c010988e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109891:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109895:	c7 44 24 08 9c d2 10 	movl   $0xc010d29c,0x8(%esp)
c010989c:	c0 
c010989d:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c01098a4:	00 
c01098a5:	c7 04 24 bf d2 10 c0 	movl   $0xc010d2bf,(%esp)
c01098ac:	e8 af 88 ff ff       	call   c0102160 <__panic>
c01098b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098b4:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01098b9:	c9                   	leave  
c01098ba:	c3                   	ret    

c01098bb <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c01098bb:	55                   	push   %ebp
c01098bc:	89 e5                	mov    %esp,%ebp
c01098be:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c01098c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01098c8:	e8 e3 95 ff ff       	call   c0102eb0 <ide_device_valid>
c01098cd:	85 c0                	test   %eax,%eax
c01098cf:	75 1c                	jne    c01098ed <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c01098d1:	c7 44 24 08 cd d2 10 	movl   $0xc010d2cd,0x8(%esp)
c01098d8:	c0 
c01098d9:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c01098e0:	00 
c01098e1:	c7 04 24 e7 d2 10 c0 	movl   $0xc010d2e7,(%esp)
c01098e8:	e8 73 88 ff ff       	call   c0102160 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c01098ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01098f4:	e8 f6 95 ff ff       	call   c0102eef <ide_device_size>
c01098f9:	c1 e8 03             	shr    $0x3,%eax
c01098fc:	a3 dc bb 12 c0       	mov    %eax,0xc012bbdc
}
c0109901:	c9                   	leave  
c0109902:	c3                   	ret    

c0109903 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0109903:	55                   	push   %ebp
c0109904:	89 e5                	mov    %esp,%ebp
c0109906:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0109909:	8b 45 0c             	mov    0xc(%ebp),%eax
c010990c:	89 04 24             	mov    %eax,(%esp)
c010990f:	e8 53 ff ff ff       	call   c0109867 <page2kva>
c0109914:	8b 55 08             	mov    0x8(%ebp),%edx
c0109917:	c1 ea 08             	shr    $0x8,%edx
c010991a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010991d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109921:	74 0b                	je     c010992e <swapfs_read+0x2b>
c0109923:	8b 15 dc bb 12 c0    	mov    0xc012bbdc,%edx
c0109929:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c010992c:	72 23                	jb     c0109951 <swapfs_read+0x4e>
c010992e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109931:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109935:	c7 44 24 08 f8 d2 10 	movl   $0xc010d2f8,0x8(%esp)
c010993c:	c0 
c010993d:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0109944:	00 
c0109945:	c7 04 24 e7 d2 10 c0 	movl   $0xc010d2e7,(%esp)
c010994c:	e8 0f 88 ff ff       	call   c0102160 <__panic>
c0109951:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109954:	c1 e2 03             	shl    $0x3,%edx
c0109957:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c010995e:	00 
c010995f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109963:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109967:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010996e:	e8 bb 95 ff ff       	call   c0102f2e <ide_read_secs>
}
c0109973:	c9                   	leave  
c0109974:	c3                   	ret    

c0109975 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0109975:	55                   	push   %ebp
c0109976:	89 e5                	mov    %esp,%ebp
c0109978:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010997b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010997e:	89 04 24             	mov    %eax,(%esp)
c0109981:	e8 e1 fe ff ff       	call   c0109867 <page2kva>
c0109986:	8b 55 08             	mov    0x8(%ebp),%edx
c0109989:	c1 ea 08             	shr    $0x8,%edx
c010998c:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010998f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109993:	74 0b                	je     c01099a0 <swapfs_write+0x2b>
c0109995:	8b 15 dc bb 12 c0    	mov    0xc012bbdc,%edx
c010999b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c010999e:	72 23                	jb     c01099c3 <swapfs_write+0x4e>
c01099a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01099a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01099a7:	c7 44 24 08 f8 d2 10 	movl   $0xc010d2f8,0x8(%esp)
c01099ae:	c0 
c01099af:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c01099b6:	00 
c01099b7:	c7 04 24 e7 d2 10 c0 	movl   $0xc010d2e7,(%esp)
c01099be:	e8 9d 87 ff ff       	call   c0102160 <__panic>
c01099c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01099c6:	c1 e2 03             	shl    $0x3,%edx
c01099c9:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01099d0:	00 
c01099d1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01099d5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01099d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01099e0:	e8 8b 97 ff ff       	call   c0103170 <ide_write_secs>
}
c01099e5:	c9                   	leave  
c01099e6:	c3                   	ret    

c01099e7 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c01099e7:	52                   	push   %edx
    call *%ebx              # call fn
c01099e8:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c01099ea:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c01099eb:	e8 4b 08 00 00       	call   c010a23b <do_exit>

c01099f0 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c01099f0:	55                   	push   %ebp
c01099f1:	89 e5                	mov    %esp,%ebp
c01099f3:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01099f6:	9c                   	pushf  
c01099f7:	58                   	pop    %eax
c01099f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01099fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01099fe:	25 00 02 00 00       	and    $0x200,%eax
c0109a03:	85 c0                	test   %eax,%eax
c0109a05:	74 0c                	je     c0109a13 <__intr_save+0x23>
        intr_disable();
c0109a07:	e8 ac 99 ff ff       	call   c01033b8 <intr_disable>
        return 1;
c0109a0c:	b8 01 00 00 00       	mov    $0x1,%eax
c0109a11:	eb 05                	jmp    c0109a18 <__intr_save+0x28>
    }
    return 0;
c0109a13:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109a18:	c9                   	leave  
c0109a19:	c3                   	ret    

c0109a1a <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0109a1a:	55                   	push   %ebp
c0109a1b:	89 e5                	mov    %esp,%ebp
c0109a1d:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109a20:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109a24:	74 05                	je     c0109a2b <__intr_restore+0x11>
        intr_enable();
c0109a26:	e8 87 99 ff ff       	call   c01033b2 <intr_enable>
    }
}
c0109a2b:	c9                   	leave  
c0109a2c:	c3                   	ret    

c0109a2d <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0109a2d:	55                   	push   %ebp
c0109a2e:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0109a30:	8b 55 08             	mov    0x8(%ebp),%edx
c0109a33:	a1 2c bb 12 c0       	mov    0xc012bb2c,%eax
c0109a38:	29 c2                	sub    %eax,%edx
c0109a3a:	89 d0                	mov    %edx,%eax
c0109a3c:	c1 f8 02             	sar    $0x2,%eax
c0109a3f:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0109a45:	5d                   	pop    %ebp
c0109a46:	c3                   	ret    

c0109a47 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0109a47:	55                   	push   %ebp
c0109a48:	89 e5                	mov    %esp,%ebp
c0109a4a:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0109a4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a50:	89 04 24             	mov    %eax,(%esp)
c0109a53:	e8 d5 ff ff ff       	call   c0109a2d <page2ppn>
c0109a58:	c1 e0 0c             	shl    $0xc,%eax
}
c0109a5b:	c9                   	leave  
c0109a5c:	c3                   	ret    

c0109a5d <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0109a5d:	55                   	push   %ebp
c0109a5e:	89 e5                	mov    %esp,%ebp
c0109a60:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0109a63:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a66:	c1 e8 0c             	shr    $0xc,%eax
c0109a69:	89 c2                	mov    %eax,%edx
c0109a6b:	a1 40 9a 12 c0       	mov    0xc0129a40,%eax
c0109a70:	39 c2                	cmp    %eax,%edx
c0109a72:	72 1c                	jb     c0109a90 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0109a74:	c7 44 24 08 18 d3 10 	movl   $0xc010d318,0x8(%esp)
c0109a7b:	c0 
c0109a7c:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0109a83:	00 
c0109a84:	c7 04 24 37 d3 10 c0 	movl   $0xc010d337,(%esp)
c0109a8b:	e8 d0 86 ff ff       	call   c0102160 <__panic>
    }
    return &pages[PPN(pa)];
c0109a90:	8b 0d 2c bb 12 c0    	mov    0xc012bb2c,%ecx
c0109a96:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a99:	c1 e8 0c             	shr    $0xc,%eax
c0109a9c:	89 c2                	mov    %eax,%edx
c0109a9e:	89 d0                	mov    %edx,%eax
c0109aa0:	c1 e0 03             	shl    $0x3,%eax
c0109aa3:	01 d0                	add    %edx,%eax
c0109aa5:	c1 e0 02             	shl    $0x2,%eax
c0109aa8:	01 c8                	add    %ecx,%eax
}
c0109aaa:	c9                   	leave  
c0109aab:	c3                   	ret    

c0109aac <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0109aac:	55                   	push   %ebp
c0109aad:	89 e5                	mov    %esp,%ebp
c0109aaf:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0109ab2:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ab5:	89 04 24             	mov    %eax,(%esp)
c0109ab8:	e8 8a ff ff ff       	call   c0109a47 <page2pa>
c0109abd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ac3:	c1 e8 0c             	shr    $0xc,%eax
c0109ac6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109ac9:	a1 40 9a 12 c0       	mov    0xc0129a40,%eax
c0109ace:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109ad1:	72 23                	jb     c0109af6 <page2kva+0x4a>
c0109ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ad6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109ada:	c7 44 24 08 48 d3 10 	movl   $0xc010d348,0x8(%esp)
c0109ae1:	c0 
c0109ae2:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0109ae9:	00 
c0109aea:	c7 04 24 37 d3 10 c0 	movl   $0xc010d337,(%esp)
c0109af1:	e8 6a 86 ff ff       	call   c0102160 <__panic>
c0109af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109af9:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0109afe:	c9                   	leave  
c0109aff:	c3                   	ret    

c0109b00 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0109b00:	55                   	push   %ebp
c0109b01:	89 e5                	mov    %esp,%ebp
c0109b03:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0109b06:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b09:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109b0c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0109b13:	77 23                	ja     c0109b38 <kva2page+0x38>
c0109b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b18:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109b1c:	c7 44 24 08 6c d3 10 	movl   $0xc010d36c,0x8(%esp)
c0109b23:	c0 
c0109b24:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0109b2b:	00 
c0109b2c:	c7 04 24 37 d3 10 c0 	movl   $0xc010d337,(%esp)
c0109b33:	e8 28 86 ff ff       	call   c0102160 <__panic>
c0109b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b3b:	05 00 00 00 40       	add    $0x40000000,%eax
c0109b40:	89 04 24             	mov    %eax,(%esp)
c0109b43:	e8 15 ff ff ff       	call   c0109a5d <pa2page>
}
c0109b48:	c9                   	leave  
c0109b49:	c3                   	ret    

c0109b4a <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c0109b4a:	55                   	push   %ebp
c0109b4b:	89 e5                	mov    %esp,%ebp
c0109b4d:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c0109b50:	c7 04 24 68 00 00 00 	movl   $0x68,(%esp)
c0109b57:	e8 63 c2 ff ff       	call   c0105dbf <kmalloc>
c0109b5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c0109b5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109b63:	0f 84 a1 00 00 00    	je     c0109c0a <alloc_proc+0xc0>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
c0109b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b6c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c0109b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b75:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;
c0109b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b7f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0;
c0109b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b89:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;
c0109b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b93:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;
c0109b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b9d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;
c0109ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ba7:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));
c0109bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bb1:	83 c0 1c             	add    $0x1c,%eax
c0109bb4:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c0109bbb:	00 
c0109bbc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109bc3:	00 
c0109bc4:	89 04 24             	mov    %eax,(%esp)
c0109bc7:	e8 f1 14 00 00       	call   c010b0bd <memset>
        proc->tf = NULL;
c0109bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bcf:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;
c0109bd6:	8b 15 28 bb 12 c0    	mov    0xc012bb28,%edx
c0109bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bdf:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;
c0109be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109be5:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);
c0109bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bef:	83 c0 48             	add    $0x48,%eax
c0109bf2:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0109bf9:	00 
c0109bfa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109c01:	00 
c0109c02:	89 04 24             	mov    %eax,(%esp)
c0109c05:	e8 b3 14 00 00       	call   c010b0bd <memset>
    }
    return proc;
c0109c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109c0d:	c9                   	leave  
c0109c0e:	c3                   	ret    

c0109c0f <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c0109c0f:	55                   	push   %ebp
c0109c10:	89 e5                	mov    %esp,%ebp
c0109c12:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c0109c15:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c18:	83 c0 48             	add    $0x48,%eax
c0109c1b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0109c22:	00 
c0109c23:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109c2a:	00 
c0109c2b:	89 04 24             	mov    %eax,(%esp)
c0109c2e:	e8 8a 14 00 00       	call   c010b0bd <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c0109c33:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c36:	8d 50 48             	lea    0x48(%eax),%edx
c0109c39:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0109c40:	00 
c0109c41:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c44:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109c48:	89 14 24             	mov    %edx,(%esp)
c0109c4b:	e8 4f 15 00 00       	call   c010b19f <memcpy>
}
c0109c50:	c9                   	leave  
c0109c51:	c3                   	ret    

c0109c52 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c0109c52:	55                   	push   %ebp
c0109c53:	89 e5                	mov    %esp,%ebp
c0109c55:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0109c58:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0109c5f:	00 
c0109c60:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109c67:	00 
c0109c68:	c7 04 24 04 bb 12 c0 	movl   $0xc012bb04,(%esp)
c0109c6f:	e8 49 14 00 00       	call   c010b0bd <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0109c74:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c77:	83 c0 48             	add    $0x48,%eax
c0109c7a:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0109c81:	00 
c0109c82:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109c86:	c7 04 24 04 bb 12 c0 	movl   $0xc012bb04,(%esp)
c0109c8d:	e8 0d 15 00 00       	call   c010b19f <memcpy>
}
c0109c92:	c9                   	leave  
c0109c93:	c3                   	ret    

c0109c94 <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c0109c94:	55                   	push   %ebp
c0109c95:	89 e5                	mov    %esp,%ebp
c0109c97:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c0109c9a:	c7 45 f8 10 bc 12 c0 	movl   $0xc012bc10,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c0109ca1:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0109ca6:	83 c0 01             	add    $0x1,%eax
c0109ca9:	a3 80 8a 12 c0       	mov    %eax,0xc0128a80
c0109cae:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0109cb3:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109cb8:	7e 0c                	jle    c0109cc6 <get_pid+0x32>
        last_pid = 1;
c0109cba:	c7 05 80 8a 12 c0 01 	movl   $0x1,0xc0128a80
c0109cc1:	00 00 00 
        goto inside;
c0109cc4:	eb 13                	jmp    c0109cd9 <get_pid+0x45>
    }
    if (last_pid >= next_safe) {
c0109cc6:	8b 15 80 8a 12 c0    	mov    0xc0128a80,%edx
c0109ccc:	a1 84 8a 12 c0       	mov    0xc0128a84,%eax
c0109cd1:	39 c2                	cmp    %eax,%edx
c0109cd3:	0f 8c ac 00 00 00    	jl     c0109d85 <get_pid+0xf1>
    inside:
        next_safe = MAX_PID;
c0109cd9:	c7 05 84 8a 12 c0 00 	movl   $0x2000,0xc0128a84
c0109ce0:	20 00 00 
    repeat:
        le = list;
c0109ce3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109ce6:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c0109ce9:	eb 7f                	jmp    c0109d6a <get_pid+0xd6>
            proc = le2proc(le, list_link);
c0109ceb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109cee:	83 e8 58             	sub    $0x58,%eax
c0109cf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c0109cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cf7:	8b 50 04             	mov    0x4(%eax),%edx
c0109cfa:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0109cff:	39 c2                	cmp    %eax,%edx
c0109d01:	75 3e                	jne    c0109d41 <get_pid+0xad>
                if (++ last_pid >= next_safe) {
c0109d03:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0109d08:	83 c0 01             	add    $0x1,%eax
c0109d0b:	a3 80 8a 12 c0       	mov    %eax,0xc0128a80
c0109d10:	8b 15 80 8a 12 c0    	mov    0xc0128a80,%edx
c0109d16:	a1 84 8a 12 c0       	mov    0xc0128a84,%eax
c0109d1b:	39 c2                	cmp    %eax,%edx
c0109d1d:	7c 4b                	jl     c0109d6a <get_pid+0xd6>
                    if (last_pid >= MAX_PID) {
c0109d1f:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0109d24:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109d29:	7e 0a                	jle    c0109d35 <get_pid+0xa1>
                        last_pid = 1;
c0109d2b:	c7 05 80 8a 12 c0 01 	movl   $0x1,0xc0128a80
c0109d32:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0109d35:	c7 05 84 8a 12 c0 00 	movl   $0x2000,0xc0128a84
c0109d3c:	20 00 00 
                    goto repeat;
c0109d3f:	eb a2                	jmp    c0109ce3 <get_pid+0x4f>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c0109d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d44:	8b 50 04             	mov    0x4(%eax),%edx
c0109d47:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0109d4c:	39 c2                	cmp    %eax,%edx
c0109d4e:	7e 1a                	jle    c0109d6a <get_pid+0xd6>
c0109d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d53:	8b 50 04             	mov    0x4(%eax),%edx
c0109d56:	a1 84 8a 12 c0       	mov    0xc0128a84,%eax
c0109d5b:	39 c2                	cmp    %eax,%edx
c0109d5d:	7d 0b                	jge    c0109d6a <get_pid+0xd6>
                next_safe = proc->pid;
c0109d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d62:	8b 40 04             	mov    0x4(%eax),%eax
c0109d65:	a3 84 8a 12 c0       	mov    %eax,0xc0128a84
c0109d6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109d6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109d73:	8b 40 04             	mov    0x4(%eax),%eax
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
c0109d76:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0109d79:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109d7c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0109d7f:	0f 85 66 ff ff ff    	jne    c0109ceb <get_pid+0x57>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
c0109d85:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
}
c0109d8a:	c9                   	leave  
c0109d8b:	c3                   	ret    

c0109d8c <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c0109d8c:	55                   	push   %ebp
c0109d8d:	89 e5                	mov    %esp,%ebp
c0109d8f:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c0109d92:	a1 e8 9a 12 c0       	mov    0xc0129ae8,%eax
c0109d97:	39 45 08             	cmp    %eax,0x8(%ebp)
c0109d9a:	74 63                	je     c0109dff <proc_run+0x73>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0109d9c:	a1 e8 9a 12 c0       	mov    0xc0129ae8,%eax
c0109da1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109da4:	8b 45 08             	mov    0x8(%ebp),%eax
c0109da7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c0109daa:	e8 41 fc ff ff       	call   c01099f0 <__intr_save>
c0109daf:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0109db2:	8b 45 08             	mov    0x8(%ebp),%eax
c0109db5:	a3 e8 9a 12 c0       	mov    %eax,0xc0129ae8
            load_esp0(next->kstack + KSTACKSIZE);
c0109dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109dbd:	8b 40 0c             	mov    0xc(%eax),%eax
c0109dc0:	05 00 20 00 00       	add    $0x2000,%eax
c0109dc5:	89 04 24             	mov    %eax,(%esp)
c0109dc8:	e8 11 c3 ff ff       	call   c01060de <load_esp0>
            lcr3(next->cr3);
c0109dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109dd0:	8b 40 40             	mov    0x40(%eax),%eax
c0109dd3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0109dd6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109dd9:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c0109ddc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ddf:	8d 50 1c             	lea    0x1c(%eax),%edx
c0109de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109de5:	83 c0 1c             	add    $0x1c,%eax
c0109de8:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109dec:	89 04 24             	mov    %eax,(%esp)
c0109def:	e8 99 06 00 00       	call   c010a48d <switch_to>
        }
        local_intr_restore(intr_flag);
c0109df4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109df7:	89 04 24             	mov    %eax,(%esp)
c0109dfa:	e8 1b fc ff ff       	call   c0109a1a <__intr_restore>
    }
}
c0109dff:	c9                   	leave  
c0109e00:	c3                   	ret    

c0109e01 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c0109e01:	55                   	push   %ebp
c0109e02:	89 e5                	mov    %esp,%ebp
c0109e04:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0109e07:	a1 e8 9a 12 c0       	mov    0xc0129ae8,%eax
c0109e0c:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109e0f:	89 04 24             	mov    %eax,(%esp)
c0109e12:	e8 eb 9d ff ff       	call   c0103c02 <forkrets>
}
c0109e17:	c9                   	leave  
c0109e18:	c3                   	ret    

c0109e19 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c0109e19:	55                   	push   %ebp
c0109e1a:	89 e5                	mov    %esp,%ebp
c0109e1c:	53                   	push   %ebx
c0109e1d:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0109e20:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e23:	8d 58 60             	lea    0x60(%eax),%ebx
c0109e26:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e29:	8b 40 04             	mov    0x4(%eax),%eax
c0109e2c:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109e33:	00 
c0109e34:	89 04 24             	mov    %eax,(%esp)
c0109e37:	e8 d4 07 00 00       	call   c010a610 <hash32>
c0109e3c:	c1 e0 03             	shl    $0x3,%eax
c0109e3f:	05 00 9b 12 c0       	add    $0xc0129b00,%eax
c0109e44:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109e47:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0109e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e53:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0109e56:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109e59:	8b 40 04             	mov    0x4(%eax),%eax
c0109e5c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109e5f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109e62:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109e65:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0109e68:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0109e6b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109e6e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109e71:	89 10                	mov    %edx,(%eax)
c0109e73:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109e76:	8b 10                	mov    (%eax),%edx
c0109e78:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109e7b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109e7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109e81:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109e84:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109e87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109e8a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109e8d:	89 10                	mov    %edx,(%eax)
}
c0109e8f:	83 c4 34             	add    $0x34,%esp
c0109e92:	5b                   	pop    %ebx
c0109e93:	5d                   	pop    %ebp
c0109e94:	c3                   	ret    

c0109e95 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0109e95:	55                   	push   %ebp
c0109e96:	89 e5                	mov    %esp,%ebp
c0109e98:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0109e9b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109e9f:	7e 5f                	jle    c0109f00 <find_proc+0x6b>
c0109ea1:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0109ea8:	7f 56                	jg     c0109f00 <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0109eaa:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ead:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109eb4:	00 
c0109eb5:	89 04 24             	mov    %eax,(%esp)
c0109eb8:	e8 53 07 00 00       	call   c010a610 <hash32>
c0109ebd:	c1 e0 03             	shl    $0x3,%eax
c0109ec0:	05 00 9b 12 c0       	add    $0xc0129b00,%eax
c0109ec5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ecb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0109ece:	eb 19                	jmp    c0109ee9 <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c0109ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ed3:	83 e8 60             	sub    $0x60,%eax
c0109ed6:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0109ed9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109edc:	8b 40 04             	mov    0x4(%eax),%eax
c0109edf:	3b 45 08             	cmp    0x8(%ebp),%eax
c0109ee2:	75 05                	jne    c0109ee9 <find_proc+0x54>
                return proc;
c0109ee4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109ee7:	eb 1c                	jmp    c0109f05 <find_proc+0x70>
c0109ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109eec:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0109eef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109ef2:	8b 40 04             	mov    0x4(%eax),%eax
// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
c0109ef5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109efb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0109efe:	75 d0                	jne    c0109ed0 <find_proc+0x3b>
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
c0109f00:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109f05:	c9                   	leave  
c0109f06:	c3                   	ret    

c0109f07 <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0109f07:	55                   	push   %ebp
c0109f08:	89 e5                	mov    %esp,%ebp
c0109f0a:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0109f0d:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0109f14:	00 
c0109f15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109f1c:	00 
c0109f1d:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109f20:	89 04 24             	mov    %eax,(%esp)
c0109f23:	e8 95 11 00 00       	call   c010b0bd <memset>
    tf.tf_cs = KERNEL_CS;
c0109f28:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0109f2e:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0109f34:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0109f38:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0109f3c:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0109f40:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0109f44:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f47:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0109f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109f4d:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0109f50:	b8 e7 99 10 c0       	mov    $0xc01099e7,%eax
c0109f55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0109f58:	8b 45 10             	mov    0x10(%ebp),%eax
c0109f5b:	80 cc 01             	or     $0x1,%ah
c0109f5e:	89 c2                	mov    %eax,%edx
c0109f60:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109f63:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109f67:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109f6e:	00 
c0109f6f:	89 14 24             	mov    %edx,(%esp)
c0109f72:	e8 79 01 00 00       	call   c010a0f0 <do_fork>
}
c0109f77:	c9                   	leave  
c0109f78:	c3                   	ret    

c0109f79 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0109f79:	55                   	push   %ebp
c0109f7a:	89 e5                	mov    %esp,%ebp
c0109f7c:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0109f7f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0109f86:	e8 a1 c2 ff ff       	call   c010622c <alloc_pages>
c0109f8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0109f8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109f92:	74 1a                	je     c0109fae <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0109f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f97:	89 04 24             	mov    %eax,(%esp)
c0109f9a:	e8 0d fb ff ff       	call   c0109aac <page2kva>
c0109f9f:	89 c2                	mov    %eax,%edx
c0109fa1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fa4:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0109fa7:	b8 00 00 00 00       	mov    $0x0,%eax
c0109fac:	eb 05                	jmp    c0109fb3 <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0109fae:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109fb3:	c9                   	leave  
c0109fb4:	c3                   	ret    

c0109fb5 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0109fb5:	55                   	push   %ebp
c0109fb6:	89 e5                	mov    %esp,%ebp
c0109fb8:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0109fbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fbe:	8b 40 0c             	mov    0xc(%eax),%eax
c0109fc1:	89 04 24             	mov    %eax,(%esp)
c0109fc4:	e8 37 fb ff ff       	call   c0109b00 <kva2page>
c0109fc9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0109fd0:	00 
c0109fd1:	89 04 24             	mov    %eax,(%esp)
c0109fd4:	e8 be c2 ff ff       	call   c0106297 <free_pages>
}
c0109fd9:	c9                   	leave  
c0109fda:	c3                   	ret    

c0109fdb <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0109fdb:	55                   	push   %ebp
c0109fdc:	89 e5                	mov    %esp,%ebp
c0109fde:	83 ec 18             	sub    $0x18,%esp
    assert(current->mm == NULL);
c0109fe1:	a1 e8 9a 12 c0       	mov    0xc0129ae8,%eax
c0109fe6:	8b 40 18             	mov    0x18(%eax),%eax
c0109fe9:	85 c0                	test   %eax,%eax
c0109feb:	74 24                	je     c010a011 <copy_mm+0x36>
c0109fed:	c7 44 24 0c 90 d3 10 	movl   $0xc010d390,0xc(%esp)
c0109ff4:	c0 
c0109ff5:	c7 44 24 08 a4 d3 10 	movl   $0xc010d3a4,0x8(%esp)
c0109ffc:	c0 
c0109ffd:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c010a004:	00 
c010a005:	c7 04 24 b9 d3 10 c0 	movl   $0xc010d3b9,(%esp)
c010a00c:	e8 4f 81 ff ff       	call   c0102160 <__panic>
    /* do nothing in this project */
    return 0;
c010a011:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a016:	c9                   	leave  
c010a017:	c3                   	ret    

c010a018 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c010a018:	55                   	push   %ebp
c010a019:	89 e5                	mov    %esp,%ebp
c010a01b:	57                   	push   %edi
c010a01c:	56                   	push   %esi
c010a01d:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c010a01e:	8b 45 08             	mov    0x8(%ebp),%eax
c010a021:	8b 40 0c             	mov    0xc(%eax),%eax
c010a024:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c010a029:	89 c2                	mov    %eax,%edx
c010a02b:	8b 45 08             	mov    0x8(%ebp),%eax
c010a02e:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c010a031:	8b 45 08             	mov    0x8(%ebp),%eax
c010a034:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a037:	8b 55 10             	mov    0x10(%ebp),%edx
c010a03a:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c010a03f:	89 c1                	mov    %eax,%ecx
c010a041:	83 e1 01             	and    $0x1,%ecx
c010a044:	85 c9                	test   %ecx,%ecx
c010a046:	74 0e                	je     c010a056 <copy_thread+0x3e>
c010a048:	0f b6 0a             	movzbl (%edx),%ecx
c010a04b:	88 08                	mov    %cl,(%eax)
c010a04d:	83 c0 01             	add    $0x1,%eax
c010a050:	83 c2 01             	add    $0x1,%edx
c010a053:	83 eb 01             	sub    $0x1,%ebx
c010a056:	89 c1                	mov    %eax,%ecx
c010a058:	83 e1 02             	and    $0x2,%ecx
c010a05b:	85 c9                	test   %ecx,%ecx
c010a05d:	74 0f                	je     c010a06e <copy_thread+0x56>
c010a05f:	0f b7 0a             	movzwl (%edx),%ecx
c010a062:	66 89 08             	mov    %cx,(%eax)
c010a065:	83 c0 02             	add    $0x2,%eax
c010a068:	83 c2 02             	add    $0x2,%edx
c010a06b:	83 eb 02             	sub    $0x2,%ebx
c010a06e:	89 d9                	mov    %ebx,%ecx
c010a070:	c1 e9 02             	shr    $0x2,%ecx
c010a073:	89 c7                	mov    %eax,%edi
c010a075:	89 d6                	mov    %edx,%esi
c010a077:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010a079:	89 f2                	mov    %esi,%edx
c010a07b:	89 f8                	mov    %edi,%eax
c010a07d:	b9 00 00 00 00       	mov    $0x0,%ecx
c010a082:	89 de                	mov    %ebx,%esi
c010a084:	83 e6 02             	and    $0x2,%esi
c010a087:	85 f6                	test   %esi,%esi
c010a089:	74 0b                	je     c010a096 <copy_thread+0x7e>
c010a08b:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c010a08f:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c010a093:	83 c1 02             	add    $0x2,%ecx
c010a096:	83 e3 01             	and    $0x1,%ebx
c010a099:	85 db                	test   %ebx,%ebx
c010a09b:	74 07                	je     c010a0a4 <copy_thread+0x8c>
c010a09d:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c010a0a1:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c010a0a4:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0a7:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a0aa:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c010a0b1:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0b4:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a0b7:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a0ba:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c010a0bd:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0c0:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a0c3:	8b 55 08             	mov    0x8(%ebp),%edx
c010a0c6:	8b 52 3c             	mov    0x3c(%edx),%edx
c010a0c9:	8b 52 40             	mov    0x40(%edx),%edx
c010a0cc:	80 ce 02             	or     $0x2,%dh
c010a0cf:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c010a0d2:	ba 01 9e 10 c0       	mov    $0xc0109e01,%edx
c010a0d7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0da:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c010a0dd:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0e0:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a0e3:	89 c2                	mov    %eax,%edx
c010a0e5:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0e8:	89 50 20             	mov    %edx,0x20(%eax)
}
c010a0eb:	5b                   	pop    %ebx
c010a0ec:	5e                   	pop    %esi
c010a0ed:	5f                   	pop    %edi
c010a0ee:	5d                   	pop    %ebp
c010a0ef:	c3                   	ret    

c010a0f0 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c010a0f0:	55                   	push   %ebp
c010a0f1:	89 e5                	mov    %esp,%ebp
c010a0f3:	83 ec 48             	sub    $0x48,%esp
    int ret = -E_NO_FREE_PROC;
c010a0f6:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c010a0fd:	a1 00 bb 12 c0       	mov    0xc012bb00,%eax
c010a102:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c010a107:	7e 05                	jle    c010a10e <do_fork+0x1e>
        goto fork_out;
c010a109:	e9 19 01 00 00       	jmp    c010a227 <do_fork+0x137>
    }
    ret = -E_NO_MEM;
c010a10e:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if ((proc = alloc_proc()) == NULL) {
c010a115:	e8 30 fa ff ff       	call   c0109b4a <alloc_proc>
c010a11a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a11d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a121:	75 05                	jne    c010a128 <do_fork+0x38>
        goto fork_out;
c010a123:	e9 ff 00 00 00       	jmp    c010a227 <do_fork+0x137>
    }

    proc->parent = current;
c010a128:	8b 15 e8 9a 12 c0    	mov    0xc0129ae8,%edx
c010a12e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a131:	89 50 14             	mov    %edx,0x14(%eax)

    if (setup_kstack(proc) != 0) {
c010a134:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a137:	89 04 24             	mov    %eax,(%esp)
c010a13a:	e8 3a fe ff ff       	call   c0109f79 <setup_kstack>
c010a13f:	85 c0                	test   %eax,%eax
c010a141:	74 05                	je     c010a148 <do_fork+0x58>
        goto bad_fork_cleanup_proc;
c010a143:	e9 e4 00 00 00       	jmp    c010a22c <do_fork+0x13c>
    }
    if (copy_mm(clone_flags, proc) != 0) {
c010a148:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a14b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a14f:	8b 45 08             	mov    0x8(%ebp),%eax
c010a152:	89 04 24             	mov    %eax,(%esp)
c010a155:	e8 81 fe ff ff       	call   c0109fdb <copy_mm>
c010a15a:	85 c0                	test   %eax,%eax
c010a15c:	74 11                	je     c010a16f <do_fork+0x7f>
        goto bad_fork_cleanup_kstack;
c010a15e:	90                   	nop
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c010a15f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a162:	89 04 24             	mov    %eax,(%esp)
c010a165:	e8 4b fe ff ff       	call   c0109fb5 <put_kstack>
c010a16a:	e9 bd 00 00 00       	jmp    c010a22c <do_fork+0x13c>
        goto bad_fork_cleanup_proc;
    }
    if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }
    copy_thread(proc, stack, tf);
c010a16f:	8b 45 10             	mov    0x10(%ebp),%eax
c010a172:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a176:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a179:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a17d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a180:	89 04 24             	mov    %eax,(%esp)
c010a183:	e8 90 fe ff ff       	call   c010a018 <copy_thread>

    bool intr_flag;
    local_intr_save(intr_flag);
c010a188:	e8 63 f8 ff ff       	call   c01099f0 <__intr_save>
c010a18d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        proc->pid = get_pid();
c010a190:	e8 ff fa ff ff       	call   c0109c94 <get_pid>
c010a195:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010a198:	89 42 04             	mov    %eax,0x4(%edx)
        hash_proc(proc);
c010a19b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a19e:	89 04 24             	mov    %eax,(%esp)
c010a1a1:	e8 73 fc ff ff       	call   c0109e19 <hash_proc>
        list_add(&proc_list, &(proc->list_link));
c010a1a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a1a9:	83 c0 58             	add    $0x58,%eax
c010a1ac:	c7 45 e8 10 bc 12 c0 	movl   $0xc012bc10,-0x18(%ebp)
c010a1b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010a1b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a1b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a1bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a1bf:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010a1c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a1c5:	8b 40 04             	mov    0x4(%eax),%eax
c010a1c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010a1cb:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010a1ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010a1d1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010a1d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010a1d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a1da:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a1dd:	89 10                	mov    %edx,(%eax)
c010a1df:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a1e2:	8b 10                	mov    (%eax),%edx
c010a1e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a1e7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010a1ea:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a1ed:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a1f0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010a1f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a1f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a1f9:	89 10                	mov    %edx,(%eax)
        nr_process ++;
c010a1fb:	a1 00 bb 12 c0       	mov    0xc012bb00,%eax
c010a200:	83 c0 01             	add    $0x1,%eax
c010a203:	a3 00 bb 12 c0       	mov    %eax,0xc012bb00
    }
    local_intr_restore(intr_flag);
c010a208:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a20b:	89 04 24             	mov    %eax,(%esp)
c010a20e:	e8 07 f8 ff ff       	call   c0109a1a <__intr_restore>

    wakeup_proc(proc);
c010a213:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a216:	89 04 24             	mov    %eax,(%esp)
c010a219:	e8 e3 02 00 00       	call   c010a501 <wakeup_proc>

    ret = proc->pid;
c010a21e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a221:	8b 40 04             	mov    0x4(%eax),%eax
c010a224:	89 45 f4             	mov    %eax,-0xc(%ebp)
fork_out:
    return ret;
c010a227:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a22a:	eb 0d                	jmp    c010a239 <do_fork+0x149>

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
c010a22c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a22f:	89 04 24             	mov    %eax,(%esp)
c010a232:	e8 a3 bb ff ff       	call   c0105dda <kfree>
    goto fork_out;
c010a237:	eb ee                	jmp    c010a227 <do_fork+0x137>
}
c010a239:	c9                   	leave  
c010a23a:	c3                   	ret    

c010a23b <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c010a23b:	55                   	push   %ebp
c010a23c:	89 e5                	mov    %esp,%ebp
c010a23e:	83 ec 18             	sub    $0x18,%esp
    panic("process exit!!.\n");
c010a241:	c7 44 24 08 cd d3 10 	movl   $0xc010d3cd,0x8(%esp)
c010a248:	c0 
c010a249:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
c010a250:	00 
c010a251:	c7 04 24 b9 d3 10 c0 	movl   $0xc010d3b9,(%esp)
c010a258:	e8 03 7f ff ff       	call   c0102160 <__panic>

c010a25d <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c010a25d:	55                   	push   %ebp
c010a25e:	89 e5                	mov    %esp,%ebp
c010a260:	83 ec 18             	sub    $0x18,%esp
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
c010a263:	a1 e8 9a 12 c0       	mov    0xc0129ae8,%eax
c010a268:	89 04 24             	mov    %eax,(%esp)
c010a26b:	e8 e2 f9 ff ff       	call   c0109c52 <get_proc_name>
c010a270:	8b 15 e8 9a 12 c0    	mov    0xc0129ae8,%edx
c010a276:	8b 52 04             	mov    0x4(%edx),%edx
c010a279:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a27d:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a281:	c7 04 24 e0 d3 10 c0 	movl   $0xc010d3e0,(%esp)
c010a288:	e8 49 75 ff ff       	call   c01017d6 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
c010a28d:	8b 45 08             	mov    0x8(%ebp),%eax
c010a290:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a294:	c7 04 24 06 d4 10 c0 	movl   $0xc010d406,(%esp)
c010a29b:	e8 36 75 ff ff       	call   c01017d6 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
c010a2a0:	c7 04 24 13 d4 10 c0 	movl   $0xc010d413,(%esp)
c010a2a7:	e8 2a 75 ff ff       	call   c01017d6 <cprintf>
    return 0;
c010a2ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a2b1:	c9                   	leave  
c010a2b2:	c3                   	ret    

c010a2b3 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c010a2b3:	55                   	push   %ebp
c010a2b4:	89 e5                	mov    %esp,%ebp
c010a2b6:	83 ec 28             	sub    $0x28,%esp
c010a2b9:	c7 45 ec 10 bc 12 c0 	movl   $0xc012bc10,-0x14(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010a2c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2c3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a2c6:	89 50 04             	mov    %edx,0x4(%eax)
c010a2c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2cc:	8b 50 04             	mov    0x4(%eax),%edx
c010a2cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2d2:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010a2d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010a2db:	eb 26                	jmp    c010a303 <proc_init+0x50>
        list_init(hash_list + i);
c010a2dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a2e0:	c1 e0 03             	shl    $0x3,%eax
c010a2e3:	05 00 9b 12 c0       	add    $0xc0129b00,%eax
c010a2e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a2eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a2ee:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010a2f1:	89 50 04             	mov    %edx,0x4(%eax)
c010a2f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a2f7:	8b 50 04             	mov    0x4(%eax),%edx
c010a2fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a2fd:	89 10                	mov    %edx,(%eax)
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010a2ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010a303:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010a30a:	7e d1                	jle    c010a2dd <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
c010a30c:	e8 39 f8 ff ff       	call   c0109b4a <alloc_proc>
c010a311:	a3 e0 9a 12 c0       	mov    %eax,0xc0129ae0
c010a316:	a1 e0 9a 12 c0       	mov    0xc0129ae0,%eax
c010a31b:	85 c0                	test   %eax,%eax
c010a31d:	75 1c                	jne    c010a33b <proc_init+0x88>
        panic("cannot alloc idleproc.\n");
c010a31f:	c7 44 24 08 2f d4 10 	movl   $0xc010d42f,0x8(%esp)
c010a326:	c0 
c010a327:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
c010a32e:	00 
c010a32f:	c7 04 24 b9 d3 10 c0 	movl   $0xc010d3b9,(%esp)
c010a336:	e8 25 7e ff ff       	call   c0102160 <__panic>
    }

    idleproc->pid = 0;
c010a33b:	a1 e0 9a 12 c0       	mov    0xc0129ae0,%eax
c010a340:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c010a347:	a1 e0 9a 12 c0       	mov    0xc0129ae0,%eax
c010a34c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010a352:	a1 e0 9a 12 c0       	mov    0xc0129ae0,%eax
c010a357:	ba 00 60 12 c0       	mov    $0xc0126000,%edx
c010a35c:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010a35f:	a1 e0 9a 12 c0       	mov    0xc0129ae0,%eax
c010a364:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010a36b:	a1 e0 9a 12 c0       	mov    0xc0129ae0,%eax
c010a370:	c7 44 24 04 47 d4 10 	movl   $0xc010d447,0x4(%esp)
c010a377:	c0 
c010a378:	89 04 24             	mov    %eax,(%esp)
c010a37b:	e8 8f f8 ff ff       	call   c0109c0f <set_proc_name>
    nr_process ++;
c010a380:	a1 00 bb 12 c0       	mov    0xc012bb00,%eax
c010a385:	83 c0 01             	add    $0x1,%eax
c010a388:	a3 00 bb 12 c0       	mov    %eax,0xc012bb00

    current = idleproc;
c010a38d:	a1 e0 9a 12 c0       	mov    0xc0129ae0,%eax
c010a392:	a3 e8 9a 12 c0       	mov    %eax,0xc0129ae8

    int pid = kernel_thread(init_main, "Hello world!!", 0);
c010a397:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010a39e:	00 
c010a39f:	c7 44 24 04 4c d4 10 	movl   $0xc010d44c,0x4(%esp)
c010a3a6:	c0 
c010a3a7:	c7 04 24 5d a2 10 c0 	movl   $0xc010a25d,(%esp)
c010a3ae:	e8 54 fb ff ff       	call   c0109f07 <kernel_thread>
c010a3b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c010a3b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a3ba:	7f 1c                	jg     c010a3d8 <proc_init+0x125>
        panic("create init_main failed.\n");
c010a3bc:	c7 44 24 08 5a d4 10 	movl   $0xc010d45a,0x8(%esp)
c010a3c3:	c0 
c010a3c4:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
c010a3cb:	00 
c010a3cc:	c7 04 24 b9 d3 10 c0 	movl   $0xc010d3b9,(%esp)
c010a3d3:	e8 88 7d ff ff       	call   c0102160 <__panic>
    }

    initproc = find_proc(pid);
c010a3d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a3db:	89 04 24             	mov    %eax,(%esp)
c010a3de:	e8 b2 fa ff ff       	call   c0109e95 <find_proc>
c010a3e3:	a3 e4 9a 12 c0       	mov    %eax,0xc0129ae4
    set_proc_name(initproc, "init");
c010a3e8:	a1 e4 9a 12 c0       	mov    0xc0129ae4,%eax
c010a3ed:	c7 44 24 04 74 d4 10 	movl   $0xc010d474,0x4(%esp)
c010a3f4:	c0 
c010a3f5:	89 04 24             	mov    %eax,(%esp)
c010a3f8:	e8 12 f8 ff ff       	call   c0109c0f <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010a3fd:	a1 e0 9a 12 c0       	mov    0xc0129ae0,%eax
c010a402:	85 c0                	test   %eax,%eax
c010a404:	74 0c                	je     c010a412 <proc_init+0x15f>
c010a406:	a1 e0 9a 12 c0       	mov    0xc0129ae0,%eax
c010a40b:	8b 40 04             	mov    0x4(%eax),%eax
c010a40e:	85 c0                	test   %eax,%eax
c010a410:	74 24                	je     c010a436 <proc_init+0x183>
c010a412:	c7 44 24 0c 7c d4 10 	movl   $0xc010d47c,0xc(%esp)
c010a419:	c0 
c010a41a:	c7 44 24 08 a4 d3 10 	movl   $0xc010d3a4,0x8(%esp)
c010a421:	c0 
c010a422:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
c010a429:	00 
c010a42a:	c7 04 24 b9 d3 10 c0 	movl   $0xc010d3b9,(%esp)
c010a431:	e8 2a 7d ff ff       	call   c0102160 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c010a436:	a1 e4 9a 12 c0       	mov    0xc0129ae4,%eax
c010a43b:	85 c0                	test   %eax,%eax
c010a43d:	74 0d                	je     c010a44c <proc_init+0x199>
c010a43f:	a1 e4 9a 12 c0       	mov    0xc0129ae4,%eax
c010a444:	8b 40 04             	mov    0x4(%eax),%eax
c010a447:	83 f8 01             	cmp    $0x1,%eax
c010a44a:	74 24                	je     c010a470 <proc_init+0x1bd>
c010a44c:	c7 44 24 0c a4 d4 10 	movl   $0xc010d4a4,0xc(%esp)
c010a453:	c0 
c010a454:	c7 44 24 08 a4 d3 10 	movl   $0xc010d3a4,0x8(%esp)
c010a45b:	c0 
c010a45c:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
c010a463:	00 
c010a464:	c7 04 24 b9 d3 10 c0 	movl   $0xc010d3b9,(%esp)
c010a46b:	e8 f0 7c ff ff       	call   c0102160 <__panic>
}
c010a470:	c9                   	leave  
c010a471:	c3                   	ret    

c010a472 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010a472:	55                   	push   %ebp
c010a473:	89 e5                	mov    %esp,%ebp
c010a475:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c010a478:	a1 e8 9a 12 c0       	mov    0xc0129ae8,%eax
c010a47d:	8b 40 10             	mov    0x10(%eax),%eax
c010a480:	85 c0                	test   %eax,%eax
c010a482:	74 07                	je     c010a48b <cpu_idle+0x19>
            schedule();
c010a484:	e8 c1 00 00 00       	call   c010a54a <schedule>
        }
    }
c010a489:	eb ed                	jmp    c010a478 <cpu_idle+0x6>
c010a48b:	eb eb                	jmp    c010a478 <cpu_idle+0x6>

c010a48d <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c010a48d:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010a491:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c010a493:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c010a496:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c010a499:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c010a49c:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c010a49f:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c010a4a2:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c010a4a5:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c010a4a8:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c010a4ac:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c010a4af:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c010a4b2:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c010a4b5:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c010a4b8:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c010a4bb:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c010a4be:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010a4c1:	ff 30                	pushl  (%eax)

    ret
c010a4c3:	c3                   	ret    

c010a4c4 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c010a4c4:	55                   	push   %ebp
c010a4c5:	89 e5                	mov    %esp,%ebp
c010a4c7:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010a4ca:	9c                   	pushf  
c010a4cb:	58                   	pop    %eax
c010a4cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010a4cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010a4d2:	25 00 02 00 00       	and    $0x200,%eax
c010a4d7:	85 c0                	test   %eax,%eax
c010a4d9:	74 0c                	je     c010a4e7 <__intr_save+0x23>
        intr_disable();
c010a4db:	e8 d8 8e ff ff       	call   c01033b8 <intr_disable>
        return 1;
c010a4e0:	b8 01 00 00 00       	mov    $0x1,%eax
c010a4e5:	eb 05                	jmp    c010a4ec <__intr_save+0x28>
    }
    return 0;
c010a4e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a4ec:	c9                   	leave  
c010a4ed:	c3                   	ret    

c010a4ee <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010a4ee:	55                   	push   %ebp
c010a4ef:	89 e5                	mov    %esp,%ebp
c010a4f1:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010a4f4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010a4f8:	74 05                	je     c010a4ff <__intr_restore+0x11>
        intr_enable();
c010a4fa:	e8 b3 8e ff ff       	call   c01033b2 <intr_enable>
    }
}
c010a4ff:	c9                   	leave  
c010a500:	c3                   	ret    

c010a501 <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c010a501:	55                   	push   %ebp
c010a502:	89 e5                	mov    %esp,%ebp
c010a504:	83 ec 18             	sub    $0x18,%esp
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
c010a507:	8b 45 08             	mov    0x8(%ebp),%eax
c010a50a:	8b 00                	mov    (%eax),%eax
c010a50c:	83 f8 03             	cmp    $0x3,%eax
c010a50f:	74 0a                	je     c010a51b <wakeup_proc+0x1a>
c010a511:	8b 45 08             	mov    0x8(%ebp),%eax
c010a514:	8b 00                	mov    (%eax),%eax
c010a516:	83 f8 02             	cmp    $0x2,%eax
c010a519:	75 24                	jne    c010a53f <wakeup_proc+0x3e>
c010a51b:	c7 44 24 0c cc d4 10 	movl   $0xc010d4cc,0xc(%esp)
c010a522:	c0 
c010a523:	c7 44 24 08 07 d5 10 	movl   $0xc010d507,0x8(%esp)
c010a52a:	c0 
c010a52b:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c010a532:	00 
c010a533:	c7 04 24 1c d5 10 c0 	movl   $0xc010d51c,(%esp)
c010a53a:	e8 21 7c ff ff       	call   c0102160 <__panic>
    proc->state = PROC_RUNNABLE;
c010a53f:	8b 45 08             	mov    0x8(%ebp),%eax
c010a542:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
}
c010a548:	c9                   	leave  
c010a549:	c3                   	ret    

c010a54a <schedule>:

void
schedule(void) {
c010a54a:	55                   	push   %ebp
c010a54b:	89 e5                	mov    %esp,%ebp
c010a54d:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c010a550:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c010a557:	e8 68 ff ff ff       	call   c010a4c4 <__intr_save>
c010a55c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c010a55f:	a1 e8 9a 12 c0       	mov    0xc0129ae8,%eax
c010a564:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c010a56b:	8b 15 e8 9a 12 c0    	mov    0xc0129ae8,%edx
c010a571:	a1 e0 9a 12 c0       	mov    0xc0129ae0,%eax
c010a576:	39 c2                	cmp    %eax,%edx
c010a578:	74 0a                	je     c010a584 <schedule+0x3a>
c010a57a:	a1 e8 9a 12 c0       	mov    0xc0129ae8,%eax
c010a57f:	83 c0 58             	add    $0x58,%eax
c010a582:	eb 05                	jmp    c010a589 <schedule+0x3f>
c010a584:	b8 10 bc 12 c0       	mov    $0xc012bc10,%eax
c010a589:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c010a58c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a58f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a592:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a595:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010a598:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a59b:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c010a59e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a5a1:	81 7d f4 10 bc 12 c0 	cmpl   $0xc012bc10,-0xc(%ebp)
c010a5a8:	74 15                	je     c010a5bf <schedule+0x75>
                next = le2proc(le, list_link);
c010a5aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a5ad:	83 e8 58             	sub    $0x58,%eax
c010a5b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c010a5b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a5b6:	8b 00                	mov    (%eax),%eax
c010a5b8:	83 f8 02             	cmp    $0x2,%eax
c010a5bb:	75 02                	jne    c010a5bf <schedule+0x75>
                    break;
c010a5bd:	eb 08                	jmp    c010a5c7 <schedule+0x7d>
                }
            }
        } while (le != last);
c010a5bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a5c2:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c010a5c5:	75 cb                	jne    c010a592 <schedule+0x48>
        if (next == NULL || next->state != PROC_RUNNABLE) {
c010a5c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a5cb:	74 0a                	je     c010a5d7 <schedule+0x8d>
c010a5cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a5d0:	8b 00                	mov    (%eax),%eax
c010a5d2:	83 f8 02             	cmp    $0x2,%eax
c010a5d5:	74 08                	je     c010a5df <schedule+0x95>
            next = idleproc;
c010a5d7:	a1 e0 9a 12 c0       	mov    0xc0129ae0,%eax
c010a5dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c010a5df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a5e2:	8b 40 08             	mov    0x8(%eax),%eax
c010a5e5:	8d 50 01             	lea    0x1(%eax),%edx
c010a5e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a5eb:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010a5ee:	a1 e8 9a 12 c0       	mov    0xc0129ae8,%eax
c010a5f3:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010a5f6:	74 0b                	je     c010a603 <schedule+0xb9>
            proc_run(next);
c010a5f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a5fb:	89 04 24             	mov    %eax,(%esp)
c010a5fe:	e8 89 f7 ff ff       	call   c0109d8c <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c010a603:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a606:	89 04 24             	mov    %eax,(%esp)
c010a609:	e8 e0 fe ff ff       	call   c010a4ee <__intr_restore>
}
c010a60e:	c9                   	leave  
c010a60f:	c3                   	ret    

c010a610 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010a610:	55                   	push   %ebp
c010a611:	89 e5                	mov    %esp,%ebp
c010a613:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010a616:	8b 45 08             	mov    0x8(%ebp),%eax
c010a619:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010a61f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010a622:	b8 20 00 00 00       	mov    $0x20,%eax
c010a627:	2b 45 0c             	sub    0xc(%ebp),%eax
c010a62a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010a62d:	89 c1                	mov    %eax,%ecx
c010a62f:	d3 ea                	shr    %cl,%edx
c010a631:	89 d0                	mov    %edx,%eax
}
c010a633:	c9                   	leave  
c010a634:	c3                   	ret    

c010a635 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010a635:	55                   	push   %ebp
c010a636:	89 e5                	mov    %esp,%ebp
c010a638:	83 ec 58             	sub    $0x58,%esp
c010a63b:	8b 45 10             	mov    0x10(%ebp),%eax
c010a63e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a641:	8b 45 14             	mov    0x14(%ebp),%eax
c010a644:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010a647:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a64a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a64d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a650:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010a653:	8b 45 18             	mov    0x18(%ebp),%eax
c010a656:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010a659:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a65c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a65f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a662:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010a665:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a668:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a66b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a66f:	74 1c                	je     c010a68d <printnum+0x58>
c010a671:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a674:	ba 00 00 00 00       	mov    $0x0,%edx
c010a679:	f7 75 e4             	divl   -0x1c(%ebp)
c010a67c:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010a67f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a682:	ba 00 00 00 00       	mov    $0x0,%edx
c010a687:	f7 75 e4             	divl   -0x1c(%ebp)
c010a68a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a68d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a690:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a693:	f7 75 e4             	divl   -0x1c(%ebp)
c010a696:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a699:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010a69c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a69f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010a6a2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a6a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010a6a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a6ab:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010a6ae:	8b 45 18             	mov    0x18(%ebp),%eax
c010a6b1:	ba 00 00 00 00       	mov    $0x0,%edx
c010a6b6:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010a6b9:	77 56                	ja     c010a711 <printnum+0xdc>
c010a6bb:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010a6be:	72 05                	jb     c010a6c5 <printnum+0x90>
c010a6c0:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010a6c3:	77 4c                	ja     c010a711 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c010a6c5:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010a6c8:	8d 50 ff             	lea    -0x1(%eax),%edx
c010a6cb:	8b 45 20             	mov    0x20(%ebp),%eax
c010a6ce:	89 44 24 18          	mov    %eax,0x18(%esp)
c010a6d2:	89 54 24 14          	mov    %edx,0x14(%esp)
c010a6d6:	8b 45 18             	mov    0x18(%ebp),%eax
c010a6d9:	89 44 24 10          	mov    %eax,0x10(%esp)
c010a6dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a6e0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a6e3:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a6e7:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010a6eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a6ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a6f2:	8b 45 08             	mov    0x8(%ebp),%eax
c010a6f5:	89 04 24             	mov    %eax,(%esp)
c010a6f8:	e8 38 ff ff ff       	call   c010a635 <printnum>
c010a6fd:	eb 1c                	jmp    c010a71b <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010a6ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a702:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a706:	8b 45 20             	mov    0x20(%ebp),%eax
c010a709:	89 04 24             	mov    %eax,(%esp)
c010a70c:	8b 45 08             	mov    0x8(%ebp),%eax
c010a70f:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c010a711:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010a715:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010a719:	7f e4                	jg     c010a6ff <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010a71b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a71e:	05 b4 d5 10 c0       	add    $0xc010d5b4,%eax
c010a723:	0f b6 00             	movzbl (%eax),%eax
c010a726:	0f be c0             	movsbl %al,%eax
c010a729:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a72c:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a730:	89 04 24             	mov    %eax,(%esp)
c010a733:	8b 45 08             	mov    0x8(%ebp),%eax
c010a736:	ff d0                	call   *%eax
}
c010a738:	c9                   	leave  
c010a739:	c3                   	ret    

c010a73a <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010a73a:	55                   	push   %ebp
c010a73b:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010a73d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010a741:	7e 14                	jle    c010a757 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010a743:	8b 45 08             	mov    0x8(%ebp),%eax
c010a746:	8b 00                	mov    (%eax),%eax
c010a748:	8d 48 08             	lea    0x8(%eax),%ecx
c010a74b:	8b 55 08             	mov    0x8(%ebp),%edx
c010a74e:	89 0a                	mov    %ecx,(%edx)
c010a750:	8b 50 04             	mov    0x4(%eax),%edx
c010a753:	8b 00                	mov    (%eax),%eax
c010a755:	eb 30                	jmp    c010a787 <getuint+0x4d>
    }
    else if (lflag) {
c010a757:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a75b:	74 16                	je     c010a773 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010a75d:	8b 45 08             	mov    0x8(%ebp),%eax
c010a760:	8b 00                	mov    (%eax),%eax
c010a762:	8d 48 04             	lea    0x4(%eax),%ecx
c010a765:	8b 55 08             	mov    0x8(%ebp),%edx
c010a768:	89 0a                	mov    %ecx,(%edx)
c010a76a:	8b 00                	mov    (%eax),%eax
c010a76c:	ba 00 00 00 00       	mov    $0x0,%edx
c010a771:	eb 14                	jmp    c010a787 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010a773:	8b 45 08             	mov    0x8(%ebp),%eax
c010a776:	8b 00                	mov    (%eax),%eax
c010a778:	8d 48 04             	lea    0x4(%eax),%ecx
c010a77b:	8b 55 08             	mov    0x8(%ebp),%edx
c010a77e:	89 0a                	mov    %ecx,(%edx)
c010a780:	8b 00                	mov    (%eax),%eax
c010a782:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010a787:	5d                   	pop    %ebp
c010a788:	c3                   	ret    

c010a789 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010a789:	55                   	push   %ebp
c010a78a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010a78c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010a790:	7e 14                	jle    c010a7a6 <getint+0x1d>
        return va_arg(*ap, long long);
c010a792:	8b 45 08             	mov    0x8(%ebp),%eax
c010a795:	8b 00                	mov    (%eax),%eax
c010a797:	8d 48 08             	lea    0x8(%eax),%ecx
c010a79a:	8b 55 08             	mov    0x8(%ebp),%edx
c010a79d:	89 0a                	mov    %ecx,(%edx)
c010a79f:	8b 50 04             	mov    0x4(%eax),%edx
c010a7a2:	8b 00                	mov    (%eax),%eax
c010a7a4:	eb 28                	jmp    c010a7ce <getint+0x45>
    }
    else if (lflag) {
c010a7a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a7aa:	74 12                	je     c010a7be <getint+0x35>
        return va_arg(*ap, long);
c010a7ac:	8b 45 08             	mov    0x8(%ebp),%eax
c010a7af:	8b 00                	mov    (%eax),%eax
c010a7b1:	8d 48 04             	lea    0x4(%eax),%ecx
c010a7b4:	8b 55 08             	mov    0x8(%ebp),%edx
c010a7b7:	89 0a                	mov    %ecx,(%edx)
c010a7b9:	8b 00                	mov    (%eax),%eax
c010a7bb:	99                   	cltd   
c010a7bc:	eb 10                	jmp    c010a7ce <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010a7be:	8b 45 08             	mov    0x8(%ebp),%eax
c010a7c1:	8b 00                	mov    (%eax),%eax
c010a7c3:	8d 48 04             	lea    0x4(%eax),%ecx
c010a7c6:	8b 55 08             	mov    0x8(%ebp),%edx
c010a7c9:	89 0a                	mov    %ecx,(%edx)
c010a7cb:	8b 00                	mov    (%eax),%eax
c010a7cd:	99                   	cltd   
    }
}
c010a7ce:	5d                   	pop    %ebp
c010a7cf:	c3                   	ret    

c010a7d0 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010a7d0:	55                   	push   %ebp
c010a7d1:	89 e5                	mov    %esp,%ebp
c010a7d3:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010a7d6:	8d 45 14             	lea    0x14(%ebp),%eax
c010a7d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010a7dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a7df:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a7e3:	8b 45 10             	mov    0x10(%ebp),%eax
c010a7e6:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a7ea:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a7ed:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a7f1:	8b 45 08             	mov    0x8(%ebp),%eax
c010a7f4:	89 04 24             	mov    %eax,(%esp)
c010a7f7:	e8 02 00 00 00       	call   c010a7fe <vprintfmt>
    va_end(ap);
}
c010a7fc:	c9                   	leave  
c010a7fd:	c3                   	ret    

c010a7fe <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010a7fe:	55                   	push   %ebp
c010a7ff:	89 e5                	mov    %esp,%ebp
c010a801:	56                   	push   %esi
c010a802:	53                   	push   %ebx
c010a803:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010a806:	eb 18                	jmp    c010a820 <vprintfmt+0x22>
            if (ch == '\0') {
c010a808:	85 db                	test   %ebx,%ebx
c010a80a:	75 05                	jne    c010a811 <vprintfmt+0x13>
                return;
c010a80c:	e9 d1 03 00 00       	jmp    c010abe2 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c010a811:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a814:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a818:	89 1c 24             	mov    %ebx,(%esp)
c010a81b:	8b 45 08             	mov    0x8(%ebp),%eax
c010a81e:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010a820:	8b 45 10             	mov    0x10(%ebp),%eax
c010a823:	8d 50 01             	lea    0x1(%eax),%edx
c010a826:	89 55 10             	mov    %edx,0x10(%ebp)
c010a829:	0f b6 00             	movzbl (%eax),%eax
c010a82c:	0f b6 d8             	movzbl %al,%ebx
c010a82f:	83 fb 25             	cmp    $0x25,%ebx
c010a832:	75 d4                	jne    c010a808 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c010a834:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010a838:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010a83f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a842:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010a845:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010a84c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a84f:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010a852:	8b 45 10             	mov    0x10(%ebp),%eax
c010a855:	8d 50 01             	lea    0x1(%eax),%edx
c010a858:	89 55 10             	mov    %edx,0x10(%ebp)
c010a85b:	0f b6 00             	movzbl (%eax),%eax
c010a85e:	0f b6 d8             	movzbl %al,%ebx
c010a861:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010a864:	83 f8 55             	cmp    $0x55,%eax
c010a867:	0f 87 44 03 00 00    	ja     c010abb1 <vprintfmt+0x3b3>
c010a86d:	8b 04 85 d8 d5 10 c0 	mov    -0x3fef2a28(,%eax,4),%eax
c010a874:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010a876:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010a87a:	eb d6                	jmp    c010a852 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010a87c:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010a880:	eb d0                	jmp    c010a852 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010a882:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010a889:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a88c:	89 d0                	mov    %edx,%eax
c010a88e:	c1 e0 02             	shl    $0x2,%eax
c010a891:	01 d0                	add    %edx,%eax
c010a893:	01 c0                	add    %eax,%eax
c010a895:	01 d8                	add    %ebx,%eax
c010a897:	83 e8 30             	sub    $0x30,%eax
c010a89a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010a89d:	8b 45 10             	mov    0x10(%ebp),%eax
c010a8a0:	0f b6 00             	movzbl (%eax),%eax
c010a8a3:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010a8a6:	83 fb 2f             	cmp    $0x2f,%ebx
c010a8a9:	7e 0b                	jle    c010a8b6 <vprintfmt+0xb8>
c010a8ab:	83 fb 39             	cmp    $0x39,%ebx
c010a8ae:	7f 06                	jg     c010a8b6 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010a8b0:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c010a8b4:	eb d3                	jmp    c010a889 <vprintfmt+0x8b>
            goto process_precision;
c010a8b6:	eb 33                	jmp    c010a8eb <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c010a8b8:	8b 45 14             	mov    0x14(%ebp),%eax
c010a8bb:	8d 50 04             	lea    0x4(%eax),%edx
c010a8be:	89 55 14             	mov    %edx,0x14(%ebp)
c010a8c1:	8b 00                	mov    (%eax),%eax
c010a8c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010a8c6:	eb 23                	jmp    c010a8eb <vprintfmt+0xed>

        case '.':
            if (width < 0)
c010a8c8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a8cc:	79 0c                	jns    c010a8da <vprintfmt+0xdc>
                width = 0;
c010a8ce:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010a8d5:	e9 78 ff ff ff       	jmp    c010a852 <vprintfmt+0x54>
c010a8da:	e9 73 ff ff ff       	jmp    c010a852 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c010a8df:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010a8e6:	e9 67 ff ff ff       	jmp    c010a852 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c010a8eb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a8ef:	79 12                	jns    c010a903 <vprintfmt+0x105>
                width = precision, precision = -1;
c010a8f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a8f4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a8f7:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010a8fe:	e9 4f ff ff ff       	jmp    c010a852 <vprintfmt+0x54>
c010a903:	e9 4a ff ff ff       	jmp    c010a852 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010a908:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010a90c:	e9 41 ff ff ff       	jmp    c010a852 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010a911:	8b 45 14             	mov    0x14(%ebp),%eax
c010a914:	8d 50 04             	lea    0x4(%eax),%edx
c010a917:	89 55 14             	mov    %edx,0x14(%ebp)
c010a91a:	8b 00                	mov    (%eax),%eax
c010a91c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a91f:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a923:	89 04 24             	mov    %eax,(%esp)
c010a926:	8b 45 08             	mov    0x8(%ebp),%eax
c010a929:	ff d0                	call   *%eax
            break;
c010a92b:	e9 ac 02 00 00       	jmp    c010abdc <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010a930:	8b 45 14             	mov    0x14(%ebp),%eax
c010a933:	8d 50 04             	lea    0x4(%eax),%edx
c010a936:	89 55 14             	mov    %edx,0x14(%ebp)
c010a939:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010a93b:	85 db                	test   %ebx,%ebx
c010a93d:	79 02                	jns    c010a941 <vprintfmt+0x143>
                err = -err;
c010a93f:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010a941:	83 fb 06             	cmp    $0x6,%ebx
c010a944:	7f 0b                	jg     c010a951 <vprintfmt+0x153>
c010a946:	8b 34 9d 98 d5 10 c0 	mov    -0x3fef2a68(,%ebx,4),%esi
c010a94d:	85 f6                	test   %esi,%esi
c010a94f:	75 23                	jne    c010a974 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c010a951:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010a955:	c7 44 24 08 c5 d5 10 	movl   $0xc010d5c5,0x8(%esp)
c010a95c:	c0 
c010a95d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a960:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a964:	8b 45 08             	mov    0x8(%ebp),%eax
c010a967:	89 04 24             	mov    %eax,(%esp)
c010a96a:	e8 61 fe ff ff       	call   c010a7d0 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010a96f:	e9 68 02 00 00       	jmp    c010abdc <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c010a974:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010a978:	c7 44 24 08 ce d5 10 	movl   $0xc010d5ce,0x8(%esp)
c010a97f:	c0 
c010a980:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a983:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a987:	8b 45 08             	mov    0x8(%ebp),%eax
c010a98a:	89 04 24             	mov    %eax,(%esp)
c010a98d:	e8 3e fe ff ff       	call   c010a7d0 <printfmt>
            }
            break;
c010a992:	e9 45 02 00 00       	jmp    c010abdc <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010a997:	8b 45 14             	mov    0x14(%ebp),%eax
c010a99a:	8d 50 04             	lea    0x4(%eax),%edx
c010a99d:	89 55 14             	mov    %edx,0x14(%ebp)
c010a9a0:	8b 30                	mov    (%eax),%esi
c010a9a2:	85 f6                	test   %esi,%esi
c010a9a4:	75 05                	jne    c010a9ab <vprintfmt+0x1ad>
                p = "(null)";
c010a9a6:	be d1 d5 10 c0       	mov    $0xc010d5d1,%esi
            }
            if (width > 0 && padc != '-') {
c010a9ab:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a9af:	7e 3e                	jle    c010a9ef <vprintfmt+0x1f1>
c010a9b1:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010a9b5:	74 38                	je     c010a9ef <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010a9b7:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c010a9ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a9bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a9c1:	89 34 24             	mov    %esi,(%esp)
c010a9c4:	e8 ed 03 00 00       	call   c010adb6 <strnlen>
c010a9c9:	29 c3                	sub    %eax,%ebx
c010a9cb:	89 d8                	mov    %ebx,%eax
c010a9cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a9d0:	eb 17                	jmp    c010a9e9 <vprintfmt+0x1eb>
                    putch(padc, putdat);
c010a9d2:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010a9d6:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a9d9:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a9dd:	89 04 24             	mov    %eax,(%esp)
c010a9e0:	8b 45 08             	mov    0x8(%ebp),%eax
c010a9e3:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c010a9e5:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010a9e9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a9ed:	7f e3                	jg     c010a9d2 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010a9ef:	eb 38                	jmp    c010aa29 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c010a9f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010a9f5:	74 1f                	je     c010aa16 <vprintfmt+0x218>
c010a9f7:	83 fb 1f             	cmp    $0x1f,%ebx
c010a9fa:	7e 05                	jle    c010aa01 <vprintfmt+0x203>
c010a9fc:	83 fb 7e             	cmp    $0x7e,%ebx
c010a9ff:	7e 15                	jle    c010aa16 <vprintfmt+0x218>
                    putch('?', putdat);
c010aa01:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aa04:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aa08:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010aa0f:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa12:	ff d0                	call   *%eax
c010aa14:	eb 0f                	jmp    c010aa25 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c010aa16:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aa19:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aa1d:	89 1c 24             	mov    %ebx,(%esp)
c010aa20:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa23:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010aa25:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010aa29:	89 f0                	mov    %esi,%eax
c010aa2b:	8d 70 01             	lea    0x1(%eax),%esi
c010aa2e:	0f b6 00             	movzbl (%eax),%eax
c010aa31:	0f be d8             	movsbl %al,%ebx
c010aa34:	85 db                	test   %ebx,%ebx
c010aa36:	74 10                	je     c010aa48 <vprintfmt+0x24a>
c010aa38:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010aa3c:	78 b3                	js     c010a9f1 <vprintfmt+0x1f3>
c010aa3e:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010aa42:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010aa46:	79 a9                	jns    c010a9f1 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010aa48:	eb 17                	jmp    c010aa61 <vprintfmt+0x263>
                putch(' ', putdat);
c010aa4a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aa4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aa51:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010aa58:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa5b:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010aa5d:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010aa61:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010aa65:	7f e3                	jg     c010aa4a <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c010aa67:	e9 70 01 00 00       	jmp    c010abdc <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010aa6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010aa6f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aa73:	8d 45 14             	lea    0x14(%ebp),%eax
c010aa76:	89 04 24             	mov    %eax,(%esp)
c010aa79:	e8 0b fd ff ff       	call   c010a789 <getint>
c010aa7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010aa81:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010aa84:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010aa87:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010aa8a:	85 d2                	test   %edx,%edx
c010aa8c:	79 26                	jns    c010aab4 <vprintfmt+0x2b6>
                putch('-', putdat);
c010aa8e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aa91:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aa95:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010aa9c:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa9f:	ff d0                	call   *%eax
                num = -(long long)num;
c010aaa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010aaa4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010aaa7:	f7 d8                	neg    %eax
c010aaa9:	83 d2 00             	adc    $0x0,%edx
c010aaac:	f7 da                	neg    %edx
c010aaae:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010aab1:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010aab4:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010aabb:	e9 a8 00 00 00       	jmp    c010ab68 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010aac0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010aac3:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aac7:	8d 45 14             	lea    0x14(%ebp),%eax
c010aaca:	89 04 24             	mov    %eax,(%esp)
c010aacd:	e8 68 fc ff ff       	call   c010a73a <getuint>
c010aad2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010aad5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010aad8:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010aadf:	e9 84 00 00 00       	jmp    c010ab68 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010aae4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010aae7:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aaeb:	8d 45 14             	lea    0x14(%ebp),%eax
c010aaee:	89 04 24             	mov    %eax,(%esp)
c010aaf1:	e8 44 fc ff ff       	call   c010a73a <getuint>
c010aaf6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010aaf9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010aafc:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010ab03:	eb 63                	jmp    c010ab68 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c010ab05:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ab08:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ab0c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010ab13:	8b 45 08             	mov    0x8(%ebp),%eax
c010ab16:	ff d0                	call   *%eax
            putch('x', putdat);
c010ab18:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ab1b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ab1f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010ab26:	8b 45 08             	mov    0x8(%ebp),%eax
c010ab29:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010ab2b:	8b 45 14             	mov    0x14(%ebp),%eax
c010ab2e:	8d 50 04             	lea    0x4(%eax),%edx
c010ab31:	89 55 14             	mov    %edx,0x14(%ebp)
c010ab34:	8b 00                	mov    (%eax),%eax
c010ab36:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ab39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010ab40:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010ab47:	eb 1f                	jmp    c010ab68 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010ab49:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010ab4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ab50:	8d 45 14             	lea    0x14(%ebp),%eax
c010ab53:	89 04 24             	mov    %eax,(%esp)
c010ab56:	e8 df fb ff ff       	call   c010a73a <getuint>
c010ab5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ab5e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010ab61:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010ab68:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010ab6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ab6f:	89 54 24 18          	mov    %edx,0x18(%esp)
c010ab73:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010ab76:	89 54 24 14          	mov    %edx,0x14(%esp)
c010ab7a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010ab7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ab81:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010ab84:	89 44 24 08          	mov    %eax,0x8(%esp)
c010ab88:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010ab8c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ab8f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ab93:	8b 45 08             	mov    0x8(%ebp),%eax
c010ab96:	89 04 24             	mov    %eax,(%esp)
c010ab99:	e8 97 fa ff ff       	call   c010a635 <printnum>
            break;
c010ab9e:	eb 3c                	jmp    c010abdc <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010aba0:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aba3:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aba7:	89 1c 24             	mov    %ebx,(%esp)
c010abaa:	8b 45 08             	mov    0x8(%ebp),%eax
c010abad:	ff d0                	call   *%eax
            break;
c010abaf:	eb 2b                	jmp    c010abdc <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010abb1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010abb4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010abb8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010abbf:	8b 45 08             	mov    0x8(%ebp),%eax
c010abc2:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010abc4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010abc8:	eb 04                	jmp    c010abce <vprintfmt+0x3d0>
c010abca:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010abce:	8b 45 10             	mov    0x10(%ebp),%eax
c010abd1:	83 e8 01             	sub    $0x1,%eax
c010abd4:	0f b6 00             	movzbl (%eax),%eax
c010abd7:	3c 25                	cmp    $0x25,%al
c010abd9:	75 ef                	jne    c010abca <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c010abdb:	90                   	nop
        }
    }
c010abdc:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010abdd:	e9 3e fc ff ff       	jmp    c010a820 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c010abe2:	83 c4 40             	add    $0x40,%esp
c010abe5:	5b                   	pop    %ebx
c010abe6:	5e                   	pop    %esi
c010abe7:	5d                   	pop    %ebp
c010abe8:	c3                   	ret    

c010abe9 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010abe9:	55                   	push   %ebp
c010abea:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010abec:	8b 45 0c             	mov    0xc(%ebp),%eax
c010abef:	8b 40 08             	mov    0x8(%eax),%eax
c010abf2:	8d 50 01             	lea    0x1(%eax),%edx
c010abf5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010abf8:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010abfb:	8b 45 0c             	mov    0xc(%ebp),%eax
c010abfe:	8b 10                	mov    (%eax),%edx
c010ac00:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ac03:	8b 40 04             	mov    0x4(%eax),%eax
c010ac06:	39 c2                	cmp    %eax,%edx
c010ac08:	73 12                	jae    c010ac1c <sprintputch+0x33>
        *b->buf ++ = ch;
c010ac0a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ac0d:	8b 00                	mov    (%eax),%eax
c010ac0f:	8d 48 01             	lea    0x1(%eax),%ecx
c010ac12:	8b 55 0c             	mov    0xc(%ebp),%edx
c010ac15:	89 0a                	mov    %ecx,(%edx)
c010ac17:	8b 55 08             	mov    0x8(%ebp),%edx
c010ac1a:	88 10                	mov    %dl,(%eax)
    }
}
c010ac1c:	5d                   	pop    %ebp
c010ac1d:	c3                   	ret    

c010ac1e <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010ac1e:	55                   	push   %ebp
c010ac1f:	89 e5                	mov    %esp,%ebp
c010ac21:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010ac24:	8d 45 14             	lea    0x14(%ebp),%eax
c010ac27:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010ac2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ac2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010ac31:	8b 45 10             	mov    0x10(%ebp),%eax
c010ac34:	89 44 24 08          	mov    %eax,0x8(%esp)
c010ac38:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ac3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ac3f:	8b 45 08             	mov    0x8(%ebp),%eax
c010ac42:	89 04 24             	mov    %eax,(%esp)
c010ac45:	e8 08 00 00 00       	call   c010ac52 <vsnprintf>
c010ac4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010ac4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010ac50:	c9                   	leave  
c010ac51:	c3                   	ret    

c010ac52 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010ac52:	55                   	push   %ebp
c010ac53:	89 e5                	mov    %esp,%ebp
c010ac55:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010ac58:	8b 45 08             	mov    0x8(%ebp),%eax
c010ac5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010ac5e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ac61:	8d 50 ff             	lea    -0x1(%eax),%edx
c010ac64:	8b 45 08             	mov    0x8(%ebp),%eax
c010ac67:	01 d0                	add    %edx,%eax
c010ac69:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ac6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010ac73:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010ac77:	74 0a                	je     c010ac83 <vsnprintf+0x31>
c010ac79:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010ac7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ac7f:	39 c2                	cmp    %eax,%edx
c010ac81:	76 07                	jbe    c010ac8a <vsnprintf+0x38>
        return -E_INVAL;
c010ac83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010ac88:	eb 2a                	jmp    c010acb4 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010ac8a:	8b 45 14             	mov    0x14(%ebp),%eax
c010ac8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010ac91:	8b 45 10             	mov    0x10(%ebp),%eax
c010ac94:	89 44 24 08          	mov    %eax,0x8(%esp)
c010ac98:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010ac9b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ac9f:	c7 04 24 e9 ab 10 c0 	movl   $0xc010abe9,(%esp)
c010aca6:	e8 53 fb ff ff       	call   c010a7fe <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010acab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010acae:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010acb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010acb4:	c9                   	leave  
c010acb5:	c3                   	ret    

c010acb6 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010acb6:	55                   	push   %ebp
c010acb7:	89 e5                	mov    %esp,%ebp
c010acb9:	57                   	push   %edi
c010acba:	56                   	push   %esi
c010acbb:	53                   	push   %ebx
c010acbc:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010acbf:	a1 88 8a 12 c0       	mov    0xc0128a88,%eax
c010acc4:	8b 15 8c 8a 12 c0    	mov    0xc0128a8c,%edx
c010acca:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010acd0:	6b f0 05             	imul   $0x5,%eax,%esi
c010acd3:	01 f7                	add    %esi,%edi
c010acd5:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
c010acda:	f7 e6                	mul    %esi
c010acdc:	8d 34 17             	lea    (%edi,%edx,1),%esi
c010acdf:	89 f2                	mov    %esi,%edx
c010ace1:	83 c0 0b             	add    $0xb,%eax
c010ace4:	83 d2 00             	adc    $0x0,%edx
c010ace7:	89 c7                	mov    %eax,%edi
c010ace9:	83 e7 ff             	and    $0xffffffff,%edi
c010acec:	89 f9                	mov    %edi,%ecx
c010acee:	0f b7 da             	movzwl %dx,%ebx
c010acf1:	89 0d 88 8a 12 c0    	mov    %ecx,0xc0128a88
c010acf7:	89 1d 8c 8a 12 c0    	mov    %ebx,0xc0128a8c
    unsigned long long result = (next >> 12);
c010acfd:	a1 88 8a 12 c0       	mov    0xc0128a88,%eax
c010ad02:	8b 15 8c 8a 12 c0    	mov    0xc0128a8c,%edx
c010ad08:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010ad0c:	c1 ea 0c             	shr    $0xc,%edx
c010ad0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010ad12:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010ad15:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010ad1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010ad1f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010ad22:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010ad25:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010ad28:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010ad2e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010ad32:	74 1c                	je     c010ad50 <rand+0x9a>
c010ad34:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad37:	ba 00 00 00 00       	mov    $0x0,%edx
c010ad3c:	f7 75 dc             	divl   -0x24(%ebp)
c010ad3f:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010ad42:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad45:	ba 00 00 00 00       	mov    $0x0,%edx
c010ad4a:	f7 75 dc             	divl   -0x24(%ebp)
c010ad4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010ad50:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010ad53:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010ad56:	f7 75 dc             	divl   -0x24(%ebp)
c010ad59:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010ad5c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010ad5f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010ad62:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010ad65:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010ad68:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010ad6b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010ad6e:	83 c4 24             	add    $0x24,%esp
c010ad71:	5b                   	pop    %ebx
c010ad72:	5e                   	pop    %esi
c010ad73:	5f                   	pop    %edi
c010ad74:	5d                   	pop    %ebp
c010ad75:	c3                   	ret    

c010ad76 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010ad76:	55                   	push   %ebp
c010ad77:	89 e5                	mov    %esp,%ebp
    next = seed;
c010ad79:	8b 45 08             	mov    0x8(%ebp),%eax
c010ad7c:	ba 00 00 00 00       	mov    $0x0,%edx
c010ad81:	a3 88 8a 12 c0       	mov    %eax,0xc0128a88
c010ad86:	89 15 8c 8a 12 c0    	mov    %edx,0xc0128a8c
}
c010ad8c:	5d                   	pop    %ebp
c010ad8d:	c3                   	ret    

c010ad8e <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010ad8e:	55                   	push   %ebp
c010ad8f:	89 e5                	mov    %esp,%ebp
c010ad91:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010ad94:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010ad9b:	eb 04                	jmp    c010ada1 <strlen+0x13>
        cnt ++;
c010ad9d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c010ada1:	8b 45 08             	mov    0x8(%ebp),%eax
c010ada4:	8d 50 01             	lea    0x1(%eax),%edx
c010ada7:	89 55 08             	mov    %edx,0x8(%ebp)
c010adaa:	0f b6 00             	movzbl (%eax),%eax
c010adad:	84 c0                	test   %al,%al
c010adaf:	75 ec                	jne    c010ad9d <strlen+0xf>
        cnt ++;
    }
    return cnt;
c010adb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010adb4:	c9                   	leave  
c010adb5:	c3                   	ret    

c010adb6 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010adb6:	55                   	push   %ebp
c010adb7:	89 e5                	mov    %esp,%ebp
c010adb9:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010adbc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010adc3:	eb 04                	jmp    c010adc9 <strnlen+0x13>
        cnt ++;
c010adc5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c010adc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010adcc:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010adcf:	73 10                	jae    c010ade1 <strnlen+0x2b>
c010add1:	8b 45 08             	mov    0x8(%ebp),%eax
c010add4:	8d 50 01             	lea    0x1(%eax),%edx
c010add7:	89 55 08             	mov    %edx,0x8(%ebp)
c010adda:	0f b6 00             	movzbl (%eax),%eax
c010addd:	84 c0                	test   %al,%al
c010addf:	75 e4                	jne    c010adc5 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c010ade1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010ade4:	c9                   	leave  
c010ade5:	c3                   	ret    

c010ade6 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010ade6:	55                   	push   %ebp
c010ade7:	89 e5                	mov    %esp,%ebp
c010ade9:	57                   	push   %edi
c010adea:	56                   	push   %esi
c010adeb:	83 ec 20             	sub    $0x20,%esp
c010adee:	8b 45 08             	mov    0x8(%ebp),%eax
c010adf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010adf4:	8b 45 0c             	mov    0xc(%ebp),%eax
c010adf7:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010adfa:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010adfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ae00:	89 d1                	mov    %edx,%ecx
c010ae02:	89 c2                	mov    %eax,%edx
c010ae04:	89 ce                	mov    %ecx,%esi
c010ae06:	89 d7                	mov    %edx,%edi
c010ae08:	ac                   	lods   %ds:(%esi),%al
c010ae09:	aa                   	stos   %al,%es:(%edi)
c010ae0a:	84 c0                	test   %al,%al
c010ae0c:	75 fa                	jne    c010ae08 <strcpy+0x22>
c010ae0e:	89 fa                	mov    %edi,%edx
c010ae10:	89 f1                	mov    %esi,%ecx
c010ae12:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010ae15:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010ae18:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010ae1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010ae1e:	83 c4 20             	add    $0x20,%esp
c010ae21:	5e                   	pop    %esi
c010ae22:	5f                   	pop    %edi
c010ae23:	5d                   	pop    %ebp
c010ae24:	c3                   	ret    

c010ae25 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010ae25:	55                   	push   %ebp
c010ae26:	89 e5                	mov    %esp,%ebp
c010ae28:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010ae2b:	8b 45 08             	mov    0x8(%ebp),%eax
c010ae2e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010ae31:	eb 21                	jmp    c010ae54 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c010ae33:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ae36:	0f b6 10             	movzbl (%eax),%edx
c010ae39:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010ae3c:	88 10                	mov    %dl,(%eax)
c010ae3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010ae41:	0f b6 00             	movzbl (%eax),%eax
c010ae44:	84 c0                	test   %al,%al
c010ae46:	74 04                	je     c010ae4c <strncpy+0x27>
            src ++;
c010ae48:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c010ae4c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010ae50:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c010ae54:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010ae58:	75 d9                	jne    c010ae33 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c010ae5a:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010ae5d:	c9                   	leave  
c010ae5e:	c3                   	ret    

c010ae5f <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010ae5f:	55                   	push   %ebp
c010ae60:	89 e5                	mov    %esp,%ebp
c010ae62:	57                   	push   %edi
c010ae63:	56                   	push   %esi
c010ae64:	83 ec 20             	sub    $0x20,%esp
c010ae67:	8b 45 08             	mov    0x8(%ebp),%eax
c010ae6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010ae6d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ae70:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c010ae73:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010ae76:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ae79:	89 d1                	mov    %edx,%ecx
c010ae7b:	89 c2                	mov    %eax,%edx
c010ae7d:	89 ce                	mov    %ecx,%esi
c010ae7f:	89 d7                	mov    %edx,%edi
c010ae81:	ac                   	lods   %ds:(%esi),%al
c010ae82:	ae                   	scas   %es:(%edi),%al
c010ae83:	75 08                	jne    c010ae8d <strcmp+0x2e>
c010ae85:	84 c0                	test   %al,%al
c010ae87:	75 f8                	jne    c010ae81 <strcmp+0x22>
c010ae89:	31 c0                	xor    %eax,%eax
c010ae8b:	eb 04                	jmp    c010ae91 <strcmp+0x32>
c010ae8d:	19 c0                	sbb    %eax,%eax
c010ae8f:	0c 01                	or     $0x1,%al
c010ae91:	89 fa                	mov    %edi,%edx
c010ae93:	89 f1                	mov    %esi,%ecx
c010ae95:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010ae98:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010ae9b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c010ae9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010aea1:	83 c4 20             	add    $0x20,%esp
c010aea4:	5e                   	pop    %esi
c010aea5:	5f                   	pop    %edi
c010aea6:	5d                   	pop    %ebp
c010aea7:	c3                   	ret    

c010aea8 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010aea8:	55                   	push   %ebp
c010aea9:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010aeab:	eb 0c                	jmp    c010aeb9 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c010aead:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010aeb1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010aeb5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010aeb9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010aebd:	74 1a                	je     c010aed9 <strncmp+0x31>
c010aebf:	8b 45 08             	mov    0x8(%ebp),%eax
c010aec2:	0f b6 00             	movzbl (%eax),%eax
c010aec5:	84 c0                	test   %al,%al
c010aec7:	74 10                	je     c010aed9 <strncmp+0x31>
c010aec9:	8b 45 08             	mov    0x8(%ebp),%eax
c010aecc:	0f b6 10             	movzbl (%eax),%edx
c010aecf:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aed2:	0f b6 00             	movzbl (%eax),%eax
c010aed5:	38 c2                	cmp    %al,%dl
c010aed7:	74 d4                	je     c010aead <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010aed9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010aedd:	74 18                	je     c010aef7 <strncmp+0x4f>
c010aedf:	8b 45 08             	mov    0x8(%ebp),%eax
c010aee2:	0f b6 00             	movzbl (%eax),%eax
c010aee5:	0f b6 d0             	movzbl %al,%edx
c010aee8:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aeeb:	0f b6 00             	movzbl (%eax),%eax
c010aeee:	0f b6 c0             	movzbl %al,%eax
c010aef1:	29 c2                	sub    %eax,%edx
c010aef3:	89 d0                	mov    %edx,%eax
c010aef5:	eb 05                	jmp    c010aefc <strncmp+0x54>
c010aef7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010aefc:	5d                   	pop    %ebp
c010aefd:	c3                   	ret    

c010aefe <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010aefe:	55                   	push   %ebp
c010aeff:	89 e5                	mov    %esp,%ebp
c010af01:	83 ec 04             	sub    $0x4,%esp
c010af04:	8b 45 0c             	mov    0xc(%ebp),%eax
c010af07:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010af0a:	eb 14                	jmp    c010af20 <strchr+0x22>
        if (*s == c) {
c010af0c:	8b 45 08             	mov    0x8(%ebp),%eax
c010af0f:	0f b6 00             	movzbl (%eax),%eax
c010af12:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010af15:	75 05                	jne    c010af1c <strchr+0x1e>
            return (char *)s;
c010af17:	8b 45 08             	mov    0x8(%ebp),%eax
c010af1a:	eb 13                	jmp    c010af2f <strchr+0x31>
        }
        s ++;
c010af1c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c010af20:	8b 45 08             	mov    0x8(%ebp),%eax
c010af23:	0f b6 00             	movzbl (%eax),%eax
c010af26:	84 c0                	test   %al,%al
c010af28:	75 e2                	jne    c010af0c <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c010af2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010af2f:	c9                   	leave  
c010af30:	c3                   	ret    

c010af31 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010af31:	55                   	push   %ebp
c010af32:	89 e5                	mov    %esp,%ebp
c010af34:	83 ec 04             	sub    $0x4,%esp
c010af37:	8b 45 0c             	mov    0xc(%ebp),%eax
c010af3a:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010af3d:	eb 11                	jmp    c010af50 <strfind+0x1f>
        if (*s == c) {
c010af3f:	8b 45 08             	mov    0x8(%ebp),%eax
c010af42:	0f b6 00             	movzbl (%eax),%eax
c010af45:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010af48:	75 02                	jne    c010af4c <strfind+0x1b>
            break;
c010af4a:	eb 0e                	jmp    c010af5a <strfind+0x29>
        }
        s ++;
c010af4c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c010af50:	8b 45 08             	mov    0x8(%ebp),%eax
c010af53:	0f b6 00             	movzbl (%eax),%eax
c010af56:	84 c0                	test   %al,%al
c010af58:	75 e5                	jne    c010af3f <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c010af5a:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010af5d:	c9                   	leave  
c010af5e:	c3                   	ret    

c010af5f <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010af5f:	55                   	push   %ebp
c010af60:	89 e5                	mov    %esp,%ebp
c010af62:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010af65:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010af6c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010af73:	eb 04                	jmp    c010af79 <strtol+0x1a>
        s ++;
c010af75:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010af79:	8b 45 08             	mov    0x8(%ebp),%eax
c010af7c:	0f b6 00             	movzbl (%eax),%eax
c010af7f:	3c 20                	cmp    $0x20,%al
c010af81:	74 f2                	je     c010af75 <strtol+0x16>
c010af83:	8b 45 08             	mov    0x8(%ebp),%eax
c010af86:	0f b6 00             	movzbl (%eax),%eax
c010af89:	3c 09                	cmp    $0x9,%al
c010af8b:	74 e8                	je     c010af75 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c010af8d:	8b 45 08             	mov    0x8(%ebp),%eax
c010af90:	0f b6 00             	movzbl (%eax),%eax
c010af93:	3c 2b                	cmp    $0x2b,%al
c010af95:	75 06                	jne    c010af9d <strtol+0x3e>
        s ++;
c010af97:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010af9b:	eb 15                	jmp    c010afb2 <strtol+0x53>
    }
    else if (*s == '-') {
c010af9d:	8b 45 08             	mov    0x8(%ebp),%eax
c010afa0:	0f b6 00             	movzbl (%eax),%eax
c010afa3:	3c 2d                	cmp    $0x2d,%al
c010afa5:	75 0b                	jne    c010afb2 <strtol+0x53>
        s ++, neg = 1;
c010afa7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010afab:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010afb2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010afb6:	74 06                	je     c010afbe <strtol+0x5f>
c010afb8:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010afbc:	75 24                	jne    c010afe2 <strtol+0x83>
c010afbe:	8b 45 08             	mov    0x8(%ebp),%eax
c010afc1:	0f b6 00             	movzbl (%eax),%eax
c010afc4:	3c 30                	cmp    $0x30,%al
c010afc6:	75 1a                	jne    c010afe2 <strtol+0x83>
c010afc8:	8b 45 08             	mov    0x8(%ebp),%eax
c010afcb:	83 c0 01             	add    $0x1,%eax
c010afce:	0f b6 00             	movzbl (%eax),%eax
c010afd1:	3c 78                	cmp    $0x78,%al
c010afd3:	75 0d                	jne    c010afe2 <strtol+0x83>
        s += 2, base = 16;
c010afd5:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010afd9:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010afe0:	eb 2a                	jmp    c010b00c <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c010afe2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010afe6:	75 17                	jne    c010afff <strtol+0xa0>
c010afe8:	8b 45 08             	mov    0x8(%ebp),%eax
c010afeb:	0f b6 00             	movzbl (%eax),%eax
c010afee:	3c 30                	cmp    $0x30,%al
c010aff0:	75 0d                	jne    c010afff <strtol+0xa0>
        s ++, base = 8;
c010aff2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010aff6:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010affd:	eb 0d                	jmp    c010b00c <strtol+0xad>
    }
    else if (base == 0) {
c010afff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b003:	75 07                	jne    c010b00c <strtol+0xad>
        base = 10;
c010b005:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010b00c:	8b 45 08             	mov    0x8(%ebp),%eax
c010b00f:	0f b6 00             	movzbl (%eax),%eax
c010b012:	3c 2f                	cmp    $0x2f,%al
c010b014:	7e 1b                	jle    c010b031 <strtol+0xd2>
c010b016:	8b 45 08             	mov    0x8(%ebp),%eax
c010b019:	0f b6 00             	movzbl (%eax),%eax
c010b01c:	3c 39                	cmp    $0x39,%al
c010b01e:	7f 11                	jg     c010b031 <strtol+0xd2>
            dig = *s - '0';
c010b020:	8b 45 08             	mov    0x8(%ebp),%eax
c010b023:	0f b6 00             	movzbl (%eax),%eax
c010b026:	0f be c0             	movsbl %al,%eax
c010b029:	83 e8 30             	sub    $0x30,%eax
c010b02c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b02f:	eb 48                	jmp    c010b079 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010b031:	8b 45 08             	mov    0x8(%ebp),%eax
c010b034:	0f b6 00             	movzbl (%eax),%eax
c010b037:	3c 60                	cmp    $0x60,%al
c010b039:	7e 1b                	jle    c010b056 <strtol+0xf7>
c010b03b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b03e:	0f b6 00             	movzbl (%eax),%eax
c010b041:	3c 7a                	cmp    $0x7a,%al
c010b043:	7f 11                	jg     c010b056 <strtol+0xf7>
            dig = *s - 'a' + 10;
c010b045:	8b 45 08             	mov    0x8(%ebp),%eax
c010b048:	0f b6 00             	movzbl (%eax),%eax
c010b04b:	0f be c0             	movsbl %al,%eax
c010b04e:	83 e8 57             	sub    $0x57,%eax
c010b051:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b054:	eb 23                	jmp    c010b079 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010b056:	8b 45 08             	mov    0x8(%ebp),%eax
c010b059:	0f b6 00             	movzbl (%eax),%eax
c010b05c:	3c 40                	cmp    $0x40,%al
c010b05e:	7e 3d                	jle    c010b09d <strtol+0x13e>
c010b060:	8b 45 08             	mov    0x8(%ebp),%eax
c010b063:	0f b6 00             	movzbl (%eax),%eax
c010b066:	3c 5a                	cmp    $0x5a,%al
c010b068:	7f 33                	jg     c010b09d <strtol+0x13e>
            dig = *s - 'A' + 10;
c010b06a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b06d:	0f b6 00             	movzbl (%eax),%eax
c010b070:	0f be c0             	movsbl %al,%eax
c010b073:	83 e8 37             	sub    $0x37,%eax
c010b076:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010b079:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b07c:	3b 45 10             	cmp    0x10(%ebp),%eax
c010b07f:	7c 02                	jl     c010b083 <strtol+0x124>
            break;
c010b081:	eb 1a                	jmp    c010b09d <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c010b083:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b087:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b08a:	0f af 45 10          	imul   0x10(%ebp),%eax
c010b08e:	89 c2                	mov    %eax,%edx
c010b090:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b093:	01 d0                	add    %edx,%eax
c010b095:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c010b098:	e9 6f ff ff ff       	jmp    c010b00c <strtol+0xad>

    if (endptr) {
c010b09d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b0a1:	74 08                	je     c010b0ab <strtol+0x14c>
        *endptr = (char *) s;
c010b0a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b0a6:	8b 55 08             	mov    0x8(%ebp),%edx
c010b0a9:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010b0ab:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010b0af:	74 07                	je     c010b0b8 <strtol+0x159>
c010b0b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b0b4:	f7 d8                	neg    %eax
c010b0b6:	eb 03                	jmp    c010b0bb <strtol+0x15c>
c010b0b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010b0bb:	c9                   	leave  
c010b0bc:	c3                   	ret    

c010b0bd <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010b0bd:	55                   	push   %ebp
c010b0be:	89 e5                	mov    %esp,%ebp
c010b0c0:	57                   	push   %edi
c010b0c1:	83 ec 24             	sub    $0x24,%esp
c010b0c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b0c7:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010b0ca:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010b0ce:	8b 55 08             	mov    0x8(%ebp),%edx
c010b0d1:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010b0d4:	88 45 f7             	mov    %al,-0x9(%ebp)
c010b0d7:	8b 45 10             	mov    0x10(%ebp),%eax
c010b0da:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010b0dd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010b0e0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010b0e4:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010b0e7:	89 d7                	mov    %edx,%edi
c010b0e9:	f3 aa                	rep stos %al,%es:(%edi)
c010b0eb:	89 fa                	mov    %edi,%edx
c010b0ed:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010b0f0:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010b0f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010b0f6:	83 c4 24             	add    $0x24,%esp
c010b0f9:	5f                   	pop    %edi
c010b0fa:	5d                   	pop    %ebp
c010b0fb:	c3                   	ret    

c010b0fc <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010b0fc:	55                   	push   %ebp
c010b0fd:	89 e5                	mov    %esp,%ebp
c010b0ff:	57                   	push   %edi
c010b100:	56                   	push   %esi
c010b101:	53                   	push   %ebx
c010b102:	83 ec 30             	sub    $0x30,%esp
c010b105:	8b 45 08             	mov    0x8(%ebp),%eax
c010b108:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b10b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b10e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b111:	8b 45 10             	mov    0x10(%ebp),%eax
c010b114:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010b117:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b11a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010b11d:	73 42                	jae    c010b161 <memmove+0x65>
c010b11f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b122:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b125:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b128:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b12b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b12e:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010b131:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b134:	c1 e8 02             	shr    $0x2,%eax
c010b137:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010b139:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b13c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b13f:	89 d7                	mov    %edx,%edi
c010b141:	89 c6                	mov    %eax,%esi
c010b143:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010b145:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010b148:	83 e1 03             	and    $0x3,%ecx
c010b14b:	74 02                	je     c010b14f <memmove+0x53>
c010b14d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b14f:	89 f0                	mov    %esi,%eax
c010b151:	89 fa                	mov    %edi,%edx
c010b153:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010b156:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010b159:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010b15c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b15f:	eb 36                	jmp    c010b197 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010b161:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b164:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b167:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b16a:	01 c2                	add    %eax,%edx
c010b16c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b16f:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010b172:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b175:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c010b178:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b17b:	89 c1                	mov    %eax,%ecx
c010b17d:	89 d8                	mov    %ebx,%eax
c010b17f:	89 d6                	mov    %edx,%esi
c010b181:	89 c7                	mov    %eax,%edi
c010b183:	fd                   	std    
c010b184:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b186:	fc                   	cld    
c010b187:	89 f8                	mov    %edi,%eax
c010b189:	89 f2                	mov    %esi,%edx
c010b18b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010b18e:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010b191:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c010b194:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010b197:	83 c4 30             	add    $0x30,%esp
c010b19a:	5b                   	pop    %ebx
c010b19b:	5e                   	pop    %esi
c010b19c:	5f                   	pop    %edi
c010b19d:	5d                   	pop    %ebp
c010b19e:	c3                   	ret    

c010b19f <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010b19f:	55                   	push   %ebp
c010b1a0:	89 e5                	mov    %esp,%ebp
c010b1a2:	57                   	push   %edi
c010b1a3:	56                   	push   %esi
c010b1a4:	83 ec 20             	sub    $0x20,%esp
c010b1a7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b1ad:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b1b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b1b3:	8b 45 10             	mov    0x10(%ebp),%eax
c010b1b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010b1b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b1bc:	c1 e8 02             	shr    $0x2,%eax
c010b1bf:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010b1c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b1c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1c7:	89 d7                	mov    %edx,%edi
c010b1c9:	89 c6                	mov    %eax,%esi
c010b1cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010b1cd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010b1d0:	83 e1 03             	and    $0x3,%ecx
c010b1d3:	74 02                	je     c010b1d7 <memcpy+0x38>
c010b1d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b1d7:	89 f0                	mov    %esi,%eax
c010b1d9:	89 fa                	mov    %edi,%edx
c010b1db:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010b1de:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010b1e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010b1e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010b1e7:	83 c4 20             	add    $0x20,%esp
c010b1ea:	5e                   	pop    %esi
c010b1eb:	5f                   	pop    %edi
c010b1ec:	5d                   	pop    %ebp
c010b1ed:	c3                   	ret    

c010b1ee <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010b1ee:	55                   	push   %ebp
c010b1ef:	89 e5                	mov    %esp,%ebp
c010b1f1:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010b1f4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010b1fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b1fd:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010b200:	eb 30                	jmp    c010b232 <memcmp+0x44>
        if (*s1 != *s2) {
c010b202:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b205:	0f b6 10             	movzbl (%eax),%edx
c010b208:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b20b:	0f b6 00             	movzbl (%eax),%eax
c010b20e:	38 c2                	cmp    %al,%dl
c010b210:	74 18                	je     c010b22a <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010b212:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b215:	0f b6 00             	movzbl (%eax),%eax
c010b218:	0f b6 d0             	movzbl %al,%edx
c010b21b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b21e:	0f b6 00             	movzbl (%eax),%eax
c010b221:	0f b6 c0             	movzbl %al,%eax
c010b224:	29 c2                	sub    %eax,%edx
c010b226:	89 d0                	mov    %edx,%eax
c010b228:	eb 1a                	jmp    c010b244 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c010b22a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010b22e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c010b232:	8b 45 10             	mov    0x10(%ebp),%eax
c010b235:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b238:	89 55 10             	mov    %edx,0x10(%ebp)
c010b23b:	85 c0                	test   %eax,%eax
c010b23d:	75 c3                	jne    c010b202 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c010b23f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b244:	c9                   	leave  
c010b245:	c3                   	ret    
