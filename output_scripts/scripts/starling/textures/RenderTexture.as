package starling.textures
{
   import flash.display3D.Context3DCompareMode;
   import flash.display3D.Context3DTriangleFace;
   import flash.display3D.textures.TextureBase;
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import starling.core.Starling;
   import starling.display.BlendMode;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.filters.FragmentFilter;
   import starling.rendering.Painter;
   import starling.rendering.RenderState;
   import starling.utils.execute;
   
   public class RenderTexture extends starling.textures.SubTexture
   {
      
      private static const USE_DOUBLE_BUFFERING_DATA_NAME:String = "starling.textures.RenderTexture.useDoubleBuffering";
      
      private static var sClipRect:flash.geom.Rectangle = new flash.geom.Rectangle();
       
      
      private var _activeTexture:starling.textures.Texture;
      
      private var _bufferTexture:starling.textures.Texture;
      
      private var _helperImage:Image;
      
      private var _drawing:Boolean;
      
      private var _bufferReady:Boolean;
      
      private var _isPersistent:Boolean;
      
      public function RenderTexture(param1:int, param2:int, param3:Boolean = true, param4:Number = -1, param5:String = "bgra", param6:Boolean = false)
      {
         this._isPersistent = param3;
         this._activeTexture = starling.textures.Texture.empty(param1,param2,true,false,true,param4,param5,param6);
         this._activeTexture.root.onRestore = this._activeTexture.root.clear;
         super(this._activeTexture,new flash.geom.Rectangle(0,0,param1,param2),true,null,false);
         if(param3 && useDoubleBuffering)
         {
            this._bufferTexture = starling.textures.Texture.empty(param1,param2,true,false,true,param4,param5,param6);
            this._bufferTexture.root.onRestore = this._bufferTexture.root.clear;
            this._helperImage = new Image(this._bufferTexture);
            this._helperImage.textureSmoothing = starling.textures.TextureSmoothing.NONE;
         }
      }
      
      public static function get useDoubleBuffering() : Boolean
      {
         var _loc1_:Painter = null;
         var _loc2_:Dictionary = null;
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         if(Starling.current)
         {
            _loc1_ = Starling.painter;
            _loc2_ = _loc1_.sharedData;
            if(USE_DOUBLE_BUFFERING_DATA_NAME in _loc2_)
            {
               return _loc2_[USE_DOUBLE_BUFFERING_DATA_NAME];
            }
            _loc3_ = !!_loc1_.profile ? _loc1_.profile : "baseline";
            _loc4_ = _loc3_ == "baseline" || _loc3_ == "baselineConstrained";
            _loc2_[USE_DOUBLE_BUFFERING_DATA_NAME] = _loc4_;
            return _loc4_;
         }
         return false;
      }
      
      public static function set useDoubleBuffering(param1:Boolean) : void
      {
         if(Starling.current == null)
         {
            throw new IllegalOperationError("Starling not yet initialized");
         }
         Starling.painter.sharedData[USE_DOUBLE_BUFFERING_DATA_NAME] = param1;
      }
      
      override public function dispose() : void
      {
         if(this._helperImage)
         {
            this._helperImage.dispose();
         }
         if(parent != this._bufferTexture && Boolean(this._bufferTexture))
         {
            this._bufferTexture.dispose();
         }
         if(parent != this._activeTexture)
         {
            this._activeTexture.dispose();
         }
         super.dispose();
      }
      
      public function draw(param1:DisplayObject, param2:Matrix = null, param3:Number = 1, param4:int = 0, param5:Vector3D = null) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(this._drawing)
         {
            this.render(param1,param2,param3);
         }
         else
         {
            this.renderBundled(this.render,param1,param2,param3,param4,param5);
         }
      }
      
      public function drawBundled(param1:Function, param2:int = 0, param3:Vector3D = null) : void
      {
         this.renderBundled(param1,null,null,1,param2,param3);
      }
      
      private function render(param1:DisplayObject, param2:Matrix = null, param3:Number = 1) : void
      {
         var _loc4_:Painter;
         var _loc5_:RenderState = (_loc4_ = Starling.painter).state;
         var _loc6_:Boolean = _loc4_.cacheEnabled;
         var _loc7_:FragmentFilter = param1.filter;
         var _loc8_:DisplayObject = param1.mask;
         _loc4_.cacheEnabled = false;
         _loc4_.pushState();
         _loc5_.alpha = param1.alpha * param3;
         _loc5_.setModelviewMatricesToIdentity();
         _loc5_.blendMode = param1.blendMode == BlendMode.AUTO ? BlendMode.NORMAL : param1.blendMode;
         if(param2)
         {
            _loc5_.transformModelviewMatrix(param2);
         }
         else
         {
            _loc5_.transformModelviewMatrix(param1.transformationMatrix);
         }
         if(_loc8_)
         {
            _loc4_.drawMask(_loc8_,param1);
         }
         if(_loc7_)
         {
            _loc7_.render(_loc4_);
         }
         else
         {
            param1.render(_loc4_);
         }
         if(_loc8_)
         {
            _loc4_.eraseMask(_loc8_,param1);
         }
         _loc4_.popState();
         _loc4_.cacheEnabled = _loc6_;
      }
      
      private function renderBundled(param1:Function, param2:DisplayObject = null, param3:Matrix = null, param4:Number = 1, param5:int = 0, param6:Vector3D = null) : void
      {
         var rootTexture:starling.textures.Texture;
         var tmpTexture:starling.textures.Texture = null;
         var renderBlock:Function = param1;
         var object:DisplayObject = param2;
         var matrix:Matrix = param3;
         var alpha:Number = param4;
         var antiAliasing:int = param5;
         var cameraPos:Vector3D = param6;
         var painter:Painter = Starling.painter;
         var state:RenderState = painter.state;
         if(!Starling.current.contextValid)
         {
            return;
         }
         if(this.isDoubleBuffered)
         {
            tmpTexture = this._activeTexture;
            this._activeTexture = this._bufferTexture;
            this._bufferTexture = tmpTexture;
            this._helperImage.texture = this._bufferTexture;
         }
         painter.pushState();
         rootTexture = this._activeTexture.root;
         state.setProjectionMatrix(0,0,rootTexture.width,rootTexture.height,width,height,cameraPos);
         sClipRect.setTo(0,0,this._activeTexture.width,this._activeTexture.height);
         state.clipRect = sClipRect;
         state.setRenderTarget(this._activeTexture,true,antiAliasing);
         painter.prepareToDraw();
         painter.context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK,Context3DCompareMode.ALWAYS);
         if(this.isDoubleBuffered || !this.isPersistent || !this._bufferReady)
         {
            painter.clear();
         }
         if(this.isDoubleBuffered && this._bufferReady)
         {
            this._helperImage.render(painter);
         }
         else
         {
            this._bufferReady = true;
         }
         try
         {
            this._drawing = true;
            execute(renderBlock,object,matrix,alpha);
         }
         finally
         {
            this._drawing = false;
            painter.popState();
         }
      }
      
      public function clear(param1:uint = 0, param2:Number = 0) : void
      {
         this._activeTexture.root.clear(param1,param2);
         this._bufferReady = true;
      }
      
      private function get isDoubleBuffered() : Boolean
      {
         return this._bufferTexture != null;
      }
      
      public function get isPersistent() : Boolean
      {
         return this._isPersistent;
      }
      
      override public function get base() : TextureBase
      {
         return this._activeTexture.base;
      }
      
      override public function get root() : starling.textures.ConcreteTexture
      {
         return this._activeTexture.root;
      }
   }
}
