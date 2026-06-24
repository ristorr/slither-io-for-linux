package starling.events
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.Stage;
   import starling.utils.Pool;
   
   public class TouchProcessor
   {
      
      private static var sUpdatedTouches:Vector.<starling.events.Touch> = new Vector.<starling.events.Touch>(0);
      
      private static var sHoveringTouchData:Vector.<Object> = new Vector.<Object>(0);
      
      private static var sHelperPoint:Point = new Point();
      
      private static const TOP:int = 0;
      
      private static const BOTTOM:int = 1;
      
      private static const LEFT:int = 2;
      
      private static const RIGHT:int = 3;
       
      
      private var _stage:Stage;
      
      private var _root:DisplayObject;
      
      private var _elapsedTime:Number;
      
      private var _lastTaps:Vector.<starling.events.Touch>;
      
      private var _shiftDown:Boolean = false;
      
      private var _ctrlDown:Boolean = false;
      
      private var _multitapTime:Number = 0.3;
      
      private var _multitapDistance:Number = 25;
      
      private var _touchEvent:starling.events.TouchEvent;
      
      private var _isProcessing:Boolean;
      
      private var _cancelRequested:Boolean;
      
      private var _touchMarker:starling.events.TouchMarker;
      
      private var _simulateMultitouch:Boolean;
      
      private var _occlusionTest:Function;
      
      private var _discardSystemGestures:Boolean;
      
      private var _systemGestureTouchID:int = -1;
      
      private var _systemGestureMargins:Array;
      
      protected var _queue:Vector.<starling.events.TouchData>;
      
      protected var _currentTouches:Vector.<starling.events.Touch>;
      
      public function TouchProcessor(param1:Stage)
      {
         this._systemGestureMargins = [15,15,15,0];
         super();
         this._root = this._stage = param1;
         this._elapsedTime = 0;
         this._currentTouches = new Vector.<starling.events.Touch>(0);
         this._queue = new Vector.<starling.events.TouchData>(0);
         this._lastTaps = new Vector.<starling.events.Touch>(0);
         this._touchEvent = new starling.events.TouchEvent(starling.events.TouchEvent.TOUCH);
         this._stage.addEventListener(starling.events.KeyboardEvent.KEY_DOWN,this.onKey);
         this._stage.addEventListener(starling.events.KeyboardEvent.KEY_UP,this.onKey);
         this.monitorInterruptions(true);
      }
      
      public function dispose() : void
      {
         this.monitorInterruptions(false);
         this._stage.removeEventListener(starling.events.KeyboardEvent.KEY_DOWN,this.onKey);
         this._stage.removeEventListener(starling.events.KeyboardEvent.KEY_UP,this.onKey);
         if(this._touchMarker)
         {
            this._touchMarker.dispose();
         }
      }
      
      public function advanceTime(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc3_:starling.events.Touch = null;
         var _loc5_:starling.events.TouchData = null;
         if(this._isProcessing)
         {
            return;
         }
         this._isProcessing = true;
         var _loc4_:int = 0;
         this._elapsedTime += param1;
         sUpdatedTouches.length = 0;
         if(this._lastTaps.length > 0)
         {
            _loc2_ = int(this._lastTaps.length - 1);
            while(_loc2_ >= 0)
            {
               if(this._elapsedTime - this._lastTaps[_loc2_].timestamp > this._multitapTime)
               {
                  this._lastTaps.removeAt(_loc2_);
               }
               _loc2_--;
            }
         }
         while(this._queue.length > 0 || _loc4_ == 0)
         {
            _loc4_++;
            for each(_loc3_ in this._currentTouches)
            {
               if(_loc3_.phase == starling.events.TouchPhase.BEGAN || _loc3_.phase == starling.events.TouchPhase.MOVED)
               {
                  _loc3_.phase = starling.events.TouchPhase.STATIONARY;
               }
            }
            while(this._queue.length > 0 && !this.containsTouchWithID(sUpdatedTouches,this._queue[this._queue.length - 1].id))
            {
               _loc5_ = this._queue.pop();
               _loc3_ = this.createOrUpdateTouch(_loc5_);
               sUpdatedTouches[sUpdatedTouches.length] = _loc3_;
               starling.events.TouchData.toPool(_loc5_);
            }
            _loc2_ = int(this._currentTouches.length - 1);
            while(_loc2_ >= 0)
            {
               _loc3_ = this._currentTouches[_loc2_];
               if(_loc3_.phase == starling.events.TouchPhase.HOVER && !this.containsTouchWithID(sUpdatedTouches,_loc3_.id))
               {
                  sHelperPoint.setTo(_loc3_.globalX,_loc3_.globalY);
                  if(_loc3_.target != this._root.hitTest(sHelperPoint))
                  {
                     sUpdatedTouches[sUpdatedTouches.length] = _loc3_;
                  }
               }
               _loc2_--;
            }
            if(sUpdatedTouches.length)
            {
               this.processTouches(sUpdatedTouches,this._shiftDown,this._ctrlDown);
            }
            _loc2_ = int(this._currentTouches.length - 1);
            while(_loc2_ >= 0)
            {
               if(this._currentTouches[_loc2_].phase == starling.events.TouchPhase.ENDED)
               {
                  this._currentTouches.removeAt(_loc2_);
               }
               _loc2_--;
            }
            sUpdatedTouches.length = 0;
         }
         this._isProcessing = false;
         if(this._cancelRequested)
         {
            this.cancelTouches();
         }
      }
      
      protected function processTouches(param1:Vector.<starling.events.Touch>, param2:Boolean, param3:Boolean) : void
      {
         var _loc4_:starling.events.Touch = null;
         var _loc5_:Object = null;
         sHoveringTouchData.length = 0;
         this._touchEvent.resetTo(starling.events.TouchEvent.TOUCH,this._currentTouches,param2,param3);
         for each(_loc4_ in param1)
         {
            if(_loc4_.phase == starling.events.TouchPhase.HOVER && Boolean(_loc4_.target))
            {
               sHoveringTouchData[sHoveringTouchData.length] = {
                  "touch":_loc4_,
                  "target":_loc4_.target,
                  "bubbleChain":_loc4_.bubbleChain
               };
            }
            if(_loc4_.phase == starling.events.TouchPhase.HOVER || _loc4_.phase == starling.events.TouchPhase.BEGAN)
            {
               sHelperPoint.setTo(_loc4_.globalX,_loc4_.globalY);
               if(this._occlusionTest != null && this._occlusionTest(_loc4_.globalX,_loc4_.globalY))
               {
                  _loc4_.target = null;
               }
               else
               {
                  _loc4_.target = this._root.hitTest(sHelperPoint);
               }
            }
         }
         for each(_loc5_ in sHoveringTouchData)
         {
            if(_loc5_.touch.target != _loc5_.target)
            {
               this._touchEvent.dispatch(_loc5_.bubbleChain);
            }
         }
         for each(_loc4_ in param1)
         {
            _loc4_.dispatchEvent(this._touchEvent);
         }
         this._touchEvent.resetTo(starling.events.TouchEvent.TOUCH);
      }
      
      private function checkForSystemGesture(param1:int, param2:String, param3:Number, param4:Number) : Boolean
      {
         var _loc5_:Boolean = false;
         var _loc6_:flash.geom.Rectangle = null;
         if(!this._discardSystemGestures || param2 == starling.events.TouchPhase.HOVER)
         {
            return false;
         }
         if(this._systemGestureTouchID == param1)
         {
            if(param2 == starling.events.TouchPhase.ENDED)
            {
               this._systemGestureTouchID = -1;
            }
            return true;
         }
         if(this._systemGestureTouchID >= 0)
         {
            return false;
         }
         if(param2 == starling.events.TouchPhase.BEGAN)
         {
            _loc6_ = this._stage.getScreenBounds(this._stage,Pool.getRectangle());
            _loc5_ = param3 < _loc6_.left + this._systemGestureMargins[LEFT] || param3 > _loc6_.right - this._systemGestureMargins[RIGHT] || param4 < _loc6_.top + this._systemGestureMargins[TOP] || param4 > _loc6_.bottom - this._systemGestureMargins[BOTTOM];
            Pool.putRectangle(_loc6_);
            if(_loc5_)
            {
               this._systemGestureTouchID = param1;
            }
            return _loc5_;
         }
         return false;
      }
      
      public function enqueue(param1:int, param2:String, param3:Number, param4:Number, param5:Number = 1, param6:Number = 1, param7:Number = 1) : void
      {
         if(this.checkForSystemGesture(param1,param2,param3,param4))
         {
            return;
         }
         this.queue_unshift(param1,param2,param3,param4,param5,param6,param7);
         if(this._ctrlDown && this._touchMarker && param1 == 0)
         {
            this._touchMarker.moveMarker(param3,param4,this._shiftDown);
            this.queue_unshift(1,param2,this._touchMarker.mockX,this._touchMarker.mockY);
         }
      }
      
      private function queue_unshift(param1:int, param2:String, param3:Number, param4:Number, param5:Number = 1, param6:Number = 1, param7:Number = 1) : void
      {
         this._queue.unshift(starling.events.TouchData.fromPool(param1,param2,param3,param4,param5,param6,param7));
      }
      
      public function enqueueMouseLeftStage() : void
      {
         var _loc1_:starling.events.Touch = this.getCurrentTouch(0);
         if(_loc1_ == null || _loc1_.phase != starling.events.TouchPhase.HOVER)
         {
            return;
         }
         var _loc2_:int = 1;
         var _loc3_:Number = _loc1_.globalX;
         var _loc4_:Number = _loc1_.globalY;
         var _loc5_:Number = _loc1_.globalX;
         var _loc6_:Number = this._stage.stageWidth - _loc5_;
         var _loc7_:Number = _loc1_.globalY;
         var _loc8_:Number = this._stage.stageHeight - _loc7_;
         var _loc9_:Number;
         if((_loc9_ = Math.min(_loc5_,_loc6_,_loc7_,_loc8_)) == _loc5_)
         {
            _loc3_ = -_loc2_;
         }
         else if(_loc9_ == _loc6_)
         {
            _loc3_ = this._stage.stageWidth + _loc2_;
         }
         else if(_loc9_ == _loc7_)
         {
            _loc4_ = -_loc2_;
         }
         else
         {
            _loc4_ = this._stage.stageHeight + _loc2_;
         }
         this.enqueue(0,starling.events.TouchPhase.HOVER,_loc3_,_loc4_);
      }
      
      public function cancelTouches() : void
      {
         var _loc1_:starling.events.Touch = null;
         if(this._isProcessing)
         {
            this._cancelRequested = true;
            return;
         }
         this._cancelRequested = false;
         if(this._currentTouches.length > 0)
         {
            for each(_loc1_ in this._currentTouches)
            {
               if(_loc1_.phase == starling.events.TouchPhase.BEGAN || _loc1_.phase == starling.events.TouchPhase.MOVED || _loc1_.phase == starling.events.TouchPhase.STATIONARY)
               {
                  _loc1_.phase = starling.events.TouchPhase.ENDED;
                  _loc1_.cancelled = true;
               }
            }
            this.processTouches(this._currentTouches,this._shiftDown,this._ctrlDown);
         }
         this._currentTouches.length = 0;
         while(this._queue.length)
         {
            starling.events.TouchData.toPool(this._queue.pop());
         }
      }
      
      private function createOrUpdateTouch(param1:starling.events.TouchData) : starling.events.Touch
      {
         var _loc2_:starling.events.Touch = this.getCurrentTouch(param1.id);
         if(_loc2_ == null)
         {
            _loc2_ = new starling.events.Touch(param1.id);
            this.addCurrentTouch(_loc2_);
         }
         _loc2_.update(this._elapsedTime,param1.phase,param1.globalX,param1.globalY,param1.pressure,param1.width,param1.height);
         if(param1.phase == starling.events.TouchPhase.BEGAN)
         {
            this.updateTapCount(_loc2_);
         }
         return _loc2_;
      }
      
      private function updateTapCount(param1:starling.events.Touch) : void
      {
         var _loc4_:starling.events.Touch = null;
         var _loc5_:Number = NaN;
         var _loc2_:starling.events.Touch = null;
         var _loc3_:Number = this._multitapDistance * this._multitapDistance;
         for each(_loc4_ in this._lastTaps)
         {
            if((_loc5_ = Math.pow(_loc4_.globalX - param1.globalX,2) + Math.pow(_loc4_.globalY - param1.globalY,2)) <= _loc3_)
            {
               _loc2_ = _loc4_;
               break;
            }
         }
         if(_loc2_)
         {
            param1.tapCount = _loc2_.tapCount + 1;
            this._lastTaps.removeAt(this._lastTaps.indexOf(_loc2_));
         }
         else
         {
            param1.tapCount = 1;
         }
         this._lastTaps[this._lastTaps.length] = param1.clone();
      }
      
      private function addCurrentTouch(param1:starling.events.Touch) : void
      {
         var _loc2_:int = int(this._currentTouches.length - 1);
         while(_loc2_ >= 0)
         {
            if(this._currentTouches[_loc2_].id == param1.id)
            {
               this._currentTouches.removeAt(_loc2_);
            }
            _loc2_--;
         }
         this._currentTouches[this._currentTouches.length] = param1;
      }
      
      private function getCurrentTouch(param1:int) : starling.events.Touch
      {
         var _loc2_:starling.events.Touch = null;
         for each(_loc2_ in this._currentTouches)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function containsTouchWithID(param1:Vector.<starling.events.Touch>, param2:int) : Boolean
      {
         var _loc3_:starling.events.Touch = null;
         for each(_loc3_ in param1)
         {
            if(_loc3_.id == param2)
            {
               return true;
            }
         }
         return false;
      }
      
      public function setSystemGestureMargins(param1:Number = 10, param2:Number = 10, param3:Number = 0, param4:Number = 0) : void
      {
         this._systemGestureMargins[TOP] = param1;
         this._systemGestureMargins[BOTTOM] = param2;
         this._systemGestureMargins[LEFT] = param3;
         this._systemGestureMargins[RIGHT] = param4;
      }
      
      public function get simulateMultitouch() : Boolean
      {
         return this._simulateMultitouch;
      }
      
      public function set simulateMultitouch(param1:Boolean) : void
      {
         var target:Starling = null;
         var createTouchMarker:Function = null;
         var value:Boolean = param1;
         createTouchMarker = function():void
         {
            target.removeEventListener(starling.events.Event.CONTEXT3D_CREATE,createTouchMarker);
            if(_touchMarker == null)
            {
               _touchMarker = new starling.events.TouchMarker();
               _touchMarker.visible = false;
               _stage.addChild(_touchMarker);
            }
         };
         if(this.simulateMultitouch == value)
         {
            return;
         }
         this._simulateMultitouch = value;
         target = Starling.current;
         if(value && this._touchMarker == null)
         {
            if(Starling.current.contextValid)
            {
               createTouchMarker();
            }
            else
            {
               target.addEventListener(starling.events.Event.CONTEXT3D_CREATE,createTouchMarker);
            }
         }
         else if(!value && Boolean(this._touchMarker))
         {
            this._touchMarker.removeFromParent(true);
            this._touchMarker = null;
         }
      }
      
      public function get multitapTime() : Number
      {
         return this._multitapTime;
      }
      
      public function set multitapTime(param1:Number) : void
      {
         this._multitapTime = param1;
      }
      
      public function get multitapDistance() : Number
      {
         return this._multitapDistance;
      }
      
      public function set multitapDistance(param1:Number) : void
      {
         this._multitapDistance = param1;
      }
      
      public function get root() : DisplayObject
      {
         return this._root;
      }
      
      public function set root(param1:DisplayObject) : void
      {
         this._root = param1;
      }
      
      public function get stage() : Stage
      {
         return this._stage;
      }
      
      public function get numCurrentTouches() : int
      {
         return this._currentTouches.length;
      }
      
      public function set occlusionTest(param1:Function) : void
      {
         this._occlusionTest = param1;
      }
      
      public function get occlusionTest() : Function
      {
         return this._occlusionTest;
      }
      
      public function get discardSystemGestures() : Boolean
      {
         return this._discardSystemGestures;
      }
      
      public function set discardSystemGestures(param1:Boolean) : void
      {
         if(this._discardSystemGestures != param1)
         {
            this._discardSystemGestures = param1;
            this._systemGestureTouchID = -1;
         }
      }
      
      private function onKey(param1:starling.events.KeyboardEvent) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:starling.events.Touch = null;
         var _loc4_:starling.events.Touch = null;
         if(param1.keyCode == 17 || param1.keyCode == 15)
         {
            _loc2_ = this._ctrlDown;
            this._ctrlDown = param1.type == starling.events.KeyboardEvent.KEY_DOWN;
            if(Boolean(this._touchMarker) && _loc2_ != this._ctrlDown)
            {
               this._touchMarker.visible = this._ctrlDown;
               this._touchMarker.moveCenter(this._stage.stageWidth / 2,this._stage.stageHeight / 2);
               _loc3_ = this.getCurrentTouch(0);
               _loc4_ = this.getCurrentTouch(1);
               if(_loc3_)
               {
                  this._touchMarker.moveMarker(_loc3_.globalX,_loc3_.globalY);
               }
               if(_loc2_ && _loc4_ && _loc4_.phase != starling.events.TouchPhase.ENDED)
               {
                  this.queue_unshift(1,starling.events.TouchPhase.ENDED,_loc4_.globalX,_loc4_.globalY);
               }
               else if(this._ctrlDown && Boolean(_loc3_))
               {
                  if(_loc3_.phase == starling.events.TouchPhase.HOVER || _loc3_.phase == starling.events.TouchPhase.ENDED)
                  {
                     this.queue_unshift(1,starling.events.TouchPhase.HOVER,this._touchMarker.mockX,this._touchMarker.mockY);
                  }
                  else
                  {
                     this.queue_unshift(1,starling.events.TouchPhase.BEGAN,this._touchMarker.mockX,this._touchMarker.mockY);
                  }
               }
            }
         }
         else if(param1.keyCode == 16)
         {
            this._shiftDown = param1.type == starling.events.KeyboardEvent.KEY_DOWN;
         }
      }
      
      private function monitorInterruptions(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         try
         {
            _loc2_ = getDefinitionByName("flash.desktop::NativeApplication");
            _loc3_ = _loc2_["nativeApplication"];
            if(param1)
            {
               _loc3_.addEventListener("deactivate",this.onInterruption,false,0,true);
            }
            else
            {
               _loc3_.removeEventListener("deactivate",this.onInterruption);
            }
         }
         catch(e:Error)
         {
         }
      }
      
      private function onInterruption(param1:Object) : void
      {
         this.cancelTouches();
      }
   }
}
