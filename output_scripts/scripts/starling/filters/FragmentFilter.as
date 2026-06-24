package starling.filters
{
   import flash.display3D.Context3DTextureFormat;
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix3D;
   import flash.geom.Rectangle;
   import starling.core.Starling;
   import starling.core.starling_internal;
   import starling.display.DisplayObject;
   import starling.display.Stage;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   import starling.rendering.FilterEffect;
   import starling.rendering.IndexData;
   import starling.rendering.Painter;
   import starling.rendering.VertexData;
   import starling.textures.Texture;
   import starling.textures.TextureSmoothing;
   import starling.utils.MatrixUtil;
   import starling.utils.Padding;
   import starling.utils.Pool;
   import starling.utils.RectangleUtil;
   
   public class FragmentFilter extends EventDispatcher
   {
      
      private static var sMatrix3D:Matrix3D = new Matrix3D();
       
      
      private var _quad:FilterQuad;
      
      private var _target:DisplayObject;
      
      private var _effect:FilterEffect;
      
      private var _vertexData:VertexData;
      
      private var _indexData:IndexData;
      
      private var _padding:Padding;
      
      private var _helper:FilterHelper;
      
      private var _resolution:Number;
      
      private var _antiAliasing:int;
      
      private var _textureFormat:String;
      
      private var _textureSmoothing:String;
      
      private var _alwaysDrawToBackBuffer:Boolean;
      
      private var _maintainResolutionAcrossPasses:Boolean;
      
      private var _cacheRequested:Boolean;
      
      private var _cached:Boolean;
      
      public function FragmentFilter()
      {
         super();
         this._resolution = 1;
         this._textureFormat = Context3DTextureFormat.BGRA;
         this._textureSmoothing = TextureSmoothing.BILINEAR;
         Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated,false,0,true);
      }
      
      public function dispose() : void
      {
         Starling.current.stage3D.removeEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated);
         if(this._helper)
         {
            this._helper.dispose();
         }
         if(this._effect)
         {
            this._effect.dispose();
         }
         if(this._quad)
         {
            this._quad.dispose();
         }
         this._effect = null;
         this._quad = null;
      }
      
      private function onContextCreated(param1:Object) : void
      {
         this.setRequiresRedraw();
      }
      
      public function render(param1:Painter) : void
      {
         if(this._target == null)
         {
            throw new IllegalOperationError("Cannot render filter without target");
         }
         if(this._target.is3D)
         {
            this._cached = this._cacheRequested = false;
         }
         if(!this._cached || this._cacheRequested)
         {
            this.renderPasses(param1,this._cacheRequested);
            this._cacheRequested = false;
         }
         else if(this._quad.visible)
         {
            this._quad.render(param1);
         }
      }
      
      private function renderPasses(param1:Painter, param2:Boolean) : void
      {
         var _loc9_:Rectangle = null;
         var _loc12_:Texture = null;
         if(this._helper == null)
         {
            this._helper = new FilterHelper(this._textureFormat);
         }
         if(this._quad == null)
         {
            this._quad = new FilterQuad(this._textureSmoothing);
         }
         else
         {
            this._helper.putTexture(this._quad.texture);
            this._quad.texture = null;
         }
         var _loc3_:Rectangle = Pool.getRectangle();
         var _loc4_:Boolean = false;
         var _loc5_:Number = this._resolution;
         var _loc6_:DisplayObject;
         var _loc7_:* = (_loc6_ = this._target.stage || this._target.parent) is Stage;
         var _loc8_:Stage = Starling.current.stage;
         if(!param2 && (this._alwaysDrawToBackBuffer || this._target.requiresRedraw))
         {
            _loc4_ = param1.state.alpha == 1 && (!this._maintainResolutionAcrossPasses || this._resolution == 1);
            param1.excludeFromCache(this._target);
         }
         if(this._target == Starling.current.root)
         {
            _loc8_.getStageBounds(this._target,_loc3_);
         }
         else
         {
            this._target.getBounds(_loc6_,_loc3_);
            if(!param2 && _loc7_)
            {
               _loc9_ = _loc8_.getStageBounds(null,Pool.getRectangle());
               RectangleUtil.intersect(_loc3_,_loc9_,_loc3_);
               Pool.putRectangle(_loc9_);
            }
         }
         this._quad.visible = !_loc3_.isEmpty();
         if(!this._quad.visible)
         {
            Pool.putRectangle(_loc3_);
            return;
         }
         if(this._padding)
         {
            RectangleUtil.extend(_loc3_,this._padding.left,this._padding.right,this._padding.top,this._padding.bottom);
         }
         RectangleUtil.extendToWholePixels(_loc3_,Starling.contentScaleFactor);
         this._helper.textureScale = Starling.contentScaleFactor * this._resolution;
         this._helper.projectionMatrix3D = param1.state.projectionMatrix3D;
         this._helper.renderTarget = param1.state.renderTarget;
         this._helper.clipRect = param1.state.clipRect;
         this._helper.targetBounds = _loc3_;
         this._helper.target = this._target;
         this._helper.start(this.numPasses,_loc4_);
         this._quad.setBounds(_loc3_);
         this._resolution = 1;
         var _loc10_:Boolean = param1.cacheEnabled;
         var _loc11_:Texture = this._helper.getTexture();
         param1.cacheEnabled = false;
         param1.pushState();
         param1.state.alpha = 1;
         param1.state.clipRect = null;
         param1.state.setRenderTarget(_loc11_,true,this._antiAliasing);
         param1.state.setProjectionMatrix(_loc3_.x,_loc3_.y,_loc11_.root.width,_loc11_.root.height,_loc8_.stageWidth,_loc8_.stageHeight,_loc8_.cameraPosition);
         this._target.render(param1);
         param1.finishMeshBatch();
         param1.state.setModelviewMatricesToIdentity();
         _loc12_ = this.process(param1,this._helper,_loc11_);
         param1.popState();
         param1.cacheEnabled = _loc10_;
         if(_loc12_)
         {
            param1.pushState();
            if(this._target.is3D)
            {
               param1.state.setModelviewMatricesToIdentity();
            }
            else
            {
               this._quad.moveVertices(_loc6_,this._target);
            }
            this._quad.texture = _loc12_;
            this._quad.render(param1);
            param1.finishMeshBatch();
            param1.popState();
         }
         this._helper.target = null;
         this._helper.putTexture(_loc11_);
         this._resolution = _loc5_;
         Pool.putRectangle(_loc3_);
      }
      
      public function process(param1:Painter, param2:IFilterHelper, param3:Texture = null, param4:Texture = null, param5:Texture = null, param6:Texture = null) : Texture
      {
         var _loc9_:Matrix3D = null;
         var _loc11_:Texture = null;
         var _loc7_:FilterEffect = this.effect;
         var _loc8_:Texture = param2.getTexture(this._resolution);
         var _loc10_:Rectangle = null;
         if(_loc8_)
         {
            _loc11_ = _loc8_;
            _loc9_ = MatrixUtil.createPerspectiveProjectionMatrix(0,0,_loc8_.root.width / this._resolution,_loc8_.root.height / this._resolution,0,0,null,sMatrix3D);
         }
         else
         {
            _loc10_ = param2.targetBounds;
            _loc11_ = (param2 as FilterHelper).renderTarget;
            _loc9_ = (param2 as FilterHelper).projectionMatrix3D;
            _loc7_.textureSmoothing = this._textureSmoothing;
            param1.state.clipRect = (param2 as FilterHelper).clipRect;
            param1.state.projectionMatrix3D.copyFrom(_loc9_);
         }
         param1.state.renderTarget = _loc11_;
         param1.prepareToDraw();
         param1.drawCount += 1;
         param3.setupVertexPositions(this.vertexData,0,"position",_loc10_);
         param3.setupTextureCoordinates(this.vertexData);
         _loc7_.texture = param3;
         _loc7_.mvpMatrix3D = _loc9_;
         _loc7_.uploadVertexData(this.vertexData);
         _loc7_.uploadIndexData(this.indexData);
         _loc7_.render(0,this.indexData.numTriangles);
         return _loc8_;
      }
      
      protected function createEffect() : FilterEffect
      {
         return new FilterEffect();
      }
      
      public function cache() : void
      {
         this._cached = this._cacheRequested = true;
         this.setRequiresRedraw();
      }
      
      public function clearCache() : void
      {
         this._cached = this._cacheRequested = false;
         this.setRequiresRedraw();
      }
      
      override public function addEventListener(param1:String, param2:Function) : void
      {
         if(param1 == Event.ENTER_FRAME && Boolean(this._target))
         {
            this._target.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
         super.addEventListener(param1,param2);
      }
      
      override public function removeEventListener(param1:String, param2:Function) : void
      {
         if(param1 == Event.ENTER_FRAME && Boolean(this._target))
         {
            this._target.removeEventListener(param1,this.onEnterFrame);
         }
         super.removeEventListener(param1,param2);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         dispatchEvent(param1);
      }
      
      protected function get effect() : FilterEffect
      {
         if(this._effect == null)
         {
            this._effect = this.createEffect();
         }
         return this._effect;
      }
      
      protected function get vertexData() : VertexData
      {
         if(this._vertexData == null)
         {
            this._vertexData = new VertexData(this.effect.vertexFormat,4);
         }
         return this._vertexData;
      }
      
      protected function get indexData() : IndexData
      {
         if(this._indexData == null)
         {
            this._indexData = new IndexData(6);
            this._indexData.addQuad(0,1,2,3);
         }
         return this._indexData;
      }
      
      protected function setRequiresRedraw() : void
      {
         dispatchEventWith(Event.CHANGE);
         if(this._target)
         {
            this._target.setRequiresRedraw();
         }
         if(this._cached)
         {
            this._cacheRequested = true;
         }
      }
      
      public function get numPasses() : int
      {
         return 1;
      }
      
      protected function onTargetAssigned(param1:DisplayObject) : void
      {
      }
      
      public function get padding() : Padding
      {
         if(this._padding == null)
         {
            this._padding = new Padding();
            this._padding.addEventListener(Event.CHANGE,this.setRequiresRedraw);
         }
         return this._padding;
      }
      
      public function set padding(param1:Padding) : void
      {
         this.padding.copyFrom(param1);
      }
      
      public function get isCached() : Boolean
      {
         return this._cached;
      }
      
      public function get resolution() : Number
      {
         return this._resolution;
      }
      
      public function set resolution(param1:Number) : void
      {
         if(param1 != this._resolution)
         {
            if(param1 <= 0)
            {
               throw new ArgumentError("resolution must be > 0");
            }
            this._resolution = param1;
            this.setRequiresRedraw();
         }
      }
      
      protected function get maintainResolutionAcrossPasses() : Boolean
      {
         return this._maintainResolutionAcrossPasses;
      }
      
      protected function set maintainResolutionAcrossPasses(param1:Boolean) : void
      {
         this._maintainResolutionAcrossPasses = param1;
      }
      
      public function get antiAliasing() : int
      {
         return this._antiAliasing;
      }
      
      public function set antiAliasing(param1:int) : void
      {
         if(param1 != this._antiAliasing)
         {
            this._antiAliasing = param1;
            this.setRequiresRedraw();
         }
      }
      
      public function get textureSmoothing() : String
      {
         return this._textureSmoothing;
      }
      
      public function set textureSmoothing(param1:String) : void
      {
         if(param1 != this._textureSmoothing)
         {
            this._textureSmoothing = param1;
            if(this._quad)
            {
               this._quad.textureSmoothing = param1;
            }
            this.setRequiresRedraw();
         }
      }
      
      public function get textureFormat() : String
      {
         return this._textureFormat;
      }
      
      public function set textureFormat(param1:String) : void
      {
         if(param1 != this._textureFormat)
         {
            this._textureFormat = param1;
            if(this._helper)
            {
               this._helper.textureFormat = param1;
            }
            this.setRequiresRedraw();
         }
      }
      
      public function get alwaysDrawToBackBuffer() : Boolean
      {
         return this._alwaysDrawToBackBuffer;
      }
      
      public function set alwaysDrawToBackBuffer(param1:Boolean) : void
      {
         this._alwaysDrawToBackBuffer = param1;
      }
      
      starling_internal function setTarget(param1:DisplayObject) : void
      {
         var _loc2_:DisplayObject = null;
         if(param1 != this._target)
         {
            _loc2_ = this._target;
            this._target = param1;
            if(param1 == null)
            {
               if(this._helper)
               {
                  this._helper.purge();
               }
               if(this._effect)
               {
                  this._effect.purgeBuffers();
               }
               if(this._quad)
               {
                  this._quad.disposeTexture();
               }
            }
            if(_loc2_)
            {
               _loc2_.filter = null;
               _loc2_.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            }
            if(param1)
            {
               if(hasEventListener(Event.ENTER_FRAME))
               {
                  param1.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
               }
               this.onTargetAssigned(param1);
            }
         }
      }
   }
}

