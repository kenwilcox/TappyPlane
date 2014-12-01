//
//  GameOverMenu.m
//  TappyPlane
//
//  Created by Kenneth Wilcox on 11/25/14.
//  Copyright (c) 2014 Kenneth Wilcox. All rights reserved.
//

#import "GameOverMenu.h"
#import "BitmapFontLabel.h"
#import "Button.h"
#import "SoundManager.h"

@interface GameOverMenu()
@property (nonatomic) SKSpriteNode *medalDisplay;
@property (nonatomic) SKTextureAtlas *atlas;
@property (nonatomic) BitmapFontLabel *scoreText;
@property (nonatomic) BitmapFontLabel *bestScoreText;

@property (nonatomic) SKSpriteNode *gameOverTitle;
@property (nonatomic) SKNode *panelGroup;
@property (nonatomic) Button *playButton;
@end

@implementation GameOverMenu

- (instancetype)initWithSize:(CGSize)size;
{
  if (!(self = [super init]))
    return nil;
  _size = size;
  
  _atlas = [SKTextureAtlas atlasNamed:@"Graphics"];
  
  // Setup game over title text
  _gameOverTitle = [SKSpriteNode spriteNodeWithTexture:[_atlas textureNamed:@"textGameOver"]];
  _gameOverTitle.position = CGPointMake(size.width * 0.5, size.height - 70);
  [self addChild:_gameOverTitle];
  
  // Setup node to act as a group for panel elements
  _panelGroup = [SKNode node];
  [self addChild:_panelGroup];
  
  // Setup background panel
  SKSpriteNode *panelBackground = [SKSpriteNode spriteNodeWithTexture:[_atlas textureNamed:@"UIbg"]];
  panelBackground.position = CGPointMake(size.width * 0.5, size.height - 150.00);
  CGFloat width = panelBackground.size.width;
  CGFloat height = panelBackground.size.height;
  panelBackground.centerRect = CGRectMake((10 / width), (10 / height), ((width -20) / width) ,((height -20) / height));
  panelBackground.xScale = 175.0 / width;
  panelBackground.yScale = 115.0 / height;
  [self.panelGroup addChild:panelBackground];
  
  // Setup score title
  SKSpriteNode *scoreTitle = [SKSpriteNode spriteNodeWithTexture:[_atlas textureNamed:@"textScore"]];
  scoreTitle.anchorPoint = CGPointMake(1.0, 1.0);
  scoreTitle.position = CGPointMake(CGRectGetMaxX(panelBackground.frame) -20, CGRectGetMaxY(panelBackground.frame) -10);
  [self.panelGroup addChild:scoreTitle];
  
  // Setup score text label
  _scoreText = [[BitmapFontLabel alloc] initWithText:@"0" andFontName:@"number"];
  _scoreText.alignment = BitmapFontAlignmentRight;
  _scoreText.position = CGPointMake(CGRectGetMaxX(scoreTitle.frame), CGRectGetMinY(scoreTitle.frame) - 15);
  [_scoreText setScale:0.5];
  [self.panelGroup addChild:_scoreText];
  
  // Setup best title
  SKSpriteNode *bestTitle = [SKSpriteNode spriteNodeWithTexture:[_atlas textureNamed:@"textBest"]];
  bestTitle.anchorPoint = CGPointMake(1.0, 1.0);
  bestTitle.position = CGPointMake(CGRectGetMaxX(panelBackground.frame) - 20, CGRectGetMaxY(panelBackground.frame) - 60);
  [self.panelGroup addChild:bestTitle];
  
  // Setup bestscore text label
  _bestScoreText = [[BitmapFontLabel alloc] initWithText:@"0" andFontName:@"number"];
  _bestScoreText.alignment = BitmapFontAlignmentRight;
  _bestScoreText.position = CGPointMake(CGRectGetMaxX(bestTitle.frame), CGRectGetMinY(bestTitle.frame) - 15);
  [_bestScoreText setScale:0.5];
  [self.panelGroup addChild:_bestScoreText];
  
  // Setup medal title
  SKSpriteNode *medalTitle = [SKSpriteNode spriteNodeWithTexture:[_atlas textureNamed:@"textMedal"]];
  medalTitle.anchorPoint = CGPointMake(0.0, 1.0);
  medalTitle.position = CGPointMake(CGRectGetMinX(panelBackground.frame) + 20, CGRectGetMaxY(panelBackground.frame) - 10);
  [self.panelGroup addChild:medalTitle];
  
  // Setup display of medal
  _medalDisplay = [SKSpriteNode spriteNodeWithTexture:[_atlas textureNamed:@"medalBlank"]];
  _medalDisplay.anchorPoint = CGPointMake(0.5, 1.0);
  _medalDisplay.position = CGPointMake(CGRectGetMidX(medalTitle.frame), CGRectGetMinY(medalTitle.frame) - 15);
  [self.panelGroup addChild:_medalDisplay];
  
  // Setup play button
  _playButton = [Button spriteNodeWithTexture:[_atlas textureNamed:@"buttonPlay"]];
  _playButton.pressedSound = [Sound soundNamed:@"Click.caf"];
  _playButton.pressedSound.volume = 0.4;
  _playButton.position = CGPointMake(CGRectGetMidX(panelBackground.frame), CGRectGetMinY(panelBackground.frame) - 25);
  [_playButton setPressedTarget:self withAction:@selector(pressedPlayButton)];
  [self addChild:_playButton];
  
  // Set initial values
  self.medal = MedalNone;
  self.score = 0;
  self.bestScore = 0;
  
  return self;
}

