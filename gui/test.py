# -*- coding: utf-8 -*-
"""
@file: test.py
@time: 2024/8/4
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
    QMainWindow,
    QAction,
    QFormLayout,
    QSpinBox,
    QDoubleSpinBox,
)
import sys


class LoginWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.initUI()

    def initUI(self):
        self.setWindowTitle("Login")
        self.setGeometry(100, 100, 300, 200)

        layout = QVBoxLayout()

        self.username_label = QLabel("Username:")
        self.username_input = QLineEdit()
        self.password_label = QLabel("Password:")
        self.password_input = QLineEdit()
        self.password_input.setEchoMode(QLineEdit.Password)

        self.login_button = QPushButton("Login")
        self.login_button.clicked.connect(self.check_login)

        layout.addWidget(self.username_label)
        layout.addWidget(self.username_input)
        layout.addWidget(self.password_label)
        layout.addWidget(self.password_input)
        layout.addWidget(self.login_button)

        self.setLayout(layout)

    def check_login(self):
        username = self.username_input.text()
        password = self.password_input.text()

        if (
            username == "admin" and password == "password"
        ):  # Simple check for demonstration
            self.accept_login()
        else:
            QMessageBox.warning(self, "Error", "Bad user or password")

    def accept_login(self):
        self.main_window = MainWindow()
        self.main_window.show()
        self.close()


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


if __name__ == "__main__":
    app = QApplication(sys.argv)
    login_window = LoginWindow()
    login_window.show()
    sys.exit(app.exec_())
