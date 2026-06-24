package starling.events
{
   import flash.geom.Point;
   import starling.display.DisplayObject;
   import starling.utils.Pool;
   import starling.utils.StringUtil;
   
   public class Touch
   {
      
      private static var sHelperPoint:Point = new Point();
       
      
      private var _id:int;
      
      private var _globalX:Number;
      
      private var _globalY:Number;
      
      private var _previousGlobalX:Number;
      
      private var _previousGlobalY:Number;
      
      private var _startGlobalX:Number;
      
      private var _startGlobalY:Number;
      
      private var _startTimestamp:Number;
      
      private var _tapCount:int;
      
      private var _phase:String;
      
      private var _target:DisplayObject;
      
      private var _timestamp:Number;
      
      private var _pressure:Number;
      
      private var _width:Number;
      
      private var _height:Number;
      
      private var _cancelled:Boolean;
      
      private var _bubbleChain:Vector.<starling.events.EventDispatcher>;
      
      public function Touch(param1:int)
      {
         super();
         this._id = param1;
         this._tapCount = 0;
         this._phase = starling.events.TouchPhase.HOVER;
         this._pressure = this._width = this._height = 1;
         this._bubbleChain = new Vector.<starling.events.EventDispatcher>(0);
         this._timestamp = this._startTimestamp = -1;
      }
      
      private static function getMovementBetween(param1:Number, param2:Number, param3:Number, param4:Number, param5:DisplayObject, param6:Point = null) : Point
      {
         if(param6 == null)
         {
            param6 = new Point();
         }
         var _loc7_:Point = Pool.getPoint(param1,param2);
         var _loc8_:Point = Pool.getPoint(param3,param4);
         param5.globalToLocal(_loc7_,_loc7_);
         param5.globalToLocal(_loc8_,_loc8_);
         param6.setTo(_loc8_.x - _loc7_.x,_loc8_.y - _loc7_.y);
         Pool.putPoint(_loc7_);
         Pool.putPoint(_loc8_);
         return param6;
      }
      
      public function getLocation(param1:DisplayObject, param2:Point = null) : Point
      {
         sHelperPoint.setTo(this._globalX,this._globalY);
         return param1.globalToLocal(sHelperPoint,param2);
      }
      
      public function getPreviousLocation(param1:DisplayObject, param2:Point = null) : Point
      {
         sHelperPoint.setTo(this._previousGlobalX,this._previousGlobalY);
         return param1.globalToLocal(sHelperPoint,param2);
      }
      
      public function getStartLocation(param1:DisplayObject, param2:Point = null) : Point
      {
         sHelperPoint.setTo(this._startGlobalX,this._startGlobalY);
         return param1.globalToLocal(sHelperPoint,param2);
      }
      
      public function getMovement(param1:DisplayObject, param2:Point = null) : Point
      {
         return getMovementBetween(this._previousGlobalX,this._previousGlobalY,this._globalX,this._globalY,param1,param2);
      }
      
      public function getMovementSinceStart(param1:DisplayObject, param2:Point = null) : Point
      {
         return getMovementBetween(this._startGlobalX,this._startGlobalY,this._globalX,this._globalY,param1,param2);
      }
      
      public function isTouching(param1:DisplayObject) : Boolean
      {
         return this._bubbleChain.indexOf(param1) != -1;
      }
      
      public function toString() : String
      {
         return StringUtil.format("[Touch {0}: globalX={1}, globalY={2}, phase={3}]",this._id,this._globalX,this._globalY,this._phase);
      }
      
      public function clone() : starling.events.Touch
      {
         var _loc1_:starling.events.Touch = new starling.events.Touch(this._id);
         _loc1_._globalX = this._globalX;
         _loc1_._globalY = this._globalY;
         _loc1_._previousGlobalX = this._previousGlobalX;
         _loc1_._previousGlobalY = this._previousGlobalY;
         _loc1_._startGlobalX = this._startGlobalX;
         _loc1_._startGlobalY = this._startGlobalY;
         _loc1_._startTimestamp = this._startTimestamp;
         _loc1_._phase = this._phase;
         _loc1_._tapCount = this._tapCount;
         _loc1_._timestamp = this._timestamp;
         _loc1_._pressure = this._pressure;
         _loc1_._width = this._width;
         _loc1_._height = this._height;
         _loc1_._cancelled = this._cancelled;
         _loc1_.target = this._target;
         return _loc1_;
      }
      
      private function updateBubbleChain() : void
      {
         var _loc1_:int = 0;
         var _loc2_:DisplayObject = null;
         if(this._target)
         {
            _loc1_ = 1;
            _loc2_ = this._target;
            this._bubbleChain.length = 1;
            this._bubbleChain[0] = _loc2_;
            while((_loc2_ = _loc2_.parent) != null)
            {
               this._bubbleChain[int(_loc1_++)] = _loc2_;
            }
         }
         else
         {
            this._bubbleChain.length = 0;
         }
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function get previousGlobalX() : Number
      {
         return this._previousGlobalX;
      }
      
      public function get previousGlobalY() : Number
      {
         return this._previousGlobalY;
      }
      
      public function get startGlobalX() : Number
      {
         return this._startGlobalX;
      }
      
      public function get startGlobalY() : Number
      {
         return this._startGlobalY;
      }
      
      public function get globalX() : Number
      {
         return this._globalX;
      }
      
      public function set globalX(param1:Number) : void
      {
         if(this._globalX != this._globalX)
         {
            this._previousGlobalX = this._startGlobalX = param1;
         }
         else
         {
            this._previousGlobalX = this._globalX;
         }
         this._globalX = param1;
      }
      
      public function get globalY() : Number
      {
         return this._globalY;
      }
      
      public function set globalY(param1:Number) : void
      {
         if(this._globalY != this._globalY)
         {
            this._previousGlobalY = this._startGlobalY = param1;
         }
         else
         {
            this._previousGlobalY = this._globalY;
         }
         this._globalY = param1;
      }
      
      public function get tapCount() : int
      {
         return this._tapCount;
      }
      
      public function set tapCount(param1:int) : void
      {
         this._tapCount = param1;
      }
      
      public function get phase() : String
      {
         return this._phase;
      }
      
      public function set phase(param1:String) : void
      {
         this._phase = param1;
         if(param1 == starling.events.TouchPhase.BEGAN)
         {
            this._startGlobalX = this._globalX;
            this._startGlobalY = this._globalY;
            this._startTimestamp = this._timestamp;
         }
      }
      
      public function get target() : DisplayObject
      {
         return this._target;
      }
      
      public function set target(param1:DisplayObject) : void
      {
         if(this._target != param1)
         {
            this._target = param1;
            this.updateBubbleChain();
         }
      }
      
      public function get timestamp() : Number
      {
         return this._timestamp;
      }
      
      public function set timestamp(param1:Number) : void
      {
         if(this._startTimestamp < 0)
         {
            this._startTimestamp = param1;
         }
         this._timestamp = param1;
      }
      
      public function get pressure() : Number
      {
         return this._pressure;
      }
      
      public function set pressure(param1:Number) : void
      {
         this._pressure = param1;
      }
      
      public function get width() : Number
      {
         return this._width;
      }
      
      public function set width(param1:Number) : void
      {
         this._width = param1;
      }
      
      public function get height() : Number
      {
         return this._height;
      }
      
      public function set height(param1:Number) : void
      {
         this._height = param1;
      }
      
      public function get cancelled() : Boolean
      {
         return this._cancelled;
      }
      
      public function set cancelled(param1:Boolean) : void
      {
         this._cancelled = param1;
      }
      
      public function get duration() : Number
      {
         if(this._timestamp < 0 || this._startTimestamp < 0 || this._startTimestamp > this._timestamp)
         {
            return -1;
         }
         return this._timestamp - this._startTimestamp;
      }
      
      internal function update(param1:Number, param2:String, param3:Number, param4:Number, param5:Number = 1, param6:Number = 1, param7:Number = 1) : void
      {
         this._pressure = param5;
         this._width = param6;
         this._height = param7;
         this.timestamp = param1;
         this.globalX = param3;
         this.globalY = param4;
         this.phase = param2;
      }
      
      internal function dispatchEvent(param1:starling.events.TouchEvent) : void
      {
         if(this._target)
         {
            param1.dispatch(this._bubbleChain);
         }
      }
      
      internal function get bubbleChain() : Vector.<starling.events.EventDispatcher>
      {
         return this._bubbleChain.concat();
      }
   }
}
