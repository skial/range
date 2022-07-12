package be.set;

import be.set.Ranges.*;

class RangesPerf implements tink.unit.Benchmark {

    public function new() {}

    public function perfIntersection_simple() {
        var a = new Ranges([3, 8]);
        var b = new Ranges([1, 3, 7]);
        return tink.unit.Assert.benchmark(10000, intersection(a, b));
    }

    public function perfIntersection() {
        var a = new Range(10, 26);
        var b = new Range(15, 28);
        var c = new Range(18, 30);
        var d = new Range(22, 35);
        var r1 = new Ranges([a, b]);
        var r2 = new Ranges([c, d]);
        return tink.unit.Assert.benchmark(10000, {
            var i1 = intersection(r1, r2);
            var i2 = intersection(r2, r1);
            i2.max == i1.max;
        });
    }

    public function perfIntersectionDisjoin() {
        return tink.unit.Assert.benchmark(10000, {
            var i = intersection(new Ranges([10, 20]), new Ranges([40, 50]));
            i.min == 0 && i.max == 0;
        });
    }

    public function perfUnion() {
        var r1 = new Ranges([new Range(10, 15), new Range(13, 18), new Range(19,20), 21]);
        var r2 = new Ranges([new Range(14, 11), new Range(9, 12), 18, new Range(8, 18), 4]);
        return tink.unit.Assert.benchmark(10000, {
            var u = union(r1, r2);
            u.max == 21;
        });
    }

    public function perfComplement() {
        var r = new Ranges([
            new Range(10, 20), 
            new Range(50, 60), 
            new Range(80, 85),
            94,
        ]);
        return tink.unit.Assert.benchmark(10000, {
            var c = complement(r, 0, 100);
            c.max == 100;
        });
    }

}