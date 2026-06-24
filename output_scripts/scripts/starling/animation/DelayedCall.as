package starling.animation
{
   import starling.core.starling_internal;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   
   public class DelayedCall extends EventDispatcher implements starling.animation.IAnimatable
   {
      
      private static var sPool:Vector.<starling.animation.DelayedCall> = new Vector.<starling.animation.DelayedCall>(0);
       
      
      private var _currentTime:Number;
      
      private var _totalTime:Number;
      
      private var _callback:Function;
      
      private var _args:Array;
      
      private var _repeatCount:int;
      
      public function DelayedCall(param1:Function, param2:Number, param3:Array = null)
      {
         super();
         this.reset(param1,param2,param3);
      }
      
      starling_internal static function fromPool(param1:Function, param2:Number, param3:Array = null) : starling.animation.DelayedCall
      {
         if(sPool.length)
         {
            return sPool.pop().reset(param1,param2,param3);
         }
         return new starling.animation.DelayedCall(param1,param2,param3);
      }
      
      starling_internal static function toPool(param1:starling.animation.DelayedCall) : void
      {
         param1._callback = null;
         param1._args = null;
         param1.removeEventListeners();
         sPool.push(param1);
      }
      
      public function reset(param1:Function, param2:Number, param3:Array = null) : starling.animation.DelayedCall
      {
         this._currentTime = 0;
         this._totalTime = Math.max(param2,0.0001);
         this._callback = param1;
         this._args = param3;
         this._repeatCount = 1;
         return this;
      }
      
      public function advanceTime(param1:Number) : void
      {
         var _loc3_:Function = null;
         var _loc4_:Array = null;
         var _loc2_:Number = this._currentTime;
         this._currentTime += param1;
         if(this._currentTime > this._totalTime)
         {
            this._currentTime = this._totalTime;
         }
         if(_loc2_ < this._totalTime && this._currentTime >= this._totalTime)
         {
            if(this._repeatCount == 0 || this._repeatCount > 1)
            {
               this._callback.apply(null,this._args);
               if(this._repeatCount > 0)
               {
                  --this._repeatCount;
               }
               this._currentTime = 0;
               this.advanceTime(_loc2_ + param1 - this._totalTime);
            }
            else
            {
               _loc3_ = this._callback;
               _loc4_ = this._args;
               dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
               _loc3_.apply(null,_loc4_);
            }
         }
      }
      
      public function complete() : void
      {
         var _loc1_:Number = this._totalTime - this._currentTime;
         if(_loc1_ > 0)
         {
            this.advanceTime(_loc1_);
         }
      }
      
      public function get isComplete() : Boolean
      {
         return this._repeatCount == 1 && this._currentTime >= this._totalTime;
      }
      
      public function get totalTime() : Number
      {
         return this._totalTime;
      }
      
      public function get currentTime() : Number
      {
         return this._currentTime;
      }
      
      public function get repeatCount() : int
      {
         return this._repeatCount;
      }
      
      public function set repeatCount(param1:int) : void
      {
         this._repeatCount = param1;
      }
      
      public function get callback() : Function
      {
         return this._callback;
      }
      
      public function get arguments() : Array
      {
         return this._args;
      }
   }
}
