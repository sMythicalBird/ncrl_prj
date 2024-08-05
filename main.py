# -*- coding: utf-8 -*-
"""
@file: main.py
@time: 2024/8/4
@auther: sMythicalBird
"""

import tkinter as tk
from tkinter import ttk


def main():
    # 创建主窗口
    root = tk.Tk()
    root.title("Simple GUI")

    # 设置窗口大小
    root.geometry("400x300")

    # 创建一个标签
    label = ttk.Label(root, text="Hello, Tkinter!")
    label.pack(pady=20)

    # 创建一个按钮
    button = ttk.Button(
        root, text="Click Me", command=lambda: label.config(text="Button Clicked!")
    )
    button.pack(pady=10)

    # 运行主循环
    root.mainloop()


if __name__ == "__main__":
    main()
