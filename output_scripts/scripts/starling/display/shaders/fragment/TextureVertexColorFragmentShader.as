package starling.display.shaders.fragment
{
   import flash.display3D.Context3DProgramType;
   import flash.display3D.Context3DTextureFormat;
   import starling.display.shaders.AbstractShader;
   import starling.textures.Texture;
   
   public class TextureVertexColorFragmentShader extends AbstractShader
   {
       
      
      private var textureTypeFormat:String;
      
      public function TextureVertexColorFragmentShader(param1:String = null)
      {
         super();
         this.textureTypeFormat = param1;
      }
      
      override public function updateTextureAgal(param1:Texture) : void
      {
         var _loc2_:String = null;
         switch(this.textureTypeFormat)
         {
            case Context3DTextureFormat.COMPRESSED:
               _loc2_ = "dxt1";
               break;
            case Context3DTextureFormat.COMPRESSED_ALPHA:
               _loc2_ = "dxt5";
               break;
            default:
               _loc2_ = "rgba";
         }
         var _loc3_:* = "tex ft1, v1, fs0 <2d, repeat, linear, " + _loc2_ + "> \n" + "mul ft2, v0, fc0 \n" + "mul oc, ft1, ft2";
         compileAGAL(Context3DProgramType.FRAGMENT,_loc3_);
      }
   }
}
