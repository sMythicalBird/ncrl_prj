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
