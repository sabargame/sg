import 'package:flutter/material.dart';

void main() {
  runApp(const BoardGameApp());
}

class BoardGameApp extends StatelessWidget {
  const BoardGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BoardGameScreen(),
    );
  }
}

class BoardGameScreen extends StatefulWidget {
  const BoardGameScreen({super.key});

  @override
  State<BoardGameScreen> createState() => _BoardGameScreenState();
}

class _BoardGameScreenState extends State<BoardGameScreen> {
  List<int> board = List.filled(24, 0); // 0 = فارغ، 1 = لاعب1، 2 = لاعب2
  int currentPlayer = 1;
  int player1Pieces = 12;
  int player2Pieces = 12;
  bool mustRemove = false; // إذا لازم اللاعب يحذف حجر الخصم

  /// كل المجموعات (صفوف/أعمدة) اللي تعتبر "Mill"
  final List<List<int>> millCombos = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [15, 16, 17], [18, 19, 20], [21, 22, 23],
    [0, 9, 21], [3, 10, 18], [6, 11, 15],
    [1, 4, 7], [16, 19, 22], [8, 12, 17],
    [5, 13, 20], [2, 14, 23],
    [9, 10, 11], [12, 13, 14],
  ];

  void placePiece(int index) {
    if (mustRemove) {
      // لازم يحذف قبل ما يكمل
      return;
    }
    if (board[index] == 0) {
      setState(() {
        if (currentPlayer == 1 && player1Pieces > 0) {
          board[index] = 1;
          player1Pieces--;
          if (checkMill(index, 1)) {
            mustRemove = true;
          } else {
            currentPlayer = 2;
          }
        } else if (currentPlayer == 2 && player2Pieces > 0) {
          board[index] = 2;
          player2Pieces--;
          if (checkMill(index, 2)) {
            mustRemove = true;
          } else {
            currentPlayer = 1;
          }
        }
      });
    }
  }

  void removePiece(int index) {
    if (!mustRemove) return;
    if (board[index] != 0 && board[index] != currentPlayer) {
      setState(() {
        board[index] = 0;
        mustRemove = false;
        currentPlayer = (currentPlayer == 1) ? 2 : 1;
      });
    }
  }

  bool checkMill(int index, int player) {
    for (var combo in millCombos) {
      if (combo.contains(index)) {
        if (combo.every((i) => board[i] == player)) {
          return true;
        }
      }
    }
    return false;
  }

  final List<Offset> positions = [
    const Offset(0.1, 0.1), const Offset(0.5, 0.1), const Offset(0.9, 0.1),
    const Offset(0.2, 0.2), const Offset(0.5, 0.2), const Offset(0.8, 0.2),
    const Offset(0.3, 0.3), const Offset(0.5, 0.3), const Offset(0.7, 0.3),
    const Offset(0.1, 0.5), const Offset(0.2, 0.5), const Offset(0.3, 0.5),
    const Offset(0.7, 0.5), const Offset(0.8, 0.5), const Offset(0.9, 0.5),
    const Offset(0.3, 0.7), const Offset(0.5, 0.7), const Offset(0.7, 0.7),
    const Offset(0.2, 0.8), const Offset(0.5, 0.8), const Offset(0.8, 0.8),
    const Offset(0.1, 0.9), const Offset(0.5, 0.9), const Offset(0.9, 0.9),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("لعبة الطاحونة - نسخة ثانية")),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              "assets/board.png", // ضع صورة الميدان
              width: 350,
              height: 350,
              fit: BoxFit.contain,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: List.generate(24, (index) {
                  final pos = positions[index];
                  double x = pos.dx * constraints.maxWidth;
                  double y = pos.dy * constraints.maxHeight;

                  Color? color;
                  if (board[index] == 1) {
                    color = Colors.red;
                  } else if (board[index] == 2) {
                    color = Colors.blue;
                  }

                  return Positioned(
                    left: x - 15,
                    top: y - 15,
                    child: GestureDetector(
                      onTap: () {
                        if (mustRemove) {
                          removePiece(index);
                        } else {
                          placePiece(index);
                        }
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color ?? Colors.transparent,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("الدور الحالي: لاعب $currentPlayer"),
                Text("أحجار لاعب 1 (أحمر): $player1Pieces"),
                Text("أحجار لاعب 2 (أزرق): $player2Pieces"),
                if (mustRemove) const Text("يجب حذف حجر من الخصم!", style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
