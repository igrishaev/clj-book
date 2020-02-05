from pygments.lexers.jvm import ClojureLexer


class CustomLexer(ClojureLexer):

    declarations = ClojureLexer.declarations + ("deftest", )
