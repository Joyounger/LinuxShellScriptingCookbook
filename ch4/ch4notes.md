
1 迭代文件中的每一行,使用子shell的方法:
cat file.txt | ( while read line; do echo $line; done )
2 迭代一行中每一个单词
for word in $line
do
  echo $word;
done
3 迭代一个单词中的每一个字符:
for ((i=0; i<${#word}; i++))
do
  echo ${word:i:1}; #每次迭代中利用${str:start:num}从字符串中提取一个字符
done


用脚本检验回文字符串:
sed能记住之前匹配的正则表达式.这种能记忆并引用之前所匹配样式的能力就是所谓的反向引用.
```sed -n '/\(.\)\1/p' filename```
\(.\)的作用是记录()中的子串.这里出现的.(点号)是sed用于匹配单个字符的正则表达式.
\1对应()中匹配的第一处内容,\1对应第二处匹配


解析文本中的email和url:
能匹配一个电子邮件地址的egrep正则表达式如下:
[A-Za-z0-9.]+@[A-Za-z0-9.]+\.[a-zA-Z]{2,4}
匹配一个http url的egrep正则表达式如下:
http://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,4}






