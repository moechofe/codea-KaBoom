#include "AppDelegate.h"
#include "HelloWorldScene.h"

USING_NS_CC;

AppDelegate::AppDelegate() {}
AppDelegate::~AppDelegate() {}

bool AppDelegate::applicationDidFinishLaunching()
{
	CCDirector *director = CCDirector::sharedDirector();
	CCEGLView *EGLView = CCEGLView::sharedOpenGLView();

	director->setOpenGLView(EGLView);
	//director->setDisplayStats(true);
	director->setAnimationInterval(1.0 / 60);

	EGLView->setDesignResolutionSize(DESIGN_WIDTH, DESIGN_HEIGHT, kResolutionFixedHeight);

	CCScene *scene = HelloWorld::scene();
	director->runWithScene(scene);

	return true;
}

void AppDelegate::applicationDidEnterBackground()
{
	CCDirector::sharedDirector()->stopAnimation();
}

void AppDelegate::applicationWillEnterForeground()
{
	CCDirector::sharedDirector()->startAnimation();
}
