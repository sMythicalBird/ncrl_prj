# -*- coding: utf-8 -*-
"""
@file: test.py
@time: 2024/8/4
@auther: sMythicalBird
"""
from gui.logic_window import LoginWindow
import sys
from PyQt5.QtWidgets import QApplication

if __name__ == "__main__":
    app = QApplication(sys.argv)
    login_window = LoginWindow()
    login_window.show()
    sys.exit(app.exec_())
