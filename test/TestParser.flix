namespace Flim/TestParser {
    use Flim/Ast.Line;
    use Flim/Ast.Program;
    use Flim/Parser.parse;

    @test
    def testAlloc01(): Bool = {
        let input = "allocate-registers a, b, c";
        let expected = Ok(Program.Program(Line.Alloc("a" :: "b" :: "c" :: Nil) :: Nil));
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
    def testLabel01(): Bool = {
        let input = "lab:";
        let expected = Ok(Program.Program(Line.Lab("lab") :: Nil));
        let actual = parse(input);
        expected == actual
    }

}