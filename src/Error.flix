namespace Flim/Error {
    use Flim/Interpreter.RuntimeError;

    pub enum Error with ToString {
        case Runtime(RuntimeError)
        case Parse(String)
        case Loading(String)
    }
}