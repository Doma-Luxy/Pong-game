# Pong

## About Flutter:
Flutter is Google's UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. Flutter works with existing code, is used by developers and organizations around the world, and is free and open source.

## About this game:
This is a simple game made with Flutter, paying homage to of the very first games, Pong. Pong is groundbreaking electronic game released in 1972 by the American game manufacturer Atari, Inc. One of the earliest video games, Pong became wildly popular and helped launch the video game industry. The original Pong consisted of two paddles that players used to volley a small ball back and forth across a screen. In this case the other paddle is contolled by the software. *To be exact the AI paddle is configugred in a way that it reads the x coordinate of the ball so it cannot miss, sorry if you tried and could not win :P*

## Game demo:
https://user-images.githubusercontent.com/54951169/150196984-a5a8fb23-7232-470f-a8ba-46b3e7f90c29.mov

## Brief code explanation:
The code is organised into multiple funcional files, which are:

* `ball.dart`
* `brick.dart`
* `coverscreen.dart`
* `homepage.dart`
* `main.dart`
* `score_screen.dart` 

### `ball.dart`
Here we define the *MyBall* class with the properties of the the ball. It is worth mentioning that we used the *avatar_glow* dependencie to create the pučsating effect of the ball.

```dart
class MyBall extends StatelessWidget {
  final x;
  final y;
  final bool gameHasStarted;

  MyBall({this.x, this.y,required this.gameHasStarted});

  @override
  Widget build(BuildContext context) {
    return gameHasStarted
        ? Container(
            alignment: Alignment(x, y),
            child: Container(
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              width: 30,
              height: 30,
            ),
          )
        : Container(
            alignment: Alignment(x, y),
            child: AvatarGlow(
                endRadius: 60,
                child: Material(
                    elevation: 8,
                    shape: CircleBorder(),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[100],
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        width: 30,
                        height: 30,
                      ),
                      radius: 7.0,
                    ))),
          );
  }
}
  ```
### `brick.dart`
Here we define the *MyBrick* class with the properties of the the paddles.
```dart
  final x;
  final y;
  final brickWidth; //out of 2
  final thisIsEnemy;

  MyBrick({this.x, this.y, this.brickWidth, this.thisIsEnemy});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(x, y),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: thisIsEnemy ? Colors.deepPurple[300] : Colors.pink[300],
          height: 20,
          width: MediaQuery.of(context).size.width * brickWidth / 2,
        ),
      ),
    );
  }
}
```
### `coverscreen.dart`
Here we a simple widget to writeout the message "T A P  T O  P L A Y" for the user.
```dart
class CoverScreen extends StatelessWidget {
  final bool gameHasStarted;

  CoverScreen({required this.gameHasStarted});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(0, -0.2),
      child: Text(
        gameHasStarted ?  '' : 'T A P  TO  P L A Y',
        style: TextStyle(color: Colors.white)),
    );
  }
}
```
### `homepage.dart`
Here lays the main part of the code as we define the movement of the ball, movenemt of the paddles (the game moves the upper brick, and the player uses arrow keys on the keyboard) and also define the rules where we restrain the ball movement on the left and right side of the screen.
```dart

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
```

### `score_screen.dart`
In this file we create a class *ScoreScreen* which keeps track of the score since the game launch.
```dart

class ScoreScreen extends StatelessWidget {
  final bool gameHasStarted;
  final enemyScore;
  final playerScore;

  ScoreScreen({required this.gameHasStarted, this.enemyScore, this.playerScore});

  @override
  Widget build(BuildContext context) {
    return gameHasStarted
        ? Stack(
            children: [
              Container(
                alignment: Alignment(0, 0),
                child: Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width / 3,
                  color: Colors.grey[700],
                ),
              ),
              Container(
                alignment: Alignment(0, -0.3),
                child: Text(enemyScore.toString(),
                    style: TextStyle(color: Colors.grey[700], fontSize: 100)),
              ),
              Container(
                alignment: Alignment(0, 0.3),
                child: Text(playerScore.toString(),
                    style: TextStyle(color: Colors.grey[700], fontSize: 100)),
              ),
            ],
          )
        : Container();
  }
}
```
