import org.antlr.v4.runtime.tree.ParseTree;

import java.util.HashMap;
import java.util.Map;

public class UtilVisitor extends NativeOverriddenVisitor {

    protected Map<ParseTree, Map<String, String>> typeCache = new HashMap<ParseTree, Map<String, String>>();

    protected boolean isDirectDescendant(Class nodeType, ParseTree node) {
        if(node == null) return false;
        if(node.getClass() == nodeType) return true;
        if(node.getChildCount() != 1) return false;
        return isDirectDescendant(nodeType, node.getChild(0));
    }

    protected ParseTree findNearestAncestorBlock(ParseTree node) {
        boolean isBlock = node instanceof SwiftParser.Top_levelContext || node instanceof SwiftParser.Code_blockContext || node instanceof SwiftParser.Function_bodyContext;
        if(isBlock) return node;
        if(node.getParent() == null || node.getParent() == node) return null;
        return findNearestAncestorBlock(node.getParent());
    }

    protected String findType(String varName, ParseTree node) {

        while((node = findNearestAncestorBlock(node)) != null) {
            Map<String, String> blockTypeCache = typeCache.get(node);
            if(blockTypeCache == null) continue;
            if(blockTypeCache.containsKey(varName)) return blockTypeCache.get(varName);
            if(node instanceof SwiftParser.Top_levelContext) return null;
        }
        return null;
    }

    public void cacheType(String identifier, String type, SwiftParser.Pattern_initializerContext ctx) {
        ParseTree nearestAncestorBlock = findNearestAncestorBlock(ctx);

        if(!typeCache.containsKey(nearestAncestorBlock)) {
            typeCache.put(nearestAncestorBlock, new HashMap<String, String>());
        }
        typeCache.get(nearestAncestorBlock).put(identifier, type);
    }
};
