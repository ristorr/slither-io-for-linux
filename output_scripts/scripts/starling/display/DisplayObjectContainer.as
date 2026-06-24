package starling.display
{
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.utils.getQualifiedClassName;
   import starling.core.starling_internal;
   import starling.errors.AbstractClassError;
   import starling.events.Event;
   import starling.filters.FragmentFilter;
   import starling.rendering.BatchToken;
   import starling.rendering.Painter;
   import starling.utils.MatrixUtil;
   
   public class DisplayObjectContainer extends starling.display.DisplayObject
   {
      
      private static var sHitTestMatrix:Matrix = new Matrix();
      
      private static var sHitTestPoint:Point = new Point();
      
      private static var sBoundsMatrix:Matrix = new Matrix();
      
      private static var sBoundsPoint:Point = new Point();
      
      private static var sBroadcastListeners:Vector.<starling.display.DisplayObject> = new Vector.<starling.display.DisplayObject>(0);
      
      private static var sSortBuffer:Vector.<starling.display.DisplayObject> = new Vector.<starling.display.DisplayObject>(0);
      
      private static var sCacheToken:BatchToken = new BatchToken();
       
      
      private var _children:Vector.<starling.display.DisplayObject>;
      
      private var _touchGroup:Boolean;
      
      public function DisplayObjectContainer()
      {
         super();
         if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.display::DisplayObjectContainer")
         {
            throw new AbstractClassError();
         }
         this._children = new Vector.<starling.display.DisplayObject>(0);
      }
      
      private static function mergeSort(param1:Vector.<starling.display.DisplayObject>, param2:Function, param3:int, param4:int, param5:Vector.<starling.display.DisplayObject>) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         if(param4 > 1)
         {
            _loc7_ = param3 + param4;
            _loc8_ = param4 / 2;
            _loc9_ = param3;
            _loc10_ = param3 + _loc8_;
            mergeSort(param1,param2,param3,_loc8_,param5);
            mergeSort(param1,param2,param3 + _loc8_,param4 - _loc8_,param5);
            _loc6_ = 0;
            while(_loc6_ < param4)
            {
               if(_loc9_ < param3 + _loc8_ && (_loc10_ == _loc7_ || param2(param1[_loc9_],param1[_loc10_]) <= 0))
               {
                  param5[_loc6_] = param1[_loc9_];
                  _loc9_++;
               }
               else
               {
                  param5[_loc6_] = param1[_loc10_];
                  _loc10_++;
               }
               _loc6_++;
            }
            _loc6_ = param3;
            while(_loc6_ < _loc7_)
            {
               param1[_loc6_] = param5[int(_loc6_ - param3)];
               _loc6_++;
            }
         }
      }
      
      override public function dispose() : void
      {
         var _loc1_:int = int(this._children.length - 1);
         while(_loc1_ >= 0)
         {
            this._children[_loc1_].dispose();
            _loc1_--;
         }
         super.dispose();
      }
      
      public function addChild(param1:starling.display.DisplayObject) : starling.display.DisplayObject
      {
         return this.addChildAt(param1,this._children.length);
      }
      
      public function addChildAt(param1:starling.display.DisplayObject, param2:int) : starling.display.DisplayObject
      {
         var _loc4_:starling.display.DisplayObjectContainer = null;
         var _loc3_:int = int(this._children.length);
         if(param2 >= 0 && param2 <= _loc3_)
         {
            setRequiresRedraw();
            if(param1.parent == this)
            {
               this.setChildIndex(param1,param2);
            }
            else
            {
               this._children.insertAt(param2,param1);
               param1.removeFromParent();
               param1.starling_internal::setParent(this);
               param1.dispatchEventWith(Event.ADDED,true);
               if(stage)
               {
                  if(_loc4_ = param1 as starling.display.DisplayObjectContainer)
                  {
                     _loc4_.broadcastEventWith(Event.ADDED_TO_STAGE);
                  }
                  else
                  {
                     param1.dispatchEventWith(Event.ADDED_TO_STAGE);
                  }
               }
            }
            return param1;
         }
         throw new RangeError("Invalid child index");
      }
      
      public function removeChild(param1:starling.display.DisplayObject, param2:Boolean = false) : starling.display.DisplayObject
      {
         var _loc3_:int = this.getChildIndex(param1);
         if(_loc3_ != -1)
         {
            return this.removeChildAt(_loc3_,param2);
         }
         return null;
      }
      
      public function removeChildAt(param1:int, param2:Boolean = false) : starling.display.DisplayObject
      {
         var _loc3_:starling.display.DisplayObject = null;
         var _loc4_:starling.display.DisplayObjectContainer = null;
         if(param1 >= 0 && param1 < this._children.length)
         {
            setRequiresRedraw();
            _loc3_ = this._children[param1];
            _loc3_.dispatchEventWith(Event.REMOVED,true);
            if(stage)
            {
               if(_loc4_ = _loc3_ as starling.display.DisplayObjectContainer)
               {
                  _loc4_.broadcastEventWith(Event.REMOVED_FROM_STAGE);
               }
               else
               {
                  _loc3_.dispatchEventWith(Event.REMOVED_FROM_STAGE);
               }
            }
            _loc3_.starling_internal::setParent(null);
            param1 = this._children.indexOf(_loc3_);
            if(param1 >= 0)
            {
               this._children.removeAt(param1);
            }
            if(param2)
            {
               _loc3_.dispose();
            }
            return _loc3_;
         }
         throw new RangeError("Invalid child index");
      }
      
      public function removeChildren(param1:int = 0, param2:int = -1, param3:Boolean = false) : void
      {
         if(param2 < 0 || param2 >= this.numChildren)
         {
            param2 = this.numChildren - 1;
         }
         var _loc4_:int = param1;
         while(_loc4_ <= param2)
         {
            this.removeChildAt(param1,param3);
            _loc4_++;
         }
      }
      
      public function getChildAt(param1:int) : starling.display.DisplayObject
      {
         var _loc2_:int = int(this._children.length);
         if(param1 < 0)
         {
            param1 = _loc2_ + param1;
         }
         if(param1 >= 0 && param1 < _loc2_)
         {
            return this._children[param1];
         }
         throw new RangeError("Invalid child index");
      }
      
      public function getChildByName(param1:String) : starling.display.DisplayObject
      {
         var _loc2_:int = int(this._children.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(this._children[_loc3_].name == param1)
            {
               return this._children[_loc3_];
            }
            _loc3_++;
         }
         return null;
      }
      
      public function getChildIndex(param1:starling.display.DisplayObject) : int
      {
         return this._children.indexOf(param1);
      }
      
      public function setChildIndex(param1:starling.display.DisplayObject, param2:int) : void
      {
         var _loc3_:int = this.getChildIndex(param1);
         if(_loc3_ == param2)
         {
            return;
         }
         if(_loc3_ == -1)
         {
            throw new ArgumentError("Not a child of this container");
         }
         this._children.removeAt(_loc3_);
         this._children.insertAt(param2,param1);
         setRequiresRedraw();
      }
      
      public function swapChildren(param1:starling.display.DisplayObject, param2:starling.display.DisplayObject) : void
      {
         var _loc3_:int = this.getChildIndex(param1);
         var _loc4_:int = this.getChildIndex(param2);
         if(_loc3_ == -1 || _loc4_ == -1)
         {
            throw new ArgumentError("Not a child of this container");
         }
         this.swapChildrenAt(_loc3_,_loc4_);
      }
      
      public function swapChildrenAt(param1:int, param2:int) : void
      {
         var _loc3_:starling.display.DisplayObject = this.getChildAt(param1);
         var _loc4_:starling.display.DisplayObject = this.getChildAt(param2);
         this._children[param1] = _loc4_;
         this._children[param2] = _loc3_;
         setRequiresRedraw();
      }
      
      public function sortChildren(param1:Function) : void
      {
         sSortBuffer.length = this._children.length;
         mergeSort(this._children,param1,0,this._children.length,sSortBuffer);
         sSortBuffer.length = 0;
         setRequiresRedraw();
      }
      
      public function contains(param1:starling.display.DisplayObject) : Boolean
      {
         while(param1)
         {
            if(param1 == this)
            {
               return true;
            }
            param1 = param1.parent;
         }
         return false;
      }
      
      override public function getBounds(param1:starling.display.DisplayObject, param2:flash.geom.Rectangle = null) : flash.geom.Rectangle
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         if(param2 == null)
         {
            param2 = new flash.geom.Rectangle();
         }
         var _loc3_:int = int(this._children.length);
         if(_loc3_ == 0)
         {
            getTransformationMatrix(param1,sBoundsMatrix);
            MatrixUtil.transformCoords(sBoundsMatrix,0,0,sBoundsPoint);
            param2.setTo(sBoundsPoint.x,sBoundsPoint.y,0,0);
         }
         else if(_loc3_ == 1)
         {
            this._children[0].getBounds(param1,param2);
         }
         else
         {
            _loc4_ = Number.MAX_VALUE;
            _loc5_ = -Number.MAX_VALUE;
            _loc6_ = Number.MAX_VALUE;
            _loc7_ = -Number.MAX_VALUE;
            _loc8_ = 0;
            while(_loc8_ < _loc3_)
            {
               this._children[_loc8_].getBounds(param1,param2);
               if(_loc4_ > param2.x)
               {
                  _loc4_ = param2.x;
               }
               if(_loc5_ < param2.right)
               {
                  _loc5_ = param2.right;
               }
               if(_loc6_ > param2.y)
               {
                  _loc6_ = param2.y;
               }
               if(_loc7_ < param2.bottom)
               {
                  _loc7_ = param2.bottom;
               }
               _loc8_++;
            }
            param2.setTo(_loc4_,_loc6_,_loc5_ - _loc4_,_loc7_ - _loc6_);
         }
         return param2;
      }
      
      override public function hitTest(param1:Point) : starling.display.DisplayObject
      {
         var _loc7_:starling.display.DisplayObject = null;
         if(!visible || !touchable || !hitTestMask(param1))
         {
            return null;
         }
         var _loc2_:starling.display.DisplayObject = null;
         var _loc3_:Number = param1.x;
         var _loc4_:Number = param1.y;
         var _loc5_:int;
         var _loc6_:int = (_loc5_ = int(this._children.length)) - 1;
         while(_loc6_ >= 0)
         {
            if(!(_loc7_ = this._children[_loc6_]).isMask)
            {
               sHitTestMatrix.copyFrom(_loc7_.transformationMatrix);
               sHitTestMatrix.invert();
               MatrixUtil.transformCoords(sHitTestMatrix,_loc3_,_loc4_,sHitTestPoint);
               _loc2_ = _loc7_.hitTest(sHitTestPoint);
               if(_loc2_)
               {
                  return this._touchGroup ? this : _loc2_;
               }
            }
            _loc6_--;
         }
         return null;
      }
      
      override public function render(param1:Painter) : void
      {
         var _loc7_:starling.display.DisplayObject = null;
         var _loc8_:BatchToken = null;
         var _loc9_:BatchToken = null;
         var _loc10_:FragmentFilter = null;
         var _loc11_:starling.display.DisplayObject = null;
         var _loc2_:int = int(this._children.length);
         var _loc3_:uint = param1.frameID;
         var _loc4_:* = _loc3_ != 0;
         var _loc5_:* = _lastParentOrSelfChangeFrameID == _loc3_;
         param1.pushState();
         var _loc6_:int = 0;
         while(_loc6_ < _loc2_)
         {
            if((_loc7_ = this._children[_loc6_])._hasVisibleArea)
            {
               if(_loc6_ != 0)
               {
                  param1.restoreState();
               }
               if(_loc5_)
               {
                  _loc7_._lastParentOrSelfChangeFrameID = _loc3_;
               }
               if(_loc7_._lastParentOrSelfChangeFrameID != _loc3_ && _loc7_._lastChildChangeFrameID != _loc3_ && _loc7_._tokenFrameID == _loc3_ - 1 && _loc4_)
               {
                  param1.fillToken(sCacheToken);
                  param1.drawFromCache(_loc7_._pushToken,_loc7_._popToken);
                  param1.fillToken(_loc7_._popToken);
                  _loc7_._pushToken.copyFrom(sCacheToken);
               }
               else
               {
                  _loc8_ = _loc4_ ? _loc7_._pushToken : null;
                  _loc9_ = _loc4_ ? _loc7_._popToken : null;
                  _loc10_ = _loc7_._filter;
                  _loc11_ = _loc7_._mask;
                  param1.fillToken(_loc8_);
                  param1.setStateTo(_loc7_.transformationMatrix,_loc7_.alpha,_loc7_.blendMode);
                  if(_loc11_)
                  {
                     param1.drawMask(_loc11_,_loc7_);
                  }
                  if(_loc10_)
                  {
                     _loc10_.render(param1);
                  }
                  else
                  {
                     _loc7_.render(param1);
                  }
                  if(_loc11_)
                  {
                     param1.eraseMask(_loc11_,_loc7_);
                  }
                  param1.fillToken(_loc9_);
               }
               if(_loc4_)
               {
                  _loc7_._tokenFrameID = _loc3_;
               }
            }
            _loc6_++;
         }
         param1.popState();
      }
      
      public function broadcastEvent(param1:Event) : void
      {
         if(param1.bubbles)
         {
            throw new ArgumentError("Broadcast of bubbling events is prohibited");
         }
         var _loc2_:int = int(sBroadcastListeners.length);
         this.getChildEventListeners(this,param1.type,sBroadcastListeners);
         var _loc3_:int = int(sBroadcastListeners.length);
         var _loc4_:int = _loc2_;
         while(_loc4_ < _loc3_)
         {
            sBroadcastListeners[_loc4_].dispatchEvent(param1);
            _loc4_++;
         }
         sBroadcastListeners.length = _loc2_;
      }
      
      public function broadcastEventWith(param1:String, param2:Object = null) : void
      {
         var _loc3_:Event = Event.starling_internal::fromPool(param1,false,param2);
         this.broadcastEvent(_loc3_);
         Event.starling_internal::toPool(_loc3_);
      }
      
      public function get numChildren() : int
      {
         return this._children.length;
      }
      
      public function get touchGroup() : Boolean
      {
         return this._touchGroup;
      }
      
      public function set touchGroup(param1:Boolean) : void
      {
         this._touchGroup = param1;
      }
      
      internal function getChildEventListeners(param1:starling.display.DisplayObject, param2:String, param3:Vector.<starling.display.DisplayObject>) : void
      {
         var _loc5_:Vector.<starling.display.DisplayObject> = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:starling.display.DisplayObjectContainer = param1 as starling.display.DisplayObjectContainer;
         if(param1.hasEventListener(param2))
         {
            param3[param3.length] = param1;
         }
         if(_loc4_)
         {
            _loc6_ = int((_loc5_ = _loc4_._children).length);
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               this.getChildEventListeners(_loc5_[_loc7_],param2,param3);
               _loc7_++;
            }
         }
      }
   }
}
