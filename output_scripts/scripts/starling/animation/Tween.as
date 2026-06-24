package starling.animation
{
   import starling.core.starling_internal;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   import starling.utils.Color;
   
   public class Tween extends EventDispatcher implements starling.animation.IAnimatable
   {
      
      private static const HINT_MARKER:String = "#";
      
      private static var sTweenPool:Vector.<starling.animation.Tween> = new Vector.<starling.animation.Tween>(0);
       
      
      private var _target:Object;
      
      private var _transitionFunc:Function;
      
      private var _transitionName:String;
      
      private var _properties:Vector.<String>;
      
      private var _startValues:Vector.<Number>;
      
      private var _endValues:Vector.<Number>;
      
      private var _updateFuncs:Vector.<Function>;
      
      private var _onStart:Function;
      
      private var _onUpdate:Function;
      
      private var _onRepeat:Function;
      
      private var _onComplete:Function;
      
      private var _onStartArgs:Array;
      
      private var _onUpdateArgs:Array;
      
      private var _onRepeatArgs:Array;
      
      private var _onCompleteArgs:Array;
      
      private var _totalTime:Number;
      
      private var _currentTime:Number;
      
      private var _progress:Number;
      
      private var _delay:Number;
      
      private var _roundToInt:Boolean;
      
      private var _nextTween:starling.animation.Tween;
      
      private var _repeatCount:int;
      
      private var _repeatDelay:Number;
      
      private var _reverse:Boolean;
      
      private var _currentCycle:int;
      
      public function Tween(param1:Object, param2:Number, param3:Object = "linear")
      {
         super();
         this.reset(param1,param2,param3);
      }
      
      internal static function getPropertyHint(param1:String) : String
      {
         if(param1.indexOf("color") != -1 || param1.indexOf("Color") != -1)
         {
            return "rgb";
         }
         var _loc2_:int = param1.indexOf(HINT_MARKER);
         if(_loc2_ != -1)
         {
            return param1.substr(_loc2_ + 1);
         }
         return null;
      }
      
      internal static function getPropertyName(param1:String) : String
      {
         var _loc2_:int = param1.indexOf(HINT_MARKER);
         if(_loc2_ != -1)
         {
            return param1.substring(0,_loc2_);
         }
         return param1;
      }
      
      starling_internal static function fromPool(param1:Object, param2:Number, param3:Object = "linear") : starling.animation.Tween
      {
         if(sTweenPool.length)
         {
            return sTweenPool.pop().reset(param1,param2,param3);
         }
         return new starling.animation.Tween(param1,param2,param3);
      }
      
      starling_internal static function toPool(param1:starling.animation.Tween) : void
      {
         param1._onStart = param1._onUpdate = param1._onRepeat = param1._onComplete = null;
         param1._onStartArgs = param1._onUpdateArgs = param1._onRepeatArgs = param1._onCompleteArgs = null;
         param1._target = null;
         param1._transitionFunc = null;
         param1.removeEventListeners();
         sTweenPool.push(param1);
      }
      
      public function reset(param1:Object, param2:Number, param3:Object = "linear") : starling.animation.Tween
      {
         this._target = param1;
         this._currentTime = 0;
         this._totalTime = Math.max(0.0001,param2);
         this._progress = 0;
         this._delay = this._repeatDelay = 0;
         this._onStart = this._onUpdate = this._onRepeat = this._onComplete = null;
         this._onStartArgs = this._onUpdateArgs = this._onRepeatArgs = this._onCompleteArgs = null;
         this._roundToInt = this._reverse = false;
         this._repeatCount = 1;
         this._currentCycle = -1;
         this._nextTween = null;
         if(param3 is String)
         {
            this.transition = param3 as String;
         }
         else
         {
            if(!(param3 is Function))
            {
               throw new ArgumentError("Transition must be either a string or a function");
            }
            this.transitionFunc = param3 as Function;
         }
         if(this._properties)
         {
            this._properties.length = 0;
         }
         else
         {
            this._properties = new Vector.<String>(0);
         }
         if(this._startValues)
         {
            this._startValues.length = 0;
         }
         else
         {
            this._startValues = new Vector.<Number>(0);
         }
         if(this._endValues)
         {
            this._endValues.length = 0;
         }
         else
         {
            this._endValues = new Vector.<Number>(0);
         }
         if(this._updateFuncs)
         {
            this._updateFuncs.length = 0;
         }
         else
         {
            this._updateFuncs = new Vector.<Function>(0);
         }
         return this;
      }
      
      public function animate(param1:String, param2:Number) : void
      {
         if(this._target == null)
         {
            return;
         }
         var _loc3_:int = int(this._properties.length);
         var _loc4_:Function = this.getUpdateFuncFromProperty(param1);
         this._properties[_loc3_] = getPropertyName(param1);
         this._startValues[_loc3_] = Number.NaN;
         this._endValues[_loc3_] = param2;
         this._updateFuncs[_loc3_] = _loc4_;
      }
      
      public function scaleTo(param1:Number) : void
      {
         this.animate("scaleX",param1);
         this.animate("scaleY",param1);
      }
      
      public function moveTo(param1:Number, param2:Number) : void
      {
         this.animate("x",param1);
         this.animate("y",param2);
      }
      
      public function fadeTo(param1:Number) : void
      {
         this.animate("alpha",param1);
      }
      
      public function rotateTo(param1:Number, param2:String = "rad") : void
      {
         this.animate("rotation#" + param2,param1);
      }
      
      public function advanceTime(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc9_:Function = null;
         var _loc10_:Function = null;
         var _loc11_:Array = null;
         if(param1 == 0 || this._repeatCount == 1 && this._currentTime == this._totalTime)
         {
            return;
         }
         var _loc3_:Number = this._currentTime;
         var _loc4_:Number = this._totalTime - this._currentTime;
         var _loc5_:Number = param1 > _loc4_ ? param1 - _loc4_ : 0;
         this._currentTime += param1;
         if(this._currentTime <= 0)
         {
            return;
         }
         if(this._currentTime > this._totalTime)
         {
            this._currentTime = this._totalTime;
         }
         if(this._currentCycle < 0 && _loc3_ <= 0 && this._currentTime > 0)
         {
            ++this._currentCycle;
            if(this._onStart != null)
            {
               this._onStart.apply(this,this._onStartArgs);
            }
         }
         var _loc6_:Number = this._currentTime / this._totalTime;
         var _loc7_:Boolean = this._reverse && this._currentCycle % 2 == 1;
         var _loc8_:int = int(this._startValues.length);
         this._progress = _loc7_ ? this._transitionFunc(1 - _loc6_) : this._transitionFunc(_loc6_);
         _loc2_ = 0;
         while(_loc2_ < _loc8_)
         {
            if(this._startValues[_loc2_] != this._startValues[_loc2_])
            {
               this._startValues[_loc2_] = this._target[this._properties[_loc2_]] as Number;
            }
            (_loc9_ = this._updateFuncs[_loc2_] as Function)(this._properties[_loc2_],this._startValues[_loc2_],this._endValues[_loc2_]);
            _loc2_++;
         }
         if(this._onUpdate != null)
         {
            this._onUpdate.apply(this,this._onUpdateArgs);
         }
         if(_loc3_ < this._totalTime && this._currentTime >= this._totalTime)
         {
            if(this._repeatCount == 0 || this._repeatCount > 1)
            {
               this._currentTime = -this._repeatDelay;
               ++this._currentCycle;
               if(this._repeatCount > 1)
               {
                  --this._repeatCount;
               }
               if(this._onRepeat != null)
               {
                  this._onRepeat.apply(this,this._onRepeatArgs);
               }
            }
            else
            {
               _loc10_ = this._onComplete;
               _loc11_ = this._onCompleteArgs;
               dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
               if(_loc10_ != null)
               {
                  _loc10_.apply(this,_loc11_);
               }
               if(this._currentTime == 0)
               {
                  _loc5_ = 0;
               }
            }
         }
         if(_loc5_)
         {
            this.advanceTime(_loc5_);
         }
      }
      
      private function getUpdateFuncFromProperty(param1:String) : Function
      {
         var _loc2_:Function = null;
         var _loc3_:String = getPropertyHint(param1);
         switch(_loc3_)
         {
            case null:
               _loc2_ = this.updateStandard;
               break;
            case "rgb":
               _loc2_ = this.updateRgb;
               break;
            case "rad":
               _loc2_ = this.updateRad;
               break;
            case "deg":
               _loc2_ = this.updateDeg;
               break;
            default:
               trace("[Starling] Ignoring unknown property hint:",_loc3_);
               _loc2_ = this.updateStandard;
         }
         return _loc2_;
      }
      
      private function updateStandard(param1:String, param2:Number, param3:Number) : void
      {
         var _loc4_:Number = param2 + this._progress * (param3 - param2);
         if(this._roundToInt)
         {
            _loc4_ = Math.round(_loc4_);
         }
         this._target[param1] = _loc4_;
      }
      
      private function updateRgb(param1:String, param2:Number, param3:Number) : void
      {
         this._target[param1] = Color.interpolate(uint(param2),uint(param3),this._progress);
      }
      
      private function updateRad(param1:String, param2:Number, param3:Number) : void
      {
         this.updateAngle(Math.PI,param1,param2,param3);
      }
      
      private function updateDeg(param1:String, param2:Number, param3:Number) : void
      {
         this.updateAngle(180,param1,param2,param3);
      }
      
      private function updateAngle(param1:Number, param2:String, param3:Number, param4:Number) : void
      {
         while(Math.abs(param4 - param3) > param1)
         {
            if(param3 < param4)
            {
               param4 -= 2 * param1;
            }
            else
            {
               param4 += 2 * param1;
            }
         }
         this.updateStandard(param2,param3,param4);
      }
      
      public function getEndValue(param1:String) : Number
      {
         var _loc2_:int = this._properties.indexOf(param1);
         if(_loc2_ == -1)
         {
            throw new ArgumentError("The property \'" + param1 + "\' is not animated");
         }
         return this._endValues[_loc2_] as Number;
      }
      
      public function animatesProperty(param1:String) : Boolean
      {
         return this._properties.indexOf(param1) != -1;
      }
      
      public function get isComplete() : Boolean
      {
         return this._currentTime >= this._totalTime && this._repeatCount == 1;
      }
      
      public function get target() : Object
      {
         return this._target;
      }
      
      public function get transition() : String
      {
         return this._transitionName;
      }
      
      public function set transition(param1:String) : void
      {
         this._transitionName = param1;
         this._transitionFunc = starling.animation.Transitions.getTransition(param1);
         if(this._transitionFunc == null)
         {
            throw new ArgumentError("Invalid transiton: " + param1);
         }
      }
      
      public function get transitionFunc() : Function
      {
         return this._transitionFunc;
      }
      
      public function set transitionFunc(param1:Function) : void
      {
         this._transitionName = "custom";
         this._transitionFunc = param1;
      }
      
      public function get totalTime() : Number
      {
         return this._totalTime;
      }
      
      public function get currentTime() : Number
      {
         return this._currentTime;
      }
      
      public function get progress() : Number
      {
         return this._progress;
      }
      
      public function get delay() : Number
      {
         return this._delay;
      }
      
      public function set delay(param1:Number) : void
      {
         this._currentTime = this._currentTime + this._delay - param1;
         this._delay = param1;
      }
      
      public function get repeatCount() : int
      {
         return this._repeatCount;
      }
      
      public function set repeatCount(param1:int) : void
      {
         this._repeatCount = param1;
      }
      
      public function get repeatDelay() : Number
      {
         return this._repeatDelay;
      }
      
      public function set repeatDelay(param1:Number) : void
      {
         this._repeatDelay = param1;
      }
      
      public function get reverse() : Boolean
      {
         return this._reverse;
      }
      
      public function set reverse(param1:Boolean) : void
      {
         this._reverse = param1;
      }
      
      public function get roundToInt() : Boolean
      {
         return this._roundToInt;
      }
      
      public function set roundToInt(param1:Boolean) : void
      {
         this._roundToInt = param1;
      }
      
      public function get onStart() : Function
      {
         return this._onStart;
      }
      
      public function set onStart(param1:Function) : void
      {
         this._onStart = param1;
      }
      
      public function get onUpdate() : Function
      {
         return this._onUpdate;
      }
      
      public function set onUpdate(param1:Function) : void
      {
         this._onUpdate = param1;
      }
      
      public function get onRepeat() : Function
      {
         return this._onRepeat;
      }
      
      public function set onRepeat(param1:Function) : void
      {
         this._onRepeat = param1;
      }
      
      public function get onComplete() : Function
      {
         return this._onComplete;
      }
      
      public function set onComplete(param1:Function) : void
      {
         this._onComplete = param1;
      }
      
      public function get onStartArgs() : Array
      {
         return this._onStartArgs;
      }
      
      public function set onStartArgs(param1:Array) : void
      {
         this._onStartArgs = param1;
      }
      
      public function get onUpdateArgs() : Array
      {
         return this._onUpdateArgs;
      }
      
      public function set onUpdateArgs(param1:Array) : void
      {
         this._onUpdateArgs = param1;
      }
      
      public function get onRepeatArgs() : Array
      {
         return this._onRepeatArgs;
      }
      
      public function set onRepeatArgs(param1:Array) : void
      {
         this._onRepeatArgs = param1;
      }
      
      public function get onCompleteArgs() : Array
      {
         return this._onCompleteArgs;
      }
      
      public function set onCompleteArgs(param1:Array) : void
      {
         this._onCompleteArgs = param1;
      }
      
      public function get nextTween() : starling.animation.Tween
      {
         return this._nextTween;
      }
      
      public function set nextTween(param1:starling.animation.Tween) : void
      {
         this._nextTween = param1;
      }
   }
}
