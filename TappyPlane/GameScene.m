//
//  GameScene.m
//  TappyPlane
//
//  Created by Kenneth Wilcox on 10/29/14.
//  Copyright (c) 2014 Kenneth Wilcox. All rights reserved.
//

#import "GameScene.h"
#import "Plane.h"
#import "ScrollingLayer.h"
#import "Constants.h"
#import "ObstacleLayer.h"
#import "BitmapFontLabel.h"
#import "TilesetTextureProvider.h"
#import "GetReadyMenu.h"
#import "WeatherLayer.h"
#import "SoundManager.h"

typedef enum : NSUInteger {
  GameReady,
  GameRunning,
  GameOver,
} GameState;

@interface GameScene()
@property (nonatomic) Plane *player;
@property (nonatomic) SKNode *world;
@property (nonatomic) ScrollingLayer *background;
@property (nonatomic) ScrollingLayer *foreground;
@property (nonatomic) ObstacleLayer *obstacles;
@property (nonatomic) WeatherLayer *weather;
@property (nonatomic) BitmapFontLabel *scoreLabel;
@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger bestScore;
@property (nonatomic) GameOverMenu *gameOverMenu;
@property (nonatomic) GetReadyMenu *getReadyMenu;
@property (nonatomic) GameState gameState;
@property (nonatomic) NSUserDefaults *defaults;
@end

static const CGFloat kMinFPS = 10.00 / 60.00;
static NSString *const kKeyBestScore = @"BestScore";

@implementation GameScene

- (instancetype) initWithSize:(CGSize)size
{
  if (!(self = [super initWithSize:size]))
    return nil;
  
  // Init audio
  [[SoundManager sharedManager] prepareToPlayWithSound:@"Crunch.caf"];
  
  // Set background color to sky blue
  self.backgroundColor = [SKColor colorWithRed:0.835294118 green:0.929411765 blue:0.968627451 alpha:1.0];
  
  // Get atlas file
  SKTextureAtlas *graphics = [SKTextureAtlas atlasNamed:@"Graphics"];
  
  // Setup physics
  self.physicsWorld.gravity = CGVectorMake(0.0, -4.0);
  self.physicsWorld.contactDelegate = self;
  
  // Setup world
  _world = [SKNode node];
  [self addChild:_world];
  
  // Setup background tiles
  NSMutableArray *backgroudTiles = [[NSMutableArray alloc] init];
  for (int i = 0; i < 3; i++) {
    [backgroudTiles addObject:[SKSpriteNode spriteNodeWithTexture:[graphics textureNamed:@"background"]]];
  }
  
  // Setup background
  _background = [[ScrollingLayer alloc] initWithTiles:backgroudTiles];
  _background.horizontalScrollSpeed = -60;
  _background.scrolling = YES;
  [_world addChild:_background];
  
  // Setup obstacle layer
  _obstacles = [[ObstacleLayer alloc] initWithChallenges:YES];
  _obstacles.collectableDelegate = self;
  _obstacles.horizontalScrollSpeed = -70;
  _obstacles.scrolling = YES;
  _obstacles.floor = 0.0;
  _obstacles.ceiling = self.size.height;
  [_world addChild:_obstacles];
  
  // Setup foreground
  _foreground = [[ScrollingLayer alloc] initWithTiles:@[[self generateGroundTile],[self generateGroundTile],[self generateGroundTile]]];
  _foreground.horizontalScrollSpeed = -80;
  _foreground.scrolling = YES;
  [_world addChild:_foreground];
  
  // Setup player
  _player = [[Plane alloc] init];
  _player.physicsBody.affectedByGravity = NO;
  [_world addChild:_player];
  
  // Setup weather
  _weather = [[WeatherLayer alloc] initWithSize:self.size];
  [_world addChild:_weather];
  
  // Setup score label
  _scoreLabel = [[BitmapFontLabel alloc] initWithText:@"0" andFontName:@"number"];
  _scoreLabel.position = CGPointMake(self.size.width * 0.5, self.size.height - 30);
  [self addChild:_scoreLabel];
  
  // Setup game over menu
  _gameOverMenu = [[GameOverMenu alloc] initWithSize:size];
  _gameOverMenu.delegate = self;
  
  // Setup get ready menu
  _getReadyMenu = [[GetReadyMenu alloc] initWithSize:size andPlayerPosition:CGPointMake(self.size.width * 0.3, self.size.height * 0.5)];
  [self addChild:_getReadyMenu];
  
  // Load best score
  _defaults = [NSUserDefaults standardUserDefaults];
  self.bestScore = [_defaults integerForKey:kKeyBestScore];
  
  [self newGame];
  
  return self;
}

