import java.util.*;
import java.io.*;

class Infix2Prefix {

	public static void main (String [] args) {

		String input = null;
		Scanner in = new Scanner( System.in );

		if ( args.length > 0 ) {
			//System.out.println("I got an argument!: " + args[0] );
			String filename = args[0];
			
			try {
				BufferedReader reader = new BufferedReader( new FileReader( new File( filename )));

				String instring = reader.readLine();
				//System.out.println( instring );
				StringReader inreader = new StringReader( instring + "\n" );
				Lexer myLexer = new Lexer( inreader );
				YYParser myParser = new YYParser( myLexer );
				myParser.parse();

			} catch ( Exception e ) {
				System.err.println( e );
			}

		} else {

			try {
				do {
					System.out.print("INPUT: ");
					input = in.nextLine() + "\n";
					StringReader inreader = new StringReader( input );
					Lexer myLexer = new Lexer( inreader );
					YYParser myParser = new YYParser( myLexer );
					myParser.parse();

				} while ( input != null );
			} catch ( Exception e ) {
				System.err.println( e );
			}
		}
	}
}


