namespace Flim/Parser {
    use FlixParsec.Parser;
    use FlixParsec/Token.LanguageDef;
    use FlixParsec/Combinators.sepBy1;
    use FlixParsec/Text.{makePattern, horizontalWhiteSpace, alphanums, alphas, newline, restOfLine};
    use FlixParsec/Combinators.{sepBy, optionalWithDefault, <!>};
    use FlixParsec/Prim.{flatMap, return, endOfInput};
    use FlixParsec/TokenSimple.symbol;
    use FlixParsec/TokenSimple.comma;
    use FlixParsec/TokenSimple.semi;
    use FlixParsec/TokenSimple.colon;
    use FlixParsec/Regex.lookingAt;

    use Flim/Ast.{Program, Line};

    pub def parse(input: String): Result[Program, String] = {
        FlixParsec/Prim.parsesString(program(), input) as & Pure // TODO the parser lib needs to be effect-poly for lifted actions?
    }

    def program(): Parser[a, Program] = {
        let* lines = sepBy(line(), newline());
        let* _ = endOfInput();
        return(Program.Program(lines))
    }

    def line(): Parser[a, Line] = {
        alloc() <!> label() <!> blank()
    }

    def blank(): Parser[a, Line] = {
        let* _ = endOfLine();
        return(Line.Blank)
    }

    def alloc(): Parser[a, Line] = {
        let* _ = symbol("allocate-registers");
        let* _ = horizontalWhiteSpace();
        let* regs = wsCommaSep1(regName());
        let* _ = endOfLine();
        return(Line.Alloc(regs))
    }

    def label(): Parser[a, Line] = {
        let* l = labelName();
        let* _ = colon();
        let* _ = endOfLine();
        return(Line.Lab(l))
    }

    def wsCommaSep1(p: Parser[a, String]): Parser[a, List[String]] = {
        let wsCommaWs = {
            let* _ = horizontalWhiteSpace();
            let* _ = comma();
            let* _ = horizontalWhiteSpace();
            return()
        };
        sepBy1(p, wsCommaWs)
    }

    def endOfLine(): Parser[a, Unit] = {
        let* _ = horizontalWhiteSpace();
        let* _ = optionalWithDefault(comment(), ());
        return()
    }

    def comment(): Parser[a, Unit] = {
        let* _ = semi();
        let* _ = restOfLine(false);
        return()
    }

    def regName(): Parser[a, String] = {
        let* start = alphas();
        let* end = optionalWithDefault(alphanums(), "");
        return(start + end)
    }

    def labelName(): Parser[a, String] = {
        let* start = alphas();
        let* end = optionalWithDefault(alphanums(), "");
        return(start + end)
    }
}