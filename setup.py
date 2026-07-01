#!/usr/bin/env python3
"""
Setup script for Slither.io for Linux
Install with: pip install -e .
"""

from setuptools import setup, find_packages

setup(
    name="slither-io-linux",
    version="0.1.0",
    description="Slither.io game client for Linux",
    author="ristorr",
    packages=find_packages(),
    install_requires=[
        "pygame>=2.0.0",
        "numpy>=1.19.0",
    ],
    entry_points={
        "console_scripts": [
            "slither-io=slither_io.main:main",
        ],
    },
    python_requires=">=3.6",
    include_package_data=True,
)
