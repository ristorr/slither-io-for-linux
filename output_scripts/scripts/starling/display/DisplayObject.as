package starling.display
{
   import flash.display.BitmapData;
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.system.Capabilities;
   import flash.ui.Mouse;
   import flash.ui.MouseCursor;
   import flash.utils.getQualifiedClassName;
   import starling.core.Starling;
   import starling.core.starling_internal;
   import starling.errors.AbstractClassError;
   import starling.errors.AbstractMethodError;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   import starling.events.TouchEvent;
   import starling.filters.FragmentFilter;
   import starling.rendering.BatchToken;
   import starling.rendering.Painter;
   import starling.utils.Align;
   import starling.utils.Color;
   import starling.utils.MathUtil;
   import starling.utils.MatrixUtil;
   import starling.utils.Pool;
   import starling.utils.SystemUtil;
   import starling.utils.execute;
   
   public class DisplayObject extends EventDispatcher
   {
      
      private static var sAncestors:Vector.<starling.display.DisplayObject> = new Vector.<starling.display.DisplayObject>(0);
      
      private static var sHelperPoint:Point = new Point();
      
      private static var sHelperPoint3D:Vector3D = new Vector3D();
      
      private static var sHelperPointAlt3D:Vector3D = new Vector3D();
      
      private static var sHelperRect:flash.geom.Rectangle = new flash.geom.Rectangle();
      
      private static var sHelperMatrix:Matrix = new Matrix();
      
      private static var sHelperMatrixAlt:Matrix = new Matrix();
      
      private static var sHelperMatrix3D:Matrix3D = new Matrix3D();
      
      private static var sHelperMatrixAlt3D:Matrix3D = new Matrix3D();
      
      private static var sMaskWarningShown:Boolean = false;
       
      
      private var _x:Number;
      
      private var _y:Number;
      
      private var _pivotX:Number;
      
      private var _pivotY:Number;
      
      private var _scaleX:Number;
      
      private var _scaleY:Number;
      
      private var _skewX:Number;
      
      private var _skewY:Number;
      
      private var _rotation:Number;
      
      private var _alpha:Number;
      
      private var _visible:Boolean;
      
      private var _touchable:Boolean;
      
      private var _blendMode:String;
      
      private var _name:String;
      
      private var _useHandCursor:Boolean;
      
      private var _transformationMatrix:Matrix;
      
      private var _transformationMatrix3D:Matrix3D;
      
      private var _transformationChanged:Boolean;
      
      private var _is3D:Boolean;
      
      private var _maskee:starling.display.DisplayObject;
      
      private var _maskInverted:Boolean = false;
      
      internal var _parent:starling.display.DisplayObjectContainer;
      
      internal var _lastParentOrSelfChangeFrameID:uint;
      
      internal var _lastChildChangeFrameID:uint;
      
      internal var _tokenFrameID:uint;
      
      internal var _pushToken:BatchToken;
      
      internal var _popToken:BatchToken;
      
      internal var _hasVisibleArea:Boolean;
      
      internal var _filter:FragmentFilter;
      
      internal var _mask:starling.display.DisplayObject;
      
      public function DisplayObject()
      {
         this._pushToken = new BatchToken();
         this._popToken = new BatchToken();
         super();
         if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.display::DisplayObject")
         {
            throw new AbstractClassError();
         }
         this._x = this._y = this._pivotX = this._pivotY = this._rotation = this._skewX = this._skewY = 0;
         this._scaleX = this._scaleY = this._alpha = 1;
         this._visible = this._touchable = this._hasVisibleArea = true;
         this._blendMode = starling.display.BlendMode.AUTO;
         this._transformationMatrix = new Matrix();
      }
      
      private static function findCommonParent(param1:starling.display.DisplayObject, param2:starling.display.DisplayObject) : starling.display.DisplayObject
      {
         var _loc3_:starling.display.DisplayObject = param1;
         while(_loc3_)
         {
            sAncestors[sAncestors.length] = _loc3_;
            _loc3_ = _loc3_._parent;
         }
         _loc3_ = param2;
         while(Boolean(_loc3_) && sAncestors.indexOf(_loc3_) == -1)
         {
            _loc3_ = _loc3_._parent;
         }
         sAncestors.length = 0;
         if(_loc3_)
         {
            return _loc3_;
         }
         throw new ArgumentError("Object not connected to target");
      }
      
      public function dispose() : void
      {
         if(this._filter)
         {
            this._filter.dispose();
         }
         if(this._mask)
         {
            this._mask.dispose();
         }
         this.removeEventListeners();
         this.mask = null;
      }
      
      public function removeFromParent(param1:Boolean = false) : void
      {
         if(this._parent)
         {
            this._parent.removeChild(this,param1);
         }
         else if(param1)
         {
            this.dispose();
         }
      }
      
      public function getTransformationMatrix(param1:starling.display.DisplayObject, param2:Matrix = null) : Matrix
      {
         var _loc3_:starling.display.DisplayObject = null;
         var _loc4_:starling.display.DisplayObject = null;
         if(param2)
         {
            param2.identity();
         }
         else
         {
            param2 = new Matrix();
         }
         if(param1 == this)
         {
            return param2;
         }
         if(param1 == this._parent || param1 == null && this._parent == null)
         {
            param2.copyFrom(this.transformationMatrix);
            return param2;
         }
         if(param1 == null || param1 == this.base)
         {
            _loc4_ = this;
            while(_loc4_ != param1)
            {
               param2.concat(_loc4_.transformationMatrix);
               _loc4_ = _loc4_._parent;
            }
            return param2;
         }
         if(param1._parent == this)
         {
            param1.getTransformationMatrix(this,param2);
            param2.invert();
            return param2;
         }
         _loc3_ = findCommonParent(this,param1);
         _loc4_ = this;
         while(_loc4_ != _loc3_)
         {
            param2.concat(_loc4_.transformationMatrix);
            _loc4_ = _loc4_._parent;
         }
         if(_loc3_ == param1)
         {
            return param2;
         }
         sHelperMatrix.identity();
         _loc4_ = param1;
         while(_loc4_ != _loc3_)
         {
            sHelperMatrix.concat(_loc4_.transformationMatrix);
            _loc4_ = _loc4_._parent;
         }
         sHelperMatrix.invert();
         param2.concat(sHelperMatrix);
         return param2;
      }
      
      public function getBounds(param1:starling.display.DisplayObject, param2:flash.geom.Rectangle = null) : flash.geom.Rectangle
      {
         throw new AbstractMethodError();
      }
      
      public function hitTest(param1:Point) : starling.display.DisplayObject
      {
         if(!this._visible || !this._touchable)
         {
            return null;
         }
         if(Boolean(this._mask) && !this.hitTestMask(param1))
         {
            return null;
         }
         if(this.getBounds(this,sHelperRect).containsPoint(param1))
         {
            return this;
         }
         return null;
      }
      
      public function hitTestMask(param1:Point) : Boolean
      {
         var _loc2_:Point = null;
         var _loc3_:* = false;
         if(this._mask)
         {
            if(this._mask.stage)
            {
               this.getTransformationMatrix(this._mask,sHelperMatrixAlt);
            }
            else
            {
               sHelperMatrixAlt.copyFrom(this._mask.transformationMatrix);
               sHelperMatrixAlt.invert();
            }
            _loc2_ = param1 == sHelperPoint ? new Point() : sHelperPoint;
            MatrixUtil.transformPoint(sHelperMatrixAlt,param1,_loc2_);
            _loc3_ = this._mask.hitTest(_loc2_) != null;
            return this._maskInverted ? !_loc3_ : _loc3_;
         }
         return true;
      }
      
      public function localToGlobal(param1:Point, param2:Point = null) : Point
      {
         if(this.is3D)
         {
            sHelperPoint3D.setTo(param1.x,param1.y,0);
            return this.local3DToGlobal(sHelperPoint3D,param2);
         }
         this.getTransformationMatrix(this.base,sHelperMatrixAlt);
         return MatrixUtil.transformPoint(sHelperMatrixAlt,param1,param2);
      }
      
      public function globalToLocal(param1:Point, param2:Point = null) : Point
      {
         if(this.is3D)
         {
            this.globalToLocal3D(param1,sHelperPoint3D);
            this.stage.getCameraPosition(this,sHelperPointAlt3D);
            return MathUtil.intersectLineWithXYPlane(sHelperPointAlt3D,sHelperPoint3D,param2);
         }
         this.getTransformationMatrix(this.base,sHelperMatrixAlt);
         sHelperMatrixAlt.invert();
         return MatrixUtil.transformPoint(sHelperMatrixAlt,param1,param2);
      }
      
      public function render(param1:Painter) : void
      {
         throw new AbstractMethodError();
      }
      
      public function alignPivot(param1:String = "center", param2:String = "center") : void
      {
         var _loc3_:flash.geom.Rectangle = this.getBounds(this,sHelperRect);
         if(param1 == Align.LEFT)
         {
            this.pivotX = _loc3_.x;
         }
         else if(param1 == Align.CENTER)
         {
            this.pivotX = _loc3_.x + _loc3_.width / 2;
         }
         else
         {
            if(param1 != Align.RIGHT)
            {
               throw new ArgumentError("Invalid horizontal alignment: " + param1);
            }
            this.pivotX = _loc3_.x + _loc3_.width;
         }
         if(param2 == Align.TOP)
         {
            this.pivotY = _loc3_.y;
         }
         else if(param2 == Align.CENTER)
         {
            this.pivotY = _loc3_.y + _loc3_.height / 2;
         }
         else
         {
            if(param2 != Align.BOTTOM)
            {
               throw new ArgumentError("Invalid vertical alignment: " + param2);
            }
            this.pivotY = _loc3_.y + _loc3_.height;
         }
      }
      
      public function drawToBitmapData(param1:BitmapData = null, param2:uint = 0, param3:Number = 0) : BitmapData
      {
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:flash.geom.Rectangle = null;
         var _loc17_:Number = NaN;
         var _loc4_:Painter = Starling.painter;
         var _loc5_:starling.display.Stage = Starling.current.stage;
         var _loc6_:flash.geom.Rectangle = Starling.current.viewPort;
         var _loc7_:Number = _loc5_.stageWidth;
         var _loc8_:Number = _loc5_.stageHeight;
         var _loc9_:Number = _loc6_.width / _loc7_;
         var _loc10_:Number = _loc6_.height / _loc8_;
         var _loc11_:Number = _loc4_.backBufferScaleFactor;
         var _loc12_:Number = _loc9_ * _loc11_;
         var _loc13_:Number = _loc10_ * _loc11_;
         if(this is starling.display.Stage)
         {
            _loc14_ = _loc6_.x < 0 ? -_loc6_.x / _loc9_ : 0;
            _loc15_ = _loc6_.y < 0 ? -_loc6_.y / _loc10_ : 0;
            param1 ||= new BitmapData(_loc4_.backBufferWidth * _loc11_,_loc4_.backBufferHeight * _loc11_);
         }
         else
         {
            _loc14_ = (_loc16_ = this.getBounds(this._parent,sHelperRect)).x;
            _loc15_ = _loc16_.y;
            param1 ||= new BitmapData(Math.ceil(_loc16_.width * _loc12_),Math.ceil(_loc16_.height * _loc13_));
         }
         param2 = Color.multiply(param2,param3);
         _loc4_.pushState();
         _loc4_.setupContextDefaults();
         _loc4_.state.renderTarget = null;
         _loc4_.state.setModelviewMatricesToIdentity();
         _loc4_.setStateTo(this.transformationMatrix);
         var _loc18_:Number = _loc15_;
         var _loc19_:Number = _loc4_.backBufferWidth / _loc9_;
         var _loc20_:Number = _loc4_.backBufferHeight / _loc10_;
         var _loc21_:Point = Pool.getPoint(0,0);
         var _loc22_:flash.geom.Rectangle = Pool.getRectangle(0,0,_loc4_.backBufferWidth * _loc11_,_loc4_.backBufferHeight * _loc11_);
         while(_loc21_.y < param1.height)
         {
            _loc17_ = _loc14_;
            _loc21_.x = 0;
            while(_loc21_.x < param1.width)
            {
               _loc4_.clear(param2,param3);
               _loc4_.state.setProjectionMatrix(_loc17_,_loc18_,_loc19_,_loc20_,_loc7_,_loc8_,_loc5_.cameraPosition);
               if(this._mask)
               {
                  _loc4_.drawMask(this.mask,this);
               }
               if(this._filter)
               {
                  this._filter.render(_loc4_);
               }
               else
               {
                  this.render(_loc4_);
               }
               if(this._mask)
               {
                  _loc4_.eraseMask(this.mask,this);
               }
               _loc4_.finishMeshBatch();
               execute(_loc4_.context.drawToBitmapData,param1,_loc22_,_loc21_);
               _loc17_ += _loc19_;
               _loc21_.x += _loc19_ * _loc12_;
            }
            _loc18_ += _loc20_;
            _loc21_.y += _loc20_ * _loc13_;
         }
         _loc4_.popState();
         Pool.putRectangle(_loc22_);
         Pool.putPoint(_loc21_);
         return param1;
      }
      
      public function getTransformationMatrix3D(param1:starling.display.DisplayObject, param2:Matrix3D = null) : Matrix3D
      {
         var _loc3_:starling.display.DisplayObject = null;
         var _loc4_:starling.display.DisplayObject = null;
         if(param2)
         {
            param2.identity();
         }
         else
         {
            param2 = new Matrix3D();
         }
         if(param1 == this)
         {
            return param2;
         }
         if(param1 == this._parent || param1 == null && this._parent == null)
         {
            param2.copyFrom(this.transformationMatrix3D);
            return param2;
         }
         if(param1 == null || param1 == this.base)
         {
            _loc4_ = this;
            while(_loc4_ != param1)
            {
               param2.append(_loc4_.transformationMatrix3D);
               _loc4_ = _loc4_._parent;
            }
            return param2;
         }
         if(param1._parent == this)
         {
            param1.getTransformationMatrix3D(this,param2);
            param2.invert();
            return param2;
         }
         _loc3_ = findCommonParent(this,param1);
         _loc4_ = this;
         while(_loc4_ != _loc3_)
         {
            param2.append(_loc4_.transformationMatrix3D);
            _loc4_ = _loc4_._parent;
         }
         if(_loc3_ == param1)
         {
            return param2;
         }
         sHelperMatrix3D.identity();
         _loc4_ = param1;
         while(_loc4_ != _loc3_)
         {
            sHelperMatrix3D.append(_loc4_.transformationMatrix3D);
            _loc4_ = _loc4_._parent;
         }
         sHelperMatrix3D.invert();
         param2.append(sHelperMatrix3D);
         return param2;
      }
      
      public function local3DToGlobal(param1:Vector3D, param2:Point = null) : Point
      {
         var _loc3_:starling.display.Stage = this.stage;
         if(_loc3_ == null)
         {
            throw new IllegalOperationError("Object not connected to stage");
         }
         this.getTransformationMatrix3D(_loc3_,sHelperMatrixAlt3D);
         MatrixUtil.transformPoint3D(sHelperMatrixAlt3D,param1,sHelperPoint3D);
         return MathUtil.intersectLineWithXYPlane(_loc3_.cameraPosition,sHelperPoint3D,param2);
      }
      
      public function globalToLocal3D(param1:Point, param2:Vector3D = null) : Vector3D
      {
         var _loc3_:starling.display.Stage = this.stage;
         if(_loc3_ == null)
         {
            throw new IllegalOperationError("Object not connected to stage");
         }
         this.getTransformationMatrix3D(_loc3_,sHelperMatrixAlt3D);
         sHelperMatrixAlt3D.invert();
         return MatrixUtil.transformCoords3D(sHelperMatrixAlt3D,param1.x,param1.y,0,param2);
      }
      
      starling_internal function setParent(param1:starling.display.DisplayObjectContainer) : void
      {
         var _loc2_:starling.display.DisplayObject = param1;
         while(_loc2_ != this && _loc2_ != null)
         {
            _loc2_ = _loc2_._parent;
         }
         if(_loc2_ == this)
         {
            throw new ArgumentError("An object cannot be added as a child to itself or one " + "of its children (or children\'s children, etc.)");
         }
         this._parent = param1;
      }
      
      internal function setIs3D(param1:Boolean) : void
      {
         this._is3D = param1;
      }
      
      internal function get isMask() : Boolean
      {
         return this._maskee != null;
      }
      
      public function setRequiresRedraw() : void
      {
         var _loc1_:starling.display.DisplayObject = this._parent || this._maskee;
         var _loc2_:int = int(Starling.frameID);
         this._lastParentOrSelfChangeFrameID = _loc2_;
         this._hasVisibleArea = this._alpha != 0 && this._visible && this._maskee == null && this._scaleX != 0 && this._scaleY != 0;
         while(Boolean(_loc1_) && _loc1_._lastChildChangeFrameID != _loc2_)
         {
            _loc1_._lastChildChangeFrameID = _loc2_;
            _loc1_ = _loc1_._parent || _loc1_._maskee;
         }
      }
      
      public function get requiresRedraw() : Boolean
      {
         var _loc1_:uint = Starling.frameID;
         return this._lastParentOrSelfChangeFrameID == _loc1_ || this._lastChildChangeFrameID == _loc1_;
      }
      
      starling_internal function excludeFromCache() : void
      {
         var _loc1_:starling.display.DisplayObject = this;
         var _loc2_:uint = 4294967295;
         while(Boolean(_loc1_) && _loc1_._tokenFrameID != _loc2_)
         {
            _loc1_._tokenFrameID = _loc2_;
            _loc1_ = _loc1_._parent;
         }
      }
      
      starling_internal function setTransformationChanged() : void
      {
         this._transformationChanged = true;
         this.setRequiresRedraw();
      }
      
      starling_internal function updateTransformationMatrices(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number, param9:Number, param10:Matrix, param11:Matrix3D) : void
      {
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         if(param7 == 0 && param8 == 0)
         {
            if(param9 == 0)
            {
               param10.setTo(param5,0,0,param6,param1 - param3 * param5,param2 - param4 * param6);
            }
            else
            {
               _loc12_ = Math.cos(param9);
               _loc13_ = Math.sin(param9);
               _loc14_ = param5 * _loc12_;
               _loc15_ = param5 * _loc13_;
               _loc16_ = param6 * -_loc13_;
               _loc17_ = param6 * _loc12_;
               _loc18_ = param1 - param3 * _loc14_ - param4 * _loc16_;
               _loc19_ = param2 - param3 * _loc15_ - param4 * _loc17_;
               param10.setTo(_loc14_,_loc15_,_loc16_,_loc17_,_loc18_,_loc19_);
            }
         }
         else
         {
            param10.identity();
            param10.scale(param5,param6);
            MatrixUtil.skew(param10,param7,param8);
            param10.rotate(param9);
            param10.translate(param1,param2);
            if(param3 != 0 || param4 != 0)
            {
               param10.tx = param1 - param10.a * param3 - param10.c * param4;
               param10.ty = param2 - param10.b * param3 - param10.d * param4;
            }
         }
         if(param11)
         {
            MatrixUtil.convertTo3D(param10,param11);
         }
      }
      
      override public function dispatchEvent(param1:Event) : void
      {
         if(param1.type == Event.REMOVED_FROM_STAGE && this.stage == null)
         {
            return;
         }
         super.dispatchEvent(param1);
      }
      
      override public function addEventListener(param1:String, param2:Function) : void
      {
         if(param1 == Event.ENTER_FRAME && !hasEventListener(param1))
         {
            this.addEventListener(Event.ADDED_TO_STAGE,this.addEnterFrameListenerToStage);
            this.addEventListener(Event.REMOVED_FROM_STAGE,this.removeEnterFrameListenerFromStage);
            if(this.stage)
            {
               this.addEnterFrameListenerToStage();
            }
         }
         super.addEventListener(param1,param2);
      }
      
      override public function removeEventListener(param1:String, param2:Function) : void
      {
         super.removeEventListener(param1,param2);
         if(param1 == Event.ENTER_FRAME && !hasEventListener(param1))
         {
            this.removeEventListener(Event.ADDED_TO_STAGE,this.addEnterFrameListenerToStage);
            this.removeEventListener(Event.REMOVED_FROM_STAGE,this.removeEnterFrameListenerFromStage);
            this.removeEnterFrameListenerFromStage();
         }
      }
      
      override public function removeEventListeners(param1:String = null) : void
      {
         if((param1 == null || param1 == Event.ENTER_FRAME) && hasEventListener(Event.ENTER_FRAME))
         {
            this.removeEventListener(Event.ADDED_TO_STAGE,this.addEnterFrameListenerToStage);
            this.removeEventListener(Event.REMOVED_FROM_STAGE,this.removeEnterFrameListenerFromStage);
            this.removeEnterFrameListenerFromStage();
         }
         super.removeEventListeners(param1);
      }
      
      private function addEnterFrameListenerToStage() : void
      {
         Starling.current.stage.addEnterFrameListener(this);
      }
      
      private function removeEnterFrameListenerFromStage() : void
      {
         Starling.current.stage.removeEnterFrameListener(this);
      }
      
      public function get transformationMatrix() : Matrix
      {
         if(this._transformationChanged)
         {
            this._transformationChanged = false;
            if(this._transformationMatrix3D == null && this._is3D)
            {
               this._transformationMatrix3D = new Matrix3D();
            }
            this.starling_internal::updateTransformationMatrices(this._x,this._y,this._pivotX,this._pivotY,this._scaleX,this._scaleY,this._skewX,this._skewY,this._rotation,this._transformationMatrix,this._transformationMatrix3D);
         }
         return this._transformationMatrix;
      }
      
      public function set transformationMatrix(param1:Matrix) : void
      {
         var _loc2_:Number = Math.PI / 4;
         this.setRequiresRedraw();
         this._transformationChanged = false;
         this._transformationMatrix.copyFrom(param1);
         this._pivotX = this._pivotY = 0;
         this._x = param1.tx;
         this._y = param1.ty;
         this._skewX = Math.atan(-param1.c / param1.d);
         this._skewY = Math.atan(param1.b / param1.a);
         if(this._skewX != this._skewX)
         {
            this._skewX = 0;
         }
         if(this._skewY != this._skewY)
         {
            this._skewY = 0;
         }
         this._scaleY = this._skewX > -_loc2_ && this._skewX < _loc2_ ? param1.d / Math.cos(this._skewX) : -param1.c / Math.sin(this._skewX);
         this._scaleX = this._skewY > -_loc2_ && this._skewY < _loc2_ ? param1.a / Math.cos(this._skewY) : param1.b / Math.sin(this._skewY);
         if(MathUtil.isEquivalent(this._skewX,this._skewY))
         {
            this._rotation = this._skewX;
            this._skewX = this._skewY = 0;
         }
         else
         {
            this._rotation = 0;
         }
      }
      
      public function get transformationMatrix3D() : Matrix3D
      {
         if(this._transformationMatrix3D == null)
         {
            this._transformationMatrix3D = MatrixUtil.convertTo3D(this._transformationMatrix);
         }
         if(this._transformationChanged)
         {
            this._transformationChanged = false;
            this.starling_internal::updateTransformationMatrices(this._x,this._y,this._pivotX,this._pivotY,this._scaleX,this._scaleY,this._skewX,this._skewY,this._rotation,this._transformationMatrix,this._transformationMatrix3D);
         }
         return this._transformationMatrix3D;
      }
      
      public function get is3D() : Boolean
      {
         return this._is3D;
      }
      
      public function get useHandCursor() : Boolean
      {
         return this._useHandCursor;
      }
      
      public function set useHandCursor(param1:Boolean) : void
      {
         if(param1 == this._useHandCursor)
         {
            return;
         }
         this._useHandCursor = param1;
         if(this._useHandCursor)
         {
            this.addEventListener(TouchEvent.TOUCH,this.onTouch);
         }
         else
         {
            this.removeEventListener(TouchEvent.TOUCH,this.onTouch);
         }
      }
      
      private function onTouch(param1:TouchEvent) : void
      {
         Mouse.cursor = param1.interactsWith(this) ? MouseCursor.BUTTON : MouseCursor.AUTO;
      }
      
      public function get bounds() : flash.geom.Rectangle
      {
         return this.getBounds(this._parent);
      }
      
      public function get width() : Number
      {
         return this.getBounds(this._parent,sHelperRect).width;
      }
      
      public function set width(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:* = this._scaleX != this._scaleX;
         var _loc4_:Boolean;
         if((_loc4_ = this._scaleX < 1e-8 && this._scaleX > -1e-8) || _loc3_)
         {
            this.scaleX = 1;
            _loc2_ = this.width;
         }
         else
         {
            _loc2_ = Math.abs(this.width / this._scaleX);
         }
         if(_loc2_)
         {
            this.scaleX = param1 / _loc2_;
         }
      }
      
      public function get height() : Number
      {
         return this.getBounds(this._parent,sHelperRect).height;
      }
      
      public function set height(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:* = this._scaleY != this._scaleY;
         var _loc4_:Boolean;
         if((_loc4_ = this._scaleY < 1e-8 && this._scaleY > -1e-8) || _loc3_)
         {
            this.scaleY = 1;
            _loc2_ = this.height;
         }
         else
         {
            _loc2_ = Math.abs(this.height / this._scaleY);
         }
         if(_loc2_)
         {
            this.scaleY = param1 / _loc2_;
         }
      }
      
      public function get x() : Number
      {
         return this._x;
      }
      
      public function set x(param1:Number) : void
      {
         if(this._x != param1)
         {
            this._x = param1;
            this.starling_internal::setTransformationChanged();
         }
      }
      
      public function get y() : Number
      {
         return this._y;
      }
      
      public function set y(param1:Number) : void
      {
         if(this._y != param1)
         {
            this._y = param1;
            this.starling_internal::setTransformationChanged();
         }
      }
      
      public function get pivotX() : Number
      {
         return this._pivotX;
      }
      
      public function set pivotX(param1:Number) : void
      {
         if(this._pivotX != param1)
         {
            this._pivotX = param1;
            this.starling_internal::setTransformationChanged();
         }
      }
      
      public function get pivotY() : Number
      {
         return this._pivotY;
      }
      
      public function set pivotY(param1:Number) : void
      {
         if(this._pivotY != param1)
         {
            this._pivotY = param1;
            this.starling_internal::setTransformationChanged();
         }
      }
      
      public function get scaleX() : Number
      {
         return this._scaleX;
      }
      
      public function set scaleX(param1:Number) : void
      {
         if(this._scaleX != param1)
         {
            this._scaleX = param1;
            this.starling_internal::setTransformationChanged();
         }
      }
      
      public function get scaleY() : Number
      {
         return this._scaleY;
      }
      
      public function set scaleY(param1:Number) : void
      {
         if(this._scaleY != param1)
         {
            this._scaleY = param1;
            this.starling_internal::setTransformationChanged();
         }
      }
      
      public function get scale() : Number
      {
         return this.scaleX;
      }
      
      public function set scale(param1:Number) : void
      {
         this.scaleX = this.scaleY = param1;
      }
      
      public function get skewX() : Number
      {
         return this._skewX;
      }
      
      public function set skewX(param1:Number) : void
      {
         param1 = MathUtil.normalizeAngle(param1);
         if(this._skewX != param1)
         {
            this._skewX = param1;
            this.starling_internal::setTransformationChanged();
         }
      }
      
      public function get skewY() : Number
      {
         return this._skewY;
      }
      
      public function set skewY(param1:Number) : void
      {
         param1 = MathUtil.normalizeAngle(param1);
         if(this._skewY != param1)
         {
            this._skewY = param1;
            this.starling_internal::setTransformationChanged();
         }
      }
      
      public function get rotation() : Number
      {
         return this._rotation;
      }
      
      public function set rotation(param1:Number) : void
      {
         param1 = MathUtil.normalizeAngle(param1);
         if(this._rotation != param1)
         {
            this._rotation = param1;
            this.starling_internal::setTransformationChanged();
         }
      }
      
      internal function get isRotated() : Boolean
      {
         return this._rotation != 0 || this._skewX != 0 || this._skewY != 0;
      }
      
      public function get alpha() : Number
      {
         return this._alpha;
      }
      
      public function set alpha(param1:Number) : void
      {
         if(param1 != this._alpha)
         {
            this._alpha = param1 < 0 ? 0 : (param1 > 1 ? 1 : param1);
            this.setRequiresRedraw();
         }
      }
      
      public function get visible() : Boolean
      {
         return this._visible;
      }
      
      public function set visible(param1:Boolean) : void
      {
         if(param1 != this._visible)
         {
            this._visible = param1;
            this.setRequiresRedraw();
         }
      }
      
      public function get touchable() : Boolean
      {
         return this._touchable;
      }
      
      public function set touchable(param1:Boolean) : void
      {
         this._touchable = param1;
      }
      
      public function get blendMode() : String
      {
         return this._blendMode;
      }
      
      public function set blendMode(param1:String) : void
      {
         if(param1 != this._blendMode)
         {
            this._blendMode = param1;
            this.setRequiresRedraw();
         }
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set name(param1:String) : void
      {
         this._name = param1;
      }
      
      public function get filter() : FragmentFilter
      {
         return this._filter;
      }
      
      public function set filter(param1:FragmentFilter) : void
      {
         if(param1 != this._filter)
         {
            if(this._filter)
            {
               this._filter.starling_internal::setTarget(null);
            }
            if(param1)
            {
               param1.starling_internal::setTarget(this);
            }
            this._filter = param1;
            this.setRequiresRedraw();
         }
      }
      
      public function get mask() : starling.display.DisplayObject
      {
         return this._mask;
      }
      
      public function set mask(param1:starling.display.DisplayObject) : void
      {
         if(this._mask != param1)
         {
            if(!sMaskWarningShown)
            {
               if(!SystemUtil.supportsDepthAndStencil)
               {
                  trace("[Starling] Full mask support requires \'depthAndStencil\'" + " to be enabled in the application descriptor.");
               }
               sMaskWarningShown = true;
            }
            if(this._mask)
            {
               this._mask._maskee = null;
            }
            if(param1)
            {
               param1._maskee = this;
               param1._hasVisibleArea = false;
            }
            this._mask = param1;
            this.setRequiresRedraw();
         }
      }
      
      public function get maskInverted() : Boolean
      {
         return this._maskInverted;
      }
      
      public function set maskInverted(param1:Boolean) : void
      {
         this._maskInverted = param1;
      }
      
      public function get parent() : starling.display.DisplayObjectContainer
      {
         return this._parent;
      }
      
      public function get base() : starling.display.DisplayObject
      {
         var _loc1_:starling.display.DisplayObject = this;
         while(_loc1_._parent)
         {
            _loc1_ = _loc1_._parent;
         }
         return _loc1_;
      }
      
      public function get root() : starling.display.DisplayObject
      {
         var _loc1_:starling.display.DisplayObject = this;
         while(_loc1_._parent)
         {
            if(_loc1_._parent is starling.display.Stage)
            {
               return _loc1_;
            }
            _loc1_ = _loc1_.parent;
         }
         return null;
      }
      
      public function get stage() : starling.display.Stage
      {
         return this.base as starling.display.Stage;
      }
   }
}
