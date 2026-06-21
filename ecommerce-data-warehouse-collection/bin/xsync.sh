#!/bin/bash
# 集群分发脚本
# 用法: xsync <文件或目录>

if [ $# -lt 1 ]; then
    echo "用法: xsync <文件或目录>"
    exit 1
fi

for file in "$@"; do
    if [ -e "$file" ]; then
        dirname=$(dirname "$file")
        basename=$(basename "$file")
        abs_path=$(cd "$dirname" && pwd)/"$basename"
        for host in hadoop102 hadoop103 hadoop104; do
            echo "同步到 $host:$abs_path"
            rsync -av "$abs_path" "$host:$abs_path"
        done
    else
        echo "$file 不存在"
    fi
done
echo "========== 同步完成 =========="
