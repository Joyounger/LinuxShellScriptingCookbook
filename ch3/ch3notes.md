

###### 3.3 查找并删除重复文件

```bash
#!/bin/bash
#Filename: remove_duplicates.sh
#Description:  Find and remove duplicate files and keep one sample of each file.

ls -lS --time-style=long-iso | awk 'BEGIN { 
  getline; getline; # 丢弃第一行
  name1=$8; size=$5 # 读取长文件列表的第一行8,5列
} 
{
  name2=$8; 
  if (size==$5) 
  { 
    "md5sum "name1 | getline; csum1=$1;
    "md5sum "name2 | getline; csum2=$1;
    if ( csum1==csum2 ) 
    {
      print name1; print name2
    }
  };

  size=$5; name1=name2; 
}' | sort -u > duplicate_files 


cat duplicate_files | xargs -I {} md5sum {} | sort | uniq -w 32 | awk '{ print "^"$2"$" }' | sort -u >  duplicate_sample
echo Removing..
# comm命令使用差集操作
# tee在将文件名传递给rm命令的同时,也起到了print的功能.tee将来自stdin的行写入文件
comm duplicate_files duplicate_sample  -2 -3 | tee /dev/stderr | xargs rm 
echo Removed duplicates files successfully.
```

awk中外部命令的输出可以用下面方法获取:
"cmd" | getline
随后可以在$0中获取命令的输出,在$1,$2,$3,$n中获取命令输出中的每一列.


###### 3.6 
目录有一个特殊的权限,粘滞位(sticky bit).当一个目录设置了粘滞位,只有创建该目录的用户才能删除目录中的文件,即使用户组和其他用户也有写权限.
粘滞位出现在其他用户权限位中的x位置,用t或T表示.如果没设置x,但设置了粘滞位,使用T.如果同时设置了粘滞位和执行权限.使用T
默认设置目录粘滞位的典型例子就是/tmp,粘滞位属于一种写保护

setuid只能用于ELF合适的二进制文件,不能用于脚本文件


###### 3.7 创建不可修改文件
某些文件属性可帮助我们将文件设置为不可修改.一旦文件被设置为不可修改,任何用户包括超级用户都不能删除该文件,除非其不可修改的属性被移除.
通过查看/etc/mtab文件,很容易找出所有挂载分区的文件系统类型.
chattr可将文件设置为不可修改:chattr +i file
chattr -i file 移除不可修改属性


###### 3.8 批量生成空白文件
for name in {1..100}.txt
do
  touch $name
done


###### 3.9 
打出符号链接指向的目标
ls -l symbol_link_name | awk '{ print $10 }' 或者 readlink symbol_link_name


###### 3.10 
生成文件统计信息的脚本如下:
```bash
#!/bin/bash
# Filename: filestat.sh
# usage: ./filestat.sh dir

if [ $# -ne 1 ];
then
  echo “Usage is $0 basepath”;
  exit
fi
path=$1

declare -A statarray;

while read line;
do
  ftype=`file -b "$line" | cut -d, -f1` # 用cut -d提取出文件类型第一段
  let statarray["$ftype"]++;
done < <(find $path -type f -print)   # <(find $path -type f -print) 等同于文件名,这里用子进程输出来代替文件名.

echo ============ File types and counts =============
for ftype in "${!statarray[@]}";
do
  echo $ftype :  ${statarray["$ftype"]}
done
```


###### 3.11 环回文件与挂载
环回文件系统是指那些在文件中而非物理设备中创建的文件系统.我们可以将这些文件挂载到挂载点上,就像设备一样.
我们通过将环回文件连接到一个设备文件来进行挂载(mount).环回文件系统的一个例子就是初始化内存文件,位于/boot/initrd.img,
这个文件中存储了一个用于内核的初始化文件系统.

如何在一个1GB的文件中创建ext4文件系统:
dd if=/dev/zero of=loopbackfile.img bs=1G count=1
可以发现创建的文件大小超过了1G,这是因为硬盘作为块设备,其分配存储空间是按照块的大小的整数倍来进行的.
用mkfs命令格式化此文件:
mkfs.ext4 loopbackfile.img
检查文件系统
sudo file loopbackfile.img
现在就可以挂载环回文件了:
mount -o loop loopbackfile.img /mnt/testdir # -o loop用于挂载环回文件系统
这是一种快捷的挂载方法,我们并没有连接到任何设备上,但是在内部这个环回文件连接到了一个名为/dev/loop1或loop2上

如果想创建一个硬盘文件,再对它分区并挂载其中某个分区,那就不能使用mount -o loop, 应该
losetup /dev/loop1 loopback.img
fdisk /dev/loop1
在loopback.img中创建分区并挂载第一个分区:
losetup -o 32256 /dev/loop2 loopback.img
现在/dev/loop2就代表第一个分区
-o表示偏移量,32256(512*63)字节是针对dos分区方案的一个设置.第一个分区自第32256字节之后开始
由于历史原因,硬盘第一个扇区作为mdr,其后的62个扇区作为保留扇区.
可以指定所需偏移量来设置第二个分区.挂载过分区后就可以像在物理设备上执行任何操作了.
当对挂载设备做出更改后,只有当缓冲区被写满之后才会进行设备写回.可以用sync命令强制立刻写入更改.

###### 3.12
创建iso镜像最好的方法是使用dd工具:
dd if=/dev/cdrom of=image.iso

###### 3.13
diff命令也能以递归的形式作用于目录,
-N:将所有缺失的文件视为空文件
-a:将所有文件视为文本文件
-u:生成一体化输出
-r:遍历目录下的所有文件

###### 3.15
只列出目录的方法:
1 
ls -d */
2 
ls -F | grep "/$"
3 
ls -l | grep "^d"
4
find . -type d -maxdepth 1 -print


###### 3.16
pushd和popd可用来在多个目录之间切换而无需复制粘贴目录路径,路径被压缩到栈中,用dirs查看栈的内容






