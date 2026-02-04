import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const StarBattleApp());
}

class StarBattleApp extends StatelessWidget {
  const StarBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

enum Difficulty { easy, hard, extreme }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int maxNumber = 100;

  Difficulty difficulty = Difficulty.easy;

  int maxAttempts = 10;
  int attemptsLeft = 10;

  int currentPlayer = 1;

  int scorePlayer1 = 0;
  int scorePlayer2 = 0;

  late int starNumber;

  Set<int> disabledNumbers = {};

  @override
  void initState() {
    super.initState();
    startRound();
  }

  void setDifficulty(Difficulty diff) {
    setState(() {
      difficulty = diff;
      if (diff == Difficulty.easy) maxAttempts = 10;
      if (diff == Difficulty.hard) maxAttempts = 6;
      if (diff == Difficulty.extreme) maxAttempts = 3;
      startRound(resetScores: true);
    });
  }

  void startRound({bool resetScores = false}) {
    starNumber = Random().nextInt(maxNumber) + 1;
    attemptsLeft = maxAttempts;
    disabledNumbers.clear();

    if (resetScores) {
      scorePlayer1 = 0;
      scorePlayer2 = 0;
      currentPlayer = 1;
    }

    setState(() {});
  }

  int calculatePoints(int usedAttempts) {
    int minPoints = 20;
    int maxPoints = 100;

    double ratio = 1 - ((usedAttempts - 1) / (maxAttempts - 1));
    return (minPoints + (maxPoints - minPoints) * ratio).round();
  }

  void onTapNumber(int number) {
    if (disabledNumbers.contains(number) || attemptsLeft == 0) return;

    setState(() {
      attemptsLeft--;

      if (number == starNumber) {
        int used = maxAttempts - attemptsLeft;
        int points = calculatePoints(used);

        if (currentPlayer == 1) {
          scorePlayer1 += points;
        } else {
          scorePlayer2 += points;
        }

        showEndDialog(true, points);
      } else if (number < starNumber) {
        for (int i = 1; i <= number; i++) {
          disabledNumbers.add(i);
        }
      } else {
        for (int i = number; i <= maxNumber; i++) {
          disabledNumbers.add(i);
        }
      }

      if (attemptsLeft == 0 && number != starNumber) {
        showEndDialog(false, 0);
      }
    });
  }

  void showEndDialog(bool win, int points) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(win ? "⭐ Bulundu!" : "😢 Hak Bitti"),
        content: Text(
          win
              ? "Oyuncu $currentPlayer kazandı!\n+$points puan"
              : "Yıldız $starNumber numarada.\nSıra rakipte!",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              switchPlayer();
            },
            child: const Text("Devam"),
          )
        ],
      ),
    );
  }

  void switchPlayer() {
    currentPlayer = currentPlayer == 1 ? 2 : 1;
    startRound();
  }

  Color tileColor(int number) {
    return disabledNumbers.contains(number)
        ? Colors.grey
        : Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("⭐ Yıldız Avı - 2 Oyuncu"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// SKOR TABLOSU
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Oyuncu 1: $scorePlayer1",
                      style: const TextStyle(fontSize: 18)),
                  Text("Sıra: Oyuncu $currentPlayer",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Oyuncu 2: $scorePlayer2",
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),

            /// ZORLUK
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                difficultyButton("Kolay", Difficulty.easy),
                difficultyButton("Zor", Difficulty.hard),
                difficultyButton("Çok Zor", Difficulty.extreme),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              "Kalan Hak: $attemptsLeft",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 6),

            /// GRID
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(4),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                  childAspectRatio: 1.2,
                ),
                itemCount: maxNumber,
                itemBuilder: (context, index) {
                  int number = index + 1;
                  return GestureDetector(
                    onTap: () => onTapNumber(number),
                    child: Container(
                      decoration: BoxDecoration(
                        color: tileColor(number),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          "$number",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget difficultyButton(String text, Difficulty diff) {
    bool selected = difficulty == diff;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selected ? Colors.orange : Colors.blue,
        ),
        onPressed: () => setDifficulty(diff),
        child: Text(text),
      ),
    );
  }
}
