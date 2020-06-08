#!/bin/bash
#nginx + php72
#
#========================
#verName

#========安裝================
echo "即將開始進入更安及更新"
echo "名子會成為目錄名稱"
read -p "Your English Name : " varName
#=====如果不是ROOT權限會無法使用=========
echo "yum nginx源配置"
sudo cat>/etc/yum.repos.d/nginx.repo<<EOF
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF
#===========開始安裝=============================
sudo yum install epel-release -y
sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
sudo yum install yum-utils -y
sudo yum-config-manager --enable remi-php72 &> /dev/null
sudo yum update -y
sudo yum install php72 -y
sudo yum install php72-php-fpm php72-php-gd php72-php-json php72-php-mbstring php72-php-mysqlnd php72-php-xml php72-php-xmlrpc php72-php-opcache -y
sudo yum install -y nginx
sudo yum install -y vim
sudo systemctl enable php72-php-fpm.service
sudo systemctl enable nginx 
#========配置vim=========
#vim 行號 不亂碼
sudo cat>~/.vimrc<<EOF
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
set nu
EOF
#=======目錄創建===========
sudo mkdir -p /web/$varName/php/WebRoot ;sudo mkdir -p /log/$varName/php/logs
#======创建文件========
touch /web/$varName/php//WebRoot/test.php
#=====配置php72=======
sed -i '24cuser = nginx' /etc/opt/remi/php72/php-fpm.d/www.conf
sed -i '26cgroup = nginx' /etc/opt/remi/php72/php-fpm.d/www.conf
sed -i '38clisten = 127.0.0.1:9001' /etc/opt/remi/php72/php-fpm.d/www.conf
#====配置nginx=======
sed -i '3cworker_processes  auto;' /etc/nginx/nginx.conf
sed -i '5cerror_log  /log/'''$varName'''/php/logs/error.log warn;' /etc/nginx/nginx.conf
sed -i '22c    access_log  /log/'''$varName'''/php/logs/access.log  main;' /etc/nginx/nginx.conf
sed -i '2c        listen       9999 default_server;' /etc/nginx/conf.d/default.conf
sed -i '9c        root         /web/'''$varName'''/php/WebRoot;' /etc/nginx/conf.d/default.conf
sed -i '10c    index test.php index.php index.html;' /etc/nginx/conf.d/default.conf
sed -i '30c    location ~ \.php$ {' /etc/nginx/conf.d/default.conf
sed -i '31c    root           /web/'''$varName'''/php/WebRoot;' /etc/nginx/conf.d/default.conf
sed -i '32c    fastcgi_pass   127.0.0.1:9001;' /etc/nginx/conf.d/default.conf
sed -i '33c    fastcgi_index  index.php;' /etc/nginx/conf.d/default.conf
sed -i '34c    fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;' /etc/nginx/conf.d/default.conf
sed -i '35c    include        fastcgi_params;' /etc/nginx/conf.d/default.conf
sed -i '36c     }' /etc/nginx/conf.d/default.conf
#=====test.php文件内容======
sudo cat>/web/$varName/php//WebRoot/test.php<<EOF
<html>
<head>
    <title>php test page</title>
</head>
<body>
    <?php
    echo '<p>php test page for $varName </p>';
    ?>
</body>
</html>
EOF
#=====php.php文件内容======
sudo cat>/web/$varName/php//WebRoot/php.php<<EOF
<?php
  // test script for CentOS/RHEL 7+PHP 7.2+Nginx 
  phpinfo();
?>
EOF
# ======關閉selinux======
setenforce 0
sed -i '7cSELINUX=disabled' /etc/selinux/config
#======啟動===========
sudo systemctl enable nginx php72-php-fpm.service
sudo systemctl start nginx php72-php-fpm.service
#====监听检查=============
sudo netstat -lpnt |grep tcp
