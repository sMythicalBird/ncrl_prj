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
from PySide6.QtGui import QGuiApplication, QPixmap
from PySide6.QtCore import Qt
from utils.init import root_path


class LoginWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.init_ui()

    def init_ui(self):
        self.setWindowTitle("Login")
        self.setGeometry(100, 100, 300, 200)

        # 新建布局
        layout = QVBoxLayout()
        layout.setContentsMargins(10, 10, 10, 10)  # 设置容器的边距（左，上，右，下）
        layout.setSpacing(30)  # 设置容器内控件之间的间距

        # 标题布局
        title_layout = QHBoxLayout()
        self.logic_label = QLabel()
        self.logic_label.setFixedSize(100, 100)
        logic_img_path = root_path / "res/img/seu.png"
        logic_pix = QPixmap(str(logic_img_path))
        scaled_pix = logic_pix.scaled(self.logic_label.size(), Qt.KeepAspectRatio)
        self.logic_label.setPixmap(scaled_pix)
        self.logic_text = QLabel("登陆系统")
        self.logic_text.setStyleSheet("font-size: 40px")
        self.logic_text.setFixedSize(500, 100)
        self.logic_text.setAlignment(Qt.AlignCenter)  # 标签中给的文字放置在中间
        title_layout.addWidget(self.logic_label)
        title_layout.addWidget(self.logic_text)
        # 创建一个 QWidget 作为容器，并设置背景颜色
        title_container = QWidget()
        title_container.setLayout(title_layout)
        title_container.setStyleSheet("background-color: lightblue;")
        # 将容器添加到主布局中
        layout.addWidget(title_container)

        # 用户名密码布局
        # 创建一个 QVBoxLayout 作为容器的布局
        credentials_layout = QVBoxLayout()
        credentials_layout.setContentsMargins(50, 20, 50, 20)
        credentials_layout.setSpacing(10)  # 设置容器内控件之间的间距
        # 用户名布局
        username_layout = QHBoxLayout()
        self.username_label = QLabel("Username:")
        self.username_label.setFixedSize(80, 30)  # 设置标签的尺寸
        self.username_label.setAlignment(Qt.AlignCenter)  # 标签中给的文字放置在中间
        self.username_input = QLineEdit()
        self.username_input.setFixedSize(200, 30)  # 设置用户名输入框的尺寸
        username_layout.addWidget(self.username_label)
        username_layout.addWidget(self.username_input)
        # 创建一个 QHBoxLayout 来包含用户名布局并使其居中
        username_center_layout = QHBoxLayout()
        username_center_layout.addStretch()  # 添加弹性空间
        username_center_layout.addLayout(username_layout)
        username_center_layout.addStretch()  # 添加弹性空间
        # 密码布局
        password_layout = QHBoxLayout()
        self.password_label = QLabel("Password:")
        self.password_label.setFixedSize(80, 30)  # 设置标签的尺寸
        self.password_label.setAlignment(Qt.AlignCenter)  # 标签中给的文字放置在中间
        self.password_input = QLineEdit()
        self.password_input.setEchoMode(QLineEdit.Password)
        self.password_input.setFixedSize(200, 30)  # 设置密码输入框的尺寸
        password_layout.addWidget(self.password_label)
        password_layout.addWidget(self.password_input)
        # 创建一个 QHBoxLayout 来包含密码布局并使其居中
        password_center_layout = QHBoxLayout()
        password_center_layout.addStretch()  # 添加弹性空间
        password_center_layout.addLayout(password_layout)
        password_center_layout.addStretch()  # 添加弹性空间
        # 将居中布局添加到容器布局中
        credentials_layout.addLayout(username_center_layout)
        credentials_layout.addLayout(password_center_layout)

        # 登录按钮
        self.login_button = QPushButton("Login")
        self.login_button.setFixedSize(100, 40)  # 设置按钮的宽度和高度
        self.login_button.clicked.connect(self.check_login)

        # 创建一个 QHBoxLayout 来包含按钮并使其居中
        button_layout = QHBoxLayout()
        button_layout.addStretch()  # 添加弹性空间
        button_layout.addWidget(self.login_button)
        button_layout.addStretch()  # 添加弹性空间

        layout.addLayout(credentials_layout)
        layout.addLayout(button_layout)

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
