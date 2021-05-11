/// Middleware that should be responsible of parsing a [Raw] type to/from any [T] representation
abstract class Serializer<T extends Object, Raw> {
  T from(Raw json);
  Raw to(T object);
}
