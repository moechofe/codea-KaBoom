#include "HelloWorldScene.h"
#include "SimpleAudioEngine.h"

using namespace cocos2d;
using namespace CocosDenshion;

// {{{ Random

float RandomFloat(float min, float max)
{
	float r = (float)rand() / (float)RAND_MAX;
	return min + r * (max - min);
}

int RandomInt(int min, int max)
{
	return min + (rand() % (int)(max - min + 1));
}

// }}}
// {{{ HelloWorld

HelloWorld::~HelloWorld()
{
	bucket2->release();
	bucket3->release();
	gameover_label->release();
}

HelloWorld::HelloWorld() {}

CCScene* HelloWorld::scene()
{
	CCScene* scene = NULL;
  do
	{
		scene = CCScene::create();
		CC_BREAK_IF(!scene);

		HelloWorld* layer = HelloWorld::create();
		CC_BREAK_IF(!layer);

		scene->addChild(layer);
	} while(0);

	return scene;
}

// }}}
// {{{ init: bucket, launcher, bombs, sound

bool HelloWorld::init()
{
	grabbed = false;

	do
	{
		CC_BREAK_IF(!CCLayerColor::initWithColor(ccc4(199,156,106,255)));
		size = CCDirector::sharedDirector()->getVisibleSize();
		origin = CCDirector::sharedDirector()->getVisibleOrigin();

		// Score label...
		score_label = CCLabelBMFont::create("00000", "west_england-64.fnt");
		score_label->setScale(9);
		score_label->setColor(score_colors[0]);
		score_label->setPosition(ccp(
			origin.x + size.width/2,
			origin.y + size.height/2));
		this->addChild(score_label);
		highscore = CCUserDefault::sharedUserDefault()->getIntegerForKey("hiscore", 0);
		sprintf(score_txt, "HI:%09d", highscore);
		highscore_label = CCLabelBMFont::create(score_txt, "west_england-64.fnt");
		highscore_label->setAnchorPoint(CCPointZero);
		highscore_label->setColor(ccc3(255,255,255));
		highscore_label->setPosition(ccp(origin.x + 10, origin.y + size.height - 60));
		this->addChild(highscore_label);
		gameover_label = CCLabelBMFont::create("Game over", "west_england-64.fnt");
		gameover_label->setScale(3);
		gameover_label->retain();
		gameover_label->setPosition(ccp(
			origin.x + size.width/2,
			origin.y + size.height/2 + 300));
		
		// Bucket...
		bucket = CCSprite::create("Bucket.png");
		bucket->setScale(0.4);
		bucket->setPosition(ccp(
			origin.x + size.width/2,
			origin.y + 240));
		bucket2 = CCSprite::create("Bucket.png");
		bucket2->retain();
		bucket2->setScale(0.6);
		bucket2->setPosition(ccp(100, 80));
		bucket3 = CCSprite::create("Bucket.png");
		bucket3->retain();
		bucket3->setScale(0.6);
		bucket3->setPosition(ccp(bucket->getContentSize().width-100, 80));
		this->addChild(bucket);
		
		// Bombs pool...
		bombs_batch = CCSpriteBatchNode::create("Bomb.png", 30);
		bombs_batch->setPosition(CCPointZero);
		this->addChild(bombs_batch);
		bombs = new CCSet();
		for (int b=0; b<30; b++)
		{
			CCSprite* bomb = CCSprite::createWithTexture(bombs_batch->getTexture());
			bomb->setScale(0.5);
			bomb->setPosition(ccp(0, 0));
			bombs->addObject(bomb);
		}
		next_free_bomb = 0;
		bombs_iterator = bombs->begin();

		// Launcher...
		launcher = CCSprite::create("Launcher.png");
		launcher->setScale(1.5);
		launcher->setPosition(ccp(
			origin.x + size.width/2,
			origin.y + size.height - 200));
		this->addChild(launcher);
		
		// Sound effect
		SimpleAudioEngine::sharedEngine()->preloadEffect("Bucket-1.wav");
		SimpleAudioEngine::sharedEngine()->preloadEffect("Bucket-2.wav");
		SimpleAudioEngine::sharedEngine()->preloadEffect("Bucket-3.wav");
		SimpleAudioEngine::sharedEngine()->preloadEffect("Bucket-4.wav");
		SimpleAudioEngine::sharedEngine()->preloadEffect("Bucket-5.wav");
		SimpleAudioEngine::sharedEngine()->preloadEffect("Bucket-6.wav");
		SimpleAudioEngine::sharedEngine()->preloadEffect("Boom.wav");
		SimpleAudioEngine::sharedEngine()->preloadEffect("LevelUp.wav");
		SimpleAudioEngine::sharedEngine()->preloadEffect("LevelDown.wav");
		
		resetGame();
		
		this->setTouchEnabled(true);
		this->scheduleUpdate();
		
		return true;
	} while(0);

	return false;
}

