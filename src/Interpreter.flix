namespace Flim/Interpreter {
    use Flim/Ast.{Program, Line, Command, Arg};

    pub enum Error {
        case UnknownRegister(String)
        case UnknownLabel(String)
        case IoError(String)
    }

    enum Next {
        case Continue
        case Done
    }

    type alias Slim = {
        regNames :: MutMap[String, Int],
        registers :: Array[Int],
        stack :: Array[Int],
        line :: Ref[Int],
        code :: Array[Line],
        labels :: Map[String, Int],
        write :: Int -> Unit & Impure,
        read :: Unit -> Result[Int, String] & Impure
    }

    def defaultStackSize(): Int = 1024

    pub def defaultSlim(p: Program): Slim & Impure = {
        let scanner = Flim/Utils/Io.stdinScanner();
        let Program.Program(lines) = p;
        let code = lines |> List.toArray;
        let labels = lines 
            |> List.mapWithIndex((l, i) -> (l, i)) 
            |> List.filterMap(
                match (l, i) -> match l {
                    case Line.Lab(name) => Some(name, i)
                    case _ => None
                }
            )
            |> List.toMap;
        {
            regNames = MutMap.empty(),
            registers = [32; 0],
            stack = [defaultStackSize(); 0],
            line = ref 0,
            code = code,
            labels = labels,
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
        
        case Line.Cmd(cmd) => executeCommand(slim, cmd)

        case _ => ??? as & Impure
    }

    def executeCommand(slim: Slim, cmd: Command): Result[Next, Error] & Impure = {
        use Result.flatMap;
        match cmd {
            case Command.Add(dst, src1, src2) => command3Helper(slim, (x, y) -> x + y, dst, src1, src2)
            case Command.Sub(dst, src1, src2) => command3Helper(slim, (x, y) -> x - y, dst, src1, src2)
            case Command.Mul(dst, src1, src2) => command3Helper(slim, (x, y) -> x * y, dst, src1, src2)
            case Command.Div(dst, src1, src2) => command3Helper(slim, (x, y) -> x / y, dst, src1, src2)
            case Command.Quo(dst, src1, src2) => command3Helper(slim, (x, y) -> x / y, dst, src1, src2)
            case Command.Rem(dst, src1, src2) => command3Helper(slim, (x, y) -> x rem y, dst, src1, src2)

            case Command.Seq(dst, src1, src2) => command3Helper(slim, (x, y) -> boolToInt(x == y), dst, src1, src2)
            case Command.Sne(dst, src1, src2) => command3Helper(slim, (x, y) -> boolToInt(x != y), dst, src1, src2)
            case Command.Slt(dst, src1, src2) => command3Helper(slim, (x, y) -> boolToInt(x < y), dst, src1, src2)
            case Command.Sgt(dst, src1, src2) => command3Helper(slim, (x, y) -> boolToInt(x > y), dst, src1, src2)
            case Command.Sle(dst, src1, src2) => command3Helper(slim, (x, y) -> boolToInt(x <= y), dst, src1, src2)
            case Command.Sge(dst, src1, src2) => command3Helper(slim, (x, y) -> boolToInt(x >= y), dst, src1, src2)

            case Command.Ld(dst, addrReg) =>
                let* addr = getRegisterContents(slim, addrReg);
                let val = (slim.stack)[addr]; // TODO handle OOB
                let* _ = setRegisterContents(slim, dst, val);
                incrLine(slim);
                Ok(Continue)
            case Command.St(src, addrReg) =>
                let* addr = getRegisterContents(slim, addrReg);
                let* val = getRegisterContents(slim, src);
                (slim.stack)[addr] = val; // TODO handle OOB
                incrLine(slim);
                Ok(Continue)

            case Command.Li(dst, val) =>
                let* v = match val {
                    case Arg.Name(lab) => lookupLabel(slim, lab)
                    case Arg.Num(i) => Ok(i)
                };
                let* _ = setRegisterContents(slim, dst, v);
                incrLine(slim);
                Ok(Continue)
            
            // TODO advance line for everyone
            case Command.Read(dst) =>
                let* val = (slim.read)() |> Result.mapErr(IoError);
                let* _ = setRegisterContents(slim, dst, val);
                incrLine(slim);
                Ok(Continue)
            
            case Command.Write(src) =>
                let* val = getRegisterContents(slim, src);
                (slim.write)(val);
                incrLine(slim);
                Ok(Continue)
            
            case Command.Jeqz(src, addrReg) =>
                let* val = getRegisterContents(slim, src);
                if (val == 0) {
                    let* addr = getRegisterContents(slim, addrReg);
                    let i = (slim.stack)[addr]; // TODO handl OOB
                    slim.line := i;
                    Ok(Continue)
                } else {
                    incrLine(slim);
                    Ok(Continue)
                }
            case Command.J(addrReg) =>
                let* addr = getRegisterContents(slim, addrReg);
                let i = (slim.stack)[addr]; // TODO handl OOB
                slim.line := i;
                Ok(Continue)

            case Command.Halt => Ok(Done)
        }
    }

    def command3Helper(slim: Slim, f: (Int, Int) -> (Int), dst: Arg, src1: Arg, src2: Arg): Result[Next, Error] & Impure = {
        use Result.flatMap;
        let* v1 = getRegisterContents(slim, src1);
        let* v2 = getRegisterContents(slim, src2);
        let res = f(v1, v2);
        let* _ = setRegisterContents(slim, dst, res);
        incrLine(slim);
        Ok(Continue)
    }

    def getRegisterContents(slim: Slim, reg: Arg): Result[Int, Error] & Impure = {
        use Result.flatMap;
        let* regNum = match reg {
            case Arg.Num(i) => Ok(i)
            case Arg.Name(n) => lookupRegister(slim, n)
        };
        Ok((slim.registers)[regNum]) // TODO handle OOB
    }

    def setRegisterContents(slim: Slim, reg: Arg, val: Int): Result[Unit, Error] & Impure = {
        use Result.flatMap;
        let* regNum = match reg {
            case Arg.Num(i) => Ok(i)
            case Arg.Name(n) => lookupRegister(slim, n)
        };
        Ok((slim.registers)[regNum] = val)
    }

    def lookupRegister(slim: Slim, reg: String): Result[Int, Error] & Impure = {
        match MutMap.get(reg, slim.regNames) {
            case Some(i) => Ok(i)
            case None => Err(UnknownRegister(reg))
        }
    }

    def lookupLabel(slim: Slim, lab: String): Result[Int, Error] = {
        match Map.get(lab, slim.labels) {
            case Some(i) => Ok(i)
            case None => Err(UnknownLabel(lab))
        }
    }

    def boolToInt(b: Bool): Int = if (b) 1 else 0

    def incrLine(slim: Slim): Unit & Impure = {
        slim.line := deref slim.line + 1
    }
}