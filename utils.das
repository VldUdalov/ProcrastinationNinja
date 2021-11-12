require daslib/media

def is_equal_float(a:float; b:float; threshold:float = 0.001)
    return abs(float(a - b)) <= threshold 

def test_lines_intersection(a0: float2; a1: float2; b0: float2; b1: float2; var intersection :float2& ): bool
    
    let maxA = float2(max(a0.x, a1.x), max(a0.y, a1.y))
    let maxB = float2(max(b0.x, b1.x), max(b0.y, b1.y))
    let minA = float2(min(a0.x, a1.x), min(a0.y, a1.y))
    let minB = float2(min(b0.x, b1.x), min(b0.y, b1.y))
    intersection = float2(0.,0.)

    if (maxA.x < minB.x || maxB.x < minA.x) || (maxA.y < minB.y || maxB.y < minA.y)
        return false

    // f1(x) = A1*x + b1 = y
    // f2(x) = A2*x + b2 = y

    var xA = 0.
    var yA = 0.
    var A1 = 0.
    var A2 = 0.

    if  is_equal_float(a0.x, a1.x) 
        xA = a0.x
    else
        A1 = float(a1.y - a0.y) / float(a1.x - a0.x)

    if is_equal_float(b0.x, b1.x) 
        xA = b0.x
    else
        A2 = float(b1.y - b0.y) / float(b1.x - b0.x)

    if A1 == A2
        return false // parallel

    let B1 = a0.y - A1 * a0.x
    let B2 = b0.y - A2 * b0.x

    if is_equal_float(xA, 0.) 
        xA = (B2 - B1) / (A1 - A2)
        yA = A1 * xA + B1
    else 
        if is_equal_float(A1, 0.) 
            yA = A2 * xA + B2
        else
            yA = A1 * xA + B1
    
    if xA < max (minA.x, minB.x) || xA > min (maxA.x , maxB.x) || yA < max (minA.y, minB.y) || yA > min (maxA.y , maxB.y)
        return false
    intersection.x = xA
    intersection.y = yA

    return true

def vec_lengthSq(a:float2; b:float2):float
    return sqr(b.x-a.x) + sqr(b.y - a.y)
