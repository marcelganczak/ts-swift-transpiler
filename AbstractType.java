abstract class AbstractType {
    abstract String tsType();
    abstract String swiftType();
    abstract AbstractType resulting(String accessor);
    abstract AbstractType copy();
}