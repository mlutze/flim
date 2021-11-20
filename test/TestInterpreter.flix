namespace Flim/TestInterpreter {
    use Flim/Ast.{Program, Line, Command, Arg};
    use Flim/Interpreter.{execute, defaultSlim};
    use Flim/Interpreter.Slim;

    def mkTest(code: Program, input: List[Int], expected: List[Int]): Bool & Impure = {
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

    @test
    def testHalt(): Bool & Impure = {
        let program = Program.Program(
            Line.Cmd(Command.Halt) ::
            Nil
        );
        let in = Nil;
        let out = Nil;
        mkTest(program, in, out)
    }

    @test
    def testReadWrite01(): Bool & Impure = {
        let program = Program.Program(
            Line.Cmd(Command.Read(Arg.Num(0))) ::
            Line.Cmd(Command.Write(Arg.Num(0))) ::
            Line.Cmd(Command.Halt) ::
            Nil
        );
        let in = 42 :: Nil;
        let out = 42 :: Nil;
        mkTest(program, in, out)
    }

    @test
    def testLoadWrite01(): Bool & Impure = {
        let program = Program.Program(
            Line.Cmd(Command.Li(Arg.Num(0), Arg.Num(42))) ::
            Line.Cmd(Command.Write(Arg.Num(0))) ::
            Line.Cmd(Command.Halt) ::
            Nil
        );
        let in = Nil;
        let out = 42 :: Nil;
        mkTest(program, in, out)
    }

}