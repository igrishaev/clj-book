
# https://github.com/pygments/pygments/blob/master/pygments/styles/bw.py
# https://github.com/pygments/pygments/blob/48e55050f8bec34d57a1a86e06e779c6288b8341/pygments/lexers/jvm.py#L736

from pygments.style import Style
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic

GRAY = "#555"

class PrintStyle(Style):
    default_style = "bw"
    styles = {
        Keyword:                "bold",
        Generic.Emph:           "noitalic",
        String:                 "nobold",
        String.Symbol:          GRAY,
        Comment:                "noitalic " + GRAY,
        Name.Function:          "bold",
    }
