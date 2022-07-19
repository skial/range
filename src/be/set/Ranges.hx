package be.set;

import unifill.CodePoint;

using Lambda;

@:structInit 
class Ranges {

	public static var EMPTY = new Ranges([Range.EMPTY]);

	public var values:Array<Range>;
	public var min(get, null):Int;
	public var max(get, null):Int;
	public var length(get, null):Int;
	
	public inline function new(ranges:Array<Range>) {
		values = ranges;
		//if (values.length == 0) values = EMPTY.values;
	}

	private inline function get_min() return values[0].min | 0;
	private inline function get_max() return values[values.length - 1].max | 0;
	private inline function get_length() return max - min;
	
	public function has(value:Int):Bool {
		for (range in values) if (range.has(value)) return true;
		return false;
	}

	/** 
		Returns the index of the range that contains `value` or `-1` if none matched.
		@value - The value to match against.
		@idx - Optional default value to return on failed matches.
	*/
	public function indexOf(value:Int, ?idx:Int = -1):Int {
		var last = values.length-1;

		if (values[0].has(value)) return 0;
		if (values[last].has(value)) return last;
		for (i in 1...(last-1)) if (values[i].has(value)) return i;
		return idx;
	}

	// TODO add `push` which just adds a range to end of collection, not position optimised or merged.

	public inline function copy():Ranges {
		return new Ranges([for (r in this.values) r.copy()]);
	}

	/**
		Adds `range` **without** merging overlapping values. Attempts to find
		sorted position before inserting.
	**/
	public function insert(range:Range):Void {
		var idx = values.length-1;

		for (i in 0...values.length) {
			if (range.min >= values[i].min && range.max <= values[i].max) {
				idx = i;
				break;
			} else if (range.min < values[i].min) {
				idx = i;
				break;
			} else if (range.min > values[i].min) {
				idx = i+1;
			}
		}
		
		values.insert(idx < 0 ? 0 : idx, range);
	}

	/**
		Merges `range` with existing `values` if possible.
		Returns false if **_nothing_** was modified.
	**/
	public function add(range:Range):Bool {
		if (values.length == 0) {
			values.push( range );
			return true;

		}

		var index = 0;
		var local:Range;
		var insertIndex = -1;
		var added = false;
		var merge = false;

		while (index < values.length) {
			local = values[index];
			#if debug_ranges
			trace( local.min + ':' + local.max, '-> ' + range.min + ':' + range.max );
			#end
			
			if (merge) {
				#if debug_ranges
				trace( 'merging' );
				#end
				if (index >= 0 && index + 1 < values.length) {
					var next = values[index + 1];

					if (local.max + 1 == next.min) {
						local.max = next.max;
						values.splice(index + 1, 1);

					}

				}

				if (index >= 1) {
					var previous = values[index - 1];

					if (local.min - 1 == previous.max) {
						previous.max = local.max;
						values.splice(index, 1);

					}

				}

				return true;

			} else {

				if (range.min == local.min - 1) {
					// modify existing `local.min` value.
					local.min--;
					added = true;
					merge = values.length > 1;
					#if debug_ranges
					trace(1);
					#end
				}
				
				if (range.max == local.max + 1) {
					// modify existing `local.max` value.
					local.max++;
					added = true;
					merge = values.length > 1;
					#if debug_ranges
					trace(2);
					#end
				}

				/**
					If `range` `min == max` is true AND both previous
					checks passed, it now belongs within `local`.
				**/
				if (range.min >= local.min && range.max <= local.max) { // ref[2]
					// `range` exists within an existing `local`.
					#if debug_ranges
					trace(4);
					#end
					merge ? continue : return added;

				}
				
				if (local.min > range.max) { // ref[1]
					// `range` needs to be inserted before `local`.
					insertIndex = index;
					#if debug_ranges
					trace(3);
					#end
					break;

				}
				
				/*
					At this point we know:
						+ That `local.min` is not larger than or equal too `range.max`. See ref[1].
						+ And `range` does not entirely fit within `local`. See ref[2].
				*/
				if (local.has(range.min) && range.max > local.max) {
					// `range.min` exists with `local`, so modify `local.max`.
					local.max = range.max;
					merge = true;
					#if debug_ranges
					trace(5);
					#end

				} 
				
				if (range.min < local.min && range.max < local.max) {
					// check `range.max` so single codepoint ranges `min == max`.
					local.min = range.min;
					merge = true;
					#if debug_ranges
					trace(6);
					#end

				}

				if (range.min - 1 == local.max) {
					local.max = range.max;
					added = true;
					merge = values.length > 1;
					#if debug_ranges
					trace(6.1);
					#end

				}

			}

			index++;

		}

		if (insertIndex != -1) {
			values.insert(insertIndex, range);
			#if debug_ranges
			trace(7);
			trace( values.map( v-> v.min + ':' + v.max ));
			#end
			return true;

		}

		if (!added && !merge) {
			values.push( range );
			#if debug_ranges
			trace(8);
			trace( values.map( v-> v.min + ':' + v.max ));
			#end
			return true;
		}

		#if debug_ranges
		trace( values.map( v-> v.min + ':' + v.max ) );
		#end

		return added;
	}

