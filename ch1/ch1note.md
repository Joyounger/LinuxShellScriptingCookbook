unix中用sharp或hash(有时是mesh)来称呼字符'#',用bang来称呼惊叹号"!",
因而shebang就是就代表"#!"


如果将脚本作为bash的命令行参数来运行,就用不着脚本中第一行的shebang.

如果有需要的话,可以利用shebang来实现脚本的独立运行,对比必须设置脚本的可执行权限,这样脚本可以使用位于#!之后的解释器路径来运行了


对于root用户, 它的主目录~为 /root

登陆shell是登陆主机后获得的那个shell,如果登陆gui环境(如gnome)后打开了一个shell,则不属于登陆shell  

当shell是交互式登录shell时，读取.bash_profile文件，如在系统启动、远程登录或使用su -切换用户时；当shell是交互式登录和非登录shell时都会读取.bashrc文件，如：在图形界面中打开新终端或使用su切换用户时，均属于非登录shell的情况。简单的说，.bash_profile只在会话开始时被读取一次，而.bashrc则每次打开新的终端时，都会被读取。


######1.2 终端打印
默认情况下,echo每次调用后会添加一个换行符

1 使用不带引号的echo时,没法在所要显示的文本中使用分号(;),因为分号在bash shell中被用作命令界定符
2 使用带单引号的echo时, 变量替换在单引号中无效
3 使用带双引号的echo时, 要在双引号中打印"!",则应该使用"\!"
如果要使用转义序列,则采用echo -e "包含转义序列的字符串"这种形式


printf:
printf的%s,%c,%d,%f成为格式替换符(format substitution character)

带选项执行echo或printf时,要确保选项应该出现在命令行内所有字符串之前,否则bash会将其视为另一个字符串  

要打印彩色文本,可输出如下命令:
echo -e "\e[1;31m This is red text \e[0m"
\e[1;31将颜色设置为红色,\e[0m将颜色重置. 只需将31替换为想要的颜色码就行了.
彩色文本常使用的颜色码为:重置=0,黑色=30,红色=31,绿色=32,黄色=33,蓝色=34,洋红=35,青色=36,白色=37
要打印彩色背景,可输出如下命令:
echo -e "\e[1;42m This is green background \e[0m"
彩色背景常使用的颜色码为:重置=0,黑色=40,红色=41,绿色=42,黄色=43,蓝色=44,洋红=45,青色=46,白色=47


######1.3 玩转变量和环境变量
对于进程来说,其运行时的环境变量可以使用下面的命令来查看:
cat /proc/$PID/environ

1 赋值操作val=value,如果value不包含任何空白字符,则不需要用引号引用,否则必须用单引号或双引号
2 比较操作val = value

一个变量被export之后,从当前shell脚本执行的任何应用程序都会继承这个变量


获得变量值的长度 length = ${#var}
识别当前使用的shell: echo $0 或 echo $SHELL
检查是否为root用户:
```bash
if [ $UID -ne 0 ]; then
  echo "non root user. please run as root"
else
  echo "root"
fi
```

有一些特殊的字符可以扩展成系统参数,例如\u可以扩展为用户名,\h可以扩展为主机名,\w可以扩展为当前工作目录


######1.4 使用函数添加环境变量 
可以把下面的函数添加进~/.bashrc,
prepend() { [ -d "$2" ] && eval $1=\"$2':'\$$1\" && export $1; }
像下面这样来使用  
prepend PATH /opt/myapp/bin(等价于export PATH=/opt/myapp/bin:$PATH)
prepend LD_LIBRARY_PATH /opt/myapp/lib(等价于export LD_LIBRARY_PATH=/opt/myapp/lib:$LD_LIBRARY_PATH)
prepend函数先检查该函数第二个参数所指定的目录是否存在,如果存在eval表达式将第一个参数所指定的变量值设置成第二个参数的值加上":"(路径分隔符),随后再跟上首个参数的原始值.
如果变量为空,会在末尾留下一个分号":",要解决这个问题,可以将该函数再进行一次修改:
prepend() { [ -d "$2" ] && eval $1=\"$2\$\{$1:+':'\$$1\}\" && export $1; }
这样当追加环境变量时,当且仅当旧值存在,才会增加

######1.5 使用shell进行算数运算
再bash shell中,可以利用let, (())和[]执行基本的算数操作.高级算数操作可以用expr和bc
可以用bc执行浮点数运算并应用一些高级函数:
echo "4 * 0.56" | bc
no=54;
result=`echo "$no * 1.5" | bc`
echo $result
其他参数可置于要执行的具体操作之前,同时以分号作为界定符,通过stdin传给bc:
1 设定小数精度: echo "scale=2;3/8" | bc
2 进制转换: 
no=100
echo "obase=2;$no" | bc
no=1100100
echo "obase=10;ibase=2;$no" | bc
3 计算平方以及平方根:
echo "sqrt(100)" | bc #square root
echo "10^10" |  bc #Squre

######1.6 文件描述符及重定向
cmd 2>&1 output.txt 或者 cmd &> output.txt

如果对stderr或stdout进行重定向,被重定向的文本会传入文件.因为文本已经被重定向到文件中,也就没剩下什么东西可以通过管道(|)传给接下来的命令,而这些命令是通过stdin进行接收的
有一个方法既可以将数据重定向到文件,还可以提供一份重定向数据的副本作为后续命令的stdin.这一切都可以使用tee.

重定向操作符默认使用标准输出,如果想使用特定的文件描述符,你必须将文件描述符支付置于操作符前
>等同于1>, >>等同于1>>

从stdin读取输入的命令能以多种方式接受数据,也可以用cat和管道来制定我们自己的文件描述符  
1 将文件重定向到命令: cmd < file
2 将脚本内部的文本块进行重定向:
cat <<EOF>log.txt
LOG FILE HEADER
This is a test log file
Function: System statistics
EOF
3 自定义文件描述符
可以使用exec来创建自己的文件描述符,<操作符用于从文件中读取至stdin. >操作符用于截断模式的文件写入(数据在目标文件内容被截断之后写入)>>操作符用于追加模式的文件写入.文件描述符可以用以上三种模式中的任意一种来创建.
创建一个文件描述符进行读取:
echo "this is a test line" > input.txt
exec 3<input.txt #使用文件描述符3打开并读取文件
cat <&3
如果需要再次读取,不能继续使用文件描述符3了.而是需要使用exec重新分配文件描述符3来进行二次读取.


######1.7 
























