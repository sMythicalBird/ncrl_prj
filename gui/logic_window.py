# -*- coding: utf-8 -*-
"""
@file: logic_window.py
@time: 2024/8/5
@auther: sMythicalBird
"""
# LoginWindow 类

from .main_window import MainWindow
from PySide6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QLabel,
    QLineEdit,
    QPushButton,
    QMessageBox,
)
from PySide6.QtGui import QGuiApplication


class LoginWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.init_ui()

    def init_ui(self):
        self.setWindowTitle("Login")
        self.setGeometry(100, 100, 300, 200)

        layout = QVBoxLayout()

        username_layout = QHBoxLayout()
        self.username_label = QLabel("Username:")
        self.username_input = QLineEdit()
        username_layout.addWidget(self.username_label)
        username_layout.addWidget(self.username_input)

        password_layout = QHBoxLayout()
        self.password_label = QLabel("Password:")
        self.password_input = QLineEdit()
        self.password_input.setEchoMode(QLineEdit.Password)
        password_layout.addWidget(self.password_label)
        password_layout.addWidget(self.password_input)

        self.login_button = QPushButton("Login")
        self.login_button.clicked.connect(self.check_login)

        layout.addLayout(username_layout)
        layout.addLayout(password_layout)
        layout.addWidget(self.login_button)

        self.setLayout(layout)
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

    def check_login(self):
        username = self.username_input.text()
        password = self.password_input.text()
        if username == "admin" and password == "123456":
            self.accept_login()
        else:
            QMessageBox.warning(self, "Error", "Bad user or password")

    def accept_login(self):
        self.main_window = MainWindow()
        self.main_window.show()
        self.close()
