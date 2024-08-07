# -*- coding: utf-8 -*-
"""
@file: main_window.py
@time: 2024/8/5
@auther: sMythicalBird
"""
from PySide6.QtWidgets import (
    QWidget,
    QMainWindow,
    QFormLayout,
    QSpinBox,
    QDoubleSpinBox,
)
from PySide6.QtGui import QGuiApplication


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.initUI()

    def initUI(self):
        self.setWindowTitle("Main Window")
        self.setGeometry(100, 100, 400, 300)

        self.form_layout = QFormLayout()

        self.int_param = QSpinBox()
        self.double_param = QDoubleSpinBox()

        self.form_layout.addRow("Integer Parameter:", self.int_param)
        self.form_layout.addRow("Double Parameter:", self.double_param)

        self.central_widget = QWidget()
        self.central_widget.setLayout(self.form_layout)
        self.setCentralWidget(self.central_widget)
        self.center()

    def center(self):
        screen_geometry = (
            QGuiApplication.primaryScreen().availableGeometry()
        )  # 获取主屏幕的可用几何信息
        window_geometry = self.frameGeometry()  # 获取当前窗口的几何信息
        window_geometry.moveCenter(
            screen_geometry.center()
        )  # 将窗口几何的中心移动到屏幕几何的中心
        self.move(window_geometry.topLeft())  # 将窗口移动到调整后的窗口几何的左上角
