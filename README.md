# Happy
This is a cooperative game where you play as two red pandas. Together with your friend, you must solve puzzles, collect coins, and help each other progress.  
The game is developed in Godot by a single student as a university project. At the moment, around 125 hours have been spent on development.

# ✔️ Checklist

## 🎮 1. Player
The game features 2 players, controlled using A/D or Left/Right arrow keys.  
W or Up arrow is used for jumping.  
S or Down arrow is used for pressing buttons.
If you scroll the mouse wheel, the camera will zoom in/out.

* Multidirectional movement
* 2 special actions (jump, press button)

## 👾 2. Enemies
The game includes one enemy with several states: idle, patrol, chase, and attack.  
The enemy scans specific areas for players. If a player is detected, it switches to the chase state, and once close enough, begins attacking. If no players are detected, it simply wanders and occasionally stops.

The enemy can perform the same actions as the players: press buttons and move boxes. These mechanics are used in some levels.

The enemy uses a zone-based system: it knows which zones are accessible and which are not.  
If the player and the enemy are in different zones but the door between them is open, the enemy will pursue the player. If the door is closed, the enemy remains in its normal state.

The enemy has a special mechanic on one of the levels: if it ends up trapped while the players are near the finish, it will activate its ability that opens the doors for itself.

* “Intelligent” AI: states, navigation, reactive behavior

## 🌍 3. Scene Complexity
Levels include various platforming elements, buttons that open passages, doors controlled by buttons, moving platforms, and boxes that can be pushed by the characters.

* Accessible and inaccessible areas
* Interactive elements (buttons)
* Animated objects (moving platforms, doors)

## 🗺️ 4. Number of Scenes
Currently the game contains 3 different levels, each using its own mechanics.

* 3 different levels

## 💎 5. Collectibles
There are 2 types of collectible coins:  
A regular gold coin increases the total coin counter, and a blue coin increases the player’s movement speed.

On the first level, coins may appear in random positions. A GET request is made to the server to obtain spawn positions for the coins. If the GET request fails, coins appear in their default locations.

* 2 types of collectible items
* At least one provides a significant advantage

## 🌐 6. REST API
The game sends POST and GET requests to a local server created with Python using Django.  
POST sends all player information after completing a level or pressing the synchronization button in the main menu.  
GET retrieves all user data from the database.
GET is also used to obtain random positions for coins.

* 2+ endpoints
* Visual impact inside the game
* API created with another technology (Django)

## 🔊 7. Sound
Each level has its own background music.  
Player movement includes footstep and jump sounds.  
There is also a sound effect when collecting coins.

* 2 sound effects
* 2 background music tracks

## ⚙️ 8. Persistent Options
In the main menu, players can customize the game: change their name, enable fullscreen mode, or adjust music volume.
The settings will be saved and loaded after restarting the game.

* 2+ saved settings (name, fullscreen, music volume)

  # Installation and Launch

## Starting the Server

Required libraries:

```
pip install djangorestframework
pip install djangorestframework-simplejwt
```

The server is located in `HappyDjango/happyserver`
Launch:

```
python manage.py runserver
```

## Running the Game

The ready-to-play build is located at:
`HappyProject\Bluid\PC\Happy.exe`
