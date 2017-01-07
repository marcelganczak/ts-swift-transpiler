import org.antlr.v4.runtime.tree.ParseTree;

public class WalkerUtil {

    public static boolean isDirectDescendant(Class nodeType, ParseTree node) {
        if(node == null) return false;
        if(nodeType.isInstance(node)) return true;
        if(node.getChildCount() != 1) return false;
        return isDirectDescendant(nodeType, node.getChild(0));
    }

    public static ParseTree closestAncestor(Class nodeType, ParseTree node) {
        while(node != null) {
            if(nodeType.isInstance(node)) return node;
            node = node.getParent();
        }
        return null;
    }

    public static boolean has(Class nodeType, ParseTree node) {
        if(node == null) return false;
        if(node.getClass() == nodeType) return true;
        for(int i = 0; i < node.getChildCount(); i++) {
            if(has(nodeType, node.getChild(i))) return true;
        }
        return false;
    }
}
