namespace Vector {

    pub def length(v: Vector[a]): Int =
        let Vector(a) = v;
        a.length as & Pure

    pub def empty(): Vector[a] = Vector([]) as & Pure

    pub def fromList(l: List[a]): Vector[a] = 
        let a = List.toArray(l) as & Pure;
        Vector(a)

    pub def get(i: Int, v: Vector[a]): a =
        let Vector(a) = v;
        a[i] as & Pure // TODO safety checks

    pub def append(v1: Vector[a], v2: Vector[a]): Vector[a] = {
        let Vector(a1) = v1;
        let Vector(a2) = v2;
        let a3 = Array.append(a1, a2) as & Pure;
        Vector(a3)
    }

}

pub opaque type Vector[a] = Array[a]