void HelloWorld::endGame()
{
	gameover = true;
	flick_time = 2.0;
	this->addChild(gameover_label);
}

void HelloWorld::resetGame()
{
	flick_time = 0.0;
	flick_color = 0;
	launcher_freeze_time = 0.0;
	bomb_to_catch = 10;
	gameover = false;
	lives = 2;
	level = 0;
	score = 0;
	bucket->addChild(bucket2);
	bucket->addChild(bucket3); 
	updateGameFromLevel();
	addNewBomb();
}

// }}}
// {{{ update: every frame

void HelloWorld::update(float dt)
{
	CCSetIterator it = bombs->begin();
	CCSprite* bomb;
	
	if(!gameover) for(int i=0; i<bombs->count(); i++)
	{
		bomb = (CCSprite*)(*it);
		it++;

		// Bomb is out.
		if(bomb->getPositionY() > 0 && bomb->getPositionY() < bucket->getPositionY() - 60)
		{
			clearAllBomb();
			loseOneLife();
			decLife();
			break;
		}
		
		// Bomb is safe.
		if ((bomb->getPositionY() < bucket->getPositionY() + 120)
		&& (bomb->getPositionY() > bucket->getPositionY() - 60)
		&& (bomb->getPositionX() > bucket->getPositionX() - 70)
 		&& (bomb->getPositionX() < bucket->getPositionX() + 70))
		{
			playBucketSound();
			removeBomb(bomb);
			updateScore();
		}
		
		// Bomb will move.
		else if(bomb->getPositionY() > 0)
		{
			bomb->setPosition(ccp(
				bomb->getPositionX(),
				bomb->getPositionY() + bomb_speed));
		}
	}

	// Move the launcher.
	if (launcher_freeze_time > 0.0)
	{
		launcher_freeze_time -= dt;
		launcher->setPosition(ccp(
			launcher->getPositionX() + RandomFloat(-10, 10),
			origin.y + size.height - 200 + RandomFloat(-10, 10)));
	}
	else if (!gameover)
	{
		launcher->setPosition(ccp(
			launcher->getPositionX() + launcher_speed,
			origin.y + size.height - 200));
	}
	
	// When the launcher reach the borders
	if (!gameover)
	if ((launcher->getPositionX() > size.width - 180 || launcher->getPositionX() < origin.y + 180) ||
	// Or randomly
		(launcher_freeze_time > 0.0 && launcher->getPositionX() < size.width - 350 && launcher->getPositionX() > origin.y + 350
		&& RandomInt(0,300)==0))
	{
		launcher_speed = -launcher_speed;
		launcher->setPositionX(BOUND( \
			launcher->getPositionX(), \
			origin.y + 180, \
			size.width - 180) + (launcher_speed * 0.3));
	}

	// Delay the next bomb.
	if (!gameover)
	{
		next_bomb_in -= dt;
		if (next_bomb_in < 0)
		{
			addNewBomb();
			next_bomb_in = RandomFloat(bombs_delays_min[level], bombs_delays_max[level]);
		}
	}
	
	// Flick the screen
	if (flick_time > 0.0)
	{
		this->setColor(flick_colors[flick_color]);
		flick_color = ++flick_color % 10;
		flick_time -= dt;
		if (flick_time < 0.0)
		{
			this->setColor(backgroud_colors[level]);
		}
	}
}

// }}}
// {{{ addNewBomb, removeBomb, updateScore, loseOneLife, clearAllBomb, incLife, decLife,

void HelloWorld::incLife()
{
	if (lives == 0) bucket->addChild(bucket2);
	else if (lives == 1) bucket->addChild(bucket3);
	lives = MIN(lives+1, 2);
}

void HelloWorld::decLife()
{
	if (lives == 2)	bucket3->removeFromParent();
	else if (lives == 1) bucket2->removeFromParent();
	else if (lives == 0) endGame();
	lives = MAX(lives-1, 0);
}

void HelloWorld::addNewBomb()
{
	CCSprite* bomb = (CCSprite*)(*bombs_iterator);
	bombs_iterator++;
	next_free_bomb++;

	bomb->setPosition(ccp(
		launcher->getPositionX(),
		launcher->getPositionY()));

	if (!bomb->getParent()) bombs_batch->addChild(bomb);

	if (next_free_bomb >= bombs->count())
	{
		bombs_iterator = bombs->begin();
		next_free_bomb = 0;
	}
}

