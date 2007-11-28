package {
    import flash.display.*;
    import flash.events.*;

    public dynamic class CardFlip extends MovieClip {
        private var flipStep:uint;
        private var isFlipping:Boolean = false;
        private var flipToFrame:uint;
		public var homeX:uint;
		public var homeY:uint;

        // begin the flip, remember which frame to jump to
        public function startFlip(flipToWhichFrame:uint) {
            isFlipping = true;
            flipStep = 10;
            flipToFrame = flipToWhichFrame;
            this.addEventListener(Event.ENTER_FRAME, flip);
        }

        // take 10 steps to flip
        public function flip(event:Event) {
			var scale:uint;
            // when it is the middle of the flip, go to new frame
            if (flipStep == 5) {
                gotoAndStop(flipToFrame);
            }

            // at the end of the flip, stop the animation
            else if (flipStep == 0) {
				this.width = MatchingGameX.cardWidth;
				this.x = this.homeX;
                this.removeEventListener(Event.ENTER_FRAME, flip);
            }
			
            else if (flipStep > 5) { // first half of flip
				scale = MatchingGameX.cardWidth*.2*(flipStep-6);
				this.width = scale;
				this.x = ((MatchingGameX.cardWidth - scale)/2) + this.homeX;
            } 
			else { // second half of flip
				scale = MatchingGameX.cardWidth*.2*(5-flipStep);
				this.width = scale;
				this.x = ((MatchingGameX.cardWidth - scale)/2) + this.homeX;
            }

			flipStep--; // next step
        }
    }
}