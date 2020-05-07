#!/usr/bin/env bash

function help()
{
	echo "usage:"

	echo "-a	不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比"
	echo "-b	不同场上位置的球员数量、百分比"
	echo "-c	统计名字最长的球员、名字最短的球员"
	echo "-d	统计年龄最大的球员、年龄最小的球员"
	echo "-h	查看帮助文档"
}

function age_info()
{
	awk -F "\t" '
	BEGIN{

	l20=0
	m=0
	g30=0

	printf "年龄范围\t20岁以下\t20—30之间\t30岁以上\n"
	printf "------------------------------------------------------\n"
	}

	{
		if($6 != "Age")
		{
		if ($6< 20 )
			{l20+=1}
		else if ( $6>=20&&$6<=30)
			{m+=1}
		else {g30+=1}
		}
	}

	END{

		sum=l20+m+g30
		printf "数量\t\t%d\t%d\t%d \n", l20, m, g30
		printf "百分比\t\t%.3f%\t%.3f%\t%.3f% \n", l20/sum*100, m/sum*100, g30/sum*100
	}
	' ./worldcupplayerinfo.tsv
}

function position_info()
{
	awk -F "\t" '
	BEGIN{

		sum=0
	}

	{
		if( $5!="Position")
		{
		position[$5]+=1
		sum+=1
		}
	}

	END{
		printf "位置\t球员数量\t百分比\n"
		printf "---------------------------------------------\n"
		for(i in position){printf "%s\t%d\t%.3f%\n",i,position[i],position[i]/sum*100}
	}' worldcupplayerinfo.tsv
}

function name_length()
{

	max=0
	min=100000

	names=$(awk -F "\t" '{if($9!="Player"){print length($9)}}' worldcupplayerinfo.tsv)

	for name in $names;do
		if [[ $name -gt $max ]];then
			max=$name
		fi
		if [[ $name -lt $min ]];then
			min=$name
		fi
	done
	echo "名字最长的球员是："
	awk -F "\t" '{if(length($9)=='$max'){printf "%s\n",$9}}' worldcupplayerinfo.tsv
	echo "名字最短的球员是："
         awk -F "\t" '{if(length($9)=='$min'){printf "%s\n",$9}}' worldcupplayerinfo.tsv
	
	
}

function Age_info
{
	min=100000
	max=0

	ages=$(awk -F "\t" '{if($6!="Age"){print $6}}' worldcupplayerinfo.tsv)

	for age in $ages;do
		if [[ $age -gt $max ]];then
			max=$age
		fi
		if [[ $age -lt $min ]];then
			min=$age
		fi
	done
	echo "年龄最大的球员是："
	awk -F "\t" '{if( $6=='$max'){printf "%s %d\n",$9,$6}}' worldcupplayerinfo.tsv
	echo "年龄最小的球员是: "
         awk -F "\t" '{if( $6=='$min'){printf "%s %d\n",$9,$6}}' worldcupplayerinfo.tsv
	

}

while [ "$1" != "" ];do
       case $1 in
	       -a) age_info
		   exit 0
		   ;;
	       -b) position_info
		   exit 0
		   ;;
	       -c) name_length
		   exit 0
		   ;;
	       -d) Age_info
		   exit 0
		   ;;
	       -h) help
		   exit 0
		   ;;
   esac
done
