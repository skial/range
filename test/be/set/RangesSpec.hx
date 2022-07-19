package be.set;

import be.set.Range;
import be.set.Ranges;

@:asserts
class RangesSpec {

    public function new() {}

    public function testInclusive() {
        var rs = new Ranges([]);

        rs.add( new Range(5, 10) );

        asserts.assert( !rs.has(4) );
        asserts.assert( rs.has(5) );
        asserts.assert( rs.has(6) );
        asserts.assert( rs.has(7) );
        asserts.assert( rs.has(8) );
        asserts.assert( rs.has(9) );
        asserts.assert( rs.has(10) );
        asserts.assert( !rs.has(11) );

        asserts.assert( rs.min == 5 );
        asserts.assert( rs.max == 10 );
        
        return asserts.done();
    }

    public function testHas() {
        var rs = new Ranges([new Range(10, 20), 25, 35, new Range(40, 42)]);

        asserts.assert( rs.has(18) );
        asserts.assert( !rs.has(22) );
        asserts.assert( !rs.has(34) );
        asserts.assert( rs.has(35) );
        asserts.assert( rs.has(41) );
        asserts.assert( !rs.has(50) );

        return asserts.done();
    }

    public function testIntersection_simple() {
        var r1 = new Ranges([3, 8]);
        var r2 = new Ranges([1, 3, 7]);
        var i = Ranges.intersection(r1, r2);
        
        asserts.assert( !i.has(1) );
        asserts.assert( i.has(3) );
        asserts.assert( !i.has(7) );
        asserts.assert( !i.has(8) );

        return asserts.done();
    }

    public function testIntersection() {
        var a = new Range(10, 26);
        var b = new Range(15, 28);
        var c = new Range(18, 30);
        var d = new Range(22, 35);
        var r1 = new Ranges([a, b]);
        var r2 = new Ranges([c, d]);
        var i1 = Ranges.intersection(r1, r2);
        var i2 = Ranges.intersection(r2, r1);
        
        asserts.assert( i1.min == 22 );
        asserts.assert( i1.max == 26 );
        asserts.assert( i2.min == 22 );
        asserts.assert( i2.max == 26 );
        asserts.assert( i2.min == i1.min );
        asserts.assert( i2.max == i1.max );

        return asserts.done();
    }

    public function testUnion() {
        var r1 = new Ranges([new Range(10, 15), new Range(13, 18), new Range(19,20), 21]);
        var r2 = new Ranges([new Range(14, 11), new Range(9, 12), 18, new Range(8, 18), 4]);
        var u = Ranges.union(r1, r2);

        //trace( u.values.map( r -> r.min + ':' + r.max ) );
        
        asserts.assert( u.values.length == 2 );
        asserts.assert( u.min == 4 );
        asserts.assert( u.max == 21 );
        asserts.assert( u.values[0].min == 4 );
        asserts.assert( u.values[0].max == 4 );
        asserts.assert( u.values[1].min == 8 );
        asserts.assert( u.values[1].max == 21 );

        for (range in r1.values) {
            asserts.assert( u.has( range.min ) );
            asserts.assert( u.has( range.max ) );
        }

        for (range in r2.values) {
            asserts.assert( u.has( range.min ) );
            asserts.assert( u.has( range.max ) );
        }
        
        return asserts.done();
    }

    // @see https://github.com/skial/seri/issues/17
    public function testIssue17_unionFailure() {
        var a = new Ranges([
            ':'.code, {min:'A'.code, max:'Z'.code}, '_'.code,
            {min:'a'.code, max:'z'.code}, {min:0x00C0, max:0x00D6},
            {min:0x00D8, max:0x00F6}, {min:0x00F8, max:0x02FF}, 
            {min:0x0370, max:0x037D}, {min:0x037F, max:0x1FFF}, 
            {min:0x200C, max:0x200D}, {min:0x2070, max:0x218F}, 
            {min:0x2C00, max:0x2FEF}, {min:0x3001, max:0xD7FF}, 
            {min:0xF900, max:0xFDCF}, {min:0xFDF0, max:0xFFFD}, 
            {min:0x10000, max:0xEFFFF}
        ]);

        var b = new Ranges([
            '-'.code, '.'.code, {min:'0'.code, max:'9'.code},
            0x00B7, {min:0x0300, max:0x036F}, {min:0x203F, max:0x2040}
        ]);

        var u = Ranges.union( a, b );

        for (range in a.values) {
            asserts.assert( u.has( range.min ), 'u.has(${range.min})' + range.min );
            asserts.assert( u.has( range.max ), 'u.has(${range.max})' + range.max );
        }

        for (range in b.values) {
            asserts.assert( u.has( range.min ), 'u.has(${range.min})' + range.min );
            asserts.assert( u.has( range.max ), 'u.has(${range.max})' + range.max );
        }

        return asserts.done();
    }

