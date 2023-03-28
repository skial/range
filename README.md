# range

Provides `intersection`, `union` and `complement` and other utility methods for
pairs of values or sets of values. _Currently only supports parts of `Int`'s or sets of `Int`'s._

## Tested targets

- Tested ✅
- Untested ➖

| Php | Python | Jvm |Java | C# | Js/Node | Interp | Neko | HashLink | Lua | CPP |
| - | -| - | - | - |- | -| - | - | - | - |
| ✅ | ✅     | ✅ |✅  | ✅ | ✅     | ✅ | ✅  | ✅       | ➖ | ➖ |

## Api

### Range

```Haxe
abstract Range {
    function new(min:Int, max:Int);
    function has(value:Int):Bool;
    function iterator():Iterator<Int>;
    function copy():Range;
    @:from static function fromInt(v:Int):Range;
    @:from static function fromArray(v:Array<Int>):Range;
    @:from static function fromIntIterator(v:IntIterator):Range;
    static function intersection(a:Range, b:Range):Range;
    static function union(a:Range, b:Range):Ranges;
    static function complement(a:Range, ?min:Int = 0, ?max:Int = 0x10FFFF):Ranges;
    static function setDifference(lhs:Range, rhs:Range):Ranges;
}
```

### Ranges

```Haxe
abstract Ranges {
    function has(value:Int):Bool;
    function indexOf(value:Int, ?idx:Int = -1):Int;
    function copy():Ranges;
    function insert(range:Range):Void;
    function add(range:Range):Bool;
    function remove(range:Range):Bool;
    function clamp(min:Int, max:Int):Ranges;
    function iterator():Iterator<Int>;
    static function intersection(a:Ranges, b:Ranges):Range;
    static function union(a:Ranges, b:Ranges):Ranges;
    static function complement(a:Ranges, ?min:Int = 0, ?max:Int = 0x10FFFF):Ranges;
    static function setDifference(lhs:Ranges, rhs:Ranges):Ranges;
}
```

### Defines

- `-D debug_ranges` - Used in `Range.hx`.

### Notes

- Currently only supports `Int` ranges.
- Some params are left over from being originally built for sets of codepoints.