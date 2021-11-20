namespace Flim/Utils/Io {
    pub def readLine(s: ##java.util.Scanner): Result[String, String] & Impure = {
        import java.util.Scanner.hasNextLine() as hasNextLine;
        import java.util.Scanner.nextLine() as nextLine;
        if (hasNextLine(s))
            Ok(nextLine(s))
        else
            Err("EOI")
    }

    pub def readInt(s: ##java.util.Scanner): Result[Int, String] & Impure = {
        use Result.flatMap;
        let* l = readLine(s);
        Int32.fromString(l)
    }

    pub def stdinScanner(): ##java.util.Scanner & Impure = {
        import new java.util.Scanner(##java.io.InputStream) as newScanner;
        import get java.lang.System:in as in;
        let i = in() as ##java.io.InputStream;
        newScanner(i)
    }
}