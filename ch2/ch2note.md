

###### 2.12 


%输入非贪婪(non-greedy)操作符,它从右到左找出匹配通配符的最短结果.
%%输入贪婪(greedy)操作符,它从右到左找出匹配通配符的最长结果.
$ VAR=hack.fun.book.txt
$ echo ${VAR%.*}
hack.fun.book
$ echo ${VAR%%.*}
hack

#与%类似,但匹配方向是从左到右
与%%类似,#也有一个相对应的贪婪操作符##


转换文件名大小写
rename 'y/A-Z/a-z/' *
rename 'y/a-z/A-Z/' *



###### 2.14 拼写检查与词典操作
/usr/share/dict下包含了一些词典文件, 可使用脚本检查给定的单词是否为词典中的单词:
```bash
#!/bin/bash
word=$1
grep "^$1$" /usr/share/dict/british-english -q
if [ $? -eq 0 ]; then
  echo $word is a dictionary
else
  echo $word is not a dictionary
fi
```

也可以用拼写检查命令aspell检查某个单词是否在词典中:
```bash
word=$1
output=`echo \"$word\" | aspell list`
if [ -z $output ]; then
  echo $word is a dictionary
else
  echo $word is not a dictionary
fi
```


###### 2.15 交互输入自动化
通过发送与用户输入等同的字符串, 就可以实现在交互过程中自动发送输入

用这个脚本进行自动化的演示:
```bash
!/bin/bash
# internative.sh
read -p "enter number:" no;
read -p "enter name:" name;
echo you have entered $no, $name
```
按下面的方法向脚本自动发送输入:
echo -e "1\nhello\n" | ./interactive.sh
如果输入文本比较多,那么可以用单独的输入文件结合重定向操作符来提供输入:
echo -e "1\nhello\n" > input.data
./interactive.sh < input.data


###### 2.16 利用并行进程加速命令执行
以md5sum为例, 如果多个文件需要生产校验和,可使用
```bash
#!/bin/bash
# generate_checksums.sh
PIDARRAY=()
for file in File1.iso File2.iso
do
  md5sum $file &
  PIDARRAY+=("$!")
done
wait ${PIDARRAY[@]}
```
利用了bash的操作符&. 它使得shell将命令置于后台并继续执行脚本.这意味着一旦循环结束,脚本就会退出,
而md5sum仍在后台运行.为了避免这种情况,使用$!来获得进程pid,$!保存最近一个后台进程pid.我们将这些pid放入数组,然后使用wait命令等待这些进程结束.



