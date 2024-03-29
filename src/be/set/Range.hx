package be.set;

@:structInit class RangeImpl implements IRange<Int> {

	@:isVar public var min(get, set):Int;

	private inline function get_min() {
		return this.min;
	}

	private inline function set_min(v) {
		return this.min = v;
	}

	@:isVar public var max(get, set):Int;
	
	private inline function get_max() {
		return this.max;
	}

	private inline function set_max(v) {
		return this.max = v;
	}

	public var length(get, never):Int;

	private inline function get_length() {
		return this.max - this.min;
	}
	
	public inline function new(min:Int, max:Int) {
		this.min = min;
		this.max = max;
	}
	
}

@:forward 
@:forwardStatics 
abstract Range(RangeImpl) from RangeImpl to RangeImpl {

	public static var EMPTY = new Range(0, 0);

	/*public var length(get, never):Int;
	private inline function get_length() return this.max - this.min;*/

	public inline function new(min:Int, max:Int) {
		this = new RangeImpl( min, max );
	}

	public inline function has(value:Int):Bool {
		return value >= this.min && value <= this.max;
	}

	public inline function iterator():Iterator<Int> {
		return new RangeIterator( this );
	}

	public inline function copy():Range {
		return new Range(this.min, this.max);
	}

	@:from public static inline function fromInt(v:Int):Range {
		return new RangeImpl( v, v );
	}

	/* Creates a `Range` using the first and last indexes of the array. */
	@:from public static inline function fromArray(v:Array<Int>):Range {
		return new RangeImpl( v[0], v[v.length-1] );
	}

	@:from public static inline function fromIntIterator(v:IntIterator):Range {
		return @:privateAccess new RangeImpl( v.min, v.max );
	}

	// @see https://en.wikipedia.org/wiki/Intersection_(set_theory)
	public static function intersection(a:Range, b:Range):Range {
		var r = new Range(0, 0); // Default is empty/disjoint.
		if ((a.has(b.min) || a.has(b.max)) || (b.has(a.min) || b.has(a.max))) {
			r.min = a.min > b.min ? a.min : b.min;
			r.max = a.max < b.max ? a.max : b.max;

		}

		return r;
	}

	// @see https://en.wikipedia.org/wiki/Union_(set_theory)
	public static function union(a:Range, b:Range):Ranges {
		var r = [];

		if (a.min <= (b.min - 1) && a.max >= (b.max - 1)) {
			r.push(a);

		} else if ((b.min - 1) <= a.min && (b.max - 1) >= a.max) {
			r.push(b);

		} else if (a.min <= (b.min - 1) && a.max >= (b.min - 1) && (b.max - 1) >= a.max) {
			r.push(new Range(a.min, b.max));

		} else if ((b.min - 1) <= a.min && (b.max - 1) >= a.min && a.max >= (b.max - 1)) {
			r.push(new Range(b.min, a.max));

		} else if (a.min > b.min) {
			r.push(b);
			r.push(a);

		} else {
			r.push(a);
			r.push(b);
		}

		return new Ranges(r);
	}

	// Alias for `absoluteComplement`
	public static inline function complement(a:Range, ?min:Int = 0, ?max:Int = 0x10FFFF):Ranges {
		return absoluteComplement(a, min, max);
	}

	public static function absoluteComplement(a:Range, ?min:Int = 0, ?max:Int = 0x10FFFF):Ranges {
		var r = [];
		if (a.min-1 > min) r.push(new Range(min, a.min-1));
		r.push(new Range(a.max+1, max));

		return new Ranges(r);
	}

	// Alias for `relativeComplement`
	public static inline function setDifference(lhs:Range, rhs:Range):Ranges {
		return relativeComplement(lhs, rhs);
	}

	/**
		The relative complement of `rhs` in `lhs` or `lhs` \ `rhs`.
		That is, the elements that appear in `lhs` that are not in `rhs`.
		---
		1) `[ln∙∙∙(rn---lx]---rx)` == `[ln∙∙∙rn-1]`
		2) `[ln∙∙∙(rn---rx)∙∙∙lx]` == `[ln∙∙∙rn-1, rx+1∙∙∙lx]`
		3) `(rn---[ln∙∙∙rx)∙∙∙lx]` == `[rx+1∙∙∙lx]`
		4) `(rn---[ln∙∙∙lx]---rx)` == `[]`
	**/
	public static function relativeComplement(lhs:Range, rhs:Range):Ranges {
		var a = new Range(0, 0);
		var b = new Range(0, 0);
		var r = [];

		// Gets output for point 1 & r[0] for point 2.
		if (lhs.min < rhs.min) {
			a.min = lhs.min;
			a.max = rhs.min - 1;
			r.push( a );
		}

		// Gets output for point 3 & r[1] for point 2.
		if (lhs.max > rhs.max) {
			b.min = rhs.max + 1;
			b.max = lhs.max;
			r.push( b );
		}

		if (r.length == 0) r.push( a ); // Satisfies point 4, which is empty (0, 0);

		return new Ranges(r);
	}
	
}

@:structInit private class RangeIterator {
	
	public var range:Range;
	public var current:Int;
	
	public inline function new(range:Range) {
		this.range = range;
		this.current = range.min;
	}
	
	public function next():Int {
		return current = current + 1;
	}
	
	public function hasNext():Bool {
		return current <= range.max;
	}
	
}