import flash.geom.Matrix;
import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.Mesh;
import starling.rendering.IndexData;
import starling.rendering.VertexData;
import starling.textures.Texture;

class FilterQuad extends Mesh
{
   
   private static var sMatrix:Matrix = new Matrix();
    
   
   public function FilterQuad(param1:String)
   {
      var _loc2_:VertexData = new VertexData(null,4);
      _loc2_.numVertices = 4;
      var _loc3_:IndexData = new IndexData(6);
      _loc3_.addQuad(0,1,2,3);
      super(_loc2_,_loc3_);
      textureSmoothing = param1;
      pixelSnapping = false;
   }
   
   override public function dispose() : void
   {
      this.disposeTexture();
      super.dispose();
   }
   
   public function disposeTexture() : void
   {
      if(texture)
      {
         texture.dispose();
         this.texture = null;
      }
   }
   
   public function moveVertices(param1:DisplayObject, param2:DisplayObject) : void
   {
      if(param2.is3D)
      {
         throw new Error("cannot move vertices into 3D space");
      }
      if(param1 != param2)
      {
         param2.getTransformationMatrix(param1,sMatrix).invert();
         vertexData.transformPoints("position",sMatrix);
      }
   }
   
   public function setBounds(param1:flash.geom.Rectangle) : void
   {
      var _loc2_:VertexData = this.vertexData;
      var _loc3_:String = "position";
      _loc2_.setPoint(0,_loc3_,param1.x,param1.y);
      _loc2_.setPoint(1,_loc3_,param1.right,param1.y);
      _loc2_.setPoint(2,_loc3_,param1.x,param1.bottom);
      _loc2_.setPoint(3,_loc3_,param1.right,param1.bottom);
   }
   
   override public function set texture(param1:Texture) : void
   {
      super.texture = param1;
      if(param1)
      {
         param1.setupTextureCoordinates(vertexData);
      }
   }
}
