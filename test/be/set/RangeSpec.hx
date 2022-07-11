package be.set;

import be.set.Range;

@:asserts class RangeSpec {

    public function new() {}

    @:variant(10, 30, 18, true)
    @:variant(10, 30, 5, false)
    @:variant(0, 0, 10, false)
    @:variant(10, 10, 10, true)
    public function testHasValue(min:Int, max:Int, v:Int, e:Bool) {
        asserts.assert( new Range(min, max).has(v) == e );
        return asserts.done();
    }

    @:variant(1, 3, 2, 4, 2, 3)
    @:variant(10, 20, 15, 25, 15, 20)
    @:variant(15, 25, 10, 20, 15, 20)
    public function testIntersection(amin:Int, amax:Int, bmin:Int, bmax:Int, rmin:Int, rmax:Int) {
        var a = new Range(amin, amax);
        var b = new Range(bmin, bmax);
        var i = Range.intersection(a, b);
        asserts.assert( a.has(rmin) == true );
        asserts.assert( b.has(rmax) == true );
        asserts.assert( i.has(rmin) == true );
        asserts.assert( i.has(rmax) == true );
        asserts.assert( i.min == rmin );
        asserts.assert( i.max == rmax );
        return asserts.done();
    }

    @:variant(1, 2, 3, 4, 1, 4)
    @:variant(10, 20, 40, 50, 15, 45)
    public function testIntersectionDisjoin(amin:Int, amax:Int, bmin:Int, bmax:Int, rmin:Int, rmax:Int) {
        var a = new Range(amin, amax);
        var b = new Range(bmin, bmax);
        var i = Range.intersection(a, b);
        asserts.assert( a.has(rmin) == true );
        asserts.assert( b.has(rmax) == true );
        asserts.assert( i.has(rmin) == false );
        asserts.assert( i.has(rmax) == false );
        asserts.assert( i.min == 0);
        asserts.assert( i.max == 0 );
        return asserts.done();
    }

    @:variant(10, 30, 20, 40, 10, 40, 1)
    @:variant(20, 40, 10, 30, 10, 40, 1)
    @:variant(10, 15, 20, 25, 10, 25, 2)
    @:variant(20, 25, 10, 15, 10, 25, 2)
    @:variant(1, 2, 3, 4, 1, 4, 1)
    public function testUnion(amin:Int, amax:Int, bmin:Int, bmax:Int, min:Int, max:Int, length:Int) {
        var a = new Range(amin, amax);
        var b = new Range(bmin, bmax);
        var u = Range.union(a, b);
        asserts.assert( u.min == min );
        asserts.assert( u.max == max );
        asserts.assert( u.values.length == length );
        return asserts.done();
    }

    @:variant(10, 20, 30, 2)
    @:variant(0, 20, 30, 1)
    public function testComplement(amin:Int, amax:Int, limit:Int, length:Int) {
        var r = new Range(amin, amax);
        var c = Range.complement(r, 0, limit);
        asserts.assert( !c.has(r.min) );
        asserts.assert( !c.has(r.max) );
        asserts.assert( c.values.length == length );
        if (length == 2) {
            asserts.assert( c.min == 0 );
            asserts.assert( c.values[0].max == (amin - 1) );
        }
        asserts.assert( c.max == limit );
        asserts.assert( c.values[c.values.length-1].min == (amax + 1) );
        return asserts.done();
    }

}