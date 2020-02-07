
# https://github.com/pygments/pygments/blob/master/pygments/styles/bw.py
from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic

class YourStyle(Style):
    default_style = "bw"
    styles = {
        String:                 'noitalic',
        Comment:                'noitalic #555',
        Keyword:                'bold',
        Name.Function:          'bold',
    }
