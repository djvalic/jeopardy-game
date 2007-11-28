/* 
 * To make a bigger set of cards, 
 * [1] redefine faces2.ai to contain more layers in Illustrator, 
 * [2] re-import faces2.ai as CardFlip the movieclip symbol
 * [3] check boardWidth & boardHeight so that:
 *     their product is 
 *     -- twice the twice the number of distinct layers in the .ai file minus 1 (the back)
 *     -- even, if not 
 *
 * This is a modified version of MatchingGame at flashgameu.com
 */

package {
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;

	public class MatchingGameX extends MovieClip {
		// game constants
		public static  const cardWidth = 62;
		public static  const cardHeight = 62;
		private static  const cardHorizontalSpacing:Number = cardWidth + 2;
		private static  const cardVerticalSpacing:Number = cardHeight + 2;
		private static const pointsForMatch:int = 100;
		private static const pointsForMiss:int = -5;

		private var boardWidth:uint = 2; // 6 is max for now
		private var boardHeight:uint = 2;
		private var boardOffsetX:Number ;
		private var boardOffsetY:Number ;
		
		private var firstCard:CardFlip;
		private var secondCard:CardFlip;
		private var cardsLeft:uint;
		private var gameScoreField:TextField;
		private var gameScore:int;
		private var gameStartTime:uint;
		private var gameTime:uint;
		private var gameTimeField:TextField;
		private var flipBackTimer:Timer;
		
		var theMissSound:MissSound = new MissSound();
		var theMatchSound:MatchSound = new MatchSound();		
		
		// game setup
		public function MatchingGameX():void {
			// make a list of card numbers
			var cardlist:Array = new Array();
			var rB:RadioButtonGroup = MovieClip(root).rbg;
			setBoardSize(rB.selectedData as String);

			boardOffsetX = (550 - boardWidth*cardWidth)/2;
			boardOffsetY = (400 - boardHeight*cardHeight)/2;
		
			for (var i:uint=0; i<boardWidth*boardHeight/2; i++) {
				cardlist.push(i);
				cardlist.push(i);
			}
			cardsLeft = 0;

			for (var x:uint=0; x<boardWidth; x++) {// horizontal
				for (var y:uint=0; y<boardHeight; y++) {// vertical
					var c:CardFlip = new CardFlip();// copy the movie clip
					c.stop();// stop on first frame
					c.buttonMode = true;
					c.homeX = x*cardHorizontalSpacing+boardOffsetX;// set position
					c.homeY = y*cardVerticalSpacing+boardOffsetY;
					c.x = c.homeX;
					c.y = c.homeY;
					c.width = cardWidth;
					c.height = cardHeight;
					var r:uint = Math.floor(Math.random()*cardlist.length);// get a random face
					c.cardface = cardlist[r];// assign face to card
					cardlist.splice(r,1);// remove face from list
					c.addEventListener(MouseEvent.CLICK,clickCard);
					//c.gotoAndStop(c.cardface+2);
					c.gotoAndStop(1);
					addChild(c);// show the card
					cardsLeft++;
				}
			}
			
			gameScoreField = new TextField();
			addChild(gameScoreField);
			gameScore = 0;
			showGameScore();
			
			gameTimeField = new TextField();
			gameTimeField.x = 480;
			addChild(gameTimeField);
			gameStartTime = getTimer();
			gameTime = 0;
			addEventListener(Event.ENTER_FRAME,showTime);
		}
		
		// query then set the board matrix
		public function setBoardSize(aSelection:String):void {
			switch(aSelection) {
				case "2":
					changeBoardSize(2,2);
					break;
				case "4": 
					changeBoardSize(4,3);
					break;
				case "6":
					changeBoardSize(6,6);
					break;
				default:
					changeBoardSize(2,2);
			}
		}
		
		// set the board matrix
		public function changeBoardSize(aWidth:uint, aHeight:uint):void {
			boardWidth = aWidth;
			boardHeight = aHeight;
		}		
		
		// play a sound
		public function playSound(soundObject:Object) {
			var channel:SoundChannel = soundObject.play();
		}		
		
		// calc time display
		public function clockTime(ms:int) {
			var seconds:int = Math.floor(ms/1000);
			var minutes:int = Math.floor(seconds/60);
			seconds -= minutes*60;
			var timeString:String = minutes+":"+String(seconds+100).substr(1,2);
			return timeString;
		}
		
		// display game time
		public function showTime(event:Event) {
			gameTime = getTimer()-gameStartTime;
			gameTimeField.text = "Time: "+clockTime(gameTime);
			//trace("inside selected button:"+rbg.selectedData);
		}
		
		// display game score
		public function showGameScore() {
			gameScoreField.text = "Score: "+String(gameScore);
		}
		
		// game controller
		public function clickCard(event:MouseEvent) {
			var thisCard:CardFlip = (event.target as CardFlip); // what card?
		
			// first card in a pair
			if (firstCard == null) { 
				firstCard = thisCard; // note it
				//firstCard.gotoAndStop(thisCard.cardface+2); // turn it over
				firstCard.startFlip(thisCard.cardface+2); // turn it over
			} 
			// clicked first card again
			else if (firstCard == thisCard) { 
				//firstCard.gotoAndStop(1); // turn back over
				firstCard.startFlip(1); // turn back over
				firstCard = null;
			} 
			// turning the 2nd card up
			else if (secondCard == null) { // second card in a pair
				secondCard = thisCard; // note it
				//secondCard.gotoAndStop(thisCard.cardface+2); // turn it over
				secondCard.startFlip(thisCard.cardface+2); // turn it over
		
				// compare two cards
				if (firstCard.cardface == secondCard.cardface) {
					playSound(theMatchSound);
					// remove a match
					removeChild(firstCard);
					removeChild(secondCard);
					// reset selection
					firstCard = null;
					secondCard = null;
					
					// award score
					gameScore += pointsForMatch;
					showGameScore();

					// check for gameover state
					cardsLeft -= 2;
					if (cardsLeft == 0) {
						MovieClip(root).gameScore = gameScore;
						MovieClip(root).gameTime = clockTime(gameTime);
						MovieClip(root).gotoAndStop("gameover");
					}
				}
				// not matching
				else {
					playSound(theMissSound);
					gameScore += pointsForMiss;
					showGameScore();
					flipBackTimer = new Timer(2000,1);
					flipBackTimer.addEventListener(TimerEvent.TIMER_COMPLETE,returnCards);
					flipBackTimer.start();
				}
			} 
			// two cards are already up, starting to pick another pair
			else { 
				// reset previous pair
				returnCards(null);
				// select first card in next pair
				firstCard = thisCard;
				firstCard.startFlip(thisCard.cardface+2);
			}
		}
		
		public function returnCards(event:TimerEvent) {
			firstCard.startFlip(1);
			secondCard.startFlip(1);
			firstCard = null;
			secondCard = null;
			flipBackTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,returnCards);
		 }
	}
}