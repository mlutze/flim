namespace Flim/Parser {
    use FlixParsec.Parser;
    use FlixParsec/Token.LanguageDef;
    use FlixParsec/Combinators.sepBy1;
    use FlixParsec/Text.{makePattern, horizontalWhiteSpace, alphanums, alphas, newline};
    use FlixParsec/Combinators.{sepBy, optionalWithDefault};
    use FlixParsec/Prim.{flatMap, return, endOfInput};
    use FlixParsec/TokenSimple.symbol;
    use FlixParsec/TokenSimple.comma;
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
        alloc()
    }

    def alloc(): Parser[a, Line] = {
        let* _ = symbol("allocate-registers");
        let* _ = horizontalWhiteSpace();
        let* regs = wsCommaSep1(regName());
        return(Line.Alloc(regs))
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

    def regName(): Parser[a, String] = {
        let* start = alphas();
        let* end = optionalWithDefault(alphanums(), "");
        return(start + end)
    }
}