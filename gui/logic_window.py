# -*- coding: utf-8 -*-
"""
@file: logic_window.py
@time: 2024/8/5
@auther: sMythicalBird
"""
from PyQt5.QtWidgets import (
    QApplication,
    QWidget,
    QVBoxLayout,
    QLabel,
    QLineEdit,
    QPushButton,
    QMessageBox,
    QHBoxLayout,
    QMainWindow,
    QAction,
    QFormLayout,
    QSpinBox,
    QDoubleSpinBox,
)
from .main_window import MainWindow


class LoginWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.initUI()

    def initUI(self):
        self.setWindowTitle("Login")
        self.setGeometry(100, 100, 300, 200)

        layout = QVBoxLayout()

        # 用户名输入框
        username_layout = QHBoxLayout()
        self.username_label = QLabel("Username:")
        self.username_input = QLineEdit()
        username_layout.addWidget(self.username_label)
        username_layout.addWidget(self.username_input)
        # 密码输入框
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

    # 账户密码验证
    def check_login(self):
        username = self.username_input.text()
        password = self.password_input.text()
        if (
            username == "admin" and password == "123456"
        ):  # Simple check for demonstration
            self.accept_login()
        else:
            QMessageBox.warning(self, "Error", "Bad user or password")

    # 打开主窗口，关闭登陆界面
    def accept_login(self):
        self.main_window = MainWindow()
        self.main_window.show()
        self.close()
