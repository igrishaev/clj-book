from setuptools import setup, find_packages

setup(
    name='pyg-print',
    version='0.1',
    description='Custom style for pygments.',
    keywords='pygments style print',
    license='BSD',

    author='Ivan Grishaev',
    author_email='ivan@grishaev.me',

    url='https://github.com/igrishaev/clj-book/pyg-print',

    packages=find_packages(),
    install_requires=['pygments == 2.5.2'],

    entry_points='''[pygments.styles]
                    print=pyg_print_style:PrintStyle''',

    classifiers=[
        'Development Status :: 3 - Alpha',
        'Environment :: Plugins',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 3',
        'Topic :: Software Development :: Libraries :: Python Modules',
    ],
)
