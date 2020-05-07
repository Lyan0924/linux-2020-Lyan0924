#!/usr/bin/env bash

function help()
{
	echo "usage:"

	echo "-a	统计访问来源主机TOP 100和分别对应出现的总次数"
	echo "-b	统计访问来源主机TOP 100 IP和分别对应出现的总次数
	echo "-c	统计最频繁被访问的URL TOP 100
	echo "-d	统计不同响应状态码的出现次数和对应百分比
	echo "-e	分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
	echo "-f URL	给定URL输出TOP 100访问来源主机
	echo "-h	帮助文档
}

function host()
{
	echo "主机			次数"
	echo "------------------------"

	awk -F "\t" '

	NR>1{
			host_num[$1]+=1
	}

	END{
	for(i in host_num)
	{
	printf "%s\t%d\n",i,host_num[i]
	}}' web_log.tsv | sort -n -r -k 2| head -n 100
}

function host_ip()
{
	echo "主机ip			次数"
	echo "------------------------"

	awk -F "\t" '

	NR>1{
		if($1~/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/)
			{host_ip[$1]+=1}
	}

	END{
	for(i in host_ip)
	{
	printf "%s\t%d\n",i,host_ip[i]
	}}' web_log.tsv | sort -n -r -k 2| head -n 100
}

function url_fre()
{
	echo "最频繁被访问的URL		访问次数"
	echo "----------------------------------"

	awk -F "\t" '

	NR>1{
		url[$5]+=1
	}

	END{
	for(i in url)
	{
	printf "%s\t%d\n",i,url[i]
	}}' web_log.tsv | sort -n -r -k 2| head -n 100

}
function response()
{
	echo "响应码	次数	百分比"
	echo "---------------------------"

	awk -F "\t" '

	BEGIN{
	sum=0
	}

	NR>1{
	if($6!="response")
		{
			number[$6]+=1
			sum++
		}
	}

	END{
	for(i in number)
	{
	printf "%s\t%d\t%.5f%\n",i,number[i],number[i]/sum*100
	}}' web_log.tsv 

}

function num_4xx()
{
	echo "403状态码对应的top10 url"
	echo "url		出现次数"
	echo "------------------------"

	awk -F "\t" '
	NR>1{
	if($6=="403")
		{
			url_403[$5]++
		}
	}

	END{
	for(i in url_403)
	{
	printf "%s\t%d\n",i,url_403[i]
	}}' web_log.tsv | sort -n -r -k 2| head -n 10
	
	echo "404状态码对应的top10 url"
	echo "url		出现次数"
	echo "------------------------"

	awk -F "\t" '
	NR>1{
	if($6=="404")
		{
			url_404[$5]++
		}
	}

	END{
	for(i in url_404)
	{
	printf "%s\t%d\n",i,url_404[i]
	}}' web_log.tsv | sort -n -r -k 2| head -n 10

}
function url_spe()
{
	url=$1
	echo "指定URL：$1"
	echo "访问来源主机			次数"
	echo "---------------------------------------"

	awk -F "\t" '

	NR>1{
	if($5=="'"$url"'")
		{
			host[$1]+=1
		}
	}

	END{
	for(i in host)
	{
	printf "%s\t%d\n",i,host[i]
	}}' web_log.tsv | sort -n -r -k 2| head -n 100

}






while [ "$1" != "" ];do
	case $1 in
	-a)
		host
		exit 0
		;;
  	-b)
		host_ip
		exit 0
		;;
	-c)
		url_fre
		exit 0
		;;
	-d)
		response
		exit 0
		;;
	-e)
		num_4xx
		exit 0
		;;
	-f)
		url_spe $2
		exit 0
		;;
	-h)
		help
		exit 0
		;;
esac
done
