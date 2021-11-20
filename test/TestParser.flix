namespace Flim/TestParser {
    use Flim/Ast.Line;
    use Flim/Ast.Program;
    use Flim/Ast.Command;
    use Flim/Ast.Arg;
    use Flim/Parser.parse;

    @test
    def testAlloc01(): Bool = {
        let input = "allocate-registers a, b, c";
        let expected = Ok(Program.Program(Line.Alloc("a" :: "b" :: "c" :: Nil) :: Nil));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testAlloc02(): Bool = {
        let input = "allocate-registers reg-1";
        let expected = Ok(Program.Program(Line.Alloc("reg-1" :: Nil) :: Nil));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testAlloc03(): Bool = {
        let input = "    allocate-registers a";
        let expected = Ok(Program.Program(Line.Alloc("a" :: Nil) :: Nil));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testAlloc04(): Bool = {
        let input = "allocate-registers a\nallocate-registers b";
        let expected = Ok(Program.Program(
            Line.Alloc("a" :: Nil) ::
            Line.Alloc("b" :: Nil) ::
            Nil
        ));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testAlloc05(): Bool = {
        let input = "allocate-registers a\n\nallocate-registers b";
        let expected = Ok(Program.Program(
            Line.Alloc("a" :: Nil) ::
            Line.Blank ::
            Line.Alloc("b" :: Nil) ::
            Nil
        ));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testAlloc06(): Bool = {
        let input = "allocate-registers a\n";
        let expected = Ok(Program.Program(
            Line.Alloc("a" :: Nil) ::
            Line.Blank ::
            Nil
        ));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testAlloc07(): Bool = {
        let input = "allocate-registers reg-1-2";
        let expected = Ok(Program.Program(Line.Alloc("reg-1-2" :: Nil) :: Nil));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testBadAlloc01(): Bool = {
        let input = "flallocate-flegisters a, b, c";
        match parse(input) {
            case Err(_) => true
            case Ok(_) => false
        }
    }

    @test
    def testComment01(): Bool = {
        let input = "; this is a comment";
        let expected = Ok(Program.Program(Line.Blank :: Nil));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testComment02(): Bool = {
        let input = "allocate-registers a, b, c ; this is a comment";
        let expected = Ok(Program.Program(Line.Alloc("a" :: "b" :: "c" :: Nil) :: Nil));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testComment03(): Bool = {
        let input = "input-2-larger:        ; an instruction label, referring to the";
        let expected = Ok(Program.Program(Line.Lab("input-2-larger") :: Nil));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testComment04(): Bool = {
        let input = "    ; this is a comment\n";
        let expected = Ok(Program.Program(Line.Blank :: Line.Blank :: Nil));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testLabel01(): Bool = {
        let input = "lab:";
        let expected = Ok(Program.Program(Line.Lab("lab") :: Nil));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testLabel02(): Bool = {
        let input = "lab-1:";
        let expected = Ok(Program.Program(Line.Lab("lab-1") :: Nil));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testCommand01(): Bool = {
        let input = "add 1, 2, 3";
        let expected = Ok(Program.Program(
            Line.Cmd(Command.Add(Arg.Num(1), Arg.Num(2), Arg.Num(3))) ::
            Nil
        ));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testCommand02(): Bool = {
        let input = "sub a, b, c";
        let expected = Ok(Program.Program(
            Line.Cmd(Command.Sub(Arg.Name("a"), Arg.Name("b"), Arg.Name("c"))) ::
            Nil
        ));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testCommand03(): Bool = {
        let input = "ld 1, 2";
        let expected = Ok(Program.Program(
            Line.Cmd(Command.Ld(Arg.Num(1), Arg.Num(2))) ::
            Nil
        ));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testCommand04(): Bool = {
        let input = "st a, b";
        let expected = Ok(Program.Program(
            Line.Cmd(Command.St(Arg.Name("a"), Arg.Name("b"))) ::
            Nil
        ));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testCommand05(): Bool = {
        let input = "read 1";
        let expected = Ok(Program.Program(
            Line.Cmd(Command.Read(Arg.Num(1))) ::
            Nil
        ));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testCommand06(): Bool = {
        let input = "write a";
        let expected = Ok(Program.Program(
            Line.Cmd(Command.Write(Arg.Name("a"))) ::
            Nil
        ));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testCommand07(): Bool = {
        let input = "halt";
        let expected = Ok(Program.Program(
            Line.Cmd(Command.Halt) ::
            Nil
        ));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testCommand08(): Bool = {
        let input = "halt\nlab:";
        let expected = Ok(Program.Program(
            Line.Cmd(Command.Halt) ::
            Line.Lab("lab") ::
            Nil
        ));
        let actual = parse(input);
        expected == actual
    }

    @test
    def testEmpty01(): Bool = {
        let input = "";
        let expected = Ok(Program.Program(Line.Blank :: Nil));
        let actual = parse(input);
        expected == actual
    }
    
}