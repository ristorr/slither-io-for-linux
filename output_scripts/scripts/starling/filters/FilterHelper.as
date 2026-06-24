package starling.filters
{
   import flash.display3D.Context3DProfile;
   import flash.geom.Matrix3D;
   import flash.geom.Rectangle;
   import starling.core.Starling;
   import starling.core.starling_internal;
   import starling.display.DisplayObject;
   import starling.textures.SubTexture;
   import starling.textures.Texture;
   import starling.utils.MathUtil;
   import starling.utils.Pool;
   
   internal class FilterHelper implements starling.filters.IFilterHelper
   {
       
      
      private var _width:Number;
      
      private var _height:Number;
      
      private var _nativeWidth:int;
      
      private var _nativeHeight:int;
      
      private var _pool:Vector.<Texture>;
      
      private var _usePotTextures:Boolean;
      
      private var _textureFormat:String;
      
      private var _preferredScale:Number;
      
      private var _scale:Number;
      
      private var _sizeStep:int;
      
      private var _numPasses:int;
      
      private var _projectionMatrix:Matrix3D;
      
      private var _renderTarget:Texture;
      
      private var _targetBounds:flash.geom.Rectangle;
      
      private var _target:DisplayObject;
      
      private var _clipRect:flash.geom.Rectangle;
      
      private var sRegion:flash.geom.Rectangle;
      
      public function FilterHelper(param1:String = "bgra")
      {
         this.sRegion = new flash.geom.Rectangle();
         super();
         this._usePotTextures = Starling.current.profile == Context3DProfile.BASELINE_CONSTRAINED;
         this._preferredScale = Starling.contentScaleFactor;
         this._textureFormat = param1;
         this._sizeStep = 64;
         this._pool = new Vector.<Texture>(0);
         this._projectionMatrix = new Matrix3D();
         this._targetBounds = new flash.geom.Rectangle();
         this.setSize(this._sizeStep,this._sizeStep);
      }
      
      public function dispose() : void
      {
         Pool.putRectangle(this._clipRect);
         this._clipRect = null;
         this.purge();
      }
      
      public function start(param1:int, param2:Boolean) : void
      {
         this._numPasses = param2 ? param1 : -1;
      }
      
      public function getTexture(param1:Number = 1) : Texture
      {
         var _loc2_:Texture = null;
         var _loc3_:SubTexture = null;
         if(this._numPasses >= 0)
         {
            if(this._numPasses-- == 0)
            {
               return null;
            }
         }
         if(this._pool.length)
         {
            _loc2_ = this._pool.pop();
         }
         else
         {
            _loc2_ = Texture.empty(this._nativeWidth / this._scale,this._nativeHeight / this._scale,true,false,true,this._scale,this._textureFormat);
         }
         if(!MathUtil.isEquivalent(_loc2_.width,this._width,0.1) || !MathUtil.isEquivalent(_loc2_.height,this._height,0.1) || !MathUtil.isEquivalent(_loc2_.scale,this._scale * param1))
         {
            this.sRegion.setTo(0,0,this._width * param1,this._height * param1);
            _loc3_ = _loc2_ as SubTexture;
            if(_loc3_)
            {
               _loc3_.starling_internal::setTo(_loc2_.root,this.sRegion,true,null,false,param1);
            }
            else
            {
               _loc2_ = new SubTexture(_loc2_.root,this.sRegion,true,null,false,param1);
            }
         }
         _loc2_.root.clear();
         return _loc2_;
      }
      
      public function putTexture(param1:Texture) : void
      {
         if(param1)
         {
            if(param1.root.nativeWidth == this._nativeWidth && param1.root.nativeHeight == this._nativeHeight)
            {
               this._pool.insertAt(this._pool.length,param1);
            }
            else
            {
               param1.dispose();
            }
         }
      }
      
      public function purge() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = int(this._pool.length);
         while(_loc1_ < _loc2_)
         {
            this._pool[_loc1_].dispose();
            _loc1_++;
         }
         this._pool.length = 0;
      }
      
      private function setSize(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = this._preferredScale;
         var _loc5_:int = Texture.getMaxSize(this._textureFormat);
         var _loc6_:int = this.getNativeSize(param1,_loc4_);
         var _loc7_:int = this.getNativeSize(param2,_loc4_);
         if(_loc6_ > _loc5_ || _loc7_ > _loc5_)
         {
            _loc3_ = _loc5_ / Math.max(_loc6_,_loc7_);
            _loc6_ *= _loc3_;
            _loc7_ *= _loc3_;
            _loc4_ *= _loc3_;
         }
         if(this._nativeWidth != _loc6_ || this._nativeHeight != _loc7_ || this._scale != _loc4_)
         {
            this.purge();
            this._scale = _loc4_;
            this._nativeWidth = _loc6_;
            this._nativeHeight = _loc7_;
         }
         this._width = param1;
         this._height = param2;
      }
      
      private function getNativeSize(param1:Number, param2:Number) : int
      {
         var _loc3_:Number = param1 * param2;
         if(this._usePotTextures)
         {
            return _loc3_ > this._sizeStep ? MathUtil.getNextPowerOfTwo(_loc3_) : this._sizeStep;
         }
         return Math.ceil(_loc3_ / this._sizeStep) * this._sizeStep;
      }
      
      public function get projectionMatrix3D() : Matrix3D
      {
         return this._projectionMatrix;
      }
      
      public function set projectionMatrix3D(param1:Matrix3D) : void
      {
         this._projectionMatrix.copyFrom(param1);
      }
      
      public function get renderTarget() : Texture
      {
         return this._renderTarget;
      }
      
      public function set renderTarget(param1:Texture) : void
      {
         this._renderTarget = param1;
      }
      
      public function get clipRect() : flash.geom.Rectangle
      {
         return this._clipRect;
      }
      
      public function set clipRect(param1:flash.geom.Rectangle) : void
      {
         if(param1)
         {
            if(this._clipRect)
            {
               this._clipRect.copyFrom(param1);
            }
            else
            {
               this._clipRect = Pool.getRectangle(param1.x,param1.y,param1.width,param1.height);
            }
         }
         else if(this._clipRect)
         {
            Pool.putRectangle(this._clipRect);
            this._clipRect = null;
         }
      }
      
      public function get targetBounds() : flash.geom.Rectangle
      {
         return this._targetBounds;
      }
      
      public function set targetBounds(param1:flash.geom.Rectangle) : void
      {
         this._targetBounds.copyFrom(param1);
         this.setSize(param1.width,param1.height);
      }
      
      public function get target() : DisplayObject
      {
         return this._target;
      }
      
      public function set target(param1:DisplayObject) : void
      {
         this._target = param1;
      }
      
      public function get textureScale() : Number
      {
         return this._preferredScale;
      }
      
      public function set textureScale(param1:Number) : void
      {
         this._preferredScale = param1 > 0 ? param1 : Starling.contentScaleFactor;
      }
      
      public function get textureFormat() : String
      {
         return this._textureFormat;
      }
      
      public function set textureFormat(param1:String) : void
      {
         this._textureFormat = param1;
      }
   }
}
