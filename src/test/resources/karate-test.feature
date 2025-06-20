Feature: API de Personajes Marvel
  Como usuario de la API de personajes Marvel
  Quiero poder gestionar personajes
  Para mantener un catálogo actualizado

  Background:
    * configure ssl = true
    * url 'http://bp-se-test-cabcd9b246a5.herokuapp.com'
    * def username = 'HolguerS'
    * def charactersPath = '/' + username + '/api/characters'
    * def validCharacter =
    """
    {
      "name": "Spider-Man",
      "alterego": "Peter Parker",
      "description": "Superhéroe arácnido de Marvel",
      "powers": ["Agilidad", "Sentido arácnido", "Trepar muros"]
    }
    """
    * def duplicateCharacter =
    """
    {
      "name": "Spider-Man",
      "alterego": "Peter Parker",
      "description": "Otro intento duplicado",
      "powers": ["Agilidad"]
    }
    """
    * def invalidCharacter =
    """
    {
      "name": "",
      "alterego": "",
      "description": "",
      "powers": []
    }
    """
    * def updatedCharacter =
    """
    {
      "name": "Spider-Man",
      "alterego": "Peter Parker",
      "description": "Superhéroe arácnido de Marvel (actualizado)",
      "powers": ["Agilidad", "Sentido arácnido", "Trepar muros"]
    }
    """
    * def nonExistentCharacter =
    """
    {
      "name": "No existe",
      "alterego": "Nadie",
      "description": "No existe",
      "powers": ["Nada"]
    }
    """
  Scenario: Obtener todos los personajes
    Given path charactersPath
    When method GET
    Then status 200
    And match response == '#array'
  Scenario: Crear personaje válido
    Given path charactersPath
    And request validCharacter
    And header Content-Type = 'application/json'
    When method POST
    Then status 201
    And match response contains { name: 'Spider-Man' }
    And match response contains { alterego: 'Peter Parker' }
    And match response.id == '#notnull'
    * def createdId = response.id
  Scenario: Obtener personaje por ID
    # Primero creamos un personaje para tener un ID válido
    Given path charactersPath
    And request validCharacter
    And header Content-Type = 'application/json'
    When method POST
    Then status 201
    * def characterId = response.id    # Ahora obtenemos el personaje por su ID
    Given path charactersPath + '/' + characterId
    When method GET
    Then status 200
    And match response.name == 'Spider-Man'
    And match response.id == characterId
  Scenario: Crear personaje con nombre duplicado
    # Primero creamos un personaje
    Given path charactersPath
    And request validCharacter
    And header Content-Type = 'application/json'
    When method POST
    Then status 201    # Intentamos crear otro con el mismo nombre
    Given path charactersPath
    And request duplicateCharacter
    And header Content-Type = 'application/json'
    When method POST
    Then status 400
    And match response.error == 'Character name already exists'
  Scenario: Crear personaje con datos inválidos
    Given path charactersPath
    And request invalidCharacter
    And header Content-Type = 'application/json'
    When method POST
    Then status 400
    And match response contains { name: '#notnull' }
    And match response contains { alterego: '#notnull' }
    And match response contains { description: '#notnull' }
    And match response contains { powers: '#notnull' }
  Scenario: Obtener personaje inexistente
    Given path charactersPath + '/9999'
    When method GET
    Then status 404
    And match response.error == 'Character not found'
  Scenario: Actualizar personaje existente
    # Primero creamos un personaje
    Given path charactersPath
    And request validCharacter
    And header Content-Type = 'application/json'
    When method POST
    Then status 201
    * def characterId = response.id    # Actualizamos el personaje
    Given path charactersPath + '/' + characterId
    And request updatedCharacter
    And header Content-Type = 'application/json'
    When method PUT
    Then status 200
    And match response.description == 'Superhéroe arácnido de Marvel (actualizado)'
    And match response.id == characterId
  Scenario: Actualizar personaje inexistente
    Given path charactersPath + '/9999'
    And request nonExistentCharacter
    And header Content-Type = 'application/json'
    When method PUT
    Then status 404
    And match response.error == 'Character not found'
  Scenario: Eliminar personaje existente
    # Primero creamos un personaje
    Given path charactersPath
    And request validCharacter
    And header Content-Type = 'application/json'
    When method POST
    Then status 201
    * def characterId = response.id    # Eliminamos el personaje
    Given path charactersPath + '/' + characterId
    When method DELETE
    Then status 204    # Verificamos que ya no existe
    Given path charactersPath + '/' + characterId
    When method GET
    Then status 404

  Scenario: Eliminar personaje inexistente
    Given path baseUrl + '/9999'
    When method DELETE
    Then status 404
    And match response.error == 'Character not found'
