namespace Flim/TestUtils {
    use Flim/Ast.Program;
    use Flim/Interpreter.defaultSlim;
    use Flim/Interpreter.execute;
    use Flim/Interpreter.RuntimeError;

    use Flim/Parser.parse;

    pub def mkInterpreterTest(code: Program, input: List[Int], expected: List[Int]): Bool & Impure = {
        let inIter = input |> List.toIterator;
        let out = MutList.new();

        let slim = {
            write = i -> MutList.push!(i, out),
            read = () -> Flim/Utils/Iter.next(inIter)
            | defaultSlim(code)
        };

        execute(slim);
        let actual = out |> MutList.toList;
        expected == actual
    }

    pub def mkInterpreterFail(code: Program, input: List[Int], expected: RuntimeError): Bool & Impure = {
        let inIter = input |> List.toIterator;

        let slim = {
            write = _ -> () as & Impure,
            read = () -> Flim/Utils/Iter.next(inIter)
            | defaultSlim(code)
        };

        match execute(slim) {
            case Err(e) => e == expected
            case Ok(_) => false
        }
    }

    pub def mkIntegTest(file: String, input: List[Int], expected: List[Int]): Bool & Impure = {
        let contents = readToString(file);
        match parse(contents) {
            case Err(e) => bug!("parse error in ${file}: ${e}")
            case Ok(code) => mkInterpreterTest(code, input, expected)
        }
    }

    pub def readToString(file: String): String & Impure = {
        let lines = match File.readLines(file) {
            case Err(_) => bug!("cannot load file ${file}")
            case Ok(l) => l
        };
        String.intercalate(String.lineSeparator(), lines)
    }

}