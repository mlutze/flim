namespace Flim/Ast {

    pub opaque type Program with Eq, ToString = List[Line]

    pub enum Line with Eq, ToString {
        case Cmd(Command)
        case Lab(String)
        case Alloc(List[String])
        case Blank
    }

    pub enum Command with Eq, ToString {
        case Add(Arg, Arg, Arg)
        case Sub(Arg, Arg, Arg)
        case Mul(Arg, Arg, Arg)
        case Div(Arg, Arg, Arg)
        case Quo(Arg, Arg, Arg)
        case Rem(Arg, Arg, Arg)

        
        case Seq(Arg, Arg, Arg)
        case Sne(Arg, Arg, Arg)
        case Slt(Arg, Arg, Arg)
        case Sgt(Arg, Arg, Arg)
        case Sle(Arg, Arg, Arg)
        case Sge(Arg, Arg, Arg)

        case Ld(Arg, Arg)
        case St(Arg, Arg)

        case Li(Arg, Arg)

        case Read(Arg)
        case Write(Arg)

        case Jeqz(Arg, Arg)
        case J(Arg)

        case Halt
    }

    pub enum Arg with Eq, ToString {
        case Name(String)
        case Num(Int32)
    }
}