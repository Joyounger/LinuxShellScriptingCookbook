




###### 5.13 用post方式发送网页并读取响应
curl中用-d/--data以post方式发送数据
wget的--post-data "string"可以post方式发送数据
post方式用于提交表单
通过post发送数据并检索输出,来自动化HTTP get和post请求,在编写解析网站数据的shell脚本过程中,是一项非常重要的任务.

curl URL -d/--data "postvar1=postdata1&postvar2=postdata2"
如果要发送多个变量,用&分隔. 如果使用了&,"名称-值"对应以引用形式出现.否则shell会将其看作是用于后台进程的特殊符号

```html
form action="http://.../submit.php"
metod="post" >

<input type="text" name="host" value="HOSTNAME" >
<input type="text" name="user" value="USER" >
<input type="submit" >
</form>
```

curt http://.../submit.php -d "host=test-host&user=slynux"
<html>
you have entered:
<p>HOST: test-host</p>
<p>USER: slynux</p>
<html>

