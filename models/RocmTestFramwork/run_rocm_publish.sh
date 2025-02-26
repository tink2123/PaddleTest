# paddle
wget $2 --no-proxy
python -m pip uninstall -y paddlepaddle-rocm
python -m pip install $3
echo 'paddle commit:'
python -c 'import paddle; print(paddle.__version__, paddle.version.commit)'

# pytest dependency
python -m pip install pytest -i https://pypi.tuna.tsinghua.edu.cn/simple
python -m pip install pytest-assume -i https://pypi.tuna.tsinghua.edu.cn/simple
python -m pip install pytest-html -i https://pypi.tuna.tsinghua.edu.cn/simple
python -m pip install pytest-timeout -i https://pypi.tuna.tsinghua.edu.cn/simple
python -m pip install pytest-repeat -i https://pypi.tuna.tsinghua.edu.cn/simple
pytest -sv . --html=report_$1/rocm_$1.html --capture=tee-sys
tar cf report_$1.tar report_$1

# pytest -sv  --count=10 -x test_seg_models.py::test_fastscnn_cityscapes_1024x1024_160k
