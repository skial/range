package be.set;

import be.set.Range;

class RangeTestMethods {

    public static inline function intersection(amin:Int, amax:Int, bmin:Int, bmax:Int) {
        var a = new Range(amin, amax);
        var b = new Range(bmin, bmax);
        var i = Range.intersection(a, b);
        return {a:a, b:b, i:i};
    }

    public static inline function union(amin:Int, amax:Int, bmin:Int, bmax:Int) {
        var a = new Range(amin, amax);
        var b = new Range(bmin, bmax);
        var u = Range.union(a, b);
        return {a:a, b:b, u:u};
    }

    public static inline function complement(amin:Int, amax:Int, limit:Int) {
        var r = new Range(amin, amax);
        var c = Range.complement(r, 0, limit);
        return {r:r, c:c};
    }
    
}