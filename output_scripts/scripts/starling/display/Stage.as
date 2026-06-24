package starling.display
{
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import starling.core.Starling;
   import starling.core.starling_internal;
   import starling.events.EnterFrameEvent;
   import starling.events.Event;
   import starling.filters.FragmentFilter;
   import starling.utils.MatrixUtil;
   import starling.utils.RectangleUtil;
   
   public class Stage extends starling.display.DisplayObjectContainer
   {
      
      private static var sMatrix:Matrix = new Matrix();
      
      private static var sMatrix3D:Matrix3D = new Matrix3D();
       
      
      private var _width:int;
      
      private var _height:int;
      
      private var _color:uint;
      
      private var _fieldOfView:Number;
      
      private var _projectionOffset:Point;
      
      private var _cameraPosition:Vector3D;
      
      private var _enterFrameEvent:EnterFrameEvent;
      
      private var _enterFrameListeners:Vector.<starling.display.DisplayObject>;
      
      public function Stage(param1:int, param2:int, param3:uint = 0)
      {
         super();
         this._width = param1;
         this._height = param2;
         this._color = param3;
         this._fieldOfView = 1;
         this._projectionOffset = new Point();
         this._cameraPosition = new Vector3D();
         this._enterFrameEvent = new EnterFrameEvent(Event.ENTER_FRAME,0);
         this._enterFrameListeners = new Vector.<starling.display.DisplayObject>(0);
      }
      
      public function advanceTime(param1:Number) : void
      {
         this._enterFrameEvent.starling_internal::reset(Event.ENTER_FRAME,false,param1);
         broadcastEvent(this._enterFrameEvent);
      }
      
      override public function hitTest(param1:Point) : starling.display.DisplayObject
      {
         if(!visible || !touchable)
         {
            return null;
         }
         if(param1.x < 0 || param1.x > this._width || param1.y < 0 || param1.y > this._height)
         {
            return null;
         }
         var _loc2_:starling.display.DisplayObject = super.hitTest(param1);
         return !!_loc2_ ? _loc2_ : this;
      }
      
      public function getStageBounds(param1:starling.display.DisplayObject, param2:flash.geom.Rectangle = null) : flash.geom.Rectangle
      {
         if(param2 == null)
         {
            param2 = new flash.geom.Rectangle();
         }
         param2.setTo(0,0,this._width,this._height);
         getTransformationMatrix(param1,sMatrix);
         return RectangleUtil.getBounds(param2,sMatrix,param2);
      }
      
      public function getScreenBounds(param1:starling.display.DisplayObject, param2:flash.geom.Rectangle = null) : flash.geom.Rectangle
      {
         var _loc3_:Starling = this.starling;
         if(_loc3_ == null)
         {
            return this.getStageBounds(param1,param2);
         }
         if(param2 == null)
         {
            param2 = new flash.geom.Rectangle();
         }
         var _loc4_:Object = _loc3_.nativeStage;
         var _loc5_:flash.geom.Rectangle = _loc3_.viewPort;
         var _loc6_:Number = this._width / _loc5_.width;
         var _loc7_:Number = this._height / _loc5_.height;
         var _loc8_:Number = -_loc5_.x * _loc6_;
         var _loc9_:Number = -_loc5_.y * _loc7_;
         param2.setTo(_loc8_,_loc9_,_loc4_.stageWidth * _loc6_,_loc4_.stageHeight * _loc7_);
         getTransformationMatrix(param1,sMatrix);
         return RectangleUtil.getBounds(param2,sMatrix,param2);
      }
      
      public function getCameraPosition(param1:starling.display.DisplayObject = null, param2:Vector3D = null) : Vector3D
      {
         getTransformationMatrix3D(param1,sMatrix3D);
         return MatrixUtil.transformCoords3D(sMatrix3D,this._width / 2 + this._projectionOffset.x,this._height / 2 + this._projectionOffset.y,-this.focalLength,param2);
      }
      
      internal function addEnterFrameListener(param1:starling.display.DisplayObject) : void
      {
         var _loc2_:int = this._enterFrameListeners.indexOf(param1);
         if(_loc2_ < 0)
         {
            this._enterFrameListeners[this._enterFrameListeners.length] = param1;
         }
      }
      
      internal function removeEnterFrameListener(param1:starling.display.DisplayObject) : void
      {
         var _loc2_:int = this._enterFrameListeners.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this._enterFrameListeners.removeAt(_loc2_);
         }
      }
      
      override internal function getChildEventListeners(param1:starling.display.DisplayObject, param2:String, param3:Vector.<starling.display.DisplayObject>) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param2 == Event.ENTER_FRAME && param1 == this)
         {
            _loc4_ = 0;
            _loc5_ = int(this._enterFrameListeners.length);
            while(_loc4_ < _loc5_)
            {
               param3[param3.length] = this._enterFrameListeners[_loc4_];
               _loc4_++;
            }
         }
         else
         {
            super.getChildEventListeners(param1,param2,param3);
         }
      }
      
      override public function set width(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot set width of stage");
      }
      
      override public function set height(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot set height of stage");
      }
      
      override public function set x(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot set x-coordinate of stage");
      }
      
      override public function set y(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot set y-coordinate of stage");
      }
      
      override public function set scaleX(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot scale stage");
      }
      
      override public function set scaleY(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot scale stage");
      }
      
      override public function set rotation(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot rotate stage");
      }
      
      override public function set skewX(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot skew stage");
      }
      
      override public function set skewY(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot skew stage");
      }
      
      override public function set filter(param1:FragmentFilter) : void
      {
         throw new IllegalOperationError("Cannot add filter to stage. Add it to \'root\' instead!");
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set color(param1:uint) : void
      {
         if(this._color != param1)
         {
            this._color = param1;
            setRequiresRedraw();
         }
      }
      
      public function get stageWidth() : int
      {
         return this._width;
      }
      
      public function set stageWidth(param1:int) : void
      {
         if(this._width != param1)
         {
            this._width = param1;
            setRequiresRedraw();
         }
      }
      
      public function get stageHeight() : int
      {
         return this._height;
      }
      
      public function set stageHeight(param1:int) : void
      {
         if(this._height != param1)
         {
            this._height = param1;
            setRequiresRedraw();
         }
      }
      
      public function get starling() : Starling
      {
         var _loc1_:Vector.<Starling> = Starling.all;
         var _loc2_:int = int(_loc1_.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(_loc1_[_loc3_].stage == this)
            {
               return _loc1_[_loc3_];
            }
            _loc3_++;
         }
         return null;
      }
      
      public function get focalLength() : Number
      {
         return this._width / (2 * Math.tan(this._fieldOfView / 2));
      }
      
      public function set focalLength(param1:Number) : void
      {
         this._fieldOfView = 2 * Math.atan(this.stageWidth / (2 * param1));
         setRequiresRedraw();
      }
      
      public function get fieldOfView() : Number
      {
         return this._fieldOfView;
      }
      
      public function set fieldOfView(param1:Number) : void
      {
         this._fieldOfView = param1;
         setRequiresRedraw();
      }
      
      public function get projectionOffset() : Point
      {
         return this._projectionOffset;
      }
      
      public function set projectionOffset(param1:Point) : void
      {
         this._projectionOffset.setTo(param1.x,param1.y);
         setRequiresRedraw();
      }
      
      public function get cameraPosition() : Vector3D
      {
         return this.getCameraPosition(null,this._cameraPosition);
      }
   }
}
