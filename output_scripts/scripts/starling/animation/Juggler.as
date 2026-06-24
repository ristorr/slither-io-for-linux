package starling.animation
{
   import flash.utils.Dictionary;
   import starling.core.starling_internal;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   
   public class Juggler implements starling.animation.IAnimatable
   {
      
      private static var sCurrentObjectID:uint;
       
      
      private var _objects:Vector.<starling.animation.IAnimatable>;
      
      private var _objectIDs:Dictionary;
      
      private var _elapsedTime:Number;
      
      private var _timeScale:Number;
      
      public function Juggler()
      {
         super();
         this._elapsedTime = 0;
         this._timeScale = 1;
         this._objects = new Vector.<starling.animation.IAnimatable>(0);
         this._objectIDs = new Dictionary(true);
      }
      
      private static function getNextID() : uint
      {
         return ++sCurrentObjectID;
      }
      
      public function add(param1:starling.animation.IAnimatable) : uint
      {
         return this.addWithID(param1,getNextID());
      }
      
      private function addWithID(param1:starling.animation.IAnimatable, param2:uint) : uint
      {
         var _loc3_:EventDispatcher = null;
         if(Boolean(param1) && !(param1 in this._objectIDs))
         {
            _loc3_ = param1 as EventDispatcher;
            if(_loc3_)
            {
               _loc3_.addEventListener(Event.REMOVE_FROM_JUGGLER,this.onRemove);
            }
            this._objects[this._objects.length] = param1;
            this._objectIDs[param1] = param2;
            return param2;
         }
         return 0;
      }
      
      public function contains(param1:starling.animation.IAnimatable) : Boolean
      {
         return param1 in this._objectIDs;
      }
      
      public function remove(param1:starling.animation.IAnimatable) : uint
      {
         var _loc3_:EventDispatcher = null;
         var _loc4_:int = 0;
         var _loc2_:uint = 0;
         if(Boolean(param1) && param1 in this._objectIDs)
         {
            _loc3_ = param1 as EventDispatcher;
            if(_loc3_)
            {
               _loc3_.removeEventListener(Event.REMOVE_FROM_JUGGLER,this.onRemove);
            }
            _loc4_ = this._objects.indexOf(param1);
            this._objects[_loc4_] = null;
            _loc2_ = uint(this._objectIDs[param1]);
            delete this._objectIDs[param1];
         }
         return _loc2_;
      }
      
      public function removeByID(param1:uint) : uint
      {
         var _loc3_:starling.animation.IAnimatable = null;
         var _loc2_:int = int(this._objects.length - 1);
         while(_loc2_ >= 0)
         {
            _loc3_ = this._objects[_loc2_];
            if(this._objectIDs[_loc3_] == param1)
            {
               this.remove(_loc3_);
               return param1;
            }
            _loc2_--;
         }
         return 0;
      }
      
      public function removeTweens(param1:Object) : void
      {
         var _loc3_:starling.animation.Tween = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:int = int(this._objects.length - 1);
         while(_loc2_ >= 0)
         {
            _loc3_ = this._objects[_loc2_] as starling.animation.Tween;
            if(Boolean(_loc3_) && _loc3_.target == param1)
            {
               _loc3_.removeEventListener(Event.REMOVE_FROM_JUGGLER,this.onRemove);
               this._objects[_loc2_] = null;
               delete this._objectIDs[_loc3_];
            }
            _loc2_--;
         }
      }
      
      public function removeDelayedCalls(param1:Function) : void
      {
         var _loc3_:starling.animation.DelayedCall = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:int = int(this._objects.length - 1);
         while(_loc2_ >= 0)
         {
            _loc3_ = this._objects[_loc2_] as starling.animation.DelayedCall;
            if(Boolean(_loc3_) && _loc3_.callback == param1)
            {
               _loc3_.removeEventListener(Event.REMOVE_FROM_JUGGLER,this.onRemove);
               this._objects[_loc2_] = null;
               delete this._objectIDs[_loc3_];
            }
            _loc2_--;
         }
      }
      
      public function containsTweens(param1:Object) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:starling.animation.Tween = null;
         if(param1)
         {
            _loc2_ = int(this._objects.length - 1);
            while(_loc2_ >= 0)
            {
               _loc3_ = this._objects[_loc2_] as starling.animation.Tween;
               if(Boolean(_loc3_) && _loc3_.target == param1)
               {
                  return true;
               }
               _loc2_--;
            }
         }
         return false;
      }
      
      public function containsDelayedCalls(param1:Function) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:starling.animation.DelayedCall = null;
         if(param1 != null)
         {
            _loc2_ = int(this._objects.length - 1);
            while(_loc2_ >= 0)
            {
               _loc3_ = this._objects[_loc2_] as starling.animation.DelayedCall;
               if(Boolean(_loc3_) && _loc3_.callback == param1)
               {
                  return true;
               }
               _loc2_--;
            }
         }
         return false;
      }
      
      public function purge() : void
      {
         var _loc2_:starling.animation.IAnimatable = null;
         var _loc3_:EventDispatcher = null;
         var _loc1_:int = int(this._objects.length - 1);
         while(_loc1_ >= 0)
         {
            _loc2_ = this._objects[_loc1_];
            _loc3_ = _loc2_ as EventDispatcher;
            if(_loc3_)
            {
               _loc3_.removeEventListener(Event.REMOVE_FROM_JUGGLER,this.onRemove);
            }
            this._objects[_loc1_] = null;
            delete this._objectIDs[_loc2_];
            _loc1_--;
         }
      }
      
      public function delayCall(param1:Function, param2:Number, ... rest) : uint
      {
         if(param1 == null)
         {
            throw new ArgumentError("call must not be null");
         }
         var _loc4_:starling.animation.DelayedCall;
         (_loc4_ = starling.animation.DelayedCall.starling_internal::fromPool(param1,param2,rest)).addEventListener(Event.REMOVE_FROM_JUGGLER,this.onPooledDelayedCallComplete);
         return this.add(_loc4_);
      }
      
      public function repeatCall(param1:Function, param2:Number, param3:int = 0, ... rest) : uint
      {
         if(param1 == null)
         {
            throw new ArgumentError("call must not be null");
         }
         var _loc5_:starling.animation.DelayedCall;
         (_loc5_ = starling.animation.DelayedCall.starling_internal::fromPool(param1,param2,rest)).repeatCount = param3;
         _loc5_.addEventListener(Event.REMOVE_FROM_JUGGLER,this.onPooledDelayedCallComplete);
         return this.add(_loc5_);
      }
      
      private function onPooledDelayedCallComplete(param1:Event) : void
      {
         starling.animation.DelayedCall.starling_internal::toPool(param1.target as starling.animation.DelayedCall);
      }
      
      public function tween(param1:Object, param2:Number, param3:Object) : uint
      {
         var _loc5_:String = null;
         var _loc6_:Object = null;
         if(param1 == null)
         {
            throw new ArgumentError("target must not be null");
         }
         var _loc4_:starling.animation.Tween = starling.animation.Tween.starling_internal::fromPool(param1,param2);
         for(_loc5_ in param3)
         {
            _loc6_ = param3[_loc5_];
            if(_loc4_.hasOwnProperty(_loc5_))
            {
               _loc4_[_loc5_] = _loc6_;
            }
            else
            {
               if(!param1.hasOwnProperty(starling.animation.Tween.getPropertyName(_loc5_)))
               {
                  throw new ArgumentError("Invalid property: " + _loc5_);
               }
               _loc4_.animate(_loc5_,_loc6_ as Number);
            }
         }
         _loc4_.addEventListener(Event.REMOVE_FROM_JUGGLER,this.onPooledTweenComplete);
         return this.add(_loc4_);
      }
      
      private function onPooledTweenComplete(param1:Event) : void
      {
         starling.animation.Tween.starling_internal::toPool(param1.target as starling.animation.Tween);
      }
      
      public function advanceTime(param1:Number) : void
      {
         var _loc4_:int = 0;
         var _loc5_:starling.animation.IAnimatable = null;
         var _loc2_:int = int(this._objects.length);
         var _loc3_:int = 0;
         this._elapsedTime += param1;
         param1 *= this._timeScale;
         if(_loc2_ == 0 || param1 == 0)
         {
            return;
         }
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            if(_loc5_ = this._objects[_loc4_])
            {
               if(_loc3_ != _loc4_)
               {
                  this._objects[_loc3_] = _loc5_;
                  this._objects[_loc4_] = null;
               }
               _loc5_.advanceTime(param1);
               _loc3_++;
            }
            _loc4_++;
         }
         if(_loc3_ != _loc4_)
         {
            _loc2_ = int(this._objects.length);
            while(_loc4_ < _loc2_)
            {
               this._objects[int(_loc3_++)] = this._objects[int(_loc4_++)];
            }
            this._objects.length = _loc3_;
         }
      }
      
      private function onRemove(param1:Event) : void
      {
         var _loc3_:starling.animation.Tween = null;
         var _loc2_:uint = this.remove(param1.target as starling.animation.IAnimatable);
         if(_loc2_)
         {
            _loc3_ = param1.target as starling.animation.Tween;
            if(Boolean(_loc3_) && _loc3_.isComplete)
            {
               this.addWithID(_loc3_.nextTween,_loc2_);
            }
         }
      }
      
      public function get elapsedTime() : Number
      {
         return this._elapsedTime;
      }
      
      public function get timeScale() : Number
      {
         return this._timeScale;
      }
      
      public function set timeScale(param1:Number) : void
      {
         this._timeScale = param1;
      }
      
      protected function get objects() : Vector.<starling.animation.IAnimatable>
      {
         return this._objects;
      }
   }
}
