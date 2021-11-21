namespace Flim/Main {
    use GetOpt.{ArgDescr, OptionDescr};
    use GetOpt.ArgOrder;
    use GetOpt.ArgDescr.ReqArg;
    use GetOpt.getOpt;
    use GetOpt.usageInfo;

    use Flim/Parser.parse;
    use Flim/Error.Error;
    use Flim/Utils/Io.readToString;

    use Flim/Interpreter.Slim;

    pub def main(args: Array[String]): Int32 & Impure = {
        use Result.flatMap;
        match getOpt(ArgOrder.Permute, options(), args) {
            case Success(opts) =>
                match {
                    let* settings = mkSettings(opts);
                    run(settings)
                } {
                    case Ok(_) => 0
                    case Err(e) => println(e); 1
                }
            case Failure(_) =>
                println(usageInfo("", options())); // TODO print to stderr
                1
        }
    }

    type alias Settings = {
        stack :: Int32,
        registers :: Int32,
        file :: String
    }

    def defaultStack(): Int32 = 1024

    def defaultRegisters(): Int32 = 32

    def mkSettings(opts: {options :: List[Flag], nonOptions :: List[String]}): Result[Settings, Error] = {
        use Result.flatMap;
        // TODO more validation on stack size bounds
        let stacks = opts.options |> List.filterMap(
            f -> match f {
                case Flag.Stack(i) => Some(i)
                case _ => None
            }
        );
        let registerss = opts.options |> List.filterMap(
            f -> match f {
                case Flag.Registers(i) => Some(i)
                case _ => None
            }
        );

        let stack = Option.getWithDefault(stacks |> List.last, defaultStack());
        let registers = Option.getWithDefault(registerss |> List.last, defaultRegisters());
        let* file = match opts.nonOptions {
            case f :: Nil => Ok(f)
            case _ => Err(Error.Loading("exactly one file must be specified"))
        };
        Ok({stack = stack, registers = registers, file = file})
    }

    def run(opts: Settings): Result[Unit, Error] & Impure = {
        use Result.flatMap;
        let* code = readToString(opts.file) |> Result.mapErr(Error.Loading);
        let* ast = parse(code) |> Result.mapErr(Error.Parse);
        let slim = mkSlim(opts, ast);
        Flim/Interpreter.execute(slim) |> Result.mapErr(Error.Runtime)
    }

    def mkSlim(settings: Settings, p: Flim/Ast.Program): Slim & Impure = {
        registers = Array.new(0, settings.registers),
        stack = Array.new(0, settings.stack) 
        | Flim/Interpreter.defaultSlim(p)
    }

    enum Flag with ToString {
        case Stack(Int32)
        case Registers(Int32)
    }

    def options(): List[OptionDescr[Flag]] = {
        {optionIds = 's' :: Nil, optionNames = "stack" :: Nil, argDescriptor = ReqArg(stack, "<stack size>"), explanation = "maximum stack size"} ::
        {optionIds = 'r' :: Nil, optionNames = "registers" :: Nil, argDescriptor = ReqArg(registers, "<registers>"), explanation = "number of registers to use"} ::
        Nil
    }

    def stack(y: String): Option[Flag] = Int32.fromString(y) |> Result.toOption |> Option.map(Flag.Stack)

    def registers(y: String): Option[Flag] = Int32.fromString(y) |> Result.toOption |> Option.map(Flag.Registers)
}

def main(args: Array[String]): Int32 & Impure = 
    Flim/Main.main(args)