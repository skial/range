package be.set;

@:forward @:forwardStatics abstract Range(RangeImpl) from RangeImpl to RangeImpl {

	public static var EMPTY = new Range(0, 0);

	public var length(get, never):Int;
	private inline function get_length() return this.max - this.min;

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

	// @see https://en.wikipedia.org/wiki/Complement_(set_theory)
	public static function complement(a:Range, ?min:Int = 0, ?max:Int = 0x10FFFF):Ranges {
		var r = [];
		if (a.min-1 > min) r.push(new Range(min, a.min-1));
		r.push(new Range(a.max+1, max));

		return new Ranges(r);
	}
	
}

@:structInit class RangeImpl {

	public var min:Int;
	public var max:Int;
	
	public inline function new (min:Int, max:Int) {
		this.min = min;
		this.max = max;
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