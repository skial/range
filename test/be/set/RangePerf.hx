package be.set;

import be.set.RangeTestMethods.*;

class RangePerf implements tink.unit.Benchmark {

    public function new() {}

    public function perfIntersection() {
        return tink.unit.Assert.benchmark(10000, intersection(15, 25, 10, 25));
    }

    public function perfIntersectionDisjoin() {
        return tink.unit.Assert.benchmark(10000, intersection(10, 20, 40, 50));
    }

    public function perfUnion() {
        return tink.unit.Assert.benchmark(10000, union(20, 40, 10, 30));
    }

    public function perfComplement() {
        return tink.unit.Assert.benchmark(10000, complement(10, 20, 30));
    }

    public function perfRelativeComplement() {
        var a = new be.set.Range(1, 10);
        var b = new be.set.Range(3, 8);
        return tink.unit.Assert.benchmark(10000, Range.relativeComplement(a, b));
    }

}