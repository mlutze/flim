namespace Flim/Utils/Iter {
    
    pub def next(iter: Iterator[a]): Result[a, String] & Impure = {
        let Iterator(done, next) = iter;
        if (done()) {
            Err("EOI")
        } else {
            Ok(next())
        }

    }
}