	public function remove(range:Range):Bool {
		if (range.max < min || range.min > max) return false;

		if (range.min <= min && range.max >= max) {
			values.splice(0, values.length);
			return true;

		} else {
			var idx = 0;

			while (idx < values.length) {
				var r = values[idx];

				if (range.min <= r.min && range.max >= r.max) {
					values.splice(idx, 1);
					continue;
				}

				if (range.min >= r.min && range.max <= r.max) {
					var diff = Range.complement(range, r.min, r.max).values;
					values[idx] = diff.shift();
					var _idx = idx+1;
					for (v in diff) {
						values.insert(_idx, v);
						_idx++;
					}
					return true;
				}

				if (range.min >= r.min && range.min <= r.max) {
					r.max = range.min - 1;

				} else if (range.max >= r.min && range.max <= r.max) {
					r.min = range.max + 1;
					return true;

				}

				idx++;
			}

			return idx != 0;
		}

		return false;
	}

	public function clamp(min:Int, max:Int):Ranges {
		if (this.min >= min && this.max <= max) return this;
		var rs = new Ranges([]);

		for (r in values) {
			var _r = r.copy();
			if (r.min < min) _r.min = min;
			if (r.max > max) _r.max = max;
			rs.values.push( _r );
		}

		return rs;
	}
	
	public inline function iterator():Iterator<Int> {
		return new RangesIterator( this );
	}

	public static function intersection(a:Ranges, b:Ranges):Range {
		var r = new Range(0, 0); // Default is empty/disjoint.
		var c = a.values.concat( b.values );
		switch c.length {
			case 1: return c[0];
			case 2: return Range.intersection(c[0], c[1]);
			case _:
				var len = 0;
				var t = c[0];
				var match = false;
				while (len < (c.length-1)) {
					if ((t.has(c[len+1].min) || t.has(c[len+1].max)) || (c[len+1].has(t.min) || c[len+1].has(t.max))) {
						t.min = t.min > c[len+1].min ? t.min : c[len+1].min;
						t.max = t.max < c[len+1].max ? t.max : c[len+1].max;
						match = true;

					}
					len++;
				}
				if (match) r = t;
		}
		return r;
	}

	// @see https://en.wikipedia.org/wiki/Union_(set_theory)
	public static function union(a:Ranges, b:Ranges):Ranges {
		var u = new Ranges([]);

		for (r in a.values) u.add( r );
		for (r in b.values) u.add( r );

		return u;
	}

	public static function complement(a:Ranges, ?min:Int = 0, ?max:Int = 0x10FFFF):Ranges {
		return absoluteComplement(a, min, max);
	}

	// @see https://en.wikipedia.org/wiki/Complement_(set_theory)
	public static function absoluteComplement(a:Ranges, ?min:Int = 0, ?max:Int = 0x10FFFF):Ranges {
		var r = [];
		var idx = 0;

		if (a.min-1 > min) r.push(new Range(min, a.min-1));

		while (idx <= a.values.length-1) {
			var b = a.values[idx];
			var a = r[r.length-1];
			if (a == null) a = new Range(min, min);

			var bmin = b.min-1;

			if (bmin < a.max) a.max = bmin;

			r.push( new Range(b.max+1, max) );

			idx++;
		}

		return new Ranges(r);
	}

