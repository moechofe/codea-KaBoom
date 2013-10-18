#ifndef __HELLOWORLD_SCENE_H__
#define __HELLOWORLD_SCENE_H__

#include "cocos2d.h"

using namespace cocos2d;

#define ccsf(...) CCString::createWithFormat(__VA_ARGS__)->getCString()
#define	BOUND(_val,_min,_max) (MAX(MIN((_val),(_max)),(_min)))

class HelloWorld : public CCLayerColor
{
public:
	HelloWorld();
	~HelloWorld();

	virtual bool init();

	static CCScene* scene();

	//virtual void menuCloseCallback(CCObject* sender);

	CREATE_FUNC(HelloWorld);

	void ccTouchesBegan(CCSet* touches, CCEvent* event);
	void ccTouchesMoved(CCSet* touches, CCEvent* event);
	void ccTouchesEnded(CCSet* touches, CCEvent* event);

private:
	CCSize size;
	CCPoint origin;
	
	CCSprite* bucket;
	CCSprite* bucket2;
	CCSprite* bucket3;
	bool grabbed;
	int touch_id;
	
	CCSpriteBatchNode* bombs_batch;
	CCSet* bombs;
	CCSetIterator bombs_iterator;
	int next_free_bomb;
	void addNewBomb();
	void removeBomb(CCSprite* bomb);
	float bomb_speed;
	void clearAllBomb();

	CCSprite* launcher;
	float launcher_speed;
	float next_bomb_in;
	float launcher_freeze_time;

	CCLabelBMFont* score_label;
	CCLabelBMFont* highscore_label;
	CCLabelBMFont* gameover_label;

	bool gameover;
	int bomb_to_catch;
	int level;
	int lives;
	int score;
	int highscore;
	char score_txt[12];
	void updateScore();
	void loseOneLife();
	void updateGameFromLevel();
	void incLife();
	void decLife();
	void endGame();
	void resetGame();
	
	float launcher_speeds[9] = {5, 8, 12, 17, 23, 30, 38, 47, 57};
	float bomb_speeds[9] = {-7, -8, -10, -13, -17, -22, -28, -35, -43};
	float bombs_delays_min[9] = {1.3, 0.6, 0.4, 0.2, 0.1, 0.08, 0.07, 0.05, 0.03};
	float bombs_delays_max[9] = {1.8, 1.3, 1.1, 0.9, 0.6, 0.40, 0.20, 0.09, 0.07};

	void playBucketSound();	

	ccColor3B backgroud_colors[9] = {
		ccc3(199,156,106),
		ccc3(135,215,222),
		ccc3(108,217,117),
		ccc3(219,224,72),
		ccc3(111,148,232),
		ccc3(200,108,240),
		ccc3(240,96,96),
		ccc3(171,171,171),
		ccc3(43,43,43) };

	ccColor3B score_colors[9] = {
		ccc3(179,131,77),
		ccc3(86,183,191),
		ccc3(65,191,75),
		ccc3(188,194,25),
		ccc3(65,108,209),
		ccc3(166,54,214),
		ccc3(212,47,47),
		ccc3(140,140,140),
		ccc3(99,99,99) };

	float flick_time;
	int flick_color;
	ccColor3B flick_colors[10] = {
		ccc3(77,77,77),
		ccc3(77,77,77),
		ccc3(77,77,77),
		ccc3(77,77,77),
		ccc3(77,77,77),
		ccc3(179,179,179),
		ccc3(179,179,179),
		ccc3(179,179,179),
		ccc3(179,179,179),
		ccc3(179,179,179) };
	
	void update(float dt);

};

#endif
