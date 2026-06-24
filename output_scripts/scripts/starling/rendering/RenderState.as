package starling.rendering
{
   import flash.display3D.Context3DCompareMode;
   import flash.display3D.Context3DTriangleFace;
   import flash.display3D.textures.TextureBase;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import starling.display.BlendMode;
   import starling.textures.Texture;
   import starling.utils.MathUtil;
   import starling.utils.MatrixUtil;
   import starling.utils.Pool;
   import starling.utils.RectangleUtil;
   
   public class RenderState
   {
      
      private static const CULLING_VALUES:Vector.<String> = new <String>[Context3DTriangleFace.NONE,Context3DTriangleFace.FRONT,Context3DTriangleFace.BACK,Context3DTriangleFace.FRONT_AND_BACK];
      
      private static const COMPARE_VALUES:Vector.<String> = new <String>[Context3DCompareMode.ALWAYS,Context3DCompareMode.NEVER,Context3DCompareMode.LESS,Context3DCompareMode.LESS_EQUAL,Context3DCompareMode.EQUAL,Context3DCompareMode.GREATER_EQUAL,Context3DCompareMode.GREATER,Context3DCompareMode.NOT_EQUAL];
      
      private static var sMatrix3D:Matrix3D = new Matrix3D();
      
      private static var sProjectionMatrix3DRev:uint = 0;
       
      
      internal var _alpha:Number;
      
      internal var _blendMode:String;
      
      internal var _modelviewMatrix:Matrix;
      
      private var _miscOptions:uint;
      
      private var _clipRect:flash.geom.Rectangle;
      
      private var _renderTarget:Texture;
      
      private var _onDrawRequired:Function;
      
      private var _modelviewMatrix3D:Matrix3D;
      
      private var _projectionMatrix3D:Matrix3D;
      
      private var _projectionMatrix3DRev:uint;
      
      private var _mvpMatrix3D:Matrix3D;
      
      public function RenderState()
      {
         super();
         this.reset();
      }
      
      public function copyFrom(param1:starling.rendering.RenderState) : void
      {
         var _loc2_:TextureBase = null;
         var _loc3_:TextureBase = null;
         var _loc4_:* = false;
         var _loc5_:* = false;
         var _loc6_:* = false;
         var _loc7_:Boolean = false;
         if(this._onDrawRequired != null)
         {
            _loc2_ = !!this._renderTarget ? this._renderTarget.base : null;
            _loc3_ = !!param1._renderTarget ? param1._renderTarget.base : null;
            _loc4_ = (this._miscOptions & 3840) != (param1._miscOptions & 3840);
            _loc5_ = (this._miscOptions & 61440) != (param1._miscOptions & 61440);
            _loc6_ = (this._miscOptions & 983040) != (param1._miscOptions & 983040);
            _loc7_ = Boolean(this._clipRect) || Boolean(param1._clipRect) ? !RectangleUtil.compare(this._clipRect,param1._clipRect) : false;
            if(this._blendMode != param1._blendMode || _loc2_ != _loc3_ || _loc7_ || _loc4_ || _loc5_ || _loc6_)
            {
               this._onDrawRequired();
            }
         }
         this._alpha = param1._alpha;
         this._blendMode = param1._blendMode;
         this._renderTarget = param1._renderTarget;
         this._miscOptions = param1._miscOptions;
         this._modelviewMatrix.copyFrom(param1._modelviewMatrix);
         if(this._projectionMatrix3DRev != param1._projectionMatrix3DRev)
         {
            this._projectionMatrix3DRev = param1._projectionMatrix3DRev;
            this._projectionMatrix3D.copyFrom(param1._projectionMatrix3D);
         }
         if(Boolean(this._modelviewMatrix3D) || Boolean(param1._modelviewMatrix3D))
         {
            this.modelviewMatrix3D = param1._modelviewMatrix3D;
         }
         if(Boolean(this._clipRect) || Boolean(param1._clipRect))
         {
            this.clipRect = param1._clipRect;
         }
      }
      
      public function reset() : void
      {
         this.alpha = 1;
         this.blendMode = BlendMode.NORMAL;
         this.culling = Context3DTriangleFace.NONE;
         this.depthMask = false;
         this.depthTest = Context3DCompareMode.ALWAYS;
         this.modelviewMatrix3D = null;
         this.renderTarget = null;
         this.clipRect = null;
         this._projectionMatrix3DRev = 0;
         if(this._modelviewMatrix)
         {
            this._modelviewMatrix.identity();
         }
         else
         {
            this._modelviewMatrix = new Matrix();
         }
         if(this._projectionMatrix3D)
         {
            this._projectionMatrix3D.identity();
         }
         else
         {
            this._projectionMatrix3D = new Matrix3D();
         }
         if(this._mvpMatrix3D == null)
         {
            this._mvpMatrix3D = new Matrix3D();
         }
      }
      
      public function transformModelviewMatrix(param1:Matrix) : void
      {
         MatrixUtil.prependMatrix(this._modelviewMatrix,param1);
      }
      
      public function transformModelviewMatrix3D(param1:Matrix3D) : void
      {
         if(this._modelviewMatrix3D == null)
         {
            this._modelviewMatrix3D = Pool.getMatrix3D();
         }
         this._modelviewMatrix3D.prepend(MatrixUtil.convertTo3D(this._modelviewMatrix,sMatrix3D));
         this._modelviewMatrix3D.prepend(param1);
         this._modelviewMatrix.identity();
      }
      
      public function setProjectionMatrix(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number = 0, param6:Number = 0, param7:Vector3D = null) : void
      {
         this._projectionMatrix3DRev = ++sProjectionMatrix3DRev;
         MatrixUtil.createPerspectiveProjectionMatrix(param1,param2,param3,param4,param5,param6,param7,this._projectionMatrix3D);
      }
      
      public function setProjectionMatrixChanged() : void
      {
         this._projectionMatrix3DRev = ++sProjectionMatrix3DRev;
      }
      
      public function setModelviewMatricesToIdentity() : void
      {
         this._modelviewMatrix.identity();
         if(this._modelviewMatrix3D)
         {
            this._modelviewMatrix3D.identity();
         }
      }
      
      public function get modelviewMatrix() : Matrix
      {
         return this._modelviewMatrix;
      }
      
      public function set modelviewMatrix(param1:Matrix) : void
      {
         this._modelviewMatrix.copyFrom(param1);
      }
      
      public function get modelviewMatrix3D() : Matrix3D
      {
         return this._modelviewMatrix3D;
      }
      
      public function set modelviewMatrix3D(param1:Matrix3D) : void
      {
         if(param1)
         {
            if(this._modelviewMatrix3D == null)
            {
               this._modelviewMatrix3D = Pool.getMatrix3D(false);
            }
            this._modelviewMatrix3D.copyFrom(param1);
         }
         else if(this._modelviewMatrix3D)
         {
            Pool.putMatrix3D(this._modelviewMatrix3D);
            this._modelviewMatrix3D = null;
         }
      }
      
      public function get projectionMatrix3D() : Matrix3D
      {
         return this._projectionMatrix3D;
      }
      
      public function set projectionMatrix3D(param1:Matrix3D) : void
      {
         this.setProjectionMatrixChanged();
         this._projectionMatrix3D.copyFrom(param1);
      }
      
      public function get mvpMatrix3D() : Matrix3D
      {
         this._mvpMatrix3D.copyFrom(this._projectionMatrix3D);
         if(this._modelviewMatrix3D)
         {
            this._mvpMatrix3D.prepend(this._modelviewMatrix3D);
         }
         this._mvpMatrix3D.prepend(MatrixUtil.convertTo3D(this._modelviewMatrix,sMatrix3D));
         return this._mvpMatrix3D;
      }
      
      public function setRenderTarget(param1:Texture, param2:Boolean = true, param3:int = 0) : void
      {
         var _loc4_:TextureBase = !!this._renderTarget ? this._renderTarget.base : null;
         var _loc5_:TextureBase = !!param1 ? param1.base : null;
         var _loc6_:uint;
         var _loc7_:* = (_loc6_ = uint(MathUtil.min(param3,15) | uint(param2) << 4)) != (this._miscOptions & 255);
         if(_loc4_ != _loc5_ || _loc7_)
         {
            if(this._onDrawRequired != null)
            {
               this._onDrawRequired();
            }
            this._renderTarget = param1;
            this._miscOptions = this._miscOptions & 4294967040 | _loc6_;
         }
      }
      
      public function get alpha() : Number
      {
         return this._alpha;
      }
      
      public function set alpha(param1:Number) : void
      {
         this._alpha = param1;
      }
      
      public function get blendMode() : String
      {
         return this._blendMode;
      }
      
      public function set blendMode(param1:String) : void
      {
         if(param1 != BlendMode.AUTO && this._blendMode != param1)
         {
            if(this._onDrawRequired != null)
            {
               this._onDrawRequired();
            }
            this._blendMode = param1;
         }
      }
      
      public function get renderTarget() : Texture
      {
         return this._renderTarget;
      }
      
      public function set renderTarget(param1:Texture) : void
      {
         this.setRenderTarget(param1);
      }
      
      internal function get renderTargetBase() : TextureBase
      {
         return !!this._renderTarget ? this._renderTarget.base : null;
      }
      
      internal function get renderTargetOptions() : uint
      {
         return this._miscOptions & 255;
      }
      
      public function get culling() : String
      {
         var _loc1_:* = (this._miscOptions & 3840) >> 8;
         return CULLING_VALUES[_loc1_];
      }
      
      public function set culling(param1:String) : void
      {
         var _loc2_:int = 0;
         if(this.culling != param1)
         {
            if(this._onDrawRequired != null)
            {
               this._onDrawRequired();
            }
            _loc2_ = CULLING_VALUES.indexOf(param1);
            if(_loc2_ == -1)
            {
               throw new ArgumentError("Invalid culling mode");
            }
            this._miscOptions = this._miscOptions & 4294963455 | _loc2_ << 8;
         }
      }
      
      public function get depthMask() : Boolean
      {
         return (this._miscOptions & 61440) != 0;
      }
      
      public function set depthMask(param1:Boolean) : void
      {
         if(this.depthMask != param1)
         {
            if(this._onDrawRequired != null)
            {
               this._onDrawRequired();
            }
            this._miscOptions = this._miscOptions & 4294905855 | uint(param1) << 12;
         }
      }
      
      public function get depthTest() : String
      {
         var _loc1_:* = (this._miscOptions & 983040) >> 16;
         return COMPARE_VALUES[_loc1_];
      }
      
      public function set depthTest(param1:String) : void
      {
         var _loc2_:int = 0;
         if(this.depthTest != param1)
         {
            if(this._onDrawRequired != null)
            {
               this._onDrawRequired();
            }
            _loc2_ = COMPARE_VALUES.indexOf(param1);
            if(_loc2_ == -1)
            {
               throw new ArgumentError("Invalid compare mode");
            }
            this._miscOptions = this._miscOptions & 4293984255 | _loc2_ << 16;
         }
      }
      
      public function get clipRect() : flash.geom.Rectangle
      {
         return this._clipRect;
      }
      
      public function set clipRect(param1:flash.geom.Rectangle) : void
      {
         if(!RectangleUtil.compare(this._clipRect,param1))
         {
            if(this._onDrawRequired != null)
            {
               this._onDrawRequired();
            }
            if(param1)
            {
               if(this._clipRect == null)
               {
                  this._clipRect = Pool.getRectangle();
               }
               this._clipRect.copyFrom(param1);
            }
            else if(this._clipRect)
            {
               Pool.putRectangle(this._clipRect);
               this._clipRect = null;
            }
         }
      }
      
      public function get renderTargetAntiAlias() : int
      {
         return this._miscOptions & 15;
      }
      
      public function get renderTargetSupportsDepthAndStencil() : Boolean
      {
         return (this._miscOptions & 240) != 0;
      }
      
      public function get is3D() : Boolean
      {
         return this._modelviewMatrix3D != null;
      }
      
      internal function get onDrawRequired() : Function
      {
         return this._onDrawRequired;
      }
      
      internal function set onDrawRequired(param1:Function) : void
      {
         this._onDrawRequired = param1;
      }
   }
}
