package ;

import tink.unit.TestBatch;
import tink.testrunner.Runner;

class Main {

    public static function main() {
        Runner.run(TestBatch.make([
            new be.set.RangeSpec(),
            new be.set.RangesSpec(),
            new be.set.RangePerf(),
            new be.set.RangesPerf(),
        ])).handle( Runner.exit );
    }

}