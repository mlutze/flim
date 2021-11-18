namespace Flim/Ast {

    pub opaque type Program with Eq, ToString = List[Line]

    pub enum Line with Eq, ToString {
        case Cmd(Command)
        case Lab(String)
        case Alloc(List[String])
    }

    pub enum Command with Eq, ToString {
        case Add(Register, Register, Register)
        case Sub(Register, Register, Register)
        case Mul(Register, Register, Register)
        case Div(Register, Register, Register)
        case Quo(Register, Register, Register)
        case Rem(Register, Register, Register)

        
        case Seq(Register, Register, Register)
        case Sne(Register, Register, Register)
        case Slt(Register, Register, Register)
        case Sgt(Register, Register, Register)
        case Sle(Register, Register, Register)
        case Sge(Register, Register, Register)

        case Ld(Register, Register)
        case St(Register, Register)

        case Li(Register, Value)

        case Read(Register)
        case Write(Register)

        case Jeqz(Register, Register)
        case J(Register)

        case Halt
    }

    pub enum Register with Eq, ToString {
        case Name(String)
        case Num(String)
    }

    pub enum Value with Eq, ToString {
        case Label(String)
        case Num(String)
    }
}