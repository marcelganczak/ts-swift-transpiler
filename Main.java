import org.antlr.v4.runtime.ANTLRFileStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

import java.io.IOException;

public class Main {

    public static void main(String [] args) {

        String srcFile = args.length > 0 ? args[0] : "./example.ts";

        ANTLRFileStream inputFile = null;

        try {
            inputFile = new ANTLRFileStream(srcFile);
        } catch (IOException e) {
            e.printStackTrace();
        }

        ECMAScriptLexer lexer = new ECMAScriptLexer(inputFile);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        ECMAScriptParser parser = new ECMAScriptParser(tokens);
        ECMAScriptParser.ProgramContext tree = parser.program();

        EntityCache cache = new EntityCache();

        CacheVisitor cacheVisitor = new CacheVisitor(cache);
        cacheVisitor.visit(tree);

        TranspilerVisitor transpilerVisitor = new TranspilerVisitor(cache);
        System.out.println(transpilerVisitor.visit(tree));
    }
}
