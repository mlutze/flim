namespace Flim/Interpreter {
    use Flim/Ast.{Program, Line, Command};

    pub enum Error

    enum Next {
        case Continue
        case Done
    }

    type alias Slim = {
        regNames :: Map[String, Int],
        registers :: Vector[Int],
        stack :: Vector[Int],
        line :: Int,
        code :: Vector[Line],
        write :: Int -> Unit & Impure,
        read :: Unit -> Option[Int] & Impure
    }

    pub def defaultSlim(p: Program): Slim & Impure = {
        let scanner = Flim/Utils/Io.stdinScanner();
        let Program.Program(lines) = p;
        let code = lines |> Vector.fromList;
        {
            regNames = Map.empty(),
            registers = Vector.empty(),
            stack = Vector.empty(),
            line = 0,
            code = code,
            write = println,
            read = () -> Flim/Utils/Io.readInt(scanner)
        }
    }

    def currentLine(slim: Slim): Line = {
        Vector.get(slim.line, slim.code)
    }

    pub def execute(slim: Slim): Result[Slim, Error] & Impure = {
        let l = currentLine(slim);
        match executeLine(slim, l) {
            case Ok(s, Continue) => execute(s)
            case Ok(s, Done) => Ok(s)
            case Err(e) => Err(e)
        }
    }

    def executeLine(slim: Slim, line: Line): Result[(Slim, Next), Error] & Impure = match line {
        case Line.Alloc(regs0) =>
            let nextReg = Map.size(slim.regNames);
            let regs = regs0 |> List.mapWithIndex((reg, i) -> (reg, nextReg + i)) |> List.toMap;
            Ok({ regNames = regs, line = slim.line + 1 | slim }, Continue)

        case Line.Blank =>
            Ok({ line = slim.line + 1 | slim }, Continue)
        
        case Line.Cmd(Command.Halt) =>
            Ok(slim, Done)

        case _ => ??? as & Impure
    }
}