    public function testComplement() {
        var r = new Ranges([
            new Range(10, 20), 
            new Range(50, 60), 
            new Range(80, 85),
            94,
        ]);
        var c = Ranges.complement(r, 0, 100);
        
        asserts.assert( c.min == 0 );
        asserts.assert( c.max == 100 );
        asserts.assert( c.values.length == 5 );

        asserts.assert( c.values[0].min == 0 );
        asserts.assert( c.values[0].max == 9 );
        asserts.assert( c.values[1].min == 21 );
        asserts.assert( c.values[1].max == 49 );
        asserts.assert( c.values[2].min == 61 );
        asserts.assert( c.values[2].max == 79 );
        asserts.assert( c.values[3].min == 86 );
        asserts.assert( c.values[3].max == 93 );
        asserts.assert( c.values[4].min == 95 );
        asserts.assert( c.values[4].max == 100 );

        return asserts.done();
    }

    public function testAdd() {
        var r = new Ranges([]);
        asserts.assert( r.has(0) == false );
        asserts.assert( r.add(new Range(10, 20)) );
        asserts.assert( r.has(10) && r.has(20) );
        asserts.assert( r.add(15) == false );
        asserts.assert( r.add(19) == false );
        asserts.assert( r.add(new Range(30, 40)) );
        // 5-9 are not in range, but overlap with an existing `Range`
        // Insert a new `Range`.
        asserts.assert( r.add(new Range(5, 15)) );
        asserts.assert( r.add(new Range(15, 25)) );

        return asserts.done();
    }

    public function testAdd_individual() {
        var r = new Ranges([]);
        for (i in 'A'.code...'I'.code) r.add(i);
        asserts.assert( r.min == 'A'.code );
        asserts.assert( r.max == 'H'.code );
        asserts.assert( r.values.length == 1 );
        return asserts.done();
    }

    public function testAdd_individualOutOfOrder() {
        var r = new Ranges([]);
        asserts.assert( r.add('B'.code) );

        // [66:66] | [B:B]
        asserts.assert( r.values.length == 1 );

        asserts.assert( r.min == 'B'.code );
        asserts.assert( r.max == 'B'.code );
        asserts.assert( r.add('A'.code) );

        // [65:66] | [A:B]
        asserts.assert( r.values.length == 1 );

        asserts.assert( r.min == 'A'.code );
        asserts.assert( r.max == 'B'.code );
        asserts.assert( r.add('H'.code) );

        // [65:66, 72:72] | [A:B, H]
        asserts.assert( r.max == 'H'.code );
        asserts.assert( r.values.length == 2 );
        asserts.assert( r.values[0].min == 'A'.code );
        asserts.assert( r.values[0].max == 'B'.code );
        asserts.assert( r.values[1].max == 'H'.code );

        asserts.assert( r.add('D'.code) );

        // [65:66, 68:68, 72:72] | [A:B, D, H]
        asserts.assert( r.values.length == 3 );

        asserts.assert( r.values[0].min == 'A'.code );
        asserts.assert( r.values[0].max == 'B'.code );
        asserts.assert( r.values[1].max == 'D'.code );
        asserts.assert( r.values[2].min == 'H'.code );

        asserts.assert( r.add('C'.code) );  // should trigger `merge` if clause.

        // [65:68, 72:72] | [A:D, H]
        asserts.assert( r.values.length == 2 );
        asserts.assert( r.values[0].min == 'A'.code );
        asserts.assert( r.values[0].max == 'D'.code );
        asserts.assert( r.values[1].min == 'H'.code );

        asserts.assert( r.add('G'.code) );
        asserts.assert( r.values[0].min == 'A'.code );
        asserts.assert( r.values[0].max == 'D'.code );
        asserts.assert( r.values[1].min == 'G'.code );
        asserts.assert( r.values[1].max == 'H'.code );

        // [65:68, 71:72] | [A:D, G:H]
        asserts.assert( r.values.length == 2 );

        asserts.assert( r.add('F'.code) );

        // [65:68, 70:72] | [A:D, F:H]
        asserts.assert( r.values.length == 2 );
        asserts.assert( r.values[0].min == 'A'.code );
        asserts.assert( r.values[0].max == 'D'.code );
        asserts.assert( r.values[1].min == 'F'.code );
        asserts.assert( r.values[1].max == 'H'.code );

        asserts.assert( r.add('E'.code) );

        // [65:72] | [A:H]
        asserts.assert( r.values.length == 1 ); // should trigger `merge` if clause.
        asserts.assert( r.values[0].min == 'A'.code );
        asserts.assert( r.values[0].max == 'H'.code );

        asserts.assert( r.add('I'.code) );

        // [65:73] | [A:I]
        asserts.assert( r.values.length == 1 );

        asserts.assert( r.min == 'A'.code );
        asserts.assert( r.max == 'I'.code );

        // Test `add` returns `false`
        asserts.assert( !r.add('G'.code) );

        asserts.assert( r.values.length == 1 );
        asserts.assert( r.min == 'A'.code );
        asserts.assert( r.max == 'I'.code );
        asserts.assert( r.values[0].min == 'A'.code );
        asserts.assert( r.values[0].max == 'I'.code );
        
        return asserts.done();
    }