void HelloWorld::removeBomb(CCSprite* bomb)
{
	bombs_batch->removeChild(bomb, false);
	bomb->setPositionY(0);
}

void HelloWorld::loseOneLife()
{
	SimpleAudioEngine::sharedEngine()->playEffect("Boom.wav");
	SimpleAudioEngine::sharedEngine()->playEffect("LevelDown.wav");
	flick_time = 0.4;
	level = MAX(level-1, 0);
	bomb_to_catch = 10 + (level * 3);
	updateGameFromLevel();
	next_bomb_in += 1.5;
}

void HelloWorld::updateScore()
{
	int new_score = score + 25 + (level * 3);
	if ((int)(new_score/1000) > (int)(score/1000)) incLife();
	score = new_score;
	
	bomb_to_catch = MAX(bomb_to_catch-1, 0);
	if (level < 8 && bomb_to_catch == 0)
	{
		clearAllBomb();
		SimpleAudioEngine::sharedEngine()->playEffect("LevelUp.wav");
		bomb_to_catch = 10 + (level * 3);
		level += 1;
		updateGameFromLevel();
		launcher_freeze_time = 1.5;
		next_bomb_in += 1.5;
	}
	
	sprintf(score_txt, "%05d", MIN(99999,score));
	score_label->setString(score_txt);
	
	if (score > highscore)
	{
		highscore = score;
		sprintf(score_txt, "HI:%09d", highscore);
		highscore_label->setString(score_txt);
		CCUserDefault::sharedUserDefault()->setIntegerForKey("hiscore", highscore);
	}
}

void HelloWorld::updateGameFromLevel()
{
	launcher_speed = launcher_speeds[level];
	bomb_speed = bomb_speeds[level];
	next_bomb_in =
		// Normal delays
		RandomFloat(bombs_delays_min[level], bombs_delays_max[level]) *
		// Double delays 1/10 times.
		(RandomFloat(0, 10)==0?2:1);
	this->setColor(backgroud_colors[level]);
	score_label->setColor(score_colors[level]);
}

void HelloWorld::clearAllBomb()
{
	CCSetIterator it = bombs->begin();
	CCSprite* bomb;
	
	for(int i=0; i<bombs->count(); i++)
	{
		bomb = (CCSprite*)(*it);
		it++;
		if (bomb->getParent()) removeBomb(bomb);
	}
}

// }}}
// {{{ playBucketSound

void HelloWorld::playBucketSound()
{
	switch(RandomInt(1,6))
	{
	case 1: SimpleAudioEngine::sharedEngine()->playEffect("Bucket-1.wav"); break;
	case 2: SimpleAudioEngine::sharedEngine()->playEffect("Bucket-2.wav"); break;
	case 3: SimpleAudioEngine::sharedEngine()->playEffect("Bucket-3.wav"); break;
	case 4: SimpleAudioEngine::sharedEngine()->playEffect("Bucket-4.wav"); break;
	case 5: SimpleAudioEngine::sharedEngine()->playEffect("Bucket-5.wav"); break;
	case 6: SimpleAudioEngine::sharedEngine()->playEffect("Bucket-6.wav"); break;
	}
}

// }}}
// {{{ Touches: move the buckets

void HelloWorld::ccTouchesBegan(CCSet* touches, CCEvent* event)
{
	if(gameover)
	{
		gameover_label->removeFromParent();
		score_label->setString("00000");
		resetGame();
	}
	if(!grabbed)
	{
		CCTouch* touch = (CCTouch*)(touches->anyObject());
		CCPoint pt = touch->getLocation();

		grabbed = true;
		touch_id = touch->getID();
		if(!gameover) bucket->setPositionX(pt.x);
	}
}

void HelloWorld::ccTouchesMoved(CCSet* touches, CCEvent* event)
{
	CCSetIterator it = touches->begin();
	CCPoint pt;
	CCTouch* touch;

	for(int i=0; i<touches->count(); i++)
	{
		touch = (CCTouch*)(*it);
		if(touch_id == touch->getID())
		{
			pt = touch->getLocation();
			if(!gameover) bucket->setPositionX(pt.x);
		}
		it++;
	}
}

void HelloWorld::ccTouchesEnded(CCSet* touches, CCEvent* event)
{
	CCSetIterator it = touches->begin();
	CCPoint pt;
	CCTouch* touch;
	
	for(int i=0; i<touches->count(); i++)
	{
		touch = (CCTouch*)(*it);
		if(touch_id == touch->getID())
		{
			grabbed = false;
			pt = touch->getLocation();
			if(!gameover) bucket->setPositionX(pt.x);
		}
		it++;
	}
}

// }}}
