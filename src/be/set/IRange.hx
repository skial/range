package be.set;

@:remove
interface IRange<T> {

    public var min(get, set):T;
    public var max(get, set):T;
    public var length(get, never):Int;

}