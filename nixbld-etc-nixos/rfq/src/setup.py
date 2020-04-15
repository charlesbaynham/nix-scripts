from setuptools import setup
from setuptools import find_packages

setup(
    name='rfq',
    version='1.0.0',
    packages=find_packages(),
    zip_safe=False,
    install_requires=[
        'Flask',
        'Flask-Mail',
        'python-dotenv'
    ]
)
