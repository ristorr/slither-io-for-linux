package starling.display.materials
{
   import flash.display3D.Context3D;
   import flash.display3D.Context3DProgramType;
   import flash.display3D.Context3DTextureFormat;
   import flash.display3D.Context3DVertexBufferFormat;
   import flash.display3D.IndexBuffer3D;
   import flash.display3D.Program3D;
   import flash.display3D.VertexBuffer3D;
   import flash.geom.Matrix3D;
   import starling.display.shaders.IShader;
   import starling.display.shaders.fragment.TextureVertexColorFragmentShader;
   import starling.display.shaders.fragment.VertexColorFragmentShader;
   import starling.display.shaders.vertex.StandardVertexShader;
   import starling.textures.Texture;
   import starling.textures.TextureSmoothing;
   import starling.utils.RenderUtil;
   
   public class StandardMaterial implements starling.display.materials.IMaterial
   {
      
      public static var COLOR_VERTEX_SHADER:IShader = new StandardVertexShader();
      
      public static var COLOR_FRAGMENT_SHADER:IShader = new VertexColorFragmentShader();
      
      public static var TEXTURE_FRAGMENT_SHADER_COMPRESSED:IShader = new TextureVertexColorFragmentShader(Context3DTextureFormat.COMPRESSED);
      
      public static var TEXTURE_FRAGMENT_SHADER_COMPRESSED_ALPHA:IShader = new TextureVertexColorFragmentShader(Context3DTextureFormat.COMPRESSED_ALPHA);
      
      public static var TEXTURE_FRAGMENT_SHADER_COLOR:IShader = new TextureVertexColorFragmentShader();
      
      private static var finalAlpha:Number;
       
      
      private var program:Program3D;
      
      private var _vertexShader:IShader;
      
      private var _fragmentShader:IShader;
      
      private var _alpha:Number = 1;
      
      private var _color:uint;
      
      private var _colorVector:Vector.<Number>;
      
      private var _materialTexture:Texture;
      
      public function StandardMaterial()
      {
         super();
         this._vertexShader = COLOR_VERTEX_SHADER;
         this._fragmentShader = COLOR_FRAGMENT_SHADER;
         this._colorVector = new Vector.<Number>();
         this._color = 16777215;
      }
      
      public function set texture(param1:Texture) : void
      {
         this._materialTexture = param1;
         if(this._materialTexture)
         {
            if(this._materialTexture.format === Context3DTextureFormat.COMPRESSED)
            {
               this._fragmentShader = TEXTURE_FRAGMENT_SHADER_COMPRESSED;
            }
            else if(this._materialTexture.format === Context3DTextureFormat.COMPRESSED_ALPHA)
            {
               this._fragmentShader = TEXTURE_FRAGMENT_SHADER_COMPRESSED_ALPHA;
            }
            else
            {
               this._fragmentShader = TEXTURE_FRAGMENT_SHADER_COLOR;
            }
         }
         else
         {
            this._fragmentShader = COLOR_FRAGMENT_SHADER;
         }
      }
      
      public function get texture() : Texture
      {
         return this._materialTexture;
      }
      
      public function dispose() : void
      {
         if(this.program)
         {
            starling.display.materials.Program3DCache.releaseProgram3D(this.program);
            this.program = null;
         }
         this._vertexShader = null;
         this._fragmentShader = null;
      }
      
      public function restoreOnLostContext() : void
      {
         if(this.program)
         {
            starling.display.materials.Program3DCache.releaseProgram3D(this.program,true);
            this.program = null;
         }
      }
      
      public function set vertexShader(param1:IShader) : void
      {
         this._vertexShader = param1;
         if(this.program)
         {
            starling.display.materials.Program3DCache.releaseProgram3D(this.program);
            this.program = null;
         }
      }
      
      public function get vertexShader() : IShader
      {
         return this._vertexShader;
      }
      
      public function set fragmentShader(param1:IShader) : void
      {
         this._fragmentShader = param1;
         if(this.program)
         {
            starling.display.materials.Program3DCache.releaseProgram3D(this.program);
            this.program = null;
         }
      }
      
      public function get fragmentShader() : IShader
      {
         return this._fragmentShader;
      }
      
      public function get alpha() : Number
      {
         return this._alpha;
      }
      
      public function set alpha(param1:Number) : void
      {
         this._alpha = param1;
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set color(param1:uint) : void
      {
         this._color = param1;
      }
      
      public function drawTriangles(param1:Context3D, param2:Matrix3D, param3:VertexBuffer3D, param4:IndexBuffer3D, param5:Number = 1, param6:int = -1) : void
      {
         param1.setVertexBufferAt(0,param3,0,Context3DVertexBufferFormat.FLOAT_3);
         param1.setVertexBufferAt(1,param3,3,Context3DVertexBufferFormat.FLOAT_4);
         param1.setVertexBufferAt(2,param3,7,Context3DVertexBufferFormat.FLOAT_2);
         if(!this.program)
         {
            if(this._materialTexture)
            {
               this._fragmentShader.updateTextureAgal(this._materialTexture);
            }
            this.program = starling.display.materials.Program3DCache.getProgram3D(param1,this._vertexShader,this._fragmentShader);
         }
         param1.setProgram(this.program);
         if(this._materialTexture)
         {
            RenderUtil.setSamplerStateAt(0,false,TextureSmoothing.TRILINEAR,true);
            param1.setTextureAt(0,this._materialTexture.base);
         }
         param1.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,0,param2,true);
         this._vertexShader.setConstants(param1,4);
         finalAlpha = this._alpha * param5;
         this._colorVector[0] = (this._color >> 16) / 255 * finalAlpha;
         this._colorVector[1] = ((this._color & 65280) >> 8) / 255 * finalAlpha;
         this._colorVector[2] = (this._color & 255) / 255 * finalAlpha;
         this._colorVector[3] = finalAlpha;
         param1.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,this._colorVector);
         this._fragmentShader.setConstants(param1,1);
         param1.drawTriangles(param4,0,param6);
      }
   }
}
