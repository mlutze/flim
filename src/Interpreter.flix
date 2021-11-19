namespace Flim/Interpreter {
    use Flim/Ast.{Program, Line, Command};

    pub enum Error

    enum Next {
        case Continue
        case Done
    }

    type alias Slim = {
        regNames :: MutMap[String, Int],
        registers :: Array[Int],
        stack :: MutList[Int],
        line :: Ref[Int],
        code :: Array[Line],
        write :: Int -> Unit & Impure,
        read :: Unit -> Option[Int] & Impure
    }

    pub def defaultSlim(p: Program): Slim & Impure = {
        let scanner = Flim/Utils/Io.stdinScanner();
        let Program.Program(lines) = p;
        let code = lines |> List.toArray;
        {
            regNames = MutMap.empty(),
            registers = [32; 0],
            stack = MutList.new(),
            line = ref 0,
            code = code,
            write = println,
            read = () -> Flim/Utils/Io.readInt(scanner)
        }
    }

    def currentLine(slim: Slim): Line & Impure = {
       (slim.code)[deref slim.line]
    }

    pub def execute(slim: Slim): Result[Unit, Error] & Impure = {
        let l = currentLine(slim);
        match executeLine(slim, l) {
            case Ok(Continue) => execute(slim)
            case Ok(Done) => Ok()
            case Err(e) => Err(e)
        }
    }

    def executeLine(slim: Slim, line: Line): Result[Next, Error] & Impure = match line {
        case Line.Alloc(regs0) =>
            let nextReg = MutMap.size(slim.regNames);
            regs0 |> List.mapWithIndex((reg, i) -> (reg, i)) |> 
                List.foreach(match (reg, i) -> MutMap.put!(reg, i + nextReg, slim.regNames));
            slim.line := deref slim.line + 1;
            Ok(Continue)

        case Line.Blank =>
            slim.line := deref slim.line + 1;
            Ok(Continue)
        
        case Line.Cmd(Command.Halt) =>
            Ok(Done)

        case _ => ??? as & Impure
    }
}