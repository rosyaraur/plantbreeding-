# core_logic/python_package/setup.py
from setuptools import setup, find_packages

setup(
    name="plantbreeding_py",
    version="2.0.0",
    author="Umesh R. Rosyara",
    author_email="rosyaraur@gmail.com",
    description="Python suite for analysis of plant breeding and genetics experiments.",
    packages=find_packages(), # Automatically finds the 'plantbreeding_py' folder
    install_requires=[
        "numpy>=1.21.0",
        "pandas>=1.3.0",
        "scipy>=1.7.0",             # For general stats and matrix math
        "statsmodels>=0.13.0",      # For ANOVA, linear models, and mixed effects
        "scikit-learn>=1.0.2",      # For PCA (GGE Biplots) and clustering
        "matplotlib>=3.5.0",        # For plotting
        "seaborn>=0.11.2",          # For advanced statistical plotting
        # "patsy>=0.5.2",           # Usually required alongside statsmodels for R-like formulas
    ],
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.8',
)
