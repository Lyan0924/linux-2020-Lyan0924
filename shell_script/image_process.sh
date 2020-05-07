#!/usr/bin/env bash

function help()
{
	echo "usage:"
	# dir为指定目录

	echo "-q  [quality][dir]      对jpeg格式图片进行图片质量压缩，质量因子大小为quality"
	echo "-r  [resolution][dir]      对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩分辨率"
	echo "-w  [watermarking][dir]      对图片批量添加自定义文本水印"
	echo "-p  [place][text][dir]      批量重命名,place=0统一添加文件名前缀，place=1添加后缀，不影响原始文件扩展名"
	echo "-t  [dir]      将png/svg图片统一转换为jpg格式图片"
	echo "-h            帮助文档"
}

function jpeg_compression()
{

	quality=$1;
	dir=$2;

	images=($(find "${dir}" -regex '.*\(jpg\|JPG\|jpeg\)')) #统计图片目录下所有JPEG图像
	for image in "${images[@]}";do
		name=${image%.*}
		tail=${image##*.}
		out=$name"_${quality}."$tail
		convert -quality ${quality} $image $out
		echo "$image is compressed with quality=$quality"
	done
}

function resolution_compression()
{
	percent=$1
	dir=$2

	images=($(find "${dir}" -regex '.*\(png\|svg\|jpeg\|jpg\)'))
	for image in "${images[@]}";do
		name=${image%.*}
		tail=${image##*.}
		out=$name"_${percent}%."$tail
		convert -resize $percent'%x'$percent'%' $image $out #以percent%的大小压缩其分辨率
		echo "$image is compressed"
	done
}

function add_watermark()
{
	text=$1
	dir=$2
			
	images=($(find "${dir}" -regex '.*\(png\|svg\|jpeg\|jpg\)'))
	for image in "${images[@]}";do
		name=${image%.*}
		tail=${image##*.}
		out=$name"_wtmed."$tail
		convert -gravity southeast -fill black -pointsize 16 -draw "text 5,5 '$text'" $image $out  #将text内容添加到图片的右下角，字体颜色为黑色，大小为16
		echo "watermark is added into $image"
	done
}

function change_filename()
{
	place=$1
	text=$2
	dir=$3

	images=($(find "${dir}" -regex '.*\(png\|svg\|jpeg\|jpg\)'))
	for image in "${images[@]}";do
		path=${image%/*}
		name=${image##/*}
		name=${name%.*}
		tail=${image##*.}

		if [[ $place -eq 0 ]];then mv $image $path'/'$text$name'.'$tail;fi #添加前缀内容
		if [[ $place -eq 1 ]];then mv $image $path'/'$name$text'.'$tail;fi #添加后缀内容
		echo "image_name is changed"
	done
}

function change2jpeg()
{
	dir=$1

	images=($(find "${dir}" -regex '.*\(png\|svg\)'))
	for image in "${images[@]}";do
		convert $image "${image%.*}.jpg"
		echo "image is changed into jpeg image"
	done
}


while [ "$1" != "" ];do
	case "$1" in
		"-q")
			jpeg_compression $2 $3
			exit 0
			;;
		"-r")
			resolution_compression $2 $3
			exit 0
			;;
		"-w")
			add_watermark $2 $3
			exit 0
			;;
		"-p")
			change_filename $2 $3 $4
			exit 0
			;;
		"-t")
			change2jpeg $2 $3
			exit 0
			;;
		"-h")
			help
			exit 0
			;;
	esac
done
