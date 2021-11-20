namespace Flim/Parser {
    use FlixParsec.Parser;
    use FlixParsec/Token.LanguageDef;
    use FlixParsec/Combinators.sepBy1;
    use FlixParsec/Text.{makePattern, horizontalWhiteSpace, alphanums, alphas, newline, restOfLine, digits};
    use FlixParsec/Combinators.{sepBy, optionalWithDefault, <!>};
    use FlixParsec/Prim.{flatMap, return, endOfInput, fail};
    use FlixParsec/TokenSimple.comma;
    use FlixParsec/TokenSimple.semi;
    use FlixParsec/TokenSimple.colon;
    use FlixParsec/Regex.lookingAt;
    use FlixParsec/Char.string;

    use Flim/Ast.{Program, Line, Arg, Command};

    pub def parse(input: String): Result[Program, String] = {
        FlixParsec/Prim.parsesString(program(), input) as & Pure // TODO the parser lib needs to be effect-poly for lifted actions?
    }

    def program(): Parser[a, Program] = {
        let* lines = sepBy(line(), newline());
        let* _ = endOfInput();
        return(Program.Program(lines))
    }

    def line(): Parser[a, Line] = {
        let* _ = horizontalWhiteSpace();
        alloc() <!> label() <!> command() <!> blank()
    }

    def blank(): Parser[a, Line] = {
        let* _ = endOfLine();
        return(Line.Blank)
    }

    def alloc(): Parser[a, Line] = {
        let* _ = string("allocate-registers");
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

    def command(): Parser[a, Line] = {
        let* c = commandN();
        let* _ = endOfLine();
        return(Line.Cmd(c))
    }

    def commandN(): Parser[a, Command] = {
        command3Helper(Command.Add, "add") <!>
        command3Helper(Command.Sub, "sub") <!>
        command3Helper(Command.Mul, "mul") <!>
        command3Helper(Command.Div, "div") <!>
        command3Helper(Command.Quo, "quo") <!>
        command3Helper(Command.Rem, "rem") <!>

        command3Helper(Command.Seq, "seq") <!>
        command3Helper(Command.Sne, "sne") <!>
        command3Helper(Command.Slt, "slt") <!>
        command3Helper(Command.Sgt, "sgt") <!>
        command3Helper(Command.Sle, "sle") <!>
        command3Helper(Command.Sge, "sge") <!>

        command2Helper(Command.Ld, "ld") <!>
        command2Helper(Command.St, "st") <!>

        command2Helper(Command.Li, "li") <!>

        command1Helper(Command.Read, "read") <!>
        command1Helper(Command.Write, "write") <!>

        command2Helper(Command.Jeqz, "jeqz") <!>
        command1Helper(Command.J, "j") <!>

        command0Helper(Command.Halt, "halt")

    }

    def command3Helper(cst: ((Arg, Arg, Arg)) -> Command, name: String): Parser[a, Command] = {
        let* _ = string(name);
        let* _ = horizontalWhiteSpace();
        let* r1 = arg();
        let* _ = wsCommaWs();
        let* r2 = arg();
        let* _ = wsCommaWs();
        let* r3 = arg();
        return(cst((r1, r2, r3)))
    }

    def command2Helper(cst: ((Arg, Arg)) -> Command, name: String): Parser[a, Command] = {
        let* _ = string(name);
        let* _ = horizontalWhiteSpace();
        let* r1 = arg();
        let* _ = wsCommaWs();
        let* r2 = arg();
        return(cst((r1, r2)))
    }

    def command1Helper(cst: Arg -> Command, name: String): Parser[a, Command] = {
        let* _ = string(name);
        let* _ = horizontalWhiteSpace();
        let* r1 = arg();
        return(cst(r1))
    }

    def command0Helper(cmd: Command, name: String): Parser[a, Command] = {
        let* _ = string(name);
        return(cmd)
    }

    def wsCommaWs(): Parser[a, Unit] = {
        let* _ = horizontalWhiteSpace();
        let* _ = comma();
        let* _ = horizontalWhiteSpace();
        return()
    }
    
    def wsCommaSep1(p: Parser[a, String]): Parser[a, List[String]] = {
        sepBy1(p, wsCommaWs())
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

    def regName(): Parser[a, String] = identifier()

    def labelName(): Parser[a, String] = identifier()

    def identifier(): Parser[a, String] = {
        let* start = alphas();
        let* sep = optionalWithDefault(string("-"), "");
        let* parts = sepBy(alphanums(), string("-"));
        return(start + sep + String.intercalate("-", parts))
    }

    def arg(): Parser[a, Arg] = {
        let num = {
            let* str = digits();
            let* n = Int32.fromString(str) |> Result.map(return) |> {s -> Result.getWithDefault(s, fail("illegal int"))};
            return(Arg.Num(n))
        };
        let name = {
            let* n = identifier();
            return(Arg.Name(n))
        };
        num <!> name
    }
}