package starling.styles
{
   import flash.geom.Matrix;
   import flash.geom.Point;
   import starling.core.starling_internal;
   import starling.display.Mesh;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   import starling.rendering.*;
   import starling.textures.ConcreteTexture;
   import starling.textures.Texture;
   import starling.textures.TextureSmoothing;
   
   public class MeshStyle extends EventDispatcher
   {
      
      public static const VERTEX_FORMAT:VertexDataFormat = MeshEffect.VERTEX_FORMAT;
      
      private static var sPoint:Point = new Point();
       
      
      private var _type:Class;
      
      private var _target:Mesh;
      
      private var _texture:Texture;
      
      private var _textureSmoothing:String;
      
      private var _textureRepeat:Boolean;
      
      private var _textureRoot:ConcreteTexture;
      
      private var _vertexData:VertexData;
      
      private var _indexData:IndexData;
      
      public function MeshStyle()
      {
         super();
         this._textureSmoothing = TextureSmoothing.BILINEAR;
         this._type = Object(this).constructor as Class;
      }
      
      public function copyFrom(param1:starling.styles.MeshStyle) : void
      {
         this._texture = param1._texture;
         this._textureRoot = param1._textureRoot;
         this._textureRepeat = param1._textureRepeat;
         this._textureSmoothing = param1._textureSmoothing;
      }
      
      public function clone() : starling.styles.MeshStyle
      {
         var _loc1_:starling.styles.MeshStyle = new this._type();
         _loc1_.copyFrom(this);
         return _loc1_;
      }
      
      public function createEffect() : MeshEffect
      {
         return new MeshEffect();
      }
      
      public function updateEffect(param1:MeshEffect, param2:RenderState) : void
      {
         param1.texture = this._texture;
         param1.textureRepeat = this._textureRepeat;
         param1.textureSmoothing = this._textureSmoothing;
         param1.mvpMatrix3D = param2.mvpMatrix3D;
         param1.alpha = param2.alpha;
         param1.tinted = this._vertexData.tinted;
      }
      
      public function canBatchWith(param1:starling.styles.MeshStyle) : Boolean
      {
         var _loc2_:Texture = null;
         if(this._type == param1._type)
         {
            _loc2_ = param1._texture;
            if(this._texture == null && _loc2_ == null)
            {
               return true;
            }
            if(Boolean(this._texture) && Boolean(_loc2_))
            {
               return this._textureRoot == param1._textureRoot && this._textureSmoothing == param1._textureSmoothing && this._textureRepeat == param1._textureRepeat;
            }
            return false;
         }
         return false;
      }
      
      public function batchVertexData(param1:starling.styles.MeshStyle, param2:int = 0, param3:Matrix = null, param4:int = 0, param5:int = -1) : void
      {
         this._vertexData.copyTo(param1._vertexData,param2,param3,param4,param5);
      }
      
      public function batchIndexData(param1:starling.styles.MeshStyle, param2:int = 0, param3:int = 0, param4:int = 0, param5:int = -1) : void
      {
         this._indexData.copyTo(param1._indexData,param2,param3,param4,param5);
      }
      
      protected function setRequiresRedraw() : void
      {
         if(this._target)
         {
            this._target.setRequiresRedraw();
         }
      }
      
      protected function setVertexDataChanged() : void
      {
         if(this._target)
         {
            this._target.setVertexDataChanged();
         }
      }
      
      protected function setIndexDataChanged() : void
      {
         if(this._target)
         {
            this._target.setIndexDataChanged();
         }
      }
      
      protected function onTargetAssigned(param1:Mesh) : void
      {
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
      
      starling_internal function setTarget(param1:Mesh = null, param2:VertexData = null, param3:IndexData = null) : void
      {
         if(this._target != param1)
         {
            if(this._target)
            {
               this._target.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            }
            if(param2)
            {
               param2.format = this.vertexFormat;
            }
            this._target = param1;
            this._vertexData = param2;
            this._indexData = param3;
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
      
      public function getVertexPosition(param1:int, param2:Point = null) : Point
      {
         return this._vertexData.getPoint(param1,"position",param2);
      }
      
      public function setVertexPosition(param1:int, param2:Number, param3:Number) : void
      {
         this._vertexData.setPoint(param1,"position",param2,param3);
         this.setVertexDataChanged();
      }
      
      public function getVertexAlpha(param1:int) : Number
      {
         return this._vertexData.getAlpha(param1);
      }
      
      public function setVertexAlpha(param1:int, param2:Number) : void
      {
         this._vertexData.setAlpha(param1,"color",param2);
         this.setVertexDataChanged();
      }
      
      public function getVertexColor(param1:int) : uint
      {
         return this._vertexData.getColor(param1);
      }
      
      public function setVertexColor(param1:int, param2:uint) : void
      {
         this._vertexData.setColor(param1,"color",param2);
         this.setVertexDataChanged();
      }
      
      public function getTexCoords(param1:int, param2:Point = null) : Point
      {
         if(this._texture)
         {
            return this._texture.getTexCoords(this._vertexData,param1,"texCoords",param2);
         }
         return this._vertexData.getPoint(param1,"texCoords",param2);
      }
      
      public function setTexCoords(param1:int, param2:Number, param3:Number) : void
      {
         if(this._texture)
         {
            this._texture.setTexCoords(this._vertexData,param1,"texCoords",param2,param3);
         }
         else
         {
            this._vertexData.setPoint(param1,"texCoords",param2,param3);
         }
         this.setVertexDataChanged();
      }
      
      protected function get vertexData() : VertexData
      {
         return this._vertexData;
      }
      
      protected function get indexData() : IndexData
      {
         return this._indexData;
      }
      
      public function get type() : Class
      {
         return this._type;
      }
      
      public function get color() : uint
      {
         if(this._vertexData.numVertices > 0)
         {
            return this._vertexData.getColor(0);
         }
         return 0;
      }
      
      public function set color(param1:uint) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = this._vertexData.numVertices;
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            this._vertexData.setColor(_loc2_,"color",param1);
            _loc2_++;
         }
         if(param1 == 16777215 && this._vertexData.tinted)
         {
            this._vertexData.updateTinted();
         }
         this.setVertexDataChanged();
      }
      
      public function get vertexFormat() : VertexDataFormat
      {
         return VERTEX_FORMAT;
      }
      
      public function get texture() : Texture
      {
         return this._texture;
      }
      
      public function set texture(param1:Texture) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1 != this._texture)
         {
            if(param1)
            {
               _loc3_ = !!this._vertexData ? this._vertexData.numVertices : 0;
               _loc2_ = 0;
               while(_loc2_ < _loc3_)
               {
                  this.getTexCoords(_loc2_,sPoint);
                  param1.setTexCoords(this._vertexData,_loc2_,"texCoords",sPoint.x,sPoint.y);
                  _loc2_++;
               }
               this.setVertexDataChanged();
            }
            else
            {
               this.setRequiresRedraw();
            }
            this._texture = param1;
            this._textureRoot = !!param1 ? param1.root : null;
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
            this.setRequiresRedraw();
         }
      }
      
      public function get textureRepeat() : Boolean
      {
         return this._textureRepeat;
      }
      
      public function set textureRepeat(param1:Boolean) : void
      {
         this._textureRepeat = param1;
      }
      
      public function get target() : Mesh
      {
         return this._target;
      }
   }
}
