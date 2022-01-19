import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pong/ball.dart';
import 'package:pong/brick.dart';
import 'package:pong/coverscreen.dart';
import 'package:pong/score_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

enum direction { up, down, left, right }

class _HomePageState extends State<HomePage> {
  //player variables (bottom brick)
  double playerX = 0;
  double brickWidth = 0.4; //out of 2
  int playerScore = 0;

  //AI variables (top brick)
  double enemyX = -0.2;
  int enemyScore = 0;

  //ball variables
  double ballX = 0;
  double ballY = 0;
  var ballXDirection = direction.left;
  var ballYDirection = direction.down;

  //game settings
  bool gameHasStarted = false;

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(Duration(milliseconds: 1), (timer) {
      //update direction
      updateDirection();

      //move ball
      moveBall();

      //move enemy
      moveEnemy();

      //check if player is dead
      if (isPlayerDead()) {
        enemyScore++;
        timer.cancel();
        _showDialog(false);
      }

      //check if enemy is dead
      if (isEnemyDead()) {
        playerScore++;
        timer.cancel();
        _showDialog(true);
      }
    });
  }

  bool isEnemyDead() {
    if (ballY <= -1) {
      return true;
    }
    return false;
  }

  bool isPlayerDead() {
    if (ballY >= 1) {
      return true;
    }
    return false;
  }

  void moveEnemy() {
    setState(() {
      enemyX = ballX;
    });
  }

  void _showDialog(bool enemyDied) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.deepPurple,
            title: Center(
              child: Text(
                enemyDied ? "YOU WON" : "AI WON" ,
                style: TextStyle(color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: resetGame,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: EdgeInsets.all(7),
                    color: enemyDied ? Colors.pink[300] : Colors.deepPurple[100],
                    child: Text(
                      "PLAY AGAIN",
                      style: TextStyle(color: enemyDied ? Colors.pink[300] : Colors.deepPurple[800]),
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }

  void resetGame() {
    Navigator.pop(context);
    setState(() {
      gameHasStarted = false;
      ballX = 0;
      ballY = 0;
      playerX = -0.2;
      enemyX = -0.2;
    });
  }

  void updateDirection() {
    setState(() {
      //update vertical direction
      if (ballY >= 0.9 && playerX + brickWidth >= ballX && playerX <= ballX) {
        ballYDirection = direction.up;
      } else if (ballY <= -0.9) {
        ballYDirection = direction.down;
      }

      //update horizontal direction
      if (ballX >= 1) {
        ballXDirection = direction.left;
      } else if (ballX <= -1) {
        ballXDirection = direction.right;
      }
    });
  }

  void moveBall() {
    setState(() {
      //vertical movement
      if (ballYDirection == direction.down) {
        ballY += 0.01;
      } else if (ballYDirection == direction.up) {
        ballY -= 0.01;
      }
      //horizontal movement
      if (ballXDirection == direction.left) {
        ballX -= 0.01;
      } else if (ballXDirection == direction.right) {
        ballX += 0.01;
      }
    });
  }

  void moveLeft() {
    setState(() {
      if (!(playerX - 0.1 <= -1)) {
        playerX -= 0.1;
      }
    });
  }

  void moveRight() {
    setState(() {
      if (!(playerX + 0.1 >= 1)) {
        playerX += 0.1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          moveLeft();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          moveRight();
        }
      },
      child: GestureDetector(
        onTap: startGame,
        child: Scaffold(
            backgroundColor: Colors.grey[900],
            body: Center(
                child: Stack(
              children: [
                //tap to play
                CoverScreen(
                  gameHasStarted: gameHasStarted,
                ),
                //score screen
                ScoreScreen(
                  gameHasStarted: gameHasStarted,
                  enemyScore: enemyScore,
                  playerScore: playerScore,
                ),
                //enemy - top brick
                MyBrick(
                    x: enemyX,
                    y: -0.9,
                    brickWidth: brickWidth,
                    thisIsEnemy: true),
                //player - bottom brick
                MyBrick(
                    x: playerX,
                    y: 0.9,
                    brickWidth: brickWidth,
                    thisIsEnemy: false),
                //ball
                MyBall(x: ballX, y: ballY, gameHasStarted: gameHasStarted),
              ],
            ))),
      ),
    );
  }
}