- (SKSpriteNode*)generateGroundTile
{
  SKTextureAtlas *graphics = [SKTextureAtlas atlasNamed:@"Graphics"];
  SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:[graphics textureNamed:@"groundGrass"]];
  sprite.anchorPoint = CGPointZero;
  
  CGFloat offsetX = sprite.frame.size.width * sprite.anchorPoint.x;
  CGFloat offsetY = sprite.frame.size.height * sprite.anchorPoint.y;
  
  CGMutablePathRef path = CGPathCreateMutable();
  
  CGPathMoveToPoint(path, NULL, 403 - offsetX, 17 - offsetY);
  CGPathAddLineToPoint(path, NULL, 383 - offsetX, 22 - offsetY);
  CGPathAddLineToPoint(path, NULL, 373 - offsetX, 34 - offsetY);
  CGPathAddLineToPoint(path, NULL, 329 - offsetX, 33 - offsetY);
  CGPathAddLineToPoint(path, NULL, 318 - offsetX, 23 - offsetY);
  CGPathAddLineToPoint(path, NULL, 298 - offsetX, 22 - offsetY);
  CGPathAddLineToPoint(path, NULL, 286 - offsetX, 7 - offsetY);
  CGPathAddLineToPoint(path, NULL, 267 - offsetX, 8 - offsetY);
  CGPathAddLineToPoint(path, NULL, 256 - offsetX, 13 - offsetY);
  CGPathAddLineToPoint(path, NULL, 235 - offsetX, 13 - offsetY);
  CGPathAddLineToPoint(path, NULL, 219 - offsetX, 28 - offsetY);
  CGPathAddLineToPoint(path, NULL, 187 - offsetX, 28 - offsetY);
  CGPathAddLineToPoint(path, NULL, 174 - offsetX, 21 - offsetY);
  CGPathAddLineToPoint(path, NULL, 155 - offsetX, 22 - offsetY);
  CGPathAddLineToPoint(path, NULL, 125 - offsetX, 33 - offsetY);
  CGPathAddLineToPoint(path, NULL, 79 - offsetX, 30 - offsetY);
  CGPathAddLineToPoint(path, NULL, 67 - offsetX, 18 - offsetY);
  CGPathAddLineToPoint(path, NULL, 45 - offsetX, 12 - offsetY);
  CGPathAddLineToPoint(path, NULL, 20 - offsetX, 14 - offsetY);
  CGPathAddLineToPoint(path, NULL, 17 - offsetX, 18 - offsetY);
  CGPathAddLineToPoint(path, NULL, 0 - offsetX, 17 - offsetY);
  
  sprite.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:path];
  sprite.physicsBody.categoryBitMask = kCategoryGround;

//#if DEBUG
//    SKShapeNode *bodyShape = [SKShapeNode node];
//    bodyShape.path = path;
//    bodyShape.strokeColor = [SKColor redColor];
//    bodyShape.lineWidth = 2.0;
//    bodyShape.zPosition = 99.0;
//    [sprite addChild:bodyShape];
//#endif
  
  return sprite;
}

- (void)newGame
{
  // Randomize tileset
  [[TilesetTextureProvider getProvider] randomizeTileset];
  
  // Set weather conditions
  NSString *tilesetName = [TilesetTextureProvider getProvider].currentTileSetName;
  self.weather.conditions = WeatherClear;
  if ([tilesetName isEqualToString:kTilesetIce] || [tilesetName isEqualToString:kTilesetSnow]) {
    // 50% chance of snow
    if (arc4random_uniform(2) == 0) {
      self.weather.conditions = WeatherSnowing;
    }
  }
  
  if ([tilesetName isEqualToString:kTilesetGrass] || [tilesetName isEqualToString:kTilesetDirt]) {
    // 33% chance of rain
    if (arc4random_uniform(3) == 0) {
      self.weather.conditions = WeatherRaining;
    }
  }
  
  // Reset layers
  self.foreground.position = CGPointZero;
  for (SKSpriteNode *node in self.foreground.children) {
    node.texture = [[TilesetTextureProvider getProvider] getTextureForKey:@"ground"];
  }
  
  [self.foreground layoutTiles];
  
  self.obstacles.position = CGPointZero;
  [self.obstacles reset];
  self.obstacles.scrolling = NO;
  
  self.background.position = CGPointZero;
  [self.background layoutTiles];

  // Reset score
  self.score = 0;
  self.scoreLabel.alpha = 1.0;
  
  // Reset plane
  self.player.position = CGPointMake(self.size.width * 0.3, self.size.height * 0.5);
  self.player.physicsBody.affectedByGravity = NO;
  [self.player reset];
  
  // Set game state to ready
  self.gameState = GameReady;
}

