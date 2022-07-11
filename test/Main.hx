package ;

import tink.unit.TestBatch;
import tink.testrunner.Runner;

class Main {

    public static function main() {
        Runner.run(TestBatch.make([
            new be.set.RangeSpec(),
            new be.set.RangesSpec(),
        ])).handle( Runner.exit );
    }

}