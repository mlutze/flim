namespace Flim/TestInterpreter {
    use Flim/Ast.{Program, Line, Command, Arg};
    use Flim/Interpreter.{execute, defaultSlim};
    use Flim/Interpreter.Slim;
    use Flim/Interpreter.RuntimeError;

    use Flim/TestUtils.mkInterpreterTest;
    use Flim/TestUtils.mkInterpreterFail;

    @test
    def testHalt(): Bool & Impure = {
        let program = Program.Program(
            Line.Cmd(Command.Halt) ::
            Nil
        );
        let in = Nil;
        let out = Nil;
        mkInterpreterTest(program, in, out)
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
        mkInterpreterTest(program, in, out)
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
        mkInterpreterTest(program, in, out)
    }

    @test
    def testNoHalt(): Bool & Impure = {
        let program = Program.Program(Nil);
        let in = Nil;
        let err = RuntimeError.OutOfProgram;
        mkInterpreterFail(program, in, err)
    }

}