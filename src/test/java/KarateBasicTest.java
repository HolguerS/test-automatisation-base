import com.intuit.karate.junit5.Karate;

class KarateBasicTest {
    static {
        System.setProperty("karate.ssl", "true");
    }

    // Este test ejecuta solo los casos básicos (puedes comentarlo si no los necesitas)
    @Karate.Test
    Karate testBasic() {
        return Karate.run("classpath:karate-test.feature");
    }

    // Este test ejecutará los casos de Marvel
    @Karate.Test
    Karate testMarvelCharacters() {
        return Karate.run("classpath:marvel/characters/get-characters.feature");
    }

    // Otra opción es ejecutar todos los tests en una carpeta específica
    /*
    @Karate.Test
    Karate testMarvelAll() {
        return Karate.run("classpath:marvel").relativeTo(getClass());
    }
    */
}
