namespace Flim/Utils/Io {
    pub def readLine(s: ##java.util.Scanner): Option[String] & Impure = {
        import java.util.Scanner.hasNextLine() as hasNextLine;
        import java.util.Scanner.nextLine() as nextLine;
        if (hasNextLine(s))
            Some(nextLine(s))
        else
            None
    }

    pub def readInt(s: ##java.util.Scanner): Option[Int] & Impure = {
        readLine(s) |> Option.flatMap(str -> Int32.fromString(str) |> Result.toOption)
    }

    pub def stdinScanner(): ##java.util.Scanner & Impure = {
        import new java.util.Scanner(##java.io.InputStream) as newScanner;
        import get java.lang.System:in as in;
        let i = in() as ##java.io.InputStream;
        newScanner(i)
    }
}