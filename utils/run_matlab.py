# -*- coding: utf-8 -*-
"""
@file: run_matlab.py
@time: 2024/8/4
@auther: sMythicalBird
"""
import matlab.engine
from .init import mat_code_path


def run_matlab(file_path: str):
    test_path = mat_code_path / file_path
    print(test_path)
    # 尝试启动MATLAB引擎
    eng = matlab.engine.start_matlab()
    print("MATLAB Engine is started.")
    # 添加MATLAB代码目录到MATLAB引擎的搜索路径
    directories = [d for d in mat_code_path.iterdir() if d.is_dir()]    # 获取matlab程序目录下的所有文件夹
    for path in directories:
        eng.addpath(str(path), nargout=0)

    # 运行test.m文件并捕获输出
    output = eng.evalc("run('{}')".format(test_path))
    print(output)
    # 关闭matlab引擎
    eng.quit()