- (void)gameOver
{
  self.gameState = GameOver;
  [self.scoreLabel runAction:[SKAction fadeOutWithDuration:0.4]];
  
  self.gameOverMenu.score = self.score;
  // Based on previous best score, not current
  self.gameOverMenu.medal = [self getMedalForCurrentScore];
  if (self.score > self.bestScore) {
    self.bestScore = self.score;
    [_defaults setInteger:self.bestScore forKey:kKeyBestScore];
    [_defaults synchronize];
  }
  self.gameOverMenu.bestScore = self.bestScore;
  
  [self addChild:self.gameOverMenu];
  [self.gameOverMenu show];
}

- (void)bump
{
  SKAction *bump = [SKAction sequence:@[[SKAction moveBy:CGVectorMake(-5, -4) duration:0.1], [SKAction moveTo:CGPointZero duration:0.1]]];
  [self.world runAction:bump];
}

- (void)setScore:(NSInteger)score
{
  _score = score;
  self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)score];
}

- (MedalType)getMedalForCurrentScore
{
  NSInteger adjustedScore = self.score - (self.bestScore / 5);
  if (adjustedScore >= 45) {
    return MedalGold;
  } else if (adjustedScore >= 25) {
    return MedalSilver;
  } else if (adjustedScore >= 10) {
    return MedalBronze;
  }
  return MedalNone;
}

#pragma mark GameOverMenu delegate

- (void)pressedStartNewGameButton
{
  SKSpriteNode *blackRectangle = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:self.size];
  blackRectangle.anchorPoint = CGPointZero;
  blackRectangle.alpha = 0.001;
  blackRectangle.zPosition = 99;
  [self addChild:blackRectangle];
  
  SKAction *startNewGame = [SKAction runBlock:^{
    [self newGame];
    [self.gameOverMenu removeFromParent];
    [self.getReadyMenu show];
  }];
  
  SKAction *fadeTransition = [SKAction sequence:@[[SKAction fadeInWithDuration:0.4], startNewGame, [SKAction fadeOutWithDuration:1.6], [SKAction removeFromParent]]];
  [blackRectangle runAction:fadeTransition];
}

# pragma mark CollectableDelegate methods

- (void)wasCollected:(Collectable *)collectable
{
  self.score += collectable.pointValue;
  
}

#pragma mark UIResponder delegates

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (self.gameState == GameReady) {
    [self.getReadyMenu hide];
    self.player.physicsBody.affectedByGravity = YES;
    self.obstacles.scrolling = YES;
    self.gameState = GameRunning;
  }
  
  if (self.gameState == GameRunning) {
#if FLAP
    [_player flap];
#else
    //self.player.engineRunning = !self.player.engineRunning;
    self.player.accelerating = YES;
#endif
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (self.gameState == GameRunning) {
#if !FLAP
    self.player.accelerating = NO;
    //self.player.engineRunning = NO;
#endif
  }
}

#pragma mark SKScene override

- (void)update:(NSTimeInterval)currentTime
{
  static NSTimeInterval lastCallTime;
  NSTimeInterval timeElapsed = currentTime - lastCallTime;
  if (timeElapsed > kMinFPS) {
    timeElapsed = kMinFPS;
  }
  lastCallTime = currentTime;
  
  [self.player update];
  
  if (self.gameState == GameRunning && self.player.crashed) {
    // Player just crashed in the last frame
    [self bump];
    [self gameOver];
  }
  
  if (self.gameState != GameOver) {
    [self.background updateWithTimeElapsed:timeElapsed];
    [self.foreground updateWithTimeElapsed:timeElapsed];
    [self.obstacles updateWithTimeElapsed:timeElapsed];
  }
}

#pragma mark SKPhysicsContactDelegate methods

- (void)didBeginContact:(SKPhysicsContact *)contact
{
  if (contact.bodyA.categoryBitMask == kCategoryPlane) {
    [self.player collide:contact.bodyB];
  } else if (contact.bodyB.categoryBitMask == kCategoryPlane) {
    [self.player collide:contact.bodyA];
  }
}

@end