- (void)pressedPlayButton
{
  if (self.delegate) {
    [self.delegate pressedStartNewGameButton];
  }
}

- (void)setScore:(NSInteger)score
{
  _score = score;
  self.scoreText.text = [NSString stringWithFormat:@"%ld", (long)score];
}

- (void)setBestScore:(NSInteger)bestScore
{
  _bestScore = bestScore;
  self.bestScoreText.text = [NSString stringWithFormat:@"%ld", (long)bestScore];
}

- (void)setMedal:(MedalType)medal
{
  _medal = medal;
  switch (medal) {
    case MedalBronze:
      self.medalDisplay.texture = [_atlas textureNamed:@"medalBronze"];
      break;
    case MedalSilver:
      self.medalDisplay.texture = [_atlas textureNamed:@"medalSilver"];
      break;
    case MedalGold:
      self.medalDisplay.texture = [_atlas textureNamed:@"medalGold"];
      break;
    default:
      self.medalDisplay.texture = [_atlas textureNamed:@"medalBlank"];
      break;
  }
}

- (void)show
{
  // Animate Game Over title text
  SKAction *dropGameOverText = [SKAction moveByX:0.0 y:-100 duration:0.5];
  dropGameOverText.timingMode = SKActionTimingEaseOut;
  self.gameOverTitle.position = CGPointMake(self.gameOverTitle.position.x, self.gameOverTitle.position.y + 100);
  [self.gameOverTitle runAction:dropGameOverText];
  
  // Animate main menu panel
  // group - at the same time, sequence - one after the other
  SKAction *raisePanel = [SKAction group:@[[SKAction fadeInWithDuration:0.4],[SKAction moveByX:0.0 y:100 duration:0.4]]];
  raisePanel.timingMode = SKActionTimingEaseOut;
  self.panelGroup.alpha = 0.001;
  self.panelGroup.position = CGPointMake(self.panelGroup.position.x, self.panelGroup.position.y - 100);
  [self.panelGroup runAction:[SKAction sequence:@[[SKAction waitForDuration:0.7], raisePanel]]];
  
  // Animate play button
  SKAction *fadeInPlayButton = [SKAction sequence:@[[SKAction waitForDuration:1.2], [SKAction fadeInWithDuration:0.4]]];
  self.playButton.alpha = 0.001;
  self.playButton.userInteractionEnabled = NO;
  [self.playButton runAction:fadeInPlayButton completion:^{
    self.playButton.userInteractionEnabled = YES;
  }];
}
@end
