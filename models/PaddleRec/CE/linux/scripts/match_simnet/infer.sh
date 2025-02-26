#!/usr/bin/env bash
#外部传入参数说明
# $1: 'single' 单卡训练； 'multi' 多卡训练； 'cpu' cpu 训练
#获取当前路径
cur_path=`pwd`
model_name=$2
temp_path=$(echo $2|awk -F '_' '{print $2}')
echo "$2 infer";

#路径配置
root_path=$cur_path/../../
code_path=$cur_path/../../PaddleRec/models/match/multiview-simnet/
log_path=$root_path/log/match_simnet/
mkdir -p $log_path
#临时环境更改

#访问RD程序,包含eval过程
print_info(){
if [ $1 -ne 0 ];then
    cat ${log_path}/$2.log
    echo "exit_code: 1.0" >> ${log_path}/$2.log
    mv ${log_path}/$2.log ${log_path}/F_$2.log
    echo -e "\033[31m ${log_path}/F_$2 \033[0m"
else
    echo "exit_code: 0.0" >> ${log_path}/$2.log
    cat ${log_path}/$2.log
    mv ${log_path}/$2.log ${log_path}/S_$2.log
    echo -e "\033[32m ${log_path}/S_$2 \033[0m"
fi
}


cd $code_path
echo -e "\033[32m `pwd` infer \033[0m";

sed -i "s/  epochs: 2/  epochs: 1/g" config_bigdata.yaml
sed -i "s/  infer_end_epoch: 2/  infer_end_epoch: 1/g" config_bigdata.yaml
# linux infer
if [ "$1" = "linux_dy_gpu1" ];then #单卡
    sed -i "s/  use_gpu: False/  use_gpu: True/g" config_bigdata.yaml
    python -u ../../../tools/infer.py -m config_bigdata.yaml -o runner.infer_load_path="output_model_simnet_all_dy_gpu1" > ${log_path}/$2.log 2>&1
    print_info $? $2
    rm -rf result.txt;
    cp ${log_path}/S_$2.log result.txt

elif [ "$1" = "linux_dy_gpu2" ];then #多卡
    sed -i "s/  use_gpu: False/  use_gpu: True/g" config_bigdata.yaml
    # 多卡的运行方式
    python -m paddle.distributed.launch ../../../tools/infer.py -m config_bigdata.yaml -o runner.infer_load_path="output_model_simnet_all_dy_gpu2" >${log_path}/$2.log 2>&1
    print_info $? $2
    rm -rf result.txt;
    cp log/wokerlog.0 result.txt;

elif [ "$1" = "linux_dy_cpu" ];then
    python -u ../../../tools/infer.py -m config.yaml -o runner.infer_load_path="output_model_simnet_all_dy_cpu" > ${log_path}/$2.log 2>&1
    print_info $? $2
    rm -rf result.txt;
    cp ${log_path}/S_$2.log result.txt

elif [ "$1" = "linux_st_gpu1" ];then #单卡
    sed -i "s/  use_gpu: False/  use_gpu: True/g" config_bigdata.yaml
    python -u ../../../tools/static_infer.py -m config_bigdata.yaml -o runner.infer_load_path="output_model_simnet_all_st_gpu1" > ${log_path}/$2.log 2>&1
    print_info $? $2
    rm -rf result.txt;
    cp ${log_path}/S_$2.log result.txt

elif [ "$1" = "linux_st_gpu2" ];then #多卡
    sed -i "s/  use_gpu: False/  use_gpu: True/g" config_bigdata.yaml
    # 多卡的运行方式
    python -m paddle.distributed.launch ../../../tools/static_infer.py -m config_bigdata.yaml -o runner.infer_load_path="output_model_simnet_all_st_gpu2" >${log_path}/$2.log 2>&1
    print_info $? $2
    rm -rf result.txt;
    cp log/wokerlog.0 result.txt;
    mv $code_path/log $log_path/$2_dist_log

elif [ "$1" = "linux_st_cpu" ];then
    python -u ../../../tools/static_infer.py -m config.yaml -o runner.infer_load_path="output_model_simnet_all_st_cpu" > ${log_path}/$2.log 2>&1
    print_info $? $2
    rm -rf result.txt;
    cp ${log_path}/S_$2.log result.txt
# mac small_data infer
elif [ "$1" = "mac_dy_cpu" ];then
    python -u ../../../tools/infer.py -m config.yaml -o runner.infer_load_path="output_model_simnet_all_mac_dy_cpu" > ${log_path}/$2.log 2>&1
    print_info $? $2
    rm -rf result.txt;
    cp ${log_path}/S_$2.log result.txt

elif [ "$1" = "mac_st_cpu" ];then
    python -u ../../../tools/static_infer.py -m config.yaml -o runner.infer_load_path="output_model_simnet_all_mac_st_cpu" > ${log_path}/$2.log 2>&1
    print_info $? $2
    rm -rf result.txt;
    cp ${log_path}/S_$2.log result.txt

else
    echo "$model_name infer.sh  parameter error "
fi

python transform.py > ${log_path}/$2_transform.log 2>&1
print_info $? $2_transform
python ../../../tools/cal_pos_neg.py pair.txt > ${log_path}/$2_pair.log 2>&1
print_info $? $2_pair
