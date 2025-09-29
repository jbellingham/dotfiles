Not sure if it's a Nix thing specifically, but using Java installed using Nix in IntelliJ doesn't seem to work out of the box.
The JAVA_HOME seems to get set weirdly - on a Mac it is expecting JAVA_HOME to be something like ...zulu-8.jdk/Contents/Home.
I get around this by just overriding it in the IntelliJ project settings (CMD + ;)