	// Alias for `relativeComplement`
	public static inline function setDifference(lhs:Ranges, rhs:Ranges):Ranges {
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
	public static function relativeComplement(lhs:Ranges, rhs:Ranges):Ranges {
		var r:Array<Range> = [];

		// Handles point 4).
		// TODO test to see if this is needed.
		if (lhs.min >= rhs.min && lhs.max <= rhs.max) {
			return EMPTY.copy();
		}

		/*var iterator:RangesIterator = cast lhs.iterator();
		var ranges = rhs.values;
		var idx = 0;//rhs.indexOf(lhs.min, 0);
		var range = ranges[idx];

		/*var tmp = new Range(0, 0);
		var val = 0;
		for (element in iterator) { // TODO turn into awhile loop, values are already tracked in the body...
			val = element;
			// If `lhs.values` contains non optimised ranges, split ranges can be less than whats tracked, this fixes that.
			if (r.length != 0 && val < r[r.length-1].max) val = ranges[idx-1].max+1;
			
			// Prevents iterating past `rhs` max value.
			if (val > rhs.max) {
				r.push( new Range( val, lhs.max ) );
				break;
			}
			
			if (val < range.min) {
				tmp.min = val;
				tmp.max = range.min - 1;

				r.push( tmp.copy() );
				@:privateAccess iterator.current = range.max + 1;
				idx++;
				range = ranges[idx];	
				
				if (range == null) {
					if (@:privateAccess iterator.current > rhs.max) {
						r.push( new Range( @:privateAccess iterator.current, lhs.max ) );
						
					}
					break;
				}

				continue;
				
			}

			idx++;
			range = ranges[idx];

		}*/

		/**
			1) `(rhM---[lhM...lhX]---rhX)` == `[]`
			2) `(rhM---[lhM.-.rhX)...lhX]` == `[rhX+1...lhX]`
			3) `[lhM...(rhM-.-lhX]---rhX)` == `[lhM...rhM-1]`
			4) `[lhM...(rhM---rhX)...lhX]` == `[lhM...rhM-1, rhX+1...lhX]`
			---
			`[{r1M---((lhM|lhM).-.r1X}, {r2M.-.(lhX|lhX))---r2X}]` == `[r1X+1...r2M-1]`
			```
			[lhM....................lhX]
			      (r1M---r1X)   {r2M---r2X}
			```
			`[lhM...r1M-1, r1x+1...r2M-1]`

			```
				[lhM............lhX]	
			(r1M---r1X)		 {r2M...r2X}
			```
			`[r1X+1...r2M-1]`

			```
			[lhM..........................lhX]
			    (r1M---r1X)   {r2M---r2X}
			```
			`[lhM...r1M-1, r1X+1...r2M-1, r2X+1...lhX]`
			---
		**/

		var _rhs:Range;
		var idx = 0;
		var values = lhs.values;
		var _lhs = values[idx];
		var tmp = _lhs.copy();
		for (i in 0...rhs.values.length) {
			_rhs = rhs.values[i];

			// `_rhs` range is too small.
			if (tmp.min > _rhs.max) continue;

			// 0)
			if (tmp.min < _rhs.min) {
				tmp.max = _rhs.min - 1;
				// creates `[x...rhM-1]`
				r.push( tmp.copy() );

				if (_lhs.max > _rhs.max) {
					// Setup `[r1X+1...lhX]` which will go through 0) creating `[r1X+1...r2M-1]`
					tmp.min = _rhs.max + 1;
					tmp.max = _lhs.max;
					continue;

				} else {
					// Attempt to move onto next `lhs` range.
					idx++;
					if (values[idx] != null) {
						_lhs = values[idx];
						tmp.min = _rhs.max + 1;
						tmp.max = _lhs.max;

					} else {
						// `lhs` is contained in `_rhs` and is last in collection, finish early.
						break;
					}

				}

			} else if (tmp.min >= _rhs.min && tmp.min < _rhs.max) {
				//  `[rhX+1...x]`
				tmp.min = _rhs.max + 1;

				if (tmp.min >= tmp.max) {
					// Attempt to move onto next `lhs` range.
					idx++;
					if (values[idx] != null) {
						_lhs = values[idx];
						tmp.max = _lhs.max;

					} else {
						// `lhs` is contained in `_rhs` and is last in collection, finish early.
						break;
					}
				}

			} else {
				// `tmp.min` equals `_rhs.min`.
				tmp.min = _rhs.max + 1;

			}

		}

		// `tmp` values may have been set and `continue`d at the end of `rhs.values.length`.
		r.push( tmp.copy() );

		return new Ranges(r);
	}
	
}

@:structInit private class RangesIterator {
	
	public var ranges:Ranges;
	public var current:Int;
	public var rangeIndex:Int = 0;
	
	public inline function new(ranges:Ranges) {
		this.ranges = ranges;
		this.current = ranges.values[0].min;
	}
	
	public function next():Int {
		var result = current;
		current = current + 1;
		return result;
	}
	
	public function hasNext():Bool {
		if (current <= ranges.values[rangeIndex].max) {
			return true;
			
		} else if (rangeIndex <= ranges.values.length) {
			rangeIndex++;
			if (ranges.values[rangeIndex] != null) {
				current = ranges.values[rangeIndex].min;
				return true;
			}
			
		}
		
		return false;
	}
	
}