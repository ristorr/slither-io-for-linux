package starling.rendering
{
   import flash.display3D.Context3D;
   import starling.textures.Texture;
   import starling.textures.TextureSmoothing;
   import starling.utils.RenderUtil;
   
   public class FilterEffect extends Effect
   {
      
      public static const VERTEX_FORMAT:VertexDataFormat = Effect.VERTEX_FORMAT.extend("texCoords:float2");
      
      public static const STD_VERTEX_SHADER:String = "m44 op, va0, vc0 \n" + "mov v0, va1";
       
      
      private var _texture:Texture;
      
      private var _textureSmoothing:String;
      
      private var _textureRepeat:Boolean;
      
      public function FilterEffect()
      {
         super();
         this._textureSmoothing = TextureSmoothing.BILINEAR;
      }
      
      protected static function tex(param1:String, param2:String, param3:int, param4:Texture, param5:Boolean = true) : String
      {
         return RenderUtil.createAGALTexOperation(param1,param2,param3,param4,param5);
      }
      
      override protected function get programVariantName() : uint
      {
         return RenderUtil.getTextureVariantBits(this._texture);
      }
      
      override protected function createProgram() : Program
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         if(this._texture)
         {
            _loc1_ = STD_VERTEX_SHADER;
            _loc2_ = tex("oc","v0",0,this._texture);
            return Program.fromSource(_loc1_,_loc2_);
         }
         return super.createProgram();
      }
      
      override protected function beforeDraw(param1:Context3D) : void
      {
         var _loc2_:Boolean = false;
         super.beforeDraw(param1);
         if(this._texture)
         {
            _loc2_ = this._textureRepeat && this._texture.root.isPotTexture;
            RenderUtil.setSamplerStateAt(0,this._texture.mipMapping,this._textureSmoothing,_loc2_);
            param1.setTextureAt(0,this._texture.base);
            this.vertexFormat.setVertexBufferAt(1,vertexBuffer,"texCoords");
         }
      }
      
      override protected function afterDraw(param1:Context3D) : void
      {
         if(this._texture)
         {
            param1.setTextureAt(0,null);
            param1.setVertexBufferAt(1,null);
         }
         super.afterDraw(param1);
      }
      
      override public function get vertexFormat() : VertexDataFormat
      {
         return VERTEX_FORMAT;
      }
      
      public function get texture() : Texture
      {
         return this._texture;
      }
      
      public function set texture(param1:Texture) : void
      {
         this._texture = param1;
      }
      
      public function get textureSmoothing() : String
      {
         return this._textureSmoothing;
      }
      
      public function set textureSmoothing(param1:String) : void
      {
         this._textureSmoothing = param1;
      }
      
      public function get textureRepeat() : Boolean
      {
         return this._textureRepeat;
      }
      
      public function set textureRepeat(param1:Boolean) : void
      {
         this._textureRepeat = param1;
      }
   }
}
