package starling.textures
{
   import flash.display3D.textures.TextureBase;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import starling.core.starling_internal;
   
   public class SubTexture extends Texture
   {
      
      private static const E:Number = 0.000001;
       
      
      private var _parent:Texture;
      
      private var _ownsParent:Boolean;
      
      private var _region:Rectangle;
      
      private var _frame:Rectangle;
      
      private var _rotated:Boolean;
      
      private var _width:Number;
      
      private var _height:Number;
      
      private var _scale:Number;
      
      private var _transformationMatrix:Matrix;
      
      private var _transformationMatrixToRoot:Matrix;
      
      public function SubTexture(param1:Texture, param2:Rectangle = null, param3:Boolean = false, param4:Rectangle = null, param5:Boolean = false, param6:Number = 1)
      {
         super();
         starling_internal::setTo(param1,param2,param3,param4,param5,param6);
      }
      
      starling_internal function setTo(param1:Texture, param2:Rectangle = null, param3:Boolean = false, param4:Rectangle = null, param5:Boolean = false, param6:Number = 1) : void
      {
         if(this._region == null)
         {
            this._region = new Rectangle();
         }
         if(param2)
         {
            this._region.copyFrom(param2);
         }
         else
         {
            this._region.setTo(0,0,param1.width,param1.height);
         }
         if(param4)
         {
            if(this._frame)
            {
               this._frame.copyFrom(param4);
            }
            else
            {
               this._frame = param4.clone();
            }
         }
         else
         {
            this._frame = null;
         }
         this._parent = param1;
         this._ownsParent = param3;
         this._rotated = param5;
         this._width = (param5 ? this._region.height : this._region.width) / param6;
         this._height = (param5 ? this._region.width : this._region.height) / param6;
         this._scale = this._parent.scale * param6;
         if(Capabilities.isDebugger && this._frame && (this._frame.x > 0 || this._frame.y > 0 || this._frame.right + E < this._width || this._frame.bottom + E < this._height))
         {
            trace("[Starling] Warning: frames inside the texture\'s region are unsupported.");
         }
         this.updateMatrices();
      }
      
      private function updateMatrices() : void
      {
         if(this._transformationMatrix)
         {
            this._transformationMatrix.identity();
         }
         else
         {
            this._transformationMatrix = new Matrix();
         }
         if(this._transformationMatrixToRoot)
         {
            this._transformationMatrixToRoot.identity();
         }
         else
         {
            this._transformationMatrixToRoot = new Matrix();
         }
         if(this._rotated)
         {
            this._transformationMatrix.translate(0,-1);
            this._transformationMatrix.rotate(Math.PI / 2);
         }
         this._transformationMatrix.scale(this._region.width / this._parent.width,this._region.height / this._parent.height);
         this._transformationMatrix.translate(this._region.x / this._parent.width,this._region.y / this._parent.height);
         var _loc1_:SubTexture = this;
         while(_loc1_)
         {
            this._transformationMatrixToRoot.concat(_loc1_._transformationMatrix);
            _loc1_ = _loc1_.parent as SubTexture;
         }
      }
      
      override public function dispose() : void
      {
         if(this._ownsParent)
         {
            this._parent.dispose();
         }
         super.dispose();
      }
      
      public function get parent() : Texture
      {
         return this._parent;
      }
      
      public function get ownsParent() : Boolean
      {
         return this._ownsParent;
      }
      
      public function get rotated() : Boolean
      {
         return this._rotated;
      }
      
      public function get region() : Rectangle
      {
         return this._region;
      }
      
      override public function get transformationMatrix() : Matrix
      {
         return this._transformationMatrix;
      }
      
      override public function get transformationMatrixToRoot() : Matrix
      {
         return this._transformationMatrixToRoot;
      }
      
      override public function get base() : TextureBase
      {
         return this._parent.base;
      }
      
      override public function get root() : ConcreteTexture
      {
         return this._parent.root;
      }
      
      override public function get format() : String
      {
         return this._parent.format;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function get nativeWidth() : Number
      {
         return this._width * this._scale;
      }
      
      override public function get nativeHeight() : Number
      {
         return this._height * this._scale;
      }
      
      override public function get mipMapping() : Boolean
      {
         return this._parent.mipMapping;
      }
      
      override public function get premultipliedAlpha() : Boolean
      {
         return this._parent.premultipliedAlpha;
      }
      
      override public function get scale() : Number
      {
         return this._scale;
      }
      
      override public function get frame() : Rectangle
      {
         return this._frame;
      }
   }
}