    public function testInsert() {
        var r = new Ranges([3, 5]);

        asserts.assert( !r.has(2) );
        asserts.assert( r.has(3) );
        asserts.assert( !r.has(4) );
        asserts.assert( r.has(5) );
        asserts.assert( !r.has(6) );
        asserts.assert( r.values.length == 2 );

        r.insert(2);

        asserts.assert( r.has(2) );
        asserts.assert( r.values.length == 3 );

        r.insert(4);
        r.insert(1);
        r.insert(6);

        asserts.assert( ('' + [1, 2, 3, 4, 5, 6]) == ('' + r.values.map( r -> r.min )) );

        return asserts.done();
    }

    public function testRemove() {
        var r = new Ranges([new Range(10, 20)]);

        asserts.assert( r.values.length == 1 );
        asserts.assert( r.remove( 5 ) == false );
        asserts.assert( r.min == 10 );
        asserts.assert( r.max == 20 );
        asserts.assert( r.has(15) == true );
        asserts.assert( r.remove(15) == true );
        asserts.assert( r.values.length == 2 );
        asserts.assert( r.has(15) == false );

        var h = new Range(13, 17);
        asserts.assert( r.has( h.min ) && r.has( h.max ) );
        asserts.assert( r.remove( h ) == true );
        asserts.assert( !r.has( h.min ) && !r.has( h.max ) );
        asserts.assert( r.remove(new Range(10, 20)) == true );
        asserts.assert( r.values.length == 0 );

        return asserts.done();
    }

    public function testClamp() {
        var r = new Ranges([new Range(10, 90)]);

        var c1 = r.clamp(20, 80);
        asserts.assert( c1.min == 20 );
        asserts.assert( c1.max == 80 );

        var c2 = r.clamp( 5, 91 );
        asserts.assert( c2.min == 10 );
        asserts.assert( c2.max == 90 );
        
        return asserts.done();
    }

    public function testIssue15_removeFailure() {
        var rs = new Ranges([9, 101, 560, 780, 1208, 6404, 8888, 9500, 120171]);

        asserts.assert( rs.min == 9 );
        asserts.assert( rs.max == 120171 );
        asserts.assert( rs.values.length == 9 );
        asserts.assert( rs.has( 101 ) );
        asserts.assert( !rs.has( 7800 ) );
        asserts.assert( rs.remove( {min:0x7F + 1, max:0x10FFFF} ) == true );
        
        return asserts.done();
    }

    // @see https://github.com/skial/seri/issues/19
    public function testIssue19_addMergeFailure() {
        var rs = new Ranges([]);

        asserts.assert( rs.add(0xD800 - 1) );
        asserts.assert( rs.values.length == 1 );
        asserts.assert( rs.values[0].min == 0xD7FF );
        asserts.assert( rs.values[0].max == 0xD7FF );

        asserts.assert( rs.add( new Range(0xD800, 0xDBFF) ) );
        asserts.assert( rs.values.length == 1 );
        asserts.assert( rs.values[0].min == 0xD7FF );
        asserts.assert( rs.values[0].max == 0xDBFF );

        return asserts.done();
    }

    @:variant(new be.set.Ranges([1...10]), new be.set.Ranges([1, 3, 5, 7, 9]), new be.set.Ranges([2, 4, 6, 8, 10]))
    @:variant(new be.set.Ranges([1...100]), new be.set.Ranges([21, 33, 55, 67, 79]), new be.set.Ranges([1...20, 22...32, 34...54, 56...66, 68...78, 80...100]))
    @:variant(new be.set.Ranges([1...50, 51...100]), new be.set.Ranges([21, 33, 55, 67, 79]), new be.set.Ranges([1...20, 22...32, 34...54, 56...66, 68...78, 80...100]))
    @:variant(new be.set.Ranges([25...50]), new be.set.Ranges([5...8, 10...12, 15...17, 20...30, 35...40]), new be.set.Ranges([31...34, 41...50]))
    public function testRelativeComplement(a:Ranges, b:Ranges, e:Ranges) {
        var o = Ranges.relativeComplement(a, b);
        asserts.assert( o.min == e.min );
        asserts.assert( o.max == e.max );
        asserts.assert( o.values.map( r -> '${r.min}:${r.max}' ).toString() == e.values.map( r -> '${r.min}:${r.max}' ).toString() );
        asserts.assert( o.values.length == e.values.length );
        for (element in b.values) {
            asserts.assert( !o.has( element.min ), 'Output `o` does not contain `${element.min}`' );
        }
        return asserts.done();
    }

}