import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicTacToeGame extends StatefulWidget {
  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> board = List.filled(9, ""); // Estado inicial del tablero
  bool isXTurn = true; // Alterna entre 'X' y 'O'
  String winner = "";
  int winsX = 0;
  int winsO = 0;
  int draws = 0;

  @override
  void initState() {
    super.initState();
    loadGame(); // Cargar el juego al iniciar
  }

  // Función que maneja cuando un jugador presiona una celda
  void handleTap(int index) {
    if (board[index] != "" || winner != "") return;

    setState(() {
      board[index] = isXTurn ? "X" : "O";
      winner = checkWinner();
      isXTurn = !isXTurn;
    });

    if (winner != "") {
      showDialogWinner();
    }
  }

  // Verificar si hay un ganador
  String checkWinner() {
    const List<List<int>> winningPositions = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Filas
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columnas
      [0, 4, 8], [2, 4, 6]             // Diagonales
    ];

    for (var pos in winningPositions) {
      String p0 = board[pos[0]], p1 = board[pos[1]], p2 = board[pos[2]];
      if (p0 != "" && p0 == p1 && p1 == p2) {
        return p0; // Retorna "X" o "O" como ganador
      }
    }

    if (!board.contains("")) return "Empate"; // Detectar empate
    return ""; // Continuar el juego
  }

  // Reiniciar el juego
  void resetGame() {
    setState(() {
      board = List.filled(9, "");
      winner = "";
      isXTurn = true;
    });
  }

  // Nuevo juego: reiniciar el marcador
  void newGame() {
    setState(() {
      board = List.filled(9, "");
      winner = "";
      isXTurn = true;
      winsX = 0;
      winsO = 0;
      draws = 0;
    });
  }

  // Mostrar el diálogo del ganador
  void showDialogWinner() {
    String message = winner == "Empate" ? "¡Empate!" : "Ganador: $winner";
    if (winner == "X") winsX++;
    if (winner == "O") winsO++;
    if (winner != "Empate") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  resetGame();
                  Navigator.of(context).pop();
                },
                child: Text("Continuar"),
              ),
              TextButton(
                onPressed: () {
                  saveGame();
                  Navigator.of(context).pop();
                },
                child: Text("Guardar y Salir"),
              ),
            ],
          );
        },
      );
    }
  }

  // Guardar el estado del juego
  Future<void> saveGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Crear un objeto de partida
    Map<String, dynamic> gameData = {
      'board': board,
      'winsX': winsX,
      'winsO': winsO,
      'draws': draws,
      'isXTurn': isXTurn,
    };

    // Obtener la lista de partidas guardadas
    List<String> savedGames = prefs.getStringList('savedGames') ?? [];
    savedGames.add(jsonEncode(gameData)); // Agregar nueva partida

    // Guardar la lista actualizada
    await prefs.setStringList('savedGames', savedGames);
  }

  // Cargar el estado del juego
  Future<void> loadGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedGames = prefs.getStringList('savedGames');
    if (savedGames != null && savedGames.isNotEmpty) {
      showLoadGameDialog(savedGames); // Mostrar el diálogo para cargar partidas
    }
  }

  // Mostrar diálogo para seleccionar partida guardada
  void showLoadGameDialog(List<String> savedGames) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Cargar Partida"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: savedGames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("Partida ${index + 1}"),
                  onTap: () {
                    loadSelectedGame(savedGames[index]);
                    Navigator.of(context).pop(); // Cerrar el diálogo
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Cargar partida seleccionada
  void loadSelectedGame(String gameData) {
    Map<String, dynamic> data = jsonDecode(gameData);
    setState(() {
      board = List<String>.from(data['board']);
      winsX = data['winsX'];
      winsO = data['winsO'];
      draws = data['draws'];
      isXTurn = data['isXTurn'];
    });
  }

  // Menú de opciones
  void showMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Opciones"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  newGame();
                  Navigator.of(context).pop();
                },
                child: Text("Juego Nuevo"),
              ),
              TextButton(
                onPressed: () {
                  resetGame();
                  Navigator.of(context).pop();
                },
                child: Text("Reiniciar"),
              ),
              TextButton(
                onPressed: () {
                  loadGame();
                  Navigator.of(context).pop();
                },
                child: Text("Cargar Juego"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Aquí puedes implementar la lógica para salir
                },
                child: Text("Salir"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Juego del Gato'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => showMenu(context),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: 9,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => handleTap(index),
                child: Container(
                  margin: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      board[index],
                      style: TextStyle(
                        fontSize: 60,
                        color: board[index] == "X"
                            ? Colors.red
                            : (board[index] == "O"
                            ? Colors.lightGreenAccent
                            : Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Texto que indica el turno del jugador
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              winner == ""
                  ? "Turno de ${isXTurn ? 'X' : 'O'}"
                  : winner == "Empate"
                  ? "¡Empate!"
                  : "Ganador: $winner",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          // Puntuación
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Puntuación: X: $winsX - O: $winsO - Empates: $draws",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: saveGame,
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: resetGame,
            ),
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: newGame,
            ),
            IconButton(
              icon: Icon(Icons.download),
              onPressed: loadGame,
            ),
          ],
        ),
      ),
    );
  }
}
