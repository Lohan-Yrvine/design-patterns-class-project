import 'dart:async' show Timer;

import 'package:flame/flame.dart';
import 'package:flame/components.dart' hide Timer;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

import 'logger/logger.dart';
import 'player/player.dart';
import 'bosses/bosses.dart';
import 'map_maker/map_maker.dart';
import 'text_box.dart';

class MyGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  final Logger _logger = Logger();

  Logger get logger => _logger;

  late TextBox _textBox;

  // mapa
  late final _components = MapMaker(this).make();
  final _scenerySpritesPath = 'scenery.png';
  final _objectsSpritesPath = 'objects.png';
  final _tileSizeInPixels = 32.0;
  late final TiledComponent _map;
  late final _mapWidthInTiles = _map.width / _tileSizeInPixels;
  late final _mapHeightInTiles = _map.height / _tileSizeInPixels;

  String get scenerySpritePath => _scenerySpritesPath;
  String get objectsSpritePath => _objectsSpritesPath;
  double get tileSizeInPixels => _tileSizeInPixels;
  double get mapWidthInPixels => _map.width;
  double get mapHeightInPixels => _map.height;
  double get mapWidthInTiles => _mapWidthInTiles;
  double get mapHeightInTiles => _mapHeightInTiles;

  late final _player = Player(this);
  late final _cpu = CPU(this);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await Flame.images.load(_scenerySpritesPath);
    await Flame.images.load(_objectsSpritesPath);

    _map = await TiledComponent.load('map.tmx', Vector2.all(_tileSizeInPixels));
    await add(_map);
    mapComponents(1);

    await add(_player);

    camera.viewport = FixedResolutionViewport(
        Vector2(_map.width, _map.height + _tileSizeInPixels));

    _textBox = TextBox(
        text: 'Não aguento mais ter que consertar computador da Negativo...',
        game: this,
        player: _player);
    add(_textBox);
    startGame();
  }

  Sprite gameSprites(String spritePath, Vector2 position) {
    return Sprite(Flame.images.fromCache(spritePath),
        srcPosition: position, srcSize: Vector2.all(_tileSizeInPixels));
  }

  void mapComponents(int op) {
    for (Component component in _components) {
      if (op == 1) {
        add(component);
      } else if (_isRemovable(component)) {
        remove(component);
      }
    }
  }

  bool _isRemovable(Component component) {
    return ((component is! Wall) &
        (component is! Plant) &
        (component is! Shelf) &
        (component is! Board));
  }

  void startGame() {
    _player.moveSpeed = 85;
    _player.movement.y -= 1;
    _player.animation = _player.upAnimation;
    _player.canWalk = false;
    Timer(
        const Duration(milliseconds: 3000),
        () => {
              _player.movement.y = 0,
              _player.animation = _player.leftAnimation,
              _player.movement.x -= 1
            });
    Timer(
        const Duration(milliseconds: 4120),
        () => {
              _player.movement.x = 0,
              _player.animation = _player.upAnimation,
              _player.movement.y -= 1
            });
    Timer(
        const Duration(milliseconds: 4600),
        () => {
              _player.movement.y = 0,
              _player.animation = _player.idleUp,
              _player.moveSpeed = 135.0
            });
  }

  void startCombat() {
    add(_cpu);
    mapComponents(2);
  }
}
